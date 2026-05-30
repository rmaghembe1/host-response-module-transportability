#!/usr/bin/env python3

from pathlib import Path
import gzip
import csv
from collections import Counter, defaultdict
from datetime import datetime

ROOT = Path(".")
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "metadata_harmonized"
DOCS = ROOT / "docs"

OUT.mkdir(parents=True, exist_ok=True)
DOCS.mkdir(parents=True, exist_ok=True)

COUNTS = RAW / "GSE161731_counts.csv.gz"
COUNTS_KEY = RAW / "GSE161731_counts_key.csv.gz"
SAMPLE_KEY = RAW / "GSE161731_key.csv.gz"

def open_gz_csv(path):
    return gzip.open(path, "rt", newline="", errors="replace")

def read_header_csv_gz(path):
    with open_gz_csv(path) as f:
        reader = csv.reader(f)
        return next(reader)

def read_dict_csv_gz(path):
    with open_gz_csv(path) as f:
        reader = csv.DictReader(f)
        return list(reader), reader.fieldnames

def write_tsv(path, rows, fields):
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields, delimiter="\t", extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

def norm_missing(x):
    if x is None:
        return ""
    x = str(x).strip()
    if x.upper() in {"NA", "N/A", "NULL", "NONE"}:
        return ""
    return x

