#!/usr/bin/env python3

from pathlib import Path
import re
import csv

manuscript = Path("docs/complete_manuscript_draft_v1.6_step7b_single_author.md")
text = manuscript.read_text()

expected_figure_files = [
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
]

callouts = {
    "Figure 1": len(re.findall(r"\bFigure 1\b", text)),
    "Figure 2": len(re.findall(r"\bFigure 2\b", text)),
    "Figure 1A": len(re.findall(r"\bFigure 1A\b", text)),
    "Figure 1B": len(re.findall(r"\bFigure 1B\b", text)),
    "Figure 1C": len(re.findall(r"\bFigure 1C\b", text)),
    "Figure 2A": len(re.findall(r"\bFigure 2A\b", text)),
    "Figure 2B": len(re.findall(r"\bFigure 2B\b", text)),
    "Figure 2C": len(re.findall(r"\bFigure 2C\b", text)),
}

legend_checks = {
    "Figure 1 legend heading": "## Figure 1." in text,
    "Figure 2 legend heading": "## Figure 2." in text,
    "Figure 1 panel A": "(A)" in text and "GSE211567" in text,
    "Figure 1 panel B": "(B)" in text and "Site-aware concordance" in text,
    "Figure 1 panel C": "(C)" in text and "Locked GSE211567 discovery modules" in text,
    "Figure 2 panel A": "(A)" in text and "Distribution of locked module scores" in text,
    "Figure 2 panel B": "(B)" in text and "Median bacterial-minus-viral" in text,
    "Figure 2 panel C": "(C)" in text and "BH-adjusted Wilcoxon" in text,
}

rows = []

for p in expected_figure_files:
    path = Path(p)
    rows.append({
        "category": "figure_file",
        "item": path.name,
        "path": p,
        "status": "present" if path.exists() else "missing",
        "value": path.stat().st_size if path.exists() else "",
    })

for item, count in callouts.items():
    rows.append({
        "category": "manuscript_callout",
        "item": item,
        "path": manuscript.as_posix(),
        "status": "present" if count > 0 else "absent",
        "value": count,
    })

for item, ok in legend_checks.items():
    rows.append({
        "category": "legend_check",
        "item": item,
        "path": manuscript.as_posix(),
        "status": "PASS" if ok else "CHECK",
        "value": str(ok),
    })

out = Path("results/audits/cmi_v16_figures_legends_audit.tsv")
out.parent.mkdir(parents=True, exist_ok=True)

with out.open("w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=["category", "item", "path", "status", "value"],
        delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(rows)

missing_files = [r for r in rows if r["category"] == "figure_file" and r["status"] == "missing"]
legend_flags = [r for r in rows if r["category"] == "legend_check" and r["status"] != "PASS"]

summary = Path("results/audits/cmi_v16_figures_legends_audit_summary.md")
summary.write_text(
    "# CMI v1.6 Figures and Legends Audit Summary\n\n"
    f"Manuscript: `{manuscript}`\n\n"
    f"Expected figure files: {len(expected_figure_files)}\n\n"
    f"Missing figure files: {len(missing_files)}\n\n"
    f"Legend checks requiring attention: {len(legend_flags)}\n\n"
    "## Figure callout counts\n\n"
    + "\n".join(f"- {k}: {v}" for k, v in callouts.items())
    + "\n\n"
    f"Detailed audit: `{out}`\n\n"
    f"Status: {'PASS' if not missing_files and not legend_flags else 'CHECK'}\n"
)

print(summary.read_text())

if missing_files or legend_flags:
    raise SystemExit("Figure/legend audit requires attention.")
