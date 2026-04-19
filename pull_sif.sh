#!/usr/bin/env bash
# Pull HippUnfold Docker image as a Singularity/Apptainer .sif file (for HPC).
# Docs: https://github.com/khanlab/hippunfold/blob/master/docs/getting_started/singularity.md
set -euo pipefail

# Many clusters mount /tmp with noexec; Apptainer then fails unless TMPDIR is elsewhere.
if [[ -z "${TMPDIR:-}" ]]; then
  export TMPDIR="${HOME}/apptainer_tmp"
  mkdir -p "$TMPDIR"
fi
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$TMPDIR}"
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-$HOME/.cache/apptainer}"
# Keep Singularity-compatible name in sync (Apptainer warns if they differ).
export SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR:-$APPTAINER_CACHEDIR}"

TAG="${1:-latest}"
OUT_DIR="${OUT_DIR:-.}"
mkdir -p "$OUT_DIR"

if command -v apptainer >/dev/null 2>&1; then
  RUNTIME=apptainer
elif command -v singularity >/dev/null 2>&1; then
  RUNTIME=singularity
else
  echo "Neither apptainer nor singularity found in PATH." >&2
  exit 1
fi

# Optional: avoid filling $HOME on shared systems (see upstream singularity.md)
# export SINGULARITY_CACHEDIR=/path/to/fast_disk/.cache/singularity
# export APPTAINER_CACHEDIR="$SINGULARITY_CACHEDIR"

SIF_NAME="khanlab_hippunfold_${TAG//./_}.sif"
SIF_PATH="${OUT_DIR%/}/$SIF_NAME"
URI="docker://khanlab/hippunfold:${TAG}"

echo "Using $RUNTIME pull $URI -> $SIF_PATH"
"$RUNTIME" pull "$SIF_PATH" "$URI"
echo "Done: $SIF_PATH"
