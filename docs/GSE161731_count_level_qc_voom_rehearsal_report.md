# GSE161731 Count-Level QC/voom Technical Rehearsal Report

- Generated: 2026-05-30 22:36:39 EAT
- Purpose: technical workflow rehearsal only.
- Analytical firewall: this analysis must not influence GSE211567 discovery-module selection, module orientation, module weighting or biological interpretation.

## Rehearsal subset

- Total samples: 102
- Bacterial samples: 24
- Non-COVID viral samples: 78

## Gene filtering

- Genes before filtering: 60675
- Genes retained after `filterByExpr`: 20561
- Genes removed: 40114

## Outputs

- `results/qc/GSE161731_technical_rehearsal/GSE161731_sample_level_qc_summary.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_filtering_summary.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_TMM_normalization_factors.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_design_matrix.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_voom_PCA_coordinates.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_technical_rehearsal_voom_objects.rds`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_MDS_plot.png` and `.pdf`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_library_size_by_group.png` and `.pdf`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_detected_genes_by_group.png` and `.pdf`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_voom_PCA.png` and `.pdf`
- `env/session_info/GSE161731_count_level_qc_voom_rehearsal_sessionInfo.txt`

## Immediate interpretation boundary

- This script verifies count-level import, sample alignment, filtering, TMM normalization, voom transformation and QC plotting.
- It does not perform differential expression testing.
- It does not perform pathway enrichment.
- It does not define, orient, reweight or validate any biological module.
- Biological interpretation is intentionally deferred.
