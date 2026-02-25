# Companion Code (Clean Core + Experimental): Cytoskeleton/EMT in Ovarian Cancer

This repository is a **GitHub-friendly companion codebase** for an ovarian cancer study that integrates bulk cohorts and single-cell validation.
It is designed to be:
- **Clean**: no huge data committed
- **Reproducible**: scripts write outputs under `results/`
- **Honest**: licensed / manual-tool steps are separated into `experimental/`

Paper context: the work uses bulk cohort integration with quantile normalization + ComBat, performs DEG and STRING PPI at high confidence, identifies hubs via multiple network metrics, computes EMT scores, integrates scRNA-seq with Seurat+Harmony, and runs CellChat.

---

## Associated publication
**Analysis of microarray and single-cell RNA-seq finds gene co-expression, cell–cell communication, and tumor environment associated with cytoskeleton protein in epithelial-mesenchymal transition in ovarian cancer**  
- Ali Shakeri Abroudi, Aryan Jalaeianbanayan, Melika Djamali, Hossein Azizi — *Discover Oncology* (2026)  
- DOI: https://doi.org/10.1007/s12672-026-04580-6
  
---

## Quick start (core)

### Install R packages
```bash
make setup
```

### Configure inputs
Edit `config/config.yaml` (optional):
- Provide Hallmark EMT GMT file for EMT scoring
- Provide a cytoskeleton gene list exported from PANTHER (one gene symbol per line)

### Run bulk pipeline
```bash
make bulk
```

Outputs:
- `results/bulk/` merged matrices
- `results/deg/` DEG results
- `results/ppi/` STRING edges + hub tables
- `results/emt/` EMT scores + plots

---

## Single-cell pipeline (optional)
```bash
make scrna
```
You must edit `scripts/10_scrna_integration_harmony.R` and `scripts/11_cellchat_analysis.R` to point to your scRNA-seq inputs.

---

## Immune infiltration (placeholder)
The paper uses CIBERSORT (LM22). Due to licensing, we provide a placeholder and clear integration notes in `experimental/`.

---

## License
MIT (code).
