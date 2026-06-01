# CMI v0.7 Main-Text Compression Plan

## Purpose

This document defines the text-compression strategy for converting the QC-passed v0.7 CMI draft into a shorter CMI-ready v0.8 draft.

## Current word-count status

Current source manuscript:

- `docs/complete_manuscript_draft_v0.7_cmi_compliant_abstract.md`

Current audit:

- Abstract word count excluding headings: 241
- Main text word count, Introduction through Discussion: 4151
- Full draft word count: 5566

## Target

CMI-facing target:

- Abstract: already compliant at 241 words.
- Main text Introduction–Discussion: compress toward approximately 2500 words.
- Preserve scientific accuracy, reproducibility and interpretation safeguards.

## Compression priorities

### Introduction

Current role:

- Establishes bacterial-versus-viral infection problem.
- Explains classifier-centred limitation.
- Introduces fixed-module transportability.
- Introduces site-aware discovery and projection firewall.

Compression strategy:

- Reduce from six paragraphs to four concise paragraphs.
- Keep clinical microbiology relevance.
- Keep distinction between module transportability and diagnostic validation.
- Remove repeated explanation of cohort heterogeneity.
- Keep the final aim paragraph concise.

### Methods

Current role:

- Provides detailed reproducible workflow.
- Explains discovery/projection firewall.
- Covers dataset selection, GSE211567 discovery, site-aware modelling, module locking, GSE73461 projection and sensitivity analysis.

Compression strategy:

- Keep enough detail for review.
- Move excessive repository/path-level details to supplementary materials and README.
- Combine dataset-selection and firewall description.
- Compress QC and audit descriptions.
- Retain statistical tests, scoring rule and projection boundaries.
- Cite Supplementary Tables S1–S5 for details.

### Results

Current role:

- Presents discovery modules, identifier coverage and projection results.

Compression strategy:

- Keep Results relatively intact.
- Reduce descriptive repetition.
- Keep all essential module names, directionality, coverage and key statistics.
- Avoid repeating full Table 1 values beyond critical highlights.

### Discussion

Current role:

- Interprets module transportability, viral/interferon modules, bacterial OXPHOS module, BACT_M1 borderline result, strengths and limitations.

Compression strategy:

- Reduce to five concise paragraphs:
  1. Principal findings.
  2. Interpretation of viral and bacterial modules.
  3. Value of fixed-module transportability versus classifier-centred work.
  4. Strengths and limitations.
  5. Implications and future work.
- Preserve all no-overclaiming language.
- Avoid broad repetition of limitations already described in Methods.

## Non-negotiable safeguards

The v0.8 compressed draft must preserve:

- Fixed-module transportability framing.
- Discovery/projection firewall.
- No diagnostic classifier discovery claim.
- No diagnostic model validation claim.
- No causal validation claim.
- No gene rediscovery/module redefinition framing.
- GSE73461 as fixed external projection cohort.
- Supplementary Tables S1–S5 citations.
- Subscription/no-APC route note.

## Proposed next action

Create `docs/complete_manuscript_draft_v0.8_cmi_compressed.md` by compressing Introduction, Methods and Discussion while keeping Results statistically intact. Then rerun:

- Manuscript QC.
- Abstract/main-text/full word-count audit.
- Package path audit.
