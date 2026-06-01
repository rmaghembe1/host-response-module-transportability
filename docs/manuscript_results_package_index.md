# Manuscript Results Package Index

## Purpose

This index lists the current manuscript-ready Results materials for the host–pathogen transcriptome transportability project. It is intended as a compact guide for manuscript assembly, internal review and later submission preparation.

## Core Results text

### Integrated Results section with figure/table callouts

- `docs/integrated_results_section_with_callouts.md`

Use as the current main Results draft for manuscript assembly.

### Combined discovery/projection Results draft

- `docs/combined_discovery_projection_results_manuscript_draft.md`

Use as a supporting narrative draft and fallback reference.

### GSE73461-specific Results draft

- `docs/GSE73461_projection_results_manuscript_draft.md`

Use for detailed external-projection wording if the manuscript needs a longer projection subsection.


## Methods materials

### Full Methods draft

- `docs/methods_section_full_draft.md`

Use as the current manuscript Methods draft.

### Methods section skeleton

- `docs/methods_section_skeleton.md`

Use as the structural fallback if the full Methods section needs trimming.

### Methods–Results alignment map

- `docs/methods_results_alignment_map.md`

Use to verify that Methods descriptions remain aligned with Results claims, scripts, outputs and interpretation boundaries.

## Main figures

### Figure 1 — GSE211567 discovery and module locking

Figure files:

- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.pdf`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.pdf`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.pdf`

Caption:

- `docs/polished_main_figure_captions.md`
- Figure 1 draft-specific caption backup: `docs/GSE211567_manuscript_discovery_figure_caption.md`

### Figure 2 — GSE73461 fixed-module external projection

Figure files:

- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.pdf`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.pdf`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.pdf`

Caption:

- `docs/polished_main_figure_captions.md`
- Figure 2 draft-specific caption backup: `docs/GSE73461_manuscript_projection_figure_caption.md`

## Main table

### Table 1 — External projection of locked GSE211567 discovery modules in GSE73461

Table files:

- `docs/GSE73461_manuscript_projection_summary_table.md`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

Title and footnotes:

- `docs/polished_table1_title_and_footnotes.md`

## Mapping and audit files

### Results-to-figure/table mapping

- `docs/manuscript_results_figure_table_mapping.md`

### Mapping path audit

- `scripts/python/37_audit_manuscript_mapping_paths.py`
- `results/audits/manuscript_results_figure_table_mapping_path_audit.tsv`

Latest audit status:

- 37 mapped path entries
- 44 expanded checked files
- 44 present
- 0 missing

## Figure export standard

- `docs/publication_figure_export_standard.md`
- helper script: `scripts/R/00_publication_figure_export_helpers.R`

Current standard:

- PNG at 1800 dpi
- editable SVG
- vector PDF

## Interpretation boundaries

The current manuscript Results package supports fixed-module transportability analysis across discovery and external projection cohorts. It must not be framed as diagnostic classifier discovery, diagnostic model training, gene rediscovery, module redefinition or causal validation.

## Current manuscript-ready framing

The preferred framing is:

> A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes in GSE211567, and fixed-module projection in GSE73461 supported external transportability of the antiviral/interferon modules and the bacterial mitochondrial respiration/OXPHOS module, while the bacterial cytoplasmic translation/ribosomal module remained directionally concordant but borderline.
