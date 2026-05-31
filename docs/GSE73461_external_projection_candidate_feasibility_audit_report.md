# GSE73461 External Projection Candidate Feasibility Audit Report

- Generated: 2026-05-31 19:10:34
- Purpose: audit GSE73461 as a candidate formal external projection cohort.
- Boundary: feasibility audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.

## Raw file audit

                                                             file  exists  size_bytes                                                           sha256
               data/metadata_raw/GSE73461/GSE73461_family.soft.gz    True   250258884 c9984a6b40ded0cc8f5b589d69eb4ea62f542dbdba74bfa8aa3a488e8972bc11
         data/metadata_raw/GSE73461/GSE73461_series_matrix.txt.gz    True    93539070 e1f00c95279d9aa927293d1fa1cea580895ef6d6a829caa89c4b451bf5b17551
data/metadata_raw/GSE73461/GSE73461_supplementary_file_index.html    True        1157 8242d0f276527b0cb395e9b02068628fdab0301b231122c6311261bf56407e48

## Metadata summary

- Number of SOFT samples parsed: 459
- Series matrix sample metadata available: True
- Supplementary files indexed: 6

## Metadata keyword clues

                         clue  sample_rows_matching_in_SOFT                                                                                                                  pattern
              bacterial_clues                           148 bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus|gram.?positive|gram.?negative
                  viral_clues                           190                           viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue|h1n1
                control_clues                            55                                                                                     control|healthy|non.?infect|afebrile
          blood_or_pbmc_clues                           459                                                                      whole blood|blood|pbmc|paxgene|leukocyte|peripheral
 respiratory_or_febrile_clues                             0                                                              respiratory|fever|febrile|acute infection|illness|pneumonia
             microarray_clues                             0                                                                               array|microarray|affymetrix|illumina human
                rna_seq_clues                             0                                                     rna-seq|rnaseq|high throughput sequencing|next generation sequencing
discovery_or_validation_clues                           459                                                                                discovery|validation|training|test|cohort

## Supplementary file type hints

supplementary_file_type_hint  n_files                                                                                                                                         example_files
        matrix_or_expression        3 GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz; GSE73461_GEOupload_Discovery_Dataset_Raw_Sept_15_n_459.txt.gz; GSE73461_RAW.tar
                    metadata        0                                                                                                                                                      
                 raw_archive        1                                                                                                                                      GSE73461_RAW.tar
                  compressed        3 GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz; GSE73461_GEOupload_Discovery_Dataset_Raw_Sept_15_n_459.txt.gz; GSE73461_RAW.tar

## Preliminary decision

candidate_dataset                       candidate_role  n_soft_samples  series_matrix_metadata_available  n_supplementary_files_indexed  bacterial_metadata_clue_rows  viral_metadata_clue_rows  control_metadata_clue_rows  blood_or_pbmc_clue_rows                                          preliminary_status                                                                                         next_action
         GSE73461 formal_external_projection_candidate             459                              True                              6                           148                       190                          55                      459 conditional_candidate_for_deeper_expression_and_label_audit Inspect phenotype fields and processed expression matrix structure before any cohort-lock decision.

## Interpretation boundary

- This audit does not lock GSE73461 as a formal projection cohort.
- This audit does not score locked GSE211567 modules.
- A cohort-lock decision requires expression availability, identifier type, sample-level bacterial/viral labels and independence confirmation.

## Generated files

- `data/metadata_harmonized/GSE73461_GEO_family_SOFT_sample_metadata_flattened.tsv`
- `data/metadata_harmonized/GSE73461_series_matrix_sample_metadata.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_raw_file_audit.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_metadata_field_presence.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_metadata_keyword_clue_summary.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_supplementary_file_index.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_supplementary_file_type_hints.tsv`
- `results/external_projection_candidate_audit/GSE73461/GSE73461_preliminary_external_projection_candidate_decision.tsv`