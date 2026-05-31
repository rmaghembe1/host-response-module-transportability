#!/usr/bin/env Rscript

# GSE211567 site-stratified limma concordance gate
# Purpose: test whether bacterial-vs-viral signal is directionally consistent across Sri Lanka and United States.
# Boundary: ranked statistical concordance only; no pathway enrichment, module discovery, or biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(limma)
  library(ggplot2)
})

expr_file <- "data/raw/GSE211567_normData_discovery_2021MAR24.txt.gz"
sample_file <- "data/metadata_harmonized/GSE211567_discovery_sample_table_locked.tsv"
pooled_file <- "results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv"

out_dir <- "results/differential_expression/GSE211567_site_stratified_concordance"
fig_dir <- "results/figures/GSE211567_site_stratified_concordance"
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
primary$discovery_group <- factor(primary$discovery_group, levels = c("viral", "bacterial"))
primary$site <- factor(primary$site)
primary$sequencing_batch <- factor(primary$sequencing_batch)

fit_site <- function(site_name) {
  message("Fitting site-stratified model: ", site_name)
  s <- primary[primary$site == site_name, , drop = FALSE]
  ids <- s$expression_sample_id

  missing <- setdiff(ids, colnames(expr_mat))
  if (length(missing) > 0) {
    stop("Missing samples for site ", site_name, ": ", paste(missing, collapse = ", "))
  }

  mat <- expr_mat[, ids, drop = FALSE]
  rownames(s) <- s$expression_sample_id
  s <- s[colnames(mat), , drop = FALSE]
  stopifnot(identical(rownames(s), colnames(mat)))

  s$discovery_group <- factor(s$discovery_group, levels = c("viral", "bacterial"))
  s$sequencing_batch <- factor(s$sequencing_batch)

  # Include sequencing batch if full-rank and both batches exist; otherwise use group-only.
  candidate_design <- model.matrix(~ discovery_group + sequencing_batch, data = s)
  group_design <- model.matrix(~ discovery_group, data = s)

  if (qr(candidate_design)$rank == ncol(candidate_design)) {
    design <- candidate_design
    model_formula <- "~ discovery_group + sequencing_batch"
  } else {
    design <- group_design
    model_formula <- "~ discovery_group"
  }

  rank_info <- data.table(
    site = site_name,
    n_samples = nrow(s),
    bacterial_samples = sum(s$discovery_group == "bacterial"),
    viral_samples = sum(s$discovery_group == "viral"),
    model_formula = model_formula,
    n_columns = ncol(design),
    rank = qr(design)$rank,
    full_rank = qr(design)$rank == ncol(design),
    design_columns = paste(colnames(design), collapse = ";")
  )

  fit <- lmFit(mat, design)
  fit <- eBayes(fit, trend = TRUE, robust = TRUE)

  coef_name <- "discovery_groupbacterial"
  if (!(coef_name %in% colnames(fit$coefficients))) {
    stop("Expected coefficient not found for site ", site_name)
  }

  res <- topTable(fit, coef = coef_name, number = Inf, sort.by = "P")
  res_dt <- as.data.table(res, keep.rownames = "feature_id")
  res_dt[, site := site_name]
  res_dt[, contrast := "bacterial_vs_viral"]
  res_dt[, logFC_direction := fifelse(logFC > 0, "higher_in_bacterial",
                               fifelse(logFC < 0, "higher_in_viral", "no_direction"))]

  safe_site <- gsub("[^A-Za-z0-9]+", "_", site_name)
  fwrite(res_dt, file.path(out_dir, paste0("GSE211567_", safe_site, "_limma_bacterial_vs_viral_ranked_results.tsv")), sep = "\t")

  summary_dt <- data.table(
    site = site_name,
    metric = c(
      "features_modelled",
      "samples",
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
      ncol(mat),
      sum(s$discovery_group == "bacterial"),
      sum(s$discovery_group == "viral"),
      sum(res_dt$adj.P.Val < 0.05, na.rm = TRUE),
      sum(res_dt$adj.P.Val < 0.10, na.rm = TRUE),
      sum(res_dt$P.Value < 0.05, na.rm = TRUE),
      sum(abs(res_dt$logFC) >= 0.5 & res_dt$adj.P.Val < 0.05, na.rm = TRUE),
      sum(res_dt$logFC > 0, na.rm = TRUE),
      sum(res_dt$logFC < 0, na.rm = TRUE)
    )
  )

  list(results = res_dt, summary = summary_dt, rank = rank_info)
}

sites <- sort(unique(primary$site))
site_fits <- lapply(sites, fit_site)
names(site_fits) <- sites

