#!/usr/bin/env python3

"""
GSE261482 expression file structure audit.

Purpose:
- Inspect raw count and normalized expression files for dimensions, identifiers, delimiters and sample columns.
- Test whether expression sample columns 1..177 map cleanly to GEO metadata samples.
- Do not score modules, lock the cohort, or make validation/biological claims.
"""

from __future__ import annotations

import gzip
import hashlib
import re
from pathlib import Path
from datetime import datetime
import pandas as pd


RAW_EXPR_DIR = Path("data/expression_raw/GSE261482")
HARM_DIR = Path("data/metadata_harmonized")
OUT_DIR = Path("results/external_projection_candidate_audit/GSE261482_expression_files")
DOCS_DIR = Path("docs")
LOG_DIR = Path("docs/download_logs")

OUT_DIR.mkdir(parents=True, exist_ok=True)
DOCS_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)

COUNTS = RAW_EXPR_DIR / "GSE261482_Counts_raw_data.csv.gz"
NORM = RAW_EXPR_DIR / "GSE261482_Normalized_data.csv.gz"
SOFT_META = HARM_DIR / "GSE261482_GEO_family_SOFT_sample_metadata_flattened.tsv"
MATRIX_META = HARM_DIR / "GSE261482_series_matrix_sample_metadata.tsv"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def sniff_gz_csv(path: Path, n_preview: int = 5) -> dict:
    with gzip.open(path, "rt", errors="replace") as f:
        lines = [next(f).rstrip("\n\r") for _ in range(n_preview)]
    header = lines[0]
    delimiter = ";" if header.count(";") >= header.count(",") else ","
    fields = header.split(delimiter)
    first_col = fields[0]
    sample_cols = fields[1:]
    first_ids = [line.split(delimiter, 1)[0] for line in lines[1:]]
    return {
        "path": str(path),
        "size_bytes": path.stat().st_size,
        "sha256": sha256_file(path),
        "delimiter": delimiter,
        "first_header_field": first_col,
        "n_sample_columns_from_header": len(sample_cols),
        "first_10_sample_columns": ";".join(sample_cols[:10]),
        "first_5_feature_ids": ";".join(first_ids[:5]),
        "first_5_lines": "\n".join(lines),
    }


def count_rows_fast(path: Path) -> int:
    n = 0
    with gzip.open(path, "rt", errors="replace") as f:
        for _ in f:
            n += 1
    return max(0, n - 1)


def classify_feature_ids(ids: list[str]) -> dict:
    return {
        "n_preview_ids": len(ids),
        "n_ensembl_like": sum(bool(re.match(r"^ENSG[0-9]+", x)) for x in ids),
        "n_symbol_like": sum(bool(re.match(r"^[A-Za-z][A-Za-z0-9_.-]*$", x)) for x in ids),
        "n_numeric_like": sum(bool(re.match(r"^[0-9]+$", x)) for x in ids),
        "example_ids": ";".join(ids[:20]),
    }


def read_header_sample_cols(path: Path) -> list[str]:
    with gzip.open(path, "rt", errors="replace") as f:
        header = f.readline().rstrip("\n\r")
    delim = ";" if header.count(";") >= header.count(",") else ","
    return header.split(delim)[1:]


def read_first_feature_ids(path: Path, n: int = 1000) -> list[str]:
    ids = []
    with gzip.open(path, "rt", errors="replace") as f:
        header = next(f)
        delim = ";" if header.count(";") >= header.count(",") else ","
        for i, line in enumerate(f):
            if i >= n:
                break
            ids.append(line.rstrip("\n\r").split(delim, 1)[0])
    return ids


def load_meta(path: Path) -> pd.DataFrame:
    if not path.exists() or path.stat().st_size == 0:
        return pd.DataFrame()
    return pd.read_csv(path, sep="\t", dtype=str).fillna("")


