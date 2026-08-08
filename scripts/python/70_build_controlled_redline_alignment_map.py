#!/usr/bin/env python3

from __future__ import annotations

import csv
import hashlib
import re
import sys
from difflib import SequenceMatcher
from pathlib import Path

from docx import Document


# ============================================================================
# Locked inputs
# ============================================================================

CLEAN_DOCX = Path(
    "submission/revision_round1/"
    "PONE-D-26-30583_clean_revised_manuscript.docx"
)

EXPECTED_CLEAN_SHA = (
    "691f494f5f2335b1a96f5b8d009c815"
    "d733b3c74fab0f230eaa3f73274f6b38f"
)

BASELINE_DOCX = Path(
    "work/plosone_revision_round1_2026/"
    "phaseR1E14B_submitted_baseline_reconstruction/"
    "PONE-D-26-30583_reconstructed_submitted_baseline.docx"
)

EXPECTED_BASELINE_SHA = (
    "0e0b4a2bcec736d2735ecc903ad72e99"
    "a1a3897bc09e2f991a7249000852dd34"
)

SOURCE_MD = Path(
    "docs/"
    "complete_manuscript_draft_v2.3_"
    "submission_candidate_metadata_restored.md"
)

EXPECTED_SOURCE_SHA = (
    "f3b61e6ddb9f5d38c6211c6cfe0d869"
    "4e6ca3b761d52a3245d58df844ab5b2ae"
)

BASELINE_PARAGRAPH_TSV = Path(
    "work/plosone_revision_round1_2026/"
    "phaseR1E14B_submitted_baseline_reconstruction/"
    "PONE-D-26-30583_submitted_baseline_paragraphs.tsv"
)

EXPECTED_SUBMITTED_TITLE = (
    "Cross-cohort transportability of bacterial- and "
    "viral-associated host-response modules in public "
    "infection transcriptomic datasets"
)

EXPECTED_CLEAN_TITLE = (
    "External transportability of bacterial- and "
    "viral-associated host-response modules across "
    "public transcriptomic cohorts"
)

EXPECTED_SUBMITTED_SHORT_TITLE = (
    "Transportability of infection host-response modules"
)

EXPECTED_CLEAN_SHORT_TITLE = (
    "Transportable infection modules"
)


# ============================================================================
# Outputs
# ============================================================================

WORK = Path(
    "work/plosone_revision_round1_2026/"
    "phaseR1E14C_controlled_redline_alignment"
)

OUT = Path(
    "results/revision_round1/"
    "plosone_controlled_redline_alignment_v2.3"
)

CLEAN_ALIGNMENT = (
    OUT
    / "PLOS_ONE_clean_to_submitted_paragraph_alignment.tsv"
)

BASELINE_ALIGNMENT = (
    OUT
    / "PLOS_ONE_submitted_to_clean_paragraph_alignment.tsv"
)

TARGET_INVENTORY = (
    OUT
    / "PLOS_ONE_reviewer_driven_redline_target_inventory.tsv"
)

QUALITY_GATE = (
    OUT
    / "PLOS_ONE_controlled_redline_alignment_quality_gate.tsv"
)

SUMMARY = (
    OUT
    / "PLOS_ONE_controlled_redline_alignment_summary.tsv"
)

REPORT = Path(
    "docs/revision_round1/"
    "PLOS_ONE_controlled_redline_alignment_report.md"
)


# ============================================================================
# Utilities
# ============================================================================

def die(message: str) -> None:

    print(
        f"ERROR: {message}",
        file=sys.stderr,
    )

    raise SystemExit(1)


def sha256(path: Path) -> str:

    digest = hashlib.sha256()

    with path.open("rb") as handle:

        for chunk in iter(
            lambda: handle.read(
                1024 * 1024
            ),
            b"",
        ):

            digest.update(chunk)

    return digest.hexdigest()