site_results <- rbindlist(lapply(site_fits, `[[`, "results"))
site_summaries <- rbindlist(lapply(site_fits, `[[`, "summary"))
site_rank <- rbindlist(lapply(site_fits, `[[`, "rank"))

fwrite(site_summaries, file.path(out_dir, "GSE211567_site_stratified_limma_summary.tsv"), sep = "\t")
fwrite(site_rank, file.path(out_dir, "GSE211567_site_stratified_model_rank_checks.tsv"), sep = "\t")

message("Reading pooled model results...")
pooled <- fread(pooled_file)

wide <- Reduce(function(x, y) merge(x, y, by = "feature_id", all = TRUE), list(
  pooled[, .(feature_id, pooled_logFC = logFC, pooled_P.Value = P.Value, pooled_adj.P.Val = adj.P.Val)],
  site_fits[["Sri_Lanka"]]$results[, .(feature_id, Sri_Lanka_logFC = logFC, Sri_Lanka_P.Value = P.Value, Sri_Lanka_adj.P.Val = adj.P.Val)],
  site_fits[["United_States"]]$results[, .(feature_id, United_States_logFC = logFC, United_States_P.Value = P.Value, United_States_adj.P.Val = adj.P.Val)]
))

wide[, pooled_direction := sign(pooled_logFC)]
wide[, Sri_Lanka_direction := sign(Sri_Lanka_logFC)]
wide[, United_States_direction := sign(United_States_logFC)]

wide[, pooled_Sri_Lanka_concordant := pooled_direction == Sri_Lanka_direction]
wide[, pooled_United_States_concordant := pooled_direction == United_States_direction]
wide[, Sri_Lanka_United_States_concordant := Sri_Lanka_direction == United_States_direction]
wide[, all_three_concordant := pooled_Sri_Lanka_concordant & pooled_United_States_concordant & Sri_Lanka_United_States_concordant]

fwrite(wide, file.path(out_dir, "GSE211567_pooled_site_stratified_concordance_table.tsv"), sep = "\t")

concordance_summary <- data.table(
  comparison = c(
    "pooled_vs_Sri_Lanka_all_features",
    "pooled_vs_United_States_all_features",
    "Sri_Lanka_vs_United_States_all_features",
    "all_three_all_features",
    "pooled_FDR05_vs_Sri_Lanka",
    "pooled_FDR05_vs_United_States",
    "pooled_FDR05_site_concordant_all_three"
  ),
  n_features = c(
    nrow(wide),
    nrow(wide),
    nrow(wide),
    nrow(wide),
    sum(pooled$adj.P.Val < 0.05),
    sum(pooled$adj.P.Val < 0.05),
    sum(pooled$adj.P.Val < 0.05)
  ),
  n_concordant = c(
    sum(wide$pooled_Sri_Lanka_concordant, na.rm = TRUE),
    sum(wide$pooled_United_States_concordant, na.rm = TRUE),
    sum(wide$Sri_Lanka_United_States_concordant, na.rm = TRUE),
    sum(wide$all_three_concordant, na.rm = TRUE),
    sum(wide[pooled_adj.P.Val < 0.05]$pooled_Sri_Lanka_concordant, na.rm = TRUE),
    sum(wide[pooled_adj.P.Val < 0.05]$pooled_United_States_concordant, na.rm = TRUE),
    sum(wide[pooled_adj.P.Val < 0.05]$all_three_concordant, na.rm = TRUE)
  )
)
concordance_summary[, pct_concordant := round(100 * n_concordant / n_features, 2)]

# Spearman correlations of logFCs
cor_summary <- data.table(
  comparison = c("pooled_vs_Sri_Lanka", "pooled_vs_United_States", "Sri_Lanka_vs_United_States"),
  spearman_logFC = c(
    suppressWarnings(cor(wide$pooled_logFC, wide$Sri_Lanka_logFC, method = "spearman", use = "complete.obs")),
    suppressWarnings(cor(wide$pooled_logFC, wide$United_States_logFC, method = "spearman", use = "complete.obs")),
    suppressWarnings(cor(wide$Sri_Lanka_logFC, wide$United_States_logFC, method = "spearman", use = "complete.obs"))
  ),
  pearson_logFC = c(
    suppressWarnings(cor(wide$pooled_logFC, wide$Sri_Lanka_logFC, method = "pearson", use = "complete.obs")),
    suppressWarnings(cor(wide$pooled_logFC, wide$United_States_logFC, method = "pearson", use = "complete.obs")),
    suppressWarnings(cor(wide$Sri_Lanka_logFC, wide$United_States_logFC, method = "pearson", use = "complete.obs"))
  )
)

fwrite(concordance_summary, file.path(out_dir, "GSE211567_direction_concordance_summary.tsv"), sep = "\t")
fwrite(cor_summary, file.path(out_dir, "GSE211567_logFC_correlation_summary.tsv"), sep = "\t")

