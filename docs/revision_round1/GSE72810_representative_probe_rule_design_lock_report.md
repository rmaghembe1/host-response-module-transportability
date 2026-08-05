# GSE72810 representative-probe rule and scoring-design lock

## Locked primary representative-probe rule

For every mapped locked gene, only probes accepted by the Entrez-authoritative reconciliation were eligible. The probe with the highest median expression across all 146 GSE72810 samples was selected. Exact ties were resolved using the lexicographically smallest Illumina probe identifier.

The representative probes produced here are frozen and must be reused in the primary projection, primary-only z-reference sensitivity, expanded definite-plus-probable sensitivity, effect-size analysis and later robustness analyses.

## Compatibility rationale

The submitted GSE73461 projection used highest median expression across projection samples followed by probe-ID tie-breaking. The GSE72810 rule preserves this principle and is phenotype-blind because all 146 samples contribute to the probe-selection statistic.

## Probe multiplicity

```text
          analysis_level accepted_probe_count count
                  <char>                <int> <int>
 1: module_gene_instance                    0    10
 2: module_gene_instance                    1   165
 3: module_gene_instance                    2    82
 4: module_gene_instance                    3    37
 5: module_gene_instance                    4    15
 6: module_gene_instance                    5     2
 7: module_gene_instance                    6     1
 8: module_gene_instance                    7     1
 9:   unique_entrez_gene                    1   136
10:   unique_entrez_gene                    2    71
11:   unique_entrez_gene                    3    34
12:   unique_entrez_gene                    4    11
13:   unique_entrez_gene                    5     2
14:   unique_entrez_gene                    6     1
15:   unique_entrez_gene                    7     1
```

## Median-rule versus variance-rule differences

- Same probe selected: 227 unique mapped genes.
- Different probe selected: 29 unique mapped genes.

```text
    requested_symbol requested_entrez candidate_probe_count
              <char>           <char>                 <int>
 1:           ATP1B1              481                     3
 2:          ATP5F1A              498                     2
 3:           BMPR1A              657                     2
 4:           BTN2A2            10385                     2
 5:            CCL28            56477                     3
 6:             CCR6             1235                     3
 7:             CSF1             1435                     3
 8:             CTSL             1514                     3
 9:            DDX17            10521                     3
10:             ETS1             2113                     2
11:           FCGR3A             2214                     2
12:             IFI6             2537                     2
13:          KIR2DL1             3802                     2
14:             MEFV             4210                     2
15:          NDUFAF7            55471                     3
16:           NDUFV3             4731                     2
17:             OAS1             4938                     4
18:            PATZ1            23598                     3
19:            RPL17             6139                     3
20:           RPS15A             6210                     3
21:            RPS27             6232                     3
22:             RPS9             6203                     2
23:          SMPDL3B            27293                     3
24:            STAT1             6772                     3
25:             TLR3             7098                     2
26:            TRAF4             9618                     2
27:            TREX1            11277                     2
28:            UBA52             7311                     2
29:          ZC3HAV1            56829                     3
    requested_symbol requested_entrez candidate_probe_count
              <char>           <char>                 <int>
    median_rule_probe_id variance_rule_probe_id median_rule_probe_median
                  <char>                 <char>                    <num>
 1:         ILMN_2407824           ILMN_1730291                 6.230648
 2:         ILMN_1764494           ILMN_2341363                11.244324
 3:         ILMN_1706957           ILMN_2095577                 6.093692
 4:         ILMN_1752758           ILMN_2256894                 6.251232
 5:         ILMN_1774087           ILMN_2228845                 6.190541
 6:         ILMN_2387696           ILMN_1690907                13.136947
 7:         ILMN_1733402           ILMN_2302947                 5.922733
 8:         ILMN_1812995           ILMN_2374036                 7.433953
 9:         ILMN_2371590           ILMN_1675124                 9.389064
10:         ILMN_1687538           ILMN_2122103                10.721332
11:         ILMN_2112580           ILMN_1703679                 6.791009
12:         ILMN_1687384           ILMN_2347798                11.279232
13:         ILMN_1678882           ILMN_1786810                 6.273485
14:         ILMN_1804738           ILMN_2115752                 7.047043
15:         ILMN_1722186           ILMN_2394132                 6.771230
16:         ILMN_1765500           ILMN_2387731                 6.201778
17:         ILMN_2410826           ILMN_1658247                 8.223720
18:         ILMN_1759297           ILMN_2401844                 6.148529
19:         ILMN_1658283           ILMN_2383097                10.706988
20:         ILMN_1787949           ILMN_2337241                12.270976
21:         ILMN_1660498           ILMN_1696839                13.169993
22:         ILMN_1749447           ILMN_2038772                11.974573
23:         ILMN_1719660           ILMN_1789913                 6.003758
24:         ILMN_1691364           ILMN_1690105                11.260507
25:         ILMN_1689578           ILMN_2155708                 6.014822
26:         ILMN_1763104           ILMN_1745976                 6.112583
27:         ILMN_1676997           ILMN_1770955                 5.967492
28:         ILMN_1782977           ILMN_2368576                13.693099
29:         ILMN_1667068           ILMN_1729973                 9.121371
    median_rule_probe_id variance_rule_probe_id median_rule_probe_median
                  <char>                 <char>                    <num>
    variance_rule_probe_median median_rule_probe_variance
                         <num>                      <num>
 1:                   6.114618                0.020900670
 2:                  10.979470                0.145939527
 3:                   5.905440                0.005766556
 4:                   6.036745                0.012440575
 5:                   6.060939                0.013840968
 6:                   7.798099                0.075647606
 7:                   5.717676                0.016823191
 8:                   7.416408                0.651018932
 9:                   8.781524                0.285532453
10:                   9.712720                0.723973876
11:                   6.372995                0.432247768
12:                  10.350804                1.064049238
13:                   6.169951                0.090888621
14:                   7.035253                0.309147039
15:                   6.556334                0.087385066
16:                   6.123617                0.014059365
17:                   7.958496                1.557539808
18:                   6.001896                0.019678140
19:                  10.702320                1.566333916
20:                  10.499515                0.926353311
21:                   9.871646                0.544554485
22:                  11.807576                0.300172968
23:                   5.832699                0.014648992
24:                   9.186810                1.001684620
25:                   5.766057                0.011560953
26:                   5.891256                0.010295641
27:                   5.941322                0.013318249
28:                   7.112963                0.098469413
29:                   7.548600                0.213854877
    variance_rule_probe_median median_rule_probe_variance
                         <num>                      <num>
    variance_rule_probe_variance
                           <num>
 1:                   0.02432654
 2:                   0.18258014
 3:                   0.01791179
 4:                   0.01877126
 5:                   0.01518167
 6:                   0.46539743
 7:                   0.01967330
 8:                   0.66897247
 9:                   0.62007538
10:                   0.73811924
11:                   0.47129253
12:                   2.83273564
13:                   0.16187867
14:                   0.36055812
15:                   0.11879759
16:                   0.02754097
17:                   2.17675277
18:                   0.02216130
19:                   1.63095934
20:                   1.02008395
21:                   1.10344076
22:                   0.32055022
23:                   0.01979778
24:                   1.10338545
25:                   0.01274242
26:                   0.02615993
27:                   0.01793556
28:                   0.14527270
29:                   0.35181429
    variance_rule_probe_variance
                           <num>
```

