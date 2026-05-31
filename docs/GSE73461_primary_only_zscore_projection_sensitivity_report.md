# GSE73461 Primary-Only Z-Score Fixed-Module Projection Sensitivity Report

- Generated: 2026-05-31 22:13:51 
- Purpose: sensitivity analysis scoring locked GSE211567 modules in GSE73461 after z-scoring genes using only DefiniteBacterial and DefiniteViral samples.
- Boundary: fixed-module projection only. No module rediscovery, gene reselection, reweighting, renaming or diagnostic model training was performed.

## Projection cohort

- Primary bacterial samples: 52 
- Primary viral samples: 94 
- Secondary control/context samples excluded: 0 

## Module coverage used for scoring

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
   final_module_direction locked_genes_n matched_genes_n missing_genes_n
                   <char>          <int>           <int>           <int>
1:    higher_in_bacterial             25              24               1
2:    higher_in_bacterial             21              21               0
3:        higher_in_viral            128             128               0
4:        higher_in_viral             33              33               0
5:        higher_in_viral            106             105               1
   coverage_fraction missing_symbols
               <num>          <char>
1:          0.960000          HYDIN2
2:          1.000000                
3:          1.000000                
4:          1.000000                
5:          0.990566         BTN2A3P

## Primary bacterial-versus-viral projection tests

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
   final_module_direction n_bacterial n_viral mean_bacterial  mean_viral
                   <char>       <int>   <int>          <num>       <num>
1:    higher_in_bacterial          52      94      0.1076700 -0.05956214
2:    higher_in_bacterial          52      94      0.1430166 -0.07911555
3:        higher_in_viral          52      94     -0.2910218  0.16099078
4:        higher_in_viral          52      94     -0.3708559  0.20515431
5:        higher_in_viral          52      94     -0.1669975  0.09238158
   median_bacterial median_viral median_difference_bacterial_minus_viral
              <num>        <num>                                   <num>
1:      -0.04506635  -0.26611646                               0.2210501
2:       0.18509254  -0.16528432                               0.3503769
3:      -0.34240469   0.10173984                              -0.4441445
4:      -0.47266859   0.17179518                              -0.6444638
5:      -0.21964049   0.04293453                              -0.2625750
       wilcox_p  wilcox_p_BH expected_direction_match
          <num>        <num>                   <lgcl>
1: 7.783557e-02 7.783557e-02                     TRUE
2: 1.319187e-02 1.648984e-02                     TRUE
3: 3.026901e-06 7.567252e-06                     TRUE
4: 4.440278e-07 2.220139e-06                     TRUE
5: 4.775126e-03 7.958544e-03                     TRUE

## Interpretation boundary

- These are fixed-module projection scores in the locked external cohort.
- Statistical results assess transportability of pre-locked modules, not new diagnostic-signature discovery.
- Any biological interpretation must preserve the discovery/projection firewall and report direction concordance explicitly.

## Generated files

- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_sensitivity_coverage.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_long.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_wide.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_score_group_summary.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_gene_probe_choice_for_projection.tsv`
- `results/figures/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_scores_primary_groups.png/.pdf`
- `results/figures/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_median_differences.png/.pdf`
