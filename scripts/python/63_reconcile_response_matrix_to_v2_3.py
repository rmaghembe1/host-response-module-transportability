#!/usr/bin/env python3

"""
63_reconcile_response_matrix_to_v2_3.py

Purpose
-------
Reconcile the already quality-gated PLOS ONE reviewer-response evidence
matrix from manuscript v2.2 to the new authoritative manuscript v2.3.

The scientific reviewer-response mappings do not change. Manuscript v2.3
differs from v2.2 only by restoration of the author metadata documented in
the original PLOS ONE submission.

This script updates:
1. authoritative manuscript path;
2. manuscript SHA256;
3. verified public revision commit;
4. textual references from v2.2 to v2.3 where they identify the current
   manuscript rather than historical revision steps;
5. matrix/report provenance.

It preserves:
- all 17 response items;
- all reviewer/editor mappings;
- all scientific revision actions;
- all supporting analysis evidence;
- the single package-stage-pending item.
"""

from __future__ import annotations

import csv
import hashlib
import sys
from pathlib import Path


# ============================================================================
# Locked provenance
# ============================================================================

MANUSCRIPT = Path(
    "docs/complete_manuscript_draft_v2.3_submission_candidate_metadata_restored.md"
)

EXPECTED_MANUSCRIPT_SHA = (
    "f3b61e6ddb9f5d38c6211c6cfe0d8694e6ca3b761d52a3245d58df844ab5b2ae"
)

VERIFIED_PUBLIC_COMMIT = (
    "bf0f04145091efd010b6a2e2d4d4148d033025b9"
)

SOURCE_MATRIX = Path(
    "results/revision_round1/plosone_reviewer_response_matrix/"
    "PLOS_ONE_revision_response_evidence_matrix.tsv"
)

SOURCE_SUMMARY = Path(
    "results/revision_round1/plosone_reviewer_response_matrix/"
    "PLOS_ONE_revision_response_matrix_summary.tsv"
)

SOURCE_REPORT = Path(
    "docs/revision_round1/PLOS_ONE_revision_response_evidence_matrix.md"
)

OUT_DIR = Path(
    "results/revision_round1/"
    "plosone_reviewer_response_matrix_v2.3_provenance"
)

TARGET_MATRIX = (
    OUT_DIR / "PLOS_ONE_revision_response_evidence_matrix_v2.3.tsv"
)

QUALITY_GATE = (
    OUT_DIR / "PLOS_ONE_revision_response_matrix_v2.3_quality_gate.tsv"
)

QUALITY_SUMMARY = (
    OUT_DIR / "PLOS_ONE_revision_response_matrix_v2.3_summary.tsv"
)

TARGET_REPORT = Path(
    "docs/revision_round1/"
    "PLOS_ONE_revision_response_evidence_matrix_v2.3.md"
)


# ============================================================================
# Utilities
# ============================================================================

def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)

    return digest.hexdigest()


def read_tsv(path: Path) -> list[dict[str, str]]:
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
    rows: list[dict[str, object]],
) -> None:

    if not rows:
        fail(f"No rows available for {path}")

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    fields = list(rows[0].keys())

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


# ============================================================================
# Preflight
# ============================================================================

required = [
    MANUSCRIPT,
    SOURCE_MATRIX,
    SOURCE_SUMMARY,
    SOURCE_REPORT,
]

missing = [
    str(path)
    for path in required
    if not path.exists()
]

if missing:
    fail(
        "Missing required file(s): "
        + ", ".join(missing)
    )

observed_manuscript_sha = sha256_file(
    MANUSCRIPT
)

if observed_manuscript_sha != EXPECTED_MANUSCRIPT_SHA:
    fail(
        "Authoritative v2.3 manuscript SHA mismatch. "
        f"Observed {observed_manuscript_sha}; "
        f"expected {EXPECTED_MANUSCRIPT_SHA}."
    )

source_rows = read_tsv(
    SOURCE_MATRIX
)

if len(source_rows) != 17:
    fail(
        f"Expected 17 response rows; observed {len(source_rows)}."
    )


# ============================================================================
# Reconcile matrix textual provenance
# ============================================================================

rows: list[dict[str, str]] = []

