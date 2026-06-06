# Complete Manuscript Draft v1.0 — Step 2 CMI IMRaD Headings

Draft v0.9 Step 1 removes internal submission-route and draft-boundary notes from the manuscript body while preserving scientific caution within the Methods, Results and Discussion.

---

## Purpose

This document provides final draft front-matter statements for the CMI-facing manuscript package, including author information, funding, competing interests, ethics, author contributions, acknowledgements, data availability and code availability.

## Title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules in public infection transcriptomes

## Short title

Transportable infection modules

## Authors and affiliations

**Reuben S. Maghembe**  
St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  
Role: First author and corresponding author

**Samweli Bahati**  
AfroBiomics Co. Ltd, Tanzania  
Role: Contributing author

**Abdalah Makaranga**  
Mwenge Catholic University (MWECAU), Tanzania  
Role: Contributing author

## Corresponding author

Reuben S. Maghembe  
St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  
Email: rmaghembe@sfuchas.ac.tz

## Funding

This research received no specific grant from any funding agency in the public, commercial or not-for-profit sectors.

## Competing interests

The authors declare no competing interests.

## Ethics approval

This study reanalysed publicly available de-identified transcriptomic datasets and did not involve new recruitment of human participants, new collection of human biospecimens or access to identifiable private information. No new ethics approval was required for this secondary analysis of public data.

## Author contributions

Reuben S. Maghembe: Conceptualization, methodology, formal analysis, investigation, data curation, visualization, writing — original draft, writing — review and editing, project administration.

Samweli Bahati: Methodological input, data interpretation, writing — review and editing.

Abdalah Makaranga: Data interpretation, manuscript review, writing — review and editing.

## Acknowledgements

The authors thank the investigators and participants of the public transcriptomic studies reanalysed in this work, including GSE211567 and GSE73461. The authors also acknowledge the public repositories and database maintainers that made these datasets available for secondary analysis. This acknowledgement does not imply endorsement of the present analysis by the original dataset generators.

## Data availability

This study reanalysed publicly available transcriptomic datasets. The discovery analysis used GSE211567, and the formal external projection analysis used GSE73461. Candidate or technical-rehearsal datasets considered during workflow development included GSE161731, GSE261482 and GSE68310. All dataset accession numbers, cohort-lock decisions, analysis boundaries and interpretation safeguards are recorded in the repository decision log and supplementary materials.

## Code availability

Analysis scripts, decision logs, audit outputs, manuscript-facing tables, supplementary tables and figure-generation outputs are organized in the project repository. The repository README provides an overview of the analysis workflow, manuscript-facing files, supplementary materials and quality-control audits.


---

## Abstract

### Objectives

To identify bacterial- and viral-associated host-response modules using a site-aware discovery workflow and test their external transportability as fixed modules in an independent public infection transcriptomic cohort.

### Methods

GSE211567 was used for discovery. A bacterial-versus-viral limma contrast was combined with site-stratified concordance assessment, transcript-to-gene mapping, Gene Ontology enrichment, redundancy reduction and manual module review. Five discovery modules were locked before external projection: two bacterial-higher modules and three viral-higher modules. GSE73461 was selected as the formal external projection cohort after metadata, expression, group-label and identifier-coverage audits. Locked modules were scored in GSE73461 using a pre-specified unweighted mean z-score rule. The primary contrast compared DefiniteBacterial and DefiniteViral samples. Wilcoxon tests with Benjamini–Hochberg correction assessed module-score differences. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set.

### Results

All five locked modules showed expected-direction concordance in GSE73461. Viral-associated modules showed the strongest external transportability: VIR_M1a, VIR_M1b and VIR_M2 were higher in DefiniteViral samples, with Benjamini–Hochberg adjusted P values of 4.77 × 10^-6, 1.41 × 10^-6 and 0.00848, respectively. BACT_M2 was higher in DefiniteBacterial samples (adjusted P = 0.0202). BACT_M1 was directionally concordant but borderline after correction (adjusted P = 0.0799). Primary-only z-score sensitivity preserved expected-direction concordance for all modules.

### Conclusions

A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes that retained expected-direction behaviour in an independent infection cohort. Fixed-module transportability analysis provides a biological complement to classifier-centred infection transcriptomics, without constituting diagnostic model validation or causal inference.

## Keywords

