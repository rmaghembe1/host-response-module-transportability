#!/usr/bin/env python3

from __future__ import annotations

import csv
import difflib
import hashlib
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

SOURCE = (
    ROOT
    / "docs/complete_manuscript_draft_v1.7_revision_round1_integrated.md"
)

TARGET = (
    ROOT
    / "docs/complete_manuscript_draft_v1.8_revision_round1_reconciled.md"
)

ASSEMBLY_SUMMARY = (
    ROOT
    / "results/revision_round1/"
    "supplementary_table_package_assembly/"
    "Supplementary_Tables_S6_S10_assembly_quality_summary.tsv"
)

ASSEMBLY_MANIFEST = (
    ROOT
    / "results/revision_round1/"
    "supplementary_table_package_assembly/"
    "Supplementary_Tables_S6_S10_assembly_manifest.tsv"
)

OUT_DIR = (
    ROOT
    / "results/revision_round1/"
    "manuscript_v1.8_reference_and_supplement_reconciliation"
)

QUALITY_FILE = (
    OUT_DIR
    / "manuscript_v1.8_reconciliation_quality_gate.tsv"
)

SUMMARY_FILE = (
    OUT_DIR
    / "manuscript_v1.8_reconciliation_quality_summary.tsv"
)

DIFF_FILE = (
    OUT_DIR
    / "manuscript_v1.7_to_v1.8_unified_diff.txt"
)

REPORT_FILE = (
    ROOT
    / "docs/revision_round1/"
    "complete_manuscript_v1.8_reconciliation_report.md"
)

EXPECTED_SOURCE_SHA256 = (
    "4d3d07a5e4f9f5a8ea28d4b9eca117275c63b124a1c2c3cab504dd36e6b40e7b"
)

