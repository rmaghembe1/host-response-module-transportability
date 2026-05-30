# GSE211567 Discovery Sample Table Lock Report

- Generated: 2026-05-31T00:14:55
- Purpose: lock the discovery sample table before any GSE211567 discovery modelling.
- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.

## Locking decision

- Include expression samples with unique GEO metadata match.
- Exclude `DU09-03S0000029` because it is present in the normalized expression matrix but absent from the authoritative GEO family SOFT metadata and lacks an explicit metadata bridge.
- Retain noninfection samples as contextual/control metadata, but exclude them from the primary bacterial-versus-viral discovery contrast.
- Primary discovery contrast is bacterial versus viral infection, with site/context strata preserved for heterogeneity/concordance analysis.

## Locked sample counts

- Expression samples in normalized matrix metadata mapping file: 291
- Locked samples retained: 290
- Excluded samples: 1
- Primary bacterial-versus-viral discovery samples: 224

## Discovery group counts among locked samples

- bacterial: 101
- noninfection_contextual: 66
- viral: 123

## Primary discovery contrast counts

- bacterial: 101
- viral: 123

## Site counts among locked samples

- Sri_Lanka: 141
- United_States: 149

## Site × discovery group counts

- Sri_Lanka:
  - bacterial: 60
  - viral: 81
- United_States:
  - bacterial: 41
  - noninfection_contextual: 66
  - viral: 42

## Pathogen counts among locked samples

- Coxiella_burnetii: 3
- Dengue: 43
- Enterobacter: 17
- Influenza_A_B: 67
- Leptospira: 30
- Noninfection: 66
- RespVirus_other: 13
- Rickettsia: 27
- Staphylococcus: 10
- Streptococcus: 14

## Sequencing batch counts among locked samples

- batch 1: 182
- batch 2: 108

## Exclusions

- DU09-03S0000029: unmatched_expression_sample_no_authoritative_GEO_metadata_bridge

## Generated files

- `data/metadata_harmonized/GSE211567_discovery_sample_table_locked.tsv`
- `data/metadata_harmonized/GSE211567_discovery_sample_exclusions.tsv`

## Next action

- Proceed to discovery-side normalized-matrix QC using the locked 290-sample table.
- No biological module discovery should begin until normalized-matrix QC, sample alignment and site/batch structure are reviewed.