def write_tsv(
    path: Path,
    rows: list[dict[str, object]],
) -> None:

    if not rows:

        die(
            f"No rows available for {path}"
        )

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
            fieldnames=list(
                rows[0].keys()
            ),
            delimiter="\t",
            lineterminator="\n",
        )

        writer.writeheader()
        writer.writerows(rows)


def normalize(
    value: str,
) -> str:

    value = value.replace(
        "\u00a0",
        " ",
    )

    value = value.replace(
        "–",
        "-",
    )

    value = value.replace(
        "—",
        "-",
    )

    value = value.replace(
        "−",
        "-",
    )

    value = re.sub(
        r"\s+",
        " ",
        value,
    ).strip()

    return value


def comparison_text(
    value: str,
) -> str:

    value = normalize(
        value
    ).lower()

    value = re.sub(
        r"[^\w\s.+\-/%]",
        " ",
        value,
    )

    return re.sub(
        r"\s+",
        " ",
        value,
    ).strip()


def tokens(
    value: str,
) -> list[str]:

    return re.findall(
        r"[a-z0-9_]+"
        r"(?:[-'][a-z0-9_]+)*"
        r"|[0-9.]+",
        comparison_text(
            value
        ),
    )


def excerpt(
    value: str,
    limit: int = 180,
) -> str:

    value = normalize(
        value
    )

    if len(value) <= limit:

        return value

    return (
        value[
            : limit - 3
        ]
        + "..."
    )


def paragraph_similarity(
    left: str,
    right: str,
) -> dict[str, float]:

    left_norm = comparison_text(
        left
    )

    right_norm = comparison_text(
        right
    )

    if (
        not left_norm
        or not right_norm
    ):

        return {
            "score": 0.0,
            "sequence_ratio": 0.0,
            "containment": 0.0,
            "jaccard": 0.0,
        }

    if left_norm == right_norm:

        return {
            "score": 1.0,
            "sequence_ratio": 1.0,
            "containment": 1.0,
            "jaccard": 1.0,
        }

    left_words = tokens(
        left
    )

    right_words = tokens(
        right
    )

    if (
        not left_words
        or not right_words
    ):

        return {
            "score": 0.0,
            "sequence_ratio": 0.0,
            "containment": 0.0,
            "jaccard": 0.0,
        }

    matcher = SequenceMatcher(
        None,
        left_words,
        right_words,
        autojunk=False,
    )

    sequence_ratio = matcher.ratio()

    longest = matcher.find_longest_match(
        0,
        len(left_words),
        0,
        len(right_words),
    ).size

    containment = (
        longest
        / min(
            len(left_words),
            len(right_words),
        )
    )

    left_set = set(
        left_words
    )

    right_set = set(
        right_words
    )

    union = (
        left_set
        | right_set
    )

    jaccard = (
        len(
            left_set
            & right_set
        )
        / len(union)
        if union
        else 0.0
    )

    substring_bonus = 0.0

    if (
        len(left_norm) >= 25
        and left_norm
        in right_norm
    ):

        substring_bonus = 0.97

    elif (
        len(right_norm) >= 25
        and right_norm
        in left_norm
    ):

        substring_bonus = 0.97

    containment_score = (
        0.82
        * containment
        + 0.18
        * jaccard
    )

    score = max(
        sequence_ratio,
        containment_score,
        substring_bonus,
    )

    return {
        "score": min(
            score,
            1.0,
        ),
        "sequence_ratio": (
            sequence_ratio
        ),
        "containment": (
            containment
        ),
        "jaccard": (
            jaccard
        ),
    }


def classify(
    source_text: str,
    target_text: str,
    metrics: dict[str, float],
) -> str:

    source_norm = comparison_text(
        source_text
    )

    target_norm = comparison_text(
        target_text
    )

    if (
        source_norm
        == target_norm
    ):

        return "EXACT_UNCHANGED"

    score = metrics[
        "score"
    ]

    containment = metrics[
        "containment"
    ]

    if (
        score >= 0.92
        or containment >= 0.94
    ):

        return "NEAR_UNCHANGED"

    if score >= 0.60:

        return "MODIFIED_CANDIDATE"

    return "REVISION_ADDITION_CANDIDATE"


