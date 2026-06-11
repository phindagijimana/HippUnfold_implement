# HippUnfold_implement

Deployment helpers for running **[HippUnfold](https://github.com/khanlab/hippunfold)**—the BIDS App for hippocampal unfolding and subfield segmentation—on **Linux HPC** with **Apptainer/Singularity** and **SLURM**.

This repository provides scripts and job templates. It does **not** fork HippUnfold; container images are pulled from Docker Hub (`khanlab/hippunfold`).

---

## Contents

| Component | Role |
|-----------|------|
| [`pull_sif.sh`](pull_sif.sh) | Build a `.sif` from `docker://khanlab/hippunfold:<tag>` with HPC-safe temp/cache paths. |
| [`run_hippunfold.sh`](run_hippunfold.sh) | Invoke the container with a clean environment and cache dir forwarding. |
| [`slurm_hippunfold_multi.slurm`](slurm_hippunfold_multi.slurm) | Parameterized batch job (used by `./hip start`): one snakemake run over one/many/all subjects. |
| [`slurm_hippunfold.example.slurm`](slurm_hippunfold.example.slurm) | Minimal hand-editable example for a single subject. |
| [`run_sample_sub1.sh`](run_sample_sub1.sh) | Example local invocation when BIDS data live under `sample_data/` (populated by you). |
| [`hip`](hip) | Small CLI: `install`, `start`, `logs`, `stop`, `checks`, `status`. |

Further reading in-repo: **[`hipp.md`](hipp.md)** (concepts and upstream links), **[`hipp_br.md`](hipp_br.md)** (concise review of the HippUnfold *eLife* paper).

---

## Prerequisites

- **Apptainer** or **Singularity**, **SLURM** (`sbatch`, `squeue`, …)—typical for shared clusters  
- Network access to pull the container and (on first run) nnU-Net models and templates into `HIPPUNFOLD_CACHE_DIR`  
- A **BIDS** dataset with **T1w** and/or **T2w** anatomical NIfTI (see [upstream tutorials](https://hippunfold.readthedocs.io/en/latest/))  
- Sufficient CPU/memory/time in your job; GPU is optional for HippUnfold

---

## Quick start

1. **Clone** this repository.
2. **Pull the image** (once per machine or tag):  
   `./pull_sif.sh latest`  
   or `./hip install`  
   This produces `khanlab_hippunfold_latest.sif` in the repo directory (not committed).
3. **Prepare BIDS data** locally—see [`sample_data/README.md`](sample_data/README.md). Do not commit patient or site-identifiable imaging to a public remote.
4. **Submit** via the CLI (saves the job id under `.hip/`):  

```bash
# sample_data, sub-1, T1w
./hip start -p 1

# your own BIDS, selected subjects, explicit output dir
./hip start -i /data/bids -o /data/derivatives/hippunfold -p 001 006 007 -m T1w

# every subject in a BIDS dir
./hip start -i /data/bids -o /data/derivatives/hippunfold
```

   `./hip start` parameterizes [`slurm_hippunfold_multi.slurm`](slurm_hippunfold_multi.slurm); all selected subjects run in one snakemake invocation (parallelized across cores) writing to one `OUT_DIR`. Edit the `#SBATCH` header in that script for your site (partition, account, wall time, memory). For a hand-built single submission you can still `sbatch slurm_hippunfold.example.slurm` after `export HIPPUNFOLD_SIF=...`.

Monitor with `./hip logs` (or `-f` to follow), `./hip status`, or `tail -f hippunfold_<jobid>.err`.

> Run only **one** job per `OUT_DIR` at a time: HippUnfold keeps a single `work/`/`.snakemake` tree there, so concurrent jobs on the same output dir collide. Use separate output dirs for parallel jobs.

---

## Configuration (summary)

| Variable | Purpose |
|----------|---------|
| `HIPPUNFOLD_SIF` | Path to the `.sif` image (required for `run_hippunfold.sh` / SLURM). |
| `HIPPUNFOLD_CACHE_DIR` | Store downloaded models/templates (default in job script uses `$SCRATCH` or `$HOME`). |
| `BIDS_DIR` / `OUT_DIR` | Override in the environment before `sbatch` if not using the script defaults. |

The wrapper sets `PYTHONNOUSERSITE` and bind paths so host `~/.local` Python packages do not break nnU-Net inside the container.

---

## Upstream documentation

- Manual: [hippunfold.readthedocs.io](https://hippunfold.readthedocs.io/en/latest/)  
- Singularity: [khanlab/hippunfold — singularity.md](https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md)  
- Source: [github.com/khanlab/hippunfold](https://github.com/khanlab/hippunfold)

---

## Citation

If you use HippUnfold in research, cite the **eLife** methods paper and (for recent versions) the unfolded-atlas paper—see the [HippUnfold README](https://github.com/khanlab/hippunfold#publications) for DOIs.

---

## Disclaimer

Scripts here are provided as a convenience for HPC deployment. **HippUnfold** licensing and terms follow the upstream project. This wrapper is not a medical device; clinical use requires appropriate validation and institutional oversight.
