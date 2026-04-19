#!/bin/bash
#SBATCH -J hippunfold
#SBATCH -o hippunfold_%j.out
#SBATCH -e hippunfold_%j.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#
# Edit paths, partition/account, and time to match your cluster.
# Build the .sif once (login node or build node): ./pull_sif.sh 1.5.2
#
# Official Singularity usage:
# https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md

set -euo pipefail

# SLURM runs the batch script from a spool directory; use the submit directory for paths.
cd "${SLURM_SUBMIT_DIR:-.}"
SCRIPT_DIR="$(pwd)"

# Apptainer/Singularity: avoid /tmp when it is noexec (common on HPC); use a dir on shared home.
export TMPDIR="${TMPDIR:-$HOME/apptainer_tmp}"
mkdir -p "$TMPDIR"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$TMPDIR}"
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-$HOME/.cache/apptainer}"

# --- paths (defaults: sample BIDS + sub-1 only; override BIDS_DIR/OUT_DIR as needed) ---
BIDS_DIR="${BIDS_DIR:-$SCRIPT_DIR/sample_data}"
OUT_DIR="${OUT_DIR:-$SCRIPT_DIR/outputs_sample_sub1_${SLURM_JOB_ID:-run}}"
SIF="${HIPPUNFOLD_SIF:-$SCRIPT_DIR/khanlab_hippunfold_latest.sif}"
# nnU-Net models download here on first run (use fast/large space, not tiny $HOME quota)
export HIPPUNFOLD_CACHE_DIR="${SCRATCH:-$HOME}/hippunfold_cache"
# If data are under /project or /scratch, ensure the container can see them:
export SINGULARITY_BINDPATH="${BIDS_DIR}:${BIDS_DIR},${OUT_DIR}:${OUT_DIR},${HIPPUNFOLD_CACHE_DIR}:${HIPPUNFOLD_CACHE_DIR}"
export APPTAINER_BINDPATH="$SINGULARITY_BINDPATH"
# Avoid host ~/.local Python leaking into the image (see run_hippunfold.sh / nnUNet crash)
export PYTHONNOUSERSITE=1
export HIPPUNFOLD_SIF="$SIF"

mkdir -p "$OUT_DIR" "$HIPPUNFOLD_CACHE_DIR"

"$SCRIPT_DIR/run_hippunfold.sh" \
  "$BIDS_DIR" "$OUT_DIR" \
  participant \
  --participant_label 1 \
  --modality T1w \
  -p \
  --cores "${SLURM_CPUS_PER_TASK:-8}"
