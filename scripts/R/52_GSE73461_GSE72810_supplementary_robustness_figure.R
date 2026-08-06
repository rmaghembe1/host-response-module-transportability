#!/usr/bin/env Rscript

# =========================================================================
# GSE73461-GSE72810 supplementary sensitivity and robustness figure
# =========================================================================
#
# Purpose
#
# Generate a three-panel supplementary figure documenting:
#
# A. Z-reference, case-definition and probe-collapse sensitivities across
#    GSE73461 and GSE72810.
#
# B. GSE73461 mean-z versus GSVA scoring-method sensitivity.
#
# C. Exhaustive GSE73461 leave-one/two-gene robustness.
#
# Panels A and B use rank-biserial effects and bootstrap 95% confidence
# intervals because rank-biserial effects remain comparable across score
# representations with different numerical scales.
#
# Panel C shows the minimum Pearson correlation between each deletion
# variant and the corresponding complete-module score.
#
# No gene reselection, module redefinition, effect-direction flipping or
# diagnostic-model training is performed.
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
  library(grid)
})

if (!capabilities("cairo")) {
  stop(
    "Cairo graphics support is required for publication figure export."
  )
}

options(
  bitmapType = "cairo"
)


# -------------------------------------------------------------------------
# Input paths
# -------------------------------------------------------------------------

gse73461_mean_z_file <- paste0(
  "results/revision_round1/",
  "GSE73461_effect_sizes_confidence_intervals/",
  "GSE73461_module_effect_sizes_confidence_intervals.tsv"
)

gse73461_gsva_file <- paste0(
  "results/revision_round1/",
  "GSE73461_GSVA_projection_comparison/",
  "GSE73461_GSVA_primary_projection_effects.tsv"
)

gse73461_deletion_file <- paste0(
  "results/revision_round1/",
  "GSE73461_leave_one_two_gene_robustness/",
  "GSE73461_leave_one_two_gene_summary.tsv"
)

gse72810_effects_file <- paste0(
  "results/revision_round1/",
  "GSE72810_effect_sizes_confidence_intervals/",
  "GSE72810_effect_sizes_confidence_intervals.tsv"
)

gse72810_concordance_file <- paste0(
  "results/revision_round1/",
  "GSE72810_fixed_module_projection/",
  "GSE72810_score_concordance.tsv"
)

gse72810_analysis_summary_file <- paste0(
  "results/revision_round1/",
  "GSE72810_effect_sizes_confidence_intervals/",
  "GSE72810_effect_size_analysis_summary.tsv"
)


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_GSE72810_supplementary_robustness"
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

panel_a_source_file <- file.path(
  out_dir,
  "Figure_S1_panel_A_zreference_probe_case_sensitivity.tsv"
)

panel_b_source_file <- file.path(
  out_dir,
  "Figure_S1_panel_B_mean_z_GSVA_method_sensitivity.tsv"
)

panel_b_summary_file <- file.path(
  out_dir,
  "Figure_S1_panel_B_method_discordance_summary.tsv"
)

panel_c_source_file <- file.path(
  out_dir,
  "Figure_S1_panel_C_leave_one_two_gene_robustness.tsv"
)

key_findings_file <- file.path(
  out_dir,
  "Figure_S1_key_robustness_findings.tsv"
)

figure_manifest_file <- file.path(
  out_dir,
  "Figure_S1_supplementary_robustness_manifest.tsv"
)

quality_gate_file <- file.path(
  out_dir,
  "Figure_S1_supplementary_robustness_quality_gate.tsv"
)

quality_summary_file <- file.path(
  out_dir,
  "Figure_S1_supplementary_robustness_quality_summary.tsv"
)

caption_file <- file.path(
  docs_dir,
  "Figure_S1_supplementary_robustness_caption.md"
)

report_file <- file.path(
  docs_dir,
  "Figure_S1_supplementary_robustness_report.md"
)

session_file <- file.path(
  session_dir,
  "Figure_S1_supplementary_robustness_sessionInfo.txt"
)

