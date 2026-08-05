#!/usr/bin/env Rscript

# GSVA package and interface feasibility audit
#
# Revision-stage technical audit.
#
# This script determines:
#   1. whether GSVA is installed;
#   2. the installed GSVA and BiocParallel versions;
#   3. whether the installed release uses the modern parameter-object API
#      or the legacy direct gsva() API;
#   4. the relevant constructor and gsva() function signatures;
#   5. whether a small outcome-independent synthetic GSVA calculation runs;
#   6. whether the environment is ready for locked-module GSVA scoring.
#
# This script does not use infection labels, alter module membership, select
# genes, or calculate study results.


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
# Required package
# -------------------------------------------------------------------------

if (!requireNamespace("data.table", quietly = TRUE)) {
  stop(
    paste(
      "The data.table package is required for the GSVA feasibility audit.",
      "Install data.table before rerunning this script."
    )
  )
}

suppressPackageStartupMessages({
  library(data.table)
})


# -------------------------------------------------------------------------
# Output paths
# -------------------------------------------------------------------------

out_dir <- paste0(
  "results/revision_round1/",
  "GSVA_package_interface_feasibility"
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

audit_file <- file.path(
  out_dir,
  "GSVA_package_interface_feasibility.tsv"
)

signature_file <- file.path(
  out_dir,
  "GSVA_interface_signature.txt"
)

synthetic_scores_file <- file.path(
  out_dir,
  "GSVA_synthetic_test_scores.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSVA_package_interface_feasibility_report.md"
)

session_file <- file.path(
  session_dir,
  "GSVA_package_interface_feasibility_sessionInfo.txt"
)


# -------------------------------------------------------------------------
# Prevent stale synthetic output
# -------------------------------------------------------------------------

if (file.exists(synthetic_scores_file)) {
  unlink(synthetic_scores_file)
}


# -------------------------------------------------------------------------
# Text-formatting helpers
# -------------------------------------------------------------------------

clean_text_lines <- function(lines) {
  lines <- as.character(lines)

  sub(
    "[[:space:]]+$",
    "",
    lines
  )
}

collapse_deparse <- function(x) {
  value <- paste(
    deparse(
      x,
      width.cutoff = 500L
    ),
    collapse = " "
  )

  value <- trimws(value)

  if (!nzchar(value)) {
    value <- "<required>"
  }

  value
}

function_formals_text <- function(fun) {
  fun_formals <- formals(fun)

  if (is.null(fun_formals)) {
    return("")
  }

  formal_names <- names(fun_formals)

  if (
    is.null(formal_names) ||
      length(formal_names) == 0L
  ) {
    return("")
  }

  formal_values <- vapply(
    fun_formals,
    collapse_deparse,
    FUN.VALUE = character(1)
  )

  paste(
    paste0(
      formal_names,
      " = ",
      formal_values
    ),
    collapse = "; "
  )
}

safe_package_version <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    return(NA_character_)
  }

  as.character(
    packageVersion(package_name)
  )
}

extract_score_matrix <- function(score_object) {
  if (is.matrix(score_object)) {
    return(score_object)
  }

  if (is.data.frame(score_object)) {
    return(
      as.matrix(score_object)
    )
  }

  if (
    inherits(
      score_object,
      "SummarizedExperiment"
    ) &&
      requireNamespace(
        "SummarizedExperiment",
        quietly = TRUE
      )
  ) {
    return(
      as.matrix(
        SummarizedExperiment::assay(
          score_object
        )
      )
    )
  }

  tryCatch(
    as.matrix(score_object),
    error = function(e) {
      NULL
    }
  )
}


# -------------------------------------------------------------------------
# Audit-table helper
# -------------------------------------------------------------------------

audit_rows <- list()
audit_index <- 0L

add_audit_row <- function(
  component,
  metric,
  value,
  status,
  detail = ""
) {
  audit_index <<- audit_index + 1L

  audit_rows[[audit_index]] <<- data.table(
    component = as.character(component),
    metric = as.character(metric),
    value = as.character(value),
    status = as.character(status),
    detail = as.character(detail)
  )

  invisible(NULL)
}


# -------------------------------------------------------------------------
# Package availability
# -------------------------------------------------------------------------

gsva_available <- requireNamespace(
  "GSVA",
  quietly = TRUE
)

