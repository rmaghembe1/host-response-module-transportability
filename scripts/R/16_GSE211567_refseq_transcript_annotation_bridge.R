#!/usr/bin/env Rscript

# GSE211567 RefSeq transcript annotation bridge
# Purpose: map RefSeq transcript IDs to gene-level identifiers before enrichment/module discovery.
# Boundary: identifier mapping and gene-level collapsing only; no enrichment, module discovery, or biological interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
})

stable_file <- "results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stable_feature_table.tsv"
eligible_file <- "results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_features.tsv"
eligible_bacterial_file <- "results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_bacterial_higher_features.tsv"
eligible_viral_file <- "results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_viral_higher_features.tsv"

out_dir <- "results/module_lock/GSE211567_refseq_annotation_bridge"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading site-aware feature tables...")
stable <- fread(stable_file)
eligible <- fread(eligible_file)
eligible_bacterial <- fread(eligible_bacterial_file)
eligible_viral <- fread(eligible_viral_file)

all_refseq <- sort(unique(stable$feature_id))

message("Mapping RefSeq transcript IDs using org.Hs.eg.db...")
mapped <- AnnotationDbi::select(
  org.Hs.eg.db,
  keys = all_refseq,
  keytype = "REFSEQ",
  columns = c("REFSEQ", "SYMBOL", "ENTREZID", "ENSEMBL", "GENENAME")
)

mapped_dt <- as.data.table(mapped)
setnames(mapped_dt, "REFSEQ", "feature_id")
mapped_dt <- unique(mapped_dt)

# Keep all features represented, including unmapped
bridge <- merge(
  data.table(feature_id = all_refseq),
  mapped_dt,
  by = "feature_id",
  all.x = TRUE,
  allow.cartesian = TRUE
)

bridge[, mapped_any := !is.na(SYMBOL) | !is.na(ENTREZID) | !is.na(ENSEMBL)]
bridge[, mapped_symbol := !is.na(SYMBOL)]
bridge[, mapped_entrez := !is.na(ENTREZID)]
bridge[, mapped_ensembl := !is.na(ENSEMBL)]

fwrite(bridge, file.path(out_dir, "GSE211567_refseq_to_gene_annotation_bridge.tsv"), sep = "\t")

mapping_summary <- data.table(
  metric = c(
    "unique_refseq_features",
    "bridge_rows_after_one_to_many_mapping",
    "features_with_any_mapping",
    "features_with_symbol",
    "features_with_entrez",
    "features_with_ensembl",
    "features_without_any_mapping",
    "features_with_multiple_bridge_rows"
  ),
  value = c(
    length(all_refseq),
    nrow(bridge),
    uniqueN(bridge[mapped_any == TRUE, feature_id]),
    uniqueN(bridge[mapped_symbol == TRUE, feature_id]),
    uniqueN(bridge[mapped_entrez == TRUE, feature_id]),
    uniqueN(bridge[mapped_ensembl == TRUE, feature_id]),
    length(setdiff(all_refseq, bridge[mapped_any == TRUE, unique(feature_id)])),
    bridge[, .N, by = feature_id][N > 1, .N]
  )
)

fwrite(mapping_summary, file.path(out_dir, "GSE211567_refseq_annotation_mapping_summary.tsv"), sep = "\t")

unmapped <- bridge[mapped_any == FALSE]
fwrite(unmapped, file.path(out_dir, "GSE211567_unmapped_refseq_features.tsv"), sep = "\t")

multi_map <- bridge[, .N, by = feature_id][N > 1]
fwrite(multi_map, file.path(out_dir, "GSE211567_refseq_features_with_multiple_gene_mappings.tsv"), sep = "\t")

collapse_to_gene <- function(dt, label) {
  x <- merge(dt, bridge, by = "feature_id", all.x = TRUE, allow.cartesian = TRUE)
  x <- x[!is.na(ENTREZID) | !is.na(SYMBOL)]

  # Prefer ENTREZID as stable enrichment identifier; retain symbol/gene name.
  # Collapse transcript-level evidence to one row per ENTREZID, selecting strongest pooled P value.
  x[, abs_pooled_logFC := abs(pooled_logFC)]
  setorder(x, pooled_P.Value, -abs_pooled_logFC)

  gene <- x[
    !is.na(ENTREZID),
    .SD[1],
    by = ENTREZID
  ]

  gene[, source_feature_set := label]
  gene[, n_refseq_features_for_entrez_in_input := x[!is.na(ENTREZID), .N, by = ENTREZID]$N[match(gene$ENTREZID, x[!is.na(ENTREZID), .N, by = ENTREZID]$ENTREZID)]]

  # Clean ordering
  setorder(gene, pooled_P.Value)

  gene_out <- gene[, .(
    source_feature_set,
    ENTREZID,
    SYMBOL,
    ENSEMBL,
    GENENAME,
    selected_refseq_feature_id = feature_id,
    n_refseq_features_for_entrez_in_input,
    pooled_rank,
    pooled_logFC,
    pooled_P.Value,
    pooled_adj.P.Val,
    Sri_Lanka_logFC,
    Sri_Lanka_adj.P.Val,
    United_States_logFC,
    United_States_adj.P.Val,
    all_three_concordant,
    stability_tier,
    recommended_use
  )]

  gene_out
}

