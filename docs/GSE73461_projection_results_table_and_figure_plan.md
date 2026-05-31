# GSE73461 External Projection — Results Table and Figure Plan

## Purpose

This document defines the manuscript-facing table and figure plan for the GSE73461 fixed-module external projection analysis.

## Recommended main Results table

### Table X. External projection of locked GSE211567 modules in GSE73461

Recommended columns:

1. Module ID
2. Conservative module label
3. Discovery direction
4. Locked genes
5. Genes scored in GSE73461
6. Main projection median difference, bacterial minus viral
7. Main projection BH-adjusted Wilcoxon P value
8. Primary-only z-score sensitivity median difference
9. Primary-only z-score sensitivity BH-adjusted Wilcoxon P value
10. Interpretation tier

Recommended rows:

| Module | Label | Discovery direction | Main result | Sensitivity result | Interpretation |
|---|---|---|---|---|---|
| BACT_M1 | Cytoplasmic translation/ribosomal protein programme | Higher in bacterial | +0.2067; BH P = 0.0799 | +0.2211; BH P = 0.0778 | Directionally concordant but borderline |
| BACT_M2 | Mitochondrial respiration/OXPHOS programme | Higher in bacterial | +0.3328; BH P = 0.0202 | +0.3504; BH P = 0.0165 | Robustly externally transported |
| VIR_M1a | Broad antiviral/interferon-stimulated defence programme | Higher in viral | −0.4629; BH P = 4.77e-06 | −0.4441; BH P = 7.57e-06 | Strongly and robustly externally transported |
| VIR_M1b | Viral restriction/type I interferon signalling subgroup | Higher in viral | −0.6739; BH P = 1.41e-06 | −0.6445; BH P = 2.22e-06 | Strongly and robustly externally transported |
| VIR_M2 | Cytokine/innate immune regulation programme | Higher in viral | −0.2596; BH P = 0.00848 | −0.2626; BH P = 0.00796 | Robustly externally transported |

## Recommended main figure

### Figure X. External projection of locked host-response modules in GSE73461

Recommended panels:

- Panel A: Workflow schematic showing discovery in GSE211567, module locking, GSE73461 cohort lock and fixed-module projection.
- Panel B: Box/violin/point plot of module scores in DefiniteBacterial versus DefiniteViral groups for all five modules.
- Panel C: Bar plot of median bacterial-minus-viral differences by module, with positive values indicating bacterial-higher and negative values indicating viral-higher.
- Panel D: Sensitivity comparison showing main versus primary-only z-score median differences.

## Recommended supplementary figure

### Supplementary Figure X. Identifier coverage and projection robustness

Recommended panels:

- Panel A: Locked gene coverage by module in GSE73461.
- Panel B: Main projection versus primary-only z-score sensitivity BH-adjusted P values.
- Panel C: Gene-probe collapse workflow for Illumina probe-to-gene scoring.

## Recommended supplementary table

### Supplementary Table X. Locked module genes scored in GSE73461

Recommended content:

- Module ID
- Module label
- Gene symbol
- Entrez ID
- Probe/array ID used for scoring
- Whether gene was matched or missing
- Missing genes: HYDIN2 for BACT_M1 and BTN2A3P for VIR_M2

## Interpretation boundary

The table and figures should emphasize fixed-module transportability. They should not imply diagnostic classifier training, gene rediscovery, causal validation or module redefinition in GSE73461.
