#!/usr/bin/env Rscript

# GSE72810 representative-probe rule and scoring-design lock.
#
# Primary representative-probe rule:
#   1. Start only from probes accepted by the Entrez-authoritative
#      reconciliation audit.
#   2. For each unique locked-gene Entrez identifier, select the probe
#      with the highest median expression across all 146 GSE72810 samples.
#   3. Break exact median-expression ties using the lexicographically
#      smallest Illumina probe identifier.
#   4. Freeze the resulting representative probes for every subsequent
#      GSE72810 analysis.
#
# The rule reproduces the representative-probe principle used in the
# submitted GSE73461 fixed-module projection workflow.
#
# This script locks the design and creates probe-choice tables. It does
# not calculate gene-wise z-scores or module scores.


# -------------------------------------------------------------------------
# Package setup
# -------------------------------------------------------------------------

candidate_libs <- unique(
  c(
    Sys.getenv("R_LIBS_USER"),
    path.expand("~/R/library"),
    "env/R_libs",
    .libPaths()
  )
)

candidate_libs <- candidate_libs[
  nzchar(candidate_libs) &
    dir.exists(candidate_libs)
]

if (length(candidate_libs) > 0L) {
  .libPaths(candidate_libs)
}

if (!requireNamespace("data.table", quietly = TRUE)) {
  stop("The data.table package is required.")
}

suppressPackageStartupMessages({
  library(data.table)
})


# -------------------------------------------------------------------------
# Input paths
# -------------------------------------------------------------------------

matrix_file <- paste0(
  "data/expression_raw/GSE72810/",
  "GSE72810_series_matrix.txt.gz"
)

metadata_file <- paste0(
  "data/metadata_harmonized/",
  "GSE72810_sample_metadata_harmonized.tsv"
)

mapping_file <- paste0(
  "results/revision_round1/",
  "GSE72810_candidate_validation_audit/",
  "GSE72810_locked_module_gene_mapping_entrez_reconciled.tsv"
)

platform_file <- paste0(
  "data/metadata_raw/GSE72810/",
  "GPL6947_platform_table_from_GSE72810_family.tsv"
)


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE72810_probe_rule_design"
)

docs_dir <- "docs/revision_round1"

session_dir <- "env/session_info/revision_round1"

dir.create(
  out_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  docs_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  session_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

candidate_statistics_file <- file.path(
  out_dir,
  "GSE72810_candidate_probe_expression_statistics.tsv"
)

unique_gene_choice_file <- file.path(
  out_dir,
  "GSE72810_frozen_representative_probe_choices.tsv"
)

module_gene_choice_file <- file.path(
  out_dir,
  "GSE72810_frozen_module_gene_probe_choices.tsv"
)

variance_choice_file <- file.path(
  out_dir,
  "GSE72810_highest_variance_probe_choices_audit.tsv"
)

choice_comparison_file <- file.path(
  out_dir,
  "GSE72810_median_vs_variance_probe_choice_comparison.tsv"
)

multiplicity_file <- file.path(
  out_dir,
  "GSE72810_probe_multiplicity_summary.tsv"
)

design_lock_file <- file.path(
  out_dir,
  "GSE72810_scoring_design_lock.tsv"
)

quality_gate_file <- file.path(
  out_dir,
  "GSE72810_probe_rule_quality_gate.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE72810_representative_probe_rule_design_lock_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE72810_representative_probe_rule_design_lock_sessionInfo.txt"
)

output_files <- c(
  candidate_statistics_file,
  unique_gene_choice_file,
  module_gene_choice_file,
  variance_choice_file,
  choice_comparison_file,
  multiplicity_file,
  design_lock_file,
  quality_gate_file,
  report_file,
  session_file
)

unlink(
  output_files,
  force = TRUE
)


# -------------------------------------------------------------------------
# Expected design constants
# -------------------------------------------------------------------------

expected_module_ids <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

expected_total_samples <- 146L
expected_feature_rows <- 48803L
expected_module_gene_instances <- 313L
expected_mapped_module_gene_instances <- 303L
expected_unmapped_module_gene_instances <- 10L

expected_group_counts <- data.table(
  category = c(
    "Definite Bacterial",
    "Definite Viral",
    "Probable Bacterial",
    "Probable Viral",
    "Uncertain",
    "Control"
  ),
  expected_n = c(
    23L,
    28L,
    17L,
    7L,
    55L,
    16L
  )
)


# -------------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------------

require_columns <- function(
  table_object,
  required_columns,
  source_name
) {
  missing_columns <- setdiff(
    required_columns,
    names(table_object)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste(
        "Missing required columns in",
        source_name,
        ":",
        paste(
          missing_columns,
          collapse = ", "
        )
      )
    )
  }

  invisible(TRUE)
}


collapse_values <- function(
  values,
  empty_value = "none"
) {
  values <- unique(
    as.character(values)
  )

  values <- values[
    !is.na(values) &
      nzchar(values)
  ]

  if (length(values) == 0L) {
    return(empty_value)
  }

  paste(
    sort(values),
    collapse = ";"
  )
}


