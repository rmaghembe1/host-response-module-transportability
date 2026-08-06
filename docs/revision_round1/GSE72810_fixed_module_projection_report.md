# GSE72810 fixed-module projection report

## Locked analytical framework

The five discovery modules were projected without probe reselection, gene reselection, module redefinition, gene reweighting, module renaming, direction flipping or diagnostic-model training.

The primary analysis used the frozen representative probes and gene-wise z-standardization across all 146 samples before comparing 23 definite bacterial with 28 definite viral samples.

## Prespecified sensitivity analyses

1. Primary-only z-reference sensitivity using the same frozen probes and the 51 definite bacterial and viral samples.
2. Expanded phenotype sensitivity comparing 40 definite-plus- probable bacterial with 35 definite-plus-probable viral samples.
3. Probe-collapse sensitivity using mean expression across all Entrez-authorized probes per mapped gene.

## Direction and significance summary

```text
                                          analysis_id
                                               <char>
1:              main_representative_all146_z_definite
2:          primary_only_representative_51_z_definite
3: expanded_representative_all146_z_definite_probable
4:                   all_probe_mean_all146_z_definite
   modules_direction_retained nominally_significant_modules
                        <int>                         <int>
1:                          5                             4
2:                          5                             4
3:                          5                             4
4:                          5                             4
   fdr_significant_modules
                     <int>
1:                       4
2:                       4
3:                       4
4:                       4
```

## Primary and sensitivity results

```text
                                           analysis_id final_module_id
                                                <char>          <char>
 1:              main_representative_all146_z_definite         BACT_M1
 2:              main_representative_all146_z_definite         BACT_M2
 3:              main_representative_all146_z_definite         VIR_M1a
 4:              main_representative_all146_z_definite         VIR_M1b
 5:              main_representative_all146_z_definite          VIR_M2
 6:          primary_only_representative_51_z_definite         BACT_M1
 7:          primary_only_representative_51_z_definite         BACT_M2
 8:          primary_only_representative_51_z_definite         VIR_M1a
 9:          primary_only_representative_51_z_definite         VIR_M1b
10:          primary_only_representative_51_z_definite          VIR_M2
11: expanded_representative_all146_z_definite_probable         BACT_M1
12: expanded_representative_all146_z_definite_probable         BACT_M2
13: expanded_representative_all146_z_definite_probable         VIR_M1a
14: expanded_representative_all146_z_definite_probable         VIR_M1b
15: expanded_representative_all146_z_definite_probable          VIR_M2
16:                   all_probe_mean_all146_z_definite         BACT_M1
17:                   all_probe_mean_all146_z_definite         BACT_M2
18:                   all_probe_mean_all146_z_definite         VIR_M1a
19:                   all_probe_mean_all146_z_definite         VIR_M1b
20:                   all_probe_mean_all146_z_definite          VIR_M2
                                           analysis_id final_module_id
                                                <char>          <char>
    bacterial_n viral_n median_difference_bacterial_minus_viral
          <int>   <int>                                   <num>
 1:          23      28                               0.5183680
 2:          23      28                               0.4229352
 3:          23      28                              -0.6879019
 4:          23      28                              -0.9051948
 5:          23      28                              -0.5471759
 6:          23      28                               0.5097950
 7:          23      28                               0.4220097
 8:          23      28                              -0.6716883
 9:          23      28                              -0.9018577
10:          23      28                              -0.5405245
11:          40      35                               0.3297441
12:          40      35                               0.4347553
13:          40      35                              -0.6354889
14:          40      35                              -0.8748272
15:          40      35                              -0.5208981
16:          23      28                               0.4777623
17:          23      28                               0.4290501
18:          23      28                              -0.6654634
19:          23      28                              -0.9121325
20:          23      28                              -0.5745974
    bacterial_n viral_n median_difference_bacterial_minus_viral
          <int>   <int>                                   <num>
    rank_biserial_effect   wilcoxon_p   wilcoxon_q direction_retained
                   <num>        <num>        <num>             <lgcl>
 1:            0.2888199 7.994480e-02 7.994480e-02               TRUE
 2:            0.5186335 1.622609e-03 2.028261e-03               TRUE
 3:           -0.9316770 1.432358e-08 7.161788e-08               TRUE
 4:           -0.8975155 4.728012e-08 8.765310e-08               TRUE
 5:           -0.8944099 5.259186e-08 8.765310e-08               TRUE
 6:            0.2919255 7.673776e-02 7.673776e-02               TRUE
 7:            0.4937888 2.696490e-03 3.370612e-03               TRUE
 8:           -0.9347826 1.282316e-08 6.411578e-08               TRUE
 9:           -0.8944099 5.259186e-08 8.765310e-08               TRUE
10:           -0.9037267 3.817199e-08 8.765310e-08               TRUE
11:            0.1742857 1.969410e-01 1.969410e-01               TRUE
12:            0.3857143 4.208986e-03 5.261232e-03               TRUE
13:           -0.8085714 1.906904e-09 6.188734e-09               TRUE
14:           -0.7728571 9.464984e-09 1.577497e-08               TRUE
15:           -0.8028571 2.475493e-09 6.188734e-09               TRUE
16:            0.3229814 5.008536e-02 5.008536e-02               TRUE
17:            0.4720497 4.132523e-03 5.165654e-03               TRUE
18:           -0.9316770 1.432358e-08 7.161788e-08               TRUE
19:           -0.8881988 6.500472e-08 1.203871e-07               TRUE
20:           -0.8850932 7.223229e-08 1.203871e-07               TRUE
    rank_biserial_effect   wilcoxon_p   wilcoxon_q direction_retained
                   <num>        <num>        <num>             <lgcl>
    fdr_significant
             <lgcl>
 1:           FALSE
 2:            TRUE
 3:            TRUE
 4:            TRUE
 5:            TRUE
 6:           FALSE
 7:            TRUE
 8:            TRUE
 9:            TRUE
10:            TRUE
11:           FALSE
12:            TRUE
13:            TRUE
14:            TRUE
15:            TRUE
16:           FALSE
17:            TRUE
18:            TRUE
19:            TRUE
20:            TRUE
    fdr_significant
             <lgcl>
```

