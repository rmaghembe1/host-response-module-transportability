#!/usr/bin/env Rscript

# GSE211567 module scoring inputs and projection rules
# Purpose: build projection-ready module gene-set tables from locked final discovery modules.
# Boundary: scoring input construction only; no external projection or validation is performed here.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

module_dir <- "results/module_lock/GSE211567_final_discovery_module_labels"
out_dir <- "results/module_scoring/GSE211567_projection_ready_inputs"
fig_dir <- "results/figures/GSE211567_module_scoring_inputs"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

label_file <- file.path(module_dir, "GSE211567_final_discovery_module_label_table.tsv")
compact_file <- file.path(module_dir, "GSE211567_final_discovery_module_label_compact_table.tsv")
gene_file <- file.path(module_dir, "GSE211567_final_discovery_module_genes.tsv")
term_file <- file.path(module_dir, "GSE211567_final_discovery_module_GO_terms.tsv")

message("Reading final discovery-module labels and genes...")
labels <- fread(label_file)
compact <- fread(compact_file)
genes <- fread(gene_file)
terms <- fread(term_file)

# Ensure one row per final_module_id + ENTREZID for projection.
genes[, ENTREZID := as.character(ENTREZID)]

# Some upstream locked module-gene tables may not carry every optional annotation field.
# Create missing optional fields explicitly so projection exports remain schema-stable.
optional_cols <- c("ENSEMBL", "GENENAME", "selected_refseq_feature_id")
for (cc in optional_cols) {
  if (!(cc %in% names(genes))) {
    genes[, (cc) := NA_character_]
  }
}

genes[, abs_pooled_logFC := abs(pooled_logFC)]

gene_sets <- genes[
  order(final_module_id, ENTREZID, pooled_adj.P.Val, -abs_pooled_logFC)
][
  , .SD[1],
  by = .(final_module_id, ENTREZID)
]

# Primary projection rule: unweighted mean z-score.
# Optional sensitivity rule: sign-aware or abs-logFC weighting can be evaluated later, not primary.
gene_sets[, primary_scoring_weight := 1]

# Direction sign for possible later composite interpretation.
gene_sets[, module_direction_sign := fifelse(module_direction == "higher_in_bacterial", 1L, -1L)]

# Optional bounded weights: normalized abs(logFC), capped to avoid dominance.
gene_sets[, optional_abs_logFC_weight_raw := abs(pooled_logFC)]
gene_sets[, optional_abs_logFC_weight := optional_abs_logFC_weight_raw / median(optional_abs_logFC_weight_raw, na.rm = TRUE), by = final_module_id]
gene_sets[optional_abs_logFC_weight > 3, optional_abs_logFC_weight := 3]
gene_sets[optional_abs_logFC_weight < 0.25, optional_abs_logFC_weight := 0.25]

# Projection-ready table.
projection_gene_table <- gene_sets[, .(
  final_module_id,
  final_module_label,
  final_module_status,
  module_direction,
  module_direction_sign,
  ENTREZID,
  SYMBOL,
  ENSEMBL,
  GENENAME,
  selected_refseq_feature_id,
  pooled_logFC,
  pooled_adj.P.Val,
  Sri_Lanka_logFC,
  United_States_logFC,
  stability_tier,
  primary_scoring_weight,
  optional_abs_logFC_weight,
  scoring_role = "module_gene",
  primary_scoring_rule = "unweighted_mean_z_score",
  optional_sensitivity_rule = "bounded_abs_logFC_weighted_mean_z_score"
)]

setorder(projection_gene_table, final_module_id, SYMBOL, ENTREZID)

