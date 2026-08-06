# Supplementary Figure S1 sensitivity and robustness report

## Key findings

```text
   finding_id
       <char>
1:         A1
2:         A2
3:         B1
4:         B2
5:         C1
                                                                                                                             finding
                                                                                                                              <char>
1:                 All 30 z-reference, case-definition and probe-collapse sensitivity rows retained their expected module direction.
2:         GSE72810 sensitivity-score concordance remained high; minimum Pearson r = 0.9874322 and minimum Spearman rho = 0.9813714.
3: VIR_M2 retained a viral-higher direction but lost confidence-interval and FDR support under GSVA in both z-reference populations.
4:                            BACT_M1 was borderline under mean-z scoring but gained confidence-interval and FDR support under GSVA.
5:  All 29826 leave-one/two-gene variants retained the expected direction; minimum Pearson r with the complete module was 0.9940203.
                                                                                                 interpretation_boundary
                                                                                                                  <char>
1:                         Direction preservation does not imply identical effect magnitude or statistical significance.
2:                             Correlation measures score-level concordance and does not replace effect-size comparison.
3:        VIR_M2 should be described as scoring-method-sensitive rather than uniformly robust across scoring algorithms.
4:      The stronger GSVA result does not convert BACT_M1 into a uniformly supported module across all primary analyses.
5: Deletion robustness supports distributed module signal but does not establish causal sufficiency of individual genes.
```

## Mean-z versus GSVA comparison

```text
Key: <final_module_id, scoring_population>
    final_module_id           scoring_population rank_biserial_effect_Mean_z
             <fctr>                       <char>                       <num>
 1:          VIR_M2 main_all_projected_reference                  -0.2806874
 2:          VIR_M2       primary_only_reference                  -0.2827332
 3:         VIR_M1b main_all_projected_reference                  -0.5143208
 4:         VIR_M1b       primary_only_reference                  -0.5057283
 5:         VIR_M1a main_all_projected_reference                  -0.4770867
 6:         VIR_M1a       primary_only_reference                  -0.4676759
 7:         BACT_M2 main_all_projected_reference                   0.2409984
 8:         BACT_M2       primary_only_reference                   0.2483633
 9:         BACT_M1 main_all_projected_reference                   0.1755319
10:         BACT_M1       primary_only_reference                   0.1767594
    rank_biserial_effect_GSVA wilcoxon_q_Mean_z wilcoxon_q_GSVA
                        <num>             <num>           <num>
 1:               -0.03355155      8.480456e-03    7.390881e-01
 2:               -0.11415712      7.958544e-03    2.550665e-01
 3:               -0.49631751      1.411749e-06    1.205190e-06
 4:               -0.50163666      2.220139e-06    9.157997e-07
 5:               -0.63870704      4.768901e-06    4.508832e-10
 6:               -0.63788871      7.567252e-06    7.079010e-10
 7:                0.65343699      2.021627e-02    3.415528e-10
 8:                0.63175123      1.648984e-02    7.079010e-10
 9:                0.46644845      7.992436e-02    4.015969e-06
10:                0.46522095      7.783557e-02    4.261963e-06
    significance_discordant
                     <lgcl>
 1:                    TRUE
 2:                    TRUE
 3:                   FALSE
 4:                   FALSE
 5:                   FALSE
 6:                   FALSE
 7:                   FALSE
 8:                   FALSE
 9:                    TRUE
10:                    TRUE
                                                                                           method_interpretation
                                                                                                          <char>
 1: Mean-z supported the expected viral-higher effect, whereas GSVA was near zero and statistically unsupported.
 2: Mean-z supported the expected viral-higher effect, whereas GSVA was near zero and statistically unsupported.
 3:                                                     Mean-z and GSVA retained concordant inferential support.
 4:                                                     Mean-z and GSVA retained concordant inferential support.
 5:                                                     Mean-z and GSVA retained concordant inferential support.
 6:                                                     Mean-z and GSVA retained concordant inferential support.
 7:                                                     Mean-z and GSVA retained concordant inferential support.
 8:                                                     Mean-z and GSVA retained concordant inferential support.
 9:                          BACT_M1 was borderline under mean-z scoring but statistically supported under GSVA.
10:                          BACT_M1 was borderline under mean-z scoring but statistically supported under GSVA.
```

