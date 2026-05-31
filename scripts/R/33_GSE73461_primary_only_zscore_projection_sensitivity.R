#!/usr/bin/env Rscript

# GSE73461 primary-only z-score fixed-module projection sensitivity
# Purpose: sensitivity analysis scoring locked GSE211567 modules in GSE73461 after z-scoring genes using only DefiniteBacterial and DefiniteViral samples.
# Boundary: fixed-module projection only; no gene reselection, module renaming, reweighting, or diagnostic model discovery.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

norm_expr_file <- "data/expression_raw/GSE73461/GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz"
probe_ann_file <- "results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_illuminaHumanv4_probe_annotation_join.tsv"
module_gene_file <- "results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv"
sample_table_file <- "results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_sample_table.tsv"

out_dir <- "results/module_projection/GSE73461_primary_only_zscore_sensitivity"
fig_dir <- "results/figures/GSE73461_primary_only_zscore_sensitivity"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading normalized GSE73461 expression matrix...")
expr <- fread(norm_expr_file, showProgress = FALSE)

# Normalized file has ARRAY_ID as first column and expression/detection columns afterward.
id_col <- names(expr)[1]
setnames(expr, id_col, "ARRAY_ID")
expr[, ARRAY_ID := as.character(ARRAY_ID)]

expr_cols <- names(expr)[!grepl("_Detection_Pval$", names(expr))]
expr_cols <- setdiff(expr_cols, "ARRAY_ID")

detect_cols <- names(expr)[grepl("_Detection_Pval$", names(expr))]

message("Expression features: ", nrow(expr))
message("Expression sample columns: ", length(expr_cols))
message("Detection P-value columns: ", length(detect_cols))

message("Reading probe annotation...")
probe_ann <- fread(probe_ann_file)
probe_ann[, ARRAY_ID := as.character(ARRAY_ID)]
probe_ann[, SYMBOL := as.character(SYMBOL)]
probe_ann[, ENTREZID := as.character(ENTREZID)]
probe_ann[, SYMBOL_UPPER := toupper(SYMBOL)]

# Restrict annotation to usable symbol/entrez mappings.
probe_ann_use <- unique(probe_ann[
  !is.na(SYMBOL_UPPER) & SYMBOL_UPPER != "" &
    !is.na(ENTREZID) & ENTREZID != "",
  .(ARRAY_ID, ID_REF, SYMBOL, SYMBOL_UPPER, ENTREZID)
])

message("Reading locked module gene table...")
modules <- fread(module_gene_file)

# Harmonize locked-module columns.
if (!("final_module_id" %in% names(modules))) {
  module_id_candidates <- names(modules)[grepl("module.*id|^module_id$", names(modules), ignore.case = TRUE)]
  if (length(module_id_candidates) == 0) stop("No module ID column detected.")
  setnames(modules, module_id_candidates[1], "final_module_id")
}
if (!("final_module_label" %in% names(modules))) {
  label_candidates <- names(modules)[grepl("module.*label|module.*name|label", names(modules), ignore.case = TRUE)]
  if (length(label_candidates) > 0) {
    setnames(modules, label_candidates[1], "final_module_label")
  } else {
    modules[, final_module_label := final_module_id]
  }
}
if (!("final_module_direction" %in% names(modules))) {
  direction_candidates <- names(modules)[grepl("direction|orientation|sign", names(modules), ignore.case = TRUE)]
  if (length(direction_candidates) > 0) {
    setnames(modules, direction_candidates[1], "final_module_direction")
  } else {
    modules[, final_module_direction := fifelse(grepl("^BACT", final_module_id), "higher_in_bacterial",
                                         fifelse(grepl("^VIR", final_module_id), "higher_in_viral", "not_specified"))]
  }
}
if (!("SYMBOL" %in% names(modules))) {
  symbol_candidates <- names(modules)[grepl("^symbol$|gene_symbol|hgnc", names(modules), ignore.case = TRUE)]
  if (length(symbol_candidates) == 0) stop("No SYMBOL column detected.")
  setnames(modules, symbol_candidates[1], "SYMBOL")
}
if (!("ENTREZID" %in% names(modules))) {
  entrez_candidates <- names(modules)[grepl("entrez", names(modules), ignore.case = TRUE)]
  if (length(entrez_candidates) > 0) {
    setnames(modules, entrez_candidates[1], "ENTREZID")
  } else {
    modules[, ENTREZID := NA_character_]
  }
}

