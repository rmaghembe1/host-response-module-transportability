#!/usr/bin/env python3

"""
62_restore_submitted_author_metadata_v2_3.py

Purpose
-------
Create manuscript v2.3 from the scientifically locked v2.2 submission
candidate by restoring the author metadata documented in the actual
PLOS ONE submission record.

Restored submitted metadata
---------------------------
Author:
Reuben S. Maghembe1,2*

Affiliation 1:
Department of Microbiology and Parasitology, Faculty of Medicine,
St. Francis University College of Health and Allied Sciences (SFUCHAS),
Ifakara, Tanzania

Affiliation 2:
Department of Omics and Computational Biology, AfroBiomics Co. Ltd.,
Kivukoni, Bridge Street, Dar es Salaam, Tanzania

Correspondence:
rmaghembe@gmail.com
rmaghembe@sfuchas.ac.tz

Important
---------
This script changes only:
1. the internal manuscript version heading; and
2. author/affiliation/correspondence metadata.

It does NOT alter:
- article title;
- Abstract;
- Methods;
- Results;
- Discussion;
- figures or captions;
- tables;
- numerical results;
- references;
- Data Availability;
- Code Availability;
- AI disclosure;
- reviewer-response content.

The v2.2 source remains untouched.
"""

from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path


# ============================================================================
# Locked source and outputs
# ============================================================================

SOURCE = Path(
    "docs/complete_manuscript_draft_v2.2_submission_candidate.md"
)

TARGET = Path(
    "docs/complete_manuscript_draft_v2.3_submission_candidate_metadata_restored.md"
)

EXPECTED_SOURCE_SHA256 = (
    "b2eab3a7e3c195cfa4b5c629af932b434357160d93650cae50aa921f8832f01a"
)

OUT_DIR = Path(
    "results/revision_round1/"
    "manuscript_v2.3_submitted_author_metadata_restoration"
)

QUALITY_GATE = OUT_DIR / "manuscript_v2.3_quality_gate.tsv"

QUALITY_SUMMARY = OUT_DIR / "manuscript_v2.3_quality_summary.tsv"

REPLACEMENT_MANIFEST = (
    OUT_DIR / "manuscript_v2.3_replacement_manifest.tsv"
)

REPORT = Path(
    "docs/revision_round1/"
    "complete_manuscript_v2.3_submitted_author_metadata_restoration_report.md"
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
            f"{label}: expected exactly one source occurrence; "
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

    fieldnames = list(rows[0].keys())

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
        f"Missing locked v2.2 manuscript: {SOURCE}"
    )

if TARGET.exists():
    fail(
        f"Target already exists: {TARGET}. "
        "Refusing to overwrite an existing manuscript."
    )

source_sha_before = sha256_file(
    SOURCE
)

