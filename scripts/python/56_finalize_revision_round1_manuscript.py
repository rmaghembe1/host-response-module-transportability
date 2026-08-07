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
    / "docs/complete_manuscript_draft_v1.8_revision_round1_reconciled.md"
)

TARGET = (
    ROOT
    / "docs/complete_manuscript_draft_v1.9_revision_round1_final.md"
)

OUT_DIR = (
    ROOT
    / "results/revision_round1/"
    "manuscript_v1.9_final_reconciliation"
)

QUALITY_FILE = (
    OUT_DIR
    / "manuscript_v1.9_final_quality_gate.tsv"
)

SUMMARY_FILE = (
    OUT_DIR
    / "manuscript_v1.9_final_quality_summary.tsv"
)

DIFF_FILE = (
    OUT_DIR
    / "manuscript_v1.8_to_v1.9_unified_diff.txt"
)

REPORT_FILE = (
    ROOT
    / "docs/revision_round1/"
    "complete_manuscript_v1.9_final_report.md"
)

EXPECTED_SOURCE_SHA256 = (
    "a4c5915638b3324bb41c835007f75ecfac53c24bb0a13bfe7f00e3c5c323cd28"
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


def replace_once(
    text: str,
    old: str,
    new: str,
    label: str,
) -> str:
    count = text.count(old)

    if count != 1:
        raise RuntimeError(
            f"{label}: expected exactly one occurrence; found {count}."
        )

    return text.replace(
        old,
        new,
        1,
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


if not SOURCE.is_file() or SOURCE.stat().st_size == 0:
    raise RuntimeError(
        f"Missing source manuscript: {SOURCE}"
    )

source_sha_before = sha256_file(
    SOURCE
)

if source_sha_before != EXPECTED_SOURCE_SHA256:
    raise RuntimeError(
        "The reviewed v1.8 manuscript checksum has changed."
    )

if TARGET.exists():
    raise RuntimeError(
        f"Target already exists and will not be overwritten: {TARGET}"
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

if (
    "GSE73461-GSE72810 cross-cohort effect-size source data"
    not in source_text
):
    raise RuntimeError(
        "Reviewed v1.8 does not contain the expected correct "
        "GSE73461-GSE72810 supplementary wording."
    )

if (
    "GSE73461-GSE7281 cross-cohort effect-size source data"
    in source_text
):
    raise RuntimeError(
        "Unexpected truncated GSE7281 wording remains in v1.8."
    )

text = source_text


old_gse73461 = (
    "GSE73461 expression, annotation, metadata and group labels were "
    "audited independently of module discovery [13]. The primary "
    "projection contrast contained 52 DefiniteBacterial and 94 "
    "DefiniteViral samples. Fifty-five Control samples were retained "
    "in the main all-projected z-score reference but were not included "
    "in the primary bacterial-versus-viral test. Inflammatory, "
    "Kawasaki and Unknown groups were excluded from that contrast."
)

new_gse73461 = (
    "GSE73461 expression, annotation, metadata and group labels were "
    "audited independently of module discovery [13]. The 52 "
    "DefiniteBacterial, 94 DefiniteViral and 55 Control samples "
    "(n = 201) constituted the main z-score reference population. "
    "The primary inferential contrast remained restricted to the "
    "52 DefiniteBacterial versus 94 DefiniteViral samples; Control "
    "samples contributed to the reference population but not to the "
    "bacterial-versus-viral test. Inflammatory, Kawasaki and Unknown "
    "groups were excluded from both the main z-score reference "
    "population and the primary contrast."
)

text = replace_once(
    text,
    old_gse73461,
    new_gse73461,
    "GSE73461 z-reference paragraph",
)


old_gse72810 = (
    "GSE72810 contained 146 paediatric whole-blood samples measured "
    "using the Illumina HumanHT-12 v3 platform [14]. The locked "
    "primary contrast contained 23 definite bacterial and 28 definite "
    "viral samples. Seventeen probable bacterial and seven probable "
    "viral samples were reserved for expanded-case sensitivity "
    "analysis. Sixteen controls were retained for score-reference "
    "context, and 55 uncertain samples were excluded from "
    "bacterial-versus-viral testing."
)

new_gse72810 = (
    "GSE72810 contained 146 paediatric whole-blood samples measured "
    "using the Illumina HumanHT-12 v3 platform [14]. All 146 samples "
    "were retained in the main z-score reference population, whereas "
    "the locked primary inferential contrast was restricted to 23 "
    "definite bacterial versus 28 definite viral samples. Seventeen "
    "probable bacterial and seven probable viral samples were reserved "
    "for expanded-case sensitivity analysis. Sixteen controls and 55 "
    "uncertain samples contributed to the main z-score reference "
    "population but were excluded from the primary "
    "bacterial-versus-viral test."
)

text = replace_once(
    text,
    old_gse72810,
    new_gse72810,
    "GSE72810 z-reference paragraph",
)


title_pattern = (
    r"^# Complete Manuscript Draft v1\.8"
    r" - Revision Round 1 Reconciled$"
)

text, title_count = re.subn(
    title_pattern,
    "# Complete Manuscript Draft v1.9 - Revision Round 1 Final",
    text,
    count=1,
    flags=re.MULTILINE,
)

if title_count != 1:
    raise RuntimeError(
        f"Expected one v1.8 manuscript title; found {title_count}."
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
    text,
    encoding="utf-8",
)

source_sha_after = sha256_file(
    SOURCE
)

target_sha = sha256_file(
    TARGET
)


diff_lines = list(
    difflib.unified_diff(
        source_text.splitlines(),
        text.splitlines(),
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


checks = []

add_check(
    checks,
    "Reviewed v1.8 checksum matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    checks,
    "Protected v1.8 manuscript remained unchanged",
    source_sha_after == EXPECTED_SOURCE_SHA256,
    source_sha_after,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    checks,
    "GSE73461 main z-reference explicitly contains 201 samples",
    (
        "55 Control samples (n = 201) constituted the main "
        "z-score reference population"
    )
    in text,
    (
        "55 Control samples (n = 201) constituted the main "
        "z-score reference population"
    )
    in text,
    True,
)

add_check(
    checks,
    "GSE73461 primary contrast explicitly remains 52 versus 94",
    (
        "52 DefiniteBacterial versus 94 DefiniteViral samples"
        in text
    ),
    (
        "52 DefiniteBacterial versus 94 DefiniteViral samples"
        in text
    ),
    True,
)

add_check(
    checks,
    "GSE73461 excluded groups are outside reference and contrast",
    (
        "Inflammatory, Kawasaki and Unknown groups were excluded "
        "from both the main z-score reference population and the "
        "primary contrast."
    )
    in text,
    "explicit exclusion from both",
    True,
)

add_check(
    checks,
    "GSE72810 main z-reference explicitly uses all 146 samples",
    (
        "All 146 samples were retained in the main "
        "z-score reference population"
    )
    in text,
    "all 146 samples",
    True,
)

add_check(
    checks,
    "GSE72810 primary contrast explicitly remains 23 versus 28",
    (
        "23 definite bacterial versus 28 definite viral samples"
        in text
    ),
    "23 versus 28",
    True,
)

add_check(
    checks,
    "GSE72810 controls and uncertain samples contribute to reference",
    (
        "Sixteen controls and 55 uncertain samples contributed "
        "to the main z-score reference population"
    )
    in text,
    "16 controls and 55 uncertain in reference",
    True,
)

add_check(
    checks,
    "GSE72810 controls and uncertain excluded from primary test",
    (
        "population but were excluded from the primary "
        "bacterial-versus-viral test."
    )
    in text,
    "excluded from primary test",
    True,
)

add_check(
    checks,
    "Correct GSE73461-GSE72810 supplementary wording retained",
    (
        "GSE73461-GSE72810 cross-cohort effect-size source data"
        in text
    ),
    "GSE73461-GSE72810",
    True,
)

add_check(
    checks,
    "Truncated GSE7281 supplementary wording absent",
    (
        "GSE73461-GSE7281 cross-cohort effect-size source data"
        not in text
    ),
    (
        "GSE73461-GSE7281 cross-cohort effect-size source data"
        in text
    ),
    False,
)

add_check(
    checks,
    "GSE72810 remains reference 14",
    (
        "[14] National Center for Biotechnology Information. "
        "Gene Expression Omnibus accession GSE72810."
    )
    in text,
    "reference [14]",
    "reference [14]",
)

add_check(
    checks,
    "STARD remains absent",
    "STARD 2015" not in text,
    "STARD 2015" in text,
    False,
)

add_check(
    checks,
    "Multipart supplementary structure remains present",
    all(
        token in text
        for token in [
            "S6A-S6D",
            "S7A-S7D",
            "S8A-S8D",
            "S9A-S9B",
            "S10A-S10E",
        ]
    ),
    "all multipart labels present",
    "all multipart labels present",
)

add_check(
    checks,
    "Cross-cohort effect-estimate distinction remains present",
    (
        "these estimates are distinct from the median score differences"
        in text
    ),
    "explicit distinction present",
    True,
)

add_check(
    checks,
    "Investigator-network limitation remains present",
    (
        "the studies arose from the same broad investigator network"
        in text
    ),
    "limitation present",
    True,
)

add_check(
    checks,
    "Fully investigator-independent wording remains excluded",
    (
        "GSE72810 is therefore described as a second accession-level "
        "and sample-level cross-platform cohort rather than as a fully "
        "investigator-independent replication cohort."
    )
    in text,
    "boundary wording present",
    True,
)

add_check(
    checks,
    "No trailing whitespace",
    all(
        line == line.rstrip()
        for line in text.splitlines()
    ),
    "none detected",
    "none",
)

add_check(
    checks,
    "v1.9 differs from v1.8",
    target_sha != source_sha_before,
    target_sha,
    "different from v1.8",
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
        "gse73461_main_z_reference_n": 201,
        "gse72810_main_z_reference_n": 146,
        "gse72810_primary_bacterial_n": 23,
        "gse72810_primary_viral_n": 28,
        "quality_gate": (
            "PASS"
            if quality_pass
            else "REVIEW"
        ),
        "final_status": (
            "READY_FOR_SELECTIVE_REVISION_PACKAGE_STAGING"
            if quality_pass
            else "FINAL_MANUSCRIPT_REVIEW_REQUIRED"
        ),
    }
]

write_tsv(
    SUMMARY_FILE,
    summary,
    list(summary[0].keys()),
)


REPORT_FILE.write_text(
    "\n".join(
        [
            "# Complete manuscript v1.9 final reconciliation",
            "",
            "## Corrections",
            "",
            "- GSE73461 main z-score reference explicitly defined as "
            "52 definite bacterial + 94 definite viral + 55 controls "
            "(n = 201).",
            "- GSE72810 main z-score reference explicitly defined as "
            "all 146 samples, while the primary inferential contrast "
            "remains 23 definite bacterial versus 28 definite viral.",
            "- The already-correct GSE73461-GSE72810 supplementary "
            "wording was preserved and validated.",
            "",
            "## Integrity",
            "",
            f"- Source v1.8 SHA256: `{source_sha_after}`.",
            f"- Final v1.9 SHA256: `{target_sha}`.",
            f"- Quality checks passed: "
            f"{sum(row['pass'] == 'TRUE' for row in checks)}/{len(checks)}.",
            "",
            "## Status",
            "",
            (
                "`READY_FOR_SELECTIVE_REVISION_PACKAGE_STAGING`"
                if quality_pass
                else "`FINAL_MANUSCRIPT_REVIEW_REQUIRED`"
            ),
            "",
        ]
    ),
    encoding="utf-8",
)


print("===== MANUSCRIPT V1.9 FINALIZATION =====")
print("gse73461_main_z_reference_n\t201")
print("gse72810_main_z_reference_n\t146")
print("gse72810_primary_contrast\t23_vs_28")
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
        "READY_FOR_SELECTIVE_REVISION_PACKAGE_STAGING"
        if quality_pass
        else "FINAL_MANUSCRIPT_REVIEW_REQUIRED"
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
        "Final manuscript v1.9 reconciliation failed."
    )
