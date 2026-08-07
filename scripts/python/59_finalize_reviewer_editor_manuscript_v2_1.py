#!/usr/bin/env python3

"""
59_finalize_reviewer_editor_manuscript_v2_1.py

Purpose
-------
Create the final reviewer/editor language-polished manuscript v2.1 from the
quality-gated v2.0 manuscript.

This pass is intentionally narrow. It:

1. Removes the residual internal drafting note.
2. Simplifies remaining reviewer-facing "site-aware", "frozen", "locking",
   and unnecessary "fixed-module projection" terminology.
3. Improves the Abstract Objectives, Methods and Conclusions.
4. Simplifies selected Methods/Results headings and descriptions.
5. Refines Figure 1 and Figure 2 wording.
6. Preserves all numerical results, references, cohort counts, statistical
   definitions, AI disclosure, GEO links and external-cohort limitations.
7. Does not alter the v2.0 source manuscript.
8. Does not generate a unified-diff artifact.
9. Does not claim that the revision branch has already been pushed.

The output should be treated as the manuscript candidate for final staging
after semantic QA.
"""

from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path


# ============================================================================
# Locked paths
# ============================================================================

SOURCE = Path(
    "docs/complete_manuscript_draft_v2.0_reviewer_editor_reconciled.md"
)

TARGET = Path(
    "docs/complete_manuscript_draft_v2.1_reviewer_editor_final.md"
)

EXPECTED_SOURCE_SHA256 = (
    "b4949e5caf29569f295f3ebd30a684ffa82fbebdbf4d604c48be88084447a677"
)

OUT_DIR = Path(
    "results/revision_round1/"
    "manuscript_v2.1_final_language_reconciliation"
)

QUALITY_GATE = OUT_DIR / "manuscript_v2.1_quality_gate.tsv"

QUALITY_SUMMARY = OUT_DIR / "manuscript_v2.1_quality_summary.tsv"

REPLACEMENT_MANIFEST = OUT_DIR / "manuscript_v2.1_replacement_manifest.tsv"

