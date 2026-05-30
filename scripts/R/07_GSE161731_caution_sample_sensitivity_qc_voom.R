#!/usr/bin/env Rscript

# GSE161731 caution-sample sensitivity QC/voom rehearsal
# Purpose: technical sensitivity only, excluding counts-key-only caution samples.
# No differential expression, no pathway enrichment, no module selection, no biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(edgeR)
  library(limma)
  library(ggplot2)
})

qc_dir <- "results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples"
dir.create(qc_dir, recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)
dir.create("env/session_info", recursive = TRUE, showWarnings = FALSE)

counts_file <- "data/raw/GSE161731_counts.csv.gz"
elig_file <- "data/metadata_harmonized/GSE161731_technical_rehearsal_eligibility.tsv"

exclude_ids <- c("434482", "434741", "94478")

message("Reading count matrix...")
counts_dt <- fread(counts_file)
gene_id <- counts_dt[[1]]
counts_mat <- as.matrix(counts_dt[, -1, with = FALSE])
rownames(counts_mat) <- gene_id
storage.mode(counts_mat) <- "numeric"

message("Reading eligibility table...")
elig <- fread(elig_file)

eligible <- elig[
  include_in_primary_non_covid_technical_rehearsal == "yes" &
    technical_rehearsal_group %in% c("bacterial", "non_covid_viral") &
    !(rna_id %in% exclude_ids)
]

sample_ids <- eligible$rna_id
missing_in_counts <- setdiff(sample_ids, colnames(counts_mat))
if (length(missing_in_counts) > 0) {
  stop("Some eligible sensitivity samples are missing from count matrix: ",
       paste(missing_in_counts, collapse = ", "))
}

counts_sub <- counts_mat[, sample_ids, drop = FALSE]

eligible <- as.data.frame(eligible)
rownames(eligible) <- eligible$rna_id
eligible <- eligible[colnames(counts_sub), , drop = FALSE]
stopifnot(identical(rownames(eligible), colnames(counts_sub)))

eligible$technical_rehearsal_group <- factor(
  eligible$technical_rehearsal_group,
  levels = c("non_covid_viral", "bacterial")
)

group_counts <- as.data.frame(table(eligible$technical_rehearsal_group))
colnames(group_counts) <- c("group", "n")
fwrite(group_counts, file.path(qc_dir, "GSE161731_sensitivity_group_counts.tsv"), sep = "\t")

sample_summary <- data.frame(
  rna_id = colnames(counts_sub),
  group = eligible$technical_rehearsal_group,
  metadata_status = eligible$metadata_usability_status,
  caution_flags = eligible$metadata_caution_flags,
  library_size = colSums(counts_sub),
  detected_genes_count_gt0 = colSums(counts_sub > 0),
  stringsAsFactors = FALSE
)

fwrite(sample_summary, file.path(qc_dir, "GSE161731_sensitivity_sample_level_qc_summary.tsv"), sep = "\t")

message("Creating DGEList...")
dge <- DGEList(counts = counts_sub, samples = eligible, group = eligible$technical_rehearsal_group)

message("Filtering low-expression genes with edgeR::filterByExpr...")
design <- model.matrix(~ 0 + technical_rehearsal_group, data = eligible)
colnames(design) <- make.names(colnames(design))

keep <- filterByExpr(dge, design = design)
dge_filt <- dge[keep, , keep.lib.sizes = FALSE]

filter_summary <- data.frame(
  metric = c(
    "genes_before_filtering",
    "genes_after_filterByExpr",
    "genes_removed_by_filterByExpr",
    "samples_in_sensitivity_subset",
    "bacterial_samples",
    "non_covid_viral_samples",
    "excluded_caution_samples"
  ),
  value = c(
    nrow(dge),
    nrow(dge_filt),
    nrow(dge) - nrow(dge_filt),
    ncol(dge_filt),
    sum(eligible$technical_rehearsal_group == "bacterial"),
    sum(eligible$technical_rehearsal_group == "non_covid_viral"),
    paste(exclude_ids, collapse = ",")
  )
)