biocparallel_available <- requireNamespace(
  "BiocParallel",
  quietly = TRUE
)

summarizedexperiment_available <- requireNamespace(
  "SummarizedExperiment",
  quietly = TRUE
)

add_audit_row(
  component = "package",
  metric = "GSVA_installed",
  value = gsva_available,
  status = ifelse(
    gsva_available,
    "PASS",
    "REVIEW"
  ),
  detail = ifelse(
    gsva_available,
    "GSVA namespace is available.",
    "GSVA is not installed in the active R library paths."
  )
)

add_audit_row(
  component = "package",
  metric = "BiocParallel_installed",
  value = biocparallel_available,
  status = ifelse(
    biocparallel_available,
    "PASS",
    "REVIEW"
  ),
  detail = ifelse(
    biocparallel_available,
    "BiocParallel namespace is available.",
    "BiocParallel is not available."
  )
)

add_audit_row(
  component = "package",
  metric = "SummarizedExperiment_installed",
  value = summarizedexperiment_available,
  status = ifelse(
    summarizedexperiment_available,
    "PASS",
    "INFORMATION"
  ),
  detail = paste(
    "SummarizedExperiment availability is recorded because some",
    "GSVA interfaces may accept or return container objects."
  )
)


# -------------------------------------------------------------------------
# Default audit values
# -------------------------------------------------------------------------

gsva_version <- NA_character_

biocparallel_version <- safe_package_version(
  "BiocParallel"
)

summarizedexperiment_version <- safe_package_version(
  "SummarizedExperiment"
)

interface_type <- "unavailable"

gsva_exported <- FALSE
gsva_param_exported <- FALSE
gsva_param_class_available <- FALSE

gsva_formals <- ""
gsva_param_formals <- ""
gsva_methods_text <- ""
gsva_exports_text <- ""

synthetic_test_attempted <- FALSE
synthetic_test_passed <- FALSE
synthetic_test_error <- ""

synthetic_score_class <- ""
synthetic_score_rows <- NA_integer_
synthetic_score_columns <- NA_integer_
synthetic_score_finite <- FALSE

synthetic_score_matrix <- NULL


# -------------------------------------------------------------------------
# Inspect GSVA namespace and interface
# -------------------------------------------------------------------------

if (gsva_available) {
  gsva_version <- as.character(
    packageVersion("GSVA")
  )

  gsva_namespace <- asNamespace(
    "GSVA"
  )

  gsva_exports <- sort(
    getNamespaceExports("GSVA")
  )

  gsva_exports_text <- paste(
    gsva_exports,
    collapse = "\n"
  )

  gsva_exported <- "gsva" %in% gsva_exports

  gsva_param_exported <- "gsvaParam" %in% gsva_exports

  gsva_param_class_available <- methods::isClass(
    "gsvaParam",
    where = gsva_namespace
  )

  if (gsva_param_exported) {
    interface_type <- "modern_parameter_object_api"
  } else if (gsva_exported) {
    interface_type <- "legacy_direct_api"
  } else {
    interface_type <- "unresolved_api"
  }

  if (gsva_exported) {
    gsva_fun <- getExportedValue(
      "GSVA",
      "gsva"
    )

    gsva_formals <- function_formals_text(
      gsva_fun
    )
  }

  if (gsva_param_exported) {
    gsva_param_fun <- getExportedValue(
      "GSVA",
      "gsvaParam"
    )

    gsva_param_formals <- function_formals_text(
      gsva_param_fun
    )
  }

  gsva_methods_text <- paste(
    tryCatch(
      capture.output(
        methods::showMethods(
          "gsva",
          where = gsva_namespace
        )
      ),
      error = function(e) {
        paste(
          "Unable to enumerate gsva methods:",
          conditionMessage(e)
        )
      }
    ),
    collapse = "\n"
  )
}


# -------------------------------------------------------------------------
# Record package versions and API inspection
# -------------------------------------------------------------------------

add_audit_row(
  component = "package",
  metric = "GSVA_version",
  value = gsva_version,
  status = ifelse(
    gsva_available,
    "PASS",
    "NOT_AVAILABLE"
  ),
  detail = "Installed GSVA package version."
)

