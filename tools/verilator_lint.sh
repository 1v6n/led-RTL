#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

FILELIST="${VERILATOR_FILELIST:-files.f}"
TOP="${VERILATOR_TOP:-top_led}"

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator not found in PATH" >&2
  exit 127
fi

if [[ ! -f "$FILELIST" ]]; then
  echo "error: Verilator filelist not found: $FILELIST" >&2
  exit 1
fi

verilator \
  --lint-only \
  -Wall \
  -sv \
  --timing \
  --top-module "$TOP" \
  -f "$FILELIST"