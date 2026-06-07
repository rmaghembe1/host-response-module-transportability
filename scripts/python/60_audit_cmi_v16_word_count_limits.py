#!/usr/bin/env python3

from pathlib import Path
import re

path = Path("docs/complete_manuscript_draft_v1.6_step7b_single_author.md")
text = path.read_text()

def section_between(text, start_heading, end_heading):
    start = text.index(start_heading)
    end = text.index(end_heading, start)
    return text[start:end]

def words(s):
    # Remove markdown tables from word count approximation for main text.
    s = re.sub(r"^\|.*\|$", "", s, flags=re.MULTILINE)
    # Remove references/citations numbers but keep text words.
    return re.findall(r"[A-Za-z0-9]+(?:[-'][A-Za-z0-9]+)?", s)

abstract = section_between(text, "## Abstract", "## Keywords")
main_text = section_between(text, "# Introduction", "# Figure captions")
refs = text.split("# References", 1)[1] if "# References" in text else ""
ref_count = len(re.findall(r"^\[[0-9]+\]", refs, flags=re.MULTILINE))

abstract_word_count = len(words(abstract))
main_word_count = len(words(main_text))
full_word_count = len(words(text))

checks = {
    "abstract_le_300": abstract_word_count <= 300,
    "main_text_le_2500": main_word_count <= 2500,
    "references_le_30": ref_count <= 30,
    "has_introduction": "# Introduction" in text,
    "has_methods": "# Methods" in text,
    "has_results": "# Results" in text,
    "has_discussion": "# Discussion" in text,
    "has_transparency": "# Transparency declaration" in text,
    "has_ai_declaration": "# Declaration of generative AI" in text,
    "single_author": "Samweli" not in text and "Abdalah" not in text and "## Author and affiliation" in text,
}

summary = Path("results/audits/cmi_v16_word_count_limits_audit.md")
summary.parent.mkdir(parents=True, exist_ok=True)
summary.write_text(
    "# CMI v1.6 Word Count and Limit Audit\n\n"
    f"Manuscript: `{path}`\n\n"
    f"Abstract word count: {abstract_word_count}\n\n"
    f"Main text word count, Introduction through Discussion: {main_word_count}\n\n"
    f"Full manuscript word count approximation: {full_word_count}\n\n"
    f"Reference count: {ref_count}\n\n"
    "## Checks\n\n"
    + "\n".join(f"- {k}: {'PASS' if v else 'CHECK'}" for k, v in checks.items())
    + "\n\n"
    f"Overall status: {'PASS' if all(checks.values()) else 'CHECK'}\n"
)

print(summary.read_text())

if not all(checks.values()):
    raise SystemExit("CMI word-count/limit audit requires attention.")
