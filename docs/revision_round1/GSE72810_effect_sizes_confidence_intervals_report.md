# GSE72810 effect sizes and confidence intervals

## Analytical framework

Effect sizes were calculated for the primary GSE72810 projection and its three prespecified sensitivities without changing the frozen probes, locked module memberships, sample definitions, z-reference definitions or expected directions.

The Hodges-Lehmann estimate is the median of all pairwise bacterial-minus-viral score differences. Positive estimates indicate higher scores in bacterial samples, whereas negative estimates indicate higher scores in viral samples.

Rank-biserial effects range from minus one to one. Positive values indicate greater bacterial scores and negative values indicate greater viral scores.

Confidence intervals used stratified nonparametric percentile bootstrap resampling within bacterial and viral groups with 10,000 replicates per analysis-module combination.

## Primary-analysis effect sizes

```text
   final_module_id bacterial_n viral_n median_difference_bacterial_minus_viral
            <char>       <int>   <int>                                   <num>
1:         BACT_M1          23      28                               0.5183680
2:         BACT_M2          23      28                               0.4229352
3:         VIR_M1a          23      28                              -0.6879019
4:         VIR_M1b          23      28                              -0.9051948
5:          VIR_M2          23      28                              -0.5471759
   hodges_lehmann_shift_bacterial_minus_viral hodges_lehmann_ci_low
                                        <num>                 <num>
1:                                  0.2656901           -0.02417504
2:                                  0.4254554            0.16114971
3:                                 -0.7259037           -0.90662560
4:                                 -0.9412638           -1.20105880
5:                                 -0.5763766           -0.68230049
   hodges_lehmann_ci_high rank_biserial_effect rank_biserial_ci_low
                    <num>                <num>                <num>
1:              0.7224372            0.2888199          -0.02173913
2:              0.6764418            0.5186335           0.23602484
3:             -0.5769217           -0.9316770          -1.00000000
4:             -0.7522106           -0.8975155          -1.00000000
5:             -0.4750370           -0.8944099          -1.00000000
   rank_biserial_ci_high   wilcoxon_p   wilcoxon_q direction_retained
                   <num>        <num>        <num>             <lgcl>
1:             0.5714286 7.994480e-02 7.994480e-02               TRUE
2:             0.7608696 1.622609e-03 2.028261e-03               TRUE
3:            -0.7857143 1.432358e-08 7.161788e-08               TRUE
4:            -0.7453416 4.728012e-08 8.765310e-08               TRUE
5:            -0.7236025 5.259186e-08 8.765310e-08               TRUE
   fdr_significant
            <lgcl>
1:           FALSE
2:            TRUE
3:            TRUE
4:            TRUE
5:            TRUE
```

## Analysis-level summary

```text
                                          analysis_id
                                               <char>
1:              main_representative_all146_z_definite
2:          primary_only_representative_51_z_definite
3: expanded_representative_all146_z_definite_probable
4:                   all_probe_mean_all146_z_definite
                          analysis_role             scoring_representation
                                 <char>                             <char>
1:                              primary      representative_probe_all146_z
2:              z_reference_sensitivity   representative_probe_primary51_z
3: expanded_case_definition_sensitivity      representative_probe_all146_z
4:           probe_collapse_sensitivity all_authorized_probe_mean_all146_z
                    z_reference_population module_count
                                    <char>        <int>
1:                All 146 GSE72810 samples            5
2: 51 definite bacterial and viral samples            5
3:                All 146 GSE72810 samples            5
4:                All 146 GSE72810 samples            5
   direction_retained_modules nominally_significant_modules
                        <int>                         <int>
1:                          5                             4
2:                          5                             4
3:                          5                             4
4:                          5                             4
   fdr_significant_modules hodges_lehmann_ci_excluding_zero_modules
                     <int>                                    <int>
1:                       4                                        4
2:                       4                                        4
3:                       4                                        4
4:                       4                                        5
   rank_biserial_ci_excluding_zero_modules minimum_hodges_lehmann_shift
                                     <int>                        <num>
1:                                       4                   -0.9412638
2:                                       4                   -0.9180241
3:                                       4                   -0.8851326
4:                                       5                   -0.9234232
   maximum_hodges_lehmann_shift minimum_rank_biserial_effect
                          <num>                        <num>
1:                    0.4254554                   -0.9316770
2:                    0.4026875                   -0.9347826
3:                    0.3307143                   -0.8085714
4:                    0.3859157                   -0.9316770
   maximum_rank_biserial_effect
                          <num>
1:                    0.5186335
2:                    0.4937888
3:                    0.3857143
4:                    0.4720497
```

## Quality gate

```text
    check_id
      <char>
 1:      Q01
 2:      Q02
 3:      Q03
 4:      Q04
 5:      Q05
 6:      Q06
 7:      Q07
 8:      Q08
 9:      Q09
10:      Q10
11:      Q11
12:      Q12
13:      Q13
14:      Q14
15:      Q15
16:      Q16
17:      Q17
18:      Q18
                                                            check_description
                                                                       <char>
 1:                     Locked Script 47 projection quality summary validates
 2:                                    Module-score input contains 1,715 rows
 3:                                   Module-score keys are unique and finite
 4:                           Analysis manifest contains four locked analyses
 5:                              Reference test input contains 20 unique rows
 6:                      Coverage input contains five eligible frozen modules
 7:                                    Twenty effect-size rows were generated
 8:                         Five primary manuscript-table rows were generated
 9:                             Twenty bootstrap-manifest rows were generated
10:                                               Effect-size keys are unique
11:                              Bootstrap-manifest keys and seeds are unique
12:                                          All group counts match Script 47
13:                            All recomputed group summaries match Script 47
14:      All recomputed test statistics and adjusted P values match Script 47
15:                     All direction and significance labels match Script 47
16:                   All 10,000 bootstrap replicates completed for every row
17:                 All confidence intervals are finite and correctly ordered
18: All rank-biserial estimates and intervals remain within minus one and one
      pass
    <lgcl>
 1:   TRUE
 2:   TRUE
 3:   TRUE
 4:   TRUE
 5:   TRUE
 6:   TRUE
 7:   TRUE
 8:   TRUE
 9:   TRUE
10:   TRUE
11:   TRUE
12:   TRUE
13:   TRUE
14:   TRUE
15:   TRUE
16:   TRUE
17:   TRUE
18:   TRUE
```

- Quality gate: `PASS`.
- Analysis status: `READY_FOR_GSE72810_FIGURE_AND_MANUSCRIPT_INTEGRATION`.
- Total completed bootstrap replicates: 200,000.
