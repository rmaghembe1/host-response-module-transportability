#!/usr/bin/env Rscript

# GSE73461 fixed-module GSVA comparison
#
# Revision-stage sensitivity analysis.
#
# This script:
#   1. reuses the locked GSE73461 sample definitions;
#   2. reuses the deterministic probe choices from the submitted mean-z
#      projection and its primary-only sensitivity analysis;
#   3. applies GSVA to the five locked GSE211567 modules;
#   4. runs separate all-projected-sample and primary-only GSVA analyses;
#   5. estimates group differences, confidence intervals and rank-biserial
#      effect sizes;
#   6. compares GSVA scores with the submitted mean-z scores.
#
# No module genes, labels, directions or weights are changed.


# -------------------------------------------------------------------------
# Library paths
# -------------------------------------------------------------------------

candidate_libs <- unique(
  c(
    Sys.getenv("R_LIBS_USER"),
    path.expand("~/R/library"),
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
# Required packages
# -------------------------------------------------------------------------

required_packages <- c(
  "data.table",
  "GSVA",
  "BiocParallel"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    quietly = TRUE,
    FUN.VALUE = logical(1)
  )
]

if (length(missing_packages) > 0L) {
  stop(
    paste(
      "Required packages are missing:",
      paste(
        missing_packages,
        collapse = ", "
      )
    )
  )
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

sample_table_file <- paste0(
  "results/external_projection_candidate_audit/",
  "GSE73461_expression_files/",
  "GSE73461_candidate_primary_projection_sample_table.tsv"
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

main_mean_z_file <- paste0(
  "results/module_projection/GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_scores_long.tsv"
)

primary_mean_z_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_scores_long.tsv"
)

gsva_audit_file <- paste0(
  "results/revision_round1/",
  "GSVA_package_interface_feasibility/",
  "GSVA_package_interface_feasibility.tsv"
)


# -------------------------------------------------------------------------
# Output files
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_GSVA_projection_comparison"
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

scores_long_file <- file.path(
  out_dir,
  "GSE73461_GSVA_scores_long.tsv"
)

scores_wide_file <- file.path(
  out_dir,
  "GSE73461_GSVA_scores_wide.tsv"
)

coverage_file <- file.path(
  out_dir,
  "GSE73461_GSVA_module_coverage.tsv"
)

effects_file <- file.path(
  out_dir,
  "GSE73461_GSVA_primary_projection_effects.tsv"
)

correlations_file <- file.path(
  out_dir,
  "GSE73461_GSVA_vs_mean_z_correlations.tsv"
)

manifest_file <- file.path(
  out_dir,
  "GSE73461_GSVA_run_manifest.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE73461_GSVA_projection_comparison_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE73461_GSVA_projection_comparison_sessionInfo.txt"
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

expected_bacterial_samples <- 52L
expected_viral_samples <- 94L
expected_control_samples <- 55L
expected_main_samples <- 201L
expected_primary_samples <- 146L

bootstrap_replicates <- 10000L
base_seed <- 20260805L

gsva_kcdf <- "Gaussian"
gsva_min_size <- 1L
gsva_max_size <- Inf
gsva_tau <- 1
gsva_max_diff <- TRUE
gsva_abs_ranking <- FALSE


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
  columns,
  source_name
) {
  missing_columns <- setdiff(
    columns,
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

pick_column <- function(
  column_names,
  preferred,
  pattern = NULL,
  required = TRUE
) {
  exact_match <- preferred[
    preferred %in% column_names
  ]

  if (length(exact_match) > 0L) {
    return(exact_match[1L])
  }

  if (!is.null(pattern)) {
    pattern_match <- column_names[
      grepl(
        pattern,
        column_names,
        ignore.case = TRUE
      )
    ]

    if (length(pattern_match) > 0L) {
      return(pattern_match[1L])
    }
  }

  if (required) {
    stop(
      paste(
        "Unable to identify required column from candidates:",
        paste(
          preferred,
          collapse = ", "
        )
      )
    )
  }

  NA_character_
}


# -------------------------------------------------------------------------
# Input validation
# -------------------------------------------------------------------------

required_input_files <- c(
  norm_expr_file,
  module_gene_file,
  sample_table_file,
  main_probe_choice_file,
  primary_probe_choice_file,
  main_mean_z_file,
  primary_mean_z_file,
  gsva_audit_file
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
# Confirm GSVA interface audit
# -------------------------------------------------------------------------

gsva_audit <- fread(
  gsva_audit_file
)

require_columns(
  gsva_audit,
  c(
    "component",
    "metric",
    "value",
    "status"
  ),
  gsva_audit_file
)

gsva_ready_rows <- gsva_audit[
  metric == "GSVA_scoring_readiness" &
    value == "PASS_READY_FOR_GSVA_SCORING" &
    status == "PASS"
]

if (nrow(gsva_ready_rows) != 1L) {
  stop(
    "The GSVA interface audit does not contain one passing readiness row."
  )
}

if (!exists(
  "gsvaParam",
  where = asNamespace("GSVA"),
  inherits = FALSE
)) {
  stop(
    "The installed GSVA package does not expose the expected gsvaParam interface."
  )
}


# -------------------------------------------------------------------------
# Read and standardize locked module definitions
# -------------------------------------------------------------------------

module_raw <- fread(
  module_gene_file
)

module_id_column <- pick_column(
  names(module_raw),
  preferred = c(
    "final_module_id",
    "module_id"
  ),
  pattern = "module.*id|^module_id$"
)

symbol_column <- pick_column(
  names(module_raw),
  preferred = c(
    "SYMBOL",
    "symbol",
    "gene_symbol"
  ),
  pattern = "^symbol$|gene.*symbol"
)

label_column <- pick_column(
  names(module_raw),
  preferred = c(
    "final_module_label",
    "module_label"
  ),
  pattern = "module.*label",
  required = FALSE
)

direction_column <- pick_column(
  names(module_raw),
  preferred = c(
    "final_module_direction",
    "module_direction"
  ),
  pattern = "direction|orientation",
  required = FALSE
)

module_genes <- data.table(
  final_module_id = as.character(
    module_raw[[module_id_column]]
  ),
  SYMBOL = as.character(
    module_raw[[symbol_column]]
  )
)

if (!is.na(label_column)) {
  module_genes[
    ,
    final_module_label :=
      as.character(
        module_raw[[label_column]]
      )
  ]
} else {
  module_genes[
    ,
    final_module_label :=
      final_module_id
  ]
}

if (!is.na(direction_column)) {
  module_genes[
    ,
    final_module_direction :=
      as.character(
        module_raw[[direction_column]]
      )
  ]
} else {
  module_genes[
    ,
    final_module_direction := fifelse(
      grepl(
        "^BACT",
        final_module_id
      ),
      "higher_in_bacterial",
      fifelse(
        grepl(
          "^VIR",
          final_module_id
        ),
        "higher_in_viral",
        "not_specified"
      )
    )
  ]
}

module_genes[
  ,
  SYMBOL_UPPER := toupper(
    trimws(SYMBOL)
  )
]

module_genes <- module_genes[
  final_module_id %in% expected_module_ids &
    !is.na(SYMBOL_UPPER) &
    nzchar(SYMBOL_UPPER)
]

module_genes <- unique(
  module_genes[
    ,
    .(
      final_module_id,
      final_module_label,
      final_module_direction,
      SYMBOL,
      SYMBOL_UPPER
    )
  ]
)

module_metadata <- module_genes[
  ,
  .(
    final_module_label =
      unique(final_module_label)[1L],
    final_module_direction =
      unique(final_module_direction)[1L]
  ),
  by = final_module_id
]

module_counts <- module_genes[
  ,
  .(
    locked_gene_count =
      uniqueN(SYMBOL_UPPER)
  ),
  by = final_module_id
]

module_count_check <- merge(
  expected_locked_counts,
  module_counts,
  by = "final_module_id",
  all = TRUE
)

module_count_check[
  ,
  count_match :=
    expected_locked_gene_count ==
      locked_gene_count
]

if (
  nrow(module_count_check) != 5L ||
    any(!module_count_check$count_match)
) {
  print(module_count_check)

  stop(
    "Locked module gene counts do not match the submitted five-module contract."
  )
}


# -------------------------------------------------------------------------
# Read and lock sample populations
# -------------------------------------------------------------------------

sample_table <- fread(
  sample_table_file
)

require_columns(
  sample_table,
  c(
    "base_sample_id",
    "projection_role"
  ),
  sample_table_file
)

sample_table[
  ,
  base_sample_id :=
    as.character(base_sample_id)
]

sample_table[
  ,
  projection_role :=
    as.character(projection_role)
]

sample_role_conflicts <- sample_table[
  ,
  .(
    n_roles =
      uniqueN(projection_role)
  ),
  by = base_sample_id
][
  n_roles != 1L
]

if (nrow(sample_role_conflicts) > 0L) {
  stop(
    "One or more GSE73461 samples have conflicting projection roles."
  )
}

sample_table <- unique(
  sample_table,
  by = "base_sample_id"
)

main_samples <- sample_table[
  projection_role %in% c(
    "primary_bacterial",
    "primary_viral",
    "secondary_control_context"
  ),
  .(
    base_sample_id,
    projection_role
  )
]

primary_samples <- main_samples[
  projection_role %in% c(
    "primary_bacterial",
    "primary_viral"
  )
]

sample_counts <- main_samples[
  ,
  .N,
  by = projection_role
]

n_bacterial <- sample_counts[
  projection_role == "primary_bacterial",
  N
]

n_viral <- sample_counts[
  projection_role == "primary_viral",
  N
]

n_control <- sample_counts[
  projection_role == "secondary_control_context",
  N
]

if (
  length(n_bacterial) != 1L ||
    length(n_viral) != 1L ||
    length(n_control) != 1L ||
    n_bacterial != expected_bacterial_samples ||
    n_viral != expected_viral_samples ||
    n_control != expected_control_samples ||
    nrow(main_samples) != expected_main_samples ||
    nrow(primary_samples) != expected_primary_samples
) {
  print(sample_counts)

  stop(
    "GSE73461 sample counts do not match the locked cohort definition."
  )
}


# -------------------------------------------------------------------------
# Read only required normalized expression columns
# -------------------------------------------------------------------------

expression_header <- names(
  fread(
    norm_expr_file,
    nrows = 0L,
    showProgress = FALSE
  )
)

array_id_column <- if (
  "ARRAY_ID" %in% expression_header
) {
  "ARRAY_ID"
} else {
  expression_header[1L]
}

missing_expression_samples <- setdiff(
  main_samples$base_sample_id,
  expression_header
)

if (length(missing_expression_samples) > 0L) {
  stop(
    paste(
      "Locked samples absent from normalized expression matrix:",
      paste(
        missing_expression_samples,
        collapse = ", "
      )
    )
  )
}

expression_columns <- c(
  array_id_column,
  main_samples$base_sample_id
)

message(
  "Reading normalized expression values for ",
  length(main_samples$base_sample_id),
  " locked projection samples..."
)

expression_dt <- fread(
  norm_expr_file,
  select = expression_columns,
  showProgress = TRUE
)

if (array_id_column != "ARRAY_ID") {
  setnames(
    expression_dt,
    array_id_column,
    "ARRAY_ID"
  )
}

expression_dt[
  ,
  ARRAY_ID :=
    as.character(ARRAY_ID)
]

if (anyDuplicated(expression_dt$ARRAY_ID)) {
  stop(
    "Normalized expression matrix contains duplicated ARRAY_ID values."
  )
}


# -------------------------------------------------------------------------
# Read deterministic probe choices
# -------------------------------------------------------------------------

read_probe_choices <- function(
  path,
  population_label
) {
  dt <- fread(path)

  require_columns(
    dt,
    "ARRAY_ID",
    path
  )

  if (!"SYMBOL_UPPER" %in% names(dt)) {
    require_columns(
      dt,
      "SYMBOL",
      path
    )

    dt[
      ,
      SYMBOL_UPPER :=
        toupper(
          trimws(
            as.character(SYMBOL)
          )
        )
    ]
  }

  dt[
    ,
    ARRAY_ID :=
      as.character(ARRAY_ID)
  ]

  dt[
    ,
    SYMBOL_UPPER :=
      toupper(
        trimws(
          as.character(SYMBOL_UPPER)
        )
      )
  ]

  dt <- dt[
    SYMBOL_UPPER %in%
      module_genes$SYMBOL_UPPER
  ]

  duplicate_symbols <- dt[
    ,
    .N,
    by = SYMBOL_UPPER
  ][
    N != 1L
  ]

  if (nrow(duplicate_symbols) > 0L) {
    stop(
      paste(
        "Probe-choice file contains duplicate selected symbols for",
        population_label
      )
    )
  }

  if (anyNA(dt$ARRAY_ID) || any(!nzchar(dt$ARRAY_ID))) {
    stop(
      paste(
        "Probe-choice file contains missing ARRAY_ID values for",
        population_label
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


# -------------------------------------------------------------------------
# Build a selected gene-expression matrix
# -------------------------------------------------------------------------

build_gene_matrix <- function(
  probe_choice,
  sample_ids,
  population_label
) {
  row_index <- match(
    probe_choice$ARRAY_ID,
    expression_dt$ARRAY_ID
  )

  if (anyNA(row_index)) {
    missing_probes <- probe_choice[
      is.na(row_index),
      ARRAY_ID
    ]

    stop(
      paste(
        "Selected probes absent from expression matrix for",
        population_label,
        ":",
        paste(
          missing_probes,
          collapse = ", "
        )
      )
    )
  }

  matrix_dt <- expression_dt[
    row_index,
    c(sample_ids),
    with = FALSE
  ]

  gene_matrix <- as.matrix(
    matrix_dt
  )

  storage.mode(gene_matrix) <- "double"

  rownames(gene_matrix) <- probe_choice$SYMBOL_UPPER
  colnames(gene_matrix) <- sample_ids

  if (anyDuplicated(rownames(gene_matrix))) {
    stop(
      paste(
        "Gene matrix contains duplicated symbols for",
        population_label
      )
    )
  }

  if (any(!is.finite(gene_matrix))) {
    stop(
      paste(
        "Gene matrix contains non-finite expression values for",
        population_label
      )
    )
  }

  gene_matrix
}


# -------------------------------------------------------------------------
# GSVA scoring for one population
# -------------------------------------------------------------------------

score_population <- function(
  scoring_population,
  sample_dt,
  probe_choice_file
) {
  sample_ids <- sample_dt$base_sample_id

  probe_choice <- read_probe_choices(
    probe_choice_file,
    scoring_population
  )

  gene_matrix <- build_gene_matrix(
    probe_choice,
    sample_ids,
    scoring_population
  )

  gene_sets <- lapply(
    expected_module_ids,
    function(module_id) {
      locked_symbols <- module_genes[
        final_module_id == module_id,
        unique(SYMBOL_UPPER)
      ]

      intersect(
        locked_symbols,
        rownames(gene_matrix)
      )
    }
  )

  names(gene_sets) <- expected_module_ids

  coverage_rows <- lapply(
    expected_module_ids,
    function(module_id) {
      locked_symbols <- module_genes[
        final_module_id == module_id,
        unique(SYMBOL_UPPER)
      ]

      available_symbols <- gene_sets[[module_id]]

      missing_symbols <- setdiff(
        locked_symbols,
        available_symbols
      )

      data.table(
        scoring_population =
          scoring_population,
        final_module_id =
          module_id,
        locked_gene_count =
          length(locked_symbols),
        available_gene_count =
          length(available_symbols),
        coverage_fraction =
          length(available_symbols) /
            length(locked_symbols),
        available_symbols =
          paste(
            sort(available_symbols),
            collapse = ";"
          ),
        missing_symbols =
          paste(
            sort(missing_symbols),
            collapse = ";"
          )
      )
    }
  )

  coverage_dt <- rbindlist(
    coverage_rows,
    use.names = TRUE
  )

  if (any(coverage_dt$coverage_fraction < 0.50)) {
    print(coverage_dt)

    stop(
      paste(
        "At least one module fails the 50% coverage rule for",
        scoring_population
      )
    )
  }

  gsva_parameters <- GSVA::gsvaParam(
    exprData = gene_matrix,
    geneSets = gene_sets,
    minSize = gsva_min_size,
    maxSize = gsva_max_size,
    kcdf = gsva_kcdf,
    tau = gsva_tau,
    maxDiff = gsva_max_diff,
    absRanking = gsva_abs_ranking
  )

  gsva_scores <- GSVA::gsva(
    gsva_parameters,
    verbose = FALSE,
    BPPARAM = BiocParallel::SerialParam(
      progressbar = FALSE
    )
  )

  gsva_scores <- as.matrix(
    gsva_scores
  )

  missing_score_modules <- setdiff(
    expected_module_ids,
    rownames(gsva_scores)
  )

  missing_score_samples <- setdiff(
    sample_ids,
    colnames(gsva_scores)
  )

  if (
    length(missing_score_modules) > 0L ||
      length(missing_score_samples) > 0L
  ) {
    stop(
      paste(
        "GSVA output identifiers are incomplete for",
        scoring_population
      )
    )
  }

  gsva_scores <- gsva_scores[
    expected_module_ids,
    sample_ids,
    drop = FALSE
  ]

  if (
    nrow(gsva_scores) != 5L ||
      ncol(gsva_scores) != length(sample_ids) ||
      any(!is.finite(gsva_scores))
  ) {
    stop(
      paste(
        "GSVA score matrix failed dimension or finite-value checks for",
        scoring_population
      )
    )
  }

  score_wide <- as.data.table(
    t(gsva_scores),
    keep.rownames = "base_sample_id"
  )

  score_long <- melt(
    score_wide,
    id.vars = "base_sample_id",
    variable.name = "final_module_id",
    value.name = "gsva_score",
    variable.factor = FALSE
  )

  score_long[
    ,
    scoring_population :=
      scoring_population
  ]

  score_long <- merge(
    score_long,
    sample_dt,
    by = "base_sample_id",
    all.x = TRUE,
    sort = FALSE
  )

  score_long <- merge(
    score_long,
    module_metadata,
    by = "final_module_id",
    all.x = TRUE,
    sort = FALSE
  )

  setcolorder(
    score_long,
    c(
      "scoring_population",
      "base_sample_id",
      "projection_role",
      "final_module_id",
      "final_module_label",
      "final_module_direction",
      "gsva_score"
    )
  )

  setorder(
    score_long,
    final_module_id,
    base_sample_id
  )

  score_wide <- merge(
    score_wide,
    sample_dt,
    by = "base_sample_id",
    all.x = TRUE,
    sort = FALSE
  )

  score_wide[
    ,
    scoring_population :=
      scoring_population
  ]

  setcolorder(
    score_wide,
    c(
      "scoring_population",
      "base_sample_id",
      "projection_role",
      expected_module_ids
    )
  )

  list(
    scoring_population =
      scoring_population,
    gene_matrix =
      gene_matrix,
    gene_sets =
      gene_sets,
    score_matrix =
      gsva_scores,
    scores_long =
      score_long,
    scores_wide =
      score_wide,
    coverage =
      coverage_dt
  )
}


# -------------------------------------------------------------------------
# Run both prespecified GSVA populations
# -------------------------------------------------------------------------

main_result <- score_population(
  scoring_population =
    "main_all_projected_reference",
  sample_dt =
    main_samples,
  probe_choice_file =
    main_probe_choice_file
)

primary_result <- score_population(
  scoring_population =
    "primary_only_reference",
  sample_dt =
    primary_samples,
  probe_choice_file =
    primary_probe_choice_file
)

scores_long <- rbindlist(
  list(
    main_result$scores_long,
    primary_result$scores_long
  ),
  use.names = TRUE,
  fill = TRUE
)

scores_wide <- rbindlist(
  list(
    main_result$scores_wide,
    primary_result$scores_wide
  ),
  use.names = TRUE,
  fill = TRUE
)

coverage <- rbindlist(
  list(
    main_result$coverage,
    primary_result$coverage
  ),
  use.names = TRUE,
  fill = TRUE
)


# -------------------------------------------------------------------------
# Effect-size helpers
# -------------------------------------------------------------------------

rank_biserial <- function(
  x,
  y
) {
  comparison_matrix <- outer(
    x,
    y,
    FUN = function(a, b) {
      ifelse(
        a > b,
        1,
        ifelse(
          a < b,
          0,
          0.5
        )
      )
    }
  )

  2 * mean(comparison_matrix) - 1
}

bootstrap_rank_biserial <- function(
  x,
  y,
  replicates,
  seed
) {
  nx <- length(x)
  ny <- length(y)

  comparison_matrix <- outer(
    x,
    y,
    FUN = function(a, b) {
      ifelse(
        a > b,
        1,
        ifelse(
          a < b,
          0,
          0.5
        )
      )
    }
  )

  set.seed(seed)

  x_counts <- rmultinom(
    n = replicates,
    size = nx,
    prob = rep(
      1 / nx,
      nx
    )
  )

  y_counts <- rmultinom(
    n = replicates,
    size = ny,
    prob = rep(
      1 / ny,
      ny
    )
  )

  weighted_superiority <- colSums(
    x_counts * (
      comparison_matrix %*% y_counts
    )
  )

  bootstrap_values <- (
    2 * (
      weighted_superiority /
        (nx * ny)
    )
  ) - 1

  c(
    lower = unname(
      quantile(
        bootstrap_values,
        probs = 0.025,
        type = 7
      )
    ),
    upper = unname(
      quantile(
        bootstrap_values,
        probs = 0.975,
        type = 7
      )
    )
  )
}

analyse_effect <- function(
  dt,
  bootstrap_seed
) {
  bacterial <- dt[
    projection_role == "primary_bacterial",
    gsva_score
  ]

  viral <- dt[
    projection_role == "primary_viral",
    gsva_score
  ]

  if (
    length(bacterial) != expected_bacterial_samples ||
      length(viral) != expected_viral_samples
  ) {
    stop(
      "Unexpected bacterial or viral sample count during GSVA testing."
    )
  }

  bacterial_quartiles <- quantile(
    bacterial,
    probs = c(
      0.25,
      0.75
    ),
    type = 7,
    names = FALSE
  )

  viral_quartiles <- quantile(
    viral,
    probs = c(
      0.25,
      0.75
    ),
    type = 7,
    names = FALSE
  )

  wilcox_test <- suppressWarnings(
    wilcox.test(
      bacterial,
      viral,
      alternative = "two.sided",
      paired = FALSE,
      exact = FALSE,
      correct = TRUE
    )
  )

  wilcox_ci <- suppressWarnings(
    wilcox.test(
      bacterial,
      viral,
      alternative = "two.sided",
      paired = FALSE,
      exact = FALSE,
      correct = TRUE,
      conf.int = TRUE,
      conf.level = 0.95
    )
  )

  rb_value <- rank_biserial(
    bacterial,
    viral
  )

  rb_ci <- bootstrap_rank_biserial(
    bacterial,
    viral,
    replicates = bootstrap_replicates,
    seed = bootstrap_seed
  )

  data.table(
    scoring_population =
      unique(dt$scoring_population),
    final_module_id =
      unique(dt$final_module_id),
    final_module_label =
      unique(dt$final_module_label),
    final_module_direction =
      unique(dt$final_module_direction),
    n_bacterial =
      length(bacterial),
    n_viral =
      length(viral),
    mean_bacterial =
      mean(bacterial),
    sd_bacterial =
      sd(bacterial),
    q1_bacterial =
      bacterial_quartiles[1L],
    median_bacterial =
      median(bacterial),
    q3_bacterial =
      bacterial_quartiles[2L],
    iqr_bacterial =
      IQR(
        bacterial,
        type = 7
      ),
    mean_viral =
      mean(viral),
    sd_viral =
      sd(viral),
    q1_viral =
      viral_quartiles[1L],
    median_viral =
      median(viral),
    q3_viral =
      viral_quartiles[2L],
    iqr_viral =
      IQR(
        viral,
        type = 7
      ),
    median_difference_bacterial_minus_viral =
      median(bacterial) -
        median(viral),
    hodges_lehmann_bacterial_minus_viral =
      unname(
        wilcox_ci$estimate
      ),
    hodges_lehmann_ci_lower =
      unname(
        wilcox_ci$conf.int[1L]
      ),
    hodges_lehmann_ci_upper =
      unname(
        wilcox_ci$conf.int[2L]
      ),
    rank_biserial_bacterial_vs_viral =
      rb_value,
    rank_biserial_ci_lower =
      unname(
        rb_ci["lower"]
      ),
    rank_biserial_ci_upper =
      unname(
        rb_ci["upper"]
      ),
    wilcox_W =
      unname(
        wilcox_test$statistic
      ),
    wilcox_p =
      wilcox_test$p.value,
    bootstrap_replicates =
      bootstrap_replicates,
    bootstrap_seed =
      bootstrap_seed
  )
}


# -------------------------------------------------------------------------
# Calculate GSVA effects
# -------------------------------------------------------------------------

effect_groups <- split(
  scores_long[
    projection_role %in% c(
      "primary_bacterial",
      "primary_viral"
    )
  ],
  by = c(
    "scoring_population",
    "final_module_id"
  ),
  keep.by = TRUE
)

effects_list <- vector(
  "list",
  length(effect_groups)
)

for (index in seq_along(effect_groups)) {
  effects_list[[index]] <- analyse_effect(
    effect_groups[[index]],
    bootstrap_seed =
      base_seed + 42000L + index
  )
}

effects <- rbindlist(
  effects_list,
  use.names = TRUE,
  fill = TRUE
)

effects[
  ,
  wilcox_p_BH :=
    p.adjust(
      wilcox_p,
      method = "BH"
    ),
  by = scoring_population
]

effects[
  ,
  expected_direction_match := fifelse(
    final_module_direction == "higher_in_bacterial",
    median_difference_bacterial_minus_viral > 0,
    fifelse(
      final_module_direction == "higher_in_viral",
      median_difference_bacterial_minus_viral < 0,
      NA
    )
  )
]

setorder(
  effects,
  scoring_population,
  final_module_id
)


# -------------------------------------------------------------------------
# Compare GSVA with submitted mean-z scores
# -------------------------------------------------------------------------

read_mean_z_scores <- function(
  path,
  scoring_population
) {
  dt <- fread(path)

  require_columns(
    dt,
    c(
      "final_module_id",
      "base_sample_id",
      "module_score"
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
    mean_z_score :=
      as.numeric(module_score)
  ]

  dt[
    ,
    scoring_population :=
      scoring_population
  ]

  dt[
    ,
    .(
      scoring_population,
      base_sample_id,
      final_module_id,
      mean_z_score
    )
  ]
}

mean_z_scores <- rbindlist(
  list(
    read_mean_z_scores(
      main_mean_z_file,
      "main_all_projected_reference"
    ),
    read_mean_z_scores(
      primary_mean_z_file,
      "primary_only_reference"
    )
  ),
  use.names = TRUE,
  fill = TRUE
)

score_comparison <- merge(
  scores_long[
    ,
    .(
      scoring_population,
      base_sample_id,
      final_module_id,
      gsva_score
    )
  ],
  mean_z_scores,
  by = c(
    "scoring_population",
    "base_sample_id",
    "final_module_id"
  ),
  all = TRUE
)

if (
  anyNA(score_comparison$gsva_score) ||
    anyNA(score_comparison$mean_z_score)
) {
  stop(
    "GSVA and submitted mean-z score tables do not merge completely."
  )
}

correlations <- score_comparison[
  ,
  .(
    n_compared =
      .N,
    pearson_correlation =
      cor(
        gsva_score,
        mean_z_score,
        method = "pearson"
      ),
    spearman_correlation =
      cor(
        gsva_score,
        mean_z_score,
        method = "spearman"
      ),
    gsva_mean =
      mean(gsva_score),
    gsva_sd =
      sd(gsva_score),
    mean_z_mean =
      mean(mean_z_score),
    mean_z_sd =
      sd(mean_z_score)
  ),
  by = .(
    scoring_population,
    final_module_id
  )
]

correlations[
  ,
  expected_n_compared := fifelse(
    scoring_population ==
      "main_all_projected_reference",
    expected_main_samples,
    expected_primary_samples
  )
]

correlations[
  ,
  sample_count_match :=
    n_compared ==
      expected_n_compared
]

setorder(
  correlations,
  scoring_population,
  final_module_id
)


# -------------------------------------------------------------------------
# Run manifest
# -------------------------------------------------------------------------

direction_matches <- effects[
  expected_direction_match == TRUE,
  .N
]

manifest <- data.table(
  metric = c(
    "GSVA_version",
    "BiocParallel_version",
    "GSVA_interface",
    "GSVA_kcdf",
    "GSVA_minSize",
    "GSVA_maxSize",
    "GSVA_tau",
    "GSVA_maxDiff",
    "GSVA_absRanking",
    "GSVA_parallel_mode",
    "locked_module_count",
    "main_sample_count",
    "primary_only_sample_count",
    "main_score_matrix_rows",
    "main_score_matrix_columns",
    "primary_score_matrix_rows",
    "primary_score_matrix_columns",
    "combined_score_rows",
    "coverage_rows",
    "effect_rows",
    "correlation_rows",
    "expected_direction_matches"
  ),
  value = c(
    as.character(
      packageVersion("GSVA")
    ),
    as.character(
      packageVersion("BiocParallel")
    ),
    "modern_parameter_object_api",
    gsva_kcdf,
    as.character(gsva_min_size),
    as.character(gsva_max_size),
    as.character(gsva_tau),
    as.character(gsva_max_diff),
    as.character(gsva_abs_ranking),
    "BiocParallel_SerialParam",
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
      nrow(main_result$score_matrix)
    ),
    as.character(
      ncol(main_result$score_matrix)
    ),
    as.character(
      nrow(primary_result$score_matrix)
    ),
    as.character(
      ncol(primary_result$score_matrix)
    ),
    as.character(
      nrow(scores_long)
    ),
    as.character(
      nrow(coverage)
    ),
    as.character(
      nrow(effects)
    ),
    as.character(
      nrow(correlations)
    ),
    paste0(
      direction_matches,
      "/",
      nrow(effects)
    )
  )
)


# -------------------------------------------------------------------------
# Write outputs
# -------------------------------------------------------------------------

fwrite(
  scores_long,
  scores_long_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  scores_wide,
  scores_wide_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  coverage,
  coverage_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  effects,
  effects_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  correlations,
  correlations_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  manifest,
  manifest_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Final quality gate
# -------------------------------------------------------------------------

expected_combined_score_rows <- (
  length(expected_module_ids) *
    (
      expected_main_samples +
        expected_primary_samples
    )
)

duplicate_score_rows <- scores_long[
  ,
  .N,
  by = .(
    scoring_population,
    base_sample_id,
    final_module_id
  )
][
  N != 1L
]

quality_gate_pass <- (
  nrow(main_result$score_matrix) == 5L &&
    ncol(main_result$score_matrix) ==
      expected_main_samples &&
    nrow(primary_result$score_matrix) == 5L &&
    ncol(primary_result$score_matrix) ==
      expected_primary_samples &&
    nrow(scores_long) ==
      expected_combined_score_rows &&
    nrow(duplicate_score_rows) == 0L &&
    all(is.finite(scores_long$gsva_score)) &&
    nrow(coverage) == 10L &&
    all(coverage$coverage_fraction >= 0.50) &&
    nrow(effects) == 10L &&
    all(is.finite(effects$wilcox_p)) &&
    all(is.finite(
      effects$hodges_lehmann_bacterial_minus_viral
    )) &&
    all(is.finite(
      effects$rank_biserial_bacterial_vs_viral
    )) &&
    all(
      effects$hodges_lehmann_ci_lower <=
        effects$hodges_lehmann_bacterial_minus_viral
    ) &&
    all(
      effects$hodges_lehmann_ci_upper >=
        effects$hodges_lehmann_bacterial_minus_viral
    ) &&
    all(
      effects$rank_biserial_ci_lower <=
        effects$rank_biserial_bacterial_vs_viral
    ) &&
    all(
      effects$rank_biserial_ci_upper >=
        effects$rank_biserial_bacterial_vs_viral
    ) &&
    nrow(correlations) == 10L &&
    all(correlations$sample_count_match) &&
    all(is.finite(
      correlations$pearson_correlation
    )) &&
    all(is.finite(
      correlations$spearman_correlation
    ))
)


# -------------------------------------------------------------------------
# Markdown report
# -------------------------------------------------------------------------

effect_preview <- clean_text_lines(
  capture.output(
    print(
      effects[
        ,
        .(
          scoring_population,
          final_module_id,
          median_difference_bacterial_minus_viral,
          hodges_lehmann_bacterial_minus_viral,
          hodges_lehmann_ci_lower,
          hodges_lehmann_ci_upper,
          rank_biserial_bacterial_vs_viral,
          rank_biserial_ci_lower,
          rank_biserial_ci_upper,
          wilcox_p,
          wilcox_p_BH,
          expected_direction_match
        )
      ]
    )
  )
)

correlation_preview <- clean_text_lines(
  capture.output(
    print(
      correlations[
        ,
        .(
          scoring_population,
          final_module_id,
          n_compared,
          pearson_correlation,
          spearman_correlation,
          sample_count_match
        )
      ]
    )
  )
)

report_lines <- c(
  "# GSE73461 fixed-module GSVA comparison",
  "",
  "## Purpose",
  "",
  paste(
    "This revision-stage sensitivity analysis compared",
    "GSVA scores with the submitted unweighted mean-z scores",
    "for the five locked GSE211567 modules in GSE73461."
  ),
  "",
  paste(
    "Module genes, labels, directions, cohort definitions and",
    "deterministic probe selections were not changed."
  ),
  "",
  "## GSVA configuration",
  "",
  paste0(
    "- GSVA version: `",
    packageVersion("GSVA"),
    "`"
  ),
  paste0(
    "- BiocParallel version: `",
    packageVersion("BiocParallel"),
    "`"
  ),
  "- Interface: `gsvaParam()` followed by `gsva()`.",
  paste0(
    "- Kernel: `",
    gsva_kcdf,
    "`."
  ),
  paste0(
    "- Minimum gene-set size: `",
    gsva_min_size,
    "`."
  ),
  "- Maximum gene-set size: `Inf`.",
  paste0(
    "- Tau: `",
    gsva_tau,
    "`."
  ),
  paste0(
    "- Maximum-difference statistic: `",
    gsva_max_diff,
    "`."
  ),
  paste0(
    "- Absolute ranking: `",
    gsva_abs_ranking,
    "`."
  ),
  "- Execution: serial using `BiocParallel::SerialParam()`.",
  "",
  "## Scoring populations",
  "",
  paste0(
    "- Main reference: ",
    expected_main_samples,
    " samples, comprising ",
    expected_bacterial_samples,
    " bacterial, ",
    expected_viral_samples,
    " viral and ",
    expected_control_samples,
    " contextual-control samples."
  ),
  paste0(
    "- Primary-only reference: ",
    expected_primary_samples,
    " bacterial and viral samples."
  ),
  "",
  "## Quality assurance",
  "",
  paste0(
    "- Combined GSVA score rows: ",
    nrow(scores_long)
  ),
  paste0(
    "- Coverage rows: ",
    nrow(coverage)
  ),
  paste0(
    "- Effect-size rows: ",
    nrow(effects)
  ),
  paste0(
    "- GSVA versus mean-z correlation rows: ",
    nrow(correlations)
  ),
  paste0(
    "- Expected-direction matches: ",
    direction_matches,
    "/",
    nrow(effects)
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
  "## GSVA bacterial-versus-viral effects",
  "",
  "```text",
  effect_preview,
  "```",
  "",
  "## GSVA versus submitted mean-z correlations",
  "",
  "```text",
  correlation_preview,
  "```",
  "",
  "## Interpretation boundary",
  "",
  paste(
    "GSVA is treated as an alternative scoring sensitivity",
    "analysis. It does not replace the submitted primary",
    "unweighted mean-z-score analysis and was not used to",
    "redefine or optimize any module."
  ),
  "",
  paste(
    "Direction disagreement, weak correlation or lack of",
    "statistical significance would be retained as an",
    "informative sensitivity result rather than used to tune",
    "the locked modules."
  ),
  "",
  "## Output files",
  "",
  paste0(
    "- `",
    scores_long_file,
    "`"
  ),
  paste0(
    "- `",
    scores_wide_file,
    "`"
  ),
  paste0(
    "- `",
    coverage_file,
    "`"
  ),
  paste0(
    "- `",
    effects_file,
    "`"
  ),
  paste0(
    "- `",
    correlations_file,
    "`"
  ),
  paste0(
    "- `",
    manifest_file,
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
  "===== GSE73461 FIXED-MODULE GSVA COMPARISON =====\n"
)

cat(
  "GSVA_version\t",
  as.character(
    packageVersion("GSVA")
  ),
  "\n",
  sep = ""
)

cat(
  "main_score_dimensions\t",
  nrow(main_result$score_matrix),
  "x",
  ncol(main_result$score_matrix),
  "\n",
  sep = ""
)

cat(
  "primary_only_score_dimensions\t",
  nrow(primary_result$score_matrix),
  "x",
  ncol(primary_result$score_matrix),
  "\n",
  sep = ""
)

cat(
  "combined_score_rows\t",
  nrow(scores_long),
  "\n",
  sep = ""
)

cat(
  "coverage_rows\t",
  nrow(coverage),
  "\n",
  sep = ""
)

cat(
  "effect_rows\t",
  nrow(effects),
  "\n",
  sep = ""
)

cat(
  "correlation_rows\t",
  nrow(correlations),
  "\n",
  sep = ""
)

cat(
  "expected_direction_matches\t",
  direction_matches,
  "/",
  nrow(effects),
  "\n",
  sep = ""
)

cat(
  "minimum_coverage_fraction\t",
  min(coverage$coverage_fraction),
  "\n",
  sep = ""
)

cat(
  "minimum_pearson_correlation\t",
  min(correlations$pearson_correlation),
  "\n",
  sep = ""
)

cat(
  "minimum_spearman_correlation\t",
  min(correlations$spearman_correlation),
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
  "scores_long\t",
  scores_long_file,
  "\n",
  sep = ""
)

cat(
  "scores_wide\t",
  scores_wide_file,
  "\n",
  sep = ""
)

cat(
  "coverage\t",
  coverage_file,
  "\n",
  sep = ""
)

cat(
  "effects\t",
  effects_file,
  "\n",
  sep = ""
)

cat(
  "correlations\t",
  correlations_file,
  "\n",
  sep = ""
)

cat(
  "manifest\t",
  manifest_file,
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
    "GSE73461 GSVA comparison failed its final quality gate."
  )
}
