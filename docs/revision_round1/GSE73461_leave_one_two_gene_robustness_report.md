# GSE73461 leave-one- and leave-two-gene robustness analysis

## Purpose

This revision-stage analysis tested whether the GSE73461 fixed-module conclusions depended strongly on individual scored genes or pairs of scored genes.

The submitted probe choices, sample definitions, gene-wise z-standardization rule and unweighted mean module score were retained.

## Method

The main analysis reconstructed gene-wise z-scores using the 201 bacterial, viral and contextual-control samples.

The primary-only sensitivity reconstructed gene-wise z-scores using the 146 bacterial and viral samples.

For each module and reference population, every scored gene and every pair of scored genes was deleted. Variant scores were calculated from the remaining gene-wise z-scores.

Bacterial-versus-viral comparisons used two-sided Wilcoxon rank-sum tests with exact calculation disabled and continuity correction retained.

## Reconstruction gate

- Reconstruction rows: 10
- Reconstruction checks passed: 10/10
- Maximum full-score reconstruction difference: 5.329070518200751e-15

## Variant inventory

- Leave-one rows: 622
- Leave-two rows: 29204
- Total population-specific variant rows: 29826
- Final quality gate: `PASS`.

## Full-module baselines

```text
              scoring_population final_module_id available_gene_count
                          <char>          <char>                <int>
 1: main_all_projected_reference         BACT_M1                   24
 2: main_all_projected_reference         BACT_M2                   21
 3: main_all_projected_reference         VIR_M1a                  128
 4: main_all_projected_reference         VIR_M1b                   33
 5: main_all_projected_reference          VIR_M2                  105
 6:       primary_only_reference         BACT_M1                   24
 7:       primary_only_reference         BACT_M2                   21
 8:       primary_only_reference         VIR_M1a                  128
 9:       primary_only_reference         VIR_M1b                   33
10:       primary_only_reference          VIR_M2                  105
    median_difference_bacterial_minus_viral     wilcox_p nominal_p_lt_0_05
                                      <num>        <num>            <lgcl>
 1:                               0.2067140 7.992436e-02             FALSE
 2:                               0.3328365 1.617302e-02              TRUE
 3:                              -0.4629475 1.907560e-06              TRUE
 4:                              -0.6738989 2.823498e-07              TRUE
 5:                              -0.2595571 5.088274e-03              TRUE
 6:                               0.2210501 7.783557e-02             FALSE
 7:                               0.3503769 1.319187e-02              TRUE
 8:                              -0.4441445 3.026901e-06              TRUE
 9:                              -0.6444638 4.440278e-07              TRUE
10:                              -0.2625750 4.775126e-03              TRUE
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

## Robustness summary

```text
Key: <scoring_population, final_module_id, deletion_order>
              scoring_population final_module_id deletion_order
                          <char>          <char>         <char>
 1: main_all_projected_reference         BACT_M1      leave_one
 2: main_all_projected_reference         BACT_M1      leave_two
 3: main_all_projected_reference         BACT_M2      leave_one
 4: main_all_projected_reference         BACT_M2      leave_two
 5: main_all_projected_reference         VIR_M1a      leave_one
 6: main_all_projected_reference         VIR_M1a      leave_two
 7: main_all_projected_reference         VIR_M1b      leave_one
 8: main_all_projected_reference         VIR_M1b      leave_two
 9: main_all_projected_reference          VIR_M2      leave_one
10: main_all_projected_reference          VIR_M2      leave_two
11:       primary_only_reference         BACT_M1      leave_one
12:       primary_only_reference         BACT_M1      leave_two
13:       primary_only_reference         BACT_M2      leave_one
14:       primary_only_reference         BACT_M2      leave_two
15:       primary_only_reference         VIR_M1a      leave_one
16:       primary_only_reference         VIR_M1a      leave_two
17:       primary_only_reference         VIR_M1b      leave_one
18:       primary_only_reference         VIR_M1b      leave_two
19:       primary_only_reference          VIR_M2      leave_one
20:       primary_only_reference          VIR_M2      leave_two
              scoring_population final_module_id deletion_order
                          <char>          <char>         <char>
    observed_variant_count expected_direction_preserved_fraction
                     <int>                                 <num>
 1:                     24                                     1
 2:                    276                                     1
 3:                     21                                     1
 4:                    210                                     1
 5:                    128                                     1
 6:                   8128                                     1
 7:                     33                                     1
 8:                    528                                     1
 9:                    105                                     1
