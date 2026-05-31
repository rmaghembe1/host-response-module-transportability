# GSE211567 RefSeq Transcript Annotation Bridge Report

- Generated: 2026-05-31 09:59:52 EAT
- Purpose: map RefSeq transcript identifiers to gene-level identifiers before enrichment/module discovery.
- Boundary: identifier mapping and transcript-to-gene collapsing only. No enrichment, module discovery or biological interpretation is performed here.

## Mapping summary

                                  metric value
                                  <char> <int>
1:                unique_refseq_features 19999
2: bridge_rows_after_one_to_many_mapping 22752
3:             features_with_any_mapping 19947
4:                  features_with_symbol 19947
5:                  features_with_entrez 19947
6:                 features_with_ensembl 19371
7:          features_without_any_mapping    52
8:    features_with_multiple_bridge_rows  1129

## Transcript-to-gene collapse summary

                            feature_set transcript_features_input
                                 <char>                     <int>
1:                all_modelled_features                     19999
2:                  site_aware_eligible                      9224
3: site_aware_eligible_bacterial_higher                      2788
4:     site_aware_eligible_viral_higher                      6436
   gene_level_entrez_output unique_symbols_output
                      <int>                 <int>
1:                     9100                  9100
2:                     4324                  4324
3:                     1479                  1479
4:                     2854                  2854

## Annotation decision

- Raw feature IDs are RefSeq transcript accessions, not gene symbols.
- Enrichment/module discovery should use gene-level mapped identifiers, preferably ENTREZID-backed tables.
- Transcript-level evidence is collapsed to one representative row per ENTREZID by strongest pooled P value, retaining direction and site-aware stability annotations.
- Unmapped RefSeq features should not be used as primary enrichment identifiers.

## Generated files

- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_to_gene_annotation_bridge.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_annotation_mapping_summary.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_unmapped_refseq_features.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_refseq_features_with_multiple_gene_mappings.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_all_modelled_features.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_features.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_bacterial_higher.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_gene_level_site_aware_eligible_viral_higher.tsv`
- `results/module_lock/GSE211567_refseq_annotation_bridge/GSE211567_transcript_to_gene_collapse_summary.tsv`
- `env/session_info/GSE211567_refseq_transcript_annotation_bridge_sessionInfo.txt`

## Boundary statement

- This report prepares identifiers for enrichment.
- It does not define pathways or modules.
- It does not make biological claims.
