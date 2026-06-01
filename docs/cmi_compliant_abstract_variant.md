# CMI-Compliant Abstract Variant

## Purpose

This document provides a CMI-compliant structured abstract variant for the CMI-facing manuscript. It uses four required headings only—Objectives, Methods, Results and Conclusions—and is designed to remain below the 300-word limit.

## Title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules in public infection transcriptomes

## Running heading

Transportable infection modules

## Keywords

Host transcriptomics; bacterial infection; viral infection; interferon response; immune metabolism; module transportability; public transcriptomic datasets; fixed-module projection

## Structured abstract

### Objectives

To identify bacterial- and viral-associated host-response modules using a site-aware discovery workflow and test their external transportability as fixed modules in an independent public infection transcriptomic cohort.

### Methods

GSE211567 was used for discovery. A bacterial-versus-viral limma contrast was combined with site-stratified concordance assessment, transcript-to-gene mapping, Gene Ontology enrichment, redundancy reduction and manual module review. Five discovery modules were locked before external projection: two bacterial-higher modules and three viral-higher modules. GSE73461 was selected as the formal external projection cohort after metadata, expression, group-label and identifier-coverage audits. Locked modules were scored in GSE73461 using a pre-specified unweighted mean z-score rule. The primary contrast compared DefiniteBacterial and DefiniteViral samples. Wilcoxon tests with Benjamini–Hochberg correction assessed module-score differences. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set.

### Results

All five locked modules showed expected-direction concordance in GSE73461. Viral-associated modules showed the strongest external transportability: VIR_M1a, VIR_M1b and VIR_M2 were higher in DefiniteViral samples, with Benjamini–Hochberg adjusted P values of 4.77 × 10^-6, 1.41 × 10^-6 and 0.00848, respectively. BACT_M2 was higher in DefiniteBacterial samples (adjusted P = 0.0202). BACT_M1 was directionally concordant but borderline after correction (adjusted P = 0.0799). Primary-only z-score sensitivity preserved expected-direction concordance for all modules.

### Conclusions

A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes that retained expected-direction behaviour in an independent infection cohort. Fixed-module transportability analysis provides a biological complement to classifier-centred infection transcriptomics, without constituting diagnostic model validation or causal inference.

## Interpretation boundary

This abstract supports fixed-module transportability analysis. It must not be interpreted as diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence or causal validation.