modules[, SYMBOL := as.character(SYMBOL)]
modules[, SYMBOL_UPPER := toupper(SYMBOL)]
modules[, ENTREZID := as.character(ENTREZID)]

modules <- unique(modules[, .(
  final_module_id,
  final_module_label,
  final_module_direction,
  SYMBOL,
  SYMBOL_UPPER,
  ENTREZID
)])

message("Reading locked GSE73461 projection sample table...")
sample_table <- fread(sample_table_file)
sample_table[, base_sample_id := as.character(base_sample_id)]
sample_table[, sample_group := as.character(sample_group)]
sample_table[, projection_role := as.character(projection_role)]

primary_samples <- sample_table[
  projection_role %in% c("primary_bacterial", "primary_viral"),
  .(base_sample_id, sample_group, projection_role)
]

excluded_control_samples <- sample_table[
  projection_role == "secondary_control_context",
  .(base_sample_id, sample_group, projection_role)
]

projection_samples <- primary_samples[base_sample_id %in% expr_cols]

if (nrow(projection_samples) == 0) {
  stop("No primary projection samples found in expression matrix.")
}

message("Projection samples available: ", nrow(projection_samples))
message("Primary bacterial samples: ", nrow(projection_samples[projection_role == "primary_bacterial"]))
message("Primary viral samples: ", nrow(projection_samples[projection_role == "primary_viral"]))
message("Secondary control samples excluded from this sensitivity: ", nrow(excluded_control_samples[base_sample_id %in% expr_cols]))

expr_projection <- expr[, c("ARRAY_ID", projection_samples$base_sample_id), with = FALSE]
expr_long_ann <- merge(probe_ann_use, expr_projection, by = "ARRAY_ID", allow.cartesian = TRUE)

expr_mat <- as.matrix(expr_long_ann[, projection_samples$base_sample_id, with = FALSE])
mode(expr_mat) <- "numeric"

expr_long_ann[, median_expression := apply(expr_mat, 1, median, na.rm = TRUE)]

setorder(expr_long_ann, SYMBOL_UPPER, -median_expression, ARRAY_ID)
gene_probe_choice <- expr_long_ann[, .SD[1], by = SYMBOL_UPPER]

gene_expr <- gene_probe_choice[, c("SYMBOL_UPPER", "SYMBOL", "ENTREZID", projection_samples$base_sample_id), with = FALSE]

# Convert to matrix and z-score each gene across all projected GSE73461 samples.
gene_ids <- gene_expr$SYMBOL_UPPER
gene_expr_mat <- as.matrix(gene_expr[, projection_samples$base_sample_id, with = FALSE])
mode(gene_expr_mat) <- "numeric"
rownames(gene_expr_mat) <- gene_ids

gene_means <- rowMeans(gene_expr_mat, na.rm = TRUE)
gene_sds <- apply(gene_expr_mat, 1, sd, na.rm = TRUE)
gene_sds[is.na(gene_sds) | gene_sds == 0] <- NA_real_

gene_z <- sweep(gene_expr_mat, 1, gene_means, "-")
gene_z <- sweep(gene_z, 1, gene_sds, "/")

available_symbols <- rownames(gene_z)

score_rows <- list()
coverage_rows <- list()

