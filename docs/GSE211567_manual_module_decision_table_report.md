# GSE211567 Manual Candidate-Module Review Decision Report

- Generated: 2026-05-31 14:43:22 EAT
- Purpose: classify provisional candidate modules into primary, secondary, contextual or deferred manual-review tiers.
- Boundary: this is a controlled review-decision table. It is not final manuscript interpretation and does not constitute external validation.

## Decision summary

              review_decision_tier    module_direction n_module_rows
                            <char>              <char>         <int>
1: contextual_or_borderline_module higher_in_bacterial             1
2: contextual_or_borderline_module     higher_in_viral             7
3:        primary_candidate_module higher_in_bacterial             2
4:        primary_candidate_module     higher_in_viral             3
5:      secondary_candidate_module higher_in_bacterial             1
6:      secondary_candidate_module     higher_in_viral             4
   total_GO_terms FDR05_GO_terms median_unique_overlap_genes
            <int>          <int>                       <num>
1:              1              0                         7.0
2:             15              4                        27.0
3:              6              6                        23.0
4:              9              9                       106.0
5:              1              1                        11.0
6:             11             10                        53.5
   max_unique_overlap_genes
                      <int>
1:                        7
2:                      230
3:                       25
4:                      128
5:                       11
6:                      531

## Compact decision table

               review_decision_tier    module_direction
                             <char>              <char>
 1:        primary_candidate_module higher_in_bacterial
 2:        primary_candidate_module higher_in_bacterial
 3:        primary_candidate_module     higher_in_viral
 4:        primary_candidate_module     higher_in_viral
 5:        primary_candidate_module     higher_in_viral
 6:      secondary_candidate_module higher_in_bacterial
 7:      secondary_candidate_module     higher_in_viral
 8:      secondary_candidate_module     higher_in_viral
 9:      secondary_candidate_module     higher_in_viral
10:      secondary_candidate_module     higher_in_viral
11: contextual_or_borderline_module higher_in_bacterial
12: contextual_or_borderline_module     higher_in_viral
13: contextual_or_borderline_module     higher_in_viral
14: contextual_or_borderline_module     higher_in_viral
15: contextual_or_borderline_module     higher_in_viral
16: contextual_or_borderline_module     higher_in_viral
17: contextual_or_borderline_module     higher_in_viral
18: contextual_or_borderline_module     higher_in_viral
                                           provisional_module_label
                                                             <char>
 1:           Cytoplasmic translation / ribosomal protein programme
 2: Mitochondrial respiration / oxidative phosphorylation programme
 3:                       Antiviral / interferon-response programme
 4:                 Cytokine and innate immune regulation programme
 5:                       Antiviral / interferon-response programme
 6:                        Glutathione / redox metabolism programme
 7:              Transcriptional and chromatin-regulatory programme
 8:                  Chemotaxis / immune-cell trafficking programme
 9:                   B-cell / adaptive immune activation programme
10:                  NF-kB / kinase / signal-transduction programme
11:                                    Glycolytic process programme
12:                Contextual developmental/tissue-regulatory terms
13:              Other viral-higher regulatory/contextual programme
14:                  NF-kB / kinase / signal-transduction programme
15:                   B-cell / adaptive immune activation programme
16:                Contextual developmental/tissue-regulatory terms
17:                 Cytokine and innate immune regulation programme
18:              Transcriptional and chromatin-regulatory programme
             evidence_grade total_GO_terms FDR05_GO_terms
                     <char>          <int>          <int>
 1:     A_strong_GO_support              2              2
 2:     A_strong_GO_support              4              4
 3:     A_strong_GO_support              3              3
 4:   B_moderate_GO_support              3              3
 5:   B_moderate_GO_support              3              3
 6:   B_moderate_GO_support              1              1
 7:   B_moderate_GO_support              6              6
 8:   B_moderate_GO_support              2              1
 9:   B_moderate_GO_support              2              2
