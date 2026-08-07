#!/usr/bin/env python3
"""
Integrate Revision Round 1 evidence into manuscript v1.7.

The integration is permitted only when:
1. The protected v1.6 manuscript has its expected checksum.
2. The v1.7 working copy still matches the untouched baseline.
3. Structured cross-cohort, mapping, coverage and robustness tables pass
   their locked numerical checks.
4. Required cohort-independence wording is present in the audit evidence.

The script does not modify the protected v1.6 manuscript or raw data.
"""

from __future__ import annotations

import csv
import difflib
import hashlib
import platform
import re
import sys
from pathlib import Path
from typing import Dict, List


EXPECTED_BASELINE_SHA256 = (
    "1e7c46270e50ae8f247265413df37ba3dd7a3b9b05c99ca7103578deb39cd08c"
)

MODULE_ORDER = [
    "BACT_M1",
    "BACT_M2",
    "VIR_M1a",
    "VIR_M1b",
    "VIR_M2",
]

EXPECTED_COVERAGE = {
    "BACT_M1": {
        "locked_gene_count": 25,
        "mapped_gene_count": 24,
        "missing_gene_count": 1,
        "missing_symbols": "HYDIN2",
    },
    "BACT_M2": {
        "locked_gene_count": 21,
        "mapped_gene_count": 20,
        "missing_gene_count": 1,
        "missing_symbols": "NDUFAF8",
    },
    "VIR_M1a": {
        "locked_gene_count": 128,
        "mapped_gene_count": 125,
        "missing_gene_count": 3,
        "missing_symbols": "DDX60L;MICA;POLR3E",
    },
    "VIR_M1b": {
        "locked_gene_count": 33,
        "mapped_gene_count": 33,
        "missing_gene_count": 0,
        "missing_symbols": "none",
    },
    "VIR_M2": {
        "locked_gene_count": 106,
        "mapped_gene_count": 101,
        "missing_gene_count": 5,
        "missing_symbols": "CCR2;CCRL2;KIR2DS2;KIR3DS1;MICA",
    },
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)

    return digest.hexdigest()


def require_file(path: Path) -> None:
    if not path.is_file() or path.stat().st_size == 0:
        raise FileNotFoundError(f"Missing or empty required file: {path}")


def read_tsv(path: Path) -> List[Dict[str, str]]:
    require_file(path)

    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(
            csv.DictReader(
                handle,
                delimiter="\t",
            )
        )


