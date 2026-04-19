# Builder Review — HippUnfold (DeKraker et al. 2022) + local HPC

Concise **Builder Review**–style notes (usability, reproducibility, performance, clinical fit, limitations, ops).

**Primary:** DeKraker J, et al. *Automated hippocampal unfolding for morphometry and subfield segmentation with HippUnfold.* *eLife* 2022;11:e77945. https://doi.org/10.7554/eLife.77945

**Related (≥1.3.0, unfolded atlas):** DeKraker J, et al. *eLife* 2023;12:RP88404. https://doi.org/10.7554/eLife.88404.3

**Local stack:** `pull_sif.sh`, `run_hippunfold.sh`, `slurm_hippunfold.example.slurm`, `./hip`, local BIDS (see `sample_data/README.md`), `khanlab_hippunfold_*.sif`, `HIPPUNFOLD_CACHE_DIR`.

---

## Context

**HippUnfold** is a **BIDS App** (Snakemake): CNN segmentation (nnU-Net–class), **hippocampal unfolding** (AutoTop-style intrinsic coordinates), surfaces + subfields for morphometry. **This repo** only adds **HPC plumbing**—Apptainer pull (`TMPDIR` for `noexec` `/tmp`), SLURM (`SLURM_SUBMIT_DIR`), **`./hip`**—not new algorithms.

---

## Usability and reproducibility

| | Paper / upstream | This deployment |
|--|-------------------|-----------------|
| **Surface** | BIDS T1w/T2w; Docker/Singularity; GPU optional | **`./hip install` → `./hip start`**; **`./hip checks`**; SLURM `cd` to submit dir |
| **Friction** | v1.3+ downloads models/atlas; version/atlas flags affect outputs | Same + **cache quota**, **network** on first run; long batch run (not interactive) |
| **Repro** | Code + containers on Docker Hub; BIDS aids provenance | **Pin image tag + HippUnfold version + CLI**; 1.3.x defaults differ—document **`--atlas` / `--no_unfolded_reg`** |

**External builder:** Paper metrics are validation on their data; **your** scanners need local QA. This repo validates **runnable** `.sif` + SLURM wiring, not the paper’s full benchmark suite. Logs: **`hippunfold_<JOBID>.err`**.

---

## Performance and generalization

- **Speed:** Dominated by **cores**, **I/O** (NFS vs scratch), **model download** first run—use **`./hip logs`** / **`sacct`** to tune; no bundled benchmark here.
- **Scope:** Best on **standard structural MRI**; exotic modalities/non-human paths need **docs flags** and often **manual masks**. **Research tool**, not a certified clinical device.
- **vs ASHS / FreeSurfer hipp:** HippUnfold’s edge is **unfolding + surface/unfold metrics**; use simpler ROI tools if you only need volumes and want lighter compute.

---

## Clinical / interpretability / integration

- **Research:** Strong when hypotheses need **subfields/surfaces in unfolded space**. **Not** diagnostic radiology; outputs need **QC** (motion, contrast, small FOV T2w → consider **`--t1_reg_template`**).
- **Outputs:** BIDS derivatives, GIfTI/CIFTI-friendly; fits **R/Python** downstream. **Stock container** does not expose Snakemake **cluster profiles**; **`./hip`** does not add PACS/XNAT.

---

## Limitations

Long DAG and large intermediates—prefer **scratch** for cache/output where allowed. **No arm64** Docker (Apple Silicon impractical per upstream). **`run -e`** needs explicit **`HIPPUNFOLD_CACHE_DIR`** in the wrapper (done in `run_hippunfold.sh`). **Hippocampus-only.**

---

## Builder insight

Choose HippUnfold when the **science needs unfolded coordinates and surface metrics**. On shared HPC, success is mostly **ops**: **pinned tags**, **cache + TMPDIR**, **SLURM paths**, **documented atlas/version flags**. Extensions: site **partition/account** in the SLURM script, **CI** `hippunfold --help` + **`./hip checks`**, scratch-first env vars.

---

## References

- Papers (DOIs above), [docs](https://hippunfold.readthedocs.io/), [GitHub](https://github.com/khanlab/hippunfold), [`hipp.md`](hipp.md).

*Updated: 2026-04-19.*
