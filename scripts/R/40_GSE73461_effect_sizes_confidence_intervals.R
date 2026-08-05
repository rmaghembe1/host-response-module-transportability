#!/usr/bin/env Rscript

# GSE73461 effect sizes and confidence intervals
#
# Revision-stage analysis.
#
# This script augments the submitted fixed-module projection with:
#   - descriptive statistics;
#   - Hodges-Lehmann location-shift estimates and 95% confidence intervals;
#   - rank-biserial correlations;
#   - stratified bootstrap confidence intervals for rank-biserial correlations;
#   - explicit checks against the submitted GSE73461 results.
#
# The submitted module definitions, module membership, score construction,
# sample contrasts and multiplicity families remain unchanged.


# -------------------------------------------------------------------------
# R library paths
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
# Packages
# -------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(data.table)
})


# -------------------------------------------------------------------------
# Input files
# -------------------------------------------------------------------------

main_scores_file <- paste0(
  "results/module_projection/",
  "GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_scores_long.tsv"
)

main_reference_file <- paste0(
  "results/module_projection/",
  "GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_primary_projection_tests.tsv"
)

sensitivity_scores_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_scores_long.tsv"
)

sensitivity_reference_file <- paste0(
  "results/module_projection/",
  "GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_primary_projection_tests.tsv"
)


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_effect_sizes_confidence_intervals"
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

output_file <- file.path(
  out_dir,
  "GSE73461_module_effect_sizes_confidence_intervals.tsv"
)

reference_check_file <- file.path(
  out_dir,
  "GSE73461_effect_size_reference_check.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE73461_effect_sizes_confidence_intervals_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE73461_effect_sizes_confidence_intervals_sessionInfo.txt"
)


# -------------------------------------------------------------------------
# Analysis constants
# -------------------------------------------------------------------------

bootstrap_replicates <- 10000L
base_seed <- 20260805L
comparison_tolerance <- 1e-12

expected_module_count <- 5L
expected_bacterial_samples <- 52L
expected_viral_samples <- 94L


# -------------------------------------------------------------------------
# Input validation
# -------------------------------------------------------------------------

required_input_files <- c(
  main_scores_file,
  main_reference_file,
  sensitivity_scores_file,
  sensitivity_reference_file
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
# Read and validate score tables
# -------------------------------------------------------------------------

read_primary_scores <- function(
  path,
  population_label
) {
  dt <- fread(path)

  required_columns <- c(
    "final_module_id",
    "final_module_label",
    "final_module_direction",
    "base_sample_id",
    "projection_role",
    "module_score"
  )

  missing_columns <- setdiff(
    required_columns,
    names(dt)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste(
        "Missing columns in",
        path,
        ":",
        paste(
          missing_columns,
          collapse = ", "
        )
      )
    )
  }

  dt <- dt[
    projection_role %in% c(
      "primary_bacterial",
      "primary_viral"
    )
  ]

  dt[
    ,
    module_score := as.numeric(module_score)
  ]

  dt[
    ,
    scoring_population := population_label
  ]

  if (any(!is.finite(dt$module_score))) {
    stop(
      paste(
        "Non-finite module scores found in",
        path
      )
    )
  }

  duplicate_rows <- dt[
    ,
    .N,
    by = .(
      final_module_id,
      base_sample_id
    )
  ][
    N != 1L
  ]

  if (nrow(duplicate_rows) > 0L) {
    stop(
      paste(
        "Duplicate module/sample rows found in",
        path
      )
    )
  }

  module_count <- uniqueN(
    dt$final_module_id
  )

  if (module_count != expected_module_count) {
    stop(
      paste(
        "Expected",
        expected_module_count,
        "modules in",
        path,
        "but found",
        module_count
      )
    )
  }

  count_check <- dt[
    ,
    .N,
    by = .(
      final_module_id,
      projection_role
    )
  ]

  invalid_counts <- count_check[
    (
      projection_role == "primary_bacterial" &
        N != expected_bacterial_samples
    ) |
      (
        projection_role == "primary_viral" &
          N != expected_viral_samples
      )
  ]

  if (nrow(invalid_counts) > 0L) {
    stop(
      paste(
        "Unexpected bacterial or viral sample counts in",
        path
      )
    )
  }

  dt
}


