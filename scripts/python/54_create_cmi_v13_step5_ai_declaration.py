#!/usr/bin/env python3

from pathlib import Path

src = Path("docs/complete_manuscript_draft_v1.2_step4_references.md")
out = Path("docs/complete_manuscript_draft_v1.3_step5_ai_declaration.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.2 — Step 4 Vancouver References",
    "# Complete Manuscript Draft v1.3 — Step 5 AI Declaration"
)

section = """# Declaration of generative AI and AI-assisted technologies in the manuscript preparation process

During the preparation of this manuscript, the authors used generative AI-assisted tools to support editorial organisation, language refinement, formatting checks and preparation of submission-support materials. The authors reviewed, edited and verified the manuscript content, analyses, interpretation, references and submission materials, and take full responsibility for the final content of the manuscript.
"""

if "# Declaration of generative AI and AI-assisted technologies in the manuscript preparation process" not in text:
    if "\n# References\n" not in text:
        raise SystemExit("References heading not found.")
    text = text.replace("\n# References\n", "\n" + section + "\n# References\n")

required = [
    "# Declaration of generative AI and AI-assisted technologies in the manuscript preparation process",
    "take full responsibility for the final content of the manuscript",
    "# References",
]
missing = [p for p in required if p not in text]
if missing:
    raise SystemExit("Missing required AI/reference phrase(s):\n" + "\n".join(missing))

out.write_text(text)
print(f"Wrote: {out}")
