#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
from collections import Counter
from pathlib import Path


INPUT = Path(
    "docs/complete_manuscript_draft_v2.3_submission_candidate_metadata_restored.md"
)

EXPECTED_INPUT_SHA = (
    "f3b61e6ddb9f5d38c6211c6cfe0d8694e6ca3b761d52a3245d58df844ab5b2ae"
)

OUTPUT = Path(
    "docs/complete_manuscript_draft_v2.4_submission_candidate_ai_methods_compliance.md"
)

HEADING_TEXT = (
    "Declaration of generative AI and AI-assisted technologies in the manuscript preparation process"
)

OLD_HEADING = f"# {HEADING_TEXT}"
NEW_HEADING = f"## {HEADING_TEXT}"
RESULTS_HEADING = "# Results"

DECLARATION = (
    "During preparation and revision of this manuscript, the author used ChatGPT, an AI-assisted tool provided by OpenAI, "
    "to assist with editorial organisation, language refinement, workflow planning, code drafting and checking, formatting "
    "checks, and preparation of manuscript and submission-support materials. AI-generated suggestions were not treated as "
    "scientific evidence. Analysis scripts were executed against the stated public datasets, and numerical and graphical "
    "outputs were checked using the documented reproducibility, source-lock and quality-control procedures. The author "
    "reviewed and verified the analysis code, results, references, biological interpretation, figures, tables, manuscript "
    "text and submission materials and takes full responsibility for the final work."
)

WORK = Path(
    "work/plosone_revision_round1_2026/"
    "phaseR1E15A_ai_methods_location_compliance"
)

OUTDIR = Path(
    "results/revision_round1/"
    "plosone_ai_methods_location_compliance_v2.4"
)

SUMMARY = (
    OUTDIR
    / "PLOS_ONE_ai_methods_location_summary.tsv"
)

QUALITY = (
    OUTDIR
    / "PLOS_ONE_ai_methods_location_quality_gate.tsv"
)

REPORT = Path(
    "docs/revision_round1/"
    "PLOS_ONE_ai_methods_location_compliance_report.md"
)


def sha256(path: Path) -> str:

    digest = hashlib.sha256()

    with path.open("rb") as handle:

        for chunk in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def write_tsv(
    path: Path,
    rows: list[dict[str, object]],
) -> None:

    if not rows:
        raise RuntimeError(
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


def normalise_declaration_candidate(
    value: str,
) -> str:

    value = value.strip()

    if value.startswith("\\:"):
        value = value[2:]

    if value.startswith(":"):
        value = value[1:]

    return value.strip()


def canonical_counter(
    lines: list[str],
) -> Counter[str]:

    items: list[str] = []

    for line in lines:

        stripped = line.strip()

        if not stripped:
            continue

        if stripped in {
            OLD_HEADING,
            NEW_HEADING,
        }:

            items.append(
                f"DECLARATION_HEADING::{HEADING_TEXT}"
            )

        else:

            items.append(
                stripped
            )

    return Counter(items)


def collapse_blank_lines(
    lines: list[str],
) -> list[str]:

    output: list[str] = []
    previous_blank = False

    for line in lines:

        is_blank = (
            not line.strip()
        )

        if (
            is_blank
            and previous_blank
        ):
            continue

        output.append(
            ""
            if is_blank
            else line.rstrip()
        )

        previous_blank = (
            is_blank
        )

    while (
        output
        and not output[-1].strip()
    ):
        output.pop()

    return output


WORK.mkdir(
    parents=True,
    exist_ok=True,
)

OUTDIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)


if not INPUT.exists():

    raise RuntimeError(
        f"Missing input source: {INPUT}"
    )


input_sha = sha256(
    INPUT
)


if input_sha != EXPECTED_INPUT_SHA:

    raise RuntimeError(
        "Input source SHA mismatch: "
        f"observed={input_sha} "
        f"expected={EXPECTED_INPUT_SHA}"
    )


raw = INPUT.read_text(
    encoding="utf-8"
)

lines = raw.splitlines()


old_heading_indices = [
    index
    for index, line
    in enumerate(lines)
    if line.strip() == OLD_HEADING
]

