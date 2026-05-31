# GSE161731 Fixed-Module Scoring Rehearsal Report

- Generated: 2026-05-31 16:19:54 EAT
- Purpose: technical rehearsal of locked GSE211567 module scoring in GSE161731.
- Boundary: no validation, no module rediscovery and no biological interpretation.

## Input

- Expression features: 20561
- Expression samples: 102
- Module score rows generated: 510

## Module scoring coverage

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
      module_direction n_locked_genes n_genes_scored coverage_pct
                <char>          <int>          <int>        <num>
1: higher_in_bacterial             24             24          100
2: higher_in_bacterial             21             21          100
3:     higher_in_viral            125            126          100
4:     higher_in_viral             32             32          100
5:     higher_in_viral            100            100          100
   n_ensembl_features_scored
                       <int>
1:                        24
2:                        21
3:                       126
4:                        32
5:                       100

## Technical group score summary

    final_module_id
             <char>
 1:         BACT_M1
 2:         BACT_M2
 3:         VIR_M1a
 4:         VIR_M1b
 5:          VIR_M2
 6:         BACT_M1
 7:         BACT_M2
 8:         VIR_M1a
 9:         VIR_M1b
10:          VIR_M2
                                                                    final_module_label
                                                                                <char>
 1:           Bacterial-higher cytoplasmic translation and ribosomal protein programme
 2: Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme
 3:           Viral-higher broad antiviral and interferon-stimulated defence programme
 4:           Viral-higher viral restriction and type I interferon signalling subgroup
 5:                       Viral-higher cytokine and innate immune regulation programme
 6:           Bacterial-higher cytoplasmic translation and ribosomal protein programme
 7: Bacterial-higher mitochondrial respiration and oxidative phosphorylation programme
 8:           Viral-higher broad antiviral and interferon-stimulated defence programme
 9:           Viral-higher viral restriction and type I interferon signalling subgroup
10:                       Viral-higher cytokine and innate immune regulation programme
       module_direction   scoring_group n_samples median_score  mean_score
                 <char>          <char>     <int>        <num>       <num>
 1: higher_in_bacterial non_covid_viral        78   0.03434369  0.09806434
 2: higher_in_bacterial non_covid_viral        78   0.10520844  0.04274741
 3:     higher_in_viral non_covid_viral        78   0.20284368  0.16145755
 4:     higher_in_viral non_covid_viral        78   0.13436270  0.17656206
 5:     higher_in_viral non_covid_viral        78   0.15076836  0.12038358
 6: higher_in_bacterial       bacterial        24  -0.30656752 -0.31870911
 7: higher_in_bacterial       bacterial        24  -0.10460592 -0.13892908
 8:     higher_in_viral       bacterial        24  -0.40958666 -0.52473703
 9:     higher_in_viral       bacterial        24  -0.48947439 -0.57382670
10:     higher_in_viral       bacterial        24  -0.21196690 -0.39124664
     sd_score   q25_score   q75_score
        <num>       <num>       <num>
 1: 0.6123730 -0.32476355  0.52362126
 2: 0.4205660 -0.12321428  0.30612048
 3: 0.4122927 -0.03923080  0.38097372
 4: 0.6100329 -0.23731271  0.55019041
 5: 0.3530699  0.01186958  0.31518887
 6: 0.5874895 -0.72130356 -0.07335477
 7: 0.5238809 -0.28269355  0.10758940
 8: 0.6575185 -0.57603890 -0.23534032
 9: 0.5269202 -0.77640069 -0.23176158
10: 0.8505940 -0.35062343 -0.07871485

## Interpretation boundary

- Module genes, labels and directions were fixed from GSE211567.
- Scores were computed using unweighted mean z-score scoring.
- GSE161731 is used here only as a technical projection rehearsal resource.
- These results must not be described as external validation or transportability evidence.

## Generated files

- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scores_long.tsv`
- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scores_wide.tsv`
- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_scoring_coverage.tsv`
- `results/module_projection_rehearsal/GSE161731_fixed_module_scoring/GSE161731_fixed_module_score_group_summary.tsv`
- `results/figures/GSE161731_fixed_module_scoring_rehearsal/GSE161731_fixed_module_score_distributions.png/.pdf`
- `results/figures/GSE161731_fixed_module_scoring_rehearsal/GSE161731_fixed_module_scores_by_group.png/.pdf`
- `env/session_info/GSE161731_fixed_module_scoring_rehearsal_sessionInfo.txt`
