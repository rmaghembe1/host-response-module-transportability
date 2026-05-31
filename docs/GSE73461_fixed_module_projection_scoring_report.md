# GSE73461 Fixed-Module Projection Scoring Report

- Generated: 2026-05-31 21:51:01 
- Purpose: score locked GSE211567 discovery modules in locked GSE73461 external projection cohort.
- Boundary: fixed-module projection only. No module rediscovery, gene reselection, reweighting, renaming or diagnostic model training was performed.

## Projection cohort

- Primary bacterial samples: 52 
- Primary viral samples: 94 
- Secondary control/context samples: 55 

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
1:    higher_in_bacterial          52      94     0.09217579 -0.06540605
2:    higher_in_bacterial          52      94     0.20889937 -0.01417797
3:        higher_in_viral          52      94    -0.24655075  0.23362663
4:        higher_in_viral          52      94    -0.26956497  0.34043647
5:        higher_in_viral          52      94    -0.17144791  0.09083678
   median_bacterial median_viral median_difference_bacterial_minus_viral
              <num>        <num>                                   <num>
1:      -0.05120991  -0.25792392                               0.2067140
2:       0.24109069  -0.09174581                               0.3328365
3:      -0.29574901   0.16719844                              -0.4629475
4:      -0.37541365   0.29848520                              -0.6738989
5:      -0.22085873   0.03869837                              -0.2595571
       wilcox_p  wilcox_p_BH expected_direction_match
          <num>        <num>                   <lgcl>
1: 7.992436e-02 7.992436e-02                     TRUE
2: 1.617302e-02 2.021627e-02                     TRUE
3: 1.907560e-06 4.768901e-06                     TRUE
4: 2.823498e-07 1.411749e-06                     TRUE
5: 5.088274e-03 8.480456e-03                     TRUE

## Interpretation boundary

- These are fixed-module projection scores in the locked external cohort.
- Statistical results assess transportability of pre-locked modules, not new diagnostic-signature discovery.
- Any biological interpretation must preserve the discovery/projection firewall and report direction concordance explicitly.

## Generated files

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_projection_coverage.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_long.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_wide.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_score_group_summary.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_gene_probe_choice_for_projection.tsv`
- `results/figures/GSE73461_fixed_module_projection/GSE73461_fixed_module_scores_primary_groups.png/.pdf`
- `results/figures/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_median_differences.png/.pdf`