parse_probe_list <- function(value) {
  value <- as.character(value)

  if (
    length(value) == 0L ||
      is.na(value) ||
      !nzchar(value) ||
      identical(value, "none")
  ) {
    return(character())
  }

  probes <- trimws(
    strsplit(
      value,
      ";",
      fixed = TRUE
    )[[1L]]
  )

  sort(
    unique(
      probes[nzchar(probes)]
    )
  )
}


extract_series_matrix_table <- function(
  input_file
) {
  temporary_file <- tempfile(
    pattern = "GSE72810_series_matrix_",
    fileext = ".tsv"
  )

  input_connection <- gzfile(
    input_file,
    open = "rt"
  )

  output_connection <- file(
    temporary_file,
    open = "wt"
  )

  on.exit(
    {
      try(
        close(input_connection),
        silent = TRUE
      )

      try(
        close(output_connection),
        silent = TRUE
      )

      unlink(
        temporary_file,
        force = TRUE
      )
    },
    add = TRUE
  )

  inside_table <- FALSE
  table_completed <- FALSE

  repeat {
    lines <- readLines(
      input_connection,
      n = 1000L,
      warn = FALSE
    )

    if (length(lines) == 0L) {
      break
    }

    if (!inside_table) {
      begin_index <- which(
        lines ==
          "!series_matrix_table_begin"
      )

      if (length(begin_index) > 0L) {
        begin_index <- begin_index[1L]
        inside_table <- TRUE

        if (begin_index < length(lines)) {
          lines <- lines[
            seq.int(
              begin_index + 1L,
              length(lines)
            )
          ]
        } else {
          lines <- character()
        }
      } else {
        next
      }
    }

    if (inside_table && length(lines) > 0L) {
      end_index <- which(
        lines ==
          "!series_matrix_table_end"
      )

      if (length(end_index) > 0L) {
        end_index <- end_index[1L]

        if (end_index > 1L) {
          writeLines(
            lines[
              seq_len(
                end_index - 1L
              )
            ],
            output_connection
          )
        }

        table_completed <- TRUE
        break
      }

      writeLines(
        lines,
        output_connection
      )
    }
  }

  close(input_connection)
  close(output_connection)

  if (!table_completed) {
    stop(
      "The GEO series-matrix expression table was not completed."
    )
  }

  expression_table <- fread(
    temporary_file,
    sep = "\t",
    header = TRUE,
    quote = "\"",
    na.strings = c(
      "",
      "NA",
      "NaN"
    ),
    check.names = FALSE
  )

  unlink(
    temporary_file,
    force = TRUE
  )

  expression_table
}


# -------------------------------------------------------------------------
# Validate inputs
# -------------------------------------------------------------------------

required_files <- c(
  matrix_file,
  metadata_file,
  mapping_file,
  platform_file
)

missing_files <- required_files[
  !file.exists(required_files)
]

if (length(missing_files) > 0L) {
  stop(
    paste(
      "Missing required input files:",
      paste(
        missing_files,
        collapse = ", "
      )
    )
  )
}


# -------------------------------------------------------------------------
# Read expression matrix
# -------------------------------------------------------------------------

message(
  "Reading the GSE72810 processed expression matrix..."
)

expression_dt <- extract_series_matrix_table(
  matrix_file
)

if (!"ID_REF" %in% names(expression_dt)) {
  stop(
    "The expression table does not contain an ID_REF column."
  )
}

expression_dt[
  ,
  ID_REF :=
    as.character(ID_REF)
]

if (
  nrow(expression_dt) !=
    expected_feature_rows
) {
  stop(
    paste(
      "Expected",
      expected_feature_rows,
      "expression rows but recovered",
      nrow(expression_dt)
    )
  )
}

if (anyDuplicated(expression_dt$ID_REF)) {
  stop(
    "The expression matrix contains duplicated probe IDs."
  )
}

sample_columns <- setdiff(
  names(expression_dt),
  "ID_REF"
)

if (
  length(sample_columns) !=
    expected_total_samples
) {
  stop(
    paste(
      "Expected",
      expected_total_samples,
      "sample columns but recovered",
      length(sample_columns)
    )
  )
}

expression_matrix <- as.matrix(
  expression_dt[
    ,
    ..sample_columns
  ]
)

storage.mode(
  expression_matrix
) <- "double"

rownames(
  expression_matrix
) <- expression_dt$ID_REF

if (anyNA(expression_matrix)) {
  stop(
    "The processed expression matrix contains missing values."
  )
}

if (any(!is.finite(expression_matrix))) {
  stop(
    "The processed expression matrix contains non-finite values."
  )
}


# -------------------------------------------------------------------------
# Read and verify harmonized metadata
# -------------------------------------------------------------------------

message(
  "Reading harmonized GSE72810 sample metadata..."
)

metadata <- fread(
  metadata_file
)

