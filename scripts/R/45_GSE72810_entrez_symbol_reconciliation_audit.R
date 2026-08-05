#!/usr/bin/env Rscript

# GSE72810 Entrez-authoritative locked-module reconciliation audit.
#
# Mapping hierarchy:
#   1. Accept probes carrying the exact locked-gene Entrez identifier.
#   2. When no Entrez-matched probe exists, accept an exact-symbol probe
#      only when that platform probe has no Entrez annotation.
#   3. Reject synonym-only probes assigned to a different Entrez gene.
#
# This script audits locked-module coverage. It does not calculate scores
# and does not select a single representative probe per gene.


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
# Input and output paths
# -------------------------------------------------------------------------

platform_file <- paste0(
  "data/metadata_raw/GSE72810/",
  "GPL6947_platform_table_from_GSE72810_family.tsv"
)

module_file <- paste0(
  "results/module_scoring/GSE211567_projection_ready_inputs/",
  "GSE211567_projection_ready_module_gene_table.tsv"
)

matrix_id_file <- paste0(
  "work/plosone_revision_round1_2026/",
  "phaseR1D2B_GSE72810_structure_audit/",
  "GSE72810_matrix_probe_IDs_sorted.txt"
)

symbol_coverage_file <- paste0(
  "results/revision_round1/",
  "GSE72810_candidate_validation_audit/",
  "GSE72810_locked_module_gene_coverage.tsv"
)