## Locked scoring populations

- Primary z-reference: all 146 samples.
- Primary contrast: 23 definite bacterial versus 28 definite viral.
- Primary-only z-reference sensitivity: the 51 definite bacterial and viral samples, using the same frozen probes.
- Expanded phenotype sensitivity: 40 definite-plus-probable bacterial versus 35 definite-plus-probable viral samples.
- Probe-collapse sensitivity: mean expression across all Entrez-authorized probes for each gene before z-standardization.

## Quality gate

```text
    check_id                                             check_description
      <char>                                                        <char>
 1:      Q01               Expression matrix contains 48,803 unique probes
 2:      Q02                Expression matrix contains 146 ordered samples
 3:      Q03                   Expression and metadata sample orders match
 4:      Q04                  Locked module mapping contains 313 instances
 5:      Q05                        Mapped module-gene instances equal 303
 6:      Q06                       Unmapped module-gene instances equal 10
 7:      Q07         Candidate probes are present in the expression matrix
 8:      Q08                          Candidate gene-probe keys are unique
 9:      Q09        No accepted probe maps to multiple locked Entrez genes
10:      Q10 One frozen representative probe exists per mapped Entrez gene
11:      Q11       All mapped module-gene instances receive a frozen probe
12:      Q12             No unmapped module-gene instance receives a probe
13:      Q13           Primary selection uses all-sample median expression
14:      Q14    Primary tie-breaker is lexicographically smallest probe ID
      pass
    <lgcl>
 1:   TRUE
 2:   TRUE
 3:   TRUE
 4:   TRUE
 5:   TRUE
 6:   TRUE
 7:   TRUE
 8:   TRUE
 9:   TRUE
10:   TRUE
11:   TRUE
12:   TRUE
13:   TRUE
14:   TRUE
```

- Quality gate: `PASS`.
- Design status: `LOCKED_READY_FOR_FIXED_MODULE_SCORING`.
