# GSE161731 Technical QC Review Report

- Generated: 2026-05-30 22:42:32 EAT
- Purpose: review technical QC outputs from the GSE161731 count-level QC/voom rehearsal.
- Analytical boundary: no differential expression, pathway enrichment, module definition, module orientation, external validation or biological interpretation is performed here.

## Rehearsal subset

- Total samples reviewed: 102
- Bacterial samples: 24
- Non-COVID viral samples: 78

## Filtering summary

- Genes before filtering: 60675
- Genes retained after `filterByExpr`: 20561
- Genes removed: 40114

## Technical QC outlier thresholds

- Library-size IQR lower threshold: 25640000
- Library-size IQR upper threshold: 72160000
- Detected-gene IQR lower threshold: 9793
- Detected-gene IQR upper threshold: 30850
- TMM normalization-factor IQR lower threshold: 0.5817
- TMM normalization-factor IQR upper threshold: 1.418

## Outlier counts

- Library-size outliers: 5
- Detected-gene-count outliers: 1
- TMM normalization-factor outliers: 2
- Samples with any IQR-defined QC outlier flag: 6
- Metadata-caution samples: 3

## Group-level QC summary

             group     n median_library_size min_library_size max_library_size
            <char> <int>               <num>            <int>            <int>
1: non_covid_viral    78            49589218          1632403        130001160
2:       bacterial    24            52659224          9403540         65802042
   median_detected_genes min_detected_genes max_detected_genes
                   <num>              <int>              <int>
1:                 21155              11320              26991
2:                 19464               5332              27451
   median_norm_factor min_norm_factor max_norm_factor n_any_iqr_outlier
                <num>           <num>           <num>             <int>
1:          1.0353868       0.6013748        2.870861                 5
2:          0.8502916       0.6076763        1.240748                 1
   n_metadata_caution_flagged
                        <int>
1:                          2
2:                          1

## Metadata-caution samples

Key: <rna_id>
   rna_id           group           metadata_status
   <char>          <char>                    <char>
1: 434482 non_covid_viral mapped_to_counts_key_only
2: 434741 non_covid_viral mapped_to_counts_key_only
3:  94478       bacterial mapped_to_counts_key_only
                       caution_flags library_size detected_genes_count_gt0
                              <char>        <int>                    <int>
1: counts_key_only_not_in_sample_key     40986006                    11320
2: counts_key_only_not_in_sample_key      1632403                    12621
3: counts_key_only_not_in_sample_key      9403540                     5332
   norm.factors      PC1      PC2 any_qc_outlier_iqr
          <num>    <num>    <num>             <lgcl>
1:    0.8571284 140.4673 53.81760              FALSE
2:    2.8708610 251.3901 46.29203               TRUE
3:    1.0196552 508.4480 53.81053               TRUE

## Technical decision

- IQR-defined technical outliers were detected. Inspect the outlier table before any further workflow rehearsal.
- At least one metadata-caution sample is also an IQR-defined QC outlier; consider a sensitivity rehearsal excluding caution samples.

## Generated files

- `results/qc/GSE161731_technical_rehearsal/GSE161731_integrated_technical_qc_review_table.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_technical_qc_group_summary.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_technical_qc_outliers_and_caution_samples.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_counts_key_only_caution_sample_qc.tsv`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_TMM_normalization_factors_by_group.png` and `.pdf`
- `results/qc/GSE161731_technical_rehearsal/GSE161731_voom_PCA_caution_samples_highlighted.png` and `.pdf`

## Boundary statement

- This review supports only technical workflow assessment.
- It does not justify biological claims about bacterial versus viral host response.
- It does not affect the GSE211567 discovery design or module-freezing plan.
