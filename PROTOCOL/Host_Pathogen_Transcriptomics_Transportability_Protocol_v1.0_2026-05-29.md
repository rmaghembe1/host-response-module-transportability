## Conserved and pathogen-ecology-specific whole-blood immune-metabolic programs across acute bacterial and viral infections: a cross-cohort transcriptomic transportability study

**Protocol version:** 1.0  
**Protocol date:** 29 May 2026  
**Project status:** Prospective secondary-analysis protocol; no
project-specific inferential analysis has commenced  
**Principal analyst/project lead:** Reuben S. Maghembe  
**Planned repository name:**
`host-pathogen-transcriptome-transportability`  
**Study type:** Reproducible secondary analysis of publicly available
human whole-blood RNA-sequencing datasets  
**Primary scientific domain:** Host-pathogen interaction / systems
immunology / transcriptomic transportability  
**Primary analysis language:** R, with optional Python utilities for
file audit, visualization support and checksum generation  
**Intended output:** A publishable transcriptomics manuscript focused on
biological pathway-module transportability, not another diagnostic
classifier

## Protocol synopsis

| **Item**                                 | **Prespecified protocol decision**                                                                                                                                                                                                          |
|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Biological problem                       | Acute bacterial and viral infections trigger overlapping inflammatory responses but may differ in coordinated immune-metabolic programs; it remains uncertain which programs are conserved across pathogen ecologies and clinical contexts. |
| Primary objective                        | Identify bacterial-versus-viral whole-blood pathway programs that are directionally stable across distinct acute-febrile-illness contexts and test whether frozen modules transport into independent respiratory infection cohorts.         |
| Primary discovery resource               | GSE211567: multinational/global-febrile-illness whole-blood RNA-seq resource including bacterial, viral and noninfectious illnesses from the United States and Sri Lanka.                                                                   |
| Primary external transportability cohort | GSE161731: adult peripheral-blood RNA-seq resource containing bacterial pneumonia, influenza, seasonal coronavirus and healthy controls; non-COVID respiratory infection groups will define the primary external comparison.                |
| Exploratory generalizability cohort      | GSE261482: pediatric pneumonia whole-blood RNA-seq resource; definitive bacterial versus definitive viral comparison will be used only after the adult program is frozen.                                                                   |
| Conditional extension                    | GSE282464: large multi-center respiratory-infection/sepsis resource; eligible only after metadata and series/sample-count discrepancies are resolved.                                                                                       |
| Primary scientific contrast              | Bacterial infection versus viral infection, interpreted at pathway/module level.                                                                                                                                                            |
| Primary novelty boundary                 | The project will not develop or promote another primary small-gene bacterial-versus-viral diagnostic classifier. It will study conserved versus context-specific biology and cross-cohort module transportability.                          |
| Key safeguards                           | Discovery/validation separation; pre-outcome module locking; feature-portability audit before external scoring; explicit sensitivity analyses; no clinical-diagnostic claims without a separate prospective design.                         |

# 1. Background and scientific rationale

Acute bacterial and viral infections can produce similar early clinical
presentations, but the host response is shaped by pathogen biology,
tissue tropism, systemic burden, host age, geographic exposure patterns
and clinical syndrome. Whole-blood transcriptomics captures systemic
innate and adaptive immune activity, including interferon programs,
neutrophil-associated antimicrobial functions, complement and
coagulation biology, antigen presentation, lymphocyte activity, cellular
stress and immunometabolic remodeling. The resulting signals are
therefore biologically informative, but they can also be context
dependent.

Public whole-blood RNA-seq resources now provide an opportunity to
examine whether coordinated immune-metabolic programs are conserved
across very different infection settings. GSE211567 was generated to
distinguish bacterial from viral illnesses of global relevance and
includes acute febrile illnesses from the United States and Sri Lanka,
including bacterial and viral disease classes as well as noninfectious
illness controls. The published analysis focused on transcriptional
classifiers. In contrast, the present project will use this cohort as a
discovery resource for **pathway-level biological conservation and
heterogeneity**.

An independent respiratory-infection cohort, GSE161731, contains
count-level RNA-seq data from bacterial pneumonia, influenza, seasonal
coronavirus and healthy controls, in addition to COVID-19 samples. This
provides a technically accessible external testing environment in which
a discovery-defined bacterial-versus-viral program can be projected
without retuning. GSE261482 extends the design into pediatric pneumonia,
allowing an exploratory test of age- and syndrome-generalizability.
GSE282464 is potentially valuable as a later large-scale extension, but
will remain conditional until its accessible series structure and
associated clinical metadata are fully reconciled.

This strategy deliberately differs from the crowded
bacterial-versus-viral diagnostic-signature field. Ko et al. developed
global fever host-response classifiers using GSE211567, and Falsey et
al. later developed and validated a parsimonious bacterial-exclusion
signature across multiple adult and pediatric RNA-seq cohorts, including
several datasets under consideration here. A further classifier-only
analysis would therefore offer limited novelty. The scientifically
stronger question is whether the **biological architecture** of
bacterial-versus-viral host response is transportable across distinct
pathogen ecologies and populations.

# 2. Study rationale and publication position

## 2.1 Gap to be addressed

Existing transcriptomic studies have convincingly shown that bacterial
and viral infections can be discriminated using host-gene expression.
However, diagnostic performance does not by itself reveal:

1.  which immune-metabolic pathways represent a conserved
    bacterial-versus-viral host-response core;
2.  which pathway signals are specific to a pathogen ecology, geographic
    setting, respiratory syndrome or age group;
3.  whether pathway/module behavior remains interpretable when
    transported between heterogeneous cohorts and assay structures; and
4.  whether apparently strong gene-level discrimination masks biological
    non-transportability of broader functional programs.

## 2.2 Intended scientific contribution

The intended paper will contribute a reproducible framework that
separates:

- **conserved bacterial-oriented modules**, stable across
  within-discovery settings and external projection;
- **conserved viral-oriented modules**, similarly stable across
  contexts;
- **context-specific modules**, reproducible within a setting but not
  broadly transportable;
- **discordant or technically nonportable modules**, which should not be
  interpreted as universal host-response biology.

## 2.3 Explicit non-objectives

This project will not be designed to:

- create another primary small-gene bacterial-versus-viral diagnostic
  classifier;
- claim clinical diagnostic readiness;
- claim a universal bacterial or viral host signature without concordant
  external evidence;
- conflate pathway association with cell-specific mechanism;
- merge heterogeneous cohorts into a single pooled model without first
  testing transportability and compatibility;
- use the external cohorts to select or optimize discovery modules.

# 3. Objectives, aims and hypotheses

## 3.1 Overall objective

To define and externally test conserved versus pathogen-ecology-specific
whole-blood immune-metabolic programs associated with acute bacterial
compared with viral infection using independent publicly available human
RNA-sequencing cohorts.

## 3.2 Specific aims

### Aim 1. Establish a reproducible, metadata-controlled transcriptomic analysis framework for public host-pathogen whole-blood RNA-seq studies.

This aim will retrieve, verify and audit the candidate datasets,
expression matrices, metadata fields, sample eligibility, data
structure, study-site representation, technical platforms and
reproducibility constraints. It will also establish the GitHub
repository, decision log, file manifests and analysis environment.

**Deliverable:** A locked dataset-feasibility and analysis-eligibility
report before inferential analyses.

### Aim 2. Discover bacterial-versus-viral immune-metabolic pathway programs in the global acute-febrile-illness cohort GSE211567.

GSE211567 will be used as the scientific discovery cohort. The primary
discovery contrast will evaluate bacterial versus viral infection among
eligible adjudicated infection cases. A critical internal heterogeneity
assessment will examine direction and effect consistency across United
States and Sri Lankan settings, as permitted by the confirmed metadata.

**Deliverable:** A directionally audited pathway landscape and a
prespecified set of candidate stable biological modules.

### Aim 3. Freeze a compact, biologically interpretable core module program before external testing.

Modules will be selected from pathways meeting predefined statistical,
direction-consistency and representation criteria. No external cohort
outcome will influence module selection, orientation or weighting.

**Deliverable:** A machine-readable frozen module-definition file and
module-lock report.

### Aim 4. Test adult external transportability in an independent respiratory infection cohort, GSE161731.

The discovery-locked module program will be projected into adult
bacterial pneumonia versus non-COVID viral respiratory infection
samples. An assay/feature-portability gate will precede external
scoring. Directional replication and composite/module behavior will be
interpreted primarily as biological transportability, with
discrimination metrics considered secondary.

**Deliverable:** Primary adult external transportability results.

### Aim 5. Explore age- and syndrome-generalizability in pediatric pneumonia using GSE261482.

Only after the module program is frozen and assessed in the adult
external cohort will it be examined in definitive pediatric bacterial
versus definitive pediatric viral pneumonia.

**Deliverable:** Exploratory pediatric generalizability analysis with
explicit small-viral-group limitations.

### Aim 6. Evaluate a conditional large-scale extension using GSE282464 only if feasibility conditions are met.

GSE282464 may support further transportability analysis in contemporary
respiratory infection/sepsis settings. It will be incorporated only
after verifying the available sample composition, metadata, diagnostic
labels, longitudinal structure and independence from previously used
samples.

**Deliverable:** A formal include/exclude decision; analysis only if the
prespecified audit passes.

## 3.3 Hypotheses

| **Hypothesis** | **Statement**                                                                                                                                        | **Interpretation if supported**                                                                          |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| H1             | A subset of bacterial-versus-viral Reactome pathways will show concordant direction across internally separable infection settings within GSE211567. | Evidence for a conserved functional core despite differing pathogen ecologies.                           |
| H2             | A frozen subset of discovery-defined modules will retain direction in adult respiratory bacterial-versus-viral comparison in GSE161731.              | Evidence for cross-cohort biological transportability.                                                   |
| H3             | Some discovery modules will fail transportability or show context-dependent behavior.                                                                | Evidence that broad host-response interpretation must account for pathogen ecology and cohort structure. |
| H4             | Adult-derived modules will demonstrate incomplete or attenuated transportability in pediatric pneumonia.                                             | Evidence for age/syndrome modulation rather than universal biological generalization.                    |

# 4. Study design

## 4.1 Overall design

This is a staged, retrospective secondary analysis of de-identified
public whole-blood RNA-seq datasets. The core scientific design is:

**Discovery in global acute febrile illness → internal
context-concordance testing → pathway/module lock → adult respiratory
external transportability → exploratory pediatric generalizability →
conditional large-cohort extension.**

## 4.2 Design principles

1.  **Biology before prediction:** pathway/module organization is
    primary; classifier construction is not the project goal.
2.  **No data leakage:** external cohorts will not be examined for
    module-selection decisions before the discovery program is locked.
3.  **Context awareness:** geographic and syndrome contexts will be
    interrogated rather than treated as nuisance alone.
4.  **Assay portability before interpretation:** module feature
    representation must be evaluated before external module scores are
    interpreted.
5.  **Reproducible provenance:** all source files, metadata decisions,
    scripts, session information and checksum manifests will be version
    controlled or documented.
6.  **Interpretive restraint:** whole-blood modules will be interpreted
    as systemic programs and not as proof of cell-specific mechanisms.

# 5. Public datasets and prespecified analytical roles

## 5.1 Dataset architecture

| **Dataset** | **Public resource description**                                                                                                                                                                      | **Current verified availability**                                                           | **Prespecified project role**                                                                          | **Inclusion status**                                              |
|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| GSE211567   | Whole-blood RNA-seq of acute febrile illness from the United States and Sri Lanka; bacterial, viral and noninfectious illnesses; GEO describes 294 RNA-sequenced tubes but lists 291 series samples. | Processed normalized-expression file on GEO; raw sequencing available through SRA.          | **Primary scientific discovery** and internal context-concordance analysis.                            | Included, subject to metadata and sample-count reconciliation.    |
| GSE161731   | Peripheral-blood RNA-seq comparing COVID-19 with seasonal coronavirus, influenza, bacterial pneumonia and healthy controls; GEO lists 198 samples.                                                   | Raw-count file, count-key file, sample-key file and normalized files publicly downloadable. | **Primary adult external transportability cohort**; also usable for technical workflow rehearsal only. | Included.                                                         |
| GSE261482   | Whole-blood pediatric pneumonia RNA-seq; study description includes 192 samples, while GEO lists 177; definitive bacterial n=40 and definitive viral n=9 reported in GEO description.                | Raw-count and normalized-expression files publicly downloadable.                            | Exploratory pediatric generalizability extension.                                                      | Conditional included after metadata/sample reconciliation.        |
| GSE282464   | Large multi-center respiratory-infection/sepsis transcriptome resource; publication describes 502 participants and 681 samples, while GEO currently lists 377 series samples.                        | GEO count archive available; additional clinical data described by source publication.      | Conditional later extension only.                                                                      | Not included in primary analyses unless feasibility audit passes. |