def write_tsv(
    path: Path,
    rows: List[Dict[str, object]],
    fieldnames: List[str],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()

        for row in rows:
            writer.writerow(row)


def truth(value: object) -> bool:
    return str(value).strip().upper() in {
        "TRUE",
        "T",
        "1",
        "YES",
    }


def integer_field(
    row: Dict[str, str],
    field: str,
) -> int:
    try:
        return int(str(row[field]).strip())
    except (KeyError, TypeError, ValueError) as error:
        raise RuntimeError(
            f"Invalid integer field {field!r}: {row.get(field)!r}"
        ) from error


def replace_section(
    text: str,
    start_heading: str,
    end_heading: str,
    replacement: str,
) -> str:
    pattern = re.compile(
        rf"^{re.escape(start_heading)}\n.*?"
        rf"(?=^{re.escape(end_heading)}\n)",
        flags=re.MULTILINE | re.DOTALL,
    )

    matches = list(pattern.finditer(text))

    if len(matches) != 1:
        raise RuntimeError(
            f"Expected one section from {start_heading!r} "
            f"to {end_heading!r}; found {len(matches)}."
        )

    return pattern.sub(
        replacement.rstrip() + "\n\n",
        text,
        count=1,
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

    return text.replace(old, new, 1)


def section_between(
    text: str,
    start_heading: str,
    end_heading: str,
) -> str:
    pattern = re.compile(
        rf"^{re.escape(start_heading)}\n.*?"
        rf"(?=^{re.escape(end_heading)}\n)",
        flags=re.MULTILINE | re.DOTALL,
    )

    matches = list(pattern.finditer(text))

    if len(matches) != 1:
        raise RuntimeError(
            f"Could not recover unique section {start_heading!r}."
        )

    return matches[0].group(0).rstrip()


def caption_body(path: Path) -> str:
    require_file(path)

    lines = path.read_text(encoding="utf-8").splitlines()

    while lines and not lines[0].strip():
        lines.pop(0)

    if lines and lines[0].lstrip().startswith("#"):
        lines.pop(0)

    while lines and not lines[0].strip():
        lines.pop(0)

    return "\n".join(lines).strip()


def clean_markdown_cell(value: object) -> str:
    return (
        str(value)
        .replace("|", "\\|")
        .replace("\r", " ")
        .replace("\n", " ")
        .strip()
    )


def count_pattern(
    text: str,
    pattern: str,
) -> int:
    return len(
        re.findall(
            pattern,
            text,
            flags=re.MULTILINE,
        )
    )


def add_check(
    checks: List[Dict[str, object]],
    description: str,
    passed: bool,
    observed: object,
    expected: object,
) -> None:
    checks.append(
        {
            "check_id": f"Q{len(checks) + 1:02d}",
            "check_description": description,
            "pass": bool(passed),
            "observed": observed,
            "expected": expected,
        }
    )


root = Path(__file__).resolve().parents[2]

source = (
    root
    / "docs/complete_manuscript_draft_v1.6_step7b_single_author.md"
)

target = (
    root
    / "docs/complete_manuscript_draft_v1.7_revision_round1_integrated.md"
)

cross_summary_file = (
    root
    / "results/revision_round1/"
    "GSE73461_GSE72810_cross_cohort_validation/"
    "GSE73461_GSE72810_cross_cohort_summary_table.tsv"
)

robustness_summary_file = (
    root
    / "results/revision_round1/"
    "GSE73461_GSE72810_supplementary_robustness/"
    "Figure_S1_supplementary_robustness_quality_summary.tsv"
)

mapping_decision_file = (
    root
    / "results/revision_round1/"
    "GSE72810_candidate_validation_audit/"
    "GSE72810_entrez_reconciliation_decision.tsv"
)

mapping_coverage_file = (
    root
    / "results/revision_round1/"
    "GSE72810_candidate_validation_audit/"
    "GSE72810_locked_module_coverage_entrez_reconciled.tsv"
)

figure3_caption_file = (
    root
    / "docs/revision_round1/"
    "GSE73461_GSE72810_cross_cohort_validation_figure_caption.md"
)

figure_s1_caption_file = (
    root
    / "docs/revision_round1/"
    "Figure_S1_supplementary_robustness_caption.md"
)

gse72810_audit_report = (
    root
    / "docs/revision_round1/"
    "GSE72810_candidate_validation_audit_report.md"
)

independence_report = (
    root
    / "docs/revision_round1/"
    "GSE72810_GSE73461_accession_overlap_independence_audit_report.md"
)

out_dir = (
    root
    / "results/revision_round1/"
    "manuscript_v1.7_revision_round1_integration"
)

quality_file = (
    out_dir
    / "manuscript_v1.7_integration_quality_gate.tsv"
)

summary_file = (
    out_dir
    / "manuscript_v1.7_integration_quality_summary.tsv"
)

supplement_map_file = (
    out_dir
    / "supplementary_numbering_map.tsv"
)

diff_file = (
    out_dir
    / "manuscript_v1.6_to_v1.7_unified_diff.txt"
)

report_file = (
    root
    / "docs/revision_round1/"
    "complete_manuscript_v1.7_integration_report.md"
)

session_file = (
    root
    / "env/session_info/revision_round1/"
    "complete_manuscript_v1.7_integration_sessionInfo.txt"
)

required_files = [
    source,
    target,
    cross_summary_file,
    robustness_summary_file,
    mapping_decision_file,
    mapping_coverage_file,
    figure3_caption_file,
    figure_s1_caption_file,
    gse72810_audit_report,
    independence_report,
]

for required_file in required_files:
    require_file(required_file)

source_sha_before = sha256_file(source)
target_sha_before = sha256_file(target)

if source_sha_before != EXPECTED_BASELINE_SHA256:
    raise RuntimeError(
        "The protected v1.6 source checksum changed. "
        "Integration was stopped."
    )

if target_sha_before != EXPECTED_BASELINE_SHA256:
    raise RuntimeError(
        "The v1.7 manuscript no longer matches the protected "
        "pre-integration baseline. Integration was stopped."
    )

source_text = source.read_text(encoding="utf-8")
text = target.read_text(encoding="utf-8")

cross_rows = read_tsv(cross_summary_file)
robustness_rows = read_tsv(robustness_summary_file)
mapping_decision_rows = read_tsv(mapping_decision_file)
coverage_rows = read_tsv(mapping_coverage_file)

if len(cross_rows) != 5:
    raise RuntimeError(
        f"Expected five cross-cohort rows; found {len(cross_rows)}."
    )

if len(robustness_rows) != 1:
    raise RuntimeError(
        "Expected one supplementary robustness summary row."
    )

if len(mapping_decision_rows) != 1:
    raise RuntimeError(
        "Expected one GSE72810 mapping-decision row."
    )

if len(coverage_rows) != 5:
    raise RuntimeError(
        f"Expected five mapping-coverage rows; found {len(coverage_rows)}."
    )

required_cross_columns = {
    "final_module_id",
    "gse73461_primary_result",
    "gse73461_bh_p_formatted",
    "gse72810_primary_result",
    "gse72810_bh_p_formatted",
    "both_direction_retained",
    "both_hl_ci_exclude_zero",
    "both_fdr_significant",
    "cross_cohort_interpretation",
}

missing_cross_columns = required_cross_columns.difference(
    cross_rows[0].keys()
)

if missing_cross_columns:
    raise RuntimeError(
        "Cross-cohort table is missing required fields: "
        + ", ".join(sorted(missing_cross_columns))
    )

cross_by_module = {
    row["final_module_id"]: row
    for row in cross_rows
}

if set(cross_by_module) != set(MODULE_ORDER):
    raise RuntimeError(
        "The cross-cohort table does not contain the five locked modules."
    )

cross_rows = [
    cross_by_module[module]
    for module in MODULE_ORDER
]

mapping_decision = mapping_decision_rows[0]

expected_mapping_decision = {
    "candidate_dataset": "GSE72810",
    "locked_module_gene_instances": 313,
    "mapped_gene_instances": 303,
    "unmapped_gene_instances": 10,
    "entrez_rescued_gene_instances": 20,
    "unsafe_alias_gene_instances_rejected": 19,
    "unsafe_alias_probe_rows_rejected": 30,
    "exact_symbol_conflict_probe_rows_rejected": 11,
    "modules_eligible_at_50_percent": 5,
    "modules_high_coverage_at_70_percent": 5,
    "scoring_readiness": "READY_FOR_FIXED_MODULE_SCORING",
    "quality_gate": "PASS",
}

if mapping_decision.get("candidate_dataset") != "GSE72810":
    raise RuntimeError(
        "The structured mapping decision is not for GSE72810."
    )

for field in [
    "locked_module_gene_instances",
    "mapped_gene_instances",
    "unmapped_gene_instances",
    "entrez_rescued_gene_instances",
    "unsafe_alias_gene_instances_rejected",
    "unsafe_alias_probe_rows_rejected",
    "exact_symbol_conflict_probe_rows_rejected",
    "modules_eligible_at_50_percent",
    "modules_high_coverage_at_70_percent",
]:
    observed_value = integer_field(
        mapping_decision,
        field,
    )
    expected_value = int(
        expected_mapping_decision[field]
    )

    if observed_value != expected_value:
        raise RuntimeError(
            f"Unexpected mapping-decision value for {field}: "
            f"{observed_value}; expected {expected_value}."
        )

for field in [
    "scoring_readiness",
    "quality_gate",
]:
    observed_value = str(
        mapping_decision.get(field, "")
    ).strip()
    expected_value = str(
        expected_mapping_decision[field]
    )

    if observed_value != expected_value:
        raise RuntimeError(
            f"Unexpected mapping-decision value for {field}: "
            f"{observed_value!r}; expected {expected_value!r}."
        )

coverage_by_module = {
    row["final_module_id"]: row
    for row in coverage_rows
}

if set(coverage_by_module) != set(MODULE_ORDER):
    raise RuntimeError(
        "The coverage table does not contain the five locked modules."
    )

for module in MODULE_ORDER:
    row = coverage_by_module[module]
    expected = EXPECTED_COVERAGE[module]

    for field in [
        "locked_gene_count",
        "mapped_gene_count",
        "missing_gene_count",
    ]:
        observed_value = integer_field(row, field)
        expected_value = int(expected[field])

        if observed_value != expected_value:
            raise RuntimeError(
                f"Unexpected {module} {field}: "
                f"{observed_value}; expected {expected_value}."
            )

    observed_missing = str(
        row.get("missing_symbols", "")
    ).strip()

    if observed_missing != expected["missing_symbols"]:
        raise RuntimeError(
            f"Unexpected {module} missing symbols: "
            f"{observed_missing!r}; "
            f"expected {expected['missing_symbols']!r}."
        )

    if not truth(row.get("eligible_at_50_percent")):
        raise RuntimeError(
            f"{module} failed the 50 percent coverage threshold."
        )

    if not truth(row.get("high_coverage_at_70_percent")):
        raise RuntimeError(
            f"{module} failed the 70 percent coverage threshold."
        )

robustness = robustness_rows[0]

expected_robustness = {
    "panel_a_rows": "30",
    "panel_b_rows": "20",
    "panel_b_wide_rows": "10",
    "panel_c_rows": "20",
    "panel_a_fdr_supported_rows": "24",
    "panel_a_ci_supported_rows": "25",
    "panel_b_fdr_supported_rows": "16",
    "panel_b_ci_supported_rows": "16",
    "method_discordant_rows": "4",
    "deletion_variants": "29826",
    "quality_gate": "PASS",
    "final_status": "READY_FOR_SUPPLEMENTARY_FIGURE_VISUAL_REVIEW",
}

for field, expected_value in expected_robustness.items():
    observed_value = str(
        robustness.get(field, "")
    ).strip()

    if observed_value != expected_value:
        raise RuntimeError(
            f"Unexpected robustness value for {field}: "
            f"{observed_value!r}; expected {expected_value!r}."
        )

audit_text = gse72810_audit_report.read_text(
    encoding="utf-8"
)

for required_token in [
    "146",
    "23",
    "28",
    "17",
    "7",
    "16",
    "55",
]:
    if required_token not in audit_text:
        raise RuntimeError(
            "The GSE72810 cohort audit does not contain "
            f"required token {required_token!r}."
        )

independence_text = independence_report.read_text(
    encoding="utf-8"
)

for required_phrase in [
    "disjoint",
    "participant",
    "investigator",
]:
    if required_phrase.lower() not in independence_text.lower():
        raise RuntimeError(
            "The independence audit lacks required wording: "
            f"{required_phrase!r}."
        )

reference_numbers = [
    int(match.group(1))
    for match in re.finditer(
        r"^\[(\d+)\]\s",
        text,
        flags=re.MULTILINE,
    )
]

if not reference_numbers:
    raise RuntimeError(
        "No numbered manuscript references were detected."
    )

gse72810_reference_number = max(reference_numbers) + 1

old_intro_paragraph = (
    "Here, GSE211567 was used for site-aware discovery of bacterial- "
    "and viral-associated host-response programmes. Five conservative "
    "modules were locked and then projected into GSE73461 using a "
    "predefined unweighted mean z-score rule. The aim was not to train "
    "or validate a diagnostic classifier, but to test fixed-module "
    "transportability across public infection transcriptomes and identify "
    "which host-response programmes show the strongest external support."
)

new_intro_paragraph = (
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
)

text = replace_once(
    text,
    old_intro_paragraph,
    new_intro_paragraph,
    "final Introduction paragraph",
)

abstract = """## Abstract

### Objectives

To determine whether site-aware bacterial- and viral-associated whole-blood host-response modules discovered in GSE211567 remain directionally coherent across fixed external projections, including a second accession-level and cross-platform cohort, and to quantify the robustness of these modules to analytical choices and gene deletion.

### Methods

Five biologically guided modules were locked in GSE211567 before external analysis. The modules were projected without gene reselection or reweighting into GSE73461 and GSE72810 using an unweighted mean gene-wise z-score rule. Primary contrasts included 52 bacterial and 94 viral samples in GSE73461 and 23 definite bacterial and 28 definite viral samples in GSE72810. Wilcoxon tests were adjusted across the five modules using the Benjamini-Hochberg method. Hodges-Lehmann shifts, rank-biserial effects and 10,000-replicate bootstrap confidence intervals were calculated. Sensitivity analyses assessed z-score reference populations, probable-case inclusion, probe summarisation, GSVA scoring and exhaustive leave-one/two-gene deletion.

### Results

All five modules retained their expected directions in both projection cohorts. BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 had confidence intervals excluding zero and passed false-discovery-rate correction in both cohorts, whereas BACT_M1 remained directionally concordant but borderline in GSE73461 and GSE72810 (adjusted P = 0.0799 in each). All 30 z-reference, case-definition and probe-collapse sensitivity estimates retained the expected direction. Under GSVA, BACT_M1 gained statistical support, whereas VIR_M2 retained its viral-higher direction but lost confidence-interval and adjusted-P-value support. Across 29,826 leave-one/two-gene variants, every variant retained the expected direction and the minimum Pearson correlation with its complete-module score was 0.9940.

### Conclusions

The locked host-response architecture transported directionally across two external accession-level cohorts and different Illumina platforms, with the strongest reproducible support for BACT_M2 and the three viral-associated modules. BACT_M1 and the GSVA behaviour of VIR_M2 demonstrate that direction preservation does not imply uniform statistical support across cohorts or scoring algorithms.
"""

coverage_text = ", ".join(
    (
        f"{module} "
        f"{coverage_by_module[module]['mapped_gene_count']}/"
        f"{coverage_by_module[module]['locked_gene_count']}"
    )
    for module in MODULE_ORDER
)

methods = f"""# Methods

## Study design and datasets

This study used a staged transcriptomic transportability design with a strict discovery/projection firewall. GSE211567 was used for discovery, biological interpretation and module locking. GSE73461 was used as the formal external projection cohort only after final module definitions, directions and scoring rules had been fixed. GSE72810 was subsequently analysed as a second accession-level and sample-level cohort providing cross-platform validation of the locked modules. External datasets were not used to reselect genes, rename modules, alter module composition, tune weights or train a diagnostic classifier.

Public host-transcriptomic datasets were considered if they contained infection-relevant human transcriptomic data, recoverable sample metadata, interpretable pathogen-class labels, usable feature identifiers and sufficient sample structure for the intended analysis. GSE161731 was retained only as a technical rehearsal dataset, while GSE261482 and GSE68310 were audited but not selected for formal projection. GSE211567, GSE73461 and GSE72810 were obtained from the Gene Expression Omnibus [12,13,{gse72810_reference_number}].

## GSE211567 discovery and module locking

GSE211567 metadata and normalised expression data were audited before modelling [12]. Sample eligibility and the bacterial-versus-viral discovery design were fixed before differential-expression analysis. Because GSE211567 contained geographically and clinically distinct strata, the workflow combined a primary bacterial-versus-viral limma contrast with site-stratified concordance assessment to prioritise directionally stable signals.

Differential-expression results were treated as a discovery-ranking layer rather than a diagnostic signature [14]. Positive log2 fold-change values were interpreted as bacterial-higher and negative values as viral-higher. Transcript-level features were mapped to gene identifiers, summarised at gene level and carried into Gene Ontology biological-process enrichment [15,16]. Redundant enriched terms were reduced and manually reviewed using a documented biologically guided curation process. Five modules were frozen before projection: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2.

## GSE73461 formal external projection

GSE73461 expression, annotation, metadata and group labels were audited independently of module discovery [13]. The primary projection contrast contained 52 DefiniteBacterial and 94 DefiniteViral samples. Fifty-five Control samples were retained in the main all-projected z-score reference but were not included in the primary bacterial-versus-viral test. Inflammatory, Kawasaki and Unknown groups were excluded from that contrast.

Illumina probes were mapped to gene symbols, and locked genes were checked against predefined module-coverage thresholds. The numbers of scored genes were 24/25 for BACT_M1, 21/21 for BACT_M2, 128/128 for VIR_M1a, 33/33 for VIR_M1b and 105/106 for VIR_M2.

## GSE72810 cross-platform validation and probe locking

GSE72810 contained 146 paediatric whole-blood samples measured using the Illumina HumanHT-12 v3 platform [{gse72810_reference_number}]. The locked primary contrast contained 23 definite bacterial and 28 definite viral samples. Seventeen probable bacterial and seven probable viral samples were reserved for expanded-case sensitivity analysis. Sixteen controls were retained for score-reference context, and 55 uncertain samples were excluded from bacterial-versus-viral testing.

Locked genes were reconciled to the GSE72810 platform through Entrez identifiers. Of {mapping_decision['locked_module_gene_instances']} module-gene instances, {mapping_decision['mapped_gene_instances']} were mapped and {mapping_decision['unmapped_gene_instances']} were unmapped. Module coverage was {coverage_text}. When multiple authorised probes represented the same Entrez gene, the representative probe was frozen as the probe with the highest median expression across all 146 samples, with lexicographic ordering used only to resolve exact ties. Probe selection was completed before testing group differences.

## Fixed-module scoring and statistical analysis

For the primary mean-z analyses, each mapped gene was z-scored within the locked scoring population and each module score was the unweighted mean of its available gene-wise z scores. Missing genes were ignored only after coverage had been documented. No module was retrained, reweighted or direction-flipped.

Wilcoxon rank-sum tests compared bacterial and viral module scores, with Benjamini-Hochberg correction across the five modules [17]. Positive effects denote bacterial-higher scores and negative effects denote viral-higher scores. In addition to median bacterial-minus-viral differences, the revision analyses calculated Hodges-Lehmann location shifts and rank-biserial effects. Confidence intervals were obtained using 10,000 bootstrap replicates.

## Sensitivity and robustness analyses

Z-reference sensitivity was evaluated by repeating scoring using only the primary bacterial and viral samples as the reference population. GSE72810 sensitivity analyses additionally included probable bacterial and viral cases and compared the locked representative-probe scores with mean scores across all authorised probes. Score concordance was assessed using Pearson and Spearman correlations.

A GSVA sensitivity analysis was performed in GSE73461 using the unchanged module gene sets and both z-reference populations. Because mean-z and GSVA scores have different numerical scales, cross-method interpretation focused on effect direction, rank-biserial effect, confidence intervals and adjusted P values rather than direct comparison of raw score magnitudes.

Gene-deletion robustness was assessed exhaustively in GSE73461 by recalculating every module after removal of each individual gene and every pair of genes. Variant scores were compared with the corresponding complete-module scores, and expected-direction retention, Wilcoxon results and Pearson and Spearman correlations were recorded.

## Cross-cohort interpretation and reproducibility boundaries

The GSE72810 and GSE73461 GEO sample accession sets were disjoint and the cohorts were measured on different Illumina array platforms. However, direct participant overlap could not be assessed because participant identifiers were not deposited, and the studies arose from the same broad investigator network. GSE72810 is therefore described as a second accession-level and sample-level cross-platform cohort rather than as a fully investigator-independent replication cohort.

Analysis scripts, decision logs, quality gates, source-data tables, manuscript-facing figures and supplementary outputs were organised in the project repository. The analyses evaluate transportability and robustness of frozen biological modules. They do not constitute diagnostic classifier discovery, clinical-performance validation, clinical implementation evidence or causal validation.
"""

results = """# Results

## GSE211567 discovery identifies site-aware bacterial- and viral-associated programmes

The GSE211567 discovery analysis used a predefined bacterial-versus-viral contrast while preserving a strict distinction between discovery, module locking and external projection. The primary limma analysis ranked host-transcriptomic features before site-aware concordance checks across pooled and available site-stratified analyses (Figure 1A-B). This procedure reduced the likelihood of carrying forward features driven mainly by one geographic or technical stratum.

## Conservative biological curation defines five frozen modules

Directionally eligible features were mapped to genes and assessed using Gene Ontology biological-process enrichment. Redundancy-reduced biological groups were reviewed using the documented curation hierarchy before final module locking. Two modules were bacterial-higher: BACT_M1, representing cytoplasmic translation and ribosomal activity, and BACT_M2, representing mitochondrial respiration and oxidative phosphorylation. Three modules were viral-higher: VIR_M1a, VIR_M1b and VIR_M2, representing broad antiviral/interferon defence, viral restriction/type I interferon activity and cytokine/innate immune regulation, respectively (Figure 1C).

## GSE73461 formal external projection retains all expected directions

The locked GSE73461 contrast contained 52 DefiniteBacterial and 94 DefiniteViral samples. All modules passed the predefined coverage threshold and were scored without gene reselection, module redefinition, reweighting or model training.

All five modules retained their discovery directions (Figure 2; Table 1). BACT_M2 was bacterial-higher, with a median bacterial-minus-viral score difference of +0.3328 and BH-adjusted Wilcoxon P = 0.0202. BACT_M1 was also bacterial-higher but remained borderline after correction, with a median difference of +0.2067 and adjusted P = 0.0799. VIR_M1a, VIR_M1b and VIR_M2 were viral-higher, with median differences of -0.4629, -0.6739 and -0.2596 and adjusted P values of 4.77 x 10^-6, 1.41 x 10^-6 and 0.00848, respectively. Primary-only z-reference scoring retained all expected directions and the same four-module pattern of adjusted statistical support.

## GSE72810 provides accession-level and cross-platform validation

The GSE72810 primary contrast contained 23 definite bacterial and 28 definite viral samples. Locked-gene coverage remained high after Entrez reconciliation and representative-probe freezing. All five modules retained their expected directions.

BACT_M2 had a Hodges-Lehmann bacterial-minus-viral shift of +0.425 (95% CI +0.161 to +0.676; adjusted P = 0.0020). VIR_M1a, VIR_M1b and VIR_M2 had shifts of -0.726 (95% CI -0.907 to -0.577), -0.941 (95% CI -1.201 to -0.752) and -0.576 (95% CI -0.682 to -0.475), with adjusted P values of 7.16 x 10^-8, 8.77 x 10^-8 and 8.77 x 10^-8, respectively. BACT_M1 was bacterial-higher but borderline, with a shift of +0.266 (95% CI -0.024 to +0.722; adjusted P = 0.0799).

## Cross-cohort effects support four modules in both cohorts

All ten cohort-module effects retained the expected direction (Figure 3; Table 2). BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 had confidence intervals excluding zero and passed false-discovery-rate correction in both GSE73461 and GSE72810. BACT_M1 was directionally concordant in both cohorts, but both confidence intervals included zero and both adjusted P values were approximately 0.08.

The cross-cohort pattern therefore supported four modules under both effect-size and adjusted-significance criteria. The strongest and most consistent signals were the viral-associated modules, followed by the bacterial mitochondrial respiration/OXPHOS module.

## Sensitivity analyses retain direction but identify method-dependent support

Across the two GSE73461 z-reference analyses and four GSE72810 z-reference, case-definition and probe-collapse analyses, all 30 module estimates retained the expected direction (Figure S1A). Twenty-four estimates passed false-discovery-rate correction and 25 rank-biserial confidence intervals excluded zero. GSE72810 score representations were highly concordant; the minimum Pearson correlation was 0.9874 and the minimum Spearman correlation was 0.9814.

The GSVA analysis retained all expected directions but showed non-uniform inferential support (Figure S1B). BACT_M2, VIR_M1a and VIR_M1b remained supported under both mean-z and GSVA scoring. BACT_M1 was borderline under mean-z scoring but gained confidence-interval and adjusted-P-value support under GSVA. In contrast, VIR_M2 was supported under mean-z scoring but was near zero and statistically unsupported under GSVA in both reference populations. VIR_M2 is therefore scoring-method-sensitive rather than uniformly robust across algorithms.

## Exhaustive deletion analysis supports distributed module signal

The leave-one/two-gene analysis evaluated 29,826 module variants across the two GSE73461 scoring populations (Figure S1C). Every variant retained the expected module direction. The minimum Pearson correlation with the corresponding complete-module score was 0.9940. These results indicate that the observed module behaviour was not driven by removal-sensitive dependence on one gene or one gene pair, while not establishing causal sufficiency of individual genes.
"""

discussion = """# Discussion

This study evaluated whether biologically curated whole-blood host-response modules discovered in GSE211567 remained coherent when their definitions, directions and scoring rules were frozen before external analysis. All five modules retained their expected directions in both GSE73461 and GSE72810. Four modules - BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 - had confidence intervals excluding zero and passed adjusted-significance thresholds in both cohorts. BACT_M1 was directionally concordant but borderline in each cohort, indicating a reproducible direction with less stable inferential support.

The viral-associated modules showed the strongest transportability. VIR_M1a and VIR_M1b captured broad antiviral, interferon-stimulated and viral-restriction programmes, while VIR_M2 represented cytokine and innate immune regulation. Their cross-cohort behaviour is consistent with the central role of interferon-linked responses in viral infection and with prior studies in which interferon-inducible biomarkers contributed to viral-versus-bacterial discrimination [3,4,18]. BACT_M2 also transported consistently, supporting a bacterial-associated mitochondrial respiration and oxidative-phosphorylation programme in these datasets and aligning with evidence that inflammatory activation can remodel leukocyte immunometabolism [19,20].

The sensitivity analyses refine rather than uniformly strengthen this interpretation. Direction was stable across z-reference populations, GSE72810 case definitions and probe handling, and GSE72810 score correlations remained high. Exhaustive deletion analysis also supported a distributed module signal. However, GSVA changed inferential support for two modules: BACT_M1 became supported, whereas VIR_M2 lost statistical support despite retaining the expected sign. Directional robustness, effect-size robustness and statistical robustness should therefore be reported as related but distinct properties.

The principal contribution is not a diagnostic classifier, but a transparent framework for testing fixed biological-module transportability. Freezing modules before projection and prohibiting gene reselection, sign reversal, reweighting and model retraining reduces rediscovery bias. Hodges-Lehmann shifts, rank-biserial effects, confidence intervals, cross-platform projection and deletion analyses provide complementary evidence about the magnitude and stability of the transported programmes.

Several limitations remain. Public metadata and infection adjudication were imperfect, and the cohorts differed in age, syndrome, pathogen composition, platform and preprocessing. Whole-blood scores may reflect both cell-composition changes and cell-intrinsic activation. The GSE72810 and GSE73461 GEO sample accession sets were disjoint and were measured on different Illumina platforms, but direct participant overlap could not be assessed because participant identifiers were not deposited; the studies also arose from the same broad investigator network. GSE72810 should therefore not be treated as a fully investigator-independent replication cohort. The retrospective analyses do not establish clinical performance, clinical readiness or causal mechanisms. Prospective, investigator-independent and multi-cohort studies are required to determine how these modules behave across age groups, syndromes, pathogens, sampling times and treatment contexts.
"""

text = replace_section(
    text,
    "## Abstract",
    "# Introduction",
    abstract,
)

text = replace_section(
    text,
    "# Methods",
    "# Results",
    methods,
)

text = replace_section(
    text,
    "# Results",
    "# Discussion",
    results,
)

text = replace_section(
    text,
    "# Discussion",
    "# Figure captions",
    discussion,
)

existing_figure_section = section_between(
    text,
    "# Figure captions",
    "# Table 1",
)

figure3_body = caption_body(
    figure3_caption_file
)

figure_s1_body = caption_body(
    figure_s1_caption_file
)

figure_section = (
    existing_figure_section
    + "\n\n"
    + "## Figure 3. Cross-cohort validation of locked module effects "
    "in GSE73461 and GSE72810\n\n"
    + figure3_body
    + "\n\n"
    + "## Figure S1. Sensitivity and robustness of locked "
    "host-response modules\n\n"
    + figure_s1_body
)

text = replace_section(
    text,
    "# Figure captions",
    "# Table 1",
    figure_section,
)

table2_lines = [
    "# Table 2",
    "",
    "## Title",
    "",
    "Cross-cohort Hodges-Lehmann effects for the five locked "
    "host-response modules",
    "",
    "## Editable table",
    "",
    "| Module | GSE73461 primary effect | GSE73461 BH-adjusted P | "
    "GSE72810 primary effect | GSE72810 BH-adjusted P | "
    "Expected direction in both cohorts | CI excludes zero in both | "
    "FDR significant in both | Interpretation |",
    "|---|---:|---:|---:|---:|:---:|:---:|:---:|---|",
]

for row in cross_rows:
    table2_lines.append(
        "| "
        + " | ".join(
            [
                clean_markdown_cell(
                    row["final_module_id"]
                ),
                clean_markdown_cell(
                    row["gse73461_primary_result"]
                ),
                clean_markdown_cell(
                    row["gse73461_bh_p_formatted"]
                ),
                clean_markdown_cell(
                    row["gse72810_primary_result"]
                ),
                clean_markdown_cell(
                    row["gse72810_bh_p_formatted"]
                ),
                (
                    "Yes"
                    if truth(row["both_direction_retained"])
                    else "No"
                ),
                (
                    "Yes"
                    if truth(row["both_hl_ci_exclude_zero"])
                    else "No"
                ),
                (
                    "Yes"
                    if truth(row["both_fdr_significant"])
                    else "No"
                ),
                clean_markdown_cell(
                    row["cross_cohort_interpretation"]
                ),
            ]
        )
        + " |"
    )

table2_lines.extend(
    [
        "",
        "## Notes",
        "",
        "Effects are Hodges-Lehmann bacterial-minus-viral location "
        "shifts with bootstrap 95% confidence intervals. Positive values "
        "indicate bacterial-higher scores and negative values indicate "
        "viral-higher scores. Benjamini-Hochberg adjustment was applied "
        "across the five modules within each cohort.",
    ]
)

table2 = "\n".join(table2_lines)

text = replace_once(
    text,
    "# Supplementary material",
    table2 + "\n\n# Supplementary material",
    "Supplementary-material insertion point",
)

supplementary = """# Supplementary material

Supplementary Tables S1-S5 retain the original external-cohort search register, locked GSE211567 module definitions, GSE73461 identifier coverage and probe choices, GSE73461 sample-level scores, and complete GSE73461 primary and z-reference sensitivity statistics.

Supplementary Table S6 provides the GSE72810 cohort audit, sample-classification framework and locked primary and expanded contrasts. Supplementary Table S7 provides GSE72810 Entrez reconciliation, module coverage, missing genes and frozen representative-probe choices. Supplementary Table S8 provides GSE72810 sample-level scores, primary effects, bootstrap confidence intervals and case-definition, z-reference and probe-collapse sensitivity results. Supplementary Table S9 provides the harmonised GSE73461-GSE72810 cross-cohort effect-size source data and summary. Supplementary Table S10 provides the GSE73461 mean-z/GSVA comparison and exhaustive leave-one/two-gene robustness results.

Supplementary Figure S1 presents z-reference, case-definition and probe-collapse sensitivity, mean-z versus GSVA scoring-method sensitivity, and exhaustive leave-one/two-gene robustness.
"""

text = replace_section(
    text,
    "# Supplementary material",
    "# Transparency declaration",
    supplementary,
)

data_availability = f"""## Data availability

This study reanalysed publicly available transcriptomic datasets. The discovery analysis used GSE211567, the formal external projection used GSE73461, and the second accession-level and cross-platform validation used GSE72810 [12,13,{gse72810_reference_number}]. Candidate or technical-rehearsal datasets considered during workflow development included GSE161731, GSE261482 and GSE68310. Dataset accession numbers, cohort-lock decisions, analysis boundaries, mapping outputs and interpretation safeguards are recorded in the repository decision logs and supplementary materials.
"""

text = replace_section(
    text,
    "## Data availability",
    "## Code availability",
    data_availability,
)

code_availability = """## Code availability

Analysis scripts, decision logs, quality gates, source-data tables, manuscript-facing figures and supplementary outputs are organised in the public project repository at `https://github.com/rmaghembe1/host-response-module-transportability`. Revision-round code and outputs are maintained on the dedicated revision branch and will be synchronised with the public repository before resubmission.
"""

text = replace_section(
    text,
    "## Code availability",
    "## Author contributions",
    code_availability,
)

acknowledgements = """## Acknowledgements

The author thanks the investigators and participants of the public transcriptomic studies reanalysed in this work, including GSE211567, GSE73461 and GSE72810. The author also acknowledges the public repositories and database maintainers that made these datasets available for secondary analysis. This acknowledgement does not imply endorsement of the present analysis by the original dataset generators.
"""

text = replace_section(
    text,
    "## Acknowledgements",
    "# Declaration of generative AI and AI-assisted technologies in the manuscript preparation process",
    acknowledgements,
)

text = re.sub(
    r"^# Complete Manuscript Draft.*$",
    "# Complete Manuscript Draft v1.7 - Revision Round 1 Integrated",
    text,
    count=1,
    flags=re.MULTILINE,
)

gse72810_reference = (
    f"[{gse72810_reference_number}] National Center for Biotechnology "
    "Information. Gene Expression Omnibus accession GSE72810. "
    "Available from: "
    "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810"
)

if "Gene Expression Omnibus accession GSE72810" in text:
    raise RuntimeError(
        "A GSE72810 reference already exists unexpectedly."
    )

text = text.rstrip() + "\n\n" + gse72810_reference + "\n"

text = "\n".join(
    line.rstrip()
    for line in text.splitlines()
).rstrip() + "\n"

out_dir.mkdir(
    parents=True,
    exist_ok=True,
)

report_file.parent.mkdir(
    parents=True,
    exist_ok=True,
)

session_file.parent.mkdir(
    parents=True,
    exist_ok=True,
)

target.write_text(
    text,
    encoding="utf-8",
)

source_sha_after = sha256_file(source)
target_sha_after = sha256_file(target)

diff_lines = list(
    difflib.unified_diff(
        source_text.splitlines(),
        text.splitlines(),
        fromfile=str(source.relative_to(root)),
        tofile=str(target.relative_to(root)),
        lineterm="",
    )
)

diff_file.write_text(
    "\n".join(diff_lines) + "\n",
    encoding="utf-8",
)

supplement_rows = [
    {
        "item_id": "Table S1",
        "content": "External cohort search and lock register",
        "revision_status": "retained",
    },
    {
        "item_id": "Table S2",
        "content": "Locked GSE211567 module definitions",
        "revision_status": "retained",
    },
    {
        "item_id": "Table S3",
        "content": "GSE73461 mapping, coverage and probe choices",
        "revision_status": "retained",
    },
    {
        "item_id": "Table S4",
        "content": "GSE73461 sample-level module scores",
        "revision_status": "retained",
    },
    {
        "item_id": "Table S5",
        "content": "GSE73461 primary and z-reference statistics",
        "revision_status": "retained",
    },
    {
        "item_id": "Table S6",
        "content": "GSE72810 cohort and case-classification audit",
        "revision_status": "new",
    },
    {
        "item_id": "Table S7",
        "content": "GSE72810 mapping, coverage and probes",
        "revision_status": "new",
    },
    {
        "item_id": "Table S8",
        "content": "GSE72810 scores, effects and sensitivities",
        "revision_status": "new",
    },
    {
        "item_id": "Table S9",
        "content": "Cross-cohort effect-size source data",
        "revision_status": "new",
    },
    {
        "item_id": "Table S10",
        "content": "GSVA and gene-deletion robustness",
        "revision_status": "new",
    },
    {
        "item_id": "Figure S1",
        "content": "Fixed-module sensitivity and robustness",
        "revision_status": "new",
    },
]

write_tsv(
    supplement_map_file,
    supplement_rows,
    [
        "item_id",
        "content",
        "revision_status",
    ],
)

both_direction = sum(
    truth(row["both_direction_retained"])
    for row in cross_rows
)

both_supported = sum(
    truth(row["both_fdr_significant"])
    for row in cross_rows
)

limitation_sentence = (
    "The GSE72810 and GSE73461 GEO sample accession sets were "
    "disjoint and the cohorts were measured on different Illumina "
    "array platforms. However, direct participant overlap could not "
    "be assessed because participant identifiers were not deposited, "
    "and the studies arose from the same broad investigator network."
)

checks: List[Dict[str, object]] = []

add_check(
    checks,
    "Protected v1.6 checksum matched before integration",
    source_sha_before == EXPECTED_BASELINE_SHA256,
    source_sha_before,
    EXPECTED_BASELINE_SHA256,
)

add_check(
    checks,
    "Protected v1.6 checksum remained unchanged",
    source_sha_after == EXPECTED_BASELINE_SHA256,
    source_sha_after,
    EXPECTED_BASELINE_SHA256,
)

add_check(
    checks,
    "v1.7 initially matched the protected baseline",
    target_sha_before == EXPECTED_BASELINE_SHA256,
    target_sha_before,
    EXPECTED_BASELINE_SHA256,
)

add_check(
    checks,
    "v1.7 changed after integration",
    target_sha_after != target_sha_before,
    target_sha_after,
    "different from baseline",
)

add_check(
    checks,
    "Structured mapping decision contained 313 locked instances",
    integer_field(
        mapping_decision,
        "locked_module_gene_instances",
    )
    == 313,
    mapping_decision["locked_module_gene_instances"],
    313,
)

add_check(
    checks,
    "Structured mapping decision contained 303 mapped instances",
    integer_field(
        mapping_decision,
        "mapped_gene_instances",
    )
    == 303,
    mapping_decision["mapped_gene_instances"],
    303,
)

add_check(
    checks,
    "Structured mapping quality gate passed",
    mapping_decision["quality_gate"] == "PASS",
    mapping_decision["quality_gate"],
    "PASS",
)

add_check(
    checks,
    "Five locked modules passed mapping coverage checks",
    len(coverage_rows) == 5,
    len(coverage_rows),
    5,
)

add_check(
    checks,
    "Five cross-cohort effects retained direction",
    both_direction == 5,
    both_direction,
    5,
)

add_check(
    checks,
    "Four modules were supported in both cohorts",
    both_supported == 4,
    both_supported,
    4,
)

add_check(
    checks,
    "Manuscript contains GSE72810",
    text.count("GSE72810") >= 10,
    text.count("GSE72810"),
    "at least 10",
)

add_check(
    checks,
    "Manuscript contains Figure 3",
    text.count("Figure 3") >= 2,
    text.count("Figure 3"),
    "at least 2",
)

add_check(
    checks,
    "Manuscript contains Figure S1",
    text.count("Figure S1") >= 2,
    text.count("Figure S1"),
    "at least 2",
)

add_check(
    checks,
    "Manuscript contains one Table 2 heading",
    count_pattern(text, r"^# Table 2$") == 1,
    count_pattern(text, r"^# Table 2$"),
    1,
)

add_check(
    checks,
    "Supplementary inventory extends through Table S10",
    "Supplementary Table S10" in text,
    "Supplementary Table S10" in text,
    True,
)

add_check(
    checks,
    "Exact cohort-independence limitation is present",
    limitation_sentence in text,
    limitation_sentence in text,
    True,
)

add_check(
    checks,
    "No fully independent GSE72810 claim is present",
    not re.search(
        r"(independent\s+GSE72810|GSE72810\s+was\s+independent)",
        text,
        flags=re.IGNORECASE,
    ),
    bool(
        re.search(
            r"(independent\s+GSE72810|GSE72810\s+was\s+independent)",
            text,
            flags=re.IGNORECASE,
        )
    ),
    False,
)

for heading in [
    "# Methods",
    "# Results",
    "# Discussion",
    "# Figure captions",
    "# Table 1",
    "# Table 2",
    "# Supplementary material",
    "# References",
]:
    add_check(
        checks,
        f"Heading occurs exactly once: {heading}",
        count_pattern(
            text,
            rf"^{re.escape(heading)}$",
        )
        == 1,
        count_pattern(
            text,
            rf"^{re.escape(heading)}$",
        ),
        1,
    )

add_check(
    checks,
    "GSE72810 GEO reference was added once",
    text.count(
        "Gene Expression Omnibus accession GSE72810"
    )
    == 1,
    text.count(
        "Gene Expression Omnibus accession GSE72810"
    ),
    1,
)

add_check(
    checks,
    "New reference number is unique",
    count_pattern(
        text,
        rf"^\[{gse72810_reference_number}\]\s",
    )
    == 1,
    count_pattern(
        text,
        rf"^\[{gse72810_reference_number}\]\s",
    ),
    1,
)

add_check(
    checks,
    "No TODO or manuscript placeholder remains",
    not re.search(
        r"\bTODO\b|\[REF\]|\[INSERT\b",
        text,
        flags=re.IGNORECASE,
    ),
    bool(
        re.search(
            r"\bTODO\b|\[REF\]|\[INSERT\b",
            text,
            flags=re.IGNORECASE,
        )
    ),
    False,
)

add_check(
    checks,
    "No trailing whitespace remains",
    all(
        line == line.rstrip()
        for line in text.splitlines()
    ),
    "none detected",
    "none",
)

add_check(
    checks,
    "Manuscript ends with a newline",
    text.endswith("\n"),
    text.endswith("\n"),
    True,
)

add_check(
    checks,
    "Unified diff was generated",
    diff_file.is_file() and diff_file.stat().st_size > 0,
    (
        diff_file.stat().st_size
        if diff_file.exists()
        else 0
    ),
    "non-empty",
)

quality_pass = all(
    bool(row["pass"])
    for row in checks
)

write_tsv(
    quality_file,
    checks,
    [
        "check_id",
        "check_description",
        "pass",
        "observed",
        "expected",
    ],
)

summary_rows = [
    {
        "total_checks": len(checks),
        "passed_checks": sum(
            bool(row["pass"])
            for row in checks
        ),
        "failed_checks": sum(
            not bool(row["pass"])
            for row in checks
        ),
        "source_sha256": source_sha_after,
        "target_sha256_before": target_sha_before,
        "target_sha256_after": target_sha_after,
        "source_lines": len(source_text.splitlines()),
        "target_lines": len(text.splitlines()),
        "mapping_locked_instances": mapping_decision[
            "locked_module_gene_instances"
        ],
        "mapping_mapped_instances": mapping_decision[
            "mapped_gene_instances"
        ],
        "gse72810_references": text.count("GSE72810"),
        "figure3_references": text.count("Figure 3"),
        "figure_s1_references": text.count("Figure S1"),
        "table2_rows": len(cross_rows),
        "gse72810_reference_number": gse72810_reference_number,
        "quality_gate": (
            "PASS"
            if quality_pass
            else "REVIEW"
        ),
        "final_status": (
            "READY_FOR_MANUSCRIPT_DIFF_REVIEW"
            if quality_pass
            else "MANUSCRIPT_INTEGRATION_REVIEW_REQUIRED"
        ),
    }
]

write_tsv(
    summary_file,
    summary_rows,
    list(summary_rows[0].keys()),
)

report_lines = [
    "# Complete manuscript v1.7 Revision Round 1 integration report",
    "",
    "## Structured evidence gates",
    "",
    "- GSE72810 mapping validation used the structured Entrez "
    "reconciliation decision TSV rather than prose-token matching.",
    "- Locked module-gene instances: 313.",
    "- Mapped instances: 303.",
    "- Unmapped instances: 10.",
    "- All five modules passed the 70% coverage threshold.",
    "",
    "## Integrated content",
    "",
    "- Revised Abstract, Methods, Results and Discussion.",
    "- Added GSE72810 cross-platform validation.",
    "- Added Figure 3 and Figure S1 captions.",
    "- Added editable cross-cohort Table 2.",
    "- Extended supplementary numbering through Table S10.",
    "- Updated data, code and acknowledgement statements.",
    "- Added the participant-overlap and investigator-network limitation.",
    f"- Added GSE72810 as reference [{gse72810_reference_number}].",
    "",
    "## Locked findings",
    "",
    f"- Expected direction retained in {both_direction}/5 modules.",
    f"- FDR support in both cohorts for {both_supported}/5 modules.",
    "- All 30 reference/case/probe sensitivity estimates retained direction.",
    "- All 29,826 deletion variants retained direction.",
    "- Minimum deletion Pearson correlation was 0.9940.",
    "",
    "## Quality gate",
    "",
    f"- Checks passed: "
    f"{sum(bool(row['pass']) for row in checks)}/{len(checks)}.",
    f"- Quality gate: "
    f"`{'PASS' if quality_pass else 'REVIEW'}`.",
    f"- Status: "
    f"`{'READY_FOR_MANUSCRIPT_DIFF_REVIEW' if quality_pass else 'MANUSCRIPT_INTEGRATION_REVIEW_REQUIRED'}`.",
]

report_file.write_text(
    "\n".join(report_lines).rstrip() + "\n",
    encoding="utf-8",
)

session_lines = [
    f"python_version\t{platform.python_version()}",
    f"python_implementation\t{platform.python_implementation()}",
    f"platform\t{platform.platform()}",
    f"executable\t{sys.executable}",
    f"script\t{Path(__file__).resolve()}",
    f"source_sha256\t{source_sha_after}",
    f"target_sha256_before\t{target_sha_before}",
    f"target_sha256_after\t{target_sha_after}",
    f"mapping_decision_file\t{mapping_decision_file}",
    f"mapping_coverage_file\t{mapping_coverage_file}",
]

session_file.write_text(
    "\n".join(session_lines) + "\n",
    encoding="utf-8",
)

print("===== MANUSCRIPT V1.7 INTEGRATION =====")
print(
    "mapping_locked_instances\t"
    f"{mapping_decision['locked_module_gene_instances']}"
)
print(
    "mapping_mapped_instances\t"
    f"{mapping_decision['mapped_gene_instances']}"
)
print(f"source_lines\t{len(source_text.splitlines())}")
print(f"target_lines\t{len(text.splitlines())}")
print(f"gse72810_references\t{text.count('GSE72810')}")
print(f"figure3_references\t{text.count('Figure 3')}")
print(f"figure_s1_references\t{text.count('Figure S1')}")
print(f"table2_rows\t{len(cross_rows)}")
print(
    "gse72810_reference_number\t"
    f"{gse72810_reference_number}"
)
print(
    "quality_checks_passed\t"
    f"{sum(bool(row['pass']) for row in checks)}/{len(checks)}"
)
print(
    "quality_gate\t"
    f"{'PASS' if quality_pass else 'REVIEW'}"
)
print(
    "final_status\t"
    + (
        "READY_FOR_MANUSCRIPT_DIFF_REVIEW"
        if quality_pass
        else "MANUSCRIPT_INTEGRATION_REVIEW_REQUIRED"
    )
)
print(f"target\t{target.relative_to(root)}")
print(f"quality_summary\t{summary_file.relative_to(root)}")
print(f"report\t{report_file.relative_to(root)}")
print(f"diff\t{diff_file.relative_to(root)}")

if not quality_pass:
    raise RuntimeError(
        "The manuscript integration failed one or more quality checks."
    )
