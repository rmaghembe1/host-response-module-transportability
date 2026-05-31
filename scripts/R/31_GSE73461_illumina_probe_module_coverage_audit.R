#!/usr/bin/env Rscript

# GSE73461 Illumina probe annotation and locked-module coverage audit
# Purpose: map GSE73461 ILMN probes using illuminaHumanv4.db and assess locked GSE211567 module coverage.
# Boundary: identifier coverage audit only; no module scoring, cohort lock or biological validation claim.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(AnnotationDbi)
  library(illuminaHumanv4.db)
})

raw_expr_file <- "data/expression_raw/GSE73461/GSE73461_GEOupload_Discovery_Dataset_Raw_Sept_15_n_459.txt.gz"

# Auto-detect the locked GSE211567 projection-ready module gene table.
# The exact filename may differ depending on the earlier module-input script version.
module_input_dir <- "results/module_scoring/GSE211567_projection_ready_inputs"
candidate_module_files <- list.files(
  module_input_dir,
  pattern = "\\.tsv$",
  full.names = TRUE
)

module_gene_file <- NA_character_
for (f in candidate_module_files) {
  header <- tryCatch(names(data.table::fread(f, nrows = 0)), error = function(e) character())
  has_module <- any(grepl("module", header, ignore.case = TRUE))
  has_gene <- any(grepl("ENTREZ|SYMBOL|gene", header, ignore.case = TRUE))
  if (has_module && has_gene) {
    module_gene_file <- f
    break
  }
}

if (is.na(module_gene_file) || !file.exists(module_gene_file)) {
  stop(
    "Could not auto-detect locked module gene file in ",
    module_input_dir,
    ". Inspect files with: find ",
    module_input_dir,
    " -maxdepth 1 -type f -printf '%f\\n' | sort"
  )
}

message("Using locked module gene file: ", module_gene_file)

out_dir <- "results/external_projection_candidate_audit/GSE73461_identifier_coverage"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading GSE73461 raw expression probe identifiers...")
header <- names(fread(raw_expr_file, nrows = 0))
id_cols <- c("ID_REF", "ARRAY_ID")
expr_ids <- fread(
  raw_expr_file,
  select = id_cols,
  showProgress = FALSE
)
expr_ids <- unique(expr_ids)
expr_ids[, ID_REF := as.character(ID_REF)]
expr_ids[, ARRAY_ID := as.character(ARRAY_ID)]

message("Expression probe rows: ", nrow(expr_ids))

message("Mapping ILMN probe IDs using illuminaHumanv4.db...")
keys_available <- keys(illuminaHumanv4.db, keytype = "PROBEID")
probe_keys <- intersect(expr_ids$ID_REF, keys_available)

probe_map <- AnnotationDbi::select(
  illuminaHumanv4.db,
  keys = probe_keys,
  keytype = "PROBEID",
  columns = c("SYMBOL", "ENTREZID", "ENSEMBL")
)
probe_map <- as.data.table(probe_map)
setnames(probe_map, "PROBEID", "ID_REF")
probe_map[, ID_REF := as.character(ID_REF)]
probe_map[, SYMBOL := as.character(SYMBOL)]
probe_map[, ENTREZID := as.character(ENTREZID)]
probe_map[, ENSEMBL := as.character(ENSEMBL)]

probe_ann <- merge(expr_ids, probe_map, by = "ID_REF", all.x = TRUE, allow.cartesian = TRUE)
probe_ann[, SYMBOL_UPPER := toupper(SYMBOL)]

fwrite(expr_ids, file.path(out_dir, "GSE73461_expression_probe_ids.tsv"), sep = "\t")
fwrite(probe_ann, file.path(out_dir, "GSE73461_illuminaHumanv4_probe_annotation_join.tsv"), sep = "\t")

