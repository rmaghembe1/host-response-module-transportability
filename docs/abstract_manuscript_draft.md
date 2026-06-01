# Manuscript Abstract Draft

## Structured abstract

### Background

Host transcriptomic studies have frequently sought to distinguish bacterial from viral infection using diagnostic classifiers, but classifier performance alone may obscure the biological transportability of underlying host-response programmes across cohorts. A fixed-module projection framework can test whether discovery-derived biological modules retain expected-direction behaviour in independent datasets without gene reselection or model retraining.

### Objective

To identify bacterial- and viral-associated host-response modules using a site-aware discovery workflow and to test their external transportability as fixed modules in an independent public infection transcriptomic cohort.

### Methods

GSE211567 was used as the discovery cohort. A bacterial-versus-viral limma contrast was combined with site-stratified concordance assessment to support conservative feature selection. Transcript-level features were mapped to gene-level identifiers, followed by Gene Ontology biological-process enrichment, redundancy reduction and manual module review. Five discovery modules were locked before projection: two bacterial-higher modules and three viral-higher modules. Projection-ready modules were scored in GSE73461 using a pre-specified unweighted mean z-score rule. The primary external contrast compared DefiniteBacterial and DefiniteViral samples. Wilcoxon tests with Benjamini–Hochberg correction were used to assess module-score differences. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set.

### Results

Five GSE211567 modules were locked for projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2. In GSE73461, all five modules showed expected-direction concordance. The viral-associated modules showed the strongest external transportability: VIR_M1a, VIR_M1b and VIR_M2 were higher in DefiniteViral samples, with BH-adjusted P values of 4.77 × 10^-6, 1.41 × 10^-6 and 0.00848, respectively. BACT_M2 was higher in DefiniteBacterial samples (BH-adjusted P = 0.0202), whereas BACT_M1 was directionally concordant but borderline after correction (BH-adjusted P = 0.0799). The primary-only z-score sensitivity analysis preserved expected-direction concordance for all five modules.

### Conclusions

A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes that could be projected as fixed modules into an independent cohort. The strongest external support was observed for antiviral/interferon-associated modules and the bacterial mitochondrial respiration/OXPHOS module. These findings support fixed-module transportability analysis as a biological complement to classifier-centred transcriptomic studies, while not constituting diagnostic model validation or causal inference.
