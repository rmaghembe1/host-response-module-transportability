#!/usr/bin/env Rscript

# GSE211567 final discovery-module label table
# Purpose: assign conservative final discovery-module labels to primary candidate modules after gene-level inspection.
# Boundary: discovery labels only; not external validation, transportability proof, or manuscript-level causal claims.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

inspection_dir <- "results/module_lock/GSE211567_primary_module_gene_inspection"
decision_dir <- "results/module_lock/GSE211567_manual_module_decisions"

out_dir <- "results/module_lock/GSE211567_final_discovery_module_labels"
fig_dir <- "results/figures/GSE211567_final_discovery_module_labels"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

summary_file <- file.path(inspection_dir, "GSE211567_primary_module_gene_level_summary.tsv")
genes_file <- file.path(inspection_dir, "GSE211567_primary_module_overlap_genes_for_inspection.tsv")
terms_file <- file.path(inspection_dir, "GSE211567_primary_module_GO_terms_for_inspection.tsv")
merge_file <- file.path(inspection_dir, "GSE211567_primary_antiviral_interferon_merge_assessment.tsv")
decision_file <- file.path(decision_dir, "GSE211567_manual_module_decision_table.tsv")

message("Reading primary-module inspection outputs...")
primary_summary <- fread(summary_file)
primary_genes <- fread(genes_file)
primary_terms <- fread(terms_file)
merge_assessment <- fread(merge_file)
manual_decisions <- fread(decision_file)

assign_final_label <- function(module_direction, provisional_label, evidence_grade, top_symbols, representative_terms) {
  lab <- tolower(provisional_label)
  terms <- tolower(representative_terms)
  syms <- toupper(top_symbols)

  if (module_direction == "higher_in_bacterial" && grepl("translation|ribosomal", lab)) {
    return(c(
      "BACT_M1",
      "Bacterial-higher cytoplasmic translation and ribosomal protein programme",
      "primary_discovery_module",
      "Retained as a compact bacterial-higher discovery module supported by cytoplasmic translation/ribosomal GO terms and ribosomal overlap genes."
    ))
  }

  if (module_direction == "higher_in_bacterial" && grepl("mitochondrial respiration|oxidative phosphorylation", lab)) {
    return(c(
      "BACT_M2",
      "Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme",
      "primary_discovery_module",
      "Retained as a compact bacterial-higher discovery module supported by respiratory-chain/oxidative phosphorylation GO terms and NDUF/ATP synthase-associated overlap genes."
    ))
  }

  if (module_direction == "higher_in_viral" &&
      grepl("antiviral|interferon", lab) &&
      evidence_grade == "A_strong_GO_support") {
    return(c(
      "VIR_M1a",
      "Viral-higher broad antiviral and interferon-stimulated defence programme",
      "primary_discovery_submodule",
      "Retained as the broader antiviral/interferon discovery submodule with strong GO support and canonical ISG/antiviral overlap genes."
    ))
  }

  if (module_direction == "higher_in_viral" &&
      grepl("antiviral|interferon", lab) &&
      evidence_grade == "B_moderate_GO_support") {
    return(c(
      "VIR_M1b",
      "Viral-higher viral restriction and type I interferon signalling subgroup",
      "primary_discovery_submodule",
      "Retained as a related but not force-merged antiviral/interferon subgroup because gene overlap with the broader antiviral module was below the merge threshold."
    ))
  }

  if (module_direction == "higher_in_viral" &&
      grepl("cytokine|innate immune", lab)) {
    return(c(
      "VIR_M2",
      "Viral-higher cytokine and innate immune regulation programme",
      "primary_discovery_module",
      "Retained as a viral-higher discovery module supported by cytokine/immune-response GO terms and immune-regulatory overlap genes."
    ))
  }

  return(c(
    "UNASSIGNED",
    provisional_label,
    "not_retained_as_primary_discovery_module",
    "Not retained in the final primary discovery-module label table."
  ))
}

message("Assigning conservative final discovery-module labels...")
assigned <- t(mapply(
  assign_final_label,
  primary_summary$module_direction,
  primary_summary$provisional_module_label,
  primary_summary$evidence_grade,
  primary_summary$top_30_symbols,
  primary_summary$GO_terms
))

primary_summary[, final_module_id := assigned[, 1]]
primary_summary[, final_module_label := assigned[, 2]]
primary_summary[, final_module_status := assigned[, 3]]
primary_summary[, final_label_rationale := assigned[, 4]]

# Explicitly record antiviral relationship.
antiviral_recommendation <- merge_assessment[assessment == "provisional_recommendation", value]
antiviral_jaccard <- merge_assessment[assessment == "max_pairwise_jaccard_between_antiviral_interferon_rows", value]
antiviral_shared <- merge_assessment[assessment == "shared_genes_between_closest_antiviral_interferon_rows", value]

primary_summary[, antiviral_submodule_relationship := fifelse(
  final_module_id %in% c("VIR_M1a", "VIR_M1b"),
  paste0(
    "Related antiviral/interferon submodules retained separately; pairwise Jaccard=",
    antiviral_jaccard,
    "; shared genes=",
    antiviral_shared,
    "; recommendation=",
    antiviral_recommendation
  ),
  NA_character_
)]

# Final label table.
final_modules <- primary_summary[
  final_module_status %in% c("primary_discovery_module", "primary_discovery_submodule")
]

setorder(final_modules, final_module_id)

