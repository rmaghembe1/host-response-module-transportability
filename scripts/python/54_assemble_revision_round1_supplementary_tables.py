#!/usr/bin/env python3
"""
Assemble Revision Round 1 supplementary Tables S6-S10.

The script:
- reads the locked 19-source supplementary design;
- verifies each source against its locked SHA256 and expected row count;
- copies sources byte-for-byte into manuscript-facing S6A-S10E filenames;
- creates manuscript-facing Markdown index documents for Tables S6-S10;
- creates a final manifest and quality gate;
- does not modify the scientific source tables;
- does not modify Supplementary Tables S1-S5;
- does not modify the manuscript.
"""

from __future__ import annotations

import csv
import hashlib
import shutil
from pathlib import Path
from typing import Dict, List


ROOT = Path(__file__).resolve().parents[2]

LOCK_FILE = (
    ROOT
    / "results/revision_round1/"
    "supplementary_table_package_design/"
    "supplementary_table_source_lock.tsv"
)

LOCK_QUALITY_FILE = (
    ROOT
    / "results/revision_round1/"
    "supplementary_table_package_design/"
    "supplementary_table_source_lock_quality_gate.tsv"
)

RESULT_DIR = ROOT / "results/supplementary_tables"

DOC_DIR = ROOT / "docs/supplementary_materials"

OUT_DIR = (
    ROOT
    / "results/revision_round1/"
    "supplementary_table_package_assembly"
)

MANIFEST_FILE = (
    OUT_DIR
    / "Supplementary_Tables_S6_S10_assembly_manifest.tsv"
)

QUALITY_FILE = (
    OUT_DIR
    / "Supplementary_Tables_S6_S10_assembly_quality_gate.tsv"
)

SUMMARY_FILE = (
    OUT_DIR
    / "Supplementary_Tables_S6_S10_assembly_quality_summary.tsv"
)

REPORT_FILE = (
    ROOT
    / "docs/revision_round1/"
    "Supplementary_Tables_S6_S10_assembly_report.md"
)

MASTER_INDEX_FILE = (
    DOC_DIR
    / "Supplementary_Materials_revision_round1_index.md"
)


DESTINATIONS = {
    "S6A": (
        "Supplementary_Table_S6A_GSE72810_candidate_validation_decision.tsv"
    ),
    "S6B": (
        "Supplementary_Table_S6B_GSE72810_sample_group_summary.tsv"
    ),
    "S6C": (
        "Supplementary_Table_S6C_GSE72810_analysis_group_summaries.tsv"
    ),
    "S6D": (
        "Supplementary_Table_S6D_GSE72810_GSE73461_independence_assessment.tsv"
    ),
    "S7A": (
        "Supplementary_Table_S7A_GSE72810_entrez_reconciliation_decision.tsv"
    ),
    "S7B": (
        "Supplementary_Table_S7B_GSE72810_module_coverage_entrez_reconciled.tsv"
    ),
    "S7C": (
        "Supplementary_Table_S7C_GSE72810_locked_module_gene_mapping.tsv"
    ),
    "S7D": (
        "Supplementary_Table_S7D_GSE72810_frozen_representative_probes.tsv"
    ),
    "S8A": (
        "Supplementary_Table_S8A_GSE72810_module_scores_long.tsv"
    ),
    "S8B": (
        "Supplementary_Table_S8B_GSE72810_primary_and_sensitivity_tests.tsv"
    ),
    "S8C": (
        "Supplementary_Table_S8C_GSE72810_effect_sizes_confidence_intervals.tsv"
    ),
    "S8D": (
        "Supplementary_Table_S8D_GSE72810_score_concordance.tsv"
    ),
    "S9A": (
        "Supplementary_Table_S9A_GSE73461_GSE72810_primary_effect_size_source.tsv"
    ),
    "S9B": (
        "Supplementary_Table_S9B_GSE73461_GSE72810_cross_cohort_summary.tsv"
    ),
    "S10A": (
        "Supplementary_Table_S10A_GSE73461_GSVA_primary_projection_effects.tsv"
    ),
    "S10B": (
        "Supplementary_Table_S10B_GSE73461_GSVA_mean_z_correlations.tsv"
    ),
    "S10C": (
        "Supplementary_Table_S10C_GSE73461_gene_deletion_summary.tsv"
    ),
    "S10D": (
        "Supplementary_Table_S10D_GSE73461_gene_deletion_worst_case_variants.tsv"
    ),
    "S10E": (
        "Supplementary_Table_S10E_GSE73461_gene_deletion_all_variants.tsv"
    ),
}


