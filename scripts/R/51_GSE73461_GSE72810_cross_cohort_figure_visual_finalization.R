#!/usr/bin/env Rscript

# =========================================================================
# GSE73461-GSE72810 cross-cohort figure visual finalization
# =========================================================================
#
# Purpose
#
# Regenerate the validated cross-cohort Hodges-Lehmann forest plot after
# visual review, without changing the analytical source tables.
#
# Final visual corrections
#
# 1. Display modules from top to bottom as:
#      BACT_M1
#      BACT_M2
#      VIR_M1a
#      VIR_M1b
#      VIR_M2
#
# 2. Remove the in-figure footer because the complete publication legend
#    is stored separately in the manuscript-facing caption file.
#
# 3. Preserve cohort colours, shapes, confidence intervals, zero-reference
#    line, title, subtitle, axis orientation and figure dimensions.
#
# This script must be run after:
#
# scripts/R/50_GSE73461_GSE72810_cross_cohort_validation_figure.R
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
      "Missing publication figure helper:",
      figure_helper
    )
  )
}

source(figure_helper)


# -------------------------------------------------------------------------
# Input and output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_GSE72810_cross_cohort_validation"
)

figure_dir <- file.path(
  out_dir,
  "figures"
)

source_data_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_primary_effect_size_source_data.tsv"
)

figure_manifest_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_figure_manifest.tsv"
)

visual_quality_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_visual_quality_gate.tsv"
)

visual_quality_summary_file <- file.path(
  out_dir,
  "GSE73461_GSE72810_cross_cohort_visual_quality_summary.tsv"
)

docs_dir <- "docs/revision_round1"
session_dir <- "env/session_info/revision_round1"

