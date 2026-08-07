#!/usr/bin/env python3

"""
61_build_plosone_reviewer_response_matrix.py

Purpose
-------
Construct a formal evidence matrix for the PLOS ONE revision of
PONE-D-26-30583.

The matrix maps every editor/reviewer request to:
- the revision action taken;
- manuscript section(s);
- supporting analyses/files;
- response status.

This is an intermediate audit product, not yet the final response letter.
Page/line references will be added only after the clean and marked-up
submission manuscripts have been formatted.

Authoritative manuscript
-------------------------
docs/complete_manuscript_draft_v2.2_submission_candidate.md

Authoritative public revision branch
------------------------------------
plosone_revision_round1_2026

Verified public commit at start of this phase
---------------------------------------------
93ee78bd48f090d67a8fed40c279ce2542066e23
"""

from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path


MANUSCRIPT = Path(
    "docs/complete_manuscript_draft_v2.2_submission_candidate.md"
)

EXPECTED_MANUSCRIPT_SHA = (
    "b2eab3a7e3c195cfa4b5c629af932b434357160d93650cae50aa921f8832f01a"
)

EXPECTED_HEAD = (
    "93ee78bd48f090d67a8fed40c279ce2542066e23"
)

OUT_DIR = Path(
    "results/revision_round1/plosone_reviewer_response_matrix"
)

MATRIX = OUT_DIR / "PLOS_ONE_revision_response_evidence_matrix.tsv"

QUALITY_GATE = OUT_DIR / "PLOS_ONE_revision_response_matrix_quality_gate.tsv"

SUMMARY = OUT_DIR / "PLOS_ONE_revision_response_matrix_summary.tsv"

REPORT = Path(
    "docs/revision_round1/PLOS_ONE_revision_response_evidence_matrix.md"
)


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)

    return digest.hexdigest()


def write_tsv(
    path: Path,
    rows: list[dict[str, object]],
) -> None:

    if not rows:
        fail(f"No rows supplied for {path}")

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
        writer.writerows(rows)


if not MANUSCRIPT.exists():
    fail(
        f"Missing authoritative manuscript: {MANUSCRIPT}"
    )

observed_sha = sha256_file(
    MANUSCRIPT
)

if observed_sha != EXPECTED_MANUSCRIPT_SHA:
    fail(
        "Authoritative v2.2 manuscript SHA mismatch. "
        f"Observed {observed_sha}; "
        f"expected {EXPECTED_MANUSCRIPT_SHA}."
    )

text = MANUSCRIPT.read_text(
    encoding="utf-8"
)


# ---------------------------------------------------------------------------
# Required manuscript anchors
# ---------------------------------------------------------------------------

anchors = {
    "transportability_definition":
        "transportability means preservation of the prespecified biological direction",

    "projection_definition":
        "Fixed-module projection means applying predefined gene sets",

    "gse211567_n":
        "prespecified primary discovery set contained 224 samples",

    "gse211567_groups":
        "101 bacterial and 123 viral",

    "directional_concordance":
        "directional concordance was defined as agreement in the sign",

    "go_curation":
        "rather than mathematical optimisation for separation or prediction accuracy",

    "gse73461_reference":
        "55 Control samples (n = 201)",

    "gse72810_reference":
        "All 146 samples were retained in the main z-score reference population",

    "gse72810_primary":
        "23 definite bacterial versus 28 definite viral samples",

    "module_formula":
        "score_i = (1/K) sum_g z_gi",

    "z_formula":
        "z_gi = (x_gi - mean_g) / SD_g",

    "figure2c_points":
        "independent points for each categorical module",

    "figure2c_not_connected":
        "The module categories are not connected",

    "deletion_count":
        "29,826",

    "deletion_correlation":
        "0.9940",

    "gsva":
        "GSVA",

    "investigator_boundary":
        "same broad investigator network",

    "not_fully_independent":
        "fully investigator-independent replication cohort",

    "chatgpt":
        "ChatGPT",

    "openai":
        "OpenAI",

    "code_branch":
        "plosone_revision_round1_2026",

    "gse211567_url":
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567",

    "gse73461_url":
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461",

    "gse72810_url":
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810",
}


missing_anchors = [
    name
    for name, value in anchors.items()
    if value not in text
]

