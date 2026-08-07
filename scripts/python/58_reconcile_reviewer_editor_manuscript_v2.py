#!/usr/bin/env python3

"""
58_reconcile_reviewer_editor_manuscript_v2.py

Purpose
-------
Create a targeted reviewer/editor-reconciled manuscript v2.0 from the locked
v1.9 revision manuscript.

This script addresses the remaining reviewer/editor-facing manuscript gaps:

1. Define "transportability" and "fixed-module projection" in plain language.
2. Replace unnecessary discovery/projection "firewall" jargon.
3. Expand the GSE211567 cohort/design description.
4. Define site-stratified directional concordance explicitly from the
   implemented sign(logFC) rule.
5. Clarify that biological module curation was documented and biologically
   guided rather than mathematically optimized.
6. Give an explicit mathematical definition of the mean-z module score.
7. Add the GSE73461 platform identifier to the cohort description.
8. Improve Figure 1B legend definitions.
9. Revise Figure 2C legend for the reviewer-requested independent-point plot.
10. Simplify selected "frozen" terminology in manuscript-facing prose.
11. Add direct GEO links in the Data Availability statement.
12. Expand the generative-AI declaration to identify ChatGPT/OpenAI, uses,
    validation, and affected materials.
13. Preserve all validated v1.9 quantitative results and the GSE72810
    cross-cohort limitation.

The script does NOT:
- rerun analyses;
- alter module composition;
- alter statistical results;
- modify the locked v1.9 manuscript;
- overwrite historical submitted figures;
- claim that the revision branch has already been pushed publicly.

A final Code Availability present-tense synchronization update should be made
only after the revision branch is actually pushed.
"""

from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path


# ============================================================================
# Locked paths and SHA
# ============================================================================

SOURCE = Path(
    "docs/complete_manuscript_draft_v1.9_revision_round1_final.md"
)

TARGET = Path(
    "docs/complete_manuscript_draft_v2.0_reviewer_editor_reconciled.md"
)

EXPECTED_SOURCE_SHA256 = (
    "4a52cf61559dda16da28d6572408731b4e7425f3d2a7fb118a5882acc9429c94"
)

FIGURE2C_QA = Path(
    "results/revision_round1/GSE73461_revised_Figure2C/"
    "GSE73461_revised_Figure2C_quality_gate.tsv"
)

FIGURE2C_SCRIPT = Path(
    "scripts/R/57_GSE73461_revised_Figure2C_point_plot.R"
)

OUT_DIR = Path(
    "results/revision_round1/manuscript_v2.0_reviewer_editor_reconciliation"
)

QUALITY_GATE = OUT_DIR / "manuscript_v2.0_quality_gate.tsv"

QUALITY_SUMMARY = OUT_DIR / "manuscript_v2.0_quality_summary.tsv"

REPLACEMENT_MANIFEST = OUT_DIR / "manuscript_v2.0_replacement_manifest.tsv"

REPORT = Path(
    "docs/revision_round1/"
    "complete_manuscript_v2.0_reviewer_editor_reconciliation_report.md"
)


# ============================================================================
# Utility functions
# ============================================================================

def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)

    return digest.hexdigest()


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


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
            f"{label}: expected exactly one source occurrence, observed {count}"
        )

    updated = text.replace(old, new, 1)

    manifest.append(
        {
            "replacement_id": f"R{len(manifest) + 1:02d}",
            "label": label,
            "source_occurrences": str(count),
            "status": "APPLIED",
        }
    )

    return updated


def write_tsv(path: Path, rows: list[dict[str, object]]) -> None:

    if not rows:
        fail(f"No rows available for {path}")

    path.parent.mkdir(parents=True, exist_ok=True)

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


def read_figure_qa(path: Path) -> tuple[int, int]:

    with path.open(
        "r",
        encoding="utf-8",
        newline="",
    ) as handle:

        rows = list(
            csv.DictReader(
                handle,
                delimiter="\t",
            )
        )

    if not rows:
        fail("Figure 2C QA table is empty")

    passed = sum(
        str(row.get("pass", "")).strip().upper() == "TRUE"
        for row in rows
    )

    return len(rows), passed


def count_reference_entries(text: str) -> int:

    return len(
        re.findall(
            r"^\[\d+\]\s",
            text,
            flags=re.MULTILINE,
        )
    )


def no_trailing_whitespace(text: str) -> bool:

    for line in text.splitlines():
        if line.endswith(" ") or line.endswith("\t"):
            return False

    return True


# ============================================================================
# Preflight
# ============================================================================

required_files = [
    SOURCE,
    FIGURE2C_QA,
    FIGURE2C_SCRIPT,
]

missing = [
    str(path)
    for path in required_files
    if not path.exists()
]

if missing:
    fail(
        "Missing required file(s): "
        + ", ".join(missing)
    )

