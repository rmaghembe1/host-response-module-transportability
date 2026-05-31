#!/usr/bin/env Rscript

# GSE73461 manuscript projection figure panels
# Purpose: generate manuscript-facing figure panels from fixed-module projection outputs.
# Boundary: figure generation only; no new scoring, no gene reselection, no model training.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

source("scripts/R/00_publication_figure_export_helpers.R")

main_scores_file <- "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv"
main_test_file <- "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv"
sens_test_file <- "results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv"
summary_table_file <- "results/tables/GSE73461_manuscript_projection_summary_table.tsv"

fig_dir <- "results/figures/GSE73461_manuscript_projection_panels"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

scores <- fread(main_scores_file)
main_test <- fread(main_test_file)
sens_test <- fread(sens_test_file)
summary_tab <- fread(summary_table_file)

module_order <- c("BACT_M1", "BACT_M2", "VIR_M1a", "VIR_M1b", "VIR_M2")
scores[, final_module_id := factor(final_module_id, levels = module_order)]
scores[, projection_role := factor(
  projection_role,
  levels = c("primary_bacterial", "primary_viral", "secondary_control_context"),
  labels = c("DefiniteBacterial", "DefiniteViral", "Control")
)]

main_plot_dt <- scores[projection_role %in% c("DefiniteBacterial", "DefiniteViral")]

p_scores <- ggplot(main_plot_dt, aes(x = projection_role, y = module_score)) +
  geom_boxplot(outlier.shape = NA, width = 0.55) +
  geom_jitter(width = 0.15, alpha = 0.45, size = 1.1) +
  facet_wrap(~ final_module_id, scales = "free_y", nrow = 1) +
  labs(
    title = "External projection of locked discovery modules in GSE73461",
    subtitle = "Fixed module scores in DefiniteBacterial versus DefiniteViral samples",
    x = NULL,
    y = "Module score: unweighted mean z-score"
  ) +
  theme_bw(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    strip.background = element_rect(fill = "grey95"),
    panel.grid.minor = element_blank()
  )

save_publication_figure(
  plot = p_scores,
  filename_base = "Figure_GSE73461_A_module_score_distributions",
  out_dir = fig_dir,
  width = 12,
  height = 4.8,
  dpi = 1800
)

main_test[, analysis := "Main projection"]
sens_test[, analysis := "Primary-only z-score sensitivity"]

main_diff <- main_test[, .(
  final_module_id,
  analysis,
  median_difference_bacterial_minus_viral,
  wilcox_p_BH,
  expected_direction_match
)]

sens_diff <- sens_test[, .(
  final_module_id,
  analysis,
  median_difference_bacterial_minus_viral,
  wilcox_p_BH,
  expected_direction_match
)]

diff_dt <- rbind(main_diff, sens_diff, use.names = TRUE)
diff_dt[, final_module_id := factor(final_module_id, levels = module_order)]
diff_dt[, analysis := factor(analysis, levels = c("Main projection", "Primary-only z-score sensitivity"))]

p_diff <- ggplot(diff_dt, aes(x = final_module_id, y = median_difference_bacterial_minus_viral, fill = analysis)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.62) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Direction and robustness of external module projection",
    subtitle = "Positive values indicate higher scores in DefiniteBacterial; negative values indicate higher scores in DefiniteViral",
    x = "Locked module",
    y = "Median difference: bacterial minus viral",
    fill = NULL
  ) +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank())

save_publication_figure(
  plot = p_diff,
  filename_base = "Figure_GSE73461_B_main_vs_sensitivity_median_differences",
  out_dir = fig_dir,
  width = 9,
  height = 5,
  dpi = 1800
)

p_pvals <- ggplot(diff_dt, aes(x = final_module_id, y = -log10(wilcox_p_BH), group = analysis, shape = analysis)) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  geom_point(size = 3) +
  geom_line(position = position_dodge(width = 0.2)) +
  labs(
    title = "Projection significance is preserved in primary-only z-score sensitivity",
    subtitle = "Dashed line indicates BH-adjusted P = 0.05",
    x = "Locked module",
    y = expression(-log[10]("BH-adjusted P")),
    shape = NULL
  ) +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank())

save_publication_figure(
  plot = p_pvals,
  filename_base = "Figure_GSE73461_C_main_vs_sensitivity_pvalues",
  out_dir = fig_dir,
  width = 9,
  height = 5,
  dpi = 1800
)

caption_file <- file.path(docs_dir, "GSE73461_manuscript_projection_figure_caption.md")
sink(caption_file)
cat("# Figure Caption Draft — GSE73461 External Projection\n\n")
cat("Figure X. External projection of locked GSE211567 host-response modules in GSE73461. ")
cat("Locked bacterial- and viral-associated discovery modules were scored in the independent GSE73461 cohort using the pre-specified unweighted mean z-score rule without gene reselection, module renaming, reweighting or diagnostic model training. ")
cat("(A) Module-score distributions in the primary DefiniteBacterial and DefiniteViral projection groups. ")
cat("(B) Median bacterial-minus-viral score differences in the main projection and in the primary-only z-score sensitivity analysis. Positive values indicate higher module scores in DefiniteBacterial samples, whereas negative values indicate higher module scores in DefiniteViral samples. ")
cat("(C) BH-adjusted Wilcoxon significance in the main and sensitivity analyses. The dashed line indicates BH-adjusted P = 0.05. ")
cat("All five modules retained the expected discovery direction in GSE73461. BACT_M1 was directionally concordant but borderline, whereas BACT_M2 and all viral-associated modules showed robust external transportability.\n")
sink()

writeLines(capture.output(sessionInfo()), "env/session_info/GSE73461_manuscript_projection_figure_panels_sessionInfo.txt")

message("Wrote figure panels to: ", fig_dir)
message("Wrote caption: ", caption_file)
