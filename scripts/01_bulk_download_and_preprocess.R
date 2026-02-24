suppressPackageStartupMessages({
  library(yaml); library(data.table); library(dplyr)
  library(GEOquery); library(limma); library(sva)
})

cfg <- yaml::read_yaml("config/config.yaml")
set.seed(cfg$project$seed)
out_dir <- cfg$project$out_dir
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(out_dir, "bulk"), recursive=TRUE, showWarnings=FALSE)

geo_series <- cfg$bulk$geo_series
all_expr <- list()
all_meta <- list()

for (gse in geo_series) {
  message("Downloading ", gse)
  gset <- GEOquery::getGEO(gse, GSEMatrix = TRUE, getGPL = FALSE)
  gset <- gset[[1]]
  expr <- Biobase::exprs(gset)
  meta <- Biobase::pData(gset)

  expr <- apply(expr, 2, as.numeric)
  rownames(expr) <- rownames(Biobase::exprs(gset))
  colnames(expr) <- colnames(Biobase::exprs(gset))

  all_expr[[gse]] <- expr
  meta$dataset <- gse
  all_meta[[gse]] <- meta
}

common_genes <- Reduce(intersect, lapply(all_expr, rownames))
expr_merged <- do.call(cbind, lapply(all_expr, function(m) m[common_genes, , drop=FALSE]))
meta_merged <- bind_rows(all_meta)

if (isTRUE(cfg$preprocess$log2_transform)) {
  if (max(expr_merged, na.rm=TRUE) > 100) expr_merged <- log2(expr_merged + 1)
}

if (isTRUE(cfg$preprocess$quantile_normalize)) {
  expr_merged <- limma::normalizeBetweenArrays(expr_merged, method="quantile")
}

if (isTRUE(cfg$preprocess$combat)) {
  batch <- meta_merged$dataset
  mod <- model.matrix(as.formula(cfg$preprocess$combat_model), data=meta_merged)
  expr_merged <- sva::ComBat(dat=expr_merged, batch=batch, mod=mod, par.prior=TRUE, prior.plots=FALSE)
}

saveRDS(expr_merged, file.path(out_dir, "bulk", "expr_merged_geo.rds"))
fwrite(meta_merged, file.path(out_dir, "bulk", "meta_merged_geo.tsv"), sep="\t")

message("Saved merged GEO expression and metadata.")
message("NOTE: probe->gene mapping may be required per platform for publication-grade reproduction.")