if TARGET.exists():
    fail(
        f"Target already exists: {TARGET}. "
        "Refusing to overwrite an existing manuscript."
    )

source_sha_before = sha256_file(SOURCE)

if source_sha_before != EXPECTED_SOURCE_SHA256:
    fail(
        "Locked v1.9 source SHA256 mismatch. "
        f"Observed {source_sha_before}; "
        f"expected {EXPECTED_SOURCE_SHA256}."
    )

figure_qa_total, figure_qa_passed = read_figure_qa(
    FIGURE2C_QA
)

if figure_qa_total != 13 or figure_qa_passed != 13:
    fail(
        "Revised Figure 2C quality gate is not 13/13 PASS."
    )

figure_script_text = FIGURE2C_SCRIPT.read_text(
    encoding="utf-8"
)

if re.search(
    r"\bgeom_(line|path)\s*\(",
    figure_script_text,
):
    fail(
        "Revised Figure 2C script still contains geom_line() or geom_path()."
    )

source_text = SOURCE.read_text(
    encoding="utf-8"
)

text = source_text

manifest: list[dict[str, str]] = []


# ============================================================================
# Replacement 1: manuscript working-version heading
# ============================================================================

text = replace_exact(
    text,
    "# Complete Manuscript Draft v1.9 - Revision Round 1 Final",
    "# Complete Manuscript Draft v2.0 - Reviewer and Editor Reconciled",
    "Update manuscript working-version heading",
    manifest,
)


# ============================================================================
# Replacement 2: simplify article title
# ============================================================================

text = replace_exact(
    text,
    (
        "External transportability of bacterial- and viral-associated "
        "host-response modules: a site-aware public transcriptomic cohort study"
    ),
    (
        "External transportability of bacterial- and viral-associated "
        "host-response modules across public transcriptomic cohorts"
    ),
    "Simplify article title",
    manifest,
)


# ============================================================================
# Replacement 3: plain-language transportability definition
# ============================================================================

old = (
    "A complementary question is whether biologically interpretable response "
    "programmes discovered in one setting retain coherent expected-direction "
    "behaviour when projected as fixed modules into an independent cohort. "
    "This is distinct from diagnostic validation. A classifier may perform "
    "well because of cohort-specific, technical or sampling structure, "
    "whereas fixed-module projection asks whether predefined gene sets remain "
    "directionally stable outside the discovery dataset without gene "
    "reselection, module redefinition or model retraining [8,10,11]."
)

new = (
    "A complementary question is whether biologically interpretable response "
    "programmes discovered in one setting behave similarly when tested in a "
    "different cohort. In this study, transportability means preservation of "
    "the prespecified biological direction when the same module definition "
    "and scoring rule are applied to another dataset. Fixed-module projection "
    "means applying predefined gene sets to an external dataset without "
    "changing their genes, expected directions or weights and without "
    "retraining a model. This is distinct from diagnostic validation. A "
    "classifier may perform well because of cohort-specific, technical or "
    "sampling structure, whereas the present analysis asks whether the same "
    "biological modules retain their expected bacterial-higher or viral-higher "
    "behaviour outside the discovery dataset [8,10,11]."
)

text = replace_exact(
    text,
    old,
    new,
    "Define transportability and fixed-module projection in plain language",
    manifest,
)


# ============================================================================
# Replacement 4: simplify discovery/projection jargon in Introduction
# ============================================================================

old = (
    "Public infection transcriptomic cohorts are valuable for this purpose "
    "but require safeguards because samples may differ by geography, clinical "
    "syndrome, pathogen spectrum, platform, preprocessing and case definition "
    "[7,9,11]. Site-aware discovery can reduce the risk that "
    "bacterial-versus-viral contrasts merely capture stratum-specific "
    "structure. A strict discovery/projection firewall further reduces "
    "overclaiming by locking modules and scoring rules before external "
    "projection."
)

new = (
    "Public infection transcriptomic cohorts are valuable for this purpose, "
    "but samples may differ by geography, clinical syndrome, pathogen "
    "spectrum, platform, preprocessing and case definition [7,9,11]. "
    "Examining the discovery contrast separately within the available "
    "geographic strata can reduce the risk that a pooled bacterial-versus-viral "
    "signal is driven mainly by one setting. The study therefore kept "
    "discovery and external testing separate: module definitions, expected "
    "directions and scoring rules were fixed before either external cohort "
    "was analysed."
)

text = replace_exact(
    text,
    old,
    new,
    "Replace Introduction firewall jargon",
    manifest,
)


# ============================================================================
# Replacement 5: simplify study-design paragraph
# ============================================================================

old = (
    "This study used a staged transcriptomic transportability design with a "
    "strict discovery/projection firewall. GSE211567 was used for discovery, "
    "biological interpretation and module locking. GSE73461 was used as the "
    "formal external projection cohort only after final module definitions, "
    "directions and scoring rules had been fixed. GSE72810 was subsequently "
    "analysed as a second accession-level and sample-level cohort providing "
    "cross-platform validation of the locked modules. External datasets were "
    "not used to reselect genes, rename modules, alter module composition, "
    "tune weights or train a diagnostic classifier."
)

