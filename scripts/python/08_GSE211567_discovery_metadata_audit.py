#!/usr/bin/env python3

from pathlib import Path
import gzip
import csv
from collections import Counter
from datetime import datetime

ROOT = Path(".")
RAW_EXPR = ROOT / "data" / "raw" / "GSE211567_normData_discovery_2021MAR24.txt.gz"
SOFT = ROOT / "data" / "metadata_raw" / "GSE211567" / "GSE211567_family.ftp.soft.gz"
OUTDIR = ROOT / "data" / "metadata_harmonized"
DOCS = ROOT / "docs"

OUTDIR.mkdir(parents=True, exist_ok=True)
DOCS.mkdir(parents=True, exist_ok=True)

def open_text(path):
    if str(path).endswith(".gz"):
        return gzip.open(path, "rt", errors="replace", newline="")
    return open(path, "rt", errors="replace", newline="")

def parse_sample_soft_blocks(path):
    samples = []
    current = None

    with open_text(path) as f:
        for raw in f:
            line = raw.rstrip("\n\r")

            if line.startswith("^SAMPLE = "):
                if current:
                    samples.append(current)
                gsm = line.split("=", 1)[1].strip()
                current = {
                    "geo_accession": gsm,
                    "characteristics": {},
                    "data_processing": []
                }
                continue

            if current is None:
                continue

            if line.startswith("!Sample_"):
                key, value = line.split("=", 1)
                key = key.replace("!Sample_", "").strip()
                value = value.strip()

                if key == "characteristics_ch1":
                    if ":" in value:
                        k, v = value.split(":", 1)
                        current["characteristics"][k.strip().lower().replace(" ", "_")] = v.strip()
                    else:
                        current["characteristics"].setdefault("unparsed_characteristics", []).append(value)
                elif key == "data_processing":
                    current["data_processing"].append(value)
                else:
                    if key in current and current[key]:
                        current[key] = str(current[key]) + " | " + value
                    else:
                        current[key] = value

    if current:
        samples.append(current)

    flat = []
    for s in samples:
        row = {}
        for k, v in s.items():
            if k == "characteristics":
                for ck, cv in v.items():
                    if isinstance(cv, list):
                        row[f"characteristics_{ck}"] = " | ".join(cv)
                    else:
                        row[f"characteristics_{ck}"] = cv
            elif k == "data_processing":
                row[k] = " | ".join(v)
            else:
                row[k] = v
        flat.append(row)

    return flat

def read_expression_header(path):
    with open_text(path) as f:
        header = f.readline().rstrip("\n\r").split("\t")
    return header[1:]

def norm(x):
    return str(x).strip().strip('"')

