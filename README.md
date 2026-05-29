# Host-Pathogen Transcriptomic Transportability Project

**Protocol version:** 1.0 (29 May 2026)  
**Project lead:** Reuben S. Maghembe  
**Planned repository:** `host-pathogen-transcriptome-transportability`

## Central question
Which whole-blood immune-metabolic programs associated with acute bacterial versus viral infection are conserved across pathogen ecologies and transportable into independent cohorts?

## Analytical firewall
- `GSE211567` is the scientific discovery resource and internal context-concordance cohort.
- `GSE161731` is the primary adult external transportability cohort; it may be used before module lock only for technical rehearsal of count-level workflow.
- `GSE261482` is exploratory pediatric generalizability after module lock.
- `GSE282464` is conditional and requires a dedicated metadata/sample-structure audit before inclusion.
- This project is not a new diagnostic-classifier development exercise.
- Frozen modules must not be reselected, reweighted or reoriented after external cohort inspection.

## Current milestone status
- [x] Protocol received and adopted as governing project document.
- [x] Level-1 source/registry feasibility audit initiated from official GEO records and primary publications.
- [ ] Local download of supplementary matrices and metadata, checksum generation and content-level sample reconciliation.
- [ ] Locked dataset eligibility report.
- [ ] Technical workflow rehearsal using GSE161731 only.
- [ ] GSE211567 discovery modelling and module lock.

## Immediate execution order
1. Run `scripts/bash/01_download_geo_supplementary_files.sh` on the analysis workstation.
2. Generate the local file manifest and SHA-256 checksums.
3. Inspect matrices and metadata to reconcile sample-count and class-label discrepancies.
4. Update `docs/dataset_feasibility_audit_v0.1_2026-05-29.md` to a locked eligibility report before inferential analysis.
