# GSE73461 Illumina Probe Annotation and Locked-Module Coverage Audit Report

- Generated: 2026-05-31 20:58:28 
- Purpose: assess whether GSE73461 can support fixed GSE211567 module projection after Illumina probe annotation.
- Boundary: identifier coverage audit only. No scoring, cohort lock, validation claim or biological interpretation is performed.

## Annotation summary

                                  metric value
                                  <char> <int>
1:                 expression_probe_rows 47323
2: expression_probe_ids_with_package_key 47323
3:                 probe_annotation_rows 57353
4:             unique_probes_with_symbol 35689
5:             unique_probes_with_entrez 35689
6:            unique_probes_with_ensembl 34652
7:                        unique_symbols 21603
8:                     unique_entrez_ids 21603
9:                    unique_ensembl_ids 24085

## Locked module coverage

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
   coverage_fraction pass_50pct_primary_threshold
               <num>                       <lgcl>
1:          0.960000                         TRUE
2:          1.000000                         TRUE
3:          1.000000                         TRUE
4:          1.000000                         TRUE
5:          0.990566                         TRUE
   pass_70pct_sensitivity_threshold
                             <lgcl>
1:                             TRUE
2:                             TRUE
3:                             TRUE
4:                             TRUE
5:                             TRUE

## Identifier coverage decision

   candidate_dataset annotation_package n_expression_probe_rows
              <char>             <char>                   <int>
1:          GSE73461 illuminaHumanv4.db                   47323
   minimum_module_coverage_fraction all_modules_pass_50pct
                              <num>                 <lgcl>
1:                             0.96                   TRUE
   all_modules_pass_70pct                           identifier_coverage_status
                   <lgcl>                                               <char>
1:                   TRUE eligible_for_formal_cohort_lock_pending_decision_log
                                                                                             reason
                                                                                             <char>
1: All locked modules pass both the 50% primary and 70% sensitivity identifier-coverage thresholds.
                                                                     next_action
                                                                          <char>
1: If accepted, log formal GSE73461 cohort lock before any fixed-module scoring.

## Interpretation boundary

- GSE73461 should not be scored until a separate cohort-lock decision is logged.
- If locked, modules must remain fixed and scoring must follow the pre-specified unweighted mean z-score rule.
- Coverage is assessed only to determine projection feasibility, not biological validity.

## Generated files

- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_expression_probe_ids.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_illuminaHumanv4_probe_annotation_join.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_probe_annotation_summary.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_identifier_coverage.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_matched_genes.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_locked_module_missing_genes.tsv`
- `results/external_projection_candidate_audit/GSE73461_identifier_coverage/GSE73461_identifier_coverage_decision.tsv`
