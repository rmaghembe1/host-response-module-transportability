#!/usr/bin/env Rscript

# ============================================================================
# 57_GSE73461_revised_Figure2C_point_plot.R
#
# Purpose:
#   Regenerate manuscript Figure 2C in response to reviewer criticism of
#   connecting categorical module positions with a line.
#
# Design:
#   - Reuse the locked GSE73461 primary and primary-only sensitivity results.
#   - Do not rerun scoring or statistical tests.
#   - Plot BH-adjusted Wilcoxon P values as independent points.
#   - Preserve five locked modules and two analysis representations.
#   - Do not connect categorical modules with lines.
#   - Do not place a title/subtitle inside the panel; explanatory text belongs
#     in the manuscript Figure 2 legend.
#   - Write revision-specific outputs without overwriting historical figures.
# ============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

options(stringsAsFactors = FALSE)

# ----------------------------------------------------------------------------
# Paths
# ----------------------------------------------------------------------------

main_test_file <- paste0(
  "results/module_projection/GSE73461_fixed_module_projection/",
  "GSE73461_fixed_module_primary_projection_tests.tsv"
)

sens_test_file <- paste0(
  "results/module_projection/GSE73461_primary_only_zscore_sensitivity/",
  "GSE73461_primary_only_zscore_primary_projection_tests.tsv"
)

out_dir <- paste0(
  "results/revision_round1/",
  "GSE73461_revised_Figure2C"
)

fig_dir <- file.path(
  out_dir,
  "figures"
)

qa_file <- file.path(
  out_dir,
  "GSE73461_revised_Figure2C_quality_gate.tsv"
)

source_file <- file.path(
  out_dir,
  "GSE73461_revised_Figure2C_source_data.tsv"
)

report_file <- file.path(
  "docs/revision_round1/",
  "GSE73461_revised_Figure2C_report.md"
)

session_file <- file.path(
  "env/session_info/revision_round1/",
  "GSE73461_revised_Figure2C_sessionInfo.txt"
)

dir.create(
  out_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  fig_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  dirname(report_file),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  dirname(session_file),
  recursive = TRUE,
  showWarnings = FALSE
)

# ----------------------------------------------------------------------------
# Input checks
# ----------------------------------------------------------------------------

required_files <- c(
  main_test_file,
  sens_test_file
)

missing_files <- required_files[
  !file.exists(required_files)
]

if (length(missing_files) > 0L) {
  stop(
    paste(
      "Missing required input file(s):",
      paste(
        missing_files,
        collapse = ", "
      )
    )
  )
}

# ----------------------------------------------------------------------------
# Read locked statistical results
# ----------------------------------------------------------------------------

main_test <- fread(
  main_test_file
)

sens_test <- fread(
  sens_test_file
)

required_columns <- c(
  "final_module_id",
  "median_difference_bacterial_minus_viral",
  "wilcox_p_BH"
)

check_columns <- function(
  dt,
  label
) {

  missing_columns <- setdiff(
    required_columns,
    names(dt)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste0(
        label,
        " is missing required column(s): ",
        paste(
          missing_columns,
          collapse = ", "
        )
      )
    )
  }
}

check_columns(
  main_test,
  "Main projection table"
)

check_columns(
  sens_test,
  "Sensitivity table"
)

# ----------------------------------------------------------------------------
# Construct figure source data
# ----------------------------------------------------------------------------

main_plot <- main_test[
  ,
  .(
    final_module_id,
    median_difference_bacterial_minus_viral,
    wilcox_p_BH
  )
]

main_plot[
  ,
  analysis := "Main projection"
]

sens_plot <- sens_test[
  ,
  .(
    final_module_id,
    median_difference_bacterial_minus_viral,
    wilcox_p_BH
  )
]

sens_plot[
  ,
  analysis := "Primary-only z-score sensitivity"
]

plot_dt <- rbindlist(
  list(
    main_plot,
    sens_plot
  ),
  use.names = TRUE
)

module_order <- c(
  "BACT_M1",
  "BACT_M2",
  "VIR_M1a",
  "VIR_M1b",
  "VIR_M2"
)

analysis_order <- c(
  "Main projection",
  "Primary-only z-score sensitivity"
)

plot_dt[
  ,
  final_module_id := factor(
    final_module_id,
    levels = module_order
  )
]

plot_dt[
  ,
  analysis := factor(
    analysis,
    levels = analysis_order
  )
]

plot_dt[
  ,
  neg_log10_BH_P := -log10(
    wilcox_p_BH
  )
]

setorder(
  plot_dt,
  final_module_id,
  analysis
)

fwrite(
  plot_dt,
  source_file,
  sep = "\t"
)

