#!/usr/bin/env python3

"""
GSE261482 external projection candidate feasibility audit.

Purpose:
- Audit GSE261482 as a conditional external projection/generalizability candidate.
- Inspect GEO metadata, sample structure, group-label clues and supplementary-file availability.
- Do not score modules, lock the cohort, or make biological/validation claims.
"""

from __future__ import annotations

import gzip
import hashlib
import html
import re
from pathlib import Path
from datetime import datetime
import pandas as pd


RAW_DIR = Path("data/metadata_raw/GSE261482")
OUT_DIR = Path("results/external_projection_candidate_audit/GSE261482")
HARM_DIR = Path("data/metadata_harmonized")
DOCS_DIR = Path("docs")
OUT_DIR.mkdir(parents=True, exist_ok=True)
HARM_DIR.mkdir(parents=True, exist_ok=True)
DOCS_DIR.mkdir(parents=True, exist_ok=True)

SOFT = RAW_DIR / "GSE261482_family.soft.gz"
MATRIX = RAW_DIR / "GSE261482_series_matrix.txt.gz"
SUPP_INDEX = RAW_DIR / "GSE261482_supplementary_file_index.html"


def sha256_file(path: Path) -> str:
    if not path.exists() or path.stat().st_size == 0:
        return ""
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def open_text_maybe_gzip(path: Path):
    if not path.exists() or path.stat().st_size == 0:
        raise FileNotFoundError(path)
    if path.suffix == ".gz":
        return gzip.open(path, "rt", errors="replace")
    return path.open("rt", errors="replace")


def parse_soft_samples(path: Path) -> pd.DataFrame:
    samples = []
    current = None

    with open_text_maybe_gzip(path) as f:
        for raw in f:
            line = raw.rstrip("\n\r")

            if line.startswith("^SAMPLE = "):
                if current:
                    samples.append(current)
                current = {"sample_record": line.split("=", 1)[1].strip()}
                continue

            if current is None:
                continue

            if line.startswith("!Sample_"):
                key, _, value = line.partition("=")
                key = key.replace("!Sample_", "").strip()
                value = value.strip()

                if key == "characteristics_ch1":
                    current.setdefault("characteristics_ch1", []).append(value)
                elif key == "supplementary_file":
                    current.setdefault("supplementary_file", []).append(value)
                elif key == "relation":
                    current.setdefault("relation", []).append(value)
                else:
                    if key in current:
                        current[key] = str(current[key]) + " | " + value
                    else:
                        current[key] = value

    if current:
        samples.append(current)

    rows = []
    for s in samples:
        row = {}
        for k, v in s.items():
            row[k] = " | ".join(v) if isinstance(v, list) else v

        for item in s.get("characteristics_ch1", []):
            if ":" in item:
                ck, cv = item.split(":", 1)
                ck = re.sub(r"[^A-Za-z0-9_]+", "_", ck.strip().lower()).strip("_")
                row[f"characteristics_{ck}"] = cv.strip()

        rows.append(row)

    return pd.DataFrame(rows)


def parse_series_matrix_header(path: Path) -> pd.DataFrame:
    if not path.exists() or path.stat().st_size == 0:
        return pd.DataFrame()

    records = {}
    with open_text_maybe_gzip(path) as f:
        for raw in f:
            line = raw.rstrip("\n\r")
            if line.startswith("!series_matrix_table_begin"):
                break
            if not line.startswith("!Sample_"):
                continue
            parts = line.split("\t")
            field = parts[0].replace("!Sample_", "")
            vals = [p.strip().strip('"') for p in parts[1:]]
            records[field] = vals

    if not records:
        return pd.DataFrame()

    max_len = max(len(v) for v in records.values())
    padded = {k: v + [""] * (max_len - len(v)) for k, v in records.items()}
    return pd.DataFrame(padded)


def extract_supplementary_links(path: Path) -> pd.DataFrame:
    if not path.exists() or path.stat().st_size == 0:
        return pd.DataFrame(columns=["supplementary_file"])
    text = path.read_text(errors="replace")
    links = re.findall(r'href="([^"]+)"', text)
    links = [html.unescape(x) for x in links]
    links = [x for x in links if x not in {"../", "/"} and not x.startswith("?")]
    return pd.DataFrame({"supplementary_file": sorted(set(links))})