require_columns(
  metadata,
  c(
    "sample_order",
    "geo_accession",
    "category",
    "projection_role",
    "include_primary_definite",
    "include_expanded_definite_probable",
    "include_all_sample_reference"
  ),
  metadata_file
)

setorder(
  metadata,
  sample_order
)

if (
  nrow(metadata) !=
    expected_total_samples
) {
  stop(
    "The harmonized metadata does not contain 146 samples."
  )
}

if (anyDuplicated(metadata$geo_accession)) {
  stop(
    "The harmonized metadata contains duplicated GEO accessions."
  )
}

if (!identical(
  sample_columns,
  metadata$geo_accession
)) {
  stop(
    paste(
      "Expression sample order does not match",
      "the harmonized metadata order."
    )
  )
}

observed_group_counts <- metadata[
  ,
  .(
    observed_n = .N
  ),
  by = category
]

group_check <- merge(
  expected_group_counts,
  observed_group_counts,
  by = "category",
  all = TRUE
)

group_check[
  ,
  count_match :=
    expected_n ==
      observed_n
]

if (
  nrow(group_check) !=
    nrow(expected_group_counts) ||
    !all(group_check$count_match)
) {
  print(group_check)

  stop(
    "GSE72810 group counts do not match the locked design."
  )
}

primary_sample_ids <- metadata[
  category %in% c(
    "Definite Bacterial",
    "Definite Viral"
  ),
  geo_accession
]

expanded_sample_ids <- metadata[
  category %in% c(
    "Definite Bacterial",
    "Definite Viral",
    "Probable Bacterial",
    "Probable Viral"
  ),
  geo_accession
]

if (length(primary_sample_ids) != 51L) {
  stop(
    "The definite bacterial-versus-viral sample set is not n=51."
  )
}

if (length(expanded_sample_ids) != 75L) {
  stop(
    "The definite-plus-probable sample set is not n=75."
  )
}


# -------------------------------------------------------------------------
# Read reconciled locked-gene mapping
# -------------------------------------------------------------------------

message(
  "Reading the Entrez-reconciled locked-gene mapping..."
)

mapping <- fread(
  mapping_file
)

require_columns(
  mapping,
  c(
    "final_module_id",
    "final_module_label",
    "module_direction",
    "requested_symbol",
    "requested_entrez",
    "accepted_probe_count",
    "mapped",
    "mapping_rule",
    "rescued_by_entrez",
    "accepted_probe_ids",
    "accepted_platform_symbols",
    "accepted_platform_entrez"
  ),
  mapping_file
)

mapping[
  ,
  final_module_id :=
    as.character(final_module_id)
]

mapping[
  ,
  requested_symbol :=
    as.character(requested_symbol)
]

mapping[
  ,
  requested_entrez :=
    as.character(requested_entrez)
]

mapping[
  ,
  accepted_probe_ids :=
    as.character(accepted_probe_ids)
]

if (
  nrow(mapping) !=
    expected_module_gene_instances
) {
  stop(
    paste(
      "Expected",
      expected_module_gene_instances,
      "module-gene instances but recovered",
      nrow(mapping)
    )
  )
}

if (
  sum(mapping$mapped) !=
    expected_mapped_module_gene_instances
) {
  stop(
    paste(
      "Expected",
      expected_mapped_module_gene_instances,
      "mapped module-gene instances but recovered",
      sum(mapping$mapped)
    )
  )
}

if (
  sum(!mapping$mapped) !=
    expected_unmapped_module_gene_instances
) {
  stop(
    paste(
      "Expected",
      expected_unmapped_module_gene_instances,
      "unmapped module-gene instances but recovered",
      sum(!mapping$mapped)
    )
  )
}

if (
  !setequal(
    unique(mapping$final_module_id),
    expected_module_ids
  )
) {
  stop(
    "Unexpected module identifiers were found in the mapping."
  )
}


# -------------------------------------------------------------------------
# Verify gene-level candidate consistency across modules
# -------------------------------------------------------------------------

mapped_rows <- mapping[
  mapped == TRUE
]

gene_consistency <- mapped_rows[
  ,
  .(
    symbol_count =
      uniqueN(requested_symbol),
    accepted_probe_set_count =
      uniqueN(accepted_probe_ids),
    accepted_probe_count_count =
      uniqueN(accepted_probe_count),
    mapping_rule_count =
      uniqueN(mapping_rule)
  ),
  by = requested_entrez
]

inconsistent_genes <- gene_consistency[
  symbol_count != 1L |
    accepted_probe_set_count != 1L |
    accepted_probe_count_count != 1L
]

if (nrow(inconsistent_genes) > 0L) {
  print(inconsistent_genes)

  stop(
    paste(
      "At least one Entrez gene has inconsistent",
      "candidate-probe definitions across modules."
    )
  )
}

gene_definitions <- mapped_rows[
  ,
  .(
    requested_symbol =
      requested_symbol[1L],
    accepted_probe_count =
      accepted_probe_count[1L],
    accepted_probe_ids =
      accepted_probe_ids[1L],
    accepted_platform_symbols =
      accepted_platform_symbols[1L],
    accepted_platform_entrez =
      accepted_platform_entrez[1L],
    mapping_rules =
      collapse_values(mapping_rule),
    rescued_by_entrez =
      any(rescued_by_entrez),
    module_memberships =
      collapse_values(final_module_id)
  ),
  by = requested_entrez
]

