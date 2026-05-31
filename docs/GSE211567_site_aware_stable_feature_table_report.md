# GSE211567 Site-Aware Stable-Feature Table Report

- Generated: 2026-05-31 09:26:24 EAT
- Purpose: annotate pooled bacterial-versus-viral ranked evidence with site-stratified direction and FDR support before pathway/module discovery.
- Boundary: this step creates feature-stability annotations only. It does not perform pathway enrichment, module discovery, external validation or biological interpretation.

## Stability tier summary

                                                        stability_tier     N
                                                                <char> <int>
1:                                                   Lower_or_unstable  9041
2:                        Tier_1_cross_site_FDR05_direction_concordant  3217
3:         Tier_2_pooled_FDR05_all_direction_concordant_one_site_FDR05  5404
4: Tier_3_pooled_FDR05_all_direction_concordant_site_nominal_or_weaker   603
5:                  Tier_4_pooled_FDR05_partial_site_direction_support   775
6:                        Tier_5_pooled_FDR10_all_direction_concordant   959

## Recommended-use summary

                                       recommended_use     N
                                                <char> <int>
1: eligible_for_site_aware_pathway_or_module_discovery  9224
2:         not_prioritized_for_stable_module_discovery 10000
3:                 secondary_or_site_contextual_signal   775

## Direction summary

                            category     n
                              <char> <int>
1: pooled_FDR05_all_three_concordant  9224
2: stable_bacterial_higher_all_three  2788
3:     stable_viral_higher_all_three  6436
4: eligible_for_site_aware_discovery  9224
5:      secondary_or_site_contextual   775
6:                   not_prioritized 10000

## Eligible feature sets

- Eligible site-aware features: 9224
- Eligible bacterial-higher features: 2788
- Eligible viral-higher features: 6436

## Intended use

- Use eligible site-aware features for pathway/module discovery input.
- Use bacterial-higher and viral-higher eligible subsets for direction-aware enrichment/module construction.
- Treat partial-support features as secondary or site-contextual evidence, not core stable modules.
- Do not use unstable/lower-tier features as primary module anchors.

## Generated files

- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stable_feature_table.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stability_tier_summary.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_recommended_use_summary.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_direction_summary.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_features.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_bacterial_higher_features.tsv`
- `results/module_lock/GSE211567_site_aware_feature_stability/GSE211567_site_aware_eligible_viral_higher_features.tsv`
- `results/figures/GSE211567_site_aware_feature_stability/GSE211567_site_aware_stability_tier_counts.png` and `.pdf`
- `results/figures/GSE211567_site_aware_feature_stability/GSE211567_pooled_vs_Sri_Lanka_stable_feature_scatter.png` and `.pdf`
- `results/figures/GSE211567_site_aware_feature_stability/GSE211567_pooled_vs_United_States_stable_feature_scatter.png` and `.pdf`

## Boundary statement

- This report does not define named biological modules.
- This report does not interpret genes or pathways.
- This report establishes a site-aware evidence table for the next enrichment/module-discovery step.
