## miRNA–mRNA network template

Recommended steps:
1) Export miRNA-target pairs from DIANA-microT, miRTarBase, TargetScan, miRDB, TarBase.
2) Harmonize columns to: miRNA, gene.
3) Keep interactions supported by >=2 databases.
4) Intersect with hub genes and export for Cytoscape.

See: `mirna_multidb_filter_TEMPLATE.R`