Host transcriptomics; bacterial infection; viral infection; interferon response; immune metabolism; module transportability; public transcriptomic datasets; fixed-module projection

---

# Introduction

Distinguishing bacterial from viral infection remains important for infectious-disease medicine, antimicrobial stewardship and host-response biology. Although pathogen detection is central to diagnosis, microbiological results may be delayed, insensitive or difficult to interpret when colonization, co-infection or previous antimicrobial exposure complicate pathogen attribution. Host transcriptomic studies have therefore been widely explored as complementary approaches, but much work has emphasized diagnostic classifiers and prediction performance rather than whether the underlying host-response biology is transportable across heterogeneous cohorts.

A complementary question is whether biologically interpretable response programmes discovered in one setting retain coherent expected-direction behaviour when projected as fixed modules into an independent cohort. This is distinct from diagnostic validation. A classifier may perform well because of cohort-specific, technical or sampling structure, whereas fixed-module projection asks whether predefined gene sets remain directionally stable outside the discovery dataset without gene reselection, module redefinition or model retraining.

Public infection transcriptomic cohorts are valuable for this purpose but require safeguards because samples may differ by geography, clinical syndrome, pathogen spectrum, platform, preprocessing and case definition. Site-aware discovery can reduce the risk that bacterial-versus-viral contrasts merely capture stratum-specific structure. A strict discovery/projection firewall further reduces overclaiming by locking modules and scoring rules before external projection.

Here, GSE211567 was used for site-aware discovery of bacterial- and viral-associated host-response programmes. Five conservative modules were locked and then projected into GSE73461 using a predefined unweighted mean z-score rule. The aim was not to train or validate a diagnostic classifier, but to test fixed-module transportability across public infection transcriptomes and identify which host-response programmes show the strongest external support.


---

# Methods

## Study design and datasets

This study used a staged transcriptomic transportability design with a strict discovery/projection firewall. GSE211567 was used for discovery, biological interpretation and module locking. GSE73461 was used only after final module definitions, directions and scoring rules had been fixed. External data were not used to reselect genes, rename modules, alter module composition, tune weights or train a diagnostic classifier.

Public host-transcriptomic datasets were considered for discovery, rehearsal or external projection if they contained infection-relevant human transcriptomic data, recoverable sample metadata, interpretable pathogen-class labels, usable feature identifiers and sufficient sample structure for the intended analysis. GSE211567 was selected for discovery because it supported bacterial-versus-viral modelling and site-aware concordance assessment. GSE161731 was retained only as a technical rehearsal dataset. GSE261482 and GSE68310 were audited but not selected as the formal projection cohort. GSE73461 was locked as the formal external projection cohort after metadata, expression, group-label and identifier-coverage audits confirmed suitability for fixed-module projection (Supplementary Table S1).

## GSE211567 discovery and module locking

GSE211567 metadata and normalized expression data were audited before modelling. Sample eligibility and the bacterial-versus-viral discovery design were fixed before differential-expression analysis. Because GSE211567 included geographically and clinically distinct strata, the discovery workflow combined a primary bacterial-versus-viral limma contrast with site-stratified concordance assessment to prioritize directionally stable signals.

Differential-expression results were treated as a discovery-ranking layer rather than a diagnostic signature. Positive log2 fold-change values were interpreted as bacterial-higher and negative values as viral-higher. Transcript-level features were mapped to gene identifiers, summarized at gene level and carried into Gene Ontology biological-process enrichment. Redundant enriched terms were reduced and manually reviewed to define biologically interpretable modules. Five final modules were locked before projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 (Supplementary Table S2). Module labels and directions were fixed before external analysis.

## GSE73461 projection and statistical analysis

GSE73461 expression and annotation files were audited independently. Illumina probe identifiers were mapped to gene symbols, and locked GSE211567 module genes were checked for coverage before scoring. Coverage was high across all modules and passed predefined identifier-coverage thresholds; matched genes, missing genes and probe choices are provided in Supplementary Table S3.

Locked modules were scored in GSE73461 using a predefined unweighted mean z-score rule. The primary projection contrast compared DefiniteBacterial and DefiniteViral samples; Control samples were retained for the main z-score reference where applicable. Sample-level module scores are provided in Supplementary Table S4. Wilcoxon rank-sum tests compared module scores between DefiniteBacterial and DefiniteViral groups, and Benjamini–Hochberg correction was applied across the five modules. Expected-direction concordance was defined according to the discovery direction of each locked module. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set. Full primary and sensitivity statistics are provided in Supplementary Table S5.

