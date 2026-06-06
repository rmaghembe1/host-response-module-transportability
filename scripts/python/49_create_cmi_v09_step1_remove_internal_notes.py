#!/usr/bin/env python3

from pathlib import Path
import re

src = Path("docs/complete_manuscript_draft_v0.8_cmi_compressed.md")
out = Path("docs/complete_manuscript_draft_v0.9_step1_internal_notes_removed.md")

text = src.read_text()

# Remove internal publication-route and draft-boundary sections from the manuscript body.
patterns = [
    r"\n# CMI Submission Route Note\n.*?(?=\n# Final Interpretation Boundary Reminder|\Z)",
    r"\n# Final Interpretation Boundary Reminder\n.*?\Z",
]

for pattern in patterns:
    text = re.sub(pattern, "\n", text, flags=re.S)

# Remove internal front-matter notes that are useful for repository tracking but not for journal submission.
text = text.replace(
    "## APC / publication route note\n\nNo dedicated APC funding is available for this work. Submission to Clinical Microbiology and Infection should proceed through the standard subscription/non-open-access route unless full open-access coverage is confirmed.\n\n",
    ""
)

text = text.replace(
    "## Front-matter interpretation boundary\n\nThese statements support a manuscript framed as fixed-module transportability analysis of host-response programmes. They should not imply diagnostic classifier discovery, diagnostic model validation, clinical implementation evidence, gene rediscovery, module redefinition or causal validation.\n\n",
    ""
)

# Retitle the draft.
text = text.replace(
    "# Complete Manuscript Draft v0.8 — CMI-Compressed Draft",
    "# Complete Manuscript Draft v0.9 — Step 1 Internal Notes Removed"
)

text = text.replace(
    "Draft v0.8 compresses the Introduction, Methods and Discussion for CMI-facing length while preserving the CMI-compliant abstract, front matter, Results, supplementary table citations, submission route note and interpretation safeguards.",
    "Draft v0.9 Step 1 removes internal submission-route and draft-boundary notes from the manuscript body while preserving scientific caution within the Methods, Results and Discussion."
)

# Do not remove scientific caution where it is naturally integrated.
required_phrases = [
    "does not constitute diagnostic classifier discovery",
    "without gene reselection",
    "without gene reselection, module redefinition, reweighting or diagnostic model training",
]

missing = [p for p in required_phrases if p not in text]
if missing:
    raise SystemExit("Required scientific safeguard phrase(s) missing after Step 1:\n" + "\n".join(missing))

out.write_text(text)
print(f"Wrote: {out}")