add_audit_row(
  component = "package",
  metric = "BiocParallel_version",
  value = biocparallel_version,
  status = ifelse(
    biocparallel_available,
    "PASS",
    "NOT_AVAILABLE"
  ),
  detail = "Installed BiocParallel package version."
)

add_audit_row(
  component = "package",
  metric = "SummarizedExperiment_version",
  value = summarizedexperiment_version,
  status = ifelse(
    summarizedexperiment_available,
    "PASS",
    "NOT_AVAILABLE"
  ),
  detail = "Installed SummarizedExperiment package version."
)

add_audit_row(
  component = "interface",
  metric = "detected_GSVA_interface",
  value = interface_type,
  status = ifelse(
    interface_type %in% c(
      "modern_parameter_object_api",
      "legacy_direct_api"
    ),
    "PASS",
    "REVIEW"
  ),
  detail = paste(
    "Modern releases export gsvaParam(); older releases use the",
    "direct gsva(expression, geneSets, ...) interface."
  )
)

add_audit_row(
  component = "interface",
  metric = "gsva_exported",
  value = gsva_exported,
  status = ifelse(
    gsva_exported,
    "PASS",
    "REVIEW"
  ),
  detail = "Whether gsva() is exported from the GSVA namespace."
)

add_audit_row(
  component = "interface",
  metric = "gsvaParam_exported",
  value = gsva_param_exported,
  status = ifelse(
    gsva_param_exported,
    "PASS",
    "INFORMATION"
  ),
  detail = paste(
    "TRUE identifies the modern parameter-object interface;",
    "FALSE may indicate a legacy GSVA release."
  )
)

add_audit_row(
  component = "interface",
  metric = "gsvaParam_class_available",
  value = gsva_param_class_available,
  status = ifelse(
    gsva_param_class_available,
    "PASS",
    "INFORMATION"
  ),
  detail = "Whether the gsvaParam S4 class is registered."
)

add_audit_row(
  component = "interface",
  metric = "gsva_formals",
  value = gsva_formals,
  status = ifelse(
    nzchar(gsva_formals),
    "PASS",
    "REVIEW"
  ),
  detail = "Formal arguments of the exported gsva() function."
)

add_audit_row(
  component = "interface",
  metric = "gsvaParam_formals",
  value = gsva_param_formals,
  status = ifelse(
    gsva_param_exported &&
      nzchar(gsva_param_formals),
    "PASS",
    "INFORMATION"
  ),
  detail = paste(
    "Formal arguments of gsvaParam() when the modern API is",
    "available."
  )
)


# -------------------------------------------------------------------------
# Build outcome-independent synthetic input
# -------------------------------------------------------------------------

synthetic_expression <- matrix(
  c(
    8.1, 8.4, 8.7, 9.0, 9.3, 9.6,
    7.8, 8.0, 8.3, 8.6, 8.9, 9.1,
    9.5, 9.2, 8.9, 8.6, 8.3, 8.0,
    6.1, 6.3, 6.5, 6.7, 6.9, 7.1,
    5.9, 6.0, 6.2, 6.4, 6.6, 6.8,
    7.4, 7.1, 6.8, 6.5, 6.2, 5.9,
    8.8, 8.7, 8.6, 8.5, 8.4, 8.3,
    6.5, 6.8, 7.1, 7.4, 7.7, 8.0
  ),
  nrow = 8L,
  byrow = TRUE
)

rownames(synthetic_expression) <- paste0(
  "GENE_",
  seq_len(
    nrow(synthetic_expression)
  )
)

colnames(synthetic_expression) <- paste0(
  "SAMPLE_",
  seq_len(
    ncol(synthetic_expression)
  )
)

synthetic_gene_sets <- list(
  TEST_SET_A = c(
    "GENE_1",
    "GENE_2",
    "GENE_3"
  ),
  TEST_SET_B = c(
    "GENE_4",
    "GENE_5",
    "GENE_6",
    "GENE_7"
  )
)


# -------------------------------------------------------------------------
# Modern parameter-object synthetic test
# -------------------------------------------------------------------------

