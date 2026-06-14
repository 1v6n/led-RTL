#!/usr/bin/env bash
set -euo pipefail

# Get repository root directory
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

# Choose target testbench module name (default to tb_top_led)
TARGET="${1:-tb_top_led}"

# 1. Generate simulation filelist dynamically
echo "Generating simulation filelist (sim.f) for $TARGET..."

# Find all design files in rtl/ (excluding cmod_a7_top.v)
find rtl/ -name "*.v" -not -name "cmod_a7_top.v" > sim.f

# 2. Automatically find and append the requested testbench from tb/
TB_FILE="tb/${TARGET}.v"
if [ -f "$TB_FILE" ]; then
  echo "$TB_FILE" >> sim.f
  TOP="$TARGET"
else
  echo "error: testbench file '$TB_FILE' not found." >&2
  echo "Make sure the file exists in the tb/ directory." >&2
  exit 1
fi

echo "Compiling $TOP with Verilator (native SystemVerilog mode)..."
# --binary: Compile SystemVerilog testbench directly to executable
# --trace: Enable VCD waveform dumping
# -j $(nproc): Use all available CPU cores
# -Wall: Enable linter warnings
# --top-module $TOP: Target the selected testbench
# -f sim.f: Use generated simulation filelist
verilator --binary --trace -j $(nproc) \
  -Wall \
  --top-module "$TOP" \
  -f sim.f

echo ""
echo "Running simulation..."
"./obj_dir/V$TOP"
