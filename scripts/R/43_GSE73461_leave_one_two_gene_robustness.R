#!/usr/bin/env Rscript

# GSE73461 exhaustive leave-one- and leave-two-gene robustness analysis
#
# Revision-stage sensitivity analysis.
#
# The script:
#   1. reuses the frozen probe-choice tables from the submitted analyses;
#   2. reconstructs gene-wise z-scores separately for the main and
#      primary-only reference populations;
#   3. verifies reconstructed full-module scores and tests against the
#      submitted output tables;
#   4. exhaustively deletes each scored gene and each pair of scored genes;
#   5. recalculates bacterial-versus-viral module effects and Wilcoxon tests;
#   6. summarizes direction, significance-state and score-level robustness.
#
# No probe reselection, module redefinition, gene reweighting, label change
# or diagnostic-model fitting is performed.


# -------------------------------------------------------------------------
# R library paths
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


# -------------------------------------------------------------------------
# Required package
# -------------------------------------------------------------------------

if (!requireNamespace("data.table", quietly = TRUE)) {
  stop("The data.table package is required.")
}

suppressPackageStartupMessages({
  library(data.table)
})


# -------------------------------------------------------------------------
# Input files
# -------------------------------------------------------------------------

norm_expr_file <- paste0(
  "data/expression_raw/GSE73461/",
  "GSE73461_GEOupload_Discovery_Dataset_Normalised_Sept_15_n_459.txt.gz"
)

module_gene_file <- paste0(
  "results/module_scoring/GSE211567_projection_ready_inputs/",
  "GSE211567_projection_ready_module_gene_table.tsv"
)

main_probe_choice_file <- paste0(
  "results/module_projection/GSE73461_fixed_module_projection/",
  "GSE73461_gene_probe_choice_for_projection.tsv"
)

primary_probe_choice_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_gene_probe_choice_for_projection.tsv"
)

main_score_file <- paste0(
  "results/module_projection/GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_scores_long.tsv"
)

primary_score_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_scores_long.tsv"
)

main_test_file <- paste0(
  "results/module_projection/GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_primary_projection_tests.tsv"
)

primary_test_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_primary_projection_tests.tsv"
)


# -------------------------------------------------------------------------
# Output files
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_leave_one_two_gene_robustness"
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

baseline_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_full_module_baselines.tsv"
)

reconstruction_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_reconstruction_check.tsv"
)

module_manifest_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_module_manifest.tsv"
)

variant_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_variant_results.tsv"
)

summary_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_summary.tsv"
)

worst_case_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_worst_case_variants.tsv"
)