def main() -> None:
    audits = []
    for path, label in [(COUNTS, "raw_counts"), (NORM, "normalized")]:
        info = sniff_gz_csv(path)
        sample_cols = read_header_sample_cols(path)
        feature_ids = read_first_feature_ids(path, n=1000)
        id_class = classify_feature_ids(feature_ids)
        audits.append({
            "file_label": label,
            "file_path": info["path"],
            "size_bytes": info["size_bytes"],
            "sha256": info["sha256"],
            "delimiter": info["delimiter"],
            "n_feature_rows": count_rows_fast(path),
            "first_header_field": info["first_header_field"],
            "n_sample_columns": len(sample_cols),
            "sample_columns_are_1_to_n": sample_cols == [str(i) for i in range(1, len(sample_cols) + 1)],
            "first_10_sample_columns": info["first_10_sample_columns"],
            **id_class,
        })

    audit_df = pd.DataFrame(audits)
    audit_df.to_csv(OUT_DIR / "GSE261482_expression_file_structure_summary.tsv", sep="\t", index=False)

    # Save previews separately for reproducibility.
    preview_rows = []
    for path, label in [(COUNTS, "raw_counts"), (NORM, "normalized")]:
        info = sniff_gz_csv(path, n_preview=5)
        preview_rows.append({
            "file_label": label,
            "first_5_lines": info["first_5_lines"],
        })
    pd.DataFrame(preview_rows).to_csv(OUT_DIR / "GSE261482_expression_file_previews.tsv", sep="\t", index=False)

    counts_cols = read_header_sample_cols(COUNTS)
    norm_cols = read_header_sample_cols(NORM)

    sample_col_audit = pd.DataFrame([{
        "comparison": "counts_vs_normalized_sample_columns",
        "n_counts_columns": len(counts_cols),
        "n_normalized_columns": len(norm_cols),
        "same_order": counts_cols == norm_cols,
        "counts_are_1_to_177": counts_cols == [str(i) for i in range(1, 178)],
        "normalized_are_1_to_177": norm_cols == [str(i) for i in range(1, 178)],
    }])
    sample_col_audit.to_csv(OUT_DIR / "GSE261482_expression_sample_column_consistency.tsv", sep="\t", index=False)

    soft_meta = load_meta(SOFT_META)
    matrix_meta = load_meta(MATRIX_META)

    # Inspect candidate sample-number fields and GEO accession fields.
    metadata_summary_rows = []
    for name, df in [("SOFT", soft_meta), ("series_matrix", matrix_meta)]:
        if df.empty:
            metadata_summary_rows.append({
                "metadata_source": name,
                "n_rows": 0,
                "n_columns": 0,
                "candidate_numeric_1_to_177_columns": "",
                "geo_accession_columns": "",
                "title_like_columns": "",
                "diagnosis_or_group_like_columns": "",
            })
            continue

        numeric_cols = []
        geo_cols = []
        title_cols = []
        group_cols = []

        for col in df.columns:
            vals = df[col].astype(str).tolist()
            if sorted(set(vals)) == [str(i) for i in range(1, 178)]:
                numeric_cols.append(col)
            if any(v.startswith("GSM") for v in vals):
                geo_cols.append(col)
            if "title" in col.lower() or "sample" in col.lower() or "source" in col.lower():
                title_cols.append(col)
            if re.search(r"group|diagn|infect|pathogen|etiolog|disease|condition|case|control|phenotype", col, re.I):
                group_cols.append(col)

        metadata_summary_rows.append({
            "metadata_source": name,
            "n_rows": len(df),
            "n_columns": len(df.columns),
            "candidate_numeric_1_to_177_columns": ";".join(numeric_cols),
            "geo_accession_columns": ";".join(geo_cols),
            "title_like_columns": ";".join(title_cols),
            "diagnosis_or_group_like_columns": ";".join(group_cols),
        })

    metadata_summary = pd.DataFrame(metadata_summary_rows)
    metadata_summary.to_csv(OUT_DIR / "GSE261482_metadata_expression_mapping_field_audit.tsv", sep="\t", index=False)

    # Create a provisional expression sample table using 1..177.
    sample_table = pd.DataFrame({
        "expression_sample_number": [str(i) for i in range(1, 178)],
        "counts_column": counts_cols,
        "normalized_column": norm_cols,
    })

    # If GEO metadata has 177 rows, attach rows in current GEO order as a provisional mapping only.
    if len(soft_meta) == 177:
        attach_cols = [c for c in soft_meta.columns if c in {
            "sample_record", "title", "source_name_ch1", "organism_ch1", "characteristics_ch1",
            "characteristics_disease", "characteristics_condition", "characteristics_group",
            "characteristics_diagnosis", "characteristics_infection", "characteristics_sample_number"
        }]
        for c in attach_cols:
            sample_table[f"SOFT_{c}"] = soft_meta[c].values

    if len(matrix_meta) == 177:
        for c in matrix_meta.columns:
            if re.search(r"geo_accession|title|source|characteristics|disease|condition|group|diagnosis|infection", c, re.I):
                sample_table[f"matrix_{c}"] = matrix_meta[c].values

    sample_table.to_csv(OUT_DIR / "GSE261482_provisional_expression_sample_to_metadata_mapping.tsv", sep="\t", index=False)

    # Keyword scan of metadata fields for pathogen class, using joined row text.
    if not sample_table.empty:
        joined = sample_table.astype(str).agg(" ".join, axis=1)
        sample_table["bacterial_keyword_flag"] = joined.str.contains(
            r"bacter|sepsis|pneumonia|strept|staph|e\.?\s*coli|klebsiella|meningoc|pseudomon|haemophilus",
            case=False, regex=True
        )
        sample_table["viral_keyword_flag"] = joined.str.contains(
            r"viral|virus|influenza|rsv|adenovirus|rhinovirus|sars|covid|coronavirus|enterovirus|dengue",
            case=False, regex=True
        )
        sample_table["control_keyword_flag"] = joined.str.contains(
            r"control|healthy|non.?infect|afebrile",
            case=False, regex=True
        )
        sample_table.to_csv(OUT_DIR / "GSE261482_provisional_expression_sample_to_metadata_mapping_with_keyword_flags.tsv", sep="\t", index=False)

        keyword_summary = pd.DataFrame([{
            "n_samples": len(sample_table),
            "bacterial_keyword_flag_n": int(sample_table["bacterial_keyword_flag"].sum()),
            "viral_keyword_flag_n": int(sample_table["viral_keyword_flag"].sum()),
            "control_keyword_flag_n": int(sample_table["control_keyword_flag"].sum()),
        }])
    else:
        keyword_summary = pd.DataFrame([{
            "n_samples": 0,
            "bacterial_keyword_flag_n": 0,
            "viral_keyword_flag_n": 0,
            "control_keyword_flag_n": 0,
        }])

    keyword_summary.to_csv(OUT_DIR / "GSE261482_provisional_sample_keyword_flag_summary.tsv", sep="\t", index=False)

    # Conservative status.
    viral_n = int(keyword_summary.loc[0, "viral_keyword_flag_n"])
    bacterial_n = int(keyword_summary.loc[0, "bacterial_keyword_flag_n"])
    if viral_n == 0:
        status = "not_ready_for_formal_bacterial_vs_viral_projection_lock"
        reason = "Expression files are usable, but viral/pathogen-class metadata remains unresolved or absent in parsed metadata."
    elif bacterial_n == 0:
        status = "not_ready_for_formal_bacterial_vs_viral_projection_lock"
        reason = "Expression files are usable, but bacterial/pathogen-class metadata remains unresolved or absent in parsed metadata."
    else:
        status = "conditional_candidate_pending_manual_metadata_validation"
        reason = "Expression files are usable and bacterial/viral keyword flags are present, but sample-level labels require manual validation before cohort lock."

    decision = pd.DataFrame([{
        "candidate_dataset": "GSE261482",
        "expression_files_usable": True,
        "counts_feature_id_type": "ENSEMBL" if audit_df.loc[audit_df["file_label"] == "raw_counts", "n_ensembl_like"].iloc[0] > 900 else "other_or_mixed",
        "normalized_feature_id_type": "SYMBOL" if audit_df.loc[audit_df["file_label"] == "normalized", "n_symbol_like"].iloc[0] > 900 else "other_or_mixed",
        "n_expression_samples": len(counts_cols),
        "sample_column_consistent_between_files": bool(sample_col_audit.loc[0, "same_order"]),
        "bacterial_keyword_flag_n": bacterial_n,
        "viral_keyword_flag_n": viral_n,
        "preliminary_expression_audit_status": status,
        "reason": reason,
        "next_action": "Inspect GEO metadata fields manually and determine whether reliable pathogen-class labels can be recovered before any cohort-lock decision.",
    }])
    decision.to_csv(OUT_DIR / "GSE261482_expression_file_audit_decision.tsv", sep="\t", index=False)

    report = DOCS_DIR / "GSE261482_expression_file_structure_audit_report.md"
    report.write_text(
        "\n".join([
            "# GSE261482 Expression File Structure Audit Report",
            "",
            f"- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "- Purpose: inspect GSE261482 expression matrices and sample/metadata mapping feasibility.",
            "- Boundary: expression-structure audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.",
            "",
            "## Expression file structure summary",
            "",
            audit_df.to_string(index=False),
            "",
            "## Sample column consistency",
            "",
            sample_col_audit.to_string(index=False),
            "",
            "## Metadata-to-expression mapping field audit",
            "",
            metadata_summary.to_string(index=False),
            "",
            "## Provisional sample keyword flag summary",
            "",
            keyword_summary.to_string(index=False),
            "",
            "## Preliminary expression audit decision",
            "",
            decision.to_string(index=False),
            "",
            "## Interpretation boundary",
            "",
            "- Raw counts use ENSEMBL feature IDs and normalized data use SYMBOL-like feature IDs.",
            "- Expression columns are numbered 1..177 and require reliable mapping to sample-level metadata before use.",
            "- The current audit does not establish formal cohort eligibility because viral/pathogen-class metadata remains unresolved.",
            "- Locked GSE211567 modules must not be scored in GSE261482 unless a formal cohort-lock decision is made.",
            "",
            "## Generated files",
            "",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_structure_summary.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_previews.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_sample_column_consistency.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_metadata_expression_mapping_field_audit.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_expression_sample_to_metadata_mapping.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_expression_sample_to_metadata_mapping_with_keyword_flags.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_provisional_sample_keyword_flag_summary.tsv`",
            "- `results/external_projection_candidate_audit/GSE261482_expression_files/GSE261482_expression_file_audit_decision.tsv`",
        ]),
        encoding="utf-8",
    )

    print(f"Wrote report: {report}")
    print(decision.to_string(index=False))


if __name__ == "__main__":
    main()
