# Manuscript Assembly Scaffold

## Working title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules across public infection transcriptomes

## Current central framing

This manuscript presents a fixed-module transportability analysis of host-response programmes associated with bacterial versus viral infection. A site-aware discovery and conservative module-locking workflow was performed in GSE211567, followed by fixed-module external projection in GSE73461. The strongest externally transported signals were antiviral/interferon modules and the bacterial mitochondrial respiration/OXPHOS module, while the bacterial cytoplasmic translation/ribosomal module remained directionally concordant but borderline.

## Manuscript structure

### Title page

Status: to draft.

Required content:

- Title
- Short title
- Author list
- Affiliations
- Corresponding author details
- Keywords
- Data/code availability statement

### Abstract

Status: to draft.

Recommended structure:

- Background
- Objective
- Methods
- Results
- Conclusions

### Introduction

Status: to draft.

Required logic:

1. Clinical and biological challenge of distinguishing bacterial and viral host-response biology.
2. Limitations of diagnostic classifier-centric transcriptomic studies.
3. Need for biological module transportability rather than only model performance.
4. Importance of site-aware discovery because public cohorts can contain geographic, clinical and technical heterogeneity.
5. Rationale for conservative module locking before external projection.
6. Study objective: identify bacterial- and viral-associated host-response modules in GSE211567 and test fixed-module external transportability in GSE73461.

### Methods

Current source file:

- `docs/methods_section_full_draft.md`

Supporting files:

- `docs/methods_section_skeleton.md`
- `docs/methods_results_alignment_map.md`

### Results

Current source file:

- `docs/integrated_results_section_with_callouts.md`

Supporting files:

- `docs/combined_discovery_projection_results_manuscript_draft.md`
- `docs/GSE73461_projection_results_manuscript_draft.md`

### Figures

Figure 1:

- Discovery and conservative locking of bacterial- and viral-associated host-response modules in GSE211567.
- Caption source: `docs/polished_main_figure_captions.md`
- Figure files: `results/figures/GSE211567_manuscript_discovery_panels/`

Figure 2:

- External fixed-module projection of GSE211567 discovery modules in GSE73461.
- Caption source: `docs/polished_main_figure_captions.md`
- Figure files: `results/figures/GSE73461_manuscript_projection_panels/`

### Table

Table 1:

- External projection of locked GSE211567 discovery modules in GSE73461.
- Table source: `docs/GSE73461_manuscript_projection_summary_table.md`
- TSV source: `results/tables/GSE73461_manuscript_projection_summary_table.tsv`
- Title/footnotes source: `docs/polished_table1_title_and_footnotes.md`

### Discussion

Status: to draft.

Required logic:

1. Principal finding: fixed discovery-derived modules showed external transportability.
2. Strongest transported modules: antiviral/interferon programmes.
3. Bacterial module interpretation: mitochondrial respiration/OXPHOS transported robustly; cytoplasmic translation/ribosomal programme directionally concordant but borderline.
4. Biological significance: module-level transportability can reveal conserved host-response architecture beyond classifier performance.
5. Site-aware discovery: importance of avoiding single-stratum artefacts.
6. External projection firewall: why fixed-module projection is more conservative than rediscovery.
7. Limitations:
   - Public dataset metadata constraints.
   - Heterogeneity across cohorts and platforms.
   - Module-level transcriptomic associations do not prove causality.
   - Not a diagnostic classifier.
   - GSE161731 used only as technical rehearsal.
8. Future work:
   - Additional independent cohorts.
   - Prospective validation.
   - Single-cell or cell-composition-aware decomposition.
   - Integration with proteomics/metabolomics.
   - Careful exploration of clinical utility without overstating diagnostic readiness.

### Data and code availability

Status: to draft.

Required points:

- Public datasets used.
- Repository tracking scripts, decision logs and outputs.
- Figure export standard.
- Reproducibility materials.

### Supplementary materials

Status: to organize.

Candidate supplementary items:

- External cohort candidate search register.
- GSE261482 and GSE68310 audit summaries.
- GSE161731 technical rehearsal outputs.
- Module gene tables.
- Identifier coverage tables.
- Mapping/path audit outputs.
- Session information files.

## Interpretation boundaries

The manuscript must preserve the following boundaries:

- Do not describe modules as diagnostic classifiers.
- Do not describe GSE73461 projection as diagnostic model validation.
- Do not imply gene rediscovery in GSE73461.
- Do not rename or redefine modules using GSE73461.
- Do not claim causal mechanisms from transcriptomic module transportability.
- Do describe the work as fixed-module transportability analysis of host-response programmes.

## Immediate next writing task

Draft the Introduction using the logic above, while preserving the distinction between biological module transportability and diagnostic classifier development.
