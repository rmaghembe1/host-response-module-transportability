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

## 2026-05-31 — GSE211567 first-pass GO BP ORA completion
- Decision: Accept the manual GO Biological Process ORA as the first direction-aware enrichment discovery layer.
- Method: manual one-sided Fisher exact over-representation analysis using org.Hs.eg.db and GO.db, avoiding the failed clusterProfiler dependency chain.
- Universe: 9,100 modelled gene-level ENTREZ identifiers.
- Direction-aware inputs: 1,479 bacterial-higher site-aware eligible genes and 2,854 viral-higher site-aware eligible genes.
- Result: bacterial-higher genes yielded 7 GO BP terms at BH FDR < 0.05 and 8 at BH FDR < 0.10.
- Result: viral-higher genes yielded 23 GO BP terms at BH FDR < 0.05 and 35 at BH FDR < 0.10.
- Interpretation boundary: enriched GO terms are discovery evidence only; they do not yet define final biological modules.
- Next action: perform GO-term redundancy reduction and overlap-gene inspection before assigning module names.

## 2026-05-31 — GSE211567 provisional candidate-module review table
- Decision: Accept the provisional candidate-module review table as an evidence-organising layer for manual biological review.
- Input: 35 redundancy-reduced GO BP candidate groups, 43 GO-term membership rows and 1,724 candidate-group overlap-gene rows.
- Output: 18 provisional higher-order module rows with module direction, evidence grade, representative GO terms, top overlap genes and interpretation status.
- Bacterial-higher candidate programmes include cytoplasmic translation/ribosomal proteins, mitochondrial respiration/oxidative phosphorylation, glutathione/redox metabolism and glycolytic process.
- Viral-higher candidate programmes include antiviral/interferon response, cytokine/innate immune regulation, B-cell/adaptive activation, transcription/chromatin regulation, chemotaxis/immune trafficking, and NF-kB/kinase/signal-transduction-related evidence.
- Interpretation safeguard: provisional module labels are evidence-organising labels only; they are not final manuscript-ready module names.
- Contextual/borderline rows must not be used as primary biological claims unless strengthened by manual evidence review or additional validation.
- Next action: manually review candidate-module rows, member GO terms and overlap genes to decide which modules are retained as primary, secondary or contextual.

## 2026-05-31 — GSE211567 manual candidate-module review tiering
- Decision: Accept the manual module decision table as a controlled review-tiering layer.
- Output: 18 provisional module rows were classified into primary, secondary and contextual/borderline tiers.
- Primary candidate modules: 5 rows comprising 2 bacterial-higher and 3 viral-higher module rows.
- Secondary candidate modules: 5 rows comprising 1 bacterial-higher and 4 viral-higher module rows.
- Contextual/borderline modules: 8 rows comprising 1 bacterial-higher and 7 viral-higher module rows.
- Primary bacterial-higher candidates: cytoplasmic translation/ribosomal protein programme and mitochondrial respiration/oxidative phosphorylation programme.
- Primary viral-higher candidates: antiviral/interferon-response programme, cytokine/innate immune regulation programme and a compact antiviral/interferon restriction subgroup.
- Interpretation safeguard: primary candidate modules are eligible for manual biological review only; they are not yet final manuscript claims or externally validated transportable modules.
- Next action: inspect primary candidate-module overlap genes, directionality and site-aware stability before naming final discovery modules.

## 2026-05-31 — GSE211567 primary-module gene-level inspection
- Decision: Accept the primary candidate-module gene-level inspection as a quality-control gate before final discovery-module naming.
- Input: 5 primary candidate module rows, 15 primary-module GO-term rows and 322 primary-module overlap-gene rows.
- Result: all five primary candidate rows passed initial gene-level inspection after duplicate gene handling.
- Result: all five primary candidate rows showed 100% Tier 1–3/site-aware direction-concordant gene membership after unique ENTREZID summarisation.
- Primary bacterial-higher rows: mitochondrial respiration/oxidative phosphorylation and cytoplasmic translation/ribosomal protein programmes.
- Primary viral-higher rows: one broad antiviral/interferon-response programme, one compact antiviral/interferon restriction subgroup and one cytokine/innate immune regulation programme.
- Antiviral/interferon merge assessment: two primary antiviral/interferon rows shared 29 genes with Jaccard overlap 0.2197; retain as related submodules pending manual biological review rather than force-merging.
- Interpretation safeguard: these primary rows remain candidate discovery modules, not final manuscript claims or externally validated transportable modules.
- Next action: create a final discovery-module label table with conservative labels, preserving submodule structure and evidence boundaries.

