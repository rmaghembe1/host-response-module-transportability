# GSE73461 effect sizes and confidence intervals

## Purpose

This revision-stage analysis augments the submitted GSE73461 fixed-module projection with descriptive statistics, Hodges-Lehmann location-shift estimates and rank-biserial effect sizes.

The five submitted modules, score definitions and sample contrasts were not changed.

## Statistical specification

- Wilcoxon rank-sum tests were two-sided, used `exact = FALSE` and retained the default continuity correction.
- Hodges-Lehmann estimates and 95% confidence intervals were obtained from the corresponding Wilcoxon location-shift calculation.
- Rank-biserial correlation was oriented so positive values indicate higher scores in bacterial infection.
- Rank-biserial 95% confidence intervals used 10000 stratified percentile-bootstrap resamples.
- BH adjustment was performed across the five modules separately within each z-score reference population.

## Quality assurance

- Effect-size rows: 10
- Submitted-result reference checks passed: 10/10
- Expected-direction matches: 10/10

## Result preview

```text
              scoring_population final_module_id
                          <char>          <char>
 1: main_all_projected_reference         BACT_M1
 2: main_all_projected_reference         BACT_M2
 3: main_all_projected_reference         VIR_M1a
 4: main_all_projected_reference         VIR_M1b
 5: main_all_projected_reference          VIR_M2
 6:       primary_only_reference         BACT_M1
 7:       primary_only_reference         BACT_M2
 8:       primary_only_reference         VIR_M1a
 9:       primary_only_reference         VIR_M1b
10:       primary_only_reference          VIR_M2
    median_difference_bacterial_minus_viral
                                      <num>
 1:                               0.2067140
 2:                               0.3328365
 3:                              -0.4629475
 4:                              -0.6738989
 5:                              -0.2595571
 6:                               0.2210501
 7:                               0.3503769
 8:                              -0.4441445
 9:                              -0.6444638
10:                              -0.2625750
    hodges_lehmann_bacterial_minus_viral hodges_lehmann_ci_lower
                                   <num>                   <num>
 1:                            0.1717405             -0.02092675
 2:                            0.2712783              0.05666679
 3:                           -0.4333867             -0.61731483
 4:                           -0.5739585             -0.78828254
 5:                           -0.2284415             -0.40663238
 6:                            0.1824438             -0.02182777
 7:                            0.2703935              0.05922734
 8:                           -0.4079256             -0.58261495
 9:                           -0.5444310             -0.74196428
10:                           -0.2255946             -0.40173979
    hodges_lehmann_ci_upper rank_biserial_bacterial_vs_viral
                      <num>                            <num>
 1:              0.37672212                        0.1755319
 2:              0.47480572                        0.2409984
 3:             -0.26937452                       -0.4770867
 4:             -0.36768592                       -0.5143208
 5:             -0.06317218                       -0.2806874
 6:              0.39519106                        0.1767594
 7:              0.47149567                        0.2483633
 8:             -0.25055131                       -0.4676759
 9:             -0.34338575                       -0.5057283
10:             -0.06617307                       -0.2827332
    rank_biserial_ci_lower rank_biserial_ci_upper     wilcox_p  wilcox_p_BH
                     <num>                  <num>        <num>        <num>
 1:            -0.01063830             0.36211129 7.992436e-02 7.992436e-02
 2:             0.05072627             0.42716858 1.617302e-02 2.021627e-02
 3:            -0.63216039            -0.30810147 1.907560e-06 4.768901e-06
 4:            -0.66490385            -0.35392799 2.823498e-07 1.411749e-06
 5:            -0.45459288            -0.10106383 5.088274e-03 8.480456e-03
 6:            -0.01022913             0.36661211 7.783557e-02 7.783557e-02
 7:             0.05769231             0.43535188 1.319187e-02 1.648984e-02
 8:            -0.62274959            -0.30030687 3.026901e-06 7.567252e-06
 9:            -0.65958470            -0.34083470 4.440278e-07 2.220139e-06
10:            -0.45662848            -0.09738134 4.775126e-03 7.958544e-03
    expected_direction_match
                      <lgcl>
 1:                     TRUE
 2:                     TRUE
 3:                     TRUE
 4:                     TRUE
 5:                     TRUE
 6:                     TRUE
 7:                     TRUE
 8:                     TRUE
 9:                     TRUE
10:                     TRUE
```

## Interpretation boundary

These effect sizes quantify separation of fixed module scores between the prespecified bacterial and viral groups. They do not represent diagnostic model training or diagnostic-performance validation.

## Output files

- `results/revision_round1/GSE73461_effect_sizes_confidence_intervals/GSE73461_module_effect_sizes_confidence_intervals.tsv`
- `results/revision_round1/GSE73461_effect_sizes_confidence_intervals/GSE73461_effect_size_reference_check.tsv`
