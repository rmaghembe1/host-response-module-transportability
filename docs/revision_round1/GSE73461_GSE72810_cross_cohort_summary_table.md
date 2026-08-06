# Cross-cohort fixed-module projection summary

Primary bacterial-versus-viral Hodges-Lehmann shifts and bootstrap 95% confidence intervals are shown for GSE73461 and GSE72810. Positive values indicate bacterial-higher module scores; negative values indicate viral-higher scores.

| Module | Conservative module label | Discovery direction | Locked genes | GSE73461 genes scored | GSE73461 primary result | GSE73461 BH P | GSE72810 genes scored | GSE72810 primary result | GSE72810 BH P | Cross-cohort interpretation |
| --- | --- | --- | ---: | ---: | --- | ---: | ---: | --- | ---: | --- |
| BACT_M1 | Bacterial-higher cytoplasmic translation and ribosomal protein programme | higher_in_bacterial | 25 | 24 | +0.172 (95% CI -0.021 to +0.377) | 0.0799 | 24 | +0.266 (95% CI -0.024 to +0.722) | 0.0799 | Directionally concordant in both cohorts but statistically borderline, with confidence intervals including zero. |
| BACT_M2 | Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme | higher_in_bacterial | 21 | 21 | +0.271 (95% CI +0.057 to +0.475) | 0.0202 | 20 | +0.425 (95% CI +0.161 to +0.676) | 0.0020 | Expected-direction support with confidence intervals excluding zero in both cohorts. |
| VIR_M1a | Viral-higher broad antiviral and interferon-stimulated defence programme | higher_in_viral | 128 | 128 | -0.433 (95% CI -0.617 to -0.269) | 4.77e-06 | 125 | -0.726 (95% CI -0.907 to -0.577) | 7.16e-08 | Strong expected-direction support with confidence intervals excluding zero in both cohorts. |
| VIR_M1b | Viral-higher viral restriction and type I interferon signalling subgroup | higher_in_viral | 33 | 33 | -0.574 (95% CI -0.788 to -0.368) | 1.41e-06 | 33 | -0.941 (95% CI -1.201 to -0.752) | 8.77e-08 | Strong expected-direction support with confidence intervals excluding zero in both cohorts. |
| VIR_M2 | Viral-higher cytokine and innate immune regulation programme | higher_in_viral | 106 | 105 | -0.228 (95% CI -0.407 to -0.063) | 0.0085 | 101 | -0.576 (95% CI -0.682 to -0.475) | 8.77e-08 | Expected-direction support with confidence intervals excluding zero in both cohorts. |

## Notes

**Primary result:** Hodges-Lehmann bacterial-minus-viral module-score shift with bootstrap 95% confidence interval.

**GSE73461:** Formal external fixed-module projection cohort relative to GSE211567 discovery; GPL10558; 52 DefiniteBacterial and 94 DefiniteViral samples.

**GSE72810:** Second accession-level and deposited-sample-level cohort providing cross-platform validation; GPL6947; 23 definite bacterial and 28 definite viral samples.

**Independence boundary:** The GSE72810 and GSE73461 GSM accession sets were disjoint. Participant overlap could not be directly assessed, and the studies arose from the same broad investigator network.

**Abbreviations:** BH, Benjamini-Hochberg; CI, confidence interval; OXPHOS, oxidative phosphorylation.