if (anyDuplicated(
  gene_definitions$requested_entrez
)) {
  stop(
    "The gene-definition table contains duplicated Entrez IDs."
  )
}


# -------------------------------------------------------------------------
# Expand accepted probe lists
# -------------------------------------------------------------------------

candidate_rows <- vector(
  "list",
  nrow(gene_definitions)
)

for (gene_row in seq_len(
  nrow(gene_definitions)
)) {
  accepted_probes <- parse_probe_list(
    gene_definitions$
      accepted_probe_ids[gene_row]
  )

  expected_probe_count <-
    gene_definitions$
      accepted_probe_count[gene_row]

  if (
    length(accepted_probes) !=
      expected_probe_count
  ) {
    stop(
      paste(
        "Accepted-probe count mismatch for",
        gene_definitions$
          requested_symbol[gene_row]
      )
    )
  }

  candidate_rows[[gene_row]] <- data.table(
    requested_entrez =
      gene_definitions$
        requested_entrez[gene_row],
    requested_symbol =
      gene_definitions$
        requested_symbol[gene_row],
    module_memberships =
      gene_definitions$
        module_memberships[gene_row],
    mapping_rules =
      gene_definitions$
        mapping_rules[gene_row],
    rescued_by_entrez =
      gene_definitions$
        rescued_by_entrez[gene_row],
    candidate_probe_count =
      length(accepted_probes),
    probe_id =
      accepted_probes
  )
}

candidate_map <- rbindlist(
  candidate_rows,
  use.names = TRUE,
  fill = TRUE
)

if (
  anyDuplicated(
    candidate_map[
      ,
      .(
        requested_entrez,
        probe_id
      )
    ]
  )
) {
  stop(
    "Duplicated gene-probe candidate keys were detected."
  )
}

probe_gene_conflicts <- candidate_map[
  ,
  .(
    entrez_gene_count =
      uniqueN(requested_entrez)
  ),
  by = probe_id
][
  entrez_gene_count > 1L
]

if (nrow(probe_gene_conflicts) > 0L) {
  print(probe_gene_conflicts)

  stop(
    paste(
      "At least one accepted probe is assigned",
      "to multiple locked-gene Entrez identifiers."
    )
  )
}


# -------------------------------------------------------------------------
# Verify platform annotation for candidate probes
# -------------------------------------------------------------------------

message(
  "Reading platform annotation for accepted candidate probes..."
)

platform <- fread(
  platform_file,
  quote = "",
  na.strings = c(
    "",
    "NA",
    "---"
  )
)

require_columns(
  platform,
  c(
    "ID",
    "Symbol",
    "Entrez_Gene_ID",
    "ILMN_Gene"
  ),
  platform_file
)

platform[
  ,
  ID := as.character(ID)
]

if (anyDuplicated(platform$ID)) {
  stop(
    "The platform annotation contains duplicated probe IDs."
  )
}

candidate_statistics <- merge(
  candidate_map,
  platform[
    ,
    .(
      probe_id = ID,
      platform_symbol = Symbol,
      platform_entrez =
        Entrez_Gene_ID,
      platform_ilmn_gene =
        ILMN_Gene
    )
  ],
  by = "probe_id",
  all.x = TRUE,
  sort = FALSE
)

if (
  anyNA(
    candidate_statistics$
      platform_symbol
  ) &&
    anyNA(
      candidate_statistics$
        platform_entrez
    )
) {
  unresolved_platform_rows <- candidate_statistics[
    is.na(platform_symbol) &
      is.na(platform_entrez)
  ]

  print(unresolved_platform_rows)

  stop(
    "At least one candidate probe lacks recoverable platform annotation."
  )
}


# -------------------------------------------------------------------------
# Calculate phenotype-blind probe statistics across all 146 samples
# -------------------------------------------------------------------------

message(
  "Calculating candidate-probe statistics across all 146 samples..."
)

candidate_expression_index <- match(
  candidate_statistics$probe_id,
  rownames(expression_matrix)
)

if (anyNA(candidate_expression_index)) {
  missing_candidate_probes <- candidate_statistics[
    is.na(candidate_expression_index),
    unique(probe_id)
  ]

  stop(
    paste(
      "Candidate probes absent from the expression matrix:",
      paste(
        missing_candidate_probes,
        collapse = ", "
      )
    )
  )
}

candidate_expression <- expression_matrix[
  candidate_expression_index,
  ,
  drop = FALSE
]

candidate_statistics[
  ,
  all_sample_mean_expression :=
    rowMeans(
      candidate_expression
    )
]

candidate_statistics[
  ,
  all_sample_median_expression :=
    apply(
      candidate_expression,
      1L,
      median
    )
]

