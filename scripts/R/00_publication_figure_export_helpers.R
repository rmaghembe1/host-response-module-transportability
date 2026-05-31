# Publication-grade figure export helpers
# Standard: 1800 dpi PNG + editable SVG + vector PDF for each manuscript-facing figure.

save_publication_figure <- function(plot,
                                    filename_base,
                                    out_dir,
                                    width,
                                    height,
                                    dpi = 1800,
                                    units = "in") {
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }

  png_file <- file.path(out_dir, paste0(filename_base, ".png"))
  svg_file <- file.path(out_dir, paste0(filename_base, ".svg"))
  pdf_file <- file.path(out_dir, paste0(filename_base, ".pdf"))

  # PNG: high-resolution raster backup.
  ggplot2::ggsave(
    filename = png_file,
    plot = plot,
    width = width,
    height = height,
    units = units,
    dpi = dpi,
    bg = "white",
    limitsize = FALSE
  )

  # SVG: editable vector master.
  ggplot2::ggsave(
    filename = svg_file,
    plot = plot,
    width = width,
    height = height,
    units = units,
    bg = "white",
    limitsize = FALSE
  )

  # PDF: vector backup.
  ggplot2::ggsave(
    filename = pdf_file,
    plot = plot,
    width = width,
    height = height,
    units = units,
    device = cairo_pdf,
    bg = "white",
    limitsize = FALSE
  )

  invisible(data.frame(
    filename_base = filename_base,
    png_file = png_file,
    svg_file = svg_file,
    pdf_file = pdf_file,
    width = width,
    height = height,
    dpi = dpi
  ))
}
