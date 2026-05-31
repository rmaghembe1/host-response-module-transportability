# GSE211567 Expression-Summary Outlier Review Report

- Generated: 2026-05-31 09:10:36 EAT
- Purpose: focused technical review of the 18 expression-summary outliers identified during locked normalized-matrix QC.
- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation, external validation or biological interpretation is performed here.

## Outlier overview

- Total locked samples reviewed: 290
- Expression-summary outlier samples: 18
- Outlier proportion: 6.21%
- Multi-metric outliers: 8

## Outlier counts by discovery group

           discovery_group     N
                    <char> <int>
1:               bacterial     7
2: noninfection_contextual     4
3:                   viral     7

## Outlier counts by site

            site     N
          <char> <int>
1:     Sri_Lanka     9
2: United_States     9

## Outlier counts by sequencing batch

   sequencing_batch     N
              <int> <int>
1:                1     8
2:                2    10

## Outlier counts by pathogen

          pathogen     N
            <char> <int>
1:    Enterobacter     1
2:   Influenza_A_B     6
3:      Leptospira     3
4:    Noninfection     4
5: RespVirus_other     1
6:  Staphylococcus     1
7:   Streptococcus     2

## Outlier flag counts

                flag     n
              <char> <int>
1:   mean_expression    12
2:     sd_expression    10
3: detected_features     4

## Multi-metric outliers

Key: <expression_sample_id>
   expression_sample_id         discovery_group        pathogen          site
                 <char>                  <char>          <char>        <char>
1:               348339               bacterial   Streptococcus United_States
2:      DU09-03S0000120 noninfection_contextual    Noninfection United_States
3:      DU10-01S0000005                   viral RespVirus_other United_States
4:      DU16-02S0003129                   viral   Influenza_A_B     Sri_Lanka
5:      DU16-02S0003157                   viral   Influenza_A_B     Sri_Lanka
6:      DU16-02S0003158                   viral   Influenza_A_B     Sri_Lanka
7:      DU16-02S0004857                   viral   Influenza_A_B     Sri_Lanka
8:      DU16-02S0004890               bacterial      Leptospira     Sri_Lanka
   sequencing_batch mean_expression_outlier_iqr sd_expression_outlier_iqr
              <int>                      <lgcl>                    <lgcl>
1:                2                        TRUE                      TRUE
2:                2                        TRUE                      TRUE
3:                1                        TRUE                      TRUE
4:                2                        TRUE                     FALSE
5:                2                        TRUE                     FALSE
6:                2                        TRUE                     FALSE
7:                1                        TRUE                      TRUE
8:                1                        TRUE                      TRUE
   detected_features_outlier_iqr mean_expression sd_expression
                          <lgcl>           <num>         <num>
1:                         FALSE      -0.5512900      3.550090
2:                         FALSE      -0.4828768      3.356329
3:                         FALSE      -0.6405284      4.173563
4:                          TRUE      -0.6740103      3.004130
5:                          TRUE      -0.7034657      2.594032
6:                          TRUE      -0.7545985      2.798103
7:                         FALSE      -1.8471020      5.959906
8:                         FALSE      -0.3849542      3.358975
   detected_features_gt0       PC1         PC2
                   <int>     <num>       <num>
1:                  9936 107.52762  -45.783934
2:                  9569 148.67722    2.255035
3:                  9217 244.72090   55.053533
4:                  7603 115.36675  -23.806930
5:                  6666 124.56675  -32.665959
6:                  6474 134.42104  -22.914353
7:                 10295 -16.62244 -145.867033
8:                  8839 222.07614   39.657097

## Technical recommendation

- Do not automatically exclude all expression-summary outliers at this stage.
- These samples have passed sample-metadata locking and matrix-integrity checks.
- Treat the 18 samples as documented QC-watch samples.
- If discovery modelling reveals strong leverage, repeat key downstream summaries as a sensitivity analysis excluding multi-metric or high-leverage outliers only.
- The primary next step should be design-matrix and covariate feasibility review, especially site, sequencing batch, platform/instrument and infection-group balance.

## Generated files

- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_expression_summary_outlier_review_table.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_expression_summary_outlier_review_summary.tsv`

## Boundary statement

- This review supports technical QC documentation only.
- It does not justify biological claims.
- It does not define sample exclusions for discovery modelling beyond the already locked unmatched-sample exclusion.
- It does not define or orient biological modules.
