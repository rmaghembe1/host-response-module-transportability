# GSE261482 External Projection Candidate Feasibility Audit Report

- Generated: 2026-05-31 16:57:10
- Purpose: audit GSE261482 as a conditional formal external projection/generalizability candidate.
- Boundary: feasibility audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed here.

## Raw file audit

                                                               file  exists  size_bytes                                                           sha256
               data/metadata_raw/GSE261482/GSE261482_family.soft.gz    True       10452 cd051fafb27759840f2c62873a8c8169de8cf3d1c7801461cc939d2686587c15
         data/metadata_raw/GSE261482/GSE261482_series_matrix.txt.gz    True        8213 d73ddf065ea5f405239699454e6d2a78173c94ef77383380bd42135cc88c15bd
data/metadata_raw/GSE261482/GSE261482_supplementary_file_index.html    True         708 3b1abb8985b946f2e56d6f12e4c2cd2ce7293f155680c086fc113cf9705452ed

## Metadata summary

- Parseable GEO SOFT sample metadata: True
- Number of SOFT samples parsed: 177
- Series matrix sample metadata available: True
- Supplementary files indexed: 4

## Metadata keyword clues

               clue  sample_rows_matching_in_SOFT                                                                                    pattern
    bacterial_clues                           139 bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus
        viral_clues                             0  viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue
      control_clues                           177                                                       control|healthy|non.?infect|afebrile
blood_or_pbmc_clues                           177                                        whole blood|blood|pbmc|paxgene|leukocyte|peripheral
    pediatric_clues                           177                              child|children|pediatric|paediatric|infant|neonate|adolescent
      rna_seq_clues                           177              rna-seq|rnaseq|high throughput sequencing|next generation sequencing|illumina
   microarray_clues                             0                                                 array|microarray|affymetrix|illumina human

## Supplementary file type hints

supplementary_file_type_hint  n_files                                                      example_files
        matrix_or_expression        2 GSE261482_Counts_raw_data.csv.gz; GSE261482_Normalized_data.csv.gz
                    metadata        0                                                                   
            raw_or_fastq_sra        1                                   GSE261482_Counts_raw_data.csv.gz
                  compressed        2 GSE261482_Counts_raw_data.csv.gz; GSE261482_Normalized_data.csv.gz

## Preliminary decision

candidate_dataset                       candidate_role  n_soft_samples  series_matrix_metadata_available  n_supplementary_files_indexed  bacterial_metadata_clue_rows  viral_metadata_clue_rows  blood_or_pbmc_clue_rows  pediatric_clue_rows                                             preliminary_status                                                                                                                next_action
        GSE261482 pediatric_generalizability_candidate             177                              True                              4                           139                         0                      177                  177 conditional_or_exclude_pathogen_class_labels_not_yet_confirmed Inspect supplementary expression files and harmonize sample-level pathogen-class metadata before any cohort-lock decision.

## Interpretation boundary

- This audit does not lock GSE261482 as a formal projection cohort.
- This audit does not score locked GSE211567 modules.
- A cohort-lock decision requires explicit confirmation of expression matrix availability, identifier type, sample-level pathogen-class metadata and projection suitability.

## Generated files

- `data/metadata_harmonized/GSE261482_GEO_family_SOFT_sample_metadata_flattened.tsv`
- `data/metadata_harmonized/GSE261482_series_matrix_sample_metadata.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_raw_file_audit.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_metadata_field_presence.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_metadata_keyword_clue_summary.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_supplementary_file_index.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_supplementary_file_type_hints.tsv`
- `results/external_projection_candidate_audit/GSE261482/GSE261482_preliminary_external_projection_candidate_decision.tsv`