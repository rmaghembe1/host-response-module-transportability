#!/usr/bin/env python3

from pathlib import Path
import re

src = Path("docs/complete_manuscript_draft_v1.3_step5_ai_declaration.md")
out = Path("docs/complete_manuscript_draft_v1.4_step6_british_spelling.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.3 — Step 5 AI Declaration",
    "# Complete Manuscript Draft v1.4 — Step 6 British Spelling and CMI Language"
)

# British / international scientific English harmonisation.
replacements = {
    "tumor": "tumour",
    "Tumor": "Tumour",
    "colonization": "colonisation",
    "Colonization": "Colonisation",
    "emphasized": "emphasised",
    "emphasize": "emphasise",
    "summarized": "summarised",
    "summarize": "summarise",
    "normalized": "normalised",
    "normalization": "normalisation",
    "prioritize": "prioritise",
    "prioritized": "prioritised",
    "visualization": "visualisation",
    "visualize": "visualise",
    "organized": "organised",
    "organize": "organise",
    "organization": "organisation",
    "Conceptualization": "Conceptualisation",
    "conceptualization": "conceptualisation",
    "etiology": "aetiology",
    "Etiology": "Aetiology",
    "modeling": "modelling",
    "Modeling": "Modelling",
    "relabeling": "relabelling",
    "pre-specified": "pre-specified",
    "z-score": "z-score",
}

for old, new in replacements.items():
    text = text.replace(old, new)

# CMI/literature style refinements.
text = text.replace("public infection transcriptomes", "public infection transcriptomic cohorts")
text = text.replace("public infection transcriptomic cohorts and identify", "public infection transcriptomes and identify")
text = text.replace("defences", "defences")
text = text.replace("programme", "programme")

# Do not alter formal titles in references too aggressively except UK spelling is acceptable in running text.
# Keep DOI/URL strings unchanged.

out.write_text(text)
print(f"Wrote: {out}")
