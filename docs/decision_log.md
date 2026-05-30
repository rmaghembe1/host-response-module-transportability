# Decision Log

| Date | Decision ID | Decision | Rationale | Status | Files/commit |
|---|---|---|---|---|---|
| 2026-05-29 | D001 | Adopt Protocol v1.0 as the governing project document. | Maintains prospective, reproducible design and dataset-role firewall. | Locked | Protocol v1.0 |
| 2026-05-29 | D002 | Begin with source/metadata/file feasibility audit; do not begin biological inference. | Required by protocol and necessary because registry/publication sample-count discrepancies exist. | Locked | `docs/dataset_feasibility_audit_v0.1_2026-05-29.md` |
| 2026-05-29 | D003 | Retain GSE282464 as conditional only; evaluate whether combined use with GSE217948 is required. | Scientific Data publication states the dataset is partitioned across two GEO series and contains longitudinal components. | Open audit item | Dataset audit |
| 2026-05-29 | D004 | Do not copy group definitions from later classifier-validation papers into this analysis without reconstructing labels from accessible metadata. | Published validation subgroup counts conflict with GEO series descriptions for candidate datasets. | Locked | Dataset audit |

## 2026-05-30 — Staged GEO supplementary-file retrieval policy
- Decision: Revise the initial GEO retrieval script so that default execution downloads only files essential for the discovery/adult/pediatric feasibility audit.
- Rationale: GSE282464 is a conditional extension and must not be treated as an active analysis cohort before metadata, sample-structure and independence audits pass. Optional normalized matrices are not required for the first count-level feasibility inspection.
- Implementation: `scripts/bash/01_download_geo_supplementary_files.sh` now supports explicit `DOWNLOAD_OPTIONAL=true` and `DOWNLOAD_CONDITIONAL=true` flags; both are disabled by default.
- Analytical boundary: Retrieved files are for provenance and matrix/metadata feasibility assessment only. No pathway/module inference or external biological interpretation will occur at this stage.

## 2026-05-30 — GSE161731 technical-rehearsal eligibility lock
- Decision: Use GSE161731 only for count-level RNA-seq workflow rehearsal at this stage.
- Eligible technical-rehearsal contrast: Bacterial versus non-COVID viral infection, where non-COVID viral includes Influenza and CoV other.
- Current metadata-derived rehearsal sample size: 24 bacterial and 78 non-COVID viral samples.
- Exclusions: COVID-19 samples are excluded from the primary non-COVID rehearsal contrast; healthy controls are retained only for contextual QC/orientation; count-matrix-only samples without metadata are excluded.
- Caution flags: three counts-key-only samples are provisionally retained for technical rehearsal because they have usable cohort/key metadata, but they must be revisited before any formal external validation use.
- Firewall: This GSE161731 subset is for technical workflow mastery only. It must not influence GSE211567 discovery-module selection, module orientation, module weighting or biological interpretation.
