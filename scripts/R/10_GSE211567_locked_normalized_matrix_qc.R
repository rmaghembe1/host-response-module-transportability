#!/usr/bin/env Rscript

# GSE211567 locked normalized-matrix QC
# Purpose: technical/sample-structure QC only before discovery modelling.
# No differential expression, no pathway enrichment, no module discovery, no biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(limma)
})

qc_dir <- "results/qc/GSE211567_locked_normalized_matrix"
dir.create(qc_dir, recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)
dir.create("env/session_info", recursive = TRUE, showWarnings = FALSE)

expr_file <- "data/raw/GSE211567_normData_discovery_2021MAR24.txt.gz"
sample_file <- "data/metadata_harmonized/GSE211567_discovery_sample_table_locked.tsv"

message("Reading normalized expression matrix...")
expr_dt <- fread(expr_file)

feature_id <- expr_dt[[1]]
expr_mat <- as.matrix(expr_dt[, -1, with = FALSE])
rownames(expr_mat) <- feature_id
storage.mode(expr_mat) <- "numeric"

message("Reading locked sample table...")
samples <- fread(sample_file)
samples <- as.data.frame(samples)

locked_ids <- samples$expression_sample_id

missing_in_expr <- setdiff(locked_ids, colnames(expr_mat))
extra_in_expr <- setdiff(colnames(expr_mat), locked_ids)

if (length(missing_in_expr) > 0) {
  stop("Locked samples missing from expression matrix: ", paste(missing_in_expr, collapse = ", "))
}

expr_locked <- expr_mat[, locked_ids, drop = FALSE]
rownames(samples) <- samples$expression_sample_id
samples <- samples[colnames(expr_locked), , drop = FALSE]

stopifnot(identical(rownames(samples), colnames(expr_locked)))
stopifnot(!("DU09-03S0000029" %in% colnames(expr_locked)))

# Basic matrix integrity
nonfinite_count <- sum(!is.finite(expr_locked))
na_count <- sum(is.na(expr_locked))
duplicate_feature_count <- sum(duplicated(rownames(expr_locked)))
duplicate_sample_count <- sum(duplicated(colnames(expr_locked)))

matrix_summary <- data.frame(
  metric = c(
    "features_total",
    "samples_locked",
    "nonfinite_values",
    "NA_values",
    "duplicate_feature_ids",
    "duplicate_sample_ids",
    "excluded_unmatched_sample_present"
  ),
  value = c(
    nrow(expr_locked),
    ncol(expr_locked),
    nonfinite_count,
    na_count,
    duplicate_feature_count,
    duplicate_sample_count,
    "DU09-03S0000029" %in% colnames(expr_locked)
  )
)

fwrite(matrix_summary, file.path(qc_dir, "GSE211567_locked_matrix_integrity_summary.tsv"), sep = "\t")

# Sample-level summaries
sample_qc <- data.frame(
  expression_sample_id = colnames(expr_locked),
  geo_accession = samples$geo_accession,
  discovery_group = samples$discovery_group,
  primary_discovery_status = samples$include_in_primary_bacterial_vs_viral_discovery,
  infection_type_original = samples$infection_type_original,
  pathogen = samples$pathogen,
  site = samples$site,
  sequencing_batch = samples$sequencing_batch,
  platform_id = samples$platform_id,
  instrument_model = samples$instrument_model,
  age = samples$age,
  gender = samples$gender,
  race = samples$race,
  mean_expression = colMeans(expr_locked, na.rm = TRUE),
  median_expression = apply(expr_locked, 2, median, na.rm = TRUE),
  sd_expression = apply(expr_locked, 2, sd, na.rm = TRUE),
  min_expression = apply(expr_locked, 2, min, na.rm = TRUE),
  max_expression = apply(expr_locked, 2, max, na.rm = TRUE),
  detected_features_gt0 = colSums(expr_locked > 0, na.rm = TRUE),
  stringsAsFactors = FALSE
)

fwrite(sample_qc, file.path(qc_dir, "GSE211567_locked_sample_level_expression_qc.tsv"), sep = "\t")

# Group/site/batch summaries
group_counts <- as.data.frame(table(samples$discovery_group))
colnames(group_counts) <- c("discovery_group", "n")
fwrite(group_counts, file.path(qc_dir, "GSE211567_locked_group_counts.tsv"), sep = "\t")

site_counts <- as.data.frame(table(samples$site))
colnames(site_counts) <- c("site", "n")
fwrite(site_counts, file.path(qc_dir, "GSE211567_locked_site_counts.tsv"), sep = "\t")

batch_counts <- as.data.frame(table(samples$sequencing_batch))
colnames(batch_counts) <- c("sequencing_batch", "n")
fwrite(batch_counts, file.path(qc_dir, "GSE211567_locked_batch_counts.tsv"), sep = "\t")

site_group_counts <- as.data.frame(table(samples$site, samples$discovery_group))
colnames(site_group_counts) <- c("site", "discovery_group", "n")
fwrite(site_group_counts, file.path(qc_dir, "GSE211567_locked_site_by_group_counts.tsv"), sep = "\t")

