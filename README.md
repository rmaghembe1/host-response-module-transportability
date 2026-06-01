# Host–Pathogen Transcriptome Transportability Analysis

## Project overview

This repository contains the analysis workflow, decision logs, manuscript-facing outputs and supplementary materials for a fixed-module host-response transcriptome transportability study.

The study uses a site-aware discovery workflow in GSE211567 to define bacterial- and viral-associated host-response modules, then projects the locked modules into the independent GSE73461 infection transcriptomic cohort. The analysis is designed as fixed-module transportability assessment, not diagnostic classifier discovery or diagnostic model validation.

## Current manuscript

Current target manuscript draft:

- `docs/complete_manuscript_draft_v0.5_cmi.md`

Target journal:

- *Clinical Microbiology and Infection*

Submission route:

- Standard subscription/non-open-access route unless full open-access coverage is confirmed.

## Main analysis stages

1. GSE211567 discovery cohort preparation.
2. Bacterial-versus-viral differential-expression modelling.
3. Site-stratified concordance assessment.
4. Transcript-to-gene mapping and GO biological-process enrichment.
5. Conservative module review and locking.
6. Projection-ready scoring rule definition.
7. Technical projection rehearsal in GSE161731.
8. Formal external projection cohort selection.
9. GSE73461 identifier mapping and module coverage assessment.
10. Fixed-module projection scoring in GSE73461.
11. Primary-only z-score sensitivity analysis.
12. Manuscript figure, table and supplementary-material generation.

## Key manuscript-facing files

### Complete manuscript

- `docs/complete_manuscript_draft_v0.5_cmi.md`

### Cover letter

- `docs/cmi_facing_cover_letter_draft.md`

### Supplementary tables index

- `docs/supplementary_materials/CMI_supplementary_tables_index.md`

### Supplementary material inventory

- `docs/cmi_supplementary_material_inventory.md`

### Decision log

- `docs/decision_log.md`

### Manuscript package index

- `docs/manuscript_results_package_index.md`

## Supplementary tables

### Supplementary Table S1

External projection candidate search register.

- `docs/supplementary_materials/Supplementary_Table_S1_external_projection_candidate_register.md`
- `results/supplementary_tables/Supplementary_Table_S1_external_projection_candidate_register.tsv`

### Supplementary Table S2

Locked GSE211567 discovery module genes.

- `docs/supplementary_materials/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.md`
- `results/supplementary_tables/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.tsv`

### Supplementary Table S3

GSE73461 identifier coverage and scored genes.

- `docs/supplementary_materials/Supplementary_Table_S3_GSE73461_identifier_coverage_and_scored_genes.md`
- `results/supplementary_tables/Supplementary_Table_S3A_GSE73461_module_identifier_coverage.tsv`
- `results/supplementary_tables/Supplementary_Table_S3B_GSE73461_matched_locked_module_genes.tsv`
- `results/supplementary_tables/Supplementary_Table_S3C_GSE73461_missing_locked_module_genes.tsv`
- `results/supplementary_tables/Supplementary_Table_S3D_GSE73461_gene_probe_choice_for_projection.tsv`

### Supplementary Table S4

GSE73461 fixed-module projection sample scores.

- `docs/supplementary_materials/Supplementary_Table_S4_GSE73461_projection_sample_scores.md`
- `results/supplementary_tables/Supplementary_Table_S4A_GSE73461_fixed_module_scores_long.tsv`
- `results/supplementary_tables/Supplementary_Table_S4B_GSE73461_fixed_module_scores_wide.tsv`

### Supplementary Table S5

GSE73461 projection statistics and sensitivity results.

- `docs/supplementary_materials/Supplementary_Table_S5_GSE73461_projection_statistics_and_sensitivity.md`
- `results/supplementary_tables/Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv`
- `results/supplementary_tables/Supplementary_Table_S5B_GSE73461_primary_only_zscore_sensitivity_tests.tsv`
- `results/supplementary_tables/Supplementary_Table_S5C_GSE73461_manuscript_projection_summary.tsv`

## Audits and quality control

### Manuscript QC

- `results/audits/complete_manuscript_v0.5_cmi_qc_summary.md`
- `results/audits/complete_manuscript_v0.5_cmi_qc_details.tsv`

### Manuscript package path audit

- `results/audits/manuscript_results_package_index_path_audit.tsv`

### Supplementary tables package audit

- `results/audits/cmi_supplementary_tables_package_audit_summary.md`
- `results/audits/cmi_supplementary_tables_package_audit.tsv`

### Supplementary source-path audit

- `results/audits/cmi_supplementary_source_path_audit_summary.md`
- `results/audits/cmi_supplementary_source_path_audit.tsv`

## Data availability

This project reanalyses publicly available transcriptomic datasets. The main discovery dataset is GSE211567, and the formal external projection dataset is GSE73461. Candidate or rehearsal datasets considered during the workflow include GSE161731, GSE261482 and GSE68310.

Raw public data should be downloaded from the original repositories. This repository is intended to contain scripts, processed analysis outputs, manuscript-facing outputs, decision logs and reproducibility records, not redistributed raw controlled or third-party source data.

## Interpretation boundary

This repository supports fixed-module transportability analysis of host-response programmes. It should not be interpreted as diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.

## Reproducibility notes

The repository includes scripted audits for manuscript package paths, supplementary source paths, supplementary table files and manuscript QC checks. The decision log documents major workflow boundaries and interpretation safeguards.

## Citation

A formal citation should be added after manuscript submission or publication.
