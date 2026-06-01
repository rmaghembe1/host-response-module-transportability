# Complete Manuscript Draft v0.6 — CMI Front-Matter-Finalized Draft

Draft v0.6 incorporates the CMI final front-matter statements into the clean v0.5 CMI-facing manuscript while preserving the abstract, main text, supplementary table citations, submission route note and interpretation safeguards.

---

# CMI Final Front-Matter Statements

## Purpose

This document provides final draft front-matter statements for the CMI-facing manuscript package, including author information, funding, competing interests, ethics, author contributions, acknowledgements, data availability and code availability.

## Title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules in public infection transcriptomes

## Short title

Transportable host-response modules in infection transcriptomes

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

## APC / publication route note

No dedicated APC funding is available for this work. Submission to Clinical Microbiology and Infection should proceed through the standard subscription/non-open-access route unless full open-access coverage is confirmed.

## Interpretation boundary

These statements support a manuscript framed as fixed-module transportability analysis of host-response programmes. They should not imply diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.

---

## CMI-facing structured abstract

### Background

Host transcriptomic studies have often sought to distinguish bacterial from viral infection using diagnostic classifiers. However, classifier performance alone does not establish whether the underlying host-response biology is transportable across heterogeneous infection cohorts. A fixed-module projection framework can test whether predefined host-response programmes retain expected-direction behaviour in independent datasets without gene reselection, module redefinition or model retraining.

### Objectives

To identify bacterial- and viral-associated host-response modules using a site-aware discovery workflow and to test their external transportability as fixed modules in an independent public infection transcriptomic cohort.

### Methods

GSE211567 was used for discovery. A bacterial-versus-viral limma contrast was combined with site-stratified concordance assessment to support conservative feature selection; the external projection candidate search and cohort-selection decisions are summarized in Supplementary Table S1. Transcript-level features were mapped to gene identifiers, followed by Gene Ontology biological-process enrichment, redundancy reduction and manual module review. Five discovery modules were locked before projection: two bacterial-higher modules and three viral-higher modules, with locked gene membership provided in Supplementary Table S2. Locked modules were scored in GSE73461 using a pre-specified unweighted mean z-score rule; sample-level projection scores are provided in Supplementary Table S4. The primary external contrast compared DefiniteBacterial and DefiniteViral samples. Wilcoxon tests with Benjamini–Hochberg correction assessed module-score differences, with full projection statistics and sensitivity results provided in Supplementary Table S5. A primary-only z-score sensitivity analysis excluded Control samples from the z-score reference set.

### Results

Five GSE211567 modules were locked for projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2. In GSE73461, all five modules showed expected-direction concordance. Viral-associated modules showed the strongest external transportability: VIR_M1a, VIR_M1b and VIR_M2 were higher in DefiniteViral samples, with Benjamini–Hochberg adjusted P values of 4.77 × 10^-6, 1.41 × 10^-6 and 0.00848, respectively. BACT_M2 was higher in DefiniteBacterial samples (adjusted P = 0.0202), whereas BACT_M1 was directionally concordant but borderline after correction (adjusted P = 0.0799). Primary-only z-score sensitivity preserved expected-direction concordance for all modules.

### Conclusions

A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes that retained expected-direction behaviour when projected into an independent infection cohort. The strongest external support was observed for antiviral/interferon-associated modules and the bacterial mitochondrial respiration/OXPHOS module. These findings support fixed-module transportability analysis as a biological complement to classifier-centred infection transcriptomics, while not constituting diagnostic model validation or causal inference.

---

# Manuscript Introduction Draft

Distinguishing bacterial from viral infection remains a central challenge in infectious-disease medicine, antimicrobial stewardship and host-response biology. Although pathogen detection is essential, direct microbiological tests may be delayed, insensitive in some clinical contexts or difficult to interpret when colonization, co-infection or prior antimicrobial exposure complicate pathogen attribution. Host transcriptomic profiling has therefore been widely explored as a complementary approach for identifying immune-response patterns associated with bacterial and viral infection. Much of this work has focused on diagnostic classifiers, gene signatures and prediction performance. These studies have advanced the field, but classifier-centric analyses can obscure the biological architecture of host response and may be sensitive to cohort composition, platform differences, geography, clinical spectrum and case-definition heterogeneity.