results_indices = [
    index
    for index, line
    in enumerate(lines)
    if line.strip() == RESULTS_HEADING
]


if len(old_heading_indices) != 1:

    raise RuntimeError(
        "Expected exactly one old AI heading; "
        f"found {len(old_heading_indices)}"
    )


if len(results_indices) != 1:

    raise RuntimeError(
        "Expected exactly one Results heading; "
        f"found {len(results_indices)}"
    )


heading_index = (
    old_heading_indices[0]
)

paragraph_index = (
    heading_index + 1
)


while (
    paragraph_index < len(lines)
    and not lines[
        paragraph_index
    ].strip()
):

    paragraph_index += 1


if paragraph_index >= len(lines):

    raise RuntimeError(
        "AI declaration paragraph not found after heading"
    )


observed_declaration = (
    normalise_declaration_candidate(
        lines[
            paragraph_index
        ]
    )
)


if observed_declaration != DECLARATION:

    raise RuntimeError(
        "AI declaration text differs from "
        "the locked wording.\n"
        f"Observed: {observed_declaration}\n"
        f"Expected: {DECLARATION}"
    )


# Remove only the existing declaration heading
# and declaration paragraph.

remove_indices = {
    heading_index,
    paragraph_index,
}

remaining = [
    line
    for index, line
    in enumerate(lines)
    if index not in remove_indices
]

remaining = collapse_blank_lines(
    remaining
)


results_indices_after = [
    index
    for index, line
    in enumerate(remaining)
    if line.strip()
    == RESULTS_HEADING
]


if len(results_indices_after) != 1:

    raise RuntimeError(
        "Results heading became ambiguous "
        "after declaration removal"
    )


insert_at = (
    results_indices_after[0]
)


block = [
    NEW_HEADING,
    "",
    DECLARATION,
    "",
]


output_lines = (
    remaining[:insert_at]
    + block
    + remaining[insert_at:]
)

output_lines = collapse_blank_lines(
    output_lines
)


output_text = (
    "\n".join(
        output_lines
    )
    + "\n"
)


# This proves that relocation and heading level
# are the only changes to the nonblank line inventory.

if (
    canonical_counter(lines)
    != canonical_counter(
        output_lines
    )
):

    raise RuntimeError(
        "Canonical nonblank-line inventory "
        "changed beyond the intended "
        "relocation/heading-level change"
    )


OUTPUT.write_text(
    output_text,
    encoding="utf-8",
    newline="\n",
)


output_sha = sha256(
    OUTPUT
)

input_sha_after = sha256(
    INPUT
)


out_lines = OUTPUT.read_text(
    encoding="utf-8"
).splitlines()


new_heading_indices = [
    index
    for index, line
    in enumerate(out_lines)
    if line.strip()
    == NEW_HEADING
]

old_heading_indices_out = [
    index
    for index, line
    in enumerate(out_lines)
    if line.strip()
    == OLD_HEADING
]

results_indices_out = [
    index
    for index, line
    in enumerate(out_lines)
    if line.strip()
    == RESULTS_HEADING
]

declaration_indices_out = [
    index
    for index, line
    in enumerate(out_lines)
    if normalise_declaration_candidate(
        line
    )
    == DECLARATION
]


checks: list[
    dict[str, object]
] = []


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
    "Input v2.3 source SHA locked",
    input_sha
    == EXPECTED_INPUT_SHA,
    input_sha,
    EXPECTED_INPUT_SHA,
)

check(
    "Original v2.3 source remains immutable",
    input_sha_after
    == EXPECTED_INPUT_SHA,
    input_sha_after,
    EXPECTED_INPUT_SHA,
)

check(
    "Exactly one Methods-level AI declaration heading",
    len(
        new_heading_indices
    ) == 1,
    len(
        new_heading_indices
    ),
    1,
)

check(
    "No level-1 AI declaration heading remains",
    len(
        old_heading_indices_out
    ) == 0,
    len(
        old_heading_indices_out
    ),
    0,
)

check(
    "Exactly one AI declaration paragraph remains",
    len(
        declaration_indices_out
    ) == 1,
    len(
        declaration_indices_out
    ),
    1,
)

