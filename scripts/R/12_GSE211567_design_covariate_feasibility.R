#!/usr/bin/env Rscript

# GSE211567 design/covariate feasibility check
# Purpose: evaluate modelling design feasibility before discovery analysis.
# No differential expression, no pathway enrichment, no module discovery, no biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
})

qc_dir <- "results/qc/GSE211567_locked_normalized_matrix"
dir.create(qc_dir, recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)

sample_file <- "data/metadata_harmonized/GSE211567_discovery_sample_table_locked.tsv"
samples <- fread(sample_file)

# Primary bacterial-vs-viral samples only
primary <- samples[include_in_primary_bacterial_vs_viral_discovery == "yes"]
primary[, discovery_group := factor(discovery_group, levels = c("viral", "bacterial"))]
primary[, site := factor(site)]
primary[, sequencing_batch := factor(sequencing_batch)]
primary[, platform_id := factor(platform_id)]
primary[, instrument_model := factor(instrument_model)]
primary[, pathogen := factor(pathogen)]
primary[, gender := factor(gender)]
primary[, race_clean := fifelse(is.na(race) | race == "", "MISSING", race)]
primary[, race_clean := factor(race_clean)]
primary[, age_numeric := suppressWarnings(as.numeric(age))]

write_table <- function(x, filename) {
  fwrite(as.data.table(x), file.path(qc_dir, filename), sep = "\t")
}

# Count tables
write_table(table(primary$discovery_group), "GSE211567_design_primary_group_counts.tsv")
write_table(table(primary$site), "GSE211567_design_primary_site_counts.tsv")
write_table(table(primary$sequencing_batch), "GSE211567_design_primary_batch_counts.tsv")
write_table(table(primary$platform_id), "GSE211567_design_primary_platform_counts.tsv")
write_table(table(primary$instrument_model), "GSE211567_design_primary_instrument_counts.tsv")
write_table(table(primary$pathogen), "GSE211567_design_primary_pathogen_counts.tsv")
write_table(table(primary$gender, useNA = "ifany"), "GSE211567_design_primary_gender_counts.tsv")
write_table(table(primary$race_clean, useNA = "ifany"), "GSE211567_design_primary_race_counts.tsv")

write_table(table(primary$site, primary$discovery_group), "GSE211567_design_site_by_group.tsv")
write_table(table(primary$sequencing_batch, primary$discovery_group), "GSE211567_design_batch_by_group.tsv")
write_table(table(primary$platform_id, primary$discovery_group), "GSE211567_design_platform_by_group.tsv")
write_table(table(primary$instrument_model, primary$discovery_group), "GSE211567_design_instrument_by_group.tsv")
write_table(table(primary$site, primary$sequencing_batch), "GSE211567_design_site_by_batch.tsv")
write_table(table(primary$site, primary$pathogen), "GSE211567_design_site_by_pathogen.tsv")
write_table(table(primary$discovery_group, primary$pathogen), "GSE211567_design_group_by_pathogen.tsv")

# Model matrix rank checks
rank_check <- function(formula, data, label) {
  mm <- model.matrix(formula, data = data)
  qr_rank <- qr(mm)$rank
  data.table(
    model_label = label,
    formula = deparse(formula),
    n_samples = nrow(mm),
    n_columns = ncol(mm),
    rank = qr_rank,
    full_rank = qr_rank == ncol(mm),
    column_names = paste(colnames(mm), collapse = ";")
  )
}

rank_checks <- rbindlist(list(
  rank_check(~ discovery_group, primary, "group_only"),
  rank_check(~ discovery_group + site, primary, "group_plus_site"),
  rank_check(~ discovery_group + sequencing_batch, primary, "group_plus_batch"),
  rank_check(~ discovery_group + site + sequencing_batch, primary, "group_plus_site_plus_batch"),
  rank_check(~ discovery_group + platform_id, primary, "group_plus_platform"),
  rank_check(~ discovery_group + instrument_model, primary, "group_plus_instrument"),
  rank_check(~ discovery_group + site + sequencing_batch + age_numeric + gender, primary[!is.na(age_numeric)], "group_site_batch_age_gender_complete_age")
), fill = TRUE)

fwrite(rank_checks, file.path(qc_dir, "GSE211567_design_model_matrix_rank_checks.tsv"), sep = "\t")

# Covariate completeness
covariate_completeness <- data.table(
  covariate = c("age_numeric", "gender", "race", "site", "sequencing_batch", "platform_id", "instrument_model", "pathogen"),
  n_nonmissing = c(
    sum(!is.na(primary$age_numeric)),
    sum(!is.na(primary$gender) & primary$gender != ""),
    sum(!is.na(primary$race) & primary$race != ""),
    sum(!is.na(primary$site) & primary$site != ""),
    sum(!is.na(primary$sequencing_batch) & primary$sequencing_batch != ""),
    sum(!is.na(primary$platform_id) & primary$platform_id != ""),
    sum(!is.na(primary$instrument_model) & primary$instrument_model != ""),
    sum(!is.na(primary$pathogen) & primary$pathogen != "")
  ),
  n_total = nrow(primary)
)
covariate_completeness[, pct_nonmissing := round(100 * n_nonmissing / n_total, 2)]
fwrite(covariate_completeness, file.path(qc_dir, "GSE211567_design_covariate_completeness.tsv"), sep = "\t")

