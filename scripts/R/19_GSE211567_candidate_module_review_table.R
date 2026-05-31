#!/usr/bin/env Rscript

# GSE211567 candidate module review table
# Purpose: add provisional higher-order module labels to redundancy-reduced GO BP candidate groups.
# Boundary: provisional module review table only; not final manuscript-level module naming or biological claims.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_dir <- "results/module_lock/GSE211567_GO_BP_redundancy_reduction"
out_dir <- "results/module_lock/GSE211567_candidate_module_review"
fig_dir <- "results/figures/GSE211567_candidate_module_review"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

groups_file <- file.path(in_dir, "GSE211567_GO_BP_candidate_term_groups.tsv")
membership_file <- file.path(in_dir, "GSE211567_GO_BP_candidate_group_term_membership.tsv")
genes_file <- file.path(in_dir, "GSE211567_GO_BP_candidate_group_overlap_genes_long.tsv")

message("Reading redundancy-reduced GO BP candidate groups...")
groups <- fread(groups_file)
membership <- fread(membership_file)
group_genes <- fread(genes_file)

assign_module <- function(direction_set, representative_term, group_terms) {
  text <- tolower(paste(representative_term, group_terms, sep = " | "))

  if (direction_set == "bacterial_higher_site_aware_eligible") {
    if (grepl("translation|ribosom|cytoplasmic translation", text)) {
      return(c("Bacterial_higher_translation_ribosomal_programme",
               "Cytoplasmic translation / ribosomal protein programme"))
    }
    if (grepl("mitochondrial|respiratory chain|electron transport|atp synthesis|aerobic respiration|oxidative", text)) {
      return(c("Bacterial_higher_mitochondrial_respiration_programme",
               "Mitochondrial respiration / oxidative phosphorylation programme"))
    }
    if (grepl("glutathione|redox|oxidative stress", text)) {
      return(c("Bacterial_higher_glutathione_redox_programme",
               "Glutathione / redox metabolism programme"))
    }
    if (grepl("glycolytic|glycolysis", text)) {
      return(c("Bacterial_higher_glycolytic_programme",
               "Glycolytic process programme"))
    }
    return(c("Bacterial_higher_other_metabolic_or_cellular_programme",
             "Other bacterial-higher metabolic/cellular programme"))
  }

  if (direction_set == "viral_higher_site_aware_eligible") {
    if (grepl("virus|viral|interferon|type i interferon|interferon-beta|innate immune response|defense response", text)) {
      return(c("Viral_higher_antiviral_interferon_programme",
               "Antiviral / interferon-response programme"))
    }
    if (grepl("cytokine|macrophage|interleukin|immune response", text)) {
      return(c("Viral_higher_cytokine_innate_immune_regulation_programme",
               "Cytokine and innate immune regulation programme"))
    }
    if (grepl("b cell|b-cell|lymphocyte|adaptive", text)) {
      return(c("Viral_higher_B_cell_adaptive_activation_programme",
               "B-cell / adaptive immune activation programme"))
    }
    if (grepl("transcription|rna polymerase|chromatin|dna-templated|polymerase ii|polymerase iii", text)) {
      return(c("Viral_higher_transcription_chromatin_regulatory_programme",
               "Transcriptional and chromatin-regulatory programme"))
    }
    if (grepl("chemotaxis|migration|trafficking", text)) {
      return(c("Viral_higher_chemotaxis_trafficking_programme",
               "Chemotaxis / immune-cell trafficking programme"))
    }
    if (grepl("nf-kappa|nf-kappab|kinase|phosphorylation|signal transduction|erk|pi3|akt|bmp", text)) {
      return(c("Viral_higher_signalling_kinase_NFkB_programme",
               "NF-kB / kinase / signal-transduction programme"))
    }
    if (grepl("synaptic|somitogenesis|bone mineralization|development", text)) {
      return(c("Viral_higher_contextual_developmental_or_tissue_regulatory_terms",
               "Contextual developmental/tissue-regulatory terms"))
    }
    return(c("Viral_higher_other_regulatory_or_contextual_programme",
             "Other viral-higher regulatory/contextual programme"))
  }

  c("Unassigned", "Unassigned")
}

