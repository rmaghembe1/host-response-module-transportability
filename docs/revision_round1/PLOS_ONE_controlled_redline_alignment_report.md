# PLOS ONE Controlled Redline Alignment

Manuscript: PONE-D-26-30583

## Locked sources

- Clean DOCX SHA256: `691f494f5f2335b1a96f5b8d009c815d733b3c74fab0f230eaa3f73274f6b38f`
- Reconstructed submitted baseline SHA256: `0e0b4a2bcec736d2735ecc903ad72e99a1a3897bc09e2f991a7249000852dd34`
- Scientific source SHA256: `f3b61e6ddb9f5d38c6211c6cfe0d8694e6ca3b761d52a3245d58df844ab5b2ae`

## Rationale

The submitted and revised manuscripts have substantial section-order and paragraph-structure differences. A global sequential diff would therefore confound true revision edits with relocation and formatting changes.

This phase aligns every clean paragraph to its best submitted-baseline paragraph independently of document order, and performs the reverse submitted-to-clean alignment.

Reviewer/editor-driven anchors are separately mapped to clean-manuscript paragraph indices so the marked-up manuscript can emphasize actual revision-round changes rather than blanket document reformatting.

## Classification

- Exact unchanged clean paragraphs: 5
- Near-unchanged clean paragraphs: 25
- Modified clean candidates: 24
- Revision-addition candidates: 92

## Quality gate

- Checks passed: 26/26
- Quality gate: `PASS`
- Final status: `READY_FOR_TARGETED_OOXML_REDLINE_BUILD`