def reverse_classify(
    source_text: str,
    target_text: str,
    metrics: dict[str, float],
) -> str:

    source_norm = comparison_text(
        source_text
    )

    target_norm = comparison_text(
        target_text
    )

    if (
        source_norm
        == target_norm
    ):

        return "EXACT_RETAINED"

    score = metrics[
        "score"
    ]

    containment = metrics[
        "containment"
    ]

    if (
        score >= 0.92
        or containment >= 0.94
    ):

        return "NEAR_RETAINED"

    if score >= 0.60:

        return "MODIFIED_OR_RELOCATED"

    return "BASELINE_DELETION_OR_REWRITE_CANDIDATE"


def paragraph_style_name(
    paragraph,
) -> str:

    if paragraph.style is None:

        return ""

    return paragraph.style.name


def read_docx_paragraphs(
    path: Path,
) -> list[dict[str, object]]:

    doc = Document(
        path
    )

    output = []

    for index, paragraph in enumerate(
        doc.paragraphs,
        start=1,
    ):

        text = normalize(
            paragraph.text
        )

        if not text:

            continue

        output.append(
            {
                "paragraph_index": index,
                "style": (
                    paragraph_style_name(
                        paragraph
                    )
                ),
                "text": text,
            }
        )

    return output


# ============================================================================
# Locked preflight
# ============================================================================

WORK.mkdir(
    parents=True,
    exist_ok=True,
)

OUT.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)


for required in [
    CLEAN_DOCX,
    BASELINE_DOCX,
    SOURCE_MD,
    BASELINE_PARAGRAPH_TSV,
]:

    if not required.exists():

        die(
            f"Required input missing: "
            f"{required}"
        )


clean_sha = sha256(
    CLEAN_DOCX
)

baseline_sha = sha256(
    BASELINE_DOCX
)

source_sha = sha256(
    SOURCE_MD
)


if clean_sha != EXPECTED_CLEAN_SHA:

    die(
        "Locked clean DOCX SHA mismatch."
    )


if baseline_sha != EXPECTED_BASELINE_SHA:

    die(
        "Reconstructed baseline DOCX SHA mismatch."
    )


if source_sha != EXPECTED_SOURCE_SHA:

    die(
        "Scientific source SHA mismatch."
    )


# ============================================================================
# Load paragraph inventories
# ============================================================================

clean_paragraphs = read_docx_paragraphs(
    CLEAN_DOCX
)

baseline_paragraphs = read_docx_paragraphs(
    BASELINE_DOCX
)


if not clean_paragraphs:

    die(
        "No clean manuscript paragraphs."
    )


if not baseline_paragraphs:

    die(
        "No submitted baseline paragraphs."
    )


clean_full_text = "\n".join(
    row[
        "text"
    ]
    for row
    in clean_paragraphs
)


baseline_full_text = "\n".join(
    row[
        "text"
    ]
    for row
    in baseline_paragraphs
)


# ============================================================================
# Clean -> submitted alignment
# ============================================================================

clean_alignment_rows = []


