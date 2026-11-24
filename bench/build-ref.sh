#!/bin/bash
# Build a ScanTailor Advanced revision with the PerfDriver hooks into build-<name>/.
# Usage: bench/build-ref.sh <git-ref> [name]      (ref "WORKTREE" builds the fork's working tree)
set -euo pipefail
OSX=$(cd "$(dirname "$0")/.." && pwd)
FORK=${FORK:-$OSX/../scantailor-advanced}
REF=$1
NAME=${2:-$REF}
B="$OSX/build-$NAME"
mkdir -p "$B"
if [ "$REF" = WORKTREE ]; then
  S="$FORK"
else
  S="$B/src"
  if [ ! -d "$S" ]; then git -C "$FORK" worktree add --detach "$S" "$REF" >/dev/null; fi
  git -C "$S" checkout -q --detach "$REF" 2>/dev/null || { git -C "$S" checkout -q -- . && git -C "$S" checkout -q --detach "$REF"; }
  "$OSX/bench/apply-driver.sh" "$S" >/dev/null
fi
cmake -S "$S" -B "$B/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-g -DBUILD_TESTS=OFF \
  -DCMAKE_FIND_FRAMEWORK=LAST -Wno-dev > "$B/configure.log" 2>&1
cmake --build "$B/build" -j "$(sysctl -n hw.ncpu)" > "$B/build.log" 2>&1
BIN=$(find "$B/build" -maxdepth 3 -type f \( -name scantailor-advanced -o -name scantailor \) -perm +111 | head -1)
[ -n "$BIN" ] && echo "$BIN"