run_manifest_file <- file.path(
  out_dir,
  "GSE73461_leave_one_two_gene_run_manifest.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE73461_leave_one_two_gene_robustness_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE73461_leave_one_two_gene_robustness_sessionInfo.txt"
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

expected_available_counts <- data.table(
  final_module_id = expected_module_ids,
  expected_available_gene_count = c(
    24L,
    21L,
    128L,
    33L,
    105L
  )
)

expected_main_samples <- 201L
expected_primary_samples <- 146L
expected_bacterial_samples <- 52L
expected_viral_samples <- 94L
expected_control_samples <- 55L

expected_variants_per_population <- 14913L
expected_total_variant_rows <- 29826L

nominal_alpha <- 0.05
reconstruction_tolerance <- 1e-12

analysis_start <- proc.time()[["elapsed"]]


# -------------------------------------------------------------------------
# General helpers
# -------------------------------------------------------------------------

clean_text_lines <- function(lines) {
  sub(
    "[[:space:]]+$",
    "",
    as.character(lines)
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

expected_direction_match <- function(
  effect,
  direction
) {
  if (direction == "higher_in_bacterial") {
    return(effect > 0)
  }

  if (direction == "higher_in_viral") {
    return(effect < 0)
  }

  NA
}

same_effect_sign <- function(
  effect,
  reference_effect
) {
  if (reference_effect > 0) {
    return(effect > 0)
  }

  if (reference_effect < 0) {
    return(effect < 0)
  }

  effect == 0
}

safe_correlation <- function(
  x,
  y,
  method
) {
  value <- suppressWarnings(
    cor(
      x,
      y,
      method = method,
      use = "complete.obs"
    )
  )

  as.numeric(value)
}

evaluate_scores <- function(
  scores,
  projection_roles
) {
  bacterial <- scores[
    projection_roles == "primary_bacterial"
  ]

  viral <- scores[
    projection_roles == "primary_viral"
  ]

  if (
    length(bacterial) != expected_bacterial_samples ||
      length(viral) != expected_viral_samples
  ) {
    stop(
      "Unexpected bacterial or viral sample count during testing."
    )
  }

  if (
    any(!is.finite(bacterial)) ||
      any(!is.finite(viral))
  ) {
    stop(
      "Non-finite module scores encountered during testing."
    )
  }

  wilcox_result <- suppressWarnings(
    wilcox.test(
      bacterial,
      viral,
      alternative = "two.sided",
      paired = FALSE,
      exact = FALSE,
      correct = TRUE
    )
  )

  list(
    n_bacterial = length(bacterial),
    n_viral = length(viral),
    mean_bacterial = mean(bacterial),
    mean_viral = mean(viral),
    median_bacterial = median(bacterial),
    median_viral = median(viral),
    median_difference_bacterial_minus_viral =
      median(bacterial) -
        median(viral),
    wilcox_W = unname(
      wilcox_result$statistic
    ),
    wilcox_p = wilcox_result$p.value
  )
}


# -------------------------------------------------------------------------
# Validate input files
# -------------------------------------------------------------------------

required_input_files <- c(
  norm_expr_file,
  module_gene_file,
  main_probe_choice_file,
  primary_probe_choice_file,
  main_score_file,
  primary_score_file,
  main_test_file,
  primary_test_file
)

missing_input_files <- required_input_files[
  !file.exists(required_input_files)
]

if (length(missing_input_files) > 0L) {
  stop(
    paste(
      "Required input files are missing:",
      paste(
        missing_input_files,
        collapse = ", "
      )
    )
  )
}


# -------------------------------------------------------------------------
# Read and harmonize locked module definitions
# -------------------------------------------------------------------------

modules <- fread(
  module_gene_file
)

if (!"final_module_id" %in% names(modules)) {
  module_id_candidates <- names(modules)[
    grepl(
      "module.*id|^module_id$",
      names(modules),
      ignore.case = TRUE
    )
  ]

  if (length(module_id_candidates) == 0L) {
    stop(
      "No module ID column was detected in the locked module table."
    )
  }

  setnames(
    modules,
    module_id_candidates[1L],
    "final_module_id"
  )
}

if (!"final_module_label" %in% names(modules)) {
  label_candidates <- names(modules)[
    grepl(
      "module.*label|module.*name|^label$",
      names(modules),
      ignore.case = TRUE
    )
  ]

  if (length(label_candidates) > 0L) {
    setnames(
      modules,
      label_candidates[1L],
      "final_module_label"
    )
  } else {
    modules[
      ,
      final_module_label :=
        as.character(final_module_id)
    ]
  }
}

if (!"final_module_direction" %in% names(modules)) {
  direction_candidates <- names(modules)[
    grepl(
      "direction|orientation|module.*sign",
      names(modules),
      ignore.case = TRUE
    )
  ]

  if (length(direction_candidates) > 0L) {
    setnames(
      modules,
      direction_candidates[1L],
      "final_module_direction"
    )
  } else {
    modules[
      ,
      final_module_direction := fifelse(
        grepl(
          "^BACT",
          as.character(final_module_id)
        ),
        "higher_in_bacterial",
        fifelse(
          grepl(
            "^VIR",
            as.character(final_module_id)
          ),
          "higher_in_viral",
          "not_specified"
        )
      )
    ]
  }
}

if (!"SYMBOL" %in% names(modules)) {
  symbol_candidates <- names(modules)[
    grepl(
      "^symbol$|gene.*symbol|hgnc",
      names(modules),
      ignore.case = TRUE
    )
  ]

  if (length(symbol_candidates) == 0L) {
    stop(
      "No gene-symbol column was detected in the locked module table."
    )
  }

  setnames(
    modules,
    symbol_candidates[1L],
    "SYMBOL"
  )
}

require_columns(
  modules,
  c(
    "final_module_id",
    "final_module_label",
    "final_module_direction",
    "SYMBOL"
  ),
  module_gene_file
)

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
    as.character(final_module_direction)
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
    final_module_id %in% expected_module_ids &
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

module_metadata_check <- modules[
  ,
  .(
    label_count =
      uniqueN(final_module_label),
    direction_count =
      uniqueN(final_module_direction)
  ),
  by = final_module_id
]

if (
  nrow(module_metadata_check) != 5L ||
    any(
      module_metadata_check$label_count != 1L
    ) ||
    any(
      module_metadata_check$direction_count != 1L
    )
) {
  print(module_metadata_check)

  stop(
    "Module labels or biological directions are not unique within modules."
  )
}

module_metadata <- modules[
  ,
  .(
    final_module_label =
      final_module_label[1L],
    final_module_direction =
      final_module_direction[1L]
  ),
  by = final_module_id
]

invalid_directions <- module_metadata[
  !final_module_direction %in% c(
    "higher_in_bacterial",
    "higher_in_viral"
  )
]

if (nrow(invalid_directions) > 0L) {
  print(invalid_directions)

  stop(
    "One or more locked modules have an unresolved biological direction."
  )
}

module_locked_counts <- modules[
  ,
  .(
    locked_gene_count =
      uniqueN(SYMBOL_UPPER)
  ),
  by = final_module_id
]

module_locked_check <- merge(
  expected_locked_counts,
  module_locked_counts,
  by = "final_module_id",
  all = TRUE
)

module_locked_check[
  ,
  locked_count_match :=
    expected_locked_gene_count ==
      locked_gene_count
]

if (
  nrow(module_locked_check) != 5L ||
    any(!module_locked_check$locked_count_match)
) {
  print(module_locked_check)

  stop(
    "Locked module counts do not match the submitted contract."
  )
}

module_union_symbols <- unique(
  modules$SYMBOL_UPPER
)


# -------------------------------------------------------------------------
# Read submitted score and test tables
# -------------------------------------------------------------------------

read_reference_scores <- function(
  path,
  population_name
) {
  dt <- fread(path)

  require_columns(
    dt,
    c(
      "base_sample_id",
      "final_module_id",
      "final_module_label",
      "final_module_direction",
      "module_score",
      "sample_group",
      "projection_role"
    ),
    path
  )

  dt[
    ,
    base_sample_id :=
      as.character(base_sample_id)
  ]

  dt[
    ,
    final_module_id :=
      as.character(final_module_id)
  ]

  dt[
    ,
    module_score :=
      as.numeric(module_score)
  ]

  dt[
    ,
    scoring_population :=
      population_name
  ]

  if (
    any(!is.finite(dt$module_score)) ||
      anyDuplicated(
        dt[
          ,
          .(
            base_sample_id,
            final_module_id
          )
        ]
      )
  ) {
    stop(
      paste(
        "Reference score table failed uniqueness or finite-value checks:",
        path
      )
    )
  }

  dt
}

read_reference_tests <- function(
  path,
  population_name
) {
  dt <- fread(path)

  require_columns(
    dt,
    c(
      "final_module_id",
      "median_difference_bacterial_minus_viral",
      "wilcox_p",
      "expected_direction_match"
    ),
    path
  )

  dt[
    ,
    final_module_id :=
      as.character(final_module_id)
  ]

  dt[
    ,
    scoring_population :=
      population_name
  ]

  if (
    nrow(dt) != 5L ||
      anyDuplicated(dt$final_module_id)
  ) {
    stop(
      paste(
        "Reference test table does not contain five unique modules:",
        path
      )
    )
  }

  dt
}

main_reference_scores <- read_reference_scores(
  main_score_file,
  "main_all_projected_reference"
)

primary_reference_scores <- read_reference_scores(
  primary_score_file,
  "primary_only_reference"
)

main_reference_tests <- read_reference_tests(
  main_test_file,
  "main_all_projected_reference"
)

primary_reference_tests <- read_reference_tests(
  primary_test_file,
  "primary_only_reference"
)


# -------------------------------------------------------------------------
# Recover exact sample definitions from submitted score tables
# -------------------------------------------------------------------------

recover_samples <- function(
  reference_scores,
  population_name
) {
  samples <- unique(
    reference_scores[
      ,
      .(
        base_sample_id,
        sample_group,
        projection_role
      )
    ]
  )

  role_counts <- samples[
    ,
    .N,
    by = projection_role
  ]

  bacterial_n <- role_counts[
    projection_role == "primary_bacterial",
    N
  ]

  viral_n <- role_counts[
    projection_role == "primary_viral",
    N
  ]

  control_n <- role_counts[
    projection_role == "secondary_control_context",
    N
  ]

  if (
    length(bacterial_n) != 1L ||
      bacterial_n != expected_bacterial_samples ||
      length(viral_n) != 1L ||
      viral_n != expected_viral_samples
  ) {
    print(role_counts)

    stop(
      paste(
        "Primary sample counts are incorrect for",
        population_name
      )
    )
  }

  if (population_name == "main_all_projected_reference") {
    if (
      nrow(samples) != expected_main_samples ||
        length(control_n) != 1L ||
        control_n != expected_control_samples
    ) {
      print(role_counts)

      stop(
        "Main reference population does not contain the expected 201 samples."
      )
    }
  }

  if (population_name == "primary_only_reference") {
    if (
      nrow(samples) != expected_primary_samples ||
        length(control_n) != 0L
    ) {
      print(role_counts)

      stop(
        "Primary-only reference population does not contain the expected 146 samples."
      )
    }
  }

  samples
}

main_samples <- recover_samples(
  main_reference_scores,
  "main_all_projected_reference"
)

primary_samples <- recover_samples(
  primary_reference_scores,
  "primary_only_reference"
)


# -------------------------------------------------------------------------
# Read frozen probe choices
# -------------------------------------------------------------------------

read_probe_choices <- function(
  path,
  population_name
) {
  dt <- fread(path)

  require_columns(
    dt,
    c(
      "SYMBOL_UPPER",
      "ARRAY_ID"
    ),
    path
  )

  dt[
    ,
    SYMBOL_UPPER :=
      toupper(
        trimws(
          as.character(SYMBOL_UPPER)
        )
      )
  ]

  dt[
    ,
    ARRAY_ID :=
      as.character(ARRAY_ID)
  ]

  dt <- dt[
    SYMBOL_UPPER %in% module_union_symbols
  ]

  duplicate_symbols <- dt[
    ,
    .N,
    by = SYMBOL_UPPER
  ][
    N != 1L
  ]

  if (nrow(duplicate_symbols) > 0L) {
    print(duplicate_symbols)

    stop(
      paste(
        "Frozen probe-choice table has duplicate selected symbols for",
        population_name
      )
    )
  }

  if (
    anyNA(dt$ARRAY_ID) ||
      any(!nzchar(dt$ARRAY_ID))
  ) {
    stop(
      paste(
        "Frozen probe-choice table has missing ARRAY_ID values for",
        population_name
      )
    )
  }

  dt[
    ,
    .(
      SYMBOL_UPPER,
      ARRAY_ID
    )
  ]
}

main_probe_choices <- read_probe_choices(
  main_probe_choice_file,
  "main_all_projected_reference"
)

primary_probe_choices <- read_probe_choices(
  primary_probe_choice_file,
  "primary_only_reference"
)


# -------------------------------------------------------------------------
# Read normalized expression values once
# -------------------------------------------------------------------------

expression_header <- names(
  fread(
    norm_expr_file,
    nrows = 0L,
    showProgress = FALSE
  )
)

expression_id_column <- expression_header[1L]

missing_main_columns <- setdiff(
  main_samples$base_sample_id,
  expression_header
)

if (length(missing_main_columns) > 0L) {
  stop(
    paste(
      "Main-reference samples are missing from the expression file:",
      paste(
        missing_main_columns,
        collapse = ", "
      )
    )
  )
}

message(
  "Reading normalized expression values for ",
  nrow(main_samples),
  " submitted projection samples..."
)

expression_dt <- fread(
  norm_expr_file,
  select = c(
    expression_id_column,
    main_samples$base_sample_id
  ),
  showProgress = TRUE
)

setnames(
  expression_dt,
  expression_id_column,
  "ARRAY_ID"
)

expression_dt[
  ,
  ARRAY_ID :=
    as.character(ARRAY_ID)
]

if (anyDuplicated(expression_dt$ARRAY_ID)) {
  stop(
    "Normalized expression file contains duplicated ARRAY_ID values."
  )
}


# -------------------------------------------------------------------------
# Build a frozen-probe gene-wise z-score matrix
# -------------------------------------------------------------------------

build_gene_z_matrix <- function(
  probe_choices,
  samples,
  population_name
) {
  row_index <- match(
    probe_choices$ARRAY_ID,
    expression_dt$ARRAY_ID
  )

  if (anyNA(row_index)) {
    missing_ids <- probe_choices[
      is.na(row_index),
      ARRAY_ID
    ]

    stop(
      paste(
        "Frozen probe ARRAY_ID values are absent for",
        population_name,
        ":",
        paste(
          missing_ids,
          collapse = ", "
        )
      )
    )
  }

  gene_expression <- as.matrix(
    expression_dt[
      row_index,
      samples$base_sample_id,
      with = FALSE
    ]
  )

  mode(gene_expression) <- "numeric"

  rownames(gene_expression) <-
    probe_choices$SYMBOL_UPPER

  colnames(gene_expression) <-
    samples$base_sample_id

  if (anyDuplicated(rownames(gene_expression))) {
    stop(
      paste(
        "Gene-expression matrix has duplicated symbols for",
        population_name
      )
    )
  }

  gene_means <- rowMeans(
    gene_expression,
    na.rm = TRUE
  )

  gene_sds <- apply(
    gene_expression,
    1L,
    sd,
    na.rm = TRUE
  )

  gene_sds[
    is.na(gene_sds) |
      gene_sds == 0
  ] <- NA_real_

  gene_z <- sweep(
    gene_expression,
    1L,
    gene_means,
    "-"
  )

  gene_z <- sweep(
    gene_z,
    1L,
    gene_sds,
    "/"
  )

  gene_z
}

main_gene_z <- build_gene_z_matrix(
  main_probe_choices,
  main_samples,
  "main_all_projected_reference"
)

primary_gene_z <- build_gene_z_matrix(
  primary_probe_choices,
  primary_samples,
  "primary_only_reference"
)


# -------------------------------------------------------------------------
# Analyse one reference population
# -------------------------------------------------------------------------

analyse_population <- function(
  population_name,
  samples,
  gene_z,
  reference_scores,
  reference_tests
) {
  population_baselines <- list()
  population_reconstruction <- list()
  population_manifest <- list()
  population_variants <- list()

  chunk_index <- 0L

  for (module_id in expected_module_ids) {
    message(
      "Analysing ",
      population_name,
      " / ",
      module_id,
      "..."
    )

    module_rows <- modules[
      final_module_id == module_id
    ]

    module_label <-
      module_rows$final_module_label[1L]

    module_direction <-
      module_rows$final_module_direction[1L]

    locked_symbols <- sort(
      unique(
        module_rows$SYMBOL_UPPER
      )
    )

    available_symbols <- sort(
      intersect(
        locked_symbols,
        rownames(gene_z)
      )
    )

    missing_symbols <- sort(
      setdiff(
        locked_symbols,
        available_symbols
      )
    )

    available_gene_count <-
      length(available_symbols)

    leave_one_count <-
      available_gene_count

    leave_two_count <-
      choose(
        available_gene_count,
        2L
      )

    expected_variant_count <-
      leave_one_count +
        leave_two_count

    if (available_gene_count < 3L) {
      stop(
        paste(
          "Module has fewer than three scored genes:",
          module_id,
          population_name
        )
      )
    }

    module_z <- gene_z[
      available_symbols,
      ,
      drop = FALSE
    ]

    full_scores <- colMeans(
      module_z,
      na.rm = TRUE
    )

    if (any(!is.finite(full_scores))) {
      stop(
        paste(
          "Full-module reconstruction produced non-finite scores:",
          module_id,
          population_name
        )
      )
    }

    full_evaluation <- evaluate_scores(
      full_scores,
      samples$projection_role
    )

    full_direction_match <-
      expected_direction_match(
        full_evaluation$
          median_difference_bacterial_minus_viral,
        module_direction
      )

    submitted_module_scores <- reference_scores[
      final_module_id == module_id,
      .(
        base_sample_id,
        submitted_module_score =
          module_score
      )
    ]

    reconstructed_scores <- data.table(
      base_sample_id =
        names(full_scores),
      reconstructed_module_score =
        as.numeric(full_scores)
    )

    score_check <- merge(
      submitted_module_scores,
      reconstructed_scores,
      by = "base_sample_id",
      all = TRUE
    )

    if (
      nrow(score_check) != nrow(samples) ||
        anyNA(score_check$submitted_module_score) ||
        anyNA(score_check$reconstructed_module_score)
    ) {
      stop(
        paste(
          "Full-module score reconstruction did not merge completely:",
          module_id,
          population_name
        )
      )
    }

    max_abs_score_difference <- max(
      abs(
        score_check$submitted_module_score -
          score_check$reconstructed_module_score
      )
    )

    submitted_test <- reference_tests[
      final_module_id == module_id
    ]

    if (nrow(submitted_test) != 1L) {
      stop(
        paste(
          "Submitted test result is not unique:",
          module_id,
          population_name
        )
      )
    }

    median_difference_difference <- abs(
      full_evaluation$
        median_difference_bacterial_minus_viral -
        submitted_test$
          median_difference_bacterial_minus_viral
    )

    p_value_difference <- abs(
      full_evaluation$wilcox_p -
        submitted_test$wilcox_p
    )

    reconstruction_pass <- (
      max_abs_score_difference <=
        reconstruction_tolerance &&
        median_difference_difference <=
          reconstruction_tolerance &&
        p_value_difference <=
          reconstruction_tolerance &&
        identical(
          as.logical(full_direction_match),
          as.logical(
            submitted_test$
              expected_direction_match
          )
        )
    )

    population_baselines[[
      module_id
    ]] <- data.table(
      scoring_population =
        population_name,
      final_module_id =
        module_id,
      final_module_label =
        module_label,
      final_module_direction =
        module_direction,
      locked_gene_count =
        length(locked_symbols),
      available_gene_count =
        available_gene_count,
      missing_gene_count =
        length(missing_symbols),
      missing_symbols = if (
        length(missing_symbols) == 0L
      ) {
        "none"
      } else {
        paste(
          missing_symbols,
          collapse = ";"
        )
      },
      n_bacterial =
        full_evaluation$n_bacterial,
      n_viral =
        full_evaluation$n_viral,
      mean_bacterial =
        full_evaluation$mean_bacterial,
      mean_viral =
        full_evaluation$mean_viral,
      median_bacterial =
        full_evaluation$median_bacterial,
      median_viral =
        full_evaluation$median_viral,
      median_difference_bacterial_minus_viral =
        full_evaluation$
          median_difference_bacterial_minus_viral,
      wilcox_W =
        full_evaluation$wilcox_W,
      wilcox_p =
        full_evaluation$wilcox_p,
      nominal_p_lt_0_05 =
        full_evaluation$wilcox_p <
          nominal_alpha,
      expected_direction_match =
        full_direction_match
    )

    population_reconstruction[[
      module_id
    ]] <- data.table(
      scoring_population =
        population_name,
      final_module_id =
        module_id,
      sample_count =
        nrow(samples),
      max_abs_score_difference =
        max_abs_score_difference,
      submitted_median_difference =
        submitted_test$
          median_difference_bacterial_minus_viral,
      reconstructed_median_difference =
        full_evaluation$
          median_difference_bacterial_minus_viral,
      abs_median_difference_difference =
        median_difference_difference,
      submitted_wilcox_p =
        submitted_test$wilcox_p,
      reconstructed_wilcox_p =
        full_evaluation$wilcox_p,
      abs_wilcox_p_difference =
        p_value_difference,
      submitted_expected_direction_match =
        submitted_test$
          expected_direction_match,
      reconstructed_expected_direction_match =
        full_direction_match,
      reconstruction_pass =
        reconstruction_pass
    )

    population_manifest[[
      module_id
    ]] <- data.table(
      scoring_population =
        population_name,
      final_module_id =
        module_id,
      locked_gene_count =
        length(locked_symbols),
      available_gene_count =
        available_gene_count,
      missing_gene_count =
        length(missing_symbols),
      leave_one_variant_count =
        leave_one_count,
      leave_two_variant_count =
        leave_two_count,
      total_variant_count =
        expected_variant_count
    )

    module_values <- module_z
    module_zero <- module_values

    module_zero[
      is.na(module_zero)
    ] <- 0

    module_valid <- !is.na(
      module_values
    )

    total_sum <- colSums(
      module_zero
    )

    total_count <- colSums(
      module_valid
    )

    variant_rows <- vector(
      "list",
      expected_variant_count
    )

    variant_index <- 0L

    make_variant_row <- function(
      variant_scores,
      deletion_order,
      deleted_gene_1,
      deleted_gene_2,
      retained_gene_count
    ) {
      if (any(!is.finite(variant_scores))) {
        stop(
          paste(
            "Deletion variant produced non-finite scores:",
            population_name,
            module_id,
            deleted_gene_1,
            deleted_gene_2
          )
        )
      }

      variant_evaluation <- evaluate_scores(
        variant_scores,
        samples$projection_role
      )

      variant_effect <-
        variant_evaluation$
          median_difference_bacterial_minus_viral

      full_effect <-
        full_evaluation$
          median_difference_bacterial_minus_viral

      pearson_correlation <- safe_correlation(
        variant_scores,
        full_scores,
        "pearson"
      )

      spearman_correlation <- safe_correlation(
        variant_scores,
        full_scores,
        "spearman"
      )

      if (
        !is.finite(pearson_correlation) ||
          !is.finite(spearman_correlation)
      ) {
        stop(
          paste(
            "Deletion variant produced a non-finite score correlation:",
            population_name,
            module_id,
            deleted_gene_1,
            deleted_gene_2
          )
        )
      }

      data.table(
        scoring_population =
          population_name,
        final_module_id =
          module_id,
        final_module_label =
          module_label,
        final_module_direction =
          module_direction,
        deletion_order =
          deletion_order,
        deleted_gene_1 =
          deleted_gene_1,
        deleted_gene_2 =
          deleted_gene_2,
        available_gene_count =
          available_gene_count,
        retained_gene_count =
          retained_gene_count,
        n_bacterial =
          variant_evaluation$n_bacterial,
        n_viral =
          variant_evaluation$n_viral,
        mean_bacterial =
          variant_evaluation$mean_bacterial,
        mean_viral =
          variant_evaluation$mean_viral,
        median_bacterial =
          variant_evaluation$median_bacterial,
        median_viral =
          variant_evaluation$median_viral,
        median_difference_bacterial_minus_viral =
          variant_effect,
        full_module_median_difference =
          full_effect,
        effect_change_from_full =
          variant_effect -
            full_effect,
        abs_effect_change_from_full =
          abs(
            variant_effect -
              full_effect
          ),
        wilcox_W =
          variant_evaluation$wilcox_W,
        wilcox_p =
          variant_evaluation$wilcox_p,
        nominal_p_lt_0_05 =
          variant_evaluation$wilcox_p <
            nominal_alpha,
        full_module_wilcox_p =
          full_evaluation$wilcox_p,
        full_module_nominal_p_lt_0_05 =
          full_evaluation$wilcox_p <
            nominal_alpha,
        same_nominal_significance_state_as_full =
          (
            variant_evaluation$wilcox_p <
              nominal_alpha
          ) ==
            (
              full_evaluation$wilcox_p <
                nominal_alpha
            ),
        expected_direction_match =
          expected_direction_match(
            variant_effect,
            module_direction
          ),
        effect_sign_preserved_vs_full =
          same_effect_sign(
            variant_effect,
            full_effect
          ),
        pearson_correlation_with_full_scores =
          pearson_correlation,
        spearman_correlation_with_full_scores =
          spearman_correlation,
        mean_abs_score_deviation =
          mean(
            abs(
              variant_scores -
                full_scores
            )
          ),
        max_abs_score_deviation =
          max(
            abs(
              variant_scores -
                full_scores
            )
          )
      )
    }

    for (
      first_index in seq_len(
        available_gene_count
      )
    ) {
      variant_index <- variant_index + 1L

      denominator <- total_count -
        module_valid[
          first_index,
        ]

      numerator <- total_sum -
        module_zero[
          first_index,
        ]

      if (any(denominator <= 0L)) {
        stop(
          paste(
            "Leave-one denominator is non-positive:",
            population_name,
            module_id,
            available_symbols[first_index]
          )
        )
      }

      variant_scores <- numerator /
        denominator

      variant_rows[[
        variant_index
      ]] <- make_variant_row(
        variant_scores =
          variant_scores,
        deletion_order =
          "leave_one",
        deleted_gene_1 =
          available_symbols[first_index],
        deleted_gene_2 =
          "none",
        retained_gene_count =
          available_gene_count - 1L
      )
    }

    deletion_pairs <- combn(
      seq_len(
        available_gene_count
      ),
      2L
    )

    for (
      pair_index in seq_len(
        ncol(deletion_pairs)
      )
    ) {
      first_index <-
        deletion_pairs[
          1L,
          pair_index
        ]

      second_index <-
        deletion_pairs[
          2L,
          pair_index
        ]

      variant_index <- variant_index + 1L

      denominator <- total_count -
        module_valid[
          first_index,
        ] -
        module_valid[
          second_index,
        ]

      numerator <- total_sum -
        module_zero[
          first_index,
        ] -
        module_zero[
          second_index,
        ]

      if (any(denominator <= 0L)) {
        stop(
          paste(
            "Leave-two denominator is non-positive:",
            population_name,
            module_id,
            available_symbols[first_index],
            available_symbols[second_index]
          )
        )
      }

      variant_scores <- numerator /
        denominator

      variant_rows[[
        variant_index
      ]] <- make_variant_row(
        variant_scores =
          variant_scores,
        deletion_order =
          "leave_two",
        deleted_gene_1 =
          available_symbols[first_index],
        deleted_gene_2 =
          available_symbols[second_index],
        retained_gene_count =
          available_gene_count - 2L
      )
    }

    if (variant_index != expected_variant_count) {
      stop(
        paste(
          "Variant count mismatch:",
          population_name,
          module_id,
          variant_index,
          expected_variant_count
        )
      )
    }

    chunk_index <- chunk_index + 1L

    population_variants[[
      chunk_index
    ]] <- rbindlist(
      variant_rows,
      use.names = TRUE,
      fill = TRUE
    )
  }

  list(
    baselines = rbindlist(
      population_baselines,
      use.names = TRUE,
      fill = TRUE
    ),
    reconstruction = rbindlist(
      population_reconstruction,
      use.names = TRUE,
      fill = TRUE
    ),
    module_manifest = rbindlist(
      population_manifest,
      use.names = TRUE,
      fill = TRUE
    ),
    variants = rbindlist(
      population_variants,
      use.names = TRUE,
      fill = TRUE
    )
  )
}


# -------------------------------------------------------------------------
# Run both reference populations
# -------------------------------------------------------------------------

main_result <- analyse_population(
  population_name =
    "main_all_projected_reference",
  samples =
    main_samples,
  gene_z =
    main_gene_z,
  reference_scores =
    main_reference_scores,
  reference_tests =
    main_reference_tests
)

primary_result <- analyse_population(
  population_name =
    "primary_only_reference",
  samples =
    primary_samples,
  gene_z =
    primary_gene_z,
  reference_scores =
    primary_reference_scores,
  reference_tests =
    primary_reference_tests
)

baselines <- rbindlist(
  list(
    main_result$baselines,
    primary_result$baselines
  ),
  use.names = TRUE,
  fill = TRUE
)

reconstruction <- rbindlist(
  list(
    main_result$reconstruction,
    primary_result$reconstruction
  ),
  use.names = TRUE,
  fill = TRUE
)

module_manifest <- rbindlist(
  list(
    main_result$module_manifest,
    primary_result$module_manifest
  ),
  use.names = TRUE,
  fill = TRUE
)

variant_results <- rbindlist(
  list(
    main_result$variants,
    primary_result$variants
  ),
  use.names = TRUE,
  fill = TRUE
)

setorder(
  baselines,
  scoring_population,
  final_module_id
)

setorder(
  reconstruction,
  scoring_population,
  final_module_id
)

setorder(
  module_manifest,
  scoring_population,
  final_module_id
)

setorder(
  variant_results,
  scoring_population,
  final_module_id,
  deletion_order,
  deleted_gene_1,
  deleted_gene_2
)


# -------------------------------------------------------------------------
# Confirm module-level available counts and theoretical totals
# -------------------------------------------------------------------------

available_count_check <- merge(
  unique(
    module_manifest[
      ,
      .(
        final_module_id,
        available_gene_count
      )
    ]
  ),
  expected_available_counts,
  by = "final_module_id",
  all = TRUE
)

available_count_check[
  ,
  available_count_match :=
    available_gene_count ==
      expected_available_gene_count
]

if (
  nrow(available_count_check) != 5L ||
    any(!available_count_check$
          available_count_match)
) {
  print(available_count_check)

  stop(
    "Available module-gene counts do not match the Phase R1C1 design lock."
  )
}


# -------------------------------------------------------------------------
# Summarize deletion robustness
# -------------------------------------------------------------------------

variant_summary <- variant_results[
  ,
  .(
    observed_variant_count =
      .N,
    expected_direction_preserved_n =
      sum(
        expected_direction_match,
        na.rm = TRUE
      ),
    expected_direction_preserved_fraction =
      mean(
        expected_direction_match,
        na.rm = TRUE
      ),
    full_effect_sign_preserved_n =
      sum(
        effect_sign_preserved_vs_full,
        na.rm = TRUE
      ),
    full_effect_sign_preserved_fraction =
      mean(
        effect_sign_preserved_vs_full,
        na.rm = TRUE
      ),
    nominal_p_lt_0_05_n =
      sum(
        nominal_p_lt_0_05,
        na.rm = TRUE
      ),
    nominal_p_lt_0_05_fraction =
      mean(
        nominal_p_lt_0_05,
        na.rm = TRUE
      ),
    same_nominal_state_as_full_n =
      sum(
        same_nominal_significance_state_as_full,
        na.rm = TRUE
      ),
    same_nominal_state_as_full_fraction =
      mean(
        same_nominal_significance_state_as_full,
        na.rm = TRUE
      ),
    minimum_median_difference =
      min(
        median_difference_bacterial_minus_viral
      ),
    maximum_median_difference =
      max(
        median_difference_bacterial_minus_viral
      ),
    minimum_abs_median_difference =
      min(
        abs(
          median_difference_bacterial_minus_viral
        )
      ),
    minimum_wilcox_p =
      min(wilcox_p),
    maximum_wilcox_p =
      max(wilcox_p),
    minimum_pearson_correlation_with_full =
      min(
        pearson_correlation_with_full_scores
      ),
    minimum_spearman_correlation_with_full =
      min(
        spearman_correlation_with_full_scores
      ),
    maximum_abs_effect_change_from_full =
      max(
        abs_effect_change_from_full
      ),
    maximum_mean_abs_score_deviation =
      max(
        mean_abs_score_deviation
      ),
    maximum_absolute_score_deviation =
      max(
        max_abs_score_deviation
      )
  ),
  by = .(
    scoring_population,
    final_module_id,
    final_module_label,
    final_module_direction,
    deletion_order
  )
]

expected_summary_counts <- module_manifest[
  ,
  .(
    scoring_population,
    final_module_id,
    deletion_order = "leave_one",
    expected_variant_count =
      leave_one_variant_count
  )
]

expected_summary_counts <- rbind(
  expected_summary_counts,
  module_manifest[
    ,
    .(
      scoring_population,
      final_module_id,
      deletion_order = "leave_two",
      expected_variant_count =
        leave_two_variant_count
    )
  ],
  use.names = TRUE
)

variant_summary <- merge(
  variant_summary,
  expected_summary_counts,
  by = c(
    "scoring_population",
    "final_module_id",
    "deletion_order"
  ),
  all.x = TRUE
)

variant_summary[
  ,
  variant_count_match :=
    observed_variant_count ==
      expected_variant_count
]

setorder(
  variant_summary,
  scoring_population,
  final_module_id,
  deletion_order
)


# -------------------------------------------------------------------------
# Select deterministic worst-case variants
# -------------------------------------------------------------------------

worst_source <- copy(
  variant_results
)

worst_source[
  ,
  absolute_median_difference :=
    abs(
      median_difference_bacterial_minus_viral
    )
]

worst_group_columns <- c(
  "scoring_population",
  "final_module_id",
  "deletion_order"
)

largest_p <- worst_source[
  order(
    -wilcox_p,
    deleted_gene_1,
    deleted_gene_2
  ),
  .SD[1L],
  by = worst_group_columns
]

largest_p[
  ,
  worst_case_criterion :=
    "largest_wilcox_p"
]

smallest_effect <- worst_source[
  order(
    absolute_median_difference,
    deleted_gene_1,
    deleted_gene_2
  ),
  .SD[1L],
  by = worst_group_columns
]

smallest_effect[
  ,
  worst_case_criterion :=
    "smallest_absolute_median_difference"
]

lowest_pearson <- worst_source[
  order(
    pearson_correlation_with_full_scores,
    deleted_gene_1,
    deleted_gene_2
  ),
  .SD[1L],
  by = worst_group_columns
]

lowest_pearson[
  ,
  worst_case_criterion :=
    "lowest_pearson_correlation"
]

largest_effect_change <- worst_source[
  order(
    -abs_effect_change_from_full,
    deleted_gene_1,
    deleted_gene_2
  ),
  .SD[1L],
  by = worst_group_columns
]

largest_effect_change[
  ,
  worst_case_criterion :=
    "largest_absolute_effect_change"
]

largest_score_deviation <- worst_source[
  order(
    -max_abs_score_deviation,
    deleted_gene_1,
    deleted_gene_2
  ),
  .SD[1L],
  by = worst_group_columns
]

largest_score_deviation[
  ,
  worst_case_criterion :=
    "largest_sample_score_deviation"
]

worst_case_variants <- rbindlist(
  list(
    largest_p,
    smallest_effect,
    lowest_pearson,
    largest_effect_change,
    largest_score_deviation
  ),
  use.names = TRUE,
  fill = TRUE
)

setorder(
  worst_case_variants,
  scoring_population,
  final_module_id,
  deletion_order,
  worst_case_criterion
)


# -------------------------------------------------------------------------
# Quality gates
# -------------------------------------------------------------------------

duplicate_variants <- variant_results[
  ,
  .N,
  by = .(
    scoring_population,
    final_module_id,
    deletion_order,
    deleted_gene_1,
    deleted_gene_2
  )
][
  N != 1L
]

variant_rows_by_population <- variant_results[
  ,
  .N,
  by = scoring_population
]

population_variant_count_pass <- (
  nrow(variant_rows_by_population) == 2L &&
    all(
      variant_rows_by_population$N ==
        expected_variants_per_population
    )
)

reconstruction_pass <- (
  nrow(reconstruction) == 10L &&
    all(
      reconstruction$
        reconstruction_pass
    )
)

module_manifest_pass <- (
  nrow(module_manifest) == 10L &&
    all(
      module_manifest$
        total_variant_count ==
        (
          module_manifest$
            leave_one_variant_count +
            module_manifest$
              leave_two_variant_count
        )
    ) &&
    all(
      module_manifest$
        available_gene_count %in%
        expected_available_counts$
          expected_available_gene_count
    )
)

variant_metric_pass <- (
  all(
    is.finite(
      variant_results$
        median_difference_bacterial_minus_viral
    )
  ) &&
    all(
      is.finite(
        variant_results$wilcox_p
      )
    ) &&
    all(
      is.finite(
        variant_results$
          pearson_correlation_with_full_scores
      )
    ) &&
    all(
      is.finite(
        variant_results$
          spearman_correlation_with_full_scores
      )
    ) &&
    all(
      variant_results$wilcox_p >= 0 &
        variant_results$wilcox_p <= 1
    ) &&
    all(
      nzchar(
        variant_results$deleted_gene_1
      )
    ) &&
    all(
      nzchar(
        variant_results$deleted_gene_2
      )
    )
)

quality_gate_pass <- (
  reconstruction_pass &&
    module_manifest_pass &&
    nrow(variant_results) ==
      expected_total_variant_rows &&
    population_variant_count_pass &&
    nrow(duplicate_variants) == 0L &&
    variant_metric_pass &&
    nrow(variant_summary) == 20L &&
    all(
      variant_summary$
        variant_count_match
    )
)


# -------------------------------------------------------------------------
# Run manifest
# -------------------------------------------------------------------------

analysis_elapsed_seconds <- (
  proc.time()[["elapsed"]] -
    analysis_start
)

run_manifest <- data.table(
  metric = c(
    "reference_populations",
    "locked_module_count",
    "main_reference_sample_count",
    "primary_only_reference_sample_count",
    "bacterial_sample_count",
    "viral_sample_count",
    "control_sample_count_main_only",
    "reconstruction_rows",
    "reconstruction_checks_passed",
    "module_manifest_rows",
    "leave_one_rows",
    "leave_two_rows",
    "variant_rows_main",
    "variant_rows_primary_only",
    "total_variant_rows",
    "expected_total_variant_rows",
    "summary_rows",
    "worst_case_rows",
    "duplicate_variant_keys",
    "nominal_alpha",
    "reconstruction_tolerance",
    "analysis_elapsed_seconds",
    "quality_gate"
  ),
  value = c(
    "2",
    as.character(
      length(expected_module_ids)
    ),
    as.character(
      nrow(main_samples)
    ),
    as.character(
      nrow(primary_samples)
    ),
    as.character(
      expected_bacterial_samples
    ),
    as.character(
      expected_viral_samples
    ),
    as.character(
      expected_control_samples
    ),
    as.character(
      nrow(reconstruction)
    ),
    paste0(
      sum(
        reconstruction$
          reconstruction_pass
      ),
      "/",
      nrow(reconstruction)
    ),
    as.character(
      nrow(module_manifest)
    ),
    as.character(
      variant_results[
        deletion_order == "leave_one",
        .N
      ]
    ),
    as.character(
      variant_results[
        deletion_order == "leave_two",
        .N
      ]
    ),
    as.character(
      variant_results[
        scoring_population ==
          "main_all_projected_reference",
        .N
      ]
    ),
    as.character(
      variant_results[
        scoring_population ==
          "primary_only_reference",
        .N
      ]
    ),
    as.character(
      nrow(variant_results)
    ),
    as.character(
      expected_total_variant_rows
    ),
    as.character(
      nrow(variant_summary)
    ),
    as.character(
      nrow(worst_case_variants)
    ),
    as.character(
      nrow(duplicate_variants)
    ),
    as.character(
      nominal_alpha
    ),
    format(
      reconstruction_tolerance,
      scientific = TRUE
    ),
    format(
      analysis_elapsed_seconds,
      digits = 8
    ),
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    )
  )
)


# -------------------------------------------------------------------------
# Write tabular outputs
# -------------------------------------------------------------------------

fwrite(
  baselines,
  baseline_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  reconstruction,
  reconstruction_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  module_manifest,
  module_manifest_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  variant_results,
  variant_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  variant_summary,
  summary_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  worst_case_variants,
  worst_case_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  run_manifest,
  run_manifest_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Markdown report
# -------------------------------------------------------------------------

baseline_preview <- clean_text_lines(
  capture.output(
    print(
      baselines[
        ,
        .(
          scoring_population,
          final_module_id,
          available_gene_count,
          median_difference_bacterial_minus_viral,
          wilcox_p,
          nominal_p_lt_0_05,
          expected_direction_match
        )
      ]
    )
  )
)

summary_preview <- clean_text_lines(
  capture.output(
    print(
      variant_summary[
        ,
        .(
          scoring_population,
          final_module_id,
          deletion_order,
          observed_variant_count,
          expected_direction_preserved_fraction,
          full_effect_sign_preserved_fraction,
          nominal_p_lt_0_05_fraction,
          same_nominal_state_as_full_fraction,
          minimum_pearson_correlation_with_full,
          maximum_wilcox_p,
          variant_count_match
        )
      ]
    )
  )
)

report_lines <- c(
  "# GSE73461 leave-one- and leave-two-gene robustness analysis",
  "",
  "## Purpose",
  "",
  paste(
    "This revision-stage analysis tested whether the",
    "GSE73461 fixed-module conclusions depended strongly on",
    "individual scored genes or pairs of scored genes."
  ),
  "",
  paste(
    "The submitted probe choices, sample definitions,",
    "gene-wise z-standardization rule and unweighted mean",
    "module score were retained."
  ),
  "",
  "## Method",
  "",
  paste(
    "The main analysis reconstructed gene-wise z-scores using",
    "the 201 bacterial, viral and contextual-control samples."
  ),
  "",
  paste(
    "The primary-only sensitivity reconstructed gene-wise",
    "z-scores using the 146 bacterial and viral samples."
  ),
  "",
  paste(
    "For each module and reference population, every scored",
    "gene and every pair of scored genes was deleted.",
    "Variant scores were calculated from the remaining",
    "gene-wise z-scores."
  ),
  "",
  paste(
    "Bacterial-versus-viral comparisons used two-sided",
    "Wilcoxon rank-sum tests with exact calculation disabled",
    "and continuity correction retained."
  ),
  "",
  "## Reconstruction gate",
  "",
  paste0(
    "- Reconstruction rows: ",
    nrow(reconstruction)
  ),
  paste0(
    "- Reconstruction checks passed: ",
    sum(
      reconstruction$
        reconstruction_pass
    ),
    "/",
    nrow(reconstruction)
  ),
  paste0(
    "- Maximum full-score reconstruction difference: ",
    format(
      max(
        reconstruction$
          max_abs_score_difference
      ),
      digits = 16
    )
  ),
  "",
  "## Variant inventory",
  "",
  paste0(
    "- Leave-one rows: ",
    variant_results[
      deletion_order == "leave_one",
      .N
    ]
  ),
  paste0(
    "- Leave-two rows: ",
    variant_results[
      deletion_order == "leave_two",
      .N
    ]
  ),
  paste0(
    "- Total population-specific variant rows: ",
    nrow(variant_results)
  ),
  paste0(
    "- Final quality gate: `",
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
    "`."
  ),
  "",
  "## Full-module baselines",
  "",
  "```text",
  baseline_preview,
  "```",
  "",
  "## Robustness summary",
  "",
  "```text",
  summary_preview,
  "```",
  "",
  "## Interpretation boundary",
  "",
  paste(
    "These deletion analyses assess internal score robustness",
    "within GSE73461. They do not redefine the locked modules",
    "and do not constitute independent-cohort replication."
  ),
  "",
  paste(
    "Fractions retaining nominal significance are descriptive",
    "sensitivity summaries. Deletion variants were not treated",
    "as separately optimized or independently selected models."
  ),
  "",
  "## Output files",
  "",
  paste0(
    "- `",
    baseline_file,
    "`"
  ),
  paste0(
    "- `",
    reconstruction_file,
    "`"
  ),
  paste0(
    "- `",
    module_manifest_file,
    "`"
  ),
  paste0(
    "- `",
    variant_file,
    "`"
  ),
  paste0(
    "- `",
    summary_file,
    "`"
  ),
  paste0(
    "- `",
    worst_case_file,
    "`"
  ),
  paste0(
    "- `",
    run_manifest_file,
    "`"
  )
)

report_lines <- clean_text_lines(
  report_lines
)

writeLines(
  report_lines,
  report_file
)


# -------------------------------------------------------------------------
# Session information
# -------------------------------------------------------------------------

session_lines <- clean_text_lines(
  capture.output(
    sessionInfo()
  )
)

writeLines(
  session_lines,
  session_file
)


# -------------------------------------------------------------------------
# Console summary
# -------------------------------------------------------------------------

cat(
  "===== GSE73461 LEAVE-ONE/TWO-GENE ROBUSTNESS =====\n"
)

cat(
  "reference_populations\t2\n"
)

cat(
  "reconstruction_checks_passed\t",
  sum(
    reconstruction$
      reconstruction_pass
  ),
  "/",
  nrow(reconstruction),
  "\n",
  sep = ""
)

cat(
  "leave_one_rows\t",
  variant_results[
    deletion_order == "leave_one",
    .N
  ],
  "\n",
  sep = ""
)

cat(
  "leave_two_rows\t",
  variant_results[
    deletion_order == "leave_two",
    .N
  ],
  "\n",
  sep = ""
)

cat(
  "total_variant_rows\t",
  nrow(variant_results),
  "\n",
  sep = ""
)

cat(
  "summary_rows\t",
  nrow(variant_summary),
  "\n",
  sep = ""
)

cat(
  "worst_case_rows\t",
  nrow(worst_case_variants),
  "\n",
  sep = ""
)

cat(
  "expected_direction_matches\t",
  sum(
    variant_results$
      expected_direction_match,
    na.rm = TRUE
  ),
  "/",
  nrow(variant_results),
  "\n",
  sep = ""
)

cat(
  "minimum_pearson_correlation\t",
  min(
    variant_results$
      pearson_correlation_with_full_scores
  ),
  "\n",
  sep = ""
)

cat(
  "maximum_wilcox_p\t",
  max(
    variant_results$wilcox_p
  ),
  "\n",
  sep = ""
)

cat(
  "analysis_elapsed_seconds\t",
  analysis_elapsed_seconds,
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
  "baseline\t",
  baseline_file,
  "\n",
  sep = ""
)

cat(
  "reconstruction\t",
  reconstruction_file,
  "\n",
  sep = ""
)

cat(
  "module_manifest\t",
  module_manifest_file,
  "\n",
  sep = ""
)

cat(
  "variants\t",
  variant_file,
  "\n",
  sep = ""
)

cat(
  "summary\t",
  summary_file,
  "\n",
  sep = ""
)

cat(
  "worst_cases\t",
  worst_case_file,
  "\n",
  sep = ""
)

cat(
  "run_manifest\t",
  run_manifest_file,
  "\n",
  sep = ""
)

cat(
  "report\t",
  report_file,
  "\n",
  sep = ""
)

cat(
  "session_info\t",
  session_file,
  "\n",
  sep = ""
)

if (!quality_gate_pass) {
  stop(
    "Leave-one/two-gene robustness analysis failed its final quality gate."
  )
}