for clean_row in clean_paragraphs:

    best_baseline = None
    best_metrics = None

    for baseline_row in baseline_paragraphs:

        metrics = paragraph_similarity(
            str(
                clean_row[
                    "text"
                ]
            ),
            str(
                baseline_row[
                    "text"
                ]
            ),
        )

        if (
            best_metrics is None
            or metrics[
                "score"
            ]
            > best_metrics[
                "score"
            ]
        ):

            best_baseline = baseline_row
            best_metrics = metrics

    assert best_baseline is not None
    assert best_metrics is not None

    classification = classify(
        str(
            clean_row[
                "text"
            ]
        ),
        str(
            best_baseline[
                "text"
            ]
        ),
        best_metrics,
    )

    clean_alignment_rows.append(
        {
            "clean_paragraph_index": (
                clean_row[
                    "paragraph_index"
                ]
            ),
            "clean_style": (
                clean_row[
                    "style"
                ]
            ),
            "classification": (
                classification
            ),
            "best_submitted_paragraph_index": (
                best_baseline[
                    "paragraph_index"
                ]
            ),
            "similarity_score": (
                f"{best_metrics['score']:.6f}"
            ),
            "sequence_ratio": (
                f"{best_metrics['sequence_ratio']:.6f}"
            ),
            "containment": (
                f"{best_metrics['containment']:.6f}"
            ),
            "jaccard": (
                f"{best_metrics['jaccard']:.6f}"
            ),
            "clean_excerpt": (
                excerpt(
                    str(
                        clean_row[
                            "text"
                        ]
                    )
                )
            ),
            "submitted_excerpt": (
                excerpt(
                    str(
                        best_baseline[
                            "text"
                        ]
                    )
                )
            ),
        }
    )


write_tsv(
    CLEAN_ALIGNMENT,
    clean_alignment_rows,
)


# ============================================================================
# Submitted -> clean alignment
# ============================================================================

baseline_alignment_rows = []


for baseline_row in baseline_paragraphs:

    best_clean = None
    best_metrics = None

    for clean_row in clean_paragraphs:

        metrics = paragraph_similarity(
            str(
                baseline_row[
                    "text"
                ]
            ),
            str(
                clean_row[
                    "text"
                ]
            ),
        )

        if (
            best_metrics is None
            or metrics[
                "score"
            ]
            > best_metrics[
                "score"
            ]
        ):

            best_clean = clean_row
            best_metrics = metrics

    assert best_clean is not None
    assert best_metrics is not None

    classification = reverse_classify(
        str(
            baseline_row[
                "text"
            ]
        ),
        str(
            best_clean[
                "text"
            ]
        ),
        best_metrics,
    )

    baseline_alignment_rows.append(
        {
            "submitted_paragraph_index": (
                baseline_row[
                    "paragraph_index"
                ]
            ),
            "classification": (
                classification
            ),
            "best_clean_paragraph_index": (
                best_clean[
                    "paragraph_index"
                ]
            ),
            "clean_style": (
                best_clean[
                    "style"
                ]
            ),
            "similarity_score": (
                f"{best_metrics['score']:.6f}"
            ),
            "sequence_ratio": (
                f"{best_metrics['sequence_ratio']:.6f}"
            ),
            "containment": (
                f"{best_metrics['containment']:.6f}"
            ),
            "jaccard": (
                f"{best_metrics['jaccard']:.6f}"
            ),
            "submitted_excerpt": (
                excerpt(
                    str(
                        baseline_row[
                            "text"
                        ]
                    )
                )
            ),
            "clean_excerpt": (
                excerpt(
                    str(
                        best_clean[
                            "text"
                        ]
                    )
                )
            ),
        }
    )


write_tsv(
    BASELINE_ALIGNMENT,
    baseline_alignment_rows,
)


# ============================================================================
# Reviewer/editor-driven target map
# ============================================================================

