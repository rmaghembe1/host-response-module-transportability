# CMI-Specific Supplementary-Material Inventory

## Purpose

This document defines the supplementary-material package for the CMI-facing manuscript draft v0.5. The goal is to keep the main manuscript concise for *Clinical Microbiology and Infection* while preserving the full reproducibility, decision-tracking and audit trail of the analysis.

## Current manuscript anchor

Current CMI-facing manuscript draft:

- `docs/complete_manuscript_draft_v0.5_cmi.md`

Current CMI-facing support files:

- `docs/cmi_facing_title_abstract_variant.md`
- `docs/cmi_facing_cover_letter_draft.md`
- `docs/cmi_specific_manuscript_polishing_checklist.md`
- `docs/cmi_facing_manuscript_adaptation_checklist.md`

## Supplementary-material strategy

The main manuscript should contain only the essential scientific narrative, key methods, two main figures and one main table. Detailed cohort-audit outputs, gene lists, identifier mapping, projection-support files, sensitivity outputs, path audits, session information and figure-export records should be organized as supplementary materials.

## Proposed supplementary files

### Supplementary Table S1 — External projection candidate search register

Purpose:

- Document external cohort search and eligibility decisions.
- Show why GSE73461 was selected for formal projection.
- Show why other candidate cohorts were held, excluded or used only for technical rehearsal.

Candidate source files:

- `docs/formal_external_projection_candidate_search_register.md`
- `docs/formal_external_projection_candidate_search_plan.md`
- `docs/GSE261482_external_projection_candidate_boundary.md`
- `docs/GSE68310_external_projection_candidate_boundary.md`

Status:

- [ ] Confirm exact source paths.
- [ ] Convert into clean supplementary table format.

### Supplementary Table S2 — GSE211567 locked discovery module genes

Purpose:

- List locked module membership for BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2.
- Preserve transparency of module composition before external projection.

Candidate source files:

- `results/module_projection/GSE211567_projection_ready_module_scoring_inputs/`
- `results/tables/`
- `docs/GSE211567_final_discovery_module_label_table.md`

Status:

- [ ] Identify final locked module gene-list TSV.
- [ ] Confirm gene symbols and module labels.
- [ ] Ensure no post-projection gene changes are introduced.

### Supplementary Table S3 — GSE73461 identifier coverage and scored genes

Purpose:

- Document locked gene coverage in GSE73461.
- Show matched and missing genes.
- Provide probe/gene mapping used for projection.

Candidate source files:

- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_matched_genes.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_missing_genes.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_gene_probe_choice_for_projection.tsv`

Status:

- [ ] Confirm all paths exist.
- [ ] Merge into one readable supplementary table if appropriate.

### Supplementary Table S4 — GSE73461 projection sample set

Purpose:

- Document DefiniteBacterial, DefiniteViral and secondary Control sample roles.
- Preserve cohort-lock transparency.

Candidate source files:

- GSE73461 cohort-lock metadata output.
- GSE73461 projection score files.

Likely source files:

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_wide.tsv`

Status:

- [ ] Locate final sample-role metadata file.
- [ ] Confirm sample group counts.
- [ ] Prepare de-identified supplementary sample table.

### Supplementary Table S5 — GSE73461 fixed-module projection statistics

Purpose:

- Provide full projection test results and sensitivity results.
- Support main Table 1.

Candidate source files:

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

Status:

- [x] Main summary table exists.
- [ ] Decide whether to include full test outputs as supplementary table.

### Supplementary Figure S1 — External projection candidate audit workflow

Purpose:

- Show the cohort search, exclusion, technical rehearsal and formal projection sequence.
- Keep main figure set concise.

Candidate source files:

- `docs/manuscript_results_figure_table_mapping.md`
- `docs/hybrid_no_apc_target_audit.md` is journal-related and not scientific supplement; do not include in scientific supplement.

Status:

- [ ] Decide whether this is needed or whether textual Methods are sufficient.

### Supplementary Figure S2 — Identifier coverage and projection robustness

Purpose:

- Show locked gene coverage by module.
- Show main versus primary-only z-score sensitivity.
- Show probe-to-gene collapse workflow if needed.

Candidate source files:

- `docs/GSE73461_projection_results_table_and_figure_plan.md`
- `results/figures/GSE73461_manuscript_projection_panels/`
- `docs/GSE73461_manuscript_projection_figure_caption.md`

Status:

- [ ] Decide whether to promote any current panel to supplementary figure.
- [ ] Confirm 1800 dpi PNG, SVG and PDF versions exist.

### Supplementary File S1 — Reproducibility and decision-log package

Purpose:

- Provide a transparent audit trail of dataset selection, module locking, projection boundaries and manuscript package QC.
- Avoid overloading the main manuscript with repository details.

Candidate source files:

- `docs/decision_log.md`
- `docs/methods_results_alignment_map.md`
- `docs/manuscript_results_package_index.md`
- `results/audits/manuscript_results_package_index_path_audit.tsv`
- `results/audits/complete_manuscript_v0.5_cmi_qc_summary.md`
- `results/audits/complete_manuscript_v0.5_cmi_qc_details.tsv`

Status:

- [ ] Decide whether to include as supplementary file or keep in GitHub repository only.

### Supplementary File S2 — Session information

Purpose:

- Support computational reproducibility.

Candidate source files:

- `env/session_info/`

Status:

- [ ] List final session-info files.
- [ ] Decide whether to combine into one supplementary file.

## Main manuscript cross-references

Suggested cross-reference points:

- Methods: cite Supplementary Table S1 for external cohort search and eligibility.
- Methods: cite Supplementary Table S2 for locked module genes.
- Methods/Results: cite Supplementary Table S3 for GSE73461 identifier coverage.
- Results: cite Supplementary Table S5 for full projection statistics.
- Data/code availability: cite repository and reproducibility package.

## Exclusions from scientific supplement

The following files are internal manuscript-preparation records and should not be submitted as scientific supplementary materials unless specifically needed:

- Journal-targeting documents.
- APC/waiver screening documents.
- Cover letter drafts.
- CMI adaptation checklists.
- Manuscript package index except as repository documentation.
- Financial-first journal tables.

## Immediate next actions

1. Locate final source paths for each proposed supplementary item.
2. Create a path-audited supplementary inventory table.
3. Generate manuscript-ready supplementary TSV files.
4. Draft supplementary legends/titles.
5. Add supplementary citations to the CMI-facing manuscript draft.
6. Re-run manuscript QC and package audit.

## Interpretation boundary

Supplementary materials must support fixed-module transportability analysis. They should not imply diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.
