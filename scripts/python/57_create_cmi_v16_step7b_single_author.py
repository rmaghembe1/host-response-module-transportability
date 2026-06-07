#!/usr/bin/env python3

from pathlib import Path
import re

src = Path("docs/complete_manuscript_draft_v1.5_step7_editable_table1.md")
out = Path("docs/complete_manuscript_draft_v1.6_step7b_single_author.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.5 — Step 7 Editable Table 1",
    "# Complete Manuscript Draft v1.6 — Step 7b Single-Author Correction"
)

# Replace author/affiliation block with single-author version.
old_author_block = """## Authors and affiliations

Reuben S. Maghembe1*  
Samweli Bahati2  
Abdalah Makaranga3  

1 St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  
2 AfroBiomics Co. Ltd, Tanzania  
3 Mwenge Catholic University (MWECAU), Tanzania  

*Corresponding author:  
Reuben S. Maghembe  
St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  
Email: rmaghembe@sfuchas.ac.tz
"""

new_author_block = """## Author and affiliation

Reuben S. Maghembe*  

St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  

*Corresponding author:  
Reuben S. Maghembe  
St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania  
Email: rmaghembe@sfuchas.ac.tz
"""

if old_author_block not in text:
    raise SystemExit("Expected multi-author block not found.")

text = text.replace(old_author_block, new_author_block)

# Replace author contributions with single-author wording.
old_contrib = """## Author contributions

Reuben S. Maghembe: Conceptualisation, methodology, formal analysis, investigation, data curation, visualisation, writing — original draft, writing — review and editing, project administration.  
Samweli Bahati: Methodological input, data interpretation, writing — review and editing.  
Abdalah Makaranga: Data interpretation, manuscript review, writing — review and editing.
"""

new_contrib = """## Author contributions

Reuben S. Maghembe: Conceptualisation, methodology, formal analysis, investigation, data curation, visualisation, writing — original draft, writing — review and editing, project administration, and final approval of the manuscript.
"""

if old_contrib not in text:
    raise SystemExit("Expected multi-author contributions block not found.")

text = text.replace(old_contrib, new_contrib)

# Single-author grammar cleanup.
text = text.replace("The authors declare no competing interests.", "The author declares no competing interests.")
text = text.replace("The authors thank", "The author thanks")
text = text.replace("The authors also acknowledge", "The author also acknowledges")
text = text.replace("The authors reviewed, edited and verified", "The author reviewed, edited and verified")
text = text.replace("the authors used generative AI-assisted tools", "the author used generative AI-assisted tools")
text = text.replace("and take full responsibility", "and takes full responsibility")

# Safety checks.
for forbidden in ["Samweli", "Bahati", "Abdalah", "Makaranga", "Authors and affiliations"]:
    if forbidden in text:
        raise SystemExit(f"Forbidden multi-author term remains: {forbidden}")

required = [
    "## Author and affiliation",
    "Reuben S. Maghembe*",
    "The author declares no competing interests.",
    "Reuben S. Maghembe: Conceptualisation",
    "takes full responsibility for the final content of the manuscript",
]
missing = [x for x in required if x not in text]
if missing:
    raise SystemExit("Missing required single-author phrase(s):\n" + "\n".join(missing))

out.write_text(text)
print(f"Wrote: {out}")