REFERENCE_MAP = {
    14: 15,
    15: 16,
    16: 17,
    17: 18,
    18: 19,
    19: 20,
    20: 21,
    21: None,
    22: 14,
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def require_file(path: Path) -> None:
    if not path.is_file() or path.stat().st_size == 0:
        raise RuntimeError(
            f"Missing or empty required file: {path}"
        )


def read_tsv(path: Path):
    require_file(path)

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


def write_tsv(path: Path, rows, fields) -> None:
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


def citation_groups(text: str):
    return list(
        re.finditer(
            r"\[(\d+(?:\s*,\s*\d+)*)\]",
            text,
        )
    )


def citation_numbers(text: str):
    numbers = []

    for match in citation_groups(text):
        values = [
            int(value.strip())
            for value in match.group(1).split(",")
        ]

        numbers.extend(values)

    return numbers


def remap_body_citations(text: str) -> str:
    def replacement(match):
        old_numbers = [
            int(value.strip())
            for value in match.group(1).split(",")
        ]

        new_numbers = []

        for number in old_numbers:
            mapped = REFERENCE_MAP.get(
                number,
                number,
            )

            if mapped is None:
                raise RuntimeError(
                    "Reference [21] is cited in the manuscript body, "
                    "so STARD cannot be removed automatically."
                )

            new_numbers.append(mapped)

        return "[" + ",".join(
            str(number)
            for number in new_numbers
        ) + "]"

    return re.sub(
        r"\[(\d+(?:\s*,\s*\d+)*)\]",
        replacement,
        text,
    )


def replace_once(
    text: str,
    old: str,
    new: str,
    label: str,
) -> str:
    count = text.count(old)

    if count != 1:
        raise RuntimeError(
            f"Expected exactly one {label}; found {count}."
        )

    return text.replace(
        old,
        new,
        1,
    )


def add_check(
    checks,
    description,
    passed,
    observed,
    expected,
):
    checks.append(
        {
            "check_id": f"Q{len(checks) + 1:02d}",
            "check_description": description,
            "pass": "TRUE" if passed else "FALSE",
            "observed": observed,
            "expected": expected,
        }
    )


for required in [
    SOURCE,
    ASSEMBLY_SUMMARY,
    ASSEMBLY_MANIFEST,
]:
    require_file(required)

source_sha_before = sha256_file(SOURCE)

if source_sha_before != EXPECTED_SOURCE_SHA256:
    raise RuntimeError(
        "The v1.7 source checksum differs from the reviewed manuscript."
    )

if TARGET.exists():
    raise RuntimeError(
        f"Target already exists and will not be overwritten: {TARGET}"
    )

assembly_summary = read_tsv(
    ASSEMBLY_SUMMARY
)

assembly_manifest = read_tsv(
    ASSEMBLY_MANIFEST
)

if len(assembly_summary) != 1:
    raise RuntimeError(
        "Expected one supplementary assembly summary row."
    )

assembly = assembly_summary[0]

if assembly.get("quality_gate") != "PASS":
    raise RuntimeError(
        "Supplementary package quality gate is not PASS."
    )

if assembly.get("final_status") != (
    "READY_FOR_SUPPLEMENTARY_PACKAGE_REVIEW"
):
    raise RuntimeError(
        "Supplementary package is not at the reviewed assembly state."
    )

if len(assembly_manifest) != 19:
    raise RuntimeError(
        f"Expected 19 supplementary parts; "
        f"found {len(assembly_manifest)}."
    )

if not all(
    row.get("byte_identical") == "TRUE"
    for row in assembly_manifest
):
    raise RuntimeError(
        "Not all supplementary parts are byte-identical."
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

if "# References\n" not in source_text:
    raise RuntimeError(
        "References heading was not found."
    )

body, references_text = source_text.split(
    "# References\n",
    1,
)

old_body_citations = citation_numbers(
    body
)

if 21 in old_body_citations:
    raise RuntimeError(
        "Current reference [21] is cited in the manuscript body. "
        "Manual review is required before removing STARD."
    )

reference_blocks = re.findall(
    r"(?ms)^\[(\d+)\]\s+(.*?)(?=^\[\d+\]\s+|\Z)",
    references_text,
)

if len(reference_blocks) != 22:
    raise RuntimeError(
        f"Expected 22 reference entries; "
        f"found {len(reference_blocks)}."
    )

old_reference_numbers = [
    int(number)
    for number, _ in reference_blocks
]

if old_reference_numbers != list(
    range(1, 23)
):
    raise RuntimeError(
        "The v1.7 references are not numbered continuously 1-22."
    )

new_body = remap_body_citations(
    body
)

new_body = replace_once(
    new_body,
    "deposited-sample-level cohort",
    "sample-level cohort",
    "Figure 3 deposited-sample-level wording",
)

old_cross_cohort = (
    "All ten cohort-module effects retained the expected direction "
    "(Figure 3; Table 2)."
)

new_cross_cohort = (
    "For harmonised cross-cohort comparison, Figure 3 and Table 2 "
    "report Hodges-Lehmann bacterial-minus-viral shifts with bootstrap "
    "95% confidence intervals; these estimates are distinct from the "
    "median score differences reported for the original GSE73461 "
    "projection in Figure 2 and Table 1. "
    "All ten cohort-module effects retained the expected direction "
    "(Figure 3; Table 2)."
)

new_body = replace_once(
    new_body,
    old_cross_cohort,
    new_cross_cohort,
    "cross-cohort effect-estimate clarification",
)

old_supplementary = (
    "Supplementary Table S6 provides the GSE72810 cohort audit, "
    "sample-classification framework and locked primary and expanded "
    "contrasts. Supplementary Table S7 provides GSE72810 Entrez "
    "reconciliation, module coverage, missing genes and frozen "
    "representative-probe choices. Supplementary Table S8 provides "
    "GSE72810 sample-level scores, primary effects, bootstrap confidence "
    "intervals and case-definition, z-reference and probe-collapse "
    "sensitivity results. Supplementary Table S9 provides the harmonised "
    "GSE73461-GSE72810 cross-cohort effect-size source data and summary. "
    "Supplementary Table S10 provides the GSE73461 mean-z/GSVA comparison "
    "and exhaustive leave-one/two-gene robustness results."
)

new_supplementary = (
    "Supplementary Table S6 (parts S6A-S6D) provides the GSE72810 "
    "cohort audit, sample-classification framework, locked primary and "
    "expanded contrasts, and cross-cohort independence assessment. "
    "Supplementary Table S7 (parts S7A-S7D) provides GSE72810 Entrez "
    "reconciliation, module coverage, complete module-gene mapping and "
    "frozen representative-probe choices. Supplementary Table S8 "
    "(parts S8A-S8D) provides GSE72810 sample-level scores, primary and "
    "sensitivity tests, bootstrap effect-size confidence intervals and "
    "score-concordance analyses. Supplementary Table S9 "
    "(parts S9A-S9B) provides the harmonised GSE73461-GSE72810 "
    "cross-cohort effect-size source data and five-module summary. "
    "Supplementary Table S10 (parts S10A-S10E) provides the GSE73461 "
    "mean-z/GSVA comparison, score concordance, module-level deletion "
    "summary, worst-case deletion variants and complete exhaustive "
    "leave-one/two-gene results."
)

new_body = replace_once(
    new_body,
    old_supplementary,
    new_supplementary,
    "multipart supplementary-table paragraph",
)

new_body = re.sub(
    r"^# Complete Manuscript Draft v1\.7.*$",
    "# Complete Manuscript Draft v1.8 - Revision Round 1 Reconciled",
    new_body,
    count=1,
    flags=re.MULTILINE,
)

new_references = []

for old_number_text, content in reference_blocks:
    old_number = int(
        old_number_text
    )

    mapped = REFERENCE_MAP.get(
        old_number,
        old_number,
    )

    if mapped is None:
        continue

    new_references.append(
        (
            mapped,
            content.strip(),
        )
    )

new_references.sort(
    key=lambda item: item[0]
)

new_numbers = [
    number
    for number, _ in new_references
]

if new_numbers != list(
    range(1, 22)
):
    raise RuntimeError(
        "Reconciled references are not continuous 1-21."
    )

new_reference_text = "\n\n".join(
    f"[{number}] {content}"
    for number, content in new_references
)

target_text = (
    new_body.rstrip()
    + "\n\n# References\n\n"
    + new_reference_text.rstrip()
    + "\n"
)

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT_FILE.parent.mkdir(
    parents=True,
    exist_ok=True,
)

TARGET.write_text(
    target_text,
    encoding="utf-8",
)

target_sha = sha256_file(
    TARGET
)

source_sha_after = sha256_file(
    SOURCE
)

diff_lines = list(
    difflib.unified_diff(
        source_text.splitlines(),
        target_text.splitlines(),
        fromfile=str(
            SOURCE.relative_to(ROOT)
        ),
        tofile=str(
            TARGET.relative_to(ROOT)
        ),
        lineterm="",
    )
)

DIFF_FILE.write_text(
    "\n".join(diff_lines) + "\n",
    encoding="utf-8",
)

new_body_numbers = citation_numbers(
    new_body
)

first_seen = []

for number in new_body_numbers:
    if (
        12 <= number <= 21
        and number not in first_seen
    ):
        first_seen.append(
            number
        )

references_by_number = {
    number: content
    for number, content in new_references
}

checks = []

add_check(
    checks,
    "Reviewed v1.7 source checksum matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    checks,
    "v1.7 remained unchanged",
    source_sha_after == EXPECTED_SOURCE_SHA256,
    source_sha_after,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    checks,
    "Supplementary assembly contains 19 byte-identical parts",
    len(assembly_manifest) == 19
    and all(
        row["byte_identical"] == "TRUE"
        for row in assembly_manifest
    ),
    len(assembly_manifest),
    19,
)

add_check(
    checks,
    "Reconciled reference list is continuous 1-21",
    new_numbers == list(range(1, 22)),
    ",".join(
        str(number)
        for number in new_numbers
    ),
    "1-21",
)

add_check(
    checks,
    "GSE72810 is reference 14",
    "GSE72810" in references_by_number[14],
    references_by_number[14],
    "GSE72810",
)

add_check(
    checks,
    "limma is reference 15",
    "limma" in references_by_number[15],
    references_by_number[15],
    "limma",
)

add_check(
    checks,
    "Benjamini-Hochberg paper is reference 18",
    "Benjamini" in references_by_number[18]
    and "Hochberg" in references_by_number[18],
    references_by_number[18],
    "Benjamini and Hochberg",
)

add_check(
    checks,
    "Russell immunometabolism reference is 21",
    "Russell DG" in references_by_number[21],
    references_by_number[21],
    "Russell DG",
)

add_check(
    checks,
    "STARD reference was removed",
    "STARD 2015" not in target_text,
    "STARD 2015" in target_text,
    False,
)

add_check(
    checks,
    "Reference 22 no longer occurs",
    22 not in new_body_numbers
    and "[22]" not in new_reference_text,
    22 in new_body_numbers,
    False,
)

add_check(
    checks,
    "First appearance sequence for references 12-21 is ordered",
    first_seen == list(range(12, 22)),
    ",".join(
        str(number)
        for number in first_seen
    ),
    "12,13,14,15,16,17,18,19,20,21",
)

add_check(
    checks,
    "GSE72810 dataset citation group is reconciled",
    "[12,13,14]" in new_body,
    "[12,13,14]" in new_body,
    True,
)

add_check(
    checks,
    "Figure 3 sample-level wording was simplified",
    "deposited-sample-level" not in target_text,
    "deposited-sample-level" in target_text,
    False,
)

add_check(
    checks,
    "Median versus Hodges-Lehmann distinction is explicit",
    (
        "these estimates are distinct from the median score differences"
        in target_text
    ),
    (
        "these estimates are distinct from the median score differences"
        in target_text
    ),
    True,
)

for token in [
    "S6A-S6D",
    "S7A-S7D",
    "S8A-S8D",
    "S9A-S9B",
    "S10A-S10E",
]:
    add_check(
        checks,
        f"Multipart supplementary structure present: {token}",
        token in target_text,
        token in target_text,
        True,
    )

add_check(
    checks,
    "No trailing whitespace",
    all(
        line == line.rstrip()
        for line in target_text.splitlines()
    ),
    "none detected",
    "none",
)

add_check(
    checks,
    "Target manuscript differs from v1.7",
    target_sha != source_sha_before,
    target_sha,
    "different from v1.7",
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
        "quality_checks": len(checks),
        "quality_checks_passed": sum(
            row["pass"] == "TRUE"
            for row in checks
        ),
        "quality_checks_failed": sum(
            row["pass"] != "TRUE"
            for row in checks
        ),
        "source_sha256": source_sha_after,
        "target_sha256": target_sha,
        "reference_count": len(new_references),
        "gse72810_reference_number": 14,
        "removed_reference": "STARD 2015",
        "supplementary_parts": len(assembly_manifest),
        "quality_gate": (
            "PASS"
            if quality_pass
            else "REVIEW"
        ),
        "final_status": (
            "READY_FOR_FINAL_MANUSCRIPT_REVIEW_AND_STAGING"
            if quality_pass
            else "FINAL_RECONCILIATION_REVIEW_REQUIRED"
        ),
    }
]

write_tsv(
    SUMMARY_FILE,
    summary,
    list(summary[0].keys()),
)

report_lines = [
    "# Manuscript v1.8 reference and supplementary reconciliation",
    "",
    "## Reference reconciliation",
    "",
    "- GSE211567 remains reference [12].",
    "- GSE73461 remains reference [13].",
    "- GSE72810 moved from [22] to [14] because it first appears before the methods references.",
    "- Former references [14]-[20] shifted to [15]-[21].",
    "- The former STARD reference [21] was removed because it is uncited in the revised manuscript.",
    "",
    "## Wording reconciliation",
    "",
    "- Figure 3 now uses 'sample-level cohort' rather than 'deposited-sample-level cohort'.",
    "- The manuscript now explicitly distinguishes original GSE73461 median score differences from harmonised cross-cohort Hodges-Lehmann shifts.",
    "- Supplementary Tables S6-S10 explicitly identify their multipart S6A-S10E structure.",
    "",
    "## Integrity",
    "",
    f"- Source v1.7 SHA256: `{source_sha_after}`.",
    f"- Reconciled v1.8 SHA256: `{target_sha}`.",
    f"- Quality checks passed: "
    f"{sum(row['pass'] == 'TRUE' for row in checks)}/{len(checks)}.",
    "",
    "## Status",
    "",
    (
        "`READY_FOR_FINAL_MANUSCRIPT_REVIEW_AND_STAGING`"
        if quality_pass
        else "`FINAL_RECONCILIATION_REVIEW_REQUIRED`"
    ),
]

REPORT_FILE.write_text(
    "\n".join(report_lines) + "\n",
    encoding="utf-8",
)

print("===== MANUSCRIPT V1.8 RECONCILIATION =====")
print(f"reference_count\t{len(new_references)}")
print("gse72810_reference_number\t14")
print("removed_reference\tSTARD 2015")
print(
    "first_seen_12_21\t"
    + ",".join(
        str(number)
        for number in first_seen
    )
)
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
        "READY_FOR_FINAL_MANUSCRIPT_REVIEW_AND_STAGING"
        if quality_pass
        else "FINAL_RECONCILIATION_REVIEW_REQUIRED"
    )
)
print(
    "target\t"
    + str(
        TARGET.relative_to(ROOT)
    )
)
print(
    "diff\t"
    + str(
        DIFF_FILE.relative_to(ROOT)
    )
)

if not quality_pass:
    raise RuntimeError(
        "Final manuscript reconciliation failed quality checks."
    )
