#!/usr/bin/env python3

from pathlib import Path
import re

manuscript = Path("docs/complete_manuscript_draft_v0.1.md")
out_dir = Path("results/audits")
out_dir.mkdir(parents=True, exist_ok=True)

if not manuscript.exists():
    raise SystemExit(f"Missing manuscript file: {manuscript}")

text = manuscript.read_text()
lines = text.splitlines()

checks = []

patterns = {
    "terminal_text": r"git log|git status|base\)|\[main|commit|oneline|decorate|host-pathogen|forgit",
    "unresolved_placeholders": r"\bTBD\b|\bTODO\b|\bFIXME\b|\?\?\?|INSERT|PLACEHOLDER|to draft",
    "diagnostic_overclaiming": r"diagnostic classifier validation|validated diagnostic model|clinical diagnostic test|diagnostic accuracy|diagnostic biomarker",
    "causal_overclaiming": r"\bcauses\b|\bcausal mechanism\b|\bproves\b|\bdemonstrates causality\b",
    "rediscovery_language": r"rediscovered in GSE73461|redefined in GSE73461|reselected in GSE73461|trained in GSE73461",
}

for check_name, pattern in patterns.items():
    hits = []
    for i, line in enumerate(lines, start=1):
        if re.search(pattern, line, flags=re.IGNORECASE):
            hits.append((i, line))
    checks.append((check_name, hits))

headings = []
for i, line in enumerate(lines, start=1):
    if re.match(r"^#{1,6}\s+", line):
        level = len(line) - len(line.lstrip("#"))
        title = line.lstrip("#").strip()
        headings.append((i, level, title))

seen = {}
duplicates = []
for i, level, title in headings:
    key = (level, title.lower())
    if key in seen:
        duplicates.append((i, level, title, seen[key]))
    else:
        seen[key] = i

required_phrases = {
    "fixed-module transportability": "fixed-module transportability",
    "not diagnostic validation": "diagnostic model validation",
    "no causal inference": "causal inference",
    "GSE211567": "GSE211567",
    "GSE73461": "GSE73461",
    "BACT_M1": "BACT_M1",
    "BACT_M2": "BACT_M2",
    "VIR_M1a": "VIR_M1a",
    "VIR_M1b": "VIR_M1b",
    "VIR_M2": "VIR_M2",
}

missing_required = []
for label, phrase in required_phrases.items():
    if phrase not in text:
        missing_required.append((label, phrase))

summary_file = out_dir / "complete_manuscript_v0.1_qc_summary.md"
detail_file = out_dir / "complete_manuscript_v0.1_qc_details.tsv"

with detail_file.open("w") as f:
    f.write("check\tline\tcontent\n")
    for check_name, hits in checks:
        if hits:
            for line_no, content in hits:
                f.write(f"{check_name}\t{line_no}\t{content}\n")
        else:
            f.write(f"{check_name}\tPASS\t\n")

    if duplicates:
        for line_no, level, title, first_line in duplicates:
            f.write(f"duplicate_heading\t{line_no}\tlevel {level}: {title} | first_seen_line={first_line}\n")
    else:
        f.write("duplicate_heading\tPASS\t\n")

    if missing_required:
        for label, phrase in missing_required:
            f.write(f"missing_required_phrase\tNA\t{label}: {phrase}\n")
    else:
        f.write("missing_required_phrase\tPASS\t\n")

with summary_file.open("w") as f:
    f.write("# Complete Manuscript Draft v0.1 QC Summary\n\n")
    f.write(f"Manuscript: `{manuscript}`\n\n")
    f.write(f"Total lines: {len(lines)}\n\n")
    f.write(f"Total headings: {len(headings)}\n\n")
    f.write("## Pattern checks\n\n")
    for check_name, hits in checks:
        f.write(f"- {check_name}: {'PASS' if not hits else str(len(hits)) + ' hit(s)'}\n")
    f.write(f"- duplicate headings: {'PASS' if not duplicates else str(len(duplicates)) + ' duplicate(s)'}\n")
    f.write(f"- required phrases: {'PASS' if not missing_required else str(len(missing_required)) + ' missing'}\n\n")
    f.write("## Files written\n\n")
    f.write(f"- `{summary_file}`\n")
    f.write(f"- `{detail_file}`\n")

print(summary_file.read_text())
print(f"Wrote details: {detail_file}")

# Do not hard-fail on content warnings; the report is for manuscript review.
