# GSE211567 Design/Covariate Feasibility Report

- Generated: 2026-05-31 09:15:50 EAT
- Purpose: assess design/covariate feasibility before GSE211567 discovery modelling.
- Analytical boundary: no differential expression, pathway enrichment, module discovery, module orientation or biological interpretation is performed here.

## Primary discovery sample set

- Primary bacterial-versus-viral samples: 224
- Bacterial samples: 101
- Viral samples: 123

## Site × group structure

              V1        V2     N
          <char>    <char> <int>
1:     Sri_Lanka     viral    81
2: United_States     viral    42
3:     Sri_Lanka bacterial    60
4: United_States bacterial    41

## Batch × group structure

       V1        V2     N
   <char>    <char> <int>
1:      1     viral    77
2:      2     viral    46
3:      1 bacterial    78
4:      2 bacterial    23

## Site × batch structure

              V1     V2     N
          <char> <char> <int>
1:     Sri_Lanka      1   100
2: United_States      1    55
3:     Sri_Lanka      2    41
4: United_States      2    28

## Group × pathogen structure

           V1                V2     N
       <char>            <char> <int>
 1:     viral Coxiella_burnetii     0
 2: bacterial Coxiella_burnetii     3
 3:     viral            Dengue    43
 4: bacterial            Dengue     0
 5:     viral      Enterobacter     0
 6: bacterial      Enterobacter    17
 7:     viral     Influenza_A_B    67
 8: bacterial     Influenza_A_B     0
 9:     viral        Leptospira     0
10: bacterial        Leptospira    30
11:     viral   RespVirus_other    13
12: bacterial   RespVirus_other     0
13:     viral        Rickettsia     0
14: bacterial        Rickettsia    27
15:     viral    Staphylococcus     0
16: bacterial    Staphylococcus    10
17:     viral     Streptococcus     0
18: bacterial     Streptococcus    14

## Covariate completeness

Index: <covariate>
          covariate n_nonmissing n_total pct_nonmissing
             <char>        <int>   <int>          <num>
1:      age_numeric          224     224         100.00
2:           gender          224     224         100.00
3:             race           83     224          37.05
4:             site          224     224         100.00
5: sequencing_batch          224     224         100.00
6:      platform_id          224     224         100.00
7: instrument_model          224     224         100.00
8:         pathogen          224     224         100.00

## Model matrix rank checks

                                model_label n_samples n_columns  rank full_rank
                                     <char>     <int>     <int> <int>    <lgcl>
1:                               group_only       224         2     2      TRUE
2:                          group_plus_site       224         3     3      TRUE
3:                         group_plus_batch       224         3     3      TRUE
4:               group_plus_site_plus_batch       224         4     4      TRUE
5:                      group_plus_platform       224         3     3      TRUE
6:                    group_plus_instrument       224         3     3      TRUE
7: group_site_batch_age_gender_complete_age       224         6     6      TRUE

## Technical recommendations

- A pooled primary design including discovery group, site and sequencing batch is algebraically full-rank and feasible as a technical starting point.
- Both sites contain bacterial and viral samples, so site-stratified bacterial-versus-viral concordance is feasible.
- Age completeness = 100%; gender completeness = 100%; race completeness = 37.05%. Age/gender may be considered cautiously if full-rank models remain stable; race should be handled carefully because missingness is site-linked.
- Pathogen is biologically nested within infection group and partly site-linked, so it should not be included as a simple adjustment covariate in the primary bacterial-versus-viral discovery model.
- Noninfection samples should remain contextual/control samples, not part of the primary bacterial-versus-viral contrast.
- A design decision should be logged before running discovery modelling.

## Generated files

- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_group_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_site_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_primary_batch_counts.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_site_by_group.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_batch_by_group.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_site_by_batch.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_group_by_pathogen.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_covariate_completeness.tsv`
- `results/qc/GSE211567_locked_normalized_matrix/GSE211567_design_model_matrix_rank_checks.tsv`

## Boundary statement

- This report determines technical feasibility of candidate model structures only.
- It does not select genes.
- It does not define biological modules.
- It does not interpret host-response biology.
