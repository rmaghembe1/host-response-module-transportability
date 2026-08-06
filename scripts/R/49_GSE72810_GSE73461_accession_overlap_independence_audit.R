#!/usr/bin/env Rscript

# =========================================================================
# GSE72810-GSE73461 accession-overlap and independence-wording audit
# =========================================================================
#
# Purpose
#
# This script formally assesses the relationship between GSE72810 and
# GSE73461 before integrating GSE72810 as an additional external
# validation cohort.
#
# The audit distinguishes five questions:
#
# 1. Are deposited GEO sample accessions shared between the cohorts?
# 2. Are the deposited samples assigned to different GEO accessions?
# 3. Were the cohorts measured on different microarray platforms?
# 4. Can participant-level overlap be excluded from deposited metadata?
# 5. Do deposited contact fields support a shared investigator network?
#
# Important interpretation boundary
#
# A zero overlap between GSM accession sets establishes accession-level
# and deposited-sample-level separation. It does not prove that no person
# contributed to both studies when participant identifiers are absent.
#
# Reused descriptive labels such as Control_01 or DefiniteBacterial_01
# are cohort-local labels and are not treated as participant identifiers.
#
# The intended manuscript wording is:
#
# "GSE72810 was analysed as a second accession-level and sample-level
# cohort providing cross-platform validation."
#
# GSE72810 should not be described as fully investigator-independent when
# deposited contact information supports a shared broad research network.
# =========================================================================


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

gse72810_metadata_file <- paste0(
  "data/metadata_harmonized/",
  "GSE72810_sample_metadata_harmonized.tsv"
)

gse73461_soft_metadata_file <- paste0(
  "data/metadata_harmonized/",
  "GSE73461_GEO_family_SOFT_sample_metadata_flattened.tsv"
)

gse73461_matrix_metadata_file <- paste0(
  "data/metadata_harmonized/",
  "GSE73461_series_matrix_sample_metadata.tsv"
)

gse72810_family_soft_file <- paste0(
  "data/metadata_raw/GSE72810/",
  "GSE72810_family.soft.gz"
)


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE72810_GSE73461_overlap_independence_audit"
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

accession_inventory_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_accession_inventory.tsv"
)

accession_overlap_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_accession_overlap.tsv"
)

accession_summary_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_accession_overlap_summary.tsv"
)

title_overlap_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_title_label_overlap.tsv"
)

title_summary_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_title_label_overlap_summary.tsv"
)

platform_comparison_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_platform_comparison.tsv"
)

participant_audit_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_participant_identifier_audit.tsv"
)

contact_inventory_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_contact_inventory.tsv"
)

contact_overlap_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_shared_contact_network_evidence.tsv"
)

independence_assessment_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_independence_dimension_assessment.tsv"
)

wording_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_manuscript_wording_recommendations.tsv"
)

quality_checks_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_overlap_audit_quality_gate.tsv"
)

quality_summary_file <- file.path(
  out_dir,
  "GSE72810_GSE73461_overlap_audit_quality_summary.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE72810_GSE73461_accession_overlap_independence_audit_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE72810_GSE73461_accession_overlap_independence_audit_sessionInfo.txt"
)

output_files <- c(
  accession_inventory_file,
  accession_overlap_file,
  accession_summary_file,
  title_overlap_file,
  title_summary_file,
  platform_comparison_file,
  participant_audit_file,
  contact_inventory_file,
  contact_overlap_file,
  independence_assessment_file,
  wording_file,
  quality_checks_file,
  quality_summary_file,
  report_file,
  session_file
)

unlink(
  output_files,
  force = TRUE
)


# -------------------------------------------------------------------------
# Locked expectations
# -------------------------------------------------------------------------

expected_gse72810_samples <- 146L
expected_gse73461_samples <- 459L

expected_gse72810_platform <- "GPL6947"
expected_gse73461_platform <- "GPL10558"

expected_accession_overlap <- 0L

gsm_pattern <- "^GSM[0-9]+$"

participant_entity_pattern <- paste0(
  "participant|subject|patient|donor|individual|person|child"
)

participant_identifier_pattern <- paste0(
  "id|identifier|number|code"
)

