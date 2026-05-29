#!/usr/bin/env bash
set -euo pipefail

# Host-Pathogen Transcriptomic Transportability Project
# Download official GEO supplementary matrices/key files and generate provenance checksums.
# Run from the repository root on the local analysis workstation/WSL environment.

RAW_DIR="data/raw"
META_DIR="data/metadata_raw"
LOG_DIR="docs/download_logs"
mkdir -p "$RAW_DIR" "$META_DIR" "$LOG_DIR"

cat > "$META_DIR/geo_supplementary_download_manifest.tsv" <<'MANIFEST'
accession	role	url	filename
GSE211567	discovery	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE211nnn/GSE211567/suppl/GSE211567_normData_discovery_2021MAR24.txt.gz	GSE211567_normData_discovery_2021MAR24.txt.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_counts.csv.gz	GSE161731_counts.csv.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_counts_key.csv.gz	GSE161731_counts_key.csv.gz
GSE161731	adult_external_technical_rehearsal	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_key.csv.gz	GSE161731_key.csv.gz
GSE161731	adult_external_optional_normalized	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_xpr_nlcpm.csv.gz	GSE161731_xpr_nlcpm.csv.gz
GSE161731	adult_external_optional_normalized	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE161nnn/GSE161731/suppl/GSE161731_xpr_tpm_geo.txt.gz	GSE161731_xpr_tpm_geo.txt.gz
GSE261482	pediatric_extension	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE261nnn/GSE261482/suppl/GSE261482_Counts_raw_data.csv.gz	GSE261482_Counts_raw_data.csv.gz
GSE261482	pediatric_extension	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE261nnn/GSE261482/suppl/GSE261482_Normalized_data.csv.gz	GSE261482_Normalized_data.csv.gz
GSE282464	conditional_extension	https://ftp.ncbi.nlm.nih.gov/geo/series/GSE282nnn/GSE282464/suppl/GSE282464_RAW.tar	GSE282464_RAW.tar
MANIFEST

while IFS=$'\t' read -r accession role url filename; do
  [[ "$accession" == "accession" ]] && continue
  echo "Downloading $filename ($accession; $role)"
  wget -c -O "$RAW_DIR/$filename" "$url"
done < "$META_DIR/geo_supplementary_download_manifest.tsv" 2>&1 | tee "$LOG_DIR/01_geo_supplementary_download.log"

(
  cd "$RAW_DIR"
  sha256sum * | sort
) > "$META_DIR/geo_supplementary_files_sha256.tsv"

ls -lh "$RAW_DIR" > "$META_DIR/geo_supplementary_file_sizes.txt"

echo "Download and checksum stage complete."
echo "Next: run metadata/matrix dimension inspection before any modelling."
