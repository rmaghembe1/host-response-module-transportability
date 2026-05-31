#!/usr/bin/env Rscript

# GSE211567 site-aware stable-feature table
# Purpose: annotate pooled bacterial-vs-viral ranked evidence with site-stratified concordance.
# Boundary: feature-stability annotation only; no pathway enrichment, module discovery, or biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

pooled_file <- "results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv"
concordance_file <- "results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_pooled_site_stratified_concordance_table.tsv"
sl_file <- "results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_Sri_Lanka_limma_bacterial_vs_viral_ranked_results.tsv"
us_file <- "results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_United_States_limma_bacterial_vs_viral_ranked_results.tsv"

out_dir <- "results/module_lock/GSE211567_site_aware_feature_stability"
fig_dir <- "results/figures/GSE211567_site_aware_feature_stability"
docs_dir <- "docs"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading model outputs...")
pooled <- fread(pooled_file)
conc <- fread(concordance_file)
sl <- fread(sl_file)
us <- fread(us_file)

pooled[, pooled_rank := frank(P.Value, ties.method = "first")]
sl[, Sri_Lanka_rank := frank(P.Value, ties.method = "first")]
us[, United_States_rank := frank(P.Value, ties.method = "first")]

tab <- merge(
  pooled[, .(
    feature_id,
    pooled_rank,
    pooled_logFC = logFC,
    pooled_AveExpr = AveExpr,
    pooled_t = t,
    pooled_P.Value = P.Value,
    pooled_adj.P.Val = adj.P.Val,
    pooled_B = B
  )],
  sl[, .(
    feature_id,
    Sri_Lanka_rank,
    Sri_Lanka_logFC = logFC,
    Sri_Lanka_P.Value = P.Value,
    Sri_Lanka_adj.P.Val = adj.P.Val
  )],
  by = "feature_id",
  all = TRUE
)

tab <- merge(
  tab,
  us[, .(
    feature_id,
    United_States_rank,
    United_States_logFC = logFC,
    United_States_P.Value = P.Value,
    United_States_adj.P.Val = adj.P.Val
  )],
  by = "feature_id",
  all = TRUE
)

tab <- merge(
  tab,
  conc[, .(
    feature_id,
    pooled_direction,
    Sri_Lanka_direction,
    United_States_direction,
    pooled_Sri_Lanka_concordant,
    pooled_United_States_concordant,
    Sri_Lanka_United_States_concordant,
    all_three_concordant
  )],
  by = "feature_id",
  all.x = TRUE
)

tab[, pooled_FDR05 := pooled_adj.P.Val < 0.05]
tab[, pooled_FDR10 := pooled_adj.P.Val < 0.10]
tab[, Sri_Lanka_FDR05 := Sri_Lanka_adj.P.Val < 0.05]
tab[, United_States_FDR05 := United_States_adj.P.Val < 0.05]

tab[, site_FDR05_count := as.integer(Sri_Lanka_FDR05) + as.integer(United_States_FDR05)]
tab[, site_direction_concordance_count :=
      as.integer(pooled_Sri_Lanka_concordant) +
      as.integer(pooled_United_States_concordant) +
      as.integer(Sri_Lanka_United_States_concordant)]

tab[, min_abs_site_logFC := pmin(abs(Sri_Lanka_logFC), abs(United_States_logFC), na.rm = TRUE)]
tab[, mean_abs_site_logFC := rowMeans(cbind(abs(Sri_Lanka_logFC), abs(United_States_logFC)), na.rm = TRUE)]

tab[, stability_tier := fifelse(
  pooled_FDR05 & all_three_concordant & site_FDR05_count == 2,
  "Tier_1_cross_site_FDR05_direction_concordant",
  fifelse(
    pooled_FDR05 & all_three_concordant & site_FDR05_count >= 1,
    "Tier_2_pooled_FDR05_all_direction_concordant_one_site_FDR05",
    fifelse(
      pooled_FDR05 & all_three_concordant,
      "Tier_3_pooled_FDR05_all_direction_concordant_site_nominal_or_weaker",
      fifelse(
        pooled_FDR05 & (pooled_Sri_Lanka_concordant | pooled_United_States_concordant),
        "Tier_4_pooled_FDR05_partial_site_direction_support",
        fifelse(
          pooled_FDR10 & all_three_concordant,
          "Tier_5_pooled_FDR10_all_direction_concordant",
          "Lower_or_unstable"
        )
      )
    )
  )
)]