if source_sha_before != EXPECTED_SOURCE_SHA256:
    fail(
        "Locked v2.2 manuscript SHA256 mismatch. "
        f"Observed {source_sha_before}; "
        f"expected {EXPECTED_SOURCE_SHA256}."
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

text = source_text

manifest: list[dict[str, str]] = []


# ============================================================================
# Replacement 1: manuscript version heading
# ============================================================================

text = replace_exact(
    text,
    "# Complete Manuscript Draft v2.2 - Submission Candidate",
    (
        "# Complete Manuscript Draft v2.3 - "
        "Submission Candidate with Submitted Author Metadata Restored"
    ),
    "Update manuscript working-version heading",
    manifest,
)


# ============================================================================
# Replacement 2: restore submitted author metadata
# ============================================================================

old_author_block = """## Author and affiliation

Reuben S. Maghembe*

St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania

*Corresponding author:
Reuben S. Maghembe
St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania
Email: rmaghembe@sfuchas.ac.tz
"""

new_author_block = """## Author and affiliations

Reuben S. Maghembe¹˒²*

¹Department of Microbiology and Parasitology, Faculty of Medicine, St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania

²Department of Omics and Computational Biology, AfroBiomics Co. Ltd., Kivukoni, Bridge Street, Dar es Salaam, Tanzania

*Corresponding author:

Reuben S. Maghembe

St. Francis University College of Health and Allied Sciences (SFUCHAS), Ifakara, Tanzania

Email: rmaghembe@gmail.com; rmaghembe@sfuchas.ac.tz
"""

text = replace_exact(
    text,
    old_author_block,
    new_author_block,
    "Restore submitted affiliations and correspondence emails",
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
    "Locked v2.2 SHA matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "Locked v2.2 source remained unchanged",
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
    "Submitted two-affiliation author marker is present",
    "Reuben S. Maghembe¹˒²*" in text,
    "present",
    "present",
)

add_check(
    "SFUCHAS department affiliation is restored",
    (
        "Department of Microbiology and Parasitology, Faculty of Medicine, "
        "St. Francis University College of Health and Allied Sciences "
        "(SFUCHAS), Ifakara, Tanzania"
    ) in text,
    "present",
    "present",
)

add_check(
    "AfroBiomics affiliation is restored",
    (
        "Department of Omics and Computational Biology, AfroBiomics Co. Ltd., "
        "Kivukoni, Bridge Street, Dar es Salaam, Tanzania"
    ) in text,
    "present",
    "present",
)

add_check(
    "Bridge Street spelling is correct",
    "Bridge Street" in text,
    "Bridge Street",
    "Bridge Street",
)

add_check(
    "Brigde Street typo is absent",
    "Brigde Street" not in text,
    text.count("Brigde Street"),
    0,
)

add_check(
    "Gmail correspondence address is restored",
    "rmaghembe@gmail.com" in text,
    "present",
    "present",
)

add_check(
    "SFUCHAS correspondence address is retained",
    "rmaghembe@sfuchas.ac.tz" in text,
    "present",
    "present",
)

add_check(
    "Both correspondence emails occur in the author block order",
    (
        "Email: rmaghembe@gmail.com; rmaghembe@sfuchas.ac.tz"
        in text
    ),
    "present",
    "present",
)

# ---------------------------------------------------------------------------
# Scientific preservation anchors
# ---------------------------------------------------------------------------

add_check(
    "Article title remains unchanged from v2.2",
    (
        "External transportability of bacterial- and viral-associated "
        "host-response modules across public transcriptomic cohorts"
    ) in text,
    "present",
    "present",
)

add_check(
    "GSE211567 discovery n remains 224",
    "prespecified primary discovery set contained 224 samples" in text,
    "224",
    "224",
)

add_check(
    "GSE211567 groups remain 101 bacterial and 123 viral",
    "101 bacterial and 123 viral" in text,
    "101 bacterial; 123 viral",
    "101 bacterial; 123 viral",
)

add_check(
    "GSE73461 reference population remains n = 201",
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
    "Figure 2C independent-point correction is preserved",
    (
        "independent points for each categorical module"
        in text
    ),
    "present",
    "present",
)

add_check(
    "Directional concordance definition is preserved",
    (
        "directional concordance was defined as agreement in the sign"
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
    "Investigator-network limitation is preserved",
    "same broad investigator network" in text,
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

add_check(
    "Public revision branch Code Availability is preserved",
    (
        "plosone_revision_round1_2026"
        in text
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
    "All three direct GEO URLs are preserved",
    all(url in text for url in geo_urls),
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
    "No trailing whitespace",
    not has_trailing_whitespace(text),
    (
        "clean"
        if not has_trailing_whitespace(text)
        else "trailing whitespace found"
    ),
    "clean",
)

add_check(
    "v2.3 differs from v2.2",
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
    "READY_FOR_V2_3_METADATA_REVIEW_AND_DOCUMENT_PRODUCTION"
    if quality_failed == 0
    else "V2_3_METADATA_RESTORATION_REQUIRES_REVIEW"
)


# ============================================================================
# Write audit outputs
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
    "# Complete Manuscript v2.3 Submitted Author Metadata Restoration",
    "",
    "## Source lock",
    "",
    f"- Source: `{SOURCE}`",
    f"- Source SHA256: `{source_sha_before}`",
    f"- Target: `{TARGET}`",
    f"- Target SHA256: `{target_sha}`",
    "",
    "## Restored submitted metadata",
    "",
    "- Reuben S. Maghembe assigned affiliations 1 and 2.",
    (
        "- Affiliation 1 restored as the Department of Microbiology and "
        "Parasitology, Faculty of Medicine, SFUCHAS, Ifakara, Tanzania."
    ),
    (
        "- Affiliation 2 restored as the Department of Omics and "
        "Computational Biology, AfroBiomics Co. Ltd., Kivukoni, "
        "Bridge Street, Dar es Salaam, Tanzania."
    ),
    "- Correspondence email restored: rmaghembe@gmail.com.",
    "- Correspondence email retained: rmaghembe@sfuchas.ac.tz.",
    "",
    "## Scientific preservation",
    "",
    "- No analysis was rerun.",
    "- No scientific interpretation was changed.",
    "- No numerical result was changed.",
    "- No module definition was changed.",
    "- No figure caption was changed.",
    "- No table was changed.",
    "- No reference was added, removed or renumbered.",
    "- Data Availability was unchanged.",
    "- Code Availability was unchanged.",
    "- The generative-AI disclosure was unchanged.",
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

print("===== MANUSCRIPT V2.3 SUBMITTED METADATA RESTORATION =====")
print(f"source_sha256\t{source_sha_before}")
print(f"target_sha256\t{target_sha}")
print(f"replacements_applied\t{len(manifest)}")
print(f"quality_checks_passed\t{quality_passed}/{len(checks)}")
print(f"quality_gate\t{quality_gate}")
print(f"reference_count\t{reference_count}")
print(f"final_status\t{final_status}")
print(f"target\t{TARGET}")
print(f"quality_gate_file\t{QUALITY_GATE}")
print(f"quality_summary\t{QUALITY_SUMMARY}")
print(f"replacement_manifest\t{REPLACEMENT_MANIFEST}")
print(f"report\t{REPORT}")

if quality_failed:
    fail(
        f"v2.3 failed {quality_failed} quality check(s)."
    )