if missing_anchors:
    fail(
        "Missing required manuscript anchor(s): "
        + ", ".join(missing_anchors)
    )


# ---------------------------------------------------------------------------
# Response matrix
# ---------------------------------------------------------------------------

rows: list[dict[str, str]] = []


def add_row(
    source: str,
    item: str,
    request: str,
    action: str,
    manuscript_location: str,
    evidence: str,
    status: str = "ADDRESSED",
) -> None:

    rows.append(
        {
            "response_id": f"RR{len(rows) + 1:02d}",
            "source": source,
            "item": item,
            "review_request": request,
            "revision_action": action,
            "manuscript_location": manuscript_location,
            "supporting_evidence": evidence,
            "status": status,
        }
    )


# ---------------------------------------------------------------------------
# Academic editor / journal requirements
# ---------------------------------------------------------------------------

add_row(
    "Academic editor / journal",
    "J1",
    "Ensure PLOS ONE style requirements and file naming are followed.",
    (
        "Scientific manuscript content has been finalized. "
        "PLOS-specific clean and marked-up submission files will be generated "
        "and checked in the final formatting/package phase."
    ),
    "Final submission package",
    "Pending clean/marked manuscript production.",
    "PACKAGE_STAGE_PENDING",
)

add_row(
    "Academic editor / journal",
    "J2",
    (
        "Provide a dedicated generative-AI disclosure naming the tool, "
        "describing use, validation of outputs, and affected study/article materials."
    ),
    (
        "Expanded the generative-AI disclosure to identify ChatGPT/OpenAI, "
        "describe editorial/workflow/code-assistance uses, state that AI output "
        "was not treated as scientific evidence, describe validation procedures, "
        "and state author responsibility."
    ),
    "Declaration of generative AI and AI-assisted technologies",
    (
        "v2.2 manuscript; "
        "scripts/python/58_reconcile_reviewer_editor_manuscript_v2.py"
    ),
)

add_row(
    "Academic editor / journal",
    "J3",
    "Make author-generated code publicly available without restriction.",
    (
        "Published the revision-round scripts, decision logs, quality gates, "
        "source-data tables, figures and supplementary outputs on the public "
        "GitHub revision branch."
    ),
    "Code availability",
    (
        "Public branch: "
        "plosone_revision_round1_2026; "
        "verified remote commit 93ee78bd48f090d67a8fed40c279ce2542066e23."
    ),
)

add_row(
    "Academic editor / journal",
    "J4",
    "Provide direct links to each database in the Data Availability Statement.",
    (
        "Added direct NCBI GEO URLs for GSE211567, GSE73461 and GSE72810."
    ),
    "Data availability",
    "Direct GEO links are present in v2.2.",
)


# ---------------------------------------------------------------------------
# Reviewer 1
# ---------------------------------------------------------------------------

add_row(
    "Reviewer 1",
    "R1.1",
    (
        "The conclusions relied on one external validation dataset; include "
        "additional datasets or discuss/soften this limitation."
    ),
    (
        "Added GSE72810 as a second accession-level and sample-level cohort "
        "measured on a different Illumina platform. Claims were simultaneously "
        "bounded because GSE72810 and GSE73461 arose from the same broad "
        "investigator network and direct participant overlap could not be assessed."
    ),
    (
        "Methods: GSE72810 cross-platform validation; "
        "Results: GSE72810 provides accession-level and cross-platform validation; "
        "Discussion: limitations"
    ),
    (
        "Scripts 44-50; Figure 3; Table 2; Supplementary Tables S6-S9."
    ),
)

add_row(
    "Reviewer 1",
    "R1.2",
    (
        "Provide more detail on criteria used during manual GO review/module "
        "definition and clarify whether the modules are optimal or most informative."
    ),
    (
        "Expanded the module-definition description to explain cross-site "
        "directional prioritisation, redundancy grouping and documented biological "
        "curation. Explicitly stated that module construction was biologically "
        "guided rather than mathematically optimized for prediction or separation."
    ),
    "Methods: GSE211567 discovery and module definition",
    (
        "v2.2 Methods; revision reproducibility/decision logs; "
        "module definitions remain unchanged."
    ),
)