tab[, recommended_use := fifelse(
  stability_tier %in% c(
    "Tier_1_cross_site_FDR05_direction_concordant",
    "Tier_2_pooled_FDR05_all_direction_concordant_one_site_FDR05",
    "Tier_3_pooled_FDR05_all_direction_concordant_site_nominal_or_weaker"
  ),
  "eligible_for_site_aware_pathway_or_module_discovery",
  fifelse(
    stability_tier == "Tier_4_pooled_FDR05_partial_site_direction_support",
    "secondary_or_site_contextual_signal",
    "not_prioritized_for_stable_module_discovery"
  )
)]

tab[, bacterial_higher_stable := pooled_logFC > 0 & all_three_concordant]
tab[, viral_higher_stable := pooled_logFC < 0 & all_three_concordant]

setorder(tab, pooled_P.Value)

out_file <- file.path(out_dir, "GSE211567_site_aware_stable_feature_table.tsv")
fwrite(tab, out_file, sep = "\t")

tier_summary <- tab[, .N, by = stability_tier][order(stability_tier)]
use_summary <- tab[, .N, by = recommended_use][order(recommended_use)]
direction_summary <- data.table(
  category = c(
    "pooled_FDR05_all_three_concordant",
    "stable_bacterial_higher_all_three",
    "stable_viral_higher_all_three",
    "eligible_for_site_aware_discovery",
    "secondary_or_site_contextual",
    "not_prioritized"
  ),
  n = c(
    sum(tab$pooled_FDR05 & tab$all_three_concordant, na.rm = TRUE),
    sum(tab$bacterial_higher_stable & tab$pooled_FDR05, na.rm = TRUE),
    sum(tab$viral_higher_stable & tab$pooled_FDR05, na.rm = TRUE),
    sum(tab$recommended_use == "eligible_for_site_aware_pathway_or_module_discovery", na.rm = TRUE),
    sum(tab$recommended_use == "secondary_or_site_contextual_signal", na.rm = TRUE),
    sum(tab$recommended_use == "not_prioritized_for_stable_module_discovery", na.rm = TRUE)
  )
)

fwrite(tier_summary, file.path(out_dir, "GSE211567_site_aware_stability_tier_summary.tsv"), sep = "\t")
fwrite(use_summary, file.path(out_dir, "GSE211567_site_aware_recommended_use_summary.tsv"), sep = "\t")
fwrite(direction_summary, file.path(out_dir, "GSE211567_site_aware_direction_summary.tsv"), sep = "\t")

eligible <- tab[recommended_use == "eligible_for_site_aware_pathway_or_module_discovery"]
eligible_bacterial <- eligible[pooled_logFC > 0][order(pooled_P.Value)]
eligible_viral <- eligible[pooled_logFC < 0][order(pooled_P.Value)]

fwrite(eligible, file.path(out_dir, "GSE211567_site_aware_eligible_features.tsv"), sep = "\t")
fwrite(eligible_bacterial, file.path(out_dir, "GSE211567_site_aware_eligible_bacterial_higher_features.tsv"), sep = "\t")
fwrite(eligible_viral, file.path(out_dir, "GSE211567_site_aware_eligible_viral_higher_features.tsv"), sep = "\t")

# Plot tier counts
p_tier <- ggplot(tier_summary, aes(x = stability_tier, y = N)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 site-aware feature stability tiers",
    x = "Stability tier",
    y = "Feature count"
  )

