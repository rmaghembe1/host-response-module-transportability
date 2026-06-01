# Formal External Projection Candidate Search Register

## Purpose

This register summarizes the external projection candidate search and cohort-selection decisions used to identify an appropriate independent cohort for fixed-module projection of the locked GSE211567 discovery modules.

## Role in the manuscript

This register supports the CMI-facing manuscript by documenting why GSE73461 was selected as the formal external projection cohort and why other candidate datasets were excluded, held or used only as technical rehearsal.

## Selection principles

Candidate external projection datasets were evaluated using the following principles:

1. Publicly available host-transcriptomic data.
2. Infection-relevant human cohort.
3. Recoverable bacterial-versus-viral or relevant infection labels.
4. Expression matrix suitable for module scoring.
5. Identifier mapping compatible with locked GSE211567 module genes.
6. Sufficient sample structure for a predefined projection contrast.
7. No gene reselection, module redefinition or diagnostic model training in the projection cohort.

## Candidate register

| Candidate dataset | Initial role | Audit outcome | Manuscript role | Main reason |
|---|---|---|---|---|
| GSE73461 | Formal external projection candidate | Accepted | Formal external projection cohort | Passed metadata, expression, group-label and identifier-coverage checks; contained DefiniteBacterial and DefiniteViral groups suitable for fixed-module projection. |
| GSE161731 | Technical projection rehearsal | Used only as technical rehearsal | Not formal validation/projection cohort | Useful for testing identifier mapping and projection-readiness logic, but retained only as a technical rehearsal rather than the formal independent projection cohort. |
| GSE261482 | External projection candidate | Not selected for formal projection | Candidate audit record only | Metadata/expression structure required further resolution and did not become the locked formal projection cohort. |
| GSE68310 | External projection candidate | Not selected for formal projection | Candidate audit record only | Non-normalized or otherwise unsuitable expression/metadata structure prevented selection as the formal projection cohort. |

## Final cohort decision

GSE73461 was locked as the formal external projection cohort after staged feasibility review. It provided recoverable primary projection groups, expression data suitable for module scoring, and acceptable locked-module identifier coverage.

## Interpretation boundary

The candidate search and final cohort decision support fixed-module transportability analysis only. They do not support diagnostic classifier discovery, diagnostic model validation, gene rediscovery, module redefinition or causal validation.
