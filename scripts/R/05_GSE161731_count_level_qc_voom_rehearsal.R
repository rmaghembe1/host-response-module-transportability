#!/usr/bin/env Rscript

# GSE161731 count-level QC/voom technical rehearsal
# Purpose: workflow mastery only. No biological interpretation, no pathway analysis,
# no discovery-module selection, no transportability testing.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(edgeR)
  library(limma)
  library(ggplot2)
})

dir.create("results/qc/GSE161731_technical_rehearsal", recursive = TRUE, showWarnings = FALSE)
dir.create("env/session_info", recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)

qc_dir <- "results/qc/GSE161731_technical_rehearsal"

counts_file <- "data/raw/GSE161731_counts.csv.gz"
elig_file <- "data/metadata_harmonized/GSE161731_technical_rehearsal_eligibility.tsv"

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
    technical_rehearsal_group %in% c("bacterial", "non_covid_viral")
]

sample_ids <- eligible$rna_id

missing_in_counts <- setdiff(sample_ids, colnames(counts_mat))
extra_in_counts <- setdiff(colnames(counts_mat), sample_ids)

if (length(missing_in_counts) > 0) {
  stop("Some eligible samples are missing from count matrix: ",
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

group_table <- as.data.frame(table(eligible$technical_rehearsal_group))
colnames(group_table) <- c("group", "n")
fwrite(group_table, file.path(qc_dir, "GSE161731_rehearsal_group_counts.tsv"), sep = "\t")

sample_summary <- data.frame(
  rna_id = colnames(counts_sub),
  group = eligible$technical_rehearsal_group,
  metadata_status = eligible$metadata_usability_status,
  caution_flags = eligible$metadata_caution_flags,
  library_size = colSums(counts_sub),
  detected_genes_count_gt0 = colSums(counts_sub > 0),
  stringsAsFactors = FALSE
)

fwrite(sample_summary, file.path(qc_dir, "GSE161731_sample_level_qc_summary.tsv"), sep = "\t")

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
    "samples_in_rehearsal_subset",
    "bacterial_samples",
    "non_covid_viral_samples"
  ),
  value = c(
    nrow(dge),
    nrow(dge_filt),
    nrow(dge) - nrow(dge_filt),
    ncol(dge_filt),
    sum(eligible$technical_rehearsal_group == "bacterial"),
    sum(eligible$technical_rehearsal_group == "non_covid_viral")
  )
)

fwrite(filter_summary, file.path(qc_dir, "GSE161731_filtering_summary.tsv"), sep = "\t")

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

fwrite(norm_factors, file.path(qc_dir, "GSE161731_TMM_normalization_factors.tsv"), sep = "\t")

message("Running voom...")
v <- voom(dge_filt, design = design, plot = FALSE)

saveRDS(
  list(
    dge_filtered = dge_filt,
    voom = v,
    design = design,
    eligible_metadata = eligible
  ),
  file.path(qc_dir, "GSE161731_technical_rehearsal_voom_objects.rds")
)

write.table(
  design,
  file = file.path(qc_dir, "GSE161731_design_matrix.tsv"),
  sep = "\t",
  quote = FALSE,
  col.names = NA
)

# MDS plot from edgeR
png(file.path(qc_dir, "GSE161731_MDS_plot.png"), width = 1800, height = 1500, res = 200)
plotMDS(dge_filt, labels = eligible$technical_rehearsal_group)
dev.off()

pdf(file.path(qc_dir, "GSE161731_MDS_plot.pdf"), width = 8, height = 6)
plotMDS(dge_filt, labels = eligible$technical_rehearsal_group)
dev.off()

# Library size plot
p_lib <- ggplot(sample_summary, aes(x = group, y = library_size)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.7) +
  theme_bw() +
  labs(
    title = "GSE161731 technical rehearsal: library sizes",
    x = "Technical rehearsal group",
    y = "Library size"
  )

ggsave(file.path(qc_dir, "GSE161731_library_size_by_group.png"), p_lib, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_library_size_by_group.pdf"), p_lib, width = 7, height = 5)

# Detected genes plot
p_detect <- ggplot(sample_summary, aes(x = group, y = detected_genes_count_gt0)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.7) +
  theme_bw() +
  labs(
    title = "GSE161731 technical rehearsal: detected genes",
    x = "Technical rehearsal group",
    y = "Genes with count > 0"
  )

ggsave(file.path(qc_dir, "GSE161731_detected_genes_by_group.png"), p_detect, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_detected_genes_by_group.pdf"), p_detect, width = 7, height = 5)

# PCA on voom expression for technical QC only
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

fwrite(pca_df, file.path(qc_dir, "GSE161731_voom_PCA_coordinates.tsv"), sep = "\t")

var_explained <- 100 * (pca$sdev^2 / sum(pca$sdev^2))

p_pca <- ggplot(pca_df, aes(x = PC1, y = PC2, shape = group)) +
  geom_point(size = 2.5, alpha = 0.8) +
  theme_bw() +
  labs(
    title = "GSE161731 technical rehearsal: PCA of voom expression",
    x = paste0("PC1 (", round(var_explained[1], 1), "%)"),
    y = paste0("PC2 (", round(var_explained[2], 1), "%)")
  )

ggsave(file.path(qc_dir, "GSE161731_voom_PCA.png"), p_pca, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE161731_voom_PCA.pdf"), p_pca, width = 7, height = 5)

# Session info
sink("env/session_info/GSE161731_count_level_qc_voom_rehearsal_sessionInfo.txt")
print(sessionInfo())
sink()

report_file <- "docs/GSE161731_count_level_qc_voom_rehearsal_report.md"

writeLines(c(
  "# GSE161731 Count-Level QC/voom Technical Rehearsal Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: technical workflow rehearsal only.",
  "- Analytical firewall: this analysis must not influence GSE211567 discovery-module selection, module orientation, module weighting or biological interpretation.",
  "",
  "## Rehearsal subset",
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
  "## Outputs",
  "",
  paste0("- `", qc_dir, "/GSE161731_sample_level_qc_summary.tsv`"),
  paste0("- `", qc_dir, "/GSE161731_filtering_summary.tsv`"),
  paste0("- `", qc_dir, "/GSE161731_TMM_normalization_factors.tsv`"),
  paste0("- `", qc_dir, "/GSE161731_design_matrix.tsv`"),
  paste0("- `", qc_dir, "/GSE161731_voom_PCA_coordinates.tsv`"),
  paste0("- `", qc_dir, "/GSE161731_technical_rehearsal_voom_objects.rds`"),
  paste0("- `", qc_dir, "/GSE161731_MDS_plot.png` and `.pdf`"),
  paste0("- `", qc_dir, "/GSE161731_library_size_by_group.png` and `.pdf`"),
  paste0("- `", qc_dir, "/GSE161731_detected_genes_by_group.png` and `.pdf`"),
  paste0("- `", qc_dir, "/GSE161731_voom_PCA.png` and `.pdf`"),
  "- `env/session_info/GSE161731_count_level_qc_voom_rehearsal_sessionInfo.txt`",
  "",
  "## Immediate interpretation boundary",
  "",
  "- This script verifies count-level import, sample alignment, filtering, TMM normalization, voom transformation and QC plotting.",
  "- It does not perform differential expression testing.",
  "- It does not perform pathway enrichment.",
  "- It does not define, orient, reweight or validate any biological module.",
  "- Biological interpretation is intentionally deferred."
), con = report_file)

message("QC/voom technical rehearsal complete.")
message("Report: ", report_file)
