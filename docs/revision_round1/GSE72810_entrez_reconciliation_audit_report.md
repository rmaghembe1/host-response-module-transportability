# GSE72810 Entrez reconciliation audit

## Mapping hierarchy

Exact locked-gene Entrez identifiers were treated as the authoritative mapping. Exact-symbol probes were accepted only when no Entrez-matched probe existed and the platform probe had no Entrez annotation. Synonym-only probes assigned to another Entrez gene were rejected.

## Reconciled module coverage

```text
   final_module_id locked_gene_count mapped_gene_count missing_gene_count
            <char>             <int>             <int>              <int>
1:         BACT_M1                25                24                  1
2:         BACT_M2                21                20                  1
3:         VIR_M1a               128               125                  3
4:         VIR_M1b                33                33                  0
5:          VIR_M2               106               101                  5
   coverage_fraction genes_rescued_by_entrez
               <num>                   <int>
1:         0.9600000                       0
2:         0.9523810                       6
3:         0.9765625                       6
4:         1.0000000                       2
5:         0.9528302                       6
                               rescued_symbols                 missing_symbols
                                        <char>                          <char>
1:                                        none                          HYDIN2
2: ATP5F1A;ATP5ME;ATP5MF;MTFR2;NDUFAF6;NDUFAF7                         NDUFAF8
3:        ADGRB1;IFIT1B;NT5C3A;PLPP6;RIGI;URI1              DDX60L;MICA;POLR3E
4:                                 RIGI;TOMM70                            none
5:    ACKR3;BTN2A3P;CTSL;GPR183;MARCHF1;ZBTB49 CCR2;CCRL2;KIR2DS2;KIR3DS1;MICA
   high_coverage_at_70_percent
                        <lgcl>
1:                        TRUE
2:                        TRUE
3:                        TRUE
4:                        TRUE
5:                        TRUE
```

## Symbol-only versus Entrez-reconciled coverage

```text
Key: <final_module_id>
   final_module_id symbol_only_locked_gene_count symbol_only_mapped_gene_count
            <char>                         <int>                         <int>
1:         BACT_M1                            25                            24
2:         BACT_M2                            21                            14
3:         VIR_M1a                           128                           120
4:         VIR_M1b                            33                            31
5:          VIR_M2                           106                            98
   symbol_only_missing_gene_count symbol_only_coverage_fraction
                            <int>                         <num>
1:                              1                     0.9600000
2:                              7                     0.6666667
3:                              8                     0.9375000
4:                              2                     0.9393939
5:                              8                     0.9245283
                              symbol_only_missing_symbols
                                                   <char>
1:                                                 HYDIN2
2:    ATP5F1A;ATP5ME;ATP5MF;MTFR2;NDUFAF6;NDUFAF7;NDUFAF8
3:     ADGRB1;DDX60L;IFIT1B;NT5C3A;PLPP6;POLR3E;RIGI;URI1
4:                                            RIGI;TOMM70
5: ACKR3;BTN2A3P;CCRL2;CTSL;GPR183;KIR3DS1;MARCHF1;ZBTB49
   entrez_reconciled_mapped_gene_count entrez_reconciled_missing_gene_count
                                 <int>                                <int>
1:                                  24                                    1
2:                                  20                                    1
3:                                 125                                    3
4:                                  33                                    0
5:                                 101                                    5
   entrez_reconciled_coverage_fraction genes_rescued_by_entrez
                                 <num>                   <int>
1:                           0.9600000                       0
2:                           0.9523810                       6
3:                           0.9765625                       6
4:                           1.0000000                       2
5:                           0.9528302                       6
                               rescued_symbols
                                        <char>
1:                                        none
2: ATP5F1A;ATP5ME;ATP5MF;MTFR2;NDUFAF6;NDUFAF7
3:        ADGRB1;IFIT1B;NT5C3A;PLPP6;RIGI;URI1
4:                                 RIGI;TOMM70
5:    ACKR3;BTN2A3P;CTSL;GPR183;MARCHF1;ZBTB49
   entrez_reconciled_missing_symbols mapped_gene_gain
                              <char>            <int>
1:                            HYDIN2                0
2:                           NDUFAF8                6
3:                DDX60L;MICA;POLR3E                5
4:                              none                2
5:   CCR2;CCRL2;KIR2DS2;KIR3DS1;MICA                3
```

## Rejected synonym-only mappings

