#!/usr/bin/env python3

from pathlib import Path
import re
import sys

index_file = Path("docs/manuscript_results_package_index.md")

if not index_file.exists():
    raise SystemExit(f"Missing package index file: {index_file}")

text = index_file.read_text()

paths = re.findall(r"`([^`]+)`", text)
paths = [
    p for p in paths
    if p.startswith(("results/", "docs/", "scripts/", "env/", "data/"))
]

unique_paths = []
seen = set()
for p in paths:
    path = Path(p)
    if path not in seen:
        seen.add(path)
        unique_paths.append(path)

missing = [p for p in unique_paths if not p.exists()]
present = [p for p in unique_paths if p.exists()]

out_dir = Path("results/audits")
out_dir.mkdir(parents=True, exist_ok=True)

audit_file = out_dir / "manuscript_results_package_index_path_audit.tsv"
with audit_file.open("w") as f:
    f.write("path\tstatus\n")
    for p in unique_paths:
        f.write(f"{p}\t{'present' if p.exists() else 'missing'}\n")

print(f"Package index path entries: {len(paths)}")
print(f"Unique checked paths: {len(unique_paths)}")
print(f"Present: {len(present)}")
print(f"Missing: {len(missing)}")
print(f"Wrote: {audit_file}")

if missing:
    print("\nMissing paths:")
    for p in missing:
        print(f"- {p}")
    sys.exit(1)

print("\nAll package-index paths exist.")