10:   B_moderate_GO_support              1              1
11: C_borderline_GO_support              1              0
12:   B_moderate_GO_support              2              2
13:   B_moderate_GO_support              2              2
14: C_borderline_GO_support              5              0
15: C_borderline_GO_support              1              0
16: C_borderline_GO_support              1              0
17: C_borderline_GO_support              1              0
18: C_borderline_GO_support              3              0
    unique_overlap_genes_across_groups     best_FDR
                                 <int>        <num>
 1:                                 25 3.386765e-07
 2:                                 21 6.688775e-03
 3:                                128 1.073283e-06
 4:                                106 5.379654e-04
 5:                                 33 1.993818e-03
 6:                                 11 6.688775e-03
 7:                                531 5.096275e-09
 8:                                 32 1.993818e-03
 9:                                 26 3.200868e-02
10:                                 75 4.884926e-02
11:                                  7 7.847965e-02
12:                                 27 7.236807e-03
13:                                 41 3.200868e-02
14:                                230 5.436291e-02
15:                                 19 7.313926e-02
16:                                 13 8.058579e-02
17:                                 12 8.058579e-02
18:                                 55 8.058579e-02
                                                                                                                                                                                                                                                                                  representative_terms
                                                                                                                                                                                                                                                                                                <char>
 1:                                                                                                                                                                                                                                                                            cytoplasmic translation
 2:                                                                                                                                                                                                                                                 mitochondrial respiratory chain complex I assembly
 3:                                                                                                                                                                                                                                                                          defense response to virus
 4:                                                                                                                                                                                        regulation of cytokine production | immune response | positive regulation of macrophage cytokine production
 5:                                                                                                                                                 negative regulation of viral genome replication | positive regulation of interferon-beta production | type I interferon-mediated signaling pathway
 6:                                                                                                                                                                                                                                                                      glutathione metabolic process
 7: negative regulation of transcription by RNA polymerase II | positive regulation of transcription by RNA polymerase II | regulation of DNA-templated transcription | positive regulation of DNA-templated transcription | negative regulation of DNA-templated transcription | chromatin remodeling
 8:                                                                                                                                                                                                                                                                                    cell chemotaxis
 9:                                                                                                                                                                                                                                    B cell activation | positive regulation of B cell proliferation