fwrite(filter_summary, file.path(qc_dir, "GSE161731_sensitivity_filtering_summary.tsv"), sep = "\t")

message("TMM normalization...")
dge_filt <- calcNormFactors(dge_filt, method = "TMM")

norm_factors <- data.frame(
  rna_id = rownames(dge_filt$samples),
  group = eligible$technical_rehearsal_group,
  lib.size = dge_filt$samples$lib.size,
  norm.factors = dge_filt$samples$norm.factors,
  metadata_status = eligible$metadata_usability_status,
  caution_flags = eligible$metadata_caution_flags,
  stringsAsFactors = FALSE
)

fwrite(norm_factors, file.path(qc_dir, "GSE161731_sensitivity_TMM_normalization_factors.tsv"), sep = "\t")

message("Running voom...")
v <- voom(dge_filt, design = design, plot = FALSE)

saveRDS(
  list(
    dge_filtered = dge_filt,
    voom = v,
    design = design,
    eligible_metadata = eligible,
    excluded_ids = exclude_ids
  ),
  file.path(qc_dir, "GSE161731_sensitivity_voom_objects.rds")
)

write.table(
  design,
  file = file.path(qc_dir, "GSE161731_sensitivity_design_matrix.tsv"),
  sep = "\t",
  quote = FALSE,
  col.names = NA
)

# PCA
expr <- v$E
pca <- prcomp(t(expr), scale. = TRUE)

pca_df <- data.frame(
  rna_id = rownames(pca$x),
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  group = eligible[rownames(pca$x), "technical_rehearsal_group"],
  metadata_status = eligible[rownames(pca$x), "metadata_usability_status"],
  caution_flags = eligible[rownames(pca$x), "metadata_caution_flags"],
  stringsAsFactors = FALSE
)

fwrite(pca_df, file.path(qc_dir, "GSE161731_sensitivity_voom_PCA_coordinates.tsv"), sep = "\t")

var_explained <- 100 * (pca$sdev^2 / sum(pca$sdev^2))

p_pca <- ggplot(pca_df, aes(x = PC1, y = PC2, shape = group)) +
  geom_point(size = 2.5, alpha = 0.8) +
  theme_bw() +
  labs(
    title = "GSE161731 sensitivity rehearsal: PCA after excluding caution samples",
    x = paste0("PC1 (", round(var_explained[1], 1), "%)"),
    y = paste0("PC2 (", round(var_explained[2], 1), "%)")
  )

ggsave(file.path(qc_dir, "GSE161731_sensitivity_voom_PCA.png"), p_pca, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_sensitivity_voom_PCA.pdf"), p_pca, width = 7, height = 5)

# MDS
png(file.path(qc_dir, "GSE161731_sensitivity_MDS_plot.png"), width = 1800, height = 1500, res = 200)
plotMDS(dge_filt, labels = eligible$technical_rehearsal_group)
dev.off()

pdf(file.path(qc_dir, "GSE161731_sensitivity_MDS_plot.pdf"), width = 8, height = 6)
plotMDS(dge_filt, labels = eligible$technical_rehearsal_group)
dev.off()

# Technical QC review in sensitivity subset
flag_iqr <- function(x, multiplier = 1.5) {
  q <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  lower <- q[1] - multiplier * iqr
  upper <- q[2] + multiplier * iqr
  list(lower = lower, upper = upper, flag = x < lower | x > upper)
}

qc <- merge(sample_summary, norm_factors[, c("rna_id", "norm.factors")], by = "rna_id", all.x = TRUE)
qc <- merge(qc, pca_df[, c("rna_id", "PC1", "PC2")], by = "rna_id", all.x = TRUE)
setDT(qc)

lib_flag <- flag_iqr(qc$library_size)
det_flag <- flag_iqr(qc$detected_genes_count_gt0)
nf_flag <- flag_iqr(qc$norm.factors)

qc[, library_size_outlier_iqr := lib_flag$flag]
qc[, detected_genes_outlier_iqr := det_flag$flag]
qc[, norm_factor_outlier_iqr := nf_flag$flag]
qc[, any_qc_outlier_iqr := library_size_outlier_iqr | detected_genes_outlier_iqr | norm_factor_outlier_iqr]

fwrite(qc, file.path(qc_dir, "GSE161731_sensitivity_integrated_qc_table.tsv"), sep = "\t")

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
  n_any_iqr_outlier = sum(any_qc_outlier_iqr)
), by = group]

