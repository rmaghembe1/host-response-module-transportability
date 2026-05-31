#!/usr/bin/env Rscript

# GSE211567 GO BP redundancy reduction and overlap-gene inspection
# Purpose: reduce redundant enriched GO BP terms into candidate term groups using overlap-gene similarity.
# Boundary: candidate grouping only; no final biological module naming or manuscript-level claims.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

ora_dir <- "results/pathway_enrichment/GSE211567_manual_GO_BP_ORA"
gene_dir <- "results/module_lock/GSE211567_refseq_annotation_bridge"

out_dir <- "results/module_lock/GSE211567_GO_BP_redundancy_reduction"
fig_dir <- "results/figures/GSE211567_GO_BP_redundancy_reduction"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

combined_file <- file.path(ora_dir, "GSE211567_manual_GO_BP_ORA_combined.tsv")
eligible_gene_file <- file.path(gene_dir, "GSE211567_gene_level_site_aware_eligible_features.tsv")

message("Reading GO BP ORA results...")
ora <- fread(combined_file)
genes <- fread(eligible_gene_file)

# Retain enriched terms for grouping.
# Use FDR < 0.10 for candidate grouping so borderline neighbouring terms are not lost,
# but clearly flag FDR < 0.05 terms.
enriched <- ora[p_adj_BH < 0.10 & overlap_genes > 0]
enriched[, FDR05 := p_adj_BH < 0.05]

message("Enriched GO BP terms retained at FDR < 0.10: ", nrow(enriched))

# Gene symbol lookup
gene_lookup <- unique(genes[, .(
  ENTREZID = as.character(ENTREZID),
  SYMBOL,
  GENENAME,
  pooled_logFC,
  pooled_adj.P.Val,
  Sri_Lanka_logFC,
  United_States_logFC,
  stability_tier,
  recommended_use
)])

parse_gene_ids <- function(x) {
  if (is.na(x) || x == "") character(0) else unique(unlist(strsplit(x, ";", fixed = TRUE)))
}

jaccard <- function(a, b) {
  a <- unique(a)
  b <- unique(b)
  if (length(a) == 0 || length(b) == 0) return(0)
  length(intersect(a, b)) / length(union(a, b))
}

make_groups <- function(dt, direction_label, similarity_cutoff = 0.25) {
  x <- copy(dt[direction_set == direction_label])
  if (nrow(x) == 0) return(list(groups = data.table(), membership = data.table(), pairs = data.table()))

  x[, term_index := .I]
  gene_sets <- lapply(x$overlap_gene_ids, parse_gene_ids)
  names(gene_sets) <- x$GO

  # Pairwise similarity
  pairs <- data.table()
  if (nrow(x) >= 2) {
    pairs <- rbindlist(lapply(seq_len(nrow(x) - 1), function(i) {
      rbindlist(lapply((i + 1):nrow(x), function(j) {
        a <- gene_sets[[i]]
        b <- gene_sets[[j]]
        data.table(
          direction_set = direction_label,
          GO_1 = x$GO[i],
          TERM_1 = x$TERM[i],
          GO_2 = x$GO[j],
          TERM_2 = x$TERM[j],
          jaccard_overlap = jaccard(a, b),
          shared_gene_count = length(intersect(a, b)),
          union_gene_count = length(union(a, b))
        )
      }))
    }))
  }

  # Simple greedy grouping:
  # Start with best-FDR term as representative, absorb terms with Jaccard >= cutoff.
  remaining <- x[order(p_adj_BH, p_value)]
  groups <- list()
  membership <- list()
  group_id <- 0

  while (nrow(remaining) > 0) {
    group_id <- group_id + 1
    rep_row <- remaining[1]
    rep_genes <- parse_gene_ids(rep_row$overlap_gene_ids)

    sim_to_rep <- vapply(
      remaining$overlap_gene_ids,
      function(g) jaccard(rep_genes, parse_gene_ids(g)),
      numeric(1)
    )

    take <- sim_to_rep >= similarity_cutoff
    # Always keep representative
    take[1] <- TRUE

    group_terms <- remaining[take]
    group_genes <- unique(unlist(lapply(group_terms$overlap_gene_ids, parse_gene_ids)))

    group_label <- paste0(
      ifelse(direction_label == "bacterial_higher_site_aware_eligible", "Bacterial_higher", "Viral_higher"),
      "_GO_group_",
      sprintf("%02d", group_id)
    )

    groups[[group_id]] <- data.table(
      direction_set = direction_label,
      candidate_group_id = group_label,
      representative_GO = rep_row$GO,
      representative_TERM = rep_row$TERM,
      representative_FDR = rep_row$p_adj_BH,
      representative_enrichment_ratio = rep_row$enrichment_ratio,
      n_terms = nrow(group_terms),
      n_FDR05_terms = sum(group_terms$FDR05),
      n_unique_overlap_genes = length(group_genes),
      group_GO_terms = paste(group_terms$GO, collapse = ";"),
      group_terms = paste(group_terms$TERM, collapse = " | "),
      group_overlap_gene_ids = paste(sort(group_genes), collapse = ";")
    )

    membership[[group_id]] <- group_terms[, .(
      direction_set,
      candidate_group_id = group_label,
      GO,
      TERM,
      overlap_genes,
      p_value,
      p_adj_BH,
      enrichment_ratio,
      FDR05,
      overlap_gene_ids,
      overlap_symbols
    )]

    remaining <- remaining[!take]
  }

  list(
    groups = rbindlist(groups, fill = TRUE),
    membership = rbindlist(membership, fill = TRUE),
    pairs = pairs
  )
}

