#!/usr/bin/env bash
set -euo pipefail

# Host-Pathogen Transcriptomic Transportability Project
# Phase 1: staged download of official GEO supplementary files and provenance checksums.
#
# Default behavior:
#   - Download essential files for discovery/adult/pediatric feasibility audit.
#   - Do NOT download optional normalized matrices.
#   - Do NOT download the conditional GSE282464 archive unless explicitly enabled.
#
# Optional usage:
#   DOWNLOAD_OPTIONAL=true bash scripts/bash/01_download_geo_supplementary_files.sh
#   DOWNLOAD_CONDITIONAL=true bash scripts/bash/01_download_geo_supplementary_files.sh

RAW_DIR="data/raw"
META_DIR="data/metadata_raw"
LOG_DIR="docs/download_logs"

DOWNLOAD_OPTIONAL="${DOWNLOAD_OPTIONAL:-false}"
DOWNLOAD_CONDITIONAL="${DOWNLOAD_CONDITIONAL:-false}"

mkdir -p "$RAW_DIR" "$META_DIR" "$LOG_DIR"

CORE_MANIFEST="$META_DIR/geo_supplementary_download_manifest_core.tsv"
OPTIONAL_MANIFEST="$META_DIR/geo_supplementary_download_manifest_optional.tsv"
CONDITIONAL_MANIFEST="$META_DIR/geo_supplementary_download_manifest_conditional.tsv"
COMBINED_MANIFEST="$META_DIR/geo_supplementary_download_manifest_requested.tsv"

cat > "$CORE_MANIFEST" <<'MANIFEST'
accession	role	url	filename
GSE211567	discovery	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE211nnn/GSE211567/suppl/GSE211567_normData_discovery_2021MAR24.txt.gz	GSE211567_normData_discovery_2021MAR24.txt.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_counts.csv.gz	GSE161731_counts.csv.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_counts_key.csv.gz	GSE161731_counts_key.csv.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_key.csv.gz	GSE161731_key.csv.gz
GSE261482	pediatric_feasibility_only	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE261nnn/GSE261482/suppl/GSE261482_Counts_raw_data.csv.gz	GSE261482_Counts_raw_data.csv.gz
MANIFEST

cat > "$OPTIONAL_MANIFEST" <<'MANIFEST'
accession	role	url	filename
GSE161731	adult_external_optional_normalized	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_xpr_nlcpm.csv.gz	GSE161731_xpr_nlcpm.csv.gz
GSE161731	adult_external_optional_normalized	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_xpr_tpm_geo.txt.gz	GSE161731_xpr_tpm_geo.txt.gz
GSE261482	pediatric_optional_normalized	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE261nnn/GSE261482/suppl/GSE261482_Normalized_data.csv.gz	GSE261482_Normalized_data.csv.gz
MANIFEST

cat > "$CONDITIONAL_MANIFEST" <<'MANIFEST'
accession	role	url	filename
GSE282464	conditional_extension_not_primary	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE282nnn/GSE282464/suppl/GSE282464_RAW.tar	GSE282464_RAW.tar
MANIFEST

cp "$CORE_MANIFEST" "$COMBINED_MANIFEST"

if [[ "$DOWNLOAD_OPTIONAL" == "true" ]]; then
  tail -n +2 "$OPTIONAL_MANIFEST" >> "$COMBINED_MANIFEST"
fi

if [[ "$DOWNLOAD_CONDITIONAL" == "true" ]]; then
  tail -n +2 "$CONDITIONAL_MANIFEST" >> "$COMBINED_MANIFEST"
fi

echo "===== Requested download manifest ====="
column -t -s $'\t' "$COMBINED_MANIFEST" || cat "$COMBINED_MANIFEST"
echo

while IFS=$'\t' read -r accession role url filename; do
  [[ "$accession" == "accession" ]] && continue
  echo "Downloading $filename ($accession; $role)"
  wget -c -O "$RAW_DIR/$filename" "$url"
done < "$COMBINED_MANIFEST" 2>&1 | tee "$LOG_DIR/01_geo_supplementary_download.log"

(
  cd "$RAW_DIR"
  find . -maxdepth 1 -type f ! -name '.gitkeep' -printf '%f\n' | sort |
  while read -r file; do
    sha256sum "$file"
  done
) > "$META_DIR/geo_supplementary_files_sha256.tsv"

find "$RAW_DIR" -maxdepth 1 -type f ! -name '.gitkeep' -printf '%f\t%s bytes\n' |
  sort > "$META_DIR/geo_supplementary_file_sizes.tsv"

{
  echo "# GEO Supplementary Retrieval Record"
  echo
  echo "- Retrieval date: $(date -Iseconds)"
  echo "- Optional normalized files downloaded: $DOWNLOAD_OPTIONAL"
  echo "- Conditional GSE282464 archive downloaded: $DOWNLOAD_CONDITIONAL"
  echo "- Purpose: file and metadata feasibility audit only; no biological inference."
  echo
  echo "## Retrieved files"
  echo
  sed 's/^/- /' "$META_DIR/geo_supplementary_file_sizes.tsv"
} > "$META_DIR/geo_supplementary_retrieval_record.md"

echo
echo "Download and checksum stage complete."
echo "GSE282464 remains undownloaded unless DOWNLOAD_CONDITIONAL=true was explicitly supplied."
echo "Next: inspect matrix dimensions, identifiers and key-file sample structure before modelling."
