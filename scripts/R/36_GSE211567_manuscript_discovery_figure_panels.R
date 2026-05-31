#!/usr/bin/env Rscript

# GSE211567 manuscript discovery figure panels
# Purpose: generate manuscript-facing discovery/module-locking figure panels from existing GSE211567 outputs.
# Boundary: figure generation only; no new modelling, no gene reselection, no module redefinition.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

source("scripts/R/00_publication_figure_export_helpers.R")

fig_dir <- "results/figures/GSE211567_manuscript_discovery_panels"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

# Input files from existing locked workflow outputs.
primary_limma_file <- "results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv"
site_correlation_file <- "results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_logFC_correlation_summary.tsv"
site_direction_file <- "results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_direction_concordance_summary.tsv"
stability_file <- "results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stability_tier_summary.tsv"
module_label_file <- "results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_table.tsv"
module_gene_file <- "results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv"

message("Checking expected input files...")
input_files <- c(primary_limma_file, site_correlation_file, site_direction_file, stability_file, module_label_file, module_gene_file)
missing_files <- input_files[!file.exists(input_files)]

if (length(missing_files) > 0) {
  message("Missing expected files:")
  message(paste(missing_files, collapse = "\n"))
  stop("One or more expected input files are missing. Inspect file paths before continuing.")
}

message("Reading GSE211567 primary limma result...")
limma_dt <- fread(primary_limma_file)

# Harmonize common limma column names.
if (!("logFC" %in% names(limma_dt))) {
  logfc_candidates <- names(limma_dt)[grepl("logFC|log2FC|log_fold", names(limma_dt), ignore.case = TRUE)]
  if (length(logfc_candidates) == 0) stop("No logFC-like column found.")
  setnames(limma_dt, logfc_candidates[1], "logFC")
}
if (!("P.Value" %in% names(limma_dt))) {
  p_candidates <- names(limma_dt)[grepl("^P\\.Value$|p_value|pval|PValue", names(limma_dt), ignore.case = TRUE)]
  if (length(p_candidates) == 0) stop("No P.Value-like column found.")
  setnames(limma_dt, p_candidates[1], "P.Value")
}
if (!("adj.P.Val" %in% names(limma_dt))) {
  fdr_candidates <- names(limma_dt)[grepl("adj.*P|FDR|BH", names(limma_dt), ignore.case = TRUE)]
  if (length(fdr_candidates) == 0) stop("No adjusted-P/FDR-like column found.")
  setnames(limma_dt, fdr_candidates[1], "adj.P.Val")
}

limma_dt[, neg_log10_p := -log10(pmax(P.Value, .Machine$double.xmin))]
limma_dt[, direction := fifelse(logFC > 0, "Bacterial-higher", "Viral-higher")]
limma_dt[, fdr_class := fifelse(adj.P.Val < 0.05, "BH FDR < 0.05", "Not FDR-significant")]

p_volcano <- ggplot(limma_dt, aes(x = logFC, y = neg_log10_p)) +
  geom_point(aes(shape = fdr_class), alpha = 0.35, size = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "GSE211567 primary bacterial-versus-viral discovery contrast",
    subtitle = "Volcano-style overview of primary limma result",
    x = "log2 fold-change: bacterial versus viral",
    y = expression(-log[10]("nominal P value")),
    shape = NULL
  ) +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank())

save_publication_figure(
  plot = p_volcano,
  filename_base = "Figure_GSE211567_A_primary_discovery_volcano",
  out_dir = fig_dir,
  width = 7.5,
  height = 5.5,
  dpi = 1800
)

message("Reading site-stratified concordance summaries...")
site_cor <- fread(site_correlation_file)
site_dir <- fread(site_direction_file)

# Direction-concordance table has matching all-feature rows with "_all_features" suffix.
# Keep only those pairwise all-feature rows and strip the suffix before merging.
site_dir_pairwise <- site_dir[
  grepl("_all_features$", comparison) &
    !grepl("^all_three", comparison)
]
site_dir_pairwise[, comparison := sub("_all_features$", "", comparison)]

site_plot <- merge(site_cor, site_dir_pairwise, by = "comparison", all.x = TRUE)

if (!("spearman_logFC" %in% names(site_plot))) {
  stop("Expected column spearman_logFC not found in site correlation file.")
}
if (!("pct_concordant" %in% names(site_plot))) {
  stop("Expected column pct_concordant not found after harmonizing direction-concordance rows.")
}
if (any(is.na(site_plot$spearman_logFC)) || any(is.na(site_plot$pct_concordant))) {
  print(site_plot)
  stop("Panel B site concordance merge produced missing values.")
}