# ----------------------------------------------------------------------------
# Quality checks before plotting
# ----------------------------------------------------------------------------

checks <- data.table(
  check_id = character(),
  description = character(),
  pass = logical(),
  observed = character(),
  expected = character()
)

add_check <- function(
  description,
  pass,
  observed,
  expected
) {

  checks <<- rbind(
    checks,
    data.table(
      check_id = sprintf(
        "Q%02d",
        nrow(checks) + 1L
      ),
      description = description,
      pass = isTRUE(pass),
      observed = as.character(observed),
      expected = as.character(expected)
    )
  )
}

add_check(
  "Main projection contains five module rows",
  nrow(main_plot) == 5L,
  nrow(main_plot),
  5L
)

add_check(
  "Sensitivity analysis contains five module rows",
  nrow(sens_plot) == 5L,
  nrow(sens_plot),
  5L
)

add_check(
  "Combined plot contains ten points",
  nrow(plot_dt) == 10L,
  nrow(plot_dt),
  10L
)

add_check(
  "Exactly five locked module identifiers are present",
  uniqueN(
    plot_dt$final_module_id
  ) == 5L,
  uniqueN(
    plot_dt$final_module_id
  ),
  5L
)

add_check(
  "Exactly two analysis representations are present",
  uniqueN(
    plot_dt$analysis
  ) == 2L,
  uniqueN(
    plot_dt$analysis
  ),
  2L
)

add_check(
  "All BH-adjusted P values are finite",
  all(
    is.finite(
      plot_dt$wilcox_p_BH
    )
  ),
  sum(
    is.finite(
      plot_dt$wilcox_p_BH
    )
  ),
  10L
)

add_check(
  "All BH-adjusted P values are greater than zero",
  all(
    plot_dt$wilcox_p_BH > 0
  ),
  min(
    plot_dt$wilcox_p_BH
  ),
  "> 0"
)

add_check(
  "All BH-adjusted P values are at most one",
  all(
    plot_dt$wilcox_p_BH <= 1
  ),
  max(
    plot_dt$wilcox_p_BH
  ),
  "<= 1"
)

add_check(
  "All transformed P values are finite",
  all(
    is.finite(
      plot_dt$neg_log10_BH_P
    )
  ),
  sum(
    is.finite(
      plot_dt$neg_log10_BH_P
    )
  ),
  10L
)

expected_modules <- sort(
  module_order
)

observed_modules <- sort(
  as.character(
    unique(
      plot_dt$final_module_id
    )
  )
)

add_check(
  "Module identities match the five locked modules",
  identical(
    observed_modules,
    expected_modules
  ),
  paste(
    observed_modules,
    collapse = ","
  ),
  paste(
    expected_modules,
    collapse = ","
  )
)

# ----------------------------------------------------------------------------
# Revised Figure 2C
# ----------------------------------------------------------------------------

dodge <- position_dodge(
  width = 0.45
)

p <- ggplot(
  plot_dt,
  aes(
    x = final_module_id,
    y = neg_log10_BH_P,
    shape = analysis
  )
) +
  geom_hline(
    yintercept = -log10(
      0.05
    ),
    linetype = "dashed",
    linewidth = 0.5
  ) +
  geom_point(
    position = dodge,
    size = 3.2,
    stroke = 0.8
  ) +
  labs(
    x = "Locked module",
    y = expression(
      -log[10](
        "BH-adjusted P"
      )
    ),
    shape = NULL
  ) +
  theme_bw(
    base_size = 11
  ) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )

# ----------------------------------------------------------------------------
# Figure outputs
# ----------------------------------------------------------------------------

png_file <- file.path(
  fig_dir,
  "Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.png"
)

pdf_file <- file.path(
  fig_dir,
  "Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.pdf"
)

svg_file <- file.path(
  fig_dir,
  "Figure_2C_GSE73461_adjusted_P_point_plot_revision_round1.svg"
)

ggsave(
  filename = png_file,
  plot = p,
  width = 8.5,
  height = 5.2,
  units = "in",
  dpi = 600
)

ggsave(
  filename = pdf_file,
  plot = p,
  width = 8.5,
  height = 5.2,
  units = "in"
)

svg_status <- TRUE
svg_message <- "SVG written"

tryCatch(
  {
    ggsave(
      filename = svg_file,
      plot = p,
      width = 8.5,
      height = 5.2,
      units = "in"
    )
  },
  error = function(e) {

    svg_status <<- FALSE

    svg_message <<- conditionMessage(
      e
    )
  }
)

# ----------------------------------------------------------------------------
# Output checks
# ----------------------------------------------------------------------------