out_dir <- paste0(
  "results/revision_round1/",
  "GSE72810_candidate_validation_audit"
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

mapping_file <- file.path(
  out_dir,
  "GSE72810_locked_module_gene_mapping_entrez_reconciled.tsv"
)

coverage_file <- file.path(
  out_dir,
  "GSE72810_locked_module_coverage_entrez_reconciled.tsv"
)

conflict_file <- file.path(
  out_dir,
  "GSE72810_mapping_conflicts_and_unsafe_aliases.tsv"
)

comparison_file <- file.path(
  out_dir,
  "GSE72810_symbol_vs_entrez_coverage_comparison.tsv"
)

decision_file <- file.path(
  out_dir,
  "GSE72810_entrez_reconciliation_decision.tsv"
)

report_file <- file.path(
  docs_dir,
  "GSE72810_entrez_reconciliation_audit_report.md"
)

session_file <- file.path(
  session_dir,
  "GSE72810_entrez_reconciliation_sessionInfo.txt"
)

output_files <- c(
  mapping_file,
  coverage_file,
  conflict_file,
  comparison_file,
  decision_file,
  report_file,
  session_file
)

unlink(
  output_files,
  force = TRUE
)


# -------------------------------------------------------------------------
# Expected specification
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

expected_matrix_probe_count <- 48803L

minimum_primary_coverage <- 0.50

minimum_high_coverage <- 0.70


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


split_symbol_tokens <- function(value) {
  value <- as.character(value)

  if (
    length(value) == 0L ||
      is.na(value) ||
      !nzchar(trimws(value))
  ) {
    return(character())
  }

  tokens <- unlist(
    strsplit(
      value,
      "[;,|/]+",
      perl = TRUE
    ),
    use.names = FALSE
  )

  tokens <- toupper(
    trimws(tokens)
  )

  tokens <- tokens[
    nzchar(tokens) &
      !tokens %in% c(
        "NA",
        "---",
        "NULL"
      )
  ]

  unique(tokens)
}


extract_entrez_tokens <- function(value) {
  value <- as.character(value)

  if (
    length(value) == 0L ||
      is.na(value) ||
      !nzchar(trimws(value))
  ) {
    return(character())
  }

  matches <- gregexpr(
    "[0-9]+",
    value,
    perl = TRUE
  )

  tokens <- regmatches(
    value,
    matches
  )[[1L]]

  tokens <- tokens[
    nzchar(tokens)
  ]

  unique(tokens)
}


build_token_map <- function(
  probe_ids,
  token_lists,
  token_column
) {
  token_lengths <- lengths(
    token_lists
  )

  if (sum(token_lengths) == 0L) {
    empty_table <- data.table(
      ID_REF = character(),
      TOKEN = character()
    )

    setnames(
      empty_table,
      "TOKEN",
      token_column
    )

    return(empty_table)
  }

  token_table <- data.table(
    ID_REF = rep(
      probe_ids,
      token_lengths
    ),
    TOKEN = unlist(
      token_lists,
      use.names = FALSE
    )
  )

  setnames(
    token_table,
    "TOKEN",
    token_column
  )

  unique(token_table)
}


collapse_values <- function(
  values,
  empty_value = "none"
) {
  values <- unique(
    as.character(values)
  )

  values <- values[
    !is.na(values) &
      nzchar(values)
  ]

  if (length(values) == 0L) {
    return(empty_value)
  }

  paste(
    sort(values),
    collapse = ";"
  )
}


make_conflict_rows <- function(
  module_id,
  requested_symbol,
  requested_entrez,
  platform_rows,
  conflict_type
) {
  if (nrow(platform_rows) == 0L) {
    return(NULL)
  }

  data.table(
    final_module_id = module_id,
    requested_symbol = requested_symbol,
    requested_entrez = requested_entrez,
    probe_id = platform_rows$ID,
    platform_symbol = platform_rows$Symbol,
    platform_synonyms = platform_rows$Synonyms,
    platform_ilmn_gene = platform_rows$ILMN_Gene,
    platform_entrez = platform_rows$Entrez_Gene_ID,
    conflict_type = conflict_type
  )
}


# -------------------------------------------------------------------------
# Validate input files
# -------------------------------------------------------------------------

required_files <- c(
  platform_file,
  module_file,
  matrix_id_file,
  symbol_coverage_file
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
# Read matrix probe inventory
# -------------------------------------------------------------------------

message(
  "Reading GSE72810 matrix probe inventory..."
)

matrix_ids <- fread(
  matrix_id_file,
  header = FALSE,
  col.names = "ID"
)

matrix_ids[
  ,
  ID := as.character(ID)
]

if (nrow(matrix_ids) != expected_matrix_probe_count) {
  stop(
    paste(
      "Expected",
      expected_matrix_probe_count,
      "matrix probes but recovered",
      nrow(matrix_ids)
    )
  )
}

if (anyDuplicated(matrix_ids$ID)) {
  stop(
    "The matrix probe inventory contains duplicated probe IDs."
  )
}


# -------------------------------------------------------------------------
# Read and restrict GPL6947 annotation
# -------------------------------------------------------------------------

message(
  "Reading GPL6947 platform annotation..."
)

platform_all <- fread(
  platform_file,
  quote = "",
  na.strings = c(
    "",
    "NA",
    "---"
  )
)

require_columns(
  platform_all,
  c(
    "ID",
    "Symbol",
    "Synonyms",
    "ILMN_Gene",
    "Entrez_Gene_ID"
  ),
  platform_file
)

platform_all[
  ,
  ID := as.character(ID)
]

platform_all[
  ,
  Symbol := as.character(Symbol)
]

platform_all[
  ,
  Synonyms := as.character(Synonyms)
]

platform_all[
  ,
  ILMN_Gene := as.character(ILMN_Gene)
]

platform_all[
  ,
  Entrez_Gene_ID :=
    as.character(Entrez_Gene_ID)
]

if (anyDuplicated(platform_all$ID)) {
  stop(
    "GPL6947 contains duplicated platform probe IDs."
  )
}

platform_index <- match(
  matrix_ids$ID,
  platform_all$ID
)

if (anyNA(platform_index)) {
  stop(
    "At least one processed matrix probe is absent from GPL6947."
  )
}

platform <- platform_all[
  platform_index
]

if (
  nrow(platform) != expected_matrix_probe_count ||
    !identical(
      platform$ID,
      matrix_ids$ID
    )
) {
  stop(
    "Matrix-to-platform probe reconstruction failed."
  )
}


# -------------------------------------------------------------------------
# Tokenize platform annotations
# -------------------------------------------------------------------------

message(
  "Constructing exact-symbol, alias and Entrez probe maps..."
)

platform[
  ,
  symbol_tokens :=
    lapply(
      Symbol,
      split_symbol_tokens
    )
]

platform[
  ,
  alias_tokens :=
    Map(
      function(
        synonyms_value,
        ilmn_gene_value
      ) {
        unique(
          c(
            split_symbol_tokens(
              synonyms_value
            ),
            split_symbol_tokens(
              ilmn_gene_value
            )
          )
        )
      },
      Synonyms,
      ILMN_Gene
    )
]

platform[
  ,
  entrez_tokens :=
    lapply(
      Entrez_Gene_ID,
      extract_entrez_tokens
    )
]

symbol_map <- build_token_map(
  platform$ID,
  platform$symbol_tokens,
  "SYMBOL_UPPER"
)

alias_map <- build_token_map(
  platform$ID,
  platform$alias_tokens,
  "ALIAS_UPPER"
)

entrez_map <- build_token_map(
  platform$ID,
  platform$entrez_tokens,
  "ENTREZID_CANONICAL"
)


# -------------------------------------------------------------------------
# Read locked module genes
# -------------------------------------------------------------------------

message(
  "Reading locked module genes and Entrez identifiers..."
)

modules_raw <- fread(
  module_file
)

require_columns(
  modules_raw,
  c(
    "final_module_id",
    "final_module_label",
    "module_direction",
    "ENTREZID",
    "SYMBOL"
  ),
  module_file
)

modules_raw[
  ,
  final_module_id :=
    as.character(final_module_id)
]

modules_raw[
  ,
  final_module_label :=
    as.character(final_module_label)
]

modules_raw[
  ,
  module_direction :=
    as.character(module_direction)
]

modules_raw[
  ,
  SYMBOL :=
    trimws(
      as.character(SYMBOL)
    )
]

modules_raw[
  ,
  SYMBOL_UPPER :=
    toupper(SYMBOL)
]

modules_raw[
  ,
  ENTREZID_RAW :=
    as.character(ENTREZID)
]

modules_raw[
  ,
  ENTREZ_TOKENS :=
    lapply(
      ENTREZID_RAW,
      extract_entrez_tokens
    )
]

invalid_module_entrez <- modules_raw[
  final_module_id %in%
    expected_module_ids &
    lengths(ENTREZ_TOKENS) != 1L
]

if (nrow(invalid_module_entrez) > 0L) {
  print(
    invalid_module_entrez[
      ,
      .(
        final_module_id,
        SYMBOL,
        ENTREZID_RAW
      )
    ]
  )

  stop(
    paste(
      "At least one locked module gene lacks exactly",
      "one usable Entrez identifier."
    )
  )
}

modules_raw[
  ,
  ENTREZID_CANONICAL :=
    vapply(
      ENTREZ_TOKENS,
      function(tokens) {
        tokens[1L]
      },
      character(1)
    )
]

modules <- unique(
  modules_raw[
    final_module_id %in%
      expected_module_ids,
    .(
      final_module_id,
      final_module_label,
      module_direction,
      SYMBOL,
      SYMBOL_UPPER,
      ENTREZID_CANONICAL
    )
  ]
)

if (
  anyDuplicated(
    modules[
      ,
      .(
        final_module_id,
        SYMBOL_UPPER
      )
    ]
  )
) {
  stop(
    "Duplicated locked module-gene keys were detected."
  )
}

locked_count_check <- modules[
  ,
  .(
    observed_locked_gene_count = .N
  ),
  by = final_module_id
]

locked_count_check <- merge(
  expected_locked_counts,
  locked_count_check,
  by = "final_module_id",
  all = TRUE
)

locked_count_check[
  ,
  count_match :=
    expected_locked_gene_count ==
      observed_locked_gene_count
]

if (
  nrow(locked_count_check) != 5L ||
    !all(
      locked_count_check$count_match
    )
) {
  print(locked_count_check)

  stop(
    "Locked module gene counts do not match the specification."
  )
}

if (nrow(modules) != 313L) {
  stop(
    paste(
      "Expected 313 locked module-gene instances but recovered",
      nrow(modules)
    )
  )
}


# -------------------------------------------------------------------------
# Reconcile every locked module-gene instance
# -------------------------------------------------------------------------

message(
  "Reconciling locked genes against GPL6947..."
)

mapping_rows <- vector(
  "list",
  nrow(modules)
)

conflict_rows <- list()

conflict_index <- 0L

for (module_row in seq_len(
  nrow(modules)
)) {
  module_id <-
    modules$final_module_id[module_row]

  module_label <-
    modules$final_module_label[module_row]

  module_direction <-
    modules$module_direction[module_row]

  requested_symbol <-
    modules$SYMBOL[module_row]

  requested_symbol_upper <-
    modules$SYMBOL_UPPER[module_row]

  requested_entrez <-
    modules$ENTREZID_CANONICAL[module_row]

  exact_entrez_probe_ids <- unique(
    entrez_map[
      ENTREZID_CANONICAL ==
        requested_entrez,
      ID_REF
    ]
  )

  exact_symbol_probe_ids <- unique(
    symbol_map[
      SYMBOL_UPPER ==
        requested_symbol_upper,
      ID_REF
    ]
  )

  alias_probe_ids <- unique(
    alias_map[
      ALIAS_UPPER ==
        requested_symbol_upper,
      ID_REF
    ]
  )

  exact_symbol_platform <- platform[
    ID %in%
      exact_symbol_probe_ids
  ]

  exact_symbol_entrez_match <- vapply(
    exact_symbol_platform$entrez_tokens,
    function(tokens) {
      requested_entrez %in% tokens
    },
    logical(1)
  )

  exact_symbol_entrez_blank <- (
    lengths(
      exact_symbol_platform$entrez_tokens
    ) == 0L
  )

  exact_symbol_entrez_conflict <- (
    lengths(
      exact_symbol_platform$entrez_tokens
    ) > 0L &
      !exact_symbol_entrez_match
  )

  blank_entrez_exact_symbol_ids <-
    exact_symbol_platform[
      exact_symbol_entrez_blank,
      ID
    ]

  conflicting_exact_symbol_ids <-
    exact_symbol_platform[
      exact_symbol_entrez_conflict,
      ID
    ]

  exact_entrez_symbol_overlap <- intersect(
    exact_entrez_probe_ids,
    exact_symbol_probe_ids
  )

  accepted_probe_ids <- character()

  mapping_rule <- "UNMAPPED"

  rescued_by_entrez <- FALSE

  if (length(exact_entrez_probe_ids) > 0L) {
    accepted_probe_ids <-
      exact_entrez_probe_ids

    if (
      length(
        exact_entrez_symbol_overlap
      ) > 0L
    ) {
      mapping_rule <-
        "EXACT_ENTREZ_WITH_EXACT_SYMBOL_SUPPORT"
    } else {
      mapping_rule <-
        "EXACT_ENTREZ_HISTORICAL_OR_ALTERNATE_SYMBOL"

      rescued_by_entrez <- TRUE
    }
  } else if (
    length(
      blank_entrez_exact_symbol_ids
    ) > 0L
  ) {
    accepted_probe_ids <-
      blank_entrez_exact_symbol_ids

    mapping_rule <-
      "EXACT_SYMBOL_PLATFORM_ENTREZ_MISSING"
  } else if (
    length(exact_symbol_probe_ids) > 0L
  ) {
    mapping_rule <-
      "EXACT_SYMBOL_WITH_CONFLICTING_ENTREZ_NOT_ACCEPTED"
  }

  accepted_probe_ids <- sort(
    unique(
      accepted_probe_ids
    )
  )

  accepted_platform <- platform[
    ID %in%
      accepted_probe_ids
  ]

  alias_only_probe_ids <- setdiff(
    alias_probe_ids,
    union(
      exact_entrez_probe_ids,
      exact_symbol_probe_ids
    )
  )

  if (
    length(
      conflicting_exact_symbol_ids
    ) > 0L
  ) {
    conflict_index <-
      conflict_index + 1L

    conflict_rows[[conflict_index]] <-
      make_conflict_rows(
        module_id = module_id,
        requested_symbol =
          requested_symbol,
        requested_entrez =
          requested_entrez,
        platform_rows = platform[
          ID %in%
            conflicting_exact_symbol_ids
        ],
        conflict_type =
          "EXACT_SYMBOL_CONFLICTING_ENTREZ"
      )
  }

  if (
    length(alias_only_probe_ids) > 0L
  ) {
    conflict_index <-
      conflict_index + 1L

    conflict_rows[[conflict_index]] <-
      make_conflict_rows(
        module_id = module_id,
        requested_symbol =
          requested_symbol,
        requested_entrez =
          requested_entrez,
        platform_rows = platform[
          ID %in%
            alias_only_probe_ids
        ],
        conflict_type =
          "SYNONYM_ONLY_NOT_ACCEPTED"
      )
  }

  mapping_rows[[module_row]] <- data.table(
    final_module_id =
      module_id,
    final_module_label =
      module_label,
    module_direction =
      module_direction,
    requested_symbol =
      requested_symbol,
    requested_entrez =
      requested_entrez,
    exact_entrez_probe_count =
      length(
        exact_entrez_probe_ids
      ),
    exact_symbol_probe_count =
      length(
        exact_symbol_probe_ids
      ),
    alias_probe_count =
      length(
        alias_probe_ids
      ),
    accepted_probe_count =
      length(
        accepted_probe_ids
      ),
    mapped =
      length(
        accepted_probe_ids
      ) > 0L,
    mapping_rule =
      mapping_rule,
    rescued_by_entrez =
      rescued_by_entrez,
    accepted_probe_ids =
      collapse_values(
        accepted_probe_ids
      ),
    accepted_platform_symbols =
      collapse_values(
        accepted_platform$Symbol
      ),
    accepted_platform_entrez =
      collapse_values(
        accepted_platform$
          Entrez_Gene_ID
      ),
    exact_symbol_probe_ids =
      collapse_values(
        exact_symbol_probe_ids
      ),
    alias_probe_ids =
      collapse_values(
        alias_probe_ids
      ),
    alias_platform_symbols =
      collapse_values(
        platform[
          ID %in%
            alias_probe_ids,
          Symbol
        ]
      ),
    alias_platform_entrez =
      collapse_values(
        platform[
          ID %in%
            alias_probe_ids,
          Entrez_Gene_ID
        ]
      )
  )
}

mapping <- rbindlist(
  mapping_rows,
  use.names = TRUE,
  fill = TRUE
)

mapping[
  ,
  module_order := match(
    final_module_id,
    expected_module_ids
  )
]

setorder(
  mapping,
  module_order,
  requested_symbol
)

mapping[
  ,
  module_order := NULL
]

if (nrow(mapping) != 313L) {
  stop(
    "The reconciliation table does not contain 313 rows."
  )
}


# -------------------------------------------------------------------------
# Assemble conflict and rejected-alias table
# -------------------------------------------------------------------------

if (length(conflict_rows) > 0L) {
  conflicts <- rbindlist(
    conflict_rows,
    use.names = TRUE,
    fill = TRUE
  )

  conflicts[
    ,
    module_order := match(
      final_module_id,
      expected_module_ids
    )
  ]

  setorder(
    conflicts,
    module_order,
    requested_symbol,
    conflict_type,
    probe_id
  )

  conflicts[
    ,
    module_order := NULL
  ]
} else {
  conflicts <- data.table(
    final_module_id = character(),
    requested_symbol = character(),
    requested_entrez = character(),
    probe_id = character(),
    platform_symbol = character(),
    platform_synonyms = character(),
    platform_ilmn_gene = character(),
    platform_entrez = character(),
    conflict_type = character()
  )
}


# -------------------------------------------------------------------------
# Calculate reconciled module coverage
# -------------------------------------------------------------------------

coverage <- mapping[
  ,
  {
    missing_genes <- sort(
      requested_symbol[
        !mapped
      ]
    )

    rescued_genes <- sort(
      requested_symbol[
        rescued_by_entrez
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
      accepted_probe_count =
        sum(
          accepted_probe_count
        ),
      genes_rescued_by_entrez =
        sum(
          rescued_by_entrez
        ),
      rescued_symbols =
        if (
          length(rescued_genes) == 0L
        ) {
          "none"
        } else {
          paste(
            rescued_genes,
            collapse = ";"
          )
        },
      missing_symbols =
        if (
          length(missing_genes) == 0L
        ) {
          "none"
        } else {
          paste(
            missing_genes,
            collapse = ";"
          )
        }
    )
  },
  by = .(
    final_module_id,
    final_module_label,
    module_direction
  )
]

coverage[
  ,
  eligible_at_50_percent :=
    coverage_fraction >=
      minimum_primary_coverage
]

coverage[
  ,
  high_coverage_at_70_percent :=
    coverage_fraction >=
      minimum_high_coverage
]

coverage[
  ,
  module_order := match(
    final_module_id,
    expected_module_ids
  )
]

setorder(
  coverage,
  module_order
)

coverage[
  ,
  module_order := NULL
]

if (nrow(coverage) != 5L) {
  stop(
    "The reconciled coverage table does not contain five modules."
  )
}


# -------------------------------------------------------------------------
# Compare symbol-only and Entrez-reconciled coverage
# -------------------------------------------------------------------------

symbol_coverage <- fread(
  symbol_coverage_file
)

require_columns(
  symbol_coverage,
  c(
    "final_module_id",
    "locked_gene_count",
    "mapped_gene_count",
    "missing_gene_count",
    "coverage_fraction",
    "missing_symbols"
  ),
  symbol_coverage_file
)

comparison <- merge(
  symbol_coverage[
    ,
    .(
      final_module_id,
      symbol_only_locked_gene_count =
        locked_gene_count,
      symbol_only_mapped_gene_count =
        mapped_gene_count,
      symbol_only_missing_gene_count =
        missing_gene_count,
      symbol_only_coverage_fraction =
        coverage_fraction,
      symbol_only_missing_symbols =
        missing_symbols
    )
  ],
  coverage[
    ,
    .(
      final_module_id,
      entrez_reconciled_mapped_gene_count =
        mapped_gene_count,
      entrez_reconciled_missing_gene_count =
        missing_gene_count,
      entrez_reconciled_coverage_fraction =
        coverage_fraction,
      genes_rescued_by_entrez,
      rescued_symbols,
      entrez_reconciled_missing_symbols =
        missing_symbols
    )
  ],
  by = "final_module_id",
  all = TRUE
)

comparison[
  ,
  mapped_gene_gain :=
    entrez_reconciled_mapped_gene_count -
      symbol_only_mapped_gene_count
]

comparison[
  ,
  module_order := match(
    final_module_id,
    expected_module_ids
  )
]

setorder(
  comparison,
  module_order
)

comparison[
  ,
  module_order := NULL
]


# -------------------------------------------------------------------------
# Final decision
# -------------------------------------------------------------------------

all_modules_eligible_50 <- (
  nrow(coverage) == 5L &&
    all(
      coverage$
        eligible_at_50_percent
    )
)

all_modules_high_coverage_70 <- (
  nrow(coverage) == 5L &&
    all(
      coverage$
        high_coverage_at_70_percent
    )
)

scoring_readiness <- if (
  all_modules_high_coverage_70
) {
  "READY_FOR_FIXED_MODULE_SCORING"
} else if (
  all_modules_eligible_50
) {
  "READY_WITH_LOW_COVERAGE_SENSITIVITY_REQUIRED"
} else {
  "NOT_READY_FOR_FIXED_MODULE_SCORING"
}

unsafe_alias_probe_rows <- conflicts[
  conflict_type ==
    "SYNONYM_ONLY_NOT_ACCEPTED",
  .N
]

unsafe_alias_gene_instances <- uniqueN(
  conflicts[
    conflict_type ==
      "SYNONYM_ONLY_NOT_ACCEPTED",
    paste(
      final_module_id,
      requested_symbol,
      sep = "::"
    )
  ]
)

exact_symbol_conflict_probe_rows <- conflicts[
  conflict_type ==
    "EXACT_SYMBOL_CONFLICTING_ENTREZ",
  .N
]

decision <- data.table(
  candidate_dataset =
    "GSE72810",
  mapping_hierarchy =
    paste0(
      "Exact Entrez; exact symbol only when platform Entrez ",
      "is absent; synonym-only conflicting mappings rejected."
    ),
  locked_module_gene_instances =
    nrow(mapping),
  mapped_gene_instances =
    sum(mapping$mapped),
  unmapped_gene_instances =
    sum(!mapping$mapped),
  entrez_rescued_gene_instances =
    sum(
      mapping$rescued_by_entrez
    ),
  unsafe_alias_gene_instances_rejected =
    unsafe_alias_gene_instances,
  unsafe_alias_probe_rows_rejected =
    unsafe_alias_probe_rows,
  exact_symbol_conflict_probe_rows_rejected =
    exact_symbol_conflict_probe_rows,
  modules_eligible_at_50_percent =
    sum(
      coverage$
        eligible_at_50_percent
    ),
  modules_high_coverage_at_70_percent =
    sum(
      coverage$
        high_coverage_at_70_percent
    ),
  scoring_readiness =
    scoring_readiness,
  quality_gate =
    ifelse(
      all_modules_eligible_50,
      "PASS",
      "REVIEW"
    )
)


# -------------------------------------------------------------------------
# Write tables
# -------------------------------------------------------------------------

fwrite(
  mapping,
  mapping_file,
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
  conflicts,
  conflict_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  comparison,
  comparison_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)

fwrite(
  decision,
  decision_file,
  sep = "\t",
  quote = FALSE,
  na = "NA"
)


# -------------------------------------------------------------------------
# Write report
# -------------------------------------------------------------------------

coverage_preview <- capture.output(
  print(
    coverage[
      ,
      .(
        final_module_id,
        locked_gene_count,
        mapped_gene_count,
        missing_gene_count,
        coverage_fraction,
        genes_rescued_by_entrez,
        rescued_symbols,
        missing_symbols,
        high_coverage_at_70_percent
      )
    ]
  )
)

comparison_preview <- capture.output(
  print(comparison)
)

rejected_alias_preview <- capture.output(
  print(
    conflicts[
      conflict_type ==
        "SYNONYM_ONLY_NOT_ACCEPTED"
    ]
  )
)

report_lines <- c(
  "# GSE72810 Entrez reconciliation audit",
  "",
  "## Mapping hierarchy",
  "",
  paste(
    "Exact locked-gene Entrez identifiers were treated as the",
    "authoritative mapping. Exact-symbol probes were accepted",
    "only when no Entrez-matched probe existed and the platform",
    "probe had no Entrez annotation. Synonym-only probes assigned",
    "to another Entrez gene were rejected."
  ),
  "",
  "## Reconciled module coverage",
  "",
  "```text",
  coverage_preview,
  "```",
  "",
  "## Symbol-only versus Entrez-reconciled coverage",
  "",
  "```text",
  comparison_preview,
  "```",
  "",
  "## Rejected synonym-only mappings",
  "",
  "```text",
  rejected_alias_preview,
  "```",
  "",
  "## Decision",
  "",
  paste0(
    "- Quality gate: `",
    decision$quality_gate,
    "`."
  ),
  paste0(
    "- Scoring readiness: `",
    scoring_readiness,
    "`."
  ),
  paste0(
    "- Entrez-rescued module-gene instances: ",
    sum(
      mapping$rescued_by_entrez
    ),
    "."
  ),
  paste0(
    "- Modules eligible at 50%: ",
    sum(
      coverage$
        eligible_at_50_percent
    ),
    "/5."
  ),
  paste0(
    "- Modules at or above 70%: ",
    sum(
      coverage$
        high_coverage_at_70_percent
    ),
    "/5."
  ),
  paste0(
    "- Rejected synonym-only gene instances: ",
    unsafe_alias_gene_instances,
    "."
  )
)

writeLines(
  report_lines,
  report_file
)

writeLines(
  capture.output(
    sessionInfo()
  ),
  session_file
)


# -------------------------------------------------------------------------
# Console summary
# -------------------------------------------------------------------------

cat(
  "===== GSE72810 ENTREZ RECONCILIATION =====\n"
)

cat(
  "locked_module_gene_instances\t",
  nrow(mapping),
  "\n",
  sep = ""
)

cat(
  "mapped_gene_instances\t",
  sum(mapping$mapped),
  "\n",
  sep = ""
)

cat(
  "unmapped_gene_instances\t",
  sum(!mapping$mapped),
  "\n",
  sep = ""
)

cat(
  "entrez_rescued_gene_instances\t",
  sum(
    mapping$rescued_by_entrez
  ),
  "\n",
  sep = ""
)

cat(
  "unsafe_alias_gene_instances_rejected\t",
  unsafe_alias_gene_instances,
  "\n",
  sep = ""
)

cat(
  "unsafe_alias_probe_rows_rejected\t",
  unsafe_alias_probe_rows,
  "\n",
  sep = ""
)

cat(
  "exact_symbol_conflict_probe_rows_rejected\t",
  exact_symbol_conflict_probe_rows,
  "\n",
  sep = ""
)

cat(
  "modules_eligible_at_50_percent\t",
  sum(
    coverage$
      eligible_at_50_percent
  ),
  "/5\n",
  sep = ""
)

cat(
  "modules_high_coverage_at_70_percent\t",
  sum(
    coverage$
      high_coverage_at_70_percent
  ),
  "/5\n",
  sep = ""
)

cat(
  "scoring_readiness\t",
  scoring_readiness,
  "\n",
  sep = ""
)

cat(
  "quality_gate\t",
  decision$quality_gate,
  "\n",
  sep = ""
)

cat(
  "mapping\t",
  mapping_file,
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
  "conflicts\t",
  conflict_file,
  "\n",
  sep = ""
)

cat(
  "comparison\t",
  comparison_file,
  "\n",
  sep = ""
)

cat(
  "decision\t",
  decision_file,
  "\n",
  sep = ""
)

cat(
  "report\t",
  report_file,
  "\n",
  sep = ""
)

if (!all_modules_eligible_50) {
  stop(
    paste(
      "Entrez-reconciled module coverage failed",
      "the 50% eligibility gate."
    )
  )
}
