# OPTIONAL scaffold for scRNA-seq integration (Seurat + Harmony)
suppressPackageStartupMessages({ library(Seurat) })
dir.create("results/scrna", recursive=TRUE, showWarnings=FALSE)
stop("Edit this script to load your scRNA matrices and run Harmony integration, then save results/scrna/integrated_seurat.rds")
