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

If you use this deployment or HippUnfold in research, cite the primary methods paper and any follow-on work that matches the version and workflow you used. Upstream maintains the full publication list in the [HippUnfold README](https://github.com/khanlab/hippunfold#publications).

### HippUnfold

**Core method (cite for any HippUnfold version):**

> DeKraker J, Haast RA, Yousif MD, Karat B, Lau JC, Köhler S, Khan AR. Automated hippocampal unfolding for morphometry and subfield segmentation with HippUnfold. *eLife*. 2022;11:e77945.  
> https://doi.org/10.7554/eLife.77945

**Unfolded-space registration / multihist atlas (HippUnfold ≥ 1.3.0; default in current releases):**

> DeKraker J, Palomero-Gallagher N, Kedo O, Ladbon-Bernasconi N, Muenzing SEA, Axer M, Amunts K, Khan AR, Bernhardt B, Evans AC. Evaluation of surface-based hippocampal registration using ground-truth subfield definitions. *eLife*. 2023;12:RP88404.  
> https://doi.org/10.7554/eLife.88404.3

### Software, standards, and resources used here

| Resource | Role in this project | Reference / link |
|----------|----------------------|------------------|
| **HippUnfold** | BIDS App: segmentation, unfolding, subfields | [github.com/khanlab/hippunfold](https://github.com/khanlab/hippunfold) · [hippunfold.readthedocs.io](https://hippunfold.readthedocs.io/en/latest/) |
| **nnU-Net** | Deep-learning segmentation backend inside HippUnfold | Isensee F, Jaeger PF, Kohl SAA, Petersen J, Maier-Hein KH. nnU-Net: a self-configuring method for deep learning-based biomedical image segmentation. *Nat Methods*. 2021;18(2):203–211. https://doi.org/10.1038/s41592-020-01008-z |
| **Snakemake / Snakebids** | Workflow engine and BIDS App framework | Mölder F, Jablonski KP, Letcher B, et al. Sustainable data analysis with Snakemake. *F1000Res*. 2021;10:33. https://doi.org/10.12688/f1000research.29032.2 |
| **BIDS** | Input dataset organization | Gorgolewski KJ, Auer T, Calhoun VD, et al. The brain imaging data structure, a format for organizing neuroimaging datasets. *Sci Data*. 2016;3:160044. https://doi.org/10.1038/sdata.2016.44 |
| **BIDS Apps** | Containerized neuroimaging app interface used by HippUnfold | Gorgolewski KJ, Burns CD, Madison C, et al. BIDS Apps: Improving ease of use, accessibility, and reproducibility of neuroimaging data analysis methods. *PLOS Comput Biol*. 2017;13(3):e1005209. https://doi.org/10.1371/journal.pcbi.1005209 |
| **Apptainer / Singularity** | Container runtime on HPC | Sochat V, Prybol CJ, Kurtzer GM, et al. The Singularity container ecosystem. *PLOS ONE*. 2021;16(9):e0256920. https://doi.org/10.1371/journal.pone.0256920 |
| **Docker image** | Upstream HippUnfold container (`khanlab/hippunfold`) | https://hub.docker.com/r/khanlab/hippunfold |

This repository (`HippUnfold_implement`) is a deployment wrapper only; it does not introduce new methods. Acknowledge HippUnfold and the resources above in publications that use outputs from this pipeline.

---

## Disclaimer

Scripts here are provided as a convenience for HPC deployment. **HippUnfold** licensing and terms follow the upstream project. This wrapper is not a medical device; clinical use requires appropriate validation and institutional oversight.