message("Collapsing transcript-level evidence to gene-level tables...")
gene_all <- collapse_to_gene(stable, "all_modelled_features")
gene_eligible <- collapse_to_gene(eligible, "site_aware_eligible")
gene_bacterial <- collapse_to_gene(eligible_bacterial, "site_aware_eligible_bacterial_higher")
gene_viral <- collapse_to_gene(eligible_viral, "site_aware_eligible_viral_higher")

fwrite(gene_all, file.path(out_dir, "GSE211567_gene_level_all_modelled_features.tsv"), sep = "\t")
fwrite(gene_eligible, file.path(out_dir, "GSE211567_gene_level_site_aware_eligible_features.tsv"), sep = "\t")
fwrite(gene_bacterial, file.path(out_dir, "GSE211567_gene_level_site_aware_eligible_bacterial_higher.tsv"), sep = "\t")
fwrite(gene_viral, file.path(out_dir, "GSE211567_gene_level_site_aware_eligible_viral_higher.tsv"), sep = "\t")

collapse_summary <- data.table(
  feature_set = c(
    "all_modelled_features",
    "site_aware_eligible",
    "site_aware_eligible_bacterial_higher",
    "site_aware_eligible_viral_higher"
  ),
  transcript_features_input = c(
    nrow(stable),
    nrow(eligible),
    nrow(eligible_bacterial),
    nrow(eligible_viral)
  ),
  gene_level_entrez_output = c(
    nrow(gene_all),
    nrow(gene_eligible),
    nrow(gene_bacterial),
    nrow(gene_viral)
  ),
  unique_symbols_output = c(
    uniqueN(gene_all$SYMBOL),
    uniqueN(gene_eligible$SYMBOL),
    uniqueN(gene_bacterial$SYMBOL),
    uniqueN(gene_viral$SYMBOL)
  )
)

fwrite(collapse_summary, file.path(out_dir, "GSE211567_transcript_to_gene_collapse_summary.tsv"), sep = "\t")

sink(file.path(session_dir, "GSE211567_refseq_transcript_annotation_bridge_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_refseq_transcript_annotation_bridge_report.md")

writeLines(c(
  "# GSE211567 RefSeq Transcript Annotation Bridge Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: map RefSeq transcript identifiers to gene-level identifiers before enrichment/module discovery.",
  "- Boundary: identifier mapping and transcript-to-gene collapsing only. No enrichment, module discovery or biological interpretation is performed here.",
  "",
  "## Mapping summary",
  "",
  paste(capture.output(print(mapping_summary)), collapse = "\n"),
  "",
  "## Transcript-to-gene collapse summary",
  "",
  paste(capture.output(print(collapse_summary)), collapse = "\n"),
  "",
  "## Annotation decision",
  "",
  "- Raw feature IDs are RefSeq transcript accessions, not gene symbols.",
  "- Enrichment/module discovery should use gene-level mapped identifiers, preferably ENTREZID-backed tables.",
  "- Transcript-level evidence is collapsed to one representative row per ENTREZID by strongest pooled P value, retaining direction and site-aware stability annotations.",
  "- Unmapped RefSeq features should not be used as primary enrichment identifiers.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_to_gene_annotation_bridge.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_annotation_mapping_summary.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_unmapped_refseq_features.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_features_with_multiple_gene_mappings.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_all_modelled_features.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_features.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_bacterial_higher.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_viral_higher.tsv`",
  "- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_transcript_to_gene_collapse_summary.tsv`",
  "- `env/session_info/GSE211567_refseq_transcript_annotation_bridge_sessionInfo.txt`",
  "",
  "## Boundary statement",
  "",
  "- This report prepares identifiers for enrichment.",
  "- It does not define pathways or modules.",
  "- It does not make biological claims."
), con = report_file)

message("RefSeq transcript annotation bridge complete.")
message("Report: ", report_file)
