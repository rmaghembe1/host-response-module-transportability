# Host-Pathogen Transcriptomic Transportability Project
# Environment setup only; no biological analysis is performed here.
required_packages <- c(
  "renv", "GEOquery", "edgeR", "limma", "fgsea", "msigdbr",
  "AnnotationDbi", "org.Hs.eg.db", "data.table", "tidyverse", "ComplexHeatmap"
)
message("Required packages for the planned workflow:")
print(required_packages)
message("Initialize with renv::init() in the repository before analysis and record sessionInfo().")
