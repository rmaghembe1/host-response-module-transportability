# GSE211567 GO BP Redundancy Reduction and Overlap-Gene Inspection Report

- Generated: 2026-05-31 14:22:06 EAT
- Purpose: reduce redundant enriched GO Biological Process terms into candidate term groups using overlap-gene similarity.
- Method: enriched GO BP terms at BH FDR < 0.10 were grouped greedily by overlap-gene Jaccard similarity using cutoff 0.25.
- Boundary: candidate grouping only. This step does not assign final module names and does not make manuscript-level biological claims.

## Input enriched GO BP terms

- Enriched GO BP terms at BH FDR < 0.10 retained for grouping: 43
- Bacterial-higher enriched terms retained: 8
- Viral-higher enriched terms retained: 35

## Candidate group summary

                          direction_set candidate_groups total_terms_in_groups
                                 <char>            <int>                 <int>
1: bacterial_higher_site_aware_eligible                4                     8
2:     viral_higher_site_aware_eligible               31                    35
   FDR05_terms_in_groups median_unique_overlap_genes_per_group
                   <int>                                 <num>
1:                     7                                    16
2:                    23                                    19
   max_unique_overlap_genes_per_group
                                <int>
1:                                 25
2:                                214

## Candidate groups

                           direction_set           candidate_group_id
                                  <char>                       <char>
 1: bacterial_higher_site_aware_eligible Bacterial_higher_GO_group_01
 2: bacterial_higher_site_aware_eligible Bacterial_higher_GO_group_03
 3: bacterial_higher_site_aware_eligible Bacterial_higher_GO_group_02
 4: bacterial_higher_site_aware_eligible Bacterial_higher_GO_group_04
 5:     viral_higher_site_aware_eligible     Viral_higher_GO_group_01
 6:     viral_higher_site_aware_eligible     Viral_higher_GO_group_02
 7:     viral_higher_site_aware_eligible     Viral_higher_GO_group_03
 8:     viral_higher_site_aware_eligible     Viral_higher_GO_group_04
 9:     viral_higher_site_aware_eligible     Viral_higher_GO_group_05
10:     viral_higher_site_aware_eligible     Viral_higher_GO_group_06
11:     viral_higher_site_aware_eligible     Viral_higher_GO_group_08
12:     viral_higher_site_aware_eligible     Viral_higher_GO_group_07
13:     viral_higher_site_aware_eligible     Viral_higher_GO_group_09
14:     viral_higher_site_aware_eligible     Viral_higher_GO_group_10
15:     viral_higher_site_aware_eligible     Viral_higher_GO_group_12
16:     viral_higher_site_aware_eligible     Viral_higher_GO_group_11
17:     viral_higher_site_aware_eligible     Viral_higher_GO_group_13
18:     viral_higher_site_aware_eligible     Viral_higher_GO_group_15
19:     viral_higher_site_aware_eligible     Viral_higher_GO_group_14
20:     viral_higher_site_aware_eligible     Viral_higher_GO_group_16
21:     viral_higher_site_aware_eligible     Viral_higher_GO_group_18
22:     viral_higher_site_aware_eligible     Viral_higher_GO_group_17
23:     viral_higher_site_aware_eligible     Viral_higher_GO_group_19
24:     viral_higher_site_aware_eligible     Viral_higher_GO_group_20
25:     viral_higher_site_aware_eligible     Viral_higher_GO_group_21
26:     viral_higher_site_aware_eligible     Viral_higher_GO_group_22
27:     viral_higher_site_aware_eligible     Viral_higher_GO_group_23
28:     viral_higher_site_aware_eligible     Viral_higher_GO_group_27
29:     viral_higher_site_aware_eligible     Viral_higher_GO_group_26
30:     viral_higher_site_aware_eligible     Viral_higher_GO_group_24
31:     viral_higher_site_aware_eligible     Viral_higher_GO_group_25
32:     viral_higher_site_aware_eligible     Viral_higher_GO_group_29
33:     viral_higher_site_aware_eligible     Viral_higher_GO_group_28
34:     viral_higher_site_aware_eligible     Viral_higher_GO_group_30
35:     viral_higher_site_aware_eligible     Viral_higher_GO_group_31
                           direction_set           candidate_group_id
                                  <char>                       <char>
    representative_GO
               <char>
 1:        GO:0002181
 2:        GO:0032981
 3:        GO:0006749
 4:        GO:0006096
 5:        GO:0000122
 6:        GO:0045944
 7:        GO:0006355
 8:        GO:0051607
 9:        GO:0001817
