# Formal External Projection Cohort Eligibility Criteria

## Purpose

This document defines the eligibility criteria for selecting a formal external projection cohort for the locked GSE211567 discovery modules.

## Locked discovery modules

The following GSE211567 discovery modules are locked and must not be redefined, renamed, reweighted or altered using external cohorts:

- BACT_M1: bacterial-higher cytoplasmic translation and ribosomal protein programme
- BACT_M2: bacterial-higher mitochondrial respiration and oxidative phosphorylation programme
- VIR_M1a: viral-higher broad antiviral and interferon-stimulated defence programme
- VIR_M1b: viral-higher viral restriction and type I interferon signalling subgroup
- VIR_M2: viral-higher cytokine and innate immune regulation programme

## Required eligibility criteria

A formal external projection cohort must meet all of the following criteria:

1. The cohort must be independent from GSE211567.
2. The cohort must not have been used for discovery-module definition, enrichment, manual module review or module naming.
3. The cohort must contain whole-blood, peripheral-blood, PBMC or closely comparable host transcriptome data.
4. The expression matrix must be available as gene-level expression or be mappable to gene-level identifiers.
5. The cohort must contain usable infection-class or pathogen-class metadata.
6. The cohort must include bacterial and viral samples, or another predefined pathogen-class contrast justified before scoring.
7. Sample size must be sufficient for fixed-module score comparison.
8. Metadata must permit transparent inclusion and exclusion decisions.
9. Identifier coverage for locked GSE211567 modules must be assessed before scoring.
10. External scoring must use fixed modules and unweighted mean z-score scoring as the primary method.

## Exclusion criteria

A candidate cohort will be excluded if any of the following apply:

1. It overlaps with GSE211567 discovery samples.
2. It lacks usable expression data.
3. It lacks usable sample-level metadata.
4. It lacks infection-class/pathogen-class labels required for the intended contrast.
5. It has insufficient identifier coverage for locked modules.
6. It would require redefining modules, reselecting genes or changing module labels.
7. It is only suitable for technical rehearsal and has already been designated as such.

## Interpretation boundaries

External projection tests whether fixed GSE211567 discovery modules can be transported into an independent cohort. It does not redefine the modules. It does not create diagnostic signatures. It does not prove causality. Any external projection result must report module coverage, score distributions, group contrasts and whether direction agrees with GSE211567 discovery orientation.

## GSE161731 boundary

GSE161731 has already been designated and used as a technical rehearsal resource. It must not be promoted to formal validation without a separate explicit cohort-lock decision.
