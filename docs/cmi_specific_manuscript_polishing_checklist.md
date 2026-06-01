# CMI-Specific Manuscript Polishing Checklist

## Purpose

This checklist defines the final manuscript-polishing tasks needed before adapting the audited v0.4 manuscript for submission to **Clinical Microbiology and Infection (CMI)** through the standard subscription/non-open-access route.

## Current manuscript and CMI files

Current complete manuscript draft:

- `docs/complete_manuscript_draft_v0.4.md`

CMI-facing support files:

- `docs/cmi_facing_manuscript_adaptation_checklist.md`
- `docs/cmi_facing_title_abstract_variant.md`
- `docs/cmi_facing_cover_letter_draft.md`
- `docs/cmi_vs_jmm_target_fit_decision.md`

## Financial submission route

- [ ] Submit through the standard subscription/non-open-access route.
- [ ] Do not select optional open access unless full APC coverage is confirmed.
- [ ] Keep cover letter wording noting no dedicated APC funding.
- [ ] Verify during submission that no mandatory publication fee applies.

## Title and abstract

- [ ] Use the CMI-facing title or a shortened variant.
- [ ] Confirm whether CMI requires structured or unstructured abstract.
- [ ] Confirm abstract word limit.
- [ ] Current CMI-facing abstract word count: 332 words excluding headings.
- [ ] Preserve “not diagnostic model validation” wording or equivalent boundary.
- [ ] Confirm all numerical results match Table 1.

## Introduction polishing

### Add or strengthen

- [ ] Clinical microbiology relevance of bacterial-versus-viral host-response biology.
- [ ] Antimicrobial-stewardship motivation as background, not as validated application.
- [ ] Challenge of interpreting pathogen detection, co-infection, colonization and prior antimicrobial exposure.
- [ ] Why classifier performance does not equal biological transportability.
- [ ] Why public infection transcriptomes require site-aware analysis.
- [ ] Why fixed-module projection is more conservative than rediscovery.

### Avoid

- [ ] Claims that the modules are ready for diagnostic use.
- [ ] Claims that the workflow solves bacterial-versus-viral diagnosis.
- [ ] Claims of clinical implementation.

## Methods polishing

### Main Methods should keep

- [ ] Dataset accessions and cohort roles.
- [ ] Discovery/projection firewall.
- [ ] GSE211567 discovery workflow.
- [ ] Site-aware concordance.
- [ ] Conservative module locking.
- [ ] GSE73461 fixed-module projection.
- [ ] Primary-only z-score sensitivity.
- [ ] Statistics and BH correction.
- [ ] Reproducibility statement.

### Move or shorten if needed

- [ ] Excessive repository/path details.
- [ ] Long decision-log explanations.
- [ ] Detailed figure export mechanics.
- [ ] Detailed failed-candidate cohort audits.

## Results polishing

- [ ] Keep the Results concise.
- [ ] Maintain three core Results stages:
  1. GSE211567 discovery and module locking.
  2. GSE73461 cohort lock and identifier coverage.
  3. Fixed-module projection and sensitivity analysis.
- [ ] Highlight expected-direction concordance for all modules.
- [ ] Emphasize strongest transportability for viral/interferon modules.
- [ ] Interpret BACT_M2 as robust bacterial-associated mitochondrial/OXPHOS programme.
- [ ] Keep BACT_M1 cautious and borderline.
- [ ] Avoid diagnostic-performance language.

## Discussion polishing

### Strengthen

- [ ] Infection-biology relevance.
- [ ] Antiviral/interferon module interpretation.
- [ ] Bacterial immune-metabolic/OXPHOS interpretation.
- [ ] Why module transportability complements classifier studies.
- [ ] Why site-aware discovery matters in heterogeneous public infection cohorts.
- [ ] Why fixed external projection reduces overfitting and rediscovery risk.

### Limit clearly

- [ ] Public metadata constraints.
- [ ] Platform and cohort heterogeneity.
- [ ] Transcriptomic module scores may reflect cell composition and activation state.
- [ ] No causal inference.
- [ ] No prospective clinical validation.
- [ ] No diagnostic classifier training or validation.
- [ ] GSE161731 was technical rehearsal only.

## Figures

- [ ] Confirm Figure 1 CMI-readable panel labels.
- [ ] Confirm Figure 2 CMI-readable panel labels.
- [ ] Confirm 1800 dpi PNG versions.
- [ ] Confirm editable SVG backups.
- [ ] Confirm vector PDF backups.
- [ ] Ensure font sizes are readable.
- [ ] Ensure captions explain non-diagnostic module projection.

## Table 1

- [ ] Confirm all P values match `results/tables/GSE73461_manuscript_projection_summary_table.tsv`.
- [ ] Confirm BACT_M1 is labelled borderline, not negative or failed.
- [ ] Confirm sensitivity values are included.
- [ ] Ensure table footnotes explain positive and negative median differences.
- [ ] Avoid calling modules biomarkers.

## Supplementary materials

### Recommended supplementary package

- [ ] Candidate external cohort search register.
- [ ] GSE261482 audit summary.
- [ ] GSE68310 audit summary.
- [ ] GSE161731 technical rehearsal output.
- [ ] GSE211567 module gene tables.
- [ ] GSE73461 locked module identifier coverage.
- [ ] GSE73461 scored genes/probe mapping.
- [ ] GSE73461 projection sample table.
- [ ] Session information files.
- [ ] Package/path audit outputs.
- [ ] Figure export standard.

### Supplementary strategy

- [ ] Use supplementary files to document transparency without overloading the main text.
- [ ] Ensure each supplementary item has a clear title and citation in the main manuscript.

## Repository / code availability

- [ ] Draft or update README.
- [ ] Ensure repository paths are understandable.
- [ ] Ensure raw data are not improperly committed.
- [ ] Provide data-download/reproduction instructions.
- [ ] Choose a license.
- [ ] Add citation instructions.
- [ ] Mention public datasets and accessions clearly.

## Front matter

- [ ] Confirm author order.
- [ ] Confirm affiliations.
- [ ] Add corresponding-author email.
- [ ] Finalize funding statement: no dedicated funding.
- [ ] Finalize competing-interest statement.
- [ ] Finalize author contributions.
- [ ] Finalize ethics statement.
- [ ] Finalize acknowledgements.

## Cover letter

- [ ] Confirm title matches final manuscript title.
- [ ] Confirm subscription/non-open-access route wording.
- [ ] Confirm all authors approved submission.
- [ ] Confirm manuscript is not under consideration elsewhere.
- [ ] Confirm repository/code availability statement is accurate.
- [ ] Avoid waiver request wording if using subscription route; simply state optional OA is not being selected due to no APC funding.

## Final quality-control checks

- [ ] Run manuscript QC script after CMI adaptation.
- [ ] Run package-index path audit.
- [ ] Search for accidental terminal text.
- [ ] Search for overclaiming terms.
- [ ] Confirm all figure/table paths exist.
- [ ] Confirm all cited supplementary files exist.
- [ ] Confirm Git working tree is clean.

## Interpretation boundary

CMI polishing must preserve the manuscript's central claim: fixed-module transportability analysis of host-response programmes. The manuscript must not be reframed as diagnostic classifier discovery, diagnostic model validation, clinical diagnostic test development, gene rediscovery, module redefinition or causal validation.
