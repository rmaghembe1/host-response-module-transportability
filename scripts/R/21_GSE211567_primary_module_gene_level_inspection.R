#!/usr/bin/env Rscript

# GSE211567 primary candidate-module gene-level inspection
# Purpose: inspect overlap genes, site-aware stability and possible merge relationships among primary candidate modules.
# Boundary: inspection only; not final module naming, manuscript interpretation or external validation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

decision_dir <- "results/module_lock/GSE211567_manual_module_decisions"
out_dir <- "results/module_lock/GSE211567_primary_module_gene_inspection"
fig_dir <- "results/figures/GSE211567_primary_module_gene_inspection"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

decision_file <- file.path(decision_dir, "GSE211567_manual_module_decision_table.tsv")
genes_file <- file.path(decision_dir, "GSE211567_manual_module_decision_overlap_genes_long.tsv")
terms_file <- file.path(decision_dir, "GSE211567_manual_module_decision_GO_term_membership.tsv")

message("Reading manual module decision outputs...")
modules <- fread(decision_file)
genes <- fread(genes_file)
terms <- fread(terms_file)

primary_modules <- modules[review_decision_tier == "primary_candidate_module"]
primary_genes <- genes[review_decision_tier == "primary_candidate_module"]
primary_terms <- terms[review_decision_tier == "primary_candidate_module"]

# The manual decision overlap-gene table does not carry all_three_concordant directly.
# Reconstruct it from stability_tier: Tier 1–3 are the site-aware all-direction-concordant eligible tiers.
if (!("all_three_concordant" %in% names(primary_genes))) {
  primary_genes[, all_three_concordant := grepl("^Tier_[123]_", stability_tier)]
}

message("Primary candidate module rows: ", nrow(primary_modules))
message("Primary-module gene rows: ", nrow(primary_genes))
message("Primary-module GO term rows: ", nrow(primary_terms))

# Unique module row key
primary_modules[, primary_module_key := paste(
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  sep = " | "
)]

primary_genes[, primary_module_key := paste(
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  sep = " | "
)]

primary_terms[, primary_module_key := paste(
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  sep = " | "
)]

# Gene-level summaries per primary module
# Collapse to one row per module-gene before computing gene-level percentages.
primary_genes_unique <- primary_genes[
  order(primary_module_key, ENTREZID, pooled_adj.P.Val, -abs(pooled_logFC))
][
  , .SD[1],
  by = .(primary_module_key, ENTREZID)
]

primary_gene_summary <- primary_genes_unique[, .(
  gene_rows = .N,
  unique_entrez = uniqueN(ENTREZID),
  unique_symbols = uniqueN(SYMBOL),
  median_pooled_logFC = median(pooled_logFC, na.rm = TRUE),
  min_pooled_logFC = min(pooled_logFC, na.rm = TRUE),
  max_pooled_logFC = max(pooled_logFC, na.rm = TRUE),
  median_Sri_Lanka_logFC = median(Sri_Lanka_logFC, na.rm = TRUE),
  median_United_States_logFC = median(United_States_logFC, na.rm = TRUE),
  all_three_concordant_genes = uniqueN(ENTREZID[all_three_concordant == TRUE]),
  tier1_genes = uniqueN(ENTREZID[stability_tier == "Tier_1_cross_site_FDR05_direction_concordant"]),
  tier2_genes = uniqueN(ENTREZID[stability_tier == "Tier_2_pooled_FDR05_all_direction_concordant_one_site_FDR05"]),
  tier3_genes = uniqueN(ENTREZID[stability_tier == "Tier_3_pooled_FDR05_all_direction_concordant_site_nominal_or_weaker"])
), by = .(
  primary_module_key,
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  review_decision_tier,
  final_claim_status
)]

primary_gene_summary[, pct_all_three_concordant := round(100 * all_three_concordant_genes / unique_entrez, 2)]
primary_gene_summary[, pct_tier1 := round(100 * tier1_genes / unique_entrez, 2)]
primary_gene_summary[, pct_tier1_to_3 := round(100 * (tier1_genes + tier2_genes + tier3_genes) / unique_entrez, 2)]

setorder(primary_gene_summary, module_direction, provisional_module_label)

# Top genes per module by pooled FDR then absolute logFC
primary_genes[, abs_pooled_logFC := abs(pooled_logFC)]
setorder(primary_genes, primary_module_key, pooled_adj.P.Val, -abs_pooled_logFC)