# Attach final module labels to gene and GO-term rows.
label_cols <- final_modules[, .(
  primary_module_key,
  final_module_id,
  final_module_label,
  final_module_status,
  final_label_rationale,
  antiviral_submodule_relationship
)]

genes_labeled <- merge(primary_genes, label_cols, by = "primary_module_key", all.x = TRUE)
terms_labeled <- merge(primary_terms, label_cols, by = "primary_module_key", all.x = TRUE)

genes_labeled <- genes_labeled[!is.na(final_module_id)]
terms_labeled <- terms_labeled[!is.na(final_module_id)]

genes_labeled[, abs_pooled_logFC_for_ordering := abs(pooled_logFC)]
setorder(genes_labeled, final_module_id, pooled_adj.P.Val, -abs_pooled_logFC_for_ordering)
genes_labeled[, abs_pooled_logFC_for_ordering := NULL]

setorder(terms_labeled, final_module_id, p_adj_BH, p_value)

# Compact module table.
compact <- final_modules[, .(
  final_module_id,
  final_module_label,
  final_module_status,
  module_direction,
  provisional_module_label,
  evidence_grade,
  unique_entrez,
  n_GO_terms,
  n_FDR05_GO_terms,
  pct_all_three_concordant,
  pct_tier1_to_3,
  best_GO_FDR,
  top_30_symbols,
  GO_terms,
  final_label_rationale,
  antiviral_submodule_relationship
)]

# Final module summary.
module_summary <- final_modules[, .(
  n_final_module_rows = .N,
  total_unique_genes = sum(unique_entrez),
  total_GO_terms = sum(n_GO_terms),
  total_FDR05_GO_terms = sum(n_FDR05_GO_terms)
), by = .(module_direction, final_module_status)]

# Save.
fwrite(final_modules, file.path(out_dir, "GSE211567_final_discovery_module_label_table.tsv"), sep = "\t")
fwrite(compact, file.path(out_dir, "GSE211567_final_discovery_module_label_compact_table.tsv"), sep = "\t")
fwrite(module_summary, file.path(out_dir, "GSE211567_final_discovery_module_label_summary.tsv"), sep = "\t")
fwrite(genes_labeled, file.path(out_dir, "GSE211567_final_discovery_module_genes.tsv"), sep = "\t")
fwrite(terms_labeled, file.path(out_dir, "GSE211567_final_discovery_module_GO_terms.tsv"), sep = "\t")

# Plot gene counts by final module.
plot_dt <- copy(compact)
plot_dt[, final_module_plot_label := paste(final_module_id, final_module_label, sep = " | ")]
plot_dt[, final_module_plot_label := factor(final_module_plot_label, levels = rev(final_module_plot_label))]

p1 <- ggplot(plot_dt, aes(x = final_module_plot_label, y = unique_entrez)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 final discovery modules: gene counts",
    x = "Final discovery module",
    y = "Unique ENTREZ genes"
  )

ggsave(file.path(fig_dir, "GSE211567_final_discovery_module_gene_counts.png"), p1, width = 11, height = 5.5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_final_discovery_module_gene_counts.pdf"), p1, width = 11, height = 5.5)

# Plot GO term counts by final module.
p2 <- ggplot(plot_dt, aes(x = final_module_plot_label, y = n_GO_terms)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 final discovery modules: GO-term counts",
    x = "Final discovery module",
    y = "GO BP terms"
  )

ggsave(file.path(fig_dir, "GSE211567_final_discovery_module_GO_term_counts.png"), p2, width = 11, height = 5.5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_final_discovery_module_GO_term_counts.pdf"), p2, width = 11, height = 5.5)

sink(file.path(session_dir, "GSE211567_final_discovery_module_label_table_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_final_discovery_module_label_table_report.md")

writeLines(c(
  "# GSE211567 Final Discovery-Module Label Table Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: assign conservative final discovery-module labels to primary candidate modules after gene-level inspection.",
  "- Boundary: discovery labels only. This is not external validation, transportability proof or manuscript-level causal interpretation.",
  "",
  "## Final discovery-module summary",
  "",
  paste(capture.output(print(module_summary)), collapse = "\n"),
  "",
  "## Final discovery-module labels",
  "",
  paste(capture.output(print(compact[, .(
    final_module_id,
    final_module_label,
    final_module_status,
    module_direction,
    unique_entrez,
    n_GO_terms,
    n_FDR05_GO_terms,
    pct_all_three_concordant,
    best_GO_FDR,
    top_30_symbols,
    final_label_rationale
  )])), collapse = "\n"),
  "",
  "## Antiviral/interferon submodule boundary",
  "",
  paste(capture.output(print(merge_assessment)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- These are GSE211567 discovery-module labels, not externally validated transportable modules.",
  "- VIR_M1a and VIR_M1b are retained as related antiviral/interferon submodules rather than force-merged.",
  "- The final module table preserves module direction, GO-term evidence, gene membership and site-aware concordance evidence.",
  "- Manuscript claims should still distinguish discovery from external validation.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_table.tsv`",
  "- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_compact_table.tsv`",
  "- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_summary.tsv`",
  "- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_genes.tsv`",
  "- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_GO_terms.tsv`",
  "- `results/figures/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_gene_counts.png/.pdf`",
  "- `results/figures/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_GO_term_counts.png/.pdf`",
  "- `env/session_info/GSE211567_final_discovery_module_label_table_sessionInfo.txt`"
), con = report_file)

message("Final discovery-module label table complete.")
message("Report: ", report_file)