10:                                                                                                                                                                                                                                                                            protein phosphorylation
11:                                                                                                                                                                                                                                                                                 glycolytic process
12:                                                                                                                                                                                                                                                  regulation of synaptic plasticity | somitogenesis
13:                                                                                                                                                                                                                                     positive regulation of protein binding | response to bacterium
14:                                                                                          BMP signaling pathway | positive regulation of canonical NF-kappaB signal transduction | ERK1 and ERK2 cascade | signal transduction | phosphatidylinositol 3-kinase/protein kinase B signal transduction
15:                                                                                                                                                                                                                                                                             B cell differentiation
16:                                                                                                                                                                                                                                                         positive regulation of bone mineralization
17:                                                                                                                                                                                                                                                    positive regulation of interleukin-2 production
18:                                                                                                                                                                                                    transcription by RNA polymerase II | positive regulation of transcription by RNA polymerase III
                                                                                                                                                                                                                                                                                                        top_symbols_union
                                                                                                                                                                                                                                                                                                                   <char>
 1:                                                                                                                                                       RPS15A;RPS3A;RPS9;RPL27;RPL26L1;RPLP0;RPS7;RPL23;RPS27;RPL15;RPL9;RPL31;RPL17;RPL34;RPS24;RPL29;MRPL22;RPS4Y1;MRPL13;MRPS18C;UBA52;RPL26;MRPS11;EIF4EBP2;HYDIN2
 2:                                                                                                                                                               NDUFB1;NDUFA4;ATP5MF;NDUFC2;ATP5ME;NDUFAF1;NDUFB3;NDUFAF8;MDH2;NDUFA3;ATP5F1A;NDUFAF2;NDUFS4;NDUFAF7;TMEM186;MTFR2;TMEM126A;NDUFAF6;CAT;SLC25A14;NDUFV3
 3:                                                                                     IFI27;IFIT1;OAS2;RSAD2;AXL;OAS3;CCL8;IFIT2;IFI44L;MX1;IFIT3;OASL;TRIM14;ISG15;IFI44;HERC5;EIF2AK2;ZBP1;DHX58;OAS1;TRIM5;SAMD9;TLR7;IFIT5;DDX60;RIGI;IFIH1;MX2;NT5C3A;RTP4;DEFB1;TREX1;IRF7;TLR3;BCL2;MOV10;PMAIP1;TRIM6;STAT2;SRC
 4: BTN2A2;BTN3A1;ELF1;JPH4;ICOSLG;SOCS1;PATZ1;ZBTB39;HIC2;GATA3;BTN2A3P;ZBTB25;ZBTB1;ZNF131;ZBTB20;CASP8;ZBTB26;ZNF134;ZBTB6;ZBTB33;IGF2BP3;ZNF572;ZBTB49;ZBTB2;ZBTB37;ERMAP;BTN2A1;IFI44L;IFI44;CMKLR1;LIF;DEFB1;TNFSF10;SMAD3;IL7R;TRIM22;TNFSF8;CCR1;CYSLTR2;IFI6;CCR3;CCR9;CD80;CCL28;IL1RN;CTSL;TCF7;CCR7;CD1D;ETS1
 5:                                                                                                               IFIT1;OAS2;RSAD2;OAS3;MX1;OASL;ISG15;EIF2AK2;OAS1;IFIT5;IFIH1;TRIM6;PLSCR1;ISG20;ZC3HAV1;APOBEC3F;IFITM3;FAM111A;TLR7;RIGI;IRF7;TLR3;DDX3X;ZBTB20;TOMM70;RIPK2;PTPN11;IFI27;TREX1;STAT2;STAT1;AZI2;TANK
 6:                                                                                                                                                                                                                                                     OPLAH;GSTZ1;GSR;SOD2;GLRX2;GSTM4;SLC7A11;HAGH;ARL6IP5;GSTM5;GSTA4
 7:               IFI27;HESX1;ZNF684;IRF7;SMAD3;PAX5;FLCN;NFX1;TFEC;KLF12;ZNF366;KLF11;BACH2;PARP9;KDM2B;GATA2;TGIF1;ZNF550;STAT1;MAFB;NRIP1;ZNF136;NSMCE3;CREM;ZNF274;CPEB3;DNAJB4;ZNF224;ZNF440;PATZ1;NR1D2;MYC;ZNF124;SMAD7;ZNF439;LEF1;ZNF337;ZNF350;MAGEE1;MEF2C;AGRN;JUP;IL4I1;TLR7;MAML2;HELZ2;RIGI;LIF;TLR3;NCOA7
 8:                                                                                                                               EPHB1;P2RY12;CCR1;CCR3;CCR9;GRIN2D;CCL28;C5;EIF2AK3;PDGFRB;CCR7;LEF1;RCAN3;PDGFB;CCRL2;PRKCQ;CCR6;CCR4;ACKR3;CCN3;CCR5;HBEGF;DOCK4;CXCL8;FCGR3A;CD3E;CXCR5;CCR2;CCL3;AVPR1A;RCAN1;CHRM3
 9:                                                                                                                                                  EPHB2;MS4A1;ICOSLG;LAX1;RASGRP1;BANK1;MALT1;CASP8;CD79A;TXLNA;CXCR5;CD40;CDKN1A;BCL2;PRLR;MEF2C;BMI1;PELI1;CLCF1;GPR183;CD38;TNFRSF13C;TNFSF13B;NFATC2;FCRL3;TNFRSF4