A complementary question is whether biologically interpretable host-response programmes discovered in one setting remain transportable when projected as fixed modules into an independent cohort. This distinction is important. A diagnostic model can perform well because of cohort-specific features, sampling structure or technical correlations, whereas a fixed biological module asks whether a predefined group of genes retains coherent expected-direction behaviour outside the discovery dataset. Module transportability is therefore not equivalent to diagnostic validation. Instead, it provides a conservative framework for evaluating whether discovery-derived immune programmes are reproducible enough to support biological interpretation across datasets.

Public infection transcriptomic cohorts are especially useful for this purpose, but they also pose important risks. Samples may come from different countries, hospitals, clinical syndromes, pathogens, platforms or preprocessing pipelines. Without careful design, a bacterial-versus-viral contrast may capture site-specific, demographic or technical structure rather than generalizable host-response biology. Site-aware discovery is therefore necessary when public datasets contain geographically or clinically distinct strata. Comparing pooled and site-stratified effects can help identify features that are directionally stable enough to support conservative biological interpretation, while also highlighting where cohort heterogeneity limits overgeneralization.

Another important safeguard is to separate discovery from projection. If genes are reselected, modules are renamed or weights are tuned in the external cohort, apparent replication can reflect rediscovery rather than transportability. A stricter approach is to lock modules in the discovery dataset, define projection-ready gene sets and scoring rules in advance, and then test those fixed modules in an independent cohort. This workflow preserves a discovery/projection firewall and reduces the risk of overclaiming. It also keeps the analysis focused on host-response biology rather than diagnostic model construction.

In this study, a site-aware discovery and conservative module-locking workflow was applied to GSE211567 to identify bacterial- and viral-associated host-response programmes. The discovery analysis first ranked host-transcriptomic features in a bacterial-versus-viral contrast, then evaluated site-stratified concordance to support conservative feature selection and biological interpretation. Redundancy-reduced Gene Ontology biological-process enrichment and manual review were used to define five locked discovery modules: two bacterial-higher modules and three viral-higher modules. These modules were then converted into fixed projection-ready gene sets.

The locked modules were projected into GSE73461 as an independent external cohort using a predefined unweighted mean z-score scoring rule. The aim was not to train or validate a diagnostic classifier, but to test whether predefined bacterial- and viral-associated host-response modules retained expected-direction separation in an independent dataset. A primary-only z-score sensitivity analysis was also performed to assess whether projection results were robust to the scoring reference set. This framework provides a conservative analysis of fixed-module transportability across public infection transcriptomes and clarifies which components of bacterial- and viral-associated host-response architecture show the strongest external support.

---

# Manuscript Methods Draft

## Study design and discovery/projection firewall

This study used a staged transcriptomic transportability design to identify host-response programmes associated with bacterial versus viral infection and to test whether those programmes could be projected into an independent cohort as fixed modules. The workflow was structured around a strict discovery/projection firewall. GSE211567 was used for discovery, site-aware filtering, biological interpretation and module locking. GSE73461 was used only after the final discovery modules, scoring rules and projection boundaries had been defined. External projection datasets were not used to reselect genes, rename modules, alter module composition, tune weights or train a diagnostic classifier.

The analysis was designed to evaluate biological module transportability rather than to build a diagnostic model. Accordingly, all external analyses used fixed discovery-derived gene sets and pre-specified scoring rules. Directional interpretation was preserved from the GSE211567 discovery analysis, and external cohorts were used only to test whether module scores showed expected-direction separation between predefined bacterial and viral groups.

## Dataset selection and eligibility assessment

