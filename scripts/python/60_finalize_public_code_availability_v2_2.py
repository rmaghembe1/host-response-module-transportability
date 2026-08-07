#!/usr/bin/env python3

"""
60_finalize_public_code_availability_v2_2.py

Purpose
-------
Create manuscript v2.2 from the locked v2.1 manuscript after verified public
synchronization of the PLOS ONE revision branch.

This pass is intentionally restricted to:

1. Updating the manuscript working-version heading.
2. Changing Code Availability from future-tense synchronization language to a
   verified present-tense statement.
3. Adding the direct public GitHub revision-branch URL.

No scientific text, numerical result, figure caption, reference, dataset link,
AI disclosure, module definition, statistical description or limitation is
changed.

Verified public branch
----------------------
Repository:
https://github.com/rmaghembe1/host-response-module-transportability

Branch:
plosone_revision_round1_2026

Verified synchronized commit before this manuscript update:
4489e7ccd530762615d0315444569984e1eb1e5c
"""

from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path


# ============================================================================
# Locked source and output paths
# ============================================================================

SOURCE = Path(
    "docs/complete_manuscript_draft_v2.1_reviewer_editor_final.md"
)

TARGET = Path(
    "docs/complete_manuscript_draft_v2.2_submission_candidate.md"
)

EXPECTED_SOURCE_SHA256 = (
    "cb14e3ef8424ca7510b22db782b737ccf93e9767b690ed758c3da9818b93347e"
)

VERIFIED_PRE_UPDATE_COMMIT = (
    "4489e7ccd530762615d0315444569984e1eb1e5c"
)

PUBLIC_REPOSITORY = (
    "https://github.com/rmaghembe1/"
    "host-response-module-transportability"
)

REVISION_BRANCH = "plosone_revision_round1_2026"

PUBLIC_BRANCH_URL = (
    "https://github.com/rmaghembe1/"
    "host-response-module-transportability/"
    "tree/plosone_revision_round1_2026"
)

OUT_DIR = Path(
    "results/revision_round1/"
    "manuscript_v2.2_public_code_availability"
)

QUALITY_GATE = OUT_DIR / "manuscript_v2.2_quality_gate.tsv"

QUALITY_SUMMARY = OUT_DIR / "manuscript_v2.2_quality_summary.tsv"

REPLACEMENT_MANIFEST = (
    OUT_DIR / "manuscript_v2.2_replacement_manifest.tsv"
)

REPORT = Path(
    "docs/revision_round1/"
    "complete_manuscript_v2.2_public_code_availability_report.md"
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


def replace_exact(
    text: str,
    old: str,
    new: str,
    label: str,
    manifest: list[dict[str, str]],
) -> str:

    count = text.count(old)

    if count != 1:
        fail(
            f"{label}: expected exactly one occurrence; "
            f"observed {count}"
        )

    updated = text.replace(
        old,
        new,
        1,
    )

    manifest.append(
        {
            "replacement_id": f"R{len(manifest) + 1:02d}",
            "label": label,
            "source_occurrences": str(count),
            "status": "APPLIED",
        }
    )

    return updated


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

    fieldnames = list(
        rows[0].keys()
    )

    with path.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as handle:

        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            delimiter="\t",
            lineterminator="\n",
        )

        writer.writeheader()

        for row in rows:
            writer.writerow(row)


def count_references(text: str) -> int:
    return len(
        re.findall(
            r"^\[\d+\]\s",
            text,
            flags=re.MULTILINE,
        )
    )


def has_trailing_whitespace(text: str) -> bool:

    for line in text.splitlines():
        if line.endswith(" ") or line.endswith("\t"):
            return True

    return False


# ============================================================================
# Preflight
# ============================================================================

if not SOURCE.exists():
    fail(
        f"Missing source manuscript: {SOURCE}"
    )

if TARGET.exists():
    fail(
        f"Target already exists: {TARGET}. "
        "Refusing to overwrite it."
    )

source_sha_before = sha256_file(
    SOURCE
)

