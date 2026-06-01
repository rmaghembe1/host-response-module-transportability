# Methods–Results Alignment Map

## Purpose

This document aligns the manuscript Results package with the analysis methods, scripts, outputs and interpretation boundaries already locked in the repository. It is intended to prevent manuscript drift, overclaiming and mismatch between Results statements and Methods descriptions.

## Analysis stage 1 — GSE211567 discovery cohort preparation

### Results supported

- GSE211567 was used as the discovery dataset.
- The primary comparison was bacterial versus viral infection.
- Site-aware analysis was required because the dataset included geographically/clinically distinct strata.

### Methods that must be described

- Metadata audit and sample eligibility locking.
- Normalized matrix QC.
- Primary bacterial-versus-viral design decision.
- Covariate feasibility assessment.
- Site-stratified analysis design.

### Key scripts / outputs

- `docs/decision_log.md`
- `results/qc/GSE211567_locked_normalized_matrix/`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_summary.tsv`

### Boundary

This stage supports discovery analysis only. It does not support diagnostic model training or external validation claims.

## Analysis stage 2 — Primary differential-expression modelling

### Results supported

- Host-transcriptomic features were ranked by bacterial-versus-viral differential expression.
- The primary limma contrast served as the discovery starting point.

### Methods that must be described

- Limma-based bacterial-versus-viral modelling.
- Direction convention for logFC.
- Multiple-testing correction.
- Ranked feature output generation.

### Key scripts / outputs

- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_top50_preview.tsv`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_A_primary_discovery_volcano.pdf`

### Boundary

The primary contrast is a discovery ranking step, not a standalone diagnostic signature.

## Analysis stage 3 — Site-stratified concordance and site-aware stability

### Results supported

- Pooled discovery effects were compared with site-stratified effects.
- Site-aware concordance supported conservative downstream feature filtering.
- Concordance differed across pooled-versus-site and site-versus-site comparisons.

### Methods that must be described

- Site-stratified limma modelling.
- Spearman and Pearson logFC concordance.
- Directional concordance across all modelled features.
- Definition of site-aware stable/eligible feature sets.

### Key scripts / outputs

- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_logFC_correlation_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_direction_concordance_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_pooled_site_stratified_concordance_table.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stable_feature_table.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_features.tsv`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_B_site_stratified_concordance_summary.pdf`

### Boundary

Site-aware concordance supports feature stability assessment. It does not imply that all site-specific biology is identical.

## Analysis stage 4 — Transcript-to-gene mapping and GO enrichment

### Results supported

- Site-aware eligible transcript features were mapped to gene-level identifiers.
- Bacterial-higher and viral-higher gene sets were used for GO biological-process enrichment.
- Redundancy-reduced GO groups supported biological module interpretation.

### Methods that must be described

- RefSeq/transcript-to-gene annotation bridge.
- Gene-level summarization.
- GO BP over-representation analysis.
- Redundancy reduction of enriched GO terms.
- Separation of bacterial-higher and viral-higher feature sets.

### Key scripts / outputs

- `results/module_lock/GSE211567_refseq_annotation_bridge/`
- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/`
- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/`

### Boundary

GO enrichment supports biological interpretation of ranked/stable gene sets; it does not establish causal mechanisms.

## Analysis stage 5 — Conservative module review and final module locking

### Results supported

- Five final GSE211567 discovery modules were locked.
- BACT_M1 and BACT_M2 were bacterial-higher modules.
- VIR_M1a, VIR_M1b and VIR_M2 were viral-higher modules.
- VIR_M1a and VIR_M1b were retained as related submodules rather than force-merged.

### Methods that must be described

- Manual review of redundancy-reduced GO groups.
- Review-decision tiers.
- Gene-level inspection of primary candidate modules.
- Final conservative module labelling.
- Freezing of module membership before external projection.

### Key scripts / outputs

- `results/module_lock/GSE211567_candidate_module_review/`
- `results/module_lock/GSE211567_manual_module_decisions/`
- `results/module_lock/GSE211567_primary_module_gene_inspection/`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_table.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_genes.tsv`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.png`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.svg`
- `results/figures/GSE211567_manuscript_discovery_panels/Figure_GSE211567_C_locked_discovery_module_gene_counts.pdf`

### Boundary

Locked modules are discovery-derived biological modules. They are not diagnostic classifiers and are not causal modules.

## Analysis stage 6 — Projection-ready scoring inputs

### Results supported

- Locked modules were converted into projection-ready fixed gene sets.
- Primary scoring used unweighted mean z-score module scoring.
- Missing genes were ignored in score calculation but coverage was reported.
- Direction was preserved from GSE211567 discovery.

### Methods that must be described