batch_group_counts <- as.data.frame(table(samples$sequencing_batch, samples$discovery_group))
colnames(batch_group_counts) <- c("sequencing_batch", "discovery_group", "n")
fwrite(batch_group_counts, file.path(qc_dir, "GSE211567_locked_batch_by_group_counts.tsv"), sep = "\t")

pathogen_counts <- as.data.frame(table(samples$pathogen))
colnames(pathogen_counts) <- c("pathogen", "n")
fwrite(pathogen_counts, file.path(qc_dir, "GSE211567_locked_pathogen_counts.tsv"), sep = "\t")

# PCA on all locked samples
message("Running PCA...")
pca <- prcomp(t(expr_locked), center = TRUE, scale. = TRUE)
var_explained <- 100 * (pca$sdev^2 / sum(pca$sdev^2))

pca_df <- data.frame(
  expression_sample_id = rownames(pca$x),
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  PC3 = pca$x[, 3],
  PC4 = pca$x[, 4],
  discovery_group = samples[rownames(pca$x), "discovery_group"],
  primary_discovery_status = samples[rownames(pca$x), "include_in_primary_bacterial_vs_viral_discovery"],
  pathogen = samples[rownames(pca$x), "pathogen"],
  site = samples[rownames(pca$x), "site"],
  sequencing_batch = samples[rownames(pca$x), "sequencing_batch"],
  platform_id = samples[rownames(pca$x), "platform_id"],
  instrument_model = samples[rownames(pca$x), "instrument_model"],
  stringsAsFactors = FALSE
)

fwrite(pca_df, file.path(qc_dir, "GSE211567_locked_PCA_coordinates.tsv"), sep = "\t")

p_group <- ggplot(pca_df, aes(x = PC1, y = PC2, shape = discovery_group)) +
  geom_point(alpha = 0.8, size = 2.3) +
  theme_bw() +
  labs(
    title = "GSE211567 locked samples: PCA by discovery group",
    x = paste0("PC1 (", round(var_explained[1], 1), "%)"),
    y = paste0("PC2 (", round(var_explained[2], 1), "%)")
  )

ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_discovery_group.png"), p_group, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_discovery_group.pdf"), p_group, width = 7, height = 5)

p_site <- ggplot(pca_df, aes(x = PC1, y = PC2, shape = site)) +
  geom_point(alpha = 0.8, size = 2.3) +
  theme_bw() +
  labs(
    title = "GSE211567 locked samples: PCA by site",
    x = paste0("PC1 (", round(var_explained[1], 1), "%)"),
    y = paste0("PC2 (", round(var_explained[2], 1), "%)")
  )

ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_site.png"), p_site, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_site.pdf"), p_site, width = 7, height = 5)

p_batch <- ggplot(pca_df, aes(x = PC1, y = PC2, shape = as.factor(sequencing_batch))) +
  geom_point(alpha = 0.8, size = 2.3) +
  theme_bw() +
  labs(
    title = "GSE211567 locked samples: PCA by sequencing batch",
    x = paste0("PC1 (", round(var_explained[1], 1), "%)"),
    y = paste0("PC2 (", round(var_explained[2], 1), "%)"),
    shape = "Sequencing batch"
  )

ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_batch.png"), p_batch, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE211567_locked_PCA_by_batch.pdf"), p_batch, width = 7, height = 5)

# MDS using limma
message("Running MDS...")
pdf(file.path(qc_dir, "GSE211567_locked_MDS_by_group.pdf"), width = 8, height = 6)
plotMDS(expr_locked, labels = samples$discovery_group)
dev.off()

png(file.path(qc_dir, "GSE211567_locked_MDS_by_group.png"), width = 1800, height = 1500, res = 200)
plotMDS(expr_locked, labels = samples$discovery_group)
dev.off()

# Robust sample outlier scan based on expression summary metrics
flag_iqr <- function(x, multiplier = 1.5) {
  q <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  lower <- q[1] - multiplier * iqr
  upper <- q[2] + multiplier * iqr
  list(lower = lower, upper = upper, flag = x < lower | x > upper)
}

mean_flag <- flag_iqr(sample_qc$mean_expression)
sd_flag <- flag_iqr(sample_qc$sd_expression)
det_flag <- flag_iqr(sample_qc$detected_features_gt0)

sample_qc$mean_expression_outlier_iqr <- mean_flag$flag
sample_qc$sd_expression_outlier_iqr <- sd_flag$flag
sample_qc$detected_features_outlier_iqr <- det_flag$flag
sample_qc$any_expression_summary_outlier_iqr <-
  sample_qc$mean_expression_outlier_iqr |
  sample_qc$sd_expression_outlier_iqr |
  sample_qc$detected_features_outlier_iqr

fwrite(sample_qc, file.path(qc_dir, "GSE211567_locked_sample_level_expression_qc_with_outlier_flags.tsv"), sep = "\t")

