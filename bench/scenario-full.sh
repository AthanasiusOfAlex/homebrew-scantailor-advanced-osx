#!/bin/bash
# Full scenario for one build and one image set:
#   pass 1 (label <set>.batch):  new project, batch every stage in turn, save
#   pass 2 (label <set>.reopen): reopen the saved project, switch through every stage twice
# Usage: bench/scenario-full.sh <build-name> <set>
set -euo pipefail
OSX=$(cd "$(dirname "$0")/.." && pwd)
NAME=$1 SET=$2
T="$OSX/testdata"
W="$T/work/$NAME/$SET"
rm -rf "$W"; mkdir -p "$W"
S="new=$T/images/$SET,$W/out;settle"
for i in 0 1 2 3 4 5; do S="$S;stage=$i;settle;batch;settle"; done
S="$S;save=$W/project.ScanTailor;quit"
"$OSX/bench/run.sh" "$NAME" "$SET.batch" "$S"
S="open=$W/project.ScanTailor;settle"
for i in 1 2 3 4 5 0 5 4 3; do S="$S;stage=$i;settle"; done
"$OSX/bench/run.sh" "$NAME" "$SET.reopen" "$S;quit"
