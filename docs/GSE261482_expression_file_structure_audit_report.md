# GSE261482 Expression File Structure Audit Report

- Generated: 2026-05-31 17:05:06
- Purpose: inspect GSE261482 expression matrices and sample/metadata mapping feasibility.
- Boundary: expression-structure audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.

## Expression file structure summary

file_label                                                      file_path  size_bytes                                                           sha256 delimiter  n_feature_rows first_header_field  n_sample_columns  sample_columns_are_1_to_n first_10_sample_columns  n_preview_ids  n_ensembl_like  n_symbol_like  n_numeric_like                                                                                                                                                                                                                                                                                                                     example_ids
raw_counts data/expression_raw/GSE261482/GSE261482_Counts_raw_data.csv.gz     7078905 e679915d2bb2b1a948379422707e60903fd526c4cef73e735db09a6a04db971a         ;           58233     Sample number                177                       True    1;2;3;4;5;6;7;8;9;10           1000            1000           1000               0 ENSG00000223972;ENSG00000227232;ENSG00000278267;ENSG00000243485;ENSG00000284332;ENSG00000237613;ENSG00000268020;ENSG00000240361;ENSG00000186092;ENSG00000238009;ENSG00000239945;ENSG00000233750;ENSG00000268903;ENSG00000269981;ENSG00000239906;ENSG00000241860;ENSG00000222623;ENSG00000241599;ENSG00000279928;ENSG00000279457
normalized data/expression_raw/GSE261482/GSE261482_Normalized_data.csv.gz    35110835 4e929ddd5f2d92bd6084a3e88e965a73d02d4ca47b9d0b81bd510371bb10f62e         ;           40516             sample               177                       True    1;2;3;4;5;6;7;8;9;10           1000               0           1000               0                                                                                                                                                                                                         TSPAN6;TNMD;DPM1;SCYL3;C1orf112;FGR;CFH;FUCA2;GCLC;NFYA;STPG1;NIPAL3;LAS1L;ENPP4;SEMA3F;CFTR;ANKIB1;CYP51A1;KRIT1;RAD52

## Sample column consistency

                         comparison  n_counts_columns  n_normalized_columns  same_order  counts_are_1_to_177  normalized_are_1_to_177
counts_vs_normalized_sample_columns               177                   177        True                 True                     True

## Metadata-to-expression mapping field audit

metadata_source  n_rows  n_columns candidate_numeric_1_to_177_columns       geo_accession_columns                                 title_like_columns                    diagnosis_or_group_like_columns
           SOFT     177         39                                    sample_record;geo_accession sample_record;title;source_name_ch1;library_source characteristics_etiology;characteristics_condition
  series_matrix     177         31                                                  geo_accession               title;source_name_ch1;library_source                                                   

## Provisional sample keyword flag summary

 n_samples  bacterial_keyword_flag_n  viral_keyword_flag_n  control_keyword_flag_n
       177                       139                     0                      38

## Preliminary expression audit decision

candidate_dataset  expression_files_usable counts_feature_id_type normalized_feature_id_type  n_expression_samples  sample_column_consistent_between_files  bacterial_keyword_flag_n  viral_keyword_flag_n                     preliminary_expression_audit_status                                                                                                          reason                                                                                                                                 next_action
        GSE261482                     True                ENSEMBL                     SYMBOL                   177                                    True                       139                     0 not_ready_for_formal_bacterial_vs_viral_projection_lock Expression files are usable, but viral/pathogen-class metadata remains unresolved or absent in parsed metadata. Inspect GEO metadata fields manually and determine whether reliable pathogen-class labels can be recovered before any cohort-lock decision.

## Interpretation boundary

- Raw counts use ENSEMBL feature IDs and normalized data use SYMBOL-like feature IDs.
- Expression columns are numbered 1..177 and require reliable mapping to sample-level metadata before use.
- The current audit does not establish formal cohort eligibility because viral/pathogen-class metadata remains unresolved.
- Locked GSE211567 modules must not be scored in GSE261482 unless a formal cohort-lock decision is made.

## Generated files

- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_structure_summary.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_previews.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_sample_column_consistency.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_metadata_expression_mapping_field_audit.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_expression_sample_to_metadata_mapping.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_expression_sample_to_metadata_mapping_with_keyword_flags.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_sample_keyword_flag_summary.tsv`
- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_audit_decision.tsv`