# Top-feature overlap
get_top <- function(dt, n) dt[order(P.Value)][1:min(n, .N), feature_id]
top_sizes <- c(50, 100, 500, 1000)

top_overlap <- rbindlist(lapply(top_sizes, function(n) {
  pooled_top <- get_top(pooled, n)
  sl_top <- get_top(site_fits[["Sri_Lanka"]]$results, n)
  us_top <- get_top(site_fits[["United_States"]]$results, n)

  data.table(
    top_n = n,
    pooled_Sri_Lanka_overlap = length(intersect(pooled_top, sl_top)),
    pooled_United_States_overlap = length(intersect(pooled_top, us_top)),
    Sri_Lanka_United_States_overlap = length(intersect(sl_top, us_top)),
    all_three_overlap = length(Reduce(intersect, list(pooled_top, sl_top, us_top)))
  )
}))

fwrite(top_overlap, file.path(out_dir, "GSE211567_top_ranked_feature_overlap.tsv"), sep = "\t")

# Scatter plots
plot_scatter <- function(x, y, xlab, ylab, filename) {
  dt <- data.table(x = x, y = y)
  p <- ggplot(dt, aes(x = x, y = y)) +
    geom_point(alpha = 0.45, size = 0.8) +
    theme_bw() +
    labs(title = filename, x = xlab, y = ylab)
  ggsave(file.path(fig_dir, paste0(filename, ".png")), p, width = 6, height = 5, dpi = 300)
  ggsave(file.path(fig_dir, paste0(filename, ".pdf")), p, width = 6, height = 5)
}

plot_scatter(wide$pooled_logFC, wide$Sri_Lanka_logFC,
             "Pooled logFC", "Sri Lanka logFC",
             "GSE211567_logFC_scatter_pooled_vs_Sri_Lanka")

plot_scatter(wide$pooled_logFC, wide$United_States_logFC,
             "Pooled logFC", "United States logFC",
             "GSE211567_logFC_scatter_pooled_vs_United_States")

plot_scatter(wide$Sri_Lanka_logFC, wide$United_States_logFC,
             "Sri Lanka logFC", "United States logFC",
             "GSE211567_logFC_scatter_Sri_Lanka_vs_United_States")

sink(file.path(session_dir, "GSE211567_site_stratified_limma_concordance_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_site_stratified_limma_concordance_report.md")

writeLines(c(
  "# GSE211567 Site-Stratified limma Concordance Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: compare pooled and site-stratified bacterial-versus-viral limma rankings before pathway/module interpretation.",
  "- Boundary: ranked statistical concordance only; no pathway enrichment, module discovery, transportability testing or biological interpretation is performed here.",
  "",
  "## Site-stratified model summaries",
  "",
  paste(capture.output(print(site_summaries)), collapse = "\n"),
  "",
  "## Site-stratified model rank checks",
  "",
  paste(capture.output(print(site_rank)), collapse = "\n"),
  "",
  "## Directional concordance summary",
  "",
  paste(capture.output(print(concordance_summary)), collapse = "\n"),
  "",
  "## logFC correlation summary",
  "",
  paste(capture.output(print(cor_summary)), collapse = "\n"),
  "",
  "## Top-ranked feature overlap",
  "",
  paste(capture.output(print(top_overlap)), collapse = "\n"),
  "",
  "## Technical interpretation gate",
  "",
  "- If pooled-versus-site logFC correlations and directional concordance are strong, proceed to pathway/module discovery with site-aware caution.",
  "- If Sri Lanka and United States are weakly concordant, prioritize stable cross-site directional modules rather than pooled-only gene hits.",
  "- Do not interpret individual genes or pathways until this concordance gate is reviewed.",
  "",
  "## Generated files",
  "",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_Sri_Lanka_limma_bacterial_vs_viral_ranked_results.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_United_States_limma_bacterial_vs_viral_ranked_results.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_site_stratified_limma_summary.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_site_stratified_model_rank_checks.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_pooled_site_stratified_concordance_table.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_direction_concordance_summary.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_logFC_correlation_summary.tsv`",
  "- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_top_ranked_feature_overlap.tsv`",
  "- `results/figures/GSE211567_site_stratified_concordance/*logFC_scatter*.png/.pdf`",
  "- `env/session_info/GSE211567_site_stratified_limma_concordance_sessionInfo.txt`",
  "",
  "## Boundary statement",
  "",
  "- This report does not define biological modules.",
  "- This report does not perform enrichment.",
  "- This report does not make biological claims."
), con = report_file)

message("Site-stratified limma concordance gate complete.")
message("Report: ", report_file)
