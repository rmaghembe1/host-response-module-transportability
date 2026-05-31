#!/usr/bin/env Rscript

# GSE211567 primary limma discovery model
# Purpose: first bacterial-vs-viral differential-expression ranking using locked design.
# Model: normalized expression ~ discovery_group + site + sequencing_batch
# Boundary: generate ranked evidence only; no pathway enrichment, module discovery, or biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(limma)
  library(ggplot2)
})

expr_file <- "data/raw/GSE211567_normData_discovery_2021MAR24.txt.gz"
sample_file <- "data/metadata_harmonized/GSE211567_discovery_sample_table_locked.tsv"

out_dir <- "results/differential_expression/GSE211567_primary_bacterial_vs_viral"
fig_dir <- "results/figures/GSE211567_primary_bacterial_vs_viral"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading normalized expression matrix...")
expr_dt <- fread(expr_file)

feature_id <- expr_dt[[1]]
expr_mat <- as.matrix(expr_dt[, -1, with = FALSE])
rownames(expr_mat) <- feature_id
storage.mode(expr_mat) <- "numeric"

message("Reading locked sample table...")
samples <- fread(sample_file)
samples <- as.data.frame(samples)

primary <- samples[samples$include_in_primary_bacterial_vs_viral_discovery == "yes", , drop = FALSE]

primary_ids <- primary$expression_sample_id

missing_in_expr <- setdiff(primary_ids, colnames(expr_mat))
if (length(missing_in_expr) > 0) {
  stop("Primary samples missing from expression matrix: ", paste(missing_in_expr, collapse = ", "))
}

expr_primary <- expr_mat[, primary_ids, drop = FALSE]
rownames(primary) <- primary$expression_sample_id
primary <- primary[colnames(expr_primary), , drop = FALSE]

stopifnot(identical(rownames(primary), colnames(expr_primary)))

primary$discovery_group <- factor(primary$discovery_group, levels = c("viral", "bacterial"))
primary$site <- factor(primary$site)
primary$sequencing_batch <- factor(primary$sequencing_batch)

message("Creating design matrix...")
design <- model.matrix(~ discovery_group + site + sequencing_batch, data = primary)

rank_info <- data.table(
  model = "primary_pooled_group_site_batch",
  n_samples = nrow(design),
  n_columns = ncol(design),
  rank = qr(design)$rank,
  full_rank = qr(design)$rank == ncol(design),
  design_columns = paste(colnames(design), collapse = ";")
)

fwrite(rank_info, file.path(out_dir, "GSE211567_primary_model_rank_check.tsv"), sep = "\t")

if (!rank_info$full_rank[1]) {
  stop("Primary model matrix is not full rank.")
}

write.table(
  design,
  file = file.path(out_dir, "GSE211567_primary_design_matrix.tsv"),
  sep = "\t",
  quote = FALSE,
  col.names = NA
)

message("Fitting limma model...")
fit <- lmFit(expr_primary, design)
fit <- eBayes(fit, trend = TRUE, robust = TRUE)

coef_name <- "discovery_groupbacterial"
if (!(coef_name %in% colnames(fit$coefficients))) {
  stop("Expected coefficient not found: ", coef_name)
}

res <- topTable(fit, coef = coef_name, number = Inf, sort.by = "P")
res_dt <- as.data.table(res, keep.rownames = "feature_id")

# Make direction explicit: positive logFC = higher in bacterial relative to viral
res_dt[, contrast := "bacterial_vs_viral"]
res_dt[, logFC_direction := fifelse(logFC > 0, "higher_in_bacterial",
                             fifelse(logFC < 0, "higher_in_viral", "no_direction"))]

fwrite(
  res_dt,
  file.path(out_dir, "GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv"),
  sep = "\t"
)

summary_dt <- data.table(
  metric = c(
    "features_modelled",
    "primary_samples",
    "bacterial_samples",
    "viral_samples",
    "BH_FDR_lt_0.05",
    "BH_FDR_lt_0.10",
    "nominal_P_lt_0.05",
    "abs_logFC_ge_0.5_and_FDR_lt_0.05",
    "positive_logFC_features",
    "negative_logFC_features"
  ),
  value = c(
    nrow(res_dt),
    ncol(expr_primary),
    sum(primary$discovery_group == "bacterial"),
    sum(primary$discovery_group == "viral"),
    sum(res_dt$adj.P.Val < 0.05, na.rm = TRUE),
    sum(res_dt$adj.P.Val < 0.10, na.rm = TRUE),
    sum(res_dt$P.Value < 0.05, na.rm = TRUE),
    sum(abs(res_dt$logFC) >= 0.5 & res_dt$adj.P.Val < 0.05, na.rm = TRUE),
    sum(res_dt$logFC > 0, na.rm = TRUE),
    sum(res_dt$logFC < 0, na.rm = TRUE)
  )
)