## Reproducibility and interpretation boundaries

Analysis scripts, decision logs, audit outputs, manuscript-facing figures and supplementary tables were organized in the project repository and indexed through path-audited package files. The analysis was designed to evaluate biological module transportability only. It does not constitute diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.


---

# Results

## GSE211567 discovery analysis identifies site-aware bacterial- and viral-associated host-response programmes

The discovery analysis was performed in GSE211567 using a predefined bacterial-versus-viral contrast while preserving a strict distinction between discovery, module locking and external projection. The primary limma analysis ranked host-transcriptomic features by bacterial-versus-viral differential expression and provided the starting point for biological module discovery (Figure 1A). This primary analysis was followed by site-aware concordance checks across the pooled dataset and available site-stratified analyses, reducing the risk of carrying forward features driven mainly by a single geographic or technical stratum.

The site-stratified concordance analysis showed that the pooled bacterial-versus-viral contrast was strongly concordant with the Sri Lanka stratum and moderately concordant with the United States stratum, whereas the direct Sri Lanka-versus-United States comparison showed weaker concordance (Figure 1B). Directional concordance was also evaluated across all modelled features, supporting a conservative site-aware filtering strategy before pathway interpretation and module locking. These results motivated the use of ranked, site-aware feature sets rather than unrestricted single-cohort differential-expression hits.

## Conservative module locking defines five projection-ready discovery modules

Site-aware eligible bacterial-higher and viral-higher features were mapped from transcript-level identifiers to gene-level identifiers and used for manual GO biological-process enrichment. Redundancy-reduced GO groups were reviewed manually, and candidate biological programmes were classified into primary, secondary and contextual tiers before final module locking. This process yielded five conservative GSE211567 discovery modules that were frozen before external projection (Figure 1C).

Two locked modules were bacterial-higher: BACT_M1, representing a cytoplasmic translation and ribosomal protein programme, and BACT_M2, representing mitochondrial respiration and oxidative phosphorylation. Three locked modules were viral-higher: VIR_M1a, representing a broad antiviral and interferon-stimulated defence programme; VIR_M1b, representing a viral restriction and type I interferon signalling subgroup; and VIR_M2, representing cytokine and innate immune regulation. VIR_M1a and VIR_M1b were retained as related but separate antiviral/interferon submodules rather than force-merged because their overlap was incomplete and each captured a distinct aspect of the antiviral response. These modules were carried forward as fixed gene sets, with no later gene reselection or relabelling allowed during projection.

## GSE73461 was locked as an independent external projection cohort

After module locking, independent external projection required a cohort with compatible host-transcriptomic data, recoverable identifiers and clear bacterial-versus-viral labels. GSE73461 was selected after staged metadata, expression-file, sample-structure and identifier-coverage audits. The locked primary projection contrast contained 52 DefiniteBacterial and 94 DefiniteViral samples. Fifty-five Control samples were retained only as secondary context, while Inflammatory, Kawasaki and Unknown groups were excluded from the primary bacterial-versus-viral contrast.

GSE73461 passed the identifier-coverage gate after Illumina probe annotation with `illuminaHumanv4.db`; module-level identifier coverage, matched genes, missing genes and projection probe choices are provided in Supplementary Table S3. Coverage of locked GSE211567 genes was high for all modules: 24/25 genes for BACT_M1, 21/21 for BACT_M2, 128/128 for VIR_M1a, 33/33 for VIR_M1b and 105/106 for VIR_M2 (Table 1). GSE73461 was therefore locked as the formal external projection cohort before any module scoring was performed.

## Fixed-module external projection supports transportability of the locked host-response architecture

Locked GSE211567 modules were scored in GSE73461 using the pre-specified unweighted mean z-score rule. Genes were z-scored within the locked GSE73461 projection sample set, and module scores were calculated without gene reselection, module redefinition, reweighting or diagnostic model training.

All five modules showed expected-direction concordance in GSE73461 (Figure 2A; Table 1). BACT_M2 was higher in DefiniteBacterial than DefiniteViral samples, with a median bacterial-minus-viral difference of +0.3328 and BH-adjusted Wilcoxon P = 0.0202. BACT_M1 was also directionally concordant but statistically borderline after correction, with a median difference of +0.2067 and BH-adjusted P = 0.0799.

