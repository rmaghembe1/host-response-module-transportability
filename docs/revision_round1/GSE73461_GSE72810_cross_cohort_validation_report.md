# GSE73461-GSE72810 cross-cohort validation figure report

## Analysis scope

This phase harmonised the primary fixed-module effect-size results from GSE73461 and GSE72810. No sensitivity result was substituted for either cohort's locked primary analysis.

The forest plot displays bacterial-minus-viral Hodges-Lehmann shifts with bootstrap 95% confidence intervals. Positive estimates represent bacterial-higher scores and negative estimates represent viral-higher scores.

## Harmonised source data

```text
    cohort_id final_module_id bacterial_n viral_n
       <char>          <char>       <int>   <int>
 1:  GSE73461         BACT_M1          52      94
 2:  GSE72810         BACT_M1          23      28
 3:  GSE73461         BACT_M2          52      94
 4:  GSE72810         BACT_M2          23      28
 5:  GSE73461         VIR_M1a          52      94
 6:  GSE72810         VIR_M1a          23      28
 7:  GSE73461         VIR_M1b          52      94
 8:  GSE72810         VIR_M1b          23      28
 9:  GSE73461          VIR_M2          52      94
10:  GSE72810          VIR_M2          23      28
    hodges_lehmann_shift_bacterial_minus_viral hodges_lehmann_ci_low
                                         <num>                 <num>
 1:                                  0.1717405           -0.02092675
 2:                                  0.2656901           -0.02417504
 3:                                  0.2712783            0.05666679
 4:                                  0.4254554            0.16114971
 5:                                 -0.4333867           -0.61731483
 6:                                 -0.7259037           -0.90662560
 7:                                 -0.5739585           -0.78828254
 8:                                 -0.9412638           -1.20105880
 9:                                 -0.2284415           -0.40663238
10:                                 -0.5763766           -0.68230049
    hodges_lehmann_ci_high rank_biserial_effect   wilcoxon_q direction_retained
                     <num>                <num>        <num>             <lgcl>
 1:             0.37672212            0.1755319 7.992436e-02               TRUE
 2:             0.72243723            0.2888199 7.994480e-02               TRUE
 3:             0.47480572            0.2409984 2.021627e-02               TRUE
 4:             0.67644176            0.5186335 2.028261e-03               TRUE
 5:            -0.26937452           -0.4770867 4.768901e-06               TRUE
 6:            -0.57692171           -0.9316770 7.161788e-08               TRUE
 7:            -0.36768592           -0.5143208 1.411749e-06               TRUE
 8:            -0.75221063           -0.8975155 8.765310e-08               TRUE
 9:            -0.06317218           -0.2806874 8.480456e-03               TRUE
10:            -0.47503695           -0.8944099 8.765310e-08               TRUE
    fdr_significant
             <lgcl>
 1:           FALSE
 2:           FALSE
 3:            TRUE
 4:            TRUE
 5:            TRUE
 6:            TRUE
 7:            TRUE
 8:            TRUE
 9:            TRUE
10:            TRUE
```

## Cross-cohort summary

```text
   final_module_id          gse73461_primary_result gse73461_bh_p_formatted
            <char>                           <char>                  <char>
1:         BACT_M1 +0.172 (95% CI -0.021 to +0.377)                  0.0799
2:         BACT_M2 +0.271 (95% CI +0.057 to +0.475)                  0.0202
3:         VIR_M1a -0.433 (95% CI -0.617 to -0.269)                4.77e-06
4:         VIR_M1b -0.574 (95% CI -0.788 to -0.368)                1.41e-06
5:          VIR_M2 -0.228 (95% CI -0.407 to -0.063)                  0.0085
            gse72810_primary_result gse72810_bh_p_formatted
                             <char>                  <char>
1: +0.266 (95% CI -0.024 to +0.722)                  0.0799
2: +0.425 (95% CI +0.161 to +0.676)                  0.0020
3: -0.726 (95% CI -0.907 to -0.577)                7.16e-08
4: -0.941 (95% CI -1.201 to -0.752)                8.77e-08
5: -0.576 (95% CI -0.682 to -0.475)                8.77e-08
   both_direction_retained both_hl_ci_exclude_zero both_fdr_significant
                    <lgcl>                  <lgcl>               <lgcl>
1:                    TRUE                   FALSE                FALSE
2:                    TRUE                    TRUE                 TRUE
3:                    TRUE                    TRUE                 TRUE
4:                    TRUE                    TRUE                 TRUE
5:                    TRUE                    TRUE                 TRUE
                                                                                        cross_cohort_interpretation
                                                                                                             <char>
1: Directionally concordant in both cohorts but statistically borderline, with confidence intervals including zero.
2:                             Expected-direction support with confidence intervals excluding zero in both cohorts.
3:                      Strong expected-direction support with confidence intervals excluding zero in both cohorts.
4:                      Strong expected-direction support with confidence intervals excluding zero in both cohorts.
5:                             Expected-direction support with confidence intervals excluding zero in both cohorts.
```

