# GSE211567 Primary limma Discovery Model Report

- Generated: 2026-05-31 09:18:59 EAT
- Purpose: first ranked differential-expression model for the locked bacterial-versus-viral GSE211567 discovery set.
- Model: normalized expression ~ discovery_group + site + sequencing_batch.
- Contrast: bacterial versus viral; positive logFC means higher expression in bacterial samples relative to viral samples.
- Boundary: this report provides ranked statistical evidence only. It does not perform pathway enrichment, module discovery, module orientation, transportability testing or biological interpretation.

## Primary model sample set

- Primary samples: 224
- Bacterial samples: 101
- Viral samples: 123

## Model matrix

                             model n_samples n_columns  rank full_rank
                            <char>     <int>     <int> <int>    <lgcl>
1: primary_pooled_group_site_batch       224         4     4      TRUE
                                                             design_columns
                                                                     <char>
1: (Intercept);discovery_groupbacterial;siteUnited_States;sequencing_batch2

## Statistical summary

                              metric value
                              <char> <int>
 1:                features_modelled 19999
 2:                  primary_samples   224
 3:                bacterial_samples   101
 4:                    viral_samples   123
 5:                   BH_FDR_lt_0.05  9999
 6:                   BH_FDR_lt_0.10 11424
 7:                nominal_P_lt_0.05 11152
 8: abs_logFC_ge_0.5_and_FDR_lt_0.05  8631
 9:          positive_logFC_features  7486
10:          negative_logFC_features 12513

## Output files

- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_summary.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_design_matrix.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_model_rank_check.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_top50_preview.tsv`
- `results/differential_expression/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_model_objects.rds`
- `results/figures/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_volcano.png` and `.pdf`
- `results/figures/GSE211567_primary_bacterial_vs_viral/GSE211567_primary_limma_MA_style.png` and `.pdf`
- `env/session_info/GSE211567_primary_limma_discovery_model_sessionInfo.txt`

## Next required review

- Review model diagnostics and summary counts.
- Run site-stratified bacterial-versus-viral models for Sri Lanka and United States separately.
- Compare direction and rank concordance between pooled and site-stratified models before pathway/module-level interpretation.

## Boundary statement

- Do not interpret individual genes biologically yet.
- Do not define modules yet.
- Do not run enrichment until pooled and site-stratified concordance has been reviewed.
