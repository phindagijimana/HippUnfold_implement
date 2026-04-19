# BIDS input data (local only)

Do **not** commit patient or site-specific imaging to a public repository. Keep your BIDS datasets **outside Git** (this directory is ignored except for this file).

**Official HippUnfold example (public test data):** download and extract the single-subject set described in the [Singularity getting started](https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md) guide (e.g. `ds002168` with T1w/T2w). Point `BIDS_DIR` to that folder, or unpack under `sample_data/` locally.

**Minimum BIDS layout:** `dataset_description.json` and `sub-*/anat/*_T1w.nii.gz` (and sidecar JSON) as required by HippUnfold.
