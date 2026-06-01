# CMI-Facing Title and Abstract Variant

## Purpose

This document provides a Clinical Microbiology and Infection (CMI)-facing title and abstract variant derived from the audited manuscript draft v0.4. The wording strengthens infection and clinical microbiology relevance while preserving the manuscript's key boundary: this is fixed-module host-response transportability analysis, not diagnostic classifier validation.

## Recommended CMI-facing title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules in public infection transcriptomes

## Alternative title options

1. Transportability of bacterial- and viral-associated host-response modules across public infection transcriptomes
2. Site-aware host-response module discovery and external projection across bacterial and viral infection transcriptomes
3. Fixed-module projection of bacterial- and viral-associated host-response programmes across public infection transcriptomes

## Recommended short title

Transportable host-response modules in infection transcriptomes

## CMI-facing structured abstract

### Background

Host transcriptomic studies have often sought to distinguish bacterial from viral infection using diagnostic classifiers. However, classifier performance alone does not establish whether the underlying host-response biology is transportable across heterogeneous infection cohorts. A fixed-module projection framework can test whether predefined host-response programmes retain expected-direction behaviour in independent datasets without gene reselection, module redefinition or model retraining.

### Objectives

To identify bacterial- and viral-associated host-response modules using a site-aware discovery workflow and to test their external transportability as fixed modules in an independent public infection transcriptomic cohort.

### Methods

GSE211567 was used for discovery. A bacterial-versus-viral limma contrast was combined with site-stratified concordance assessment to support conservative feature selection. Transcript-level features were mapped to gene identifiers, followed by Gene Ontology biological-process enrichment, redundancy reduction and manual module review. Five discovery modules were locked before projection: two bacterial-higher modules and three viral-higher modules. Locked modules were scored in GSE73461 using a pre-specified unweighted mean z-score rule. The primary external contrast compared DefiniteBacterial and DefiniteViral samples. Wilcoxon tests with Benjamini–Hochberg correction assessed module-score differences. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set.

### Results

Five GSE211567 modules were locked for projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2. In GSE73461, all five modules showed expected-direction concordance. Viral-associated modules showed the strongest external transportability: VIR_M1a, VIR_M1b and VIR_M2 were higher in DefiniteViral samples, with Benjamini–Hochberg adjusted P values of 4.77 × 10^-6, 1.41 × 10^-6 and 0.00848, respectively. BACT_M2 was higher in DefiniteBacterial samples (adjusted P = 0.0202), whereas BACT_M1 was directionally concordant but borderline after correction (adjusted P = 0.0799). Primary-only z-score sensitivity preserved expected-direction concordance for all modules.

### Conclusions

A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes that retained expected-direction behaviour when projected into an independent infection cohort. The strongest external support was observed for antiviral/interferon-associated modules and the bacterial mitochondrial respiration/OXPHOS module. These findings support fixed-module transportability analysis as a biological complement to classifier-centred infection transcriptomics, while not constituting diagnostic model validation or causal inference.

## CMI-facing positioning note

This abstract should be used only if CMI permits or prefers a structured abstract. If an unstructured abstract is required, the same content should be converted into a single paragraph while preserving the non-diagnostic and non-causal interpretation boundaries.

## Interpretation boundary

The title and abstract must not imply diagnostic classifier discovery, diagnostic model validation, clinical diagnostic test development, gene rediscovery, module redefinition or causal validation.
