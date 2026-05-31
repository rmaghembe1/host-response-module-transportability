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

## 2026-05-31 — GSE211567 site-stratified concordance gate
- Decision: Proceed toward pathway/module discovery with site-aware safeguards.
- Evidence: The pooled bacterial-versus-viral limma model was directionally concordant with the Sri Lanka site-stratified model for 87.20% of all modelled features and with the United States model for 77.34% of all modelled features.
- Evidence: Among pooled FDR < 0.05 features, 99.14% were directionally concordant with Sri Lanka, 93.11% were directionally concordant with the United States, and 92.25% were concordant across pooled, Sri Lanka and United States analyses.
- Site contrast note: Sri Lanka and United States showed moderate direct logFC concordance, indicating that site/pathogen ecology contributes to the signal and should remain explicit in interpretation.
- Modelling implication: Use the pooled limma ranking as the discovery backbone, but prioritize features/pathways/modules with cross-site directional support.
- Interpretation safeguard: Avoid presenting pooled-only top genes as universal bacterial-versus-viral biology unless supported by site-stratified concordance.
- Next action: Generate a site-aware feature-stability table and then proceed to pathway/module discovery using concordance-filtered or concordance-annotated ranked evidence.
- Boundary: This gate still does not define biological modules or pathway-level claims.

## 2026-05-31 — GSE211567 site-aware feature universe lock
- Decision: Use the site-aware eligible feature set as the primary input for pathway/module discovery.
- Eligible primary feature universe: 9,224 site-aware features with pooled FDR support and cross-site directional concordance.
- Direction-aware subsets: 2,788 bacterial-higher eligible features and 6,436 viral-higher eligible features.
- Primary module-discovery rule: prioritize Tier 1–3 eligible features for stable cross-site pathway/module discovery.
- Secondary/contextual rule: treat Tier 4 partial-support features as site/ecology-contextual evidence only.
- Exclusion rule: do not use lower/unstable features as primary module anchors.
- Interpretation safeguard: pathway/module claims must distinguish stable cross-site programmes from site- or pathogen-ecology-specific signals.
- Boundary: this decision locks the evidence universe for enrichment/module discovery but does not itself define biological modules or interpret pathways.

## 2026-05-31 — GSE211567 gene-level enrichment input lock
- Decision: Run enrichment/module discovery using gene-level ENTREZ-backed identifiers generated from the RefSeq transcript annotation bridge.
- Annotation result: 19,947 of 19,999 RefSeq transcript features mapped to at least one gene-level identifier; 52 unmapped RefSeq features will be excluded from enrichment identifiers.
- Primary enrichment universe: 9,100 gene-level ENTREZ identifiers from all modelled features.
- Primary site-aware eligible gene set: 4,324 gene-level eligible features after transcript-to-gene collapsing.
- Direction-aware enrichment inputs: 1,479 bacterial-higher eligible genes and 2,854 viral-higher eligible genes.
- Collapse rule: transcript-level evidence is collapsed to one representative row per ENTREZID by strongest pooled P value while retaining site-aware direction/stability annotations.
- Identifier rule: enrichment should use ENTREZID as the primary identifier, with SYMBOL/GENENAME retained for interpretation.
- Interpretation safeguard: enrichment/module claims must be made at gene-level, not raw RefSeq-transcript level, unless transcript-specific biology is explicitly justified later.
- Boundary: this decision locks the identifier universe for enrichment but does not itself define biological modules or pathway claims.
