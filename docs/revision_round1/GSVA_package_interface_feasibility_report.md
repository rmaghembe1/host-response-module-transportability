# GSVA package and interface feasibility audit

## Purpose

This technical audit establishes the installed GSVA package version, identifies the supported function interface and tests a small outcome-independent synthetic calculation before study scoring.

No infection labels or study expression values were used.

## Environment

- GSVA installed: `TRUE`
- GSVA version: `1.50.5`
- BiocParallel installed: `TRUE`
- BiocParallel version: `1.36.0`
- Detected interface: `modern_parameter_object_api`

## Synthetic interface test

- Test attempted: `TRUE`
- Test passed: `TRUE`
- Returned object class: `matrix;array`
- Score dimensions: `2 x 6`
- All scores finite: `TRUE`
- Error message: `none`

## Readiness decision

**PASS_READY_FOR_GSVA_SCORING**

GSVA is installed, its interface was resolved, and the synthetic outcome-independent calculation passed.

## Interpretation boundary

Passing this audit establishes only that the installed GSVA software interface can calculate gene-set scores. It does not evaluate the biological performance of the submitted modules.

## Output files

- `results/revision_round1/GSVA_package_interface_feasibility/GSVA_package_interface_feasibility.tsv`
- `results/revision_round1/GSVA_package_interface_feasibility/GSVA_interface_signature.txt`
- `results/revision_round1/GSVA_package_interface_feasibility/GSVA_synthetic_test_scores.tsv`
