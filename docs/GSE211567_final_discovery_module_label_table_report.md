# GSE211567 Final Discovery-Module Label Table Report

- Generated: 2026-05-31 15:01:38 EAT
- Purpose: assign conservative final discovery-module labels to primary candidate modules after gene-level inspection.
- Boundary: discovery labels only. This is not external validation, transportability proof or manuscript-level causal interpretation.

## Final discovery-module summary

      module_direction         final_module_status n_final_module_rows
                <char>                      <char>               <int>
1: higher_in_bacterial    primary_discovery_module                   2
2:     higher_in_viral primary_discovery_submodule                   2
3:     higher_in_viral    primary_discovery_module                   1
   total_unique_genes total_GO_terms total_FDR05_GO_terms
                <int>          <int>                <int>
1:                 46              6                    6
2:                161              6                    6
3:                106              3                    3

## Final discovery-module labels

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
           final_module_status    module_direction unique_entrez n_GO_terms
                        <char>              <char>         <int>      <int>
1:    primary_discovery_module higher_in_bacterial            25          2
2:    primary_discovery_module higher_in_bacterial            21          4
3: primary_discovery_submodule     higher_in_viral           128          3
4: primary_discovery_submodule     higher_in_viral            33          3
5:    primary_discovery_module     higher_in_viral           106          3
   n_FDR05_GO_terms pct_all_three_concordant  best_GO_FDR
              <int>                    <int>        <num>
1:                2                      100 3.386765e-07
2:                4                      100 6.688775e-03
3:                3                      100 1.073283e-06
4:                3                      100 1.993818e-03
5:                3                      100 5.379654e-04
                                                                                                                                                                     top_30_symbols
                                                                                                                                                                             <char>
1:                  RPS15A;RPS3A;RPS9;RPL27;RPL26L1;RPLP0;RPS7;RPL23;RPS27;RPL15;RPL9;RPL31;RPL17;RPL34;RPS24;RPL29;MRPL22;RPS4Y1;MRPL13;MRPS18C;UBA52;RPL26;MRPS11;EIF4EBP2;HYDIN2
2:                          NDUFB1;NDUFA4;ATP5MF;NDUFC2;ATP5ME;NDUFAF1;NDUFB3;NDUFAF8;MDH2;NDUFA3;ATP5F1A;NDUFAF2;NDUFS4;NDUFAF7;TMEM186;MTFR2;TMEM126A;NDUFAF6;CAT;SLC25A14;NDUFV3
3:        IFI27;IFIT1;OAS2;RSAD2;AXL;OAS3;CCL8;IFIT2;IFI44L;MX1;IFIT3;OASL;TRIM14;ISG15;IFI44;HERC5;EIF2AK2;ZBP1;DHX58;OAS1;TRIM5;SAMD9;TLR7;IFIT5;DDX60;RIGI;IFIH1;MX2;NT5C3A;RTP4
4:                                                     IFI27;IFIT1;OAS2;RSAD2;OAS3;MX1;OASL;ISG15;EIF2AK2;OAS1;TLR7;IFIT5;RIGI;IFIH1;TREX1;IRF7;TLR3;TRIM6;STAT2;PLSCR1;ISG20;STAT1
5: IFI44L;IFI44;CMKLR1;BTN2A2;TLR7;LIF;DEFB1;TNFSF10;SMAD3;TLR3;IL7R;TRIM22;TNFSF8;BTN3A1;ELF1;CCR1;CYSLTR2;IFI6;CCR3;PANX1;JPH4;CCR9;ICOSLG;CD80;CCL28;P2RX7;IL1RN;CTSL;TCF7;SOCS1
                                                                                                                                                       final_label_rationale
                                                                                                                                                                      <char>
1:                              Retained as a compact bacterial-higher discovery module supported by cytoplasmic translation/ribosomal GO terms and ribosomal overlap genes.
2: Retained as a compact bacterial-higher discovery module supported by respiratory-chain/oxidative phosphorylation GO terms and NDUF/ATP synthase-associated overlap genes.
3:                                        Retained as the broader antiviral/interferon discovery submodule with strong GO support and canonical ISG/antiviral overlap genes.
4:            Retained as a related but not force-merged antiviral/interferon subgroup because gene overlap with the broader antiviral module was below the merge threshold.
5:                                           Retained as a viral-higher discovery module supported by cytokine/immune-response GO terms and immune-regulatory overlap genes.

## Antiviral/interferon submodule boundary

Index: <assessment>
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

- These are GSE211567 discovery-module labels, not externally validated transportable modules.
- VIR_M1a and VIR_M1b are retained as related antiviral/interferon submodules rather than force-merged.
- The final module table preserves module direction, GO-term evidence, gene membership and site-aware concordance evidence.
- Manuscript claims should still distinguish discovery from external validation.

## Generated files

- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_table.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_compact_table.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_label_summary.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_genes.tsv`
- `results/module_lock/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_GO_terms.tsv`
- `results/figures/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_gene_counts.png/.pdf`
- `results/figures/GSE211567_final_discovery_module_labels/GSE211567_final_discovery_module_GO_term_counts.png/.pdf`
- `env/session_info/GSE211567_final_discovery_module_label_table_sessionInfo.txt`
