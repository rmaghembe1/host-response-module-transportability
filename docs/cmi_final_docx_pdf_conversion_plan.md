# CMI Final DOCX/PDF Conversion Package Plan

## Purpose

This document defines the final file-conversion plan for preparing the CMI-facing submission package from the current clean manuscript repository.

## Current source manuscript

Current submission-format manuscript draft:

- `docs/complete_manuscript_draft_v0.8_cmi_compressed.md`

Status:

- CMI-compliant abstract: 241 words
- Main text Introduction–Discussion: 2036 words
- Full draft: 3444 words
- QC status: all checks passed
- Package-index status: all indexed paths present

## Target journal

- Clinical Microbiology and Infection

## Financial route

Submission should proceed through the standard subscription/non-open-access route unless full open-access coverage is confirmed.

## Conversion outputs to prepare

### 1. Main manuscript DOCX

Target output:

- `submission/cmi_main_manuscript_v0.8.docx`

Source:

- `docs/complete_manuscript_draft_v0.8_cmi_compressed.md`

Content to include:

- Title
- Running heading
- Authors and affiliations
- Corresponding author details
- Funding statement
- Competing interests
- Ethics statement
- Author contributions
- Acknowledgements
- Data availability
- Code availability
- APC/subscription-route note if appropriate for internal submission package
- Structured abstract
- Keywords
- Introduction
- Methods
- Results
- Discussion
- Figure legends
- Table 1 title and footnotes
- Supplementary tables note

Formatting principles:

- Use clean journal-style headings.
- Remove internal draft labels where possible.
- Keep manuscript readable and reviewer-facing.
- Keep interpretation safeguards.
- Do not include terminal logs, audit records or internal package-index details in the main DOCX.

### 2. Main manuscript PDF

Target output:

- `submission/cmi_main_manuscript_v0.8.pdf`

Source:

- `submission/cmi_main_manuscript_v0.8.docx`

Purpose:

- Local visual inspection.
- Optional submission upload if journal system requests PDF.

### 3. Cover letter DOCX/PDF

Target outputs:

- `submission/cmi_cover_letter.docx`
- `submission/cmi_cover_letter.pdf`

Source:

- `docs/cmi_facing_cover_letter_draft.md`

Required checks before conversion:

- Confirm title matches v0.8.
- Include explicit declarations:
  - Instructions for Authors have been read.
  - All authors approved the manuscript.
  - Acknowledged contributors approved acknowledgement.
  - Work is original.
  - Manuscript is not published elsewhere.
  - Manuscript is not under consideration elsewhere.
- Include no-APC/subscription-route note carefully.

### 4. Supplementary tables package

Target output options:

- Individual TSV files retained under `results/supplementary_tables/`
- Optional combined spreadsheet:
  - `submission/cmi_supplementary_tables_S1_to_S5.xlsx`
- Optional combined PDF/DOCX index:
  - `submission/cmi_supplementary_tables_index.pdf`
  - `submission/cmi_supplementary_tables_index.docx`

Current source index:

- `docs/supplementary_materials/CMI_supplementary_tables_index.md`

Current TSV files:

- `results/supplementary_tables/Supplementary_Table_S1_external_projection_candidate_register.tsv`
- `results/supplementary_tables/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.tsv`
- `results/supplementary_tables/Supplementary_Table_S3A_GSE73461_module_identifier_coverage.tsv`
- `results/supplementary_tables/Supplementary_Table_S3B_GSE73461_matched_locked_module_genes.tsv`
- `results/supplementary_tables/Supplementary_Table_S3C_GSE73461_missing_locked_module_genes.tsv`
- `results/supplementary_tables/Supplementary_Table_S3D_GSE73461_gene_probe_choice_for_projection.tsv`
- `results/supplementary_tables/Supplementary_Table_S4A_GSE73461_fixed_module_scores_long.tsv`
- `results/supplementary_tables/Supplementary_Table_S4B_GSE73461_fixed_module_scores_wide.tsv`
- `results/supplementary_tables/Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv`
- `results/supplementary_tables/Supplementary_Table_S5B_GSE73461_primary_only_zscore_sensitivity_tests.tsv`
- `results/supplementary_tables/Supplementary_Table_S5C_GSE73461_manuscript_projection_summary.tsv`

Recommended submission approach:

- Prepare a combined XLSX workbook with separate sheets for S1, S2, S3A–S3D, S4A–S4B and S5A–S5C.
- Retain individual TSVs for repository transparency.
- Include the supplementary tables index as a short DOCX/PDF if the submission system accepts supplementary legends separately.

### 5. Figure files

Target action:

- Confirm final main Figure 1 and Figure 2 file paths.
- Copy final figure files into `submission/figures/`.

Expected formats:

- High-resolution PNG
- Editable SVG
- Vector PDF where available

Required checks:

- Confirm figure filenames.
- Confirm captions match the manuscript.
- Confirm resolution and readability.
- Confirm no excessive detail or illegible text.

### 6. Table 1

Target action:

- Confirm final Table 1 source file and decide whether to embed in manuscript DOCX or upload separately.

Likely source:

- `results/tables/GSE73461_manuscript_projection_summary_table.tsv`

Required checks:

- Confirm values match Results.
- Confirm footnotes are included.
- Confirm abbreviations are defined.

### 7. Repository/audit archive

Not intended as primary manuscript upload unless requested.

Potential archive contents:

- `README.md`
- `docs/decision_log.md`
- `docs/manuscript_results_package_index.md`
- `results/audits/complete_manuscript_v0.8_cmi_qc_summary.md`
- `results/audits/complete_manuscript_v0.8_cmi_qc_details.tsv`
- `results/audits/complete_manuscript_v0.8_cmi_word_count.md`
- `results/audits/cmi_supplementary_tables_package_audit_summary.md`

Recommended action:

- Keep these in repository.
- Do not upload as supplementary scientific material unless requested.

## Conversion order

1. Prepare `submission/` folder structure.
2. Convert main manuscript Markdown to clean DOCX.
3. Export main manuscript PDF for inspection.
4. Convert/polish cover letter.
5. Create combined supplementary XLSX workbook.
6. Copy final figures into `submission/figures/`.
7. Create final submission package index.
8. Run local file-existence audit.
9. Visually inspect DOCX and PDF.
10. Commit final submission files or store large binary files according to repository policy.

## Remaining decisions before final upload

- Whether GitHub repository is public at submission or after acceptance/revision.
- Whether to add a license before public release.
- Whether supplementary tables should be uploaded as XLSX only, TSV only, or both.
- Whether figures should be embedded in DOCX, uploaded separately, or both.
- Whether the APC/subscription route note belongs in the cover letter only or also in manuscript front matter.

## Interpretation boundary

Conversion must not alter the scientific framing. The manuscript remains a fixed-module transportability analysis, not diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.
