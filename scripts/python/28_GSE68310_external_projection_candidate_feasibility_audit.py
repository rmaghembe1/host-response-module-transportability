#!/usr/bin/env python3

"""
GSE68310 external projection candidate feasibility audit.

Purpose:
- Audit GSE68310 as a candidate formal external projection cohort.
- Inspect GEO metadata, sample structure, bacterial/viral/control label clues,
  platform information and supplementary-file availability.
- Do not score modules, lock the cohort, or make validation/biological claims.
"""

from __future__ import annotations

import gzip
import hashlib
import html
import re
from pathlib import Path
from datetime import datetime
import pandas as pd


RAW_DIR = Path("data/metadata_raw/GSE68310")
OUT_DIR = Path("results/external_projection_candidate_audit/GSE68310")
HARM_DIR = Path("data/metadata_harmonized")
DOCS_DIR = Path("docs")

OUT_DIR.mkdir(parents=True, exist_ok=True)
HARM_DIR.mkdir(parents=True, exist_ok=True)
DOCS_DIR.mkdir(parents=True, exist_ok=True)

SOFT = RAW_DIR / "GSE68310_family.soft.gz"
MATRIX = RAW_DIR / "GSE68310_series_matrix.txt.gz"
SUPP_INDEX = RAW_DIR / "GSE68310_supplementary_file_index.html"


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

    soft_df = parse_soft_samples(SOFT)
    matrix_df = parse_series_matrix_header(MATRIX)
    supp_df = extract_supplementary_links(SUPP_INDEX)

    soft_df.to_csv(HARM_DIR / "GSE68310_GEO_family_SOFT_sample_metadata_flattened.tsv", sep="\t", index=False)
    matrix_df.to_csv(HARM_DIR / "GSE68310_series_matrix_sample_metadata.tsv", sep="\t", index=False)
    supp_df.to_csv(OUT_DIR / "GSE68310_supplementary_file_index.tsv", sep="\t", index=False)
    file_audit.to_csv(OUT_DIR / "GSE68310_raw_file_audit.tsv", sep="\t", index=False)

    field_presence = pd.DataFrame({
        "field": soft_df.columns,
        "nonmissing_count": [
            int(soft_df[c].astype(str).replace({"": pd.NA, "nan": pd.NA}).notna().sum())
            for c in soft_df.columns
        ],
        "unique_values": [int(soft_df[c].astype(str).nunique(dropna=True)) for c in soft_df.columns],
        "example_values": ["; ".join(soft_df[c].dropna().astype(str).unique()[:6]) for c in soft_df.columns],
    })
    field_presence.to_csv(OUT_DIR / "GSE68310_metadata_field_presence.tsv", sep="\t", index=False)

    keyword_patterns = {
        "bacterial_clues": r"bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus",
        "viral_clues": r"viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue",
        "control_clues": r"control|healthy|non.?infect|afebrile",
        "blood_or_pbmc_clues": r"whole blood|blood|pbmc|paxgene|leukocyte|peripheral",
        "respiratory_or_febrile_clues": r"respiratory|fever|febrile|acute infection|illness",
        "microarray_clues": r"array|microarray|affymetrix|illumina human",
        "rna_seq_clues": r"rna-seq|rnaseq|high throughput sequencing|next generation sequencing",
    }

    clue_df = pd.DataFrame([{
        "clue": name,
        "sample_rows_matching_in_SOFT": keyword_count(soft_df, pat),
        "pattern": pat,
    } for name, pat in keyword_patterns.items()])
    clue_df.to_csv(OUT_DIR / "GSE68310_metadata_keyword_clue_summary.tsv", sep="\t", index=False)

    if not supp_df.empty:
        supp_df["lower"] = supp_df["supplementary_file"].str.lower()
        supp_type_rows = []
        for label, pat in {
            "matrix_or_expression": r"count|counts|matrix|expression|expr|normalized|norm|series",
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

    supp_type_df.to_csv(OUT_DIR / "GSE68310_supplementary_file_type_hints.tsv", sep="\t", index=False)

    bacterial_hits = int(clue_df.loc[clue_df["clue"] == "bacterial_clues", "sample_rows_matching_in_SOFT"].iloc[0])
    viral_hits = int(clue_df.loc[clue_df["clue"] == "viral_clues", "sample_rows_matching_in_SOFT"].iloc[0])
    blood_hits = int(clue_df.loc[clue_df["clue"] == "blood_or_pbmc_clues", "sample_rows_matching_in_SOFT"].iloc[0])

    if bacterial_hits > 0 and viral_hits > 0 and blood_hits > 0:
        preliminary_status = "conditional_candidate_for_deeper_expression_and_label_audit"
    elif bacterial_hits > 0 and viral_hits > 0:
        preliminary_status = "conditional_tissue_source_needs_confirmation"
    else:
        preliminary_status = "not_ready_until_bacterial_viral_labels_confirmed"

    decision_df = pd.DataFrame([{
        "candidate_dataset": "GSE68310",
        "candidate_role": "formal_external_projection_candidate",
        "n_soft_samples": len(soft_df),
        "series_matrix_metadata_available": not matrix_df.empty,
        "n_supplementary_files_indexed": len(supp_df),
        "bacterial_metadata_clue_rows": bacterial_hits,
        "viral_metadata_clue_rows": viral_hits,
        "blood_or_pbmc_clue_rows": blood_hits,
        "preliminary_status": preliminary_status,
        "next_action": "Inspect phenotype fields and expression matrix structure before any cohort-lock decision.",
    }])
    decision_df.to_csv(OUT_DIR / "GSE68310_preliminary_external_projection_candidate_decision.tsv", sep="\t", index=False)

    report = DOCS_DIR / "GSE68310_external_projection_candidate_feasibility_audit_report.md"
    report.write_text(
        "\n".join([
            "# GSE68310 External Projection Candidate Feasibility Audit Report",
            "",
            f"- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "- Purpose: audit GSE68310 as a candidate formal external projection cohort.",
            "- Boundary: feasibility audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.",
            "",
            "## Raw file audit",
            "",
            file_audit.to_string(index=False),
            "",
            "## Metadata summary",
            "",
            f"- Number of SOFT samples parsed: {len(soft_df)}",
            f"- Series matrix sample metadata available: {not matrix_df.empty}",
            f"- Supplementary files indexed: {len(supp_df)}",
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
            "- This audit does not lock GSE68310 as a formal projection cohort.",
            "- This audit does not score locked GSE211567 modules.",
            "- A cohort-lock decision requires expression availability, identifier type, sample-level bacterial/viral labels and independence confirmation.",
            "",
            "## Generated files",
            "",
            "- `data/metadata_harmonized/GSE68310_GEO_family_SOFT_sample_metadata_flattened.tsv`",
            "- `data/metadata_harmonized/GSE68310_series_matrix_sample_metadata.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_raw_file_audit.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_metadata_field_presence.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_metadata_keyword_clue_summary.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_supplementary_file_index.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_supplementary_file_type_hints.tsv`",
            "- `results/external_projection_candidate_audit/GSE68310/GSE68310_preliminary_external_projection_candidate_decision.tsv`",
        ]),
        encoding="utf-8",
    )

    print(f"Wrote report: {report}")
    print(decision_df.to_string(index=False))


if __name__ == "__main__":
    main()
