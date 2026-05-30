# Level-2 Matrix and Metadata Content Audit

- Generated: 2026-05-30T10:17:33
- Purpose: structural file inspection only; no biological modelling or module selection.
- Boundary: GSE211567 remains discovery; GSE161731 is only technical/count-level rehearsal until modules are frozen; GSE261482 remains exploratory; GSE282464 remains conditional and undownloaded.

## File inventory

| Accession | Role | File | Size bytes | Delimiter | Data rows | Columns | First column |
|---|---|---|---:|---|---:|---:|---|
| GSE211567 | discovery_normalized_matrix | `GSE211567_normData_discovery_2021MAR24.txt.gz` | 48276900 | `\t` | 19999 | 292 | `` |
| GSE161731 | adult_count_matrix | `GSE161731_counts.csv.gz` | 8347405 | `,` | 60675 | 202 | `` |
| GSE161731 | adult_counts_key | `GSE161731_counts_key.csv.gz` | 2443 | `,` | 198 | 9 | `rna_id` |
| GSE161731 | adult_sample_key | `GSE161731_key.csv.gz` | 2398 | `,` | 195 | 9 | `rna_id` |
| GSE261482 | pediatric_count_matrix | `GSE261482_Counts_raw_data.csv.gz` | 7078905 | `;` | 58233 | 178 | `Sample number ` |

## Header previews

### GSE211567_normData_discovery_2021MAR24.txt.gz

- First header fields: `, DU16-02S0004801, DU14-03S0000021, DU16-02S0004851, DU10-01S0000004, DU09-03S0000020, DU09-03S0000018, DU16-02S0004883, DU09-03S0000030, DU16-02S0004790, DU09-03S0000031, DU10-01S0000025, DU09-03S0000040, DU10-01S0000020, DU16-02S0004787, DU09-03S0000037, DU16-02S0004805, DU10-01S0000027, DU09-03S0000029, DU16-02S0004847, ... [total 292]`
- First preview rows, first fields only:

  - `NM_001353689, -1.17016413007349, -5.00008623701064, 0.00893703687380809, 0.901532351659084, -1.15175912638238, -0.924109314218048, -1.32496746247363`
  - `NM_001286458, 4.74517305164694, 5.33043596201068, 5.15252828089679, 3.52681412510252, 2.07365613682564, 1.84483025899836, 2.6581756276835`
  - `NM_001323969, 2.99244386061104, 2.28222277180755, 1.76196060473205, 0.736374902390003, 1.71313516950099, 3.2889471595797, 1.35588067461432`
  - `NM_001303059, 4.35230216667883, 3.37339571923722, 3.09468270110781, 1.86157247613743, 3.06082967031021, 3.04814575218571, 3.29399785370117`
  - `NM_001286830, 3.03161062696871, 0.820535404421838, 0.0280187632483375, 0.921863110944772, 2.3647063015027, 1.90935631016622, 1.52603868825496`

### GSE161731_counts.csv.gz

- First header fields: `, 94189, DU09-03S0000604, DU09-03S0000611, 105920, DU09-03S0000774, DU09-03S0000775, DU09-03S19478, DU14-03S0000878, DU14-03S0000889, DU18-02S0011619, DU18-02S0011620, DU18-02S0011621, DU18-02S0011622, DU18-02S0011626, DU18-02S0011624, DU18-02S0011625, DU18-02S0011623, DU18-02S0011603, DU18-02S0011605, ... [total 202]`
- First preview rows, first fields only:

  - `ENSG00000223972, 0, 0, 3, 49, 6, 46, 35`
  - `ENSG00000227232, 393, 142, 152, 246, 586, 570, 213`
  - `ENSG00000278267, 0, 22, 29, 44, 104, 69, 58`
  - `ENSG00000243485, 0, 0, 0, 0, 1, 1, 0`
  - `ENSG00000274890, 0, 0, 0, 0, 0, 0, 0`

### GSE161731_counts_key.csv.gz

- First header fields: `rna_id, subject_id, age, gender, race, cohort, time_since_onset, hospitalized, batch`
- First preview rows, first fields only:

  - `94189, A1BD46, 57, Female, Black/African American, Bacterial, NA, NA`
  - `DU09-03S0000604, 44DF6B, 19, Male, Black/African American, Influenza, NA, NA`
  - `DU09-03S0000611, 658A11, 14, Male, White, Influenza, NA, NA`
  - `105920, 61DE97, 21, Female, White, Influenza, NA, NA`
  - `DU09-03S0000774, 4D4F7C, 50, Female, Black/African American, Influenza, NA, NA`

### GSE161731_key.csv.gz

- First header fields: `rna_id, subject_id, age, gender, race, cohort, time_since_onset, hospitalized, batch`
- First preview rows, first fields only:

  - `94189, A1BD46, 57, Female, Black/African American, Bacterial, NA, NA`
  - `DU09-03S0000604, 44DF6B, 19, Male, Black/African American, Influenza, NA, NA`
  - `DU09-03S0000611, 658A11, 14, Male, White, Influenza, NA, NA`
  - `105920, 61DE97, 21, Female, White, Influenza, NA, NA`
  - `DU09-03S0000774, 4D4F7C, 50, Female, Black/African American, Influenza, NA, NA`

### GSE261482_Counts_raw_data.csv.gz

- First header fields: `Sample number , 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, ... [total 178]`
- First preview rows, first fields only:

  - `ENSG00000223972, 0, 1, 0, 0, 1, 1, 0`
  - `ENSG00000227232, 34, 38, 17, 19, 25, 12, 17`
  - `ENSG00000278267, 1, 3, 2, 0, 1, 2, 2`
  - `ENSG00000243485, 0, 0, 0, 0, 0, 0, 0`
  - `ENSG00000284332, 0, 0, 0, 0, 0, 0, 0`

## GSE161731 matrix/key compatibility inspection

- GSE161731 count-matrix total columns: 202
- GSE161731 count-matrix sample columns after first identifier column: 201
- GSE161731 count-matrix first identifier column: ``
- GSE161731 counts-key columns: rna_id, subject_id, age, gender, race, cohort, time_since_onset, hospitalized, batch
- GSE161731 counts-key rows: 198
- GSE161731 sample-key columns: rna_id, subject_id, age, gender, race, cohort, time_since_onset, hospitalized, batch
- GSE161731 sample-key rows: 195
- Count sample IDs found anywhere in counts-key cells: 198
- Count sample IDs found anywhere in sample-key cells: 195

## Immediate interpretation

- This audit confirms structural readability only.
- Sample eligibility, infection-class reconstruction, repeated-sample handling and contrast locking must be performed next.
- No differential expression, enrichment, module selection or transportability interpretation has been performed.
