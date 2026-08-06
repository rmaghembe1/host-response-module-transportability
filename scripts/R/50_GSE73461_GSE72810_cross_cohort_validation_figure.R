#!/usr/bin/env Rscript

# =========================================================================
# GSE73461-GSE72810 cross-cohort validation figure and summary table
# Corrected release version with physical TSV integrity validation
# =========================================================================
#
# Outputs
#
# 1. Harmonised ten-row primary effect-size source-data table.
# 2. Five-row cross-cohort manuscript summary table.
# 3. Hodges-Lehmann forest plot as 1800-dpi PNG, editable SVG and PDF.
# 4. Figure caption, Markdown table, report, manifest and quality files.
#
# Critical serialization rule
#
# Character values written to TSV files must not contain carriage returns
# or newline characters. Multiline module labels are created only inside
# the plotting data object and are never written to a tabular output.
#
# Interpretation boundary
#
# GSE73461 is the formal external projection cohort relative to GSE211567.
#
# GSE72810 is a second accession-level and deposited-sample-level cohort
# providing cross-platform validation. The GSE72810 and GSE73461 GSM sets
# are disjoint and use distinct Illumina platforms. Participant overlap
# cannot be directly assessed, and the studies arose from the same broad
# investigator network.
#
# No gene reselection, module redefinition, gene reweighting, direction
# flipping or diagnostic-model training is performed.
# =========================================================================


# -------------------------------------------------------------------------
# Library setup
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

required_packages <- c(
  "data.table",
  "ggplot2"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    quietly = TRUE,
    FUN.VALUE = logical(1L)
  )
]

if (length(missing_packages) > 0L) {
  stop(
    paste(
      "Missing required R packages:",
      paste(
        missing_packages,
        collapse = ", "
      )
    )
  )
}

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

figure_helper <- "scripts/R/00_publication_figure_export_helpers.R"

if (!file.exists(figure_helper)) {
  stop(
    paste(
      "Missing figure-export helper:",
      figure_helper
    )
  )
}

source(figure_helper)


# -------------------------------------------------------------------------
# Input files
# -------------------------------------------------------------------------

gse73461_effects_file <- paste0(
  "results/revision_round1/",
  "GSE73461_effect_sizes_confidence_intervals/",
  "GSE73461_module_effect_sizes_confidence_intervals.tsv"
)

gse73461_summary_file <- paste0(
  "results/tables/",
  "GSE73461_manuscript_projection_summary_table.tsv"
)

gse72810_effects_file <- paste0(
  "results/revision_round1/",
  "GSE72810_effect_sizes_confidence_intervals/",
  "GSE72810_effect_sizes_confidence_intervals.tsv"
)

gse72810_coverage_file <- paste0(
  "results/revision_round1/",
  "GSE72810_fixed_module_projection/",
  "GSE72810_scoring_module_coverage.tsv"
)

cohort_wording_file <- paste0(
  "results/revision_round1/",
  "GSE72810_GSE73461_overlap_independence_audit/",
  "GSE72810_GSE73461_manuscript_wording_recommendations.tsv"
)

overlap_quality_file <- paste0(
  "results/revision_round1/",
  "GSE72810_GSE73461_overlap_independence_audit/",
  "GSE72810_GSE73461_overlap_audit_quality_summary.tsv"
)


# -------------------------------------------------------------------------
# Output files
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_GSE72810_cross_cohort_validation"
)

figure_dir <- file.path(
  out_dir,
  "figures"
)

docs_dir <- "docs/revision_round1"
session_dir <- "env/session_info/revision_round1"

dir.create(
  out_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  figure_dir,
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

source_data_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_primary_effect_size_source_data.tsv"
)

summary_table_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_summary_table.tsv"
)

figure_manifest_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_figure_manifest.tsv"
)

quality_gate_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_quality_gate.tsv"
)

quality_summary_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_quality_summary.tsv"
)

caption_file <- file.path(
  docs_dir,
  "GSE73461_GSE72810_cross_cohort_validation_figure_caption.md"
)

markdown_table_file <- file.path(
  docs_dir,
  "GSE73461_GSE72810_cross_cohort_summary_table.md"
)

report_file <- file.path(
  docs_dir,
  "GSE73461_GSE72810_cross_cohort_validation_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE73461_GSE72810_cross_cohort_validation_sessionInfo.txt"
)

figure_base <- paste0(
  "Figure_3_GSE73461_GSE72810_",
  "cross_cohort_Hodges_Lehmann_forest"
)

figure_png <- file.path(
  figure_dir,
  paste0(
    figure_base,
    ".png"
  )
)

figure_svg <- file.path(
  figure_dir,
  paste0(
    figure_base,
    ".svg"
  )
)

figure_pdf <- file.path(
  figure_dir,
  paste0(
    figure_base,
    ".pdf"
  )
)

generated_files <- c(
  source_data_file,
  summary_table_file,
  figure_manifest_file,
  quality_gate_file,
  quality_summary_file,
  caption_file,
  markdown_table_file,
  report_file,
  session_file,
  figure_png,
  figure_svg,
  figure_pdf
)

unlink(
  generated_files,
  force = TRUE
)


# -------------------------------------------------------------------------
# Locked constants
# -------------------------------------------------------------------------

module_order <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

cohort_order <- c(
  "GSE73461",
  "GSE72810"
)

expected_gse73461_bacterial_n <- 52L
expected_gse73461_viral_n <- 94L

expected_gse72810_bacterial_n <- 23L
expected_gse72810_viral_n <- 28L

expected_bootstrap_replicates <- 10000L

expected_gse73461_platform <- "GPL10558"
expected_gse72810_platform <- "GPL6947"

gse73461_primary_id <- "main_all_projected_reference"

gse72810_primary_id <-
  "main_representative_all146_z_definite"

figure_width_inches <- 10.5
figure_height_inches <- 6.8
figure_dpi <- 1800L

cohort_display_labels <- c(
  GSE73461 =
    "GSE73461: GPL10558; 52 bacterial, 94 viral",
  GSE72810 =
    "GSE72810: GPL6947; 23 bacterial, 28 viral"
)

module_export_labels <- c(
  BACT_M1 =
    "BACT_M1: Translation and ribosomal programme",
  BACT_M2 =
    "BACT_M2: Mitochondrial respiration and OXPHOS",
  VIR_M1a =
    "VIR_M1a: Broad antiviral and interferon defence",
  VIR_M1b =
    "VIR_M1b: Viral restriction and type I interferon",
  VIR_M2 =
    "VIR_M2: Cytokine and innate immune regulation"
)

module_plot_labels <- c(
  BACT_M1 =
    "BACT_M1\nTranslation and ribosomal programme",
  BACT_M2 =
    "BACT_M2\nMitochondrial respiration and OXPHOS",
  VIR_M1a =
    "VIR_M1a\nBroad antiviral and interferon defence",
  VIR_M1b =
    "VIR_M1b\nViral restriction and type I interferon",
  VIR_M2 =
    "VIR_M2\nCytokine and innate immune regulation"
)

cohort_colours <- c(
  "GSE73461: GPL10558; 52 bacterial, 94 viral" =
    "#0072B2",
  "GSE72810: GPL6947; 23 bacterial, 28 viral" =
    "#D55E00"
)

