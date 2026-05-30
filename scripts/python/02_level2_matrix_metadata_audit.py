#!/usr/bin/env python3

from pathlib import Path
import gzip
import csv
import hashlib
from datetime import datetime

ROOT = Path(".")
RAW = ROOT / "data" / "raw"
META = ROOT / "data" / "metadata_raw"
DOCS = ROOT / "docs"

FILES = [
    ("GSE211567", "discovery_normalized_matrix", RAW / "GSE211567_normData_discovery_2021MAR24.txt.gz"),
    ("GSE161731", "adult_count_matrix", RAW / "GSE161731_counts.csv.gz"),
    ("GSE161731", "adult_counts_key", RAW / "GSE161731_counts_key.csv.gz"),
    ("GSE161731", "adult_sample_key", RAW / "GSE161731_key.csv.gz"),
    ("GSE261482", "pediatric_count_matrix", RAW / "GSE261482_Counts_raw_data.csv.gz"),
]

def sha256_file(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def open_text(path):
    return gzip.open(path, "rt", errors="replace", newline="") if path.suffix == ".gz" else path.open("rt", errors="replace", newline="")

def guess_delimiter(header):
    counts = {d: header.count(d) for d in ["\t", ",", ";"]}
    return max(counts, key=counts.get)

def split_line(line, delim):
    if delim == ",":
        return next(csv.reader([line]))
    return line.rstrip("\n\r").split(delim)

def inspect_table(path):
    info = {
        "exists": path.exists(),
        "size_bytes": path.stat().st_size if path.exists() else None,
        "sha256": sha256_file(path) if path.exists() else None,
        "delimiter": None,
        "n_columns": None,
        "n_data_rows": None,
        "header": [],
        "preview": [],
        "first_column_name": None,
    }

    if not path.exists():
        return info

    with open_text(path) as f:
        header_line = f.readline()
        delim = guess_delimiter(header_line)
        header = split_line(header_line, delim)

        info["delimiter"] = "\\t" if delim == "\t" else delim
        info["n_columns"] = len(header)
        info["header"] = header
        info["first_column_name"] = header[0] if header else None

        rows = 0
        preview = []
        for line in f:
            if not line.strip():
                continue
            rows += 1
            if len(preview) < 5:
                preview.append(split_line(line, delim)[:8])
        info["n_data_rows"] = rows
        info["preview"] = preview

    return info

def short_list(values, n=12):
    values = list(values)
    if len(values) <= n:
        return ", ".join(values)
    return ", ".join(values[:n]) + f", ... [total {len(values)}]"

def read_header(path):
    with open_text(path) as f:
        header_line = f.readline()
    delim = guess_delimiter(header_line)
    return split_line(header_line, delim)

def read_small_table(path):
    with open_text(path) as f:
        header_line = f.readline()
        delim = guess_delimiter(header_line)
        header = split_line(header_line, delim)
        rows = [split_line(line, delim) for line in f if line.strip()]
    return header, rows

def main():
    inspections = []

    for accession, role, path in FILES:
        info = inspect_table(path)
        info.update({"accession": accession, "role": role, "filename": path.name})
        inspections.append(info)

    inventory_path = META / "level2_matrix_file_inventory.tsv"
    with inventory_path.open("w", newline="") as out:
        writer = csv.writer(out, delimiter="\t")
        writer.writerow([
            "accession", "role", "filename", "exists", "size_bytes",
            "sha256", "delimiter", "n_columns", "n_data_rows", "first_column_name"
        ])
        for x in inspections:
            writer.writerow([
                x["accession"], x["role"], x["filename"], x["exists"],
                x["size_bytes"], x["sha256"], x["delimiter"],
                x["n_columns"], x["n_data_rows"], x["first_column_name"]
            ])

    compatibility_lines = []
    try:
        counts_header = read_header(RAW / "GSE161731_counts.csv.gz")
        count_sample_cols = counts_header[1:]

        ck_header, ck_rows = read_small_table(RAW / "GSE161731_counts_key.csv.gz")
        key_header, key_rows = read_small_table(RAW / "GSE161731_key.csv.gz")

        count_set = set(count_sample_cols)
        ck_cells = set(cell for row in ck_rows for cell in row)
        key_cells = set(cell for row in key_rows for cell in row)

        compatibility_lines.extend([
            f"- GSE161731 count-matrix total columns: {len(counts_header)}",
            f"- GSE161731 count-matrix sample columns after first identifier column: {len(count_sample_cols)}",
            f"- GSE161731 count-matrix first identifier column: `{counts_header[0] if counts_header else 'NA'}`",
            f"- GSE161731 counts-key columns: {short_list(ck_header)}",
            f"- GSE161731 counts-key rows: {len(ck_rows)}",
            f"- GSE161731 sample-key columns: {short_list(key_header)}",
            f"- GSE161731 sample-key rows: {len(key_rows)}",
            f"- Count sample IDs found anywhere in counts-key cells: {len(count_set & ck_cells)}",
            f"- Count sample IDs found anywhere in sample-key cells: {len(count_set & key_cells)}",
        ])
    except Exception as e:
        compatibility_lines.append(f"- GSE161731 compatibility check failed: {e}")

    report_path = DOCS / "level2_matrix_metadata_content_audit_generated.md"
    with report_path.open("w", encoding="utf-8") as out:
        out.write("# Level-2 Matrix and Metadata Content Audit\n\n")
        out.write(f"- Generated: {datetime.now().isoformat(timespec='seconds')}\n")
        out.write("- Purpose: structural file inspection only; no biological modelling or module selection.\n")
        out.write("- Boundary: GSE211567 remains discovery; GSE161731 is only technical/count-level rehearsal until modules are frozen; GSE261482 remains exploratory; GSE282464 remains conditional and undownloaded.\n\n")

        out.write("## File inventory\n\n")
        out.write("| Accession | Role | File | Size bytes | Delimiter | Data rows | Columns | First column |\n")
        out.write("|---|---|---|---:|---|---:|---:|---|\n")
        for x in inspections:
            out.write(
                f"| {x['accession']} | {x['role']} | `{x['filename']}` | "
                f"{x['size_bytes']} | `{x['delimiter']}` | {x['n_data_rows']} | "
                f"{x['n_columns']} | `{x['first_column_name']}` |\n"
            )

        out.write("\n## Header previews\n\n")
        for x in inspections:
            out.write(f"### {x['filename']}\n\n")
            out.write(f"- First header fields: `{short_list(x['header'], 20)}`\n")
            out.write("- First preview rows, first fields only:\n\n")
            for row in x["preview"]:
                out.write(f"  - `{short_list(row, 8)}`\n")
            out.write("\n")

        out.write("## GSE161731 matrix/key compatibility inspection\n\n")
        for line in compatibility_lines:
            out.write(line + "\n")

        out.write("\n## Immediate interpretation\n\n")
        out.write("- This audit confirms structural readability only.\n")
        out.write("- Sample eligibility, infection-class reconstruction, repeated-sample handling and contrast locking must be performed next.\n")
        out.write("- No differential expression, enrichment, module selection or transportability interpretation has been performed.\n")

    print(f"Wrote {inventory_path}")
    print(f"Wrote {report_path}")

if __name__ == "__main__":
    main()
