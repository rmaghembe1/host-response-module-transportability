# Complete Manuscript v2.0 Reviewer/Editor Reconciliation Report

## Locked source

- Source: `docs/complete_manuscript_draft_v1.9_revision_round1_final.md`
- Source SHA256: `4a52cf61559dda16da28d6572408731b4e7425f3d2a7fb118a5882acc9429c94`
- Target: `docs/complete_manuscript_draft_v2.0_reviewer_editor_reconciled.md`
- Target SHA256: `b4949e5caf29569f295f3ebd30a684ffa82fbebdbf4d604c48be88084447a677`

## Figure 2C prerequisite

- Revised Figure 2C QA: 13/13 checks passed.
- Revised Script 57 contains no geom_line() or geom_path().

## Targeted manuscript changes

- Defined transportability and fixed-module projection in plain language.
- Replaced unnecessary discovery/projection firewall terminology with direct descriptions of separation between discovery and external testing.
- Expanded GSE211567 design description to state the 224-sample discovery set, bacterial/viral counts, geographic strata, primary model adjustment and sign-based directional-concordance definition.
- Clarified that GO/module curation was biologically guided and documented rather than mathematically optimized for predictive separation.
- Added explicit gene-wise z-score and arithmetic-mean module-score definitions.
- Added GPL10558 to the GSE73461 cohort description.
- Revised Figure 1B and Figure 2C captions to define the relevant statistics and categorical point representation.
- Added direct GEO links to the Data Availability statement.
- Expanded the AI declaration to identify ChatGPT/OpenAI, describe its uses, describe validation of outputs, and state author responsibility.

## Preserved scientific results

- No analysis was rerun by this manuscript-reconciliation script.
- No module genes, expected directions or weights were changed.
- GSE73461 and GSE72810 sample counts were preserved.
- Cross-cohort effect estimates and confidence intervals were preserved.
- GSVA sensitivity conclusions were preserved.
- The 29,826-variant deletion analysis was preserved.
- The limitation concerning participant-level overlap and the shared broad investigator network was preserved.

## Code Availability boundary

The manuscript still states that revision-round code and outputs will be synchronized before resubmission. This is deliberate: the script does not claim that a Git push has occurred when it has not yet been verified. The statement should be converted to present tense only after repository synchronization is completed.

## Quality gate

- Checks passed: 37/37.
- Quality gate: `PASS`.
- Final status: `READY_FOR_V2_MANUSCRIPT_DIFF_REVIEW_PENDING_REPOSITORY_SYNC`.

No unified-diff artifact was generated, avoiding the historical whitespace/staging problem encountered with earlier audit diffs.
