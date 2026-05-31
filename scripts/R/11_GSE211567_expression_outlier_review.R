#!/usr/bin/env Rscript

# GSE211567 expression-summary outlier review
# Purpose: technical review of outlier flags from locked normalized-matrix QC.
# No differential expression, pathway enrichment, module discovery, or biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
})

qc_dir <- "results/qc/GSE211567_locked_normalized_matrix"
docs_dir <- "docs"
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)

qc_file <- file.path(qc_dir, "GSE211567_locked_sample_level_expression_qc_with_outlier_flags.tsv")
outlier_file <- file.path(qc_dir, "GSE211567_locked_expression_summary_outliers.tsv")
pca_file <- file.path(qc_dir, "GSE211567_locked_PCA_coordinates.tsv")

qc <- fread(qc_file)
outliers <- fread(outlier_file)
pca <- fread(pca_file)

review <- merge(
  outliers,
  pca[, .(expression_sample_id, PC1, PC2, PC3, PC4)],
  by = "expression_sample_id",
  all.x = TRUE
)

# Add compact flag description
review[, outlier_flag_summary := paste(
  c(
    ifelse(mean_expression_outlier_iqr, "mean_expression", NA),
    ifelse(sd_expression_outlier_iqr, "sd_expression", NA),
    ifelse(detected_features_outlier_iqr, "detected_features", NA)
  )[!is.na(c(
    ifelse(mean_expression_outlier_iqr, "mean_expression", NA),
    ifelse(sd_expression_outlier_iqr, "sd_expression", NA),
    ifelse(detected_features_outlier_iqr, "detected_features", NA)
  ))],
  collapse = ";"
), by = expression_sample_id]

review_out <- file.path(qc_dir, "GSE211567_expression_summary_outlier_review_table.tsv")
fwrite(review, review_out, sep = "\t")

group_counts <- review[, .N, by = discovery_group][order(discovery_group)]
site_counts <- review[, .N, by = site][order(site)]
batch_counts <- review[, .N, by = sequencing_batch][order(sequencing_batch)]
pathogen_counts <- review[, .N, by = pathogen][order(pathogen)]
flag_counts <- data.table(
  flag = c("mean_expression", "sd_expression", "detected_features"),
  n = c(
    sum(review$mean_expression_outlier_iqr),
    sum(review$sd_expression_outlier_iqr),
    sum(review$detected_features_outlier_iqr)
  )
)

summary_out <- file.path(qc_dir, "GSE211567_expression_summary_outlier_review_summary.tsv")
summary_rows <- rbindlist(list(
  data.table(category = "discovery_group", label = group_counts$discovery_group, n = group_counts$N),
  data.table(category = "site", label = site_counts$site, n = site_counts$N),
  data.table(category = "sequencing_batch", label = as.character(batch_counts$sequencing_batch), n = batch_counts$N),
  data.table(category = "pathogen", label = pathogen_counts$pathogen, n = pathogen_counts$N),
  data.table(category = "outlier_flag", label = flag_counts$flag, n = flag_counts$n)
), fill = TRUE)

fwrite(summary_rows, summary_out, sep = "\t")

# Conservative technical recommendation:
# Do not automatically exclude expression-summary outliers from a normalized discovery matrix
# unless they show extreme multi-metric failure or metadata/sample integrity issues.
multi_metric <- review[
  (mean_expression_outlier_iqr + sd_expression_outlier_iqr + detected_features_outlier_iqr) >= 2
]

report_file <- file.path(docs_dir, "GSE211567_expression_summary_outlier_review_report.md")

writeLines(c(
  "# GSE211567 Expression-Summary Outlier Review Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: focused technical review of the 18 expression-summary outliers identified during locked normalized-matrix QC.",
  "- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation, external validation or biological interpretation is performed here.",
  "",
  "## Outlier overview",
  "",
  paste0("- Total locked samples reviewed: ", nrow(qc)),
  paste0("- Expression-summary outlier samples: ", nrow(review)),
  paste0("- Outlier proportion: ", round(100 * nrow(review) / nrow(qc), 2), "%"),
  paste0("- Multi-metric outliers: ", nrow(multi_metric)),
  "",
  "## Outlier counts by discovery group",
  "",
  paste(capture.output(print(group_counts)), collapse = "\n"),
  "",
  "## Outlier counts by site",
  "",
  paste(capture.output(print(site_counts)), collapse = "\n"),
  "",
  "## Outlier counts by sequencing batch",
  "",
  paste(capture.output(print(batch_counts)), collapse = "\n"),
  "",
  "## Outlier counts by pathogen",
  "",
  paste(capture.output(print(pathogen_counts)), collapse = "\n"),
  "",
  "## Outlier flag counts",
  "",
  paste(capture.output(print(flag_counts)), collapse = "\n"),
  "",
  "## Multi-metric outliers",
  "",
  if (nrow(multi_metric) > 0) {
    paste(capture.output(print(multi_metric[, .(
      expression_sample_id, discovery_group, pathogen, site, sequencing_batch,
      mean_expression_outlier_iqr, sd_expression_outlier_iqr, detected_features_outlier_iqr,
      mean_expression, sd_expression, detected_features_gt0, PC1, PC2
    )])), collapse = "\n")
  } else {
    "- None."
  },
  "",
  "## Technical recommendation",
  "",
  "- Do not automatically exclude all expression-summary outliers at this stage.",
  "- These samples have passed sample-metadata locking and matrix-integrity checks.",
  "- Treat the 18 samples as documented QC-watch samples.",
  "- If discovery modelling reveals strong leverage, repeat key downstream summaries as a sensitivity analysis excluding multi-metric or high-leverage outliers only.",
  "- The primary next step should be design-matrix and covariate feasibility review, especially site, sequencing batch, platform/instrument and infection-group balance.",
  "",
  "## Generated files",
  "",
  paste0("- `", review_out, "`"),
  paste0("- `", summary_out, "`"),
  "",
  "## Boundary statement",
  "",
  "- This review supports technical QC documentation only.",
  "- It does not justify biological claims.",
  "- It does not define sample exclusions for discovery modelling beyond the already locked unmatched-sample exclusion.",
  "- It does not define or orient biological modules."
), con = report_file)

message("GSE211567 expression-summary outlier review complete.")
message("Report: ", report_file)