```text
    final_module_id requested_symbol requested_entrez     probe_id
             <char>           <char>           <char>       <char>
 1:         BACT_M1            RPL17             6139 ILMN_1755115
 2:         BACT_M1            RPL23             9349 ILMN_1655422
 3:         BACT_M1            RPL23             9349 ILMN_1658283
 4:         BACT_M1            RPL23             9349 ILMN_1806123
 5:         BACT_M1            RPL23             9349 ILMN_2383097
 6:         BACT_M2              CAT              847 ILMN_1668510
 7:         BACT_M2              CAT              847 ILMN_1757477
 8:         BACT_M2              CAT              847 ILMN_1811345
 9:         VIR_M1a             AZI2            64343 ILMN_1659599
10:         VIR_M1a               C2              717 ILMN_1695588
11:         VIR_M1a               C2              717 ILMN_1712082
12:         VIR_M1a               C2              717 ILMN_2334587
13:         VIR_M1a            DDX21             9188 ILMN_1679405
14:         VIR_M1a             GBP3             2635 ILMN_1689251
15:         VIR_M1a             GBP3             2635 ILMN_2381476
16:         VIR_M1a             IL27           246778 ILMN_1753823
17:         VIR_M1a             IL27           246778 ILMN_1787844
18:         VIR_M1a             PRF1             5551 ILMN_1772876
19:         VIR_M1a             ZBP1            81030 ILMN_1733807
20:         VIR_M1b             AZI2            64343 ILMN_1659599
21:          VIR_M2            CCL28            56477 ILMN_1779147
22:          VIR_M2             CCR4             1233 ILMN_2136177
23:          VIR_M2             CCR9            10803 ILMN_1763127
24:          VIR_M2             ELF1             1997 ILMN_1723185
25:          VIR_M2              FAS              355 ILMN_1784871
26:          VIR_M2           FCGR2B             2213 ILMN_2331121
27:          VIR_M2          KIR3DS1             3813 ILMN_2131828
28:          VIR_M2            MS4A2             2206 ILMN_1697830
29:          VIR_M2            MS4A2             2206 ILMN_1776939
30:          VIR_M2            MS4A2             2206 ILMN_2401714
    final_module_id requested_symbol requested_entrez     probe_id
             <char>           <char>           <char>       <char>
    platform_symbol
             <char>
 1:           RPL23
 2:           RPL17
 3:           RPL17
 4:          MRPL23
 5:           RPL17
 6:           GLYAT
 7:           GLYAT
 8:           GLYAT
 9:             ADC
10:           HNRPC
11:           GCNT3
12:          HNRNPC
13:           DDX56
14:           SPG3A
15:           SPG3A
16:           IL17D
17:        C19orf10
18:          ZNF395
19:         IGF2BP1
20:             ADC
21:            ENC1
22:           CNOT6
23:           CCBP2
24:           ELOF1
25:            FASN
26:          FCGR2C
27:         KIR3DL1
28:           MS4A1
29:           MS4A1
30:           MS4A1
    platform_symbol
             <char>
                                                                                                                                            platform_synonyms
                                                                                                                                                       <char>
 1:                                                                                                                     MGC117346; rpL17; MGC111167; MGC72008
 2:                                                                                                                                                     rpL23
 3:                                                                                                                                          MGC117162; rpL23
 4:                                                                                                                           FLJ45387; L23MRP; RPL23; RPL23L
 5:                                                                                                                                          MGC117162; rpL23
 6:                                                                                                                                          ACGNAT; CAT; GAT
 7:                                                                                                                                          ACGNAT; CAT; GAT
 8:                                                                                                                                          ACGNAT; CAT; GAT
 9:                                                                                                                              ODC1L; AZI2; ODC-p; KIAA1945
10:                                                                                  MGC131677; MGC105117; MGC117353; C1; hnRNPC; C2; MGC104306; SNRPC; HNRNP
11:                                                                                                                           C2/4GnT; GnT-M; C2GnT-M; C2GnT2
12:                                                                           HNRPC; MGC131677; MGC105117; MGC104306; MGC117353; SNRPC; C1; hnRNPC; HNRNP; C2
13:                                                                                                                                              DDX21; NOH61
14:                                                                                                                 SPG3; GBP3; FSP1; AD-FSP; ATL1; atlastin1
15:                                                                                                                 SPG3; GBP3; FSP1; AD-FSP; ATL1; atlastin1
16:                                                                                                                      IL-22; IL-17D; IL-27; IL27; FLJ30846
17:                                                                                                       EUROIMAGE1875335; R33729_1; SF20; IL27; IL27w; IL25
18:                                                                                                         PRF1; DKFZp434K1210; PBF; PRF-1; HDBP2; Si-1-8-14
19:                                                                                                                  CRD-BP; VICKZ1; IMP-1; CRDBP; IMP1; ZBP1
20:                                                                                                                              ODC1L; AZI2; ODC-p; KIAA1945
21:                                                                                                      PIG10; NRPB; CCL28; FLJ39259; ENC-1; TP53I10; KLHL35
22:                                                                                                                                            KIAA1194; CCR4
23:                                                                                                        D6; CCR9; MGC138250; MGC126678; CCR10; hD6; CMKBR9
24:                                                                                                                                                      ELF1
25:                                                                                                                           MGC14367; MGC15706; FAS; OA-519
26:                                                                                                                FCGR2B; CD32; FcgammaRIIC; hFcRII-C; CD32C
27: CD158E2; MGC126589; MGC119728; CL-11; AMB11; MGC126591; NKB1B; KIR; CD158E1; NKB1; NKAT10; MGC119726; KIR3DL1/2V; KIR-G1; NKAT3; KIR3DS1; CL-2; CD158E1/2
28:                                                                                                                MS4A2; LEU-16; B1; CD20; Bp35; S7; MGC3969
29:                                                                                                                MS4A2; LEU-16; B1; CD20; Bp35; S7; MGC3969
30:                                                                                                                MS4A2; B1; CD20; Bp35; LEU-16; S7; MGC3969
                                                                                                                                            platform_synonyms
                                                                                                                                                       <char>
    platform_ilmn_gene platform_entrez             conflict_type
                <char>          <char>                    <char>
 1:              RPL23            9349 SYNONYM_ONLY_NOT_ACCEPTED
 2:              RPL17            6139 SYNONYM_ONLY_NOT_ACCEPTED
 3:              RPL17            6139 SYNONYM_ONLY_NOT_ACCEPTED
 4:             MRPL23            6150 SYNONYM_ONLY_NOT_ACCEPTED
 5:              RPL17            6139 SYNONYM_ONLY_NOT_ACCEPTED
 6:              GLYAT           10249 SYNONYM_ONLY_NOT_ACCEPTED
 7:              GLYAT           10249 SYNONYM_ONLY_NOT_ACCEPTED
 8:              GLYAT           10249 SYNONYM_ONLY_NOT_ACCEPTED
 9:                ADC          113451 SYNONYM_ONLY_NOT_ACCEPTED
10:              HNRPC            3183 SYNONYM_ONLY_NOT_ACCEPTED
11:              GCNT3            9245 SYNONYM_ONLY_NOT_ACCEPTED
12:             HNRNPC            3183 SYNONYM_ONLY_NOT_ACCEPTED
13:              DDX56           54606 SYNONYM_ONLY_NOT_ACCEPTED
14:              SPG3A           51062 SYNONYM_ONLY_NOT_ACCEPTED
15:              SPG3A           51062 SYNONYM_ONLY_NOT_ACCEPTED
16:              IL17D           53342 SYNONYM_ONLY_NOT_ACCEPTED
17:           C19ORF10           56005 SYNONYM_ONLY_NOT_ACCEPTED
18:             ZNF395           55893 SYNONYM_ONLY_NOT_ACCEPTED
19:            IGF2BP1           10642 SYNONYM_ONLY_NOT_ACCEPTED
20:                ADC          113451 SYNONYM_ONLY_NOT_ACCEPTED
21:               ENC1            8507 SYNONYM_ONLY_NOT_ACCEPTED
22:              CNOT6           57472 SYNONYM_ONLY_NOT_ACCEPTED
23:              CCBP2            1238 SYNONYM_ONLY_NOT_ACCEPTED
24:              ELOF1           84337 SYNONYM_ONLY_NOT_ACCEPTED
25:               FASN            2194 SYNONYM_ONLY_NOT_ACCEPTED
26:             FCGR2C            9103 SYNONYM_ONLY_NOT_ACCEPTED
27:            KIR3DL1            3811 SYNONYM_ONLY_NOT_ACCEPTED
28:              MS4A1             931 SYNONYM_ONLY_NOT_ACCEPTED
29:              MS4A1             931 SYNONYM_ONLY_NOT_ACCEPTED
30:              MS4A1             931 SYNONYM_ONLY_NOT_ACCEPTED
    platform_ilmn_gene platform_entrez             conflict_type
                <char>          <char>                    <char>
```

## Decision

- Quality gate: `PASS`.
- Scoring readiness: `READY_FOR_FIXED_MODULE_SCORING`.
- Entrez-rescued module-gene instances: 20.
- Modules eligible at 50%: 5/5.
- Modules at or above 70%: 5/5.
- Rejected synonym-only gene instances: 19.