Public host-transcriptomic datasets were considered for discovery, technical rehearsal and external projection according to predefined eligibility principles. Suitable datasets required host-derived transcriptomic measurements from whole blood or a comparable immune-relevant sample type, recoverable sample-level metadata, interpretable bacterial and viral or pathogen-class labels, usable feature identifiers and sufficient sample size for the intended analysis stage. Datasets used for discovery or module definition were not eligible for formal external projection.

GSE211567 was selected as the discovery dataset because it provided a bacterial-versus-viral host-response setting with sufficient structure to support primary modelling and site-aware concordance assessment. Candidate external datasets were audited separately. GSE161731 was used only as a technical rehearsal resource for identifier coverage and fixed-module scoring mechanics. GSE261482 was retained as a conditional secondary paediatric bacterial/control or infection/control candidate because viral/pathogen-class metadata were not recovered during the audit. GSE68310 was audited but not locked as the primary formal projection cohort. GSE73461 was selected and locked as the formal external projection cohort after staged metadata, expression-file, sample-structure and identifier-coverage audits confirmed suitability for bacterial-versus-viral fixed-module projection.

## GSE211567 discovery cohort preparation and quality control

GSE211567 metadata and expression files were audited before discovery modelling. Sample eligibility was defined before differential-expression analysis, and the discovery sample table was locked before downstream modelling. Normalized matrix quality control was performed to verify sample alignment, expression-matrix integrity and suitability for downstream limma analysis. The bacterial-versus-viral discovery design was then fixed, and covariate feasibility was assessed before modelling.

Because GSE211567 included geographically and clinically distinct strata, site-aware analysis was incorporated into the discovery workflow. The site-aware design was intended to identify discovery signals that were not solely driven by one stratum and to provide a conservative foundation for biological module definition.

## Primary bacterial-versus-viral differential-expression modelling

The primary GSE211567 discovery contrast compared bacterial versus viral infection using limma-based differential-expression modelling. Host-transcriptomic features were ranked according to bacterial-versus-viral differential expression. Positive log2 fold-change values were interpreted as bacterial-higher, whereas negative values were interpreted as viral-higher. Nominal P values and Benjamini–Hochberg adjusted P values were retained for ranking, inspection and visualization.

The primary differential-expression result was treated as a discovery-ranking layer rather than as a diagnostic signature. No classifier was trained, and no gene list from this stage alone was interpreted as a final model. Instead, the ranked output was carried forward into site-aware concordance assessment, gene-level summarization and biological module review.

## Site-stratified concordance and site-aware feature stability

To evaluate stability of the discovery contrast across available strata, site-stratified bacterial-versus-viral analyses were compared with the pooled GSE211567 result. Concordance of log2 fold-change estimates was summarized using Spearman and Pearson correlations. Directional concordance was also assessed across all modelled features.

The site-stratified concordance results were used to support a conservative site-aware filtering strategy. Features with stable directionality and adequate site-aware support were prioritized for downstream biological interpretation. This step was designed to reduce the risk of defining modules from features driven primarily by a single geographic or technical stratum. Site-aware concordance was interpreted as evidence of transportability within the discovery cohort structure, not as proof that all site-specific host-response biology was identical.

## Transcript-to-gene mapping and GO biological-process enrichment

Site-aware eligible transcript-level features were mapped to gene-level identifiers using the project annotation bridge. Transcript-to-gene mapping was performed before enrichment analysis so that downstream biological interpretation used gene-level rather than transcript-level features. Bacterial-higher and viral-higher genes were handled separately to preserve the direction of the discovery contrast.

Gene-level bacterial-higher and viral-higher feature sets were used for Gene Ontology biological-process over-representation analysis. Enriched GO biological-process terms were reviewed and redundancy-reduced to identify interpretable biological programmes. GO enrichment was used as an annotation and interpretation layer for ranked and site-aware stable genes, not as evidence that the enriched pathways directly drive the observed infection-associated transcriptional differences.

## Conservative module review and locking

Redundancy-reduced GO groups, their contributing genes and their discovery directions were reviewed manually to define conservative host-response modules. Candidate modules were classified into review tiers and inspected at gene level for biological coherence, direction concordance and suitability for fixed external projection. This manual review was used to avoid overinterpreting broad or redundant ontology terms and to prevent unstable or poorly interpretable groups from being carried forward as final modules.