10:                   5460                                     1
11:                     24                                     1
12:                    276                                     1
13:                     21                                     1
14:                    210                                     1
15:                    128                                     1
16:                   8128                                     1
17:                     33                                     1
18:                    528                                     1
19:                    105                                     1
20:                   5460                                     1
    observed_variant_count expected_direction_preserved_fraction
                     <int>                                 <num>
    full_effect_sign_preserved_fraction nominal_p_lt_0_05_fraction
                                  <num>                      <num>
 1:                                   1                 0.04166667
 2:                                   1                 0.08695652
 3:                                   1                 1.00000000
 4:                                   1                 0.97142857
 5:                                   1                 1.00000000
 6:                                   1                 1.00000000
 7:                                   1                 1.00000000
 8:                                   1                 1.00000000
 9:                                   1                 1.00000000
10:                                   1                 1.00000000
11:                                   1                 0.04166667
12:                                   1                 0.09057971
13:                                   1                 1.00000000
14:                                   1                 0.97619048
15:                                   1                 1.00000000
16:                                   1                 1.00000000
17:                                   1                 1.00000000
18:                                   1                 1.00000000
19:                                   1                 1.00000000
20:                                   1                 1.00000000
    full_effect_sign_preserved_fraction nominal_p_lt_0_05_fraction
                                  <num>                      <num>
    same_nominal_state_as_full_fraction minimum_pearson_correlation_with_full
                                  <num>                                 <num>
 1:                           0.9583333                             0.9987977
 2:                           0.9130435                             0.9968605
 3:                           1.0000000                             0.9976674
 4:                           0.9714286                             0.9943707
 5:                           1.0000000                             0.9998999
 6:                           1.0000000                             0.9996447
 7:                           1.0000000                             0.9990405
 8:                           1.0000000                             0.9967307
 9:                           1.0000000                             0.9997955
10:                           1.0000000                             0.9991818
11:                           0.9583333                             0.9987829
12:                           0.9094203                             0.9967381
13:                           1.0000000                             0.9976341
14:                           0.9761905                             0.9940203
15:                           1.0000000                             0.9999006
16:                           1.0000000                             0.9996597
17:                           1.0000000                             0.9990181
18:                           1.0000000                             0.9966134
19:                           1.0000000                             0.9998020
20:                           1.0000000                             0.9992065
    same_nominal_state_as_full_fraction minimum_pearson_correlation_with_full
                                  <num>                                 <num>
    maximum_wilcox_p variant_count_match
               <num>              <lgcl>
 1:     1.051565e-01                TRUE
 2:     1.384982e-01                TRUE
 3:     4.414935e-02                TRUE
 4:     8.205847e-02                TRUE
 5:     3.342722e-06                TRUE
 6:     4.152503e-06                TRUE
 7:     1.434204e-06                TRUE
 8:     2.197342e-06                TRUE
 9:     7.122703e-03                TRUE
10:     1.083363e-02                TRUE
11:     1.016933e-01                TRUE
12:     1.363347e-01                TRUE
13:     4.002058e-02                TRUE
14:     6.804863e-02                TRUE
15:     4.579871e-06                TRUE
16:     6.494783e-06                TRUE
17:     1.907560e-06                TRUE
18:     3.617896e-06                TRUE
19:     7.035929e-03                TRUE
20:     9.976973e-03                TRUE
    maximum_wilcox_p variant_count_match
               <num>              <lgcl>
```

## Interpretation boundary

These deletion analyses assess internal score robustness within GSE73461. They do not redefine the locked modules and do not constitute independent-cohort replication.

Fractions retaining nominal significance are descriptive sensitivity summaries. Deletion variants were not treated as separately optimized or independently selected models.

## Output files

- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_full_module_baselines.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_reconstruction_check.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_module_manifest.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_variant_results.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_summary.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_worst_case_variants.tsv`
- `results/revision_round1/GSE73461_leave_one_two_gene_robustness/GSE73461_leave_one_two_gene_run_manifest.tsv`
