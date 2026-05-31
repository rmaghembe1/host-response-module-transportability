#!/usr/bin/env Rscript

# GSE211567 manual GO Biological Process over-representation analysis
# Purpose: direction-aware GO BP ORA using site-aware gene-level eligible sets.
# Boundary: enrichment discovery only; no final biological module naming or manuscript-level interpretation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(GO.db)
  library(ggplot2)
})

in_dir <- "results/module_lock/GSE211567_refseq_annotation_bridge"
out_dir <- "results/pathway_enrichment/GSE211567_manual_GO_BP_ORA"
fig_dir <- "results/figures/GSE211567_manual_GO_BP_ORA"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

universe_file <- file.path(in_dir, "GSE211567_gene_level_all_modelled_features.tsv")
bact_file <- file.path(in_dir, "GSE211567_gene_level_site_aware_eligible_bacterial_higher.tsv")
viral_file <- file.path(in_dir, "GSE211567_gene_level_site_aware_eligible_viral_higher.tsv")

message("Reading gene-level inputs...")
universe_dt <- fread(universe_file)
bact_dt <- fread(bact_file)
viral_dt <- fread(viral_file)

universe <- unique(as.character(universe_dt$ENTREZID))
bact_genes <- intersect(unique(as.character(bact_dt$ENTREZID)), universe)
viral_genes <- intersect(unique(as.character(viral_dt$ENTREZID)), universe)

message("Universe genes: ", length(universe))
message("Bacterial-higher genes: ", length(bact_genes))
message("Viral-higher genes: ", length(viral_genes))

message("Building GO BP annotation map from org.Hs.eg.db...")
go_map <- AnnotationDbi::select(
  org.Hs.eg.db,
  keys = universe,
  keytype = "ENTREZID",
  columns = c("GO", "ONTOLOGY", "EVIDENCE", "SYMBOL")
)

go_map <- as.data.table(go_map)
go_map <- go_map[ONTOLOGY == "BP" & !is.na(GO)]
go_map <- unique(go_map[, .(ENTREZID, GO)])

go_terms <- AnnotationDbi::select(
  GO.db,
  keys = unique(go_map$GO),
  keytype = "GOID",
  columns = c("GOID", "TERM", "ONTOLOGY")
)
go_terms <- as.data.table(go_terms)
setnames(go_terms, "GOID", "GO")
go_terms <- unique(go_terms[ONTOLOGY == "BP", .(GO, TERM)])

go_map <- merge(go_map, go_terms, by = "GO", all.x = TRUE)

# Term-size filtering within the study universe
term_universe <- go_map[, .(
  term_universe_genes = uniqueN(ENTREZID),
  universe_gene_ids = paste(sort(unique(ENTREZID)), collapse = ";")
), by = .(GO, TERM)]

term_universe <- term_universe[term_universe_genes >= 10 & term_universe_genes <= 500]

run_ora <- function(query_genes, label) {
  query_genes <- unique(as.character(query_genes))
  query_genes <- intersect(query_genes, universe)

  N <- length(universe)
  n <- length(query_genes)

  message("Running GO BP ORA for ", label, ": ", n, " genes")

  out <- term_universe[, {
    term_genes <- unlist(strsplit(universe_gene_ids, ";", fixed = TRUE))
    k <- sum(query_genes %in% term_genes)
    K <- term_universe_genes

    # one-sided Fisher exact test for over-representation
    mat <- matrix(
      c(
        k,
        n - k,
        K - k,
        N - K - n + k
      ),
      nrow = 2
    )

    p <- if (k > 0) fisher.test(mat, alternative = "greater")$p.value else 1

    .(
      query_genes = n,
      universe_genes = N,
      term_genes_in_universe = K,
      overlap_genes = k,
      p_value = p,
      overlap_gene_ids = paste(sort(intersect(query_genes, term_genes)), collapse = ";")
    )
  }, by = .(GO, TERM)]

  out[, p_adj_BH := p.adjust(p_value, method = "BH")]
  out[, gene_ratio := overlap_genes / query_genes]
  out[, background_ratio := term_genes_in_universe / universe_genes]
  out[, enrichment_ratio := gene_ratio / background_ratio]
  out[, direction_set := label]

  setorder(out, p_adj_BH, p_value, -overlap_genes)

  # Add symbols for overlap genes
  entrez_to_symbol <- unique(universe_dt[, .(ENTREZID = as.character(ENTREZID), SYMBOL)])
  symbol_lookup <- setNames(entrez_to_symbol$SYMBOL, entrez_to_symbol$ENTREZID)

  out[, overlap_symbols := vapply(
    overlap_gene_ids,
    function(x) {
      ids <- unlist(strsplit(x, ";", fixed = TRUE))
      syms <- unique(na.omit(symbol_lookup[ids]))
      paste(syms, collapse = ";")
    },
    character(1)
  )]

  out
}

bact_ora <- run_ora(bact_genes, "bacterial_higher_site_aware_eligible")
viral_ora <- run_ora(viral_genes, "viral_higher_site_aware_eligible")

