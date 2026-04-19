# Paper review — HippUnfold (DeKraker et al., *eLife* 2022)

Concise **Builder Review**–style evaluation of the primary methods paper—not an audit of this repository’s shell scripts.

**DeKraker J, Haast RA, Yousif MD, Karat B, Lau JC, Köhler S, Khan AR.** *Automated hippocampal unfolding for morphometry and subfield segmentation with HippUnfold.* *eLife* 2022;11:e77945. https://doi.org/10.7554/eLife.77945

**Also relevant for software ≥1.3.0 (unfolded-space atlas registration):** DeKraker J, et al. *eLife* 2023;12:RP88404. https://doi.org/10.7554/eLife.88404.3

---

## What the paper contributes

The work introduces **HippUnfold**, a **Snakemake-based BIDS App** that (i) segments hippocampal tissue and subfields with **deep learning** (nnU-Net–class models), (ii) **unfolds** the hippocampus into an **intrinsic coordinate system** suited to laminar and longitudinal position along the structure, and (iii) delivers **surfaces, unfolded maps, and subfield labels** for **morphometry** and group studies. The narrative ties **computational unfolding** to clearer **intersubject alignment** and richer **surface-based** statistics than voxel-only ROI approaches.

---

## Methods and reproducibility (as presented)

- **Inputs:** Standard **BIDS** anatomical MRI (**T1w** / **T2w**); the pipeline is positioned for research cohorts with conventional resolutions, with emphasis on benefit from **higher resolution** where available.
- **Segmentation:** Data-driven **CNN** segmentation replaces manual labels for typical contrasts; the paper discusses validation **against manual labels** and **comparison to other pipelines** (e.g. FreeSurfer/ASHS-style workflows) under stated acquisition assumptions.
- **Software story:** Open implementation and **containerized** distribution support **reproducibility**; exact numbers on **new** data remain **protocol-dependent**.

---

## Strengths

- Clear **problem framing**: hippocampal subfields are easier to interpret in a **topology-aware unfolded space** than in raw slice or whole-hippocampus volume summaries alone.
- **End-to-end tool**: from BIDS to **surfaces, metrics, and subfields** with documented CLI and ecosystem (toolboxes, docs).
- **Empirical validation** against manual references and alternatives, with honest discussion of **resolution** and **failure modes** (motion, contrast, limited FOV for some contrasts).

---

## Limitations and generalization

- Performance metrics are **cohort-specific**; new scanners, sequences, and patient groups require **local QA**—the paper does not promise universal numeric performance.
- **Non-standard modalities** or species may need **manual masks** or **template modes** outside the default T1w/T2w human pipeline described for the main validation.
- **Research software**, not a regulated clinical product; segmentations and registrations remain **algorithm-dependent** and require **expert review** where clinical decisions are involved.

---

## Positioning vs other tools

The paper situates HippUnfold among **hippocampal subfield** methods: compared with tools that chiefly output **volumetric ROIs**, HippUnfold’s emphasis is **unfolding** and **surface/unfold metrics**. Teams that only need **simple volume** or **fast turnaround** may prefer lighter pipelines; teams studying **intrinsic coordinates, laminar-style measures, or unfolded registration** get a stronger match—at the cost of **compute** and **workflow complexity**.

---

## Synthesis

The manuscript makes a **credible case** that automated unfolding plus deep segmentation **lowers the barrier** to consistent, surface-oriented hippocampal analysis in **typical multicenter T1w/T2w** settings, while **transparently** acknowledging **QC**, **protocol effects**, and **limits of automation**. Cite the **2022 *eLife*** paper for the core method; cite the **2023 *eLife*** follow-on if you rely on **unfolded-space atlas registration** in **current** default workflows.

---

## Relation to this repository

The **`HippUnfold_implement`** repo only holds **HPC wrappers** (image pull, SLURM, environment isolation). It **does not** replicate or extend the paper’s experiments; successful local runs **do not** substitute for reading the paper and upstream docs for **scientific** interpretation.

---

## References

- DeKraker et al. 2022 — primary HippUnfold methods (*eLife* e77945).  
- DeKraker et al. 2023 — unfolded registration / multihist atlas (*eLife* RP88404).  
- [hippunfold.readthedocs.io](https://hippunfold.readthedocs.io/) — user manual.  
- [github.com/khanlab/hippunfold](https://github.com/khanlab/hippunfold) — source.  
- [`hipp.md`](hipp.md) — short concepts summary in this project.

*Updated: 2026-04-19.*