def main():
    counts_header = read_header_csv_gz(COUNTS)
    count_sample_ids = counts_header[1:]  # first blank/ID column removed

    counts_key_rows, counts_key_fields = read_dict_csv_gz(COUNTS_KEY)
    sample_key_rows, sample_key_fields = read_dict_csv_gz(SAMPLE_KEY)

    counts_key_by_rna = {r["rna_id"]: r for r in counts_key_rows}
    sample_key_by_rna = {r["rna_id"]: r for r in sample_key_rows}

    count_set = set(count_sample_ids)
    counts_key_set = set(counts_key_by_rna)
    sample_key_set = set(sample_key_by_rna)

    all_ids = sorted(count_set | counts_key_set | sample_key_set)

    reconciliation_rows = []
    for rna_id in all_ids:
        ck = counts_key_by_rna.get(rna_id, {})
        sk = sample_key_by_rna.get(rna_id, {})

        # Prefer sample_key values where available, otherwise counts_key values.
        source = sk if sk else ck

        cohort = norm_missing(source.get("cohort"))
        subject_id = norm_missing(source.get("subject_id"))
        age = norm_missing(source.get("age"))
        gender = norm_missing(source.get("gender"))
        race = norm_missing(source.get("race"))
        time_since_onset = norm_missing(source.get("time_since_onset"))
        hospitalized = norm_missing(source.get("hospitalized"))
        batch = norm_missing(source.get("batch"))

        in_counts = rna_id in count_set
        in_counts_key = rna_id in counts_key_set
        in_sample_key = rna_id in sample_key_set

        if in_counts and in_sample_key:
            usability = "mapped_to_sample_key"
        elif in_counts and in_counts_key and not in_sample_key:
            usability = "mapped_to_counts_key_only"
        elif in_counts and not in_counts_key and not in_sample_key:
            usability = "count_matrix_only_unmapped"
        elif not in_counts and (in_counts_key or in_sample_key):
            usability = "metadata_only_not_in_count_matrix"
        else:
            usability = "unclassified"

        # Conservative primary external candidate flag; no modelling implied.
        cohort_lower = cohort.lower()
        if cohort_lower == "bacterial":
            broad_group = "bacterial"
            primary_non_covid_candidate = "yes"
        elif cohort_lower in {"influenza", "seasonal coronavirus", "coronavirus"}:
            broad_group = "non_covid_viral"
            primary_non_covid_candidate = "yes"
        elif cohort_lower == "healthy":
            broad_group = "healthy_contextual"
            primary_non_covid_candidate = "contextual_only"
        elif "covid" in cohort_lower or "sars" in cohort_lower:
            broad_group = "covid_excluded_primary"
            primary_non_covid_candidate = "no"
        elif cohort:
            broad_group = "other_or_unclear"
            primary_non_covid_candidate = "review"
        else:
            broad_group = "missing_metadata"
            primary_non_covid_candidate = "no"

        reconciliation_rows.append({
            "rna_id": rna_id,
            "in_count_matrix": str(in_counts),
            "in_counts_key": str(in_counts_key),
            "in_sample_key": str(in_sample_key),
            "metadata_usability_status": usability,
            "subject_id": subject_id,
            "cohort": cohort,
            "broad_group_preliminary": broad_group,
            "primary_non_covid_external_candidate_preliminary": primary_non_covid_candidate,
            "age": age,
            "gender": gender,
            "race": race,
            "time_since_onset": time_since_onset,
            "hospitalized": hospitalized,
            "batch": batch,
        })

    fields = [
        "rna_id", "in_count_matrix", "in_counts_key", "in_sample_key",
        "metadata_usability_status", "subject_id", "cohort",
        "broad_group_preliminary",
        "primary_non_covid_external_candidate_preliminary",
        "age", "gender", "race", "time_since_onset", "hospitalized", "batch"
    ]

    rec_path = OUT / "GSE161731_sample_id_reconciliation.tsv"
    write_tsv(rec_path, reconciliation_rows, fields)

    # Cohort counts among count-matrix samples only.
    count_matrix_rows = [r for r in reconciliation_rows if r["in_count_matrix"] == "True"]
    cohort_counts = Counter(r["cohort"] if r["cohort"] else "MISSING" for r in count_matrix_rows)
    broad_counts = Counter(r["broad_group_preliminary"] for r in count_matrix_rows)
    usability_counts = Counter(r["metadata_usability_status"] for r in reconciliation_rows)

    # Duplicates/repeated subject inspection among count-matrix samples.
    subject_to_rnas = defaultdict(list)
    for r in count_matrix_rows:
        sid = r["subject_id"]
        if sid:
            subject_to_rnas[sid].append(r["rna_id"])

    repeated_subjects = [
        {
            "subject_id": sid,
            "n_samples_in_count_matrix": len(ids),
            "rna_ids": ",".join(ids),
        }
        for sid, ids in sorted(subject_to_rnas.items())
        if len(ids) > 1
    ]

    repeated_path = OUT / "GSE161731_repeated_subjects_preliminary.tsv"
    write_tsv(repeated_path, repeated_subjects, ["subject_id", "n_samples_in_count_matrix", "rna_ids"])

    unmatched_rows = [
        r for r in reconciliation_rows
        if r["metadata_usability_status"] != "mapped_to_sample_key"
    ]
    unmatched_path = OUT / "GSE161731_unmatched_or_incompletely_mapped_ids.tsv"
    write_tsv(unmatched_path, unmatched_rows, fields)

    report_path = DOCS / "GSE161731_sample_id_reconciliation_report.md"
    with report_path.open("w", encoding="utf-8") as out:
        out.write("# GSE161731 Sample-ID Reconciliation Report\n\n")
        out.write(f"- Generated: {datetime.now().isoformat(timespec='seconds')}\n")
        out.write("- Purpose: metadata/sample-ID reconciliation before any count-level modelling.\n")
        out.write("- Analytical boundary: this report does not perform differential expression, pathway analysis, module selection or transportability testing.\n\n")

        out.write("## Source structures\n\n")
        out.write(f"- Count matrix sample columns after first identifier column: {len(count_sample_ids)}\n")
        out.write(f"- `GSE161731_counts_key.csv.gz` metadata rows: {len(counts_key_rows)}\n")
        out.write(f"- `GSE161731_key.csv.gz` metadata rows: {len(sample_key_rows)}\n")
        out.write(f"- Unique RNA IDs across all three sources: {len(all_ids)}\n\n")

        out.write("## Mapping status across all observed RNA IDs\n\n")
        for k, v in sorted(usability_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Unmatched set sizes\n\n")
        out.write(f"- Count-matrix sample IDs absent from counts-key: {len(count_set - counts_key_set)}\n")
        out.write(f"- Count-matrix sample IDs absent from sample-key: {len(count_set - sample_key_set)}\n")
        out.write(f"- Counts-key RNA IDs absent from count matrix: {len(counts_key_set - count_set)}\n")
        out.write(f"- Sample-key RNA IDs absent from count matrix: {len(sample_key_set - count_set)}\n")
        out.write(f"- Counts-key RNA IDs absent from sample-key: {len(counts_key_set - sample_key_set)}\n")
        out.write(f"- Sample-key RNA IDs absent from counts-key: {len(sample_key_set - counts_key_set)}\n\n")

        out.write("## Cohort labels among count-matrix samples after metadata merging\n\n")
        for k, v in sorted(cohort_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Preliminary broad group counts among count-matrix samples\n\n")
        for k, v in sorted(broad_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Repeated-subject preliminary inspection\n\n")
        out.write(f"- Subjects with more than one count-matrix sample: {len(repeated_subjects)}\n")
        if repeated_subjects:
            for row in repeated_subjects[:20]:
                out.write(f"- {row['subject_id']}: {row['n_samples_in_count_matrix']} samples ({row['rna_ids']})\n")
            if len(repeated_subjects) > 20:
                out.write(f"- Additional repeated subjects not shown: {len(repeated_subjects) - 20}\n")

        out.write("\n## Generated files\n\n")
        out.write(f"- `{rec_path}`\n")
        out.write(f"- `{unmatched_path}`\n")
        out.write(f"- `{repeated_path}`\n")

        out.write("\n## Immediate interpretation\n\n")
        out.write("- Samples mapped only to `counts_key` or only to the count matrix require review before eligibility locking.\n")
        out.write("- The preliminary non-COVID bacterial-versus-viral subset is metadata-derived only and must not be used to select biological modules.\n")
        out.write("- The next step is to inspect unmatched IDs and cohort distributions, then write a formal contrast-lock decision for technical workflow rehearsal.\n")

    print(f"Wrote {rec_path}")
    print(f"Wrote {unmatched_path}")
    print(f"Wrote {repeated_path}")
    print(f"Wrote {report_path}")

if __name__ == "__main__":
    main()