TARGETS = [
    {
        "response_id": "EDITOR_AI",
        "topic": "AI disclosure",
        "patterns": [
            r"\bChatGPT\b",
            r"\bOpenAI\b",
            r"AI-assisted",
        ],
    },
    {
        "response_id": "EDITOR_CODE",
        "topic": "Public code availability",
        "patterns": [
            r"plosone_revision_round1_2026",
            r"host-response-module-transportability",
        ],
    },
    {
        "response_id": "RR05",
        "topic": "Second external cohort GSE72810",
        "patterns": [
            r"\bGSE72810\b",
            r"23 definite bacterial",
            r"28 definite viral",
            r"cross-platform validation",
        ],
    },
    {
        "response_id": "RR06",
        "topic": "Biological curation and GO rationale",
        "patterns": [
            r"Gene Ontology",
            r"biologically guided",
            r"reproducible curation",
            r"mathematical optimi[sz]ation",
            r"not uniquely optimal",
        ],
    },
    {
        "response_id": "RR07",
        "topic": "GSVA sensitivity analysis",
        "patterns": [
            r"\bGSVA\b",
            r"scoring-method-sensitive",
        ],
    },
    {
        "response_id": "RR08",
        "topic": "Effect sizes and confidence intervals",
        "patterns": [
            r"Hodges-Lehmann",
            r"confidence interval",
            r"95% CI",
        ],
    },
    {
        "response_id": "RR09",
        "topic": "Leave-one/two-gene robustness",
        "patterns": [
            r"leave-one/two-gene",
            r"29,826",
            r"deletion analysis",
            r"removal-sensitive",
        ],
    },
    {
        "response_id": "RR10",
        "topic": "Cohort/sample description",
        "patterns": [
            r"52 DefiniteBacterial",
            r"94 DefiniteViral",
            r"146 pediatric",
            r"sample-level cohort",
        ],
    },
    {
        "response_id": "RR11",
        "topic": "Control and z-reference logic",
        "patterns": [
            r"z-reference",
            r"reference population",
            r"Control samples",
            r"controls were",
        ],
    },
    {
        "response_id": "RR13",
        "topic": "Directional concordance definition",
        "patterns": [
            r"directional concordance",
            r"same-sign",
            r"percentage directional",
        ],
    },
    {
        "response_id": "RR14",
        "topic": "Module-score definition",
        "patterns": [
            r"unweighted arithmetic mean",
            r"unweighted mean",
            r"gene-wise z",
            r"score_i",
        ],
    },
    {
        "response_id": "RR15",
        "topic": "Figure 2C categorical-point revision",
        "patterns": [
            r"independent points",
            r"Circles denote",
            r"triangles denote",
            r"not connected",
        ],
    },
    {
        "response_id": "RR16",
        "topic": "Statistical methods clarification",
        "patterns": [
            r"Benjamini",
            r"Wilcoxon",
            r"rank-biserial",
            r"bootstrap",
        ],
    },
    {
        "response_id": "LIMITATION",
        "topic": "GSE72810/GSE73461 independence limitation",
        "patterns": [
            r"same broad investigator network",
            r"participant overlap could not be assessed",
            r"accession sets were disjoint",
        ],
    },
]


target_rows = []


for target in TARGETS:

    hit_indices = []

    hit_excerpts = []

    hit_classes = []

    for alignment_row in clean_alignment_rows:

        paragraph_index = int(
            alignment_row[
                "clean_paragraph_index"
            ]
        )

        text = next(
            row[
                "text"
            ]
            for row
            in clean_paragraphs
            if int(
                row[
                    "paragraph_index"
                ]
            )
            == paragraph_index
        )

        if any(
            re.search(
                pattern,
                str(text),
                flags=re.IGNORECASE,
            )
            for pattern
            in target[
                "patterns"
            ]
        ):

            hit_indices.append(
                str(
                    paragraph_index
                )
            )

            hit_excerpts.append(
                excerpt(
                    str(text),
                    120,
                )
            )

            hit_classes.append(
                str(
                    alignment_row[
                        "classification"
                    ]
                )
            )

    target_rows.append(
        {
            "response_id": (
                target[
                    "response_id"
                ]
            ),
            "topic": (
                target[
                    "topic"
                ]
            ),
            "clean_paragraph_hits": (
                ",".join(
                    hit_indices
                )
                or "NONE"
            ),
            "hit_count": len(
                hit_indices
            ),
            "alignment_classes": (
                "|".join(
                    hit_classes
                )
                or "NONE"
            ),
            "sample_excerpts": (
                " || ".join(
                    hit_excerpts[
                        :4
                    ]
                )
                or "NONE"
            ),
        }
    )