TABLE_INDEX_DOCS = {
    "S6": {
        "filename": (
            "Supplementary_Table_S6_GSE72810_cohort_and_analysis_design.md"
        ),
        "title": (
            "Supplementary Table S6. "
            "GSE72810 cohort and analysis design"
        ),
        "description": (
            "GSE72810 cohort suitability, deposited sample-group "
            "classification, locked primary and sensitivity analysis "
            "groups, and the GSE72810-GSE73461 accession/platform/"
            "participant/investigator-network assessment."
        ),
        "parts": ["S6A", "S6B", "S6C", "S6D"],
    },
    "S7": {
        "filename": (
            "Supplementary_Table_S7_GSE72810_mapping_coverage_"
            "and_probe_design.md"
        ),
        "title": (
            "Supplementary Table S7. "
            "GSE72810 mapping, coverage and frozen probe design"
        ),
        "description": (
            "Entrez reconciliation, module-level locked-gene coverage, "
            "complete module-gene mapping, and frozen representative "
            "probe choices used for GSE72810 scoring."
        ),
        "parts": ["S7A", "S7B", "S7C", "S7D"],
    },
    "S8": {
        "filename": (
            "Supplementary_Table_S8_GSE72810_scores_effects_"
            "and_sensitivity.md"
        ),
        "title": (
            "Supplementary Table S8. "
            "GSE72810 scores, effects and sensitivity analyses"
        ),
        "description": (
            "Sample-level fixed-module scores, primary and sensitivity "
            "Wilcoxon tests, Hodges-Lehmann and rank-biserial effects "
            "with bootstrap confidence intervals, and score-concordance "
            "analyses."
        ),
        "parts": ["S8A", "S8B", "S8C", "S8D"],
    },
    "S9": {
        "filename": (
            "Supplementary_Table_S9_GSE73461_GSE72810_"
            "cross_cohort_validation.md"
        ),
        "title": (
            "Supplementary Table S9. "
            "GSE73461-GSE72810 cross-cohort validation"
        ),
        "description": (
            "Harmonised primary effect-size source data and the "
            "five-module manuscript-facing cross-cohort summary."
        ),
        "parts": ["S9A", "S9B"],
    },
    "S10": {
        "filename": (
            "Supplementary_Table_S10_GSE73461_scoring_method_"
            "and_gene_deletion_robustness.md"
        ),
        "title": (
            "Supplementary Table S10. "
            "GSE73461 scoring-method and gene-deletion robustness"
        ),
        "description": (
            "Mean-z versus GSVA effects and score concordance, "
            "module-level leave-one/two-gene summaries, worst-case "
            "variants, and the complete exhaustive deletion results."
        ),
        "parts": ["S10A", "S10B", "S10C", "S10D", "S10E"],
    },
}


def require_nonempty(path: Path) -> None:
    if not path.is_file() or path.stat().st_size == 0:
        raise RuntimeError(
            f"Missing or empty required file: {path}"
        )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for block in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(block)

    return digest.hexdigest()


def count_rows(path: Path) -> int:
    require_nonempty(path)

    with path.open(
        "r",
        encoding="utf-8",
        errors="strict",
    ) as handle:
        count = sum(1 for _ in handle)

    return max(count - 1, 0)


def count_columns(path: Path) -> int:
    require_nonempty(path)

    with path.open(
        "r",
        encoding="utf-8",
        errors="strict",
    ) as handle:
        header = handle.readline().rstrip("\n\r")

    return len(header.split("\t"))


def read_tsv(path: Path) -> List[Dict[str, str]]:
    require_nonempty(path)

    with path.open(
        "r",
        encoding="utf-8",
        newline="",
    ) as handle:
        return list(
            csv.DictReader(
                handle,
                delimiter="\t",
            )
        )


def write_tsv(
    path: Path,
    rows: List[Dict[str, object]],
    fields: List[str],
) -> None:
    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with path.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fields,
            delimiter="\t",
            lineterminator="\n",
        )

        writer.writeheader()

        for row in rows:
            writer.writerow(row)


def bool_text(value: bool) -> str:
    return "TRUE" if value else "FALSE"


require_nonempty(LOCK_FILE)
require_nonempty(LOCK_QUALITY_FILE)

RESULT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

DOC_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT_FILE.parent.mkdir(
    parents=True,
    exist_ok=True,
)

lock_rows = read_tsv(LOCK_FILE)
quality_rows = read_tsv(LOCK_QUALITY_FILE)

if len(lock_rows) != 19:
    raise RuntimeError(
        f"Expected 19 source-lock rows; found {len(lock_rows)}."
    )

