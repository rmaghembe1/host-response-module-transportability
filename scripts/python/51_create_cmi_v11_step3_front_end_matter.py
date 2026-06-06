#!/usr/bin/env python3

from pathlib import Path
import re

src = Path("docs/complete_manuscript_draft_v1.0_step2_imrad_headings.md")
out = Path("docs/complete_manuscript_draft_v1.1_step3_front_end_matter.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.0 — Step 2 CMI IMRaD Headings",
    "# Complete Manuscript Draft v1.1 — Step 3 CMI Front and End Matter"
)

# Remove remaining internal Purpose section near the top.
text = re.sub(
    r"\n## Purpose\n\nDraft v0\.9 Step 1 removes internal submission-route and draft-boundary notes from the manuscript body while preserving scientific caution within the Methods, Results and Discussion\.\n\n",
    "\n",
    text,
    flags=re.S
)

# Also remove any generic Purpose heading block if still present.
text = re.sub(
    r"\n## Purpose\n\n.*?(?=\n## Title)",
    "\n",
    text,
    flags=re.S
)

# Clean title page.
front_matter = """## Article category

Original Article

## Title

External transportability of bacterial- and viral-associated host-response modules: a site-aware public transcriptomic cohort study

## Short title

Transportable infection modules

## Authors and affiliations

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

# Replace old front matter from Article/Title through Code availability, leaving Abstract onward.
text = re.sub(
    r"## Title\n\n.*?(?=\n## Abstract)",
    front_matter,
    text,
    flags=re.S
)

# Build CMI-style end matter to be placed after Supplementary material and before references in later steps.
end_matter = """# Transparency declaration

## Conflicts of interest

The authors declare no competing interests.

## Funding

This research received no specific grant from any funding agency in the public, commercial or not-for-profit sectors.

## Ethics approval

This study reanalysed publicly available de-identified transcriptomic datasets and did not involve new recruitment of human participants, new collection of human biospecimens or access to identifiable private information. No new ethics approval was required for this secondary analysis of public data.

## Data availability

This study reanalysed publicly available transcriptomic datasets. The discovery analysis used GSE211567, and the formal external projection analysis used GSE73461. Candidate or technical-rehearsal datasets considered during workflow development included GSE161731, GSE261482 and GSE68310. Dataset accession numbers, cohort-lock decisions, analysis boundaries and interpretation safeguards are recorded in the repository decision log and supplementary materials.

## Code availability

Analysis scripts, decision logs, audit outputs, manuscript-facing tables, supplementary tables and figure-generation outputs are organised in the project repository. Repository access details will be provided at submission or made available upon reasonable request.

## Author contributions

Reuben S. Maghembe: Conceptualisation, methodology, formal analysis, investigation, data curation, visualisation, writing — original draft, writing — review and editing, project administration.  
Samweli Bahati: Methodological input, data interpretation, writing — review and editing.  
Abdalah Makaranga: Data interpretation, manuscript review, writing — review and editing.

## Acknowledgements

The authors thank the investigators and participants of the public transcriptomic studies reanalysed in this work, including GSE211567 and GSE73461. The authors also acknowledge the public repositories and database maintainers that made these datasets available for secondary analysis. This acknowledgement does not imply endorsement of the present analysis by the original dataset generators.
"""

# Place end matter after Supplementary material section content.
if "# Transparency declaration" not in text:
    text = text.rstrip() + "\n\n" + end_matter + "\n"

# Ensure CMI-required headings exist.
required = [
    "## Article category",
    "## Title",
    "## Authors and affiliations",
    "# Introduction",
    "# Methods",
    "# Results",
    "# Discussion",
    "# Transparency declaration",
    "## Conflicts of interest",
    "## Funding",
    "## Ethics approval",
    "## Data availability",
    "## Code availability",
    "## Author contributions",
    "## Acknowledgements",
]
missing = [h for h in required if h not in text]
if missing:
    raise SystemExit("Missing required heading(s):\n" + "\n".join(missing))

# Ensure removed author role labels and old role fields are gone.
forbidden = [
    "Role: First author",
    "Role: Contributing author",
    "## Purpose",
    "Competing interests",
]
# Allow Conflicts of interest, but not old "## Competing interests"
if "## Competing interests" in text:
    raise SystemExit("Old 'Competing interests' heading still present.")
if "Role:" in text:
    raise SystemExit("Old author role label still present.")

out.write_text(text)
print(f"Wrote: {out}")
