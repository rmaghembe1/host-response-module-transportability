#!/usr/bin/env python3

from pathlib import Path
import re

path = Path("docs/complete_manuscript_draft_v1.2_step4_references.md")
text = path.read_text()

body, refs = text.split("# References", 1)

# Extract reference numbers from reference list
ref_nums = sorted(int(x) for x in re.findall(r"^\[([0-9]+)\]", refs, flags=re.MULTILINE))

# Extract citation numbers and ranges from body
citation_blocks = re.findall(r"\[([0-9,\s–-]+)\]", body)

cited = set()
for block in citation_blocks:
    parts = [p.strip() for p in re.split(r",", block)]
    for part in parts:
        if not part:
            continue
        if "–" in part or "-" in part:
            bits = re.split(r"[–-]", part)
            if len(bits) == 2 and bits[0].strip().isdigit() and bits[1].strip().isdigit():
                start, end = int(bits[0]), int(bits[1])
                cited.update(range(start, end + 1))
        elif part.isdigit():
            cited.add(int(part))

refs_set = set(ref_nums)
uncited_refs = sorted(refs_set - cited)
missing_refs = sorted(cited - refs_set)

out = Path("results/audits/cmi_v12_reference_audit.md")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(
    "# CMI v1.2 Reference Audit\n\n"
    f"Manuscript: `{path}`\n\n"
    f"Reference count: {len(ref_nums)}\n\n"
    f"Cited reference numbers: {', '.join(map(str, sorted(cited)))}\n\n"
    f"Uncited references: {', '.join(map(str, uncited_refs)) if uncited_refs else 'None'}\n\n"
    f"Citations without reference-list entries: {', '.join(map(str, missing_refs)) if missing_refs else 'None'}\n\n"
    f"CMI maximum reference limit for Original Articles: 30\n\n"
    f"Status: {'PASS' if not uncited_refs and not missing_refs and len(ref_nums) <= 30 else 'CHECK'}\n"
)

print(out.read_text())

if uncited_refs or missing_refs or len(ref_nums) > 30:
    raise SystemExit("Reference audit requires attention.")
