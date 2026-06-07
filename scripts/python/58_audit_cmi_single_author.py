#!/usr/bin/env python3

from pathlib import Path

path = Path("docs/complete_manuscript_draft_v1.6_step7b_single_author.md")
text = path.read_text()

forbidden = [
    "Samweli",
    "Bahati",
    "Abdalah",
    "Makaranga",
    "Authors and affiliations",
    "The authors declare",
    "The authors thank",
    "The authors also acknowledge",
    "The authors reviewed",
]

required = [
    "## Author and affiliation",
    "Reuben S. Maghembe*",
    "The author declares no competing interests.",
    "Reuben S. Maghembe: Conceptualisation",
    "The author thanks",
    "The author also acknowledges",
    "The author reviewed, edited and verified",
    "takes full responsibility for the final content of the manuscript",
]

forbidden_hits = [x for x in forbidden if x in text]
missing = [x for x in required if x not in text]

summary = Path("results/audits/cmi_single_author_audit.md")
summary.parent.mkdir(parents=True, exist_ok=True)
summary.write_text(
    "# CMI Single-Author Audit\n\n"
    f"Manuscript: `{path}`\n\n"
    f"Forbidden multi-author terms found: {', '.join(forbidden_hits) if forbidden_hits else 'None'}\n\n"
    f"Missing required single-author terms: {', '.join(missing) if missing else 'None'}\n\n"
    f"Status: {'PASS' if not forbidden_hits and not missing else 'CHECK'}\n"
)

print(summary.read_text())

if forbidden_hits or missing:
    raise SystemExit("Single-author audit requires attention.")
