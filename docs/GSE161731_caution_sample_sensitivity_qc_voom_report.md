# GSE161731 Caution-Sample Sensitivity QC/voom Report

- Generated: 2026-05-30 22:48:05 EAT
- Purpose: technical sensitivity rehearsal only, excluding counts-key-only caution samples.
- Analytical boundary: no differential expression, pathway enrichment, module definition, module orientation, external validation or biological interpretation is performed here.

## Excluded samples

- 434482, 434741, 94478

## Sensitivity subset

- Total samples: 99
- Bacterial samples: 23
- Non-COVID viral samples: 76

## Gene filtering

- Genes before filtering: 60675
- Genes retained after `filterByExpr`: 20561
- Genes removed: 40114

## Sensitivity technical outlier counts

- Library-size outliers: 3
- Detected-gene-count outliers: 0
- TMM normalization-factor outliers: 4
- Samples with any IQR-defined QC outlier flag: 6

## Group-level QC summary

             group     n median_library_size min_library_size max_library_size
            <fctr> <int>               <num>            <num>            <num>
1: non_covid_viral    76            50125302         16320748        130001160
2:       bacterial    23            52712744         40199836         65802042
   median_detected_genes min_detected_genes max_detected_genes
                   <num>              <num>              <num>
1:               21184.5              13552              26991
2:               19586.0              14695              27451
   median_norm_factor min_norm_factor max_norm_factor n_any_iqr_outlier
                <num>           <num>           <num>             <int>
1:          1.0385317       0.6298963        1.524676                 5
2:          0.8356933       0.5920208        1.273812                 1

## IQR-defined sensitivity outliers

            rna_id           group      metadata_status caution_flags
            <char>          <fctr>               <char>        <char>
1:          434325 non_covid_viral mapped_to_sample_key          none
2:          434596 non_covid_viral mapped_to_sample_key          none
3:          434777 non_covid_viral mapped_to_sample_key          none
4:           95982       bacterial mapped_to_sample_key          none
5: DU09-03S0000774 non_covid_viral mapped_to_sample_key          none
6:   DU09-03S19478 non_covid_viral mapped_to_sample_key          none
   library_size detected_genes_count_gt0 norm.factors        PC1       PC2
          <num>                    <num>        <num>      <num>     <num>
1:    130001160                    17025    1.1454041  -1.755998  60.35936
2:     16320748                    26834    1.4478476  -7.433979 -79.42344
3:     20302169                    22370    1.2008387 -44.597333 -41.17877
4:     62144581                    23621    0.5920208 139.727918 -40.55323
5:     43639732                    25902    1.5246755 -38.162510 -66.11010
6:     48547888                    26655    1.4079749 -30.011650 -56.75843
   library_size_outlier_iqr detected_genes_outlier_iqr norm_factor_outlier_iqr
                     <lgcl>                     <lgcl>                  <lgcl>
1:                     TRUE                      FALSE                   FALSE
2:                     TRUE                      FALSE                    TRUE
3:                     TRUE                      FALSE                   FALSE
4:                    FALSE                      FALSE                    TRUE
5:                    FALSE                      FALSE                    TRUE
6:                    FALSE                      FALSE                    TRUE

## Generated files

- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_sample_level_qc_summary.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_filtering_summary.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_TMM_normalization_factors.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_design_matrix.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_voom_PCA_coordinates.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_integrated_qc_table.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_qc_group_summary.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_qc_outliers.tsv`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_voom_objects.rds`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_voom_PCA.png` and `.pdf`
- `results/sensitivity/GSE161731_exclude_counts_key_only_caution_samples/GSE161731_sensitivity_MDS_plot.png` and `.pdf`
- `env/session_info/GSE161731_caution_sample_sensitivity_qc_voom_sessionInfo.txt`

## Boundary statement

- This sensitivity analysis supports only technical workflow assessment.
- It does not justify biological claims about bacterial versus viral host response.
- It does not affect GSE211567 discovery-module selection or module-freezing.
