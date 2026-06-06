#!/usr/bin/env python3

from pathlib import Path
import re

src = Path("docs/complete_manuscript_draft_v0.9_step1_internal_notes_removed.md")
out = Path("docs/complete_manuscript_draft_v1.0_step2_imrad_headings.md")

text = src.read_text()

# Retitle draft.
text = text.replace(
    "# Complete Manuscript Draft v0.9 — Step 1 Internal Notes Removed",
    "# Complete Manuscript Draft v1.0 — Step 2 CMI IMRaD Headings"
)

# Remove internal package-purpose front-matter label.
text = text.replace("# CMI Final Front-Matter Statements\n\n", "")

text = re.sub(
    r"## Purpose\n\nDraft v0\.9 Step 1 removes internal submission-route and draft-boundary notes from the manuscript body while preserving scientific caution within the Methods, Results and Discussion\.\n\n",
    "",
    text,
    flags=re.S
)

# Convert abstract heading to journal-facing form.
text = text.replace("## CMI-compliant structured abstract", "## Abstract")

# Convert internal draft labels to clean CMI IMRaD headings.
text = text.replace("# Manuscript Introduction Draft", "# Introduction")
text = text.replace("# Manuscript Methods Draft", "# Methods")
text = text.replace("# Integrated Manuscript Results Section with Figure and Table Callouts", "# Results")
text = text.replace("# Manuscript Discussion Draft", "# Discussion")

# Clean figure/table internal labels while keeping content.
text = text.replace("# Main Figure Captions\n\n", "")
text = text.replace("# Polished Main Figure Captions", "# Figure captions")
text = text.replace("# Table 1 Title and Footnotes\n\n", "")
text = text.replace("# Polished Table 1 Title and Footnotes", "# Table 1")

# Make Table 1 subheadings less awkward.
text = text.replace("## Table 1. External projection of locked GSE211567 discovery modules in GSE73461", "## Title")
text = text.replace("## Suggested table columns", "## Columns")
text = text.replace("## Footnotes", "## Notes")

# Clean supplementary heading.
text = text.replace("# Supplementary Tables Note", "# Supplementary material")

# Remove remaining internal phrase variants if present.
internal_patterns = [
    "Manuscript Introduction Draft",
    "Manuscript Methods Draft",
    "Integrated Manuscript Results Section",
    "Manuscript Discussion Draft",
    "Polished Main Figure Captions",
    "Polished Table 1 Title and Footnotes",
    "CMI-compliant structured abstract",
    "CMI Final Front-Matter Statements",
]
remaining = [p for p in internal_patterns if p in text]
if remaining:
    raise SystemExit("Internal heading phrase(s) remain:\n" + "\n".join(remaining))

# Check required clean headings.
required = ["# Introduction", "# Methods", "# Results", "# Discussion", "# Figure captions", "# Table 1", "# Supplementary material"]
missing = [h for h in required if h not in text]
if missing:
    raise SystemExit("Required CMI heading(s) missing:\n" + "\n".join(missing))

out.write_text(text)
print(f"Wrote: {out}")