for row in source_rows:
    updated = dict(row)

    for field in [
        "revision_action",
        "manuscript_location",
        "supporting_evidence",
    ]:
        value = updated[field]

        value = value.replace(
            "v2.2 manuscript",
            "v2.3 manuscript",
        )

        value = value.replace(
            "present in v2.2",
            "present in v2.3",
        )

        value = value.replace(
            "v2.2 Methods",
            "v2.3 Methods",
        )

        value = value.replace(
            "v2.2 figure captions",
            "v2.3 figure captions",
        )

        value = value.replace(
            "described explicitly in v2.2",
            "described explicitly in v2.3",
        )

        value = value.replace(
            "v2.1/v2.2 language QA",
            (
                "v2.1/v2.2 language QA; "
                "v2.3 author-metadata restoration did not alter scientific text"
            ),
        )

        value = value.replace(
            (
                "verified remote commit "
                "93ee78bd48f090d67a8fed40c279ce2542066e23"
            ),
            (
                "verified public revision commit "
                f"{VERIFIED_PUBLIC_COMMIT}"
            ),
        )

        updated[field] = value

    rows.append(updated)


# ============================================================================
# Quality checks
# ============================================================================

checks: list[dict[str, object]] = []


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
            "pass": "TRUE" if passed else "FALSE",
            "observed": str(observed),
            "expected": str(expected),
        }
    )


add_check(
    "Authoritative v2.3 manuscript SHA matched",
    observed_manuscript_sha == EXPECTED_MANUSCRIPT_SHA,
    observed_manuscript_sha,
    EXPECTED_MANUSCRIPT_SHA,
)

add_check(
    "Response item count remains 17",
    len(rows) == 17,
    len(rows),
    17,
)

editor_count = sum(
    row["source"] == "Academic editor / journal"
    for row in rows
)

reviewer1_count = sum(
    row["source"] == "Reviewer 1"
    for row in rows
)

reviewer2_count = sum(
    row["source"] == "Reviewer 2"
    for row in rows
)

add_check(
    "Editor/journal item count remains four",
    editor_count == 4,
    editor_count,
    4,
)

add_check(
    "Reviewer 1 item count remains four",
    reviewer1_count == 4,
    reviewer1_count,
    4,
)

add_check(
    "Reviewer 2 item count remains nine",
    reviewer2_count == 9,
    reviewer2_count,
    9,
)

pending_count = sum(
    row["status"] == "PACKAGE_STAGE_PENDING"
    for row in rows
)

add_check(
    "Exactly one package-stage item remains pending",
    pending_count == 1,
    pending_count,
    1,
)

scientific_unaddressed = [
    row["response_id"]
    for row in rows
    if (
        row["source"] in {"Reviewer 1", "Reviewer 2"}
        and row["status"] != "ADDRESSED"
    )
]

add_check(
    "All Reviewer 1 and Reviewer 2 items remain addressed",
    len(scientific_unaddressed) == 0,
    (
        "none"
        if not scientific_unaddressed
        else ",".join(scientific_unaddressed)
    ),
    "none",
)

combined_text = "\n".join(
    "\t".join(row.values())
    for row in rows
)

add_check(
    "Obsolete v2.2 current-manuscript wording is absent",
    "v2.2 manuscript" not in combined_text,
    combined_text.count("v2.2 manuscript"),
    0,
)

add_check(
    "Obsolete pre-v2.3 verified commit is absent",
    (
        "93ee78bd48f090d67a8fed40c279ce2542066e23"
        not in combined_text
    ),
    combined_text.count(
        "93ee78bd48f090d67a8fed40c279ce2542066e23"
    ),
    0,
)

add_check(
    "Current verified public commit is represented",
    VERIFIED_PUBLIC_COMMIT in combined_text,
    "present",
    "present",
)

add_check(
    "Second external cohort response remains documented",
    any(
        row["item"] == "R1.1"
        and "GSE72810" in row["revision_action"]
        for row in rows
    ),
    "present",
    "present",
)

add_check(
    "GSVA response remains documented",
    any(
        row["item"] == "R1.3"
        and "GSVA" in row["revision_action"]
        for row in rows
    ),
    "present",
    "present",
)

add_check(
    "Effect-size response remains documented",
    any(
        row["item"] == "R1.4"
        and "Hodges-Lehmann" in row["revision_action"]
        for row in rows
    ),
    "present",
    "present",
)

add_check(
    "Gene-deletion response remains documented",
    any(
        row["item"] == "R2.1"
        and "29,826" in row["supporting_evidence"]
        for row in rows
    ),
    "present",
    "present",
)

add_check(
    "Figure 2C correction remains documented",
    any(
        row["item"] == "R2.7"
        and "no line connects modules" in row["revision_action"]
        for row in rows
    ),
    "present",
    "present",
)


quality_passed = sum(
    row["pass"] == "TRUE"
    for row in checks
)