outliers <- sample_qc[sample_qc$any_expression_summary_outlier_iqr == TRUE, ]
fwrite(outliers, file.path(qc_dir, "GSE211567_locked_expression_summary_outliers.tsv"), sep = "\t")

# Boxplots for sample metrics
p_mean <- ggplot(sample_qc, aes(x = discovery_group, y = mean_expression)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.6) +
  theme_bw() +
  labs(title = "GSE211567 locked samples: mean expression", x = "Discovery group", y = "Mean expression")

ggsave(file.path(qc_dir, "GSE211567_locked_mean_expression_by_group.png"), p_mean, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE211567_locked_mean_expression_by_group.pdf"), p_mean, width = 7, height = 5)

p_sd <- ggplot(sample_qc, aes(x = discovery_group, y = sd_expression)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.6) +
  theme_bw() +
  labs(title = "GSE211567 locked samples: expression SD", x = "Discovery group", y = "Expression SD")

ggsave(file.path(qc_dir, "GSE211567_locked_sd_expression_by_group.png"), p_sd, width = 7, height = 5, dpi = 300)
ggsave(file.path(qc_dir, "GSE211567_locked_sd_expression_by_group.pdf"), p_sd, width = 7, height = 5)

sink("env/session_info/GSE211567_locked_normalized_matrix_qc_sessionInfo.txt")
print(sessionInfo())
sink()

report_file <- "docs/GSE211567_locked_normalized_matrix_qc_report.md"

writeLines(c(
  "# GSE211567 Locked Normalized-Matrix QC Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: technical QC of the locked GSE211567 normalized discovery matrix before discovery modelling.",
  "- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.",
  "",
  "## Matrix integrity",
  "",
  paste0("- Features: ", nrow(expr_locked)),
  paste0("- Locked samples: ", ncol(expr_locked)),
  paste0("- Non-finite values: ", nonfinite_count),
  paste0("- NA values: ", na_count),
  paste0("- Duplicate feature IDs: ", duplicate_feature_count),
  paste0("- Duplicate sample IDs: ", duplicate_sample_count),
  paste0("- Excluded unmatched sample present in QC subset: ", "DU09-03S0000029" %in% colnames(expr_locked)),
  "",
  "## Locked sample structure",
  "",
  "### Discovery groups",
  paste(capture.output(print(group_counts)), collapse = "\n"),
  "",
  "### Site counts",
  paste(capture.output(print(site_counts)), collapse = "\n"),
  "",
  "### Sequencing batch counts",
  paste(capture.output(print(batch_counts)), collapse = "\n"),
  "",
  "### Site × discovery group counts",
  paste(capture.output(print(site_group_counts)), collapse = "\n"),
  "",
  "### Batch × discovery group counts",
  paste(capture.output(print(batch_group_counts)), collapse = "\n"),
  "",
  "## PCA variance explained",
  "",
  paste0("- PC1: ", round(var_explained[1], 2), "%"),
  paste0("- PC2: ", round(var_explained[2], 2), "%"),
  paste0("- PC3: ", round(var_explained[3], 2), "%"),
  paste0("- PC4: ", round(var_explained[4], 2), "%"),
  "",
  "## Expression-summary outlier scan",
  "",
  paste0("- Mean-expression IQR lower threshold: ", signif(mean_flag$lower, 4)),
  paste0("- Mean-expression IQR upper threshold: ", signif(mean_flag$upper, 4)),
  paste0("- SD-expression IQR lower threshold: ", signif(sd_flag$lower, 4)),
  paste0("- SD-expression IQR upper threshold: ", signif(sd_flag$upper, 4)),
  paste0("- Detected-feature IQR lower threshold: ", signif(det_flag$lower, 4)),
  paste0("- Detected-feature IQR upper threshold: ", signif(det_flag$upper, 4)),
  paste0("- Samples with any expression-summary outlier flag: ", nrow(outliers)),
  "",
  "## Generated files",
  "",
  paste0("- `", file.path(qc_dir, "GSE211567_locked_matrix_integrity_summary.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_sample_level_expression_qc.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_sample_level_expression_qc_with_outlier_flags.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_expression_summary_outliers.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_PCA_coordinates.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_group_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_site_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_batch_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_site_by_group_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_batch_by_group_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_pathogen_counts.tsv"), "`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_PCA_by_discovery_group.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_PCA_by_site.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_PCA_by_batch.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_MDS_by_group.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_mean_expression_by_group.png"), "` and `.pdf`"),
  paste0("- `", file.path(qc_dir, "GSE211567_locked_sd_expression_by_group.png"), "` and `.pdf`"),
  "- `env/session_info/GSE211567_locked_normalized_matrix_qc_sessionInfo.txt`",
  "",
  "## Boundary statement",
  "",
  "- This QC stage verifies matrix/sample integrity and major technical structure only.",
  "- It does not define biological modules.",
  "- It does not test bacterial-versus-viral differential expression.",
  "- It does not interpret host-response biology.",
  "- Discovery modelling remains deferred until this QC is reviewed and committed."
), con = report_file)

message("GSE211567 locked normalized-matrix QC complete.")
message("Report: ", report_file)