10:                                                                              CCL2;EPHB2;EIF2AK2;CDK18;PRKAG2;EPHB1;BMPR2;SRC;LOC102724428;GRK5;CDK17;SIK1;AKT3;PRKCE;PRAG1;NEK3;TXK;ITK;TNIK;ERBB2;EPHA4;IGFBP3;EIF2AK3;FER;ACVR1;FNIP2;PDGFB;MYLK;PRKACB;ATR;PRKCH;PRKCQ;ACVR2A;PRKD3;SGK1;TAF1;PKN2;PDK4;VRK2;CDKL1
11:                                                                                                                                                                                                                                                                                 IER3;PGM1;ALDOA;GPI;PFKFB2;ENO3;PGAM2
12:                                                                                                                                                    RIMS3;JPH4;GRIN2D;CPEB3;MEF2C;BAIAP2;SLC38A1;SCT;ACE;PLK2;RAPGEF2;MAP1A;UBE3A;ADGRB1;SMAD3;DLL1;AXIN2;LEF1;FOXC1;POGLUT1;BMPR1A;NKX3-1;PALB2;LFNG;POFUT1;MIB1;TP53
13:                                                                       DTX3L;EPB41;CAPRIN2;CLDN5;TIAM1;TAF1;NMD3;STK4;ADD2;HIP1R;USP33;BAMBI;RIPK2;RAPGEF2;BLK;USP18;HERC6;CCL2;TMEM255A;IFI44;DHX58;TENT5A;DEFB1;PRLR;TMEM229B;MS4A1;C2;CFB;ERAP1;FCGR2B;CEP192;RGS1;CCR4;CUBN;BANK1;IKZF3;WASL;ABCD2;VIL1;PLAAT3;CFD
14:          BMPR2;SMPD3;RGMB;LEF1;ACVR1;ACVR2A;SPART;HIVEP1;BMP6;RUNX2;PDCD4;EGR1;BMPR1A;TGFBR3;ACVR2B;ATF2;FAM83G;NOG;TRIM5;IFIT5;TNFSF10;TLR3;TRIM6;TRIM22;TRIM38;PRKCE;CASP10;CLEC7A;BIRC3;CCR7;LGALS9;TAB2;FASLG;PELI1;EDAR;MALT1;TAB3;NOD2;MID2;CASP8;PIM2;TRIM32;PELI2;PLK2;TRIM52;BIRC2;TICAM2;UNC5CL;RIPK2;DDX21
15:                                                                                                                                                                                                          BLNK;PAX5;KLF6;MS4A1;DCAF1;ITGA4;CLCF1;CD40LG;ZBTB1;CR2;TNFSF13B;PIK3R1;IKZF3;CD79A;TPD52;YY1;MSH2;ITGB1;SP3
16:                                                                                                                                                                                                                                      ISG15;TENT5A;SMAD3;BMPR2;P2RX7;MEF2C;ACVR1;ACVR2A;ATP2B1;ANO6;BMP6;BMPR1A;ACVR2B
17:                                                                                                                                                                                                                                                   CD83;CD80;CLEC7A;PDE4B;PRKCQ;IRF4;MALT1;CD28;CD3E;RIPK2;CCR2;SPTBN1
18:              TSC22D1;PAX5;NFX1;GATA2;TAF5L;LEF1;FOS;GATA3;ETV7;AIRE;BCL11B;MAF;ERCC6;TAF1;TAF1A;GTF2E1;THRA;ZNF345;ZNF141;ATXN1L;ELL3;PIK3R1;NFE2L3;NFATC2;RPAP1;CD28;KLF4;GTF2I;RBMX;NR4A1;FOSB;RREB1;MED20;NFIX;ABLIM3;CCNT2;DDX21;SUPT3H;PAXBP1;TAF4;ERBB2;ICE2;EIF2AK3;ICE1;ZC3H8;WDR75;MYBBP1A;WDR43;SF3B1;UTP15
                                                                                                                                                          review_decision_rationale
                                                                                                                                                                             <char>
 1:                                                                                   Compact and coherent bacterial-higher translation/ribosomal programme with strong GO support.
 2:                                                     Compact and coherent bacterial-higher mitochondrial respiration/oxidative phosphorylation programme with strong GO support.
 3:                                                            Coherent viral-higher antiviral/interferon programme with strong/moderate GO support and recognizable overlap genes.
 4:                                                                  Viral-higher cytokine/innate immune regulation programme with sufficient GO support for primary manual review.
 5:                                                            Coherent viral-higher antiviral/interferon programme with strong/moderate GO support and recognizable overlap genes.
 6:                                    Biologically plausible bacterial-higher redox/glutathione programme, but represented by a single GO group and should be reviewed cautiously.
 7: Large viral-higher transcription/chromatin regulatory programme; likely real but broad and should not be overinterpreted as a single mechanistic module without further review.
 8:                                                Viral-higher chemotaxis/immune-cell trafficking signal is plausible but represented by limited GO evidence; retain as secondary.
 9:                 Viral-higher B-cell/adaptive activation programme is biologically plausible but should be reviewed as secondary because support is split across compact groups.