new = (
    "This study used a staged design that kept discovery separate from "
    "external testing. GSE211567 was used for discovery, biological "
    "interpretation and definition of the five modules. GSE73461 was analysed "
    "only after the module genes, expected directions and scoring rules had "
    "been fixed. GSE72810 was subsequently analysed as a second "
    "accession-level and sample-level cohort providing cross-platform "
    "validation. Neither external dataset was used to reselect genes, rename "
    "modules, alter module composition, tune weights or train a diagnostic "
    "classifier."
)

text = replace_exact(
    text,
    old,
    new,
    "Simplify Methods study-design wording",
    manifest,
)


# ============================================================================
# Replacement 6: expand GSE211567 cohort and concordance description
# ============================================================================

old = (
    "GSE211567 metadata and normalised expression data were audited before "
    "modelling [12]. Sample eligibility and the bacterial-versus-viral "
    "discovery design were fixed before differential-expression analysis. "
    "Because GSE211567 contained geographically and clinically distinct "
    "strata, the workflow combined a primary bacterial-versus-viral limma "
    "contrast with site-stratified concordance assessment to prioritise "
    "directionally stable signals."
)

new = (
    "GSE211567 provided the discovery dataset and contained whole-blood "
    "transcriptomic samples from Sri Lanka and the United States [12]. After "
    "metadata and expression-quality auditing, the locked primary discovery "
    "set contained 224 samples: 101 bacterial and 123 viral. The primary "
    "limma model evaluated bacterial versus viral infection while adjusting "
    "for site and sequencing batch, and separate bacterial-versus-viral "
    "models were also fitted within Sri Lanka and the United States. For each "
    "modelled feature, directional concordance was defined as agreement in "
    "the sign of the bacterial-versus-viral log2 fold change between the "
    "contrasts being compared. Percentage directional concordance was the "
    "number of same-sign features divided by the number of compared features, "
    "multiplied by 100. Spearman correlations of log2 fold changes were used "
    "as a complementary measure of ranked effect-size agreement across the "
    "pooled and site-specific analyses."
)

text = replace_exact(
    text,
    old,
    new,
    "Expand GSE211567 cohort and define directional concordance",
    manifest,
)


# ============================================================================
# Replacement 7: clarify biological curation rationale
# ============================================================================

old = (
    "Differential-expression results were treated as a discovery-ranking "
    "layer rather than a diagnostic signature [15]. Positive log2 fold-change "
    "values were interpreted as bacterial-higher and negative values as "
    "viral-higher. Transcript-level features were mapped to gene identifiers, "
    "summarised at gene level and carried into Gene Ontology biological-process "
    "enrichment [16,17]. Redundant enriched terms were reduced and manually "
    "reviewed using a documented biologically guided curation process. Five "
    "modules were frozen before projection: BACT_M1, BACT_M2, VIR_M1a, "
    "VIR_M1b and VIR_M2."
)

new = (
    "Differential-expression results were treated as a discovery-ranking "
    "layer rather than a diagnostic signature [15]. Positive log2 fold-change "
    "values were interpreted as bacterial-higher and negative values as "
    "viral-higher. Transcript-level features were mapped to gene identifiers, "
    "summarised at gene level and carried into Gene Ontology biological-process "
    "enrichment [16,17]. Cross-site directionally supported features were "
    "prioritised, overlapping or redundant enriched terms were grouped, and "
    "candidate biological programmes were reviewed using the documented "
    "curation hierarchy. Module selection was therefore a biologically guided "
    "and reproducible curation step rather than mathematical optimisation for "
    "separation or prediction accuracy. The external-cohort results were not "
    "used to choose or modify module genes. Five modules were fixed before "
    "external testing: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2."
)

text = replace_exact(
    text,
    old,
    new,
    "Clarify GO and biological module curation rationale",
    manifest,
)


# ============================================================================
# Replacement 8: add GSE73461 platform context
# ============================================================================

old = (
    "GSE73461 expression, annotation, metadata and group labels were audited "
    "independently of module discovery [13]. The 52 DefiniteBacterial, 94 "
    "DefiniteViral and 55 Control samples (n = 201) constituted the main "
    "z-score reference population. The primary inferential contrast remained "
    "restricted to the 52 DefiniteBacterial versus 94 DefiniteViral samples; "
    "Control samples contributed to the reference population but not to the "
    "bacterial-versus-viral test. Inflammatory, Kawasaki and Unknown groups "
    "were excluded from both the main z-score reference population and the "
    "primary contrast."
)