fwrite(group_summary, file.path(qc_dir, "GSE161731_sensitivity_qc_group_summary.tsv"), sep = "\t")

outlier_table <- qc[any_qc_outlier_iqr == TRUE,
                    .(rna_id, group, metadata_status, caution_flags,
                      library_size, detected_genes_count_gt0, norm.factors,
                      PC1, PC2,
                      library_size_outlier_iqr,
                      detected_genes_outlier_iqr,
                      norm_factor_outlier_iqr)]

fwrite(outlier_table, file.path(qc_dir, "GSE161731_sensitivity_qc_outliers.tsv"), sep = "\t")

sink("env/session_info/GSE161731_caution_sample_sensitivity_qc_voom_sessionInfo.txt")
print(sessionInfo())
sink()

report_file <- "docs/GSE161731_caution_sample_sensitivity_qc_voom_report.md"

writeLines(c(
  "# GSE161731 Caution-Sample Sensitivity QC/voom Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: technical sensitivity rehearsal only, excluding counts-key-only caution samples.",
  "- Analytical boundary: no differential expression, pathway enrichment, module definition, module orientation, external validation or biological interpretation is performed here.",
  "",
  "## Excluded samples",
  "",
  paste0("- ", paste(exclude_ids, collapse = ", ")),
  "",
  "## Sensitivity subset",
  "",
  paste0("- Total samples: ", ncol(counts_sub)),
  paste0("- Bacterial samples: ", sum(eligible$technical_rehearsal_group == "bacterial")),
  paste0("- Non-COVID viral samples: ", sum(eligible$technical_rehearsal_group == "non_covid_viral")),
  "",
  "## Gene filtering",
  "",
  paste0("- Genes before filtering: ", nrow(dge)),
  paste0("- Genes retained after `filterByExpr`: ", nrow(dge_filt)),
  paste0("- Genes removed: ", nrow(dge) - nrow(dge_filt)),
  "",
  "## Sensitivity technical outlier counts",
  "",
  paste0("- Library-size outliers: ", sum(qc$library_size_outlier_iqr)),
  paste0("- Detected-gene-count outliers: ", sum(qc$detected_genes_outlier_iqr)),
  paste0("- TMM normalization-factor outliers: ", sum(qc$norm_factor_outlier_iqr)),
  paste0("- Samples with any IQR-defined QC outlier flag: ", sum(qc$any_qc_outlier_iqr)),
  "",
  "## Group-level QC summary",
  "",
  paste(capture.output(print(group_summary)), collapse = "\n"),
  "",
  "## IQR-defined sensitivity outliers",
  "",
  if (nrow(outlier_table) > 0) paste(capture.output(print(outlier_table)), collapse = "\n") else "- None.",
  "",
  "## Generated files",
  "",
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_sample_level_qc_summary.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_filtering_summary.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_TMM_normalization_factors.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_design_matrix.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_voom_PCA_coordinates.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_integrated_qc_table.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_qc_group_summary.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_qc_outliers.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_voom_objects.rds"), "`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_voom_PCA.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE161731_sensitivity_MDS_plot.png"), "` and `.pdf`"),
  "- `env/session_info/GSE161731_caution_sample_sensitivity_qc_voom_sessionInfo.txt`",
  "",
  "## Boundary statement",
  "",
  "- This sensitivity analysis supports only technical workflow assessment.",
  "- It does not justify biological claims about bacterial versus viral host response.",
  "- It does not affect GSE211567 discovery-module selection or module-freezing."
), con = report_file)

message("Sensitivity QC/voom rehearsal complete.")
message("Report: ", report_file)