add_row(
    "Reviewer 1",
    "R1.3",
    "Compare the proposed scoring strategy with GSVA.",
    (
        "Added GSVA sensitivity analysis using the unchanged module gene sets. "
        "The analysis showed strong support for BACT_M2, VIR_M1a and VIR_M1b, "
        "additional support for BACT_M1, and scoring-method sensitivity for VIR_M2."
    ),
    (
        "Methods: Sensitivity and robustness analyses; "
        "Results: Sensitivity analyses; Discussion"
    ),
    (
        "Scripts 41-42; Figure S1B; Supplementary Table S10."
    ),
)

add_row(
    "Reviewer 1",
    "R1.4",
    "Report effect sizes and confidence intervals in addition to medians and adjusted P values.",
    (
        "Added Hodges-Lehmann location shifts, rank-biserial effects and "
        "bootstrap 95% confidence intervals for the external-cohort analyses."
    ),
    (
        "Methods: Module scoring and statistical analysis; "
        "Results; Figure 3; Table 2"
    ),
    (
        "Scripts 40 and 48; cross-cohort Figure 3; Table 2; "
        "Supplementary Tables S8-S9."
    ),
)


# ---------------------------------------------------------------------------
# Reviewer 2
# ---------------------------------------------------------------------------

add_row(
    "Reviewer 2",
    "R2.1",
    (
        "Evaluate how loss of specific genes affects module discrimination, "
        "for example leave-one-out and leave-two-out analyses."
    ),
    (
        "Performed exhaustive leave-one-gene and leave-two-gene deletion analyses "
        "for every module in both GSE73461 scoring populations."
    ),
    (
        "Methods: Sensitivity and robustness analyses; "
        "Results: Exhaustive deletion analysis"
    ),
    (
        "29,826 variants evaluated; all retained expected direction; "
        "minimum Pearson correlation 0.9940. "
        "Script 43; Figure S1C; Supplementary Table S10."
    ),
)

add_row(
    "Reviewer 2",
    "R2.2",
    "Describe the nature and sample composition of the analyzed datasets in substantially greater detail.",
    (
        "Expanded the dataset descriptions. GSE211567 now states whole-blood "
        "samples from Sri Lanka and the United States and the 224-sample discovery "
        "set (101 bacterial, 123 viral). GSE73461 and GSE72810 now state relevant "
        "platforms, scoring-reference populations and inferential contrasts."
    ),
    (
        "Methods: Study design and datasets; GSE211567; GSE73461; GSE72810"
    ),
    "v2.2 Methods and supplementary cohort-audit tables.",
)

add_row(
    "Reviewer 2",
    "R2.3",
    (
        "Explain the logic and consequences of control-sample inclusion/exclusion "
        "in the z-score reference population."
    ),
    (
        "Clarified that GSE73461 Controls contribute to the main z-score reference "
        "population but not to the bacterial-versus-viral inferential contrast. "
        "Primary-only z-score sensitivity was retained to quantify dependence on "
        "the reference-population choice. GSE72810 uses all 146 samples as the "
        "main z-score reference while restricting inference to the definite "
        "bacterial and definite viral groups."
    ),
    (
        "Methods: GSE73461 formal external projection; GSE72810; "
        "Sensitivity and robustness analyses"
    ),
    "Primary-only sensitivity analyses; Figure 2; Figure S1; Supplementary Tables.",
)

add_row(
    "Reviewer 2",
    "R2.4",
    "Rewrite figure captions so they explain the finding, analysis and figure elements.",
    (
        "Expanded the legends for Figures 1-3 and Figure S1 to describe the "
        "analysis, direction conventions, symbols/statistics and principal findings."
    ),
    "Figure captions",
    "v2.2 figure captions.",
)

add_row(
    "Reviewer 2",
    "R2.5",
    "Provide the formal definition of concordance used in Figure 1B.",
    (
        "Defined directional concordance as agreement in the sign of the "
        "bacterial-versus-viral log2 fold change; percentage concordance is the "
        "number of same-sign features divided by the number compared and multiplied "
        "by 100. Spearman log2-fold-change correlations are reported separately."
    ),
    (
        "Methods: GSE211567 discovery and module definition; Figure 1B caption"
    ),
    "Implemented in Script 14 and described explicitly in v2.2.",
)

