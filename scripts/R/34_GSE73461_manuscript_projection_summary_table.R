#!/usr/bin/env Rscript

# GSE73461 manuscript-ready projection summary table
# Purpose: combine main projection and primary-only z-score sensitivity results into a manuscript-facing table.
# Boundary: table generation only; no new scoring, no gene reselection, no model training.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
})

main_test_file <- "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv"
main_cov_file <- "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_projection_coverage.tsv"
sens_test_file <- "results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv"
out_dir <- "results/tables"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

main <- fread(main_test_file)
cov <- fread(main_cov_file)
sens <- fread(sens_test_file)

main_keep <- main[, .(
  final_module_id,
  final_module_label,
  final_module_direction,
  main_median_difference_bacterial_minus_viral = median_difference_bacterial_minus_viral,
  main_wilcox_p = wilcox_p,
  main_wilcox_p_BH = wilcox_p_BH,
  main_expected_direction_match = expected_direction_match
)]

sens_keep <- sens[, .(
  final_module_id,
  sensitivity_median_difference_bacterial_minus_viral = median_difference_bacterial_minus_viral,
  sensitivity_wilcox_p = wilcox_p,
  sensitivity_wilcox_p_BH = wilcox_p_BH,
  sensitivity_expected_direction_match = expected_direction_match
)]

cov_keep <- cov[, .(
  final_module_id,
  locked_genes_n,
  matched_genes_n,
  coverage_fraction,
  missing_symbols
)]

tab <- merge(main_keep, sens_keep, by = "final_module_id", all.x = TRUE)
tab <- merge(tab, cov_keep, by = "final_module_id", all.x = TRUE)

tab[, discovery_direction := fifelse(
  final_module_direction == "higher_in_bacterial",
  "Higher in bacterial",
  fifelse(final_module_direction == "higher_in_viral", "Higher in viral", final_module_direction)
)]

tab[, conservative_module_label := final_module_label]
tab[, interpretation_tier := fifelse(
  final_module_id == "BACT_M1",
  "Directionally concordant but borderline",
  fifelse(
    final_module_id %in% c("VIR_M1a", "VIR_M1b"),
    "Strongly and robustly externally transported",
    "Robustly externally transported"
  )
)]

tab[, main_result := sprintf(
  "%+.4f; BH P = %.3g",
  main_median_difference_bacterial_minus_viral,
  main_wilcox_p_BH
)]

tab[, sensitivity_result := sprintf(
  "%+.4f; BH P = %.3g",
  sensitivity_median_difference_bacterial_minus_viral,
  sensitivity_wilcox_p_BH
)]

final_tab <- tab[, .(
  Module = final_module_id,
  `Conservative module label` = conservative_module_label,
  `Discovery direction` = discovery_direction,
  `Locked genes` = locked_genes_n,
  `Genes scored in GSE73461` = matched_genes_n,
  `Main projection result` = main_result,
  `Primary-only z-score sensitivity result` = sensitivity_result,
  `Expected direction in main analysis` = main_expected_direction_match,
  `Expected direction in sensitivity` = sensitivity_expected_direction_match,
  `Interpretation tier` = interpretation_tier,
  `Missing genes` = missing_symbols
)]

setorder(final_tab, Module)

fwrite(final_tab, file.path(out_dir, "GSE73461_manuscript_projection_summary_table.tsv"), sep = "\t")

md_file <- file.path(docs_dir, "GSE73461_manuscript_projection_summary_table.md")
sink(md_file)
cat("# GSE73461 Manuscript Projection Summary Table\n\n")
cat("| Module | Conservative module label | Discovery direction | Locked genes | Genes scored | Main projection result | Primary-only z-score sensitivity result | Interpretation tier |\n")
cat("|---|---|---|---:|---:|---|---|---|\n")
for (i in seq_len(nrow(final_tab))) {
  r <- final_tab[i]
  cat(sprintf(
    "| %s | %s | %s | %s | %s | %s | %s | %s |\n",
    r$Module,
    r$`Conservative module label`,
    r$`Discovery direction`,
    r$`Locked genes`,
    r$`Genes scored in GSE73461`,
    r$`Main projection result`,
    r$`Primary-only z-score sensitivity result`,
    r$`Interpretation tier`
  ))
}
cat("\n## Notes\n\n")
cat("- Main projection used the locked GSE73461 projection sample set with Control retained only as secondary context.\n")
cat("- Primary-only z-score sensitivity excluded Control samples from the z-score reference set.\n")
cat("- Positive median differences indicate higher module scores in DefiniteBacterial; negative median differences indicate higher module scores in DefiniteViral.\n")
cat("- This table summarizes fixed-module projection, not diagnostic model discovery.\n")
sink()

writeLines(capture.output(sessionInfo()), "env/session_info/GSE73461_manuscript_projection_summary_table_sessionInfo.txt")

message("Wrote: ", file.path(out_dir, "GSE73461_manuscript_projection_summary_table.tsv"))
message("Wrote: ", md_file)