top_genes_by_module <- primary_genes[, head(.SD, 30), by = primary_module_key]

# Compact top-symbol summary
top_symbol_summary <- top_genes_by_module[, .(
  top_30_symbols = paste(unique(na.omit(SYMBOL)), collapse = ";"),
  top_30_entrez = paste(unique(na.omit(ENTREZID)), collapse = ";")
), by = primary_module_key]

primary_gene_summary <- merge(primary_gene_summary, top_symbol_summary, by = "primary_module_key", all.x = TRUE)

# Term summary
primary_term_summary <- primary_terms[, .(
  n_GO_terms = .N,
  n_FDR05_GO_terms = sum(FDR05 == TRUE, na.rm = TRUE),
  GO_terms = paste(paste0(GO, ":", TERM), collapse = " | "),
  best_GO_FDR = min(p_adj_BH, na.rm = TRUE)
), by = primary_module_key]

primary_gene_summary <- merge(primary_gene_summary, primary_term_summary, by = "primary_module_key", all.x = TRUE)

# Pairwise module overlap based on unique ENTREZ IDs
module_keys <- unique(primary_genes$primary_module_key)

pairwise <- rbindlist(lapply(seq_along(module_keys), function(i) {
  rbindlist(lapply(seq_along(module_keys), function(j) {
    a_key <- module_keys[i]
    b_key <- module_keys[j]
    a <- unique(primary_genes[primary_module_key == a_key, as.character(ENTREZID)])
    b <- unique(primary_genes[primary_module_key == b_key, as.character(ENTREZID)])
    shared <- intersect(a, b)
    union <- union(a, b)
    data.table(
      module_A = a_key,
      module_B = b_key,
      genes_A = length(a),
      genes_B = length(b),
      shared_genes = length(shared),
      union_genes = length(union),
      jaccard_gene_overlap = ifelse(length(union) > 0, length(shared) / length(union), 0),
      shared_gene_ids = paste(sort(shared), collapse = ";")
    )
  }))
}))

# Add shared symbols
symbol_lookup <- unique(primary_genes[, .(ENTREZID = as.character(ENTREZID), SYMBOL)])
symbol_map <- setNames(symbol_lookup$SYMBOL, symbol_lookup$ENTREZID)

pairwise[, shared_symbols := vapply(shared_gene_ids, function(x) {
  if (is.na(x) || x == "") return("")
  ids <- unlist(strsplit(x, ";", fixed = TRUE))
  paste(unique(na.omit(symbol_map[ids])), collapse = ";")
}, character(1))]

# Merge assessment for antiviral/interferon primary rows
ifn_keys <- unique(primary_modules[
  review_decision_tier == "primary_candidate_module" &
    module_direction == "higher_in_viral" &
    grepl("Antiviral / interferon-response", provisional_module_label, fixed = TRUE),
  primary_module_key
])

ifn_merge_assessment <- data.table(
  assessment = character(),
  value = character()
)

if (length(ifn_keys) >= 2) {
  ifn_pair <- pairwise[module_A %in% ifn_keys & module_B %in% ifn_keys & module_A != module_B]
  ifn_pair <- ifn_pair[order(-jaccard_gene_overlap)][1]

  ifn_merge_assessment <- data.table(
    assessment = c(
      "n_primary_antiviral_interferon_rows",
      "max_pairwise_jaccard_between_antiviral_interferon_rows",
      "shared_genes_between_closest_antiviral_interferon_rows",
      "provisional_recommendation"
    ),
    value = c(
      as.character(length(ifn_keys)),
      as.character(round(ifn_pair$jaccard_gene_overlap, 4)),
      as.character(ifn_pair$shared_genes),
      ifelse(
        ifn_pair$jaccard_gene_overlap >= 0.25,
        "consider_merging_antiviral_interferon_rows_after_manual_gene_review",
        "retain_as_related_antiviral_interferon_submodules_pending_manual_review"
      )
    )
  )
} else {
  ifn_merge_assessment <- data.table(
    assessment = c("n_primary_antiviral_interferon_rows", "provisional_recommendation"),
    value = c(as.character(length(ifn_keys)), "merge_assessment_not_applicable")
  )
}

# Inspection flags
primary_gene_summary[, inspection_flag := fifelse(
  pct_all_three_concordant < 90,
  "review_site_concordance_before_module_naming",
  fifelse(
    n_GO_terms < 2,
    "single_GO_term_or_compact_module_review_carefully",
    "passes_initial_gene_level_inspection"
  )
)]

