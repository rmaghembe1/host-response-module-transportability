#!/usr/bin/env Rscript

# GSE72810 metadata harmonization and locked-module coverage audit.
#
# This script does not score modules. It:
#   1. parses the processed GEO series matrix and family SOFT metadata;
#   2. constructs a deterministic sample-level metadata table;
#   3. verifies the definite/probable/uncertain/control group structure;
#   4. verifies matrix-to-platform probe mapping;
#   5. maps locked module genes to GPL6947 probes present in the matrix;
#   6. determines readiness for fixed-module scoring.


# -------------------------------------------------------------------------
# Library paths and package
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
# Files and directories
# -------------------------------------------------------------------------

matrix_file <- paste0(
  "data/expression_raw/GSE72810/",
  "GSE72810_series_matrix.txt.gz"
)

soft_file <- paste0(
  "data/metadata_raw/GSE72810/",
  "GSE72810_family.soft.gz"
)

platform_file <- paste0(
  "data/metadata_raw/GSE72810/",
  "GPL6947_platform_table_from_GSE72810_family.tsv"
)

module_file <- paste0(
  "results/module_scoring/GSE211567_projection_ready_inputs/",
  "GSE211567_projection_ready_module_gene_table.tsv"
)

harmonized_dir <- "data/metadata_harmonized"

out_dir <- paste0(
  "results/revision_round1/",
  "GSE72810_candidate_validation_audit"
)

docs_dir <- "docs/revision_round1"
session_dir <- "env/session_info/revision_round1"