candidate_statistics[
  ,
  all_sample_expression_variance :=
    apply(
      candidate_expression,
      1L,
      var
    )
]

candidate_statistics[
  ,
  all_sample_expression_sd :=
    sqrt(
      all_sample_expression_variance
    )
]

candidate_statistics[
  ,
  all_sample_minimum_expression :=
    apply(
      candidate_expression,
      1L,
      min
    )
]

candidate_statistics[
  ,
  all_sample_maximum_expression :=
    apply(
      candidate_expression,
      1L,
      max
    )
]

candidate_statistics[
  ,
  primary_rule_top_median :=
    max(
      all_sample_median_expression
    ),
  by = requested_entrez
]

candidate_statistics[
  ,
  primary_rule_median_tie :=
    all_sample_median_expression ==
      primary_rule_top_median
]

candidate_statistics[
  ,
  primary_rule_tie_count :=
    sum(primary_rule_median_tie),
  by = requested_entrez
]

candidate_statistics[
  ,
  variance_rule_top_variance :=
    max(
      all_sample_expression_variance
    ),
  by = requested_entrez
]

candidate_statistics[
  ,
  variance_rule_tie :=
    all_sample_expression_variance ==
      variance_rule_top_variance
]

candidate_statistics[
  ,
  variance_rule_tie_count :=
    sum(variance_rule_tie),
  by = requested_entrez
]


# -------------------------------------------------------------------------
# Select primary frozen representative probes
# -------------------------------------------------------------------------

primary_choice_ranked <- copy(
  candidate_statistics
)

setorder(
  primary_choice_ranked,
  requested_entrez,
  -all_sample_median_expression,
  probe_id
)

primary_choices <- primary_choice_ranked[
  ,
  .SD[1L],
  by = requested_entrez
]

primary_choices[
  ,
  selection_rule :=
    paste0(
      "Highest median expression across all 146 samples; ",
      "lexicographically smallest probe ID for exact ties"
    )
]

primary_choices[
  ,
  selection_reference_population :=
    "All 146 GSE72810 samples"
]

primary_choices[
  ,
  representative_probe_frozen :=
    TRUE
]

setorder(
  primary_choices,
  requested_symbol,
  requested_entrez
)

if (
  nrow(primary_choices) !=
    nrow(gene_definitions)
) {
  stop(
    "The primary probe-choice table does not contain one row per mapped gene."
  )
}

if (
  anyDuplicated(
    primary_choices$
      requested_entrez
  )
) {
  stop(
    "The primary probe-choice table contains duplicated Entrez IDs."
  )
}


# -------------------------------------------------------------------------
# Calculate highest-variance alternative for audit comparison
# -------------------------------------------------------------------------

variance_choice_ranked <- copy(
  candidate_statistics
)

setorder(
  variance_choice_ranked,
  requested_entrez,
  -all_sample_expression_variance,
  probe_id
)

variance_choices <- variance_choice_ranked[
  ,
  .SD[1L],
  by = requested_entrez
]

variance_choices[
  ,
  selection_rule :=
    paste0(
      "Highest variance across all 146 samples; ",
      "lexicographically smallest probe ID for exact ties"
    )
]

setorder(
  variance_choices,
  requested_symbol,
  requested_entrez
)


# -------------------------------------------------------------------------
# Compare primary and highest-variance choices
# -------------------------------------------------------------------------

choice_comparison <- merge(
  primary_choices[
    ,
    .(
      requested_entrez,
      requested_symbol,
      module_memberships,
      candidate_probe_count,
      median_rule_probe_id =
        probe_id,
      median_rule_probe_median =
        all_sample_median_expression,
      median_rule_probe_variance =
        all_sample_expression_variance,
      median_rule_tie_count =
        primary_rule_tie_count
    )
  ],
  variance_choices[
    ,
    .(
      requested_entrez,
      variance_rule_probe_id =
        probe_id,
      variance_rule_probe_median =
        all_sample_median_expression,
      variance_rule_probe_variance =
        all_sample_expression_variance,
      variance_rule_tie_count =
        variance_rule_tie_count
    )
  ],
  by = "requested_entrez",
  all = TRUE
)

choice_comparison[
  ,
  same_probe_selected :=
    median_rule_probe_id ==
      variance_rule_probe_id
]

setorder(
  choice_comparison,
  requested_symbol,
  requested_entrez
)


# -------------------------------------------------------------------------
# Expand frozen choices back to all 313 module-gene instances
# -------------------------------------------------------------------------

module_gene_choices <- merge(
  mapping[
    ,
    .(
      final_module_id,
      final_module_label,
      module_direction,
      requested_symbol,
      requested_entrez,
      mapped,
      mapping_rule,
      rescued_by_entrez,
      accepted_probe_count,
      accepted_probe_ids
    )
  ],
  primary_choices[
    ,
    .(
      requested_entrez,
      selected_probe_id =
        probe_id,
      selected_platform_symbol =
        platform_symbol,
      selected_platform_entrez =
        platform_entrez,
      selected_probe_mean_expression =
        all_sample_mean_expression,
      selected_probe_median_expression =
        all_sample_median_expression,
      selected_probe_expression_variance =
        all_sample_expression_variance,
      selected_probe_expression_sd =
        all_sample_expression_sd,
      median_tie_count =
        primary_rule_tie_count,
      selection_rule,
      selection_reference_population,
      representative_probe_frozen
    )
  ],
  by = "requested_entrez",
  all.x = TRUE
)