## Leave-one/two-gene robustness

```text
            reference_display final_module_id deletion_display
                       <fctr>          <fctr>           <fctr>
 1: All projected z-reference          VIR_M2   Leave one gene
 2: All projected z-reference          VIR_M2  Leave two genes
 3:  Primary-only z-reference          VIR_M2   Leave one gene
 4:  Primary-only z-reference          VIR_M2  Leave two genes
 5: All projected z-reference         VIR_M1b   Leave one gene
 6: All projected z-reference         VIR_M1b  Leave two genes
 7:  Primary-only z-reference         VIR_M1b   Leave one gene
 8:  Primary-only z-reference         VIR_M1b  Leave two genes
 9: All projected z-reference         VIR_M1a   Leave one gene
10: All projected z-reference         VIR_M1a  Leave two genes
11:  Primary-only z-reference         VIR_M1a   Leave one gene
12:  Primary-only z-reference         VIR_M1a  Leave two genes
13: All projected z-reference         BACT_M2   Leave one gene
14: All projected z-reference         BACT_M2  Leave two genes
15:  Primary-only z-reference         BACT_M2   Leave one gene
16:  Primary-only z-reference         BACT_M2  Leave two genes
17: All projected z-reference         BACT_M1   Leave one gene
18: All projected z-reference         BACT_M1  Leave two genes
19:  Primary-only z-reference         BACT_M1   Leave one gene
20:  Primary-only z-reference         BACT_M1  Leave two genes
            reference_display final_module_id deletion_display
                       <fctr>          <fctr>           <fctr>
    observed_variant_count expected_direction_preserved_fraction
                     <int>                                 <num>
 1:                    105                                     1
 2:                   5460                                     1
 3:                    105                                     1
 4:                   5460                                     1
 5:                     33                                     1
 6:                    528                                     1
 7:                     33                                     1
 8:                    528                                     1
 9:                    128                                     1
10:                   8128                                     1
11:                    128                                     1
12:                   8128                                     1
13:                     21                                     1
14:                    210                                     1
15:                     21                                     1
16:                    210                                     1
17:                     24                                     1
18:                    276                                     1
19:                     24                                     1
20:                    276                                     1
    observed_variant_count expected_direction_preserved_fraction
                     <int>                                 <num>
    minimum_pearson_correlation_with_full maximum_wilcox_p
                                    <num>            <num>
 1:                             0.9997955     7.122703e-03
 2:                             0.9991818     1.083363e-02
 3:                             0.9998020     7.035929e-03
 4:                             0.9992065     9.976973e-03
 5:                             0.9990405     1.434204e-06
 6:                             0.9967307     2.197342e-06
 7:                             0.9990181     1.907560e-06
 8:                             0.9966134     3.617896e-06
 9:                             0.9998999     3.342722e-06
10:                             0.9996447     4.152503e-06
11:                             0.9999006     4.579871e-06
12:                             0.9996597     6.494783e-06
13:                             0.9976674     4.414935e-02
14:                             0.9943707     8.205847e-02
15:                             0.9976341     4.002058e-02
16:                             0.9940203     6.804863e-02
17:                             0.9987977     1.051565e-01
18:                             0.9968605     1.384982e-01
19:                             0.9987829     1.016933e-01
20:                             0.9967381     1.363347e-01
    minimum_pearson_correlation_with_full maximum_wilcox_p
                                    <num>            <num>
```

## Interpretation

The sensitivity analyses support stable module directions across z-reference, case-definition and probe-collapse choices.