# Per-module gene lists.
module_summary <- projection_gene_table[, .(
  n_genes = uniqueN(ENTREZID),
  n_symbols = uniqueN(SYMBOL),
  median_pooled_logFC = median(pooled_logFC, na.rm = TRUE),
  min_pooled_logFC = min(pooled_logFC, na.rm = TRUE),
  max_pooled_logFC = max(pooled_logFC, na.rm = TRUE),
  median_optional_abs_logFC_weight = median(optional_abs_logFC_weight, na.rm = TRUE),
  top_symbols = paste(head(unique(SYMBOL[order(pooled_adj.P.Val)]), 50), collapse = ";")
), by = .(
  final_module_id,
  final_module_label,
  final_module_status,
  module_direction,
  module_direction_sign
)]

setorder(module_summary, final_module_id)

# GMT-style outputs.
gmt_lines_symbol <- projection_gene_table[
  , paste(
    final_module_id,
    final_module_label,
    paste(unique(na.omit(SYMBOL)), collapse = "\t"),
    sep = "\t"
  ),
  by = final_module_id
]$V1

gmt_lines_entrez <- projection_gene_table[
  , paste(
    final_module_id,
    final_module_label,
    paste(unique(na.omit(ENTREZID)), collapse = "\t"),
    sep = "\t"
  ),
  by = final_module_id
]$V1

# Module metadata table.
module_metadata <- unique(projection_gene_table[, .(
  final_module_id,
  final_module_label,
  final_module_status,
  module_direction,
  module_direction_sign,
  primary_scoring_rule,
  optional_sensitivity_rule
)])

module_metadata <- merge(
  module_metadata,
  module_summary[, .(final_module_id, n_genes, n_symbols, median_pooled_logFC, top_symbols)],
  by = "final_module_id",
  all.x = TRUE
)

setorder(module_metadata, final_module_id)

# Projection rules.
projection_rules <- data.table(
  rule_id = c(
    "R1_input_identifier",
    "R2_primary_scoring",
    "R3_scaling",
    "R4_missing_gene_rule",
    "R5_minimum_gene_coverage",
    "R6_direction_handling",
    "R7_weighted_scoring",
    "R8_external_projection_boundary",
    "R9_no_retraining",
    "R10_reporting"
  ),
  rule = c(
    "Projection should use gene-level identifiers. SYMBOL may be used for cross-platform matching, with ENTREZID retained as the locked discovery identifier.",
    "Primary module score is the unweighted mean of per-gene z-scored expression values for genes available in the external cohort.",
    "Within each external dataset, expression values should be z-scored gene-wise across samples before module scoring.",
    "Missing genes are ignored for a module score, but coverage must be reported.",
    "A module should be considered projection-eligible only if at least 50% of its locked genes are available after identifier matching; stricter 70% coverage can be used as sensitivity.",
    "Module direction is retained as discovered: bacterial-higher modules have direction sign +1; viral-higher modules have direction sign -1. Do not flip module direction using external outcomes.",
    "Weighted scoring using bounded absolute pooled logFC weights is optional sensitivity only and must not replace the primary unweighted score.",
    "External projection tests transportability of fixed discovery modules; it does not redefine modules, reweight genes, or select new genes.",
    "No external cohort should be used to reselect genes, rename modules, or adjust module composition.",
    "Report gene coverage, score distributions, group contrasts, and whether direction agrees with GSE211567 discovery orientation."
  )
)

# Save outputs.
fwrite(projection_gene_table, file.path(out_dir, "GSE211567_projection_ready_module_gene_table.tsv"), sep = "\t")
fwrite(module_summary, file.path(out_dir, "GSE211567_projection_ready_module_summary.tsv"), sep = "\t")
fwrite(module_metadata, file.path(out_dir, "GSE211567_projection_ready_module_metadata.tsv"), sep = "\t")
fwrite(projection_rules, file.path(out_dir, "GSE211567_projection_scoring_rules.tsv"), sep = "\t")

writeLines(gmt_lines_symbol, file.path(out_dir, "GSE211567_projection_ready_modules_SYMBOL.gmt"))
writeLines(gmt_lines_entrez, file.path(out_dir, "GSE211567_projection_ready_modules_ENTREZID.gmt"))

