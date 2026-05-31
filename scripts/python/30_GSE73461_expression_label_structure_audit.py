#!/usr/bin/env python3

"""
GSE73461 expression and label structure audit.

Purpose:
- Inspect processed raw and normalized GSE73461 expression files.
- Confirm matrix dimensions, feature identifiers, sample labels and detection-p-value pairing.
- Determine whether Definite Bacterial vs Definite Viral samples can support formal fixed-module projection.
- Do not score modules and do not lock the cohort yet.
"""

from __future__ import annotations

import gzip
import hashlib
import re
from pathlib import Path
from datetime import datetime
import pandas as pd


EXPR_DIR = Path("data/expression_raw/GSE73461")
OUT_DIR = Path("results/external_projection_candidate_audit/GSE73461_expression_files")
DOCS_DIR = Path("docs")
OUT_DIR.mkdir(parents=True, exist_ok=True)
DOCS_DIR.mkdir(parents=True, exist_ok=True)

NORM = EXPR_DIR / "GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz"
RAW = EXPR_DIR / "GSE73461_GEOupload_Discovery_Dataset_Raw_Sept_15_n_459.txt.gz"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def read_header(path: Path) -> list[str]:
    with gzip.open(path, "rt", errors="replace") as f:
        header = f.readline().rstrip("\n\r")
    # Files appear tab-delimited.
    return header.split("\t")


def count_feature_rows(path: Path) -> int:
    n = 0
    with gzip.open(path, "rt", errors="replace") as f:
        for _ in f:
            n += 1
    return max(0, n - 1)


def first_feature_ids(path: Path, n: int = 1000) -> list[tuple[str, str]]:
    ids = []
    with gzip.open(path, "rt", errors="replace") as f:
        header = f.readline().rstrip("\n\r").split("\t")
        for i, line in enumerate(f):
            if i >= n:
                break
            parts = line.rstrip("\n\r").split("\t")
            if len(parts) >= 2:
                ids.append((parts[0], parts[1]))
            elif len(parts) == 1:
                ids.append((parts[0], ""))
    return ids


def clean_group_from_sample(sample: str) -> str:
    s = sample.replace("_Detection_Pval", "")
    s = s.replace("Definite Bacterial", "DefiniteBacterial")
    s = s.replace("Definite Viral", "DefiniteViral")

    if "_" in s:
        return s.rsplit("_", 1)[0]
    return s


def sample_columns_from_header(header: list[str], id_cols: int) -> pd.DataFrame:
    cols = header[id_cols:]
    rows = []
    for col in cols:
        is_detection = col.endswith("_Detection_Pval")
        base = col.replace("_Detection_Pval", "")
        base = base.replace("Definite Bacterial", "DefiniteBacterial")
        base = base.replace("Definite Viral", "DefiniteViral")
        group = clean_group_from_sample(col)
        rows.append({
            "column_name": col,
            "base_sample_id": base,
            "is_detection_pval_column": is_detection,
            "sample_group": group,
        })
    return pd.DataFrame(rows)


def classify_ids(ids: list[tuple[str, str]]) -> dict:
    first = [x[0] for x in ids]
    second = [x[1] for x in ids]

    return {
        "n_preview_ids": len(ids),
        "first_col_ilmn_like_n": sum(bool(re.match(r"^ILMN_", x)) for x in first),
        "first_col_numeric_like_n": sum(bool(re.match(r"^[0-9]+$", x)) for x in first),
        "second_col_numeric_like_n": sum(bool(re.match(r"^[0-9]+$", x)) for x in second),
        "example_first_col_ids": ";".join(first[:10]),
        "example_second_col_ids": ";".join(second[:10]),
    }


def audit_file(path: Path, label: str, id_cols: int) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    header = read_header(path)
    sample_df = sample_columns_from_header(header, id_cols=id_cols)
    expression_cols = sample_df[~sample_df["is_detection_pval_column"]].copy()
    detection_cols = sample_df[sample_df["is_detection_pval_column"]].copy()

    # Pairing check: every expression column should have matching Detection_Pval column.
    expression_bases = set(expression_cols["base_sample_id"])
    detection_bases = set(detection_cols["base_sample_id"])

    id_preview = first_feature_ids(path, n=1000)
    id_info = classify_ids(id_preview)

    summary = pd.DataFrame([{
        "file_label": label,
        "file_path": str(path),
        "size_bytes": path.stat().st_size,
        "sha256": sha256_file(path),
        "n_feature_rows": count_feature_rows(path),
        "n_header_columns_total": len(header),
        "n_identifier_columns_assumed": id_cols,
        "n_expression_sample_columns": len(expression_cols),
        "n_detection_pval_columns": len(detection_cols),
        "expression_detection_pairs_complete": expression_bases == detection_bases,
        "n_expression_without_detection": len(expression_bases - detection_bases),
        "n_detection_without_expression": len(detection_bases - expression_bases),
        **id_info,
    }])

    group_counts = (
        expression_cols.groupby("sample_group", dropna=False)
        .size()
        .reset_index(name="n_expression_samples")
        .sort_values(["sample_group"])
    )
    group_counts.insert(0, "file_label", label)

    sample_df.insert(0, "file_label", label)
    return summary, group_counts, sample_df


