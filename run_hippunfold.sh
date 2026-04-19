#!/usr/bin/env bash
# Run HippUnfold BIDS App via Singularity/Apptainer (HPC-friendly wrapper).
# Example:
#   export HIPPUNFOLD_SIF=/path/to/khanlab_hippunfold_latest.sif
#   export HIPPUNFOLD_CACHE_DIR=/scratch/$USER/hippunfold_cache
#   ./run_hippunfold.sh /data/bids_in /data/bids_out participant --modality T1w -p --cores 8
#
# Upstream examples use: singularity run -e image.sif <bids_dir> <out_dir> participant ...
# https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <bids_dir> <output_dir> <analysis_level> [hippunfold_args...]" >&2
  echo "  analysis_level is typically: participant  or  group" >&2
  exit 1
fi

SIF="${HIPPUNFOLD_SIF:-}"
if [[ -z "$SIF" || ! -f "$SIF" ]]; then
  echo "Set HIPPUNFOLD_SIF to the .sif file path (e.g. from ./pull_sif.sh)." >&2
  exit 1
fi

if command -v apptainer >/dev/null 2>&1; then
  RUNTIME=apptainer
elif command -v singularity >/dev/null 2>&1; then
  RUNTIME=singularity
else
  echo "Neither apptainer nor singularity found in PATH." >&2
  exit 1
fi

# Models (v1.3+): default ~/.cache/hippunfold — on HPC set a persistent path.
# With `-e/--cleanenv`, variables must be injected with --env (see below).
#   export HIPPUNFOLD_CACHE_DIR=/scratch/$USER/hippunfold_cache

# Bind extra paths if inputs live outside $HOME (colon-separated list).
#   export SINGULARITY_BINDPATH=/project:/project,/scratch:/scratch
# Bind mounts are resolved on the host; they still apply with --cleanenv.

RUN_FLAGS=(-e)
if [[ -n "${HIPPUNFOLD_CACHE_DIR:-}" ]]; then
  RUN_FLAGS+=(--env "HIPPUNFOLD_CACHE_DIR=$HIPPUNFOLD_CACHE_DIR")
fi
# Home is usually bind-mounted; Python then loads ~/.local/site-packages and can shadow
# the image's numpy/skimage → "numpy.dtype size changed" / nnUNet_predict crash.
RUN_FLAGS+=(--env "PYTHONNOUSERSITE=1")
# Drop host PYTHONPATH if the scheduler/modules set it (still use image site-packages only).
RUN_FLAGS+=(--env "PYTHONPATH=")

# -e/--cleanenv: minimal env inside container (matches upstream docs)
exec "$RUNTIME" run "${RUN_FLAGS[@]}" "$SIF" "$@"
