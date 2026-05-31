# Manuscript Results-to-Figure/Table Mapping

## Purpose

This document maps the current manuscript Results narrative to the publication-grade figures, summary tables and supporting outputs generated in the project repository.

## Results Section 1

### Results subsection

**GSE211567 discovery analysis identifies site-aware bacterial- and viral-associated host-response programmes**

### Primary figure support

**Figure 1A**  
File base:

- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

### Additional figure support

**Figure 1B**  
File base:

- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

### Supporting source outputs

- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_logFC_correlation_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_direction_concordance_summary.tsv`

## Results Section 2

### Results subsection

**Conservative module locking defines five projection-ready discovery modules**

### Primary figure support

**Figure 1C**  
File base:

- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

### Supporting source outputs

- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_table.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_genes.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_metadata.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_scoring_rules.tsv`

## Results Section 3

### Results subsection

**GSE73461 was locked as an independent external projection cohort**

### Primary table support

**Table 1 / Supplementary Table candidate**

- `docs/GSE73461_manuscript_projection_summary_table.md`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

### Supporting source outputs

- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_group_counts.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_sample_table.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_module_probe_symbol_coverage.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_illuminaHumanv4_probe_annotation_join.tsv`

## Results Section 4

### Results subsection

**Fixed-module external projection supports transportability of the locked host-response architecture**

### Primary figure support

**Figure 2A**  
File base:

- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

**Figure 2B**  
File base:

- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

### Primary table support

**Table 1**

- `docs/GSE73461_manuscript_projection_summary_table.md`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

### Supporting source outputs

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_wide.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_projection_coverage.tsv`

## Results Section 5

### Results subsection

**Primary-only z-score sensitivity confirms robustness to the scoring reference set**

### Primary figure support

**Figure 2B**  
File base:

- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences`

**Figure 2C**  
File base:

- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues`

Available formats:

- `.png` — 1800 dpi raster
- `.svg` — editable vector
- `.pdf` — vector backup

### Primary table support

**Table 1**

- `docs/GSE73461_manuscript_projection_summary_table.md`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

### Supporting source outputs

- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_long.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_wide.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`

## Figure caption files

### Figure 1 caption draft

- `docs/GSE211567_manuscript_discovery_figure_caption.md`

### Figure 2 caption draft

- `docs/GSE73461_manuscript_projection_figure_caption.md`

## Current manuscript Results drafts

### Combined Results narrative

- `docs/combined_discovery_projection_results_manuscript_draft.md`

### GSE73461-specific Results narrative

- `docs/GSE73461_projection_results_manuscript_draft.md`

## Figure export standard

All manuscript-facing figures must be exported as:

1. PNG at 1800 dpi
2. Editable SVG
3. Vector PDF

The export standard is documented in:

- `docs/publication_figure_export_standard.md`

## Interpretation boundary

The mapped outputs support a fixed-module transportability manuscript workflow. They must not be described as diagnostic classifier training, gene rediscovery, module redefinition or causal validation.