write_tsv(
    TARGET_INVENTORY,
    target_rows,
)


# ============================================================================
# Quality checks
# ============================================================================

checks = []


def check(
    description: str,
    passed: bool,
    observed: object,
    expected: object,
) -> None:

    checks.append(
        {
            "check_id": (
                f"Q{len(checks) + 1:02d}"
            ),
            "check_description": (
                description
            ),
            "pass": (
                "TRUE"
                if passed
                else "FALSE"
            ),
            "observed": str(
                observed
            ),
            "expected": str(
                expected
            ),
        }
    )


check(
    "Clean manuscript SHA locked",
    clean_sha
    == EXPECTED_CLEAN_SHA,
    clean_sha,
    EXPECTED_CLEAN_SHA,
)

check(
    "Submitted baseline SHA locked",
    baseline_sha
    == EXPECTED_BASELINE_SHA,
    baseline_sha,
    EXPECTED_BASELINE_SHA,
)

check(
    "Scientific source SHA locked",
    source_sha
    == EXPECTED_SOURCE_SHA,
    source_sha,
    EXPECTED_SOURCE_SHA,
)

check(
    "Submitted title present only in baseline authority",
    (
        EXPECTED_SUBMITTED_TITLE
        in baseline_full_text
    ),
    (
        "present"
        if EXPECTED_SUBMITTED_TITLE
        in baseline_full_text
        else "absent"
    ),
    "present",
)

check(
    "Revised title present in clean manuscript",
    (
        EXPECTED_CLEAN_TITLE
        in clean_full_text
    ),
    (
        "present"
        if EXPECTED_CLEAN_TITLE
        in clean_full_text
        else "absent"
    ),
    "present",
)

check(
    "Submitted short title recovered",
    (
        EXPECTED_SUBMITTED_SHORT_TITLE
        in baseline_full_text
    ),
    (
        "present"
        if EXPECTED_SUBMITTED_SHORT_TITLE
        in baseline_full_text
        else "absent"
    ),
    "present",
)

check(
    "Revised short title present",
    (
        EXPECTED_CLEAN_SHORT_TITLE
        in clean_full_text
    ),
    (
        "present"
        if EXPECTED_CLEAN_SHORT_TITLE
        in clean_full_text
        else "absent"
    ),
    "present",
)

check(
    "GSE72810 absent from submitted baseline",
    "GSE72810"
    not in baseline_full_text,
    baseline_full_text.count(
        "GSE72810"
    ),
    0,
)

check(
    "GSE72810 present in clean manuscript",
    "GSE72810"
    in clean_full_text,
    clean_full_text.count(
        "GSE72810"
    ),
    ">0",
)

check(
    "29,826 deletion-variant result absent from baseline",
    "29,826"
    not in baseline_full_text,
    baseline_full_text.count(
        "29,826"
    ),
    0,
)

check(
    "29,826 deletion-variant result present in clean manuscript",
    "29,826"
    in clean_full_text,
    clean_full_text.count(
        "29,826"
    ),
    ">0",
)

check(
    "Every clean paragraph received an alignment",
    len(
        clean_alignment_rows
    )
    == len(
        clean_paragraphs
    ),
    len(
        clean_alignment_rows
    ),
    len(
        clean_paragraphs
    ),
)

check(
    "Every submitted paragraph received a reverse alignment",
    len(
        baseline_alignment_rows
    )
    == len(
        baseline_paragraphs
    ),
    len(
        baseline_alignment_rows
    ),
    len(
        baseline_paragraphs
    ),
)