module_gene_choices[
  ,
  module_order := match(
    final_module_id,
    expected_module_ids
  )
]

setorder(
  module_gene_choices,
  module_order,
  requested_symbol,
  requested_entrez
)

module_gene_choices[
  ,
  module_order := NULL
]

if (
  nrow(module_gene_choices) !=
    expected_module_gene_instances
) {
  stop(
    "The module-gene probe-choice table does not contain 313 rows."
  )
}

if (
  anyNA(
    module_gene_choices[
      mapped == TRUE,
      selected_probe_id
    ]
  )
) {
  stop(
    "At least one mapped module-gene instance lacks a selected probe."
  )
}

if (
  any(
    !is.na(
      module_gene_choices[
        mapped == FALSE,
        selected_probe_id
      ]
    )
  )
) {
  stop(
    "An unmapped module-gene instance unexpectedly received a probe."
  )
}


# -------------------------------------------------------------------------
# Probe multiplicity summary
# -------------------------------------------------------------------------

module_instance_multiplicity <- mapping[
  ,
  .(
    module_gene_instances = .N
  ),
  by = accepted_probe_count
]

setorder(
  module_instance_multiplicity,
  accepted_probe_count
)

gene_level_multiplicity <- gene_definitions[
  ,
  .(
    unique_mapped_genes = .N
  ),
  by = accepted_probe_count
]

setorder(
  gene_level_multiplicity,
  accepted_probe_count
)

multiplicity_summary <- rbindlist(
  list(
    module_instance_multiplicity[
      ,
      .(
        analysis_level =
          "module_gene_instance",
        accepted_probe_count,
        count =
          module_gene_instances
      )
    ],
    gene_level_multiplicity[
      ,
      .(
        analysis_level =
          "unique_entrez_gene",
        accepted_probe_count,
        count =
          unique_mapped_genes
      )
    ]
  ),
  use.names = TRUE,
  fill = TRUE
)

setorder(
  multiplicity_summary,
  analysis_level,
  accepted_probe_count
)


# -------------------------------------------------------------------------
# Design lock
# -------------------------------------------------------------------------

median_vs_variance_same_count <- choice_comparison[
  same_probe_selected == TRUE,
  .N
]

median_vs_variance_different_count <- choice_comparison[
  same_probe_selected == FALSE,
  .N
]

unique_mapped_gene_count <- nrow(
  primary_choices
)

multi_probe_unique_gene_count <- gene_definitions[
  accepted_probe_count > 1L,
  .N
]

single_probe_unique_gene_count <- gene_definitions[
  accepted_probe_count == 1L,
  .N
]

design_lock <- data.table(
  candidate_dataset =
    "GSE72810",
  platform =
    "GPL6947",
  representative_probe_rule =
    paste0(
      "Select the Entrez-authorized probe with the highest ",
      "median expression across all 146 samples."
    ),
  exact_tie_breaker =
    "Lexicographically smallest Illumina probe ID",
  compatibility_basis =
    paste0(
      "Matches the representative-probe principle used in ",
      "the submitted GSE73461 fixed-module projection."
    ),
  probe_choice_reference_population =
    "All 146 GSE72810 samples",
  representative_probe_reselection =
    "Not permitted after this design lock",
  primary_z_reference_population =
    "All 146 GSE72810 samples",
  primary_pathogen_contrast =
    "23 Definite Bacterial versus 28 Definite Viral",
  primary_module_scoring_rule =
    paste0(
      "Gene-wise z-score of frozen representative probes; ",
      "unweighted mean across mapped genes in each locked module."
    ),
  primary_only_z_reference_sensitivity =
    paste0(
      "Reuse frozen representative probes; calculate gene-wise ",
      "z-scores using only the 51 definite bacterial and viral samples."
    ),
  expanded_case_sensitivity =
    paste0(
      "Reuse frozen representative probes and all-sample z-reference; ",
      "compare 40 definite-plus-probable bacterial versus ",
      "35 definite-plus-probable viral samples."
    ),
  all_probe_mean_sensitivity =
    paste0(
      "For each mapped gene, average all Entrez-authorized probes ",
      "before gene-wise z-standardization; do not reselect modules."
    ),
  unmapped_gene_handling =
    paste0(
      "Ignore unavailable genes, report module-specific coverage, ",
      "and retain the locked module definitions."
    ),
  module_reselection =
    "Not permitted",
  gene_reweighting =
    "Not permitted",
  module_renaming =
    "Not permitted",
  diagnostic_model_training =
    "Not permitted",
  total_samples =
    nrow(metadata),
  primary_samples =
    length(primary_sample_ids),
  expanded_samples =
    length(expanded_sample_ids),
  locked_module_gene_instances =
    nrow(mapping),
  mapped_module_gene_instances =
    sum(mapping$mapped),
  unmapped_module_gene_instances =
    sum(!mapping$mapped),
  unique_mapped_entrez_genes =
    unique_mapped_gene_count,
  single_probe_unique_genes =
    single_probe_unique_gene_count,
  multi_probe_unique_genes =
    multi_probe_unique_gene_count,
  median_vs_variance_same_choice =
    median_vs_variance_same_count,
  median_vs_variance_different_choice =
    median_vs_variance_different_count,
  design_status =
    "LOCKED_READY_FOR_FIXED_MODULE_SCORING"
)


