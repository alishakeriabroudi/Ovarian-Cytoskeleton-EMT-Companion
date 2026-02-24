.PHONY: help setup bulk scrna immune smoke

help:
	@echo "Targets:"
	@echo "  setup  - install R packages (Bioc/CRAN)"
	@echo "  bulk   - run bulk pipeline (download/normalize/DEG/PPI/hubs/EMT/plots)"
	@echo "  scrna  - run scRNA-seq integration + CellChat (requires scRNA data paths)"
	@echo "  immune - run immune deconvolution (CIBERSORT placeholder)"
	@echo "  smoke  - quick checks for expected outputs"

setup:
	Rscript scripts/00_install_packages.R

bulk:
	Rscript scripts/01_bulk_download_and_preprocess.R
	Rscript scripts/02_bulk_deg_edgeR.R
	Rscript scripts/03_cytoskeleton_filter_and_ppi.R
	Rscript scripts/04_hub_metrics_and_plots.R
	Rscript scripts/05_emt_gsva.R

scrna:
	Rscript scripts/10_scrna_integration_harmony.R
	Rscript scripts/11_cellchat_analysis.R

immune:
	Rscript scripts/20_immune_deconvolution_placeholder.R

smoke:
	Rscript scripts/99_smoke_test.R