for (mid in sort(unique(modules$final_module_id))) {
  m <- modules[final_module_id == mid]
  locked_symbols <- unique(m$SYMBOL_UPPER)
  matched_symbols <- intersect(locked_symbols, available_symbols)
  missing_symbols <- setdiff(locked_symbols, available_symbols)

  if (length(matched_symbols) == 0) {
    warning("No matched genes for module: ", mid)
    next
  }

  module_score <- colMeans(gene_z[matched_symbols, , drop = FALSE], na.rm = TRUE)

  score_rows[[mid]] <- data.table(
    base_sample_id = names(module_score),
    final_module_id = mid,
    final_module_label = m$final_module_label[1],
    final_module_direction = m$final_module_direction[1],
    module_score = as.numeric(module_score),
    matched_genes_n = length(matched_symbols),
    locked_genes_n = length(locked_symbols),
    coverage_fraction = length(matched_symbols) / length(locked_symbols)
  )

  coverage_rows[[mid]] <- data.table(
    final_module_id = mid,
    final_module_label = m$final_module_label[1],
    final_module_direction = m$final_module_direction[1],
    locked_genes_n = length(locked_symbols),
    matched_genes_n = length(matched_symbols),
    missing_genes_n = length(missing_symbols),
    coverage_fraction = length(matched_symbols) / length(locked_symbols),
    missing_symbols = paste(sort(missing_symbols), collapse = ";")
  )
}

scores_long <- rbindlist(score_rows, use.names = TRUE)
coverage <- rbindlist(coverage_rows, use.names = TRUE)

scores_long <- merge(scores_long, projection_samples, by = "base_sample_id", all.x = TRUE)
setorder(scores_long, final_module_id, projection_role, base_sample_id)

scores_wide <- dcast(
  scores_long,
  base_sample_id + sample_group + projection_role ~ final_module_id,
  value.var = "module_score"
)

group_summary <- scores_long[
  projection_role %in% c("primary_bacterial", "primary_viral"),
  .(
    n = .N,
    mean_score = mean(module_score, na.rm = TRUE),
    median_score = median(module_score, na.rm = TRUE),
    sd_score = sd(module_score, na.rm = TRUE),
    q25 = quantile(module_score, 0.25, na.rm = TRUE),
    q75 = quantile(module_score, 0.75, na.rm = TRUE)
  ),
  by = .(final_module_id, final_module_label, final_module_direction, projection_role, sample_group)
]

primary_test <- scores_long[
  projection_role %in% c("primary_bacterial", "primary_viral"),
  {
    bact <- module_score[projection_role == "primary_bacterial"]
    viral <- module_score[projection_role == "primary_viral"]
    wt <- wilcox.test(bact, viral, exact = FALSE)
    .(
      n_bacterial = length(bact),
      n_viral = length(viral),
      mean_bacterial = mean(bact, na.rm = TRUE),
      mean_viral = mean(viral, na.rm = TRUE),
      median_bacterial = median(bact, na.rm = TRUE),
      median_viral = median(viral, na.rm = TRUE),
      median_difference_bacterial_minus_viral = median(bact, na.rm = TRUE) - median(viral, na.rm = TRUE),
      wilcox_p = wt$p.value
    )
  },
  by = .(final_module_id, final_module_label, final_module_direction)
]
primary_test[, wilcox_p_BH := p.adjust(wilcox_p, method = "BH")]
primary_test[, expected_direction_match := fifelse(
  final_module_direction == "higher_in_bacterial",
  median_difference_bacterial_minus_viral > 0,
  fifelse(final_module_direction == "higher_in_viral",
          median_difference_bacterial_minus_viral < 0,
          NA)
)]

fwrite(coverage, file.path(out_dir, "GSE73461_primary_only_zscore_sensitivity_coverage.tsv"), sep = "\t")
fwrite(scores_long, file.path(out_dir, "GSE73461_primary_only_zscore_scores_long.tsv"), sep = "\t")
fwrite(scores_wide, file.path(out_dir, "GSE73461_primary_only_zscore_scores_wide.tsv"), sep = "\t")
fwrite(group_summary, file.path(out_dir, "GSE73461_primary_only_zscore_score_group_summary.tsv"), sep = "\t")
fwrite(primary_test, file.path(out_dir, "GSE73461_primary_only_zscore_primary_projection_tests.tsv"), sep = "\t")
fwrite(gene_probe_choice[, .(SYMBOL_UPPER, SYMBOL, ENTREZID, ARRAY_ID, ID_REF, median_expression)],
       file.path(out_dir, "GSE73461_gene_probe_choice_for_projection.tsv"), sep = "\t")

