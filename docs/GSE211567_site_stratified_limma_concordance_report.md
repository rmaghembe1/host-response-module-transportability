# GSE211567 Site-Stratified limma Concordance Report

- Generated: 2026-05-31 09:22:29 EAT
- Purpose: compare pooled and site-stratified bacterial-versus-viral limma rankings before pathway/module interpretation.
- Boundary: ranked statistical concordance only; no pathway enrichment, module discovery, transportability testing or biological interpretation is performed here.

## Site-stratified model summaries

             site                           metric value
           <fctr>                           <char> <int>
 1:     Sri_Lanka                features_modelled 19999
 2:     Sri_Lanka                          samples   141
 3:     Sri_Lanka                bacterial_samples    60
 4:     Sri_Lanka                    viral_samples    81
 5:     Sri_Lanka                   BH_FDR_lt_0.05  9915
 6:     Sri_Lanka                   BH_FDR_lt_0.10 11317
 7:     Sri_Lanka                nominal_P_lt_0.05 11087
 8:     Sri_Lanka abs_logFC_ge_0.5_and_FDR_lt_0.05  9765
 9:     Sri_Lanka          positive_logFC_features  8062
10:     Sri_Lanka          negative_logFC_features 11937
11: United_States                features_modelled 19999
12: United_States                          samples    83
13: United_States                bacterial_samples    41
14: United_States                    viral_samples    42
15: United_States                   BH_FDR_lt_0.05  6661
16: United_States                   BH_FDR_lt_0.10  8183
17: United_States                nominal_P_lt_0.05  8600
18: United_States abs_logFC_ge_0.5_and_FDR_lt_0.05  6657
19: United_States          positive_logFC_features  7287
20: United_States          negative_logFC_features 12712
             site                           metric value
           <fctr>                           <char> <int>

## Site-stratified model rank checks

            site n_samples bacterial_samples viral_samples
          <fctr>     <int>             <int>         <int>
1:     Sri_Lanka       141                60            81
2: United_States        83                41            42
                          model_formula n_columns  rank full_rank
                                 <char>     <int> <int>    <lgcl>
1: ~ discovery_group + sequencing_batch         3     3      TRUE
2: ~ discovery_group + sequencing_batch         3     3      TRUE
                                           design_columns
                                                   <char>
1: (Intercept);discovery_groupbacterial;sequencing_batch2
2: (Intercept);discovery_groupbacterial;sequencing_batch2

## Directional concordance summary

                                comparison n_features n_concordant
                                    <char>      <int>        <int>
1:        pooled_vs_Sri_Lanka_all_features      19999        17439
2:    pooled_vs_United_States_all_features      19999        15468
3: Sri_Lanka_vs_United_States_all_features      19999        12916
4:                  all_three_all_features      19999        12912
5:               pooled_FDR05_vs_Sri_Lanka       9999         9913
6:           pooled_FDR05_vs_United_States       9999         9310
7:  pooled_FDR05_site_concordant_all_three       9999         9224
   pct_concordant
            <num>
1:          87.20
2:          77.34
3:          64.58
4:          64.56
5:          99.14
6:          93.11
7:          92.25

## logFC correlation summary

                   comparison spearman_logFC pearson_logFC
                       <char>          <num>         <num>
1:        pooled_vs_Sri_Lanka      0.9077140     0.9263798
2:    pooled_vs_United_States      0.7341512     0.7940624
3: Sri_Lanka_vs_United_States      0.4079860     0.5080291

## Top-ranked feature overlap

   top_n pooled_Sri_Lanka_overlap pooled_United_States_overlap
   <num>                    <int>                        <int>
1:    50                       44                           13
2:   100                       79                           24
3:   500                      394                          205
4:  1000                      725                          440
   Sri_Lanka_United_States_overlap all_three_overlap
                             <int>             <int>
1:                              12                12
2:                              14                14
3:                             131               131
4:                             278               278

## Technical interpretation gate

- If pooled-versus-site logFC correlations and directional concordance are strong, proceed to pathway/module discovery with site-aware caution.
- If Sri Lanka and United States are weakly concordant, prioritize stable cross-site directional modules rather than pooled-only gene hits.
- Do not interpret individual genes or pathways until this concordance gate is reviewed.

## Generated files

- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_Sri_Lanka_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_United_States_limma_bacterial_vs_viral_ranked_results.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_site_stratified_limma_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_site_stratified_model_rank_checks.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_pooled_site_stratified_concordance_table.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_direction_concordance_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_logFC_correlation_summary.tsv`
- `results/differential_expression/GSE211567_site_stratified_concordance/GSE211567_top_ranked_feature_overlap.tsv`
- `results/figures/GSE211567_site_stratified_concordance/*logFC_scatter*.png/.pdf`
- `env/session_info/GSE211567_site_stratified_limma_concordance_sessionInfo.txt`

## Boundary statement

- This report does not define biological modules.
- This report does not perform enrichment.
- This report does not make biological claims.