ggsave(file.path(fig_dir, "GSE211567_site_aware_stability_tier_counts.png"), p_tier, width = 9, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_site_aware_stability_tier_counts.pdf"), p_tier, width = 9, height = 5)

# Plot pooled vs sites, highlight eligible
plot_dt <- copy(tab)
plot_dt[, eligible := recommended_use == "eligible_for_site_aware_pathway_or_module_discovery"]

p_sl <- ggplot(plot_dt, aes(x = pooled_logFC, y = Sri_Lanka_logFC, shape = eligible)) +
  geom_point(alpha = 0.45, size = 0.9) +
  theme_bw() +
  labs(
    title = "Pooled vs Sri Lanka logFC with eligible stable features",
    x = "Pooled logFC",
    y = "Sri Lanka logFC",
    shape = "Eligible"
  )

ggsave(file.path(fig_dir, "GSE211567_pooled_vs_Sri_Lanka_stable_feature_scatter.png"), p_sl, width = 6, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_pooled_vs_Sri_Lanka_stable_feature_scatter.pdf"), p_sl, width = 6, height = 5)

p_us <- ggplot(plot_dt, aes(x = pooled_logFC, y = United_States_logFC, shape = eligible)) +
  geom_point(alpha = 0.45, size = 0.9) +
  theme_bw() +
  labs(
    title = "Pooled vs United States logFC with eligible stable features",
    x = "Pooled logFC",
    y = "United States logFC",
    shape = "Eligible"
  )

ggsave(file.path(fig_dir, "GSE211567_pooled_vs_United_States_stable_feature_scatter.png"), p_us, width = 6, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_pooled_vs_United_States_stable_feature_scatter.pdf"), p_us, width = 6, height = 5)

report_file <- file.path(docs_dir, "GSE211567_site_aware_stable_feature_table_report.md")

writeLines(c(
  "# GSE211567 Site-Aware Stable-Feature Table Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: annotate pooled bacterial-versus-viral ranked evidence with site-stratified direction and FDR support before pathway/module discovery.",
  "- Boundary: this step creates feature-stability annotations only. It does not perform pathway enrichment, module discovery, external validation or biological interpretation.",
  "",
  "## Stability tier summary",
  "",
  paste(capture.output(print(tier_summary)), collapse = "\n"),
  "",
  "## Recommended-use summary",
  "",
  paste(capture.output(print(use_summary)), collapse = "\n"),
  "",
  "## Direction summary",
  "",
  paste(capture.output(print(direction_summary)), collapse = "\n"),
  "",
  "## Eligible feature sets",
  "",
  paste0("- Eligible site-aware features: ", nrow(eligible)),
  paste0("- Eligible bacterial-higher features: ", nrow(eligible_bacterial)),
  paste0("- Eligible viral-higher features: ", nrow(eligible_viral)),
  "",
  "## Intended use",
  "",
  "- Use eligible site-aware features for pathway/module discovery input.",
  "- Use bacterial-higher and viral-higher eligible subsets for direction-aware enrichment/module construction.",
  "- Treat partial-support features as secondary or site-contextual evidence, not core stable modules.",
  "- Do not use unstable/lower-tier features as primary module anchors.",
  "",
  "## Generated files",
  "",
  paste0("- `", out_file, "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_stability_tier_summary.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_recommended_use_summary.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_direction_summary.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_eligible_features.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_eligible_bacterial_higher_features.tsv"), "`"),
  paste0("- `", file.path(out_dir, "GSE211567_site_aware_eligible_viral_higher_features.tsv"), "`"),
  paste0("- `", file.path(fig_dir, "GSE211567_site_aware_stability_tier_counts.png"), "` and `.pdf`"),
  paste0("- `", file.path(fig_dir, "GSE211567_pooled_vs_Sri_Lanka_stable_feature_scatter.png"), "` and `.pdf`"),
  paste0("- `", file.path(fig_dir, "GSE211567_pooled_vs_United_States_stable_feature_scatter.png"), "` and `.pdf`"),
  "",
  "## Boundary statement",
  "",
  "- This report does not define named biological modules.",
  "- This report does not interpret genes or pathways.",
  "- This report establishes a site-aware evidence table for the next enrichment/module-discovery step."
), con = report_file)

message("Site-aware stable-feature table complete.")
message("Report: ", report_file)