new = (
    "GSE73461 expression, annotation, metadata and group labels were audited "
    "independently of module discovery [13]. The cohort was measured on the "
    "Illumina GPL10558 platform. The 52 DefiniteBacterial, 94 DefiniteViral "
    "and 55 Control samples (n = 201) constituted the main z-score reference "
    "population. The primary inferential contrast remained restricted to the "
    "52 DefiniteBacterial versus 94 DefiniteViral samples; Control samples "
    "contributed to the reference population but not to the "
    "bacterial-versus-viral test. Inflammatory, Kawasaki and Unknown groups "
    "were excluded from both the main z-score reference population and the "
    "primary contrast."
)

text = replace_exact(
    text,
    old,
    new,
    "Add GSE73461 platform information",
    manifest,
)


# ============================================================================
# Replacement 9: formal mean-z module-score definition
# ============================================================================

old = (
    "For the primary mean-z analyses, each mapped gene was z-scored within "
    "the locked scoring population and each module score was the unweighted "
    "mean of its available gene-wise z scores. Missing genes were ignored "
    "only after coverage had been documented. No module was retrained, "
    "reweighted or direction-flipped."
)

new = (
    "For the primary mean-z analyses, expression for each mapped gene g in "
    "sample i was standardised within the prespecified reference population "
    "as z_gi = (x_gi - mean_g) / SD_g. For a module containing K mapped and "
    "available genes, the sample-level module score was the unweighted "
    "arithmetic mean, score_i = (1/K) sum_g z_gi. Thus, every available gene "
    "contributed equally to the primary module score. Missing genes were "
    "omitted only after module coverage had been documented. No module was "
    "retrained, reweighted or direction-flipped."
)

text = replace_exact(
    text,
    old,
    new,
    "Add formal module-score definition",
    manifest,
)


# ============================================================================
# Replacement 10: simplify Results heading
# ============================================================================

text = replace_exact(
    text,
    (
        "## GSE211567 discovery identifies site-aware bacterial- and "
        "viral-associated programmes"
    ),
    (
        "## GSE211567 discovery identifies bacterial- and viral-associated "
        "programmes across sites"
    ),
    "Simplify GSE211567 Results heading",
    manifest,
)


# ============================================================================
# Replacement 11: simplify fixed-module Results heading
# ============================================================================

text = replace_exact(
    text,
    "## Conservative biological curation defines five frozen modules",
    "## Conservative biological curation defines five fixed modules",
    "Replace frozen-module Results heading",
    manifest,
)


# ============================================================================
# Replacement 12: simplify GSE72810 Results wording
# ============================================================================

old = (
    "The GSE72810 primary contrast contained 23 definite bacterial and 28 "
    "definite viral samples. Locked-gene coverage remained high after Entrez "
    "reconciliation and representative-probe freezing. All five modules "
    "retained their expected directions."
)

new = (
    "The GSE72810 primary contrast contained 23 definite bacterial and 28 "
    "definite viral samples. Coverage of the predefined module genes remained "
    "high after Entrez reconciliation and prespecified representative-probe "
    "selection. All five modules retained their expected directions."
)

text = replace_exact(
    text,
    old,
    new,
    "Simplify GSE72810 probe-selection wording",
    manifest,
)


# ============================================================================
# Replacement 13: simplify Discussion opening
# ============================================================================

old = (
    "This study evaluated whether biologically curated whole-blood "
    "host-response modules discovered in GSE211567 remained coherent when "
    "their definitions, directions and scoring rules were frozen before "
    "external analysis. All five modules retained their expected directions "
    "in both GSE73461 and GSE72810. Four modules - BACT_M2, VIR_M1a, VIR_M1b "
    "and VIR_M2 - had confidence intervals excluding zero and passed "
    "adjusted-significance thresholds in both cohorts. BACT_M1 was "
    "directionally concordant but borderline in each cohort, indicating a "
    "reproducible direction with less stable inferential support."
)

new = (
    "This study evaluated whether biologically curated whole-blood "
    "host-response modules discovered in GSE211567 retained their "
    "prespecified bacterial-higher or viral-higher behaviour when the same "
    "definitions and scoring rules were applied to two external cohorts. All "
    "five modules retained their expected directions in both GSE73461 and "
    "GSE72810. Four modules - BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 - had "
    "confidence intervals excluding zero and passed adjusted-significance "
    "thresholds in both cohorts. BACT_M1 was directionally concordant but "
    "borderline in each cohort, indicating a reproducible direction with "
    "less stable inferential support."
)

text = replace_exact(
    text,
    old,
    new,
    "Simplify Discussion opening",
    manifest,
)


# ============================================================================
# Replacement 14: simplify Discussion description of fixed modules
# ============================================================================

old = (
    "The principal contribution is not a diagnostic classifier, but a "
    "transparent framework for testing fixed biological-module "
    "transportability. Freezing modules before projection and prohibiting gene "
    "reselection, sign reversal, reweighting and model retraining reduces "
    "rediscovery bias. Hodges-Lehmann shifts, rank-biserial effects, "
    "confidence intervals, cross-platform projection and deletion analyses "
    "provide complementary evidence about the magnitude and stability of the "
    "transported programmes."
)

