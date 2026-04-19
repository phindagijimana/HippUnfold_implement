# HippUnfold — key ideas and resources

This note summarizes the main concepts behind **HippUnfold** (the hippocampal unfolding and subfield-segmentation pipeline) and points to the canonical documentation. For full methods and equations, use the primary paper and the project manual linked below.

---

## What HippUnfold is

HippUnfold is a **BIDS App** that **models the topological folding structure of the human hippocampus**, **computationally unfolds** it into a standardized 2D-like coordinate system, and performs **automated subfield segmentation** using deep learning (U-Net / nnU-Net–style models). It is designed for **in vivo structural MRI** (typically **T1w** and/or **T2w**) organized in **BIDS** format.

---

## Key ideas from the methods literature

1. **Unfolding as a coordinate system**  
   Instead of analyzing the hippocampus only in native 3D voxel space, the pipeline **flattens** the structure along its intrinsic long axis so that **position along the hippocampus** and **laminar depth** can be studied in a **canonical, topologically consistent** layout. That supports visualization, **intersubject comparison**, and **surface-based** measurements.

2. **Topology-aware modeling**  
   The approach explicitly respects **folding and laminar organization** (the “unfold” is not a generic 2D slice; it is tied to the hippocampus’s **intrinsic geometry**). This is the conceptual bridge between **volumetric MRI** and **subfield-level** analysis.

3. **Automated segmentation**  
   Hippocampal tissue and subfields are obtained with **convolutional neural networks** trained on common MRI contrasts, so users do not need manual hippocampal labels for standard T1w/T2w scans.

4. **Morphometry and mapping**  
   Once surfaces and unfolded space exist, the framework supports **thickness**, **surface area**, **curvature**, **gyrification**, and **quantitative mapping** (e.g. mapping other modalities or maps onto **midthickness** surfaces and **laminar profiles** perpendicular to the surface).

5. **Registration in unfolded space (newer releases)**  
   From **version 1.3.x** onward, the default workflow adds **registration of each subject’s unfolded representation to a reference atlas** built from **multiple ground-truth histology** samples, improving **intersubject alignment** in unfolded space (with options to fall back to earlier atlas behavior). Models may be **downloaded at runtime** rather than shipped fully inside the container.

---

## Documentation (official)

| Resource | URL |
|----------|-----|
| **Read the Docs (main manual)** | [https://hippunfold.readthedocs.io/en/latest/](https://hippunfold.readthedocs.io/en/latest/) |
| **Khan lab docs (alternate site)** | [https://hippunfold.khanlab.ca/en/latest/](https://hippunfold.khanlab.ca/en/latest/) |
| **Installation** | [https://hippunfold.readthedocs.io/en/latest/getting_started/installation.html](https://hippunfold.readthedocs.io/en/latest/getting_started/installation.html) |
| **Singularity / Apptainer** | [https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md](https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md) |
| **Source repository** | [https://github.com/khanlab/hippunfold](https://github.com/khanlab/hippunfold) |

---

## HPC helper CLI (`./hip`)

In this folder, **`./hip`** wraps the local **Apptainer/Singularity** image and **SLURM** job script. Run **`./hip help`** for the full text.

| Command | Purpose |
|--------|---------|
| **`./hip install [TAG]`** | Pull `docker://khanlab/hippunfold:TAG` to `khanlab_hippunfold_<TAG>.sif` (default `TAG=latest`). Uses a safe **`TMPDIR`** when `/tmp` is `noexec`. |
| **`./hip start`** | **`sbatch slurm_hippunfold.example.slurm`** with **`HIPPUNFOLD_SIF`** set; writes the job id to **`.hip/last_job_id`**. |
| **`./hip logs [-f] [JOBID]`** | Tail **`hippunfold_<JOBID>.err`** / **`.out`** in this directory; default **JOBID** = last `./hip start`. **`-f`** follows the log. |
| **`./hip stop [JOBID]`** | **`scancel`** (default **JOBID** = last `./hip start`). |
| **`./hip checks`** | Verifies **apptainer**, **sbatch**, and **.sif**; optional note if local BIDS is present. |
| **`./hip status`** | **checks** plus a quick list of recent **`hippunfold_*.err`** files. |

**Environment:** `HIPPUNFOLD_SIF` (explicit image path), `HIPPUNFOLD_IMAGE_TAG` (default tag name for install / resolution).

---

## How to cite

- **Any HippUnfold version:** DeKraker, J., Haast, R. A., Yousif, M. D., Karat, B., Lau, J. C., Köhler, S., & Khan, A. R. (2022). Automated hippocampal unfolding for morphometry and subfield segmentation with HippUnfold. *eLife*, **11**, e77945. [https://doi.org/10.7554/eLife.77945](https://doi.org/10.7554/eLife.77945)

- **HippUnfold ≥ 1.3.0** (unfolded-space registration / multihist atlas): DeKraker, J., Palomero-Gallagher, N., Kedo, O., Ladbon-Bernasconi, N., Muenzing, S. E. A., Axer, M., Amunts, K., Khan, A. R., Bernhardt, B., & Evans, A. C. (2023). Evaluation of surface-based hippocampal registration using ground-truth subfield definitions. *eLife*, **12**, RP88404. [https://doi.org/10.7554/eLife.88404.3](https://doi.org/10.7554/eLife.88404.3)