dir.create(
  harmonized_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

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

metadata_file <- file.path(
  harmonized_dir,
  "GSE72810_sample_metadata_harmonized.tsv"
)

group_summary_file <- file.path(
  out_dir,
  "GSE72810_sample_group_summary.tsv"
)

structural_summary_file <- file.path(
  out_dir,
  "GSE72810_structural_summary.tsv"
)

platform_summary_file <- file.path(
  out_dir,
  "GSE72810_platform_annotation_summary.tsv"
)

module_mapping_file <- file.path(
  out_dir,
  "GSE72810_locked_module_gene_probe_mapping.tsv"
)

module_coverage_file <- file.path(
  out_dir,
  "GSE72810_locked_module_gene_coverage.tsv"
)

decision_file <- file.path(
  out_dir,
  "GSE72810_candidate_validation_decision.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE72810_candidate_validation_audit_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE72810_candidate_validation_audit_sessionInfo.txt"
)


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------

expected_module_ids <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

expected_locked_counts <- data.table(
  final_module_id = expected_module_ids,
  expected_locked_gene_count = c(
    25L,
    21L,
    128L,
    33L,
    106L
  )
)

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

expected_sample_count <- 146L
expected_feature_count <- 48803L
minimum_primary_coverage <- 0.50
minimum_high_coverage <- 0.70


# -------------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------------

strip_quotes <- function(x) {
  x <- trimws(as.character(x))
  sub('^"(.*)"$', "\\1", x)
}

normalise_text <- function(x) {
  trimws(
    gsub(
      "[[:space:]]+",
      " ",
      as.character(x)
    )
  )
}

require_columns <- function(
  dt,
  required,
  source_name
) {
  missing_columns <- setdiff(
    required,
    names(dt)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste(
        "Missing columns in",
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

extract_single_metadata_row <- function(
  metadata_rows,
  key,
  expected_length
) {
  rows <- metadata_rows[[key]]

  if (is.null(rows) || length(rows) != 1L) {
    stop(
      paste(
        "Expected exactly one metadata row for",
        key
      )
    )
  }

  values <- rows[[1L]]

  if (length(values) != expected_length) {
    stop(
      paste(
        "Unexpected value count for",
        key,
        ":",
        length(values)
      )
    )
  }

  values
}


# -------------------------------------------------------------------------
# Parse the GEO series matrix without loading the expression matrix
# -------------------------------------------------------------------------

parse_series_matrix <- function(path) {
  connection <- gzfile(
    path,
    open = "rt"
  )

  on.exit(
    close(connection),
    add = TRUE
  )

  metadata_rows <- list()
  feature_id_chunks <- list()

  in_table <- FALSE
  table_header_read <- FALSE
  matrix_sample_ids <- NULL
  feature_chunk_index <- 0L
  finished <- FALSE

  repeat {
    lines <- readLines(
      connection,
      n = 1000L,
      warn = FALSE
    )

    if (length(lines) == 0L) {
      break
    }

    for (line in lines) {
      if (!in_table) {
        if (identical(
          line,
          "!series_matrix_table_begin"
        )) {
          in_table <- TRUE
          next
        }

        if (startsWith(
          line,
          "!Sample_"
        )) {
          fields <- strsplit(
            line,
            "\t",
            fixed = TRUE
          )[[1L]]

          key <- fields[1L]
          values <- strip_quotes(
            fields[-1L]
          )

          if (is.null(metadata_rows[[key]])) {
            metadata_rows[[key]] <- list()
          }

          metadata_rows[[key]][[
            length(metadata_rows[[key]]) + 1L
          ]] <- values
        }

        next
      }

      if (identical(
        line,
        "!series_matrix_table_end"
      )) {
        finished <- TRUE
        break
      }

      fields <- strsplit(
        line,
        "\t",
        fixed = TRUE
      )[[1L]]

      if (!table_header_read) {
        first_field <- strip_quotes(
          fields[1L]
        )

        if (!identical(
          first_field,
          "ID_REF"
        )) {
          stop(
            paste(
              "Unexpected matrix header:",
              first_field
            )
          )
        }

        matrix_sample_ids <- strip_quotes(
          fields[-1L]
        )

        table_header_read <- TRUE
        next
      }

      feature_id <- strip_quotes(
        fields[1L]
      )

      feature_chunk_index <-
        feature_chunk_index + 1L

      feature_id_chunks[[
        feature_chunk_index
      ]] <- feature_id
    }

    if (finished) {
      break
    }
  }

  if (!table_header_read) {
    stop(
      "The series-matrix expression table was not detected."
    )
  }

  list(
    metadata_rows = metadata_rows,
    matrix_sample_ids = matrix_sample_ids,
    feature_ids = unlist(
      feature_id_chunks,
      use.names = FALSE
    )
  )
}


# -------------------------------------------------------------------------
# Parse the SOFT sample accession-title map
# -------------------------------------------------------------------------

parse_soft_sample_map <- function(path) {
  connection <- gzfile(
    path,
    open = "rt"
  )

  on.exit(
    close(connection),
    add = TRUE
  )

  current_gsm <- NA_character_
  gsm_values <- character()
  title_values <- character()

  repeat {
    lines <- readLines(
      connection,
      n = 2000L,
      warn = FALSE
    )

    if (length(lines) == 0L) {
      break
    }

    for (line in lines) {
      if (startsWith(
        line,
        "^SAMPLE = "
      )) {
        current_gsm <- trimws(
          sub(
            "^\\^SAMPLE = ",
            "",
            line
          )
        )

        next
      }

      if (
        !is.na(current_gsm) &&
          startsWith(
            line,
            "!Sample_title = "
          )
      ) {
        gsm_values <- c(
          gsm_values,
          current_gsm
        )

        title_values <- c(
          title_values,
          sub(
            "^!Sample_title = ",
            "",
            line
          )
        )
      }
    }
  }

  data.table(
    geo_accession = gsm_values,
    soft_title = title_values
  )
}


# -------------------------------------------------------------------------
# Validate inputs
# -------------------------------------------------------------------------

required_files <- c(
  matrix_file,
  soft_file,
  platform_file,
  module_file
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
# Parse matrix metadata and feature identifiers
# -------------------------------------------------------------------------

message(
  "Parsing GSE72810 series-matrix metadata and probe identifiers..."
)

matrix_parsed <- parse_series_matrix(
  matrix_file
)

matrix_sample_ids <-
  matrix_parsed$matrix_sample_ids

feature_ids <-
  matrix_parsed$feature_ids

metadata_rows <-
  matrix_parsed$metadata_rows

if (
  length(matrix_sample_ids) !=
    expected_sample_count ||
    anyDuplicated(matrix_sample_ids)
) {
  stop(
    "Matrix sample IDs failed count or uniqueness checks."
  )
}

if (
  length(feature_ids) !=
    expected_feature_count ||
    uniqueN(feature_ids) !=
      expected_feature_count
) {
  stop(
    "Matrix probe IDs failed count or uniqueness checks."
  )
}

metadata_geo_accessions <-
  extract_single_metadata_row(
    metadata_rows,
    "!Sample_geo_accession",
    expected_sample_count
  )

if (!identical(
  matrix_sample_ids,
  metadata_geo_accessions
)) {
  stop(
    "Matrix header sample order does not match the metadata accession order."
  )
}


# -------------------------------------------------------------------------
# Construct harmonized sample metadata
# -------------------------------------------------------------------------

sample_metadata <- data.table(
  sample_order =
    seq_len(expected_sample_count),
  geo_accession =
    matrix_sample_ids,
  sample_title =
    extract_single_metadata_row(
      metadata_rows,
      "!Sample_title",
      expected_sample_count
    ),
  source_name =
    extract_single_metadata_row(
      metadata_rows,
      "!Sample_source_name_ch1",
      expected_sample_count
    ),
  organism =
    extract_single_metadata_row(
      metadata_rows,
      "!Sample_organism_ch1",
      expected_sample_count
    ),
  platform_id =
    extract_single_metadata_row(
      metadata_rows,
      "!Sample_platform_id",
      expected_sample_count
    )
)

characteristic_rows <-
  metadata_rows[[
    "!Sample_characteristics_ch1"
  ]]

if (
  is.null(characteristic_rows) ||
    length(characteristic_rows) == 0L
) {
  stop(
    "No sample characteristics were recovered."
  )
}

normalise_characteristic_key <- function(x) {
  key <- tolower(
    gsub(
      "[^A-Za-z0-9]+",
      "_",
      trimws(as.character(x))
    )
  )

  gsub(
    "^_+|_+$",
    "",
    key
  )
}

characteristic_long_rows <- vector(
  "list",
  length(characteristic_rows)
)

for (
  characteristic_row_index in
    seq_along(characteristic_rows)
) {
  characteristic_row <-
    characteristic_rows[[
      characteristic_row_index
    ]]

  if (
    length(characteristic_row) !=
      expected_sample_count
  ) {
    stop(
      paste(
        "Sample-characteristic row",
        characteristic_row_index,
        "has",
        length(characteristic_row),
        "values instead of",
        expected_sample_count
      )
    )
  }

  characteristic_row <-
    as.character(characteristic_row)

  has_delimiter <- grepl(
    ":",
    characteristic_row,
    fixed = TRUE
  )

  nonempty_without_delimiter <- (
    !has_delimiter &
      !is.na(characteristic_row) &
      nzchar(trimws(characteristic_row))
  )

  if (any(nonempty_without_delimiter)) {
    stop(
      paste(
        "Sample-characteristic row",
        characteristic_row_index,
        "contains a nonempty value without a key-value delimiter."
      )
    )
  }

  key_original <- rep(
    NA_character_,
    expected_sample_count
  )

  characteristic_value <- rep(
    NA_character_,
    expected_sample_count
  )

  key_original[has_delimiter] <- trimws(
    sub(
      ":.*$",
      "",
      characteristic_row[has_delimiter]
    )
  )

  characteristic_value[has_delimiter] <- trimws(
    sub(
      "^[^:]+:[[:space:]]*",
      "",
      characteristic_row[has_delimiter]
    )
  )

  characteristic_key <-
    normalise_characteristic_key(
      key_original
    )

  keep <- (
    has_delimiter &
      !is.na(characteristic_key) &
      nzchar(characteristic_key)
  )

  characteristic_long_rows[[
    characteristic_row_index
  ]] <- data.table(
    sample_order =
      seq_len(expected_sample_count)[keep],
    characteristic_row =
      characteristic_row_index,
    characteristic_key_original =
      key_original[keep],
    characteristic_key =
      characteristic_key[keep],
    characteristic_value =
      characteristic_value[keep]
  )
}

characteristic_long <- rbindlist(
  characteristic_long_rows,
  use.names = TRUE,
  fill = TRUE
)

if (nrow(characteristic_long) == 0L) {
  stop(
    "No keyed sample-characteristic values were recovered."
  )
}

characteristic_conflict_check <-
  characteristic_long[
    ,
    .(
      entry_count = .N,
      unique_value_count =
        uniqueN(characteristic_value)
    ),
    by = .(
      sample_order,
      characteristic_key
    )
  ]

characteristic_conflicts <-
  characteristic_conflict_check[
    unique_value_count > 1L
  ]

if (nrow(characteristic_conflicts) > 0L) {
  print(
    characteristic_conflicts[
      order(
        sample_order,
        characteristic_key
      )
    ]
  )

  stop(
    paste(
      "Conflicting values were recovered for at least one",
      "sample-characteristic key."
    )
  )
}

characteristic_keys <- sort(
  unique(
    characteristic_long$
      characteristic_key
  )
)

for (column_name in characteristic_keys) {
  key_values <- characteristic_long[
    characteristic_key ==
      column_name,
    .(
      characteristic_value =
        characteristic_value[1L]
    ),
    by = sample_order
  ]

  values_vector <- rep(
    NA_character_,
    expected_sample_count
  )

  values_vector[
    key_values$sample_order
  ] <- key_values$characteristic_value

  set(
    sample_metadata,
    j = column_name,
    value = values_vector
  )
}


required_metadata_columns <- c(
  "category",
  "dataset",
  "gender",
  "tissue"
)

require_columns(
  sample_metadata,
  required_metadata_columns,
  "GSE72810 harmonized metadata"
)

sample_metadata[
  ,
  sample_title :=
    normalise_text(sample_title)
]

sample_metadata[
  ,
  source_name :=
    normalise_text(source_name)
]

sample_metadata[
  ,
  tissue_normalized :=
    tolower(
      normalise_text(tissue)
    )
]

sample_metadata[
  ,
  sex :=
    gender
]

sample_metadata[
  ,
  projection_role := fcase(
    category == "Definite Bacterial",
    "primary_bacterial",
    category == "Definite Viral",
    "primary_viral",
    category == "Probable Bacterial",
    "sensitivity_bacterial",
    category == "Probable Viral",
    "sensitivity_viral",
    category == "Control",
    "secondary_control_context",
    category == "Uncertain",
    "uncertain_excluded",
    default = "unresolved"
  )
]

sample_metadata[
  ,
  include_primary_definite :=
    category %in% c(
      "Definite Bacterial",
      "Definite Viral"
    )
]

sample_metadata[
  ,
  include_expanded_definite_probable :=
    category %in% c(
      "Definite Bacterial",
      "Definite Viral",
      "Probable Bacterial",
      "Probable Viral"
    )
]

sample_metadata[
  ,
  include_all_sample_reference :=
    TRUE
]

sample_metadata[
  ,
  title_category := fcase(
    grepl(
      "^Definite Bacterial_",
      sample_title
    ),
    "Definite Bacterial",
    grepl(
      "^Definite Viral_",
      sample_title
    ),
    "Definite Viral",
    grepl(
      "^Probable Bacterial_",
      sample_title
    ),
    "Probable Bacterial",
    grepl(
      "^Probable Viral_",
      sample_title
    ),
    "Probable Viral",
    grepl(
      "^Unknown_",
      sample_title
    ),
    "Uncertain",
    grepl(
      "^Control_",
      sample_title
    ),
    "Control",
    default = "unresolved"
  )
]

sample_metadata[
  ,
  title_category_matches_characteristic :=
    title_category == category
]


# -------------------------------------------------------------------------
# Verify SOFT and matrix sample identities
# -------------------------------------------------------------------------

message(
  "Parsing GSE72810 SOFT sample records..."
)

soft_sample_map <- parse_soft_sample_map(
  soft_file
)

if (
  nrow(soft_sample_map) !=
    expected_sample_count ||
    anyDuplicated(
      soft_sample_map$geo_accession
    )
) {
  stop(
    "SOFT sample map failed count or uniqueness checks."
  )
}

soft_matrix_comparison <- merge(
  sample_metadata[
    ,
    .(
      geo_accession,
      matrix_title = sample_title
    )
  ],
  soft_sample_map,
  by = "geo_accession",
  all = TRUE
)

soft_matrix_comparison[
  ,
  title_match :=
    matrix_title ==
      soft_title
]

soft_matrix_accession_pass <- (
  nrow(soft_matrix_comparison) ==
    expected_sample_count &&
    !anyNA(
      soft_matrix_comparison$
        matrix_title
    ) &&
    !anyNA(
      soft_matrix_comparison$
        soft_title
    )
)

soft_matrix_title_pass <- (
  soft_matrix_accession_pass &&
    all(
      soft_matrix_comparison$
        title_match
    )
)


# -------------------------------------------------------------------------
# Group and metadata checks
# -------------------------------------------------------------------------

group_summary <- sample_metadata[
  ,
  .(
    observed_n = .N
  ),
  by = category
]

group_summary <- merge(
  expected_group_counts,
  group_summary,
  by = "category",
  all = TRUE
)

group_summary[
  ,
  count_match :=
    expected_n ==
      observed_n
]

group_summary[
  ,
  group_order := match(
    category,
    expected_group_counts$category
  )
]

setorder(
  group_summary,
  group_order
)

group_summary[
  ,
  group_order := NULL
]

group_count_pass <- (
  nrow(group_summary) == 6L &&
    all(
      group_summary$count_match
    )
)

required_metadata_pass <- (
  all(
    sample_metadata$organism ==
      "Homo sapiens"
  ) &&
    all(
      sample_metadata$platform_id ==
        "GPL6947"
    ) &&
    all(
      sample_metadata$dataset ==
        "Validation"
    ) &&
    all(
      sample_metadata$
        tissue_normalized ==
        "whole blood"
    ) &&
    all(
      sample_metadata$
        projection_role !=
        "unresolved"
    ) &&
    all(
      sample_metadata$
        title_category_matches_characteristic
    )
)


# -------------------------------------------------------------------------
# Read and validate platform annotation
# -------------------------------------------------------------------------

message(
  "Reading GPL6947 platform annotation..."
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
    "Entrez_Gene_ID"
  ),
  platform_file
)

platform[
  ,
  ID :=
    as.character(ID)
]

platform[
  ,
  Symbol :=
    as.character(Symbol)
]

platform[
  ,
  Entrez_Gene_ID :=
    as.character(Entrez_Gene_ID)
]

if (anyDuplicated(platform$ID)) {
  stop(
    "GPL6947 platform annotation contains duplicated probe IDs."
  )
}

platform_match_index <- match(
  feature_ids,
  platform$ID
)

matrix_ids_missing_from_platform <- sum(
  is.na(platform_match_index)
)

matrix_to_platform_pass <- (
  matrix_ids_missing_from_platform == 0L
)

matrix_platform <- platform[
  platform_match_index
]

matrix_platform[
  ,
  ID_REF :=
    feature_ids
]

if (
  matrix_to_platform_pass &&
    any(
      matrix_platform$ID !=
        matrix_platform$ID_REF
    )
) {
  stop(
    "Matrix-to-platform probe order reconstruction failed."
  )
}


# -------------------------------------------------------------------------
# Parse symbol mappings
# -------------------------------------------------------------------------

split_symbol_string <- function(x) {
  if (
    is.na(x) ||
      !nzchar(trimws(x))
  ) {
    return(character())
  }

  values <- unlist(
    strsplit(
      x,
      "\\s*(?:///|//|;|,|\\|)\\s*",
      perl = TRUE
    ),
    use.names = FALSE
  )

  values <- trimws(values)

  values <- values[
    nzchar(values) &
      !values %in% c(
        "NA",
        "---",
        "NULL"
      )
  ]

  unique(values)
}

symbol_lists <- lapply(
  matrix_platform$Symbol,
  split_symbol_string
)

symbol_count_per_probe <- lengths(
  symbol_lists
)

probe_symbol_rows <- vector(
  "list",
  length(symbol_lists)
)

for (row_index in seq_along(
  symbol_lists
)) {
  symbols <- symbol_lists[[
    row_index
  ]]

  if (length(symbols) == 0L) {
    next
  }

  probe_symbol_rows[[
    row_index
  ]] <- data.table(
    ID_REF =
      matrix_platform$ID_REF[row_index],
    SYMBOL_ORIGINAL =
      matrix_platform$Symbol[row_index],
    SYMBOL =
      symbols,
    SYMBOL_UPPER =
      toupper(symbols),
    ENTREZID =
      matrix_platform$
        Entrez_Gene_ID[row_index]
  )
}

probe_symbol_map <- rbindlist(
  probe_symbol_rows,
  use.names = TRUE,
  fill = TRUE
)

probe_symbol_map <- unique(
  probe_symbol_map[
    !is.na(SYMBOL_UPPER) &
      nzchar(SYMBOL_UPPER)
  ]
)

platform_summary <- data.table(
  metric = c(
    "platform_probe_rows",
    "matrix_feature_rows",
    "matrix_probe_IDs_mapped_to_platform",
    "matrix_probe_IDs_missing_from_platform",
    "platform_probe_IDs_absent_from_matrix",
    "matrix_probes_with_at_least_one_symbol",
    "matrix_probes_without_symbol",
    "matrix_probes_with_multiple_symbols",
    "unique_valid_symbol_tokens",
    "matrix_probes_with_entrez"
  ),
  value = c(
    nrow(platform),
    length(feature_ids),
    sum(!is.na(platform_match_index)),
    matrix_ids_missing_from_platform,
    nrow(platform) -
      length(feature_ids),
    sum(symbol_count_per_probe >= 1L),
    sum(symbol_count_per_probe == 0L),
    sum(symbol_count_per_probe > 1L),
    uniqueN(
      probe_symbol_map$SYMBOL_UPPER
    ),
    sum(
      !is.na(
        matrix_platform$
          Entrez_Gene_ID
      ) &
        nzchar(
          matrix_platform$
            Entrez_Gene_ID
        )
    )
  )
)


# -------------------------------------------------------------------------
# Read locked modules
# -------------------------------------------------------------------------

modules <- fread(
  module_file
)

require_columns(
  modules,
  c(
    "final_module_id",
    "final_module_label",
    "SYMBOL"
  ),
  module_file
)

if (
  !"final_module_direction" %in%
    names(modules)
) {
  if (
    "module_direction" %in%
      names(modules)
  ) {
    modules[
      ,
      final_module_direction :=
        as.character(
          module_direction
        )
    ]
  } else {
    modules[
      ,
      final_module_direction := fcase(
        grepl(
          "^BACT",
          final_module_id
        ),
        "higher_in_bacterial",
        grepl(
          "^VIR",
          final_module_id
        ),
        "higher_in_viral",
        default = "unresolved"
      )
    ]
  }
}

modules[
  ,
  final_module_id :=
    as.character(final_module_id)
]

modules[
  ,
  final_module_label :=
    as.character(final_module_label)
]

modules[
  ,
  final_module_direction :=
    as.character(
      final_module_direction
    )
]

modules[
  ,
  SYMBOL :=
    as.character(SYMBOL)
]

modules[
  ,
  SYMBOL_UPPER :=
    toupper(
      trimws(SYMBOL)
    )
]

modules <- unique(
  modules[
    final_module_id %in%
      expected_module_ids &
      !is.na(SYMBOL_UPPER) &
      nzchar(SYMBOL_UPPER),
    .(
      final_module_id,
      final_module_label,
      final_module_direction,
      SYMBOL,
      SYMBOL_UPPER
    )
  ]
)

locked_count_check <- modules[
  ,
  .(
    observed_locked_gene_count =
      uniqueN(SYMBOL_UPPER)
  ),
  by = final_module_id
]

locked_count_check <- merge(
  expected_locked_counts,
  locked_count_check,
  by = "final_module_id",
  all = TRUE
)

locked_count_check[
  ,
  locked_count_match :=
    expected_locked_gene_count ==
      observed_locked_gene_count
]

locked_module_count_pass <- (
  nrow(locked_count_check) == 5L &&
    all(
      locked_count_check$
        locked_count_match
    )
)


# -------------------------------------------------------------------------
# Locked-module probe mapping and coverage
# -------------------------------------------------------------------------

module_probe_mapping <- merge(
  modules,
  probe_symbol_map,
  by = "SYMBOL_UPPER",
  all.x = TRUE,
  allow.cartesian = TRUE
)

setorder(
  module_probe_mapping,
  final_module_id,
  SYMBOL_UPPER,
  ID_REF
)

module_coverage <- module_probe_mapping[
  ,
  {
    locked_symbols <- unique(
      SYMBOL_UPPER
    )

    mapped_symbols <- unique(
      SYMBOL_UPPER[
        !is.na(ID_REF)
      ]
    )

    missing_symbols <- sort(
      setdiff(
        locked_symbols,
        mapped_symbols
      )
    )

    list(
      locked_gene_count =
        length(locked_symbols),
      mapped_gene_count =
        length(mapped_symbols),
      missing_gene_count =
        length(missing_symbols),
      coverage_fraction =
        length(mapped_symbols) /
          length(locked_symbols),
      mapped_probe_count =
        uniqueN(
          na.omit(ID_REF)
        ),
      genes_with_multiple_probes =
        uniqueN(
          SYMBOL_UPPER[
            !is.na(ID_REF) &
              duplicated(
                paste(
                  final_module_id,
                  SYMBOL_UPPER
                )
              )
          ]
        ),
      missing_symbols = if (
        length(missing_symbols) == 0L
      ) {
        "none"
      } else {
        paste(
          missing_symbols,
          collapse = ";"
        )
      }
    )
  },
  by = .(
    final_module_id,
    final_module_label,
    final_module_direction
  )
]

module_coverage[
  ,
  eligible_at_50_percent :=
    coverage_fraction >=
      minimum_primary_coverage
]

module_coverage[
  ,
  high_coverage_at_70_percent :=
    coverage_fraction >=
      minimum_high_coverage
]

module_coverage[
  ,
  module_order := match(
    final_module_id,
    expected_module_ids
  )
]

setorder(
  module_coverage,
  module_order
)

module_coverage[
  ,
  module_order := NULL
]

module_coverage_pass_50 <- (
  nrow(module_coverage) == 5L &&
    all(
      module_coverage$
        eligible_at_50_percent
    )
)

module_coverage_pass_70 <- (
  nrow(module_coverage) == 5L &&
    all(
      module_coverage$
        high_coverage_at_70_percent
    )
)


# -------------------------------------------------------------------------
# Structural summary and final decision
# -------------------------------------------------------------------------

structural_summary <- data.table(
  metric = c(
    "matrix_sample_count",
    "soft_sample_count",
    "matrix_feature_count",
    "unique_matrix_feature_count",
    "soft_matrix_accession_match",
    "soft_matrix_title_match",
    "group_count_match",
    "required_metadata_complete",
    "matrix_to_platform_complete",
    "locked_module_count_match",
    "all_modules_eligible_at_50_percent",
    "all_modules_high_coverage_at_70_percent"
  ),
  value = c(
    length(matrix_sample_ids),
    nrow(soft_sample_map),
    length(feature_ids),
    uniqueN(feature_ids),
    soft_matrix_accession_pass,
    soft_matrix_title_pass,
    group_count_pass,
    required_metadata_pass,
    matrix_to_platform_pass,
    locked_module_count_pass,
    module_coverage_pass_50,
    module_coverage_pass_70
  )
)

quality_gate_pass <- (
  soft_matrix_accession_pass &&
    soft_matrix_title_pass &&
    group_count_pass &&
    required_metadata_pass &&
    matrix_to_platform_pass &&
    locked_module_count_pass &&
    module_coverage_pass_50
)

scoring_readiness <- if (
  quality_gate_pass &&
    module_coverage_pass_70
) {
  "READY_FOR_FIXED_MODULE_SCORING"
} else if (
  quality_gate_pass
) {
  "READY_WITH_LOW_COVERAGE_SENSITIVITY_REQUIRED"
} else {
  "REVIEW_BEFORE_SCORING"
}

candidate_role <- if (
  quality_gate_pass
) {
  paste0(
    "SECOND_INDEPENDENT_SAMPLE_COHORT_",
    "AND_CROSS_PLATFORM_VALIDATION"
  )
} else {
  "CANDIDATE_NOT_YET_LOCKED"
}

decision <- data.table(
  candidate_dataset =
    "GSE72810",
  tissue =
    "whole blood",
  platform =
    "GPL6947",
  total_samples =
    nrow(sample_metadata),
  primary_definite_bacterial =
    sample_metadata[
      category ==
        "Definite Bacterial",
      .N
    ],
  primary_definite_viral =
    sample_metadata[
      category ==
        "Definite Viral",
      .N
    ],
  expanded_bacterial =
    sample_metadata[
      category %in% c(
        "Definite Bacterial",
        "Probable Bacterial"
      ),
      .N
    ],
  expanded_viral =
    sample_metadata[
      category %in% c(
        "Definite Viral",
        "Probable Viral"
      ),
      .N
    ],
  controls =
    sample_metadata[
      category == "Control",
      .N
    ],
  uncertain_excluded =
    sample_metadata[
      category == "Uncertain",
      .N
    ],
  candidate_role =
    candidate_role,
  scoring_readiness =
    scoring_readiness,
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  participant_overlap_assessment =
    paste0(
      "Not directly assessable from GEO metadata: ",
      "no participant identifier was recovered."
    ),
  primary_analysis_rule =
    paste0(
      "Definite Bacterial versus Definite Viral; ",
      "no module reselection, reweighting or relabelling."
    ),
  sensitivity_rule =
    paste0(
      "Definite plus Probable bacterial versus ",
      "Definite plus Probable viral; controls contextual; ",
      "uncertain samples excluded from pathogen-class contrasts."
    )
)


# -------------------------------------------------------------------------
# Write outputs
# -------------------------------------------------------------------------

fwrite(
  sample_metadata,
  metadata_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  group_summary,
  group_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  structural_summary,
  structural_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  platform_summary,
  platform_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  module_probe_mapping,
  module_mapping_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  module_coverage,
  module_coverage_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  decision,
  decision_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Report
# -------------------------------------------------------------------------

coverage_preview <- capture.output(
  print(
    module_coverage[
      ,
      .(
        final_module_id,
        locked_gene_count,
        mapped_gene_count,
        missing_gene_count,
        coverage_fraction,
        mapped_probe_count,
        eligible_at_50_percent,
        high_coverage_at_70_percent,
        missing_symbols
      )
    ]
  )
)

group_preview <- capture.output(
  print(group_summary)
)

report_lines <- c(
  "# GSE72810 candidate validation audit",
  "",
  "## Cohort structure",
  "",
  paste0(
    "- Total samples: ",
    nrow(sample_metadata),
    "."
  ),
  paste0(
    "- Definite bacterial: ",
    sample_metadata[
      category == "Definite Bacterial",
      .N
    ],
    "."
  ),
  paste0(
    "- Definite viral: ",
    sample_metadata[
      category == "Definite Viral",
      .N
    ],
    "."
  ),
  paste0(
    "- Probable bacterial: ",
    sample_metadata[
      category == "Probable Bacterial",
      .N
    ],
    "."
  ),
  paste0(
    "- Probable viral: ",
    sample_metadata[
      category == "Probable Viral",
      .N
    ],
    "."
  ),
  paste0(
    "- Uncertain: ",
    sample_metadata[
      category == "Uncertain",
      .N
    ],
    "."
  ),
  paste0(
    "- Controls: ",
    sample_metadata[
      category == "Control",
      .N
    ],
    "."
  ),
  "",
  "## Structural validation",
  "",
  paste0(
    "- Matrix probes: ",
    length(feature_ids),
    "."
  ),
  paste0(
    "- Matrix samples: ",
    length(matrix_sample_ids),
    "."
  ),
  paste0(
    "- Matrix probes absent from GPL6947 annotation: ",
    matrix_ids_missing_from_platform,
    "."
  ),
  paste0(
    "- Matrix probes with multiple parsed symbols: ",
    sum(
      symbol_count_per_probe > 1L
    ),
    "."
  ),
  "",
  "## Sample groups",
  "",
  "```text",
  group_preview,
  "```",
  "",
  "## Locked-module coverage",
  "",
  "```text",
  coverage_preview,
  "```",
  "",
  "## Decision",
  "",
  paste0(
    "- Quality gate: `",
    decision$quality_gate,
    "`."
  ),
  paste0(
    "- Scoring readiness: `",
    decision$scoring_readiness,
    "`."
  ),
  paste0(
    "- Candidate role: `",
    decision$candidate_role,
    "`."
  ),
  "",
  paste(
    "The primary validation contrast is restricted to",
    "Definite Bacterial versus Definite Viral samples."
  ),
  "",
  paste(
    "Probable cases are reserved for an expanded sensitivity",
    "analysis. Controls provide contextual reference information,",
    "and uncertain-aetiology samples are excluded from",
    "pathogen-class contrasts."
  ),
  "",
  paste(
    "Participant overlap with another GEO accession cannot be",
    "excluded directly because no participant identifier was",
    "recovered from the deposited GSE72810 metadata."
  )
)

writeLines(
  sub(
    "[[:space:]]+$",
    "",
    report_lines
  ),
  report_file
)

writeLines(
  capture.output(
    sessionInfo()
  ),
  session_file
)


# -------------------------------------------------------------------------
# Console summary
# -------------------------------------------------------------------------

cat(
  "===== GSE72810 CANDIDATE VALIDATION AUDIT =====\n"
)

cat(
  "samples\t",
  nrow(sample_metadata),
  "\n",
  sep = ""
)

cat(
  "features\t",
  length(feature_ids),
  "\n",
  sep = ""
)

cat(
  "soft_matrix_accession_match\t",
  soft_matrix_accession_pass,
  "\n",
  sep = ""
)

cat(
  "soft_matrix_title_match\t",
  soft_matrix_title_pass,
  "\n",
  sep = ""
)

cat(
  "group_count_match\t",
  group_count_pass,
  "\n",
  sep = ""
)

cat(
  "matrix_to_platform_complete\t",
  matrix_to_platform_pass,
  "\n",
  sep = ""
)

cat(
  "modules_eligible_at_50_percent\t",
  sum(
    module_coverage$
      eligible_at_50_percent
  ),
  "/5\n",
  sep = ""
)

cat(
  "modules_high_coverage_at_70_percent\t",
  sum(
    module_coverage$
      high_coverage_at_70_percent
  ),
  "/5\n",
  sep = ""
)

cat(
  "scoring_readiness\t",
  scoring_readiness,
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  ifelse(
    quality_gate_pass,
    "PASS",
    "REVIEW"
  ),
  "\n",
  sep = ""
)

cat(
  "metadata\t",
  metadata_file,
  "\n",
  sep = ""
)

cat(
  "module_coverage\t",
  module_coverage_file,
  "\n",
  sep = ""
)

cat(
  "decision\t",
  decision_file,
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
    "GSE72810 candidate validation audit failed its quality gate."
  )
}
