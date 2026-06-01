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
