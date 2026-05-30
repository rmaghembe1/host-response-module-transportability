#!/usr/bin/env Rscript

# GSE161731 technical QC review
# Purpose: evaluate technical adequacy of the completed count-level QC/voom rehearsal.
# No differential expression, no pathway enrichment, no module selection, no biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

qc_dir <- "results/qc/GSE161731_technical_rehearsal"
docs_dir <- "docs"
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)

sample_qc_file <- file.path(qc_dir, "GSE161731_sample_level_qc_summary.tsv")
norm_file <- file.path(qc_dir, "GSE161731_TMM_normalization_factors.tsv")
pca_file <- file.path(qc_dir, "GSE161731_voom_PCA_coordinates.tsv")
filter_file <- file.path(qc_dir, "GSE161731_filtering_summary.tsv")

sample_qc <- fread(sample_qc_file)
norm <- fread(norm_file)
pca <- fread(pca_file)
filter_summary <- fread(filter_file)

# Merge key QC summaries
qc <- merge(sample_qc, norm[, .(rna_id, norm.factors)], by = "rna_id", all.x = TRUE)
qc <- merge(qc, pca[, .(rna_id, PC1, PC2)], by = "rna_id", all.x = TRUE)

# Robust outlier helpers
flag_iqr <- function(x, multiplier = 1.5) {
  q <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  lower <- q[1] - multiplier * iqr
  upper <- q[2] + multiplier * iqr
  list(lower = lower, upper = upper, flag = x < lower | x > upper)
}

lib_flag <- flag_iqr(qc$library_size)
det_flag <- flag_iqr(qc$detected_genes_count_gt0)
nf_flag <- flag_iqr(qc$norm.factors)

qc[, library_size_outlier_iqr := lib_flag$flag]
qc[, detected_genes_outlier_iqr := det_flag$flag]
qc[, norm_factor_outlier_iqr := nf_flag$flag]
qc[, any_qc_outlier_iqr := library_size_outlier_iqr | detected_genes_outlier_iqr | norm_factor_outlier_iqr]
qc[, caution_flagged_metadata := caution_flags != "none"]

fwrite(qc, file.path(qc_dir, "GSE161731_integrated_technical_qc_review_table.tsv"), sep = "\t")

# Summary tables
group_summary <- qc[, .(
  n = .N,
  median_library_size = median(library_size),
  min_library_size = min(library_size),
  max_library_size = max(library_size),
  median_detected_genes = median(detected_genes_count_gt0),
  min_detected_genes = min(detected_genes_count_gt0),
  max_detected_genes = max(detected_genes_count_gt0),
  median_norm_factor = median(norm.factors),
  min_norm_factor = min(norm.factors),
  max_norm_factor = max(norm.factors),
  n_any_iqr_outlier = sum(any_qc_outlier_iqr),
  n_metadata_caution_flagged = sum(caution_flagged_metadata)
), by = group]

fwrite(group_summary, file.path(qc_dir, "GSE161731_technical_qc_group_summary.tsv"), sep = "\t")

outlier_table <- qc[any_qc_outlier_iqr == TRUE | caution_flagged_metadata == TRUE,
                    .(rna_id, group, metadata_status, caution_flags,
                      library_size, detected_genes_count_gt0, norm.factors,
                      PC1, PC2,
                      library_size_outlier_iqr,
                      detected_genes_outlier_iqr,
                      norm_factor_outlier_iqr,
                      caution_flagged_metadata)]

fwrite(outlier_table, file.path(qc_dir, "GSE161731_technical_qc_outliers_and_caution_samples.tsv"), sep = "\t")

# Caution samples only
caution_only <- qc[caution_flagged_metadata == TRUE,
                   .(rna_id, group, metadata_status, caution_flags,
                     library_size, detected_genes_count_gt0, norm.factors, PC1, PC2,
                     any_qc_outlier_iqr)]

fwrite(caution_only, file.path(qc_dir, "GSE161731_counts_key_only_caution_sample_qc.tsv"), sep = "\t")

# Plot normalized factor distribution
p_nf <- ggplot(qc, aes(x = group, y = norm.factors)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.75) +
  theme_bw() +
  labs(
    title = "GSE161731 technical rehearsal: TMM normalization factors",
    x = "Technical rehearsal group",
    y = "TMM normalization factor"
  )