new = (
    "The principal contribution is not a diagnostic classifier, but a "
    "transparent framework for asking whether predefined biological modules "
    "retain their behaviour in new datasets. Fixing the module genes, "
    "expected directions and scoring rules before external testing, and "
    "prohibiting gene reselection, sign reversal, reweighting and model "
    "retraining, reduces rediscovery bias. Hodges-Lehmann shifts, "
    "rank-biserial effects, confidence intervals, cross-platform testing and "
    "deletion analyses provide complementary evidence about the magnitude and "
    "stability of the observed programmes."
)

text = replace_exact(
    text,
    old,
    new,
    "Simplify Discussion transportability terminology",
    manifest,
)


# ============================================================================
# Replacement 15: strengthen Figure 1B caption definition
# ============================================================================

old = (
    "(B) Site-aware concordance of the GSE211567 bacterial-versus-viral "
    "discovery contrast. Spearman logFC concordance is shown for "
    "pooled-versus-site and site-versus-site comparisons, with directional "
    "concordance annotated for the corresponding all-feature comparisons. "
    "This analysis was used as a stability gate before carrying features "
    "forward into pathway interpretation and module locking."
)

new = (
    "(B) Cross-site concordance of the GSE211567 bacterial-versus-viral "
    "discovery contrast. Spearman correlations summarise ranked agreement of "
    "log2 fold changes between the pooled, Sri Lanka and United States "
    "analyses. Directional concordance is the percentage of compared features "
    "whose bacterial-versus-viral log2 fold changes have the same sign in the "
    "two indicated analyses. This analysis was used to prioritise signals "
    "whose direction was not restricted to a single site before pathway "
    "interpretation and module definition."
)

text = replace_exact(
    text,
    old,
    new,
    "Define Figure 1B directional concordance",
    manifest,
)


# ============================================================================
# Replacement 16: simplify Figure 1C locking terminology
# ============================================================================

old = (
    "(C) Locked GSE211567 discovery modules carried forward as "
    "projection-ready fixed gene sets. Two modules were bacterial-higher, "
    "representing cytoplasmic translation/ribosomal protein activity and "
    "mitochondrial respiration/oxidative phosphorylation. Three modules were "
    "viral-higher, representing broad antiviral/interferon-stimulated defence, "
    "viral restriction/type I interferon signalling and cytokine/innate "
    "immune regulation. Modules were frozen before external projection, with "
    "no later gene reselection or module redefinition."
)

new = (
    "(C) The five predefined GSE211567 discovery modules used in external "
    "testing. Two modules were bacterial-higher, representing cytoplasmic "
    "translation/ribosomal protein activity and mitochondrial "
    "respiration/oxidative phosphorylation. Three modules were viral-higher, "
    "representing broad antiviral/interferon-stimulated defence, viral "
    "restriction/type I interferon signalling and cytokine/innate immune "
    "regulation. Module genes and expected directions were fixed before "
    "external analysis, with no later gene reselection or module redefinition."
)

text = replace_exact(
    text,
    old,
    new,
    "Simplify Figure 1C fixed-module wording",
    manifest,
)


# ============================================================================
# Replacement 17: revise Figure 2C caption for point-based categorical plot
# ============================================================================

old = (
    "(C) BH-adjusted Wilcoxon significance values for the main projection and "
    "the primary-only z-score sensitivity analysis. The dashed line indicates "
    "BH-adjusted P = 0.05. BACT_M1 remained directionally concordant but "
    "borderline, whereas BACT_M2 and all viral-associated modules showed "
    "robust external transportability."
)

new = (
    "(C) BH-adjusted Wilcoxon P values for the main projection and the "
    "primary-only z-score sensitivity analysis are shown as independent "
    "points for each categorical module. Circles denote the main projection "
    "and triangles denote the primary-only z-score sensitivity analysis. The "
    "dashed horizontal line indicates BH-adjusted P = 0.05. The module "
    "categories are not connected because they are distinct predefined gene "
    "sets rather than points on a continuous sequence. BACT_M1 remained "
    "directionally concordant but borderline, whereas BACT_M2 and all three "
    "viral-associated modules passed the adjusted-P-value threshold in both "
    "mean-z analyses."
)

text = replace_exact(
    text,
    old,
    new,
    "Revise Figure 2C caption for independent-point plot",
    manifest,
)


# ============================================================================
# Replacement 18: direct GEO links in Data Availability
# ============================================================================

