#!/usr/bin/env Rscript

# GSE161731 module projection identifier-coverage audit
# Purpose: technical rehearsal only. Check whether locked GSE211567 module genes are represented in GSE161731.
# Boundary: identifier coverage audit only; no module scoring, no validation, no biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
})

module_dir <- "results/module_scoring/GSE211567_projection_ready_inputs"
gse161731_qc_dir <- "results/qc/GSE161731_technical_rehearsal"

out_dir <- "results/module_projection_rehearsal/GSE161731_identifier_coverage_audit"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

module_gene_file <- file.path(module_dir, "GSE211567_projection_ready_module_gene_table.tsv")
voom_file <- file.path(gse161731_qc_dir, "GSE161731_technical_rehearsal_voom_objects.rds")

message("Reading locked GSE211567 projection-ready module genes...")
module_genes <- fread(module_gene_file)
module_genes[, ENTREZID := as.character(ENTREZID)]

message("Reading GSE161731 technical rehearsal voom object...")
voom_obj <- readRDS(voom_file)

expr <- NULL
if (is.list(voom_obj) && "voom" %in% names(voom_obj)) {
  expr <- voom_obj$voom$E
}
if (is.null(expr) && is.list(voom_obj) && "E" %in% names(voom_obj)) {
  expr <- voom_obj$E
}
if (is.null(expr) && is.matrix(voom_obj)) {
  expr <- voom_obj
}
if (is.null(expr)) {
  stop("Could not identify expression matrix inside GSE161731 voom object. Inspect object names manually with str(readRDS(...)).")
}

gse161731_ids <- rownames(expr)

id_pattern_summary <- data.table(
  pattern = c(
    "ENSG",
    "Entrez_numeric_only",
    "RefSeq_NM_NR_XM_XR",
    "contains_pipe",
    "contains_dot"
  ),
  count = c(
    sum(grepl("^ENSG", gse161731_ids)),
    sum(grepl("^[0-9]+$", gse161731_ids)),
    sum(grepl("^(NM_|NR_|XM_|XR_)", gse161731_ids)),
    sum(grepl("\\|", gse161731_ids)),
    sum(grepl("\\.", gse161731_ids))
  )
)

message("Mapping locked module ENTREZID values to ENSEMBL...")
entrez_keys <- unique(na.omit(module_genes$ENTREZID))

entrez_to_ensembl <- AnnotationDbi::select(
  org.Hs.eg.db,
  keys = entrez_keys,
  keytype = "ENTREZID",
  columns = c("ENTREZID", "SYMBOL", "ENSEMBL")
)

entrez_to_ensembl <- as.data.table(entrez_to_ensembl)
entrez_to_ensembl <- unique(entrez_to_ensembl[!is.na(ENSEMBL)])

# Attach possible ENSEMBL IDs to module genes.
module_genes_mapped <- merge(
  module_genes,
  entrez_to_ensembl[, .(
    ENTREZID = as.character(ENTREZID),
    mapped_SYMBOL = SYMBOL,
    mapped_ENSEMBL = ENSEMBL
  )],
  by = "ENTREZID",
  all.x = TRUE,
  allow.cartesian = TRUE
)

module_genes_mapped[, ensembl_available_in_GSE161731 := mapped_ENSEMBL %in% gse161731_ids]
module_genes_mapped[, symbol_available_in_GSE161731 := SYMBOL %in% gse161731_ids]

# Gene-level coverage: count locked unique ENTREZID as matched if any mapped ENSEMBL is present.
gene_level_match <- module_genes_mapped[, .(
  SYMBOL = unique(na.omit(SYMBOL))[1],
  final_module_label = unique(final_module_label)[1],
  module_direction = unique(module_direction)[1],
  locked_entrez_present = TRUE,
  any_ensembl_mapping = any(!is.na(mapped_ENSEMBL)),
  matched_by_ensembl = any(ensembl_available_in_GSE161731, na.rm = TRUE),
  matched_by_symbol = any(symbol_available_in_GSE161731, na.rm = TRUE),
  matched_ensembl_ids = paste(sort(unique(na.omit(mapped_ENSEMBL[ensembl_available_in_GSE161731]))), collapse = ";"),
  all_mapped_ensembl_ids = paste(sort(unique(na.omit(mapped_ENSEMBL))), collapse = ";")
), by = .(final_module_id, ENTREZID)]