## Interpretation

BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 retained their expected directions with confidence intervals excluding zero and BH-adjusted P values below 0.05 in both cohorts.

BACT_M1 remained bacterial-higher in both cohorts but its confidence interval included zero and its BH-adjusted P value remained approximately 0.08 in both primary analyses.

GSVA and leave-one/two-gene analyses were not incorporated into the primary forest plot. They remain separate prespecified sensitivity and robustness analyses.

## Cohort-independence boundary

GSE72810 was treated as a second accession-level and deposited-sample-level cohort providing cross-platform validation. Participant overlap cannot be directly assessed, and full investigator-network independence is not claimed.

## Tabular serialization integrity

- Source-data rows in memory: 10.
- Source-data physical rows on disk: 10.
- Summary rows in memory: 5.
- Summary physical rows on disk: 5.

## Figure manifest

```text
           figure_role
                <char>
1:     publication_png
2: editable_vector_svg
3:          vector_pdf
                                                                                                                                     file_path
                                                                                                                                        <char>
1: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.png
2: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.svg
3: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.pdf
   file_format width_inches height_inches   dpi file_exists file_size_bytes
        <char>        <num>         <num> <int>      <lgcl>           <num>
1:         PNG         10.5           6.8  1800        TRUE         1844308
2:         SVG         10.5           6.8    NA        TRUE          144193
3:         PDF         10.5           6.8    NA        TRUE           26554
                                md5 svg_contains_raster_image
                             <char>                    <lgcl>
1: e68d1c09ba3653e7c12297a8ef34bfe6                        NA
2: 3c2f33457d7dcc985d792d555ef1ada9                     FALSE
3: 9250c031643fec231d68a60d58e5cada                        NA
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
19:      Q19
20:      Q20
21:      Q21
22:      Q22
23:      Q23
24:      Q24
25:      Q25
26:      Q26
27:      Q27
    check_id
      <char>
                                                                        check_description
                                                                                   <char>
 1:                                                All six locked input files are present
 2:                                        The cohort overlap and wording audit validates
 3:                         GSE73461 primary analysis contains five unique locked modules
 4:                         GSE72810 primary analysis contains five unique locked modules
 5:                                    Both cohorts contain exactly the locked module set
 6:                               The harmonised in-memory source table contains ten rows
 7:                                              Harmonised cohort-module keys are unique
 8:                                           Module labels are identical between cohorts
 9:                                     Expected directions are identical between cohorts
10:                             Locked gene counts are identical between coverage sources
11:                                   GSE73461 group counts are 52 bacterial and 94 viral
12:                                   GSE72810 group counts are 23 bacterial and 28 viral
13:                             Every primary effect row used 10,000 bootstrap replicates
14:                               All effect estimates, intervals and P values are finite
15:                            All confidence-interval lower and upper bounds are ordered
16:               All rank-biserial estimates and intervals lie between minus one and one
17:                                 All module coverage fractions are at least 70 percent
18:                                      All GSE72810 representative probes remain frozen
19:                        All ten cohort-module effects retain their expected directions
20:              BACT_M1 is FDR-borderline in both cohorts and the other modules pass FDR
21: BACT_M1 confidence intervals include zero and the other module intervals exclude zero
22:                      The manuscript-facing summary table contains five unique modules
23:                               PNG, SVG and PDF figure files are present and non-empty
24:                                     The SVG contains no embedded raster image element
25:                    Caption and Markdown summary-table files are present and non-empty
26:                   The written source-data TSV contains exactly ten physical data rows
27:                      The written summary TSV contains exactly five physical data rows
                                                                        check_description
                                                                                   <char>
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
19:   TRUE
20:   TRUE
21:   TRUE
22:   TRUE
23:   TRUE
24:   TRUE
25:   TRUE
26:   TRUE
27:   TRUE
      pass
    <lgcl>
```

- Quality gate: `PASS`.
- Integration status: `READY_FOR_VISUAL_REVIEW_AND_COMMIT`.