run_modern_synthetic_test <- function() {
  gsva_param_fun <- getExportedValue(
    "GSVA",
    "gsvaParam"
  )

  gsva_fun <- getExportedValue(
    "GSVA",
    "gsva"
  )

  param_formal_names <- names(
    formals(gsva_param_fun)
  )

  param_args <- list()

  if ("exprData" %in% param_formal_names) {
    param_args$exprData <- synthetic_expression
  } else if ("expr" %in% param_formal_names) {
    param_args$expr <- synthetic_expression
  } else {
    stop(
      paste(
        "The installed gsvaParam() constructor has neither",
        "exprData nor expr as a recognized formal argument."
      )
    )
  }

  if ("geneSets" %in% param_formal_names) {
    param_args$geneSets <- synthetic_gene_sets
  } else if ("gset.idx.list" %in% param_formal_names) {
    param_args$gset.idx.list <- synthetic_gene_sets
  } else {
    stop(
      paste(
        "The installed gsvaParam() constructor has neither",
        "geneSets nor gset.idx.list as a recognized formal argument."
      )
    )
  }

  if ("kcdf" %in% param_formal_names) {
    param_args$kcdf <- "Gaussian"
  }

  if ("minSize" %in% param_formal_names) {
    param_args$minSize <- 1L
  }

  if ("min.sz" %in% param_formal_names) {
    param_args$min.sz <- 1L
  }

  if ("maxSize" %in% param_formal_names) {
    param_args$maxSize <- Inf
  }

  if ("max.sz" %in% param_formal_names) {
    param_args$max.sz <- Inf
  }

  if ("tau" %in% param_formal_names) {
    param_args$tau <- 1
  }

  if ("maxDiff" %in% param_formal_names) {
    param_args$maxDiff <- TRUE
  }

  if ("absRanking" %in% param_formal_names) {
    param_args$absRanking <- FALSE
  }

  if ("sparse" %in% param_formal_names) {
    param_args$sparse <- FALSE
  }

  parameter_object <- do.call(
    gsva_param_fun,
    param_args
  )

  gsva_formal_names <- names(
    formals(gsva_fun)
  )

  gsva_call_args <- list(
    parameter_object
  )

  if (
    "verbose" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_call_args$verbose <- FALSE
  }

  if (
    biocparallel_available &&
      (
        "BPPARAM" %in% gsva_formal_names ||
          "..." %in% gsva_formal_names
      )
  ) {
    gsva_call_args$BPPARAM <- BiocParallel::SerialParam(
      progressbar = FALSE
    )
  }

  do.call(
    gsva_fun,
    gsva_call_args
  )
}


# -------------------------------------------------------------------------
# Legacy direct-API synthetic test
# -------------------------------------------------------------------------

run_legacy_synthetic_test <- function() {
  gsva_fun <- getExportedValue(
    "GSVA",
    "gsva"
  )

  gsva_formal_names <- names(
    formals(gsva_fun)
  )

  gsva_args <- list()

  if ("expr" %in% gsva_formal_names) {
    gsva_args$expr <- synthetic_expression
  } else {
    gsva_args[[1L]] <- synthetic_expression
  }

  if ("gset.idx.list" %in% gsva_formal_names) {
    gsva_args$gset.idx.list <- synthetic_gene_sets
  } else if ("geneSets" %in% gsva_formal_names) {
    gsva_args$geneSets <- synthetic_gene_sets
  } else {
    gsva_args[[length(gsva_args) + 1L]] <- synthetic_gene_sets
  }

  if (
    "method" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$method <- "gsva"
  }

  if (
    "kcdf" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$kcdf <- "Gaussian"
  }

  if (
    "min.sz" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$min.sz <- 1L
  }

  if (
    "max.sz" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$max.sz <- Inf
  }

  if (
    "verbose" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$verbose <- FALSE
  }

  if (
    "parallel.sz" %in% gsva_formal_names ||
      "..." %in% gsva_formal_names
  ) {
    gsva_args$parallel.sz <- 1L
  }

  do.call(
    gsva_fun,
    gsva_args
  )
}


# -------------------------------------------------------------------------
# Execute synthetic test
# -------------------------------------------------------------------------