## 5.2 Primary discovery dataset: GSE211567

### Prespecified use

GSE211567 will be used to establish bacterial-versus-viral pathway
programs and to identify pathways whose direction is stable across
distinguishable infection contexts. Its inclusion is justified by the
breadth of acute febrile pathogen classes and its representation of both
United States and Sri Lankan settings.

### Important audit requirements

Before inferential modeling, the following must be resolved and
documented:

- why GEO describes 294 RNA-sequenced samples but lists 291 series
  samples;
- final number of samples with complete infection-class, study-site and
  required covariate information;
- exact pathogen-class definitions and the presence/absence of
  co-infection or uncertain diagnoses;
- whether the normalized expression file permits appropriately
  controlled limma modeling;
- whether raw-read re-quantification from SRA is feasible and
  scientifically necessary.

### Expression-data strategy

The primary protocol allows two mutually exclusive discovery processing
branches:

- **Branch A: processed-matrix analysis.** If the normalized matrix is
  adequately documented, complete and compatible with linear modeling,
  it will be analyzed with limma using the supplied expression scale and
  appropriate design covariates.
- **Branch B: raw-read re-quantification.** If the processed matrix is
  unsuitable for the planned model, raw reads will be retrieved and
  quantified using a single standardized pipeline, after which
  edgeR/limma-voom will be applied.

The branch choice must be recorded **before** differential-expression
and pathway results are interpreted. Results from incompatible
processing branches will not be mixed into a single inferential model.

## 5.3 Primary external cohort: GSE161731

The primary validation comparison will use non-COVID acute respiratory
infection groups:

- bacterial pneumonia: n=20 as described by GEO;
- influenza: n=17;
- seasonal coronavirus: n=59;
- healthy controls: n=19, for biological orientation only.

COVID-19 samples will not be included in the primary
bacterial-versus-non-COVID-viral external contrast because the cohort
was designed around COVID-19 biology and includes repeated sampling of
some COVID-19 participants. COVID-19 may be examined later as an
exploratory comparator after primary analyses are locked.

Because raw counts and sample keys are available, GSE161731 will be used
to master the count-level edgeR/limma-voom workflow. Importantly, such
technical rehearsal must not influence the selection or orientation of
discovery modules.

## 5.4 Pediatric extension: GSE261482

The pediatric extension will be limited to the etiologically defined
comparison described in the GEO record:

- definitive bacterial pneumonia: n=40;
- definitive viral pneumonia: n=9.

The small definitive viral group makes this an exploratory
direction/generalizability analysis rather than an independent
confirmatory replication. Any null or unstable results will be
interpreted in the context of limited power and population differences.

## 5.5 Conditional extension: GSE282464

GSE282464 will not enter the primary protocol analysis until a dedicated
audit resolves:

- the relationship between the 502 participants/681 samples described in
  the Scientific Data publication and the 377 GEO-listed samples;
- which infection categories are represented in the downloadable GEO
  count archive;
- whether baseline/independent samples can be defined without
  longitudinal duplication;
- whether bacterial-versus-viral comparisons are sufficiently powered
  and clinically interpretable;
- whether any samples overlap with prior cohorts used in the study.

# 6. Eligibility criteria

## 6.1 Dataset-level eligibility

A dataset will be eligible for primary or secondary
module-transportability analysis if it meets all relevant criteria:

| **Criterion**            | **Required for primary/secondary inclusion**                                                                                                               |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Human study              | Yes                                                                                                                                                        |
| Transcriptomic material  | Whole blood or peripheral blood RNA-seq; PBMC-only datasets are excluded from the core analysis unless introduced as explicitly separate exploratory work. |
| Infection classification | A clearly documented bacterial and viral group, with diagnosis/etiology definitions available.                                                             |
| Data availability        | Downloadable processed expression matrix or raw count matrix and adequate metadata for sample-class assignment.                                            |
| Sample independence      | Ability to identify independent participants or select a prespecified baseline sample where repeated measures occur.                                       |
| Biological relevance     | Acute infection or clinically relevant infection-response state.                                                                                           |
| External-use suitability | For projection cohorts, adequate feature overlap with frozen discovery modules.                                                                            |

## 6.2 Sample-level inclusion criteria

Samples will be included if they:

- represent human peripheral/whole blood transcriptomics;
- have sufficient diagnostic label to place them into the relevant
  prespecified comparison group;
- have a usable expression profile after technical quality assessment;
- are independent observations for the primary contrast, or can be
  reduced to a prespecified baseline/first sample for repeated-measures
  datasets;
- meet any dataset-specific eligibility rules defined before outcome
  testing.

## 6.3 Sample-level exclusion criteria

Samples will be excluded from primary contrasts if they are:

- labelled as ambiguous, unknown, mixed infection or co-infection unless
  incorporated in an explicitly separate exploratory analysis;
- missing the key bacterial/viral group label;
- technical failures or extreme quality-control outliers according to
  prespecified criteria;
- repeated follow-up samples when a baseline-only cross-sectional
  primary model is used;
- COVID-19 samples in the primary GSE161731 adult
  bacterial-versus-non-COVID-viral external analysis.

## 6.4 Control and comparator use

Healthy or noninfectious illness groups will not be combined with
bacterial or viral cases in the primary etiologic contrast. They will be
used for contextual analyses such as:

- direction relative to noninfectious baseline;
- identifying inflammation shared by both bacterial and viral disease;
- distinguishing infection-generic from etiologically oriented modules.

# 7. Operational definitions and analysis outcomes

## 7.1 Infection group orientation

For every bacterial-versus-viral contrast, effect direction will be
oriented as:

**Positive log2 fold-change or positive normalized enrichment score
(NES) = higher in bacterial infection relative to viral infection.**

**Negative log2 fold-change or negative NES = higher in viral infection
relative to bacterial infection.**

This direction convention must be maintained across all datasets,
scripts, tables and figures.

## 7.2 Primary outcome

The primary outcome is **pathway-level directional transportability** of
discovery-defined immune-metabolic programs from GSE211567 into
GSE161731.

## 7.3 Secondary outcomes

Secondary outcomes include:

- number of statistically supported bacterial-oriented and
  viral-oriented pathways in discovery;
- direction and effect concordance across United States and Sri Lankan
  discovery strata;
- feature representation and scoreability of frozen modules in
  GSE161731;
- module-level direction and composite-score association in external
  adult respiratory infection;
- descriptive discrimination metrics, including AUC, only as secondary
  evidence of module separation.

## 7.4 Exploratory outcomes

Exploratory outcomes include:

- module direction in pediatric definitive bacterial versus viral
  pneumonia;
- module behavior relative to healthy controls or noninfectious illness
  controls;
- behavior of frozen modules in COVID-19 or conditional GSE282464
  analyses;
- deconvolution-informed interpretation of broad cell-composition
  patterns, if technically supported and clearly labeled as exploratory.

# 8. Prespecified methodological workflow

## Phase 0. Project registration and repository initiation

### Purpose

Create a clean project environment separated from all other manuscripts
and analyses.

### Tasks

- Create a dedicated ChatGPT project panel using this protocol as
  foundational context.
- Initialize a dedicated GitHub repository.
- Store the protocol in both DOCX and Markdown formats.
- Create a decision log, protocol amendment log and dataset manifest.
- Commit the protocol before downloading or analyzing project-specific
  data.

### Outputs

- `PROTOCOL/Host_Pathogen_Transcriptomics_Transportability_Protocol_v1.0_2026-05-29.md`
- `PROTOCOL/Host_Pathogen_Transcriptomics_Transportability_Protocol_v1.0_2026-05-29.docx`
- `docs/decision_log.md`
- `docs/protocol_amendments.md`
- Git commit recording protocol initialization.

## Phase 1. Public-data acquisition and provenance audit

### Purpose

Establish a verifiable source record for every candidate dataset.

### Tasks

For each accession:

- retrieve GEO series metadata;
- record GEO accession, BioProject/SRA relationship, platform and
  downloadable file names;
- download processed/count files where provided;
- generate SHA-256 checksums;
- retrieve the primary publication and any key subsequent uses;
- record sample-count discrepancies between publication, GEO description
  and downloadable matrix;
- record whether access is unrestricted and whether all required
  metadata are available.

### Outputs

- `metadata/source_registry.tsv`
- `metadata/dataset_feasibility_audit.xlsx` or `.tsv`
- `data/raw/checksums_sha256.txt`
- `docs/literature_novelty_audit.md`

## Phase 2. Metadata harmonization and participant-flow audit

### Purpose

Construct clean analytical metadata without making inferential decisions
from the expression results.

### Tasks

For each cohort:

- extract sample identifiers;
- harmonize diagnosis labels;
- classify infection as bacterial, viral, noninfectious, healthy,
  COVID-19, mixed/co-infection, ambiguous or excluded;
- identify study site, country, age/age group, sex, clinical severity,
  timepoint and technical variables where available;
- identify repeated participants or longitudinal samples;
- define the primary-analysis sample subset and any sensitivity subsets;
- generate a participant/sample flow table.

### Outputs

- one harmonized metadata file per cohort;
- exclusion-reason table;
- sample-flow diagram/table;
- locked primary contrast definitions.

## Phase 3. Expression-matrix audit and processing-branch decision

### Purpose

Ensure that expression values are technically appropriate for each
model.

### GSE211567 decision

The normalized expression matrix will be inspected for:

- gene identifier format;
- sample identifiers matching metadata;
- transformation and normalization description;
- missingness and duplicated genes/samples;
- distribution and suitability for linear modeling.

If the matrix is appropriate, limma modeling will proceed on the
normalized expression values. If not, raw-read re-quantification will be
considered, with the decision documented before pathway interpretation.

### GSE161731 and GSE261482 processing

Because raw-count files are publicly available, the planned count-level
process is:

1.  import count matrix and metadata;
2.  harmonize gene identifiers;
3.  remove duplicated or unmapped identifiers according to a documented
    rule;
4.  construct a design matrix;
5.  filter weakly expressed genes using `edgeR::filterByExpr`;
6.  normalize library sizes using trimmed mean of M values (TMM);
7.  evaluate mean-variance structure using `limma::voom`;
8.  fit linear models and apply empirical Bayes moderation.

### Outputs

- matrix audit report for each dataset;
- documented processing branch for GSE211567;
- count-processing objects and QC plots for count-level datasets.

## Phase 4. Quality control and sample integrity assessment

### Purpose

Detect technical anomalies while preventing outcome-driven sample
removal.

### QC components

- library-size and count-distribution evaluation for raw-count datasets;
- multidimensional scaling or principal-component analysis;
- sample-sample correlation assessment;
- clustering annotated by diagnostic class, site, platform, sex, age
  group and other available covariates;
- inspection of possible outliers;
- examination of batch/site structure and possible confounding.

### Outlier policy

No sample will be excluded solely because it weakens an anticipated
biological conclusion. A sample may be excluded from a sensitivity
analysis when it is a strong technical or metadata-supported outlier.
The primary model will retain eligible samples unless exclusion is
justified before inferential interpretation. All exclusions and
sensitivity decisions will be logged.

### Outputs

- QC report and figures;
- outlier/sensitivity decision log;
- final analysis-ready metadata table.

## Phase 5. Primary discovery modeling in GSE211567

### Primary contrast

Eligible bacterial infection samples versus eligible viral infection
samples.

### Discovery models

Subject to metadata availability, the following sequence will be used:

1.  **Global primary model:** bacterial versus viral infection using all
    eligible adjudicated infection samples, adjusting for justified
    available covariates.
2.  **Within-setting models:** bacterial versus viral contrasts run
    separately within United States and Sri Lankan settings, if each
    setting has sufficient group size and unambiguous etiologic labels.