# Figures
plot_dt <- scores_long[projection_role %in% c("primary_bacterial", "primary_viral")]
plot_dt[, projection_role := factor(projection_role, levels = c("primary_bacterial", "primary_viral"))]

p1 <- ggplot(plot_dt, aes(x = projection_role, y = module_score)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.45, size = 1.2) +
  facet_wrap(~ final_module_id, scales = "free_y") +
  labs(
    title = "GSE73461 fixed-module projection scores",
    subtitle = "Primary contrast only: DefiniteBacterial vs DefiniteViral",
    x = "Projection group",
    y = "Unweighted mean z-score"
  ) +
  theme_bw(base_size = 11) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave(file.path(fig_dir, "GSE73461_primary_only_zscore_scores_primary_groups.png"), p1, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "GSE73461_primary_only_zscore_scores_primary_groups.pdf"), p1, width = 10, height = 6)

p2 <- ggplot(primary_test, aes(x = final_module_id, y = median_difference_bacterial_minus_viral)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "GSE73461 median module-score difference",
    subtitle = "Positive = higher in DefiniteBacterial; negative = higher in DefiniteViral",
    x = "Locked module",
    y = "Median difference: bacterial minus viral"
  ) +
  theme_bw(base_size = 11)

ggsave(file.path(fig_dir, "GSE73461_primary_only_zscore_primary_median_differences.png"), p2, width = 8, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE73461_primary_only_zscore_primary_median_differences.pdf"), p2, width = 8, height = 5)

report_file <- "docs/GSE73461_primary_only_zscore_projection_sensitivity_report.md"
sink(report_file)
cat("# GSE73461 Primary-Only Z-Score Fixed-Module Projection Sensitivity Report\n\n")
cat("- Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("- Purpose: sensitivity analysis scoring locked GSE211567 modules in GSE73461 after z-scoring genes using only DefiniteBacterial and DefiniteViral samples.\n")
cat("- Boundary: fixed-module projection only. No module rediscovery, gene reselection, reweighting, renaming or diagnostic model training was performed.\n\n")

cat("## Projection cohort\n\n")
cat("- Primary bacterial samples:", nrow(projection_samples[projection_role == "primary_bacterial"]), "\n")
cat("- Primary viral samples:", nrow(projection_samples[projection_role == "primary_viral"]), "\n")
cat("- Secondary control/context samples excluded:", nrow(projection_samples[projection_role == "secondary_control_context"]), "\n\n")

cat("## Module coverage used for scoring\n\n")
print(coverage)
cat("\n## Primary bacterial-versus-viral projection tests\n\n")
print(primary_test)
cat("\n## Interpretation boundary\n\n")
cat("- These are fixed-module projection scores in the locked external cohort.\n")
cat("- Statistical results assess transportability of pre-locked modules, not new diagnostic-signature discovery.\n")
cat("- Any biological interpretation must preserve the discovery/projection firewall and report direction concordance explicitly.\n\n")

cat("## Generated files\n\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_sensitivity_coverage.tsv`\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_long.tsv`\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_wide.tsv`\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_score_group_summary.tsv`\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`\n")
cat("- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_gene_probe_choice_for_projection.tsv`\n")
cat("- `results/figures/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_primary_groups.png/.pdf`\n")
cat("- `results/figures/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_median_differences.png/.pdf`\n")
sink()

writeLines(capture.output(sessionInfo()), "env/session_info/GSE73461_primary_only_zscore_sensitivity_scoring_sessionInfo.txt")

message("Wrote report: ", report_file)
print(primary_test)