10:        GO:0045893
11:        GO:0060326
12:        GO:0045071
13:        GO:0006955
14:        GO:0048167
15:        GO:0045892
16:        GO:0006338
17:        GO:0032092
18:        GO:0001756
19:        GO:0042113
20:        GO:0009617
21:        GO:0006468
22:        GO:0030890
23:        GO:0060907
24:        GO:0032728
25:        GO:0060337
26:        GO:0030509
27:        GO:0030183
28:        GO:0006366
29:        GO:0043123
30:        GO:0030501
31:        GO:0070371
32:        GO:0045945
33:        GO:0032743
34:        GO:0007165
35:        GO:0043491
    representative_GO
               <char>
                                                   representative_TERM
                                                                <char>
 1:                                            cytoplasmic translation
 2:                 mitochondrial respiratory chain complex I assembly
 3:                                      glutathione metabolic process
 4:                                                 glycolytic process
 5:          negative regulation of transcription by RNA polymerase II
 6:          positive regulation of transcription by RNA polymerase II
 7:                          regulation of DNA-templated transcription
 8:                                          defense response to virus
 9:                                  regulation of cytokine production
10:                 positive regulation of DNA-templated transcription
11:                                                    cell chemotaxis
12:                    negative regulation of viral genome replication
13:                                                    immune response
14:                                  regulation of synaptic plasticity
15:                 negative regulation of DNA-templated transcription
16:                                               chromatin remodeling
17:                             positive regulation of protein binding
18:                                                      somitogenesis
19:                                                  B cell activation
20:                                              response to bacterium
21:                                            protein phosphorylation
22:                        positive regulation of B cell proliferation
23:              positive regulation of macrophage cytokine production
24:                  positive regulation of interferon-beta production
25:                       type I interferon-mediated signaling pathway
26:                                              BMP signaling pathway
27:                                             B cell differentiation
28:                                 transcription by RNA polymerase II
29:     positive regulation of canonical NF-kappaB signal transduction
30:                         positive regulation of bone mineralization
31:                                              ERK1 and ERK2 cascade
32:         positive regulation of transcription by RNA polymerase III
33:                    positive regulation of interleukin-2 production
34:                                                signal transduction
35: phosphatidylinositol 3-kinase/protein kinase B signal transduction
                                                   representative_TERM
                                                                <char>
    representative_FDR n_terms n_FDR05_terms n_unique_overlap_genes
                 <num>   <int>         <int>                  <int>
 1:       3.386765e-07       2             2                     25
 2:       6.688775e-03       4             4                     21
 3:       6.688775e-03       1             1                     11
 4:       7.847965e-02       1             0                      7
 5:       5.096275e-09       1             1                    193
 6:       7.704956e-09       1             1                    214
 7:       4.882673e-08       1             1                    130
 8:       1.073283e-06       3             3                    128
 9:       5.379654e-04       1             1                     27
