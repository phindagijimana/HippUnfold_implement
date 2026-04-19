#!/usr/bin/env bash
# HippUnfold HPC helper: install (pull .sif), start (sbatch), logs, stop, checks.
# Usage: ./hip <command> [args]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$ROOT/.hip"
LAST_JOB_FILE="$STATE_DIR/last_job_id"
DEFAULT_TAG="${HIPPUNFOLD_IMAGE_TAG:-latest}"
DEFAULT_SIF="$ROOT/khanlab_hippunfold_${DEFAULT_TAG//./_}.sif"
SLURM_SCRIPT="$ROOT/slurm_hippunfold.example.slurm"

mkdir -p "$STATE_DIR"

die() { echo "hip: $*" >&2; exit 1; }

usage() {
  cat <<EOF
HippUnfold helper (Singularity/Apptainer + SLURM).

  ./hip install [TAG]     Pull container (default TAG=$DEFAULT_TAG). Sets TMPDIR/APPTAINER_* for noexec /tmp.
  ./hip start             Submit $SLURM_SCRIPT; saves job id to $LAST_JOB_FILE
  ./hip logs [-f] [JOB]   Show stderr log (default: last job). Use -f to follow.
  ./hip stop [JOB]        scancel JOB (default: last job from ./hip start)
  ./hip checks            Verify tools, image, sample BIDS, optional running jobs
  ./hip status            Short summary (last job + squeue)

Environment:
  HIPPUNFOLD_IMAGE_TAG   Tag for install and checks (default: latest)
  HIPPUNFOLD_SIF         Override .sif path for checks

EOF
}

cmd_install() {
  local tag="${1:-$DEFAULT_TAG}"
  echo "hip: pulling docker://khanlab/hippunfold:$tag ..."
  (cd "$ROOT" && HIPPUNFOLD_IMAGE_TAG="$tag" OUT_DIR="$ROOT" "$ROOT/pull_sif.sh" "$tag")
  local sif="$ROOT/khanlab_hippunfold_${tag//./_}.sif"
  [[ -f "$sif" ]] || die "expected $sif after pull"
  echo "$tag" >"$STATE_DIR/installed_tag"
  echo "hip: install ok -> $sif"
}

resolve_sif() {
  if [[ -n "${HIPPUNFOLD_SIF:-}" && -f "${HIPPUNFOLD_SIF}" ]]; then
    echo "$HIPPUNFOLD_SIF"
    return 0
  fi
  if [[ -f "$STATE_DIR/installed_tag" ]]; then
    local t
    t="$(cat "$STATE_DIR/installed_tag")"
    local candidate="$ROOT/khanlab_hippunfold_${t//./_}.sif"
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  fi
  if [[ -f "$DEFAULT_SIF" ]]; then
    echo "$DEFAULT_SIF"
    return 0
  fi
  return 1
}

cmd_start() {
  [[ -f "$SLURM_SCRIPT" ]] || die "missing $SLURM_SCRIPT"
  command -v sbatch >/dev/null 2>&1 || die "sbatch not found"
  local sif
  sif="$(resolve_sif)" || die "no .sif found — run: ./hip install [TAG] or export HIPPUNFOLD_SIF=/path/to.sif"
  local out
  out="$(cd "$ROOT" && export HIPPUNFOLD_SIF="$sif" && sbatch "$SLURM_SCRIPT")"
  echo "$out"
  local id
  id="$(echo "$out" | awk '{print $NF}')"
  [[ -n "$id" ]] || die "could not parse job id from sbatch output"
  echo "$id" >"$LAST_JOB_FILE"
  echo "hip: saved job id $id -> $LAST_JOB_FILE"
}

resolve_job() {
  local j="${1:-}"
  if [[ -z "$j" ]]; then
    [[ -f "$LAST_JOB_FILE" ]] || die "no JOB and no $LAST_JOB_FILE — pass JOB or run ./hip start"
    j="$(cat "$LAST_JOB_FILE")"
  fi
  echo "$j"
}

cmd_logs() {
  local follow=0
  if [[ "${1:-}" == "-f" ]]; then follow=1; shift; fi
  local job
  job="$(resolve_job "${1:-}")"
  local err="$ROOT/hippunfold_${job}.err"
  local out="$ROOT/hippunfold_${job}.out"
  [[ -f "$err" || -f "$out" ]] || die "no logs yet for job $job (expected $err)"
  if [[ "$follow" -eq 1 ]]; then
    tail -n 5 -f "$err" "$out"
  else
    echo "hip: --- $err (tail) ---"
    tail -n 120 "$err" 2>/dev/null || true
    echo "hip: --- $out (tail) ---"
    tail -n 40 "$out" 2>/dev/null || true
  fi
}

cmd_stop() {
  local job
  job="$(resolve_job "${1:-}")"
  command -v scancel >/dev/null 2>&1 || die "scancel not found"
  scancel "$job"
  echo "hip: scancel $job"
}

cmd_checks() {
  echo "hip: checks (ROOT=$ROOT)"
  local ok=0

  for b in apptainer singularity sbatch scancel sacct squeue; do
    if command -v "$b" >/dev/null 2>&1; then
      echo "  [ok] $b -> $(command -v "$b")"
    else
      echo "  [missing] $b"
      ok=1
    fi
  done

  local sif
  if sif="$(resolve_sif 2>/dev/null)"; then
    echo "  [ok] image $sif ($(du -h "$sif" | awk '{print $1}'))"
  else
    echo "  [missing] HippUnfold .sif — run: ./hip install [TAG] or export HIPPUNFOLD_SIF"
    ok=1
  fi

  if [[ -f "$ROOT/sample_data/dataset_description.json" ]]; then
    echo "  [ok] local BIDS under sample_data/ (not tracked by git)"
  else
    echo "  [info] no local BIDS in sample_data/ yet — see sample_data/README.md"
  fi

  if [[ -f "$LAST_JOB_FILE" ]]; then
    local jid
    jid="$(cat "$LAST_JOB_FILE")"
    echo "  [info] last ./hip start job: $jid"
    squeue -j "$jid" -h 2>/dev/null | while read -r line; do echo "  [queue] $line"; done || true
  fi

  return "$ok"
}

cmd_status() {
  cmd_checks || true
  echo "hip: recent hippunfold_*.err in $ROOT:"
  ls -1t "$ROOT"/hippunfold_*.err 2>/dev/null | head -5 || echo "  (none)"
}

main() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    install) cmd_install "$@" ;;
    start) cmd_start "$@" ;;
    logs) cmd_logs "$@" ;;
    stop) cmd_stop "$@" ;;
    checks) cmd_checks ;;
    status) cmd_status ;;
    help|-h|--help|'') usage ;;
    *) die "unknown command: $sub — try ./hip help" ;;
  esac
}

main "$@"