10:                                                      Viral-higher kinase/NF-kB/signal-transduction evidence is plausible but broad; retain as secondary/manual-review evidence.
11:                                              Bacterial-higher glycolytic evidence is borderline and represented by a small single GO group; retain as contextual evidence only.
12:                                         Developmental/tissue-regulatory terms may reflect annotation pleiotropy or broad immune-regulatory genes; do not use as primary claims.
13:                                         Developmental/tissue-regulatory terms may reflect annotation pleiotropy or broad immune-regulatory genes; do not use as primary claims.
14:                                                                           Borderline GO support; retain only as contextual evidence unless strengthened by additional evidence.
15:                                                                           Borderline GO support; retain only as contextual evidence unless strengthened by additional evidence.
16:                                         Developmental/tissue-regulatory terms may reflect annotation pleiotropy or broad immune-regulatory genes; do not use as primary claims.
17:                                                                           Borderline GO support; retain only as contextual evidence unless strengthened by additional evidence.
18:                                                                           Borderline GO support; retain only as contextual evidence unless strengthened by additional evidence.
                                               final_claim_status
                                                           <char>
 1: eligible_for_primary_manual_biological_review_not_final_claim
 2: eligible_for_primary_manual_biological_review_not_final_claim
 3: eligible_for_primary_manual_biological_review_not_final_claim
 4: eligible_for_primary_manual_biological_review_not_final_claim
 5: eligible_for_primary_manual_biological_review_not_final_claim
 6:               eligible_for_secondary_manual_biological_review
 7:               eligible_for_secondary_manual_biological_review
 8:               eligible_for_secondary_manual_biological_review
 9:               eligible_for_secondary_manual_biological_review
10:               eligible_for_secondary_manual_biological_review
11:          contextual_or_borderline_do_not_use_as_primary_claim
12:          contextual_or_borderline_do_not_use_as_primary_claim
13:          contextual_or_borderline_do_not_use_as_primary_claim
14:          contextual_or_borderline_do_not_use_as_primary_claim
15:          contextual_or_borderline_do_not_use_as_primary_claim
16:          contextual_or_borderline_do_not_use_as_primary_claim
17:          contextual_or_borderline_do_not_use_as_primary_claim
18:          contextual_or_borderline_do_not_use_as_primary_claim

## Interpretation boundary

- Primary candidate modules are eligible for manual biological review, not final manuscript claims.
- Secondary modules may support the biological narrative but require caution and further inspection.
- Contextual/borderline modules should not be used as primary claims.
- Deferred modules should not be prioritized unless strengthened by additional evidence.

## Generated files

- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_table.tsv`
- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_compact_table.tsv`
- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_summary.tsv`
- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_GO_term_membership.tsv`
- `results/module_lock/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_overlap_genes_long.tsv`
- `results/figures/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_tier_counts.png/.pdf`
- `results/figures/GSE211567_manual_module_decisions/GSE211567_manual_module_decision_overlap_gene_counts.png/.pdf`
- `env/session_info/GSE211567_manual_module_decision_table_sessionInfo.txt`