10:       8.687155e-04       1             1                    127
11:       1.993818e-03       2             1                     32
12:       1.993818e-03       1             1                     18
13:       6.494481e-03       1             1                     70
14:       7.236807e-03       1             1                     14
15:       3.200868e-02       1             1                     99
16:       3.200868e-02       1             1                     67
17:       3.200868e-02       1             1                     15
18:       3.200868e-02       1             1                     13
19:       3.200868e-02       1             1                     12
20:       3.824953e-02       1             1                     26
21:       4.884926e-02       1             1                     75
22:       4.884926e-02       1             1                     16
23:       4.884926e-02       1             1                      9
24:       4.919941e-02       1             1                     14
25:       4.919941e-02       1             1                     10
26:       5.436291e-02       1             0                     18
27:       7.313926e-02       1             0                     19
28:       8.058579e-02       1             0                     45
29:       8.058579e-02       1             0                     37
30:       8.058579e-02       1             0                     13
31:       8.058579e-02       1             0                     13
32:       8.058579e-02       2             0                     13
33:       8.058579e-02       1             0                     12
34:       8.727002e-02       1             0                    162
35:       8.727002e-02       1             0                     19
    representative_FDR n_terms n_FDR05_terms n_unique_overlap_genes
                 <num>   <int>         <int>                  <int>
                                                                                                                                                                                                                                         top_overlap_symbols
                                                                                                                                                                                                                                                      <char>
 1:                                                                                          RPS15A;RPS3A;RPS9;RPL27;RPL26L1;RPLP0;RPS7;RPL23;RPS27;RPL15;RPL9;RPL31;RPL17;RPL34;RPS24;RPL29;MRPL22;RPS4Y1;MRPL13;MRPS18C;UBA52;RPL26;MRPS11;EIF4EBP2;HYDIN2
 2:                                                                                                  NDUFB1;NDUFA4;ATP5MF;NDUFC2;ATP5ME;NDUFAF1;NDUFB3;NDUFAF8;MDH2;NDUFA3;ATP5F1A;NDUFAF2;NDUFS4;NDUFAF7;TMEM186;MTFR2;TMEM126A;NDUFAF6;CAT;SLC25A14;NDUFV3
 3:                                                                                                                                                                                        OPLAH;GSTZ1;GSR;SOD2;GLRX2;GSTM4;SLC7A11;HAGH;ARL6IP5;GSTM5;GSTA4
 4:                                                                                                                                                                                                                    IER3;PGM1;ALDOA;GPI;PFKFB2;ENO3;PGAM2
 5:      IFI27;HESX1;ZNF684;IRF7;SMAD3;PAX5;FLCN;NFX1;TFEC;KLF12;ZNF366;KLF11;BACH2;PARP9;KDM2B;GATA2;TGIF1;ZNF550;STAT1;MAFB;NRIP1;ZNF136;NSMCE3;CREM;ZNF274;CPEB3;DNAJB4;ZNF224;ZNF440;PATZ1;NR1D2;MYC;ZNF124;SMAD7;ZNF439;LEF1;ZNF337;ZNF350;MAGEE1;MEF2C
 6:                        AGRN;JUP;IL4I1;TLR7;MAML2;HELZ2;RIGI;LIF;IRF7;SMAD3;TLR3;NCOA7;PAX5;FLCN;LPIN2;BMPR2;STAT2;ZNF600;PLSCR1;DLL1;MYBL1;TNFSF8;ELF1;TFEC;CXCL10;GPBP1;TCF4;KLF6;LPIN1;TXK;GATA2;UBP1;STAT1;MAFB;ZNF33B;NRIP1;ZFP64;ZNF841;CREM;MLLT10
 7: SMAD3;TRIM22;ZNF702P;BRCA2;SPIN3;GPBP1;ZNF146;PML;ZNF506;MAFB;KMT2E;PDE8A;CREM;ZNF331;ATF5;ZNF274;ZNF736;TCF7;PATZ1;ZSCAN26;NR1D2;ZNF92;TAF5L;ZNF235;ZNF350;MEF2C;NCOA2;ZNF45;ZBTB38;ZZZ3;ZNF284;FOXC1;POLR2M;AHDC1;ZNF223;PRKCQ;AIRE;ZNF738;DMTF1;SPIN1
 8:                        IFI27;IFIT1;OAS2;RSAD2;AXL;OAS3;CCL8;IFIT2;IFI44L;MX1;IFIT3;OASL;TRIM14;ISG15;IFI44;HERC5;EIF2AK2;ZBP1;DHX58;OAS1;TRIM5;SAMD9;TLR7;IFIT5;DDX60;RIGI;IFIH1;MX2;NT5C3A;RTP4;DEFB1;TREX1;IRF7;TLR3;BCL2;MOV10;PMAIP1;TRIM6;STAT2;SRC
 9:                                                                         BTN2A2;BTN3A1;ELF1;JPH4;ICOSLG;SOCS1;PATZ1;ZBTB39;HIC2;GATA3;BTN2A3P;ZBTB25;ZBTB1;ZNF131;ZBTB20;CASP8;ZBTB26;ZNF134;ZBTB6;ZBTB33;IGF2BP3;ZNF572;ZBTB49;ZBTB2;ZBTB37;ERMAP;BTN2A1
