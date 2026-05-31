# GSE68310 External Projection Candidate Feasibility Audit Report

- Generated: 2026-05-31 18:30:57
- Purpose: audit GSE68310 as a candidate formal external projection cohort.
- Boundary: feasibility audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.

## Raw file audit

                                                             file  exists  size_bytes                                                           sha256
               data/metadata_raw/GSE68310/GSE68310_family.soft.gz    True   404592570 ab029717684216c58b030a859a9231b6bba964efb89aa67bf732a0e572146a58
         data/metadata_raw/GSE68310/GSE68310_series_matrix.txt.gz    True   204934272 3ba7898be1c6c279fb2779b1e7bf99b887374fccf4221a0c7bcb7b2cfae312de
data/metadata_raw/GSE68310/GSE68310_supplementary_file_index.html    True         888 d66fef99db20de46819b5f2d2ba42cc95295d34ed7bf9ea71694c80f7276bea7

## Metadata summary

- Number of SOFT samples parsed: 880
- Series matrix sample metadata available: True
- Supplementary files indexed: 6

## Metadata keyword clues

                        clue  sample_rows_matching_in_SOFT                                                                                    pattern
             bacterial_clues                             0 bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus
                 viral_clues                           880  viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue
               control_clues                           880                                                       control|healthy|non.?infect|afebrile
         blood_or_pbmc_clues                           880                                        whole blood|blood|pbmc|paxgene|leukocyte|peripheral
respiratory_or_febrile_clues                            27                                          respiratory|fever|febrile|acute infection|illness
            microarray_clues                             0                                                 array|microarray|affymetrix|illumina human
               rna_seq_clues                             0                       rna-seq|rnaseq|high throughput sequencing|next generation sequencing

## Supplementary file type hints

supplementary_file_type_hint  n_files                                                                        example_files
        matrix_or_expression        2                       /geo/series/GSE68nnn/GSE68310/; GSE68310_non-normalized.txt.gz
                    metadata        1                                                   GSE68310_SubjectPhenotypes1.txt.gz
            raw_or_fastq_sra        1                                                                     GSE68310_RAW.tar
                  compressed        3 GSE68310_RAW.tar; GSE68310_SubjectPhenotypes1.txt.gz; GSE68310_non-normalized.txt.gz

## Preliminary decision

candidate_dataset                       candidate_role  n_soft_samples  series_matrix_metadata_available  n_supplementary_files_indexed  bacterial_metadata_clue_rows  viral_metadata_clue_rows  blood_or_pbmc_clue_rows                               preliminary_status                                                                               next_action
         GSE68310 formal_external_projection_candidate             880                              True                              6                             0                       880                      880 not_ready_until_bacterial_viral_labels_confirmed Inspect phenotype fields and expression matrix structure before any cohort-lock decision.

## Interpretation boundary

- This audit does not lock GSE68310 as a formal projection cohort.
- This audit does not score locked GSE211567 modules.
- A cohort-lock decision requires expression availability, identifier type, sample-level bacterial/viral labels and independence confirmation.

## Generated files

- `data/metadata_harmonized/GSE68310_GEO_family_SOFT_sample_metadata_flattened.tsv`
- `data/metadata_harmonized/GSE68310_series_matrix_sample_metadata.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_raw_file_audit.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_metadata_field_presence.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_metadata_keyword_clue_summary.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_supplementary_file_index.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_supplementary_file_type_hints.tsv`
- `results/external_projection_candidate_audit/GSE68310/GSE68310_preliminary_external_projection_candidate_decision.tsv`