old = (
    "This study reanalysed publicly available transcriptomic datasets. The "
    "discovery analysis used GSE211567, the formal external projection used "
    "GSE73461, and the second accession-level and cross-platform validation "
    "used GSE72810 [12,13,14]. Candidate or technical-rehearsal datasets "
    "considered during workflow development included GSE161731, GSE261482 "
    "and GSE68310. Dataset accession numbers, cohort-lock decisions, analysis "
    "boundaries, mapping outputs and interpretation safeguards are recorded "
    "in the repository decision logs and supplementary materials."
)

new = (
    "This study reanalysed publicly available transcriptomic datasets from "
    "the NCBI Gene Expression Omnibus. The discovery dataset is GSE211567 "
    "(https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567), the "
    "formal external projection dataset is GSE73461 "
    "(https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461), and the "
    "second accession-level and cross-platform validation dataset is GSE72810 "
    "(https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810) "
    "[12,13,14]. Candidate or technical-rehearsal datasets considered during "
    "workflow development included GSE161731, GSE261482 and GSE68310. "
    "Dataset accession numbers, cohort-selection decisions, analysis "
    "boundaries, mapping outputs and supporting documentation are recorded "
    "in the repository and supplementary materials."
)

text = replace_exact(
    text,
    old,
    new,
    "Add direct GEO URLs to Data Availability",
    manifest,
)


# ============================================================================
# Replacement 19: explicit generative-AI disclosure
# ============================================================================

old = (
    "During the preparation of this manuscript, the author used generative "
    "AI-assisted tools to support editorial organisation, language refinement, "
    "formatting checks and preparation of submission-support materials. The "
    "author reviewed, edited and verified the manuscript content, analyses, "
    "interpretation, references and submission materials, and takes full "
    "responsibility for the final content of the manuscript."
)

new = (
    "During preparation and revision of this manuscript, the author used "
    "ChatGPT, an AI-assisted tool provided by OpenAI, to assist with editorial "
    "organisation, language refinement, workflow planning, code drafting and "
    "checking, formatting checks, and preparation of manuscript and "
    "submission-support materials. AI-generated suggestions were not treated "
    "as scientific evidence. Analysis scripts were executed against the "
    "stated public datasets, and numerical and graphical outputs were checked "
    "using the documented reproducibility, source-lock and quality-control "
    "procedures. The author reviewed and verified the analysis code, results, "
    "references, biological interpretation, figures, tables, manuscript text "
    "and submission materials and takes full responsibility for the final "
    "work."
)

text = replace_exact(
    text,
    old,
    new,
    "Expand generative-AI declaration",
    manifest,
)


# ============================================================================
# Write target before post-write validation
# ============================================================================

OUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)

TARGET.parent.mkdir(
    parents=True,
    exist_ok=True,
)

TARGET.write_text(
    text,
    encoding="utf-8",
    newline="\n",
)

target_sha = sha256_file(
    TARGET
)

source_sha_after = sha256_file(
    SOURCE
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
    "Locked v1.9 source SHA matched",
    source_sha_before == EXPECTED_SOURCE_SHA256,
    source_sha_before,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "Locked v1.9 source remained unchanged",
    source_sha_after == EXPECTED_SOURCE_SHA256,
    source_sha_after,
    EXPECTED_SOURCE_SHA256,
)

add_check(
    "Revised Figure 2C passed all thirteen checks",
    figure_qa_total == 13 and figure_qa_passed == 13,
    f"{figure_qa_passed}/{figure_qa_total}",
    "13/13",
)

add_check(
    "Revised Figure 2C script contains no connecting-line geometry",
    not bool(
        re.search(
            r"\bgeom_(line|path)\s*\(",
            figure_script_text,
        )
    ),
    "none detected",
    "none detected",
)

add_check(
    "Transportability is explicitly defined",
    (
        "transportability means preservation of the prespecified "
        "biological direction"
    ) in text,
    "definition present",
    "definition present",
)

add_check(
    "Fixed-module projection is explicitly defined",
    "Fixed-module projection means applying predefined gene sets" in text,
    "definition present",
    "definition present",
)

add_check(
    "Discovery/projection firewall phrase was removed",
    "discovery/projection firewall" not in text,
    text.count("discovery/projection firewall"),
    0,
)

add_check(
    "GSE211567 locked discovery sample size is stated",
    "locked primary discovery set contained 224 samples" in text,
    "224 samples",
    "224 samples",
)

add_check(
    "GSE211567 bacterial and viral sample counts are stated",
    (
        "101 bacterial and 123 viral" in text
    ),
    "101 bacterial; 123 viral",
    "101 bacterial; 123 viral",
)

add_check(
    "GSE211567 Sri Lanka and United States strata are stated",
    (
        "Sri Lanka" in text
        and "United States" in text
    ),
    "both site names present",
    "both site names present",
)

add_check(
    "Directional concordance uses same-sign log2 fold changes",
    (
        "directional concordance was defined as agreement in the sign "
        "of the bacterial-versus-viral log2 fold change"
    ) in text,
    "sign-based definition present",
    "sign-based definition present",
)

