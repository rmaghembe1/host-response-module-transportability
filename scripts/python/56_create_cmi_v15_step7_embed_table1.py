#!/usr/bin/env python3

from pathlib import Path
import csv
import re

src = Path("docs/complete_manuscript_draft_v1.4_step6_british_spelling.md")
table_src = Path("submission/tables/Table_1_GSE73461_projection_summary.tsv")
out = Path("docs/complete_manuscript_draft_v1.5_step7_editable_table1.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.4 — Step 6 British Spelling and CMI Language",
    "# Complete Manuscript Draft v1.5 — Step 7 Editable Table 1"
)

if not table_src.exists():
    raise SystemExit(f"Missing Table 1 source: {table_src}")

with table_src.open(newline="") as f:
    reader = csv.reader(f, delimiter="\t")
    rows = list(reader)

if len(rows) < 2:
    raise SystemExit("Table 1 source has no data rows.")

# Build editable Markdown table.
header = rows[0]
data = rows[1:]

def clean_cell(x):
    x = str(x).strip()
    x = x.replace("\n", " ")
    x = x.replace("|", "/")
    return x

md_lines = []
md_lines.append("| " + " | ".join(clean_cell(x) for x in header) + " |")
md_lines.append("| " + " | ".join("---" for _ in header) + " |")
for row in data:
    padded = row + [""] * (len(header) - len(row))
    md_lines.append("| " + " | ".join(clean_cell(x) for x in padded[:len(header)]) + " |")

table_md = "\n".join(md_lines)

# Replace Columns helper block with actual editable table.
pattern = r"## Columns\n\n.*?(?=\n## Notes)"
replacement = "## Editable table\n\n" + table_md + "\n\n"
text = re.sub(pattern, replacement, text, flags=re.S)

# Confirm old helper heading gone and table present.
if "## Columns" in text:
    raise SystemExit("Old Table 1 Columns helper section remains.")
if "## Editable table" not in text:
    raise SystemExit("Editable table section not inserted.")
if "| " not in text:
    raise SystemExit("Markdown table not detected.")

out.write_text(text)
print(f"Wrote: {out}")
print(f"Inserted Table 1 rows including header: {len(rows)}")
