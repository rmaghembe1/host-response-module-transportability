# GSE211567 Manual GO Biological Process ORA Report

- Generated: 2026-05-31 14:08:03 EAT
- Purpose: first direction-aware pathway discovery using site-aware gene-level eligible sets.
- Method: manual one-sided Fisher exact over-representation analysis using org.Hs.eg.db and GO.db.
- Universe: all modelled gene-level ENTREZ identifiers.
- Boundary: enrichment discovery only; no final biological module naming or manuscript-level interpretation is made here.

## Input gene sets

- Universe genes: 9100
- Bacterial-higher site-aware eligible genes: 1479
- Viral-higher site-aware eligible genes: 2854

## Enrichment summary

                          direction_set query_genes universe_genes
                                 <char>       <int>          <int>
1: bacterial_higher_site_aware_eligible        1479           9100
2:     viral_higher_site_aware_eligible        2854           9100
   tested_GO_BP_terms FDR_0.05_terms FDR_0.10_terms
                <int>          <int>          <int>
1:               1181              7              8
2:               1181             23             35

## Top FDR < 0.05 terms by direction

                           direction_set         GO
                                  <char>     <char>
 1: bacterial_higher_site_aware_eligible GO:0002181
 2: bacterial_higher_site_aware_eligible GO:0006412
 3: bacterial_higher_site_aware_eligible GO:0006749
 4: bacterial_higher_site_aware_eligible GO:0032981
 5: bacterial_higher_site_aware_eligible GO:0042776
 6: bacterial_higher_site_aware_eligible GO:0009060
 7: bacterial_higher_site_aware_eligible GO:0006120
 8:     viral_higher_site_aware_eligible GO:0000122
 9:     viral_higher_site_aware_eligible GO:0045944
10:     viral_higher_site_aware_eligible GO:0006355
11:     viral_higher_site_aware_eligible GO:0051607
12:     viral_higher_site_aware_eligible GO:0009615
13:     viral_higher_site_aware_eligible GO:0001817
14:     viral_higher_site_aware_eligible GO:0045893
15:     viral_higher_site_aware_eligible GO:0045071
16:     viral_higher_site_aware_eligible GO:0060326
17:     viral_higher_site_aware_eligible GO:0006955
18:     viral_higher_site_aware_eligible GO:0048167
19:     viral_higher_site_aware_eligible GO:0006338
20:     viral_higher_site_aware_eligible GO:0045892
21:     viral_higher_site_aware_eligible GO:0032092
22:     viral_higher_site_aware_eligible GO:0042113
23:     viral_higher_site_aware_eligible GO:0001756
24:     viral_higher_site_aware_eligible GO:0009617
25:     viral_higher_site_aware_eligible GO:0030890
26:     viral_higher_site_aware_eligible GO:0006468
27:     viral_higher_site_aware_eligible GO:0060907
28:     viral_higher_site_aware_eligible GO:0032728
29:     viral_higher_site_aware_eligible GO:0045087
30:     viral_higher_site_aware_eligible GO:0060337
                           direction_set         GO
                                  <char>     <char>
                                                         TERM overlap_genes
                                                       <char>         <int>
 1:                                   cytoplasmic translation            18
 2:                                               translation            23
 3:                             glutathione metabolic process            11
 4:        mitochondrial respiratory chain complex I assembly            12
 5:    proton motive force-driven mitochondrial ATP synthesis             9
 6:                                       aerobic respiration            10
 7:      mitochondrial electron transport, NADH to ubiquinone             8
 8: negative regulation of transcription by RNA polymerase II           193
 9: positive regulation of transcription by RNA polymerase II           214
10:                 regulation of DNA-templated transcription           130
11:                                 defense response to virus            66
12:                                         response to virus            34
13:                         regulation of cytokine production            27
14:        positive regulation of DNA-templated transcription           127
15:           negative regulation of viral genome replication            18
16:                                           cell chemotaxis            21
17:                                           immune response            70
18:                         regulation of synaptic plasticity            14
19:                                      chromatin remodeling            67
20:        negative regulation of DNA-templated transcription            99
21:                    positive regulation of protein binding            15
22:                                         B cell activation            12
23:                                             somitogenesis            13
24:                                     response to bacterium            26
25:               positive regulation of B cell proliferation            16
26:                                   protein phosphorylation            75
27:     positive regulation of macrophage cytokine production             9
28:         positive regulation of interferon-beta production            14
29:                                    innate immune response            82
30:              type I interferon-mediated signaling pathway            10
                                                         TERM overlap_genes
                                                       <char>         <int>
        p_adj_BH enrichment_ratio
           <num>            <num>
 1: 3.386765e-07         4.614604
 2: 6.688775e-03         2.482711
 3: 6.688775e-03         3.760048
 4: 6.688775e-03         3.515889
 5: 6.991608e-03         4.259635
 6: 7.643673e-03         3.845504
 7: 2.154951e-02         4.101871
 8: 5.096275e-09         1.508289
 9: 7.704956e-09         1.461115
10: 4.882673e-08         1.600409
11: 1.073283e-06         1.845978
12: 3.849150e-04         2.007579
13: 5.379654e-04         2.152242
14: 8.687155e-04         1.391548
15: 1.993818e-03         2.391381
16: 1.993818e-03         2.231955
17: 6.494481e-03         1.487970
18: 7.236807e-03         2.479950
19: 3.200868e-02         1.424200
20: 3.200868e-02         1.331908
21: 3.200868e-02         2.173982
22: 3.200868e-02         2.391381
23: 3.200868e-02         2.302811
24: 3.824953e-02         1.763855
25: 4.884926e-02         2.040645
26: 4.884926e-02         1.366503
27: 4.884926e-02         2.608779
28: 4.919941e-02         2.125672
29: 4.919941e-02         1.340808
30: 4.919941e-02         2.452698
        p_adj_BH enrichment_ratio
           <num>            <num>

## Generated files

- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_bacterial_higher.tsv`
- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_viral_higher.tsv`
- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_combined.tsv`
- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_summary.tsv`
- `results/pathway_enrichment/GSE211567_manual_GO_BP_ORA/GSE211567_manual_GO_BP_ORA_top25_FDR05_by_direction.tsv`
- `results/figures/GSE211567_manual_GO_BP_ORA/*top20*.png/.pdf`
- `env/session_info/GSE211567_manual_GO_BP_ORA_site_aware_sessionInfo.txt`

## Interpretation boundary

- This analysis identifies enriched GO Biological Process terms.
- It does not yet merge terms into named biological modules.
- It does not yet define transportable modules.
- It does not make final biological claims.