check(
    "Exactly one Results heading remains",
    len(
        results_indices_out
    ) == 1,
    len(
        results_indices_out
    ),
    1,
)


if (
    new_heading_indices
    and declaration_indices_out
    and results_indices_out
):

    new_heading_index = (
        new_heading_indices[0]
    )

    declaration_index = (
        declaration_indices_out[0]
    )

    results_index = (
        results_indices_out[0]
    )

    check(
        "AI declaration is located before Results",
        (
            new_heading_index
            < declaration_index
            < results_index
        ),
        (
            f"heading={new_heading_index + 1}; "
            f"declaration={declaration_index + 1}; "
            f"results={results_index + 1}"
        ),
        "heading < declaration < results",
    )

    check(
        "AI declaration immediately precedes Results as final Methods subsection",
        (
            results_index
            - declaration_index
            <= 2
        ),
        (
            f"declaration_line={declaration_index + 1}; "
            f"results_line={results_index + 1}"
        ),
        "only blank line between declaration and Results",
    )

else:

    check(
        "AI declaration is located before Results",
        False,
        "indices unavailable",
        "heading < declaration < results",
    )

    check(
        "AI declaration immediately precedes Results as final Methods subsection",
        False,
        "indices unavailable",
        "only blank line between declaration and Results",
    )


check(
    "Canonical manuscript line inventory unchanged except heading level and relocation",
    (
        canonical_counter(lines)
        == canonical_counter(
            out_lines
        )
    ),
    (
        "identical"
        if canonical_counter(lines)
        == canonical_counter(
            out_lines
        )
        else "different"
    ),
    "identical",
)

check(
    "Output source differs from v2.3 source",
    output_sha
    != input_sha,
    output_sha,
    "different SHA",
)


passed = sum(
    row[
        "pass"
    ] == "TRUE"
    for row in checks
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
    "READY_FOR_CLEAN_AND_MARKED_MANUSCRIPT_AI_LOCATION_SYNC"
    if failed == 0
    else "AI_METHODS_LOCATION_REQUIRES_CORRECTION"
)


write_tsv(
    QUALITY,
    checks,
)


write_tsv(
    SUMMARY,
    [
        {
            "input_source_sha256": (
                input_sha
            ),
            "output_source_sha256": (
                output_sha
            ),
            "input_source": (
                str(INPUT)
            ),
            "output_source": (
                str(OUTPUT)
            ),
            "quality_checks": (
                len(checks)
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
            "# PLOS ONE AI Declaration Methods-Location Compliance",
            "",
            "Manuscript: PONE-D-26-30583",
            "",
            (
                f"- Locked input v2.3 SHA256: "
                f"`{input_sha}`"
            ),
            (
                f"- New v2.4 source SHA256: "
                f"`{output_sha}`"
            ),
            (
                "- The AI declaration wording "
                "was preserved exactly."
            ),
            (
                "- The declaration was moved from "
                "the end matter to the final Methods "
                "subsection immediately before Results."
            ),
            (
                "- The declaration heading was changed "
                "from level 1 to level 2 so it sits "
                "within Methods."
            ),
            (
                "- No other nonblank manuscript "
                "line content changed."
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


print(
    "===== PLOS ONE AI METHODS-LOCATION COMPLIANCE ====="
)

print(
    f"input_source_sha256\t"
    f"{input_sha}"
)

print(
    f"output_source_sha256\t"
    f"{output_sha}"
)

print(
    f"quality_checks_passed\t"
    f"{passed}/{len(checks)}"
)

print(
    f"quality_gate\t"
    f"{quality_gate}"
)

print(
    f"final_status\t"
    f"{final_status}"
)

print(
    f"output_source\t"
    f"{OUTPUT}"
)

print(
    f"summary\t"
    f"{SUMMARY}"
)

print(
    f"quality_gate_file\t"
    f"{QUALITY}"
)

print(
    f"report\t"
    f"{REPORT}"
)


if failed:

    raise RuntimeError(
        "AI Methods-location compliance failed "
        f"{failed} quality check(s)."
    )