Five final GSE211567 discovery modules were locked before external projection. Two modules were bacterial-higher: BACT_M1, representing a cytoplasmic translation and ribosomal protein programme, and BACT_M2, representing mitochondrial respiration and oxidative phosphorylation. Three modules were viral-higher: VIR_M1a, representing a broad antiviral and interferon-stimulated defence programme; VIR_M1b, representing a viral restriction and type I interferon signalling subgroup; and VIR_M2, representing cytokine and innate immune regulation. VIR_M1a and VIR_M1b were retained as related but separate antiviral/interferon submodules because their overlap was incomplete and they captured distinguishable components of the antiviral response.

After final labelling, module membership was frozen. Locked modules were treated as discovery-derived biological gene sets, not as diagnostic classifiers or causal modules.

## Projection-ready module scoring rules

Locked GSE211567 modules were converted into projection-ready gene-set tables before any formal external scoring. The primary module score was defined as the unweighted mean of gene-wise z-scores within each projection dataset. For each dataset, gene expression values were z-scored across the samples included in the relevant scoring reference set, and each module score was calculated as the mean of available locked-module genes.

Missing genes were ignored during score calculation, but module-level gene coverage was reported. Projection eligibility required adequate locked-gene coverage according to predefined coverage thresholds. Module direction was preserved from the GSE211567 discovery analysis. Bacterial-higher modules were expected to have higher scores in bacterial samples, whereas viral-higher modules were expected to have higher scores in viral samples. External outcomes were not used to flip module orientation.

## Technical projection rehearsal in GSE161731

GSE161731 was used as a technical rehearsal dataset to verify fixed-module projection mechanics. This step assessed whether locked GSE211567 module genes could be mapped to the identifier system used in GSE161731 and whether unweighted mean z-score module scoring could be executed reproducibly. Because GSE161731 was designated as a technical rehearsal resource, its outputs were not used to make biological validation or transportability claims. The rehearsal did not alter module membership, module labels or scoring rules.

## External projection cohort selection and GSE73461 locking

Formal external projection required an independent cohort with compatible expression data, clear bacterial-versus-viral labels and adequate locked-module gene coverage. Candidate external cohorts were audited using a staged approach that considered metadata, sample labels, expression-file structure and identifier compatibility. GSE261482 and GSE68310 were audited during this process but were not locked as the primary formal bacterial-versus-viral projection cohort.

GSE73461 was selected after confirming that its expression data and sample labels supported a primary DefiniteBacterial versus DefiniteViral contrast. The locked primary projection contrast included 52 DefiniteBacterial and 94 DefiniteViral samples. Fifty-five Control samples were retained only as secondary context. Inflammatory, Kawasaki and Unknown groups were excluded from the primary bacterial-versus-viral projection contrast. GSE73461 was locked as the formal external projection cohort before module scoring was performed.

## GSE73461 identifier mapping and module coverage

GSE73461 expression features were annotated using the Illumina Human v4 annotation resource. Probe-to-gene annotation was used to determine which locked GSE211567 module genes were represented in the GSE73461 expression matrix. Module coverage was summarized before scoring, and missing genes were recorded.

All five locked modules passed the identifier-coverage gate for projection. Successfully mapped locked genes were carried forward to module scoring. Genes not represented in GSE73461 were excluded from score calculation but retained in the coverage report so that interpretation could account for missingness.

## Fixed-module projection scoring and statistical testing in GSE73461

Locked GSE211567 modules were scored in GSE73461 using the pre-specified unweighted mean z-score rule. Gene-wise z-scores were calculated within the locked GSE73461 projection sample set, and module scores were calculated for each sample as the mean z-score of available locked-module genes. No genes were reselected, no modules were redefined, no gene weights were tuned and no diagnostic model was trained.