ggsave(file.path(qc_dir, "GSE161731_TMM_normalization_factors_by_group.png"), p_nf, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_TMM_normalization_factors_by_group.pdf"), p_nf, width = 7, height = 5)

# Plot PCA with caution samples highlighted by outline-style label table only; no biology.
p_pca_caution <- ggplot(qc, aes(x = PC1, y = PC2, shape = group)) +
  geom_point(aes(alpha = caution_flagged_metadata), size = 2.5) +
  scale_alpha_manual(values = c(`FALSE` = 0.65, `TRUE` = 1.0)) +
  theme_bw() +
  labs(
    title = "GSE161731 technical rehearsal: PCA with metadata-caution samples highlighted",
    x = "PC1",
    y = "PC2",
    alpha = "Metadata caution"
  )

ggsave(file.path(qc_dir, "GSE161731_voom_PCA_caution_samples_highlighted.png"), p_pca_caution, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_voom_PCA_caution_samples_highlighted.pdf"), p_pca_caution, width = 7, height = 5)

# Extract filter metrics safely
get_metric <- function(metric_name) {
  value <- filter_summary[metric == metric_name, value]
  if (length(value) == 0) return(NA)
  value[1]
}

genes_before <- get_metric("genes_before_filtering")
genes_after <- get_metric("genes_after_filterByExpr")
genes_removed <- get_metric("genes_removed_by_filterByExpr")

technical_decision <- if (sum(qc$any_qc_outlier_iqr) == 0) {
  "No IQR-defined library-size, detected-gene or normalization-factor outliers were detected. Proceed to a cautious technical rehearsal summary."
} else {
  "IQR-defined technical outliers were detected. Inspect the outlier table before any further workflow rehearsal."
}

caution_decision <- if (nrow(caution_only) == 0) {
  "No metadata-caution samples are present in the technical rehearsal subset."
} else if (all(caution_only$any_qc_outlier_iqr == FALSE)) {
  "Metadata-caution samples are present, but none are flagged as IQR-defined QC outliers in library size, detected genes or TMM normalization factor."
} else {
  "At least one metadata-caution sample is also an IQR-defined QC outlier; consider a sensitivity rehearsal excluding caution samples."
}

report_file <- file.path(docs_dir, "GSE161731_technical_qc_review_report.md")

writeLines(c(
  "# GSE161731 Technical QC Review Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: review technical QC outputs from the GSE161731 count-level QC/voom rehearsal.",
  "- Analytical boundary: no differential expression, pathway enrichment, module definition, module orientation, external validation or biological interpretation is performed here.",
  "",
  "## Rehearsal subset",
  "",
  paste0("- Total samples reviewed: ", nrow(qc)),
  paste0("- Bacterial samples: ", sum(qc$group == "bacterial")),
  paste0("- Non-COVID viral samples: ", sum(qc$group == "non_covid_viral")),
  "",
  "## Filtering summary",
  "",
  paste0("- Genes before filtering: ", genes_before),
  paste0("- Genes retained after `filterByExpr`: ", genes_after),
  paste0("- Genes removed: ", genes_removed),
  "",
  "## Technical QC outlier thresholds",
  "",
  paste0("- Library-size IQR lower threshold: ", signif(lib_flag$lower, 4)),
  paste0("- Library-size IQR upper threshold: ", signif(lib_flag$upper, 4)),
  paste0("- Detected-gene IQR lower threshold: ", signif(det_flag$lower, 4)),
  paste0("- Detected-gene IQR upper threshold: ", signif(det_flag$upper, 4)),
  paste0("- TMM normalization-factor IQR lower threshold: ", signif(nf_flag$lower, 4)),
  paste0("- TMM normalization-factor IQR upper threshold: ", signif(nf_flag$upper, 4)),
  "",
  "## Outlier counts",
  "",
  paste0("- Library-size outliers: ", sum(qc$library_size_outlier_iqr)),
  paste0("- Detected-gene-count outliers: ", sum(qc$detected_genes_outlier_iqr)),
  paste0("- TMM normalization-factor outliers: ", sum(qc$norm_factor_outlier_iqr)),
  paste0("- Samples with any IQR-defined QC outlier flag: ", sum(qc$any_qc_outlier_iqr)),
  paste0("- Metadata-caution samples: ", sum(qc$caution_flagged_metadata)),
  "",
  "## Group-level QC summary",
  "",
  paste(capture.output(print(group_summary)), collapse = "\n"),
  "",
  "## Metadata-caution samples",
  "",
  if (nrow(caution_only) > 0) paste(capture.output(print(caution_only)), collapse = "\n") else "- None.",
  "",
  "## Technical decision",
  "",
  paste0("- ", technical_decision),
  paste0("- ", caution_decision),
  "",
  "## Generated files",
  "",
  paste0("- `", file.path(qc_dir, "GSE161731_integrated_technical_qc_review_table.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_technical_qc_group_summary.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_technical_qc_outliers_and_caution_samples.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_counts_key_only_caution_sample_qc.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_TMM_normalization_factors_by_group.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE161731_voom_PCA_caution_samples_highlighted.png"), "` and `.pdf`"),
  "",
  "## Boundary statement",
  "",
  "- This review supports only technical workflow assessment.",
  "- It does not justify biological claims about bacterial versus viral host response.",
  "- It does not affect the GSE211567 discovery design or module-freezing plan."
), con = report_file)

message("Technical QC review complete.")
message("Report: ", report_file)
