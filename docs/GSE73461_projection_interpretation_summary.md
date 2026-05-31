# GSE73461 Fixed-Module Projection Interpretation Summary

## Status

GSE73461 has been locked as the formal external projection cohort for fixed GSE211567 discovery-module scoring. The fixed-module projection analysis has been completed and accepted as the formal external projection result.

## Primary projection contrast

- DefiniteBacterial: 52 samples
- DefiniteViral: 94 samples
- Control: 55 samples, retained only as secondary context
- Excluded from primary projection contrast: Inflammatory, Kawasaki and Unknown groups

## Scoring rule

Projection used the pre-specified unweighted mean z-score scoring rule after gene-wise z-scoring within GSE73461. Locked GSE211567 module genes were preserved without gene reselection, reweighting, renaming or diagnostic model training.

## Module-level interpretation

| Module | Discovery direction | GSE73461 result | Interpretation tier |
|---|---|---|---|
| BACT_M1 | Higher in bacterial | Direction matched; BH P = 0.0799 | Directionally concordant but borderline |
| BACT_M2 | Higher in bacterial | Direction matched; BH P = 0.0202 | Externally transported |
| VIR_M1a | Higher in viral | Direction matched; BH P = 4.77e-06 | Strongly externally transported |
| VIR_M1b | Higher in viral | Direction matched; BH P = 1.41e-06 | Strongly externally transported |
| VIR_M2 | Higher in viral | Direction matched; BH P = 0.00848 | Externally transported |

## Conservative interpretation

The external projection supports transportability of the locked GSE211567 module architecture into GSE73461. The strongest transportable signals are the viral/interferon-related modules and the bacterial mitochondrial respiration/oxidative phosphorylation module. The bacterial cytoplasmic translation/ribosomal protein programme is directionally concordant but statistically borderline and should be framed cautiously.

## Interpretation safeguards

- Do not describe this as diagnostic signature discovery.
- Do not describe this as model training.
- Do not claim causal validation.
- Do not reselect genes based on GSE73461.
- Do not rename modules based on GSE73461.
- Report GSE73461 as an external fixed-module projection cohort.

## Optional sensitivity checks before manuscript-style Results drafting

1. Repeat scoring using only the stricter 70% coverage-confirmed module genes.
2. Repeat scoring after excluding secondary control samples from the z-scoring reference set, using only DefiniteBacterial and DefiniteViral samples for within-dataset z-scoring.
3. Compare raw-matrix-derived versus normalized-matrix-derived scoring if technically justified.
4. Add rank-based effect size summaries, such as Cliff’s delta or rank-biserial correlation, to complement Wilcoxon P values.
5. Inspect whether BACT_M1 borderline behaviour is driven by a small subset of ribosomal genes or broad weak shift.

## Manuscript-ready boundary sentence

These findings support external transportability of pre-specified bacterial- and viral-associated host-response modules across an independent cohort, while preserving a strict discovery/projection firewall and avoiding diagnostic model rediscovery.
