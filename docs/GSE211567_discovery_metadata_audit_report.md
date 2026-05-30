# GSE211567 Discovery-Side Metadata Audit Report

- Generated: 2026-05-30T23:43:06
- Purpose: reconcile GSE211567 normalized discovery-matrix sample columns with GEO family SOFT sample metadata before any discovery modelling.
- Analytical boundary: no differential expression, pathway enrichment, module selection or biological interpretation is performed here.

## Source structures

- Normalized discovery matrix sample columns: 291
- GEO family SOFT sample records parsed: 291
- GEO metadata fields detected after flattening: 38

## Expression-column to GEO-metadata mapping status

- no_metadata_match: 1
- unique_metadata_match: 290

## GEO metadata site counts

- Sri_Lanka: 141
- United_States: 150

## GEO metadata infection-type counts

- Bacterial: 101
- Noninfection: 67
- Viral: 123

## GEO metadata pathogen counts

- Coxiella_burnetii: 3
- Dengue: 43
- Enterobacter: 17
- Influenza_A_B: 67
- Leptospira: 30
- Noninfection: 67
- RespVirus_other: 13
- Rickettsia: 27
- Staphylococcus: 10
- Streptococcus: 14

## Metadata fields with non-empty values

- channel_count: 291
- characteristics_age: 291
- characteristics_gender: 291
- characteristics_infection_type: 291
- characteristics_pathogen: 291
- characteristics_race: 150
- characteristics_sequencing_batch: 291
- characteristics_site: 291
- contact_address: 291
- contact_city: 291
- contact_country: 291
- contact_department: 291
- contact_email: 291
- contact_institute: 291
- contact_name: 291
- contact_state: 291
- contact_zip/postal_code: 291
- data_processing: 291
- data_row_count: 291
- extract_protocol_ch1: 291
- geo_accession: 291
- instrument_model: 291
- last_update_date: 291
- library_selection: 291
- library_source: 291
- library_strategy: 291
- molecule_ch1: 291
- organism_ch1: 291
- platform_id: 291
- relation: 291
- series_id: 291
- source_name_ch1: 291
- status: 291
- submission_date: 291
- supplementary_file_1: 291
- taxid_ch1: 291
- title: 291
- type: 291

## Generated files

- `data/metadata_harmonized/GSE211567_expression_sample_to_GEO_metadata_mapping.tsv`
- `data/metadata_harmonized/GSE211567_GEO_family_SOFT_sample_metadata_flattened.tsv`
- `data/metadata_harmonized/GSE211567_GEO_metadata_field_presence.tsv`

## Immediate interpretation

- This audit determines whether normalized expression sample columns can be linked to GEO sample metadata.
- If mapping is complete or near-complete, the next step is to lock discovery sample classes, site/context strata and exclusion rules.
- If sample-column identifiers do not match GEO titles directly, an explicit identifier bridge must be created before modelling.
- No discovery modelling should begin until the GSE211567 sample-class table is locked.