The primary statistical comparison contrasted DefiniteBacterial and DefiniteViral samples. For each module, group separation was summarized as the median bacterial-minus-viral score difference. Wilcoxon tests were used to compare module-score distributions between groups. P values were adjusted across the five locked modules using the Benjamini–Hochberg method. Expected-direction concordance was assessed by comparing the observed median difference with the locked discovery direction of each module.

## Primary-only z-score sensitivity analysis

A sensitivity analysis was performed to test whether the projection results depended on including Control samples in the z-score reference set. In this analysis, gene-wise z-scores were recalculated using only DefiniteBacterial and DefiniteViral samples. Control samples were excluded from the z-score reference set.

The same locked module definitions, unweighted mean z-score scoring rule, DefiniteBacterial versus DefiniteViral contrast, Wilcoxon testing and Benjamini–Hochberg correction were applied. The sensitivity analysis was used to evaluate robustness to the scoring reference set. It did not introduce new genes, new modules, new labels or alternative model-training steps.

## Reproducibility, software environment and figure export

All major analysis decisions, cohort-lock boundaries, scripts, session information and generated outputs were tracked in the project repository. Decision logs were used to document discovery boundaries, technical rehearsal boundaries, formal external projection decisions and interpretation safeguards. Output tables, figure files and manuscript-facing documents were indexed and audited for path consistency.

Manuscript-facing figures were exported using the project publication-grade standard: PNG at 1800 dpi, editable SVG and vector PDF. Figure regeneration affected only presentation quality and export format; it did not alter underlying statistical results or interpretation. The manuscript Results package, figure/table mapping and package index were audited to confirm that all mapped files were present.

## Interpretation boundaries

The workflow was designed to assess fixed-module transportability of host-response programmes. Modules should not be described as diagnostic classifiers. GSE73461 projection should not be described as diagnostic model validation. External projection did not involve gene rediscovery, module relabelling, module redefinition or causal validation. Biological interpretation should therefore be framed around transportability of pre-specified host-response programmes rather than diagnostic signature development or mechanistic causality.

---

# Integrated Manuscript Results Section with Figure and Table Callouts

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

# Manuscript Discussion Draft

This study used a site-aware discovery and fixed-module projection framework to evaluate the transportability of bacterial- and viral-associated host-response programmes across public infection transcriptomic cohorts. Rather than training a diagnostic classifier, the analysis deliberately separated discovery, module locking and external projection. Five discovery-derived modules were locked in GSE211567 and then projected without gene reselection, module relabelling, reweighting or model training into GSE73461. This design allowed the analysis to ask a conservative biological question: whether predefined host-response programmes retained expected-direction behaviour in an independent cohort.

The principal finding was that all five locked modules showed expected-direction concordance in GSE73461. The strongest external support was observed for the viral-associated modules. VIR_M1a, representing a broad antiviral and interferon-stimulated defence programme, and VIR_M1b, representing a viral restriction and type I interferon signalling subgroup, showed robust separation in the expected viral-higher direction. VIR_M2, representing cytokine and innate immune regulation, also transported in the expected direction. These findings are biologically plausible because antiviral host responses are often characterized by interferon-stimulated genes, restriction factors and cytokine-linked innate immune activation. The results suggest that these antiviral/interferon-associated programmes are among the most stable components of the bacterial-versus-viral host-response architecture captured by this workflow.

Among the bacterial-higher modules, BACT_M2, representing mitochondrial respiration and oxidative phosphorylation, showed robust external transportability. This result supports the idea that bacterial-associated host responses may include reproducible immune-metabolic components rather than only canonical inflammatory markers. In contrast, BACT_M1, representing cytoplasmic translation and ribosomal protein biology, was directionally concordant but statistically borderline after correction in both the main projection and the primary-only z-score sensitivity analysis. This module should therefore be interpreted cautiously. Its repeated directionality suggests that it may reflect a real bacterial-associated signal, but its weaker statistical support indicates that it is less robustly transported than BACT_M2 and the viral-associated modules.