if (
  gsva_available &&
    gsva_exported &&
    interface_type %in% c(
      "modern_parameter_object_api",
      "legacy_direct_api"
    )
) {
  synthetic_test_attempted <- TRUE

  synthetic_result <- tryCatch(
    {
      if (
        interface_type ==
          "modern_parameter_object_api"
      ) {
        run_modern_synthetic_test()
      } else {
        run_legacy_synthetic_test()
      }
    },
    error = function(e) {
      synthetic_test_error <<- conditionMessage(e)
      NULL
    }
  )

  if (!is.null(synthetic_result)) {
    synthetic_score_class <- paste(
      class(synthetic_result),
      collapse = ";"
    )

    synthetic_score_matrix <- extract_score_matrix(
      synthetic_result
    )

    if (!is.null(synthetic_score_matrix)) {
      synthetic_score_rows <- nrow(
        synthetic_score_matrix
      )

      synthetic_score_columns <- ncol(
        synthetic_score_matrix
      )

      synthetic_score_finite <- (
        length(synthetic_score_matrix) > 0L &&
          all(
            is.finite(
              synthetic_score_matrix
            )
          )
      )

      row_names_ok <- all(
        c(
          "TEST_SET_A",
          "TEST_SET_B"
        ) %in%
          rownames(
            synthetic_score_matrix
          )
      )

      column_names_ok <- all(
        colnames(synthetic_expression) %in%
          colnames(
            synthetic_score_matrix
          )
      )

      synthetic_test_passed <- (
        identical(
          synthetic_score_rows,
          2L
        ) &&
          identical(
            synthetic_score_columns,
            6L
          ) &&
          synthetic_score_finite &&
          row_names_ok &&
          column_names_ok
      )

      synthetic_scores_dt <- as.data.table(
        synthetic_score_matrix,
        keep.rownames = "gene_set"
      )

      fwrite(
        synthetic_scores_dt,
        synthetic_scores_file,
        sep = "\t",
        quote = FALSE,
        na = "NA"
      )
    } else {
      synthetic_test_error <- paste(
        "The synthetic GSVA call returned an object that could",
        "not be converted to a score matrix."
      )
    }
  }
}


# -------------------------------------------------------------------------
# Record synthetic-test audit
# -------------------------------------------------------------------------

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_test_attempted",
  value = synthetic_test_attempted,
  status = ifelse(
    synthetic_test_attempted,
    "PASS",
    "NOT_RUN"
  ),
  detail = paste(
    "The synthetic test uses artificial expression values and",
    "contains no study outcome information."
  )
)

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_test_passed",
  value = synthetic_test_passed,
  status = ifelse(
    synthetic_test_passed,
    "PASS",
    "REVIEW"
  ),
  detail = ifelse(
    synthetic_test_passed,
    paste(
      "GSVA returned a finite 2 by 6 score matrix with the",
      "expected gene-set and sample identifiers."
    ),
    synthetic_test_error
  )
)

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_result_class",
  value = synthetic_score_class,
  status = ifelse(
    nzchar(synthetic_score_class),
    "PASS",
    "NOT_AVAILABLE"
  ),
  detail = "Class of the object returned by the synthetic GSVA call."
)

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_score_rows",
  value = synthetic_score_rows,
  status = ifelse(
    identical(
      synthetic_score_rows,
      2L
    ),
    "PASS",
    "REVIEW"
  ),
  detail = "Expected number of synthetic gene-set score rows."
)

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_score_columns",
  value = synthetic_score_columns,
  status = ifelse(
    identical(
      synthetic_score_columns,
      6L
    ),
    "PASS",
    "REVIEW"
  ),
  detail = "Expected number of synthetic sample columns."
)

add_audit_row(
  component = "synthetic_test",
  metric = "synthetic_scores_all_finite",
  value = synthetic_score_finite,
  status = ifelse(
    synthetic_score_finite,
    "PASS",
    "REVIEW"
  ),
  detail = "Whether all synthetic GSVA scores are finite."
)


# -------------------------------------------------------------------------
# Overall readiness decision
# -------------------------------------------------------------------------

