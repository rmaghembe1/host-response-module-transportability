#!/usr/bin/env python3

from pathlib import Path
import csv
from collections import Counter, defaultdict
from datetime import datetime

ROOT = Path(".")
MAP_FILE = ROOT / "data" / "metadata_harmonized" / "GSE211567_expression_sample_to_GEO_metadata_mapping.tsv"
META_FILE = ROOT / "data" / "metadata_harmonized" / "GSE211567_GEO_family_SOFT_sample_metadata_flattened.tsv"
OUTDIR = ROOT / "data" / "metadata_harmonized"
DOCS = ROOT / "docs"

OUTDIR.mkdir(parents=True, exist_ok=True)
DOCS.mkdir(parents=True, exist_ok=True)

LOCKED_TABLE = OUTDIR / "GSE211567_discovery_sample_table_locked.tsv"
EXCLUSION_TABLE = OUTDIR / "GSE211567_discovery_sample_exclusions.tsv"
REPORT = DOCS / "GSE211567_discovery_sample_table_lock_report.md"

UNMATCHED_EXCLUDE = {"DU09-03S0000029"}

def read_tsv(path):
    with path.open("r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f, delimiter="\t"))

def write_tsv(path, rows, fields):
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t", extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow(row)

def clean_gsm(x):
    # Parser produced some values like "GSM6479889 | GSM6479889"; keep first token.
    x = (x or "").strip()
    if "|" in x:
        x = x.split("|")[0].strip()
    return x

def discovery_group(infection_type):
    infection_type = (infection_type or "").strip()
    if infection_type == "Bacterial":
        return "bacterial"
    if infection_type == "Viral":
        return "viral"
    if infection_type == "Noninfection":
        return "noninfection_contextual"
    if not infection_type:
        return "missing_infection_type"
    return "review"

def include_primary(group):
    if group in {"bacterial", "viral"}:
        return "yes"
    if group == "noninfection_contextual":
        return "contextual_only"
    return "no"

def main():
    mappings = read_tsv(MAP_FILE)
    meta = read_tsv(META_FILE)

    meta_by_gsm = {}
    for row in meta:
        gsm = clean_gsm(row.get("geo_accession", ""))
        meta_by_gsm[gsm] = row

    locked = []
    exclusions = []

    for m in mappings:
        expr_id = m["expression_sample_id"]
        status = m["mapping_status"]
        matched = clean_gsm(m.get("matched_geo_accessions", ""))

        if expr_id in UNMATCHED_EXCLUDE or status != "unique_metadata_match":
            exclusions.append({
                "expression_sample_id": expr_id,
                "matched_geo_accessions": matched,
                "mapping_status": status,
                "exclusion_reason": (
                    "unmatched_expression_sample_no_authoritative_GEO_metadata_bridge"
                    if expr_id in UNMATCHED_EXCLUDE else
                    "non_unique_or_missing_metadata_mapping"
                )
            })
            continue

        row = meta_by_gsm.get(matched)
        if row is None:
            exclusions.append({
                "expression_sample_id": expr_id,
                "matched_geo_accessions": matched,
                "mapping_status": status,
                "exclusion_reason": "matched_GEO_accession_not_found_in_flattened_metadata"
            })
            continue

        group = discovery_group(row.get("characteristics_infection_type", ""))
        primary = include_primary(group)

        locked.append({
            "expression_sample_id": expr_id,
            "geo_accession": matched,
            "title": row.get("title", ""),
            "include_in_locked_discovery_table": "yes",
            "include_in_primary_bacterial_vs_viral_discovery": primary,
            "discovery_group": group,
            "infection_type_original": row.get("characteristics_infection_type", ""),
            "pathogen": row.get("characteristics_pathogen", ""),
            "site": row.get("characteristics_site", ""),
            "sequencing_batch": row.get("characteristics_sequencing_batch", ""),
            "platform_id": row.get("platform_id", ""),
            "instrument_model": row.get("instrument_model", ""),
            "age": row.get("characteristics_age", ""),
            "gender": row.get("characteristics_gender", ""),
            "race": row.get("characteristics_race", ""),
            "source_name": row.get("source_name_ch1", ""),
            "mapping_status": status,
            "matched_metadata_fields": m.get("matched_metadata_fields", "")
        })

    fields = [
        "expression_sample_id", "geo_accession", "title",
        "include_in_locked_discovery_table",
        "include_in_primary_bacterial_vs_viral_discovery",
        "discovery_group", "infection_type_original", "pathogen", "site",
        "sequencing_batch", "platform_id", "instrument_model",
        "age", "gender", "race", "source_name",
        "mapping_status", "matched_metadata_fields"
    ]

    write_tsv(LOCKED_TABLE, locked, fields)

    exclusion_fields = [
        "expression_sample_id", "matched_geo_accessions",
        "mapping_status", "exclusion_reason"
    ]
    write_tsv(EXCLUSION_TABLE, exclusions, exclusion_fields)

    group_counts = Counter(r["discovery_group"] for r in locked)
    primary_counts = Counter(
        r["discovery_group"] for r in locked
        if r["include_in_primary_bacterial_vs_viral_discovery"] == "yes"
    )
    site_counts = Counter(r["site"] for r in locked)
    site_by_group = defaultdict(Counter)
    pathogen_counts = Counter(r["pathogen"] for r in locked)
    batch_counts = Counter(r["sequencing_batch"] for r in locked)

    for r in locked:
        site_by_group[r["site"]][r["discovery_group"]] += 1

    primary_rows = [
        r for r in locked
        if r["include_in_primary_bacterial_vs_viral_discovery"] == "yes"
    ]

    with REPORT.open("w", encoding="utf-8") as out:
        out.write("# GSE211567 Discovery Sample Table Lock Report\n\n")
        out.write(f"- Generated: {datetime.now().isoformat(timespec='seconds')}\n")
        out.write("- Purpose: lock the discovery sample table before any GSE211567 discovery modelling.\n")
        out.write("- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.\n\n")

        out.write("## Locking decision\n\n")
        out.write("- Include expression samples with unique GEO metadata match.\n")
        out.write("- Exclude `DU09-03S0000029` because it is present in the normalized expression matrix but absent from the authoritative GEO family SOFT metadata and lacks an explicit metadata bridge.\n")
        out.write("- Retain noninfection samples as contextual/control metadata, but exclude them from the primary bacterial-versus-viral discovery contrast.\n")
        out.write("- Primary discovery contrast is bacterial versus viral infection, with site/context strata preserved for heterogeneity/concordance analysis.\n\n")

        out.write("## Locked sample counts\n\n")
        out.write(f"- Expression samples in normalized matrix metadata mapping file: {len(mappings)}\n")
        out.write(f"- Locked samples retained: {len(locked)}\n")
        out.write(f"- Excluded samples: {len(exclusions)}\n")
        out.write(f"- Primary bacterial-versus-viral discovery samples: {len(primary_rows)}\n\n")

        out.write("## Discovery group counts among locked samples\n\n")
        for k, v in sorted(group_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Primary discovery contrast counts\n\n")
        for k, v in sorted(primary_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Site counts among locked samples\n\n")
        for k, v in sorted(site_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Site × discovery group counts\n\n")
        for site in sorted(site_by_group):
            out.write(f"- {site}:\n")
            for group, n in sorted(site_by_group[site].items()):
                out.write(f"  - {group}: {n}\n")

        out.write("\n## Pathogen counts among locked samples\n\n")
        for k, v in sorted(pathogen_counts.items()):
            out.write(f"- {k}: {v}\n")

        out.write("\n## Sequencing batch counts among locked samples\n\n")
        for k, v in sorted(batch_counts.items()):
            out.write(f"- batch {k}: {v}\n")

        out.write("\n## Exclusions\n\n")
        for e in exclusions:
            out.write(f"- {e['expression_sample_id']}: {e['exclusion_reason']}\n")

        out.write("\n## Generated files\n\n")
        out.write(f"- `{LOCKED_TABLE}`\n")
        out.write(f"- `{EXCLUSION_TABLE}`\n\n")

        out.write("## Next action\n\n")
        out.write("- Proceed to discovery-side normalized-matrix QC using the locked 290-sample table.\n")
        out.write("- No biological module discovery should begin until normalized-matrix QC, sample alignment and site/batch structure are reviewed.\n")

    print(f"Wrote {LOCKED_TABLE}")
    print(f"Wrote {EXCLUSION_TABLE}")
    print(f"Wrote {REPORT}")

if __name__ == "__main__":
    main()
