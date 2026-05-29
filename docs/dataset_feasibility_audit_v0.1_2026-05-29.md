# Dataset Feasibility and Eligibility Audit v0.1

**Project:** Host-Pathogen Transcriptomic Transportability Project  
**Audit stage:** Level-1 official registry and primary-publication verification  
**Audit date:** 29 May 2026  
**Inference status:** No biological inference has commenced.

## Executive decision
The prespecified project remains feasible, but biological modelling must not begin until content-level metadata reconciliation is completed. GSE161731 is presently confirmed as the most immediately workable count-level technical-rehearsal resource. GSE211567 remains the required discovery cohort, but its 294-versus-291 discrepancy and normalized-matrix suitability require resolution. GSE261482 remains an exploratory pediatric extension. GSE282464 remains conditional and now requires explicit audit together with GSE217948 because the data-descriptor publication states that the total cohort is divided between the two GEO series.

## Protocol-governed cohort roles
| Cohort | Prespecified role | Registry-level conclusion | Current eligibility decision |
|---|---|---|---|
| GSE211567 | Primary scientific discovery and USA/Sri Lanka internal concordance | Public; whole-blood RNA-seq; processed normalized matrix and SRA raw data available; sample discrepancy present | Retain as discovery; do not model until metadata and matrix audit pass |
| GSE161731 | Primary adult external transportability; technical rehearsal allowed | Public; count matrix plus count/sample key files available; comparator groups identifiable in GEO description | Retain; proceed first for download/content audit and workflow rehearsal only |
| GSE261482 | Exploratory pediatric generalizability | Public; raw counts and normalized data visible; GEO lists 177 samples but description states 192; DV group small | Retain conditionally after module lock and metadata reconciliation |
| GSE282464 | Conditional extension | Public; count TAR visible; GEO lists 377 while paper reports 681 samples/502 participants across GSE217948 and GSE282464 | Do not include in primary analyses; dedicated combined-series audit required |

## Official-source verification table
| Accession | Official series observations | Processed/count availability on GEO | Primary unresolved issue |
|---|---|---|---|
| GSE211567 | GEO states 294 whole-blood PAXgene RNA tubes from USA and Sri Lanka; GEO series lists 291 samples; two sequencing platforms are listed | `GSE211567_normData_discovery_2021MAR24.txt.gz` (46.0 MB); raw data in SRA | Resolve missing/omitted three samples, etiologic/site metadata, platform structure, and whether normalized matrix is suitable for limma or raw re-quantification is required |
| GSE161731 | GEO lists 198 samples; non-COVID comparator description gives bacterial pneumonia n=20, influenza n=17, seasonal coronavirus n=59 and healthy controls n=19; COVID includes repeated sampling | `GSE161731_counts.csv.gz`, `GSE161731_counts_key.csv.gz`, `GSE161731_key.csv.gz`, normalized CPM and TPM files; raw data in SRA | Reconcile the later Falsey et al. validation report of 24 bacterial and 78 viral observations; define primary non-COVID independent comparison from source metadata |
| GSE261482 | GEO description states 192 samples (154 pneumonia, 38 controls) and DB n=40/DV n=9, whereas the series lists 177 samples | `GSE261482_Counts_raw_data.csv.gz`; `GSE261482_Normalized_data.csv.gz`; raw data in SRA | Identify which samples are absent from GEO and whether definitive bacterial/viral labels are fully available for the listed expression matrix |
| GSE282464 | GEO lists 377 samples and a count TAR; series names visible on GEO are dominated by COVID-positive samples | `GSE282464_RAW.tar` of counts; raw data in SRA | Paper reports 681 samples from 502 participants and explicitly states that count data are split between GSE217948 and GSE282464; any bacterial-versus-viral analysis would require two-series merging, clinical metadata linkage and independence checks |

## Key literature-position finding
The novelty boundary is strengthened, not weakened. Ko et al. used GSE211567 to construct and validate diagnostic classifiers. Falsey et al. (2025) subsequently tested a four-gene bacterial-exclusion signature using GSE211567, GSE161731, GSE261482 and GSE282464 among external validation resources. Therefore a further classifier-focused paper would have significant redundancy risk. The present module-transportability design is scientifically justified provided it retains the discovery/validation firewall and reports context-dependent or negative transportability honestly.

## Important discrepancies requiring formal resolution
### 1. GSE211567: discovery cohort
- Publication and GEO overall design describe 294 discovery whole-blood samples/participants.
- GEO currently lists 291 series samples.
- Required resolution: compare series metadata, normalized-matrix columns and SRA run/sample mapping; determine whether three samples were withheld, excluded, missing or represented differently.

### 2. GSE161731: adult external cohort
- GEO describes non-COVID ARI comparators as bacterial pneumonia n=20, influenza n=17 and seasonal coronavirus n=59 (viral total n=76).
- Falsey et al. later report validation in GSE161731 using 24 bacterial and 78 viral observations.
- Required resolution: reconstruct diagnosis and sample independence from original key files; do not inherit the later study's classification without documenting its rule.

### 3. GSE261482: pediatric extension
- GEO summary states 192 collected/analyzed samples but lists 177 series samples.
- GEO defines the etiologic discovery comparison as DB n=40 versus DV n=9.
- Falsey et al. report a different definitive bacterial/viral subgroup size in their validation usage.
- Required resolution: inspect downloadable count columns and accessible phenotype metadata and establish a project-specific eligible pediatric subset before any frozen-module projection.

### 4. GSE282464: conditional extension
- The data-descriptor publication reports 681 samples from 502 participants and explicitly indicates the dataset is distributed across GSE217948 and GSE282464.
- GSE282464 alone lists 377 samples; its visible sample labels are COVID-positive, indicating it is not automatically the necessary bacterial-versus-non-COVID viral comparison resource by itself.
- Required resolution: do not analyze this extension until clinical metadata, group membership, longitudinal sampling and overlap with GSE217948 are reconstructed and an include/exclude memorandum is issued.

## Next mandatory actions
1. Download the visible supplementary matrices/key files from official GEO locations and generate SHA-256 checksums.
2. Obtain family/series metadata and, where required, publication supplementary clinical metadata.
3. Construct one content-level audit table per cohort: matrix dimensions, gene identifiers, sample identifiers, diagnosis labels, site/country, repeat-participant status, group counts and exclusions.
4. Lock primary contrast definitions only after metadata reconciliation.
5. Use GSE161731 for technical count-level workflow rehearsal only; do not select biological modules from it.
6. Proceed to GSE211567 biological discovery only after processing-branch choice and eligible-group definitions are documented.

## Sources verified during Level-1 audit
- NCBI GEO Series GSE211567 and Ko et al. (2023), *Scientific Reports*, 13, 22554.
- NCBI GEO Series GSE161731 and McClain et al. (2021), *Nature Communications*, 12, 1070/1079 as recorded by GEO/publication metadata.
- NCBI GEO Series GSE261482 and Viz-Lasheras et al. (2025), *iScience*, 28, 111747.
- NCBI GEO Series GSE282464 and Chew et al. (2025), *Scientific Data*, 12, 1175.
- Falsey et al. (2025), *Nature Communications*, four-gene bacterial-exclusion signature external-validation analysis.

## Status recommendation
**Proceed to Level-2 download and content audit.** No dataset should yet be used for biological inference, and GSE282464 must remain outside the primary analysis unless its multi-series structure is resolved.