if (!gsva_available) {
  overall_status <- "REVIEW_GSVA_NOT_INSTALLED"

  readiness_detail <- paste(
    "The GSVA package is not installed in the active R",
    "environment. Install and re-audit GSVA before writing",
    "the study scoring script."
  )
} else if (!gsva_exported) {
  overall_status <- "REVIEW_GSVA_FUNCTION_NOT_EXPORTED"

  readiness_detail <- paste(
    "The GSVA package is installed, but gsva() was not found",
    "among its exported functions."
  )
} else if (
  !interface_type %in% c(
    "modern_parameter_object_api",
    "legacy_direct_api"
  )
) {
  overall_status <- "REVIEW_GSVA_INTERFACE_UNRESOLVED"

  readiness_detail <- paste(
    "The installed GSVA interface could not be classified as",
    "the modern parameter-object or legacy direct interface."
  )
} else if (!synthetic_test_passed) {
  overall_status <- "REVIEW_GSVA_SYNTHETIC_TEST_FAILED"

  readiness_detail <- paste(
    "The GSVA interface was detected, but the synthetic",
    "outcome-independent calculation did not pass."
  )
} else {
  overall_status <- "PASS_READY_FOR_GSVA_SCORING"

  readiness_detail <- paste(
    "GSVA is installed, its interface was resolved, and the",
    "synthetic outcome-independent calculation passed."
  )
}

add_audit_row(
  component = "overall",
  metric = "GSVA_scoring_readiness",
  value = overall_status,
  status = ifelse(
    overall_status ==
      "PASS_READY_FOR_GSVA_SCORING",
    "PASS",
    "REVIEW"
  ),
  detail = readiness_detail
)


# -------------------------------------------------------------------------
# Assemble and write audit table
# -------------------------------------------------------------------------

audit_table <- rbindlist(
  audit_rows,
  use.names = TRUE,
  fill = TRUE
)