if source_sha_before != EXPECTED_SOURCE_SHA256:
    fail(
        "Locked v2.1 source SHA256 mismatch. "
        f"Observed {source_sha_before}; "
        f"expected {EXPECTED_SOURCE_SHA256}."
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

text = source_text

manifest: list[dict[str, str]] = []


# ============================================================================
# Replacement 1: version heading
# ============================================================================

text = replace_exact(
    text,
    "# Complete Manuscript Draft v2.1 - Reviewer and Editor Final",
    "# Complete Manuscript Draft v2.2 - Submission Candidate",
    "Update manuscript working-version heading",
    manifest,
)


# ============================================================================
# Replacement 2: verified public Code Availability
# ============================================================================

old_code_availability = (
    "Analysis scripts, decision logs, quality gates, source-data tables, "
    "manuscript-facing figures and supplementary outputs are organised in "
    "the public project repository at "
    "`https://github.com/rmaghembe1/host-response-module-transportability`. "
    "Revision-round code and outputs are maintained on the dedicated "
    "revision branch and will be synchronised with the public repository "
    "before resubmission."
)

new_code_availability = (
    "Analysis scripts, decision logs, quality gates, source-data tables, "
    "manuscript-facing figures and supplementary outputs are available in "
    "the public project repository at "
    "`https://github.com/rmaghembe1/host-response-module-transportability`. "
    "The revision-round code and outputs used for this resubmission are "
    "available on the public `plosone_revision_round1_2026` branch at "
    "`https://github.com/rmaghembe1/"
    "host-response-module-transportability/"
    "tree/plosone_revision_round1_2026`."
)

text = replace_exact(
    text,
    old_code_availability,
    new_code_availability,
    "Convert Code Availability to verified present tense",
    manifest,
)


# ============================================================================
# Write target
# ============================================================================

TARGET.parent.mkdir(
    parents=True,
    exist_ok=True,
)

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)

TARGET.write_text(
    text,
    encoding="utf-8",
    newline="\n",
)

source_sha_after = sha256_file(
    SOURCE
)

target_sha = sha256_file(
    TARGET
)


# ============================================================================
# Quality gate
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
    "Locked v2.1 source SHA matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "Locked v2.1 source remained unchanged",
    source_sha_after == EXPECTED_SOURCE_SHA256,
    source_sha_after,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "Exactly two controlled replacements were applied",
    len(manifest) == 2,
    len(manifest),
    2,
)

add_check(
    "Submission-candidate heading is present",
    (
        "# Complete Manuscript Draft v2.2 - Submission Candidate"
        in text
    ),
    "present",
    "present",
)

add_check(
    "Future synchronization wording is absent",
    (
        "will be synchronised with the public repository before resubmission"
        not in text
    ),
    "absent",
    "absent",
)

add_check(
    "Public repository URL is present",
    PUBLIC_REPOSITORY in text,
    "present",
    "present",
)

add_check(
    "Revision branch name is present",
    REVISION_BRANCH in text,
    "present",
    "present",
)

add_check(
    "Direct public revision-branch URL is present",
    PUBLIC_BRANCH_URL in text,
    "present",
    "present",
)

add_check(
    "Code Availability states materials are available",
    (
        "revision-round code and outputs used for this resubmission "
        "are available"
    ) in text,
    "present-tense availability statement present",
    "present-tense availability statement present",
)

add_check(
    "GSE211567 discovery n remains 224",
    "prespecified primary discovery set contained 224 samples" in text,
    "224",
    "224",
)

add_check(
    "GSE211567 group counts remain 101 bacterial and 123 viral",
    "101 bacterial and 123 viral" in text,
    "101 bacterial; 123 viral",
    "101 bacterial; 123 viral",
)

add_check(
    "GSE73461 main reference remains n = 201",
    "55 Control samples (n = 201)" in text,
    "201",
    "201",
)

add_check(
    "GSE72810 primary contrast remains 23 versus 28",
    (
        "23 definite bacterial versus 28 definite viral samples"
        in text
    ),
    "23 versus 28",
    "23 versus 28",
)

add_check(
    "Deletion analysis remains 29,826 variants",
    "29,826" in text,
    "29,826",
    "29,826",
)

add_check(
    "Minimum deletion Pearson correlation remains 0.9940",
    "0.9940" in text,
    "0.9940",
    "0.9940",
)

add_check(
    "Figure 2C independent-point language is preserved",
    (
        "are shown as independent points for each categorical module"
        in text
    ),
    "present",
    "present",
)

add_check(
    "Directional-concordance definition is preserved",
    (
        "directional concordance was defined as agreement in the sign "
        "of the bacterial-versus-viral log2 fold change"
        in text
    ),
    "present",
    "present",
)

add_check(
    "Formal z-score equation is preserved",
    "z_gi = (x_gi - mean_g) / SD_g" in text,
    "present",
    "present",
)

add_check(
    "Formal module-score equation is preserved",
    "score_i = (1/K) sum_g z_gi" in text,
    "present",
    "present",
)

add_check(
    "Cross-cohort investigator-network limitation is preserved",
    "same broad investigator network" in text,
    "present",
    "present",
)

add_check(
    "Fully investigator-independent boundary is preserved",
    (
        "should therefore not be treated as a fully "
        "investigator-independent replication cohort"
        in text
    ),
    "present",
    "present",
)