3.  **Contextual analyses:** bacterial and viral groups each compared
    with noninfectious illness controls, where this helps distinguish
    infection-generic inflammation from etiologically oriented biology.

### Covariate policy

Covariates will be included only if they are available, adequately
represented and not structurally inseparable from infection class.
Candidate covariates include study site, sex, age or age group,
sequencing platform/batch and clinical severity. Covariate decisions
will be documented before results interpretation.

### Outputs

- gene-level statistics for each discovery model;
- pathway-ranking inputs;
- contrast and covariate decision report.

## Phase 6. Ranked pathway enrichment and internal concordance testing

### Pathway analysis

Ranked enrichment will use moderated gene-level statistics and curated
Reactome pathways. Identifier mapping and duplicate-resolution rules
will be locked before enrichment.

### Stable pathway criteria

A discovery pathway will be eligible for stable-module consideration if
it:

- is represented by an adequate number of mapped genes;
- reaches the prespecified multiple-testing threshold in the global
  discovery analysis;
- shows the same biological direction in the internal within-setting
  analyses where estimable;
- does not depend entirely on one technical or etiologic subgroup in
  sensitivity evaluation.

### Internal concordance metrics

- correlation of pathway NES values across United States and Sri Lankan
  contrasts;
- proportion of pathways sharing direction;
- classification of pathways as conserved, context-specific or
  discordant;
- representative visualization of conserved and discordant biological
  domains.

### Outputs

- ranked pathway-results files;
- within-setting concordance table;
- stable pathway candidate list.

## Phase 7. Biological module definition and lock

### Purpose

Define a compact, interpretable program before examining its behavior in
external cohorts.

### Module-selection principles

Representative modules will be chosen from stable pathways to cover
nonredundant domains such as:

- interferon/antiviral signaling;
- neutrophil and antimicrobial effector programs;
- complement/Fc-receptor or coagulation/vascular biology;
- antigen presentation/adaptive immune organization;
- mitochondrial, metabolic or translational stress;
- programmed cell death/repair;
- cytokine/NF-κB-associated inflammatory regulation.

### Module-lock requirements

The lock file will contain:

- module name;
- Reactome pathway identifier and pathway label;
- discovery direction;
- mapped gene set;
- scoring orientation;
- pathway-selection justification;
- overlap/redundancy rationale;
- date locked and Git commit hash.

No module will be reselected, reweighted or direction-flipped on the
basis of external-cohort results.

### Outputs

- `results/module_lock/frozen_module_definitions.tsv`
- `results/module_lock/module_lock_report.md`
- Git commit marking the pre-validation lock.

## Phase 8. External adult respiratory transportability test in GSE161731

### Primary comparison

Bacterial pneumonia versus non-COVID viral respiratory infection, where
viral infection includes influenza and seasonal coronavirus samples
eligible under the metadata audit.

### Assay/feature-portability gate

Before scoring:

- determine the number and proportion of frozen module genes represented
  in the GSE161731 matrix;
- exclude or flag modules with inadequate feature representation
  according to a prespecified threshold finalized before outcome
  scoring;
- report all retained and nonportable modules transparently.

### Primary external measures

- direction of each retained module;
- concordance between discovery and external effect orientation;
- association of a composite oriented module score with bacterial versus
  viral status;
- secondary AUC or descriptive separation measures, explicitly not
  claimed as clinical classifier validation.

### Sensitivity analyses

- bacterial pneumonia versus influenza only;
- bacterial pneumonia versus seasonal coronavirus only;
- exclusion of any technical outlier identified independently of module
  scores;
- optional contextual comparison to healthy controls.

### Outputs

- portability audit table;
- external module-score table;
- adult transportability figures and results narrative.

## Phase 9. Exploratory pediatric generalizability in GSE261482

### Primary pediatric comparison

Definitive bacterial versus definitive viral pediatric pneumonia.

### Analytical rules

- use the already frozen adult/global discovery modules;
- perform a feature-portability gate before interpretation;
- interpret direction and effect patterns cautiously because the viral
  group is small;
- do not optimize modules using pediatric data;
- do not present the pediatric result as definitive independent
  validation unless the final metadata audit supports sufficient
  inference.

### Outputs

- pediatric portability and direction-concordance table;
- exploratory figure and limitations statement.

## Phase 10. Conditional GSE282464 extension

### Entry criteria

The dataset will enter analysis only if:

- diagnostic groups relevant to the biological question are clearly
  identifiable;
- independent samples or appropriately selected baseline samples can be
  defined;
- count matrix and metadata can be reliably linked;
- discrepancies between the publication-described cohort and
  GEO-displayed samples are resolved or adequately explained;
- no design issue prevents interpretable bacterial-versus-viral or
  module-transportability analysis.

### Outputs

- include/exclude audit memorandum;
- if included, prespecified extension analysis using frozen modules
  only.

## Phase 11. Integrated interpretation and manuscript preparation

### Interpretation framework

Results will be summarized using four categories:

| **Result category**                                  | **Meaning**                                                                                            |
|------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Conserved and transportable                          | Same direction internally and externally with adequate feature representation; candidate core biology. |
| Internally conserved but externally nontransportable | Stable within discovery but not represented or not replicated in external assay/context.               |
| Context-specific                                     | Appears in one discovery setting but not another; likely ecology-, syndrome- or population-dependent.  |
| Discordant                                           | Opposite directions or unstable results; should not support generalized biological claims.             |

### Planned manuscript structure

1.  Introduction: biology of bacterial-versus-viral host response and
    the need to separate diagnostic prediction from functional
    transportability.
2.  Methods: staged discovery, module-lock and external-projection
    design.
3.  Results:
    - cohort and metadata feasibility;
    - discovery differential-expression and pathway landscape;
    - within-discovery context concordance;
    - frozen-module definition;
    - adult external transportability;
    - pediatric/conditional extensions;
    - integrated interpretation.
4.  Discussion: conserved immune-metabolic biology, context specificity,
    technical transportability, implications and limitations.
5.  Reproducibility and data availability statement.

# 9. Detailed statistical analysis plan

## 9.1 Software environment

Primary analyses will be conducted in R using a locked environment.
Expected packages include:

- `edgeR` for count filtering and TMM normalization;
- `limma` for voom precision weighting, linear modeling and empirical
  Bayes moderation;
- `fgsea` for ranked pathway enrichment;
- `msigdbr` or appropriately verified Reactome gene-set retrieval;
- `AnnotationDbi`, `org.Hs.eg.db`, `biomaRt` or equivalent documented
  mapping approach;
- `ggplot2`, `ComplexHeatmap` and related packages for figures;
- `pROC` only for secondary descriptive discrimination metrics;
- `renv` for R-environment reproducibility.

Versions will be recorded in the analysis repository using
`sessionInfo()` and/or `renv.lock`.

## 9.2 Gene identifier harmonization

The protocol will use a reproducible mapping procedure:

1.  identify the source identifier type for each matrix;
2.  remove Ensembl version suffixes when applicable;
3.  map identifiers to HGNC symbols or stable identifiers required for
    pathway analysis;
4.  retain a documented rule for duplicate mapped identifiers, such as
    keeping the feature with the largest absolute moderated statistic at
    pathway-ranking stage;
5.  generate mapping audit tables containing mapped, unmapped and
    duplicated identifiers.

## 9.3 Differential-expression modeling

### Count-level cohorts

For GSE161731, GSE261482 and any included count-level extension:

- apply `filterByExpr` using the prespecified design;
- calculate TMM normalization factors;
- perform `voom` modeling;
- fit contrasts using `lmFit`, `contrasts.fit` and `eBayes`;
- report log2 fold-change, moderated statistic, nominal P value and
  Benjamini-Hochberg false discovery rate.

### Normalized-matrix discovery cohort

For GSE211567, if the processed normalized matrix is selected after
audit:

- verify expression scale and distribution;
- perform limma modeling appropriate to normalized continuous expression
  values;
- do not apply count-specific normalization procedures to normalized
  data;
- record this processing distinction prominently in methods and
  limitations.

If raw-read re-quantification is selected, count-level modeling will be
used consistently for discovery.

## 9.4 Multiple-testing control

Gene-level and pathway-level analyses will use Benjamini-Hochberg false
discovery rate adjustment. The study will emphasize ranked pathway
concordance rather than rely exclusively on individual gene
significance.

## 9.5 Pathway enrichment

- Gene ranks will be based on moderated test statistics for bacterial
  versus viral contrast.
- Reactome gene sets will be used as the primary pathway knowledgebase.
- Pathway size thresholds will be prespecified after identifier mapping
  inspection, provisionally 15 to 500 represented genes.
- Enrichment outputs will include NES, nominal P value, adjusted P
  value, mapped feature count and leading-edge representation where
  available.

## 9.6 Internal discovery stability criteria

A pathway may be called **internally conserved** only when:

- direction is the same in the global discovery model and both
  setting-specific models, when both setting-specific models are
  estimable;
- it has adequate feature representation;
- its signal is not eliminated solely by a justified sensitivity
  analysis;
- its biological interpretation is not redundant with a more strongly
  supported equivalent pathway selected for module representation.

Because final sample distributions are pending audit, the precise
statistical significance threshold for setting-specific stability will
be locked after sample-size review and before external testing. If a
setting-specific model is underpowered, direction concordance rather
than significance will be treated as the principal stability criterion
and this limitation will be stated.

## 9.7 Module scoring

For each retained module:

- gene expression will be standardized within each external cohort
  without using outcome-based feature selection;
- gene directions will be oriented according to discovery;
- a module score will summarize oriented expression across represented
  genes;
- a composite program score may average retained oriented module scores
  after the feature-portability gate.

The final scoring algorithm will be stored in a locked script before
external interpretation.

## 9.8 Feature-portability gate

Before any external score is interpreted, each module will be assessed
for:

- number of discovery module genes available in the external matrix;
- proportion of discovery genes represented;
- evidence of gene-identifier compatibility;
- any gross assay limitation affecting module interpretation.

A provisional retainability threshold is at least 60% representation of
discovery-module genes and at least 20 available genes, but this will be
finalized in the module-lock document before external scoring, guided by
module sizes and without examining bacterial-versus-viral external
outcomes.

## 9.9 Transportability metrics

Primary metrics:

- same-direction module count and proportion;
- correlation of pathway/module effect estimates between discovery and
  external cohort;
- external retained-module score contrast between bacterial and viral
  infection.

Secondary metrics:

- AUC of the locked composite score;
- effect consistency in pathogen-specific external sensitivity
  contrasts.

Diagnostic metrics will be reported as descriptive rather than used to
assert clinical utility.

## 9.10 Sensitivity analyses

Planned sensitivity analyses include:

- site-stratified discovery contrasts;
- removal of ambiguous or mixed infection groups;
- adjustment for available age, sex, platform or severity variables
  where defensible;
- technical-outlier sensitivity analysis;
- separate adult bacterial-versus-influenza and
  bacterial-versus-seasonal-coronavirus external analyses;
- pediatric extension analyzed separately from adults;
- COVID-19 considered separately only after the primary non-COVID
  analysis.

# 10. Planned tables and figures

## 10.1 Planned main tables

| **Table** | **Proposed content**                                                                            |
|-----------|-------------------------------------------------------------------------------------------------|
| Table 1   | Public datasets, populations, assay structures and prespecified analytical roles.               |
| Table 2   | Sample eligibility, exclusions, metadata availability and final contrasts.                      |
| Table 3   | Discovery-defined stable pathway modules and module-lock criteria.                              |
| Table 4   | External assay-portability audit and adult respiratory transportability results.                |
| Table 5   | Integrated classification of modules as conserved, context-specific, nonportable or discordant. |

## 10.2 Planned main figures

| **Figure** | **Proposed content**                                                                             |
|------------|--------------------------------------------------------------------------------------------------|
| Figure 1   | Study design, dataset roles, discovery-to-validation firewall and module-lock workflow.          |
| Figure 2   | Discovery cohort QC, differential-expression overview and Reactome pathway landscape.            |
| Figure 3   | United States versus Sri Lanka within-discovery pathway-direction concordance and heterogeneity. |
| Figure 4   | Frozen module program and adult external transportability in GSE161731.                          |
| Figure 5   | Exploratory pediatric generalizability and integrated biological interpretation model.           |

