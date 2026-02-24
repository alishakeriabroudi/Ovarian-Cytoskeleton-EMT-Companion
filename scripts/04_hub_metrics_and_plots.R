suppressPackageStartupMessages({
  library(yaml); library(data.table); library(igraph); library(ggplot2)
})

cfg <- yaml::read_yaml("config/config.yaml")
out_dir <- cfg$project$out_dir
edges_path <- file.path(out_dir, "ppi", "string_edges_highconf.tsv")
if (!file.exists(edges_path)) stop("Missing edges. Run script 03 first.")
edges <- fread(edges_path)

g <- graph_from_data_frame(edges[, .(from, to)], directed=FALSE)

hub <- data.table(
  node = V(g)$name,
  degree = degree(g),
  betweenness = betweenness(g, normalized=TRUE),
  closeness = closeness(g, normalized=TRUE),
  strength = strength(g)
)

n_top <- max(1, ceiling(0.10 * nrow(hub)))
hub[, r_degree := frank(-degree)]
hub[, r_betweenness := frank(-betweenness)]
hub[, r_closeness := frank(-closeness)]
hub[, r_strength := frank(-strength)]
hub[, top_count := (r_degree<=n_top) + (r_betweenness<=n_top) + (r_closeness<=n_top) + (r_strength<=n_top)]

hub_candidates <- hub[top_count >= 2][order(-top_count, r_degree)]

fwrite(hub, file.path(out_dir, "ppi", "hub_metrics_all.tsv"), sep="\t")
fwrite(hub_candidates, file.path(out_dir, "ppi", "hub_candidates.tsv"), sep="\t")

dir.create(file.path(out_dir, "figures"), recursive=TRUE, showWarnings=FALSE)
p <- ggplot(as.data.frame(hub), aes(x=degree)) + geom_histogram(bins=30) + theme_minimal() +
  labs(title="PPI degree distribution (high-confidence STRING)", x="Degree", y="Count")
ggsave(file.path(out_dir, "figures", "ppi_degree_hist.png"), p, width=7, height=4)

message("Saved hub metrics and candidate hubs.")