## 2026-05-31 — GSE211567 final discovery-module label lock
- Decision: Accept the conservative final GSE211567 discovery-module label table as the locked discovery-module set for downstream scoring and projection planning.
- Final bacterial-higher discovery modules: BACT_M1, bacterial-higher cytoplasmic translation and ribosomal protein programme; BACT_M2, bacterial-higher mitochondrial respiration and oxidative phosphorylation programme.
- Final viral-higher discovery modules: VIR_M1a, viral-higher broad antiviral and interferon-stimulated defence programme; VIR_M1b, viral-higher viral restriction and type I interferon signalling subgroup; VIR_M2, viral-higher cytokine and innate immune regulation programme.
- Antiviral/interferon boundary: VIR_M1a and VIR_M1b are retained as related submodules rather than force-merged because their pairwise gene-overlap Jaccard was 0.2197 with 29 shared genes.
- Evidence basis: all final discovery-module rows passed primary gene-level inspection, retained FDR-supported GO BP evidence and showed 100% Tier 1–3/site-aware direction-concordant gene membership after unique ENTREZID summarisation.
- Interpretation safeguard: these are GSE211567 discovery-module labels only; they are not externally validated transportable modules, diagnostic signatures or causal claims.
- Next action: build module scoring inputs and define projection rules before applying modules to any external cohort.

## 2026-05-31 — GSE211567 projection-ready module scoring inputs
- Decision: Accept the GSE211567 projection-ready module scoring inputs as the locked input set for downstream scoring and external projection planning.
- Locked modules: BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2.
- Module sizes: BACT_M1 = 25 genes, BACT_M2 = 21 genes, VIR_M1a = 128 genes, VIR_M1b = 33 genes and VIR_M2 = 106 genes.
- Primary scoring rule: use unweighted mean z-score module scoring after gene-wise z-scoring within each external dataset.
- Missing-gene rule: ignore missing genes for score calculation but report per-module gene coverage.
- Projection eligibility rule: require at least 50% locked-gene coverage for primary projection; optionally repeat using a stricter 70% coverage threshold as sensitivity.
- Direction rule: preserve GSE211567 discovery orientation; bacterial-higher modules retain direction sign +1 and viral-higher modules retain direction sign -1. Do not flip direction using external outcomes.
- Sensitivity rule: bounded abs(logFC)-weighted scoring is allowed only as optional sensitivity and must not replace the primary unweighted score.
- Interpretation safeguard: external cohorts must not be used to reselect genes, rename modules or alter module composition; projection tests fixed-module transportability, not discovery.
- Next action: prepare an external projection/rehearsal script, beginning with GSE161731 only as a technical projection rehearsal unless a formal validation cohort is separately locked.

## 2026-05-31 — GSE161731 technical projection identifier-coverage audit
- Decision: Accept the GSE161731 identifier-coverage audit as a technical projection-readiness gate only.
- Result: GSE161731 expression features are ENSEMBL gene IDs, explaining the earlier 0% SYMBOL-only coverage result.
- Corrected matching approach: locked GSE211567 module ENTREZID identifiers were mapped to ENSEMBL IDs using org.Hs.eg.db before checking GSE161731 expression-row coverage.
- Coverage results: BACT_M1 = 96.00%, BACT_M2 = 100.00%, VIR_M1a = 97.66%, VIR_M1b = 96.97% and VIR_M2 = 94.34%.
- Projection eligibility: all five locked discovery modules pass both the 50% primary and 70% sensitivity coverage thresholds.
- Interpretation safeguard: GSE161731 remains a technical projection rehearsal resource, not a formal validation cohort.
- Boundary: this step performs identifier coverage only; it does not compute module scores, test biological hypotheses or make transportability claims.
- Next action: run fixed-module technical scoring rehearsal in GSE161731 using unweighted mean z-score scoring, while preserving the firewall against biological validation claims.