annotation_summary <- data.table(
  metric = c(
    "expression_probe_rows",
    "expression_probe_ids_with_package_key",
    "probe_annotation_rows",
    "unique_probes_with_symbol",
    "unique_probes_with_entrez",
    "unique_probes_with_ensembl",
    "unique_symbols",
    "unique_entrez_ids",
    "unique_ensembl_ids"
  ),
  value = c(
    nrow(expr_ids),
    length(probe_keys),
    nrow(probe_ann),
    uniqueN(probe_ann[!is.na(SYMBOL) & SYMBOL != "", ID_REF]),
    uniqueN(probe_ann[!is.na(ENTREZID) & ENTREZID != "", ID_REF]),
    uniqueN(probe_ann[!is.na(ENSEMBL) & ENSEMBL != "", ID_REF]),
    uniqueN(probe_ann[!is.na(SYMBOL) & SYMBOL != "", SYMBOL_UPPER]),
    uniqueN(probe_ann[!is.na(ENTREZID) & ENTREZID != "", ENTREZID]),
    uniqueN(probe_ann[!is.na(ENSEMBL) & ENSEMBL != "", ENSEMBL])
  )
)
fwrite(annotation_summary, file.path(out_dir, "GSE73461_probe_annotation_summary.tsv"), sep = "\t")

message("Reading locked GSE211567 module genes...")
modules <- fread(module_gene_file)

# Harmonize column names because the locked module table filename/columns may vary
# depending on the earlier module-input script version.
if (!("final_module_id" %in% names(modules))) {
  module_id_candidates <- names(modules)[grepl("module.*id|^module_id$", names(modules), ignore.case = TRUE)]
  if (length(module_id_candidates) == 0) stop("No module ID column detected in locked module gene table.")
  setnames(modules, module_id_candidates[1], "final_module_id")
}

if (!("final_module_label" %in% names(modules))) {
  label_candidates <- names(modules)[grepl("module.*label|module.*name|label", names(modules), ignore.case = TRUE)]
  if (length(label_candidates) > 0) {
    setnames(modules, label_candidates[1], "final_module_label")
  } else {
    modules[, final_module_label := final_module_id]
  }
}

if (!("final_module_direction" %in% names(modules))) {
  direction_candidates <- names(modules)[grepl("direction|orientation|sign", names(modules), ignore.case = TRUE)]
  if (length(direction_candidates) > 0) {
    setnames(modules, direction_candidates[1], "final_module_direction")
  } else {
    modules[, final_module_direction := fifelse(grepl("^BACT", final_module_id), "bacterial_higher",
                                         fifelse(grepl("^VIR", final_module_id), "viral_higher", "not_specified"))]
  }
}

if (!("SYMBOL" %in% names(modules))) {
  symbol_candidates <- names(modules)[grepl("^symbol$|gene_symbol|hgnc", names(modules), ignore.case = TRUE)]
  if (length(symbol_candidates) == 0) stop("No SYMBOL column detected in locked module gene table.")
  setnames(modules, symbol_candidates[1], "SYMBOL")
}

if (!("ENTREZID" %in% names(modules))) {
  entrez_candidates <- names(modules)[grepl("entrez", names(modules), ignore.case = TRUE)]
  if (length(entrez_candidates) > 0) {
    setnames(modules, entrez_candidates[1], "ENTREZID")
  } else {
    modules[, ENTREZID := NA_character_]
  }
}

modules[, SYMBOL := as.character(SYMBOL)]
modules[, SYMBOL_UPPER := toupper(SYMBOL)]
modules[, ENTREZID := as.character(ENTREZID)]

available_symbols <- unique(probe_ann[!is.na(SYMBOL_UPPER) & SYMBOL_UPPER != "", SYMBOL_UPPER])
available_entrez <- unique(probe_ann[!is.na(ENTREZID) & ENTREZID != "", ENTREZID])

coverage_list <- list()
matched_list <- list()
missing_list <- list()

for (mid in sort(unique(modules$final_module_id))) {
  m <- unique(modules[final_module_id == mid, .(
    final_module_id,
    final_module_label,
    final_module_direction,
    ENTREZID,
    SYMBOL,
    SYMBOL_UPPER
  )])

  m[, symbol_match := SYMBOL_UPPER %in% available_symbols]
  m[, entrez_match := ENTREZID %in% available_entrez]
  m[, any_match := symbol_match | entrez_match]

  locked_n <- nrow(m)
  matched_n <- m[any_match == TRUE, .N]
  missing_n <- m[any_match != TRUE, .N]

  coverage_list[[mid]] <- data.table(
    final_module_id = mid,
    final_module_label = m$final_module_label[1],
    final_module_direction = m$final_module_direction[1],
    locked_genes_n = locked_n,
    matched_genes_n = matched_n,
    missing_genes_n = missing_n,
    coverage_fraction = matched_n / locked_n,
    pass_50pct_primary_threshold = matched_n / locked_n >= 0.50,
    pass_70pct_sensitivity_threshold = matched_n / locked_n >= 0.70
  )

  matched_list[[mid]] <- m[any_match == TRUE]
  missing_list[[mid]] <- m[any_match != TRUE]
}

