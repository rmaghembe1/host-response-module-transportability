#!/usr/bin/env python3

from pathlib import Path
import csv
import re

manuscript = Path("docs/complete_manuscript_draft_v0.8_cmi_compressed.md")

expected_files = [
    # Main manuscript figure outputs: update paths after the find command if names differ.
    ("main_figure_candidate", "results/figures", "directory"),

    # Main table / table support files.
    ("supplementary_workbook", "submission/cmi_supplementary_tables_S1_to_S5.xlsx", "file"),
    ("supplementary_index", "docs/supplementary_materials/CMI_supplementary_tables_index.md", "file"),
    ("supplementary_table_S1_tsv", "results/supplementary_tables/Supplementary_Table_S1_external_projection_candidate_register.tsv", "file"),
    ("supplementary_table_S2_tsv", "results/supplementary_tables/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.tsv", "file"),
    ("supplementary_table_S3A_tsv", "results/supplementary_tables/Supplementary_Table_S3A_GSE73461_module_identifier_coverage.tsv", "file"),
    ("supplementary_table_S3B_tsv", "results/supplementary_tables/Supplementary_Table_S3B_GSE73461_matched_locked_module_genes.tsv", "file"),
    ("supplementary_table_S3C_tsv", "results/supplementary_tables/Supplementary_Table_S3C_GSE73461_missing_locked_module_genes.tsv", "file"),
    ("supplementary_table_S3D_tsv", "results/supplementary_tables/Supplementary_Table_S3D_GSE73461_gene_probe_choice_for_projection.tsv", "file"),
    ("supplementary_table_S4A_tsv", "results/supplementary_tables/Supplementary_Table_S4A_GSE73461_fixed_module_scores_long.tsv", "file"),
    ("supplementary_table_S4B_tsv", "results/supplementary_tables/Supplementary_Table_S4B_GSE73461_fixed_module_scores_wide.tsv", "file"),
    ("supplementary_table_S5A_tsv", "results/supplementary_tables/Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv", "file"),
    ("supplementary_table_S5B_tsv", "results/supplementary_tables/Supplementary_Table_S5B_GSE73461_primary_only_zscore_sensitivity_tests.tsv", "file"),
    ("supplementary_table_S5C_tsv", "results/supplementary_tables/Supplementary_Table_S5C_GSE73461_manuscript_projection_summary.tsv", "file"),
]

text = manuscript.read_text()

callouts = {
    "Figure 1": len(re.findall(r"\bFigure 1\b", text)),
    "Figure 2": len(re.findall(r"\bFigure 2\b", text)),
    "Table 1": len(re.findall(r"\bTable 1\b", text)),
    "Supplementary Table S1": len(re.findall(r"\bSupplementary Table S1\b", text)),
    "Supplementary Table S2": len(re.findall(r"\bSupplementary Table S2\b", text)),
    "Supplementary Table S3": len(re.findall(r"\bSupplementary Table S3\b", text)),
    "Supplementary Table S4": len(re.findall(r"\bSupplementary Table S4\b", text)),
    "Supplementary Table S5": len(re.findall(r"\bSupplementary Table S5\b", text)),
    "Supplementary Tables S1–S5": len(re.findall(r"Supplementary Tables S1[–-]S5", text)),
}

figure_files = []
for root in [Path("results/figures"), Path("submission/figures")]:
    if root.exists():
        for p in root.rglob("*"):
            if p.is_file() and p.suffix.lower() in [".png", ".svg", ".pdf"]:
                figure_files.append(str(p))

rows = []
for label, path_str, kind in expected_files:
    p = Path(path_str)
    if kind == "directory":
        exists = p.exists() and p.is_dir()
        size = ""
    else:
        exists = p.exists() and p.is_file()
        size = p.stat().st_size if exists else ""
    rows.append({
        "category": "expected_file_or_directory",
        "item": label,
        "path": path_str,
        "exists": str(exists),
        "size_bytes": size,
        "status": "present" if exists else "missing",
    })

for callout, count in callouts.items():
    rows.append({
        "category": "manuscript_callout",
        "item": callout,
        "path": manuscript.as_posix(),
        "exists": str(count > 0),
        "size_bytes": "",
        "status": f"count={count}",
    })

for p in figure_files:
    fp = Path(p)
    rows.append({
        "category": "located_figure_file",
        "item": fp.name,
        "path": p,
        "exists": "True",
        "size_bytes": fp.stat().st_size,
        "status": "located",
    })

out = Path("results/audits/cmi_figures_tables_audit.tsv")
out.parent.mkdir(parents=True, exist_ok=True)

with out.open("w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=["category", "item", "path", "exists", "size_bytes", "status"],
        delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(rows)

missing_expected = [
    r for r in rows
    if r["category"] == "expected_file_or_directory" and r["status"] == "missing"
]

summary = Path("results/audits/cmi_figures_tables_audit_summary.md")
summary.write_text(
    "# CMI Figures and Tables Audit Summary\n\n"
    f"Manuscript audited: `{manuscript}`\n\n"
    f"Expected file/directory entries checked: {len(expected_files)}\n\n"
    f"Missing expected entries: {len(missing_expected)}\n\n"
    f"Located figure files: {len(figure_files)}\n\n"
    "## Manuscript callout counts\n\n"
    + "\n".join(f"- {k}: {v}" for k, v in callouts.items())
    + "\n\n"
    f"Detailed audit: `{out}`\n"
)

print(summary.read_text())

# Do not fail on missing main figure files yet, because this first pass is meant to locate them.
