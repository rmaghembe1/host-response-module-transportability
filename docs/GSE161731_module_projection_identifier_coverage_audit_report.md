# GSE161731 Module Projection Identifier-Coverage Audit Report

- Generated: 2026-05-31 15:32:50 EAT
- Purpose: technical projection rehearsal identifier-coverage audit only.
- Boundary: no module scoring, no validation, no biological interpretation.

## Input

- Locked GSE211567 module-gene rows: 313
- Locked unique module genes: 265
- GSE161731 expression features detected: 20561

## GSE161731 expression identifier pattern summary

               pattern count
                <char> <int>
1:                ENSG 20561
2: Entrez_numeric_only     0
3:  RefSeq_NM_NR_XM_XR     0
4:       contains_pipe     0
5:        contains_dot     0

## Module coverage by ENSEMBL mapping

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
      module_direction locked_genes genes_with_any_ensembl_mapping
                <char>        <int>                          <int>
1: higher_in_bacterial           25                             24
2: higher_in_bacterial           21                             21
3:     higher_in_viral          128                            128
4:     higher_in_viral           33                             33
5:     higher_in_viral          106                            106
   matched_genes_by_ensembl matched_genes_by_symbol
                      <int>                   <int>
1:                       24                       0
2:                       21                       0
3:                      125                       0
4:                       32                       0
5:                      100                       0
   missing_genes_after_ensembl_mapping
                                 <int>
1:                                   1
2:                                   0
3:                                   3
4:                                   1
5:                                   6
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          matched_symbols_by_ensembl
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              <char>
1:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          EIF4EBP2;MRPL13;MRPL22;MRPS11;MRPS18C;RPL15;RPL17;RPL23;RPL26;RPL26L1;RPL27;RPL29;RPL31;RPL34;RPL9;RPLP0;RPS15A;RPS24;RPS27;RPS3A;RPS4Y1;RPS7;RPS9;UBA52
2:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           ATP5F1A;ATP5ME;ATP5MF;CAT;MDH2;MTFR2;NDUFA3;NDUFA4;NDUFAF1;NDUFAF2;NDUFAF6;NDUFAF7;NDUFAF8;NDUFB1;NDUFB3;NDUFC2;NDUFS4;NDUFV3;SLC25A14;TMEM126A;TMEM186
3: ACTA2;ADGRB1;APOBEC3B;APOBEC3F;APOBEC3H;ATP1B1;AXL;AZI2;BCL2;BLK;BNIP3L;C2;CARD9;CCL8;CD160;CD1D;CD40;CDK6;CLEC10A;CREBZF;CSF1;DDX17;DDX21;DDX3X;DDX60;DDX60L;DHX58;DTX3L;EIF2AK2;ENDOD1;FOXP3;G3BP1;G3BP2;GATA3;GBP1;GBP3;HERC5;IFI27;IFI35;IFI44;IFI44L;IFI6;IFIH1;IFIT1;IFIT1B;IFIT2;IFIT3;IFIT5;IFITM3;IL27;IPO7;IRF7;IRF9;ISG15;ISG20;KLRG1;LILRA4;LY9;MALT1;MATR3;MCOLN2;MEFV;MFHAS1;MICA;MID2;MOV10;MX1;MX2;N4BP3;NOD2;NT5C3A;OAS1;OAS2;OAS3;OASL;OTUD4;PARP14;PARP9;PIM2;PLD4;PLPP6;PLSCR1;PMAIP1;PML;POLR3E;PRDM1;PRF1;PRKRA;RIGI;RIPK2;RSAD2;RTP4;SAMD9;SERINC5;SERPING1;SH2D1B;SLFN11;SLFN13;SMPDL3B;SPON2;SRC;STAT1;STAT2;TANK;TICAM2;TLR3;TLR7;TNFSF4;TRAF4;TRIM14;TRIM22;TRIM32;TRIM35;TRIM38;TRIM5;TRIM52;TRIM6;UBE2L6;URI1;XPR1;ZBP1;ZBTB1;ZC3HAV1;ZCCHC3;ZMYND11
4:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 APOBEC3F;AZI2;DDX3X;EIF2AK2;FAM111A;IFI27;IFIH1;IFIT1;IFIT5;IFITM3;IRF7;ISG15;ISG20;MX1;OAS1;OAS2;OAS3;OASL;PLSCR1;PTPN11;RIGI;RIPK2;RSAD2;STAT1;STAT2;TANK;TLR3;TLR7;TOMM70;TRIM6;ZBTB20;ZC3HAV1
5:                                                                                                                                             ACKR3;AIRE;BMP6;BMPR1A;BTN2A1;BTN2A2;BTN3A1;CARD9;CASP8;CBLB;CCL28;CCR1;CCR2;CCR3;CCR4;CCR5;CCR6;CCR7;CCR9;CCRL2;CD164;CD1D;CD80;CD96;CMKLR1;CR2;CTSL;CXCR5;CYSLTR2;ELF1;ENPP1;ERMAP;ETS1;EXOSC9;FAS;FCGR2B;FCGR3A;FCGR3B;GATA3;GPR183;HIC2;ICOS;ICOSLG;IFI44;IFI44L;IFI6;IFITM3;IGF2BP3;IL15;IL1RN;IL2RA;IL7R;JPH4;KIR2DL1;KIR3DL1;LAX1;LIF;MARCHF1;MICA;MS4A2;NOD2;P2RX7;PANX1;PATZ1;PIK3R1;PRKRA;PTGER4;RGS1;RIPK2;SERPINB9;SIRT1;SMAD3;SOCS1;SPON2;TCF12;TCF7;TGFBR3;TLR3;TLR7;TNFRSF4;TNFSF10;TNFSF15;TNFSF4;TNFSF8;TNFSF9;TRIM22;VPREB3;ZBTB1;ZBTB2;ZBTB20;ZBTB25;ZBTB26;ZBTB33;ZBTB37;ZBTB39;ZBTB49;ZBTB6;ZNF131;ZNF134;ZNF572
           missing_symbols_after_ensembl_mapping coverage_pct_by_ensembl
                                          <char>                   <num>