10:                        TRIM14;TRIM5;IRF7;SMAD3;HAS3;TRIM22;MYBL1;TRIM38;DTX3L;BRCA2;MDK;ELF1;TCF4;KLF6;PARP9;ZNF496;STAT1;MAFB;MGA;CD80;KMT2E;ATF5;RGMB;ATXN7;KANSL2;CEP290;RRN3;PATZ1;NR1D2;ATMIN;MYC;TAF5L;ETS1;LEF1;MDFIC;FOS;MEF2C;ACVR1;KANSL3;FLI1
11:                                                                  EPHB1;P2RY12;CCR1;CCR3;CCR9;GRIN2D;CCL28;C5;EIF2AK3;PDGFRB;CCR7;LEF1;RCAN3;PDGFB;CCRL2;PRKCQ;CCR6;CCR4;ACKR3;CCN3;CCR5;HBEGF;DOCK4;CXCL8;FCGR3A;CD3E;CXCR5;CCR2;CCL3;AVPR1A;RCAN1;CHRM3
12:                                                                                                                                         IFIT1;OAS2;RSAD2;OAS3;MX1;OASL;ISG15;EIF2AK2;OAS1;IFIT5;IFIH1;TRIM6;PLSCR1;ISG20;ZC3HAV1;APOBEC3F;IFITM3;FAM111A
13:           IFI44L;IFI44;CMKLR1;LIF;DEFB1;TNFSF10;SMAD3;IL7R;TRIM22;TNFSF8;CCR1;CYSLTR2;IFI6;CCR3;CCR9;CD80;CCL28;IL1RN;CTSL;TCF7;CCR7;CD1D;ETS1;MARCHF1;LAX1;TCF12;FCGR2B;CCRL2;AIRE;CCR6;GPR183;MS4A2;IL15;RGS1;KIR2DS2;CCR4;KIR2DL1;BMP6;EXOSC9;KIR3DS1
14:                                                                                                                                                                     RIMS3;JPH4;GRIN2D;CPEB3;MEF2C;BAIAP2;SLC38A1;SCT;ACE;PLK2;RAPGEF2;MAP1A;UBE3A;ADGRB1
15:           HIRA;TRIM6;TRIM22;SFMBT2;BAHD1;ARK2N;PRICKLE1;PML;PARP14;WWP1;ZNF256;KCTD1;ATF5;ZNF224;PHC1;TCF7;PATZ1;NR1D2;TOB2;LEF1;MDFIC;ZNF350;ZBTB38;HIC2;PDGFB;GATA3;LBH;SOX8;SETDB2;MDM4;ZBTB14;BCOR;CD38;ZNF253;CLOCK;SCML1;ZNF540;TOB1;PRDM11;ZBTB21
16:      HIRA;BRCA2;KDM2B;KDM6A;ZNF274;PHC1;MYC;DCAF1;SLFN11;GATA3;BMI1;KDM4C;RAD54L2;BCOR;CLOCK;SATB1;ERCC6;BRD1;IRF4;ZBTB1;ZNF827;TAF1;SMARCAD1;ARID1B;BCL7A;RPS6KA5;YEATS2;JMJD1C;BAZ2B;MYSM1;DYRK1A;KAT2B;PWWP2A;WAC;SRCAP;CHD1;INO80D;BICRAL;CHD9;SMYD2
17:                                                                                                                                                                  DTX3L;EPB41;CAPRIN2;CLDN5;TIAM1;TAF1;NMD3;STK4;ADD2;HIP1R;USP33;BAMBI;RIPK2;RAPGEF2;BLK
18:                                                                                                                                                                            SMAD3;DLL1;AXIN2;LEF1;FOXC1;POGLUT1;BMPR1A;NKX3-1;PALB2;LFNG;POFUT1;MIB1;TP53
19:                                                                                                                                                                                 EPHB2;MS4A1;ICOSLG;LAX1;RASGRP1;BANK1;MALT1;CASP8;CD79A;TXLNA;CXCR5;CD40
20:                                                                                                  USP18;HERC6;CCL2;TMEM255A;IFI44;DHX58;TENT5A;DEFB1;PRLR;TMEM229B;MS4A1;C2;CFB;ERAP1;FCGR2B;CEP192;RGS1;CCR4;CUBN;BANK1;IKZF3;WASL;ABCD2;VIL1;PLAAT3;CFD
21:                 CCL2;EPHB2;EIF2AK2;CDK18;PRKAG2;EPHB1;BMPR2;SRC;LOC102724428;GRK5;CDK17;SIK1;AKT3;PRKCE;PRAG1;NEK3;TXK;ITK;TNIK;ERBB2;EPHA4;IGFBP3;EIF2AK3;FER;ACVR1;FNIP2;PDGFB;MYLK;PRKACB;ATR;PRKCH;PRKCQ;ACVR2A;PRKD3;SGK1;TAF1;PKN2;PDK4;VRK2;CDKL1
22:                                                                                                                                                   EPHB2;CDKN1A;BCL2;PRLR;MEF2C;BMI1;PELI1;CLCF1;GPR183;CD38;TNFRSF13C;TNFSF13B;NFATC2;FCRL3;TNFRSF4;CD40
23:                                                                                                                                                                                                       TLR7;TLR3;PANX1;P2RX7;NOD2;SIRT1;SPON2;RIPK2;CARD9
24:                                                                                                                                                                          OAS2;OAS3;ISG15;OAS1;TLR7;RIGI;IFIH1;IRF7;TLR3;DDX3X;ZBTB20;TOMM70;RIPK2;PTPN11
25:                                                                                                                                                                                                 IFI27;OAS2;IFIH1;TREX1;IRF7;STAT2;STAT1;AZI2;TANK;IFITM3
26:                                                                                                                                               BMPR2;SMPD3;RGMB;LEF1;ACVR1;ACVR2A;SPART;HIVEP1;BMP6;RUNX2;PDCD4;EGR1;BMPR1A;TGFBR3;ACVR2B;ATF2;FAM83G;NOG
27:                                                                                                                                             BLNK;PAX5;KLF6;MS4A1;DCAF1;ITGA4;CLCF1;CD40LG;ZBTB1;CR2;TNFSF13B;PIK3R1;IKZF3;CD79A;TPD52;YY1;MSH2;ITGB1;SP3
28:               TSC22D1;PAX5;NFX1;GATA2;TAF5L;LEF1;FOS;GATA3;ETV7;AIRE;BCL11B;MAF;ERCC6;TAF1;TAF1A;GTF2E1;THRA;ZNF345;ZNF141;ATXN1L;ELL3;PIK3R1;NFE2L3;NFATC2;RPAP1;CD28;KLF4;GTF2I;RBMX;NR4A1;FOSB;RREB1;MED20;NFIX;ABLIM3;CCNT2;DDX21;SUPT3H;PAXBP1;TAF4
29:                          TRIM5;IFIT5;TNFSF10;TLR3;TRIM6;TRIM22;TRIM38;PRKCE;CASP10;CLEC7A;BIRC3;CCR7;LGALS9;TAB2;FASLG;PELI1;EDAR;MALT1;TAB3;NOD2;MID2;CASP8;PIM2;TRIM32;PELI2;PLK2;TRIM52;BIRC2;TICAM2;UNC5CL;RIPK2;DDX21;MIER1;CD40;ATP2C1;CXXC5;CARD9
30:                                                                                                                                                                         ISG15;TENT5A;SMAD3;BMPR2;P2RX7;MEF2C;ACVR1;ACVR2A;ATP2B1;ANO6;BMP6;BMPR1A;ACVR2B
31:                                                                                                                                                                             HESX1;BTN2A2;FLCN;DUSP5;DUSP6;ZFP36L2;MYC;LGALS9;EGF;PTGER4;NOD2;DUSP7;RIPK2
32:                                                                                                                                                                            ERBB2;ICE2;EIF2AK3;ERCC6;ICE1;ZC3H8;WDR75;MYBBP1A;DDX21;WDR43;SF3B1;UTP15;DEK
33:                                                                                                                                                                                      CD83;CD80;CLEC7A;PDE4B;PRKCQ;IRF4;MALT1;CD28;CD3E;RIPK2;CCR2;SPTBN1
34:                CCL2;AGRN;AXL;CCL8;MX1;FPR3;HSH2D;SRGAP2;LGALS3BP;TNFSF10;TLR3;IL7R;CD2AP;ADCY9;SRC;CD83;TNFSF8;MDK;CXCL10;TAGAP;AKT3;PRKCE;NR3C2;CXCL11;IRS1;WWP1;ITK;ICOSLG;CCL28;PDE8A;CREM;RGMB;CD226;ERBB2;CLCN6;IL1RN;RTKN2;ARHGAP23;PDGFRB;EDARADD
35:                                                                                                                                    AXL;BTN2A2;FLCN;IRS1;SMPD3;ERBB2;PEAR1;PLEKHA1;GATA3;BANK1;PIK3R1;PIK3C2B;CD28;CD160;ADTRP;FCGR3A;NKX3-1;RPS6KB1;CD40
                                                                                                                                                                                                                                         top_overlap_symbols
                                                                                                                                                                                                                                                      <char>

## Interpretation boundary

- Candidate groups are redundancy-reduced GO-term clusters.
- Candidate groups are not yet final biological modules.
- Final module naming requires review of member GO terms, overlap genes, directionality and cross-site stability.

## Generated files

- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_term_groups.tsv`
- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_term_membership.tsv`
- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_term_pairwise_jaccard_similarity.tsv`
- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_overlap_genes_long.tsv`
- `results/module_lock/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_redundancy_reduction_summary.tsv`
- `results/figures/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_term_counts.png/.pdf`
- `results/figures/GSE211567_GO_BP_redundancy_reduction/GSE211567_GO_BP_candidate_group_gene_counts.png/.pdf`
- `env/session_info/GSE211567_GO_BP_redundancy_reduction_overlap_inspection_sessionInfo.txt`
