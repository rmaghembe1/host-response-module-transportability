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


## 2026-05-30 — GSE161731 technical rehearsal closeout
- Decision: Close the GSE161731 count-level technical rehearsal phase as successful for workflow-mastery purposes.
- Full rehearsal subset: 102 samples comprising 24 bacterial and 78 non-COVID viral samples.
- Sensitivity rehearsal subset: 99 samples after excluding the three counts-key-only caution samples 434482, 434741 and 94478.
- Technical result: count import, metadata alignment, gene filtering, TMM normalization, voom transformation, PCA/MDS plotting, session capture and QC reporting all executed successfully.
- Stability note: `filterByExpr` retained 20,561 genes in both the full and caution-sample-excluded sensitivity rehearsals.
- QC note: the full rehearsal identified metadata-caution samples with QC concerns; the sensitivity rehearsal resolved the metadata-integrity concern, although ordinary IQR-defined technical outliers remained and are documented.
- Firewall: GSE161731 has served only as a count-level workflow rehearsal resource. It must not influence GSE211567 discovery-module selection, module orientation, module weighting or biological interpretation.
- Next action: proceed to GSE211567 discovery-side metadata and sample-structure audit before any discovery modelling.

## 2026-05-31 — GSE211567 primary discovery design lock
- Decision: Proceed to first GSE211567 discovery modelling using the locked 224-sample bacterial-versus-viral primary discovery set.
- Primary discovery model: normalized expression ~ discovery_group + site + sequencing_batch.
- Rationale: the primary model matrix is full-rank, and both Sri Lanka and United States contain bacterial and viral samples, allowing pooled modelling with site/batch adjustment.
- Primary sample counts: 101 bacterial and 123 viral samples.
- Site-stratified feasibility: both sites support bacterial-versus-viral comparisons; site-stratified concordance will be used as an important secondary/sensitivity analysis.
- Covariates: age and gender are complete and may be considered in sensitivity models if stable; race will not be used in the primary adjustment because it is only 37.05% complete and site-linked.
- Excluded from primary adjustment: pathogen, because it is nested within infection group and partly site-linked; noninfection, because it is contextual/control only and not part of the primary bacterial-versus-viral contrast.
- QC-watch samples: the 18 expression-summary outliers will not be automatically excluded from the primary analysis because they passed metadata locking and matrix-integrity checks; leverage or outlier sensitivity may be evaluated later if needed.
- Analytical boundary: this design lock does not select genes, define modules, orient modules or make biological claims.