assign_evidence_grade <- function(n_terms, n_FDR05_terms, representative_FDR, n_unique_overlap_genes) {
  if (n_FDR05_terms >= 2 && representative_FDR < 0.01 && n_unique_overlap_genes >= 15) {
    return("A_strong_GO_support")
  }
  if (n_FDR05_terms >= 1 && representative_FDR < 0.05) {
    return("B_moderate_GO_support")
  }
  if (representative_FDR < 0.10) {
    return("C_borderline_GO_support")
  }
  "D_insufficient_GO_support"
}

message("Assigning provisional module labels...")
assignments <- t(mapply(
  assign_module,
  groups$direction_set,
  groups$representative_TERM,
  groups$group_terms
))

groups[, provisional_module_id := assignments[, 1]]
groups[, provisional_module_label := assignments[, 2]]

groups[, evidence_grade := mapply(
  assign_evidence_grade,
  n_terms,
  n_FDR05_terms,
  representative_FDR,
  n_unique_overlap_genes
)]

groups[, interpretation_status := fifelse(
  evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support"),
  "candidate_module_ready_for_manual_biological_review",
  "retain_as_contextual_or_borderline_evidence"
)]

groups[, module_direction := fifelse(
  direction_set == "bacterial_higher_site_aware_eligible",
  "higher_in_bacterial",
  "higher_in_viral"
)]

setorder(groups, module_direction, provisional_module_id, representative_FDR)

# Add module labels to term membership
membership_labeled <- merge(
  membership,
  groups[, .(
    direction_set,
    candidate_group_id,
    provisional_module_id,
    provisional_module_label,
    evidence_grade,
    interpretation_status,
    module_direction
  )],
  by = c("direction_set", "candidate_group_id"),
  all.x = TRUE
)

setorder(membership_labeled, module_direction, provisional_module_id, p_adj_BH, p_value)

# Add module labels to gene table
genes_labeled <- merge(
  group_genes,
  groups[, .(
    direction_set,
    candidate_group_id,
    provisional_module_id,
    provisional_module_label,
    evidence_grade,
    interpretation_status,
    module_direction
  )],
  by = c("direction_set", "candidate_group_id"),
  all.x = TRUE
)

genes_labeled[, abs_pooled_logFC_for_ordering := abs(pooled_logFC)]
setorder(genes_labeled, module_direction, provisional_module_id, pooled_adj.P.Val, -abs_pooled_logFC_for_ordering)
genes_labeled[, abs_pooled_logFC_for_ordering := NULL]

module_summary <- groups[, .(
  candidate_GO_groups = .N,
  total_GO_terms = sum(n_terms),
  FDR05_GO_terms = sum(n_FDR05_terms),
  unique_overlap_genes_across_groups = uniqueN(unlist(strsplit(paste(group_overlap_gene_ids, collapse = ";"), ";", fixed = TRUE))),
  best_FDR = min(representative_FDR),
  representative_terms = paste(representative_TERM, collapse = " | "),
  representative_GO_ids = paste(representative_GO, collapse = ";"),
  top_symbols_union = paste(unique(unlist(strsplit(paste(top_overlap_symbols, collapse = ";"), ";", fixed = TRUE)))[1:min(50, length(unique(unlist(strsplit(paste(top_overlap_symbols, collapse = ";"), ";", fixed = TRUE)))))], collapse = ";")
), by = .(
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  interpretation_status
)]

setorder(module_summary, module_direction, provisional_module_id)

fwrite(groups, file.path(out_dir, "GSE211567_candidate_module_review_GO_group_assignments.tsv"), sep = "\t")
fwrite(module_summary, file.path(out_dir, "GSE211567_candidate_module_review_summary.tsv"), sep = "\t")
fwrite(membership_labeled, file.path(out_dir, "GSE211567_candidate_module_review_GO_term_membership.tsv"), sep = "\t")
fwrite(genes_labeled, file.path(out_dir, "GSE211567_candidate_module_review_overlap_genes_long.tsv"), sep = "\t")