add_row(
    "Reviewer 2",
    "R2.6",
    "Define the module score and explain what the mean z-score represents.",
    (
        "Added the explicit gene-wise z-score equation and module-score equation. "
        "Each available mapped gene contributes equally to the unweighted arithmetic "
        "mean of its gene-wise z score."
    ),
    "Methods: Module scoring and statistical analysis",
    (
        "z_gi = (x_gi - mean_g) / SD_g; "
        "score_i = (1/K) sum_g z_gi."
    ),
)

add_row(
    "Reviewer 2",
    "R2.7",
    (
        "Clarify Figure 2C and remove inappropriate lines connecting categorical "
        "module values."
    ),
    (
        "Rebuilt Figure 2C as independent categorical points. Circles represent "
        "the main projection and triangles the primary-only z-score sensitivity; "
        "no line connects modules. The dashed horizontal line denotes "
        "BH-adjusted P = 0.05."
    ),
    "Figure 2C and its revised caption",
    (
        "Script 57; 13/13 Figure 2C QA checks passed; PNG and editable SVG "
        "committed on the public revision branch."
    ),
)

add_row(
    "Reviewer 2",
    "R2.statistics",
    "Improve description of statistical analyses.",
    (
        "Expanded the Methods to state Wilcoxon rank-sum testing, BH correction "
        "across five modules, effect-size direction conventions, Hodges-Lehmann "
        "shifts, rank-biserial effects, 10,000-replicate bootstrap confidence "
        "intervals, correlation metrics and sensitivity-analysis interpretation."
    ),
    "Methods: Module scoring and statistical analysis; Sensitivity and robustness analyses",
    "v2.2 Methods and supplementary statistical outputs.",
)

add_row(
    "Reviewer 2",
    "R2.clarity",
    (
        "Use simpler English; define transportability and fixed-module projection "
        "and reduce jargon such as site-aware, safeguards, firewall and frozen."
    ),
    (
        "Revised the title, Abstract, Introduction, Methods, Results, Discussion "
        "and figure captions for simpler wording. Transportability and fixed-module "
        "projection are explicitly defined at first use, and the cited jargon was "
        "removed from manuscript-facing text."
    ),
    "Title; Abstract; Introduction; throughout manuscript",
    (
        "Scripts 58-59; v2.1/v2.2 language QA."
    ),
)


# ---------------------------------------------------------------------------
# QA
# ---------------------------------------------------------------------------

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
    "Authoritative v2.2 manuscript SHA matched",
    observed_sha == EXPECTED_MANUSCRIPT_SHA,
    observed_sha,
    EXPECTED_MANUSCRIPT_SHA,
)

add_check(
    "All required manuscript anchors are present",
    len(missing_anchors) == 0,
    len(missing_anchors),
    0,
)

add_check(
    "Four journal/editor requirements are represented",
    sum(row["source"] == "Academic editor / journal" for row in rows) == 4,
    sum(row["source"] == "Academic editor / journal" for row in rows),
    4,
)

add_check(
    "Four Reviewer 1 requests are represented",
    sum(row["source"] == "Reviewer 1" for row in rows) == 4,
    sum(row["source"] == "Reviewer 1" for row in rows),
    4,
)

add_check(
    "Nine Reviewer 2 response items are represented",
    sum(row["source"] == "Reviewer 2" for row in rows) == 9,
    sum(row["source"] == "Reviewer 2" for row in rows),
    9,
)

add_check(
    "Only final formatting requirement remains package-stage pending",
    sum(row["status"] == "PACKAGE_STAGE_PENDING" for row in rows) == 1,
    sum(row["status"] == "PACKAGE_STAGE_PENDING" for row in rows),
    1,
)

add_check(
    "All scientific reviewer items are addressed",
    all(
        row["status"] == "ADDRESSED"
        for row in rows
        if row["source"] in {"Reviewer 1", "Reviewer 2"}
    ),
    "all addressed",
    "all addressed",
)

add_check(
    "Figure 2C correction is documented",
    any(
        row["item"] == "R2.7"
        and "no line connects modules" in row["revision_action"]
        for row in rows
    ),
    "documented",
    "documented",
)

add_check(
    "Deletion robustness is documented",
    any(
        row["item"] == "R2.1"
        and "29,826" in row["supporting_evidence"]
        for row in rows
    ),
    "documented",
    "documented",
)