# -------------------------------------------------------------------------
# Quality gate
# -------------------------------------------------------------------------

quality_checks <- data.table(
  check_id = c(
    "Q01",
    "Q02",
    "Q03",
    "Q04",
    "Q05",
    "Q06",
    "Q07",
    "Q08",
    "Q09",
    "Q10",
    "Q11",
    "Q12",
    "Q13",
    "Q14"
  ),
  check_description = c(
    "Expression matrix contains 48,803 unique probes",
    "Expression matrix contains 146 ordered samples",
    "Expression and metadata sample orders match",
    "Locked module mapping contains 313 instances",
    "Mapped module-gene instances equal 303",
    "Unmapped module-gene instances equal 10",
    "Candidate probes are present in the expression matrix",
    "Candidate gene-probe keys are unique",
    "No accepted probe maps to multiple locked Entrez genes",
    "One frozen representative probe exists per mapped Entrez gene",
    "All mapped module-gene instances receive a frozen probe",
    "No unmapped module-gene instance receives a probe",
    "Primary selection uses all-sample median expression",
    "Primary tie-breaker is lexicographically smallest probe ID"
  ),
  pass = c(
    nrow(expression_dt) ==
      expected_feature_rows &&
      !anyDuplicated(expression_dt$ID_REF),
    length(sample_columns) ==
      expected_total_samples,
    identical(
      sample_columns,
      metadata$geo_accession
    ),
    nrow(mapping) ==
      expected_module_gene_instances,
    sum(mapping$mapped) ==
      expected_mapped_module_gene_instances,
    sum(!mapping$mapped) ==
      expected_unmapped_module_gene_instances,
    !anyNA(candidate_expression_index),
    !anyDuplicated(
      candidate_map[
        ,
        .(
          requested_entrez,
          probe_id
        )
      ]
    ),
    nrow(probe_gene_conflicts) == 0L,
    nrow(primary_choices) ==
      uniqueN(
        mapped_rows$requested_entrez
      ) &&
      !anyDuplicated(
        primary_choices$
          requested_entrez
      ),
    !anyNA(
      module_gene_choices[
        mapped == TRUE,
        selected_probe_id
      ]
    ),
    !any(
      !is.na(
        module_gene_choices[
          mapped == FALSE,
          selected_probe_id
        ]
      )
    ),
    all(
      primary_choices$
        selection_reference_population ==
        "All 146 GSE72810 samples"
    ),
    all(
      primary_choices$
        selection_rule ==
        paste0(
          "Highest median expression across all 146 samples; ",
          "lexicographically smallest probe ID for exact ties"
        )
    )
  )
)

quality_gate_pass <- all(
  quality_checks$pass
)

quality_gate <- data.table(
  total_checks =
    nrow(quality_checks),
  passed_checks =
    sum(quality_checks$pass),
  failed_checks =
    sum(!quality_checks$pass),
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  design_status =
    ifelse(
      quality_gate_pass,
      "LOCKED_READY_FOR_FIXED_MODULE_SCORING",
      "NOT_LOCKED_REVIEW_REQUIRED"
    )
)


# -------------------------------------------------------------------------
# Write outputs
# -------------------------------------------------------------------------

setorder(
  candidate_statistics,
  requested_symbol,
  requested_entrez,
  -all_sample_median_expression,
  probe_id
)

