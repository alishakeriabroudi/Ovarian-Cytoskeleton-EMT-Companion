if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")

cran <- c("yaml","data.table","dplyr","ggplot2","Matrix")
bioc <- c("GEOquery","limma","edgeR","sva","clusterProfiler","org.Hs.eg.db",
          "GSVA","msigdbr","STRINGdb","igraph")

for (p in cran) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, repos="https://cloud.r-project.org")
for (p in bioc) if (!requireNamespace(p, quietly=TRUE)) BiocManager::install(p, ask=FALSE, update=FALSE)

opt_bioc <- c("Seurat","harmony","CellChat")
for (p in opt_bioc) if (!requireNamespace(p, quietly=TRUE)) message("Optional package missing: ", p)

message("Setup complete.")
