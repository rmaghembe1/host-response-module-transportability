#!/usr/bin/env Rscript

# =========================================================================
# GSE72810 fixed-module projection scoring
# =========================================================================
#
# Locked analyses
#
# 1. Primary analysis
#    - Frozen highest-median representative probe per mapped Entrez gene.
#    - Gene-wise z-standardization using all 146 GSE72810 samples.
#    - Contrast: 23 Definite Bacterial versus 28 Definite Viral.
#
# 2. Primary-only z-reference sensitivity
#    - Same frozen representative probes.
#    - Gene-wise z-standardization using only the 51 definite samples.
#    - Contrast: 23 Definite Bacterial versus 28 Definite Viral.
#
# 3. Expanded phenotype sensitivity
#    - Same frozen representative probes.
#    - Same all-146-sample z-reference used in the primary analysis.
#    - Contrast: 40 definite-plus-probable bacterial versus
#      35 definite-plus-probable viral.
#
# 4. All-authorized-probe mean sensitivity
#    - Mean expression across all Entrez-authorized probes per gene.
#    - Gene-wise z-standardization using all 146 samples.
#    - Contrast: 23 Definite Bacterial versus 28 Definite Viral.
#
# No probe reselection, module reselection, module renaming, gene
# reweighting, direction flipping or diagnostic-model training is allowed.
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

matrix_file <- paste0(
  "data/expression_raw/GSE72810/",
  "GSE72810_series_matrix.txt.gz"
)

metadata_file <- paste0(
  "data/metadata_harmonized/",
  "GSE72810_sample_metadata_harmonized.tsv"
)

gene_choice_file <- paste0(
  "results/revision_round1/",
  "GSE72810_probe_rule_design/",
  "GSE72810_frozen_representative_probe_choices.tsv"
)

module_choice_file <- paste0(
  "results/revision_round1/",
  "GSE72810_probe_rule_design/",
  "GSE72810_frozen_module_gene_probe_choices.tsv"
)

design_lock_file <- paste0(
  "results/revision_round1/",
  "GSE72810_probe_rule_design/",
  "GSE72810_scoring_design_lock.tsv"
)


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE72810_fixed_module_projection"
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

representative_all_parameters_file <- file.path(
  out_dir,
  "GSE72810_representative_all146_z_parameters.tsv"
)

representative_primary_parameters_file <- file.path(
  out_dir,
  "GSE72810_representative_primary51_z_parameters.tsv"
)

all_probe_parameters_file <- file.path(
  out_dir,
  "GSE72810_all_probe_mean_all146_z_parameters.tsv"
)

scores_file <- file.path(
  out_dir,
  "GSE72810_module_scores_long.tsv"
)

group_summary_file <- file.path(
  out_dir,
  "GSE72810_analysis_group_summaries.tsv"
)

test_results_file <- file.path(
  out_dir,
  "GSE72810_primary_and_sensitivity_tests.tsv"
)

concordance_file <- file.path(
  out_dir,
  "GSE72810_score_concordance.tsv"
)

coverage_file <- file.path(
  out_dir,
  "GSE72810_scoring_module_coverage.tsv"
)

analysis_manifest_file <- file.path(
  out_dir,
  "GSE72810_scoring_analysis_manifest.tsv"
)

quality_checks_file <- file.path(
  out_dir,
  "GSE72810_projection_quality_gate.tsv"
)

quality_summary_file <- file.path(
  out_dir,
  "GSE72810_projection_quality_summary.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE72810_fixed_module_projection_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE72810_fixed_module_projection_sessionInfo.txt"
)