coverage <- rbindlist(coverage_list, use.names = TRUE)
matched <- rbindlist(matched_list, use.names = TRUE, fill = TRUE)
missing <- rbindlist(missing_list, use.names = TRUE, fill = TRUE)

fwrite(coverage, file.path(out_dir, "GSE73461_locked_module_identifier_coverage.tsv"), sep = "\t")
fwrite(matched, file.path(out_dir, "GSE73461_locked_module_matched_genes.tsv"), sep = "\t")
fwrite(missing, file.path(out_dir, "GSE73461_locked_module_missing_genes.tsv"), sep = "\t")

min_cov <- min(coverage$coverage_fraction)
all_pass_50 <- all(coverage$pass_50pct_primary_threshold)
all_pass_70 <- all(coverage$pass_70pct_sensitivity_threshold)

status <- if (all_pass_70) {
  "eligible_for_formal_cohort_lock_pending_decision_log"
} else if (all_pass_50) {
  "eligible_for_primary_projection_but_not_70pct_sensitivity"
} else {
  "not_ready_for_formal_lock_identifier_coverage_insufficient"
}

reason <- if (all_pass_70) {
  "All locked modules pass both the 50% primary and 70% sensitivity identifier-coverage thresholds."
} else if (all_pass_50) {
  "All locked modules pass the 50% primary threshold, but at least one module does not pass the stricter 70% sensitivity threshold."
} else {
  "At least one locked module does not pass the 50% primary identifier-coverage threshold."
}

decision <- data.table(
  candidate_dataset = "GSE73461",
  annotation_package = "illuminaHumanv4.db",
  n_expression_probe_rows = nrow(expr_ids),
  minimum_module_coverage_fraction = min_cov,
  all_modules_pass_50pct = all_pass_50,
  all_modules_pass_70pct = all_pass_70,
  identifier_coverage_status = status,
  reason = reason,
  next_action = "If accepted, log formal GSE73461 cohort lock before any fixed-module scoring."
)
fwrite(decision, file.path(out_dir, "GSE73461_identifier_coverage_decision.tsv"), sep = "\t")

report_file <- "docs/GSE73461_illumina_probe_module_coverage_audit_report.md"
sink(report_file)
cat("# GSE73461 Illumina Probe Annotation and Locked-Module Coverage Audit Report\n\n")
cat("- Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("- Purpose: assess whether GSE73461 can support fixed GSE211567 module projection after Illumina probe annotation.\n")
cat("- Boundary: identifier coverage audit only. No scoring, cohort lock, validation claim or biological interpretation is performed.\n\n")

cat("## Annotation summary\n\n")
print(annotation_summary)
cat("\n## Locked module coverage\n\n")
print(coverage)
cat("\n## Identifier coverage decision\n\n")
print(decision)
cat("\n## Interpretation boundary\n\n")
cat("- GSE73461 should not be scored until a separate cohort-lock decision is logged.\n")
cat("- If locked, modules must remain fixed and scoring must follow the pre-specified unweighted mean z-score rule.\n")
cat("- Coverage is assessed only to determine projection feasibility, not biological validity.\n\n")

cat("## Generated files\n\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_expression_probe_ids.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_illuminaHumanv4_probe_annotation_join.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_probe_annotation_summary.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_matched_genes.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_missing_genes.tsv`\n")
cat("- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_identifier_coverage_decision.tsv`\n")
sink()

writeLines(capture.output(sessionInfo()), "env/session_info/GSE73461_illumina_probe_module_coverage_audit_sessionInfo.txt")

message("Wrote report: ", report_file)
print(decision)
