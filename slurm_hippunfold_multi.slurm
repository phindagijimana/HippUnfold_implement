#!/bin/bash
#SBATCH -J hippunfold
#SBATCH -o hippunfold_%j.out
#SBATCH -e hippunfold_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#
# Run one or more participants in a SINGLE snakemake invocation.
# One shared work/.snakemake tree per OUT_DIR, so do NOT run concurrent jobs
# against the same OUT_DIR; snakemake parallelizes subjects across --cores instead.
#
# Submit, e.g.:
#   sbatch --export=ALL,BIDS_DIR=/path/bids,OUT_DIR=/path/derivatives/hippunfold,PARTICIPANTS="001 006 007",MODALITY=T1w \
#     slurm_hippunfold_multi.slurm
#
# Required env: BIDS_DIR, OUT_DIR, PARTICIPANTS (space-separated labels, no "sub-")
# Optional env: MODALITY (default T1w), HIPPUNFOLD_SIF, HIPPUNFOLD_CACHE_DIR

set -euo pipefail

cd "${SLURM_SUBMIT_DIR:-.}"
SCRIPT_DIR="$(pwd)"

# Apptainer: avoid noexec /tmp.
export TMPDIR="${TMPDIR:-$HOME/apptainer_tmp}"
mkdir -p "$TMPDIR"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$TMPDIR}"
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-$HOME/.cache/apptainer}"

BIDS_DIR="${BIDS_DIR:?set BIDS_DIR}"
OUT_DIR="${OUT_DIR:?set OUT_DIR}"
MODALITY="${MODALITY:-T1w}"
# PARTICIPANTS is optional: if empty, HippUnfold processes every subject in BIDS_DIR.
read -r -a LABELS <<< "${PARTICIPANTS:-}"

SIF="${HIPPUNFOLD_SIF:-$SCRIPT_DIR/khanlab_hippunfold_latest.sif}"
export HIPPUNFOLD_SIF="$SIF"
export HIPPUNFOLD_CACHE_DIR="${HIPPUNFOLD_CACHE_DIR:-${SCRATCH:-$HOME}/hippunfold_cache}"
export SINGULARITY_BINDPATH="${BIDS_DIR}:${BIDS_DIR},${OUT_DIR}:${OUT_DIR},${HIPPUNFOLD_CACHE_DIR}:${HIPPUNFOLD_CACHE_DIR}"
export APPTAINER_BINDPATH="$SINGULARITY_BINDPATH"
export PYTHONNOUSERSITE=1
unset PYTHONPATH 2>/dev/null || true

mkdir -p "$OUT_DIR" "$HIPPUNFOLD_CACHE_DIR"

LABEL_ARGS=()
if [[ ${#LABELS[@]} -gt 0 ]]; then
  LABEL_ARGS=(--participant-label "${LABELS[@]}")
fi

echo "hippunfold: subjects=[${LABELS[*]:-ALL}] modality=$MODALITY bids=$BIDS_DIR out=$OUT_DIR"
"$SCRIPT_DIR/run_hippunfold.sh" \
  "$BIDS_DIR" "$OUT_DIR" \
  participant \
  ${LABEL_ARGS[@]+"${LABEL_ARGS[@]}"} \
  --modality "$MODALITY" \
  -p \
  --cores "${SLURM_CPUS_PER_TASK:-8}" \
  --latency-wait 60