bact <- make_groups(enriched, "bacterial_higher_site_aware_eligible")
viral <- make_groups(enriched, "viral_higher_site_aware_eligible")

groups <- rbindlist(list(bact$groups, viral$groups), fill = TRUE)
membership <- rbindlist(list(bact$membership, viral$membership), fill = TRUE)
pairs <- rbindlist(list(bact$pairs, viral$pairs), fill = TRUE)

# Add gene-symbol summaries for each group
groups[, top_overlap_symbols := vapply(group_overlap_gene_ids, function(ids) {
  idv <- parse_gene_ids(ids)
  sub <- gene_lookup[ENTREZID %in% idv]
  sub <- sub[order(pooled_adj.P.Val, -abs(pooled_logFC))]
  paste(head(unique(na.omit(sub$SYMBOL)), 40), collapse = ";")
}, character(1))]

# Long table of group genes for inspection
group_gene_long <- rbindlist(lapply(seq_len(nrow(groups)), function(i) {
  ids <- parse_gene_ids(groups$group_overlap_gene_ids[i])
  sub <- gene_lookup[ENTREZID %in% ids]
  sub[, `:=`(
    direction_set = groups$direction_set[i],
    candidate_group_id = groups$candidate_group_id[i],
    representative_GO = groups$representative_GO[i],
    representative_TERM = groups$representative_TERM[i]
  )]
  sub[]
}), fill = TRUE)

setorder(groups, direction_set, representative_FDR, -n_FDR05_terms, -n_unique_overlap_genes)
setorder(membership, direction_set, candidate_group_id, p_adj_BH, p_value)

# data.table::setorder() requires column names, not expressions.
# Create an explicit helper column for absolute pooled logFC before ordering.
group_gene_long[, abs_pooled_logFC_for_ordering := abs(pooled_logFC)]
setorder(group_gene_long, direction_set, candidate_group_id, pooled_adj.P.Val, -abs_pooled_logFC_for_ordering)
group_gene_long[, abs_pooled_logFC_for_ordering := NULL]

fwrite(groups, file.path(out_dir, "GSE211567_GO_BP_candidate_term_groups.tsv"), sep = "\t")
fwrite(membership, file.path(out_dir, "GSE211567_GO_BP_candidate_group_term_membership.tsv"), sep = "\t")
fwrite(pairs, file.path(out_dir, "GSE211567_GO_BP_term_pairwise_jaccard_similarity.tsv"), sep = "\t")
fwrite(group_gene_long, file.path(out_dir, "GSE211567_GO_BP_candidate_group_overlap_genes_long.tsv"), sep = "\t")

summary_dt <- groups[, .(
  candidate_groups = .N,
  total_terms_in_groups = sum(n_terms),
  FDR05_terms_in_groups = sum(n_FDR05_terms),
  median_unique_overlap_genes_per_group = median(n_unique_overlap_genes),
  max_unique_overlap_genes_per_group = max(n_unique_overlap_genes)
), by = direction_set]

