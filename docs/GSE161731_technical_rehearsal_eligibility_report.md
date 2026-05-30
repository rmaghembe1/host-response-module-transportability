# GSE161731 Technical-Rehearsal Eligibility Report

- Generated: 2026-05-30T11:58:36
- Purpose: define a metadata-derived sample subset for count-level RNA-seq workflow rehearsal only.
- Firewall statement: this subset must not be used to select, orient, reweight or validate discovery modules. It exists only to master count-level processing before GSE211567 discovery analysis.

## Classification rules

- `Bacterial` → `bacterial`, included in technical bacterial-versus-viral rehearsal.
- `Influenza` → `non_covid_viral`, included in technical rehearsal.
- `CoV other` → `non_covid_viral`, included in technical rehearsal as seasonal/non-SARS coronavirus.
- `COVID-19` → excluded from the primary non-COVID rehearsal contrast.
- `healthy` → retained for contextual QC/orientation only, not included in the bacterial-versus-viral rehearsal contrast.
- Count-matrix-only samples lacking metadata → excluded.
- Counts-key-only samples are provisionally retained if cohort and key metadata are adequate, but flagged.

## Count-matrix sample classification

- bacterial: 24
- covid_excluded_primary: 77
- exclude_missing_metadata: 3
- healthy_contextual: 19
- non_covid_viral: 78

## Inclusion-decision counts among count-matrix samples

- contextual_only: 19
- no: 80
- yes: 102

## Primary technical-rehearsal contrast size

- Total included primary non-COVID rehearsal samples: 102
- bacterial: 24
- non_covid_viral: 78

## Caution-flagged count-matrix samples

- Count-matrix samples with caution flags: 6
- 434482: group=non_covid_viral; cohort=CoV other; status=mapped_to_counts_key_only; flags=counts_key_only_not_in_sample_key
- 434741: group=non_covid_viral; cohort=CoV other; status=mapped_to_counts_key_only; flags=counts_key_only_not_in_sample_key
- 94478: group=bacterial; cohort=Bacterial; status=mapped_to_counts_key_only; flags=counts_key_only_not_in_sample_key
- DU09-02S0000150_batch2: group=exclude_missing_metadata; cohort=MISSING; status=count_matrix_only_unmapped; flags=unmapped_count_matrix_sample;missing_subject_id;missing_cohort
- DU09-02S0000154_batch2: group=exclude_missing_metadata; cohort=MISSING; status=count_matrix_only_unmapped; flags=unmapped_count_matrix_sample;missing_subject_id;missing_cohort
- DU09-02S0000158_batch2: group=exclude_missing_metadata; cohort=MISSING; status=count_matrix_only_unmapped; flags=unmapped_count_matrix_sample;missing_subject_id;missing_cohort

## Output

- `data/metadata_harmonized/GSE161731_technical_rehearsal_eligibility.tsv`

## Immediate interpretation

- GSE161731 has a metadata-derived non-COVID technical-rehearsal contrast of bacterial versus influenza/seasonal-coronavirus samples.
- Three count-matrix-only samples remain excluded because they lack metadata.
- Three counts-key-only samples are flagged; inclusion is acceptable for technical rehearsal if no additional contradiction appears, but this should be revisited before any formal external validation use.
- The next step is to commit this eligibility lock and then create the first count-level QC/voom rehearsal script using only this metadata-derived subset.
