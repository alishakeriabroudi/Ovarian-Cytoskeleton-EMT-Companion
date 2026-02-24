library(data.table)

hub_path <- "results/ppi/hub_candidates.tsv"
stopifnot(file.exists(hub_path))
hub <- fread(hub_path)

# Replace node IDs with gene symbols if you export gene symbols from STRING/Cytoscape.
hub_nodes <- unique(hub$node)

# TODO: Load your multi-db exports and filter miRNAs supported by >=2 sources.
message("Template only. Fill in data loading + harmonization.")