# Save outputs
fwrite(primary_modules, file.path(out_dir, "GSE211567_primary_module_rows_for_gene_inspection.tsv"), sep = "\t")
fwrite(primary_terms, file.path(out_dir, "GSE211567_primary_module_GO_terms_for_inspection.tsv"), sep = "\t")
fwrite(primary_genes, file.path(out_dir, "GSE211567_primary_module_overlap_genes_for_inspection.tsv"), sep = "\t")
fwrite(primary_gene_summary, file.path(out_dir, "GSE211567_primary_module_gene_level_summary.tsv"), sep = "\t")
fwrite(top_genes_by_module, file.path(out_dir, "GSE211567_primary_module_top30_genes_by_module.tsv"), sep = "\t")
fwrite(pairwise, file.path(out_dir, "GSE211567_primary_module_pairwise_gene_overlap.tsv"), sep = "\t")
fwrite(ifn_merge_assessment, file.path(out_dir, "GSE211567_primary_antiviral_interferon_merge_assessment.tsv"), sep = "\t")

# Plots
plot_dt <- copy(primary_gene_summary)
plot_dt[, plot_label := paste(module_direction, provisional_module_label, evidence_grade, sep = " | ")]
plot_dt[, plot_label := factor(plot_label, levels = rev(unique(plot_label)))]

p1 <- ggplot(plot_dt, aes(x = plot_label, y = unique_entrez)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 primary candidate modules: overlap-gene counts",
    x = "Primary candidate module",
    y = "Unique ENTREZ genes"
  )

ggsave(file.path(fig_dir, "GSE211567_primary_module_gene_counts.png"), p1, width = 10, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_primary_module_gene_counts.pdf"), p1, width = 10, height = 5)

p2 <- ggplot(plot_dt, aes(x = plot_label, y = pct_all_three_concordant)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 primary candidate modules: all-three direction concordance",
    x = "Primary candidate module",
    y = "% genes all-three direction concordant"
  )

ggsave(file.path(fig_dir, "GSE211567_primary_module_all_three_concordance.png"), p2, width = 10, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_primary_module_all_three_concordance.pdf"), p2, width = 10, height = 5)

sink(file.path(session_dir, "GSE211567_primary_module_gene_level_inspection_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_primary_module_gene_level_inspection_report.md")

writeLines(c(
  "# GSE211567 Primary Candidate-Module Gene-Level Inspection Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: inspect overlap genes, site-aware stability and merge relationships among primary candidate modules.",
  "- Boundary: inspection only. This is not final module naming, manuscript interpretation or external validation.",
  "",
  "## Primary candidate-module input",
  "",
  paste0("- Primary candidate module rows: ", nrow(primary_modules)),
  paste0("- Primary-module GO term rows: ", nrow(primary_terms)),
  paste0("- Primary-module overlap-gene rows: ", nrow(primary_genes)),
  "",
  "## Primary module gene-level summary",
  "",
  paste(capture.output(print(primary_gene_summary[, .(
    module_direction,
    provisional_module_label,
    evidence_grade,
    unique_entrez,
    n_GO_terms,
    n_FDR05_GO_terms,
    pct_all_three_concordant,
    pct_tier1_to_3,
    best_GO_FDR,
    inspection_flag,
    top_30_symbols
  )])), collapse = "\n"),
  "",
  "## Antiviral/interferon merge assessment",
  "",
  paste(capture.output(print(ifn_merge_assessment)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- This inspection prioritizes gene-level coherence and site-aware stability.",
  "- Primary candidate modules are still not final manuscript claims.",
  "- Any final module naming should occur only after reviewing top genes, GO-term membership and pairwise overlap.",
  "- The two antiviral/interferon primary rows should be merged only if gene overlap and biological content support a single coherent programme.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_rows_for_gene_inspection.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_GO_terms_for_inspection.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_overlap_genes_for_inspection.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_gene_level_summary.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_top30_genes_by_module.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_pairwise_gene_overlap.tsv`",
  "- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_antiviral_interferon_merge_assessment.tsv`",
  "- `results/figures/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_gene_counts.png/.pdf`",
  "- `results/figures/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_all_three_concordance.png/.pdf`",
  "- `env/session_info/GSE211567_primary_module_gene_level_inspection_sessionInfo.txt`"
), con = report_file)

message("Primary candidate-module gene-level inspection complete.")
message("Report: ", report_file)