The viral-associated modules showed the strongest external transportability. VIR_M1a was higher in DefiniteViral samples, with a median bacterial-minus-viral difference of −0.4629 and BH-adjusted P = 4.77 × 10^-6. VIR_M1b showed the largest separation, with a median difference of −0.6739 and BH-adjusted P = 1.41 × 10^-6. VIR_M2 was also higher in DefiniteViral samples, with a median difference of −0.2596 and BH-adjusted P = 0.00848.

## Primary-only z-score sensitivity confirms robustness to the scoring reference set

To test whether the projection result depended on including Control samples in the z-score reference set, the fixed-module scoring was repeated after gene-wise z-scoring using only DefiniteBacterial and DefiniteViral samples. The 55 Control samples were excluded from this sensitivity analysis.

The sensitivity analysis preserved the main result. All five modules retained expected-direction concordance (Figure 2B–C; Table 1). BACT_M2 remained significantly higher in DefiniteBacterial samples (median difference +0.3504; BH-adjusted P = 0.0165), while BACT_M1 remained directionally concordant but borderline (median difference +0.2211; BH-adjusted P = 0.0778). The viral-associated modules remained robustly higher in DefiniteViral samples: VIR_M1a (median difference −0.4441; BH-adjusted P = 7.57 × 10^-6), VIR_M1b (median difference −0.6445; BH-adjusted P = 2.22 × 10^-6) and VIR_M2 (median difference −0.2626; BH-adjusted P = 0.00796).

Together, these results support external transportability of a pre-specified bacterial- and viral-associated host-response module architecture from GSE211567 into an independent cohort. The strongest transported signals were the antiviral/interferon-related modules, followed by the bacterial mitochondrial respiration and oxidative phosphorylation module. The bacterial cytoplasmic translation and ribosomal protein programme was directionally concordant in both analyses but should be interpreted cautiously because it remained statistically borderline. These findings represent fixed-module transportability analysis, not diagnostic classifier discovery, model training or causal validation.

---

# Discussion

This study used a site-aware discovery and fixed-module projection workflow to evaluate host-response module transportability across public infection transcriptomes. Five bacterial- or viral-associated modules were locked in GSE211567 and projected without modification into GSE73461. All modules showed expected-direction concordance in the independent cohort, with strongest support for the viral/interferon-associated modules and for the bacterial mitochondrial respiration/OXPHOS module. BACT_M1 remained directionally concordant but borderline after correction, supporting cautious interpretation.

The viral-associated modules showed the clearest external transportability. VIR_M1a and VIR_M1b captured broad antiviral, interferon-stimulated and viral-restriction programmes, while VIR_M2 represented cytokine and innate immune regulation. Their robust expected-direction behaviour in GSE73461 is consistent with the central role of interferon-linked host responses in viral infection. The bacterial-associated BACT_M2 module also transported robustly and suggests that mitochondrial respiration and oxidative phosphorylation programmes may form part of a bacterial-associated host-response architecture in this analysis. In contrast, the borderline BACT_M1 result indicates that cytoplasmic translation and ribosomal programmes may be more context-sensitive or more affected by cohort and platform heterogeneity.

The principal contribution is not a new diagnostic classifier, but a conservative framework for testing whether discovery-derived biological modules remain directionally coherent in an independent cohort. This distinction matters because classifier-centred studies can be influenced by cohort composition, sampling structure and technical correlations. By locking modules before projection and prohibiting gene reselection or model retraining in GSE73461, the workflow reduces rediscovery bias and focuses interpretation on module transportability.

Several limitations should guide interpretation. Public metadata were imperfect, and case definitions, clinical syndromes, pathogens, platforms and preprocessing may differ across datasets. Whole-blood transcriptomic scores may reflect both cell composition and cell-intrinsic activation states. GSE73461 provided a useful external projection cohort, but the analysis remains retrospective and does not establish clinical performance, clinical readiness or causal mechanisms. Additional prospective and multi-cohort analyses are needed to test how these modules behave across age groups, syndromes, pathogens, sampling times and treatment contexts.