network_evidence_fields <- c(
  "contact_name",
  "contact_email",
  "contact_laboratory",
  "contact_department",
  "contact_institute"
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


clean_character <- function(values) {
  values <- trimws(
    as.character(values)
  )

  values[
    is.na(values) |
      !nzchar(values) |
      toupper(values) %in%
        c(
          "NA",
          "NONE",
          "NULL"
        )
  ] <- NA_character_

  values
}


strip_outer_quotes <- function(values) {
  values <- trimws(
    as.character(values)
  )

  values <- sub(
    '^"',
    "",
    values
  )

  values <- sub(
    '"$',
    "",
    values
  )

  values
}


normalize_accession <- function(values) {
  toupper(
    trimws(
      as.character(values)
    )
  )
}


normalize_general_text <- function(values) {
  values <- tolower(
    trimws(
      as.character(values)
    )
  )

  gsub(
    "[^a-z0-9]+",
    "",
    values
  )
}


normalize_email <- function(values) {
  tolower(
    trimws(
      as.character(values)
    )
  )
}


normalize_title_label <- function(values) {
  values <- tolower(
    trimws(
      as.character(values)
    )
  )

  values <- gsub(
    "\\[[^]]*\\]",
    "",
    values
  )

  values <- gsub(
    "\\([^)]*\\)",
    "",
    values
  )

  gsub(
    "[^a-z0-9]+",
    "",
    values
  )
}


canonical_contact_field <- function(field_name) {
  field_name <- tolower(
    trimws(
      as.character(field_name)
    )
  )

  if (field_name == "name") {
    return("contact_name")
  }

  if (field_name == "email") {
    return("contact_email")
  }

  if (field_name == "laboratory") {
    return("contact_laboratory")
  }

  if (field_name == "department") {
    return("contact_department")
  }

  if (field_name == "institute") {
    return("contact_institute")
  }

  if (field_name == "address") {
    return("contact_address")
  }

  if (field_name == "city") {
    return("contact_city")
  }

  if (
    field_name %in%
      c(
        "zip/postal_code",
        "zip_postal_code",
        "postal_code"
      )
  ) {
    return("contact_postal_code")
  }

  if (field_name == "country") {
    return("contact_country")
  }

  paste0(
    "contact_",
    field_name
  )
}


expand_contact_value <- function(
  cohort,
  source_scope,
  contact_field,
  raw_value
) {
  raw_value <- clean_character(
    raw_value
  )

  if (
    length(raw_value) == 0L ||
      all(is.na(raw_value))
  ) {
    return(
      data.table(
        cohort = character(),
        source_scope = character(),
        contact_field = character(),
        raw_value = character(),
        normalized_value = character()
      )
    )
  }

  raw_value <- raw_value[
    !is.na(raw_value)
  ]

  if (contact_field == "contact_email") {
    expanded <- unlist(
      strsplit(
        raw_value,
        "[,;|[:space:]]+",
        perl = TRUE
      ),
      use.names = FALSE
    )

    expanded <- expanded[
      grepl(
        "@",
        expanded,
        fixed = TRUE
      )
    ]
  } else {
    expanded <- raw_value
  }

  expanded <- clean_character(
    expanded
  )

  expanded <- expanded[
    !is.na(expanded)
  ]

  if (length(expanded) == 0L) {
    return(
      data.table(
        cohort = character(),
        source_scope = character(),
        contact_field = character(),
        raw_value = character(),
        normalized_value = character()
      )
    )
  }

  normalized <- if (
    contact_field == "contact_email"
  ) {
    normalize_email(expanded)
  } else {
    normalize_general_text(expanded)
  }

  result <- data.table(
    cohort = cohort,
    source_scope = source_scope,
    contact_field = contact_field,
    raw_value = expanded,
    normalized_value = normalized
  )

  unique(
    result[
      nzchar(normalized_value)
    ]
  )
}


read_soft_contact_inventory <- function(
  soft_file,
  cohort
) {
  input_connection <- gzfile(
    soft_file,
    open = "rt"
  )

  on.exit(
    {
      try(
        close(input_connection),
        silent = TRUE
      )
    },
    add = TRUE
  )

  result_chunks <- list()
  chunk_index <- 0L

  repeat {
    lines <- readLines(
      input_connection,
      n = 5000L,
      warn = FALSE
    )

    if (length(lines) == 0L) {
      break
    }

    contact_indices <- grep(
      "^!(Series|Sample)_contact_",
      lines,
      perl = TRUE
    )

    if (length(contact_indices) == 0L) {
      next
    }

    contact_lines <- lines[
      contact_indices
    ]

    source_scope <- sub(
      "^!(Series|Sample)_contact_.*$",
      "\\1",
      contact_lines,
      perl = TRUE
    )

    field_name <- sub(
      "^!(?:Series|Sample)_contact_([^=[:space:]]+).*$",
      "\\1",
      contact_lines,
      perl = TRUE
    )

    raw_value <- sub(
      "^[^=]*=[[:space:]]*",
      "",
      contact_lines,
      perl = TRUE
    )

    raw_value <- strip_outer_quotes(
      raw_value
    )

    chunk_rows <- vector(
      "list",
      length(contact_lines)
    )

    for (row_index in seq_along(
      contact_lines
    )) {
      chunk_rows[[row_index]] <- expand_contact_value(
        cohort = cohort,
        source_scope = source_scope[row_index],
        contact_field = canonical_contact_field(
          field_name[row_index]
        ),
        raw_value = raw_value[row_index]
      )
    }

    chunk_result <- rbindlist(
      chunk_rows,
      use.names = TRUE,
      fill = TRUE
    )

    if (nrow(chunk_result) > 0L) {
      chunk_index <- chunk_index + 1L
      result_chunks[[chunk_index]] <- chunk_result
    }
  }

  if (length(result_chunks) == 0L) {
    return(
      data.table(
        cohort = character(),
        source_scope = character(),
        contact_field = character(),
        raw_value = character(),
        normalized_value = character()
      )
    )
  }

  unique(
    rbindlist(
      result_chunks,
      use.names = TRUE,
      fill = TRUE
    )
  )
}


metadata_contact_inventory <- function(
  metadata,
  cohort,
  field_map
) {
  result_rows <- list()
  result_index <- 0L

  for (column_name in names(field_map)) {
    if (!column_name %in% names(metadata)) {
      next
    }

    contact_field <- unname(
      field_map[column_name]
    )

    unique_values <- unique(
      clean_character(
        metadata[[column_name]]
      )
    )

    unique_values <- unique_values[
      !is.na(unique_values)
    ]

    for (value in unique_values) {
      result_index <- result_index + 1L

      result_rows[[result_index]] <- expand_contact_value(
        cohort = cohort,
        source_scope = "harmonized_metadata",
        contact_field = contact_field,
        raw_value = value
      )
    }
  }

  if (length(result_rows) == 0L) {
    return(
      data.table(
        cohort = character(),
        source_scope = character(),
        contact_field = character(),
        raw_value = character(),
        normalized_value = character()
      )
    )
  }

  unique(
    rbindlist(
      result_rows,
      use.names = TRUE,
      fill = TRUE
    )
  )
}


detect_participant_identifier_fields <- function(
  metadata
) {
  column_names <- names(metadata)

  normalized_names <- tolower(
    column_names
  )

  entity_match <- grepl(
    participant_entity_pattern,
    normalized_names,
    perl = TRUE
  )

  identifier_match <- grepl(
    participant_identifier_pattern,
    normalized_names,
    perl = TRUE
  )

  column_names[
    entity_match &
      identifier_match
  ]
}


detect_participant_identifier_values <- function(
  metadata
) {
  character_columns <- names(metadata)[
    vapply(
      metadata,
      function(column_values) {
        is.character(column_values) ||
          is.factor(column_values)
      },
      logical(1L)
    )
  ]

  if (length(character_columns) == 0L) {
    return(
      data.table(
        column_name = character(),
        matched_value = character()
      )
    )
  }

  key_pattern <- paste0(
    "(",
    participant_entity_pattern,
    ")[ _-]*(",
    participant_identifier_pattern,
    ")[[:space:]]*:"
  )

  matched_rows <- list()
  matched_index <- 0L

  for (column_name in character_columns) {
    values <- as.character(
      metadata[[column_name]]
    )

    matching <- which(
      !is.na(values) &
        grepl(
          key_pattern,
          values,
          ignore.case = TRUE,
          perl = TRUE
        )
    )

    if (length(matching) == 0L) {
      next
    }

    for (row_index in matching) {
      matched_index <- matched_index + 1L

      matched_rows[[matched_index]] <- data.table(
        column_name = column_name,
        matched_value = values[row_index]
      )
    }
  }

  if (length(matched_rows) == 0L) {
    return(
      data.table(
        column_name = character(),
        matched_value = character()
      )
    )
  }

  unique(
    rbindlist(
      matched_rows,
      use.names = TRUE,
      fill = TRUE
    )
  )
}


# -------------------------------------------------------------------------
# Validate required inputs
# -------------------------------------------------------------------------

required_files <- c(
  gse72810_metadata_file,
  gse73461_soft_metadata_file,
  gse73461_matrix_metadata_file,
  gse72810_family_soft_file
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
# Read harmonized metadata
# -------------------------------------------------------------------------

message(
  "Reading GSE72810 and GSE73461 harmonized metadata..."
)

gse72810 <- fread(
  gse72810_metadata_file
)

gse73461_soft <- fread(
  gse73461_soft_metadata_file
)

gse73461_matrix <- fread(
  gse73461_matrix_metadata_file
)


# -------------------------------------------------------------------------
# Validate input schemas
# -------------------------------------------------------------------------

require_columns(
  gse72810,
  c(
    "sample_order",
    "geo_accession",
    "sample_title",
    "platform_id",
    "category",
    "dataset",
    "projection_role"
  ),
  gse72810_metadata_file
)

require_columns(
  gse73461_soft,
  c(
    "sample_record",
    "title",
    "geo_accession",
    "platform_id",
    "series_id",
    "characteristics_category",
    "characteristics_dataset",
    "contact_name",
    "contact_email",
    "contact_laboratory",
    "contact_department",
    "contact_institute",
    "contact_address",
    "contact_city",
    "contact_country"
  ),
  gse73461_soft_metadata_file
)

require_columns(
  gse73461_matrix,
  c(
    "title",
    "geo_accession",
    "platform_id"
  ),
  gse73461_matrix_metadata_file
)


# -------------------------------------------------------------------------
# Standardize accession and title fields
# -------------------------------------------------------------------------

gse72810[
  ,
  geo_accession :=
    normalize_accession(
      geo_accession
    )
]

gse72810[
  ,
  sample_title :=
    clean_character(
      sample_title
    )
]

gse72810[
  ,
  platform_id :=
    toupper(
      trimws(
        as.character(platform_id)
      )
    )
]

gse73461_soft[
  ,
  geo_accession :=
    normalize_accession(
      geo_accession
    )
]

gse73461_soft[
  ,
  title :=
    clean_character(
      title
    )
]

gse73461_soft[
  ,
  platform_id :=
    toupper(
      trimws(
        as.character(platform_id)
      )
    )
]

gse73461_matrix[
  ,
  geo_accession :=
    normalize_accession(
      geo_accession
    )
]

gse73461_matrix[
  ,
  title :=
    clean_character(
      title
    )
]

gse73461_matrix[
  ,
  platform_id :=
    toupper(
      trimws(
        as.character(platform_id)
      )
    )
]


# -------------------------------------------------------------------------
# Validate cohort row counts and accession uniqueness
# -------------------------------------------------------------------------

if (
  nrow(gse72810) !=
    expected_gse72810_samples
) {
  stop(
    paste(
      "Expected",
      expected_gse72810_samples,
      "GSE72810 samples but recovered",
      nrow(gse72810)
    )
  )
}

if (
  nrow(gse73461_soft) !=
    expected_gse73461_samples
) {
  stop(
    paste(
      "Expected",
      expected_gse73461_samples,
      "GSE73461 SOFT samples but recovered",
      nrow(gse73461_soft)
    )
  )
}

if (
  nrow(gse73461_matrix) !=
    expected_gse73461_samples
) {
  stop(
    paste(
      "Expected",
      expected_gse73461_samples,
      "GSE73461 matrix samples but recovered",
      nrow(gse73461_matrix)
    )
  )
}

if (
  anyDuplicated(
    gse72810$geo_accession
  ) ||
    anyDuplicated(
      gse73461_soft$geo_accession
    ) ||
    anyDuplicated(
      gse73461_matrix$geo_accession
    )
) {
  stop(
    "At least one metadata source contains duplicated GEO accessions."
  )
}

if (
  any(
    !grepl(
      gsm_pattern,
      gse72810$geo_accession
    )
  ) ||
    any(
      !grepl(
        gsm_pattern,
        gse73461_soft$geo_accession
      )
    ) ||
    any(
      !grepl(
        gsm_pattern,
        gse73461_matrix$geo_accession
      )
    )
) {
  stop(
    "At least one accession does not match the expected GSM format."
  )
}


# -------------------------------------------------------------------------
# Validate GSE73461 metadata-source consistency
# -------------------------------------------------------------------------

gse73461_soft_accessions <- sort(
  gse73461_soft$geo_accession
)

gse73461_matrix_accessions <- sort(
  gse73461_matrix$geo_accession
)

gse73461_accession_sources_match <- identical(
  gse73461_soft_accessions,
  gse73461_matrix_accessions
)

if (!gse73461_accession_sources_match) {
  stop(
    "GSE73461 SOFT and series-matrix accession sets do not match."
  )
}

gse73461_title_consistency <- merge(
  gse73461_soft[
    ,
    .(
      geo_accession,
      soft_title = title
    )
  ],
  gse73461_matrix[
    ,
    .(
      geo_accession,
      matrix_title = title
    )
  ],
  by = "geo_accession",
  all = TRUE
)

gse73461_title_consistency[
  ,
  title_match :=
    soft_title ==
      matrix_title
]

gse73461_titles_match <- (
  nrow(gse73461_title_consistency) ==
    expected_gse73461_samples &&
    !anyNA(
      gse73461_title_consistency$
        title_match
    ) &&
    all(
      gse73461_title_consistency$
        title_match
    )
)


# -------------------------------------------------------------------------
# Build accession inventory
# -------------------------------------------------------------------------

gse72810_inventory <- gse72810[
  ,
  .(
    cohort = "GSE72810",
    geo_accession,
    sample_title,
    platform_id,
    category =
      as.character(category),
    dataset =
      as.character(dataset),
    projection_role =
      as.character(projection_role),
    metadata_source =
      gse72810_metadata_file
  )
]

gse73461_inventory <- gse73461_soft[
  ,
  .(
    cohort = "GSE73461",
    geo_accession,
    sample_title = title,
    platform_id,
    category =
      as.character(
        characteristics_category
      ),
    dataset =
      as.character(
        characteristics_dataset
      ),
    projection_role =
      NA_character_,
    metadata_source =
      gse73461_soft_metadata_file
  )
]

accession_inventory <- rbindlist(
  list(
    gse72810_inventory,
    gse73461_inventory
  ),
  use.names = TRUE,
  fill = TRUE
)

setorder(
  accession_inventory,
  cohort,
  geo_accession
)


# -------------------------------------------------------------------------
# Accession-overlap audit
# -------------------------------------------------------------------------

gse72810_accessions <- sort(
  unique(
    gse72810$geo_accession
  )
)

gse73461_accessions <- sort(
  unique(
    gse73461_soft$geo_accession
  )
)

shared_accessions <- intersect(
  gse72810_accessions,
  gse73461_accessions
)

accession_overlap <- data.table(
  geo_accession =
    shared_accessions
)

accession_overlap_count <- length(
  shared_accessions
)

accession_summary <- data.table(
  comparison =
    "GSE72810 versus GSE73461",
  gse72810_samples =
    length(gse72810_accessions),
  gse73461_samples =
    length(gse73461_accessions),
  shared_gsm_accessions =
    accession_overlap_count,
  gse72810_only_accessions =
    length(
      setdiff(
        gse72810_accessions,
        gse73461_accessions
      )
    ),
  gse73461_only_accessions =
    length(
      setdiff(
        gse73461_accessions,
        gse72810_accessions
      )
    ),
  accession_sets_disjoint =
    accession_overlap_count ==
      expected_accession_overlap,
  accession_level_interpretation =
    if (
      accession_overlap_count == 0L
    ) {
      paste(
        "The deposited GSM accession sets are disjoint, supporting",
        "accession-level and deposited-sample-level separation."
      )
    } else {
      paste(
        "At least one GSM accession is shared; the cohorts cannot be",
        "treated as accession-level separate."
      )
    }
)


# -------------------------------------------------------------------------
# Descriptive-title overlap audit
# -------------------------------------------------------------------------

gse72810_titles <- gse72810[
  ,
  .(
    gse72810_geo_accession =
      geo_accession,
    gse72810_title =
      sample_title,
    normalized_title_label =
      normalize_title_label(
        sample_title
      )
  )
]

gse73461_titles <- gse73461_soft[
  ,
  .(
    gse73461_geo_accession =
      geo_accession,
    gse73461_title =
      title,
    normalized_title_label =
      normalize_title_label(
        title
      )
  )
]

title_overlap <- merge(
  gse72810_titles,
  gse73461_titles,
  by = "normalized_title_label",
  allow.cartesian = TRUE
)

title_overlap[
  ,
  exact_full_title_match :=
    gse72810_title ==
      gse73461_title
]

title_overlap[
  ,
  accession_match :=
    gse72810_geo_accession ==
      gse73461_geo_accession
]

title_overlap[
  ,
  interpretation :=
    paste(
      "Shared normalized descriptive label only;",
      "not a participant or accession identifier."
    )
]

setorder(
  title_overlap,
  normalized_title_label,
  gse72810_geo_accession,
  gse73461_geo_accession
)

title_summary <- data.table(
  gse72810_unique_titles =
    uniqueN(
      gse72810$sample_title
    ),
  gse73461_unique_titles =
    uniqueN(
      gse73461_soft$title
    ),
  exact_full_title_overlap =
    length(
      intersect(
        unique(
          gse72810$sample_title
        ),
        unique(
          gse73461_soft$title
        )
      )
    ),
  normalized_label_overlap_rows =
    nrow(title_overlap),
  normalized_label_overlap_values =
    uniqueN(
      title_overlap$
        normalized_title_label
    ),
  normalized_title_labels_are_participant_ids =
    FALSE,
  interpretation =
    paste(
      "Reused descriptive labels are cohort-local naming conventions",
      "and do not establish participant overlap."
    )
)


# -------------------------------------------------------------------------
# Platform comparison
# -------------------------------------------------------------------------

gse72810_platforms <- sort(
  unique(
    gse72810$platform_id
  )
)

gse73461_platforms <- sort(
  unique(
    gse73461_soft$platform_id
  )
)

platform_comparison <- data.table(
  gse72810_platforms =
    paste(
      gse72810_platforms,
      collapse = ";"
    ),
  gse73461_platforms =
    paste(
      gse73461_platforms,
      collapse = ";"
    ),
  expected_gse72810_platform =
    expected_gse72810_platform,
  expected_gse73461_platform =
    expected_gse73461_platform,
  gse72810_platform_matches_expected =
    identical(
      gse72810_platforms,
      expected_gse72810_platform
    ),
  gse73461_platform_matches_expected =
    identical(
      gse73461_platforms,
      expected_gse73461_platform
    ),
  platform_sets_disjoint =
    length(
      intersect(
        gse72810_platforms,
        gse73461_platforms
      )
    ) ==
      0L,
  platform_interpretation =
    paste(
      "GSE72810 and GSE73461 use different Illumina array",
      "generations, supporting cross-platform validation."
    )
)


# -------------------------------------------------------------------------
# Participant-identifier availability audit
# -------------------------------------------------------------------------

gse72810_participant_columns <-
  detect_participant_identifier_fields(
    gse72810
  )

gse73461_participant_columns <-
  detect_participant_identifier_fields(
    gse73461_soft
  )

gse72810_participant_values <-
  detect_participant_identifier_values(
    gse72810
  )

gse73461_participant_values <-
  detect_participant_identifier_values(
    gse73461_soft
  )

participant_audit <- data.table(
  cohort = c(
    "GSE72810",
    "GSE73461"
  ),
  metadata_rows = c(
    nrow(gse72810),
    nrow(gse73461_soft)
  ),
  dedicated_participant_identifier_column_count = c(
    length(
      gse72810_participant_columns
    ),
    length(
      gse73461_participant_columns
    )
  ),
  dedicated_participant_identifier_columns = c(
    if (
      length(
        gse72810_participant_columns
      ) == 0L
    ) {
      "none"
    } else {
      paste(
        gse72810_participant_columns,
        collapse = ";"
      )
    },
    if (
      length(
        gse73461_participant_columns
      ) == 0L
    ) {
      "none"
    } else {
      paste(
        gse73461_participant_columns,
        collapse = ";"
      )
    }
  ),
  participant_identifier_key_value_match_count = c(
    nrow(
      gse72810_participant_values
    ),
    nrow(
      gse73461_participant_values
    )
  ),
  participant_identifier_available = c(
    length(
      gse72810_participant_columns
    ) > 0L ||
      nrow(
        gse72810_participant_values
      ) > 0L,
    length(
      gse73461_participant_columns
    ) > 0L ||
      nrow(
        gse73461_participant_values
      ) > 0L
  )
)

participant_audit[
  ,
  participant_overlap_assessable :=
    participant_identifier_available
]

participant_audit[
  ,
  interpretation :=
    ifelse(
      participant_identifier_available,
      paste(
        "A candidate participant identifier is present and",
        "requires manual review."
      ),
      paste(
        "No dedicated participant identifier was recovered;",
        "participant overlap cannot be directly assessed."
      )
    )
]

participant_overlap_assessable <- all(
  participant_audit$
    participant_overlap_assessable
)


# -------------------------------------------------------------------------
# Contact and investigator-network audit
# -------------------------------------------------------------------------

message(
  "Extracting GSE72810 SOFT contact information..."
)

gse72810_contact_inventory <-
  read_soft_contact_inventory(
    gse72810_family_soft_file,
    "GSE72810"
  )

gse73461_contact_field_map <- c(
  contact_name =
    "contact_name",
  contact_email =
    "contact_email",
  contact_laboratory =
    "contact_laboratory",
  contact_department =
    "contact_department",
  contact_institute =
    "contact_institute",
  contact_address =
    "contact_address",
  contact_city =
    "contact_city",
  contact_country =
    "contact_country"
)

gse73461_contact_inventory <-
  metadata_contact_inventory(
    metadata =
      gse73461_soft,
    cohort =
      "GSE73461",
    field_map =
      gse73461_contact_field_map
  )

contact_inventory <- unique(
  rbindlist(
    list(
      gse72810_contact_inventory,
      gse73461_contact_inventory
    ),
    use.names = TRUE,
    fill = TRUE
  )
)

setorder(
  contact_inventory,
  cohort,
  contact_field,
  normalized_value
)

gse72810_contact_unique <- unique(
  contact_inventory[
    cohort ==
      "GSE72810",
    .(
      contact_field,
      normalized_value,
      gse72810_raw_value =
        raw_value
    )
  ]
)

gse73461_contact_unique <- unique(
  contact_inventory[
    cohort ==
      "GSE73461",
    .(
      contact_field,
      normalized_value,
      gse73461_raw_value =
        raw_value
    )
  ]
)

contact_overlap <- merge(
  gse72810_contact_unique,
  gse73461_contact_unique,
  by = c(
    "contact_field",
    "normalized_value"
  ),
  allow.cartesian = TRUE
)

contact_overlap[
  ,
  network_evidence_field :=
    contact_field %in%
      network_evidence_fields
]

contact_overlap[
  ,
  interpretation :=
    ifelse(
      network_evidence_field,
      paste(
        "Shared deposited contact or institutional field supports",
        "a shared broad investigator network."
      ),
      paste(
        "Shared contextual location field; not sufficient alone",
        "to establish investigator-network overlap."
      )
    )
]

setorder(
  contact_overlap,
  -network_evidence_field,
  contact_field,
  normalized_value
)

network_contact_overlap <- contact_overlap[
  network_evidence_field ==
    TRUE
]

shared_investigator_network_supported <- (
  nrow(
    network_contact_overlap
  ) >
    0L
)


# -------------------------------------------------------------------------
# Independence-dimension assessment
# -------------------------------------------------------------------------

independence_assessment <- data.table(
  dimension = c(
    "GEO accession-level separation",
    "Deposited sample-level separation",
    "Platform-level separation",
    "Participant-level separation",
    "Investigator-network independence"
  ),
  directly_assessable = c(
    TRUE,
    TRUE,
    TRUE,
    participant_overlap_assessable,
    nrow(contact_inventory) > 0L
  ),
  result = c(
    if (
      accession_overlap_count == 0L
    ) {
      "SUPPORTED"
    } else {
      "NOT_SUPPORTED"
    },
    if (
      accession_overlap_count == 0L
    ) {
      "SUPPORTED_AT_DEPOSITED_SAMPLE_ACCESSION_LEVEL"
    } else {
      "NOT_SUPPORTED"
    },
    if (
      isTRUE(
        platform_comparison$
          platform_sets_disjoint
      )
    ) {
      "SUPPORTED"
    } else {
      "NOT_SUPPORTED"
    },
    if (
      participant_overlap_assessable
    ) {
      "ASSESSABLE"
    } else {
      "NOT_ASSESSABLE_FROM_DEPOSITED_METADATA"
    },
    if (
      shared_investigator_network_supported
    ) {
      "NOT_SUPPORTED"
    } else {
      "NOT_ESTABLISHED"
    }
  ),
  evidence = c(
    paste0(
      accession_overlap_count,
      " shared GSM accessions among ",
      length(gse72810_accessions),
      " GSE72810 and ",
      length(gse73461_accessions),
      " GSE73461 accessions."
    ),
    paste(
      "Every deposited sample has a cohort-specific GSM accession;",
      "descriptive title labels are not sample identifiers."
    ),
    paste0(
      paste(
        gse72810_platforms,
        collapse = ";"
      ),
      " versus ",
      paste(
        gse73461_platforms,
        collapse = ";"
      ),
      "."
    ),
    paste(
      "Neither cohort provides a dedicated participant identifier",
      "in the audited deposited metadata."
    ),
    paste0(
      nrow(network_contact_overlap),
      " shared contact or institutional evidence rows across ",
      paste(
        network_evidence_fields,
        collapse = ", "
      ),
      "."
    )
  ),
  manuscript_consequence = c(
    paste(
      "The cohorts may be described as accession-level separate."
    ),
    paste(
      "GSE72810 may be described as a second deposited sample cohort."
    ),
    paste(
      "GSE72810 provides cross-platform validation relative to GSE73461."
    ),
    paste(
      "Do not claim that participant overlap was definitively excluded."
    ),
    paste(
      "Do not describe GSE72810 as fully investigator-independent."
    )
  )
)


# -------------------------------------------------------------------------
# Manuscript-wording recommendations
# -------------------------------------------------------------------------

recommended_primary_wording <- paste(
  "GSE72810 was analysed as a second accession-level and",
  "sample-level cohort providing cross-platform validation of",
  "the locked host-response modules."
)

recommended_caution_wording <- paste(
  "The GSE72810 and GSE73461 GEO sample accession sets were",
  "disjoint and the cohorts were measured on different Illumina",
  "array platforms. However, direct participant overlap could not",
  "be assessed because participant identifiers were not deposited,",
  "and the studies arose from the same broad investigator network."
)

recommended_results_wording <- paste(
  "Projection into GSE72810 provided additional sample-level and",
  "cross-platform support for the locked module architecture, with",
  "no module reselection, reweighting or diagnostic-model training."
)

wording_recommendations <- data.table(
  wording_role = c(
    "preferred_cohort_description",
    "required_limitation",
    "preferred_results_description",
    "avoid_unqualified_phrase",
    "avoid_overstated_claim"
  ),
  wording = c(
    recommended_primary_wording,
    recommended_caution_wording,
    recommended_results_wording,
    "a fully independent external cohort",
    paste(
      "participant overlap was excluded between GSE72810 and GSE73461"
    )
  ),
  use_status = c(
    "USE",
    "USE",
    "USE",
    "AVOID",
    "AVOID"
  ),
  rationale = c(
    paste(
      "Supported by disjoint GSM accessions and distinct platforms."
    ),
    paste(
      "Required because participant identifiers are absent and",
      "contact metadata support a shared broad network."
    ),
    paste(
      "Accurately describes the additional validation layer."
    ),
    paste(
      "Investigator-network independence is not supported."
    ),
    paste(
      "Participant-level overlap is not directly assessable."
    )
  )
)


# -------------------------------------------------------------------------
# Quality gate
# -------------------------------------------------------------------------

accession_inventory_expected_rows <- (
  expected_gse72810_samples +
    expected_gse73461_samples
)

contact_inventory_has_both_cohorts <- setequal(
  unique(
    contact_inventory$cohort
  ),
  c(
    "GSE72810",
    "GSE73461"
  )
)

quality_checks <- data.table(
  check_id = sprintf(
    "Q%02d",
    seq_len(18L)
  ),
  check_description = c(
    "GSE72810 harmonized metadata contains 146 samples",
    "GSE73461 SOFT metadata contains 459 samples",
    "GSE73461 series-matrix metadata contains 459 samples",
    "All three accession sources contain unique valid GSM identifiers",
    "GSE73461 SOFT and series-matrix accession sets match",
    "GSE73461 SOFT and series-matrix titles match by accession",
    "Combined accession inventory contains 605 rows",
    "GSE72810 and GSE73461 have zero shared GSM accessions",
    "GSE72810 contains only GPL6947",
    "GSE73461 contains only GPL10558",
    "The cohort platform sets are disjoint",
    "No dedicated participant identifier was recovered in GSE72810",
    "No dedicated participant identifier was recovered in GSE73461",
    "Contact inventories were recovered for both cohorts",
    "Shared broad investigator-network evidence was recovered",
    "Five independence dimensions were assessed",
    "Five manuscript-wording recommendations were generated",
    "Preferred wording avoids unqualified participant or investigator independence"
  ),
  pass = c(
    nrow(gse72810) ==
      expected_gse72810_samples,
    nrow(gse73461_soft) ==
      expected_gse73461_samples,
    nrow(gse73461_matrix) ==
      expected_gse73461_samples,
    !anyDuplicated(
      gse72810$geo_accession
    ) &&
      !anyDuplicated(
        gse73461_soft$geo_accession
      ) &&
      !anyDuplicated(
        gse73461_matrix$geo_accession
      ) &&
      all(
        grepl(
          gsm_pattern,
          gse72810$geo_accession
        )
      ) &&
      all(
        grepl(
          gsm_pattern,
          gse73461_soft$geo_accession
        )
      ) &&
      all(
        grepl(
          gsm_pattern,
          gse73461_matrix$geo_accession
        )
      ),
    gse73461_accession_sources_match,
    gse73461_titles_match,
    nrow(accession_inventory) ==
      accession_inventory_expected_rows,
    accession_overlap_count ==
      expected_accession_overlap,
    identical(
      gse72810_platforms,
      expected_gse72810_platform
    ),
    identical(
      gse73461_platforms,
      expected_gse73461_platform
    ),
    isTRUE(
      platform_comparison$
        platform_sets_disjoint
    ),
    participant_audit[
      cohort ==
        "GSE72810",
      participant_identifier_available
    ] ==
      FALSE,
    participant_audit[
      cohort ==
        "GSE73461",
      participant_identifier_available
    ] ==
      FALSE,
    contact_inventory_has_both_cohorts,
    shared_investigator_network_supported,
    nrow(independence_assessment) ==
      5L,
    nrow(wording_recommendations) ==
      5L,
    wording_recommendations[
      wording_role ==
        "preferred_cohort_description",
      use_status
    ] ==
      "USE" &&
      wording_recommendations[
        wording_role ==
          "avoid_unqualified_phrase",
        use_status
      ] ==
        "AVOID" &&
      wording_recommendations[
        wording_role ==
          "avoid_overstated_claim",
        use_status
      ] ==
        "AVOID"
  )
)

quality_gate_pass <- all(
  quality_checks$pass
)

overall_audit_decision <- if (
  quality_gate_pass
) {
  paste(
    "SECOND_ACCESSION_LEVEL_AND_SAMPLE_LEVEL_COHORT_WITH",
    "CROSS_PLATFORM_VALIDATION_AND_SHARED_NETWORK_CAUTION",
    sep = "_"
  )
} else {
  "OVERLAP_AND_INDEPENDENCE_AUDIT_REVIEW_REQUIRED"
}

quality_summary <- data.table(
  total_checks =
    nrow(quality_checks),
  passed_checks =
    sum(quality_checks$pass),
  failed_checks =
    sum(!quality_checks$pass),
  gse72810_accessions =
    length(gse72810_accessions),
  gse73461_accessions =
    length(gse73461_accessions),
  shared_gsm_accessions =
    accession_overlap_count,
  normalized_title_overlap_values =
    uniqueN(
      title_overlap$
        normalized_title_label
    ),
  gse72810_platform =
    paste(
      gse72810_platforms,
      collapse = ";"
    ),
  gse73461_platform =
    paste(
      gse73461_platforms,
      collapse = ";"
    ),
  participant_overlap_assessable =
    participant_overlap_assessable,
  shared_network_evidence_rows =
    nrow(network_contact_overlap),
  accession_level_separation =
    accession_overlap_count == 0L,
  cross_platform_validation_supported =
    isTRUE(
      platform_comparison$
        platform_sets_disjoint
    ),
  fully_investigator_independent_supported =
    FALSE,
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  overall_audit_decision =
    overall_audit_decision,
  preferred_cohort_wording =
    recommended_primary_wording
)


# -------------------------------------------------------------------------
# Write outputs
# -------------------------------------------------------------------------

fwrite(
  accession_inventory,
  accession_inventory_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  accession_overlap,
  accession_overlap_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  accession_summary,
  accession_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  title_overlap,
  title_overlap_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  title_summary,
  title_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  platform_comparison,
  platform_comparison_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  participant_audit,
  participant_audit_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  contact_inventory,
  contact_inventory_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  contact_overlap,
  contact_overlap_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  independence_assessment,
  independence_assessment_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  wording_recommendations,
  wording_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  quality_checks,
  quality_checks_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  quality_summary,
  quality_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Report
# -------------------------------------------------------------------------

accession_preview <- capture.output(
  print(accession_summary)
)

title_preview <- capture.output(
  print(title_summary)
)

platform_preview <- capture.output(
  print(platform_comparison)
)

participant_preview <- capture.output(
  print(participant_audit)
)

contact_preview <- capture.output(
  print(
    network_contact_overlap
  )
)

independence_preview <- capture.output(
  print(independence_assessment)
)

wording_preview <- capture.output(
  print(wording_recommendations)
)

quality_preview <- capture.output(
  print(quality_checks)
)

report_lines <- c(
  "# GSE72810-GSE73461 accession-overlap and independence audit",
  "",
  "## Scope",
  "",
  paste(
    "This audit distinguishes deposited GEO accession separation,",
    "deposited sample separation, platform separation, participant",
    "separation and investigator-network independence."
  ),
  "",
  paste(
    "Descriptive labels such as Control_01 and",
    "DefiniteBacterial_01 were treated as cohort-local labels rather",
    "than participant identifiers."
  ),
  "",
  "## GEO accession comparison",
  "",
  "```text",
  accession_preview,
  "```",
  "",
  "## Descriptive-title comparison",
  "",
  "```text",
  title_preview,
  "```",
  "",
  "## Platform comparison",
  "",
  "```text",
  platform_preview,
  "```",
  "",
  "## Participant-identifier audit",
  "",
  "```text",
  participant_preview,
  "```",
  "",
  "## Shared contact and network evidence",
  "",
  "```text",
  contact_preview,
  "```",
  "",
  "## Independence-dimension assessment",
  "",
  "```text",
  independence_preview,
  "```",
  "",
  "## Manuscript wording",
  "",
  "```text",
  wording_preview,
  "```",
  "",
  "## Preferred interpretation",
  "",
  paste0(
    "- ",
    recommended_primary_wording
  ),
  paste0(
    "- ",
    recommended_caution_wording
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
    quality_summary$quality_gate,
    "`."
  ),
  paste0(
    "- Overall decision: `",
    quality_summary$
      overall_audit_decision,
    "`."
  )
)

writeLines(
  report_lines,
  report_file
)


# -------------------------------------------------------------------------
# Session information
# -------------------------------------------------------------------------

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
  "===== GSE72810-GSE73461 OVERLAP AND INDEPENDENCE AUDIT =====\n"
)

cat(
  "gse72810_accessions\t",
  length(gse72810_accessions),
  "\n",
  sep = ""
)

cat(
  "gse73461_accessions\t",
  length(gse73461_accessions),
  "\n",
  sep = ""
)

cat(
  "shared_gsm_accessions\t",
  accession_overlap_count,
  "\n",
  sep = ""
)

cat(
  "normalized_title_overlap_values\t",
  uniqueN(
    title_overlap$
      normalized_title_label
  ),
  "\n",
  sep = ""
)

cat(
  "gse72810_platform\t",
  paste(
    gse72810_platforms,
    collapse = ";"
  ),
  "\n",
  sep = ""
)

cat(
  "gse73461_platform\t",
  paste(
    gse73461_platforms,
    collapse = ";"
  ),
  "\n",
  sep = ""
)

cat(
  "participant_overlap_assessable\t",
  participant_overlap_assessable,
  "\n",
  sep = ""
)

cat(
  "shared_network_evidence_rows\t",
  nrow(network_contact_overlap),
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
  quality_summary$quality_gate,
  "\n",
  sep = ""
)

cat(
  "overall_audit_decision\t",
  quality_summary$
    overall_audit_decision,
  "\n",
  sep = ""
)

cat(
  "\n===== INDEPENDENCE DIMENSIONS =====\n"
)

print(
  independence_assessment
)

cat(
  "\n===== PREFERRED COHORT WORDING =====\n"
)

cat(
  recommended_primary_wording,
  "\n"
)

cat(
  "\n===== REQUIRED LIMITATION =====\n"
)

cat(
  recommended_caution_wording,
  "\n"
)

cat(
  "\naccession_summary\t",
  accession_summary_file,
  "\n",
  sep = ""
)

cat(
  "contact_overlap\t",
  contact_overlap_file,
  "\n",
  sep = ""
)

cat(
  "wording_recommendations\t",
  wording_file,
  "\n",
  sep = ""
)

cat(
  "quality_summary\t",
  quality_summary_file,
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
    "The GSE72810-GSE73461 overlap audit failed its quality gate."
  )
}