def keyword_count(df: pd.DataFrame, pattern: str) -> int:
    if df.empty:
        return 0
    joined = df.astype(str).agg(" ".join, axis=1)
    return int(joined.str.contains(pattern, case=False, regex=True, na=False).sum())


def main() -> None:
    file_audit = pd.DataFrame([{
        "file": str(p),
        "exists": p.exists(),
        "size_bytes": p.stat().st_size if p.exists() else 0,
        "sha256": sha256_file(p),
    } for p in [SOFT, MATRIX, SUPP_INDEX]])

    soft_df = parse_soft_samples(SOFT) if SOFT.exists() and SOFT.stat().st_size > 0 else pd.DataFrame()
    matrix_df = parse_series_matrix_header(MATRIX) if MATRIX.exists() and MATRIX.stat().st_size > 0 else pd.DataFrame()
    supp_df = extract_supplementary_links(SUPP_INDEX)

    soft_df.to_csv(HARM_DIR / "GSE261482_GEO_family_SOFT_sample_metadata_flattened.tsv", sep="\t", index=False)
    matrix_df.to_csv(HARM_DIR / "GSE261482_series_matrix_sample_metadata.tsv", sep="\t", index=False)
    supp_df.to_csv(OUT_DIR / "GSE261482_supplementary_file_index.tsv", sep="\t", index=False)
    file_audit.to_csv(OUT_DIR / "GSE261482_raw_file_audit.tsv", sep="\t", index=False)

    if not soft_df.empty:
        field_presence = pd.DataFrame({
            "field": soft_df.columns,
            "nonmissing_count": [int(soft_df[c].astype(str).replace({"": pd.NA, "nan": pd.NA}).notna().sum()) for c in soft_df.columns],
            "unique_values": [int(soft_df[c].astype(str).nunique(dropna=True)) for c in soft_df.columns],
            "example_values": ["; ".join(soft_df[c].dropna().astype(str).unique()[:5]) for c in soft_df.columns],
        })
    else:
        field_presence = pd.DataFrame(columns=["field", "nonmissing_count", "unique_values", "example_values"])

    field_presence.to_csv(OUT_DIR / "GSE261482_metadata_field_presence.tsv", sep="\t", index=False)

    keyword_patterns = {
        "bacterial_clues": r"bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus",
        "viral_clues": r"viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue",
        "control_clues": r"control|healthy|non.?infect|afebrile",
        "blood_or_pbmc_clues": r"whole blood|blood|pbmc|paxgene|leukocyte|peripheral",
        "pediatric_clues": r"child|children|pediatric|paediatric|infant|neonate|adolescent",
        "rna_seq_clues": r"rna-seq|rnaseq|high throughput sequencing|next generation sequencing|illumina",
        "microarray_clues": r"array|microarray|affymetrix|illumina human",
    }

    clue_df = pd.DataFrame([{
        "clue": name,
        "sample_rows_matching_in_SOFT": keyword_count(soft_df, pat),
        "pattern": pat,
    } for name, pat in keyword_patterns.items()])
    clue_df.to_csv(OUT_DIR / "GSE261482_metadata_keyword_clue_summary.tsv", sep="\t", index=False)

    if not supp_df.empty:
        supp_df["lower"] = supp_df["supplementary_file"].str.lower()
        supp_type_rows = []
        for label, pat in {
            "matrix_or_expression": r"count|counts|matrix|expression|expr|tpm|fpkm|rpkm|normalized|norm",
            "metadata": r"metadata|clinical|sample|phenotype|pheno|annotation",
            "raw_or_fastq_sra": r"fastq|sra|bam|cram|raw",
            "compressed": r"\.gz$|\.zip$|\.tar$|\.tgz$",
        }.items():
            hits = supp_df[supp_df["lower"].str.contains(pat, regex=True, na=False)]["supplementary_file"].tolist()
            supp_type_rows.append({
                "supplementary_file_type_hint": label,
                "n_files": len(hits),
                "example_files": "; ".join(hits[:10]),
            })
        supp_type_df = pd.DataFrame(supp_type_rows)
    else:
        supp_type_df = pd.DataFrame(columns=["supplementary_file_type_hint", "n_files", "example_files"])

    supp_type_df.to_csv(OUT_DIR / "GSE261482_supplementary_file_type_hints.tsv", sep="\t", index=False)

    n_samples = len(soft_df)
    has_soft = not soft_df.empty
    has_matrix = not matrix_df.empty
    n_supp = len(supp_df)

    bacterial_hits = clue_df.loc[clue_df["clue"] == "bacterial_clues", "sample_rows_matching_in_SOFT"].iloc[0]
    viral_hits = clue_df.loc[clue_df["clue"] == "viral_clues", "sample_rows_matching_in_SOFT"].iloc[0]
    blood_hits = clue_df.loc[clue_df["clue"] == "blood_or_pbmc_clues", "sample_rows_matching_in_SOFT"].iloc[0]
    pediatric_hits = clue_df.loc[clue_df["clue"] == "pediatric_clues", "sample_rows_matching_in_SOFT"].iloc[0]

    preliminary_status = "conditional_pending_expression_and_metadata_resolution"
    if not has_soft:
        preliminary_status = "exclude_for_now_no_parseable_GEO_SOFT"
    elif n_samples == 0:
        preliminary_status = "exclude_for_now_no_sample_metadata"
    elif bacterial_hits == 0 or viral_hits == 0:
        preliminary_status = "conditional_or_exclude_pathogen_class_labels_not_yet_confirmed"
    elif blood_hits == 0:
        preliminary_status = "conditional_tissue_source_not_yet_confirmed"
    else:
        preliminary_status = "conditional_candidate_for_deeper_expression_and_metadata_audit"

    decision_df = pd.DataFrame([{
        "candidate_dataset": "GSE261482",
        "candidate_role": "pediatric_generalizability_candidate",
        "n_soft_samples": n_samples,
        "series_matrix_metadata_available": has_matrix,
        "n_supplementary_files_indexed": n_supp,
        "bacterial_metadata_clue_rows": bacterial_hits,
        "viral_metadata_clue_rows": viral_hits,
        "blood_or_pbmc_clue_rows": blood_hits,
        "pediatric_clue_rows": pediatric_hits,
        "preliminary_status": preliminary_status,
        "next_action": "Inspect supplementary expression files and harmonize sample-level pathogen-class metadata before any cohort-lock decision.",
    }])

    decision_df.to_csv(OUT_DIR / "GSE261482_preliminary_external_projection_candidate_decision.tsv", sep="\t", index=False)

    report = DOCS_DIR / "GSE261482_external_projection_candidate_feasibility_audit_report.md"
    report.write_text(
        "\n".join([
            "# GSE261482 External Projection Candidate Feasibility Audit Report",
            "",
            f"- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "- Purpose: audit GSE261482 as a conditional formal external projection/generalizability candidate.",
            "- Boundary: feasibility audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed here.",
            "",
            "## Raw file audit",
            "",
            file_audit.to_string(index=False),
            "",
            "## Metadata summary",
            "",
            f"- Parseable GEO SOFT sample metadata: {has_soft}",
            f"- Number of SOFT samples parsed: {n_samples}",
            f"- Series matrix sample metadata available: {has_matrix}",
            f"- Supplementary files indexed: {n_supp}",
            "",
            "## Metadata keyword clues",
            "",
            clue_df.to_string(index=False),
            "",
            "## Supplementary file type hints",
            "",
            supp_type_df.to_string(index=False),
            "",
            "## Preliminary decision",
            "",
            decision_df.to_string(index=False),
            "",
            "## Interpretation boundary",
            "",
            "- This audit does not lock GSE261482 as a formal projection cohort.",
            "- This audit does not score locked GSE211567 modules.",
            "- A cohort-lock decision requires explicit confirmation of expression matrix availability, identifier type, sample-level pathogen-class metadata and projection suitability.",
            "",
            "## Generated files",
            "",
            "- `data/metadata_harmonized/GSE261482_GEO_family_SOFT_sample_metadata_flattened.tsv`",
            "- `data/metadata_harmonized/GSE261482_series_matrix_sample_metadata.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_raw_file_audit.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_metadata_field_presence.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_metadata_keyword_clue_summary.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_supplementary_file_index.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_supplementary_file_type_hints.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482/GSE261482_preliminary_external_projection_candidate_decision.tsv`",
        ]),
        encoding="utf-8",
    )

    print(f"Wrote report: {report}")
    print(decision_df.to_string(index=False))


if __name__ == "__main__":
    main()