fwrite(
  candidate_statistics,
  candidate_statistics_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  primary_choices,
  unique_gene_choice_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  module_gene_choices,
  module_gene_choice_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  variance_choices,
  variance_choice_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  choice_comparison,
  choice_comparison_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  multiplicity_summary,
  multiplicity_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  design_lock,
  design_lock_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  quality_checks,
  quality_gate_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Report
# -------------------------------------------------------------------------

multiplicity_preview <- capture.output(
  print(multiplicity_summary)
)

choice_difference_preview <- capture.output(
  print(
    choice_comparison[
      same_probe_selected == FALSE,
      .(
        requested_symbol,
        requested_entrez,
        candidate_probe_count,
        median_rule_probe_id,
        variance_rule_probe_id,
        median_rule_probe_median,
        variance_rule_probe_median,
        median_rule_probe_variance,
        variance_rule_probe_variance
      )
    ]
  )
)

quality_preview <- capture.output(
  print(quality_checks)
)

report_lines <- c(
  "# GSE72810 representative-probe rule and scoring-design lock",
  "",
  "## Locked primary representative-probe rule",
  "",
  paste(
    "For every mapped locked gene, only probes accepted by the",
    "Entrez-authoritative reconciliation were eligible. The probe",
    "with the highest median expression across all 146 GSE72810",
    "samples was selected. Exact ties were resolved using the",
    "lexicographically smallest Illumina probe identifier."
  ),
  "",
  paste(
    "The representative probes produced here are frozen and must",
    "be reused in the primary projection, primary-only z-reference",
    "sensitivity, expanded definite-plus-probable sensitivity,",
    "effect-size analysis and later robustness analyses."
  ),
  "",
  "## Compatibility rationale",
  "",
  paste(
    "The submitted GSE73461 projection used highest median",
    "expression across projection samples followed by probe-ID",
    "tie-breaking. The GSE72810 rule preserves this principle and",
    "is phenotype-blind because all 146 samples contribute to the",
    "probe-selection statistic."
  ),
  "",
  "## Probe multiplicity",
  "",
  "```text",
  multiplicity_preview,
  "```",
  "",
  "## Median-rule versus variance-rule differences",
  "",
  paste0(
    "- Same probe selected: ",
    median_vs_variance_same_count,
    " unique mapped genes."
  ),
  paste0(
    "- Different probe selected: ",
    median_vs_variance_different_count,
    " unique mapped genes."
  ),
  "",
  "```text",
  choice_difference_preview,
  "```",
  "",
  "## Locked scoring populations",
  "",
  "- Primary z-reference: all 146 samples.",
  "- Primary contrast: 23 definite bacterial versus 28 definite viral.",
  paste(
    "- Primary-only z-reference sensitivity: the 51 definite",
    "bacterial and viral samples, using the same frozen probes."
  ),
  paste(
    "- Expanded phenotype sensitivity: 40 definite-plus-probable",
    "bacterial versus 35 definite-plus-probable viral samples."
  ),
  paste(
    "- Probe-collapse sensitivity: mean expression across all",
    "Entrez-authorized probes for each gene before z-standardization."
  ),
  "",
  "## Quality gate",
  "",
  "```text",
  quality_preview,
  "```",
  "",
  paste0(
    "- Quality gate: `",
    quality_gate$quality_gate,
    "`."
  ),
  paste0(
    "- Design status: `",
    quality_gate$design_status,
    "`."
  )
)

writeLines(
  report_lines,
  report_file
)

session_lines <- capture.output(
  sessionInfo()
)

session_lines <- sub(
  "[ \t]+$",
  "",
  session_lines
)

writeLines(
  session_lines,
  session_file
)


# -------------------------------------------------------------------------
# Console summary
# -------------------------------------------------------------------------

cat(
  "===== GSE72810 REPRESENTATIVE-PROBE DESIGN LOCK =====\n"
)

cat(
  "total_samples\t",
  nrow(metadata),
  "\n",
  sep = ""
)

cat(
  "primary_samples\t",
  length(primary_sample_ids),
  "\n",
  sep = ""
)

cat(
  "expanded_samples\t",
  length(expanded_sample_ids),
  "\n",
  sep = ""
)

cat(
  "locked_module_gene_instances\t",
  nrow(mapping),
  "\n",
  sep = ""
)

cat(
  "mapped_module_gene_instances\t",
  sum(mapping$mapped),
  "\n",
  sep = ""
)

cat(
  "unmapped_module_gene_instances\t",
  sum(!mapping$mapped),
  "\n",
  sep = ""
)

cat(
  "unique_mapped_entrez_genes\t",
  unique_mapped_gene_count,
  "\n",
  sep = ""
)

cat(
  "single_probe_unique_genes\t",
  single_probe_unique_gene_count,
  "\n",
  sep = ""
)

cat(
  "multi_probe_unique_genes\t",
  multi_probe_unique_gene_count,
  "\n",
  sep = ""
)

cat(
  "median_vs_variance_same_choice\t",
  median_vs_variance_same_count,
  "\n",
  sep = ""
)

cat(
  "median_vs_variance_different_choice\t",
  median_vs_variance_different_count,
  "\n",
  sep = ""
)

cat(
  "quality_checks_passed\t",
  sum(quality_checks$pass),
  "/",
  nrow(quality_checks),
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  quality_gate$quality_gate,
  "\n",
  sep = ""
)

cat(
  "design_status\t",
  quality_gate$design_status,
  "\n",
  sep = ""
)

cat(
  "frozen_probe_choices\t",
  unique_gene_choice_file,
  "\n",
  sep = ""
)

cat(
  "module_gene_probe_choices\t",
  module_gene_choice_file,
  "\n",
  sep = ""
)

cat(
  "design_lock\t",
  design_lock_file,
  "\n",
  sep = ""
)

cat(
  "report\t",
  report_file,
  "\n",
  sep = ""
)

if (!quality_gate_pass) {
  stop(
    "The representative-probe design failed its quality gate."
  )
}