# -------------------------------------------------------------------------
# Rank-biserial correlation
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

  superiority_probability <- mean(
    comparison_matrix
  )

  2 * superiority_probability - 1
}


# -------------------------------------------------------------------------
# Stratified bootstrap confidence interval for rank-biserial correlation
# -------------------------------------------------------------------------

bootstrap_rank_biserial <- function(
  x,
  y,
  replicates,
  seed
) {
  nx <- length(x)
  ny <- length(y)

  if (nx < 2L || ny < 2L) {
    stop(
      "Both groups require at least two observations for bootstrap analysis."
    )
  }

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

  superiority_probability <- weighted_superiority / (
    nx * ny
  )

  bootstrap_values <- (
    2 * superiority_probability
  ) - 1

  c(
    lower = unname(
      quantile(
        bootstrap_values,
        probs = 0.025,
        type = 7,
        na.rm = TRUE
      )
    ),
    upper = unname(
      quantile(
        bootstrap_values,
        probs = 0.975,
        type = 7,
        na.rm = TRUE
      )
    )
  )
}


# -------------------------------------------------------------------------
# Analyse one module in one score-reference population
# -------------------------------------------------------------------------

analyse_module <- function(
  module_dt,
  bootstrap_seed
) {
  module_ids <- unique(
    module_dt$final_module_id
  )

  module_labels <- unique(
    module_dt$final_module_label
  )

  module_directions <- unique(
    module_dt$final_module_direction
  )

  populations <- unique(
    module_dt$scoring_population
  )

  if (
    length(module_ids) != 1L ||
      length(module_labels) != 1L ||
      length(module_directions) != 1L ||
      length(populations) != 1L
  ) {
    stop(
      "Module metadata are not unique."
    )
  }

  bacterial <- module_dt[
    projection_role == "primary_bacterial",
    module_score
  ]

  viral <- module_dt[
    projection_role == "primary_viral",
    module_score
  ]

  if (
    length(bacterial) != expected_bacterial_samples ||
      length(viral) != expected_viral_samples
  ) {
    stop(
      paste(
        "Unexpected sample counts for",
        module_ids
      )
    )
  }

  bacterial_quartiles <- quantile(
    bacterial,
    probs = c(
      0.25,
      0.75
    ),
    type = 7,
    names = FALSE,
    na.rm = TRUE
  )

  viral_quartiles <- quantile(
    viral,
    probs = c(
      0.25,
      0.75
    ),
    type = 7,
    names = FALSE,
    na.rm = TRUE
  )

  wilcox_primary <- suppressWarnings(
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

  if (
    length(wilcox_ci$estimate) != 1L ||
      length(wilcox_ci$conf.int) < 2L
  ) {
    stop(
      paste(
        "Hodges-Lehmann estimate or confidence interval unavailable for",
        module_ids
      )
    )
  }

  rank_biserial_value <- rank_biserial(
    bacterial,
    viral
  )

  rank_biserial_ci <- bootstrap_rank_biserial(
    bacterial,
    viral,
    replicates = bootstrap_replicates,
    seed = bootstrap_seed
  )

  data.table(
    scoring_population = populations,
    final_module_id = module_ids,
    final_module_label = module_labels,
    final_module_direction = module_directions,

    n_bacterial = length(bacterial),
    n_viral = length(viral),

    mean_bacterial = mean(
      bacterial
    ),

    sd_bacterial = sd(
      bacterial
    ),

    q1_bacterial = bacterial_quartiles[1],

    median_bacterial = median(
      bacterial
    ),

    q3_bacterial = bacterial_quartiles[2],

    iqr_bacterial = IQR(
      bacterial,
      type = 7
    ),

    mean_viral = mean(
      viral
    ),

    sd_viral = sd(
      viral
    ),

    q1_viral = viral_quartiles[1],

    median_viral = median(
      viral
    ),

    q3_viral = viral_quartiles[2],

    iqr_viral = IQR(
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
        wilcox_ci$conf.int[1]
      ),

    hodges_lehmann_ci_upper =
      unname(
        wilcox_ci$conf.int[2]
      ),

    rank_biserial_bacterial_vs_viral =
      rank_biserial_value,

    rank_biserial_ci_lower =
      unname(
        rank_biserial_ci["lower"]
      ),

    rank_biserial_ci_upper =
      unname(
        rank_biserial_ci["upper"]
      ),

    wilcox_W =
      unname(
        wilcox_primary$statistic
      ),

    wilcox_p =
      wilcox_primary$p.value,

    bootstrap_replicates =
      bootstrap_replicates,

    bootstrap_seed =
      bootstrap_seed,

    rank_biserial_orientation =
      "positive_means_higher_in_bacterial"
  )
}


# -------------------------------------------------------------------------
# Define score sources
# -------------------------------------------------------------------------

score_sources <- data.table(
  scoring_population = c(
    "main_all_projected_reference",
    "primary_only_reference"
  ),
  score_file = c(
    main_scores_file,
    sensitivity_scores_file
  )
)


# -------------------------------------------------------------------------
# Run effect-size analyses
# -------------------------------------------------------------------------

result_list <- list()
result_index <- 0L

for (
  source_index in seq_len(
    nrow(score_sources)
  )
) {
  population_label <- score_sources[
    source_index,
    scoring_population
  ]

  score_file <- score_sources[
    source_index,
    score_file
  ]

  scores <- read_primary_scores(
    score_file,
    population_label
  )

  module_ids <- sort(
    unique(
      scores$final_module_id
    )
  )

  for (
    module_index in seq_along(
      module_ids
    )
  ) {
    result_index <- result_index + 1L

    module_id <- module_ids[
      module_index
    ]

    bootstrap_seed <- (
      base_seed +
        source_index * 1000L +
        module_index
    )

    result_list[[result_index]] <- analyse_module(
      scores[
        final_module_id == module_id
      ],
      bootstrap_seed = bootstrap_seed
    )
  }
}

results <- rbindlist(
  result_list,
  use.names = TRUE,
  fill = TRUE
)


# -------------------------------------------------------------------------
# Multiplicity correction and directional checks
# -------------------------------------------------------------------------

results[
  ,
  wilcox_p_BH := p.adjust(
    wilcox_p,
    method = "BH"
  ),
  by = scoring_population
]

results[
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

population_order <- c(
  "main_all_projected_reference",
  "primary_only_reference"
)

results[
  ,
  scoring_population := factor(
    scoring_population,
    levels = population_order
  )
]

setorder(
  results,
  scoring_population,
  final_module_id
)

results[
  ,
  scoring_population := as.character(
    scoring_population
  )
]


# -------------------------------------------------------------------------
# Read submitted reference results
# -------------------------------------------------------------------------

read_reference <- function(
  path,
  population_label
) {
  dt <- fread(path)

  required_columns <- c(
    "final_module_id",
    "n_bacterial",
    "n_viral",
    "mean_bacterial",
    "mean_viral",
    "median_bacterial",
    "median_viral",
    "median_difference_bacterial_minus_viral",
    "wilcox_p",
    "wilcox_p_BH",
    "expected_direction_match"
  )

  missing_columns <- setdiff(
    required_columns,
    names(dt)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste(
        "Missing reference columns in",
        path,
        ":",
        paste(
          missing_columns,
          collapse = ", "
        )
      )
    )
  }

  dt <- dt[
    ,
    ..required_columns
  ]

  dt[
    ,
    scoring_population := population_label
  ]

  numeric_columns <- c(
    "mean_bacterial",
    "mean_viral",
    "median_bacterial",
    "median_viral",
    "median_difference_bacterial_minus_viral",
    "wilcox_p",
    "wilcox_p_BH"
  )

  setnames(
    dt,
    numeric_columns,
    paste0(
      "submitted_",
      numeric_columns
    )
  )

  setnames(
    dt,
    c(
      "n_bacterial",
      "n_viral",
      "expected_direction_match"
    ),
    c(
      "submitted_n_bacterial",
      "submitted_n_viral",
      "submitted_expected_direction_match"
    )
  )

  dt
}

reference <- rbindlist(
  list(
    read_reference(
      main_reference_file,
      "main_all_projected_reference"
    ),
    read_reference(
      sensitivity_reference_file,
      "primary_only_reference"
    )
  ),
  use.names = TRUE,
  fill = TRUE
)


# -------------------------------------------------------------------------
# Compare new calculations against submitted results
# -------------------------------------------------------------------------

reference_check <- merge(
  results,
  reference,
  by = c(
    "scoring_population",
    "final_module_id"
  ),
  all = TRUE
)

reference_check[
  ,
  mean_bacterial_abs_difference := abs(
    mean_bacterial -
      submitted_mean_bacterial
  )
]

reference_check[
  ,
  mean_viral_abs_difference := abs(
    mean_viral -
      submitted_mean_viral
  )
]

reference_check[
  ,
  median_bacterial_abs_difference := abs(
    median_bacterial -
      submitted_median_bacterial
  )
]

reference_check[
  ,
  median_viral_abs_difference := abs(
    median_viral -
      submitted_median_viral
  )
]

reference_check[
  ,
  median_difference_abs_difference := abs(
    median_difference_bacterial_minus_viral -
      submitted_median_difference_bacterial_minus_viral
  )
]

reference_check[
  ,
  wilcox_p_abs_difference := abs(
    wilcox_p -
      submitted_wilcox_p
  )
]

reference_check[
  ,
  wilcox_p_BH_abs_difference := abs(
    wilcox_p_BH -
      submitted_wilcox_p_BH
  )
]

reference_check[
  ,
  reference_check_status := fifelse(
    n_bacterial ==
      submitted_n_bacterial &
      n_viral ==
        submitted_n_viral &
      expected_direction_match ==
        submitted_expected_direction_match &
      mean_bacterial_abs_difference <=
        comparison_tolerance &
      mean_viral_abs_difference <=
        comparison_tolerance &
      median_bacterial_abs_difference <=
        comparison_tolerance &
      median_viral_abs_difference <=
        comparison_tolerance &
      median_difference_abs_difference <=
        comparison_tolerance &
      wilcox_p_abs_difference <=
        comparison_tolerance &
      wilcox_p_BH_abs_difference <=
        comparison_tolerance,
    "PASS",
    "REVIEW"
  )
]


# -------------------------------------------------------------------------
# Write result tables
# -------------------------------------------------------------------------

fwrite(
  results,
  output_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  reference_check,
  reference_check_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Quality-control summaries
# -------------------------------------------------------------------------

reference_passes <- reference_check[
  reference_check_status == "PASS",
  .N
]

direction_matches <- results[
  expected_direction_match == TRUE,
  .N
]


# -------------------------------------------------------------------------
# Write Markdown report
# -------------------------------------------------------------------------

report_connection <- file(
  report_file,
  open = "wt",
  encoding = "UTF-8"
)

writeLines(
  c(
    "# GSE73461 effect sizes and confidence intervals",
    "",
    "## Purpose",
    "",
    paste(
      "This revision-stage analysis augments the submitted",
      "GSE73461 fixed-module projection with descriptive",
      "statistics, Hodges-Lehmann location-shift estimates",
      "and rank-biserial effect sizes."
    ),
    "",
    paste(
      "The five submitted modules, score definitions and",
      "sample contrasts were not changed."
    ),
    "",
    "## Statistical specification",
    "",
    paste0(
      "- Wilcoxon rank-sum tests were two-sided, used ",
      "`exact = FALSE` and retained the default continuity ",
      "correction."
    ),
    paste0(
      "- Hodges-Lehmann estimates and 95% confidence intervals ",
      "were obtained from the corresponding Wilcoxon ",
      "location-shift calculation."
    ),
    paste0(
      "- Rank-biserial correlation was oriented so positive ",
      "values indicate higher scores in bacterial infection."
    ),
    paste0(
      "- Rank-biserial 95% confidence intervals used ",
      bootstrap_replicates,
      " stratified percentile-bootstrap resamples."
    ),
    paste0(
      "- BH adjustment was performed across the five modules ",
      "separately within each z-score reference population."
    ),
    "",
    "## Quality assurance",
    "",
    paste0(
      "- Effect-size rows: ",
      nrow(results)
    ),
    paste0(
      "- Submitted-result reference checks passed: ",
      reference_passes,
      "/",
      nrow(reference_check)
    ),
    paste0(
      "- Expected-direction matches: ",
      direction_matches,
      "/",
      nrow(results)
    ),
    "",
    "## Result preview",
    "",
    "```text"
  ),
  con = report_connection
)

writeLines(
  capture.output(
    print(
      results[
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
  ),
  con = report_connection
)

writeLines(
  c(
    "```",
    "",
    "## Interpretation boundary",
    "",
    paste(
      "These effect sizes quantify separation of fixed module",
      "scores between the prespecified bacterial and viral",
      "groups. They do not represent diagnostic model",
      "training or diagnostic-performance validation."
    ),
    "",
    "## Output files",
    "",
    paste0(
      "- `",
      output_file,
      "`"
    ),
    paste0(
      "- `",
      reference_check_file,
      "`"
    )
  ),
  con = report_connection
)

close(report_connection)


# -------------------------------------------------------------------------
# Write session information without trailing whitespace
# -------------------------------------------------------------------------

session_lines <- capture.output(
  sessionInfo()
)

session_lines <- sub(
  "[[:space:]]+$",
  "",
  session_lines
)

writeLines(
  session_lines,
  session_file
)


# -------------------------------------------------------------------------
# Final analysis gate
# -------------------------------------------------------------------------

cat(
  "===== GSE73461 EFFECT-SIZE ANALYSIS =====\n"
)

cat(
  "scoring_populations\t",
  uniqueN(
    results$scoring_population
  ),
  "\n",
  sep = ""
)

cat(
  "effect_rows\t",
  nrow(results),
  "\n",
  sep = ""
)

cat(
  "bootstrap_replicates_per_row\t",
  bootstrap_replicates,
  "\n",
  sep = ""
)

cat(
  "reference_checks_passed\t",
  reference_passes,
  "/",
  nrow(reference_check),
  "\n",
  sep = ""
)

cat(
  "expected_direction_matches\t",
  direction_matches,
  "/",
  nrow(results),
  "\n",
  sep = ""
)

analysis_pass <- (
  nrow(results) == 10L &&
    uniqueN(
      results$scoring_population
    ) == 2L &&
    reference_passes == 10L &&
    direction_matches == 10L &&
    all(
      is.finite(
        results$hodges_lehmann_bacterial_minus_viral
      )
    ) &&
    all(
      is.finite(
        results$hodges_lehmann_ci_lower
      )
    ) &&
    all(
      is.finite(
        results$hodges_lehmann_ci_upper
      )
    ) &&
    all(
      is.finite(
        results$rank_biserial_bacterial_vs_viral
      )
    ) &&
    all(
      is.finite(
        results$rank_biserial_ci_lower
      )
    ) &&
    all(
      is.finite(
        results$rank_biserial_ci_upper
      )
    ) &&
    all(
      results$rank_biserial_ci_lower <=
        results$rank_biserial_bacterial_vs_viral
    ) &&
    all(
      results$rank_biserial_ci_upper >=
        results$rank_biserial_bacterial_vs_viral
    ) &&
    all(
      results$hodges_lehmann_ci_lower <=
        results$hodges_lehmann_bacterial_minus_viral
    ) &&
    all(
      results$hodges_lehmann_ci_upper >=
        results$hodges_lehmann_bacterial_minus_viral
    )
)

cat(
  "status\t",
  ifelse(
    analysis_pass,
    "PASS",
    "REVIEW"
  ),
  "\n",
  sep = ""
)

cat(
  "results\t",
  output_file,
  "\n",
  sep = ""
)

cat(
  "reference_check\t",
  reference_check_file,
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

if (!analysis_pass) {
  stop(
    "GSE73461 effect-size analysis failed its quality gate."
  )
}