Scoring-method sensitivity is non-uniform. VIR_M2 loses statistical support under GSVA, whereas BACT_M1 gains support. These differences are reported directly rather than treating all scoring approaches as interchangeable.

The exhaustive deletion audit supports distributed module signal because every variant retained the expected direction and remained highly correlated with the complete-module score. This does not establish causal sufficiency of individual genes.

## Figure manifest

```text
           figure_role
                <char>
1:     publication_png
2: editable_vector_svg
3:          vector_pdf
                                                                                                                          file_path
                                                                                                                             <char>
1: results/revision_round1/GSE73461_GSE72810_supplementary_robustness/figures/Figure_S1_fixed_module_sensitivity_and_robustness.png
2: results/revision_round1/GSE73461_GSE72810_supplementary_robustness/figures/Figure_S1_fixed_module_sensitivity_and_robustness.svg
3: results/revision_round1/GSE73461_GSE72810_supplementary_robustness/figures/Figure_S1_fixed_module_sensitivity_and_robustness.pdf
   file_format width_inches height_inches   dpi panel_count file_exists
        <char>        <num>         <num> <int>       <int>      <lgcl>
1:         PNG           10            12  1200           3        TRUE
2:         SVG           10            12    NA           3        TRUE
3:         PDF           10            12    NA           3        TRUE
   file_size_bytes                              md5 svg_contains_raster_image
             <num>                           <char>                    <lgcl>
1:         2934374 ab0e9e476d52cca85ecd9b63f58fa21a                        NA
2:          345203 1871cfdc544029370ea7816688300803                     FALSE
3:           36181 748e37afaf4c841289f631c15d6e4367                        NA
   svg_path_elements
               <int>
1:                NA
2:               613
3:                NA
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
28:      Q28
29:      Q29
    check_id
      <char>
                                                           check_description
                                                                      <char>
 1:                                 All six required input files are present
 2:                              Panel A contains 30 sensitivity-effect rows
 3:                                 Panel B contains 20 mean-z and GSVA rows
 4:                   Panel B wide table contains ten module-population rows
 5:                                Panel C contains 20 deletion-summary rows
 6:                         All three panels contain the five locked modules
 7:                       Panel A estimates and confidence limits are finite
 8:                       Panel B estimates and confidence limits are finite
 9:                                  Panel C minimum correlations are finite
10:           All Panel A rank-biserial values lie between minus one and one
11:           All Panel B rank-biserial values lie between minus one and one
12:                    Every Panel A estimate retains the expected direction
13:                    Every Panel B estimate retains the expected direction
14:           Every Panel A and Panel B row used 10,000 bootstrap replicates
15:                                   Panel A contains 24 FDR-supported rows
16:                  Panel A contains 25 confidence intervals excluding zero
17:                                   Panel B contains 16 FDR-supported rows
18:                  Panel B contains 16 confidence intervals excluding zero
19: GSE72810 minimum sensitivity-score Pearson correlation is at least 0.987
20: Panel B wide table contains the locked syntactic Mean_z and GSVA columns
21:          VIR_M2 is FDR-supported under mean-z but unsupported under GSVA
22:          BACT_M1 is FDR-borderline under mean-z but supported under GSVA
23:                      The deletion audit contains exactly 29,826 variants
24:                    All deletion variants preserve the expected direction
25:                  All deletion variant counts match their expected counts
26:       The minimum deletion-variant Pearson correlation is at least 0.994
27:                Panel source TSVs contain 30, 20, 10 and 20 physical rows
28:       The composite plot contains all expected point and interval layers
29:        PNG, SVG and PDF files exist and the SVG contains no raster image
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
28:   TRUE
29:   TRUE
      pass
    <lgcl>
```

- Quality gate: `PASS`.
- Final status: `READY_FOR_SUPPLEMENTARY_FIGURE_VISUAL_REVIEW`.
