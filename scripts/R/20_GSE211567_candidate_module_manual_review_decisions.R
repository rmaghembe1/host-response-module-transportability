#!/usr/bin/env Rscript

# GSE211567 candidate module manual review decisions
# Purpose: classify provisional candidate modules into primary, secondary, contextual or deferred review tiers.
# Boundary: controlled review-decision table only; not final manuscript interpretation or external validation.

.libPaths("env/R_libs")

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_dir <- "results/module_lock/GSE211567_candidate_module_review"
out_dir <- "results/module_lock/GSE211567_manual_module_decisions"
fig_dir <- "results/figures/GSE211567_manual_module_decisions"
docs_dir <- "docs"
session_dir <- "env/session_info"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(docs_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(session_dir, recursive = TRUE, showWarnings = FALSE)

summary_file <- file.path(in_dir, "GSE211567_candidate_module_review_summary.tsv")
membership_file <- file.path(in_dir, "GSE211567_candidate_module_review_GO_term_membership.tsv")
genes_file <- file.path(in_dir, "GSE211567_candidate_module_review_overlap_genes_long.tsv")

message("Reading provisional candidate-module review outputs...")
modules <- fread(summary_file)
membership <- fread(membership_file)
genes <- fread(genes_file)

assign_review_decision <- function(module_direction, label, evidence_grade, total_GO_terms,
                                   FDR05_GO_terms, unique_genes, best_FDR,
                                   representative_terms) {
  lab <- tolower(label)
  terms <- tolower(representative_terms)

  # Strong bacterial-side core biology
  if (module_direction == "higher_in_bacterial") {
    if (grepl("translation|ribosomal", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("primary_candidate_module",
               "Compact and coherent bacterial-higher translation/ribosomal programme with strong GO support."))
    }

    if (grepl("mitochondrial respiration|oxidative phosphorylation", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("primary_candidate_module",
               "Compact and coherent bacterial-higher mitochondrial respiration/oxidative phosphorylation programme with strong GO support."))
    }

    if (grepl("glutathione|redox", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("secondary_candidate_module",
               "Biologically plausible bacterial-higher redox/glutathione programme, but represented by a single GO group and should be reviewed cautiously."))
    }

    if (grepl("glycolytic", lab)) {
      return(c("contextual_or_borderline_module",
               "Bacterial-higher glycolytic evidence is borderline and represented by a small single GO group; retain as contextual evidence only."))
    }

    return(c("defer_or_do_not_prioritize",
             "Bacterial-higher module does not meet primary or secondary review criteria."))
  }

  # Viral-side core biology
  if (module_direction == "higher_in_viral") {
    if (grepl("antiviral|interferon", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("primary_candidate_module",
               "Coherent viral-higher antiviral/interferon programme with strong/moderate GO support and recognizable overlap genes."))
    }

    if (grepl("cytokine|innate immune", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("primary_candidate_module",
               "Viral-higher cytokine/innate immune regulation programme with sufficient GO support for primary manual review."))
    }

    if (grepl("b-cell|adaptive", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("secondary_candidate_module",
               "Viral-higher B-cell/adaptive activation programme is biologically plausible but should be reviewed as secondary because support is split across compact groups."))
    }

    if (grepl("transcriptional|chromatin", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("secondary_candidate_module",
               "Large viral-higher transcription/chromatin regulatory programme; likely real but broad and should not be overinterpreted as a single mechanistic module without further review."))
    }

    if (grepl("chemotaxis|trafficking", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("secondary_candidate_module",
               "Viral-higher chemotaxis/immune-cell trafficking signal is plausible but represented by limited GO evidence; retain as secondary."))
    }

    if (grepl("nf-kb|kinase|signal", lab) &&
        evidence_grade %in% c("A_strong_GO_support", "B_moderate_GO_support")) {
      return(c("secondary_candidate_module",
               "Viral-higher kinase/NF-kB/signal-transduction evidence is plausible but broad; retain as secondary/manual-review evidence."))
    }

    if (grepl("contextual|developmental|tissue", lab)) {
      return(c("contextual_or_borderline_module",
               "Developmental/tissue-regulatory terms may reflect annotation pleiotropy or broad immune-regulatory genes; do not use as primary claims."))
    }

    if (evidence_grade == "C_borderline_GO_support") {
      return(c("contextual_or_borderline_module",
               "Borderline GO support; retain only as contextual evidence unless strengthened by additional evidence."))
    }

    return(c("defer_or_do_not_prioritize",
             "Viral-higher module does not meet primary or secondary review criteria."))
  }

  c("defer_or_do_not_prioritize", "Unrecognized module direction or insufficient evidence.")
}

message("Assigning manual review decisions...")
dec <- t(mapply(
  assign_review_decision,
  modules$module_direction,
  modules$provisional_module_label,
  modules$evidence_grade,
  modules$total_GO_terms,
  modules$FDR05_GO_terms,
  modules$unique_overlap_genes_across_groups,
  modules$best_FDR,
  modules$representative_terms
))

modules[, review_decision_tier := dec[, 1]]
modules[, review_decision_rationale := dec[, 2]]

modules[, final_claim_status := fifelse(
  review_decision_tier == "primary_candidate_module",
  "eligible_for_primary_manual_biological_review_not_final_claim",
  fifelse(
    review_decision_tier == "secondary_candidate_module",
    "eligible_for_secondary_manual_biological_review",
    fifelse(
      review_decision_tier == "contextual_or_borderline_module",
      "contextual_or_borderline_do_not_use_as_primary_claim",
      "defer_or_do_not_prioritize"
    )
  )
)]

# Stable sort for review
modules[, tier_order := fifelse(
  review_decision_tier == "primary_candidate_module", 1L,
  fifelse(review_decision_tier == "secondary_candidate_module", 2L,
          fifelse(review_decision_tier == "contextual_or_borderline_module", 3L, 4L))
)]

setorder(modules, tier_order, module_direction, best_FDR, provisional_module_label)
modules[, tier_order := NULL]

# Attach decisions to GO-term membership and overlap-gene tables.
# The module summary table does not contain direction_set/candidate_group_id.
# Use full module-review keys, including evidence grade and interpretation status,
# because the same provisional module label can appear in multiple evidence strata.
decision_cols <- unique(modules[, .(
  module_direction,
  provisional_module_id,
  provisional_module_label,
  evidence_grade,
  interpretation_status,
  review_decision_tier,
  review_decision_rationale,
  final_claim_status
)])

membership_decision <- merge(
  membership,
  decision_cols,
  by = c("module_direction", "provisional_module_id", "provisional_module_label", "evidence_grade", "interpretation_status"),
  all.x = TRUE
)

genes_decision <- merge(
  genes,
  decision_cols,
  by = c("module_direction", "provisional_module_id", "provisional_module_label", "evidence_grade", "interpretation_status"),
  all.x = TRUE
)

genes_decision[, abs_pooled_logFC_for_ordering := abs(pooled_logFC)]
setorder(genes_decision, review_decision_tier, module_direction, provisional_module_label,
         pooled_adj.P.Val, -abs_pooled_logFC_for_ordering)
genes_decision[, abs_pooled_logFC_for_ordering := NULL]

decision_summary <- modules[, .(
  n_module_rows = .N,
  total_GO_terms = sum(total_GO_terms),
  FDR05_GO_terms = sum(FDR05_GO_terms),
  median_unique_overlap_genes = median(unique_overlap_genes_across_groups),
  max_unique_overlap_genes = max(unique_overlap_genes_across_groups)
), by = .(review_decision_tier, module_direction)]

setorder(decision_summary, review_decision_tier, module_direction)

compact <- modules[, .(
  review_decision_tier,
  module_direction,
  provisional_module_label,
  evidence_grade,
  total_GO_terms,
  FDR05_GO_terms,
  unique_overlap_genes_across_groups,
  best_FDR,
  representative_terms,
  top_symbols_union,
  review_decision_rationale,
  final_claim_status
)]

fwrite(modules, file.path(out_dir, "GSE211567_manual_module_decision_table.tsv"), sep = "\t")
fwrite(compact, file.path(out_dir, "GSE211567_manual_module_decision_compact_table.tsv"), sep = "\t")
fwrite(decision_summary, file.path(out_dir, "GSE211567_manual_module_decision_summary.tsv"), sep = "\t")
fwrite(membership_decision, file.path(out_dir, "GSE211567_manual_module_decision_GO_term_membership.tsv"), sep = "\t")
fwrite(genes_decision, file.path(out_dir, "GSE211567_manual_module_decision_overlap_genes_long.tsv"), sep = "\t")

# Plot review-decision counts
plot_dt <- decision_summary[, .(
  n_module_rows = sum(n_module_rows)
), by = review_decision_tier]

plot_dt[, review_decision_tier := factor(
  review_decision_tier,
  levels = c(
    "primary_candidate_module",
    "secondary_candidate_module",
    "contextual_or_borderline_module",
    "defer_or_do_not_prioritize"
  )
)]

p1 <- ggplot(plot_dt, aes(x = review_decision_tier, y = n_module_rows)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 manual module review decision tiers",
    x = "Review decision tier",
    y = "Number of provisional module rows"
  )

ggsave(file.path(fig_dir, "GSE211567_manual_module_decision_tier_counts.png"), p1, width = 8, height = 4.5, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_manual_module_decision_tier_counts.pdf"), p1, width = 8, height = 4.5)

# Plot modules by overlap-gene count
plot_mod <- copy(modules)
plot_mod[, plot_label := paste(review_decision_tier, module_direction, provisional_module_label, sep = " | ")]
plot_mod[, plot_label := factor(plot_label, levels = rev(unique(plot_label)))]

p2 <- ggplot(plot_mod, aes(x = plot_label, y = unique_overlap_genes_across_groups)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  labs(
    title = "GSE211567 manual module review: overlap-gene counts",
    x = "Module review row",
    y = "Unique overlap genes"
  )

ggsave(file.path(fig_dir, "GSE211567_manual_module_decision_overlap_gene_counts.png"), p2, width = 11, height = 7, dpi = 300)
ggsave(file.path(fig_dir, "GSE211567_manual_module_decision_overlap_gene_counts.pdf"), p2, width = 11, height = 7)

sink(file.path(session_dir, "GSE211567_manual_module_decision_table_sessionInfo.txt"))
print(sessionInfo())
sink()

report_file <- file.path(docs_dir, "GSE211567_manual_module_decision_table_report.md")

writeLines(c(
  "# GSE211567 Manual Candidate-Module Review Decision Report",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "- Purpose: classify provisional candidate modules into primary, secondary, contextual or deferred manual-review tiers.",
  "- Boundary: this is a controlled review-decision table. It is not final manuscript interpretation and does not constitute external validation.",
  "",
  "## Decision summary",
  "",
  paste(capture.output(print(decision_summary)), collapse = "\n"),
  "",
  "## Compact decision table",
  "",
  paste(capture.output(print(compact)), collapse = "\n"),
  "",
  "## Interpretation boundary",
  "",
  "- Primary candidate modules are eligible for manual biological review, not final manuscript claims.",
  "- Secondary modules may support the biological narrative but require caution and further inspection.",
  "- Contextual/borderline modules should not be used as primary claims.",
  "- Deferred modules should not be prioritized unless strengthened by additional evidence.",
  "",
  "## Generated files",
  "",
  "- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_table.tsv`",
  "- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_compact_table.tsv`",
  "- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_summary.tsv`",
  "- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_GO_term_membership.tsv`",
  "- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_overlap_genes_long.tsv`",
  "- `results/figures/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_tier_counts.png/.pdf`",
  "- `results/figures/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_overlap_gene_counts.png/.pdf`",
  "- `env/session_info/GSE211567_manual_module_decision_table_sessionInfo.txt`"
), con = report_file)

message("Manual candidate-module review decision table complete.")
message("Report: ", report_file)