coverage_by_module <- gene_level_match[, .(
  locked_genes = uniqueN(ENTREZID),
  genes_with_any_ensembl_mapping = sum(any_ensembl_mapping),
  matched_genes_by_ensembl = sum(matched_by_ensembl),
  matched_genes_by_symbol = sum(matched_by_symbol),
  missing_genes_after_ensembl_mapping = sum(!matched_by_ensembl),
  matched_symbols_by_ensembl = paste(sort(unique(SYMBOL[matched_by_ensembl])), collapse = ";"),
  missing_symbols_after_ensembl_mapping = paste(sort(unique(SYMBOL[!matched_by_ensembl])), collapse = ";")
), by = .(final_module_id, final_module_label, module_direction)]

coverage_by_module[, coverage_pct_by_ensembl := round(100 * matched_genes_by_ensembl / locked_genes, 2)]
coverage_by_module[, coverage_pct_by_symbol := round(100 * matched_genes_by_symbol / locked_genes, 2)]
coverage_by_module[, projection_eligible_50pct := coverage_pct_by_ensembl >= 50]
coverage_by_module[, projection_eligible_70pct := coverage_pct_by_ensembl >= 70]

setorder(coverage_by_module, final_module_id)

matched_gene_table <- gene_level_match[matched_by_ensembl == TRUE]
missing_gene_table <- gene_level_match[matched_by_ensembl == FALSE]

fwrite(id_pattern_summary, file.path(out_dir, "GSE161731_expression_identifier_pattern_summary.tsv"), sep = "\t")
fwrite(module_genes_mapped, file.path(out_dir, "GSE161731_projection_rehearsal_module_gene_ensembl_mapping_long.tsv"), sep = "\t")
fwrite(gene_level_match, file.path(out_dir, "GSE161731_projection_rehearsal_gene_level_identifier_match_table.tsv"), sep = "\t")
fwrite(coverage_by_module, file.path(out_dir, "GSE161731_projection_rehearsal_module_ensembl_coverage.tsv"), sep = "\t")
fwrite(matched_gene_table, file.path(out_dir, "GSE161731_projection_rehearsal_matched_module_genes_by_ensembl.tsv"), sep = "\t")
fwrite(missing_gene_table, file.path(out_dir, "GSE161731_projection_rehearsal_missing_module_genes_after_ensembl_mapping.tsv"), sep = "\t")

# Keep the old-style filename too, but now with explicit ENSEMBL-aware results for continuity.
fwrite(coverage_by_module, file.path(out_dir, "GSE161731_projection_rehearsal_module_symbol_coverage.tsv"), sep = "\t")
fwrite(matched_gene_table, file.path(out_dir, "GSE161731_projection_rehearsal_matched_module_genes.tsv"), sep = "\t")
fwrite(missing_gene_table, file.path(out_dir, "GSE161731_projection_rehearsal_missing_module_genes.tsv"), sep = "\t")

sink(file.path(session_dir, "GSE161731_module_projection_identifier_coverage_audit_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE161731_module_projection_identifier_coverage_audit_report.md")

writeLines(c(
  "# GSE161731 Module Projection Identifier-Coverage Audit Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: technical projection rehearsal identifier-coverage audit only.",
  "- Boundary: no module scoring, no validation, no biological interpretation.",
  "",
  "## Input",
  "",
  paste0("- Locked GSE211567 module-gene rows: ", nrow(module_genes)),
  paste0("- Locked unique module genes: ", uniqueN(module_genes$ENTREZID)),
  paste0("- GSE161731 expression features detected: ", length(gse161731_ids)),
  "",
  "## GSE161731 expression identifier pattern summary",
  "",
  paste(capture.output(print(id_pattern_summary)), collapse = "\n"),
  "",
  "## Module coverage by ENSEMBL mapping",
  "",
  paste(capture.output(print(coverage_by_module)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- This audit checks whether locked GSE211567 module genes can be found in GSE161731 after mapping locked ENTREZID values to ENSEMBL IDs.",
  "- GSE161731 remains a technical projection rehearsal resource, not formal validation.",
  "- No module scores or biological claims are produced here.",
  "- If coverage is adequate, the next step may be technical module-score rehearsal using fixed GSE211567 modules and unweighted mean z-score scoring.",
  "",
  "## Generated files",
  "",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_expression_identifier_pattern_summary.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_module_gene_ensembl_mapping_long.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_gene_level_identifier_match_table.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_module_ensembl_coverage.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_matched_module_genes_by_ensembl.tsv`",
  "- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_missing_module_genes_after_ensembl_mapping.tsv`",
  "- `env/session_info/GSE161731_module_projection_identifier_coverage_audit_sessionInfo.txt`"
), con = report_file)

message("GSE161731 module projection identifier-coverage audit complete.")
message("Report: ", report_file)
