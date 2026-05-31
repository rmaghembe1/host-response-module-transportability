# Integrated Manuscript Results Section with Figure and Table Callouts

## GSE211567 discovery analysis identifies site-aware bacterial- and viral-associated host-response programmes

The discovery analysis was performed in GSE211567 using a predefined bacterial-versus-viral contrast while preserving a strict distinction between discovery, module locking and external projection. The primary limma analysis ranked host-transcriptomic features by bacterial-versus-viral differential expression and provided the starting point for biological module discovery (Figure 1A). This primary analysis was followed by site-aware concordance checks across the pooled dataset and available site-stratified analyses, reducing the risk of carrying forward features driven mainly by a single geographic or technical stratum.

The site-stratified concordance analysis showed that the pooled bacterial-versus-viral contrast was strongly concordant with the Sri Lanka stratum and moderately concordant with the United States stratum, whereas the direct Sri Lanka-versus-United States comparison showed weaker concordance (Figure 1B). Directional concordance was also evaluated across all modelled features, supporting a conservative site-aware filtering strategy before pathway interpretation and module locking. These results motivated the use of ranked, site-aware feature sets rather than unrestricted single-cohort differential-expression hits.

## Conservative module locking defines five projection-ready discovery modules

Site-aware eligible bacterial-higher and viral-higher features were mapped from transcript-level identifiers to gene-level identifiers and used for manual GO biological-process enrichment. Redundancy-reduced GO groups were reviewed manually, and candidate biological programmes were classified into primary, secondary and contextual tiers before final module locking. This process yielded five conservative GSE211567 discovery modules that were frozen before external projection (Figure 1C).

Two locked modules were bacterial-higher: BACT_M1, representing a cytoplasmic translation and ribosomal protein programme, and BACT_M2, representing mitochondrial respiration and oxidative phosphorylation. Three locked modules were viral-higher: VIR_M1a, representing a broad antiviral and interferon-stimulated defence programme; VIR_M1b, representing a viral restriction and type I interferon signalling subgroup; and VIR_M2, representing cytokine and innate immune regulation. VIR_M1a and VIR_M1b were retained as related but separate antiviral/interferon submodules rather than force-merged because their overlap was incomplete and each captured a distinct aspect of the antiviral response. These modules were carried forward as fixed gene sets, with no later gene reselection or relabelling allowed during projection.

## GSE73461 was locked as an independent external projection cohort

After module locking, independent external projection required a cohort with compatible host-transcriptomic data, recoverable identifiers and clear bacterial-versus-viral labels. GSE73461 was selected after staged metadata, expression-file, sample-structure and identifier-coverage audits. The locked primary projection contrast contained 52 DefiniteBacterial and 94 DefiniteViral samples. Fifty-five Control samples were retained only as secondary context, while Inflammatory, Kawasaki and Unknown groups were excluded from the primary bacterial-versus-viral contrast.

GSE73461 passed the identifier-coverage gate after Illumina probe annotation with `illuminaHumanv4.db`. Coverage of locked GSE211567 genes was high for all modules: 24/25 genes for BACT_M1, 21/21 for BACT_M2, 128/128 for VIR_M1a, 33/33 for VIR_M1b and 105/106 for VIR_M2 (Table 1). GSE73461 was therefore locked as the formal external projection cohort before any module scoring was performed.

## Fixed-module external projection supports transportability of the locked host-response architecture

Locked GSE211567 modules were scored in GSE73461 using the pre-specified unweighted mean z-score rule. Genes were z-scored within the locked GSE73461 projection sample set, and module scores were calculated without gene reselection, module redefinition, reweighting or diagnostic model training.

All five modules showed expected-direction concordance in GSE73461 (Figure 2A; Table 1). BACT_M2 was higher in DefiniteBacterial than DefiniteViral samples, with a median bacterial-minus-viral difference of +0.3328 and BH-adjusted Wilcoxon P = 0.0202. BACT_M1 was also directionally concordant but statistically borderline after correction, with a median difference of +0.2067 and BH-adjusted P = 0.0799.

The viral-associated modules showed the strongest external transportability. VIR_M1a was higher in DefiniteViral samples, with a median bacterial-minus-viral difference of −0.4629 and BH-adjusted P = 4.77 × 10^-6. VIR_M1b showed the largest separation, with a median difference of −0.6739 and BH-adjusted P = 1.41 × 10^-6. VIR_M2 was also higher in DefiniteViral samples, with a median difference of −0.2596 and BH-adjusted P = 0.00848.

## Primary-only z-score sensitivity confirms robustness to the scoring reference set

To test whether the projection result depended on including Control samples in the z-score reference set, the fixed-module scoring was repeated after gene-wise z-scoring using only DefiniteBacterial and DefiniteViral samples. The 55 Control samples were excluded from this sensitivity analysis.

The sensitivity analysis preserved the main result. All five modules retained expected-direction concordance (Figure 2B–C; Table 1). BACT_M2 remained significantly higher in DefiniteBacterial samples (median difference +0.3504; BH-adjusted P = 0.0165), while BACT_M1 remained directionally concordant but borderline (median difference +0.2211; BH-adjusted P = 0.0778). The viral-associated modules remained robustly higher in DefiniteViral samples: VIR_M1a (median difference −0.4441; BH-adjusted P = 7.57 × 10^-6), VIR_M1b (median difference −0.6445; BH-adjusted P = 2.22 × 10^-6) and VIR_M2 (median difference −0.2626; BH-adjusted P = 0.00796).

Together, these results support external transportability of a pre-specified bacterial- and viral-associated host-response module architecture from GSE211567 into an independent cohort. The strongest transported signals were the antiviral/interferon-related modules, followed by the bacterial mitochondrial respiration and oxidative phosphorylation module. The bacterial cytoplasmic translation and ribosomal protein programme was directionally concordant in both analyses but should be interpreted cautiously because it remained statistically borderline. These findings represent fixed-module transportability analysis, not diagnostic classifier discovery, model training or causal validation.