visual_report_file <- file.path(
  docs_dir,
  "GSE73461_GSE72810_cross_cohort_visual_finalization_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE73461_GSE72810_cross_cohort_visual_finalization_sessionInfo.txt"
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

unlink(
  c(
    visual_quality_file,
    visual_quality_summary_file,
    visual_report_file,
    session_file
  ),
  force = TRUE
)


# -------------------------------------------------------------------------
# Locked visual constants
# -------------------------------------------------------------------------

module_top_to_bottom <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

# With coord_flip(), discrete factor levels are displayed from bottom to
# top. Reversing the factor levels therefore produces the required
# top-to-bottom manuscript order.

module_factor_levels <- rev(
  module_top_to_bottom
)

cohort_order <- c(
  "GSE73461",
  "GSE72810"
)

expected_source_rows <- 10L
expected_modules <- 5L
expected_cohorts <- 2L

figure_width_inches <- 10.5
figure_height_inches <- 6.8
figure_dpi <- 1800L

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

cohort_display_labels <- c(
  GSE73461 =
    "GSE73461: GPL10558; 52 bacterial, 94 viral",
  GSE72810 =
    "GSE72810: GPL6947; 23 bacterial, 28 viral"
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


svg_path_count <- function(path) {
  if (!file.exists(path)) {
    return(NA_integer_)
  }

  svg_lines <- readLines(
    path,
    warn = FALSE,
    encoding = "UTF-8"
  )

  sum(
    lengths(
      gregexpr(
        "<path([[:space:]>])",
        svg_lines,
        ignore.case = TRUE,
        perl = TRUE
      )
    ) >
      0L
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


write_tsv <- function(
  table_object,
  output_file
) {
  output <- copy(table_object)

  character_columns <- names(output)[
    vapply(
      output,
      function(values) {
        is.character(values) ||
          is.factor(values)
      },
      FUN.VALUE = logical(1L)
    )
  ]

  for (column_name in character_columns) {
    set(
      output,
      j = column_name,
      value = clean_text(
        output[[column_name]]
      )
    )
  }

  fwrite(
    output,
    output_file,
    sep = "\t",
    quote = FALSE,
    na = "NA"
  )
}


# -------------------------------------------------------------------------
# Validate and read source data
# -------------------------------------------------------------------------

if (!file.exists(source_data_file)) {
  stop(
    paste(
      "Missing validated source-data table:",
      source_data_file
    )
  )
}

source_data <- fread(
  source_data_file
)

require_columns(
  source_data,
  c(
    "cohort_id",
    "cohort_label",
    "platform_id",
    "final_module_id",
    "final_module_label",
    "bacterial_n",
    "viral_n",
    "hodges_lehmann_shift_bacterial_minus_viral",
    "hodges_lehmann_ci_low",
    "hodges_lehmann_ci_high",
    "direction_retained"
  ),
  source_data_file
)

if (nrow(source_data) != expected_source_rows) {
  stop(
    paste(
      "Expected",
      expected_source_rows,
      "source-data rows but recovered",
      nrow(source_data)
    )
  )
}

if (
  uniqueN(
    source_data$final_module_id
  ) !=
    expected_modules
) {
  stop(
    "The source-data table does not contain five unique modules."
  )
}

if (
  uniqueN(
    source_data$cohort_id
  ) !=
    expected_cohorts
) {
  stop(
    "The source-data table does not contain two validation cohorts."
  )
}

if (
  !setequal(
    source_data$final_module_id,
    module_top_to_bottom
  )
) {
  stop(
    "The source-data table does not contain the expected locked modules."
  )
}

if (
  !setequal(
    source_data$cohort_id,
    cohort_order
  )
) {
  stop(
    "The source-data table does not contain the expected cohorts."
  )
}

numeric_columns <- c(
  "hodges_lehmann_shift_bacterial_minus_viral",
  "hodges_lehmann_ci_low",
  "hodges_lehmann_ci_high"
)

if (
  !all(
    vapply(
      source_data[
        ,
        ..numeric_columns
      ],
      function(values) {
        all(
          is.finite(values)
        )
      },
      FUN.VALUE = logical(1L)
    )
  )
) {
  stop(
    "At least one plotted estimate or confidence limit is not finite."
  )
}

if (
  any(
    source_data$
      hodges_lehmann_ci_low >
      source_data$
        hodges_lehmann_ci_high
  )
) {
  stop(
    "At least one confidence interval has reversed bounds."
  )
}


# -------------------------------------------------------------------------
# Prepare plot data
# -------------------------------------------------------------------------

plot_data <- copy(
  source_data
)

plot_data[
  ,
  final_module_id :=
    factor(
      final_module_id,
      levels = module_factor_levels
    )
]

plot_data[
  ,
  cohort_id :=
    factor(
      cohort_id,
      levels = cohort_order
    )
]

plot_data[
  ,
  cohort_label :=
    factor(
      unname(
        cohort_display_labels[
          as.character(cohort_id)
        ]
      ),
      levels = unname(
        cohort_display_labels[
          cohort_order
        ]
      )
    )
]

setorder(
  plot_data,
  final_module_id,
  cohort_id
)


# -------------------------------------------------------------------------
# Construct final forest plot
# -------------------------------------------------------------------------

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
    caption = NULL
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


# -------------------------------------------------------------------------
# Inspect built layers before export
# -------------------------------------------------------------------------

plot_build <- ggplot_build(
  forest_plot
)

built_layer_rows <- vapply(
  plot_build$data,
  nrow,
  FUN.VALUE = integer(1L)
)

errorbar_layer_rows <- built_layer_rows[2L]
point_layer_rows <- built_layer_rows[3L]

plot_caption_removed <- (
  is.null(
    forest_plot$labels$caption
  ) ||
    !nzchar(
      clean_text(
        forest_plot$labels$caption
      )
    )
)

factor_levels_correct <- identical(
  levels(
    plot_data$final_module_id
  ),
  module_factor_levels
)


# -------------------------------------------------------------------------
# Export final figure
# -------------------------------------------------------------------------

message(
  "Exporting final visually refined cross-cohort figure..."
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
# Regenerate figure manifest
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
  final_module_order_top_to_bottom =
    paste(
      module_top_to_bottom,
      collapse = ";"
    ),
  in_figure_footer_present =
    FALSE
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
# Visual quality gate
# -------------------------------------------------------------------------

figure_files_exist <- all(
  file.exists(
    c(
      figure_png,
      figure_svg,
      figure_pdf
    )
  )
)

figure_files_nonempty <- all(
  file.info(
    c(
      figure_png,
      figure_svg,
      figure_pdf
    )
  )$size >
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

visual_quality <- data.table(
  check_id = sprintf(
    "VQ%02d",
    seq_len(14L)
  ),
  check_description = c(
    "Validated source-data table is present",
    "Source-data table contains ten cohort-module rows",
    "Source-data table contains two cohorts",
    "Source-data table contains five locked modules",
    "All plotted estimates and confidence limits are finite",
    "All confidence-interval bounds are correctly ordered",
    "The plotting factor encodes the required top-to-bottom module order",
    "The in-figure footer has been removed",
    "The built forest plot contains ten confidence intervals",
    "The built forest plot contains ten point estimates",
    "PNG, SVG and PDF files were generated",
    "PNG, SVG and PDF files are non-empty",
    "The SVG contains no embedded raster image",
    "The figure manifest records the final visual configuration"
  ),
  pass = c(
    file.exists(
      source_data_file
    ),
    nrow(source_data) ==
      expected_source_rows,
    uniqueN(
      source_data$cohort_id
    ) ==
      expected_cohorts,
    uniqueN(
      source_data$final_module_id
    ) ==
      expected_modules,
    all(
      vapply(
        source_data[
          ,
          ..numeric_columns
        ],
        function(values) {
          all(
            is.finite(values)
          )
        },
        FUN.VALUE = logical(1L)
      )
    ),
    all(
      source_data$
        hodges_lehmann_ci_low <=
        source_data$
          hodges_lehmann_ci_high
    ),
    factor_levels_correct,
    plot_caption_removed,
    errorbar_layer_rows ==
      expected_source_rows,
    point_layer_rows ==
      expected_source_rows,
    figure_files_exist,
    figure_files_nonempty,
    svg_vector_only,
    file.exists(
      figure_manifest_file
    ) &&
      file_size_bytes(
        figure_manifest_file
      ) >
        0
  )
)

visual_quality_pass <- all(
  visual_quality$pass
)

visual_quality_summary <- data.table(
  total_checks =
    nrow(visual_quality),
  passed_checks =
    sum(visual_quality$pass),
  failed_checks =
    sum(!visual_quality$pass),
  source_rows =
    nrow(source_data),
  plotted_confidence_intervals =
    errorbar_layer_rows,
  plotted_point_estimates =
    point_layer_rows,
  top_to_bottom_module_order =
    paste(
      module_top_to_bottom,
      collapse = ";"
    ),
  in_figure_footer_present =
    !plot_caption_removed,
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
      visual_quality_pass,
      "PASS",
      "REVIEW"
    ),
  final_status =
    ifelse(
      visual_quality_pass,
      "READY_FOR_FINAL_VISUAL_CONFIRMATION_AND_COMMIT",
      "VISUAL_REFINEMENT_REVIEW_REQUIRED"
    )
)

write_tsv(
  visual_quality,
  visual_quality_file
)

write_tsv(
  visual_quality_summary,
  visual_quality_summary_file
)


# -------------------------------------------------------------------------
# Visual finalization report
# -------------------------------------------------------------------------

manifest_preview <- capture.output(
  print(figure_manifest)
)

quality_preview <- capture.output(
  print(visual_quality)
)

report_lines <- c(
  "# GSE73461-GSE72810 cross-cohort figure visual finalization",
  "",
  "## Final corrections",
  "",
  paste(
    "The displayed module order was changed to BACT_M1, BACT_M2,",
    "VIR_M1a, VIR_M1b and VIR_M2 from top to bottom."
  ),
  "",
  paste(
    "The in-figure footer was removed because the full interpretive",
    "legend is provided separately in the manuscript-facing figure",
    "caption."
  ),
  "",
  paste(
    "No analytical values, confidence intervals, P values, cohort",
    "definitions, colours, shapes or effect orientations were changed."
  ),
  "",
  "## Figure manifest",
  "",
  "```text",
  manifest_preview,
  "```",
  "",
  "## Automated visual-quality gate",
  "",
  "```text",
  quality_preview,
  "```",
  "",
  paste0(
    "- Quality gate: `",
    visual_quality_summary$
      quality_gate,
    "`."
  ),
  paste0(
    "- Final status: `",
    visual_quality_summary$
      final_status,
    "`."
  ),
  "",
  "## Required human confirmation",
  "",
  paste(
    "The final PNG or PDF should be inspected for label clipping,",
    "confidence-interval visibility, zero-line visibility, legend",
    "placement and overall balance before the package is committed."
  )
)

writeLines(
  report_lines,
  visual_report_file
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
  "===== CROSS-COHORT FIGURE VISUAL FINALIZATION =====\n"
)

cat(
  "source_rows\t",
  nrow(source_data),
  "\n",
  sep = ""
)

cat(
  "plotted_confidence_intervals\t",
  errorbar_layer_rows,
  "\n",
  sep = ""
)

cat(
  "plotted_point_estimates\t",
  point_layer_rows,
  "\n",
  sep = ""
)

cat(
  "top_to_bottom_module_order\t",
  paste(
    module_top_to_bottom,
    collapse = ";"
  ),
  "\n",
  sep = ""
)

cat(
  "in_figure_footer_present\t",
  !plot_caption_removed,
  "\n",
  sep = ""
)

cat(
  "svg_raster_image_elements\t",
  visual_quality_summary$
    svg_raster_image_elements,
  "\n",
  sep = ""
)

cat(
  "svg_path_elements\t",
  visual_quality_summary$
    svg_path_elements,
  "\n",
  sep = ""
)

cat(
  "visual_quality_checks_passed\t",
  sum(visual_quality$pass),
  "/",
  nrow(visual_quality),
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  visual_quality_summary$
    quality_gate,
  "\n",
  sep = ""
)

cat(
  "final_status\t",
  visual_quality_summary$
    final_status,
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
  "figure_manifest\t",
  figure_manifest_file,
  "\n",
  sep = ""
)

cat(
  "visual_quality_summary\t",
  visual_quality_summary_file,
  "\n",
  sep = ""
)

cat(
  "visual_report\t",
  visual_report_file,
  "\n",
  sep = ""
)

if (!visual_quality_pass) {
  stop(
    "The final cross-cohort figure failed its visual-quality gate."
  )
}