A key contribution of this work is the emphasis on module transportability rather than diagnostic classification. Many transcriptomic studies of bacterial and viral infection prioritize predictive signatures and diagnostic performance. Such approaches are valuable, but they can be difficult to interpret biologically and may be sensitive to cohort structure, platform effects, case definitions and sampling context. In contrast, fixed-module projection preserves predefined biological units and asks whether they behave coherently outside the discovery dataset. This makes the approach more conservative, because the external cohort cannot contribute to gene selection, module naming or model optimization.

The site-aware discovery step was also important. Public infection transcriptomic datasets often contain geographic, clinical and technical heterogeneity. A pooled bacterial-versus-viral contrast can therefore capture a mixture of pathogen biology, site structure, demographic composition, clinical syndrome and platform-specific effects. By comparing pooled and site-stratified effects before module locking, the workflow reduced the risk of defining modules from signals driven mainly by a single stratum. This does not eliminate all heterogeneity, nor does it imply that host responses are identical across sites, but it provides a stronger basis for conservative biological interpretation than unrestricted pooled discovery alone.

The external projection firewall was another important safeguard. GSE73461 was used only after the GSE211567 modules and scoring rules had been locked. This prevented external rediscovery and helped preserve the distinction between testing transportability and re-deriving cohort-specific signatures. The primary-only z-score sensitivity analysis further showed that the main projection pattern did not depend on including Control samples in the z-score reference set. All five modules retained expected-direction concordance, strengthening confidence that the observed projection pattern was not an artefact of the chosen scoring reference.

This study has several limitations. First, it is based on public datasets, and the analysis is therefore constrained by the metadata, case definitions, preprocessing histories and sample labels available for each cohort. Second, the external projection cohort differed from the discovery cohort in cohort composition and platform context, which is useful for transportability testing but also introduces heterogeneity that cannot be fully decomposed. Third, module scores are transcriptomic summaries and may reflect differences in cell composition, activation state, disease severity, sampling time or clinical phenotype. Without matched single-cell, protein, metabolomic or functional data, these modules should not be interpreted as direct causal mechanisms. Fourth, GSE161731 was used only as a technical scoring rehearsal and should not be interpreted as formal validation evidence. Finally, the workflow was not designed to build a clinical diagnostic classifier, and the results should not be interpreted as diagnostic model validation.

Future work should extend this fixed-module projection framework to additional independent cohorts, including datasets with clearer pathogen-level labels, richer clinical metadata and longitudinal sampling. Prospective datasets would be particularly valuable for testing whether these modules remain stable across age groups, geography, pathogen species, illness severity and treatment contexts. Cell-composition-aware, single-cell or deconvolution analyses could help determine whether transported modules reflect changes in immune-cell abundance, cell-intrinsic activation states or both. Multi-omic integration with proteomics, metabolomics or plasma inflammatory markers could also clarify whether transcriptomic module transportability corresponds to reproducible downstream functional programmes.

In conclusion, this study shows that a site-aware discovery and conservative module-locking workflow can identify bacterial- and viral-associated host-response programmes that retain expected-direction behaviour when projected as fixed modules into an independent cohort. The strongest transported signals were antiviral/interferon-associated modules and the bacterial mitochondrial respiration/OXPHOS module, while the bacterial cytoplasmic translation/ribosomal module remained directionally concordant but borderline. These findings support fixed-module transportability analysis as a biologically interpretable complement to classifier-centred infection transcriptomics, while preserving clear boundaries against diagnostic model validation and causal inference.

---

# Main Figure Captions

# Polished Main Figure Captions

## Figure 1. Discovery and conservative locking of bacterial- and viral-associated host-response modules in GSE211567

(A) Primary bacterial-versus-viral discovery analysis in GSE211567. The volcano-style plot summarizes the limma-ranked host-transcriptomic contrast used as the discovery starting point before site-aware filtering and biological module definition. Positive log2 fold-change values indicate bacterial-higher features, whereas negative values indicate viral-higher features.

(B) Site-aware concordance of the GSE211567 bacterial-versus-viral discovery contrast. Spearman logFC concordance is shown for pooled-versus-site and site-versus-site comparisons, with directional concordance annotated for the corresponding all-feature comparisons. This analysis was used as a stability gate before carrying features forward into pathway interpretation and module locking.