# Site-stratified primary group counts
site_group <- as.data.table(table(primary$site, primary$discovery_group))
setnames(site_group, c("site", "discovery_group", "n"))
fwrite(site_group, file.path(qc_dir, "GSE211567_design_site_stratified_primary_counts.tsv"), sep = "\t")

# Practical recommendations
site_group_wide <- dcast(site_group, site ~ discovery_group, value.var = "n", fill = 0)
site_has_both_groups <- all(site_group_wide$bacterial > 0 & site_group_wide$viral > 0)

rank_group_site_batch <- rank_checks[model_label == "group_plus_site_plus_batch", full_rank]
rank_group_site <- rank_checks[model_label == "group_plus_site", full_rank]
rank_group_batch <- rank_checks[model_label == "group_plus_batch", full_rank]

age_complete <- covariate_completeness[covariate == "age_numeric", pct_nonmissing]
gender_complete <- covariate_completeness[covariate == "gender", pct_nonmissing]
race_complete <- covariate_completeness[covariate == "race", pct_nonmissing]

primary_recommendation <- if (isTRUE(rank_group_site_batch)) {
  "A pooled primary design including discovery group, site and sequencing batch is algebraically full-rank and feasible as a technical starting point."
} else if (isTRUE(rank_group_site)) {
  "A pooled design including discovery group and site is full-rank, but adding sequencing batch causes rank/confounding concerns."
} else {
  "A pooled group-plus-site design is not full-rank; site-stratified analysis should be prioritized."
}

site_recommendation <- if (site_has_both_groups) {
  "Both sites contain bacterial and viral samples, so site-stratified bacterial-versus-viral concordance is feasible."
} else {
  "At least one site lacks both bacterial and viral groups; site-stratified bacterial-versus-viral concordance is limited."
}

covariate_recommendation <- paste0(
  "Age completeness = ", age_complete, "%; gender completeness = ", gender_complete,
  "%; race completeness = ", race_complete,
  "%. Age/gender may be considered cautiously if full-rank models remain stable; race should be handled carefully because missingness is site-linked."
)

report_file <- "docs/GSE211567_design_covariate_feasibility_report.md"

writeLines(c(
  "# GSE211567 Design/Covariate Feasibility Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: assess design/covariate feasibility before GSE211567 discovery modelling.",
  "- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.",
  "",
  "## Primary discovery sample set",
  "",
  paste0("- Primary bacterial-versus-viral samples: ", nrow(primary)),
  paste0("- Bacterial samples: ", sum(primary$discovery_group == "bacterial")),
  paste0("- Viral samples: ", sum(primary$discovery_group == "viral")),
  "",
  "## Site × group structure",
  "",
  paste(capture.output(print(as.data.table(table(primary$site, primary$discovery_group)))), collapse = "\n"),
  "",
  "## Batch × group structure",
  "",
  paste(capture.output(print(as.data.table(table(primary$sequencing_batch, primary$discovery_group)))), collapse = "\n"),
  "",
  "## Site × batch structure",
  "",
  paste(capture.output(print(as.data.table(table(primary$site, primary$sequencing_batch)))), collapse = "\n"),
  "",
  "## Group × pathogen structure",
  "",
  paste(capture.output(print(as.data.table(table(primary$discovery_group, primary$pathogen)))), collapse = "\n"),
  "",
  "## Covariate completeness",
  "",
  paste(capture.output(print(covariate_completeness)), collapse = "\n"),
  "",
  "## Model matrix rank checks",
  "",
  paste(capture.output(print(rank_checks[, .(model_label, n_samples, n_columns, rank, full_rank)])), collapse = "\n"),
  "",
  "## Technical recommendations",
  "",
  paste0("- ", primary_recommendation),
  paste0("- ", site_recommendation),
  paste0("- ", covariate_recommendation),
  "- Pathogen is biologically nested within infection group and partly site-linked, so it should not be included as a simple adjustment covariate in the primary bacterial-versus-viral discovery model.",
  "- Noninfection samples should remain contextual/control samples, not part of the primary bacterial-versus-viral contrast.",
  "- A design decision should be logged before running discovery modelling.",
  "",
  "## Generated files",
  "",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_group_counts.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_site_counts.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_batch_counts.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_site_by_group.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_batch_by_group.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_site_by_batch.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_group_by_pathogen.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_covariate_completeness.tsv`",
  "- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_model_matrix_rank_checks.tsv`",
  "",
  "## Boundary statement",
  "",
  "- This report determines technical feasibility of candidate model structures only.",
  "- It does not select genes.",
  "- It does not define biological modules.",
  "- It does not interpret host-response biology."
), con = report_file)

message("GSE211567 design/covariate feasibility check complete.")
message("Report: ", report_file)
