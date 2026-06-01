# Manuscript Methods Draft — Skeleton

## Study design and discovery/projection firewall

This study used a staged transcriptomic transportability design to identify host-response programmes associated with bacterial versus viral infection in a discovery cohort and to test whether the resulting fixed modules transported to an independent external cohort. The workflow separated discovery, module locking and external projection. GSE211567 was used for discovery and module definition, whereas GSE73461 was used only after the final modules and scoring rules had been locked. External cohorts were not used to reselect genes, rename modules, alter module composition or train a diagnostic classifier.

## Dataset selection and eligibility assessment

Candidate public host-transcriptomic datasets were assessed for cohort independence, compatible whole-blood or comparable host-transcriptome data, usable gene identifiers, recoverable bacterial and viral or pathogen-class labels, sufficient sample size and absence from discovery/module definition. Candidate datasets that lacked required pathogen-class labels or did not meet projection criteria were retained only as audit records or conditional secondary resources. GSE73461 was selected as the formal external projection cohort after staged metadata, expression-file, sample-structure and identifier-coverage audits.

## GSE211567 discovery cohort preparation and quality control

GSE211567 was processed as the discovery dataset after metadata audit, sample eligibility assessment and normalized matrix quality control. Discovery samples were assigned to the predefined bacterial-versus-viral comparison according to the locked sample table and design decision. Available cohort structure was reviewed to determine whether site-stratified analysis was feasible and necessary. The resulting discovery matrix and sample annotations were carried forward to primary differential-expression modelling.

## Primary bacterial-versus-viral differential-expression modelling

The primary GSE211567 discovery contrast compared bacterial versus viral infection using limma-based differential-expression modelling. Host-transcriptomic features were ranked by bacterial-versus-viral differential expression. Positive log2 fold-change values were interpreted as bacterial-higher, whereas negative values were interpreted as viral-higher. Nominal P values and Benjamini–Hochberg adjusted P values were retained for downstream ranking, filtering and visualization. This primary contrast served as the discovery starting point rather than as a diagnostic signature.

## Site-stratified concordance and site-aware feature stability

To assess whether the pooled discovery contrast was stable across available strata, site-stratified differential-expression analyses were compared with the pooled bacterial-versus-viral result. LogFC concordance was summarized using Spearman and Pearson correlations, and directional concordance was assessed across all modelled features. These concordance summaries were used to define site-aware stable or eligible feature sets for downstream biological interpretation. The site-aware step was intended to reduce the risk of carrying forward features driven primarily by a single site or stratum; it was not interpreted as evidence that all site-specific biology was identical.

## Transcript-to-gene mapping and GO biological-process enrichment

Site-aware eligible transcript-level features were mapped to gene-level identifiers using the project annotation bridge. Bacterial-higher and viral-higher gene sets were considered separately. Gene-level feature sets were used for Gene Ontology biological-process over-representation analysis. Enriched GO terms were reviewed and redundancy-reduced to support conservative interpretation of biological programmes. GO enrichment was treated as biological annotation of ranked and stable gene sets, not as causal mechanism inference.

## Conservative module review and locking

Redundancy-reduced GO groups and their contributing genes were manually reviewed to define conservative discovery modules. Candidate modules were assigned review tiers, inspected at gene level and evaluated for biological coherence and direction concordance. Five final GSE211567 discovery modules were locked before external projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2. BACT_M1 and BACT_M2 were bacterial-higher modules, while VIR_M1a, VIR_M1b and VIR_M2 were viral-higher modules. VIR_M1a and VIR_M1b were retained as related but separate antiviral/interferon submodules because their overlap was incomplete and they represented distinguishable components of the antiviral response. Locked modules were treated as fixed discovery-derived gene sets.

## Projection-ready module scoring rules

Locked modules were converted into projection-ready gene-set tables before any external scoring. The primary module score was defined as the unweighted mean of gene-wise z-scores within each projection dataset. Missing genes were ignored during score calculation, but module-level gene coverage was reported. Projection eligibility required adequate locked-gene coverage according to predefined coverage rules. Module orientation was preserved from GSE211567 discovery and was not flipped using external outcomes.

## Technical projection rehearsal in GSE161731

GSE161731 was used only as a technical rehearsal resource to verify identifier mapping and fixed-module scoring mechanics. Identifier coverage and module-score calculation were tested without making biological validation or transportability claims. Results from GSE161731 were not used to redefine modules, alter scoring rules or support formal external validation.

## External projection cohort selection and GSE73461 locking

Formal external projection required an independent cohort with compatible expression data, clear bacterial-versus-viral labels and sufficient locked-module gene coverage. GSE261482 and GSE68310 were audited during the external cohort search but were not locked as the primary formal bacterial-versus-viral projection cohort. GSE73461 was locked after confirming suitable expression files, recoverable projection groups and adequate identifier coverage. The primary projection contrast consisted of DefiniteBacterial and DefiniteViral samples. Control samples were retained only as secondary context, and Inflammatory, Kawasaki and Unknown groups were excluded from the primary bacterial-versus-viral projection contrast.

## GSE73461 identifier mapping and module coverage

GSE73461 expression features were annotated using the Illumina Human v4 annotation resource. Probe-to-gene annotation was used to determine which locked GSE211567 module genes were represented in GSE73461. Module coverage was summarized before scoring. Locked genes absent from GSE73461 were recorded and excluded from score calculation, while successfully mapped genes were carried forward to fixed-module projection.

## Fixed-module projection scoring and statistical testing in GSE73461

Locked GSE211567 modules were scored in GSE73461 using the predefined unweighted mean z-score rule. Gene-wise z-scores were calculated within the locked projection sample set, and module scores were computed for each sample without gene reselection, module redefinition, reweighting or diagnostic model training. The primary statistical comparison used DefiniteBacterial versus DefiniteViral samples. Module-score differences were summarized as median bacterial-minus-viral differences, and Wilcoxon tests were used for group comparison. P values were adjusted across modules using the Benjamini–Hochberg method.

## Primary-only z-score sensitivity analysis

A sensitivity analysis repeated fixed-module scoring after recalculating gene-wise z-scores using only DefiniteBacterial and DefiniteViral samples. Control samples were excluded from the z-score reference set in this analysis. The same module definitions, scoring rule, group contrast, Wilcoxon testing and Benjamini–Hochberg correction were applied. This sensitivity analysis tested robustness to the z-score reference set and did not introduce new genes, new modules or new labels.

## Reproducibility, software environment and figure export

All major decisions, cohort-lock boundaries, analysis scripts, session information and generated outputs were tracked in the project repository. Decision logs documented the distinction between discovery, technical rehearsal, formal external projection and interpretation boundaries. Manuscript-facing figures were exported using the project publication-grade standard: 1800 dpi PNG, editable SVG and vector PDF. Figure generation changed only presentation and export quality, not the underlying statistical results.