if len(quality_rows) != 19:
    raise RuntimeError(
        f"Expected 19 source-lock quality rows; found "
        f"{len(quality_rows)}."
    )

quality_by_item = {
    row["supplementary_item"]: row
    for row in quality_rows
}

if set(quality_by_item) != set(DESTINATIONS):
    raise RuntimeError(
        "Source-lock quality items do not match the expected "
        "S6A-S10E assembly set."
    )

for item, row in quality_by_item.items():
    if row["pass"].strip().upper() != "TRUE":
        raise RuntimeError(
            f"Source-lock gate did not pass for {item}."
        )

manifest_rows: List[Dict[str, object]] = []

for row in lock_rows:
    item = row["supplementary_item"].strip()

    if item not in DESTINATIONS:
        raise RuntimeError(
            f"Unexpected supplementary item: {item}"
        )

    source = ROOT / row["source_file"]
    destination = RESULT_DIR / DESTINATIONS[item]

    require_nonempty(source)

    expected_rows = int(row["expected_rows"])
    source_rows = count_rows(source)
    source_columns = count_columns(source)
    source_sha = sha256_file(source)

    locked_quality = quality_by_item[item]

    locked_sha = locked_quality["sha256"].strip()
    locked_rows = int(
        locked_quality["expected_rows"]
    )

    if source_rows != expected_rows:
        raise RuntimeError(
            f"{item}: source row count changed from lock: "
            f"{source_rows} versus {expected_rows}."
        )

    if expected_rows != locked_rows:
        raise RuntimeError(
            f"{item}: lock row-count disagreement."
        )

    if source_sha != locked_sha:
        raise RuntimeError(
            f"{item}: source SHA256 changed after source lock."
        )

    shutil.copyfile(
        source,
        destination,
    )

    require_nonempty(destination)

    destination_rows = count_rows(destination)
    destination_columns = count_columns(destination)
    destination_sha = sha256_file(destination)

    if destination_sha != source_sha:
        raise RuntimeError(
            f"{item}: copied file is not byte-identical "
            "to its source."
        )

    if destination_rows != source_rows:
        raise RuntimeError(
            f"{item}: copied row count differs from source."
        )

    if destination_columns != source_columns:
        raise RuntimeError(
            f"{item}: copied column count differs from source."
        )

    manifest_rows.append(
        {
            "supplementary_item": item,
            "source_file": str(
                source.relative_to(ROOT)
            ),
            "destination_file": str(
                destination.relative_to(ROOT)
            ),
            "role": row["role"],
            "rows": source_rows,
            "columns": source_columns,
            "source_sha256": source_sha,
            "destination_sha256": destination_sha,
            "byte_identical": "TRUE",
        }
    )

manifest_rows.sort(
    key=lambda x: (
        int(
            x["supplementary_item"]
            .replace("S", "")
            .rstrip("ABCDE")
        ),
        x["supplementary_item"],
    )
)

write_tsv(
    MANIFEST_FILE,
    manifest_rows,
    [
        "supplementary_item",
        "source_file",
        "destination_file",
        "role",
        "rows",
        "columns",
        "source_sha256",
        "destination_sha256",
        "byte_identical",
    ],
)

manifest_by_item = {
    str(row["supplementary_item"]): row
    for row in manifest_rows
}

generated_docs: List[Path] = []

for table_id, spec in TABLE_INDEX_DOCS.items():
    doc_path = DOC_DIR / spec["filename"]

    lines = [
        f"# {spec['title']}",
        "",
        spec["description"],
        "",
        "## Files",
        "",
        "| Part | File | Rows | Columns | Content |",
        "|---|---|---:|---:|---|",
    ]

    for item in spec["parts"]:
        entry = manifest_by_item[item]

        lines.append(
            "| "
            + " | ".join(
                [
                    item,
                    f"`{Path(str(entry['destination_file'])).name}`",
                    str(entry["rows"]),
                    str(entry["columns"]),
                    str(entry["role"]),
                ]
            )
            + " |"
        )

    lines.extend(
        [
            "",
            "## Assembly note",
            "",
            "Each tabular file is a byte-identical copy of the "
            "corresponding locked revision-round scientific source. "
            "No scientific values, rows or columns were altered during "
            "supplementary-table assembly.",
            "",
        ]
    )

    doc_path.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )

    generated_docs.append(doc_path)


