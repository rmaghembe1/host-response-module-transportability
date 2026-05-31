#!/usr/bin/env Rscript

# GSE161731 fixed-module scoring rehearsal
# Purpose: technical rehearsal only. Score locked GSE211567 modules in GSE161731 using fixed genes and unweighted mean z-scores.
# Boundary: technical scoring rehearsal only; not formal validation, not module rediscovery, not biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

voom_file <- "results/qc/GSE161731_technical_rehearsal/GSE161731_technical_rehearsal_voom_objects.rds"
coverage_dir <- "results/module_projection_rehearsal/GSE161731_identifier_coverage_audit"
module_dir <- "results/module_scoring/GSE211567_projection_ready_inputs"
metadata_file <- "data/metadata_harmonized/GSE161731_technical_rehearsal_eligibility.tsv"

out_dir <- "results/module_projection_rehearsal/GSE161731_fixed_module_scoring"
fig_dir <- "results/figures/GSE161731_fixed_module_scoring_rehearsal"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading GSE161731 voom expression object...")
voom_obj <- readRDS(voom_file)

expr <- NULL
if (is.list(voom_obj) && "voom" %in% names(voom_obj)) expr <- voom_obj$voom$E
if (is.null(expr) && is.list(voom_obj) && "E" %in% names(voom_obj)) expr <- voom_obj$E
if (is.null(expr) && is.matrix(voom_obj)) expr <- voom_obj
if (is.null(expr)) stop("Could not identify expression matrix in voom object.")

message("Reading module coverage/mapping and metadata...")
match_table <- fread(file.path(coverage_dir, "GSE161731_projection_rehearsal_gene_level_identifier_match_table.tsv"))
module_metadata <- fread(file.path(module_dir, "GSE211567_projection_ready_module_metadata.tsv"))
elig <- fread(metadata_file)

# Prepare metadata sample ID column robustly by overlap with expression sample IDs.
sample_ids <- colnames(expr)

candidate_cols <- names(elig)[vapply(elig, function(x) is.character(x) || is.factor(x), logical(1))]
if (length(candidate_cols) == 0) {
  stop("No character/factor columns found in GSE161731 eligibility metadata for sample matching.")
}

overlap_dt <- rbindlist(lapply(candidate_cols, function(cc) {
  vals <- as.character(elig[[cc]])
  data.table(
    column = cc,
    overlap_with_expression_samples = sum(vals %in% sample_ids),
    nonmissing_values = sum(!is.na(vals) & vals != "")
  )
}))

setorder(overlap_dt, -overlap_with_expression_samples, -nonmissing_values)

sample_col <- overlap_dt[overlap_with_expression_samples > 0, column][1]
if (is.na(sample_col)) {
  stop(
    "Could not identify metadata sample ID column by overlap with expression sample IDs. ",
    "Inspect metadata columns with: Rscript -e '.libPaths(\"env/R_libs\"); library(data.table); x<-fread(\"",
    metadata_file,
    "\"); print(names(x)); print(head(x))'"
  )
}

message("Selected metadata sample ID column: ", sample_col)
setnames(elig, sample_col, "sample_id_for_scoring")

# Identify group column robustly.
group_candidates <- c(
  "technical_rehearsal_group",
  "discovery_group",
  "infection_group",
  "group",
  "diagnosis_group",
  "pathogen_class",
  "infection_type",
  "etiology"
)

group_col <- group_candidates[group_candidates %in% names(elig)][1]

if (is.na(group_col)) {
  # Fallback: choose a low-cardinality character/factor column that is not the sample ID.
  possible_group_cols <- setdiff(candidate_cols, sample_col)
  group_overlap <- rbindlist(lapply(possible_group_cols, function(cc) {
    vals <- as.character(elig[[cc]])
    data.table(
      column = cc,
      n_unique = uniqueN(vals[!is.na(vals) & vals != ""]),
      example_values = paste(head(unique(vals[!is.na(vals) & vals != ""]), 6), collapse = ";")
    )
  }))
  group_overlap <- group_overlap[n_unique >= 2 & n_unique <= 10]
  setorder(group_overlap, n_unique)
  group_col <- group_overlap$column[1]
}

if (is.na(group_col)) {
  warning("Could not identify group column in metadata; module scores will be saved without group summaries.")
  elig[, scoring_group := NA_character_]
} else {
  message("Selected metadata group column: ", group_col)
  elig[, scoring_group := as.character(get(group_col))]
}

# Restrict metadata to expression samples.
sample_dt <- data.table(sample_id_for_scoring = sample_ids)
sample_meta <- merge(sample_dt, elig, by = "sample_id_for_scoring", all.x = TRUE)

# Save metadata-matching diagnostics.
metadata_match_diagnostics <- overlap_dt

# Build gene-wise z-score matrix within GSE161731.
message("Gene-wise z-scoring expression matrix...")
zexpr <- t(scale(t(expr)))
zexpr[is.na(zexpr)] <- 0

# For each module, use matched ENSEMBL IDs available in GSE161731.
matched <- match_table[matched_by_ensembl == TRUE]
matched[, matched_ensembl_list := strsplit(matched_ensembl_ids, ";", fixed = TRUE)]

module_scores_list <- list()
module_coverage_rows <- list()

