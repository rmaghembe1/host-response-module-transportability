# Journal Targeting and Submission-Readiness Checklist

## Purpose

This document defines the next manuscript-preparation phase after completion of the audited v0.4 manuscript draft. It is intended to guide journal selection, manuscript polishing, supplementary-material organization and final submission formatting while preserving the fixed-module transportability framing.

## Current manuscript anchor

Current central draft:

- `docs/complete_manuscript_draft_v0.4.md`

Current status:

- Complete manuscript draft assembled.
- Front matter included.
- Structured Abstract included.
- Introduction, Methods, Results and Discussion included.
- Figure captions and Table 1 notes included.
- Complete-manuscript QC passed.
- Package index audited.
- Interpretation safeguards logged.

## Core manuscript framing to preserve

Preferred framing:

> A site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes in GSE211567, and fixed-module projection in GSE73461 supported external transportability of antiviral/interferon modules and the bacterial mitochondrial respiration/OXPHOS module, while the bacterial cytoplasmic translation/ribosomal module remained directionally concordant but borderline.

Do not frame the manuscript as:

- Diagnostic classifier discovery.
- Diagnostic model validation.
- Clinical diagnostic test development.
- Gene rediscovery in GSE73461.
- Module redefinition in GSE73461.
- Causal validation of pathways.

## Journal-fit criteria

A suitable target journal should be receptive to at least four of the following:

1. Host-response transcriptomics.
2. Infectious-disease systems biology.
3. Public dataset reanalysis.
4. Reproducible computational biology.
5. Biomarker biology without requiring new wet-lab validation.
6. Cross-cohort transcriptomic transportability.
7. Methodologically careful module-based interpretation.
8. Open science, scripts and transparent decision logs.

## Journals to evaluate

Potential journal categories:

### Infection / host-response journals

- Journals focused on infection biology, host response, clinical microbiology or translational infectious disease.
- Strong fit if they accept computational public-data reanalysis with biological interpretation.

### Systems biology / computational biology journals

- Journals focused on reproducible computational biology, transcriptomics and cross-cohort analysis.
- Strong fit if they value workflow transparency, module transportability and public-data reuse.

### Immunology / inflammation journals

- Journals focused on immune-response programmes and interferon/inflammatory biology.
- Strong fit if they are open to infection-context transcriptomic module analysis.

### Multidisciplinary open-access journals

- May be suitable if the manuscript is positioned as a reproducible public-data analysis with careful interpretation boundaries.
- Need to ensure novelty is clear enough beyond dataset reanalysis.

## Minimum journal-screening questions

For each candidate journal, assess:

1. Does the journal publish computational reanalysis of public transcriptomic datasets?
2. Does it require wet-lab validation for transcriptomic findings?
3. Does it accept module/pathway-level biological interpretation without clinical classifier validation?
4. Does it support supplementary datasets, code availability and transparent reproducibility materials?
5. Are figure limits compatible with two main figures and one main table?
6. Are structured abstracts allowed or required?
7. Are data/code availability statements required?
8. Does the journal require specific reporting guidelines?
9. Are there word limits for Abstract, Introduction, Methods and Discussion?
10. Are there restrictions on supplementary files or figure file types?

## Submission-readiness checklist

### Title and front matter

- [ ] Confirm final title.
- [ ] Confirm short title.
- [ ] Complete author list.
- [ ] Complete affiliations.
- [ ] Complete corresponding-author details.
- [ ] Finalize keywords.
- [ ] Finalize funding statement.
- [ ] Finalize competing-interest statement.
- [ ] Finalize author contributions.
- [ ] Finalize acknowledgements.
- [ ] Finalize ethics statement.

### Abstract

- [ ] Check target journal word limit.
- [ ] Convert structured Abstract to unstructured format if required.
- [ ] Confirm no diagnostic-model overclaiming.
- [ ] Confirm numerical results match Table 1.

### Introduction

- [ ] Add references.
- [ ] Ensure rationale is not overly broad.
- [ ] Preserve distinction between diagnostic classifiers and biological module transportability.
- [ ] End with a clear study objective.

### Methods

- [ ] Add software versions where required.
- [ ] Add accession and dataset-source details.
- [ ] Add exact statistical test descriptions.
- [ ] Add multiple-testing correction details.
- [ ] Add figure export details only if appropriate for journal Methods.
- [ ] Move extensive workflow-audit details to supplement if Methods becomes too long.

### Results

- [ ] Confirm Figure 1 and Figure 2 callouts.
- [ ] Confirm Table 1 callouts.
- [ ] Confirm all module names and P values match final source tables.
- [ ] Avoid classifier-validation language.
- [ ] Keep BACT_M1 interpretation cautious.

### Discussion

- [ ] Add references.
- [ ] Strengthen biological interpretation of interferon modules.
- [ ] Keep BACT_M2 interpretation carefully framed as immune-metabolic association.
- [ ] Preserve limitations around public metadata, platform heterogeneity and lack of causality.
- [ ] Avoid overstating clinical utility.

### Figures

- [ ] Confirm final figure panel labels.
- [ ] Confirm 1800 dpi PNG files.
- [ ] Confirm editable SVG backups.
- [ ] Confirm vector PDF backups.
- [ ] Confirm journal-required figure format.
- [ ] Check font sizes and readability.
- [ ] Confirm captions match final figure panels.

### Tables

- [ ] Confirm Table 1 values against TSV.
- [ ] Decide whether identifier coverage goes in main table or supplement.
- [ ] Prepare supplementary module gene tables.
- [ ] Prepare supplementary cohort-audit tables.

### Supplementary materials

Candidate supplementary files:

- External projection candidate search register.
- GSE261482 audit summary.
- GSE68310 audit summary.
- GSE161731 technical rehearsal summary.
- GSE211567 module gene tables.
- GSE73461 identifier coverage table.
- GSE73461 projection sample table.
- Mapping/path audit outputs.
- Session information files.
- Figure export standard.

### Reproducibility

- [ ] Confirm repository structure is readable.
- [ ] Confirm README exists or draft one.
- [ ] Confirm decision log is clean and interpretable.
- [ ] Confirm scripts are named sequentially and descriptively.
- [ ] Confirm no large raw files need to be excluded from GitHub.
- [ ] Confirm data-download instructions are reproducible.
- [ ] Confirm license choice.
- [ ] Confirm citation instructions for repository.

## Suggested next actions

1. Create a journal-candidate comparison table.
2. Draft a repository README.
3. Organize supplementary tables.
4. Add references to Introduction and Discussion.
5. Convert v0.4 into journal-specific manuscript format.
6. Run final consistency audit after journal formatting.

## Current recommendation

Before choosing a final journal, perform a small journal-fit audit using 5–8 candidate journals. The strongest target will likely be a journal that values reproducible host-response transcriptomics and accepts public-data computational reanalysis without requiring new experimental validation, provided the manuscript is framed as module transportability rather than diagnostic classifier validation.