## 10.3 Planned supplementary outputs

- complete metadata audit tables;
- quality-control reports;
- complete gene-level model statistics;
- complete pathway enrichment outputs;
- frozen module definitions;
- feature-portability reports;
- sensitivity-analysis outputs;
- session information and checksums;
- analysis scripts and README.

# 11. Reproducibility, GitHub and project governance

## 11.1 Repository structure

    host-pathogen-transcriptome-transportability/
    ├── README.md
    ├── LICENSE
    ├── .gitignore
    ├── PROTOCOL/
    │   ├── Host_Pathogen_Transcriptomics_Transportability_Protocol_v1.0_2026-05-29.md
    │   └── Host_Pathogen_Transcriptomics_Transportability_Protocol_v1.0_2026-05-29.docx
    ├── data/
    │   ├── raw/                         # ignored by Git when large; source links/checksums retained
    │   ├── metadata_raw/
    │   ├── metadata_harmonized/
    │   └── processed/
    ├── docs/
    │   ├── decision_log.md
    │   ├── protocol_amendments.md
    │   ├── dataset_feasibility_audit.md
    │   ├── novelty_audit.md
    │   ├── analysis_log.md
    │   └── software_versions.md
    ├── scripts/
    │   ├── R/
    │   │   ├── 00_setup_environment.R
    │   │   ├── 01_download_and_manifest.R
    │   │   ├── 02_metadata_audit.R
    │   │   ├── 03_expression_matrix_audit.R
    │   │   ├── 04_qc_and_filtering.R
    │   │   ├── 05_discovery_models_GSE211567.R
    │   │   ├── 06_pathway_enrichment.R
    │   │   ├── 07_module_lock.R
    │   │   ├── 08_external_transport_GSE161731.R
    │   │   ├── 09_pediatric_extension_GSE261482.R
    │   │   └── 10_conditional_extension_GSE282464.R
    │   └── bash/
    ├── results/
    │   ├── qc/
    │   ├── differential_expression/
    │   ├── pathway_enrichment/
    │   ├── module_lock/
    │   ├── transportability/
    │   ├── sensitivity/
    │   ├── tables/
    │   └── figures/
    ├── manuscript/
    │   ├── main_text/
    │   ├── supplementary_material/
    │   └── references/
    └── env/
        ├── renv.lock
        └── session_info/

## 11.2 Version-control rules

- Commit the protocol before project-specific data analysis begins.
- Do not commit large raw sequencing/expression files unless appropriate
  for Git LFS; instead retain source URLs, file names and checksums.
- Commit metadata harmonization rules, scripts, module-lock files and
  generated summary results.
- Create a Git tag when the module program is locked before external
  projection.
- Any change after module lock that affects primary interpretation must
  be recorded as a protocol amendment.

## 11.3 Data provenance and checksum rules

Every retrieved public file will be recorded with:

- accession;
- exact downloaded filename;
- date retrieved;
- source repository;
- checksum;
- processing status;
- script producing derived files.

## 11.4 Reproducible environment

The project will use `renv` for R dependency control. Every analysis
milestone will save:

- `sessionInfo()` output;
- key input checksums;
- a timestamped log;
- resulting tables and figures;
- Git commit hash.

# 12. Quality assurance and analysis firewall

## 12.1 Discovery-validation firewall

The following rules are mandatory:

1.  GSE211567 determines candidate pathways and frozen modules.
2.  GSE161731 may be used before discovery only for technical training
    in count-level processing, not for selecting biology.
3.  External outcome patterns must not alter the discovery-defined
    module list or orientation.
4.  Pediatric and conditional extension findings must be labeled
    exploratory unless a separate confirmatory design is prospectively
    specified.
5.  A failed external transportability result is scientifically valid
    and must not be “rescued” by post hoc module redesign.

## 12.2 Decision-log triggers

A decision log entry is required for:

- sample exclusions;
- processing-branch choice for GSE211567;
- covariate inclusion or omission;
- pathway-database or pathway-size rule;
- module lock;
- portability threshold finalization;
- addition or removal of extension datasets;
- any deviation from this protocol.

# 13. Ethical, data-use and reporting considerations

All datasets are publicly accessible, de-identified human transcriptomic
resources generated under the ethical approvals of the original studies.
This project will not involve new participant recruitment, specimen
acquisition or intervention. Ethical approvals and consent remain those
reported by the original investigators.

The project will:

- cite original dataset generators and publications;
- comply with repository data-use terms;
- avoid re-identification attempts;
- report use of public human data transparently;
- state the use of computational assistance or generative artificial
  intelligence in manuscript preparation according to target-journal
  policy, while ensuring that all analytical results are independently
  verified against executable scripts and output files.

# 14. Risks, constraints and mitigation plan

| **Risk or constraint**                                                                               | **Consequence**                                                                  | **Mitigation**                                                                                                       |
|------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| GSE211567 provides normalized expression on GEO rather than an immediately visible raw-count matrix. | Discovery modeling may not exactly mirror count-level edgeR/voom workflow.       | Audit the normalized matrix; decide prospectively between appropriate limma analysis and raw-read re-quantification. |
| Site and pathogen type may be strongly related in GSE211567.                                         | “Site-adjusted” estimates may be uninterpretable or biologically overcontrolled. | Treat site-stratified direction concordance as a central biological test; avoid unjustified pooled correction.       |
| Existing bacterial-versus-viral classifier literature is strong.                                     | Limited novelty for classifier-focused paper.                                    | Keep primary focus on functional module transportability and context specificity.                                    |
| GSE161731 was generated around COVID-19 and contains repeated COVID samples.                         | COVID may dominate signals and complicate primary comparisons.                   | Restrict primary external test to bacterial pneumonia versus non-COVID viral ARI; handle COVID separately.           |
| Pediatric definitive viral sample size is small in GSE261482.                                        | Low power and unstable estimates.                                                | Treat as exploratory direction/generalizability analysis only.                                                       |
| GSE282464 sample-count discrepancy and complex cohort structure.                                     | Potentially invalid extension if used prematurely.                               | Require a separate feasibility gate before inclusion.                                                                |
| Whole-blood pathway signals may reflect cell composition.                                            | Mechanistic overinterpretation risk.                                             | Interpret as systemic transcriptomic programs; consider deconvolution only as exploratory support.                   |

