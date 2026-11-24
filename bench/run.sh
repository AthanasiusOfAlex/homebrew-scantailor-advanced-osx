#!/bin/bash
# Run one PerfDriver script against a build. Prints the CSV lines.
# Usage: bench/run.sh <build-name> <label> <script>
set -euo pipefail
OSX=$(cd "$(dirname "$0")/.." && pwd)
NAME=$1 LABEL=$2 SCRIPT=$3
BIN=$(find "$OSX/build-$NAME/build" -maxdepth 3 -type f \( -name scantailor-advanced -o -name scantailor \) -perm +111 | head -1)
mkdir -p "$OSX/bench-results"
OUT="$OSX/bench-results/$NAME.$LABEL.csv"
: > "$OUT"
SCANTAILOR_PERF_SCRIPT="$SCRIPT" SCANTAILOR_PERF_OUT="$OUT" SCANTAILOR_PERF_TIMEOUT=${TIMEOUT:-3600} \
  "$BIN" -NSAppSleepDisabled "${NAP_DISABLED:-YES}" > "$OSX/bench-results/$NAME.$LABEL.log" 2>&1 || echo "exit code $?"
cat "$OUT"