- Construction of module gene tables.
- Gene-wise z-scoring within each external dataset.
- Unweighted mean z-score calculation.
- Coverage threshold rules.
- Optional bounded abs(logFC)-weighted sensitivity scoring, if mentioned.

### Key scripts / outputs

- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_metadata.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_scoring_rules.tsv`

### Boundary

External cohorts must not be used to reselect genes, rename modules or alter module composition.

## Analysis stage 7 — GSE161731 technical scoring rehearsal

### Results supported

- GSE161731 was used only to test projection mechanics.
- Identifier mapping and fixed-module scoring were technically feasible.
- No biological validation or transportability claim was made from GSE161731.

### Methods that must be described

Only describe this if included as workflow validation or supplement:

- Identifier coverage audit.
- ENSEMBL mapping.
- Technical fixed-module scoring rehearsal.

### Key scripts / outputs

- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/`
- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/`

### Boundary

GSE161731 is a technical rehearsal resource only, not a formal validation cohort.

## Analysis stage 8 — Formal external cohort search and GSE73461 locking

### Results supported

- Candidate external cohorts were audited.
- GSE261482 was not locked for bacterial-versus-viral projection because viral/pathogen-class metadata were not recovered.
- GSE68310 was audited but not used as the formal primary projection cohort.
- GSE73461 was locked as the formal external projection cohort.

### Methods that must be described

- External cohort eligibility criteria.
- Candidate cohort search register.
- Metadata/sample-label audit.
- Expression file structure audit.
- Identifier coverage audit.
- Cohort-lock decision before scoring.

### Key scripts / outputs

- `results/external_projection_candidate_audit/GSE261482/`
- `results/external_projection_candidate_audit/GSE73461_expression_files/`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv`

### Boundary

External cohort choice was locked before scoring; GSE73461 was used for fixed-module projection, not rediscovery.

## Analysis stage 9 — GSE73461 fixed-module projection

### Results supported

- All five locked modules showed expected-direction concordance in GSE73461.
- VIR_M1a and VIR_M1b showed strongest external transportability.
- BACT_M2 and VIR_M2 were robustly transported.
- BACT_M1 was directionally concordant but borderline.

### Methods that must be described

- Illumina probe-to-gene annotation.
- Probe/gene handling for scoring.
- Unweighted mean z-score module scoring.
- Primary DefiniteBacterial versus DefiniteViral comparison.
- Wilcoxon testing and BH adjustment.
- Reporting of median bacterial-minus-viral differences.

### Key scripts / outputs

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_projection_coverage.tsv`
- `docs/GSE73461_manuscript_projection_summary_table.md`
- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_A_module_score_distributions.pdf`

### Boundary

This is fixed-module external projection, not classifier training, model discovery or causal validation.

## Analysis stage 10 — Primary-only z-score sensitivity

### Results supported

- Main projection results were robust when Control samples were excluded from the z-score reference set.
- All five modules retained expected-direction concordance.
- BACT_M1 remained borderline.
- BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 remained robust.

### Methods that must be described

- Recalculation of gene-wise z-scores using only DefiniteBacterial and DefiniteViral samples.
- Recalculation of fixed-module scores.
- Same statistical contrast and BH correction as the main projection.
- Comparison of main and sensitivity results.

### Key scripts / outputs

- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_long.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_B_main_vs_sensitivity_median_differences.pdf`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.png`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.svg`
- `results/figures/GSE73461_manuscript_projection_panels/Figure_GSE73461_C_main_vs_sensitivity_pvalues.pdf`

### Boundary

Sensitivity analysis tests robustness to scoring reference set; it does not introduce new modules or validate causality.

## Manuscript Methods sections required

The manuscript Methods should include the following subsections:

1. Study design and discovery/projection firewall
2. Dataset selection and eligibility assessment
3. GSE211567 discovery cohort preparation and QC
4. Differential-expression modelling
5. Site-stratified concordance and site-aware feature stability
6. Transcript-to-gene mapping and GO enrichment
7. Conservative module review and locking
8. Projection-ready module scoring rules
9. External projection cohort selection and GSE73461 locking
10. GSE73461 identifier mapping and module coverage
11. Fixed-module projection scoring and statistical testing
12. Primary-only z-score sensitivity analysis
13. Reproducibility, software environment and figure export

## Global interpretation boundaries

- Do not describe modules as diagnostic classifiers.
- Do not describe projection as diagnostic model validation.
- Do not imply gene rediscovery in GSE73461.
- Do not rename or redefine modules using GSE73461.
- Do not claim causal mechanisms from transcriptomic module transportability.
- Do describe the work as a fixed-module transportability analysis of host-response programmes.