## 2026-05-31 — GSE161731 fixed-module technical scoring rehearsal
- Decision: Accept the GSE161731 fixed-module scoring run as a successful technical rehearsal of locked GSE211567 module scoring.
- Input: locked GSE211567 modules BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2.
- Scoring method: unweighted mean z-score scoring after gene-wise z-scoring within GSE161731.
- Technical result: 20,561 expression features and 102 samples were scored, producing 510 module-score rows.
- Coverage result: all five modules were scoreable using ENSEMBL-mapped GSE161731 features.
- Metadata result: the scoring script selected `rna_id` as the sample identifier column and `technical_rehearsal_group` as the technical grouping column.
- Interpretation safeguard: GSE161731 remains a technical projection rehearsal resource only; these scores must not be described as external validation, transportability evidence or biological confirmation.
- Boundary: no module rediscovery, gene reselection, module renaming, effect-size reweighting or validation claim was performed.
- Next action: prepare a formal external validation/projection cohort lock before making transportability claims.

## 2026-05-31 — Transition from technical rehearsal to formal external projection planning
- Decision: Stop interpreting GSE161731 beyond technical scoring rehearsal.
- Rationale: GSE161731 has already served as a workflow and projection-scoring rehearsal resource and must not be promoted to formal validation without a separate cohort-lock decision.
- Current status: GSE211567 discovery modules are locked, projection-ready scoring inputs are locked, and GSE161731 has verified the technical scoring workflow.
- Boundary: no biological claims, validation claims or transportability claims will be made from GSE161731 technical rehearsal outputs.
- Next phase: identify and lock a formal external projection cohort using predefined eligibility criteria before scoring fixed GSE211567 modules.
- Required external cohort criteria: independent cohort, compatible whole-blood or comparable host transcriptome data, usable gene identifiers, adequate bacterial and viral or relevant pathogen-class metadata, sufficient sample size, and no use in discovery/module definition.

## 2026-05-31 — GSE261482 external projection candidate audit boundary
- Decision: Do not lock GSE261482 as the primary formal bacterial-versus-viral external projection cohort.
- Evidence: GSE261482 has valid expression files, including raw counts with ENSEMBL-like feature IDs and normalized data with SYMBOL-like feature IDs.
- Evidence: both expression files contain 177 sample columns numbered 1–177, and count/normalized sample columns are consistent.
- Evidence: GEO metadata and expression mapping audits support pediatric/blood/RNA-seq feasibility and bacterial/control-related structure.
- Blocking issue: viral/pathogen-class metadata was not recovered in the parsed GEO metadata or keyword audit.
- Current status: GSE261482 remains a conditional secondary pediatric bacterial/control or infection/control generalizability candidate, not a bacterial-versus-viral validation cohort.
- Interpretation safeguard: locked GSE211567 modules must not be scored in GSE261482 for bacterial-versus-viral projection unless reliable pathogen-class labels are recovered and a separate cohort-lock decision is made.
- Next action: search for or audit a stronger independent formal external projection cohort with confirmed bacterial and viral labels.

## 2026-05-31 — GSE68310 supplementary phenotype/expression inspection boundary
- Decision: Do not lock GSE68310 as the primary formal bacterial-versus-viral external projection cohort.
- Evidence: the supplementary phenotype file was valid and contained subject-level influenza metadata, including `Virus_by_PCR` values such as `influenza_A_virus`.
- Evidence: the non-normalized expression file was valid and contains longitudinal subject-timepoint expression columns such as Baseline, Day0, Day2, Day4, Day6, Day21 and Spring, with AVG_Signal and Detection P-value measurements.
- Technical status: GSE68310 is expression-usable and metadata-usable for a longitudinal influenza host-response analysis.
- Blocking issue: GSE68310 does not provide a bacterial-versus-viral pathogen-class contrast for the locked GSE211567 discovery-module projection question.
- Current status: GSE68310 may remain a secondary viral-only longitudinal perturbation/generalizability candidate, but it is not eligible as the primary bacterial-versus-viral validation/projection cohort.
- Interpretation safeguard: locked GSE211567 bacterial-versus-viral modules must not be formally validated using GSE68310 unless a separate viral-only question and cohort-lock decision are created.
- Next action: continue searching/auditing independent cohorts with confirmed bacterial and viral labels.

