# Host-response module transportability across public infection transcriptomic cohorts

This repository contains reproducibility scripts and supporting materials for the manuscript:

**Cross-cohort transportability of bacterial- and viral-associated host-response modules in public infection transcriptomic datasets**

Author: Reuben S. Maghembe

## Overview

This study evaluates the external transportability of predefined bacterial- and viral-associated host-response modules across independent public infection transcriptomic cohorts.

The workflow uses public transcriptomic datasets, locked host-response module definitions, identifier matching, module scoring, external projection, statistical testing, figure generation and supplementary-table generation.

The analysis is designed as a fixed-module transportability assessment. It is not a diagnostic classifier-discovery study and does not claim clinical diagnostic validation.

## Repository structure

- `PROTOCOL/` - protocol or workflow-planning materials
- `data/` - public-data notes and local data placeholders
- `docs/` - manuscript-facing notes, decision logs and documentation
- `env/` - environment information and local environment files
- `manuscript/` - manuscript-related working files
- `metadata/` - curated metadata and cohort-mapping resources
- `results/` - analysis outputs and supplementary table components
- `scripts/` - Bash, R and Python analysis scripts
- `submission/` - publication-facing supplementary dataset
- `README.md` - repository overview

## Data availability

This study uses publicly available transcriptomic datasets. Source accessions and analysis metadata are reported in the manuscript and in:

`submission/S1_Dataset_supplementary_tables_S1_to_S5.xlsx`

Raw source data are not redistributed in this repository because they are available from public repositories. Scripts are provided to support data retrieval and reproducible analysis from the public sources.

Large raw files, downloaded expression matrices and intermediate cache files are intentionally excluded from Git tracking.

## Supplementary dataset

The publication-facing supplementary workbook is:

`submission/S1_Dataset_supplementary_tables_S1_to_S5.xlsx`

It contains:

- candidate dataset register
- locked discovery module genes
- identifier coverage and probe-choice audit
- fixed module scores
- primary and sensitivity statistical tests
- manuscript projection summary

## Reproducibility notes

The scripts are organised according to the manuscript workflow and support data acquisition, identifier matching, module scoring, external projection, statistical testing, figure generation and supplementary-table generation.

Some files may retain internal labels from earlier manuscript preparation stages. These labels do not alter the analysis logic, results or manuscript interpretation.

## Software environment

Environment-related files are stored under `env/`. Where available, the repository includes R and Python environment information to support reproducibility.

## License

The code in this repository is released under the MIT License. See `LICENSE`.

## Citation

Please cite the associated manuscript when using this repository. Repository citation metadata are provided in `CITATION.cff`.
