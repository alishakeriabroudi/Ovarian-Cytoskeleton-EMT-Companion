suppressPackageStartupMessages({
  library(yaml); library(data.table); library(GSVA); library(ggplot2)
})

cfg <- yaml::read_yaml("config/config.yaml")
out_dir <- cfg$project$out_dir
dir.create(file.path(out_dir, "emt"), recursive=TRUE, showWarnings=FALSE)

expr <- readRDS(file.path(out_dir, "bulk", "expr_merged_geo.rds"))
gmt <- cfg$emt$hallmark_emt_gmt
if (!file.exists(gmt)) stop("Missing EMT GMT at: ", gmt)

read_gmt <- function(path){
  lines <- readLines(path)
  sets <- lapply(lines, function(x){
    parts <- strsplit(x, "\t")[[1]]
    list(name=parts[1], genes=unique(parts[-c(1,2)]))
  })
  names(sets) <- vapply(sets, `[[`, character(1), "name")
  sets
}

sets <- read_gmt(gmt)
target <- if ("HALLMARK_EPITHELIAL_MESENCHYMAL_TRANSITION" %in% names(sets)) "HALLMARK_EPITHELIAL_MESENCHYMAL_TRANSITION" else names(sets)[1]
genes <- sets[[target]]$genes
genes <- genes[genes %in% rownames(expr)]
if (length(genes) < 10) stop("Too few EMT genes overlap; check gene IDs.")

score <- gsva(expr, list(EMT=genes), method="ssgsea", kcdf="Gaussian", abs.ranking=TRUE)
emt_scores <- data.table(sample=colnames(expr), EMT=as.numeric(score["EMT", ]))
fwrite(emt_scores, file.path(out_dir, "emt", "emt_scores.tsv"), sep="\t")

dir.create(file.path(out_dir, "figures"), recursive=TRUE, showWarnings=FALSE)
p <- ggplot(as.data.frame(emt_scores), aes(x=EMT)) + geom_histogram(bins=40) + theme_minimal() +
  labs(title="EMT ssGSEA score distribution", x="EMT score", y="Count")
ggsave(file.path(out_dir, "figures", "emt_score_hist.png"), p, width=7, height=4)

message("Saved EMT scores.")
