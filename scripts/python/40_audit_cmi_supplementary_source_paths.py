#!/usr/bin/env python3

from pathlib import Path
import csv

items = [
    {
        "supplementary_item": "Supplementary Table S1",
        "description": "External projection candidate search register to generate from search plan and candidate audit outputs",
        "path": "docs/formal_external_projection_candidate_search_register.md",
        "required_status": "to_generate"
    },
    {
        "supplementary_item": "Supplementary Table S1",
        "description": "External projection candidate search plan",
        "path": "docs/formal_external_projection_candidate_search_plan.md",
        "required_status": "locate_or_confirm"
    },
    {
        "supplementary_item": "Supplementary Table S1",
        "description": "GSE261482 external projection boundary",
        "path": "docs/GSE261482_external_projection_candidate_feasibility_audit_report.md",
        "required_status": "optional_if_exists"
    },
    {
        "supplementary_item": "Supplementary Table S1",
        "description": "GSE68310 external projection boundary",
        "path": "docs/GSE68310_external_projection_candidate_feasibility_audit_report.md",
        "required_status": "optional_if_exists"
    },
    {
        "supplementary_item": "Supplementary Table S2",
        "description": "GSE211567 final discovery module label table",
        "path": "docs/GSE211567_final_discovery_module_label_table_report.md",
        "required_status": "locate_or_confirm"
    },
    {
        "supplementary_item": "Supplementary Table S3",
        "description": "GSE73461 locked module identifier coverage",
        "path": "results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S3",
        "description": "GSE73461 locked module matched genes",
        "path": "results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_matched_genes.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S3",
        "description": "GSE73461 locked module missing genes",
        "path": "results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_missing_genes.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S3",
        "description": "GSE73461 projection gene-probe choice",
        "path": "results/module_projection/GSE73461_fixed_module_projection/GSE73461_gene_probe_choice_for_projection.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S4",
        "description": "GSE73461 module scores long table",
        "path": "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S4",
        "description": "GSE73461 module scores wide table",
        "path": "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_wide.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S5",
        "description": "GSE73461 primary projection tests",
        "path": "results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S5",
        "description": "GSE73461 primary-only sensitivity projection tests",
        "path": "results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Table S5",
        "description": "GSE73461 manuscript projection summary table",
        "path": "results/tables/GSE73461_manuscript_projection_summary_table.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Supplementary Figure S2",
        "description": "GSE73461 projection figure plan",
        "path": "docs/GSE73461_projection_results_table_and_figure_plan.md",
        "required_status": "optional_if_exists"
    },
    {
        "supplementary_item": "Supplementary Figure S2",
        "description": "GSE73461 manuscript projection figure caption",
        "path": "docs/GSE73461_manuscript_projection_figure_caption.md",
        "required_status": "optional_if_exists"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "Decision log",
        "path": "docs/decision_log.md",
        "required_status": "required"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "Methods Results alignment map",
        "path": "docs/methods_results_alignment_map.md",
        "required_status": "required"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "Manuscript package index",
        "path": "docs/manuscript_results_package_index.md",
        "required_status": "required"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "Package index path audit",
        "path": "results/audits/manuscript_results_package_index_path_audit.tsv",
        "required_status": "required"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "CMI manuscript QC summary",
        "path": "results/audits/complete_manuscript_v0.5_cmi_qc_summary.md",
        "required_status": "required"
    },
    {
        "supplementary_item": "Reproducibility package",
        "description": "CMI manuscript QC details",
        "path": "results/audits/complete_manuscript_v0.5_cmi_qc_details.tsv",
        "required_status": "required"
    },
]

out_path = Path("results/audits/cmi_supplementary_source_path_audit.tsv")
out_path.parent.mkdir(parents=True, exist_ok=True)

rows = []
for item in items:
    p = Path(item["path"])
    exists = p.exists()
    if exists:
        status = "present"
    elif item["required_status"] == "required":
        status = "missing_required"
    else:
        status = "missing_to_locate_or_optional"
    rows.append({
        **item,
        "exists": str(exists),
        "status": status
    })

with out_path.open("w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            "supplementary_item",
            "description",
            "path",
            "required_status",
            "exists",
            "status"
        ],
        delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(rows)

present = sum(1 for r in rows if r["status"] == "present")
missing_required = sum(1 for r in rows if r["status"] == "missing_required")
missing_optional = sum(1 for r in rows if r["status"] == "missing_to_locate_or_optional")

summary = Path("results/audits/cmi_supplementary_source_path_audit_summary.md")
summary.write_text(
    "# CMI Supplementary Source Path Audit Summary\n\n"
    f"Total checked paths: {len(rows)}\n\n"
    f"Present: {present}\n\n"
    f"Missing required: {missing_required}\n\n"
    f"Missing to locate or optional: {missing_optional}\n\n"
    f"Detailed audit: `{out_path}`\n"
)

print(summary.read_text())

if missing_required:
    print("WARNING: Missing required supplementary source paths detected.")
else:
    print("All required supplementary source paths are present.")
