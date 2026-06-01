# Supplementary Table S5. GSE73461 projection statistics and sensitivity results

This supplementary table set provides the full statistical outputs supporting the fixed-module external projection analysis in GSE73461 and the primary-only z-score sensitivity analysis.

## Source files

- Primary projection tests: `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- Primary-only z-score sensitivity tests: `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`
- Manuscript projection summary table: `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

## Generated supplementary TSV files

- `results/supplementary_tables/Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv` — 5 rows × 14 columns
- `results/supplementary_tables/Supplementary_Table_S5B_GSE73461_primary_only_zscore_sensitivity_tests.tsv` — 5 rows × 14 columns
- `results/supplementary_tables/Supplementary_Table_S5C_GSE73461_manuscript_projection_summary.tsv` — 5 rows × 12 columns

## Primary projection tests preview

| supplementary_table_section | final_module_id | final_module_label | final_module_direction | n_bacterial | n_viral | mean_bacterial | mean_viral | median_bacterial | median_viral | median_difference_bacterial_minus_viral | wilcox_p | wilcox_p_BH | expected_direction_match |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S5A_primary_projection_tests | BACT_M1 | Bacterial-higher cytoplasmic translation and ribosomal protein programme | higher_in_bacterial | 52 | 94 | 0.0921757900002996 | -0.0654060472890546 | -0.0512099069297803 | -0.257923917899844 | 0.206714010970064 | 0.0799243564652853 | 0.0799243564652853 | True |
| S5A_primary_projection_tests | BACT_M2 | Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme | higher_in_bacterial | 52 | 94 | 0.208899367239193 | -0.0141779661485658 | 0.241090687872253 | -0.0917458119629794 | 0.332836499835232 | 0.0161730187854322 | 0.0202162734817903 | True |
| S5A_primary_projection_tests | VIR_M1a | Viral-higher broad antiviral and interferon-stimulated defence programme | higher_in_viral | 52 | 94 | -0.246550746041787 | 0.233626632696282 | -0.295749009701834 | 0.167198442572938 | -0.462947452274773 | 1.90756029587882e-06 | 4.76890073969705e-06 | True |
| S5A_primary_projection_tests | VIR_M1b | Viral-higher viral restriction and type I interferon signalling subgroup | higher_in_viral | 52 | 94 | -0.26956497367652 | 0.340436467764166 | -0.375413651876157 | 0.298485202161975 | -0.673898854038133 | 2.82349820628983e-07 | 1.41174910314491e-06 | True |
| S5A_primary_projection_tests | VIR_M2 | Viral-higher cytokine and innate immune regulation programme | higher_in_viral | 52 | 94 | -0.17144790813375 | 0.0908367815252405 | -0.220858728537747 | 0.038698374091173 | -0.25955710262892 | 0.0050882738500871 | 0.0084804564168119 | True |

## Primary-only z-score sensitivity preview

| supplementary_table_section | final_module_id | final_module_label | final_module_direction | n_bacterial | n_viral | mean_bacterial | mean_viral | median_bacterial | median_viral | median_difference_bacterial_minus_viral | wilcox_p | wilcox_p_BH | expected_direction_match |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S5B_primary_only_zscore_sensitivity | BACT_M1 | Bacterial-higher cytoplasmic translation and ribosomal protein programme | higher_in_bacterial | 52 | 94 | 0.10767001504321 | -0.05956213598135 | -0.0450663457424796 | -0.266116456290355 | 0.221050110547876 | 0.077835567767349 | 0.077835567767349 | True |
| S5B_primary_only_zscore_sensitivity | BACT_M2 | Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme | higher_in_bacterial | 52 | 94 | 0.14301656558463 | -0.0791155469191572 | 0.185092537524498 | -0.165284323900502 | 0.350376861425001 | 0.0131918722289065 | 0.0164898402861331 | True |
| S5B_primary_only_zscore_sensitivity | VIR_M1a | Viral-higher broad antiviral and interferon-stimulated defence programme | higher_in_viral | 52 | 94 | -0.291021792650443 | 0.160990778913011 | -0.342404685772091 | 0.101739839776447 | -0.444144525548538 | 3.02690096568566e-06 | 7.56725241421415e-06 | True |
| S5B_primary_only_zscore_sensitivity | VIR_M1b | Viral-higher viral restriction and type I interferon signalling subgroup | higher_in_viral | 52 | 94 | -0.370855863642177 | 0.205154307546736 | -0.472668589939535 | 0.171795175529683 | -0.644463765469218 | 4.44027783010254e-07 | 2.22013891505127e-06 | True |
| S5B_primary_only_zscore_sensitivity | VIR_M2 | Viral-higher cytokine and innate immune regulation programme | higher_in_viral | 52 | 94 | -0.166997474876352 | 0.0923815818464926 | -0.219640485336016 | 0.0429345342601169 | -0.262575019596133 | 0.0047751262039251 | 0.0079585436732085 | True |

## Manuscript projection summary preview

| supplementary_table_section | Module | Conservative module label | Discovery direction | Locked genes | Genes scored in GSE73461 | Main projection result | Primary-only z-score sensitivity result | Expected direction in main analysis | Expected direction in sensitivity | Interpretation tier | Missing genes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| S5C_manuscript_projection_summary | BACT_M1 | Bacterial-higher cytoplasmic translation and ribosomal protein programme | Higher in bacterial | 25 | 24 | +0.2067; BH P = 0.0799 | +0.2211; BH P = 0.0778 | True | True | Directionally concordant but borderline | HYDIN2 |
| S5C_manuscript_projection_summary | BACT_M2 | Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme | Higher in bacterial | 21 | 21 | +0.3328; BH P = 0.0202 | +0.3504; BH P = 0.0165 | True | True | Robustly externally transported | nan |
| S5C_manuscript_projection_summary | VIR_M1a | Viral-higher broad antiviral and interferon-stimulated defence programme | Higher in viral | 128 | 128 | -0.4629; BH P = 4.77e-06 | -0.4441; BH P = 7.57e-06 | True | True | Strongly and robustly externally transported | nan |
| S5C_manuscript_projection_summary | VIR_M1b | Viral-higher viral restriction and type I interferon signalling subgroup | Higher in viral | 33 | 33 | -0.6739; BH P = 1.41e-06 | -0.6445; BH P = 2.22e-06 | True | True | Strongly and robustly externally transported | nan |
| S5C_manuscript_projection_summary | VIR_M2 | Viral-higher cytokine and innate immune regulation programme | Higher in viral | 106 | 105 | -0.2596; BH P = 0.00848 | -0.2626; BH P = 0.00796 | True | True | Robustly externally transported | BTN2A3P |

## Interpretation boundary

These statistical outputs support fixed-module transportability analysis. They should not be interpreted as diagnostic accuracy metrics, diagnostic model validation results or causal pathway validation.
