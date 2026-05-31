# GSE211567 Module Scoring Inputs and Projection Rules Report

- Generated: 2026-05-31 15:11:02 EAT
- Purpose: construct projection-ready module scoring inputs from locked final GSE211567 discovery modules.
- Boundary: scoring input construction only. No external projection, validation or transportability claim is performed here.

## Projection-ready module summary

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
           final_module_status    module_direction module_direction_sign
                        <char>              <char>                 <int>
1:    primary_discovery_module higher_in_bacterial                     1
2:    primary_discovery_module higher_in_bacterial                     1
3: primary_discovery_submodule     higher_in_viral                    -1
4: primary_discovery_submodule     higher_in_viral                    -1
5:    primary_discovery_module     higher_in_viral                    -1
   n_genes n_symbols median_pooled_logFC min_pooled_logFC max_pooled_logFC
     <int>     <int>               <num>            <num>            <num>
1:      25        25           0.7905924        0.4308131        3.0997808
2:      21        21           0.7585119       -0.7242210        1.4399087
3:     128       128          -0.9946967       -5.4450415       -0.3168443
4:      33        33          -1.4181680       -4.7677286       -0.4314568
5:     106       106          -0.8802844       -3.6846304       -0.3748731
   median_optional_abs_logFC_weight
                              <num>
1:                                1
2:                                1
3:                                1
4:                                1
5:                                1
                                                                                                                                                                                                                                                                                                top_symbols
                                                                                                                                                                                                                                                                                                     <char>
1:                                                                                                                                          RPS15A;RPS3A;RPS9;RPL27;RPL26L1;RPLP0;RPS7;RPL23;RPS27;RPL15;RPL9;RPL31;RPL17;RPL34;RPS24;RPL29;MRPL22;RPS4Y1;MRPL13;MRPS18C;UBA52;RPL26;MRPS11;EIF4EBP2;HYDIN2
2:                                                                                                                                                  NDUFB1;NDUFA4;ATP5MF;NDUFC2;ATP5ME;NDUFAF1;NDUFB3;NDUFAF8;MDH2;NDUFA3;ATP5F1A;NDUFAF2;NDUFS4;NDUFAF7;TMEM186;MTFR2;TMEM126A;NDUFAF6;CAT;SLC25A14;NDUFV3
3:          IFI27;IFIT1;OAS2;RSAD2;AXL;OAS3;CCL8;IFIT2;IFI44L;MX1;IFIT3;OASL;TRIM14;ISG15;IFI44;HERC5;EIF2AK2;ZBP1;DHX58;OAS1;TRIM5;SAMD9;TLR7;IFIT5;DDX60;RIGI;IFIH1;MX2;NT5C3A;RTP4;DEFB1;TREX1;IRF7;TLR3;BCL2;MOV10;PMAIP1;TRIM6;STAT2;SRC;TRIM22;PLSCR1;TRIM38;DTX3L;DDX60L;ENDOD1;IFI6;ISG20;PARP9;PML
4:                                                                                                  IFI27;IFIT1;OAS2;RSAD2;OAS3;MX1;OASL;ISG15;EIF2AK2;OAS1;TLR7;IFIT5;RIGI;IFIH1;TREX1;IRF7;TLR3;TRIM6;STAT2;PLSCR1;ISG20;STAT1;ZC3HAV1;AZI2;TANK;DDX3X;APOBEC3F;ZBTB20;IFITM3;TOMM70;RIPK2;FAM111A;PTPN11
5: IFI44L;IFI44;CMKLR1;BTN2A2;TLR7;LIF;DEFB1;TNFSF10;SMAD3;TLR3;IL7R;TRIM22;TNFSF8;BTN3A1;ELF1;CCR1;CYSLTR2;IFI6;CCR3;PANX1;JPH4;CCR9;ICOSLG;CD80;CCL28;P2RX7;IL1RN;CTSL;TCF7;SOCS1;PATZ1;CCR7;CD1D;ETS1;MARCHF1;LAX1;ZBTB39;TCF12;FCGR2B;HIC2;GATA3;CCRL2;AIRE;BTN2A3P;CCR6;GPR183;MS4A2;IL15;RGS1;KIR2DS2

## Scoring rules

                            rule_id
                             <char>
 1:             R1_input_identifier
 2:              R2_primary_scoring
 3:                      R3_scaling
 4:            R4_missing_gene_rule
 5:        R5_minimum_gene_coverage
 6:           R6_direction_handling
 7:             R7_weighted_scoring
 8: R8_external_projection_boundary
 9:                R9_no_retraining
10:                   R10_reporting
                                                                                                                                                                                               rule
                                                                                                                                                                                             <char>
 1:                                        Projection should use gene-level identifiers. SYMBOL may be used for cross-platform matching, with ENTREZID retained as the locked discovery identifier.
 2:                                                                  Primary module score is the unweighted mean of per-gene z-scored expression values for genes available in the external cohort.
 3:                                                                              Within each external dataset, expression values should be z-scored gene-wise across samples before module scoring.
 4:                                                                                                                    Missing genes are ignored for a module score, but coverage must be reported.
 5:           A module should be considered projection-eligible only if at least 50% of its locked genes are available after identifier matching; stricter 70% coverage can be used as sensitivity.
 6: Module direction is retained as discovered: bacterial-higher modules have direction sign +1; viral-higher modules have direction sign -1. Do not flip module direction using external outcomes.
 7:                                                    Weighted scoring using bounded absolute pooled logFC weights is optional sensitivity only and must not replace the primary unweighted score.
 8:                                                       External projection tests transportability of fixed discovery modules; it does not redefine modules, reweight genes, or select new genes.
 9:                                                                                              No external cohort should be used to reselect genes, rename modules, or adjust module composition.
10:                                                                  Report gene coverage, score distributions, group contrasts, and whether direction agrees with GSE211567 discovery orientation.

## Primary scoring rule

- Use unweighted mean z-score module scoring as the primary projection method.
- Z-score expression gene-wise within each external dataset before module scoring.
- Ignore missing genes but report coverage for every module.
- Require at least 50% locked-gene coverage for projection eligibility; optionally repeat with 70% coverage as sensitivity.

## Optional sensitivity rule

- Bounded abs(logFC)-weighted scoring is provided only as sensitivity.
- Do not use weighted scoring as the primary result because it risks overfitting to GSE211567 effect sizes.

## Interpretation boundary

- These module inputs are locked discovery-module gene sets.
- External datasets must not be used to reselect genes, rename modules, or alter module weights for the primary analysis.
- External projection should be described as transportability testing, not discovery.

## Generated files

- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_gene_table.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_summary.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_module_metadata.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_scoring_rules.tsv`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_modules_SYMBOL.gmt`
- `results/module_scoring/GSE211567_projection_ready_inputs/GSE211567_projection_ready_modules_ENTREZID.gmt`
- `results/module_scoring/GSE211567_projection_ready_inputs/module_<MODULE_ID>_genes.tsv`
- `results/figures/GSE211567_module_scoring_inputs/GSE211567_projection_ready_module_gene_counts.png/.pdf`
- `results/figures/GSE211567_module_scoring_inputs/GSE211567_optional_module_weight_distributions.png/.pdf`
- `env/session_info/GSE211567_module_scoring_inputs_projection_rules_sessionInfo.txt`