## 2026-05-31 — GSE73461 formal external projection cohort lock
- Decision: Lock GSE73461 as the formal external projection cohort for fixed GSE211567 discovery-module scoring.
- Rationale: GSE73461 passed metadata, expression-label, sample-structure and identifier-coverage gates.
- Metadata/sample gate: GSE73461 contains 459 expression samples with clear projection-relevant groups, including 52 DefiniteBacterial samples and 94 DefiniteViral samples.
- Control/context groups: 55 Control samples are retained as secondary context; Inflammatory, Kawasaki and Unknown groups are excluded from the primary bacterial-versus-viral projection contrast.
- Expression gate: processed raw and normalized discovery matrices are valid, contain 47,323 feature rows, have 459 expression columns and 459 paired detection P-value columns, and raw/normalized sample sets are identical.
- Annotation gate: GSE73461 Illumina probes were mapped using `illuminaHumanv4.db`, avoiding the oversized GPL10558 family SOFT download.
- Identifier coverage gate: all five locked GSE211567 modules passed both the 50% primary and 70% sensitivity coverage thresholds in GSE73461.
- Module coverage: BACT_M1 = 24/25 genes, BACT_M2 = 21/21 genes, VIR_M1a = 128/128 genes, VIR_M1b = 33/33 genes and VIR_M2 = 105/106 genes.
- Locked scoring rule: apply the pre-specified unweighted mean z-score scoring rule using fixed GSE211567 module genes; do not reselect genes, rename modules, reweight modules or change module composition.
- Primary projection contrast: DefiniteBacterial versus DefiniteViral only.
- Interpretation safeguard: GSE73461 projection may support module transportability assessment, but must not be framed as diagnostic signature discovery or causal validation.
- Next action: run fixed-module GSE73461 projection scoring after this lock.

## 2026-05-31 — GSE73461 fixed-module external projection scoring result
- Decision: Accept the GSE73461 fixed-module projection scoring run as the formal external projection analysis of locked GSE211567 discovery modules.
- Input: locked GSE211567 modules BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2.
- Cohort: locked GSE73461 external projection cohort, restricted to the primary DefiniteBacterial versus DefiniteViral contrast, with Control retained only as secondary context.
- Scoring method: pre-specified unweighted mean z-score scoring after gene-wise z-scoring within GSE73461; no gene reselection, module renaming, reweighting or diagnostic model training was performed.
- Sample counts: 52 DefiniteBacterial samples, 94 DefiniteViral samples and 55 secondary Control/context samples.
- Coverage used for scoring: BACT_M1 = 24/25 genes, BACT_M2 = 21/21 genes, VIR_M1a = 128/128 genes, VIR_M1b = 33/33 genes and VIR_M2 = 105/106 genes.
- Result: all five modules showed expected-direction concordance in GSE73461.
- BACT_M1: bacterial-higher direction matched, median bacterial-minus-viral difference +0.2067, Wilcoxon P = 0.0799, BH P = 0.0799; interpret as directionally concordant but borderline.
- BACT_M2: bacterial-higher direction matched, median difference +0.3328, Wilcoxon P = 0.0162, BH P = 0.0202.
- VIR_M1a: viral-higher direction matched, median difference −0.4629, Wilcoxon P = 1.91e-06, BH P = 4.77e-06.
- VIR_M1b: viral-higher direction matched, median difference −0.6739, Wilcoxon P = 2.82e-07, BH P = 1.41e-06.
- VIR_M2: viral-higher direction matched, median difference −0.2596, Wilcoxon P = 0.00509, BH P = 0.00848.
- Interpretation safeguard: these results support fixed-module transportability across an independent external cohort; they must not be framed as new diagnostic-signature discovery, causal validation or model training.
- Next action: prepare an interpretation summary and optional sensitivity checks before manuscript-style Results drafting.