def main() -> None:
    # Normalized file appears to have ARRAY_ID only as identifier column.
    norm_summary, norm_groups, norm_cols = audit_file(NORM, "normalized", id_cols=1)

    # Raw file appears to have ID_REF + ARRAY_ID identifier columns.
    raw_summary, raw_groups, raw_cols = audit_file(RAW, "raw", id_cols=2)

    summary = pd.concat([norm_summary, raw_summary], ignore_index=True)
    group_counts = pd.concat([norm_groups, raw_groups], ignore_index=True)
    sample_columns = pd.concat([norm_cols, raw_cols], ignore_index=True)

    summary.to_csv(OUT_DIR / "GSE73461_expression_file_structure_summary.tsv", sep="\t", index=False)
    group_counts.to_csv(OUT_DIR / "GSE73461_expression_sample_group_counts.tsv", sep="\t", index=False)
    sample_columns.to_csv(OUT_DIR / "GSE73461_expression_sample_columns_long.tsv", sep="\t", index=False)

    # Compare normalized and raw expression sample IDs.
    norm_expr = norm_cols[~norm_cols["is_detection_pval_column"]][["base_sample_id", "sample_group"]].copy()
    raw_expr = raw_cols[~raw_cols["is_detection_pval_column"]][["base_sample_id", "sample_group"]].copy()

    norm_samples = set(norm_expr["base_sample_id"])
    raw_samples = set(raw_expr["base_sample_id"])

    sample_consistency = pd.DataFrame([{
        "n_normalized_expression_samples": len(norm_samples),
        "n_raw_expression_samples": len(raw_samples),
        "same_sample_set_normalized_and_raw": norm_samples == raw_samples,
        "n_in_normalized_not_raw": len(norm_samples - raw_samples),
        "n_in_raw_not_normalized": len(raw_samples - norm_samples),
    }])
    sample_consistency.to_csv(OUT_DIR / "GSE73461_normalized_raw_sample_consistency.tsv", sep="\t", index=False)

    # Primary formal projection contrast candidate.
    raw_group_map = raw_expr.copy()
    raw_group_map["projection_role"] = "exclude_from_primary_projection"
    raw_group_map.loc[raw_group_map["sample_group"] == "DefiniteBacterial", "projection_role"] = "primary_bacterial"
    raw_group_map.loc[raw_group_map["sample_group"] == "DefiniteViral", "projection_role"] = "primary_viral"
    raw_group_map.loc[raw_group_map["sample_group"] == "Control", "projection_role"] = "secondary_control_context"

    raw_group_map.to_csv(OUT_DIR / "GSE73461_candidate_primary_projection_sample_table.tsv", sep="\t", index=False)

    primary_counts = (
        raw_group_map.groupby(["projection_role", "sample_group"])
        .size()
        .reset_index(name="n_samples")
        .sort_values(["projection_role", "sample_group"])
    )
    primary_counts.to_csv(OUT_DIR / "GSE73461_candidate_primary_projection_group_counts.tsv", sep="\t", index=False)

    n_bact = int((raw_group_map["projection_role"] == "primary_bacterial").sum())
    n_viral = int((raw_group_map["projection_role"] == "primary_viral").sum())
    n_control = int((raw_group_map["projection_role"] == "secondary_control_context").sum())

    if n_bact >= 20 and n_viral >= 20:
        status = "strong_candidate_for_formal_cohort_lock_pending_identifier_coverage_audit"
        reason = "Expression files contain sizeable DefiniteBacterial and DefiniteViral groups with paired detection-p-value columns."
    else:
        status = "not_ready_for_formal_lock_group_size_or_labels_insufficient"
        reason = "Primary bacterial/viral sample groups are not sufficiently represented or not clearly labelled."

    decision = pd.DataFrame([{
        "candidate_dataset": "GSE73461",
        "expression_files_usable": True,
        "normalized_and_raw_same_sample_set": bool(sample_consistency.loc[0, "same_sample_set_normalized_and_raw"]),
        "n_primary_bacterial_samples": n_bact,
        "n_primary_viral_samples": n_viral,
        "n_secondary_control_samples": n_control,
        "preliminary_expression_label_status": status,
        "reason": reason,
        "next_action": "Audit feature annotation/identifier mapping and locked-module gene coverage before cohort-lock decision.",
    }])
    decision.to_csv(OUT_DIR / "GSE73461_expression_label_audit_decision.tsv", sep="\t", index=False)

    report = DOCS_DIR / "GSE73461_expression_label_structure_audit_report.md"
    report.write_text(
        "\n".join([
            "# GSE73461 Expression and Label Structure Audit Report",
            "",
            f"- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "- Purpose: inspect GSE73461 processed raw and normalized expression files for formal projection readiness.",
            "- Boundary: expression/label audit only. No module scoring, cohort lock, validation claim or biological interpretation is performed.",
            "",
            "## Expression file structure summary",
            "",
            summary.to_string(index=False),
            "",
            "## Expression sample group counts",
            "",
            group_counts.to_string(index=False),
            "",
            "## Normalized/raw sample consistency",
            "",
            sample_consistency.to_string(index=False),
            "",
            "## Candidate primary projection group counts",
            "",
            primary_counts.to_string(index=False),
            "",
            "## Preliminary expression-label audit decision",
            "",
            decision.to_string(index=False),
            "",
            "## Interpretation boundary",
            "",
            "- GSE73461 is not yet locked as a formal projection cohort.",
            "- The current audit supports deeper identifier-coverage assessment because DefiniteBacterial and DefiniteViral groups are present.",
            "- Locked GSE211567 modules must not be scored until identifier coverage is confirmed and a separate cohort-lock decision is made.",
            "",
            "## Generated files",
            "",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_file_structure_summary.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_sample_group_counts.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_sample_columns_long.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_normalized_raw_sample_consistency.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_sample_table.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_candidate_primary_projection_group_counts.tsv`",
            "- `results/external_projection_candidate_audit/GSE73461_expression_files/GSE73461_expression_label_audit_decision.tsv`",
        ]),
        encoding="utf-8",
    )

    print(f"Wrote report: {report}")
    print(decision.to_string(index=False))


if __name__ == "__main__":
    main()
