# HippUnfold_implement

HPC-oriented wrapper for [HippUnfold](https://github.com/khanlab/hippunfold): Apptainer/Singularity image pull, SLURM job script, and a small **`./hip`** CLI (`install`, `start`, `logs`, `stop`, `checks`).

- **Docs in repo:** [`hipp.md`](hipp.md) (usage + links), [`hipp_br.md`](hipp_br.md) (short paper/deployment review).
- **Quick start:** `./hip install` → `./hip start` (after cluster-specific `#SBATCH` edits). See `hipp.md` for details.
- **BIDS inputs:** obtain data locally; see [`sample_data/README.md`](sample_data/README.md) (nothing sensitive is committed).

The Docker image is **not** committed; run **`./pull_sif.sh latest`** (or `./hip install`) on your system.
