# GSE211567 Primary Candidate-Module Gene-Level Inspection Report

- Generated: 2026-05-31 14:56:48 EAT
- Purpose: inspect overlap genes, site-aware stability and merge relationships among primary candidate modules.
- Boundary: inspection only. This is not final module naming, manuscript interpretation or external validation.

## Primary candidate-module input

- Primary candidate module rows: 5
- Primary-module GO term rows: 15
- Primary-module overlap-gene rows: 322

## Primary module gene-level summary

      module_direction
                <char>
1: higher_in_bacterial
2: higher_in_bacterial
3:     higher_in_viral
4:     higher_in_viral
5:     higher_in_viral
                                          provisional_module_label
                                                            <char>
1: Mitochondrial respiration / oxidative phosphorylation programme
2:           Cytoplasmic translation / ribosomal protein programme
3:                       Antiviral / interferon-response programme
4:                       Antiviral / interferon-response programme
5:                 Cytokine and innate immune regulation programme
          evidence_grade unique_entrez n_GO_terms n_FDR05_GO_terms
                  <char>         <int>      <int>            <int>
1:   A_strong_GO_support            21          4                4
2:   A_strong_GO_support            25          2                2
3:   A_strong_GO_support           128          3                3
4: B_moderate_GO_support            33          3                3
5: B_moderate_GO_support           106          3                3
   pct_all_three_concordant pct_tier1_to_3  best_GO_FDR
                      <num>          <num>        <num>
1:                      100            100 6.688775e-03
2:                      100            100 3.386765e-07
3:                      100            100 1.073283e-06
4:                      100            100 1.993818e-03
5:                      100            100 5.379654e-04
                        inspection_flag
                                 <char>
1: passes_initial_gene_level_inspection
2: passes_initial_gene_level_inspection
3: passes_initial_gene_level_inspection
4: passes_initial_gene_level_inspection
5: passes_initial_gene_level_inspection
                                                                                                                                                                     top_30_symbols
                                                                                                                                                                             <char>
1:                          NDUFB1;NDUFA4;ATP5MF;NDUFC2;ATP5ME;NDUFAF1;NDUFB3;NDUFAF8;MDH2;NDUFA3;ATP5F1A;NDUFAF2;NDUFS4;NDUFAF7;TMEM186;MTFR2;TMEM126A;NDUFAF6;CAT;SLC25A14;NDUFV3
2:                  RPS15A;RPS3A;RPS9;RPL27;RPL26L1;RPLP0;RPS7;RPL23;RPS27;RPL15;RPL9;RPL31;RPL17;RPL34;RPS24;RPL29;MRPL22;RPS4Y1;MRPL13;MRPS18C;UBA52;RPL26;MRPS11;EIF4EBP2;HYDIN2
3:        IFI27;IFIT1;OAS2;RSAD2;AXL;OAS3;CCL8;IFIT2;IFI44L;MX1;IFIT3;OASL;TRIM14;ISG15;IFI44;HERC5;EIF2AK2;ZBP1;DHX58;OAS1;TRIM5;SAMD9;TLR7;IFIT5;DDX60;RIGI;IFIH1;MX2;NT5C3A;RTP4
4:                                                     IFI27;IFIT1;OAS2;RSAD2;OAS3;MX1;OASL;ISG15;EIF2AK2;OAS1;TLR7;IFIT5;RIGI;IFIH1;TREX1;IRF7;TLR3;TRIM6;STAT2;PLSCR1;ISG20;STAT1
5: IFI44L;IFI44;CMKLR1;BTN2A2;TLR7;LIF;DEFB1;TNFSF10;SMAD3;TLR3;IL7R;TRIM22;TNFSF8;BTN3A1;ELF1;CCR1;CYSLTR2;IFI6;CCR3;PANX1;JPH4;CCR9;ICOSLG;CD80;CCL28;P2RX7;IL1RN;CTSL;TCF7;SOCS1

## Antiviral/interferon merge assessment

                                               assessment
                                                   <char>
1:                    n_primary_antiviral_interferon_rows
2: max_pairwise_jaccard_between_antiviral_interferon_rows
3: shared_genes_between_closest_antiviral_interferon_rows
4:                             provisional_recommendation
                                                                     value
                                                                    <char>
1:                                                                       2
2:                                                                  0.2197
3:                                                                      29
4: retain_as_related_antiviral_interferon_submodules_pending_manual_review

## Interpretation boundary

- This inspection prioritizes gene-level coherence and site-aware stability.
- Primary candidate modules are still not final manuscript claims.
- Any final module naming should occur only after reviewing top genes, GO-term membership and pairwise overlap.
- The two antiviral/interferon primary rows should be merged only if gene overlap and biological content support a single coherent programme.

## Generated files

- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_rows_for_gene_inspection.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_GO_terms_for_inspection.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_overlap_genes_for_inspection.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_gene_level_summary.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_top30_genes_by_module.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_pairwise_gene_overlap.tsv`
- `results/module_lock/GSE211567_primary_module_gene_inspection/GSE211567_primary_antiviral_interferon_merge_assessment.tsv`
- `results/figures/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_gene_counts.png/.pdf`
- `results/figures/GSE211567_primary_module_gene_inspection/GSE211567_primary_module_all_three_concordance.png/.pdf`
- `env/session_info/GSE211567_primary_module_gene_level_inspection_sessionInfo.txt`