quality_failed = len(checks) - quality_passed

quality_gate = (
    "PASS"
    if quality_failed == 0
    else "FAIL"
)

final_status = (
    "READY_FOR_DOCX_SUBMISSION_PACKAGE_PRODUCTION"
    if quality_failed == 0
    else "V2_3_RESPONSE_MATRIX_PROVENANCE_REQUIRES_REVIEW"
)


# ============================================================================
# Write reconciled matrix and audit files
# ============================================================================

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

TARGET_REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)

write_tsv(
    TARGET_MATRIX,
    rows,
)

write_tsv(
    QUALITY_GATE,
    checks,
)

write_tsv(
    QUALITY_SUMMARY,
    [
        {
            "response_items": len(rows),
            "editor_items": editor_count,
            "reviewer1_items": reviewer1_count,
            "reviewer2_items": reviewer2_count,
            "package_stage_pending": pending_count,
            "quality_checks": len(checks),
            "quality_checks_passed": quality_passed,
            "quality_checks_failed": quality_failed,
            "authoritative_manuscript": str(MANUSCRIPT),
            "manuscript_sha256": observed_manuscript_sha,
            "verified_public_commit": VERIFIED_PUBLIC_COMMIT,
            "quality_gate": quality_gate,
            "final_status": final_status,
        }
    ],
)


# ============================================================================
# Report
# ============================================================================

report_lines = [
    "# PLOS ONE Revision Response Evidence Matrix - v2.3 Provenance",
    "",
    "Manuscript: PONE-D-26-30583",
    "",
    f"Authoritative revised manuscript: `{MANUSCRIPT}`",
    "",
    f"Manuscript SHA256: `{observed_manuscript_sha}`",
    "",
    f"Verified public revision commit: `{VERIFIED_PUBLIC_COMMIT}`",
    "",
    "## Provenance reconciliation",
    "",
    (
        "The scientific reviewer-response mappings remain unchanged from "
        "the previously quality-gated 17-item response matrix."
    ),
    "",
    (
        "Manuscript v2.3 differs from v2.2 only by restoration of the "
        "submitted author affiliations and correspondence metadata."
    ),
    "",
    (
        "References to the current manuscript and verified public commit "
        "have therefore been updated to v2.3 provenance."
    ),
    "",
    "## Matrix status",
    "",
    f"- Response items: {len(rows)}",
    f"- Editor/journal items: {editor_count}",
    f"- Reviewer 1 items: {reviewer1_count}",
    f"- Reviewer 2 items: {reviewer2_count}",
    f"- Package-stage-pending items: {pending_count}",
    f"- Quality checks passed: {quality_passed}/{len(checks)}",
    f"- Quality gate: `{quality_gate}`",
    f"- Final status: `{final_status}`",
    "",
    "## Baselines for document production",
    "",
    (
        "- Clean revised manuscript source: "
        "`docs/complete_manuscript_draft_v2.3_submission_candidate_"
        "metadata_restored.md`"
    ),
    (
        "- Marked-up textual baseline: actual PLOS ONE submission PDF "
        "`PONE-D-26-30583.pdf`"
    ),
    (
        "- Formatting donor only: June 8 DOCX "
        "`External transportability of bacterial and viral.docx`"
    ),
    "",
]

TARGET_REPORT.write_text(
    "\n".join(report_lines),
    encoding="utf-8",
    newline="\n",
)


# ============================================================================
# Console summary
# ============================================================================

print("===== PLOS ONE RESPONSE MATRIX V2.3 PROVENANCE =====")
print(f"response_items\t{len(rows)}")
print(f"editor_items\t{editor_count}")
print(f"reviewer1_items\t{reviewer1_count}")
print(f"reviewer2_items\t{reviewer2_count}")
print(f"package_stage_pending\t{pending_count}")
print(f"quality_checks_passed\t{quality_passed}/{len(checks)}")
print(f"quality_gate\t{quality_gate}")
print(f"manuscript_sha256\t{observed_manuscript_sha}")
print(f"verified_public_commit\t{VERIFIED_PUBLIC_COMMIT}")
print(f"final_status\t{final_status}")
print(f"matrix\t{TARGET_MATRIX}")
print(f"quality_gate_file\t{QUALITY_GATE}")
print(f"summary\t{QUALITY_SUMMARY}")
print(f"report\t{TARGET_REPORT}")

if quality_failed:
    fail(
        f"v2.3 response-matrix provenance failed "
        f"{quality_failed} quality check(s)."
    )