# One file per module for easy external projection.
for (mid in unique(projection_gene_table$final_module_id)) {
  sub <- projection_gene_table[final_module_id == mid]
  fwrite(
    sub,
    file.path(out_dir, paste0("module_", mid, "_genes.tsv")),
    sep = "\t"
  )
}

# Plot module gene counts.
plot_dt <- copy(module_summary)
plot_dt[, module_plot_label := paste(final_module_id, final_module_label, sep = " | ")]
plot_dt[, module_plot_label := factor(module_plot_label, levels = rev(module_plot_label))]

p1 <- ggplot(plot_dt, aes(x = module_plot_label, y = n_genes)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 projection-ready module gene counts",
    x = "Module",
    y = "Locked genes"
  )

ggsave(file.path(fig_dir, "GSE211567_projection_ready_module_gene_counts.png"), p1, width = 11, height = 5.5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_projection_ready_module_gene_counts.pdf"), p1, width = 11, height = 5.5)

# Plot optional weight distributions.
p2 <- ggplot(projection_gene_table, aes(x = final_module_id, y = optional_abs_logFC_weight)) +
  geom_boxplot() +
  theme_bw() +
  labs(
    title = "Optional bounded abs(logFC) weights by module",
    x = "Module",
    y = "Optional bounded abs(logFC) weight"
  )

ggsave(file.path(fig_dir, "GSE211567_optional_module_weight_distributions.png"), p2, width = 8, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_optional_module_weight_distributions.pdf"), p2, width = 8, height = 5)

sink(file.path(session_dir, "GSE211567_module_scoring_inputs_projection_rules_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_module_scoring_inputs_projection_rules_report.md")

writeLines(c(
  "# GSE211567 Module Scoring Inputs and Projection Rules Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: construct projection-ready module scoring inputs from locked final GSE211567 discovery modules.",
  "- Boundary: scoring input construction only. No external projection, validation or transportability claim is performed here.",
  "",
  "## Projection-ready module summary",
  "",
  paste(capture.output(print(module_summary)), collapse = "\n"),
  "",
  "## Scoring rules",
  "",
  paste(capture.output(print(projection_rules)), collapse = "\n"),
  "",
  "## Primary scoring rule",
  "",
  "- Use unweighted mean z-score module scoring as the primary projection method.",
  "- Z-score expression gene-wise within each external dataset before module scoring.",
  "- Ignore missing genes but report coverage for every module.",
  "- Require at least 50% locked-gene coverage for projection eligibility; optionally repeat with 70% coverage as sensitivity.",
  "",
  "## Optional sensitivity rule",
  "",
  "- Bounded abs(logFC)-weighted scoring is provided only as sensitivity.",
  "- Do not use weighted scoring as the primary result because it risks overfitting to GSE211567 effect sizes.",
  "",
  "## Interpretation boundary",
  "",
  "- These module inputs are locked discovery-module gene sets.",
  "- External datasets must not be used to reselect genes, rename modules, or alter module weights for the primary analysis.",
  "- External projection should be described as transportability testing, not discovery.",
  "",
  "## Generated files",
  "",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_summary.tsv`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_metadata.tsv`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_scoring_rules.tsv`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_modules_SYMBOL.gmt`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_modules_ENTREZID.gmt`",
  "- `results/module_scoring/GSE211567_projection_ready_inputs/module_<MODULE_ID>_genes.tsv`",
  "- `results/figures/GSE211567_module_scoring_inputs/GSE211567_projection_ready_module_gene_counts.png/.pdf`",
  "- `results/figures/GSE211567_module_scoring_inputs/GSE211567_optional_module_weight_distributions.png/.pdf`",
  "- `env/session_info/GSE211567_module_scoring_inputs_projection_rules_sessionInfo.txt`"
), con = report_file)

message("Module scoring inputs and projection rules complete.")
message("Report: ", report_file)