fwrite(bact_ora, file.path(out_dir, "GSE211567_manual_GO_BP_ORA_bacterial_higher.tsv"), sep = "\t")
fwrite(viral_ora, file.path(out_dir, "GSE211567_manual_GO_BP_ORA_viral_higher.tsv"), sep = "\t")

combined <- rbindlist(list(bact_ora, viral_ora), use.names = TRUE)
fwrite(combined, file.path(out_dir, "GSE211567_manual_GO_BP_ORA_combined.tsv"), sep = "\t")

summary_dt <- rbindlist(list(
  data.table(
    direction_set = "bacterial_higher_site_aware_eligible",
    query_genes = length(bact_genes),
    universe_genes = length(universe),
    tested_GO_BP_terms = nrow(bact_ora),
    FDR_0.05_terms = sum(bact_ora$p_adj_BH < 0.05),
    FDR_0.10_terms = sum(bact_ora$p_adj_BH < 0.10)
  ),
  data.table(
    direction_set = "viral_higher_site_aware_eligible",
    query_genes = length(viral_genes),
    universe_genes = length(universe),
    tested_GO_BP_terms = nrow(viral_ora),
    FDR_0.05_terms = sum(viral_ora$p_adj_BH < 0.05),
    FDR_0.10_terms = sum(viral_ora$p_adj_BH < 0.10)
  )
))

fwrite(summary_dt, file.path(out_dir, "GSE211567_manual_GO_BP_ORA_summary.tsv"), sep = "\t")

top_terms <- combined[p_adj_BH < 0.05][
  order(direction_set, p_adj_BH, p_value)
][
  , head(.SD, 25), by = direction_set
]

fwrite(top_terms, file.path(out_dir, "GSE211567_manual_GO_BP_ORA_top25_FDR05_by_direction.tsv"), sep = "\t")

plot_top <- function(dt, label, outfile_prefix) {
  x <- dt[p_adj_BH < 0.05][order(p_adj_BH)][1:min(.N, 20)]
  if (nrow(x) == 0) {
    return(NULL)
  }

  x[, TERM := factor(TERM, levels = rev(TERM))]

  p <- ggplot(x, aes(x = TERM, y = -log10(p_adj_BH))) +
    geom_col() +
    coord_flip() +
    theme_bw() +
    labs(
      title = paste0("Top GO BP terms: ", label),
      x = "GO Biological Process",
      y = "-log10(BH FDR)"
    )

  ggsave(file.path(fig_dir, paste0(outfile_prefix, ".png")), p, width = 9, height = 6, dpi = 300)
  ggsave(file.path(fig_dir, paste0(outfile_prefix, ".pdf")), p, width = 9, height = 6)
}

plot_top(bact_ora, "bacterial-higher site-aware genes", "GSE211567_manual_GO_BP_ORA_bacterial_higher_top20")
plot_top(viral_ora, "viral-higher site-aware genes", "GSE211567_manual_GO_BP_ORA_viral_higher_top20")

sink(file.path(session_dir, "GSE211567_manual_GO_BP_ORA_site_aware_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_manual_GO_BP_ORA_site_aware_report.md")

writeLines(c(
  "# GSE211567 Manual GO Biological Process ORA Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: first direction-aware pathway discovery using site-aware gene-level eligible sets.",
  "- Method: manual one-sided Fisher exact over-representation analysis using org.Hs.eg.db and GO.db.",
  "- Universe: all modelled gene-level ENTREZ identifiers.",
  "- Boundary: enrichment discovery only; no final biological module naming or manuscript-level interpretation is made here.",
  "",
  "## Input gene sets",
  "",
  paste0("- Universe genes: ", length(universe)),
  paste0("- Bacterial-higher site-aware eligible genes: ", length(bact_genes)),
  paste0("- Viral-higher site-aware eligible genes: ", length(viral_genes)),
  "",
  "## Enrichment summary",
  "",
  paste(capture.output(print(summary_dt)), collapse = "\n"),
  "",
  "## Top FDR < 0.05 terms by direction",
  "",
  paste(capture.output(print(top_terms[, .(direction_set, GO, TERM, overlap_genes, p_adj_BH, enrichment_ratio)][1:min(.N, 50)])), collapse = "\n"),
  "",
  "## Generated files",
  "",
  "- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_bacterial_higher.tsv`",
  "- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_viral_higher.tsv`",
  "- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_combined.tsv`",
  "- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_summary.tsv`",
  "- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_top25_FDR05_by_direction.tsv`",
  "- `results/figures/GSE211567_manual_GO_BP_ORA/*top20*.png/.pdf`",
  "- `env/session_info/GSE211567_manual_GO_BP_ORA_site_aware_sessionInfo.txt`",
  "",
  "## Interpretation boundary",
  "",
  "- This analysis identifies enriched GO Biological Process terms.",
  "- It does not yet merge terms into named biological modules.",
  "- It does not yet define transportable modules.",
  "- It does not make final biological claims."
), con = report_file)

message("Manual GO BP ORA complete.")
message("Report: ", report_file)
