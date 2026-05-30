# GSE161731 Sample-ID Reconciliation Report

- Generated: 2026-05-30T11:31:12
- Purpose: metadata/sample-ID reconciliation before any count-level modelling.
- Analytical boundary: this report does not perform differential expression, pathway analysis, module selection or transportability testing.

## Source structures

- Count matrix sample columns after first identifier column: 201
- `GSE161731_counts_key.csv.gz` metadata rows: 198
- `GSE161731_key.csv.gz` metadata rows: 195
- Unique RNA IDs across all three sources: 201

## Mapping status across all observed RNA IDs

- count_matrix_only_unmapped: 3
- mapped_to_counts_key_only: 3
- mapped_to_sample_key: 195

## Unmatched set sizes

- Count-matrix sample IDs absent from counts-key: 3
- Count-matrix sample IDs absent from sample-key: 6
- Counts-key RNA IDs absent from count matrix: 0
- Sample-key RNA IDs absent from count matrix: 0
- Counts-key RNA IDs absent from sample-key: 3
- Sample-key RNA IDs absent from counts-key: 0

## Cohort labels among count-matrix samples after metadata merging

- Bacterial: 24
- COVID-19: 77
- CoV other: 61
- Influenza: 17
- MISSING: 3
- healthy: 19

## Preliminary broad group counts among count-matrix samples

- bacterial: 24
- covid_excluded_primary: 77
- healthy_contextual: 19
- missing_metadata: 3
- non_covid_viral: 17
- other_or_unclear: 61

## Repeated-subject preliminary inspection

- Subjects with more than one count-matrix sample: 24
- 0B943B: 3 samples (DU18-02S0011603,DU18-02S0011605,DU18-02S0011623)
- 0D76FC: 3 samples (DU18-02S0011606,DU18-02S0011617,DU18-02S0011630)
- 0E1F8E: 3 samples (DU18-02S0011610,DU18-02S0011655,DU18-02S0011661)
- 180E1A: 3 samples (DU18-02S0011607,DU18-02S0011658,DU18-02S0011678)
- 1A9B20: 3 samples (DU18-02S0011635,DU18-02S0011673,DU18-02S0011674)
- 2096A5: 2 samples (DU14-02S0000003,DU14-02S0000004)
- 318281: 3 samples (DU18-02S0011609,DU18-02S0011616,DU18-02S0011628)
- 35D90D: 3 samples (DU18-02S0011644,DU18-02S0011659,DU18-02S0011663)
- 450905: 7 samples (DU18-02S0011619,DU18-02S0011620,DU18-02S0011621,DU18-02S0011622,DU18-02S0011624,DU18-02S0011625,DU18-02S0011626)
- 45FBA5: 2 samples (DU18-02S0011618,DU18-02S0011669)
- 693EE8: 2 samples (234376,234377)
- 6ED61C: 3 samples (434557,434567,434570)
- 7085CA: 3 samples (DU18-02S0011627,DU18-02S0011671,DU18-02S0011672)
- 7190A0: 3 samples (DU14-02S0000005,DU14-02S0000006,DU14-02S0000008)
- 82CCF5: 3 samples (DU18-02S0011608,DU18-02S0011657,DU18-02S0011680)
- A34BBC: 2 samples (234326,DU09-02S0000105)
- C90C79: 3 samples (DU18-02S0011604,DU18-02S0011632,DU18-02S0011656)
- CEFC9F: 2 samples (434735,434757)
- DFC78E: 2 samples (DU14-02S0000007,DU14-02S0000009)
- E2CEAC: 2 samples (234435,DU09-02S0000145)
- Additional repeated subjects not shown: 4

## Generated files

- `data/metadata_harmonized/GSE161731_sample_id_reconciliation.tsv`
- `data/metadata_harmonized/GSE161731_unmatched_or_incompletely_mapped_ids.tsv`
- `data/metadata_harmonized/GSE161731_repeated_subjects_preliminary.tsv`

## Immediate interpretation

- Samples mapped only to `counts_key` or only to the count matrix require review before eligibility locking.
- The preliminary non-COVID bacterial-versus-viral subset is metadata-derived only and must not be used to select biological modules.
- The next step is to inspect unmatched IDs and cohort distributions, then write a formal contrast-lock decision for technical workflow rehearsal.