## 2026-05-31 — GSE73461 primary-only z-score projection sensitivity
- Decision: Accept the primary-only z-score sensitivity analysis as a valid robustness check for the GSE73461 fixed-module projection.
- Purpose: test whether the external projection result is robust when gene-wise z-scoring is performed using only the primary DefiniteBacterial and DefiniteViral samples, excluding Control samples from the z-score reference set.
- Sample counts: 52 DefiniteBacterial samples and 94 DefiniteViral samples were included; 55 Control samples were excluded from the z-score reference set.
- Result: all five locked modules retained expected-direction concordance.
- BACT_M1: bacterial-higher direction matched, median bacterial-minus-viral difference +0.2211, Wilcoxon P = 0.0778, BH P = 0.0778; remains directionally concordant but borderline.
- BACT_M2: bacterial-higher direction matched, median difference +0.3504, Wilcoxon P = 0.0132, BH P = 0.0165.
- VIR_M1a: viral-higher direction matched, median difference −0.4441, Wilcoxon P = 3.03e-06, BH P = 7.57e-06.
- VIR_M1b: viral-higher direction matched, median difference −0.6445, Wilcoxon P = 4.44e-07, BH P = 2.22e-06.
- VIR_M2: viral-higher direction matched, median difference −0.2626, Wilcoxon P = 0.00478, BH P = 0.00796.
- Interpretation safeguard: this sensitivity supports robustness of fixed-module transportability to the z-scoring reference set; it remains external module projection, not diagnostic model discovery or causal validation.
- Next action: update the interpretation summary to include the primary-only z-score robustness result.

## 2026-05-31 — Publication-grade figure export standard
- Decision: Adopt a uniform publication-grade export standard for all manuscript-facing figures.
- Standard: export every manuscript-facing figure as 1800 dpi PNG, editable SVG and vector PDF.
- Rationale: PNG provides a high-resolution raster backup for submission systems; SVG provides an editable vector master; PDF provides a vector publication/shareable backup.
- Scope: applies to main manuscript figures and supplementary manuscript figures, including GSE73461 projection figures and future GSE211567 discovery-module figures.
- Implementation: use `scripts/R/00_publication_figure_export_helpers.R` and the `save_publication_figure()` helper for manuscript-facing figure export.

## 2026-05-31 — GSE73461 manuscript figures regenerated at publication resolution
- Decision: Accept the regenerated GSE73461 manuscript projection figure panels as publication-grade figure outputs.
- Export standard: each manuscript-facing GSE73461 projection panel is exported as 1800 dpi PNG, editable SVG and vector PDF.
- Implemented panels: module-score distributions, main-versus-sensitivity median differences and main-versus-sensitivity adjusted P-value comparison.
- Technical implementation: `scripts/R/00_publication_figure_export_helpers.R` now exports PNG at 1800 dpi, SVG using base R `grDevices::svg()` and PDF using `cairo_pdf`.
- Rationale: this avoids the `svglite` system-dependency issue while preserving an editable SVG backup, a vector PDF backup and high-resolution raster PNG.
- Interpretation safeguard: figure regeneration changes only export quality and file formats; it does not alter the underlying scoring results or interpretation.
- Next action: apply the same publication-grade export standard to all future manuscript-facing GSE211567 discovery and supplementary figures.

## 2026-05-31 — GSE211567 manuscript discovery figures regenerated at publication resolution
- Decision: Accept the GSE211567 manuscript discovery figure panels as publication-grade manuscript-facing outputs.
- Export standard: each GSE211567 discovery panel is exported as 1800 dpi PNG, editable SVG and vector PDF.
- Implemented panels: primary bacterial-versus-viral discovery volcano, site-stratified concordance summary and locked discovery-module gene-count summary.
- Technical correction: site-concordance plotting harmonized the direction-concordance table by retaining pairwise `_all_features` rows and stripping the suffix before merging with the logFC-correlation table.
- Quality check: all panels regenerated without removed-row warnings after the site-concordance merge correction.
- Interpretation safeguard: figure generation changes only manuscript presentation/export quality; it does not alter discovery modelling, site-aware filtering, module locking or external projection results.
- Next action: prepare the combined manuscript Results narrative linking GSE211567 discovery, conservative module locking and GSE73461 external projection.