fwrite(summary_dt, file.path(out_dir, "GSE211567_primary_limma_summary.tsv"), sep = "\t")

# Save model object
saveRDS(
  list(
    fit = fit,
    design = design,
    primary_metadata = primary,
    results = res_dt
  ),
  file.path(out_dir, "GSE211567_primary_limma_model_objects.rds")
)

# Volcano-style technical plot
plot_dt <- copy(res_dt)
plot_dt[, neg_log10_p := -log10(P.Value)]
plot_dt[, fdr_category := fifelse(adj.P.Val < 0.05, "FDR<0.05", "FDR>=0.05")]

p_volcano <- ggplot(plot_dt, aes(x = logFC, y = neg_log10_p, shape = fdr_category)) +
  geom_point(alpha = 0.55, size = 1.2) +
  theme_bw() +
  labs(
    title = "GSE211567 primary limma model: bacterial vs viral",
    x = "logFC, bacterial minus viral",
    y = "-log10(P value)",
    shape = "FDR category"
  )

ggsave(file.path(fig_dir, "GSE211567_primary_limma_volcano.png"), p_volcano, width = 7, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_primary_limma_volcano.pdf"), p_volcano, width = 7, height = 5)

# Mean-expression versus logFC plot
ave_col <- if ("AveExpr" %in% colnames(res_dt)) "AveExpr" else NULL
if (!is.null(ave_col)) {
  p_ma <- ggplot(plot_dt, aes(x = AveExpr, y = logFC, shape = fdr_category)) +
    geom_point(alpha = 0.55, size = 1.2) +
    theme_bw() +
    labs(
      title = "GSE211567 primary limma model: MA-style plot",
      x = "Average expression",
      y = "logFC, bacterial minus viral",
      shape = "FDR category"
    )
  ggsave(file.path(fig_dir, "GSE211567_primary_limma_MA_style.png"), p_ma, width = 7, height = 5, dpi = 300)
  ggsave(file.path(fig_dir, "GSE211567_primary_limma_MA_style.pdf"), p_ma, width = 7, height = 5)
}

# Top ranked preview table
top_preview <- res_dt[1:min(.N, 50)]
fwrite(top_preview, file.path(out_dir, "GSE211567_primary_limma_top50_preview.tsv"), sep = "\t")

sink(file.path(session_dir, "GSE211567_primary_limma_discovery_model_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_primary_limma_discovery_model_report.md")

writeLines(c(
  "# GSE211567 Primary limma Discovery Model Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: first ranked differential-expression model for the locked bacterial-versus-viral GSE211567 discovery set.",
  "- Model: normalized expression ~ discovery_group + site + sequencing_batch.",
  "- Contrast: bacterial versus viral; positive logFC means higher expression in bacterial samples relative to viral samples.",
  "- Boundary: this report provides ranked statistical evidence only. It does not perform pathway enrichment, module discovery, module orientation, transportability testing or biological interpretation.",
  "",
  "## Primary model sample set",
  "",
  paste0("- Primary samples: ", ncol(expr_primary)),
  paste0("- Bacterial samples: ", sum(primary$discovery_group == "bacterial")),
  paste0("- Viral samples: ", sum(primary$discovery_group == "viral")),
  "",
  "## Model matrix",
  "",
  paste(capture.output(print(rank_info)), collapse = "\n"),
  "",
  "## Statistical summary",
  "",
  paste(capture.output(print(summary_dt)), collapse = "\n"),
  "",
  "## Output files",
  "",
  paste0("- `", file.path(out_dir, "GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_primary_limma_summary.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_primary_design_matrix.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_primary_model_rank_check.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_primary_limma_top50_preview.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_primary_limma_model_objects.rds"), "`"),
  paste0("- `", file.path(fig_dir, "GSE211567_primary_limma_volcano.png"), "` and `.pdf`"),
  paste0("- `", file.path(fig_dir, "GSE211567_primary_limma_MA_style.png"), "` and `.pdf`"),
  "- `env/session_info/GSE211567_primary_limma_discovery_model_sessionInfo.txt`",
  "",
  "## Next required review",
  "",
  "- Review model diagnostics and summary counts.",
  "- Run site-stratified bacterial-versus-viral models for Sri Lanka and United States separately.",
  "- Compare direction and rank concordance between pooled and site-stratified models before pathway/module-level interpretation.",
  "",
  "## Boundary statement",
  "",
  "- Do not interpret individual genes biologically yet.",
  "- Do not define modules yet.",
  "- Do not run enrichment until pooled and site-stratified concordance has been reviewed."
), con = report_file)

message("Primary limma discovery model complete.")
message("Report: ", report_file)
