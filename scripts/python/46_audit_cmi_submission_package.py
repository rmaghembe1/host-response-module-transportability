#!/usr/bin/env python3

from pathlib import Path
import csv

expected_files = [
    "submission/CMI_submission_package_index.md",
    "submission/source_markdown/cmi_main_manuscript_v0.8_source.md",
    "submission/source_markdown/cmi_cover_letter_source.md",
    "submission/source_markdown/cmi_supplementary_tables_index_source.md",
    "submission/audits/complete_manuscript_v0.8_cmi_qc_summary.md",
    "submission/audits/complete_manuscript_v0.8_cmi_qc_details.tsv",
    "submission/audits/complete_manuscript_v0.8_cmi_word_count.md",
    "submission/cmi_main_manuscript_v0.8.docx",
    "submission/cmi_cover_letter.docx",
    "submission/cmi_supplementary_tables_S1_to_S5.xlsx",
]

optional_pending_files = [
    "submission/cmi_main_manuscript_v0.8.pdf",
    "submission/cmi_cover_letter.pdf",
]

out = Path("results/audits/cmi_submission_package_audit.tsv")
out.parent.mkdir(parents=True, exist_ok=True)

rows = []
for p in expected_files:
    path = Path(p)
    rows.append({
        "file_type": "required",
        "path": p,
        "exists": str(path.exists()),
        "size_bytes": path.stat().st_size if path.exists() else "",
        "status": "present" if path.exists() else "missing",
    })

for p in optional_pending_files:
    path = Path(p)
    rows.append({
        "file_type": "optional_pending_pdf",
        "path": p,
        "exists": str(path.exists()),
        "size_bytes": path.stat().st_size if path.exists() else "",
        "status": "present" if path.exists() else "pending",
    })

with out.open("w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=["file_type", "path", "exists", "size_bytes", "status"],
        delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(rows)

required_missing = sum(r["file_type"] == "required" and r["status"] == "missing" for r in rows)
required_present = sum(r["file_type"] == "required" and r["status"] == "present" for r in rows)
optional_present = sum(r["file_type"] == "optional_pending_pdf" and r["status"] == "present" for r in rows)
optional_pending = sum(r["file_type"] == "optional_pending_pdf" and r["status"] == "pending" for r in rows)

summary = Path("results/audits/cmi_submission_package_audit_summary.md")
summary.write_text(
    "# CMI Submission Package Audit Summary\n\n"
    f"Required files expected: {len(expected_files)}\n\n"
    f"Required files present: {required_present}\n\n"
    f"Required files missing: {required_missing}\n\n"
    f"Optional PDF files present: {optional_present}\n\n"
    f"Optional PDF files pending: {optional_pending}\n\n"
    f"Detailed audit: `{out}`\n"
)

print(summary.read_text())

if required_missing:
    raise SystemExit("Required CMI submission package files are missing.")