add_check(
    "Percentage directional concordance formula is stated",
    (
        "number of same-sign features divided by the number of compared "
        "features, multiplied by 100"
    ) in text,
    "percentage formula present",
    "percentage formula present",
)

add_check(
    "Biological curation is distinguished from mathematical optimisation",
    (
        "rather than mathematical optimisation for separation or "
        "prediction accuracy"
    ) in text,
    "curation boundary present",
    "curation boundary present",
)

add_check(
    "GSE73461 GPL10558 platform is stated",
    "Illumina GPL10558 platform" in text,
    "GPL10558 present",
    "GPL10558 present",
)

add_check(
    "Formal gene-wise z-score expression is stated",
    "z_gi = (x_gi - mean_g) / SD_g" in text,
    "formula present",
    "formula present",
)

add_check(
    "Formal module mean expression is stated",
    "score_i = (1/K) sum_g z_gi" in text,
    "formula present",
    "formula present",
)

add_check(
    "Figure 1B legend defines directional concordance",
    (
        "Directional concordance is the percentage of compared features "
        "whose bacterial-versus-viral log2 fold changes have the same sign"
    ) in text,
    "definition present",
    "definition present",
)

add_check(
    "Figure 2C legend describes independent categorical points",
    (
        "are shown as independent points for each categorical module"
    ) in text,
    "independent-point description present",
    "independent-point description present",
)

add_check(
    "Figure 2C legend states categories are not connected",
    (
        "The module categories are not connected"
    ) in text,
    "non-connection explanation present",
    "non-connection explanation present",
)

add_check(
    "Direct GSE211567 GEO URL is present",
    (
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567"
    ) in text,
    "URL present",
    "URL present",
)

add_check(
    "Direct GSE73461 GEO URL is present",
    (
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461"
    ) in text,
    "URL present",
    "URL present",
)

add_check(
    "Direct GSE72810 GEO URL is present",
    (
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72810"
    ) in text,
    "URL present",
    "URL present",
)

add_check(
    "AI declaration names ChatGPT and OpenAI",
    (
        "ChatGPT" in text
        and "OpenAI" in text
    ),
    "ChatGPT/OpenAI present",
    "ChatGPT/OpenAI present",
)

add_check(
    "AI declaration states code-related assistance",
    (
        "code drafting and checking" in text
    ),
    "code assistance stated",
    "code assistance stated",
)

add_check(
    "AI declaration states output validation procedures",
    (
        "reproducibility, source-lock and quality-control procedures"
    ) in text,
    "validation procedures stated",
    "validation procedures stated",
)

add_check(
    "GSE73461 main z-score reference remains 201",
    (
        "55 Control samples (n = 201)"
    ) in text,
    "n = 201",
    "n = 201",
)