## Score concordance

```text
                                            comparison_id
                                                   <char>
 1:  main_all146_z_vs_primary51_z_within_definite_samples
 2:  main_all146_z_vs_primary51_z_within_definite_samples
 3:  main_all146_z_vs_primary51_z_within_definite_samples
 4:  main_all146_z_vs_primary51_z_within_definite_samples
 5:  main_all146_z_vs_primary51_z_within_definite_samples
 6: representative_probe_vs_all_probe_mean_all146_samples
 7: representative_probe_vs_all_probe_mean_all146_samples
 8: representative_probe_vs_all_probe_mean_all146_samples
 9: representative_probe_vs_all_probe_mean_all146_samples
10: representative_probe_vs_all_probe_mean_all146_samples
                 representation_a                   representation_b
                           <char>                             <char>
 1: representative_probe_all146_z   representative_probe_primary51_z
 2: representative_probe_all146_z   representative_probe_primary51_z
 3: representative_probe_all146_z   representative_probe_primary51_z
 4: representative_probe_all146_z   representative_probe_primary51_z
 5: representative_probe_all146_z   representative_probe_primary51_z
 6: representative_probe_all146_z all_authorized_probe_mean_all146_z
 7: representative_probe_all146_z all_authorized_probe_mean_all146_z
 8: representative_probe_all146_z all_authorized_probe_mean_all146_z
 9: representative_probe_all146_z all_authorized_probe_mean_all146_z
10: representative_probe_all146_z all_authorized_probe_mean_all146_z
    final_module_id sample_count pearson_correlation spearman_correlation
             <char>        <int>               <num>                <num>
 1:         BACT_M1           51           0.9998372            0.9992760
 2:         BACT_M2           51           0.9995252            0.9984615
 3:         VIR_M1a           51           0.9997100            0.9987330
 4:         VIR_M1b           51           0.9997490            0.9987330
 5:          VIR_M2           51           0.9983978            0.9957466
 6:         BACT_M1          146           0.9961532            0.9968110
 7:         BACT_M2          146           0.9874322            0.9813714
 8:         VIR_M1a          146           0.9974334            0.9971619
 9:         VIR_M1b          146           0.9959748            0.9961555
10:          VIR_M2          146           0.9942033            0.9942583
    mean_absolute_score_difference median_absolute_score_difference
                             <num>                            <num>
 1:                     0.08225470                       0.08106109
 2:                     0.15874342                       0.16015678
 3:                     0.02966470                       0.02917052
 4:                     0.08257771                       0.08304277
 5:                     0.02372630                       0.01775082
 6:                     0.05266753                       0.04613251
 7:                     0.05782868                       0.04411602
 8:                     0.02456237                       0.02041904
 9:                     0.04463430                       0.03563369
10:                     0.02517623                       0.02132632
    maximum_absolute_score_difference
                                <num>
 1:                        0.13976401
 2:                        0.20466395
 3:                        0.06190223
 4:                        0.11194400
 5:                        0.07354531
 6:                        0.17240018
 7:                        0.26902339
 8:                        0.11844608
 9:                        0.28951873
10:                        0.09098987
```

