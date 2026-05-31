# GSE211567 Locked Normalized-Matrix QC Report

- Generated: 2026-05-31 09:08:26 EAT
- Purpose: technical QC of the locked GSE211567 normalized discovery matrix before discovery modelling.
- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.

## Matrix integrity

- Features: 19999
- Locked samples: 290
- Non-finite values: 0
- NA values: 0
- Duplicate feature IDs: 0
- Duplicate sample IDs: 0
- Excluded unmatched sample present in QC subset: FALSE

## Locked sample structure

### Discovery groups
          discovery_group   n
1               bacterial 101
2 noninfection_contextual  66
3                   viral 123

### Site counts
           site   n
1     Sri_Lanka 141
2 United_States 149

### Sequencing batch counts
  sequencing_batch   n
1                1 182
2                2 108

### Site × discovery group counts
           site         discovery_group  n
1     Sri_Lanka               bacterial 60
2 United_States               bacterial 41
3     Sri_Lanka noninfection_contextual  0
4 United_States noninfection_contextual 66
5     Sri_Lanka                   viral 81
6 United_States                   viral 42

### Batch × discovery group counts
  sequencing_batch         discovery_group  n
1                1               bacterial 78
2                2               bacterial 23
3                1 noninfection_contextual 27
4                2 noninfection_contextual 39
5                1                   viral 77
6                2                   viral 46

## PCA variance explained

- PC1: 19.77%
- PC2: 10.82%
- PC3: 5.54%
- PC4: 5.28%

## Expression-summary outlier scan

- Mean-expression IQR lower threshold: -0.2864
- Mean-expression IQR upper threshold: 1.697
- SD-expression IQR lower threshold: 1.928
- SD-expression IQR upper threshold: 3.276
- Detected-feature IQR lower threshold: 8292
- Detected-feature IQR upper threshold: 16030
- Samples with any expression-summary outlier flag: 18

## Generated files

- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_matrix_integrity_summary.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_sample_level_expression_qc.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_sample_level_expression_qc_with_outlier_flags.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_expression_summary_outliers.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_PCA_coordinates.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_group_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_site_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_batch_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_site_by_group_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_batch_by_group_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_pathogen_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_PCA_by_discovery_group.png` and `.pdf`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_PCA_by_site.png` and `.pdf`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_PCA_by_batch.png` and `.pdf`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_MDS_by_group.png` and `.pdf`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_mean_expression_by_group.png` and `.pdf`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_locked_sd_expression_by_group.png` and `.pdf`
- `env/session_info/GSE211567_locked_normalized_matrix_qc_sessionInfo.txt`

## Boundary statement

- This QC stage verifies matrix/sample integrity and major technical structure only.
- It does not define biological modules.
- It does not test bacterial-versus-viral differential expression.
- It does not interpret host-response biology.
- Discovery modelling remains deferred until this QC is reviewed and committed.
