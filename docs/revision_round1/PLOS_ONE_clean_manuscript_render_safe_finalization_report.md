# PLOS ONE Clean Manuscript Render-Safe Finalization

Manuscript: PONE-D-26-30583

## Input

- Pre-finalization DOCX SHA256: `299e0bd45efa1be622e361905279a915cd5896ddbe6df5343420345ad1eccac9`

## Render-safe normalization

- The validated clean DOCX was opened and resaved with python-docx.
- Main-document text was required to remain exactly identical.
- Paragraph, table and section counts were required to remain unchanged.
- Line numbering and page-number fields were required to remain present.
- Comment-related package parts remained absent.
- LibreOffice smoke rendering was required to produce a non-empty PDF before promotion.

## Output

- Candidate SHA256: `a21d3599e32d7479dd95402135eaaa27ee2719107bf417a727f721b082f95c8c`
- Promoted clean DOCX SHA256: `a21d3599e32d7479dd95402135eaaa27ee2719107bf417a727f721b082f95c8c`

## Remaining manuscript-layout work

- Figure 1, Figure 2, Figure 3, Table 1 and Table 2 still require PLOS read-order placement correction.
- Figure S1 caption remains pending final supporting-information placement.
- No placement change was performed in this phase.

## Quality gate

- Checks passed: 30/30
- Quality gate: `PASS`
- Final status: `READY_FOR_FULL_RENDER_AND_VISUAL_REVIEW`
