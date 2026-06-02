#!/usr/bin/env python3

from pathlib import Path
import csv

expected_files = [
    "submission/figures/Figure_1A_GSE211567_primary_discovery_volcano.png",
    "submission/figures/Figure_1A_GSE211567_primary_discovery_volcano.svg",
    "submission/figures/Figure_1A_GSE211567_primary_discovery_volcano.pdf",
    "submission/figures/Figure_1B_GSE211567_site_stratified_concordance_summary.png",
    "submission/figures/Figure_1B_GSE211567_site_stratified_concordance_summary.svg",
    "submission/figures/Figure_1B_GSE211567_site_stratified_concordance_summary.pdf",
    "submission/figures/Figure_1C_GSE211567_locked_discovery_module_gene_counts.png",
    "submission/figures/Figure_1C_GSE211567_locked_discovery_module_gene_counts.svg",
    "submission/figures/Figure_1C_GSE211567_locked_discovery_module_gene_counts.pdf",
    "submission/figures/Figure_2A_GSE73461_module_score_distributions.png",
    "submission/figures/Figure_2A_GSE73461_module_score_distributions.svg",
    "submission/figures/Figure_2A_GSE73461_module_score_distributions.pdf",
    "submission/figures/Figure_2B_GSE73461_main_vs_sensitivity_median_differences.png",
    "submission/figures/Figure_2B_GSE73461_main_vs_sensitivity_median_differences.svg",
    "submission/figures/Figure_2B_GSE73461_main_vs_sensitivity_median_differences.pdf",
    "submission/figures/Figure_2C_GSE73461_main_vs_sensitivity_pvalues.png",
    "submission/figures/Figure_2C_GSE73461_main_vs_sensitivity_pvalues.svg",
    "submission/figures/Figure_2C_GSE73461_main_vs_sensitivity_pvalues.pdf",
    "submission/tables/Table_1_GSE73461_projection_summary.tsv",
]

rows = []
for path_str in expected_files:
    p = Path(path_str)
    rows.append({
        "path": path_str,
        "exists": str(p.exists()),
        "size_bytes": p.stat().st_size if p.exists() else "",
        "status": "present" if p.exists() else "missing",
    })

out = Path("results/audits/cmi_submission_figures_tables_audit.tsv")
out.parent.mkdir(parents=True, exist_ok=True)

with out.open("w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=["path", "exists", "size_bytes", "status"],
        delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(rows)

missing = [r for r in rows if r["status"] == "missing"]
present = [r for r in rows if r["status"] == "present"]

summary = Path("results/audits/cmi_submission_figures_tables_audit_summary.md")
summary.write_text(
    "# CMI Submission Figures and Tables Audit Summary\n\n"
    f"Expected figure/table files: {len(expected_files)}\n\n"
    f"Present files: {len(present)}\n\n"
    f"Missing files: {len(missing)}\n\n"
    f"Detailed audit: `{out}`\n"
)

print(summary.read_text())

if missing:
    raise SystemExit("Missing submission figure/table files.")
