#!/usr/bin/env python3

from pathlib import Path
import re
import sys

mapping_file = Path("docs/manuscript_results_figure_table_mapping.md")

if not mapping_file.exists():
    raise SystemExit(f"Missing mapping file: {mapping_file}")

text = mapping_file.read_text()

# Extract inline-code paths.
paths = re.findall(r"`([^`]+)`", text)

# Exclude non-path inline code if any.
paths = [
    p for p in paths
    if p.startswith(("results/", "docs/", "scripts/", "env/", "data/"))
]

expanded = []

for p in paths:
    path = Path(p)

    # Figure file bases are intentionally extension-less. Check png/svg/pdf triplets.
    if str(path).startswith("results/figures/") and path.suffix == "":
        for ext in [".png", ".svg", ".pdf"]:
            expanded.append(Path(str(path) + ext))
    else:
        expanded.append(path)

seen = set()
unique_expanded = []
for p in expanded:
    if p not in seen:
        seen.add(p)
        unique_expanded.append(p)

missing = [p for p in unique_expanded if not p.exists()]
present = [p for p in unique_expanded if p.exists()]

out_dir = Path("results/audits")
out_dir.mkdir(parents=True, exist_ok=True)

audit_file = out_dir / "manuscript_results_figure_table_mapping_path_audit.tsv"
with audit_file.open("w") as f:
    f.write("path\tstatus\n")
    for p in unique_expanded:
        f.write(f"{p}\t{'present' if p.exists() else 'missing'}\n")

print(f"Mapped path entries: {len(paths)}")
print(f"Expanded checked files: {len(unique_expanded)}")
print(f"Present: {len(present)}")
print(f"Missing: {len(missing)}")
print(f"Wrote: {audit_file}")

if missing:
    print("\nMissing paths:")
    for p in missing:
        print(f"- {p}")
    sys.exit(1)

print("\nAll mapped paths exist.")