figure_base <- paste0(
  "Figure_S1_fixed_module_",
  "sensitivity_and_robustness"
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
  panel_a_source_file,
  panel_b_source_file,
  panel_b_summary_file,
  panel_c_source_file,
  key_findings_file,
  figure_manifest_file,
  quality_gate_file,
  quality_summary_file,
  caption_file,
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

module_top_to_bottom <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

module_factor_levels <- rev(
  module_top_to_bottom
)

expected_panel_a_rows <- 30L
expected_panel_b_rows <- 20L
expected_panel_b_wide_rows <- 10L
expected_panel_c_rows <- 20L

expected_deletion_variants <- 29826L
expected_bootstrap_replicates <- 10000L

figure_width_inches <- 10
figure_height_inches <- 12
figure_dpi <- 1200L

module_labels <- c(
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

panel_a_analysis_levels <- c(
  "GSE73461 mean-z primary",
  "GSE73461 primary-only z-reference",
  "GSE72810 primary",
  "GSE72810 primary-only z-reference",
  "GSE72810 expanded case definition",
  "GSE72810 all-probe mean"
)

panel_a_colours <- c(
  "GSE73461 mean-z primary" =
    "#0072B2",
  "GSE73461 primary-only z-reference" =
    "#56B4E9",
  "GSE72810 primary" =
    "#D55E00",
  "GSE72810 primary-only z-reference" =
    "#E69F00",
  "GSE72810 expanded case definition" =
    "#CC79A7",
  "GSE72810 all-probe mean" =
    "#009E73"
)

panel_a_shapes <- c(
  "GSE73461 mean-z primary" =
    21,
  "GSE73461 primary-only z-reference" =
    24,
  "GSE72810 primary" =
    22,
  "GSE72810 primary-only z-reference" =
    23,
  "GSE72810 expanded case definition" =
    25,
  "GSE72810 all-probe mean" =
    8
)

method_colours <- c(
  "Mean-z" =
    "#0072B2",
  "GSVA" =
    "#CC79A7"
)

reference_shapes <- c(
  "All projected z-reference" =
    21,
  "Primary-only z-reference" =
    24
)

deletion_colours <- c(
  "Leave one gene" =
    "#0072B2",
  "Leave two genes" =
    "#D55E00"
)

required_panel_b_wide_columns <- c(
  "final_module_id",
  "scoring_population",
  "rank_biserial_effect_GSVA",
  "rank_biserial_effect_Mean_z",
  "wilcoxon_q_GSVA",
  "wilcoxon_q_Mean_z",
  "fdr_significant_GSVA",
  "fdr_significant_Mean_z",
  "rank_biserial_ci_excludes_zero_GSVA",
  "rank_biserial_ci_excludes_zero_Mean_z"
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

  trimws(values)
}


sanitize_table <- function(table_object) {
  output <- copy(table_object)

  text_columns <- names(output)[
    vapply(
      output,
      function(values) {
        is.character(values) ||
          is.factor(values)
      },
      FUN.VALUE = logical(1L)
    )
  ]

  for (column_name in text_columns) {
    set(
      output,
      j = column_name,
      value = clean_text(
        output[[column_name]]
      )
    )
  }

  output
}


write_tsv <- function(
  table_object,
  output_file
) {
  fwrite(
    sanitize_table(table_object),
    output_file,
    sep = "\t",
    quote = FALSE,
    na = "NA"
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


file_size_bytes <- function(path) {
  if (!file.exists(path)) {
    return(NA_real_)
  }

  as.numeric(
    file.info(path)$size
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


svg_contains_raster_image <- function(path) {
  if (!file.exists(path)) {
    return(NA)
  }

  svg_text <- paste(
    readLines(
      path,
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  grepl(
    "<image([[:space:]>])|data:image/",
    svg_text,
    ignore.case = TRUE,
    perl = TRUE
  )
}


svg_path_count <- function(path) {
  if (!file.exists(path)) {
    return(NA_integer_)
  }

  svg_text <- paste(
    readLines(
      path,
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  matches <- gregexpr(
    "<path([[:space:]>])",
    svg_text,
    ignore.case = TRUE,
    perl = TRUE
  )[[1L]]

  if (
    length(matches) == 1L &&
      matches[1L] == -1L
  ) {
    return(0L)
  }

  length(matches)
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


render_composite <- function() {
  grid.newpage()

  layout_object <- grid.layout(
    nrow = 4L,
    ncol = 1L,
    heights = unit(
      c(
        0.55,
        4.15,
        3.65,
        3.35
      ),
      "in"
    )
  )

  pushViewport(
    viewport(
      layout = layout_object
    )
  )

  grid.text(
    paste(
      "Supplementary sensitivity and robustness of",
      "locked host-response modules"
    ),
    vp = viewport(
      layout.pos.row = 1L,
      layout.pos.col = 1L
    ),
    gp = gpar(
      fontsize = 17,
      fontface = "bold"
    )
  )

  print(
    panel_a_plot,
    vp = viewport(
      layout.pos.row = 2L,
      layout.pos.col = 1L
    )
  )

  print(
    panel_b_plot,
    vp = viewport(
      layout.pos.row = 3L,
      layout.pos.col = 1L
    )
  )

  print(
    panel_c_plot,
    vp = viewport(
      layout.pos.row = 4L,
      layout.pos.col = 1L
    )
  )

  popViewport()
}


export_composite <- function() {
  grDevices::png(
    filename = figure_png,
    width = figure_width_inches,
    height = figure_height_inches,
    units = "in",
    res = figure_dpi,
    type = "cairo",
    bg = "white"
  )

  tryCatch(
    render_composite(),
    finally = grDevices::dev.off()
  )

  grDevices::svg(
    filename = figure_svg,
    width = figure_width_inches,
    height = figure_height_inches,
    onefile = TRUE,
    bg = "white"
  )

  tryCatch(
    render_composite(),
    finally = grDevices::dev.off()
  )

  grDevices::cairo_pdf(
    filename = figure_pdf,
    width = figure_width_inches,
    height = figure_height_inches,
    onefile = TRUE,
    bg = "white"
  )

  tryCatch(
    render_composite(),
    finally = grDevices::dev.off()
  )
}


# -------------------------------------------------------------------------
# Validate and read inputs
# -------------------------------------------------------------------------

required_files <- c(
  gse73461_mean_z_file,
  gse73461_gsva_file,
  gse73461_deletion_file,
  gse72810_effects_file,
  gse72810_concordance_file,
  gse72810_analysis_summary_file
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

gse73461_mean_z <- fread(
  gse73461_mean_z_file
)

gse73461_gsva <- fread(
  gse73461_gsva_file
)

gse73461_deletion <- fread(
  gse73461_deletion_file
)

gse72810_effects <- fread(
  gse72810_effects_file
)

gse72810_concordance <- fread(
  gse72810_concordance_file
)

gse72810_analysis_summary <- fread(
  gse72810_analysis_summary_file
)


# -------------------------------------------------------------------------
# Validate schemas
# -------------------------------------------------------------------------

effect_columns_gse73461 <- c(
  "scoring_population",
  "final_module_id",
  "final_module_label",
  "final_module_direction",
  "n_bacterial",
  "n_viral",
  "rank_biserial_bacterial_vs_viral",
  "rank_biserial_ci_lower",
  "rank_biserial_ci_upper",
  "bootstrap_replicates",
  "wilcox_p_BH",
  "expected_direction_match"
)

require_columns(
  gse73461_mean_z,
  effect_columns_gse73461,
  gse73461_mean_z_file
)

require_columns(
  gse73461_gsva,
  effect_columns_gse73461,
  gse73461_gsva_file
)

require_columns(
  gse73461_deletion,
  c(
    "scoring_population",
    "final_module_id",
    "deletion_order",
    "final_module_label",
    "observed_variant_count",
    "expected_direction_preserved_fraction",
    "full_effect_sign_preserved_fraction",
    "minimum_wilcox_p",
    "maximum_wilcox_p",
    "minimum_pearson_correlation_with_full",
    "minimum_spearman_correlation_with_full",
    "expected_variant_count",
    "variant_count_match"
  ),
  gse73461_deletion_file
)

require_columns(
  gse72810_effects,
  c(
    "analysis_id",
    "final_module_id",
    "analysis_role",
    "final_module_label",
    "expected_direction",
    "rank_biserial_effect",
    "rank_biserial_ci_low",
    "rank_biserial_ci_high",
    "rank_biserial_ci_excludes_zero",
    "bootstrap_replicates_completed",
    "wilcoxon_q",
    "direction_retained",
    "fdr_significant"
  ),
  gse72810_effects_file
)

require_columns(
  gse72810_concordance,
  c(
    "comparison_id",
    "final_module_id",
    "sample_count",
    "pearson_correlation",
    "spearman_correlation",
    "mean_absolute_score_difference",
    "maximum_absolute_score_difference"
  ),
  gse72810_concordance_file
)

require_columns(
  gse72810_analysis_summary,
  c(
    "analysis_id",
    "analysis_role",
    "module_count",
    "direction_retained_modules",
    "nominally_significant_modules",
    "fdr_significant_modules",
    "hodges_lehmann_ci_excluding_zero_modules",
    "rank_biserial_ci_excluding_zero_modules"
  ),
  gse72810_analysis_summary_file
)


# -------------------------------------------------------------------------
# Parse logical fields
# -------------------------------------------------------------------------

gse73461_mean_z[
  ,
  expected_direction_match :=
    coerce_logical_strict(
      expected_direction_match,
      "GSE73461 mean-z expected-direction field"
    )
]

gse73461_gsva[
  ,
  expected_direction_match :=
    coerce_logical_strict(
      expected_direction_match,
      "GSE73461 GSVA expected-direction field"
    )
]

gse73461_deletion[
  ,
  variant_count_match :=
    coerce_logical_strict(
      variant_count_match,
      "GSE73461 deletion variant-count field"
    )
]

gse72810_effects[
  ,
  direction_retained :=
    coerce_logical_strict(
      direction_retained,
      "GSE72810 direction-retained field"
    )
]

gse72810_effects[
  ,
  rank_biserial_ci_excludes_zero :=
    coerce_logical_strict(
      rank_biserial_ci_excludes_zero,
      "GSE72810 rank-biserial CI field"
    )
]

gse72810_effects[
  ,
  fdr_significant :=
    coerce_logical_strict(
      fdr_significant,
      "GSE72810 FDR field"
    )
]


# -------------------------------------------------------------------------
# Panel A: z-reference, case-definition and probe-collapse sensitivity
# -------------------------------------------------------------------------

gse73461_panel_a <- gse73461_mean_z[
  ,
  .(
    cohort_id =
      "GSE73461",
    analysis_id =
      as.character(scoring_population),
    analysis_display =
      ifelse(
        scoring_population ==
          "main_all_projected_reference",
        "GSE73461 mean-z primary",
        "GSE73461 primary-only z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(final_module_direction),
    bacterial_n =
      as.integer(n_bacterial),
    viral_n =
      as.integer(n_viral),
    rank_biserial_effect =
      as.numeric(
        rank_biserial_bacterial_vs_viral
      ),
    rank_biserial_ci_low =
      as.numeric(rank_biserial_ci_lower),
    rank_biserial_ci_high =
      as.numeric(rank_biserial_ci_upper),
    bootstrap_replicates =
      as.integer(bootstrap_replicates),
    wilcoxon_q =
      as.numeric(wilcox_p_BH),
    direction_retained =
      expected_direction_match,
    fdr_significant =
      wilcox_p_BH < 0.05
  )
]

gse73461_panel_a[
  ,
  rank_biserial_ci_excludes_zero :=
    mapply(
      ci_excludes_zero,
      rank_biserial_ci_low,
      rank_biserial_ci_high
    )
]

gse72810_analysis_display <- c(
  main_representative_all146_z_definite =
    "GSE72810 primary",
  primary_only_representative_51_z_definite =
    "GSE72810 primary-only z-reference",
  expanded_representative_all146_z_definite_probable =
    "GSE72810 expanded case definition",
  all_probe_mean_all146_z_definite =
    "GSE72810 all-probe mean"
)

gse72810_panel_a <- gse72810_effects[
  ,
  .(
    cohort_id =
      "GSE72810",
    analysis_id =
      as.character(analysis_id),
    analysis_display =
      unname(
        gse72810_analysis_display[
          analysis_id
        ]
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(expected_direction),
    bacterial_n =
      as.integer(
        ifelse(
          analysis_id ==
            "expanded_representative_all146_z_definite_probable",
          40L,
          23L
        )
      ),
    viral_n =
      as.integer(
        ifelse(
          analysis_id ==
            "expanded_representative_all146_z_definite_probable",
          35L,
          28L
        )
      ),
    rank_biserial_effect =
      as.numeric(rank_biserial_effect),
    rank_biserial_ci_low =
      as.numeric(rank_biserial_ci_low),
    rank_biserial_ci_high =
      as.numeric(rank_biserial_ci_high),
    rank_biserial_ci_excludes_zero =
      rank_biserial_ci_excludes_zero,
    bootstrap_replicates =
      as.integer(
        bootstrap_replicates_completed
      ),
    wilcoxon_q =
      as.numeric(wilcoxon_q),
    direction_retained =
      direction_retained,
    fdr_significant =
      fdr_significant
  )
]

if (anyNA(gse72810_panel_a$analysis_display)) {
  stop(
    "At least one GSE72810 analysis identifier lacks a locked display label."
  )
}

panel_a_source <- rbindlist(
  list(
    gse73461_panel_a,
    gse72810_panel_a
  ),
  use.names = TRUE,
  fill = TRUE
)

panel_a_source[
  ,
  final_module_id :=
    factor(
      final_module_id,
      levels = module_factor_levels
    )
]

panel_a_source[
  ,
  analysis_display :=
    factor(
      analysis_display,
      levels = panel_a_analysis_levels
    )
]

panel_a_source[
  ,
  cohort_id :=
    factor(
      cohort_id,
      levels = c(
        "GSE73461",
        "GSE72810"
      )
    )
]

setorder(
  panel_a_source,
  cohort_id,
  final_module_id,
  analysis_display
)


# -------------------------------------------------------------------------
# Panel B: mean-z versus GSVA method sensitivity
# -------------------------------------------------------------------------

mean_z_panel_b <- gse73461_mean_z[
  ,
  .(
    scoring_method =
      "Mean-z",
    method_key =
      "Mean_z",
    scoring_population =
      as.character(scoring_population),
    reference_display =
      ifelse(
        scoring_population ==
          "main_all_projected_reference",
        "All projected z-reference",
        "Primary-only z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(final_module_direction),
    rank_biserial_effect =
      as.numeric(
        rank_biserial_bacterial_vs_viral
      ),
    rank_biserial_ci_low =
      as.numeric(rank_biserial_ci_lower),
    rank_biserial_ci_high =
      as.numeric(rank_biserial_ci_upper),
    bootstrap_replicates =
      as.integer(bootstrap_replicates),
    wilcoxon_q =
      as.numeric(wilcox_p_BH),
    direction_retained =
      expected_direction_match,
    fdr_significant =
      wilcox_p_BH < 0.05
  )
]

gsva_panel_b <- gse73461_gsva[
  ,
  .(
    scoring_method =
      "GSVA",
    method_key =
      "GSVA",
    scoring_population =
      as.character(scoring_population),
    reference_display =
      ifelse(
        scoring_population ==
          "main_all_projected_reference",
        "All projected z-reference",
        "Primary-only z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    expected_direction =
      as.character(final_module_direction),
    rank_biserial_effect =
      as.numeric(
        rank_biserial_bacterial_vs_viral
      ),
    rank_biserial_ci_low =
      as.numeric(rank_biserial_ci_lower),
    rank_biserial_ci_high =
      as.numeric(rank_biserial_ci_upper),
    bootstrap_replicates =
      as.integer(bootstrap_replicates),
    wilcoxon_q =
      as.numeric(wilcox_p_BH),
    direction_retained =
      expected_direction_match,
    fdr_significant =
      wilcox_p_BH < 0.05
  )
]

panel_b_source <- rbindlist(
  list(
    mean_z_panel_b,
    gsva_panel_b
  ),
  use.names = TRUE,
  fill = TRUE
)

panel_b_source[
  ,
  rank_biserial_ci_excludes_zero :=
    mapply(
      ci_excludes_zero,
      rank_biserial_ci_low,
      rank_biserial_ci_high
    )
]

panel_b_source[
  ,
  final_module_id :=
    factor(
      final_module_id,
      levels = module_factor_levels
    )
]

panel_b_source[
  ,
  scoring_method :=
    factor(
      scoring_method,
      levels = c(
        "Mean-z",
        "GSVA"
      )
    )
]

panel_b_source[
  ,
  method_key :=
    factor(
      method_key,
      levels = c(
        "Mean_z",
        "GSVA"
      )
    )
]

panel_b_source[
  ,
  reference_display :=
    factor(
      reference_display,
      levels = c(
        "All projected z-reference",
        "Primary-only z-reference"
      )
    )
]

setorder(
  panel_b_source,
  final_module_id,
  reference_display,
  scoring_method
)

panel_b_wide <- dcast(
  panel_b_source,
  final_module_id +
    scoring_population ~
    method_key,
  value.var = c(
    "rank_biserial_effect",
    "wilcoxon_q",
    "fdr_significant",
    "rank_biserial_ci_excludes_zero"
  )
)

missing_panel_b_wide_columns <- setdiff(
  required_panel_b_wide_columns,
  names(panel_b_wide)
)

if (length(missing_panel_b_wide_columns) > 0L) {
  stop(
    paste(
      "Panel B wide-table construction did not create the locked",
      "syntactic method columns:",
      paste(
        missing_panel_b_wide_columns,
        collapse = ", "
      )
    )
  )
}

panel_b_wide[
  ,
  significance_discordant :=
    fdr_significant_Mean_z !=
      fdr_significant_GSVA
]

panel_b_wide[
  ,
  ci_support_discordant :=
    rank_biserial_ci_excludes_zero_Mean_z !=
      rank_biserial_ci_excludes_zero_GSVA
]

panel_b_wide[
  ,
  method_interpretation :=
    fifelse(
      final_module_id ==
        "VIR_M2" &
        fdr_significant_Mean_z &
        !fdr_significant_GSVA,
      paste(
        "Mean-z supported the expected viral-higher effect,",
        "whereas GSVA was near zero and statistically unsupported."
      ),
      fifelse(
        final_module_id ==
          "BACT_M1" &
          !fdr_significant_Mean_z &
          fdr_significant_GSVA,
        paste(
          "BACT_M1 was borderline under mean-z scoring but",
          "statistically supported under GSVA."
        ),
        paste(
          "Mean-z and GSVA retained concordant inferential support."
        )
      )
    )
]


# -------------------------------------------------------------------------
# Panel C: exhaustive leave-one/two-gene robustness
# -------------------------------------------------------------------------

panel_c_source <- gse73461_deletion[
  ,
  .(
    scoring_population =
      as.character(scoring_population),
    reference_display =
      ifelse(
        scoring_population ==
          "main_all_projected_reference",
        "All projected z-reference",
        "Primary-only z-reference"
      ),
    final_module_id =
      as.character(final_module_id),
    final_module_label =
      clean_text(final_module_label),
    deletion_order =
      as.character(deletion_order),
    deletion_display =
      ifelse(
        deletion_order ==
          "leave_one",
        "Leave one gene",
        "Leave two genes"
      ),
    observed_variant_count =
      as.integer(observed_variant_count),
    expected_variant_count =
      as.integer(expected_variant_count),
    variant_count_match =
      variant_count_match,
    expected_direction_preserved_fraction =
      as.numeric(
        expected_direction_preserved_fraction
      ),
    full_effect_sign_preserved_fraction =
      as.numeric(
        full_effect_sign_preserved_fraction
      ),
    minimum_wilcox_p =
      as.numeric(minimum_wilcox_p),
    maximum_wilcox_p =
      as.numeric(maximum_wilcox_p),
    minimum_pearson_correlation_with_full =
      as.numeric(
        minimum_pearson_correlation_with_full
      ),
    minimum_spearman_correlation_with_full =
      as.numeric(
        minimum_spearman_correlation_with_full
      )
  )
]

panel_c_source[
  ,
  final_module_id :=
    factor(
      final_module_id,
      levels = module_factor_levels
    )
]

panel_c_source[
  ,
  deletion_display :=
    factor(
      deletion_display,
      levels = c(
        "Leave one gene",
        "Leave two genes"
      )
    )
]

panel_c_source[
  ,
  reference_display :=
    factor(
      reference_display,
      levels = c(
        "All projected z-reference",
        "Primary-only z-reference"
      )
    )
]

setorder(
  panel_c_source,
  final_module_id,
  reference_display,
  deletion_display
)


# -------------------------------------------------------------------------
# Derived summaries
# -------------------------------------------------------------------------

minimum_gse72810_pearson <- min(
  gse72810_concordance$
    pearson_correlation,
  na.rm = TRUE
)

minimum_gse72810_spearman <- min(
  gse72810_concordance$
    spearman_correlation,
  na.rm = TRUE
)

total_deletion_variants <- sum(
  panel_c_source$
    observed_variant_count
)

minimum_deletion_pearson <- min(
  panel_c_source$
    minimum_pearson_correlation_with_full
)

minimum_deletion_spearman <- min(
  panel_c_source$
    minimum_spearman_correlation_with_full
)

all_deletion_directions_preserved <- all(
  panel_c_source$
    expected_direction_preserved_fraction ==
    1
)

panel_a_fdr_count <- sum(
  panel_a_source$
    fdr_significant
)

panel_a_ci_support_count <- sum(
  panel_a_source$
    rank_biserial_ci_excludes_zero
)

panel_b_fdr_count <- sum(
  panel_b_source$
    fdr_significant
)

panel_b_ci_support_count <- sum(
  panel_b_source$
    rank_biserial_ci_excludes_zero
)

method_discordant_rows <- panel_b_wide[
  significance_discordant ==
    TRUE
]

key_findings <- data.table(
  finding_id = c(
    "A1",
    "A2",
    "B1",
    "B2",
    "C1"
  ),
  finding = c(
    paste(
      "All 30 z-reference, case-definition and probe-collapse",
      "sensitivity rows retained their expected module direction."
    ),
    paste0(
      "GSE72810 sensitivity-score concordance remained high; ",
      "minimum Pearson r = ",
      format(
        minimum_gse72810_pearson,
        digits = 7
      ),
      " and minimum Spearman rho = ",
      format(
        minimum_gse72810_spearman,
        digits = 7
      ),
      "."
    ),
    paste(
      "VIR_M2 retained a viral-higher direction but lost",
      "confidence-interval and FDR support under GSVA in both",
      "z-reference populations."
    ),
    paste(
      "BACT_M1 was borderline under mean-z scoring but gained",
      "confidence-interval and FDR support under GSVA."
    ),
    paste0(
      "All ",
      total_deletion_variants,
      " leave-one/two-gene variants retained the expected",
      " direction; minimum Pearson r with the complete module was ",
      format(
        minimum_deletion_pearson,
        digits = 7
      ),
      "."
    )
  ),
  interpretation_boundary = c(
    paste(
      "Direction preservation does not imply identical effect",
      "magnitude or statistical significance."
    ),
    paste(
      "Correlation measures score-level concordance and does not",
      "replace effect-size comparison."
    ),
    paste(
      "VIR_M2 should be described as scoring-method-sensitive rather",
      "than uniformly robust across scoring algorithms."
    ),
    paste(
      "The stronger GSVA result does not convert BACT_M1 into a",
      "uniformly supported module across all primary analyses."
    ),
    paste(
      "Deletion robustness supports distributed module signal but",
      "does not establish causal sufficiency of individual genes."
    )
  )
)


# -------------------------------------------------------------------------
# Write source tables
# -------------------------------------------------------------------------

write_tsv(
  panel_a_source,
  panel_a_source_file
)

write_tsv(
  panel_b_source,
  panel_b_source_file
)

write_tsv(
  panel_b_wide,
  panel_b_summary_file
)

write_tsv(
  panel_c_source,
  panel_c_source_file
)

write_tsv(
  key_findings,
  key_findings_file
)

panel_a_disk_rows <- physical_data_rows(
  panel_a_source_file
)

panel_b_disk_rows <- physical_data_rows(
  panel_b_source_file
)

panel_b_wide_disk_rows <- physical_data_rows(
  panel_b_summary_file
)

panel_c_disk_rows <- physical_data_rows(
  panel_c_source_file
)


# -------------------------------------------------------------------------
# Panel A plot
# -------------------------------------------------------------------------

panel_a_dodge <- position_dodge(
  width = 0.72
)

panel_a_plot <- ggplot(
  panel_a_source,
  aes(
    x = final_module_id,
    y = rank_biserial_effect,
    colour = analysis_display,
    fill = analysis_display,
    shape = analysis_display,
    group = analysis_display
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    linewidth = 0.45,
    colour = "grey40"
  ) +
  geom_errorbar(
    aes(
      ymin = rank_biserial_ci_low,
      ymax = rank_biserial_ci_high
    ),
    position = panel_a_dodge,
    width = 0.14,
    linewidth = 0.66
  ) +
  geom_point(
    position = panel_a_dodge,
    size = 2.45,
    stroke = 0.7
  ) +
  facet_grid(
    cohort_id ~ .,
    scales = "free_y",
    space = "free_y"
  ) +
  scale_x_discrete(
    labels = module_labels
  ) +
  scale_y_continuous(
    limits = c(
      -1.05,
      1.05
    ),
    breaks = c(
      -1,
      -0.5,
      0,
      0.5,
      1
    )
  ) +
  scale_colour_manual(
    values = panel_a_colours,
    drop = FALSE,
    name = "Sensitivity analysis"
  ) +
  scale_fill_manual(
    values = panel_a_colours,
    drop = FALSE,
    name = "Sensitivity analysis"
  ) +
  scale_shape_manual(
    values = panel_a_shapes,
    drop = FALSE,
    name = "Sensitivity analysis"
  ) +
  coord_flip(
    clip = "off"
  ) +
  labs(
    title =
      "A  Z-reference, case-definition and probe-collapse sensitivities",
    subtitle =
      paste0(
        "Rank-biserial effects with bootstrap 95% CIs; all ",
        nrow(panel_a_source),
        " rows retained the expected direction; GSE72810 score Pearson r >= ",
        sprintf(
          "%.3f",
          minimum_gse72810_pearson
        )
      ),
    x = NULL,
    y =
      "Rank-biserial effect (bacterial versus viral)"
  ) +
  theme_bw(
    base_size = 9.3
  ) +
  theme(
    panel.grid.minor =
      element_blank(),
    panel.grid.major.y =
      element_blank(),
    strip.background =
      element_rect(
        fill = "grey95",
        colour = "grey50"
      ),
    strip.text =
      element_text(
        face = "bold",
        size = 9.2
      ),
    axis.text.y =
      element_text(
        size = 7.8,
        lineheight = 0.9,
        colour = "black"
      ),
    axis.text.x =
      element_text(
        size = 8,
        colour = "black"
      ),
    axis.title.x =
      element_text(
        size = 8.6
      ),
    plot.title =
      element_text(
        face = "bold",
        size = 11.4
      ),
    plot.subtitle =
      element_text(
        size = 8.2
      ),
    legend.position =
      "bottom",
    legend.box =
      "vertical",
    legend.title =
      element_text(
        face = "bold",
        size = 8.3
      ),
    legend.text =
      element_text(
        size = 7.5
      ),
    legend.key.height =
      unit(
        0.34,
        "cm"
      ),
    legend.key.width =
      unit(
        0.52,
        "cm"
      ),
    plot.margin =
      margin(
        4,
        8,
        2,
        4
      )
  ) +
  guides(
    colour = guide_legend(
      ncol = 2,
      byrow = TRUE
    ),
    fill = "none",
    shape = "none"
  )


# -------------------------------------------------------------------------
# Panel B plot
# -------------------------------------------------------------------------

panel_b_dodge <- position_dodge(
  width = 0.72
)

panel_b_plot <- ggplot(
  panel_b_source,
  aes(
    x = final_module_id,
    y = rank_biserial_effect,
    colour = scoring_method,
    fill = scoring_method,
    shape = reference_display,
    group = interaction(
      scoring_method,
      reference_display
    )
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    linewidth = 0.45,
    colour = "grey40"
  ) +
  geom_errorbar(
    aes(
      ymin = rank_biserial_ci_low,
      ymax = rank_biserial_ci_high
    ),
    position = panel_b_dodge,
    width = 0.14,
    linewidth = 0.68
  ) +
  geom_point(
    position = panel_b_dodge,
    size = 2.6,
    stroke = 0.75
  ) +
  scale_x_discrete(
    labels = module_labels
  ) +
  scale_y_continuous(
    limits = c(
      -1.05,
      1.05
    ),
    breaks = c(
      -1,
      -0.5,
      0,
      0.5,
      1
    )
  ) +
  scale_colour_manual(
    values = method_colours,
    name = "Scoring method"
  ) +
  scale_fill_manual(
    values = method_colours,
    name = "Scoring method"
  ) +
  scale_shape_manual(
    values = reference_shapes,
    name = "Z-reference"
  ) +
  coord_flip(
    clip = "off"
  ) +
  labs(
    title =
      "B  GSE73461 mean-z versus GSVA scoring-method sensitivity",
    subtitle =
      paste(
        "Rank-biserial effects with bootstrap 95% CIs;",
        "VIR_M2 loses support under GSVA, while BACT_M1 gains support"
      ),
    x = NULL,
    y =
      "Rank-biserial effect (bacterial versus viral)"
  ) +
  theme_bw(
    base_size = 9.3
  ) +
  theme(
    panel.grid.minor =
      element_blank(),
    panel.grid.major.y =
      element_blank(),
    axis.text.y =
      element_text(
        size = 7.8,
        lineheight = 0.9,
        colour = "black"
      ),
    axis.text.x =
      element_text(
        size = 8,
        colour = "black"
      ),
    axis.title.x =
      element_text(
        size = 8.6
      ),
    plot.title =
      element_text(
        face = "bold",
        size = 11.4
      ),
    plot.subtitle =
      element_text(
        size = 8.2
      ),
    legend.position =
      "bottom",
    legend.box =
      "horizontal",
    legend.title =
      element_text(
        face = "bold",
        size = 8.3
      ),
    legend.text =
      element_text(
        size = 7.5
      ),
    legend.key.height =
      unit(
        0.34,
        "cm"
      ),
    legend.key.width =
      unit(
        0.52,
        "cm"
      ),
    plot.margin =
      margin(
        4,
        8,
        2,
        4
      )
  ) +
  guides(
    colour = guide_legend(
      order = 1
    ),
    fill = "none",
    shape = guide_legend(
      order = 2
    )
  )


# -------------------------------------------------------------------------
# Panel C plot
# -------------------------------------------------------------------------

panel_c_dodge <- position_dodge(
  width = 0.68
)

panel_c_plot <- ggplot(
  panel_c_source,
  aes(
    x = final_module_id,
    y =
      minimum_pearson_correlation_with_full,
    colour = deletion_display,
    fill = deletion_display,
    shape = reference_display,
    group = interaction(
      deletion_display,
      reference_display
    )
  )
) +
  geom_hline(
    yintercept = 0.99,
    linetype = "dashed",
    linewidth = 0.45,
    colour = "grey40"
  ) +
  geom_point(
    position = panel_c_dodge,
    size = 2.8,
    stroke = 0.75
  ) +
  scale_x_discrete(
    labels = module_labels
  ) +
  scale_y_continuous(
    limits = c(
      0.99,
      1.0004
    ),
    breaks = c(
      0.990,
      0.992,
      0.994,
      0.996,
      0.998,
      1.000
    ),
    labels = function(values) {
      sprintf(
        "%.3f",
        values
      )
    }
  ) +
  scale_colour_manual(
    values = deletion_colours,
    name = "Deletion order"
  ) +
  scale_fill_manual(
    values = deletion_colours,
    name = "Deletion order"
  ) +
  scale_shape_manual(
    values = reference_shapes,
    name = "Z-reference"
  ) +
  coord_flip(
    clip = "off"
  ) +
  labs(
    title =
      "C  Exhaustive leave-one/two-gene robustness in GSE73461",
    subtitle =
      paste0(
        format(
          total_deletion_variants,
          big.mark = ",",
          scientific = FALSE
        ),
        " variants; 100% expected-direction retention; minimum Pearson r = ",
        sprintf(
          "%.4f",
          minimum_deletion_pearson
        )
      ),
    x = NULL,
    y =
      "Minimum correlation with complete-module score"
  ) +
  theme_bw(
    base_size = 9.3
  ) +
  theme(
    panel.grid.minor =
      element_blank(),
    panel.grid.major.y =
      element_blank(),
    axis.text.y =
      element_text(
        size = 7.8,
        lineheight = 0.9,
        colour = "black"
      ),
    axis.text.x =
      element_text(
        size = 8,
        colour = "black"
      ),
    axis.title.x =
      element_text(
        size = 8.6
      ),
    plot.title =
      element_text(
        face = "bold",
        size = 11.4
      ),
    plot.subtitle =
      element_text(
        size = 8.2
      ),
    legend.position =
      "bottom",
    legend.box =
      "horizontal",
    legend.title =
      element_text(
        face = "bold",
        size = 8.3
      ),
    legend.text =
      element_text(
        size = 7.5
      ),
    legend.key.height =
      unit(
        0.34,
        "cm"
      ),
    legend.key.width =
      unit(
        0.52,
        "cm"
      ),
    plot.margin =
      margin(
        4,
        8,
        4,
        4
      )
  ) +
  guides(
    colour = guide_legend(
      order = 1
    ),
    fill = "none",
    shape = guide_legend(
      order = 2
    )
  )


# -------------------------------------------------------------------------
# Validate built plot layers
# -------------------------------------------------------------------------

panel_a_build <- ggplot_build(
  panel_a_plot
)

panel_b_build <- ggplot_build(
  panel_b_plot
)

panel_c_build <- ggplot_build(
  panel_c_plot
)

panel_a_errorbar_rows <- nrow(
  panel_a_build$data[[2L]]
)

panel_a_point_rows <- nrow(
  panel_a_build$data[[3L]]
)

panel_b_errorbar_rows <- nrow(
  panel_b_build$data[[2L]]
)

panel_b_point_rows <- nrow(
  panel_b_build$data[[3L]]
)

panel_c_point_rows <- nrow(
  panel_c_build$data[[2L]]
)


# -------------------------------------------------------------------------
# Export composite figure
# -------------------------------------------------------------------------

message(
  "Exporting supplementary robustness figure..."
)

export_composite()


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
  ),
  panel_count =
    3L,
  file_exists =
    file.exists(
      c(
        figure_png,
        figure_svg,
        figure_pdf
      )
    )
)

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

figure_manifest[
  ,
  svg_path_elements :=
    c(
      NA_integer_,
      svg_path_count(
        figure_svg
      ),
      NA_integer_
    )
]

write_tsv(
  figure_manifest,
  figure_manifest_file
)


# -------------------------------------------------------------------------
# Figure caption
# -------------------------------------------------------------------------

caption_lines <- c(
  paste0(
    "# Supplementary Figure S1. Sensitivity and robustness of ",
    "locked host-response module transportability"
  ),
  "",
  paste(
    "**A, Z-reference, case-definition and probe-collapse",
    "sensitivities.** Rank-biserial bacterial-versus-viral effects",
    "and bootstrap 95% confidence intervals are shown for the two",
    "GSE73461 mean-z analyses and four GSE72810 analyses. All 30",
    "cohort-module estimates retained the expected direction.",
    "GSE72810 score concordance across the tested z-reference and",
    "probe-collapse representations remained high, with minimum",
    sprintf(
      "Pearson r = %.4f and minimum Spearman rho = %.4f.",
      minimum_gse72810_pearson,
      minimum_gse72810_spearman
    )
  ),
  "",
  paste(
    "**B, Mean-z versus GSVA scoring-method sensitivity in",
    "GSE73461.** Rank-biserial effects are displayed because they",
    "are comparable across scoring methods with different raw",
    "score scales. BACT_M2, VIR_M1a and VIR_M1b retained",
    "confidence-interval and BH-adjusted statistical support under",
    "both methods and z-reference populations. BACT_M1 was",
    "borderline under mean-z scoring but supported under GSVA.",
    "VIR_M2 retained a small viral-higher direction under GSVA but",
    "its confidence intervals included zero and its BH-adjusted",
    "P values were not significant. VIR_M2 is therefore described",
    "as scoring-method-sensitive."
  ),
  "",
  paste(
    "**C, Exhaustive leave-one/two-gene robustness in GSE73461.**",
    "Points show the minimum Pearson correlation between each",
    "deletion variant and the corresponding complete-module score.",
    "Across",
    format(
      total_deletion_variants,
      big.mark = ",",
      scientific = FALSE
    ),
    "variants, every leave-one and leave-two analysis retained the",
    "expected module direction. The minimum Pearson correlation was",
    sprintf(
      "%.4f and the minimum Spearman correlation was %.4f.",
      minimum_deletion_pearson,
      minimum_deletion_spearman
    )
  ),
  "",
  paste(
    "Positive rank-biserial effects indicate bacterial-higher",
    "scores and negative effects indicate viral-higher scores.",
    "These analyses evaluate robustness of the frozen modules and",
    "do not constitute gene reselection, module redefinition,",
    "diagnostic-model training or causal validation."
  )
)

writeLines(
  caption_lines,
  caption_file
)


# -------------------------------------------------------------------------
# Quality gate
# -------------------------------------------------------------------------

panel_a_numeric_valid <- all(
  is.finite(
    panel_a_source$
      rank_biserial_effect
  )
) &&
  all(
    is.finite(
      panel_a_source$
        rank_biserial_ci_low
    )
  ) &&
  all(
    is.finite(
      panel_a_source$
        rank_biserial_ci_high
    )
  )

panel_b_numeric_valid <- all(
  is.finite(
    panel_b_source$
      rank_biserial_effect
  )
) &&
  all(
    is.finite(
      panel_b_source$
        rank_biserial_ci_low
    )
  ) &&
  all(
    is.finite(
      panel_b_source$
        rank_biserial_ci_high
    )
  )

panel_c_numeric_valid <- all(
  is.finite(
    panel_c_source$
      minimum_pearson_correlation_with_full
  )
)

panel_a_bootstrap_valid <- all(
  panel_a_source$
    bootstrap_replicates ==
    expected_bootstrap_replicates
)

panel_b_bootstrap_valid <- all(
  panel_b_source$
    bootstrap_replicates ==
    expected_bootstrap_replicates
)

panel_b_wide_schema_valid <- all(
  required_panel_b_wide_columns %in%
    names(panel_b_wide)
)

vir_m2_method_sensitivity_valid <- all(
  panel_b_source[
    final_module_id ==
      "VIR_M2" &
      scoring_method ==
        "Mean-z",
    fdr_significant
  ]
) &&
  all(
    panel_b_source[
      final_module_id ==
        "VIR_M2" &
        scoring_method ==
          "GSVA",
      fdr_significant
    ] ==
      FALSE
  )

bact_m1_method_sensitivity_valid <- all(
  panel_b_source[
    final_module_id ==
      "BACT_M1" &
      scoring_method ==
        "Mean-z",
    fdr_significant
  ] ==
    FALSE
) &&
  all(
    panel_b_source[
      final_module_id ==
        "BACT_M1" &
        scoring_method ==
          "GSVA",
      fdr_significant
    ]
)

figure_files_valid <- all(
  file.exists(
    c(
      figure_png,
      figure_svg,
      figure_pdf
    )
  )
) &&
  all(
    file.info(
      c(
        figure_png,
        figure_svg,
        figure_pdf
      )
    )$size >
      0
  )

quality_checks <- data.table(
  check_id = sprintf(
    "Q%02d",
    seq_len(29L)
  ),
  check_description = c(
    "All six required input files are present",
    "Panel A contains 30 sensitivity-effect rows",
    "Panel B contains 20 mean-z and GSVA rows",
    "Panel B wide table contains ten module-population rows",
    "Panel C contains 20 deletion-summary rows",
    "All three panels contain the five locked modules",
    "Panel A estimates and confidence limits are finite",
    "Panel B estimates and confidence limits are finite",
    "Panel C minimum correlations are finite",
    "All Panel A rank-biserial values lie between minus one and one",
    "All Panel B rank-biserial values lie between minus one and one",
    "Every Panel A estimate retains the expected direction",
    "Every Panel B estimate retains the expected direction",
    "Every Panel A and Panel B row used 10,000 bootstrap replicates",
    "Panel A contains 24 FDR-supported rows",
    "Panel A contains 25 confidence intervals excluding zero",
    "Panel B contains 16 FDR-supported rows",
    "Panel B contains 16 confidence intervals excluding zero",
    "GSE72810 minimum sensitivity-score Pearson correlation is at least 0.987",
    "Panel B wide table contains the locked syntactic Mean_z and GSVA columns",
    "VIR_M2 is FDR-supported under mean-z but unsupported under GSVA",
    "BACT_M1 is FDR-borderline under mean-z but supported under GSVA",
    "The deletion audit contains exactly 29,826 variants",
    "All deletion variants preserve the expected direction",
    "All deletion variant counts match their expected counts",
    "The minimum deletion-variant Pearson correlation is at least 0.994",
    "Panel source TSVs contain 30, 20, 10 and 20 physical rows",
    "The composite plot contains all expected point and interval layers",
    "PNG, SVG and PDF files exist and the SVG contains no raster image"
  ),
  pass = c(
    all(
      file.exists(
        required_files
      )
    ),
    nrow(panel_a_source) ==
      expected_panel_a_rows,
    nrow(panel_b_source) ==
      expected_panel_b_rows,
    nrow(panel_b_wide) ==
      expected_panel_b_wide_rows,
    nrow(panel_c_source) ==
      expected_panel_c_rows,
    setequal(
      as.character(
        panel_a_source$
          final_module_id
      ),
      module_top_to_bottom
    ) &&
      setequal(
        as.character(
          panel_b_source$
            final_module_id
        ),
        module_top_to_bottom
      ) &&
      setequal(
        as.character(
          panel_c_source$
            final_module_id
        ),
        module_top_to_bottom
      ),
    panel_a_numeric_valid,
    panel_b_numeric_valid,
    panel_c_numeric_valid,
    all(
      panel_a_source$
        rank_biserial_effect >=
        -1
    ) &&
      all(
        panel_a_source$
          rank_biserial_effect <=
          1
      ),
    all(
      panel_b_source$
        rank_biserial_effect >=
        -1
    ) &&
      all(
        panel_b_source$
          rank_biserial_effect <=
          1
      ),
    all(
      panel_a_source$
        direction_retained
    ),
    all(
      panel_b_source$
        direction_retained
    ),
    panel_a_bootstrap_valid &&
      panel_b_bootstrap_valid,
    panel_a_fdr_count ==
      24L,
    panel_a_ci_support_count ==
      25L,
    panel_b_fdr_count ==
      16L,
    panel_b_ci_support_count ==
      16L,
    minimum_gse72810_pearson >=
      0.987,
    panel_b_wide_schema_valid,
    vir_m2_method_sensitivity_valid,
    bact_m1_method_sensitivity_valid,
    total_deletion_variants ==
      expected_deletion_variants,
    all_deletion_directions_preserved,
    all(
      panel_c_source$
        variant_count_match
    ),
    minimum_deletion_pearson >=
      0.994,
    panel_a_disk_rows ==
      expected_panel_a_rows &&
      panel_b_disk_rows ==
        expected_panel_b_rows &&
      panel_b_wide_disk_rows ==
        expected_panel_b_wide_rows &&
      panel_c_disk_rows ==
        expected_panel_c_rows,
    panel_a_errorbar_rows ==
      expected_panel_a_rows &&
      panel_a_point_rows ==
        expected_panel_a_rows &&
      panel_b_errorbar_rows ==
        expected_panel_b_rows &&
      panel_b_point_rows ==
        expected_panel_b_rows &&
      panel_c_point_rows ==
        expected_panel_c_rows,
    figure_files_valid &&
      !isTRUE(
        svg_contains_raster_image(
          figure_svg
        )
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
  panel_a_rows =
    nrow(panel_a_source),
  panel_b_rows =
    nrow(panel_b_source),
  panel_b_wide_rows =
    nrow(panel_b_wide),
  panel_c_rows =
    nrow(panel_c_source),
  panel_a_fdr_supported_rows =
    panel_a_fdr_count,
  panel_a_ci_supported_rows =
    panel_a_ci_support_count,
  panel_b_fdr_supported_rows =
    panel_b_fdr_count,
  panel_b_ci_supported_rows =
    panel_b_ci_support_count,
  method_discordant_rows =
    nrow(method_discordant_rows),
  deletion_variants =
    total_deletion_variants,
  deletion_direction_preserved_fraction =
    min(
      panel_c_source$
        expected_direction_preserved_fraction
    ),
  minimum_deletion_pearson =
    minimum_deletion_pearson,
  minimum_gse72810_sensitivity_pearson =
    minimum_gse72810_pearson,
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
  svg_path_elements =
    svg_path_count(
      figure_svg
    ),
  quality_gate =
    ifelse(
      quality_gate_pass,
      "PASS",
      "REVIEW"
    ),
  final_status =
    ifelse(
      quality_gate_pass,
      "READY_FOR_SUPPLEMENTARY_FIGURE_VISUAL_REVIEW",
      "SUPPLEMENTARY_ROBUSTNESS_FIGURE_REVIEW_REQUIRED"
    )
)

write_tsv(
  quality_checks,
  quality_gate_file
)

write_tsv(
  quality_summary,
  quality_summary_file
)


# -------------------------------------------------------------------------
# Report
# -------------------------------------------------------------------------

key_preview <- capture.output(
  print(key_findings)
)

method_preview <- capture.output(
  print(
    panel_b_wide[
      ,
      .(
        final_module_id,
        scoring_population,
        rank_biserial_effect_Mean_z,
        rank_biserial_effect_GSVA,
        wilcoxon_q_Mean_z,
        wilcoxon_q_GSVA,
        significance_discordant,
        method_interpretation
      )
    ]
  )
)

deletion_preview <- capture.output(
  print(
    panel_c_source[
      ,
      .(
        reference_display,
        final_module_id,
        deletion_display,
        observed_variant_count,
        expected_direction_preserved_fraction,
        minimum_pearson_correlation_with_full,
        maximum_wilcox_p
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
  "# Supplementary Figure S1 sensitivity and robustness report",
  "",
  "## Key findings",
  "",
  "```text",
  key_preview,
  "```",
  "",
  "## Mean-z versus GSVA comparison",
  "",
  "```text",
  method_preview,
  "```",
  "",
  "## Leave-one/two-gene robustness",
  "",
  "```text",
  deletion_preview,
  "```",
  "",
  "## Interpretation",
  "",
  paste(
    "The sensitivity analyses support stable module directions",
    "across z-reference, case-definition and probe-collapse choices."
  ),
  "",
  paste(
    "Scoring-method sensitivity is non-uniform. VIR_M2 loses",
    "statistical support under GSVA, whereas BACT_M1 gains support.",
    "These differences are reported directly rather than treating",
    "all scoring approaches as interchangeable."
  ),
  "",
  paste(
    "The exhaustive deletion audit supports distributed module",
    "signal because every variant retained the expected direction",
    "and remained highly correlated with the complete-module score.",
    "This does not establish causal sufficiency of individual genes."
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
    "- Final status: `",
    quality_summary$final_status,
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
  "===== SUPPLEMENTARY FIGURE S1 ROBUSTNESS PACKAGE =====\n"
)

cat(
  "panel_a_rows\t",
  nrow(panel_a_source),
  "\n",
  sep = ""
)

cat(
  "panel_b_rows\t",
  nrow(panel_b_source),
  "\n",
  sep = ""
)

cat(
  "panel_b_wide_rows\t",
  nrow(panel_b_wide),
  "\n",
  sep = ""
)

cat(
  "panel_c_rows\t",
  nrow(panel_c_source),
  "\n",
  sep = ""
)

cat(
  "panel_a_fdr_supported_rows\t",
  panel_a_fdr_count,
  "\n",
  sep = ""
)

cat(
  "panel_a_ci_supported_rows\t",
  panel_a_ci_support_count,
  "\n",
  sep = ""
)

cat(
  "panel_b_fdr_supported_rows\t",
  panel_b_fdr_count,
  "\n",
  sep = ""
)

cat(
  "panel_b_ci_supported_rows\t",
  panel_b_ci_support_count,
  "\n",
  sep = ""
)

cat(
  "method_discordant_rows\t",
  nrow(method_discordant_rows),
  "\n",
  sep = ""
)

cat(
  "deletion_variants\t",
  total_deletion_variants,
  "\n",
  sep = ""
)

cat(
  "minimum_deletion_pearson\t",
  minimum_deletion_pearson,
  "\n",
  sep = ""
)

cat(
  "minimum_gse72810_sensitivity_pearson\t",
  minimum_gse72810_pearson,
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
  "final_status\t",
  quality_summary$final_status,
  "\n",
  sep = ""
)

cat(
  "\nfigure_png\t",
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
    "Supplementary Figure S1 failed its quality gate."
  )
}