add_check(
    "ChatGPT/OpenAI disclosure is preserved",
    (
        "ChatGPT" in text
        and "OpenAI" in text
    ),
    "present",
    "present",
)

geo_urls = [
    "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567",
    "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461",
    "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810",
]

add_check(
    "All three direct GEO links are preserved",
    all(
        url in text
        for url in geo_urls
    ),
    "3 URLs present",
    "3 URLs present",
)

reference_count = count_references(
    text
)

add_check(
    "Reference count remains 21",
    reference_count == 21,
    reference_count,
    21,
)

add_check(
    "STARD remains absent",
    "STARD" not in text,
    text.count("STARD"),
    0,
)

add_check(
    "No trailing whitespace is present",
    not has_trailing_whitespace(text),
    (
        "clean"
        if not has_trailing_whitespace(text)
        else "trailing whitespace found"
    ),
    "clean",
)

add_check(
    "v2.2 differs from v2.1",
    target_sha != source_sha_before,
    target_sha,
    "different from source SHA",
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
    "READY_FOR_PUBLIC_CODE_AVAILABILITY_COMMIT"
    if quality_failed == 0
    else "V2_2_REQUIRES_REVIEW"
)


# ============================================================================
# Write audit products
# ============================================================================

write_tsv(
    REPLACEMENT_MANIFEST,
    manifest,
)

write_tsv(
    QUALITY_GATE,
    checks,
)

write_tsv(
    QUALITY_SUMMARY,
    [
        {
            "quality_checks": len(checks),
            "quality_checks_passed": quality_passed,
            "quality_checks_failed": quality_failed,
            "replacements_applied": len(manifest),
            "verified_pre_update_commit": VERIFIED_PRE_UPDATE_COMMIT,
            "source_sha256": source_sha_before,
            "target_sha256": target_sha,
            "reference_count": reference_count,
            "quality_gate": quality_gate,
            "final_status": final_status,
        }
    ],
)


# ============================================================================
# Report
# ============================================================================

report_lines = [
    "# Complete Manuscript v2.2 Public Code Availability Reconciliation",
    "",
    "## Verified repository state",
    "",
    f"- Public repository: `{PUBLIC_REPOSITORY}`",
    f"- Revision branch: `{REVISION_BRANCH}`",
    (
        "- Verified synchronized pre-update commit: "
        f"`{VERIFIED_PRE_UPDATE_COMMIT}`"
    ),
    f"- Public branch URL: `{PUBLIC_BRANCH_URL}`",
    "",
    "## Controlled manuscript changes",
    "",
    "- Updated the manuscript working-version heading to v2.2.",
    (
        "- Converted Code Availability from future-tense synchronization "
        "language to a verified present-tense availability statement."
    ),
    "- Added the direct public revision-branch URL.",
    "",
    "## Scientific preservation",
    "",
    "- No analysis was rerun.",
    "- No numerical result was changed.",
    "- No module gene set or expected direction was changed.",
    "- No figure or table result was changed.",
    "- No reference was added, removed or renumbered.",
    "- No dataset-access statement was changed.",
    "- No AI-disclosure language was changed.",
    "- No cohort-independence limitation was changed.",
    "",
    "## Quality gate",
    "",
    f"- Checks passed: {quality_passed}/{len(checks)}.",
    f"- Quality gate: `{quality_gate}`.",
    f"- Final status: `{final_status}`.",
    "",
]

REPORT.write_text(
    "\n".join(report_lines),
    encoding="utf-8",
    newline="\n",
)


# ============================================================================
# Console summary
# ============================================================================

print("===== MANUSCRIPT V2.2 PUBLIC CODE AVAILABILITY =====")
print(f"source_sha256\t{source_sha_before}")
print(f"target_sha256\t{target_sha}")
print(f"replacements_applied\t{len(manifest)}")
print(f"quality_checks_passed\t{quality_passed}/{len(checks)}")
print(f"quality_gate\t{quality_gate}")
print(f"reference_count\t{reference_count}")
print(f"verified_pre_update_commit\t{VERIFIED_PRE_UPDATE_COMMIT}")
print(f"revision_branch\t{REVISION_BRANCH}")
print(f"final_status\t{final_status}")
print(f"target\t{TARGET}")
print(f"quality_gate_file\t{QUALITY_GATE}")
print(f"quality_summary\t{QUALITY_SUMMARY}")
print(f"replacement_manifest\t{REPLACEMENT_MANIFEST}")
print(f"report\t{REPORT}")

if quality_failed:
    fail(
        f"v2.2 failed {quality_failed} quality check(s)."
    )