for (mid in sort(unique(matched$final_module_id))) {
  sub <- matched[final_module_id == mid]
  ens_ids <- unique(unlist(sub$matched_ensembl_list))
  ens_ids <- ens_ids[ens_ids %in% rownames(zexpr)]

  if (length(ens_ids) == 0) {
    next
  }

  scores <- colMeans(zexpr[ens_ids, , drop = FALSE], na.rm = TRUE)

  module_label <- unique(sub$final_module_label)[1]
  module_direction <- unique(sub$module_direction)[1]

  module_scores_list[[mid]] <- data.table(
    sample_id_for_scoring = names(scores),
    final_module_id = mid,
    final_module_label = module_label,
    module_direction = module_direction,
    module_score_unweighted_zmean = as.numeric(scores),
    n_genes_scored = length(ens_ids)
  )

  module_coverage_rows[[mid]] <- data.table(
    final_module_id = mid,
    final_module_label = module_label,
    module_direction = module_direction,
    n_locked_genes = uniqueN(sub$ENTREZID),
    n_genes_scored = length(ens_ids),
    coverage_pct = round(100 * uniqueN(sub[matched_by_ensembl == TRUE, ENTREZID]) / uniqueN(sub$ENTREZID), 2),
    n_ensembl_features_scored = length(ens_ids)
  )
}

module_scores_long <- rbindlist(module_scores_list, fill = TRUE)
module_coverage <- rbindlist(module_coverage_rows, fill = TRUE)

module_scores_long <- merge(module_scores_long, sample_meta, by = "sample_id_for_scoring", all.x = TRUE)

module_scores_wide <- dcast(
  module_scores_long,
  sample_id_for_scoring ~ final_module_id,
  value.var = "module_score_unweighted_zmean"
)

# Technical group summaries only, no biological claims.
if ("scoring_group" %in% names(module_scores_long)) {
  group_summary <- module_scores_long[, .(
    n_samples = .N,
    median_score = median(module_score_unweighted_zmean, na.rm = TRUE),
    mean_score = mean(module_score_unweighted_zmean, na.rm = TRUE),
    sd_score = sd(module_score_unweighted_zmean, na.rm = TRUE),
    q25_score = quantile(module_score_unweighted_zmean, 0.25, na.rm = TRUE),
    q75_score = quantile(module_score_unweighted_zmean, 0.75, na.rm = TRUE)
  ), by = .(final_module_id, final_module_label, module_direction, scoring_group)]
} else {
  group_summary <- data.table()
}

# Save.
fwrite(module_scores_long, file.path(out_dir, "GSE161731_fixed_module_scores_long.tsv"), sep = "\t")
fwrite(module_scores_wide, file.path(out_dir, "GSE161731_fixed_module_scores_wide.tsv"), sep = "\t")
fwrite(module_coverage, file.path(out_dir, "GSE161731_fixed_module_scoring_coverage.tsv"), sep = "\t")
fwrite(group_summary, file.path(out_dir, "GSE161731_fixed_module_score_group_summary.tsv"), sep = "\t")

# Plot score distributions.
p1 <- ggplot(module_scores_long, aes(x = final_module_id, y = module_score_unweighted_zmean)) +
  geom_boxplot() +
  theme_bw() +
  labs(
    title = "GSE161731 fixed-module scoring rehearsal",
    x = "Locked GSE211567 module",
    y = "Unweighted mean z-score"
  )

ggsave(file.path(fig_dir, "GSE161731_fixed_module_score_distributions.png"), p1, width = 8, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE161731_fixed_module_score_distributions.pdf"), p1, width = 8, height = 5)

if ("scoring_group" %in% names(module_scores_long) && any(!is.na(module_scores_long$scoring_group))) {
  p2 <- ggplot(module_scores_long, aes(x = scoring_group, y = module_score_unweighted_zmean)) +
    geom_boxplot() +
    facet_wrap(~ final_module_id, scales = "free_y") +
    theme_bw() +
    labs(
      title = "GSE161731 fixed-module scores by technical rehearsal group",
      x = "Technical rehearsal group",
      y = "Unweighted mean z-score"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  ggsave(file.path(fig_dir, "GSE161731_fixed_module_scores_by_group.png"), p2, width = 10, height = 6, dpi = 300)
  ggsave(file.path(fig_dir, "GSE161731_fixed_module_scores_by_group.pdf"), p2, width = 10, height = 6)
}

sink(file.path(session_dir, "GSE161731_fixed_module_scoring_rehearsal_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE161731_fixed_module_scoring_rehearsal_report.md")

writeLines(c(
  "# GSE161731 Fixed-Module Scoring Rehearsal Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: technical rehearsal of locked GSE211567 module scoring in GSE161731.",
  "- Boundary: no validation, no module rediscovery and no biological interpretation.",
  "",
  "## Input",
  "",
  paste0("- Expression features: ", nrow(expr)),
  paste0("- Expression samples: ", ncol(expr)),
  paste0("- Module score rows generated: ", nrow(module_scores_long)),
  "",
  "## Module scoring coverage",
  "",
  paste(capture.output(print(module_coverage)), collapse = "\n"),
  "",
  "## Technical group score summary",
  "",
  paste(capture.output(print(group_summary)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- Module genes, labels and directions were fixed from GSE211567.",
  "- Scores were computed using unweighted mean z-score scoring.",
  "- GSE161731 is used here only as a technical projection rehearsal resource.",
  "- These results must not be described as external validation or transportability evidence.",
  "",
  "## Generated files",
  "",
  "- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scores_long.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scores_wide.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scoring_coverage.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_score_group_summary.tsv`",
  "- `results/figures/GSE161731_fixed_module_scoring_rehearsal/GSE161731_fixed_module_score_distributions.png/.pdf`",
  "- `results/figures/GSE161731_fixed_module_scoring_rehearsal/GSE161731_fixed_module_scores_by_group.png/.pdf`",
  "- `env/session_info/GSE161731_fixed_module_scoring_rehearsal_sessionInfo.txt`"
), con = report_file)

message("GSE161731 fixed-module scoring rehearsal complete.")
message("Report: ", report_file)