# Compact human-readable table
compact <- module_summary[, .(
  module_direction,
  provisional_module_label,
  evidence_grade,
  candidate_GO_groups,
  total_GO_terms,
  FDR05_GO_terms,
  unique_overlap_genes_across_groups,
  best_FDR,
  representative_terms,
  top_symbols_union,
  interpretation_status
)]

fwrite(compact, file.path(out_dir, "GSE211567_candidate_module_review_compact_table.tsv"), sep = "\t")

# Plot module GO-term counts
plot_dt <- copy(module_summary)
plot_dt[, plot_label := paste(module_direction, provisional_module_id, provisional_module_label, sep = " | ")]
plot_dt[, plot_label := factor(plot_label, levels = rev(unique(plot_label)))]

p1 <- ggplot(plot_dt, aes(x = plot_label, y = total_GO_terms)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 provisional candidate modules by GO-term count",
    x = "Provisional candidate module",
    y = "GO BP terms"
  )

ggsave(file.path(fig_dir, "GSE211567_candidate_module_GO_term_counts.png"), p1, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_candidate_module_GO_term_counts.pdf"), p1, width = 10, height = 6)

# Plot module overlap-gene counts
plot_dt2 <- copy(module_summary)
plot_dt2[, plot_label := paste(module_direction, provisional_module_id, provisional_module_label, sep = " | ")]
plot_dt2[, plot_label := factor(plot_label, levels = rev(unique(plot_label)))]

p2 <- ggplot(plot_dt2, aes(x = plot_label, y = unique_overlap_genes_across_groups)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 provisional candidate modules by overlap-gene count",
    x = "Provisional candidate module",
    y = "Unique overlap genes"
  )

ggsave(file.path(fig_dir, "GSE211567_candidate_module_overlap_gene_counts.png"), p2, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_candidate_module_overlap_gene_counts.pdf"), p2, width = 10, height = 6)

sink(file.path(session_dir, "GSE211567_candidate_module_review_table_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_candidate_module_review_table_report.md")

writeLines(c(
  "# GSE211567 Candidate Module Review Table Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: add provisional higher-order module labels to redundancy-reduced GO BP candidate groups.",
  "- Boundary: this is a candidate review table only. It is not final manuscript-level module naming and does not make final biological claims.",
  "",
  "## Input",
  "",
  paste0("- GO BP candidate groups imported: ", nrow(groups)),
  paste0("- GO term membership rows imported: ", nrow(membership)),
  paste0("- Candidate-group overlap-gene rows imported: ", nrow(group_genes)),
  "",
  "## Provisional candidate module summary",
  "",
  paste(capture.output(print(compact)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- Provisional module labels are evidence-organising labels.",
  "- Final module names require manual review of GO terms, overlap genes, directionality, site-aware stability and biological plausibility.",
  "- Contextual/borderline modules should not be used as primary biological claims.",
  "- This table is intended to guide the next manual evidence review step.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_candidate_module_review/GSE211567_candidate_module_review_GO_group_assignments.tsv`",
  "- `results/module_lock/GSE211567_candidate_module_review/GSE211567_candidate_module_review_summary.tsv`",
  "- `results/module_lock/GSE211567_candidate_module_review/GSE211567_candidate_module_review_GO_term_membership.tsv`",
  "- `results/module_lock/GSE211567_candidate_module_review/GSE211567_candidate_module_review_overlap_genes_long.tsv`",
  "- `results/module_lock/GSE211567_candidate_module_review/GSE211567_candidate_module_review_compact_table.tsv`",
  "- `results/figures/GSE211567_candidate_module_review/GSE211567_candidate_module_GO_term_counts.png/.pdf`",
  "- `results/figures/GSE211567_candidate_module_review/GSE211567_candidate_module_overlap_gene_counts.png/.pdf`",
  "- `env/session_info/GSE211567_candidate_module_review_table_sessionInfo.txt`"
), con = report_file)

message("Candidate module review table complete.")
message("Report: ", report_file)
