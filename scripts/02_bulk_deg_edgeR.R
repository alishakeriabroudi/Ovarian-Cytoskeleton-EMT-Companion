suppressPackageStartupMessages({
  library(yaml); library(data.table); library(dplyr); library(limma)
})

cfg <- yaml::read_yaml("config/config.yaml")
out_dir <- cfg$project$out_dir
dir.create(file.path(out_dir, "deg"), recursive=TRUE, showWarnings=FALSE)

expr <- readRDS(file.path(out_dir, "bulk", "expr_merged_geo.rds"))
meta <- fread(file.path(out_dir, "bulk", "meta_merged_geo.tsv"))

candidate_cols <- c("characteristics_ch1.1","characteristics_ch1","source_name_ch1","title")
group <- rep(NA_character_, nrow(meta))
for (cc in candidate_cols) {
  if (cc %in% colnames(meta)) {
    txt <- tolower(as.character(meta[[cc]]))
    group[is.na(group) & grepl("normal", txt)] <- "Normal"
    group[is.na(group) & grepl("tumou|tumor|cancer|carcinoma|ovarian", txt)] <- "Tumor"
  }
}
meta$group <- group

if (length(unique(na.omit(meta$group))) < 2) {
  stop("Could not infer Tumor/Normal groups from GEO metadata. Please set meta$group manually in this script.")
}

keep <- !is.na(meta$group)
expr <- expr[, keep, drop=FALSE]
meta <- meta[keep, ]
grp <- factor(meta$group)

design <- model.matrix(~ grp)
fit <- lmFit(expr, design)
fit <- eBayes(fit)
tab <- topTable(fit, coef=2, number=Inf, sort.by="P")
tab$FDR <- p.adjust(tab$P.Value, method="BH")

deg <- as.data.table(tab, keep.rownames="gene")
deg_sig <- deg[FDR < cfg$deg$fdr & abs(logFC) >= cfg$deg$log2fc][order(FDR)]

fwrite(deg, file.path(out_dir, "deg", "de_all.tsv"), sep="\t")
fwrite(deg_sig, file.path(out_dir, "deg", "de_deg.tsv"), sep="\t")

message(sprintf("Saved DEG (n=%d) with thresholds |log2FC|>=%.2f and FDR<%.2f.",
                nrow(deg_sig), cfg$deg$log2fc, cfg$deg$fdr))
