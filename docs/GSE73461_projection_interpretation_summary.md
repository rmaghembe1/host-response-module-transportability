# GSE73461 Fixed-Module Projection Interpretation Summary

## Status

GSE73461 is locked as the formal external projection cohort for fixed GSE211567 discovery-module scoring. The main projection analysis and the primary-only z-score sensitivity analysis have both been completed and accepted.

## Primary projection contrast

- DefiniteBacterial: 52 samples
- DefiniteViral: 94 samples
- Control: 55 samples, retained only as secondary context in the main projection and excluded from the primary-only z-score sensitivity
- Excluded from primary projection contrast: Inflammatory, Kawasaki and Unknown groups

## Scoring rule

The main projection used the pre-specified unweighted mean z-score scoring rule after gene-wise z-scoring within the locked GSE73461 projection sample set. The primary-only sensitivity repeated scoring after gene-wise z-scoring using only DefiniteBacterial and DefiniteViral samples. Locked GSE211567 module genes were preserved without gene reselection, reweighting, renaming or diagnostic model training.

## Module-level interpretation

| Module | Discovery direction | Main GSE73461 result | Primary-only z-score sensitivity | Interpretation tier |
|---|---|---|---|---|
| BACT_M1 | Higher in bacterial | Direction matched; BH P = 0.0799 | Direction matched; BH P = 0.0778 | Directionally concordant but borderline |
| BACT_M2 | Higher in bacterial | Direction matched; BH P = 0.0202 | Direction matched; BH P = 0.0165 | Robustly externally transported |
| VIR_M1a | Higher in viral | Direction matched; BH P = 4.77e-06 | Direction matched; BH P = 7.57e-06 | Strongly and robustly externally transported |
| VIR_M1b | Higher in viral | Direction matched; BH P = 1.41e-06 | Direction matched; BH P = 2.22e-06 | Strongly and robustly externally transported |
| VIR_M2 | Higher in viral | Direction matched; BH P = 0.00848 | Direction matched; BH P = 0.00796 | Robustly externally transported |

## Conservative interpretation

The GSE73461 external projection supports transportability of the locked GSE211567 module architecture into an independent cohort. The strongest and most robust transported signals are the viral/interferon-related modules. The bacterial mitochondrial respiration/oxidative phosphorylation module also transported robustly. The bacterial cytoplasmic translation/ribosomal protein programme is directionally concordant in both analyses but remains statistically borderline and should be framed cautiously.

## Interpretation safeguards

- Do not describe this as diagnostic signature discovery.
- Do not describe this as model training.
- Do not claim causal validation.
- Do not reselect genes based on GSE73461.
- Do not rename modules based on GSE73461.
- Report GSE73461 as an external fixed-module projection cohort.
- Report BACT_M1 as directionally concordant but borderline, not as a strong transported module.

## Manuscript-ready boundary sentence

These findings support external transportability of pre-specified bacterial- and viral-associated host-response modules across an independent cohort, while preserving a strict discovery/projection firewall and avoiding diagnostic model rediscovery.