master_lines = [
    "# Supplementary Materials - Revision Round 1",
    "",
    "## Existing supplementary tables",
    "",
    "Supplementary Tables S1-S5 retain the original "
    "submission-era supplementary materials.",
    "",
    "## Revision-round supplementary tables",
    "",
    "- Table S6: GSE72810 cohort and analysis design.",
    "- Table S7: GSE72810 mapping, coverage and frozen probe design.",
    "- Table S8: GSE72810 scores, effects and sensitivity analyses.",
    "- Table S9: GSE73461-GSE72810 cross-cohort validation.",
    "- Table S10: GSE73461 scoring-method and gene-deletion robustness.",
    "- Figure S1: fixed-module sensitivity and robustness.",
    "",
    "## Multipart table files",
    "",
]

for row in manifest_rows:
    master_lines.append(
        f"- {row['supplementary_item']}: "
        f"`{Path(str(row['destination_file'])).name}` "
        f"({row['rows']} rows x {row['columns']} columns)."
    )

master_lines.extend(
    [
        "",
        "## Large-table note",
        "",
        "Supplementary Table S10E contains the complete "
        "29,826-row exhaustive leave-one/two-gene result set. "
        "Table S10C provides the compact module-level summary and "
        "Table S10D provides the worst-case variants.",
        "",
        "## Integrity",
        "",
        "All S6A-S10E files were assembled from the locked "
        "revision-round sources using SHA256-verified byte-for-byte "
        "copies.",
        "",
    ]
)

MASTER_INDEX_FILE.write_text(
    "\n".join(master_lines),
    encoding="utf-8",
)

generated_docs.append(
    MASTER_INDEX_FILE
)

checks: List[Dict[str, object]] = []


def add_check(
    description: str,
    passed: bool,
    observed: object,
    expected: object,
) -> None:
    checks.append(
        {
            "check_id": f"Q{len(checks) + 1:02d}",
            "check_description": description,
            "pass": bool_text(passed),
            "observed": observed,
            "expected": expected,
        }
    )


add_check(
    "Source lock contained 19 supplementary parts",
    len(lock_rows) == 19,
    len(lock_rows),
    19,
)

add_check(
    "Source-lock quality table contained 19 passing rows",
    all(
        row["pass"].strip().upper() == "TRUE"
        for row in quality_rows
    )
    and len(quality_rows) == 19,
    sum(
        row["pass"].strip().upper() == "TRUE"
        for row in quality_rows
    ),
    19,
)

add_check(
    "Assembly manifest contains 19 supplementary parts",
    len(manifest_rows) == 19,
    len(manifest_rows),
    19,
)

add_check(
    "All assembled tables are byte-identical to their sources",
    all(
        row["source_sha256"]
        == row["destination_sha256"]
        for row in manifest_rows
    ),
    sum(
        row["source_sha256"]
        == row["destination_sha256"]
        for row in manifest_rows
    ),
    19,
)

add_check(
    "All assembled tables contain at least one column",
    all(
        int(row["columns"]) >= 1
        for row in manifest_rows
    ),
    min(
        int(row["columns"])
        for row in manifest_rows
    ),
    ">=1",
)

add_check(
    "S7C contains 313 module-gene rows",
    int(manifest_by_item["S7C"]["rows"]) == 313,
    manifest_by_item["S7C"]["rows"],
    313,
)

add_check(
    "S8A contains 1715 sample-score rows",
    int(manifest_by_item["S8A"]["rows"]) == 1715,
    manifest_by_item["S8A"]["rows"],
    1715,
)

add_check(
    "S10E contains 29826 deletion-variant rows",
    int(manifest_by_item["S10E"]["rows"]) == 29826,
    manifest_by_item["S10E"]["rows"],
    29826,
)

add_check(
    "Five S6-S10 table index documents were created",
    len(
        [
            path
            for path in generated_docs
            if path != MASTER_INDEX_FILE
        ]
    )
    == 5
    and all(
        path.is_file()
        and path.stat().st_size > 0
        for path in generated_docs
        if path != MASTER_INDEX_FILE
    ),
    5,
    5,
)

add_check(
    "Revision-round supplementary master index was created",
    MASTER_INDEX_FILE.is_file()
    and MASTER_INDEX_FILE.stat().st_size > 0,
    MASTER_INDEX_FILE.stat().st_size,
    "non-empty",
)

existing_s1_s5 = [
    ROOT
    / "results/supplementary_tables/"
    "Supplementary_Table_S1_external_projection_candidate_register.tsv",
    ROOT
    / "results/supplementary_tables/"
    "Supplementary_Table_S2_GSE211567_locked_discovery_module_genes.tsv",
    ROOT
    / "results/supplementary_tables/"
    "Supplementary_Table_S3A_GSE73461_module_identifier_coverage.tsv",
    ROOT
    / "results/supplementary_tables/"
    "Supplementary_Table_S4A_GSE73461_fixed_module_scores_long.tsv",
    ROOT
    / "results/supplementary_tables/"
    "Supplementary_Table_S5A_GSE73461_primary_projection_tests.tsv",
]

