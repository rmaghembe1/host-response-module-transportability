#!/usr/bin/env python3

from pathlib import Path
import csv
from collections import Counter
from datetime import datetime

ROOT = Path(".")
INFILE = ROOT / "data" / "metadata_harmonized" / "GSE161731_sample_id_reconciliation.tsv"
OUTDIR = ROOT / "data" / "metadata_harmonized"
DOCS = ROOT / "docs"

OUTDIR.mkdir(parents=True, exist_ok=True)
DOCS.mkdir(parents=True, exist_ok=True)

OUTFILE = OUTDIR / "GSE161731_technical_rehearsal_eligibility.tsv"
REPORT = DOCS / "GSE161731_technical_rehearsal_eligibility_report.md"

def read_tsv(path):
    with path.open("r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f, delimiter="\t"))

def write_tsv(path, rows, fields):
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t", extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow(row)

def classify(row):
    cohort = (row.get("cohort") or "").strip()
    status = row.get("metadata_usability_status", "")
    in_count = row.get("in_count_matrix") == "True"

    if not in_count:
        return ("exclude_not_in_count_matrix", "no", "not present in count matrix")

    if status == "count_matrix_only_unmapped":
        return ("exclude_missing_metadata", "no", "count matrix sample lacks metadata in both key files")

    if cohort == "Bacterial":
        return ("bacterial", "yes", "eligible bacterial sample for technical rehearsal")
    if cohort in {"Influenza", "CoV other"}:
        return ("non_covid_viral", "yes", "eligible non-COVID viral sample for technical rehearsal")
    if cohort == "COVID-19":
        return ("covid_excluded_primary", "no", "COVID-19 excluded from primary non-COVID technical rehearsal")
    if cohort == "healthy":
        return ("healthy_contextual", "contextual_only", "healthy controls retained for contextual QC/orientation only")
    if cohort == "":
        return ("exclude_missing_metadata", "no", "missing cohort metadata")
    return ("review", "review", f"unrecognized cohort label: {cohort}")

def main():
    rows = read_tsv(INFILE)
    out_rows = []

    for r in rows:
        group, include, reason = classify(r)

        caution_flags = []
        if r.get("metadata_usability_status") == "mapped_to_counts_key_only":
            caution_flags.append("counts_key_only_not_in_sample_key")
        if r.get("metadata_usability_status") == "count_matrix_only_unmapped":
            caution_flags.append("unmapped_count_matrix_sample")
        if not r.get("subject_id"):
            caution_flags.append("missing_subject_id")
        if not r.get("cohort"):
            caution_flags.append("missing_cohort")

        r = dict(r)
        r["technical_rehearsal_group"] = group
        r["include_in_primary_non_covid_technical_rehearsal"] = include
        r["technical_rehearsal_decision_reason"] = reason
        r["metadata_caution_flags"] = ";".join(caution_flags) if caution_flags else "none"
        out_rows.append(r)

    fields = list(out_rows[0].keys())
    write_tsv(OUTFILE, out_rows, fields)

    count_matrix_rows = [r for r in out_rows if r["in_count_matrix"] == "True"]
    group_counts = Counter(r["technical_rehearsal_group"] for r in count_matrix_rows)
    include_counts = Counter(r["include_in_primary_non_covid_technical_rehearsal"] for r in count_matrix_rows)

    primary_rows = [
        r for r in count_matrix_rows
        if r["include_in_primary_non_covid_technical_rehearsal"] == "yes"
    ]
    primary_counts = Counter(r["technical_rehearsal_group"] for r in primary_rows)
    caution_rows = [
        r for r in count_matrix_rows
        if r["metadata_caution_flags"] != "none"
    ]

    with REPORT.open("w", encoding="utf-8") as out:
        out.write("# GSE161731 Technical-Rehearsal Eligibility Report\n\n")
        out.write(f"- Generated: {datetime.now().isoformat(timespec='seconds')}\n")
        out.write("- Purpose: define a metadata-derived sample subset for count-level RNA-seq workflow rehearsal only.\n")
        out.write("- Firewall statement: this subset must not be used to select, orient, reweight or validate discovery modules. It exists only to master count-level processing before GSE211567 discovery analysis.\n\n")

        out.write("## Classification rules\n\n")
        out.write("- `Bacterial` → `bacterial`, included in technical bacterial-versus-viral rehearsal.\n")
        out.write("- `Influenza` → `non_covid_viral`, included in technical rehearsal.\n")
        out.write("- `CoV other` → `non_covid_viral`, included in technical rehearsal as seasonal/non-SARS coronavirus.\n")
        out.write("- `COVID-19` → excluded from the primary non-COVID rehearsal contrast.\n")
        out.write("- `healthy` → retained for contextual QC/orientation only, not included in the bacterial-versus-viral rehearsal contrast.\n")
        out.write("- Count-matrix-only samples lacking metadata → excluded.\n")
        out.write("- Counts-key-only samples are provisionally retained if cohort and key metadata are adequate, but flagged.\n\n")

        out.write("## Count-matrix sample classification\n\n")
        for k, v in sorted(group_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Inclusion-decision counts among count-matrix samples\n\n")
        for k, v in sorted(include_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Primary technical-rehearsal contrast size\n\n")
        out.write(f"- Total included primary non-COVID rehearsal samples: {len(primary_rows)}\n")
        for k, v in sorted(primary_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Caution-flagged count-matrix samples\n\n")
        out.write(f"- Count-matrix samples with caution flags: {len(caution_rows)}\n")
        for r in caution_rows:
            out.write(
                f"- {r['rna_id']}: group={r['technical_rehearsal_group']}; "
                f"cohort={r['cohort'] or 'MISSING'}; "
                f"status={r['metadata_usability_status']}; "
                f"flags={r['metadata_caution_flags']}\n"
            )

        out.write("\n## Output\n\n")
        out.write(f"- `{OUTFILE}`\n\n")

        out.write("## Immediate interpretation\n\n")
        out.write("- GSE161731 has a metadata-derived non-COVID technical-rehearsal contrast of bacterial versus influenza/seasonal-coronavirus samples.\n")
        out.write("- Three count-matrix-only samples remain excluded because they lack metadata.\n")
        out.write("- Three counts-key-only samples are flagged; inclusion is acceptable for technical rehearsal if no additional contradiction appears, but this should be revisited before any formal external validation use.\n")
        out.write("- The next step is to commit this eligibility lock and then create the first count-level QC/voom rehearsal script using only this metadata-derived subset.\n")

    print(f"Wrote {OUTFILE}")
    print(f"Wrote {REPORT}")

if __name__ == "__main__":
    main()
