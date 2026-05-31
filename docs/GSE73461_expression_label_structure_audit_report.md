# GSE73461 Expression and Label Structure Audit Report

- Generated: 2026-05-31 19:51:50
- Purpose: inspect GSE73461 processed raw and normalized expression files for formal projection readiness.
- Boundary: expression/label audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.

## Expression file structure summary

file_label                                                                                         file_path  size_bytes                                                           sha256  n_feature_rows  n_header_columns_total  n_identifier_columns_assumed  n_expression_sample_columns  n_detection_pval_columns  expression_detection_pairs_complete  n_expression_without_detection  n_detection_without_expression  n_preview_ids  first_col_ilmn_like_n  first_col_numeric_like_n  second_col_numeric_like_n                                                                                                             example_first_col_ids                                                                     example_second_col_ids
normalized data/expression_raw/GSE73461/GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz   143582247 af0a63c2e6e408ec9acd17fc87db9fac016673962aa7907d19d155339b4e759b           47323                     919                             1                          459                       459                                 True                               0                               0           1000                      0                      1000                          0                                                   6450255;2570615;6370619;2600039;2650615;5340672;2000519;3870044;7050209;1580181 1.056382;35.20401;3.072594;-6.239761;13.09677;-3.6856;-2.164848;-28.5632;-6.644271;2.91282
       raw        data/expression_raw/GSE73461/GSE73461_GEOupload_Discovery_Dataset_Raw_Sept_15_n_459.txt.gz   138797790 015028c1853dd1fdefc1c6abbb47e40be2dfe7b0b757e6a0c681036ad77495b6           47323                     920                             2                          459                       459                                 True                               0                               0           1000                   1000                         0                       1000 ILMN_1762337;ILMN_2055271;ILMN_1736007;ILMN_2383229;ILMN_1806310;ILMN_1779670;ILMN_1653355;ILMN_1717783;ILMN_1705025;ILMN_1814316            6450255;2570615;6370619;2600039;2650615;5340672;2000519;3870044;7050209;1580181

## Expression sample group counts

file_label      sample_group  n_expression_samples
normalized           Control                    55
normalized DefiniteBacterial                    52
normalized     DefiniteViral                    94
normalized      Inflammatory                    84
normalized          Kawasaki                    78
normalized           Unknown                    96
       raw           Control                    55
       raw DefiniteBacterial                    52
       raw     DefiniteViral                    94
       raw      Inflammatory                    84
       raw          Kawasaki                    78
       raw           Unknown                    96

## Normalized/raw sample consistency

 n_normalized_expression_samples  n_raw_expression_samples  same_sample_set_normalized_and_raw  n_in_normalized_not_raw  n_in_raw_not_normalized
                             459                       459                                True                        0                        0

## Candidate primary projection group counts

                projection_role      sample_group  n_samples
exclude_from_primary_projection      Inflammatory         84
exclude_from_primary_projection          Kawasaki         78
exclude_from_primary_projection           Unknown         96
              primary_bacterial DefiniteBacterial         52
                  primary_viral     DefiniteViral         94
      secondary_control_context           Control         55

## Preliminary expression-label audit decision

candidate_dataset  expression_files_usable  normalized_and_raw_same_sample_set  n_primary_bacterial_samples  n_primary_viral_samples  n_secondary_control_samples                                       preliminary_expression_label_status                                                                                                              reason                                                                                              next_action
         GSE73461                     True                                True                           52                       94                           55 strong_candidate_for_formal_cohort_lock_pending_identifier_coverage_audit Expression files contain sizeable DefiniteBacterial and DefiniteViral groups with paired detection-p-value columns. Audit feature annotation/identifier mapping and locked-module gene coverage before cohort-lock decision.

## Interpretation boundary

- GSE73461 is not yet locked as a formal projection cohort.
- The current audit supports deeper identifier-coverage assessment because DefiniteBacterial and DefiniteViral groups are present.
- Locked GSE211567 modules must not be scored until identifier coverage is confirmed and a separate cohort-lock decision is made.

## Generated files

- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_file_structure_summary.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_sample_group_counts.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_sample_columns_long.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_normalized_raw_sample_consistency.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_sample_table.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_group_counts.tsv`
- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_label_audit_decision.tsv`