cohort_shapes <- c(
  "GSE73461: GPL10558; 52 bacterial, 94 viral" =
    21,
  "GSE72810: GPL6947; 23 bacterial, 28 viral" =
    22
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


coerce_logical_strict <- function(
  values,
  field_name
) {
  if (is.logical(values)) {
    if (anyNA(values)) {
      stop(
        paste(
          field_name,
          "contains missing logical values."
        )
      )
    }

    return(values)
  }

  normalized <- toupper(
    trimws(
      as.character(values)
    )
  )

  allowed <- c(
    "TRUE",
    "FALSE",
    "T",
    "F",
    "1",
    "0"
  )

  if (
    any(
      is.na(normalized) |
        !normalized %in%
          allowed
    )
  ) {
    stop(
      paste(
        field_name,
        "contains invalid logical values."
      )
    )
  }

  normalized %in%
    c(
      "TRUE",
      "T",
      "1"
    )
}


clean_text <- function(values) {
  values <- as.character(values)

  values[
    is.na(values)
  ] <- ""

  values <- gsub(
    "[\r\n]+",
    " ",
    values,
    perl = TRUE
  )

  values <- gsub(
    "[[:space:]]+",
    " ",
    values,
    perl = TRUE
  )

  values <- trimws(values)

  values[
    toupper(values) %in%
      c(
        "NA",
        "NULL",
        "NONE"
      )
  ] <- ""

  values
}


sanitize_table_for_tsv <- function(table_object) {
  result <- copy(table_object)

  character_columns <- names(result)[
    vapply(
      result,
      is.character,
      FUN.VALUE = logical(1L)
    )
  ]

  factor_columns <- names(result)[
    vapply(
      result,
      is.factor,
      FUN.VALUE = logical(1L)
    )
  ]

  for (column_name in factor_columns) {
    set(
      result,
      j = column_name,
      value = as.character(
        result[[column_name]]
      )
    )
  }

  character_columns <- unique(
    c(
      character_columns,
      factor_columns
    )
  )

  for (column_name in character_columns) {
    set(
      result,
      j = column_name,
      value = clean_text(
        result[[column_name]]
      )
    )
  }

  result
}


contains_embedded_line_break <- function(
  table_object
) {
  character_columns <- names(table_object)[
    vapply(
      table_object,
      function(values) {
        is.character(values) ||
          is.factor(values)
      },
      FUN.VALUE = logical(1L)
    )
  ]

  if (length(character_columns) == 0L) {
    return(FALSE)
  }

  any(
    vapply(
      character_columns,
      function(column_name) {
        any(
          grepl(
            "[\r\n]",
            as.character(
              table_object[[column_name]]
            ),
            perl = TRUE
          )
        )
      },
      FUN.VALUE = logical(1L)
    )
  )
}


physical_data_rows <- function(path) {
  if (!file.exists(path)) {
    return(NA_integer_)
  }

  lines <- readLines(
    path,
    warn = FALSE,
    encoding = "UTF-8"
  )

  max(
    length(lines) - 1L,
    0L
  )
}


format_signed <- function(
  value,
  digits = 3L
) {
  if (
    length(value) == 0L ||
      is.na(value)
  ) {
    return("NA")
  }

  sprintf(
    paste0(
      "%+.",
      digits,
      "f"
    ),
    value
  )
}


format_interval <- function(
  estimate,
  lower,
  upper,
  digits = 3L
) {
  paste0(
    format_signed(
      estimate,
      digits
    ),
    " (95% CI ",
    format_signed(
      lower,
      digits
    ),
    " to ",
    format_signed(
      upper,
      digits
    ),
    ")"
  )
}


format_p_value <- function(value) {
  if (
    length(value) == 0L ||
      is.na(value)
  ) {
    return("NA")
  }

  if (value < 0.001) {
    return(
      formatC(
        value,
        format = "e",
        digits = 2L
      )
    )
  }

  formatC(
    value,
    format = "f",
    digits = 4L
  )
}


markdown_escape <- function(values) {
  values <- clean_text(values)

  gsub(
    "\\|",
    "\\\\|",
    values
  )
}


direction_from_effect <- function(value) {
  if (value > 0) {
    return("higher_in_bacterial")
  }

  if (value < 0) {
    return("higher_in_viral")
  }

  "no_difference"
}


ci_excludes_zero <- function(
  lower,
  upper
) {
  (
    lower > 0 &&
      upper > 0
  ) ||
    (
      lower < 0 &&
        upper < 0
    )
}


file_md5 <- function(path) {
  if (!file.exists(path)) {
    return(NA_character_)
  }

  unname(
    as.character(
      tools::md5sum(path)
    )
  )
}


file_size_bytes <- function(path) {
  if (!file.exists(path)) {
    return(NA_real_)
  }

  as.numeric(
    file.info(path)$size
  )
}


svg_contains_raster_image <- function(path) {
  if (!file.exists(path)) {
    return(NA)
  }

  svg_lines <- readLines(
    path,
    warn = FALSE,
    encoding = "UTF-8"
  )

  any(
    grepl(
      "<image([[:space:]>])|data:image/",
      svg_lines,
      ignore.case = TRUE,
      perl = TRUE
    )
  )
}


cross_cohort_interpretation <- function(
  module_id,
  direction_retained_both,
  ci_excludes_zero_both,
  fdr_significant_both
) {
  if (!direction_retained_both) {
    return(
      "Expected direction was not retained in both cohorts."
    )
  }

  if (
    ci_excludes_zero_both &&
      fdr_significant_both
  ) {
    if (
      module_id %in%
        c(
          "VIR_M1a",
          "VIR_M1b"
        )
    ) {
      return(
        paste(
          "Strong expected-direction support with confidence",
          "intervals excluding zero in both cohorts."
        )
      )
    }

    return(
      paste(
        "Expected-direction support with confidence intervals",
        "excluding zero in both cohorts."
      )
    )
  }

  paste(
    "Directionally concordant in both cohorts but statistically",
    "borderline, with confidence intervals including zero."
  )
}


# -------------------------------------------------------------------------
# Validate input-file availability
# -------------------------------------------------------------------------

required_input_files <- c(
  gse73461_effects_file,
  gse73461_summary_file,
  gse72810_effects_file,
  gse72810_coverage_file,
  cohort_wording_file,
  overlap_quality_file
)

missing_input_files <- required_input_files[
  !file.exists(required_input_files)
]

if (length(missing_input_files) > 0L) {
  stop(
    paste(
      "Missing required input files:",
      paste(
        missing_input_files,
        collapse = ", "
      )
    )
  )
}


# -------------------------------------------------------------------------
# Read inputs
# -------------------------------------------------------------------------

message(
  "Reading primary GSE73461 and GSE72810 validation results..."
)

gse73461_effects <- fread(
  gse73461_effects_file
)

gse73461_summary <- fread(
  gse73461_summary_file
)

gse72810_effects <- fread(
  gse72810_effects_file
)

gse72810_coverage <- fread(
  gse72810_coverage_file
)

cohort_wording <- fread(
  cohort_wording_file
)

overlap_quality <- fread(
  overlap_quality_file
)


# -------------------------------------------------------------------------
# Validate schemas
# -------------------------------------------------------------------------

require_columns(
  gse73461_effects,
  c(
    "scoring_population",
    "final_module_id",
    "final_module_label",
    "final_module_direction",
    "n_bacterial",
    "n_viral",
    "median_bacterial",
    "median_viral",
    "median_difference_bacterial_minus_viral",
    "hodges_lehmann_bacterial_minus_viral",
    "hodges_lehmann_ci_lower",
    "hodges_lehmann_ci_upper",
    "rank_biserial_bacterial_vs_viral",
    "rank_biserial_ci_lower",
    "rank_biserial_ci_upper",
    "wilcox_p",
    "bootstrap_replicates",
    "wilcox_p_BH",
    "expected_direction_match"
  ),
  gse73461_effects_file
)

require_columns(
  gse73461_summary,
  c(
    "Module",
    "Conservative module label",
    "Discovery direction",
    "Locked genes",
    "Genes scored in GSE73461",
    "Missing genes"
  ),
  gse73461_summary_file
)

require_columns(
  gse72810_effects,
  c(
    "analysis_id",
    "final_module_id",
    "analysis_role",
    "scoring_representation",
    "z_reference_population",
    "final_module_label",
    "expected_direction",
    "observed_direction",
    "direction_retained",
    "bacterial_n",
    "viral_n",
    "median_bacterial",
    "median_viral",
    "median_difference_bacterial_minus_viral",
    "hodges_lehmann_shift_bacterial_minus_viral",
    "hodges_lehmann_ci_low",
    "hodges_lehmann_ci_high",
    "hodges_lehmann_ci_excludes_zero",
    "rank_biserial_effect",
    "rank_biserial_ci_low",
    "rank_biserial_ci_high",
    "rank_biserial_ci_excludes_zero",
    "wilcoxon_p",
    "bootstrap_replicates_completed",
    "wilcoxon_q",
    "fdr_significant"
  ),
  gse72810_effects_file
)

require_columns(
  gse72810_coverage,
  c(
    "final_module_id",
    "final_module_label",
    "module_direction",
    "locked_gene_count",
    "mapped_gene_count",
    "coverage_fraction",
    "missing_symbols",
    "representative_probes_frozen"
  ),
  gse72810_coverage_file
)

require_columns(
  cohort_wording,
  c(
    "wording_role",
    "wording",
    "use_status",
    "rationale"
  ),
  cohort_wording_file
)

require_columns(
  overlap_quality,
  c(
    "shared_gsm_accessions",
    "gse72810_platform",
    "gse73461_platform",
    "participant_overlap_assessable",
    "accession_level_separation",
    "cross_platform_validation_supported",
    "fully_investigator_independent_supported",
    "quality_gate",
    "overall_audit_decision",
    "preferred_cohort_wording"
  ),
  overlap_quality_file
)


# -------------------------------------------------------------------------
# Validate cohort-overlap audit
# -------------------------------------------------------------------------

if (nrow(overlap_quality) != 1L) {
  stop(
    "The overlap quality summary must contain exactly one row."
  )
}

overlap_quality[
  ,
  participant_overlap_assessable :=
    coerce_logical_strict(
      participant_overlap_assessable,
      "participant_overlap_assessable"
    )
]

overlap_quality[
  ,
  accession_level_separation :=
    coerce_logical_strict(
      accession_level_separation,
      "accession_level_separation"
    )
]

overlap_quality[
  ,
  cross_platform_validation_supported :=
    coerce_logical_strict(
      cross_platform_validation_supported,
      "cross_platform_validation_supported"
    )
]

overlap_quality[
  ,
  fully_investigator_independent_supported :=
    coerce_logical_strict(
      fully_investigator_independent_supported,
      "fully_investigator_independent_supported"
    )
]

overlap_audit_valid <- (
  overlap_quality$shared_gsm_accessions[1L] ==
    0L &&
    overlap_quality$gse72810_platform[1L] ==
      expected_gse72810_platform &&
    overlap_quality$gse73461_platform[1L] ==
      expected_gse73461_platform &&
    overlap_quality$
      participant_overlap_assessable[1L] ==
      FALSE &&
    overlap_quality$
      accession_level_separation[1L] ==
      TRUE &&
    overlap_quality$
      cross_platform_validation_supported[1L] ==
      TRUE &&
    overlap_quality$
      fully_investigator_independent_supported[1L] ==
      FALSE &&
    overlap_quality$quality_gate[1L] ==
      "PASS"
)

if (!overlap_audit_valid) {
  stop(
    "The locked cohort-overlap and wording audit did not validate."
  )
}


# -------------------------------------------------------------------------
# Select primary analyses
# -------------------------------------------------------------------------

gse73461_primary <- gse73461_effects[
  scoring_population ==
    gse73461_primary_id
]

gse73461_primary[
  ,
  expected_direction_match :=
    coerce_logical_strict(
      expected_direction_match,
      "GSE73461 expected_direction_match"
    )
]

gse72810_primary <- gse72810_effects[
  analysis_id ==
    gse72810_primary_id
]

gse72810_primary[
  ,
  direction_retained :=
    coerce_logical_strict(
      direction_retained,
      "GSE72810 direction_retained"
    )
]

gse72810_primary[
  ,
  hodges_lehmann_ci_excludes_zero :=
    coerce_logical_strict(
      hodges_lehmann_ci_excludes_zero,
      "GSE72810 Hodges-Lehmann CI exclusion"
    )
]

gse72810_primary[
  ,
  rank_biserial_ci_excludes_zero :=
    coerce_logical_strict(
      rank_biserial_ci_excludes_zero,
      "GSE72810 rank-biserial CI exclusion"
    )
]

gse72810_primary[
  ,
  fdr_significant :=
    coerce_logical_strict(
      fdr_significant,
      "GSE72810 FDR significance"
    )
]

if (
  nrow(gse73461_primary) !=
    5L ||
    anyDuplicated(
      gse73461_primary$
        final_module_id
    ) ||
    !setequal(
      gse73461_primary$
        final_module_id,
      module_order
    )
) {
  stop(
    "The primary GSE73461 analysis does not contain five unique locked modules."
  )
}

if (
  nrow(gse72810_primary) !=
    5L ||
    anyDuplicated(
      gse72810_primary$
        final_module_id
    ) ||
    !setequal(
      gse72810_primary$
        final_module_id,
      module_order
    )
) {
  stop(
    "The primary GSE72810 analysis does not contain five unique locked modules."
  )
}


# -------------------------------------------------------------------------
# Standardise coverage tables
# -------------------------------------------------------------------------

gse73461_coverage <- gse73461_summary[
  ,
  .(
    final_module_id =
      as.character(Module),
    coverage_module_label =
      as.character(
        `Conservative module label`
      ),
    coverage_direction =
      as.character(
        `Discovery direction`
      ),
    locked_gene_count =
      as.integer(
        `Locked genes`
      ),
    genes_scored =
      as.integer(
        `Genes scored in GSE73461`
      ),
    missing_genes =
      clean_text(
        `Missing genes`
      )
  )
]

gse73461_coverage[
  ,
  coverage_fraction :=
    genes_scored /
      locked_gene_count
]

gse72810_coverage[
  ,
  representative_probes_frozen :=
    coerce_logical_strict(
      representative_probes_frozen,
      "GSE72810 representative-probe lock"
    )
]

gse72810_coverage_standard <- gse72810_coverage[
  ,
  .(
    final_module_id =
      as.character(final_module_id),
    coverage_module_label =
      as.character(final_module_label),
    coverage_direction =
      as.character(module_direction),
    locked_gene_count =
      as.integer(locked_gene_count),
    genes_scored =
      as.integer(mapped_gene_count),
    coverage_fraction =
      as.numeric(coverage_fraction),
    missing_genes =
      clean_text(missing_symbols),
    representative_probes_frozen =
      representative_probes_frozen
  )
]


# -------------------------------------------------------------------------
# Harmonise GSE73461 effects
# -------------------------------------------------------------------------

gse73461_source <- gse73461_primary[
  ,
  .(
    cohort_id =
      "GSE73461",
    cohort_label =
      unname(
        cohort_display_labels[
          "GSE73461"
        ]
      ),
    platform_id =
      expected_gse73461_platform,
    validation_role =
      paste(
        "Formal external fixed-module projection cohort",
        "relative to GSE211567 discovery"
      ),
    scoring_population =
      as.character(
        scoring_population
      ),
    scoring_rule =
      paste(
        "Unweighted mean gene-wise z score;",
        "all projected samples as z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(
        final_module_direction
      ),
    bacterial_n =
      as.integer(n_bacterial),
    viral_n =
      as.integer(n_viral),
    median_bacterial =
      as.numeric(median_bacterial),
    median_viral =
      as.numeric(median_viral),
    median_difference_bacterial_minus_viral =
      as.numeric(
        median_difference_bacterial_minus_viral
      ),
    hodges_lehmann_shift_bacterial_minus_viral =
      as.numeric(
        hodges_lehmann_bacterial_minus_viral
      ),
    hodges_lehmann_ci_low =
      as.numeric(
        hodges_lehmann_ci_lower
      ),
    hodges_lehmann_ci_high =
      as.numeric(
        hodges_lehmann_ci_upper
      ),
    rank_biserial_effect =
      as.numeric(
        rank_biserial_bacterial_vs_viral
      ),
    rank_biserial_ci_low =
      as.numeric(
        rank_biserial_ci_lower
      ),
    rank_biserial_ci_high =
      as.numeric(
        rank_biserial_ci_upper
      ),
    wilcoxon_p =
      as.numeric(wilcox_p),
    wilcoxon_q =
      as.numeric(wilcox_p_BH),
    bootstrap_replicates =
      as.integer(
        bootstrap_replicates
      ),
    direction_retained =
      expected_direction_match
  )
]

gse73461_source[
  ,
  observed_direction :=
    vapply(
      hodges_lehmann_shift_bacterial_minus_viral,
      direction_from_effect,
      FUN.VALUE = character(1L)
    )
]

gse73461_source[
  ,
  hodges_lehmann_ci_excludes_zero :=
    mapply(
      ci_excludes_zero,
      hodges_lehmann_ci_low,
      hodges_lehmann_ci_high
    )
]

gse73461_source[
  ,
  rank_biserial_ci_excludes_zero :=
    mapply(
      ci_excludes_zero,
      rank_biserial_ci_low,
      rank_biserial_ci_high
    )
]

gse73461_source[
  ,
  fdr_significant :=
    wilcoxon_q <
      0.05
]

gse73461_source <- merge(
  gse73461_source,
  gse73461_coverage,
  by = "final_module_id",
  all.x = TRUE,
  sort = FALSE
)


# -------------------------------------------------------------------------
# Harmonise GSE72810 effects
# -------------------------------------------------------------------------

gse72810_source <- gse72810_primary[
  ,
  .(
    cohort_id =
      "GSE72810",
    cohort_label =
      unname(
        cohort_display_labels[
          "GSE72810"
        ]
      ),
    platform_id =
      expected_gse72810_platform,
    validation_role =
      paste(
        "Second accession-level and deposited-sample-level",
        "cohort providing cross-platform validation"
      ),
    scoring_population =
      as.character(analysis_id),
    scoring_rule =
      paste(
        "Frozen representative-probe unweighted mean gene-wise",
        "z score; all 146 samples as z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(
        expected_direction
      ),
    bacterial_n =
      as.integer(bacterial_n),
    viral_n =
      as.integer(viral_n),
    median_bacterial =
      as.numeric(median_bacterial),
    median_viral =
      as.numeric(median_viral),
    median_difference_bacterial_minus_viral =
      as.numeric(
        median_difference_bacterial_minus_viral
      ),
    hodges_lehmann_shift_bacterial_minus_viral =
      as.numeric(
        hodges_lehmann_shift_bacterial_minus_viral
      ),
    hodges_lehmann_ci_low =
      as.numeric(
        hodges_lehmann_ci_low
      ),
    hodges_lehmann_ci_high =
      as.numeric(
        hodges_lehmann_ci_high
      ),
    rank_biserial_effect =
      as.numeric(
        rank_biserial_effect
      ),
    rank_biserial_ci_low =
      as.numeric(
        rank_biserial_ci_low
      ),
    rank_biserial_ci_high =
      as.numeric(
        rank_biserial_ci_high
      ),
    wilcoxon_p =
      as.numeric(wilcoxon_p),
    wilcoxon_q =
      as.numeric(wilcoxon_q),
    bootstrap_replicates =
      as.integer(
        bootstrap_replicates_completed
      ),
    observed_direction =
      as.character(
        observed_direction
      ),
    direction_retained =
      direction_retained,
    hodges_lehmann_ci_excludes_zero =
      hodges_lehmann_ci_excludes_zero,
    rank_biserial_ci_excludes_zero =
      rank_biserial_ci_excludes_zero,
    fdr_significant =
      fdr_significant
  )
]

gse72810_source <- merge(
  gse72810_source,
  gse72810_coverage_standard,
  by = "final_module_id",
  all.x = TRUE,
  sort = FALSE
)


# -------------------------------------------------------------------------
# Combine source data
# -------------------------------------------------------------------------

source_data <- rbindlist(
  list(
    gse73461_source,
    gse72810_source
  ),
  use.names = TRUE,
  fill = TRUE
)

source_data[
  ,
  module_order_index :=
    match(
      final_module_id,
      module_order
    )
]

source_data[
  ,
  cohort_order_index :=
    match(
      cohort_id,
      cohort_order
    )
]

setorder(
  source_data,
  module_order_index,
  cohort_order_index
)

source_data[
  ,
  module_display_label :=
    unname(
      module_export_labels[
        final_module_id
      ]
    )
]

source_data[
  ,
  effect_orientation :=
    paste(
      "Positive values indicate higher scores in bacterial samples;",
      "negative values indicate higher scores in viral samples."
    )
]

source_data[
  ,
  accession_independence_boundary :=
    ifelse(
      cohort_id ==
        "GSE72810",
      paste(
        "Disjoint GSM accession set and distinct platform relative",
        "to GSE73461; participant overlap not directly assessable;",
        "shared broad investigator network."
      ),
      paste(
        "Formal external projection cohort relative to GSE211567",
        "discovery; no gene or module reselection."
      )
    )
]

source_data[
  ,
  c(
    "module_order_index",
    "cohort_order_index"
  ) := NULL
]


# -------------------------------------------------------------------------
# Cross-source consistency checks
# -------------------------------------------------------------------------

module_label_consistency <- source_data[
  ,
  .(
    unique_module_labels =
      uniqueN(final_module_label)
  ),
  by = final_module_id
]

direction_consistency <- source_data[
  ,
  .(
    unique_expected_directions =
      uniqueN(expected_direction)
  ),
  by = final_module_id
]

locked_gene_consistency <- source_data[
  ,
  .(
    unique_locked_gene_counts =
      uniqueN(locked_gene_count)
  ),
  by = final_module_id
]

if (
  any(
    module_label_consistency$
      unique_module_labels !=
      1L
  )
) {
  stop(
    "Module labels differ between validation cohorts."
  )
}

if (
  any(
    direction_consistency$
      unique_expected_directions !=
      1L
  )
) {
  stop(
    "Expected module directions differ between validation cohorts."
  )
}

if (
  any(
    locked_gene_consistency$
      unique_locked_gene_counts !=
      1L
  )
) {
  stop(
    "Locked gene counts differ between coverage sources."
  )
}


# -------------------------------------------------------------------------
# Construct manuscript summary table
# -------------------------------------------------------------------------

gse73461_wide <- source_data[
  cohort_id ==
    "GSE73461",
  .(
    final_module_id,
    final_module_label,
    expected_direction,
    locked_gene_count,
    gse73461_platform =
      platform_id,
    gse73461_bacterial_n =
      bacterial_n,
    gse73461_viral_n =
      viral_n,
    gse73461_genes_scored =
      genes_scored,
    gse73461_coverage_fraction =
      coverage_fraction,
    gse73461_missing_genes =
      missing_genes,
    gse73461_hodges_lehmann_shift =
      hodges_lehmann_shift_bacterial_minus_viral,
    gse73461_hodges_lehmann_ci_low =
      hodges_lehmann_ci_low,
    gse73461_hodges_lehmann_ci_high =
      hodges_lehmann_ci_high,
    gse73461_rank_biserial_effect =
      rank_biserial_effect,
    gse73461_rank_biserial_ci_low =
      rank_biserial_ci_low,
    gse73461_rank_biserial_ci_high =
      rank_biserial_ci_high,
    gse73461_wilcoxon_p =
      wilcoxon_p,
    gse73461_wilcoxon_q =
      wilcoxon_q,
    gse73461_direction_retained =
      direction_retained,
    gse73461_hl_ci_excludes_zero =
      hodges_lehmann_ci_excludes_zero,
    gse73461_fdr_significant =
      fdr_significant
  )
]

gse72810_wide <- source_data[
  cohort_id ==
    "GSE72810",
  .(
    final_module_id,
    gse72810_platform =
      platform_id,
    gse72810_bacterial_n =
      bacterial_n,
    gse72810_viral_n =
      viral_n,
    gse72810_genes_scored =
      genes_scored,
    gse72810_coverage_fraction =
      coverage_fraction,
    gse72810_missing_genes =
      missing_genes,
    gse72810_hodges_lehmann_shift =
      hodges_lehmann_shift_bacterial_minus_viral,
    gse72810_hodges_lehmann_ci_low =
      hodges_lehmann_ci_low,
    gse72810_hodges_lehmann_ci_high =
      hodges_lehmann_ci_high,
    gse72810_rank_biserial_effect =
      rank_biserial_effect,
    gse72810_rank_biserial_ci_low =
      rank_biserial_ci_low,
    gse72810_rank_biserial_ci_high =
      rank_biserial_ci_high,
    gse72810_wilcoxon_p =
      wilcoxon_p,
    gse72810_wilcoxon_q =
      wilcoxon_q,
    gse72810_direction_retained =
      direction_retained,
    gse72810_hl_ci_excludes_zero =
      hodges_lehmann_ci_excludes_zero,
    gse72810_fdr_significant =
      fdr_significant
  )
]

summary_table <- merge(
  gse73461_wide,
  gse72810_wide,
  by = "final_module_id",
  all = TRUE,
  sort = FALSE
)

summary_table[
  ,
  both_direction_retained :=
    gse73461_direction_retained &
      gse72810_direction_retained
]

summary_table[
  ,
  both_hl_ci_exclude_zero :=
    gse73461_hl_ci_excludes_zero &
      gse72810_hl_ci_excludes_zero
]

summary_table[
  ,
  both_fdr_significant :=
    gse73461_fdr_significant &
      gse72810_fdr_significant
]

summary_table[
  ,
  gse73461_primary_result :=
    mapply(
      format_interval,
      gse73461_hodges_lehmann_shift,
      gse73461_hodges_lehmann_ci_low,
      gse73461_hodges_lehmann_ci_high
    )
]

summary_table[
  ,
  gse72810_primary_result :=
    mapply(
      format_interval,
      gse72810_hodges_lehmann_shift,
      gse72810_hodges_lehmann_ci_low,
      gse72810_hodges_lehmann_ci_high
    )
]

summary_table[
  ,
  gse73461_bh_p_formatted :=
    vapply(
      gse73461_wilcoxon_q,
      format_p_value,
      FUN.VALUE = character(1L)
    )
]

summary_table[
  ,
  gse72810_bh_p_formatted :=
    vapply(
      gse72810_wilcoxon_q,
      format_p_value,
      FUN.VALUE = character(1L)
    )
]

summary_table[
  ,
  cross_cohort_interpretation :=
    mapply(
      cross_cohort_interpretation,
      final_module_id,
      both_direction_retained,
      both_hl_ci_exclude_zero,
      both_fdr_significant
    )
]

summary_table[
  ,
  module_order_index :=
    match(
      final_module_id,
      module_order
    )
]

setorder(
  summary_table,
  module_order_index
)

summary_table[
  ,
  module_order_index := NULL
]


# -------------------------------------------------------------------------
# Sanitize and write tabular outputs
# -------------------------------------------------------------------------

source_data_output <- sanitize_table_for_tsv(
  source_data
)

summary_table_output <- sanitize_table_for_tsv(
  summary_table
)

source_has_embedded_breaks_before_write <-
  contains_embedded_line_break(
    source_data_output
  )

summary_has_embedded_breaks_before_write <-
  contains_embedded_line_break(
    summary_table_output
  )

if (source_has_embedded_breaks_before_write) {
  stop(
    "The sanitized source-data table still contains an embedded line break."
  )
}

if (summary_has_embedded_breaks_before_write) {
  stop(
    "The sanitized summary table still contains an embedded line break."
  )
}

fwrite(
  source_data_output,
  source_data_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  summary_table_output,
  summary_table_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

source_physical_rows <- physical_data_rows(
  source_data_file
)

summary_physical_rows <- physical_data_rows(
  summary_table_file
)


# -------------------------------------------------------------------------
# Construct forest plot
# -------------------------------------------------------------------------

plot_data <- copy(
  source_data
)

plot_data[
  ,
  cohort_label :=
    factor(
      cohort_label,
      levels = unname(
        cohort_display_labels[
          cohort_order
        ]
      )
    )
]

plot_data[
  ,
  final_module_id :=
    factor(
      final_module_id,
      levels = module_order
    )
]

cohort_dodge <- position_dodge(
  width = 0.62
)

forest_plot <- ggplot(
  plot_data,
  aes(
    x = final_module_id,
    y =
      hodges_lehmann_shift_bacterial_minus_viral,
    colour = cohort_label,
    fill = cohort_label,
    shape = cohort_label
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    linewidth = 0.55,
    colour = "grey35"
  ) +
  geom_errorbar(
    aes(
      ymin =
        hodges_lehmann_ci_low,
      ymax =
        hodges_lehmann_ci_high
    ),
    position = cohort_dodge,
    width = 0.18,
    linewidth = 0.85,
    lineend = "round"
  ) +
  geom_point(
    position = cohort_dodge,
    size = 3.9,
    stroke = 0.9
  ) +
  scale_x_discrete(
    labels =
      module_plot_labels
  ) +
  scale_colour_manual(
    values =
      cohort_colours,
    name =
      "Validation cohort"
  ) +
  scale_fill_manual(
    values =
      cohort_colours,
    name =
      "Validation cohort"
  ) +
  scale_shape_manual(
    values =
      cohort_shapes,
    name =
      "Validation cohort"
  ) +
  scale_y_continuous(
    expand = expansion(
      mult = c(
        0.06,
        0.08
      )
    )
  ) +
  coord_flip(
    clip = "off"
  ) +
  labs(
    title =
      "Cross-cohort transportability of locked host-response modules",
    subtitle =
      paste(
        "Hodges-Lehmann bacterial-minus-viral score shifts",
        "with bootstrap 95% confidence intervals"
      ),
    x = NULL,
    y =
      "Hodges-Lehmann shift (bacterial - viral)",
    caption =
      paste(
        "Positive values indicate bacterial-higher scores;",
        "negative values indicate viral-higher scores.",
        "Modules were projected without gene reselection,",
        "reweighting or diagnostic-model training."
      )
  ) +
  theme_bw(
    base_size = 12
  ) +
  theme(
    panel.grid.minor =
      element_blank(),
    panel.grid.major.y =
      element_blank(),
    panel.border =
      element_rect(
        linewidth = 0.6
      ),
    axis.text.y =
      element_text(
        size = 10.5,
        lineheight = 0.93,
        colour = "black"
      ),
    axis.text.x =
      element_text(
        colour = "black"
      ),
    axis.title.x =
      element_text(
        margin = margin(
          t = 8
        )
      ),
    plot.title =
      element_text(
        face = "bold",
        size = 14,
        margin = margin(
          b = 5
        )
      ),
    plot.subtitle =
      element_text(
        size = 11.5,
        margin = margin(
          b = 10
        )
      ),
    plot.caption =
      element_text(
        size = 9,
        hjust = 0,
        margin = margin(
          t = 10
        )
      ),
    legend.position =
      "bottom",
    legend.direction =
      "vertical",
    legend.title =
      element_text(
        face = "bold"
      ),
    legend.text =
      element_text(
        size = 9.5
      ),
    plot.margin =
      margin(
        t = 12,
        r = 18,
        b = 12,
        l = 12
      )
  )

message(
  "Exporting publication figure..."
)

save_publication_figure(
  plot = forest_plot,
  out_dir = figure_dir,
  filename_base = figure_base,
  width = figure_width_inches,
  height = figure_height_inches,
  dpi = figure_dpi
)


# -------------------------------------------------------------------------
# Figure manifest
# -------------------------------------------------------------------------

figure_manifest <- data.table(
  figure_role = c(
    "publication_png",
    "editable_vector_svg",
    "vector_pdf"
  ),
  file_path = c(
    figure_png,
    figure_svg,
    figure_pdf
  ),
  file_format = c(
    "PNG",
    "SVG",
    "PDF"
  ),
  width_inches =
    figure_width_inches,
  height_inches =
    figure_height_inches,
  dpi = c(
    figure_dpi,
    NA_integer_,
    NA_integer_
  )
)

figure_manifest[
  ,
  file_exists :=
    file.exists(file_path)
]

figure_manifest[
  ,
  file_size_bytes :=
    vapply(
      file_path,
      file_size_bytes,
      FUN.VALUE = numeric(1L)
    )
]

figure_manifest[
  ,
  md5 :=
    vapply(
      file_path,
      file_md5,
      FUN.VALUE = character(1L)
    )
]

figure_manifest[
  ,
  svg_contains_raster_image :=
    c(
      NA,
      svg_contains_raster_image(
        figure_svg
      ),
      NA
    )
]

fwrite(
  sanitize_table_for_tsv(
    figure_manifest
  ),
  figure_manifest_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Figure caption
# -------------------------------------------------------------------------

caption_lines <- c(
  paste0(
    "# Figure 3. Cross-cohort transportability of locked ",
    "host-response modules in GSE73461 and GSE72810"
  ),
  "",
  paste(
    "Hodges-Lehmann bacterial-minus-viral module-score shifts",
    "are shown with stratified nonparametric bootstrap 95%",
    "confidence intervals for the five modules locked in the",
    "GSE211567 discovery analysis."
  ),
  "",
  paste(
    "Positive estimates indicate higher module scores in bacterial",
    "samples, whereas negative estimates indicate higher scores in",
    "viral samples. GSE73461 contained 52 DefiniteBacterial and 94",
    "DefiniteViral samples measured on GPL10558. GSE72810 contained",
    "23 definite bacterial and 28 definite viral samples measured",
    "on GPL6947."
  ),
  "",
  paste(
    "BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 retained their expected",
    "directions with confidence intervals excluding zero and",
    "BH-adjusted Wilcoxon P values below 0.05 in both cohorts.",
    "BACT_M1 retained the expected bacterial-higher direction in",
    "both cohorts but remained statistically borderline."
  ),
  "",
  paste(
    "The modules were scored without gene reselection, module",
    "redefinition, gene reweighting, direction flipping or",
    "diagnostic-model training."
  ),
  "",
  paste(
    "GSE72810 was analysed as a second accession-level and",
    "deposited-sample-level cohort providing cross-platform",
    "validation. Its GSM accession set was disjoint from GSE73461",
    "and it used a different Illumina platform. Direct participant",
    "overlap could not be assessed because participant identifiers",
    "were not deposited, and the studies arose from the same broad",
    "investigator network."
  )
)

writeLines(
  caption_lines,
  caption_file
)


# -------------------------------------------------------------------------
# Markdown summary table
# -------------------------------------------------------------------------

markdown_header <- c(
  "# Cross-cohort fixed-module projection summary",
  "",
  paste(
    "Primary bacterial-versus-viral Hodges-Lehmann shifts and",
    "bootstrap 95% confidence intervals are shown for GSE73461 and",
    "GSE72810. Positive values indicate bacterial-higher module",
    "scores; negative values indicate viral-higher scores."
  ),
  "",
  paste0(
    "| Module | Conservative module label | Discovery direction | ",
    "Locked genes | GSE73461 genes scored | GSE73461 primary result | ",
    "GSE73461 BH P | GSE72810 genes scored | GSE72810 primary result | ",
    "GSE72810 BH P | Cross-cohort interpretation |"
  ),
  paste0(
    "| --- | --- | --- | ---: | ---: | --- | ---: | ---: | --- | ",
    "---: | --- |"
  )
)

markdown_rows <- vapply(
  seq_len(
    nrow(summary_table)
  ),
  function(row_index) {
    current_row <- summary_table[
      row_index
    ]

    paste0(
      "| ",
      markdown_escape(
        current_row$
          final_module_id
      ),
      " | ",
      markdown_escape(
        current_row$
          final_module_label
      ),
      " | ",
      markdown_escape(
        current_row$
          expected_direction
      ),
      " | ",
      current_row$
        locked_gene_count,
      " | ",
      current_row$
        gse73461_genes_scored,
      " | ",
      markdown_escape(
        current_row$
          gse73461_primary_result
      ),
      " | ",
      current_row$
        gse73461_bh_p_formatted,
      " | ",
      current_row$
        gse72810_genes_scored,
      " | ",
      markdown_escape(
        current_row$
          gse72810_primary_result
      ),
      " | ",
      current_row$
        gse72810_bh_p_formatted,
      " | ",
      markdown_escape(
        current_row$
          cross_cohort_interpretation
      ),
      " |"
    )
  },
  FUN.VALUE = character(1L)
)

markdown_notes <- c(
  "",
  "## Notes",
  "",
  paste(
    "**Primary result:** Hodges-Lehmann bacterial-minus-viral",
    "module-score shift with bootstrap 95% confidence interval."
  ),
  "",
  paste(
    "**GSE73461:** Formal external fixed-module projection cohort",
    "relative to GSE211567 discovery; GPL10558; 52",
    "DefiniteBacterial and 94 DefiniteViral samples."
  ),
  "",
  paste(
    "**GSE72810:** Second accession-level and",
    "deposited-sample-level cohort providing cross-platform",
    "validation; GPL6947; 23 definite bacterial and 28 definite",
    "viral samples."
  ),
  "",
  paste(
    "**Independence boundary:** The GSE72810 and GSE73461 GSM",
    "accession sets were disjoint. Participant overlap could not be",
    "directly assessed, and the studies arose from the same broad",
    "investigator network."
  ),
  "",
  paste(
    "**Abbreviations:** BH, Benjamini-Hochberg; CI, confidence",
    "interval; OXPHOS, oxidative phosphorylation."
  )
)

writeLines(
  c(
    markdown_header,
    markdown_rows,
    markdown_notes
  ),
  markdown_table_file
)


# -------------------------------------------------------------------------
# Quality-gate calculations
# -------------------------------------------------------------------------

source_keys_unique <- (
  !anyDuplicated(
    source_data[
      ,
      .(
        cohort_id,
        final_module_id
      )
    ]
  )
)

all_numeric_values_finite <- all(
  is.finite(
    source_data$
      hodges_lehmann_shift_bacterial_minus_viral
  )
) &&
  all(
    is.finite(
      source_data$
        hodges_lehmann_ci_low
    )
  ) &&
  all(
    is.finite(
      source_data$
        hodges_lehmann_ci_high
    )
  ) &&
  all(
    is.finite(
      source_data$
        rank_biserial_effect
    )
  ) &&
  all(
    is.finite(
      source_data$
        rank_biserial_ci_low
    )
  ) &&
  all(
    is.finite(
      source_data$
        rank_biserial_ci_high
    )
  ) &&
  all(
    is.finite(
      source_data$
        wilcoxon_p
    )
  ) &&
  all(
    is.finite(
      source_data$
        wilcoxon_q
    )
  )

all_ci_order_valid <- all(
  source_data$
    hodges_lehmann_ci_low <=
    source_data$
      hodges_lehmann_ci_high
) &&
  all(
    source_data$
      rank_biserial_ci_low <=
      source_data$
        rank_biserial_ci_high
  )

all_rank_biserial_valid <- all(
  source_data$
    rank_biserial_effect >=
    -1
) &&
  all(
    source_data$
      rank_biserial_effect <=
      1
  ) &&
  all(
    source_data$
      rank_biserial_ci_low >=
      -1
  ) &&
  all(
    source_data$
      rank_biserial_ci_high <=
      1
  )

gse73461_counts_valid <- all(
  source_data[
    cohort_id ==
      "GSE73461",
    bacterial_n
  ] ==
    expected_gse73461_bacterial_n
) &&
  all(
    source_data[
      cohort_id ==
        "GSE73461",
      viral_n
    ] ==
      expected_gse73461_viral_n
  )

gse72810_counts_valid <- all(
  source_data[
    cohort_id ==
      "GSE72810",
    bacterial_n
  ] ==
    expected_gse72810_bacterial_n
) &&
  all(
    source_data[
      cohort_id ==
        "GSE72810",
      viral_n
    ] ==
      expected_gse72810_viral_n
  )

bootstrap_counts_valid <- all(
  source_data$
    bootstrap_replicates ==
    expected_bootstrap_replicates
)

all_coverage_valid <- all(
  source_data$
    coverage_fraction >=
    0.70
)

gse72810_probe_lock_valid <- all(
  gse72810_coverage_standard$
    representative_probes_frozen
)

all_directions_retained <- all(
  source_data$
    direction_retained
)

expected_fdr_pattern_valid <- (
  all(
    source_data[
      final_module_id ==
        "BACT_M1",
      fdr_significant
    ] ==
      FALSE
  ) &&
    all(
      source_data[
        final_module_id !=
          "BACT_M1",
        fdr_significant
      ] ==
        TRUE
    )
)

expected_ci_pattern_valid <- (
  all(
    source_data[
      final_module_id ==
        "BACT_M1",
      hodges_lehmann_ci_excludes_zero
    ] ==
      FALSE
  ) &&
    all(
      source_data[
        final_module_id !=
          "BACT_M1",
        hodges_lehmann_ci_excludes_zero
      ] ==
        TRUE
    )
)

figure_files_valid <- (
  file.exists(figure_png) &&
    file_size_bytes(
      figure_png
    ) >
      0 &&
    file.exists(figure_svg) &&
    file_size_bytes(
      figure_svg
    ) >
      0 &&
    file.exists(figure_pdf) &&
    file_size_bytes(
      figure_pdf
    ) >
      0
)

svg_vector_only <- (
  file.exists(figure_svg) &&
    !isTRUE(
      svg_contains_raster_image(
        figure_svg
      )
    )
)

documentation_files_valid <- all(
  file.exists(
    c(
      caption_file,
      markdown_table_file
    )
  )
) &&
  all(
    file.info(
      c(
        caption_file,
        markdown_table_file
      )
    )$size >
      0
  )

source_file_integrity_valid <- (
  source_physical_rows ==
    nrow(source_data_output)
)

summary_file_integrity_valid <- (
  summary_physical_rows ==
    nrow(summary_table_output)
)


# -------------------------------------------------------------------------
# Quality gate
# -------------------------------------------------------------------------

quality_checks <- data.table(
  check_id = sprintf(
    "Q%02d",
    seq_len(27L)
  ),
  check_description = c(
    "All six locked input files are present",
    "The cohort overlap and wording audit validates",
    "GSE73461 primary analysis contains five unique locked modules",
    "GSE72810 primary analysis contains five unique locked modules",
    "Both cohorts contain exactly the locked module set",
    "The harmonised in-memory source table contains ten rows",
    "Harmonised cohort-module keys are unique",
    "Module labels are identical between cohorts",
    "Expected directions are identical between cohorts",
    "Locked gene counts are identical between coverage sources",
    "GSE73461 group counts are 52 bacterial and 94 viral",
    "GSE72810 group counts are 23 bacterial and 28 viral",
    "Every primary effect row used 10,000 bootstrap replicates",
    "All effect estimates, intervals and P values are finite",
    "All confidence-interval lower and upper bounds are ordered",
    "All rank-biserial estimates and intervals lie between minus one and one",
    "All module coverage fractions are at least 70 percent",
    "All GSE72810 representative probes remain frozen",
    "All ten cohort-module effects retain their expected directions",
    "BACT_M1 is FDR-borderline in both cohorts and the other modules pass FDR",
    "BACT_M1 confidence intervals include zero and the other module intervals exclude zero",
    "The manuscript-facing summary table contains five unique modules",
    "PNG, SVG and PDF figure files are present and non-empty",
    "The SVG contains no embedded raster image element",
    "Caption and Markdown summary-table files are present and non-empty",
    "The written source-data TSV contains exactly ten physical data rows",
    "The written summary TSV contains exactly five physical data rows"
  ),
  pass = c(
    all(
      file.exists(
        required_input_files
      )
    ),
    overlap_audit_valid,
    nrow(gse73461_primary) ==
      5L &&
      !anyDuplicated(
        gse73461_primary$
          final_module_id
      ),
    nrow(gse72810_primary) ==
      5L &&
      !anyDuplicated(
        gse72810_primary$
          final_module_id
      ),
    setequal(
      gse73461_primary$
        final_module_id,
      module_order
    ) &&
      setequal(
        gse72810_primary$
          final_module_id,
        module_order
      ),
    nrow(source_data) ==
      10L,
    source_keys_unique,
    all(
      module_label_consistency$
        unique_module_labels ==
        1L
    ),
    all(
      direction_consistency$
        unique_expected_directions ==
        1L
    ),
    all(
      locked_gene_consistency$
        unique_locked_gene_counts ==
        1L
    ),
    gse73461_counts_valid,
    gse72810_counts_valid,
    bootstrap_counts_valid,
    all_numeric_values_finite,
    all_ci_order_valid,
    all_rank_biserial_valid,
    all_coverage_valid,
    gse72810_probe_lock_valid,
    all_directions_retained,
    expected_fdr_pattern_valid,
    expected_ci_pattern_valid,
    nrow(summary_table) ==
      5L &&
      !anyDuplicated(
        summary_table$
          final_module_id
      ),
    figure_files_valid,
    svg_vector_only,
    documentation_files_valid,
    source_file_integrity_valid,
    summary_file_integrity_valid
  )
)

quality_gate_pass <- all(
  quality_checks$pass
)

quality_summary <- data.table(
  total_checks =
    nrow(quality_checks),
  passed_checks =
    sum(quality_checks$pass),
  failed_checks =
    sum(!quality_checks$pass),
  source_data_rows_in_memory =
    nrow(source_data),
  source_data_rows_on_disk =
    source_physical_rows,
  summary_table_rows_in_memory =
    nrow(summary_table),
  summary_table_rows_on_disk =
    summary_physical_rows,
  validation_cohorts =
    uniqueN(
      source_data$cohort_id
    ),
  locked_modules =
    uniqueN(
      source_data$final_module_id
    ),
  expected_direction_rows =
    sum(
      source_data$direction_retained
    ),
  fdr_significant_rows =
    sum(
      source_data$fdr_significant
    ),
  hl_ci_excluding_zero_rows =
    sum(
      source_data$
        hodges_lehmann_ci_excludes_zero
    ),
  modules_supported_in_both_cohorts =
    sum(
      summary_table$
        both_fdr_significant
    ),
  svg_raster_image_elements =
    ifelse(
      isTRUE(
        svg_contains_raster_image(
          figure_svg
        )
      ),
      1L,
      0L
    ),
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  integration_status =
    ifelse(
      quality_gate_pass,
      "READY_FOR_VISUAL_REVIEW_AND_COMMIT",
      "CROSS_COHORT_FIGURE_REVIEW_REQUIRED"
    )
)

fwrite(
  quality_checks,
  quality_gate_file,
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
# Audit report
# -------------------------------------------------------------------------

source_preview <- capture.output(
  print(
    source_data[
      ,
      .(
        cohort_id,
        final_module_id,
        bacterial_n,
        viral_n,
        hodges_lehmann_shift_bacterial_minus_viral,
        hodges_lehmann_ci_low,
        hodges_lehmann_ci_high,
        rank_biserial_effect,
        wilcoxon_q,
        direction_retained,
        fdr_significant
      )
    ]
  )
)

summary_preview <- capture.output(
  print(
    summary_table[
      ,
      .(
        final_module_id,
        gse73461_primary_result,
        gse73461_bh_p_formatted,
        gse72810_primary_result,
        gse72810_bh_p_formatted,
        both_direction_retained,
        both_hl_ci_exclude_zero,
        both_fdr_significant,
        cross_cohort_interpretation
      )
    ]
  )
)

quality_preview <- capture.output(
  print(quality_checks)
)

manifest_preview <- capture.output(
  print(figure_manifest)
)

report_lines <- c(
  "# GSE73461-GSE72810 cross-cohort validation figure report",
  "",
  "## Analysis scope",
  "",
  paste(
    "This phase harmonised the primary fixed-module effect-size",
    "results from GSE73461 and GSE72810. No sensitivity result was",
    "substituted for either cohort's locked primary analysis."
  ),
  "",
  paste(
    "The forest plot displays bacterial-minus-viral",
    "Hodges-Lehmann shifts with bootstrap 95% confidence",
    "intervals. Positive estimates represent bacterial-higher",
    "scores and negative estimates represent viral-higher scores."
  ),
  "",
  "## Harmonised source data",
  "",
  "```text",
  source_preview,
  "```",
  "",
  "## Cross-cohort summary",
  "",
  "```text",
  summary_preview,
  "```",
  "",
  "## Interpretation",
  "",
  paste(
    "BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 retained their expected",
    "directions with confidence intervals excluding zero and",
    "BH-adjusted P values below 0.05 in both cohorts."
  ),
  "",
  paste(
    "BACT_M1 remained bacterial-higher in both cohorts but its",
    "confidence interval included zero and its BH-adjusted P value",
    "remained approximately 0.08 in both primary analyses."
  ),
  "",
  paste(
    "GSVA and leave-one/two-gene analyses were not incorporated",
    "into the primary forest plot. They remain separate",
    "prespecified sensitivity and robustness analyses."
  ),
  "",
  "## Cohort-independence boundary",
  "",
  paste(
    "GSE72810 was treated as a second accession-level and",
    "deposited-sample-level cohort providing cross-platform",
    "validation. Participant overlap cannot be directly assessed,",
    "and full investigator-network independence is not claimed."
  ),
  "",
  "## Tabular serialization integrity",
  "",
  paste0(
    "- Source-data rows in memory: ",
    nrow(source_data),
    "."
  ),
  paste0(
    "- Source-data physical rows on disk: ",
    source_physical_rows,
    "."
  ),
  paste0(
    "- Summary rows in memory: ",
    nrow(summary_table),
    "."
  ),
  paste0(
    "- Summary physical rows on disk: ",
    summary_physical_rows,
    "."
  ),
  "",
  "## Figure manifest",
  "",
  "```text",
  manifest_preview,
  "```",
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
    "- Integration status: `",
    quality_summary$
      integration_status,
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
  "===== GSE73461-GSE72810 CROSS-COHORT VALIDATION =====\n"
)

cat(
  "validation_cohorts\t",
  uniqueN(
    source_data$cohort_id
  ),
  "\n",
  sep = ""
)

cat(
  "locked_modules\t",
  uniqueN(
    source_data$final_module_id
  ),
  "\n",
  sep = ""
)

cat(
  "source_data_rows_in_memory\t",
  nrow(source_data),
  "\n",
  sep = ""
)

cat(
  "source_data_rows_on_disk\t",
  source_physical_rows,
  "\n",
  sep = ""
)

cat(
  "summary_table_rows_in_memory\t",
  nrow(summary_table),
  "\n",
  sep = ""
)

cat(
  "summary_table_rows_on_disk\t",
  summary_physical_rows,
  "\n",
  sep = ""
)

cat(
  "direction_retained_rows\t",
  sum(
    source_data$direction_retained
  ),
  "\n",
  sep = ""
)

cat(
  "fdr_significant_rows\t",
  sum(
    source_data$fdr_significant
  ),
  "\n",
  sep = ""
)

cat(
  "hl_ci_excluding_zero_rows\t",
  sum(
    source_data$
      hodges_lehmann_ci_excludes_zero
  ),
  "\n",
  sep = ""
)

cat(
  "modules_supported_in_both_cohorts\t",
  sum(
    summary_table$
      both_fdr_significant
  ),
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
  "integration_status\t",
  quality_summary$
    integration_status,
  "\n",
  sep = ""
)

cat(
  "\n===== CROSS-COHORT SUMMARY =====\n"
)

print(
  summary_table[
    ,
    .(
      final_module_id,
      gse73461_primary_result,
      gse73461_bh_p_formatted,
      gse72810_primary_result,
      gse72810_bh_p_formatted,
      both_direction_retained,
      both_hl_ci_exclude_zero,
      both_fdr_significant,
      cross_cohort_interpretation
    )
  ]
)

cat(
  "\nsource_data\t",
  source_data_file,
  "\n",
  sep = ""
)

cat(
  "summary_table\t",
  summary_table_file,
  "\n",
  sep = ""
)

cat(
  "figure_png\t",
  figure_png,
  "\n",
  sep = ""
)

cat(
  "figure_svg\t",
  figure_svg,
  "\n",
  sep = ""
)

cat(
  "figure_pdf\t",
  figure_pdf,
  "\n",
  sep = ""
)

cat(
  "caption\t",
  caption_file,
  "\n",
  sep = ""
)

cat(
  "markdown_table\t",
  markdown_table_file,
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
    "The corrected cross-cohort figure package failed its quality gate."
  )
}
