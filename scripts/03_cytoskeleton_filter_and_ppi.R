suppressPackageStartupMessages({
  library(yaml); library(data.table); library(dplyr); library(STRINGdb)
})

cfg <- yaml::read_yaml("config/config.yaml")
out_dir <- cfg$project$out_dir
dir.create(file.path(out_dir, "ppi"), recursive=TRUE, showWarnings=FALSE)

deg <- fread(file.path(out_dir, "deg", "de_deg.tsv"))

panther_path <- cfg$cytoskeleton$panther_list_path
if (!file.exists(panther_path)) {
  message("Missing cytoskeleton list at: ", panther_path)
  message("Create it manually from PANTHER export (one gene symbol per line). Proceeding with all DEGs.")
  cyto_deg <- deg
} else {
  cyto_genes <- readLines(panther_path)
  cyto_deg <- deg[gene %in% cyto_genes]
}
fwrite(cyto_deg, file.path(out_dir, "ppi", "cytoskeleton_deg.tsv"), sep="\t")

genes <- unique(cyto_deg$gene)
genes <- genes[!is.na(genes) & genes != ""]
if (length(genes) < 5) stop("Too few genes for PPI. Provide cytoskeleton list or relax filters.")

string_db <- STRINGdb$new(version="11.5", species=9606, score_threshold=0, input_directory="")
mapped <- string_db$map(data.frame(gene=genes), "gene", removeUnmappedRows=TRUE)
ppi <- string_db$get_interactions(mapped$STRING_id)
ppi <- ppi[combined_score >= (cfg$ppi$string_score * 1000)]

fwrite(ppi, file.path(out_dir, "ppi", "string_edges_highconf.tsv"), sep="\t")
message(sprintf("Saved STRING edges (n=%d) at high confidence.", nrow(ppi)))