def main():
    expr_ids = [norm(x) for x in read_expression_header(RAW_EXPR)]
    meta_rows = parse_sample_soft_blocks(SOFT)

    # Build title and accession matching
    title_to_rows = {}
    accession_to_rows = {}
    any_value_index = []

    for row in meta_rows:
        gsm = row.get("geo_accession", "")
        title = row.get("title", "")
        accession_to_rows.setdefault(gsm, []).append(row)
        if title:
            title_to_rows.setdefault(title, []).append(row)

        values = []
        for k, v in row.items():
            values.append((k, norm(v)))
        any_value_index.append((row, values))

    mapping_rows = []
    for expr_id in expr_ids:
        matched = []
        matched_fields = []

        # Exact title match first
        for row in title_to_rows.get(expr_id, []):
            matched.append(row.get("geo_accession", ""))
            matched_fields.append("title_exact")

        # Some titles may include lane suffix or sample suffix; also try containment.
        if not matched:
            for row, values in any_value_index:
                for k, v in values:
                    if expr_id and expr_id == v:
                        matched.append(row.get("geo_accession", ""))
                        matched_fields.append(k + "_exact")
                    elif expr_id and expr_id in v:
                        matched.append(row.get("geo_accession", ""))
                        matched_fields.append(k + "_contains")

        matched_unique = sorted(set([m for m in matched if m]))
        if len(matched_unique) == 1:
            status = "unique_metadata_match"
        elif len(matched_unique) == 0:
            status = "no_metadata_match"
        else:
            status = "multiple_metadata_matches"

        mapping_rows.append({
            "expression_sample_id": expr_id,
            "matched_geo_accessions": ",".join(matched_unique),
            "n_matched_geo_accessions": len(matched_unique),
            "matched_metadata_fields": ",".join(sorted(set(matched_fields))),
            "mapping_status": status
        })

    all_keys = sorted({k for row in meta_rows for k in row.keys()})

    meta_out = OUTDIR / "GSE211567_GEO_family_SOFT_sample_metadata_flattened.tsv"
    with meta_out.open("w", newline="", encoding="utf-8") as f:
        fields = all_keys
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t", extrasaction="ignore")
        w.writeheader()
        for row in meta_rows:
            w.writerow(row)

    map_out = OUTDIR / "GSE211567_expression_sample_to_GEO_metadata_mapping.tsv"
    with map_out.open("w", newline="", encoding="utf-8") as f:
        fields = [
            "expression_sample_id",
            "matched_geo_accessions",
            "n_matched_geo_accessions",
            "matched_metadata_fields",
            "mapping_status"
        ]
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t")
        w.writeheader()
        w.writerows(mapping_rows)

    field_presence = []
    for key in all_keys:
        field_presence.append({
            "field": key,
            "n_nonempty": sum(1 for row in meta_rows if norm(row.get(key, "")) != "")
        })

    field_out = OUTDIR / "GSE211567_GEO_metadata_field_presence.tsv"
    with field_out.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["field", "n_nonempty"], delimiter="\t")
        w.writeheader()
        w.writerows(field_presence)

    # Simple sample-category summaries from GEO metadata
    site_counts = Counter(norm(row.get("characteristics_site", "")) or "MISSING" for row in meta_rows)
    infection_counts = Counter(norm(row.get("characteristics_infection_type", "")) or "MISSING" for row in meta_rows)
    pathogen_counts = Counter(norm(row.get("characteristics_pathogen", "")) or "MISSING" for row in meta_rows)
    mapping_counts = Counter(row["mapping_status"] for row in mapping_rows)

    report = DOCS / "GSE211567_discovery_metadata_audit_report.md"
    with report.open("w", encoding="utf-8") as out:
        out.write("# GSE211567 Discovery-Side Metadata Audit Report\n\n")
        out.write(f"- Generated: {datetime.now().isoformat(timespec='seconds')}\n")
        out.write("- Purpose: reconcile GSE211567 normalized discovery-matrix sample columns with GEO family SOFT sample metadata before any discovery modelling.\n")
        out.write("- Analytical boundary: no differential expression, pathway enrichment, module selection or biological interpretation is performed here.\n\n")

        out.write("## Source structures\n\n")
        out.write(f"- Normalized discovery matrix sample columns: {len(expr_ids)}\n")
        out.write(f"- GEO family SOFT sample records parsed: {len(meta_rows)}\n")
        out.write(f"- GEO metadata fields detected after flattening: {len(all_keys)}\n\n")

        out.write("## Expression-column to GEO-metadata mapping status\n\n")
        for k, v in sorted(mapping_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## GEO metadata site counts\n\n")
        for k, v in sorted(site_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## GEO metadata infection-type counts\n\n")
        for k, v in sorted(infection_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## GEO metadata pathogen counts\n\n")
        for k, v in sorted(pathogen_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Metadata fields with non-empty values\n\n")
        for row in field_presence:
            out.write(f"- {row['field']}: {row['n_nonempty']}\n")

        out.write("\n## Generated files\n\n")
        out.write(f"- `{map_out}`\n")
        out.write(f"- `{meta_out}`\n")
        out.write(f"- `{field_out}`\n\n")

        out.write("## Immediate interpretation\n\n")
        out.write("- This audit determines whether normalized expression sample columns can be linked to GEO sample metadata.\n")
        out.write("- If mapping is complete or near-complete, the next step is to lock discovery sample classes, site/context strata and exclusion rules.\n")
        out.write("- If sample-column identifiers do not match GEO titles directly, an explicit identifier bridge must be created before modelling.\n")
        out.write("- No discovery modelling should begin until the GSE211567 sample-class table is locked.\n")

    print(f"Wrote {map_out}")
    print(f"Wrote {meta_out}")
    print(f"Wrote {field_out}")
    print(f"Wrote {report}")

if __name__ == "__main__":
    main()
