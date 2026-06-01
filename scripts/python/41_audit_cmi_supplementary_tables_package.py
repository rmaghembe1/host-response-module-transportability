#!/usr/bin/env python3

from pathlib import Path
import csv

paths = [
    "docs/supplementary_materials/CMI_supplementary_tables_index.md",

    "docs/supplementary_materials/Supplementary_Table_S1_external_projection_candidate_register.md",
    "results/supplementary_tables/Supplementary_Table_S1_external_projection_candidate_register.tsv",

    "docs/supplementary_materials/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.md",
    "results/supplementary_tables/Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.tsv",

    "docs/supplementary_materials/Supplementary_Table_S3_GSE73461_identifier_coverage_and_scored_genes.md",
    "results/supplementary_tables/Supplementary_Table_S3A_GSE73461_module_identifier_coverage.tsv",
    "results/supplementary_tables/Supplementary_Table_S3B_GSE73461_matched_locked_module_genes.tsv",
    "results/supplementary_tables/Supplementary_Table_S3C_GSE73461_missing_locked_module_genes.tsv",
    "results/supplementary_tables/Supplementary_Table_S3D_GSE73461_gene_probe_choice_for_projection.tsv",

    "docs/supplementary_materials/Supplementary_Table_S4_GSE73461_projection_sample_scores.md",
    "results/supplementary_tables/Supplementary_Table_S4A_GSE73461_fixed_module_scores_long.tsv",
    "results/supplementary_tables/Supplementary_Table_S4B_GSE73461_fixed_module_scores_wide.tsv",

    "docs/supplementary_materials/Supplementary_Table_S5_GSE73461_projection_statistics_and_sensitivity.md",
    "results/supplementary_tables/Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv",
    "results/supplementary_tables/Supplementary_Table_S5B_GSE73461_primary_only_zscore_sensitivity_tests.tsv",
    "results/supplementary_tables/Supplementary_Table_S5C_GSE73461_manuscript_projection_summary.tsv",
]

out = Path("results/audits/cmi_supplementary_tables_package_audit.tsv")
out.parent.mkdir(parents=True, exist_ok=True)

rows = []
for p in paths:
    path = Path(p)
    rows.append({
        "path": p,
        "exists": str(path.exists()),
        "size_bytes": path.stat().st_size if path.exists() else "",
        "status": "present" if path.exists() else "missing",
    })

with out.open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["path", "exists", "size_bytes", "status"], delimiter="\t")
    writer.writeheader()
    writer.writerows(rows)

present = sum(r["status"] == "present" for r in rows)
missing = sum(r["status"] == "missing" for r in rows)

summary = Path("results/audits/cmi_supplementary_tables_package_audit_summary.md")
summary.write_text(
    "# CMI Supplementary Tables Package Audit Summary\n\n"
    f"Total expected files: {len(rows)}\n\n"
    f"Present: {present}\n\n"
    f"Missing: {missing}\n\n"
    f"Detailed audit: `{out}`\n"
)

print(summary.read_text())

if missing:
    raise SystemExit("Missing supplementary table files detected.")