## 2026-05-31 — Manuscript Results figure-table mapping and path audit completed
- Decision: Accept the manuscript Results-to-figure/table mapping as the current manuscript assembly guide.
- Scope: mapping links the combined Results narrative to GSE211567 discovery figures, GSE73461 projection figures, manuscript summary table, caption drafts and supporting source TSV outputs.
- Audit result: 37 mapped path entries expanded to 44 checked files; all 44 mapped files were present.
- Repair performed: replaced the obsolete GSE73461 coverage path with `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv`.
- Quality safeguard: the mapping audit script `scripts/python/37_audit_manuscript_mapping_paths.py` can be rerun after future manuscript edits to detect missing or outdated figure/table/source references.
- Interpretation safeguard: the mapped package supports fixed-module transportability analysis and must not be framed as diagnostic classifier training, gene rediscovery, module redefinition or causal validation.
- Next action: use the mapped Results package to prepare the integrated manuscript Results section with figure/table callouts.

## 2026-05-31 — Manuscript Results package assembly and audits completed
- Decision: Accept the current manuscript Results package as assembled, indexed and audit-checked for manuscript drafting.
- Completed components: integrated Results section with figure/table callouts, polished Figure 1 and Figure 2 captions, polished Table 1 title and footnotes, manuscript Results package index, manuscript Results-to-figure/table mapping, and supporting path-audit outputs.
- Figure standard: all main manuscript-facing GSE211567 and GSE73461 figure panels are available as 1800 dpi PNG, editable SVG and vector PDF.
- Mapping audit: manuscript Results-to-figure/table mapping expanded to 44 checked files, with 44 present and 0 missing.
- Package-index audit: manuscript Results package index contained 32 unique checked paths, with 32 present and 0 missing.
- Interpretation safeguard: the assembled package supports fixed-module transportability analysis across discovery and external projection cohorts; it must not be framed as diagnostic classifier discovery, diagnostic model training, gene rediscovery, module redefinition or causal validation.
- Current preferred framing: a site-aware discovery and conservative module-locking workflow identified bacterial- and viral-associated host-response programmes in GSE211567, and fixed-module projection in GSE73461 supported external transportability of the antiviral/interferon modules and the bacterial mitochondrial respiration/OXPHOS module, while the bacterial cytoplasmic translation/ribosomal module remained directionally concordant but borderline.
- Next action: proceed from Results-package assembly to manuscript-level Methods/Results integration and journal-targeted manuscript drafting.

## 2026-05-31 — Manuscript Methods package integrated with audited Results package
- Decision: Accept the current Methods materials as integrated into the manuscript package.
- Completed components: Methods–Results alignment map, Methods section skeleton, full Methods draft, and updated manuscript package index.
- Package-index update: Methods materials were added to `docs/manuscript_results_package_index.md`.
- Audit result: manuscript package index now contains 36 path entries, 35 unique checked paths, 35 present and 0 missing.
- Scope: the Methods draft describes the discovery/projection firewall, dataset selection, GSE211567 discovery preparation, differential-expression modelling, site-aware concordance, transcript-to-gene mapping, GO enrichment, conservative module locking, projection-ready scoring rules, GSE161731 technical rehearsal, GSE73461 cohort locking, identifier mapping, fixed-module projection, primary-only z-score sensitivity, reproducibility and interpretation boundaries.
- Interpretation safeguard: Methods wording preserves the fixed-module transportability framing and avoids diagnostic classifier, model-training, gene-rediscovery, module-redefinition and causal-validation claims.
- Next action: proceed to manuscript-level integration of Introduction, Methods, Results, figures, table and discussion framing.