# 15. Milestones and stopping rules

## 15.1 Milestones

| **Milestone**                     | **Completion criterion**                                                                                         |
|-----------------------------------|------------------------------------------------------------------------------------------------------------------|
| M1: Protocol and repository setup | Protocol committed to GitHub; decision and amendment logs created.                                               |
| M2: Dataset feasibility audit     | Source files, metadata, discrepancies and primary contrasts documented.                                          |
| M3: Technical workflow mastery    | GSE161731 count-level QC and modeling pipeline successfully executed without using results for module selection. |
| M4: Discovery analysis            | GSE211567 modeling branch selected and primary/pathway results generated.                                        |
| M5: Module lock                   | Frozen module file committed and Git-tagged before external interpretation.                                      |
| M6: Adult transportability        | GSE161731 portability gate and external results completed.                                                       |
| M7: Pediatric extension           | GSE261482 exploratory analysis completed or justified as unsuitable.                                             |
| M8: Manuscript drafting           | Integrated results, figures, tables and reproducibility supplement ready.                                        |

## 15.2 Stopping or redesign rules

The project will pause for redesign if:

- discovery metadata do not support a defensible bacterial-versus-viral
  or within-setting comparison;
- expression data cannot be analyzed with adequately documented
  processing;
- no biologically meaningful, internally stable module program can be
  defined;
- external feature portability is too poor for interpretable testing.

A scientifically negative result—such as absent transportability—is not
a stopping condition and may itself support a rigorous manuscript if the
design and reporting remain transparent.

# 16. Initial ChatGPT project-panel context

This protocol should be uploaded to a new dedicated ChatGPT project
panel. All future work in that project should be governed by the
following project identity:

- This is a separate project from TB-undernutrition transcriptomics and
  all other manuscripts.
- Its central question is host-pathogen immune-metabolic transcriptomic
  module transportability across acute bacterial and viral infections.
- GSE211567 is the scientific discovery resource.
- GSE161731 is the primary adult external transportability cohort; it
  may be used earlier only for technical workflow rehearsal without
  biological module selection.
- GSE261482 is an exploratory pediatric generalizability extension.
- GSE282464 is conditional and must not be used before
  metadata/sample-structure resolution.
- The project is not a classifier-development project.
- Module definitions must be frozen before external testing.
- Every major decision must be reproducible, documented and
  Git-versioned.
- Negative or nontransportable findings must be reported honestly rather
  than adjusted post hoc.

# 17. References

Chew, T., Pelaia, T. M., Phu, A. L., et al. (2025). Molecular landscape
of respiratory infection: A large-scale, multi-centre blood
transcriptome dataset. *Scientific Data, 12*, 1175.
<https://doi.org/10.1038/s41597-025-05488-6>

Falsey, A. R., Peterson, D. R., Walsh, E. E., et al. (2025). A four-gene
signature from blood to exclude bacterial etiology of lower respiratory
tract infection in adults. *Nature Communications*.
<https://doi.org/10.1038/s41467-025-65361-3>

Ko, E. R., Reller, M. E., Tillekeratne, L. G., et al. (2023).
Host-response transcriptional biomarkers accurately discriminate
bacterial and viral infections of global relevance. *Scientific Reports,
13*, 22554. <https://doi.org/10.1038/s41598-023-49734-6>

McClain, M. T., Constantine, F. J., Henao, R., et al. (2021).
Dysregulated transcriptional responses to SARS-CoV-2 in the periphery
support novel diagnostic approaches. *Nature Communications, 12*, 1070.
<https://doi.org/10.1038/s41467-021-21289-y>

National Center for Biotechnology Information. (2023). *Gene Expression
Omnibus accession GSE211567: Host-response transcriptional biomarkers
accurately discriminate bacterial and viral infections by global
pathogens*. Gene Expression Omnibus.

National Center for Biotechnology Information. (2021). *Gene Expression
Omnibus accession GSE161731: Dysregulated transcriptional responses to
SARS-CoV-2 in the periphery support novel diagnostic approaches*. Gene
Expression Omnibus.

National Center for Biotechnology Information. (2024). *Gene Expression
Omnibus accession GSE261482: A 5-transcript signature for discriminating
viral and bacterial etiology in pediatric pneumonia*. Gene Expression
Omnibus.

National Center for Biotechnology Information. (2025). *Gene Expression
Omnibus accession GSE282464: Molecular landscape of respiratory
infection: A large-scale, multi-centre blood transcriptome dataset*.
Gene Expression Omnibus.

Viz-Lasheras, S., Gómez-Carballa, A., Habgood-Coote, D., et al. (2025).
A 5-transcript signature for discriminating viral and bacterial etiology
in pediatric pneumonia. iScience.
https://doi.org/10.1016/j.isci.2025.111747

# Appendix A. Mandatory first-session actions in the dedicated project

1.  Add this protocol to the new ChatGPT project panel and state that it
    governs the project.
2.  Create the GitHub repository using the proposed name or an agreed
    equivalent.
3.  Commit the DOCX and Markdown protocol files.
4.  Create `docs/decision_log.md`, `docs/protocol_amendments.md` and
    `docs/dataset_feasibility_audit.md`.
5.  Begin with formal metadata and file audit; do not begin biological
    interpretation before the audit is documented.
6.  Use GSE161731 only to establish technical proficiency in the
    count-level workflow while GSE211567 remains the discovery cohort.
7.  Freeze discovery modules before interpreting external results.

# Appendix B. Initial project-panel starter text

**Project name:** Host-Pathogen Transcriptomic Transportability Project

**Core mission:** Conduct a rigorous, reproducible public-data
transcriptomics study identifying conserved versus
pathogen-ecology-specific whole-blood immune-metabolic programs across
acute bacterial and viral infections, with pathway/module locking and
external transportability testing.

**Governance statement:** Use the uploaded protocol as the governing
project document. Keep this project separate from TB-undernutrition work
and other manuscripts. Maintain a documented audit trail, versioned
scripts and explicit interpretation boundaries. Do not convert the
project into another bacterial-versus-viral classifier study, and do not
modify frozen modules after examining external results.