add_check(
  "PNG figure was written",
  file.exists(
    png_file
  ) &&
    file.info(
      png_file
    )$size > 0,
  ifelse(
    file.exists(
      png_file
    ),
    file.info(
      png_file
    )$size,
    0
  ),
  "> 0 bytes"
)

add_check(
  "PDF figure was written",
  file.exists(
    pdf_file
  ) &&
    file.info(
      pdf_file
    )$size > 0,
  ifelse(
    file.exists(
      pdf_file
    ),
    file.info(
      pdf_file
    )$size,
    0
  ),
  "> 0 bytes"
)

add_check(
  "SVG figure was written",
  svg_status &&
    file.exists(
      svg_file
    ) &&
    file.info(
      svg_file
    )$size > 0,
  svg_message,
  "SVG written"
)

fwrite(
  checks,
  qa_file,
  sep = "\t"
)

quality_pass <- all(
  checks$pass
)

# ----------------------------------------------------------------------------
# Revision report
# ----------------------------------------------------------------------------

report_lines <- c(
  "# Revised GSE73461 Figure 2C",
  "",
  "## Purpose",
  "",
  paste0(
    "This revision replaces the categorical connected-line representation ",
    "of adjusted P values with independent points for each locked module ",
    "and analysis representation."
  ),
  "",
  paste0(
    "The revised panel contains no internal title or subtitle because ",
    "the explanatory description will be provided in the manuscript ",
    "Figure 2 legend."
  ),
  "",
  "No module scoring or statistical test was recomputed.",
  "",
  "## Inputs",
  "",
  paste0(
    "- `",
    main_test_file,
    "`"
  ),
  paste0(
    "- `",
    sens_test_file,
    "`"
  ),
  "",
  "## Plot design",
  "",
  "- Five locked modules are shown as categorical x-axis positions.",
  "- Each analysis contributes one independent point per module.",
  "- No line connects different modules.",
  "- Main and sensitivity analyses are distinguished by point shape.",
  "- The dashed horizontal reference denotes BH-adjusted P = 0.05.",
  "- The y-axis is -log10(BH-adjusted P).",
  "- No panel title or subtitle is embedded in the figure.",
  "",
  "## Outputs",
  "",
  paste0(
    "- `",
    png_file,
    "`"
  ),
  paste0(
    "- `",
    pdf_file,
    "`"
  ),
  paste0(
    "- `",
    svg_file,
    "`"
  ),
  paste0(
    "- `",
    source_file,
    "`"
  ),
  paste0(
    "- `",
    qa_file,
    "`"
  ),
  "",
  "## Quality gate",
  "",
  paste0(
    "- Checks passed: ",
    sum(
      checks$pass
    ),
    "/",
    nrow(
      checks
    ),
    "."
  ),
  paste0(
    "- Final status: `",
    ifelse(
      quality_pass,
      "READY_FOR_FIGURE_2C_VISUAL_REVIEW",
      "FIGURE_2C_REVIEW_REQUIRED"
    ),
    "`."
  ),
  ""
)

writeLines(
  report_lines,
  report_file
)

# ----------------------------------------------------------------------------
# Session information
# ----------------------------------------------------------------------------

writeLines(
  capture.output(
    sessionInfo()
  ),
  session_file
)

# ----------------------------------------------------------------------------
# Console summary
# ----------------------------------------------------------------------------

cat(
  "===== REVISED FIGURE 2C =====\n"
)

cat(
  "points\t",
  nrow(
    plot_dt
  ),
  "\n",
  sep = ""
)

cat(
  "modules\t",
  uniqueN(
    plot_dt$final_module_id
  ),
  "\n",
  sep = ""
)

cat(
  "analyses\t",
  uniqueN(
    plot_dt$analysis
  ),
  "\n",
  sep = ""
)

cat(
  "quality_checks_passed\t",
  sum(
    checks$pass
  ),
  "/",
  nrow(
    checks
  ),
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  ifelse(
    quality_pass,
    "PASS",
    "REVIEW"
  ),
  "\n",
  sep = ""
)

cat(
  "final_status\t",
  ifelse(
    quality_pass,
    "READY_FOR_FIGURE_2C_VISUAL_REVIEW",
    "FIGURE_2C_REVIEW_REQUIRED"
  ),
  "\n",
  sep = ""
)

cat(
  "png\t",
  png_file,
  "\n",
  sep = ""
)

cat(
  "pdf\t",
  pdf_file,
  "\n",
  sep = ""
)

cat(
  "svg\t",
  svg_file,
  "\n",
  sep = ""
)

if (!quality_pass) {
  stop(
    "Revised Figure 2C failed its quality gate."
  )
}