(C) Locked GSE211567 discovery modules carried forward as projection-ready fixed gene sets. Two modules were bacterial-higher, representing cytoplasmic translation/ribosomal protein activity and mitochondrial respiration/oxidative phosphorylation. Three modules were viral-higher, representing broad antiviral/interferon-stimulated defence, viral restriction/type I interferon signalling and cytokine/innate immune regulation. Modules were frozen before external projection, with no later gene reselection or module redefinition.

## Figure 2. External fixed-module projection of GSE211567 discovery modules in GSE73461

(A) Distribution of locked module scores in the independent GSE73461 external projection cohort. Module scores were calculated using the pre-specified unweighted mean z-score rule in DefiniteBacterial and DefiniteViral samples. Genes were scored without reselection, reweighting, module renaming or diagnostic model training.

(B) Median bacterial-minus-viral module-score differences in the main GSE73461 projection and in the primary-only z-score sensitivity analysis. Positive values indicate higher scores in DefiniteBacterial samples, whereas negative values indicate higher scores in DefiniteViral samples. All five modules retained the expected discovery direction in both analyses.

(C) BH-adjusted Wilcoxon significance values for the main projection and the primary-only z-score sensitivity analysis. The dashed line indicates BH-adjusted P = 0.05. BACT_M1 remained directionally concordant but borderline, whereas BACT_M2 and all viral-associated modules showed robust external transportability.

---

# Table 1 Title and Footnotes

# Polished Table 1 Title and Footnotes

## Table 1. External projection of locked GSE211567 discovery modules in GSE73461

This table summarizes fixed-module projection of the five locked GSE211567 discovery modules in the independent GSE73461 cohort. Module scores were calculated using the pre-specified unweighted mean z-score rule without gene reselection, module redefinition, reweighting or diagnostic model training. The primary projection contrast compared DefiniteBacterial and DefiniteViral samples.

## Suggested table columns

1. Module ID
2. Conservative module label
3. Discovery direction
4. Locked genes
5. Genes scored in GSE73461
6. Main projection result
7. Primary-only z-score sensitivity result
8. Interpretation tier

## Footnotes

**Discovery direction:** Direction assigned during GSE211567 discovery-module locking before external projection.

**Locked genes:** Number of genes fixed in the locked GSE211567 discovery module before GSE73461 projection.

**Genes scored in GSE73461:** Number of locked module genes successfully mapped and scored in GSE73461 after Illumina probe annotation.

**Main projection result:** Median bacterial-minus-viral module-score difference and Benjamini–Hochberg adjusted Wilcoxon P value from the main GSE73461 projection analysis.

**Primary-only z-score sensitivity result:** Median bacterial-minus-viral module-score difference and Benjamini–Hochberg adjusted Wilcoxon P value after gene-wise z-scoring using only DefiniteBacterial and DefiniteViral samples, excluding Control samples from the z-score reference set.

**Interpretation tier:** Conservative interpretation based on direction concordance, statistical support and robustness in the primary-only z-score sensitivity analysis.

**Abbreviations:** BH, Benjamini–Hochberg; OXPHOS, oxidative phosphorylation.

## Front-matter interpretation boundary

Table 1 reports fixed-module external projection. It should not be interpreted as diagnostic classifier discovery, model training, gene rediscovery, module redefinition or causal validation.

---



# Supplementary Tables Note

Supplementary Tables S1–S5 provide the external cohort search register, locked GSE211567 module genes, GSE73461 identifier coverage and probe choices, sample-level fixed-module projection scores, and full projection/sensitivity statistics.

# CMI Submission Route Note

This manuscript should be submitted through the standard subscription/non-open-access route unless full open-access coverage is confirmed. Optional open access should not be selected without a confirmed APC waiver or coverage route.

# Final Interpretation Boundary Reminder

This manuscript draft presents fixed-module transportability analysis of host-response programmes. It must not be framed as diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.