1:                                        HYDIN2                   96.00
2:                                                                100.00
3:                               DEFB1;FRK;TREX1                   97.66
4:                                         TREX1                   96.97
5: BTN2A3P;DEFB1;KIR2DS1;KIR2DS2;KIR2DS5;KIR3DS1                   94.34
   coverage_pct_by_symbol projection_eligible_50pct projection_eligible_70pct
                    <num>                    <lgcl>                    <lgcl>
1:                      0                      TRUE                      TRUE
2:                      0                      TRUE                      TRUE
3:                      0                      TRUE                      TRUE
4:                      0                      TRUE                      TRUE
5:                      0                      TRUE                      TRUE

## Interpretation boundary

- This audit checks whether locked GSE211567 module genes can be found in GSE161731 after mapping locked ENTREZID values to ENSEMBL IDs.
- GSE161731 remains a technical projection rehearsal resource, not formal validation.
- No module scores or biological claims are produced here.
- If coverage is adequate, the next step may be technical module-score rehearsal using fixed GSE211567 modules and unweighted mean z-score scoring.

## Generated files

- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_expression_identifier_pattern_summary.tsv`
- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_module_gene_ensembl_mapping_long.tsv`
- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_gene_level_identifier_match_table.tsv`
- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_module_ensembl_coverage.tsv`
- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_matched_module_genes_by_ensembl.tsv`
- `results/module_projection_rehearsal/GSE161731_identifier_coverage_audit/GSE161731_projection_rehearsal_missing_module_genes_after_ensembl_mapping.tsv`
- `env/session_info/GSE161731_module_projection_identifier_coverage_audit_sessionInfo.txt`