fwrite(
  audit_table,
  audit_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Normalize empty error message
# -------------------------------------------------------------------------

signature_error_text <- synthetic_test_error

if (!nzchar(signature_error_text)) {
  signature_error_text <- "none"
}


# -------------------------------------------------------------------------
# Write interface signature without trailing whitespace
# -------------------------------------------------------------------------

signature_lines <- c(
  "===== GSVA PACKAGE AND INTERFACE SIGNATURE =====",
  "",
  paste0(
    "GSVA installed: ",
    gsva_available
  ),
  paste0(
    "GSVA version: ",
    gsva_version
  ),
  paste0(
    "BiocParallel installed: ",
    biocparallel_available
  ),
  paste0(
    "BiocParallel version: ",
    biocparallel_version
  ),
  paste0(
    "Detected interface: ",
    interface_type
  ),
  paste0(
    "gsva exported: ",
    gsva_exported
  ),
  paste0(
    "gsvaParam exported: ",
    gsva_param_exported
  ),
  paste0(
    "gsvaParam class available: ",
    gsva_param_class_available
  ),
  "",
  "===== gsva() FORMALS =====",
  gsva_formals,
  "",
  "===== gsvaParam() FORMALS =====",
  gsva_param_formals,
  "",
  "===== gsva METHODS =====",
  gsva_methods_text,
  "",
  "===== EXPORTED GSVA NAMESPACE OBJECTS =====",
  gsva_exports_text,
  "",
  "===== SYNTHETIC TEST =====",
  paste0(
    "Attempted: ",
    synthetic_test_attempted
  ),
  paste0(
    "Passed: ",
    synthetic_test_passed
  ),
  paste0(
    "Result class: ",
    synthetic_score_class
  ),
  paste0(
    "Score dimensions: ",
    synthetic_score_rows,
    " x ",
    synthetic_score_columns
  ),
  paste0(
    "All scores finite: ",
    synthetic_score_finite
  ),
  paste0(
    "Error: ",
    signature_error_text
  ),
  "",
  "===== OVERALL STATUS =====",
  overall_status,
  readiness_detail
)

signature_lines <- clean_text_lines(
  signature_lines
)

writeLines(
  signature_lines,
  signature_file
)


# -------------------------------------------------------------------------
# Write Markdown report without trailing whitespace
# -------------------------------------------------------------------------

report_lines <- c(
  "# GSVA package and interface feasibility audit",
  "",
  "## Purpose",
  "",
  paste(
    "This technical audit establishes the installed GSVA",
    "package version, identifies the supported function",
    "interface and tests a small outcome-independent",
    "synthetic calculation before study scoring."
  ),
  "",
  "No infection labels or study expression values were used.",
  "",
  "## Environment",
  "",
  paste0(
    "- GSVA installed: `",
    gsva_available,
    "`"
  ),
  paste0(
    "- GSVA version: `",
    gsva_version,
    "`"
  ),
  paste0(
    "- BiocParallel installed: `",
    biocparallel_available,
    "`"
  ),
  paste0(
    "- BiocParallel version: `",
    biocparallel_version,
    "`"
  ),
  paste0(
    "- Detected interface: `",
    interface_type,
    "`"
  ),
  "",
  "## Synthetic interface test",
  "",
  paste0(
    "- Test attempted: `",
    synthetic_test_attempted,
    "`"
  ),
  paste0(
    "- Test passed: `",
    synthetic_test_passed,
    "`"
  ),
  paste0(
    "- Returned object class: `",
    synthetic_score_class,
    "`"
  ),
  paste0(
    "- Score dimensions: `",
    synthetic_score_rows,
    " x ",
    synthetic_score_columns,
    "`"
  ),
  paste0(
    "- All scores finite: `",
    synthetic_score_finite,
    "`"
  ),
  paste0(
    "- Error message: `",
    signature_error_text,
    "`"
  ),
  "",
  "## Readiness decision",
  "",
  paste0(
    "**",
    overall_status,
    "**"
  ),
  "",
  readiness_detail,
  "",
  "## Interpretation boundary",
  "",
  paste(
    "Passing this audit establishes only that the installed",
    "GSVA software interface can calculate gene-set scores.",
    "It does not evaluate the biological performance of the",
    "submitted modules."
  ),
  "",
  "## Output files",
  "",
  paste0(
    "- `",
    audit_file,
    "`"
  ),
  paste0(
    "- `",
    signature_file,
    "`"
  ),
  paste0(
    "- `",
    synthetic_scores_file,
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
# Write session information without trailing whitespace
# -------------------------------------------------------------------------

session_lines <- capture.output(
  sessionInfo()
)

session_lines <- clean_text_lines(
  session_lines
)

writeLines(
  session_lines,
  session_file
)


# -------------------------------------------------------------------------
# Final quality gate
# -------------------------------------------------------------------------

audit_pass <- (
  gsva_available &&
    gsva_exported &&
    interface_type %in% c(
      "modern_parameter_object_api",
      "legacy_direct_api"
    ) &&
    synthetic_test_attempted &&
    synthetic_test_passed &&
    identical(
      synthetic_score_rows,
      2L
    ) &&
    identical(
      synthetic_score_columns,
      6L
    ) &&
    synthetic_score_finite &&
    file.exists(audit_file) &&
    file.exists(signature_file) &&
    file.exists(synthetic_scores_file) &&
    file.exists(report_file) &&
    file.exists(session_file)
)


# -------------------------------------------------------------------------
# Console summary
# -------------------------------------------------------------------------

cat(
  "===== GSVA PACKAGE AND INTERFACE FEASIBILITY AUDIT =====\n"
)

cat(
  "GSVA_installed\t",
  gsva_available,
  "\n",
  sep = ""
)

cat(
  "GSVA_version\t",
  gsva_version,
  "\n",
  sep = ""
)

cat(
  "BiocParallel_installed\t",
  biocparallel_available,
  "\n",
  sep = ""
)

cat(
  "BiocParallel_version\t",
  biocparallel_version,
  "\n",
  sep = ""
)

cat(
  "detected_interface\t",
  interface_type,
  "\n",
  sep = ""
)

cat(
  "synthetic_test_attempted\t",
  synthetic_test_attempted,
  "\n",
  sep = ""
)

cat(
  "synthetic_test_passed\t",
  synthetic_test_passed,
  "\n",
  sep = ""
)

cat(
  "synthetic_score_dimensions\t",
  synthetic_score_rows,
  "x",
  synthetic_score_columns,
  "\n",
  sep = ""
)

cat(
  "status\t",
  overall_status,
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  ifelse(
    audit_pass,
    "PASS",
    "REVIEW"
  ),
  "\n",
  sep = ""
)

cat(
  "audit_table\t",
  audit_file,
  "\n",
  sep = ""
)

cat(
  "interface_signature\t",
  signature_file,
  "\n",
  sep = ""
)

cat(
  "synthetic_scores\t",
  synthetic_scores_file,
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

if (!audit_pass) {
  stop(
    "GSVA feasibility audit failed its final quality gate."
  )
}
