# Revised GSE73461 Figure 2C

## Purpose

This revision replaces the categorical connected-line representation of adjusted P values with independent points for each locked module and analysis representation.

The revised panel contains no internal title or subtitle because the explanatory description will be provided in the manuscript Figure 2 legend.

No module scoring or statistical test was recomputed.

## Inputs

- `results/module_projection/GSE73461_fixed_module_projection/GSE73461_fixed_module_primary_projection_tests.tsv`
- `results/module_projection/GSE73461_primary_only_zscore_sensitivity/GSE73461_primary_only_zscore_primary_projection_tests.tsv`

## Plot design

- Five locked modules are shown as categorical x-axis positions.
- Each analysis contributes one independent point per module.
- No line connects different modules.
- Main and sensitivity analyses are distinguished by point shape.
- The dashed horizontal reference denotes BH-adjusted P = 0.05.
- The y-axis is -log10(BH-adjusted P).
- No panel title or subtitle is embedded in the figure.

## Outputs

- `results/revision_round1/GSE73461_revised_Figure2C/figures/Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.png`
- `results/revision_round1/GSE73461_revised_Figure2C/figures/Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.pdf`
- `results/revision_round1/GSE73461_revised_Figure2C/figures/Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.svg`
- `results/revision_round1/GSE73461_revised_Figure2C/GSE73461_revised_Figure2C_source_data.tsv`
- `results/revision_round1/GSE73461_revised_Figure2C/GSE73461_revised_Figure2C_quality_gate.tsv`

## Quality gate

- Checks passed: 13/13.
- Final status: `READY_FOR_FIGURE_2C_VISUAL_REVIEW`.
