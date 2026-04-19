# HippUnfold_implement

HPC-oriented wrapper for [HippUnfold](https://github.com/khanlab/hippunfold): Apptainer/Singularity image pull, SLURM job script, and a small **`./hip`** CLI (`install`, `start`, `logs`, `stop`, `checks`).

- **Docs in repo:** [`hipp.md`](hipp.md) (usage + links), [`hipp_br.md`](hipp_br.md) (short paper/deployment review).
- **Quick start:** `./hip install` → `./hip start` (after cluster-specific `#SBATCH` edits). See `hipp.md` for details.
- **Sample BIDS data:** `sample_data/` (two subjects; pipeline example uses `sub-1`).

The Docker image is **not** committed; run **`./pull_sif.sh latest`** (or `./hip install`) on your system.

## HPC fixes bundled here

1. **`/tmp` noexec** — `pull_sif.sh`, `slurm_hippunfold.example.slurm`, and `run_sample_sub1.sh` use **`TMPDIR`** / **`APPTAINER_TMPDIR`** under **`$HOME/apptainer_tmp`** (and aligned cache dirs) so Apptainer can build/pull.
2. **SLURM spool paths** — the batch script **`cd`s to `SLURM_SUBMIT_DIR`** before resolving `BIDS_DIR` / `OUT_DIR` / `.sif` paths.
3. **Host `~/.local` Python vs container** — `run_hippunfold.sh` passes **`PYTHONNOUSERSITE=1`** and clears **`PYTHONPATH`** inside the container; SLURM and **`run_sample_sub1.sh`** also set **`PYTHONNOUSERSITE`**, **`unset PYTHONPATH`**, and duplicate **`APPTAINER_BINDPATH`** with **`SINGULARITY_BINDPATH`**.