fwrite(summary_dt, file.path(out_dir, "GSE211567_GO_BP_redundancy_reduction_summary.tsv"), sep = "\t")

# Plot group sizes
if (nrow(groups) > 0) {
  plot_dt <- copy(groups)
  plot_dt[, candidate_group_id := factor(candidate_group_id, levels = rev(candidate_group_id))]

  p <- ggplot(plot_dt, aes(x = candidate_group_id, y = n_terms)) +
    geom_col() +
    coord_flip() +
    theme_bw() +
    labs(
      title = "GSE211567 candidate GO BP term groups",
      x = "Candidate term group",
      y = "Number of enriched GO BP terms"
    )

  ggsave(file.path(fig_dir, "GSE211567_GO_BP_candidate_group_term_counts.png"), p, width = 8, height = 5, dpi = 300)
  ggsave(file.path(fig_dir, "GSE211567_GO_BP_candidate_group_term_counts.pdf"), p, width = 8, height = 5)
}

# Plot group-gene sizes
if (nrow(groups) > 0) {
  plot_dt2 <- copy(groups)
  plot_dt2[, candidate_group_id := factor(candidate_group_id, levels = rev(candidate_group_id))]

  p2 <- ggplot(plot_dt2, aes(x = candidate_group_id, y = n_unique_overlap_genes)) +
    geom_col() +
    coord_flip() +
    theme_bw() +
    labs(
      title = "GSE211567 candidate GO BP group overlap-gene sizes",
      x = "Candidate term group",
      y = "Unique overlap genes"
    )

  ggsave(file.path(fig_dir, "GSE211567_GO_BP_candidate_group_gene_counts.png"), p2, width = 8, height = 5, dpi = 300)
  ggsave(file.path(fig_dir, "GSE211567_GO_BP_candidate_group_gene_counts.pdf"), p2, width = 8, height = 5)
}

sink(file.path(session_dir, "GSE211567_GO_BP_redundancy_reduction_overlap_inspection_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_GO_BP_redundancy_reduction_overlap_inspection_report.md")

writeLines(c(
  "# GSE211567 GO BP Redundancy Reduction and Overlap-Gene Inspection Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: reduce redundant enriched GO Biological Process terms into candidate term groups using overlap-gene similarity.",
  "- Method: enriched GO BP terms at BH FDR < 0.10 were grouped greedily by overlap-gene Jaccard similarity using cutoff 0.25.",
  "- Boundary: candidate grouping only. This step does not assign final module names and does not make manuscript-level biological claims.",
  "",
  "## Input enriched GO BP terms",
  "",
  paste0("- Enriched GO BP terms at BH FDR < 0.10 retained for grouping: ", nrow(enriched)),
  paste0("- Bacterial-higher enriched terms retained: ", nrow(enriched[direction_set == "bacterial_higher_site_aware_eligible"])),
  paste0("- Viral-higher enriched terms retained: ", nrow(enriched[direction_set == "viral_higher_site_aware_eligible"])),
  "",
  "## Candidate group summary",
  "",
  paste(capture.output(print(summary_dt)), collapse = "\n"),
  "",
  "## Candidate groups",
  "",
  paste(capture.output(print(groups[, .(
    direction_set,
    candidate_group_id,
    representative_GO,
    representative_TERM,
    representative_FDR,
    n_terms,
    n_FDR05_terms,
    n_unique_overlap_genes,
    top_overlap_symbols
  )])), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- Candidate groups are redundancy-reduced GO-term clusters.",
  "- Candidate groups are not yet final biological modules.",
  "- Final module naming requires review of member GO terms, overlap genes, directionality and cross-site stability.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_term_groups.tsv`",
  "- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_term_membership.tsv`",
  "- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_term_pairwise_jaccard_similarity.tsv`",
  "- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_overlap_genes_long.tsv`",
  "- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_redundancy_reduction_summary.tsv`",
  "- `results/figures/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_term_counts.png/.pdf`",
  "- `results/figures/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_gene_counts.png/.pdf`",
  "- `env/session_info/GSE211567_GO_BP_redundancy_reduction_overlap_inspection_sessionInfo.txt`"
), con = report_file)

message("GO BP redundancy reduction and overlap-gene inspection complete.")
message("Report: ", report_file)