site_plot[, comparison_label := gsub("_", " ", comparison)]
site_plot[, comparison_label := factor(comparison_label, levels = rev(comparison_label))]

p_site <- ggplot(site_plot, aes(x = comparison_label, y = spearman_logFC)) +
  geom_col(width = 0.6) +
  geom_text(
    aes(label = paste0(round(pct_concordant, 1), "% direction concordant")),
    hjust = -0.05,
    size = 3
  ) +
  coord_flip() +
  expand_limits(y = max(site_plot$spearman_logFC, na.rm = TRUE) + 0.12) +
  labs(
    title = "Site-aware stability of the GSE211567 discovery contrast",
    subtitle = "LogFC correlation with directional concordance across pooled and site-stratified analyses",
    x = NULL,
    y = "Spearman logFC concordance"
  ) +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank())

save_publication_figure(
  plot = p_site,
  filename_base = "Figure_GSE211567_B_site_stratified_concordance_summary",
  out_dir = fig_dir,
  width = 8,
  height = 4.8,
  dpi = 1800
)

message("Reading final discovery module labels...")
modules <- fread(module_label_file)

if (!("final_module_id" %in% names(modules))) {
  module_id_candidates <- names(modules)[grepl("module.*id|^module_id$", names(modules), ignore.case = TRUE)]
  if (length(module_id_candidates) == 0) stop("No module ID column found.")
  setnames(modules, module_id_candidates[1], "final_module_id")
}
if (!("final_module_label" %in% names(modules))) {
  label_candidates <- names(modules)[grepl("module.*label|label|name", names(modules), ignore.case = TRUE)]
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
    modules[, final_module_direction := fifelse(grepl("^BACT", final_module_id), "Higher in bacterial",
                                         fifelse(grepl("^VIR", final_module_id), "Higher in viral", "Not specified"))]
  }
}

message("Reading projection-ready module genes...")
module_genes <- fread(module_gene_file)

if (!("final_module_id" %in% names(module_genes))) {
  module_id_candidates <- names(module_genes)[grepl("module.*id|^module_id$", names(module_genes), ignore.case = TRUE)]
  if (length(module_id_candidates) == 0) stop("No module ID column found in module gene table.")
  setnames(module_genes, module_id_candidates[1], "final_module_id")
}

gene_count <- module_genes[, .(locked_genes_n = uniqueN(SYMBOL)), by = final_module_id]
module_plot <- merge(unique(modules[, .(final_module_id, final_module_label, final_module_direction)]),
                     gene_count,
                     by = "final_module_id",
                     all.x = TRUE)

module_order <- c("BACT_M1", "BACT_M2", "VIR_M1a", "VIR_M1b", "VIR_M2")
module_plot[, final_module_id := factor(final_module_id, levels = module_order)]
module_plot[, final_module_direction := fifelse(grepl("^BACT", as.character(final_module_id)), "Higher in bacterial",
                                         fifelse(grepl("^VIR", as.character(final_module_id)), "Higher in viral", final_module_direction))]

p_modules <- ggplot(module_plot, aes(x = final_module_id, y = locked_genes_n, fill = final_module_direction)) +
  geom_col(width = 0.65) +
  labs(
    title = "Locked GSE211567 discovery modules",
    subtitle = "Projection-ready fixed gene sets carried forward to external testing",
    x = "Locked module",
    y = "Locked genes",
    fill = "Discovery direction"
  ) +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank())

save_publication_figure(
  plot = p_modules,
  filename_base = "Figure_GSE211567_C_locked_discovery_module_gene_counts",
  out_dir = fig_dir,
  width = 7.5,
  height = 5,
  dpi = 1800
)

caption_file <- file.path(docs_dir, "GSE211567_manuscript_discovery_figure_caption.md")
sink(caption_file)
cat("# Figure Caption Draft — GSE211567 Discovery and Module Locking\n\n")
cat("Figure X. GSE211567 discovery analysis and conservative module locking. ")
cat("(A) Primary bacterial-versus-viral limma contrast shown as a volcano-style overview. ")
cat("(B) Site-aware concordance summary used to assess whether the discovery contrast was directionally stable across pooled and site-stratified analyses. ")
cat("(C) Locked discovery modules and their projection-ready gene counts. ")
cat("Modules were defined and locked before external projection, preserving the discovery/projection firewall and preventing gene reselection or module redefinition in validation cohorts.\n")
sink()

writeLines(capture.output(sessionInfo()), "env/session_info/GSE211567_manuscript_discovery_figure_panels_sessionInfo.txt")

message("Wrote GSE211567 manuscript discovery figure panels to: ", fig_dir)
message("Wrote caption: ", caption_file)
