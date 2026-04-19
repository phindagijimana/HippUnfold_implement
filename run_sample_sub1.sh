#!/usr/bin/env bash
# Run HippUnfold on bundled sample BIDS data for **sub-1** only (T1w).
# sample_data/ also contains sub-2; use --participant_label 2 to select that subject.
#
# Prerequisites: pull a container once, e.g. ./pull_sif.sh 1.5.2
#   export HIPPUNFOLD_SIF="$PWD/khanlab_hippunfold_1_5_2.sif"
#
# Dry-run (prints Snakemake plan only):
#   ./run_sample_sub1.sh -n -p --cores 1
#
# Full run:
#   ./run_sample_sub1.sh -p --cores 8
set -euo pipefail

# Match slurm_hippunfold.example.slurm: safe TMPDIR (noexec /tmp) + Python isolation.
export TMPDIR="${TMPDIR:-$HOME/apptainer_tmp}"
mkdir -p "$TMPDIR"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$TMPDIR}"
export PYTHONNOUSERSITE=1
unset PYTHONPATH 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIDS_DIR="$SCRIPT_DIR/sample_data"
OUT_DIR="$SCRIPT_DIR/outputs_sample_sub1"

if [[ -z "${HIPPUNFOLD_SIF:-}" || ! -f "${HIPPUNFOLD_SIF}" ]]; then
  echo "Set HIPPUNFOLD_SIF to your HippUnfold .sif file, e.g.:" >&2
  echo "  export HIPPUNFOLD_SIF=$SCRIPT_DIR/khanlab_hippunfold_latest.sif" >&2
  exit 1
fi

export HIPPUNFOLD_CACHE_DIR="${HIPPUNFOLD_CACHE_DIR:-$HOME/hippunfold_cache}"
export SINGULARITY_BINDPATH="${BIDS_DIR}:${BIDS_DIR},${OUT_DIR}:${OUT_DIR},${HIPPUNFOLD_CACHE_DIR}:${HIPPUNFOLD_CACHE_DIR}"
export APPTAINER_BINDPATH="$SINGULARITY_BINDPATH"
mkdir -p "$OUT_DIR" "$HIPPUNFOLD_CACHE_DIR"

exec "$SCRIPT_DIR/run_hippunfold.sh" \
  "$BIDS_DIR" "$OUT_DIR" \
  participant \
  --participant_label 1 \
  --modality T1w \
  "$@"