add_check(
    "Existing S1-S5 representative files remain present",
    all(
        path.is_file()
        and path.stat().st_size > 0
        for path in existing_s1_s5
    ),
    sum(
        path.is_file()
        and path.stat().st_size > 0
        for path in existing_s1_s5
    ),
    5,
)

quality_pass = all(
    row["pass"] == "TRUE"
    for row in checks
)

write_tsv(
    QUALITY_FILE,
    checks,
    [
        "check_id",
        "check_description",
        "pass",
        "observed",
        "expected",
    ],
)

summary = [
    {
        "assembled_table_parts": len(manifest_rows),
        "byte_identical_parts": sum(
            row["source_sha256"]
            == row["destination_sha256"]
            for row in manifest_rows
        ),
        "table_index_documents": 5,
        "master_index_documents": 1,
        "quality_checks": len(checks),
        "quality_checks_passed": sum(
            row["pass"] == "TRUE"
            for row in checks
        ),
        "quality_checks_failed": sum(
            row["pass"] != "TRUE"
            for row in checks
        ),
        "quality_gate": (
            "PASS"
            if quality_pass
            else "REVIEW"
        ),
        "final_status": (
            "READY_FOR_SUPPLEMENTARY_PACKAGE_REVIEW"
            if quality_pass
            else "SUPPLEMENTARY_ASSEMBLY_REVIEW_REQUIRED"
        ),
    }
]

write_tsv(
    SUMMARY_FILE,
    summary,
    list(summary[0].keys()),
)

report_lines = [
    "# Supplementary Tables S6-S10 assembly report",
    "",
    "## Assembly result",
    "",
    f"- Supplementary table parts assembled: {len(manifest_rows)}.",
    "- Assembly method: byte-identical copy from locked sources.",
    "- Existing Supplementary Tables S1-S5 were not modified.",
    "",
    "## Table structure",
    "",
    "- Table S6: four parts (S6A-S6D).",
    "- Table S7: four parts (S7A-S7D).",
    "- Table S8: four parts (S8A-S8D).",
    "- Table S9: two parts (S9A-S9B).",
    "- Table S10: five parts (S10A-S10E).",
    "",
    "## Large scientific tables",
    "",
    "- S7C: 313 module-gene reconciliation rows.",
    "- S8A: 1,715 sample-module score rows.",
    "- S10E: 29,826 exhaustive deletion-variant rows.",
    "",
    "## Integrity",
    "",
    f"- Byte-identical copies: "
    f"{sum(row['source_sha256'] == row['destination_sha256'] for row in manifest_rows)}/19.",
    f"- Quality checks passed: "
    f"{sum(row['pass'] == 'TRUE' for row in checks)}/{len(checks)}.",
    "",
    "## Status",
    "",
    (
        "`READY_FOR_SUPPLEMENTARY_PACKAGE_REVIEW`"
        if quality_pass
        else "`SUPPLEMENTARY_ASSEMBLY_REVIEW_REQUIRED`"
    ),
    "",
]

REPORT_FILE.write_text(
    "\n".join(report_lines),
    encoding="utf-8",
)

print("===== SUPPLEMENTARY TABLE S6-S10 ASSEMBLY =====")
print(f"assembled_table_parts\t{len(manifest_rows)}")
print(
    "byte_identical_parts\t"
    + str(
        sum(
            row["source_sha256"]
            == row["destination_sha256"]
            for row in manifest_rows
        )
    )
)
print("table_index_documents\t5")
print("master_index_documents\t1")
print(
    "quality_checks_passed\t"
    f"{sum(row['pass'] == 'TRUE' for row in checks)}/{len(checks)}"
)
print(
    "quality_gate\t"
    + (
        "PASS"
        if quality_pass
        else "REVIEW"
    )
)
print(
    "final_status\t"
    + (
        "READY_FOR_SUPPLEMENTARY_PACKAGE_REVIEW"
        if quality_pass
        else "SUPPLEMENTARY_ASSEMBLY_REVIEW_REQUIRED"
    )
)
print(
    "manifest\t"
    + str(
        MANIFEST_FILE.relative_to(ROOT)
    )
)
print(
    "master_index\t"
    + str(
        MASTER_INDEX_FILE.relative_to(ROOT)
    )
)

if not quality_pass:
    raise RuntimeError(
        "Supplementary-table assembly failed quality checks."
    )