output_files <- c(
  representative_all_parameters_file,
  representative_primary_parameters_file,
  all_probe_parameters_file,
  scores_file,
  group_summary_file,
  test_results_file,
  concordance_file,
  coverage_file,
  analysis_manifest_file,
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
# Locked constants
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

expected_primary_bacterial <- 23L
expected_primary_viral <- 28L

expected_expanded_bacterial <- 40L
expected_expanded_viral <- 35L

expected_module_gene_instances <- 313L
expected_mapped_module_gene_instances <- 303L
expected_unmapped_module_gene_instances <- 10L
expected_unique_mapped_genes <- 256L

expected_score_rows <- (
  expected_total_samples * length(expected_module_ids) +
    51L * length(expected_module_ids) +
    expected_total_samples * length(expected_module_ids)
)

expected_test_rows <- 20L
expected_group_summary_rows <- 40L
expected_concordance_rows <- 10L

primary_bacterial_categories <- "Definite Bacterial"
primary_viral_categories <- "Definite Viral"

expanded_bacterial_categories <- c(
  "Definite Bacterial",
  "Probable Bacterial"
)

expanded_viral_categories <- c(
  "Definite Viral",
  "Probable Viral"
)

analysis_order <- c(
  "main_representative_all146_z_definite",
  "primary_only_representative_51_z_definite",
  "expanded_representative_all146_z_definite_probable",
  "all_probe_mean_all146_z_definite"
)

representation_order <- c(
  "representative_probe_all146_z",
  "representative_probe_primary51_z",
  "all_authorized_probe_mean_all146_z"
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

  allowed_values <- c(
    "TRUE",
    "FALSE",
    "T",
    "F",
    "1",
    "0"
  )

  invalid <- (
    is.na(normalized) |
      !normalized %in%
        allowed_values
  )

  if (any(invalid)) {
    stop(
      paste(
        field_name,
        "contains values that cannot be interpreted as logical."
      )
    )
  }

  normalized %in% c(
    "TRUE",
    "T",
    "1"
  )
}


parse_probe_list <- function(value) {
  value <- as.character(value)

  if (
    length(value) == 0L ||
      is.na(value) ||
      !nzchar(trimws(value)) ||
      identical(trimws(value), "none")
  ) {
    return(character())
  }

  probe_ids <- trimws(
    strsplit(
      value,
      ";",
      fixed = TRUE
    )[[1L]]
  )

  sort(
    unique(
      probe_ids[nzchar(probe_ids)]
    )
  )
}


extract_series_matrix_table <- function(
  input_file
) {
  temporary_file <- tempfile(
    pattern = "GSE72810_expression_",
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

      if (length(begin_index) == 0L) {
        next
      }

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


standardize_gene_matrix <- function(
  gene_matrix,
  reference_sample_ids,
  reference_label
) {
  reference_index <- match(
    reference_sample_ids,
    colnames(gene_matrix)
  )

  if (anyNA(reference_index)) {
    stop(
      paste(
        "Reference samples are absent from the gene matrix for",
        reference_label
      )
    )
  }

  reference_matrix <- gene_matrix[
    ,
    reference_index,
    drop = FALSE
  ]

  reference_means <- rowMeans(
    reference_matrix
  )

  reference_sds <- apply(
    reference_matrix,
    1L,
    sd
  )

  invalid_sd <- (
    is.na(reference_sds) |
      !is.finite(reference_sds) |
      reference_sds <= 0
  )

  if (any(invalid_sd)) {
    stop(
      paste(
        "Zero, missing or non-finite reference SD detected for",
        reference_label,
        ":",
        paste(
          rownames(gene_matrix)[invalid_sd],
          collapse = ", "
        )
      )
    )
  }

  centered_matrix <- sweep(
    gene_matrix,
    1L,
    reference_means,
    "-"
  )

  z_matrix <- sweep(
    centered_matrix,
    1L,
    reference_sds,
    "/"
  )

  if (
    anyNA(z_matrix) ||
      any(!is.finite(z_matrix))
  ) {
    stop(
      paste(
        "Non-finite gene-wise z-scores were generated for",
        reference_label
      )
    )
  }

  list(
    z_matrix = z_matrix,
    reference_means = reference_means,
    reference_sds = reference_sds,
    reference_n = length(reference_sample_ids),
    reference_label = reference_label
  )
}


normalize_expected_direction <- function(
  direction_value
) {
  value <- tolower(
    trimws(
      as.character(direction_value)
    )
  )

  bacterial_values <- c(
    "higher_in_bacterial",
    "bacterial_higher",
    "higher in bacterial",
    "bacterial-associated",
    "bacterial_associated"
  )

  viral_values <- c(
    "higher_in_viral",
    "viral_higher",
    "higher in viral",
    "viral-associated",
    "viral_associated"
  )

  if (value %in% bacterial_values) {
    return("higher_in_bacterial")
  }

  if (value %in% viral_values) {
    return("higher_in_viral")
  }

  if (
    grepl("bacter", value) &&
      grepl(
        "higher|associated",
        value
      )
  ) {
    return("higher_in_bacterial")
  }

  if (
    grepl("viral|virus", value) &&
      grepl(
        "higher|associated",
        value
      )
  ) {
    return("higher_in_viral")
  }

  stop(
    paste(
      "Unrecognized locked module direction:",
      direction_value
    )
  )
}


calculate_module_scores <- function(
  z_matrix,
  scored_sample_ids,
  module_gene_map,
  representation_id,
  z_reference_label,
  probe_collapse_rule
) {
  sample_index <- match(
    scored_sample_ids,
    colnames(z_matrix)
  )

  if (anyNA(sample_index)) {
    stop(
      paste(
        "Scored samples are absent for",
        representation_id
      )
    )
  }

  result_rows <- vector(
    "list",
    length(expected_module_ids)
  )

  for (module_index in seq_along(
    expected_module_ids
  )) {
    module_id <- expected_module_ids[module_index]

    current_map <- module_gene_map[
      final_module_id ==
        module_id
    ]

    if (nrow(current_map) == 0L) {
      stop(
        paste(
          "No mapped genes were recovered for",
          module_id
        )
      )
    }

    if (anyDuplicated(
      current_map$requested_entrez
    )) {
      stop(
        paste(
          "Duplicated Entrez genes were found within",
          module_id
        )
      )
    }

    gene_index <- match(
      current_map$requested_entrez,
      rownames(z_matrix)
    )

    if (anyNA(gene_index)) {
      stop(
        paste(
          "Mapped genes are absent from the z-score matrix for",
          module_id
        )
      )
    }

    module_z <- z_matrix[
      gene_index,
      sample_index,
      drop = FALSE
    ]

    module_scores <- colMeans(
      module_z
    )

    result_rows[[module_index]] <- data.table(
      scoring_representation =
        representation_id,
      z_reference_population =
        z_reference_label,
      probe_collapse_rule =
        probe_collapse_rule,
      geo_accession =
        scored_sample_ids,
      final_module_id =
        module_id,
      final_module_label =
        current_map$
          final_module_label[1L],
      module_direction =
        current_map$
          module_direction[1L],
      mapped_gene_count =
        nrow(current_map),
      module_score =
        as.numeric(module_scores)
    )
  }

  result <- rbindlist(
    result_rows,
    use.names = TRUE,
    fill = TRUE
  )

  if (
    anyNA(result$module_score) ||
      any(!is.finite(result$module_score))
  ) {
    stop(
      paste(
        "Invalid module scores were generated for",
        representation_id
      )
    )
  }

  result
}


summarize_analysis_groups <- function(
  analysis_scores,
  analysis_id,
  analysis_role,
  bacterial_categories,
  viral_categories
) {
  selected <- copy(
    analysis_scores[
      category %in%
        c(
          bacterial_categories,
          viral_categories
        )
    ]
  )

  selected[
    ,
    comparison_group :=
      ifelse(
        category %in%
          bacterial_categories,
        "bacterial",
        "viral"
      )
  ]

  summary_table <- selected[
    ,
    .(
      n = .N,
      mean_score =
        mean(module_score),
      sd_score =
        sd(module_score),
      median_score =
        median(module_score),
      first_quartile =
        as.numeric(
          quantile(
            module_score,
            probs = 0.25,
            names = FALSE
          )
        ),
      third_quartile =
        as.numeric(
          quantile(
            module_score,
            probs = 0.75,
            names = FALSE
          )
        ),
      interquartile_range =
        IQR(module_score),
      minimum_score =
        min(module_score),
      maximum_score =
        max(module_score)
    ),
    by = .(
      final_module_id,
      final_module_label,
      module_direction,
      comparison_group
    )
  ]

  summary_table[
    ,
    analysis_id :=
      analysis_id
  ]

  summary_table[
    ,
    analysis_role :=
      analysis_role
  ]

  setcolorder(
    summary_table,
    c(
      "analysis_id",
      "analysis_role",
      "final_module_id",
      "final_module_label",
      "module_direction",
      "comparison_group",
      "n",
      "mean_score",
      "sd_score",
      "median_score",
      "first_quartile",
      "third_quartile",
      "interquartile_range",
      "minimum_score",
      "maximum_score"
    )
  )

  summary_table
}


test_analysis_groups <- function(
  analysis_scores,
  analysis_id,
  analysis_role,
  bacterial_categories,
  viral_categories,
  expected_bacterial_n,
  expected_viral_n
) {
  selected <- analysis_scores[
    category %in%
      c(
        bacterial_categories,
        viral_categories
      )
  ]

  result_rows <- vector(
    "list",
    length(expected_module_ids)
  )

  for (module_index in seq_along(
    expected_module_ids
  )) {
    module_id <- expected_module_ids[module_index]

    module_scores <- selected[
      final_module_id ==
        module_id
    ]

    bacterial_scores <- module_scores[
      category %in%
        bacterial_categories,
      module_score
    ]

    viral_scores <- module_scores[
      category %in%
        viral_categories,
      module_score
    ]

    if (
      length(bacterial_scores) !=
        expected_bacterial_n ||
        length(viral_scores) !=
          expected_viral_n
    ) {
      stop(
        paste(
          "Unexpected group counts for",
          analysis_id,
          module_id,
          ": bacterial",
          length(bacterial_scores),
          "viral",
          length(viral_scores)
        )
      )
    }

    wilcoxon_result <- suppressWarnings(
      wilcox.test(
        bacterial_scores,
        viral_scores,
        alternative = "two.sided",
        exact = FALSE
      )
    )

    wilcoxon_u <- as.numeric(
      wilcoxon_result$statistic
    )

    rank_biserial <- (
      2 * wilcoxon_u /
        (
          length(bacterial_scores) *
            length(viral_scores)
        )
    ) - 1

    mean_difference <- (
      mean(bacterial_scores) -
        mean(viral_scores)
    )

    median_difference <- (
      median(bacterial_scores) -
        median(viral_scores)
    )

    expected_direction_raw <- module_scores$
      module_direction[1L]

    expected_direction <- normalize_expected_direction(
      expected_direction_raw
    )

    observed_direction <- if (
      median_difference > 0
    ) {
      "higher_in_bacterial"
    } else if (
      median_difference < 0
    ) {
      "higher_in_viral"
    } else {
      "no_median_difference"
    }

    result_rows[[module_index]] <- data.table(
      analysis_id =
        analysis_id,
      analysis_role =
        analysis_role,
      scoring_representation =
        module_scores$
          scoring_representation[1L],
      z_reference_population =
        module_scores$
          z_reference_population[1L],
      probe_collapse_rule =
        module_scores$
          probe_collapse_rule[1L],
      final_module_id =
        module_id,
      final_module_label =
        module_scores$
          final_module_label[1L],
      expected_direction_raw =
        expected_direction_raw,
      expected_direction =
        expected_direction,
      observed_direction =
        observed_direction,
      direction_retained =
        observed_direction ==
          expected_direction,
      bacterial_n =
        length(bacterial_scores),
      viral_n =
        length(viral_scores),
      mean_bacterial =
        mean(bacterial_scores),
      mean_viral =
        mean(viral_scores),
      mean_difference_bacterial_minus_viral =
        mean_difference,
      median_bacterial =
        median(bacterial_scores),
      median_viral =
        median(viral_scores),
      median_difference_bacterial_minus_viral =
        median_difference,
      wilcoxon_u =
        wilcoxon_u,
      rank_biserial_effect =
        rank_biserial,
      wilcoxon_p =
        wilcoxon_result$p.value
    )
  }

  results <- rbindlist(
    result_rows,
    use.names = TRUE,
    fill = TRUE
  )

  results[
    ,
    wilcoxon_q :=
      p.adjust(
        wilcoxon_p,
        method = "BH"
      )
  ]

  results[
    ,
    nominal_significant :=
      wilcoxon_p < 0.05
  ]

  results[
    ,
    fdr_significant :=
      wilcoxon_q < 0.05
  ]

  results
}


calculate_score_concordance <- function(
  all_scores,
  representation_a,
  representation_b,
  sample_ids,
  comparison_id
) {
  table_a <- all_scores[
    scoring_representation ==
      representation_a &
      geo_accession %in%
        sample_ids,
    .(
      geo_accession,
      final_module_id,
      score_a = module_score
    )
  ]

  table_b <- all_scores[
    scoring_representation ==
      representation_b &
      geo_accession %in%
        sample_ids,
    .(
      geo_accession,
      final_module_id,
      score_b = module_score
    )
  ]

  merged <- merge(
    table_a,
    table_b,
    by = c(
      "geo_accession",
      "final_module_id"
    ),
    all = TRUE
  )

  if (
    anyNA(merged$score_a) ||
      anyNA(merged$score_b)
  ) {
    stop(
      paste(
        "Score concordance merge was incomplete for",
        comparison_id
      )
    )
  }

  result <- merged[
    ,
    .(
      sample_count = .N,
      pearson_correlation =
        cor(
          score_a,
          score_b,
          method = "pearson"
        ),
      spearman_correlation =
        cor(
          score_a,
          score_b,
          method = "spearman"
        ),
      mean_absolute_score_difference =
        mean(
          abs(
            score_a -
              score_b
          )
        ),
      median_absolute_score_difference =
        median(
          abs(
            score_a -
              score_b
          )
        ),
      maximum_absolute_score_difference =
        max(
          abs(
            score_a -
              score_b
          )
        )
    ),
    by = final_module_id
  ]

  result[
    ,
    comparison_id :=
      comparison_id
  ]

  result[
    ,
    representation_a :=
      representation_a
  ]

  result[
    ,
    representation_b :=
      representation_b
  ]

  setcolorder(
    result,
    c(
      "comparison_id",
      "representation_a",
      "representation_b",
      "final_module_id",
      "sample_count",
      "pearson_correlation",
      "spearman_correlation",
      "mean_absolute_score_difference",
      "median_absolute_score_difference",
      "maximum_absolute_score_difference"
    )
  )

  result
}


# -------------------------------------------------------------------------
# Validate required files
# -------------------------------------------------------------------------

required_files <- c(
  matrix_file,
  metadata_file,
  gene_choice_file,
  module_choice_file,
  design_lock_file
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
# Validate Phase R1D3A design lock
# -------------------------------------------------------------------------

message(
  "Validating the GSE72810 scoring-design lock..."
)

design_lock <- fread(
  design_lock_file
)

require_columns(
  design_lock,
  c(
    "candidate_dataset",
    "platform",
    "probe_choice_reference_population",
    "representative_probe_reselection",
    "primary_z_reference_population",
    "primary_pathogen_contrast",
    "module_reselection",
    "gene_reweighting",
    "module_renaming",
    "diagnostic_model_training",
    "total_samples",
    "primary_samples",
    "expanded_samples",
    "locked_module_gene_instances",
    "mapped_module_gene_instances",
    "unmapped_module_gene_instances",
    "unique_mapped_entrez_genes",
    "design_status"
  ),
  design_lock_file
)

if (nrow(design_lock) != 1L) {
  stop(
    "The scoring-design lock must contain exactly one row."
  )
}

design_lock_valid <- isTRUE(
  all(
    c(
      design_lock$candidate_dataset[1L] ==
        "GSE72810",
      design_lock$platform[1L] ==
        "GPL6947",
      design_lock$
        probe_choice_reference_population[1L] ==
        "All 146 GSE72810 samples",
      design_lock$
        representative_probe_reselection[1L] ==
        "Not permitted after this design lock",
      design_lock$
        primary_z_reference_population[1L] ==
        "All 146 GSE72810 samples",
      design_lock$
        primary_pathogen_contrast[1L] ==
        "23 Definite Bacterial versus 28 Definite Viral",
      design_lock$module_reselection[1L] ==
        "Not permitted",
      design_lock$gene_reweighting[1L] ==
        "Not permitted",
      design_lock$module_renaming[1L] ==
        "Not permitted",
      design_lock$diagnostic_model_training[1L] ==
        "Not permitted",
      as.integer(
        design_lock$total_samples[1L]
      ) ==
        expected_total_samples,
      as.integer(
        design_lock$primary_samples[1L]
      ) ==
        51L,
      as.integer(
        design_lock$expanded_samples[1L]
      ) ==
        75L,
      as.integer(
        design_lock$
          locked_module_gene_instances[1L]
      ) ==
        expected_module_gene_instances,
      as.integer(
        design_lock$
          mapped_module_gene_instances[1L]
      ) ==
        expected_mapped_module_gene_instances,
      as.integer(
        design_lock$
          unmapped_module_gene_instances[1L]
      ) ==
        expected_unmapped_module_gene_instances,
      as.integer(
        design_lock$
          unique_mapped_entrez_genes[1L]
      ) ==
        expected_unique_mapped_genes,
      design_lock$design_status[1L] ==
        "LOCKED_READY_FOR_FIXED_MODULE_SCORING"
    )
  )
)

if (!design_lock_valid) {
  stop(
    "The Phase R1D3A scoring-design lock did not validate."
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
    "The expression table does not contain ID_REF."
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

if (
  anyNA(expression_matrix) ||
    any(!is.finite(expression_matrix))
) {
  stop(
    "The processed expression matrix contains invalid values."
  )
}


# -------------------------------------------------------------------------
# Read harmonized sample metadata
# -------------------------------------------------------------------------

message(
  "Reading harmonized sample metadata..."
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

metadata[
  ,
  geo_accession :=
    as.character(geo_accession)
]

metadata[
  ,
  category :=
    as.character(category)
]

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
    "Expression and metadata sample orders do not match."
  )
}

primary_sample_ids <- metadata[
  category %in%
    c(
      primary_bacterial_categories,
      primary_viral_categories
    ),
  geo_accession
]

expanded_sample_ids <- metadata[
  category %in%
    c(
      expanded_bacterial_categories,
      expanded_viral_categories
    ),
  geo_accession
]

primary_bacterial_n <- metadata[
  category %in%
    primary_bacterial_categories,
  .N
]

primary_viral_n <- metadata[
  category %in%
    primary_viral_categories,
  .N
]

expanded_bacterial_n <- metadata[
  category %in%
    expanded_bacterial_categories,
  .N
]

expanded_viral_n <- metadata[
  category %in%
    expanded_viral_categories,
  .N
]

if (
  primary_bacterial_n !=
    expected_primary_bacterial ||
    primary_viral_n !=
      expected_primary_viral ||
    expanded_bacterial_n !=
      expected_expanded_bacterial ||
    expanded_viral_n !=
      expected_expanded_viral
) {
  stop(
    "The locked comparison-group counts were not recovered."
  )
}

if (
  length(primary_sample_ids) !=
    51L ||
    length(expanded_sample_ids) !=
      75L
) {
  stop(
    "The locked primary or expanded sample count was not recovered."
  )
}


# -------------------------------------------------------------------------
# Read frozen unique-gene representative probes
# -------------------------------------------------------------------------

message(
  "Reading frozen representative probes..."
)

gene_choices <- fread(
  gene_choice_file
)

require_columns(
  gene_choices,
  c(
    "requested_entrez",
    "requested_symbol",
    "candidate_probe_count",
    "probe_id",
    "selection_rule",
    "selection_reference_population",
    "representative_probe_frozen"
  ),
  gene_choice_file
)

gene_choices[
  ,
  requested_entrez :=
    as.character(requested_entrez)
]

gene_choices[
  ,
  requested_symbol :=
    as.character(requested_symbol)
]

gene_choices[
  ,
  probe_id :=
    as.character(probe_id)
]

gene_choices[
  ,
  representative_probe_frozen :=
    coerce_logical_strict(
      representative_probe_frozen,
      "gene_choices$representative_probe_frozen"
    )
]

if (
  nrow(gene_choices) !=
    expected_unique_mapped_genes ||
    anyDuplicated(
      gene_choices$requested_entrez
    )
) {
  stop(
    "The frozen representative-probe table failed count or uniqueness checks."
  )
}

if (!all(
  gene_choices$representative_probe_frozen
)) {
  stop(
    "At least one unique-gene representative probe is not frozen."
  )
}

if (!all(
  gene_choices$
    selection_reference_population ==
    "All 146 GSE72810 samples"
)) {
  stop(
    "The frozen probe table does not use the locked all-sample reference."
  )
}

representative_probe_index <- match(
  gene_choices$probe_id,
  rownames(expression_matrix)
)

if (anyNA(representative_probe_index)) {
  stop(
    paste(
      "Frozen representative probes absent from the expression matrix:",
      paste(
        gene_choices$
          probe_id[
            is.na(
              representative_probe_index
            )
          ],
        collapse = ", "
      )
    )
  )
}

representative_expression <- expression_matrix[
  representative_probe_index,
  ,
  drop = FALSE
]

rownames(
  representative_expression
) <- gene_choices$requested_entrez

if (anyDuplicated(
  rownames(representative_expression)
)) {
  stop(
    "The representative-gene expression matrix contains duplicate Entrez IDs."
  )
}


# -------------------------------------------------------------------------
# Read frozen module-gene probe choices
# -------------------------------------------------------------------------

message(
  "Reading frozen module-gene probe choices..."
)

module_choices <- fread(
  module_choice_file
)

require_columns(
  module_choices,
  c(
    "final_module_id",
    "final_module_label",
    "module_direction",
    "requested_symbol",
    "requested_entrez",
    "mapped",
    "accepted_probe_count",
    "accepted_probe_ids",
    "selected_probe_id",
    "representative_probe_frozen"
  ),
  module_choice_file
)

module_choices[
  ,
  final_module_id :=
    as.character(final_module_id)
]

module_choices[
  ,
  final_module_label :=
    as.character(final_module_label)
]

module_choices[
  ,
  module_direction :=
    as.character(module_direction)
]

module_choices[
  ,
  requested_symbol :=
    as.character(requested_symbol)
]

module_choices[
  ,
  requested_entrez :=
    as.character(requested_entrez)
]

module_choices[
  ,
  accepted_probe_ids :=
    as.character(accepted_probe_ids)
]

module_choices[
  ,
  selected_probe_id :=
    as.character(selected_probe_id)
]

module_choices[
  ,
  mapped :=
    coerce_logical_strict(
      mapped,
      "module_choices$mapped"
    )
]

mapped_indices <- which(
  module_choices$mapped
)

mapped_freeze_values <- coerce_logical_strict(
  module_choices$
    representative_probe_frozen[
      mapped_indices
    ],
  "mapped module_choices$representative_probe_frozen"
)

module_choices[
  ,
  representative_probe_frozen_parsed :=
    as.logical(NA)
]

module_choices[
  mapped_indices,
  representative_probe_frozen_parsed :=
    mapped_freeze_values
]

module_choices[
  ,
  representative_probe_frozen :=
    representative_probe_frozen_parsed
]

module_choices[
  ,
  representative_probe_frozen_parsed :=
    NULL
]

if (
  nrow(module_choices) !=
    expected_module_gene_instances
) {
  stop(
    "The module-gene probe-choice table does not contain 313 rows."
  )
}

if (
  sum(module_choices$mapped) !=
    expected_mapped_module_gene_instances ||
    sum(!module_choices$mapped) !=
      expected_unmapped_module_gene_instances
) {
  stop(
    "Mapped or unmapped module-gene counts do not match the lock."
  )
}

if (
  !setequal(
    unique(module_choices$final_module_id),
    expected_module_ids
  )
) {
  stop(
    "Unexpected module identifiers were detected."
  )
}

mapped_module_choices <- module_choices[
  mapped == TRUE
]

unmapped_module_choices <- module_choices[
  mapped == FALSE
]

if (
  anyNA(
    mapped_module_choices$
      representative_probe_frozen
  ) ||
    !all(
      mapped_module_choices$
        representative_probe_frozen
    )
) {
  stop(
    "At least one mapped module-gene representative probe is not frozen."
  )
}

if (
  any(
    !is.na(
      unmapped_module_choices$
        selected_probe_id
    ) &
      nzchar(
        unmapped_module_choices$
          selected_probe_id
      )
  )
) {
  stop(
    "At least one unmapped module-gene row contains a selected probe."
  )
}

selected_probe_consistency <- merge(
  unique(
    mapped_module_choices[
      ,
      .(
        requested_entrez,
        selected_probe_id
      )
    ]
  ),
  gene_choices[
    ,
    .(
      requested_entrez,
      frozen_probe_id =
        probe_id
    )
  ],
  by = "requested_entrez",
  all = TRUE
)

if (
  anyNA(
    selected_probe_consistency$
      selected_probe_id
  ) ||
    anyNA(
      selected_probe_consistency$
        frozen_probe_id
    ) ||
    any(
      selected_probe_consistency$
        selected_probe_id !=
        selected_probe_consistency$
          frozen_probe_id
    )
) {
  stop(
    "Module-gene and unique-gene frozen probe choices are inconsistent."
  )
}

module_gene_map <- unique(
  mapped_module_choices[
    ,
    .(
      final_module_id,
      final_module_label,
      module_direction,
      requested_entrez,
      requested_symbol
    )
  ]
)

if (
  nrow(module_gene_map) !=
    expected_mapped_module_gene_instances
) {
  stop(
    "The mapped module-gene scoring table does not contain 303 rows."
  )
}

module_direction_check <- unique(
  module_gene_map[
    ,
    .(
      final_module_id,
      module_direction
    )
  ]
)

if (
  nrow(module_direction_check) !=
    length(expected_module_ids)
) {
  stop(
    "At least one module has inconsistent locked direction values."
  )
}

invisible(
  vapply(
    module_direction_check$module_direction,
    normalize_expected_direction,
    character(1L)
  )
)


# -------------------------------------------------------------------------
# Build all-authorized-probe mean gene expression
# -------------------------------------------------------------------------

message(
  "Constructing all-authorized-probe mean gene expression..."
)

gene_probe_sets <- mapped_module_choices[
  ,
  .(
    requested_symbol =
      requested_symbol[1L],
    accepted_probe_count =
      accepted_probe_count[1L],
    accepted_probe_ids =
      accepted_probe_ids[1L],
    symbol_count =
      uniqueN(requested_symbol),
    accepted_probe_count_count =
      uniqueN(accepted_probe_count),
    accepted_probe_set_count =
      uniqueN(accepted_probe_ids)
  ),
  by = requested_entrez
]

inconsistent_probe_sets <- gene_probe_sets[
  symbol_count != 1L |
    accepted_probe_count_count != 1L |
    accepted_probe_set_count != 1L
]

if (nrow(inconsistent_probe_sets) > 0L) {
  print(inconsistent_probe_sets)

  stop(
    "Accepted probe sets are inconsistent across module memberships."
  )
}

if (
  nrow(gene_probe_sets) !=
    expected_unique_mapped_genes ||
    anyDuplicated(
      gene_probe_sets$requested_entrez
    )
) {
  stop(
    "The all-probe gene-definition table failed validation."
  )
}

all_probe_expression <- matrix(
  NA_real_,
  nrow = nrow(gene_probe_sets),
  ncol = ncol(expression_matrix),
  dimnames = list(
    gene_probe_sets$requested_entrez,
    colnames(expression_matrix)
  )
)

all_authorized_probe_ids <- character()

for (gene_index in seq_len(
  nrow(gene_probe_sets)
)) {
  current_probe_ids <- parse_probe_list(
    gene_probe_sets$
      accepted_probe_ids[gene_index]
  )

  expected_probe_count <- gene_probe_sets$
    accepted_probe_count[gene_index]

  if (
    length(current_probe_ids) !=
      expected_probe_count
  ) {
    stop(
      paste(
        "Accepted-probe count mismatch for",
        gene_probe_sets$
          requested_symbol[gene_index]
      )
    )
  }

  current_probe_index <- match(
    current_probe_ids,
    rownames(expression_matrix)
  )

  if (anyNA(current_probe_index)) {
    stop(
      paste(
        "Authorized probes are missing for",
        gene_probe_sets$
          requested_symbol[gene_index]
      )
    )
  }

  all_authorized_probe_ids <- c(
    all_authorized_probe_ids,
    current_probe_ids
  )

  current_expression <- expression_matrix[
    current_probe_index,
    ,
    drop = FALSE
  ]

  all_probe_expression[
    gene_index,
  ] <- colMeans(
    current_expression
  )
}

if (
  anyNA(all_probe_expression) ||
    any(!is.finite(all_probe_expression))
) {
  stop(
    "The all-probe mean gene-expression matrix contains invalid values."
  )
}


# -------------------------------------------------------------------------
# Gene-wise z-standardization
# -------------------------------------------------------------------------

message(
  "Calculating gene-wise z-scores..."
)

representative_all_z <- standardize_gene_matrix(
  gene_matrix =
    representative_expression,
  reference_sample_ids =
    metadata$geo_accession,
  reference_label =
    "All 146 GSE72810 samples"
)

representative_primary_z <- standardize_gene_matrix(
  gene_matrix =
    representative_expression,
  reference_sample_ids =
    primary_sample_ids,
  reference_label =
    "51 definite bacterial and viral samples"
)

all_probe_all_z <- standardize_gene_matrix(
  gene_matrix =
    all_probe_expression,
  reference_sample_ids =
    metadata$geo_accession,
  reference_label =
    "All 146 GSE72810 samples"
)


# -------------------------------------------------------------------------
# Z-reference parameter tables
# -------------------------------------------------------------------------

representative_all_parameters <- data.table(
  requested_entrez =
    gene_choices$requested_entrez,
  requested_symbol =
    gene_choices$requested_symbol,
  selected_probe_id =
    gene_choices$probe_id,
  candidate_probe_count =
    gene_choices$candidate_probe_count,
  reference_population =
    representative_all_z$
      reference_label,
  reference_n =
    representative_all_z$
      reference_n,
  reference_mean =
    representative_all_z$
      reference_means[
        gene_choices$
          requested_entrez
      ],
  reference_sd =
    representative_all_z$
      reference_sds[
        gene_choices$
          requested_entrez
      ]
)

representative_primary_parameters <- data.table(
  requested_entrez =
    gene_choices$requested_entrez,
  requested_symbol =
    gene_choices$requested_symbol,
  selected_probe_id =
    gene_choices$probe_id,
  candidate_probe_count =
    gene_choices$candidate_probe_count,
  reference_population =
    representative_primary_z$
      reference_label,
  reference_n =
    representative_primary_z$
      reference_n,
  reference_mean =
    representative_primary_z$
      reference_means[
        gene_choices$
          requested_entrez
      ],
  reference_sd =
    representative_primary_z$
      reference_sds[
        gene_choices$
          requested_entrez
      ]
)

all_probe_parameters <- data.table(
  requested_entrez =
    gene_probe_sets$requested_entrez,
  requested_symbol =
    gene_probe_sets$requested_symbol,
  authorized_probe_count =
    gene_probe_sets$accepted_probe_count,
  authorized_probe_ids =
    gene_probe_sets$accepted_probe_ids,
  reference_population =
    all_probe_all_z$
      reference_label,
  reference_n =
    all_probe_all_z$
      reference_n,
  reference_mean =
    all_probe_all_z$
      reference_means[
        gene_probe_sets$
          requested_entrez
      ],
  reference_sd =
    all_probe_all_z$
      reference_sds[
        gene_probe_sets$
          requested_entrez
      ]
)

setorder(
  representative_all_parameters,
  requested_symbol,
  requested_entrez
)

setorder(
  representative_primary_parameters,
  requested_symbol,
  requested_entrez
)

setorder(
  all_probe_parameters,
  requested_symbol,
  requested_entrez
)


# -------------------------------------------------------------------------
# Module-score calculation
# -------------------------------------------------------------------------

message(
  "Calculating locked module scores..."
)

representative_all_scores <- calculate_module_scores(
  z_matrix =
    representative_all_z$z_matrix,
  scored_sample_ids =
    metadata$geo_accession,
  module_gene_map =
    module_gene_map,
  representation_id =
    "representative_probe_all146_z",
  z_reference_label =
    "All 146 GSE72810 samples",
  probe_collapse_rule =
    "Frozen highest-median Entrez-authorized representative probe"
)

representative_primary_scores <- calculate_module_scores(
  z_matrix =
    representative_primary_z$z_matrix,
  scored_sample_ids =
    primary_sample_ids,
  module_gene_map =
    module_gene_map,
  representation_id =
    "representative_probe_primary51_z",
  z_reference_label =
    "51 definite bacterial and viral samples",
  probe_collapse_rule =
    "Same frozen representative probes; no probe reselection"
)

all_probe_scores <- calculate_module_scores(
  z_matrix =
    all_probe_all_z$z_matrix,
  scored_sample_ids =
    metadata$geo_accession,
  module_gene_map =
    module_gene_map,
  representation_id =
    "all_authorized_probe_mean_all146_z",
  z_reference_label =
    "All 146 GSE72810 samples",
  probe_collapse_rule =
    "Mean expression across all Entrez-authorized probes per gene"
)

scores <- rbindlist(
  list(
    representative_all_scores,
    representative_primary_scores,
    all_probe_scores
  ),
  use.names = TRUE,
  fill = TRUE
)

metadata_index <- match(
  scores$geo_accession,
  metadata$geo_accession
)

if (anyNA(metadata_index)) {
  stop(
    "Module-score samples could not be matched to metadata."
  )
}

scores[
  ,
  sample_order :=
    metadata$
      sample_order[metadata_index]
]

scores[
  ,
  category :=
    metadata$
      category[metadata_index]
]

scores[
  ,
  projection_role :=
    metadata$
      projection_role[metadata_index]
]

scores[
  ,
  include_primary_definite :=
    metadata$
      include_primary_definite[metadata_index]
]

scores[
  ,
  include_expanded_definite_probable :=
    metadata$
      include_expanded_definite_probable[metadata_index]
]

scores[
  ,
  include_all_sample_reference :=
    metadata$
      include_all_sample_reference[metadata_index]
]

scores[
  ,
  representation_order :=
    match(
      scoring_representation,
      representation_order
    )
]

scores[
  ,
  module_order :=
    match(
      final_module_id,
      expected_module_ids
    )
]

setorder(
  scores,
  representation_order,
  sample_order,
  module_order
)

scores[
  ,
  c(
    "representation_order",
    "module_order"
  ) := NULL
]

if (
  anyDuplicated(
    scores[
      ,
      .(
        scoring_representation,
        geo_accession,
        final_module_id
      )
    ]
  )
) {
  stop(
    "Duplicated module-score keys were generated."
  )
}


# -------------------------------------------------------------------------
# Analysis manifest
# -------------------------------------------------------------------------

analysis_manifest <- data.table(
  analysis_id = analysis_order,
  analysis_role = c(
    "primary",
    "z_reference_sensitivity",
    "expanded_case_definition_sensitivity",
    "probe_collapse_sensitivity"
  ),
  scoring_representation = c(
    "representative_probe_all146_z",
    "representative_probe_primary51_z",
    "representative_probe_all146_z",
    "all_authorized_probe_mean_all146_z"
  ),
  z_reference_population = c(
    "All 146 GSE72810 samples",
    "51 definite bacterial and viral samples",
    "All 146 GSE72810 samples",
    "All 146 GSE72810 samples"
  ),
  bacterial_categories = c(
    "Definite Bacterial",
    "Definite Bacterial",
    "Definite Bacterial;Probable Bacterial",
    "Definite Bacterial"
  ),
  viral_categories = c(
    "Definite Viral",
    "Definite Viral",
    "Definite Viral;Probable Viral",
    "Definite Viral"
  ),
  bacterial_n = c(
    expected_primary_bacterial,
    expected_primary_bacterial,
    expected_expanded_bacterial,
    expected_primary_bacterial
  ),
  viral_n = c(
    expected_primary_viral,
    expected_primary_viral,
    expected_expanded_viral,
    expected_primary_viral
  ),
  representative_probe_reselection =
    "Not permitted",
  module_reselection =
    "Not permitted",
  gene_reweighting =
    "Not permitted",
  module_renaming =
    "Not permitted",
  direction_flipping =
    "Not permitted",
  diagnostic_model_training =
    "Not permitted"
)


# -------------------------------------------------------------------------
# Primary and sensitivity statistics
# -------------------------------------------------------------------------

message(
  "Running primary and sensitivity comparisons..."
)

main_scores <- scores[
  scoring_representation ==
    "representative_probe_all146_z"
]

primary_only_scores <- scores[
  scoring_representation ==
    "representative_probe_primary51_z"
]

all_probe_mean_scores <- scores[
  scoring_representation ==
    "all_authorized_probe_mean_all146_z"
]

group_summaries <- rbindlist(
  list(
    summarize_analysis_groups(
      analysis_scores =
        main_scores,
      analysis_id =
        analysis_order[1L],
      analysis_role =
        "primary",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories
    ),
    summarize_analysis_groups(
      analysis_scores =
        primary_only_scores,
      analysis_id =
        analysis_order[2L],
      analysis_role =
        "z_reference_sensitivity",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories
    ),
    summarize_analysis_groups(
      analysis_scores =
        main_scores,
      analysis_id =
        analysis_order[3L],
      analysis_role =
        "expanded_case_definition_sensitivity",
      bacterial_categories =
        expanded_bacterial_categories,
      viral_categories =
        expanded_viral_categories
    ),
    summarize_analysis_groups(
      analysis_scores =
        all_probe_mean_scores,
      analysis_id =
        analysis_order[4L],
      analysis_role =
        "probe_collapse_sensitivity",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories
    )
  ),
  use.names = TRUE,
  fill = TRUE
)

group_summaries[
  ,
  analysis_order_column :=
    match(
      analysis_id,
      analysis_order
    )
]

group_summaries[
  ,
  module_order :=
    match(
      final_module_id,
      expected_module_ids
    )
]

setorder(
  group_summaries,
  analysis_order_column,
  module_order,
  comparison_group
)

group_summaries[
  ,
  c(
    "analysis_order_column",
    "module_order"
  ) := NULL
]

test_results <- rbindlist(
  list(
    test_analysis_groups(
      analysis_scores =
        main_scores,
      analysis_id =
        analysis_order[1L],
      analysis_role =
        "primary",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories,
      expected_bacterial_n =
        expected_primary_bacterial,
      expected_viral_n =
        expected_primary_viral
    ),
    test_analysis_groups(
      analysis_scores =
        primary_only_scores,
      analysis_id =
        analysis_order[2L],
      analysis_role =
        "z_reference_sensitivity",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories,
      expected_bacterial_n =
        expected_primary_bacterial,
      expected_viral_n =
        expected_primary_viral
    ),
    test_analysis_groups(
      analysis_scores =
        main_scores,
      analysis_id =
        analysis_order[3L],
      analysis_role =
        "expanded_case_definition_sensitivity",
      bacterial_categories =
        expanded_bacterial_categories,
      viral_categories =
        expanded_viral_categories,
      expected_bacterial_n =
        expected_expanded_bacterial,
      expected_viral_n =
        expected_expanded_viral
    ),
    test_analysis_groups(
      analysis_scores =
        all_probe_mean_scores,
      analysis_id =
        analysis_order[4L],
      analysis_role =
        "probe_collapse_sensitivity",
      bacterial_categories =
        primary_bacterial_categories,
      viral_categories =
        primary_viral_categories,
      expected_bacterial_n =
        expected_primary_bacterial,
      expected_viral_n =
        expected_primary_viral
    )
  ),
  use.names = TRUE,
  fill = TRUE
)

test_results[
  ,
  analysis_order_column :=
    match(
      analysis_id,
      analysis_order
    )
]

test_results[
  ,
  module_order :=
    match(
      final_module_id,
      expected_module_ids
    )
]

setorder(
  test_results,
  analysis_order_column,
  module_order
)

test_results[
  ,
  c(
    "analysis_order_column",
    "module_order"
  ) := NULL
]

if (
  anyDuplicated(
    test_results[
      ,
      .(
        analysis_id,
        final_module_id
      )
    ]
  )
) {
  stop(
    "Duplicated analysis-test keys were generated."
  )
}


# -------------------------------------------------------------------------
# Score concordance
# -------------------------------------------------------------------------

message(
  "Calculating score concordance..."
)

score_concordance <- rbindlist(
  list(
    calculate_score_concordance(
      all_scores =
        scores,
      representation_a =
        "representative_probe_all146_z",
      representation_b =
        "representative_probe_primary51_z",
      sample_ids =
        primary_sample_ids,
      comparison_id =
        "main_all146_z_vs_primary51_z_within_definite_samples"
    ),
    calculate_score_concordance(
      all_scores =
        scores,
      representation_a =
        "representative_probe_all146_z",
      representation_b =
        "all_authorized_probe_mean_all146_z",
      sample_ids =
        metadata$geo_accession,
      comparison_id =
        "representative_probe_vs_all_probe_mean_all146_samples"
    )
  ),
  use.names = TRUE,
  fill = TRUE
)

score_concordance[
  ,
  comparison_order :=
    match(
      comparison_id,
      c(
        "main_all146_z_vs_primary51_z_within_definite_samples",
        "representative_probe_vs_all_probe_mean_all146_samples"
      )
    )
]

score_concordance[
  ,
  module_order :=
    match(
      final_module_id,
      expected_module_ids
    )
]

setorder(
  score_concordance,
  comparison_order,
  module_order
)

score_concordance[
  ,
  c(
    "comparison_order",
    "module_order"
  ) := NULL
]

if (
  anyNA(
    score_concordance$
      pearson_correlation
  ) ||
    anyNA(
      score_concordance$
        spearman_correlation
    ) ||
    any(
      !is.finite(
        score_concordance$
          pearson_correlation
      )
    ) ||
    any(
      !is.finite(
        score_concordance$
          spearman_correlation
      )
    )
) {
  stop(
    "At least one score-concordance coefficient is invalid."
  )
}


# -------------------------------------------------------------------------
# Module coverage
# -------------------------------------------------------------------------

module_coverage <- module_choices[
  ,
  {
    missing_symbols <- sort(
      requested_symbol[
        !mapped
      ]
    )

    list(
      locked_gene_count =
        .N,
      mapped_gene_count =
        sum(mapped),
      missing_gene_count =
        sum(!mapped),
      coverage_fraction =
        sum(mapped) / .N,
      missing_symbols =
        if (
          length(missing_symbols) == 0L
        ) {
          "none"
        } else {
          paste(
            missing_symbols,
            collapse = ";"
          )
        },
      representative_probes_frozen =
        all(
          representative_probe_frozen[
            mapped
          ]
        )
    )
  },
  by = .(
    final_module_id,
    final_module_label,
    module_direction
  )
]

module_coverage[
  ,
  module_order :=
    match(
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


# -------------------------------------------------------------------------
# Quality gate
# -------------------------------------------------------------------------

quality_checks <- data.table(
  check_id = sprintf(
    "Q%02d",
    seq_len(21L)
  ),
  check_description = c(
    "Phase R1D3A design lock validates",
    "Expression matrix contains 48,803 unique probes",
    "Expression matrix contains 146 samples",
    "Expression and metadata sample orders match",
    "Frozen representative table contains 256 unique Entrez genes",
    "Frozen module-gene table contains 313 instances",
    "Mapped module-gene instances equal 303",
    "Unmapped module-gene instances equal 10",
    "All frozen representative probes are present",
    "All authorized probes are present",
    "Representative all-sample reference SDs are positive",
    "Representative primary-only reference SDs are positive",
    "All-probe-mean all-sample reference SDs are positive",
    "All module scores are finite",
    "Module-score row count matches the locked design",
    "Module-score keys are unique",
    "Twenty analysis-test rows were generated",
    "Forty group-summary rows were generated",
    "Ten score-concordance rows were generated and finite",
    "All five modules retain at least 70 percent mapped coverage",
    "All analysis definitions prohibit reselection and model training"
  ),
  pass = c(
    design_lock_valid,
    nrow(expression_dt) ==
      expected_feature_rows &&
      !anyDuplicated(
        expression_dt$ID_REF
      ),
    length(sample_columns) ==
      expected_total_samples,
    identical(
      sample_columns,
      metadata$geo_accession
    ),
    nrow(gene_choices) ==
      expected_unique_mapped_genes &&
      !anyDuplicated(
        gene_choices$requested_entrez
      ),
    nrow(module_choices) ==
      expected_module_gene_instances,
    sum(module_choices$mapped) ==
      expected_mapped_module_gene_instances,
    sum(!module_choices$mapped) ==
      expected_unmapped_module_gene_instances,
    !anyNA(
      representative_probe_index
    ),
    all(
      unique(
        all_authorized_probe_ids
      ) %in%
        rownames(expression_matrix)
    ),
    all(
      representative_all_z$
        reference_sds > 0
    ),
    all(
      representative_primary_z$
        reference_sds > 0
    ),
    all(
      all_probe_all_z$
        reference_sds > 0
    ),
    !anyNA(scores$module_score) &&
      all(
        is.finite(
          scores$module_score
        )
      ),
    nrow(scores) ==
      expected_score_rows,
    !anyDuplicated(
      scores[
        ,
        .(
          scoring_representation,
          geo_accession,
          final_module_id
        )
      ]
    ),
    nrow(test_results) ==
      expected_test_rows,
    nrow(group_summaries) ==
      expected_group_summary_rows,
    nrow(score_concordance) ==
      expected_concordance_rows &&
      all(
        is.finite(
          score_concordance$
            pearson_correlation
        )
      ) &&
      all(
        is.finite(
          score_concordance$
            spearman_correlation
        )
      ),
    nrow(module_coverage) ==
      length(expected_module_ids) &&
      all(
        module_coverage$
          coverage_fraction >=
          0.70
      ),
    nrow(analysis_manifest) == 4L &&
      all(
        analysis_manifest$
          representative_probe_reselection ==
          "Not permitted"
      ) &&
      all(
        analysis_manifest$
          module_reselection ==
          "Not permitted"
      ) &&
      all(
        analysis_manifest$
          gene_reweighting ==
          "Not permitted"
      ) &&
      all(
        analysis_manifest$
          module_renaming ==
          "Not permitted"
      ) &&
      all(
        analysis_manifest$
          direction_flipping ==
          "Not permitted"
      ) &&
      all(
        analysis_manifest$
          diagnostic_model_training ==
          "Not permitted"
      )
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
  score_rows =
    nrow(scores),
  test_rows =
    nrow(test_results),
  group_summary_rows =
    nrow(group_summaries),
  concordance_rows =
    nrow(score_concordance),
  direction_retained_rows =
    sum(test_results$direction_retained),
  nominally_significant_rows =
    sum(test_results$nominal_significant),
  fdr_significant_rows =
    sum(test_results$fdr_significant),
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  projection_status =
    ifelse(
      quality_gate_pass,
      "READY_FOR_EFFECT_SIZE_AND_FIGURE_ANALYSIS",
      "PROJECTION_REVIEW_REQUIRED"
    )
)


# -------------------------------------------------------------------------
# Write output tables
# -------------------------------------------------------------------------

fwrite(
  representative_all_parameters,
  representative_all_parameters_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  representative_primary_parameters,
  representative_primary_parameters_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  all_probe_parameters,
  all_probe_parameters_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  scores,
  scores_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  group_summaries,
  group_summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  test_results,
  test_results_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  score_concordance,
  concordance_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  module_coverage,
  coverage_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  analysis_manifest,
  analysis_manifest_file,
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

test_preview <- capture.output(
  print(
    test_results[
      ,
      .(
        analysis_id,
        final_module_id,
        bacterial_n,
        viral_n,
        median_difference_bacterial_minus_viral,
        rank_biserial_effect,
        wilcoxon_p,
        wilcoxon_q,
        direction_retained,
        fdr_significant
      )
    ]
  )
)

direction_summary <- test_results[
  ,
  .(
    modules_direction_retained =
      sum(direction_retained),
    nominally_significant_modules =
      sum(nominal_significant),
    fdr_significant_modules =
      sum(fdr_significant)
  ),
  by = analysis_id
]

direction_preview <- capture.output(
  print(direction_summary)
)

concordance_preview <- capture.output(
  print(score_concordance)
)

coverage_preview <- capture.output(
  print(module_coverage)
)

quality_preview <- capture.output(
  print(quality_checks)
)

report_lines <- c(
  "# GSE72810 fixed-module projection report",
  "",
  "## Locked analytical framework",
  "",
  paste(
    "The five discovery modules were projected without probe",
    "reselection, gene reselection, module redefinition, gene",
    "reweighting, module renaming, direction flipping or",
    "diagnostic-model training."
  ),
  "",
  paste(
    "The primary analysis used the frozen representative probes",
    "and gene-wise z-standardization across all 146 samples before",
    "comparing 23 definite bacterial with 28 definite viral samples."
  ),
  "",
  "## Prespecified sensitivity analyses",
  "",
  paste(
    "1. Primary-only z-reference sensitivity using the same frozen",
    "probes and the 51 definite bacterial and viral samples."
  ),
  paste(
    "2. Expanded phenotype sensitivity comparing 40 definite-plus-",
    "probable bacterial with 35 definite-plus-probable viral samples."
  ),
  paste(
    "3. Probe-collapse sensitivity using mean expression across all",
    "Entrez-authorized probes per mapped gene."
  ),
  "",
  "## Direction and significance summary",
  "",
  "```text",
  direction_preview,
  "```",
  "",
  "## Primary and sensitivity results",
  "",
  "```text",
  test_preview,
  "```",
  "",
  "## Score concordance",
  "",
  "```text",
  concordance_preview,
  "```",
  "",
  "## Module coverage",
  "",
  "```text",
  coverage_preview,
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
    "- Projection status: `",
    quality_summary$projection_status,
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
  "===== GSE72810 FIXED-MODULE PROJECTION =====\n"
)

cat(
  "total_samples\t",
  nrow(metadata),
  "\n",
  sep = ""
)

cat(
  "primary_bacterial\t",
  primary_bacterial_n,
  "\n",
  sep = ""
)

cat(
  "primary_viral\t",
  primary_viral_n,
  "\n",
  sep = ""
)

cat(
  "expanded_bacterial\t",
  expanded_bacterial_n,
  "\n",
  sep = ""
)

cat(
  "expanded_viral\t",
  expanded_viral_n,
  "\n",
  sep = ""
)

cat(
  "unique_mapped_genes\t",
  nrow(gene_choices),
  "\n",
  sep = ""
)

cat(
  "mapped_module_gene_instances\t",
  sum(module_choices$mapped),
  "\n",
  sep = ""
)

cat(
  "module_score_rows\t",
  nrow(scores),
  "\n",
  sep = ""
)

cat(
  "analysis_test_rows\t",
  nrow(test_results),
  "\n",
  sep = ""
)

cat(
  "group_summary_rows\t",
  nrow(group_summaries),
  "\n",
  sep = ""
)

cat(
  "score_concordance_rows\t",
  nrow(score_concordance),
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
  "projection_status\t",
  quality_summary$projection_status,
  "\n",
  sep = ""
)

cat(
  "\n===== DIRECTION AND SIGNIFICANCE SUMMARY =====\n"
)

print(direction_summary)

cat(
  "\nscores\t",
  scores_file,
  "\n",
  sep = ""
)

cat(
  "tests\t",
  test_results_file,
  "\n",
  sep = ""
)

cat(
  "concordance\t",
  concordance_file,
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
    "The GSE72810 fixed-module projection failed its quality gate."
  )
}