REPORT = Path(
    "docs/revision_round1/"
    "complete_manuscript_v2.1_final_language_reconciliation_report.md"
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

    text = text.replace(
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

    return text


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
        "v2.0 source SHA256 mismatch. "
        f"Observed {source_sha_before}; "
        f"expected {EXPECTED_SOURCE_SHA256}."
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

text = source_text

manifest: list[dict[str, str]] = []


# ============================================================================
# R01: manuscript working heading
# ============================================================================

text = replace_exact(
    text,
    "# Complete Manuscript Draft v2.0 - Reviewer and Editor Reconciled",
    "# Complete Manuscript Draft v2.1 - Reviewer and Editor Final",
    "Update manuscript working-version heading",
    manifest,
)


# ============================================================================
# R02: remove internal drafting note
# ============================================================================

text = replace_exact(
    text,
    (
        "Draft v0.9 Step 1 removes internal submission-route and "
        "draft-boundary notes from the manuscript body while preserving "
        "scientific caution within the Methods, Results and Discussion.\n\n"
    ),
    "",
    "Remove internal drafting note",
    manifest,
)


# ============================================================================
# R03: simplify Abstract Objectives
# ============================================================================

text = replace_exact(
    text,
    (
        "To determine whether site-aware bacterial- and viral-associated "
        "whole-blood host-response modules discovered in GSE211567 remain "
        "directionally coherent across fixed external projections, including "
        "a second accession-level and cross-platform cohort, and to quantify "
        "the robustness of these modules to analytical choices and gene "
        "deletion."
    ),
    (
        "To determine whether bacterial- and viral-associated whole-blood "
        "host-response modules discovered in GSE211567 retain their "
        "prespecified directions when applied unchanged to two external "
        "cohorts, including a second cross-platform cohort, and to quantify "
        "their robustness to analytical choices and gene deletion."
    ),
    "Simplify Abstract Objectives",
    manifest,
)


# ============================================================================
# R04: simplify Abstract Methods
# ============================================================================

text = replace_exact(
    text,
    (
        "Five biologically guided modules were locked in GSE211567 before "
        "external analysis. The modules were projected without gene "
        "reselection or reweighting into GSE73461 and GSE72810 using an "
        "unweighted mean gene-wise z-score rule."
    ),
    (
        "Five biologically guided modules were defined and fixed in "
        "GSE211567 before external analysis. The same modules were applied "
        "unchanged to GSE73461 and GSE72810 using an unweighted mean "
        "gene-wise z-score rule."
    ),
    "Simplify Abstract Methods",
    manifest,
)


# ============================================================================
# R05: simplify Abstract Conclusions
# ============================================================================

text = replace_exact(
    text,
    (
        "The locked host-response architecture transported directionally "
        "across two external accession-level cohorts and different Illumina "
        "platforms, with the strongest reproducible support for BACT_M2 and "
        "the three viral-associated modules. BACT_M1 and the GSVA behaviour "
        "of VIR_M2 demonstrate that direction preservation does not imply "
        "uniform statistical support across cohorts or scoring algorithms."
    ),
    (
        "The predefined host-response modules retained their expected "
        "directions across two external cohorts measured on different "
        "Illumina platforms, with the strongest reproducible support for "
        "BACT_M2 and the three viral-associated modules. BACT_M1 and the "
        "GSVA behaviour of VIR_M2 demonstrate that direction preservation "
        "does not imply uniform statistical support across cohorts or "
        "scoring algorithms."
    ),
    "Simplify Abstract Conclusions",
    manifest,
)


# ============================================================================
# R06: simplify final Introduction paragraph
# ============================================================================

text = replace_exact(
    text,
    (
        "Here, GSE211567 was used for site-aware discovery of bacterial- "
        "and viral-associated host-response programmes. Five conservative "
        "modules were locked and projected without modification into the "
        "formal external cohort GSE73461 and then into GSE72810 as a second "
        "accession-level and sample-level cohort providing cross-platform "
        "validation. The aim was not to train or validate a diagnostic "
        "classifier, but to test fixed-module transportability, quantify "
        "cross-cohort effect sizes and determine the sensitivity of the "
        "findings to score reference, probe handling, case definition, "
        "alternative gene-set scoring and gene deletion."
    ),
    (
        "Here, GSE211567 was used to discover bacterial- and "
        "viral-associated host-response programmes while requiring "
        "cross-site directional support. Five conservative modules were "
        "defined before external testing and then applied unchanged to "
        "GSE73461 and GSE72810. The latter provided a second "
        "accession-level, sample-level and cross-platform cohort. The aim "
        "was not to train or validate a diagnostic classifier, but to test "
        "whether predefined modules retained their expected directions, "
        "quantify cross-cohort effect sizes and determine sensitivity to "
        "score reference, probe handling, case definition, alternative "
        "gene-set scoring and gene deletion."
    ),
    "Simplify final Introduction paragraph",
    manifest,
)


# ============================================================================
# R07: simplify GSE211567 Methods heading
# ============================================================================

text = replace_exact(
    text,
    "## GSE211567 discovery and module locking",
    "## GSE211567 discovery and module definition",
    "Simplify GSE211567 Methods heading",
    manifest,
)


# ============================================================================
# R08: remove locked wording from discovery set
# ============================================================================

text = replace_exact(
    text,
    "the locked primary discovery set contained 224 samples",
    "the prespecified primary discovery set contained 224 samples",
    "Simplify GSE211567 discovery-set wording",
    manifest,
)


# ============================================================================
# R09: simplify GSE72810 Methods heading
# ============================================================================

text = replace_exact(
    text,
    "## GSE72810 cross-platform validation and probe locking",
    "## GSE72810 cross-platform validation and probe selection",
    "Simplify GSE72810 Methods heading",
    manifest,
)


# ============================================================================
# R10: simplify GSE72810 primary contrast terminology
# ============================================================================

text = replace_exact(
    text,
    (
        "whereas the locked primary inferential contrast was restricted to "
        "23 definite bacterial versus 28 definite viral samples"
    ),
    (
        "whereas the prespecified primary inferential contrast was restricted "
        "to 23 definite bacterial versus 28 definite viral samples"
    ),
    "Simplify GSE72810 primary-contrast wording",
    manifest,
)


# ============================================================================
# R11: simplify representative-probe paragraph
# ============================================================================

text = replace_exact(
    text,
    (
        "Locked genes were reconciled to the GSE72810 platform through "
        "Entrez identifiers. Of 313 module-gene instances, 303 were mapped "
        "and 10 were unmapped. Module coverage was BACT_M1 24/25, BACT_M2 "
        "20/21, VIR_M1a 125/128, VIR_M1b 33/33, VIR_M2 101/106. When "
        "multiple authorised probes represented the same Entrez gene, the "
        "representative probe was frozen as the probe with the highest "
        "median expression across all 146 samples, with lexicographic "
        "ordering used only to resolve exact ties. Probe selection was "
        "completed before testing group differences."
    ),
    (
        "Predefined module genes were reconciled to the GSE72810 platform "
        "through Entrez identifiers. Of 313 module-gene instances, 303 were "
        "mapped and 10 were unmapped. Module coverage was BACT_M1 24/25, "
        "BACT_M2 20/21, VIR_M1a 125/128, VIR_M1b 33/33 and VIR_M2 101/106. "
        "When multiple authorised probes represented the same Entrez gene, "
        "a prespecified rule selected the probe with the highest median "
        "expression across all 146 samples, with lexicographic ordering used "
        "only to resolve exact ties. Probe selection was completed before "
        "testing group differences."
    ),
    "Simplify GSE72810 representative-probe description",
    manifest,
)


# ============================================================================
# R12: simplify scoring heading
# ============================================================================

text = replace_exact(
    text,
    "## Fixed-module scoring and statistical analysis",
    "## Module scoring and statistical analysis",
    "Simplify module-scoring heading",
    manifest,
)


# ============================================================================
# R13: remove frozen terminology from reproducibility boundary
# ============================================================================

text = replace_exact(
    text,
    (
        "The analyses evaluate transportability and robustness of frozen "
        "biological modules."
    ),
    (
        "The analyses evaluate transportability and robustness of the "
        "predefined biological modules."
    ),
    "Simplify reproducibility-boundary wording",
    manifest,
)


# ============================================================================
# R14: simplify discovery Results paragraph
# ============================================================================

text = replace_exact(
    text,
    (
        "The GSE211567 discovery analysis used a predefined "
        "bacterial-versus-viral contrast while preserving a strict "
        "distinction between discovery, module locking and external "
        "projection. The primary limma analysis ranked host-transcriptomic "
        "features before site-aware concordance checks across pooled and "
        "available site-stratified analyses (Figure 1A-B). This procedure "
        "reduced the likelihood of carrying forward features driven mainly "
        "by one geographic or technical stratum."
    ),
    (
        "The GSE211567 discovery analysis used a predefined "
        "bacterial-versus-viral contrast while keeping module definition "
        "separate from external testing. The primary limma analysis ranked "
        "host-transcriptomic features before cross-site concordance checks "
        "across the pooled and site-stratified analyses (Figure 1A-B). This "
        "procedure reduced the likelihood of carrying forward features "
        "driven mainly by one geographic or technical stratum."
    ),
    "Simplify discovery Results terminology",
    manifest,
)


# ============================================================================
# R15: simplify GSE73461 Results opening
# ============================================================================

text = replace_exact(
    text,
    (
        "The locked GSE73461 contrast contained 52 DefiniteBacterial and "
        "94 DefiniteViral samples."
    ),
    (
        "The primary GSE73461 contrast contained 52 DefiniteBacterial and "
        "94 DefiniteViral samples."
    ),
    "Simplify GSE73461 Results opening",
    manifest,
)


# ============================================================================
# R16: simplify Figure 1 heading
# ============================================================================

text = replace_exact(
    text,
    (
        "## Figure 1. Discovery and conservative locking of bacterial- and "
        "viral-associated host-response modules in GSE211567"
    ),
    (
        "## Figure 1. Discovery and conservative definition of bacterial- "
        "and viral-associated host-response modules in GSE211567"
    ),
    "Simplify Figure 1 title",
    manifest,
)


# ============================================================================
# R17: simplify Figure 1A wording
# ============================================================================

text = replace_exact(
    text,
    (
        "The volcano-style plot summarises the limma-ranked "
        "host-transcriptomic contrast used as the discovery starting point "
        "before site-aware filtering and biological module definition."
    ),
    (
        "The volcano-style plot summarises the limma-ranked "
        "host-transcriptomic contrast used as the discovery starting point "
        "before cross-site concordance assessment and biological module "
        "definition."
    ),
    "Simplify Figure 1A terminology",
    manifest,
)


# ============================================================================
# R18: simplify Figure 2 title
# ============================================================================

text = replace_exact(
    text,
    (
        "## Figure 2. External fixed-module projection of GSE211567 "
        "discovery modules in GSE73461"
    ),
    (
        "## Figure 2. External evaluation of predefined GSE211567 "
        "discovery modules in GSE73461"
    ),
    "Simplify Figure 2 title",
    manifest,
)


# ============================================================================
# R19: simplify Supplementary Figure S1 frozen wording
# ============================================================================

text = replace_exact(
    text,
    "robustness of the frozen modules",
    "robustness of the predefined modules",
    "Simplify Supplementary Figure S1 wording",
    manifest,
)


# ============================================================================
# R20: simplify Table 1 description
# ============================================================================

text = replace_exact(
    text,
    (
        "This table summarises fixed-module projection of the five locked "
        "GSE211567 discovery modules in the independent GSE73461 cohort."
    ),
    (
        "This table summarises external evaluation of the five predefined "
        "GSE211567 discovery modules in GSE73461."
    ),
    "Simplify Table 1 description",
    manifest,
)


# ============================================================================
# R21: simplify Figure 3 locked-module wording
# ============================================================================

text = replace_exact(
    text,
    (
        "the five modules locked in the GSE211567 discovery analysis"
    ),
    (
        "the five modules predefined in the GSE211567 discovery analysis"
    ),
    "Simplify Figure 3 caption wording",
    manifest,
)


# ============================================================================
# R22: simplify supplementary representative-probe wording
# ============================================================================

text = replace_exact(
    text,
    "frozen representative-probe choices",
    "prespecified representative-probe choices",
    "Simplify Supplementary Table S7 wording",
    manifest,
)


# ============================================================================
# Write target
# ============================================================================

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
# QA
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
    "v2.0 source SHA matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "v2.0 source remained unchanged",
    source_sha_after == EXPECTED_SOURCE_SHA256,
    source_sha_after,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "All targeted replacements were applied",
    len(manifest) == 22,
    len(manifest),
    22,
)

add_check(
    "Internal Draft v0.9 note is absent",
    "Draft v0.9 Step 1" not in text,
    text.count("Draft v0.9 Step 1"),
    0,
)

add_check(
    "Site-aware terminology is absent from manuscript-facing text",
    re.search(
        r"\bsite-aware\b",
        text,
        flags=re.IGNORECASE,
    ) is None,
    len(
        re.findall(
            r"\bsite-aware\b",
            text,
            flags=re.IGNORECASE,
        )
    ),
    0,
)

add_check(
    "Frozen terminology is absent",
    re.search(
        r"\bfrozen\b|\bfreezing\b",
        text,
        flags=re.IGNORECASE,
    ) is None,
    len(
        re.findall(
            r"\bfrozen\b|\bfreezing\b",
            text,
            flags=re.IGNORECASE,
        )
    ),
    0,
)

add_check(
    "Discovery/projection firewall remains absent",
    "discovery/projection firewall" not in text,
    text.count("discovery/projection firewall"),
    0,
)

add_check(
    "Transportability definition is preserved",
    (
        "transportability means preservation of the prespecified "
        "biological direction"
    ) in text,
    "present",
    "present",
)

add_check(
    "Fixed-module projection definition is preserved",
    (
        "Fixed-module projection means applying predefined gene sets"
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
    "GSE211567 group counts remain 101 and 123",
    (
        "101 bacterial and 123 viral"
    ) in text,
    "101 bacterial; 123 viral",
    "101 bacterial; 123 viral",
)

add_check(
    "GSE73461 primary groups remain 52 and 94",
    (
        "52 DefiniteBacterial and 94 DefiniteViral"
    ) in text,
    "52 and 94",
    "52 and 94",
)

add_check(
    "GSE73461 main reference remains n = 201",
    "55 Control samples (n = 201)" in text,
    "201",
    "201",
)

add_check(
    "GSE72810 main reference remains 146",
    (
        "All 146 samples were retained in the main z-score reference "
        "population"
    ) in text,
    "146",
    "146",
)

add_check(
    "GSE72810 primary contrast remains 23 versus 28",
    (
        "23 definite bacterial versus 28 definite viral samples"
    ) in text,
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
    "Deletion minimum Pearson correlation remains 0.9940",
    "0.9940" in text,
    "0.9940",
    "0.9940",
)

add_check(
    "Figure 2C independent-point explanation is preserved",
    (
        "are shown as independent points for each categorical module"
    ) in text,
    "present",
    "present",
)

add_check(
    "Figure 2C non-connection explanation is preserved",
    "The module categories are not connected" in text,
    "present",
    "present",
)

add_check(
    "Directional-concordance definition is preserved",
    (
        "directional concordance was defined as agreement in the sign "
        "of the bacterial-versus-viral log2 fold change"
    ) in text,
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
    "GSE72810 investigator-network limitation is preserved",
    (
        "same broad investigator network"
    ) in text,
    "present",
    "present",
)

add_check(
    "Fully investigator-independent boundary is preserved",
    (
        "should therefore not be treated as a fully "
        "investigator-independent replication cohort"
    ) in text,
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
    "All three direct GEO links are preserved",
    all(
        accession in text
        for accession in [
            "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567",
            "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461",
            "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810",
        ]
    ),
    "3 URLs present",
    "3 URLs present",
)

add_check(
    "Code Availability remains future tense before repository push",
    (
        "will be synchronised with the public repository before resubmission"
        in text
    ),
    "future tense retained",
    "future tense retained",
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
    "v2.1 differs from v2.0",
    target_sha != source_sha_before,
    target_sha,
    "different from source",
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
    "READY_FOR_FINAL_V2_1_SEMANTIC_REVIEW"
    if quality_failed == 0
    else "V2_1_LANGUAGE_RECONCILIATION_REQUIRES_REVIEW"
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
    "# Complete Manuscript v2.1 Final Language Reconciliation",
    "",
    "## Source lock",
    "",
    f"- Source: `{SOURCE}`",
    f"- Source SHA256: `{source_sha_before}`",
    f"- Target: `{TARGET}`",
    f"- Target SHA256: `{target_sha}`",
    "",
    "## Purpose",
    "",
    (
        "This pass removes residual internal drafting text and simplifies "
        "remaining reviewer-facing terminology after the v2.0 scientific "
        "and editor reconciliation."
    ),
    "",
    "## Main changes",
    "",
    "- Removed the internal Draft v0.9 note.",
    "- Simplified Abstract Objectives, Methods and Conclusions.",
    "- Removed manuscript-facing uses of `site-aware`.",
    "- Removed manuscript-facing uses of `frozen`/`freezing`.",
    "- Replaced probe-locking language with prespecified probe selection.",
    "- Simplified remaining discovery/external-testing terminology.",
    "- Simplified Figure 1 and Figure 2 titles and captions.",
    "- Preserved the formal transportability definition.",
    "- Preserved the formal fixed-module projection definition at first use.",
    "",
    "## Scientific preservation",
    "",
    "- No analysis was rerun.",
    "- No numerical result was intentionally changed.",
    "- No module composition or expected direction was changed.",
    "- No reference was added, removed or renumbered.",
    "- Figure 2C interpretation was preserved.",
    "- GEO links and AI disclosure were preserved.",
    "- Cross-cohort independence limitations were preserved.",
    "",
    "## Repository boundary",
    "",
    (
        "Code Availability remains in future tense because public revision-"
        "branch synchronization has not yet been verified."
    ),
    "",
    "## Quality gate",
    "",
    f"- Checks passed: {quality_passed}/{len(checks)}.",
    f"- Quality gate: `{quality_gate}`.",
    f"- Final status: `{final_status}`.",
    "",
    "No unified-diff artifact was generated.",
    "",
]

REPORT.write_text(
    "\n".join(report_lines),
    encoding="utf-8",
    newline="\n",
)


# ============================================================================
# Console
# ============================================================================

print("===== MANUSCRIPT V2.1 FINAL LANGUAGE RECONCILIATION =====")
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
        f"v2.1 failed {quality_failed} quality check(s)."
    )