for response_id in [
    "EDITOR_AI",
    "EDITOR_CODE",
    "RR05",
    "RR06",
    "RR07",
    "RR08",
    "RR09",
    "RR11",
    "RR13",
    "RR14",
    "RR15",
    "RR16",
    "LIMITATION",
]:

    row = next(
        item
        for item
        in target_rows
        if item[
            "response_id"
        ]
        == response_id
    )

    check(
        (
            "Reviewer/editor redline target "
            f"{response_id} has clean-manuscript hits"
        ),
        int(
            row[
                "hit_count"
            ]
        ) > 0,
        row[
            "hit_count"
        ],
        ">0",
    )


# ============================================================================
# Summary
# ============================================================================

clean_class_counts = {}

for row in clean_alignment_rows:

    value = str(
        row[
            "classification"
        ]
    )

    clean_class_counts[
        value
    ] = (
        clean_class_counts.get(
            value,
            0,
        )
        + 1
    )


baseline_class_counts = {}

for row in baseline_alignment_rows:

    value = str(
        row[
            "classification"
        ]
    )

    baseline_class_counts[
        value
    ] = (
        baseline_class_counts.get(
            value,
            0,
        )
        + 1
    )


passed = sum(
    row[
        "pass"
    ] == "TRUE"
    for row
    in checks
)

failed = (
    len(checks)
    - passed
)

quality_gate = (
    "PASS"
    if failed == 0
    else "FAIL"
)

final_status = (
    "READY_FOR_TARGETED_OOXML_REDLINE_BUILD"
    if failed == 0
    else "CONTROLLED_REDLINE_ALIGNMENT_REQUIRES_REVIEW"
)


write_tsv(
    QUALITY_GATE,
    checks,
)


write_tsv(
    SUMMARY,
    [
        {
            "clean_docx_sha256": (
                clean_sha
            ),
            "baseline_docx_sha256": (
                baseline_sha
            ),
            "scientific_source_sha256": (
                source_sha
            ),
            "clean_paragraphs": len(
                clean_paragraphs
            ),
            "submitted_paragraphs": len(
                baseline_paragraphs
            ),
            "clean_exact_unchanged": (
                clean_class_counts.get(
                    "EXACT_UNCHANGED",
                    0,
                )
            ),
            "clean_near_unchanged": (
                clean_class_counts.get(
                    "NEAR_UNCHANGED",
                    0,
                )
            ),
            "clean_modified_candidates": (
                clean_class_counts.get(
                    "MODIFIED_CANDIDATE",
                    0,
                )
            ),
            "clean_revision_addition_candidates": (
                clean_class_counts.get(
                    "REVISION_ADDITION_CANDIDATE",
                    0,
                )
            ),
            "submitted_exact_retained": (
                baseline_class_counts.get(
                    "EXACT_RETAINED",
                    0,
                )
            ),
            "submitted_near_retained": (
                baseline_class_counts.get(
                    "NEAR_RETAINED",
                    0,
                )
            ),
            "submitted_modified_or_relocated": (
                baseline_class_counts.get(
                    "MODIFIED_OR_RELOCATED",
                    0,
                )
            ),
            "submitted_deletion_or_rewrite_candidates": (
                baseline_class_counts.get(
                    "BASELINE_DELETION_OR_REWRITE_CANDIDATE",
                    0,
                )
            ),
            "reviewer_target_categories": len(
                target_rows
            ),
            "quality_checks": len(
                checks
            ),
            "quality_checks_passed": (
                passed
            ),
            "quality_checks_failed": (
                failed
            ),
            "quality_gate": (
                quality_gate
            ),
            "final_status": (
                final_status
            ),
        }
    ],
)