In summary, site-aware discovery followed by fixed external projection identified host-response programmes with varying degrees of transportability across infection transcriptomes. Antiviral/interferon modules and a bacterial mitochondrial respiration/OXPHOS module showed the strongest support, whereas a bacterial translation/ribosomal module was directionally concordant but borderline. Fixed-module transportability analysis can complement classifier-centred transcriptomic studies by clarifying which biological programmes remain stable enough to support cross-cohort interpretation.


---

# Figure captions

## Figure 1. Discovery and conservative locking of bacterial- and viral-associated host-response modules in GSE211567

(A) Primary bacterial-versus-viral discovery analysis in GSE211567. The volcano-style plot summarizes the limma-ranked host-transcriptomic contrast used as the discovery starting point before site-aware filtering and biological module definition. Positive log2 fold-change values indicate bacterial-higher features, whereas negative values indicate viral-higher features.

(B) Site-aware concordance of the GSE211567 bacterial-versus-viral discovery contrast. Spearman logFC concordance is shown for pooled-versus-site and site-versus-site comparisons, with directional concordance annotated for the corresponding all-feature comparisons. This analysis was used as a stability gate before carrying features forward into pathway interpretation and module locking.

(C) Locked GSE211567 discovery modules carried forward as projection-ready fixed gene sets. Two modules were bacterial-higher, representing cytoplasmic translation/ribosomal protein activity and mitochondrial respiration/oxidative phosphorylation. Three modules were viral-higher, representing broad antiviral/interferon-stimulated defence, viral restriction/type I interferon signalling and cytokine/innate immune regulation. Modules were frozen before external projection, with no later gene reselection or module redefinition.

## Figure 2. External fixed-module projection of GSE211567 discovery modules in GSE73461

(A) Distribution of locked module scores in the independent GSE73461 external projection cohort. Module scores were calculated using the pre-specified unweighted mean z-score rule in DefiniteBacterial and DefiniteViral samples. Genes were scored without gene reselection, reweighting, module renaming or diagnostic model training.

(B) Median bacterial-minus-viral module-score differences in the main GSE73461 projection and in the primary-only z-score sensitivity analysis. Positive values indicate higher scores in DefiniteBacterial samples, whereas negative values indicate higher scores in DefiniteViral samples. All five modules retained the expected discovery direction in both analyses.

(C) BH-adjusted Wilcoxon significance values for the main projection and the primary-only z-score sensitivity analysis. The dashed line indicates BH-adjusted P = 0.05. BACT_M1 remained directionally concordant but borderline, whereas BACT_M2 and all viral-associated modules showed robust external transportability.

---

# Table 1

## Title

This table summarizes fixed-module projection of the five locked GSE211567 discovery modules in the independent GSE73461 cohort. Module scores were calculated using the pre-specified unweighted mean z-score rule without gene reselection, module redefinition, reweighting or diagnostic model training. The primary projection contrast compared DefiniteBacterial and DefiniteViral samples.

## Columns

1. Module ID
2. Conservative module label
3. Discovery direction
4. Locked genes
5. Genes scored in GSE73461
6. Main projection result
7. Primary-only z-score sensitivity result
8. Interpretation tier

## Notes

**Discovery direction:** Direction assigned during GSE211567 discovery-module locking before external projection.

**Locked genes:** Number of genes fixed in the locked GSE211567 discovery module before GSE73461 projection.

**Genes scored in GSE73461:** Number of locked module genes successfully mapped and scored in GSE73461 after Illumina probe annotation.

**Main projection result:** Median bacterial-minus-viral module-score difference and Benjamini–Hochberg adjusted Wilcoxon P value from the main GSE73461 projection analysis.

**Primary-only z-score sensitivity result:** Median bacterial-minus-viral module-score difference and Benjamini–Hochberg adjusted Wilcoxon P value after gene-wise z-scoring using only DefiniteBacterial and DefiniteViral samples, excluding Control samples from the z-score reference set.

**Interpretation tier:** Conservative interpretation based on direction concordance, statistical support and robustness in the primary-only z-score sensitivity analysis.

**Abbreviations:** BH, Benjamini–Hochberg; OXPHOS, oxidative phosphorylation.


Table 1 reports fixed-module external projection. It should not be interpreted as diagnostic classifier discovery, model training, gene rediscovery, module redefinition or causal validation.

---



# Supplementary material

Supplementary Tables S1–S5 provide the external cohort search register, locked GSE211567 module genes, GSE73461 identifier coverage and probe choices, sample-level fixed-module projection scores, and full projection/sensitivity statistics.