add_check(
    "GSE72810 main z-score reference remains 146",
    (
        "All 146 samples were retained in the main z-score reference population"
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
    "Exhaustive deletion count remains 29,826",
    "29,826" in text,
    "29,826 present",
    "29,826 present",
)

add_check(
    "Minimum deletion Pearson correlation remains 0.9940",
    "0.9940" in text,
    "0.9940 present",
    "0.9940 present",
)

required_limitation = (
    "The GSE72810 and GSE73461 GEO sample accession sets were disjoint and "
    "were measured on different Illumina platforms, but direct participant "
    "overlap could not be assessed because participant identifiers were not "
    "deposited; the studies also arose from the same broad investigator "
    "network."
)

add_check(
    "Required GSE72810/GSE73461 limitation is preserved",
    required_limitation in text,
    "limitation present",
    "limitation present",
)

add_check(
    "Manuscript does not call GSE72810 fully investigator-independent",
    (
        "GSE72810 should therefore not be treated as a fully "
        "investigator-independent replication cohort."
    ) in text,
    "boundary statement present",
    "boundary statement present",
)

reference_count = count_reference_entries(
    text
)

add_check(
    "Reference count remains 21",
    reference_count == 21,
    reference_count,
    21,
)

add_check(
    "STARD reference remains absent",
    "STARD" not in text,
    text.count("STARD"),
    0,
)

add_check(
    "Target contains no trailing whitespace",
    no_trailing_whitespace(text),
    "clean" if no_trailing_whitespace(text) else "trailing whitespace found",
    "clean",
)

add_check(
    "Target differs from locked v1.9 source",
    target_sha != source_sha_before,
    target_sha,
    "different from source SHA",
)

add_check(
    "Code Availability does not falsely claim revision branch already synchronized",
    (
        "will be synchronised with the public repository before resubmission"
        in text
    ),
    "future-tense synchronization retained",
    "future-tense synchronization retained until push",
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
    "READY_FOR_V2_MANUSCRIPT_DIFF_REVIEW_PENDING_REPOSITORY_SYNC"
    if quality_failed == 0
    else "V2_MANUSCRIPT_RECONCILIATION_REQUIRES_REVIEW"
)


# ============================================================================
# Write audit outputs
# ============================================================================

write_tsv(
    QUALITY_GATE,
    checks,
)

write_tsv(
    REPLACEMENT_MANIFEST,
    manifest,
)

summary_rows = [
    {
        "quality_checks": len(checks),
        "quality_checks_passed": quality_passed,
        "quality_checks_failed": quality_failed,
        "replacements_applied": len(manifest),
        "figure2c_quality_checks_passed": (
            f"{figure_qa_passed}/{figure_qa_total}"
        ),
        "source_sha256": source_sha_before,
        "target_sha256": target_sha,
        "reference_count": reference_count,
        "quality_gate": quality_gate,
        "final_status": final_status,
    }
]

write_tsv(
    QUALITY_SUMMARY,
    summary_rows,
)


# ============================================================================
# Report
# ============================================================================

report_lines = [
    "# Complete Manuscript v2.0 Reviewer/Editor Reconciliation Report",
    "",
    "## Locked source",
    "",
    f"- Source: `{SOURCE}`",
    f"- Source SHA256: `{source_sha_before}`",
    f"- Target: `{TARGET}`",
    f"- Target SHA256: `{target_sha}`",
    "",
    "## Figure 2C prerequisite",
    "",
    (
        f"- Revised Figure 2C QA: "
        f"{figure_qa_passed}/{figure_qa_total} checks passed."
    ),
    "- Revised Script 57 contains no geom_line() or geom_path().",
    "",
    "## Targeted manuscript changes",
    "",
    (
        "- Defined transportability and fixed-module projection in "
        "plain language."
    ),
    (
        "- Replaced unnecessary discovery/projection firewall terminology "
        "with direct descriptions of separation between discovery and "
        "external testing."
    ),
    (
        "- Expanded GSE211567 design description to state the 224-sample "
        "discovery set, bacterial/viral counts, geographic strata, primary "
        "model adjustment and sign-based directional-concordance definition."
    ),
    (
        "- Clarified that GO/module curation was biologically guided and "
        "documented rather than mathematically optimized for predictive "
        "separation."
    ),
    (
        "- Added explicit gene-wise z-score and arithmetic-mean module-score "
        "definitions."
    ),
    "- Added GPL10558 to the GSE73461 cohort description.",
    (
        "- Revised Figure 1B and Figure 2C captions to define the relevant "
        "statistics and categorical point representation."
    ),
    "- Added direct GEO links to the Data Availability statement.",
    (
        "- Expanded the AI declaration to identify ChatGPT/OpenAI, describe "
        "its uses, describe validation of outputs, and state author "
        "responsibility."
    ),
    "",
    "## Preserved scientific results",
    "",
    "- No analysis was rerun by this manuscript-reconciliation script.",
    "- No module genes, expected directions or weights were changed.",
    "- GSE73461 and GSE72810 sample counts were preserved.",
    "- Cross-cohort effect estimates and confidence intervals were preserved.",
    "- GSVA sensitivity conclusions were preserved.",
    "- The 29,826-variant deletion analysis was preserved.",
    (
        "- The limitation concerning participant-level overlap and the shared "
        "broad investigator network was preserved."
    ),
    "",
    "## Code Availability boundary",
    "",
    (
        "The manuscript still states that revision-round code and outputs "
        "will be synchronized before resubmission. This is deliberate: the "
        "script does not claim that a Git push has occurred when it has not "
        "yet been verified. The statement should be converted to present "
        "tense only after repository synchronization is completed."
    ),
    "",
    "## Quality gate",
    "",
    f"- Checks passed: {quality_passed}/{len(checks)}.",
    f"- Quality gate: `{quality_gate}`.",
    f"- Final status: `{final_status}`.",
    "",
    (
        "No unified-diff artifact was generated, avoiding the historical "
        "whitespace/staging problem encountered with earlier audit diffs."
    ),
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

print("===== MANUSCRIPT V2.0 RECONCILIATION =====")
print(f"source_sha256\t{source_sha_before}")
print(f"target_sha256\t{target_sha}")
print(f"replacements_applied\t{len(manifest)}")
print(
    f"figure2c_quality_checks_passed\t"
    f"{figure_qa_passed}/{figure_qa_total}"
)
print(
    f"quality_checks_passed\t"
    f"{quality_passed}/{len(checks)}"
)
print(f"quality_gate\t{quality_gate}")
print(f"reference_count\t{reference_count}")
print(f"final_status\t{final_status}")
print(f"target\t{TARGET}")
print(f"quality_gate_file\t{QUALITY_GATE}")
print(f"quality_summary\t{QUALITY_SUMMARY}")
print(f"replacement_manifest\t{REPLACEMENT_MANIFEST}")
print(f"report\t{REPORT}")

if quality_failed != 0:
    fail(
        f"Manuscript v2.0 failed {quality_failed} quality check(s)."
    )