REPORT.write_text(
    "\n".join(
        [
            "# PLOS ONE Controlled Redline Alignment",
            "",
            "Manuscript: PONE-D-26-30583",
            "",
            "## Locked sources",
            "",
            (
                f"- Clean DOCX SHA256: "
                f"`{clean_sha}`"
            ),
            (
                f"- Reconstructed submitted baseline "
                f"SHA256: `{baseline_sha}`"
            ),
            (
                f"- Scientific source SHA256: "
                f"`{source_sha}`"
            ),
            "",
            "## Rationale",
            "",
            (
                "The submitted and revised manuscripts have "
                "substantial section-order and paragraph-structure "
                "differences. A global sequential diff would therefore "
                "confound true revision edits with relocation and "
                "formatting changes."
            ),
            "",
            (
                "This phase aligns every clean paragraph to its "
                "best submitted-baseline paragraph independently "
                "of document order, and performs the reverse "
                "submitted-to-clean alignment."
            ),
            "",
            (
                "Reviewer/editor-driven anchors are separately "
                "mapped to clean-manuscript paragraph indices so "
                "the marked-up manuscript can emphasize actual "
                "revision-round changes rather than blanket document "
                "reformatting."
            ),
            "",
            "## Classification",
            "",
            (
                f"- Exact unchanged clean paragraphs: "
                f"{clean_class_counts.get('EXACT_UNCHANGED', 0)}"
            ),
            (
                f"- Near-unchanged clean paragraphs: "
                f"{clean_class_counts.get('NEAR_UNCHANGED', 0)}"
            ),
            (
                f"- Modified clean candidates: "
                f"{clean_class_counts.get('MODIFIED_CANDIDATE', 0)}"
            ),
            (
                f"- Revision-addition candidates: "
                f"{clean_class_counts.get('REVISION_ADDITION_CANDIDATE', 0)}"
            ),
            "",
            "## Quality gate",
            "",
            (
                f"- Checks passed: "
                f"{passed}/{len(checks)}"
            ),
            (
                f"- Quality gate: "
                f"`{quality_gate}`"
            ),
            (
                f"- Final status: "
                f"`{final_status}`"
            ),
            "",
        ]
    ),
    encoding="utf-8",
    newline="\n",
)


# ============================================================================
# Console
# ============================================================================

print(
    "===== PLOS ONE CONTROLLED REDLINE ALIGNMENT ====="
)

print(
    f"clean_docx_sha256\t{clean_sha}"
)

print(
    f"baseline_docx_sha256\t{baseline_sha}"
)

print(
    f"scientific_source_sha256\t{source_sha}"
)

print(
    f"clean_paragraphs\t{len(clean_paragraphs)}"
)

print(
    f"submitted_paragraphs\t{len(baseline_paragraphs)}"
)

print(
    "clean_exact_unchanged\t"
    f"{clean_class_counts.get('EXACT_UNCHANGED', 0)}"
)

print(
    "clean_near_unchanged\t"
    f"{clean_class_counts.get('NEAR_UNCHANGED', 0)}"
)

print(
    "clean_modified_candidates\t"
    f"{clean_class_counts.get('MODIFIED_CANDIDATE', 0)}"
)

print(
    "clean_revision_addition_candidates\t"
    f"{clean_class_counts.get('REVISION_ADDITION_CANDIDATE', 0)}"
)

print(
    "submitted_deletion_or_rewrite_candidates\t"
    f"{baseline_class_counts.get('BASELINE_DELETION_OR_REWRITE_CANDIDATE', 0)}"
)

print(
    f"reviewer_target_categories\t{len(target_rows)}"
)

print(
    f"quality_checks_passed\t{passed}/{len(checks)}"
)

print(
    f"quality_gate\t{quality_gate}"
)

print(
    f"final_status\t{final_status}"
)

print(
    f"clean_alignment\t{CLEAN_ALIGNMENT}"
)

print(
    f"baseline_alignment\t{BASELINE_ALIGNMENT}"
)

print(
    f"target_inventory\t{TARGET_INVENTORY}"
)

print(
    f"summary\t{SUMMARY}"
)

print(
    f"quality_gate_file\t{QUALITY_GATE}"
)

print(
    f"report\t{REPORT}"
)


if failed:

    die(
        "Controlled redline alignment failed "
        f"{failed} quality check(s)."
    )
