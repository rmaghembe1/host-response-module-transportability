# GSE73461 fixed-module GSVA comparison

## Purpose

This revision-stage sensitivity analysis compared GSVA scores with the submitted unweighted mean-z scores for the five locked GSE211567 modules in GSE73461.

Module genes, labels, directions, cohort definitions and deterministic probe selections were not changed.

## GSVA configuration

- GSVA version: `1.50.5`
- BiocParallel version: `1.36.0`
- Interface: `gsvaParam()` followed by `gsva()`.
- Kernel: `Gaussian`.
- Minimum gene-set size: `1`.
- Maximum gene-set size: `Inf`.
- Tau: `1`.
- Maximum-difference statistic: `TRUE`.
- Absolute ranking: `FALSE`.
- Execution: serial using `BiocParallel::SerialParam()`.

## Scoring populations

- Main reference: 201 samples, comprising 52 bacterial, 94 viral and 55 contextual-control samples.
- Primary-only reference: 146 bacterial and viral samples.

## Quality assurance

- Combined GSVA score rows: 1735
- Coverage rows: 10
- Effect-size rows: 10
- GSVA versus mean-z correlation rows: 10
- Expected-direction matches: 10/10
- Final quality gate: `PASS`.

## GSVA bacterial-versus-viral effects

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
 1:                             0.704569617
 2:                             0.615772074
 3:                            -0.462614980
 4:                            -0.456427555
 5:                            -0.002635745
 6:                             0.673137146
 7:                             0.656095176
 8:                            -0.456706870
 9:                            -0.438136723
10:                            -0.034080241
    hodges_lehmann_bacterial_minus_viral hodges_lehmann_ci_lower
                                   <num>                   <num>
 1:                          0.445508834              0.25131245
 2:                          0.477544967              0.34897748
 3:                         -0.354578491             -0.46595940
 4:                         -0.338747040             -0.47597314
 5:                         -0.009869992             -0.06789191
 6:                          0.457928342              0.24499754
 7:                          0.521265312              0.36154646
 8:                         -0.355522052             -0.46974854
 9:                         -0.344462738             -0.48425600
10:                         -0.035018656             -0.08899188
    hodges_lehmann_ci_upper rank_biserial_bacterial_vs_viral
                      <num>                            <num>
 1:              0.67839727                       0.46644845
 2:              0.63771277                       0.65343699
 3:             -0.25006664                      -0.63870704
 4:             -0.20667991                      -0.49631751
 5:              0.04596853                      -0.03355155
 6:              0.69834845                       0.46522095
 7:              0.68075055                       0.63175123
 8:             -0.24279570                      -0.63788871
 9:             -0.20956489                      -0.50163666
10:              0.02631014                      -0.11415712
    rank_biserial_ci_lower rank_biserial_ci_upper     wilcox_p  wilcox_p_BH
                     <num>                  <num>        <num>        <num>
 1:              0.2999182             0.62194149 3.212775e-06 4.015969e-06
 2:              0.5175941             0.77823241 6.831055e-11 3.415528e-10
 3:             -0.7651391            -0.49222586 1.803533e-10 4.508832e-10
 4:             -0.6489362            -0.33101473 7.231142e-07 1.205190e-06
 5:             -0.2311989             0.16121113 7.390881e-01 7.390881e-01
 6:              0.3023732             0.61865794 3.409570e-06 4.261963e-06
 7:              0.4864975             0.76063830 2.831604e-10 7.079010e-10
 8:             -0.7671952            -0.49548895 1.902298e-10 7.079010e-10
 9:             -0.6567103            -0.33755115 5.494798e-07 9.157997e-07
10:             -0.3036109             0.08265139 2.550665e-01 2.550665e-01
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

## GSVA versus submitted mean-z correlations

```text
              scoring_population final_module_id n_compared pearson_correlation
                          <char>          <char>      <int>               <num>
 1: main_all_projected_reference         BACT_M1        201          0.64499185
 2: main_all_projected_reference         BACT_M2        201          0.65878996
 3: main_all_projected_reference         VIR_M1a        201          0.40360234
 4: main_all_projected_reference         VIR_M1b        201          0.64594694
 5: main_all_projected_reference          VIR_M2        201         -0.01406782
 6:       primary_only_reference         BACT_M1        146          0.61915939
 7:       primary_only_reference         BACT_M2        146          0.64037045
 8:       primary_only_reference         VIR_M1a        146          0.44316491
 9:       primary_only_reference         VIR_M1b        146          0.66312532
10:       primary_only_reference          VIR_M2        146          0.03951149
    spearman_correlation sample_count_match
                   <num>             <lgcl>
 1:          0.671869366               TRUE
 2:          0.677583863               TRUE
 3:          0.315251958               TRUE
 4:          0.624278114               TRUE
 5:         -0.009407418               TRUE
 6:          0.675011809               TRUE
 7:          0.671872982               TRUE
 8:          0.414076523               TRUE
 9:          0.652141556               TRUE
10:          0.052263021               TRUE
```

## Interpretation boundary

GSVA is treated as an alternative scoring sensitivity analysis. It does not replace the submitted primary unweighted mean-z-score analysis and was not used to redefine or optimize any module.

Direction disagreement, weak correlation or lack of statistical significance would be retained as an informative sensitivity result rather than used to tune the locked modules.

## Output files

- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_scores_long.tsv`
- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_scores_wide.tsv`
- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_module_coverage.tsv`
- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_primary_projection_effects.tsv`
- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_vs_mean_z_correlations.tsv`
- `results/revision_round1/GSE73461_GSVA_projection_comparison/GSE73461_GSVA_run_manifest.tsv`