## Module coverage

```text
   final_module_id
            <char>
1:         BACT_M1
2:         BACT_M2
3:         VIR_M1a
4:         VIR_M1b
5:          VIR_M2
                                                                   final_module_label
                                                                               <char>
1:           Bacterial-higher cytoplasmic translation and ribosomal protein programme
2: Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme
3:           Viral-higher broad antiviral and interferon-stimulated defence programme
4:           Viral-higher viral restriction and type I interferon signalling subgroup
5:                       Viral-higher cytokine and innate immune regulation programme
      module_direction locked_gene_count mapped_gene_count missing_gene_count
                <char>             <int>             <int>              <int>
1: higher_in_bacterial                25                24                  1
2: higher_in_bacterial                21                20                  1
3:     higher_in_viral               128               125                  3
4:     higher_in_viral                33                33                  0
5:     higher_in_viral               106               101                  5
   coverage_fraction                 missing_symbols
               <num>                          <char>
1:         0.9600000                          HYDIN2
2:         0.9523810                         NDUFAF8
3:         0.9765625              DDX60L;MICA;POLR3E
4:         1.0000000                            none
5:         0.9528302 CCR2;CCRL2;KIR2DS2;KIR3DS1;MICA
   representative_probes_frozen
                         <lgcl>
1:                         TRUE
2:                         TRUE
3:                         TRUE
4:                         TRUE
5:                         TRUE
```

## Quality gate

```text
    check_id                                                check_description
      <char>                                                           <char>
 1:      Q01                                Phase R1D3A design lock validates
 2:      Q02                  Expression matrix contains 48,803 unique probes
 3:      Q03                           Expression matrix contains 146 samples
 4:      Q04                      Expression and metadata sample orders match
 5:      Q05     Frozen representative table contains 256 unique Entrez genes
 6:      Q06                  Frozen module-gene table contains 313 instances
 7:      Q07                           Mapped module-gene instances equal 303
 8:      Q08                          Unmapped module-gene instances equal 10
 9:      Q09                     All frozen representative probes are present
10:      Q10                                All authorized probes are present
11:      Q11             Representative all-sample reference SDs are positive
12:      Q12           Representative primary-only reference SDs are positive
13:      Q13             All-probe-mean all-sample reference SDs are positive
14:      Q14                                     All module scores are finite
15:      Q15                 Module-score row count matches the locked design
16:      Q16                                     Module-score keys are unique
17:      Q17                         Twenty analysis-test rows were generated
18:      Q18                          Forty group-summary rows were generated
19:      Q19             Ten score-concordance rows were generated and finite
20:      Q20      All five modules retain at least 70 percent mapped coverage
21:      Q21 All analysis definitions prohibit reselection and model training
    check_id                                                check_description
      <char>                                                           <char>
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
      pass
    <lgcl>
```

- Quality gate: `PASS`.
- Projection status: `READY_FOR_EFFECT_SIZE_AND_FIGURE_ANALYSIS`.