add_check(
    "Second external cohort is documented",
    any(
        row["item"] == "R1.1"
        and "GSE72810" in row["revision_action"]
        for row in rows
    ),
    "documented",
    "documented",
)

add_check(
    "GSVA is documented",
    any(
        row["item"] == "R1.3"
        and "GSVA" in row["revision_action"]
        for row in rows
    ),
    "documented",
    "documented",
)

add_check(
    "Effect sizes and confidence intervals are documented",
    any(
        row["item"] == "R1.4"
        and "confidence intervals" in row["revision_action"]
        for row in rows
    ),
    "documented",
    "documented",
)

quality_passed = sum(
    row["pass"] == "TRUE"
    for row in checks
)

quality_failed = len(checks) - quality_passed

quality_gate = "PASS" if quality_failed == 0 else "FAIL"

final_status = (
    "READY_FOR_CLEAN_AND_MARKED_MANUSCRIPT_PACKAGE"
    if quality_failed == 0
    else "RESPONSE_MATRIX_REQUIRES_REVIEW"
)


# ---------------------------------------------------------------------------
# Write outputs
# ---------------------------------------------------------------------------

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)

write_tsv(
    MATRIX,
    rows,
)

write_tsv(
    QUALITY_GATE,
    checks,
)

write_tsv(
    SUMMARY,
    [
        {
            "response_items": len(rows),
            "editor_items": sum(
                row["source"] == "Academic editor / journal"
                for row in rows
            ),
            "reviewer1_items": sum(
                row["source"] == "Reviewer 1"
                for row in rows
            ),
            "reviewer2_items": sum(
                row["source"] == "Reviewer 2"
                for row in rows
            ),
            "quality_checks": len(checks),
            "quality_checks_passed": quality_passed,
            "quality_checks_failed": quality_failed,
            "manuscript_sha256": observed_sha,
            "verified_public_commit": EXPECTED_HEAD,
            "quality_gate": quality_gate,
            "final_status": final_status,
        }
    ],
)


report_lines = [
    "# PLOS ONE Revision Response Evidence Matrix",
    "",
    "Manuscript: PONE-D-26-30583",
    "",
    f"Authoritative manuscript: `{MANUSCRIPT}`",
    "",
    f"Manuscript SHA256: `{observed_sha}`",
    "",
    f"Verified public revision commit: `{EXPECTED_HEAD}`",
    "",
    "## Purpose",
    "",
    (
        "This document maps every academic-editor/journal requirement and "
        "reviewer request to the corresponding revision action, manuscript "
        "location and supporting evidence."
    ),
    "",
    (
        "It is an audit document rather than the final response letter. "
        "Final page and line references will be inserted after production "
        "of the clean and marked-up submission manuscripts."
    ),
    "",
    "## Status",
    "",
    f"- Response items: {len(rows)}",
    f"- Quality checks passed: {quality_passed}/{len(checks)}",
    f"- Quality gate: `{quality_gate}`",
    f"- Final status: `{final_status}`",
    "",
    "## Remaining package-stage item",
    "",
    (
        "PLOS-specific document formatting/file naming and production of "
        "the clean manuscript, marked-up manuscript and final point-by-point "
        "response remain to be completed."
    ),
    "",
]

REPORT.write_text(
    "\n".join(report_lines),
    encoding="utf-8",
    newline="\n",
)


print("===== PLOS ONE REVIEWER RESPONSE MATRIX =====")
print(f"response_items\t{len(rows)}")
print(
    "editor_items\t"
    f"{sum(row['source'] == 'Academic editor / journal' for row in rows)}"
)
print(
    "reviewer1_items\t"
    f"{sum(row['source'] == 'Reviewer 1' for row in rows)}"
)
print(
    "reviewer2_items\t"
    f"{sum(row['source'] == 'Reviewer 2' for row in rows)}"
)
print(f"quality_checks_passed\t{quality_passed}/{len(checks)}")
print(f"quality_gate\t{quality_gate}")
print(f"final_status\t{final_status}")
print(f"matrix\t{MATRIX}")
print(f"quality_gate_file\t{QUALITY_GATE}")
print(f"summary\t{SUMMARY}")
print(f"report\t{REPORT}")

if quality_failed:
    fail(
        f"Response matrix failed {quality_failed} quality check(s)."
    )
