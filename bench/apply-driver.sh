#!/bin/bash
# Add the PerfDriver hooks to a ScanTailor Advanced source tree at any revision.
# Idempotent. Usage: bench/apply-driver.sh <srcdir> [ref-holding-PerfDriver]
set -euo pipefail
SRC=$1
FORK=${FORK:-$(cd "$(dirname "$0")/../../scantailor-advanced" && pwd)}
cd "$SRC"
for f in PerfDriver.h PerfDriver.cpp; do
  if [ "$(git rev-parse --show-toplevel)" != "$(git -C "$FORK" rev-parse --show-toplevel 2>/dev/null)" ]; then cp "$FORK/src/app/$f" "src/app/$f"; fi
done
grep -q 'friend class PerfDriverImpl' src/app/MainWindow.h ||
  perl -0pi -e 's/(  Q_OBJECT\n)/$1  friend class PerfDriverImpl;\n/' src/app/MainWindow.h
grep -q 'PerfDriver.h' src/app/main.cpp ||
  perl -0pi -e 's/(#include "MainWindow.h"\n)/$1#include "PerfDriver.h"\n/; s/if \(args\.size\(\) > 1\) \{/if (!PerfDriver::installIfRequested(mainWnd) && (args.size() > 1)) {/' src/app/main.cpp
grep -q 'PerfDriver.cpp' src/app/CMakeLists.txt ||
  perl -0pi -e 's/(    main\.cpp\n)/$1    PerfDriver.cpp PerfDriver.h\n/' src/app/CMakeLists.txt
# Older revisions miss includes that current compilers require.
grep -q "<QObject>" src/core/Utils.h || perl -0pi -e 's/(#include <QString>\n)/$1#include <QObject>\n/' src/core/Utils.h
[ -f src/foundation/Proximity.h ] && ! grep -q '<algorithm>' src/foundation/Proximity.h &&
  perl -0pi -e 's/(#include <cmath>\n)/$1#include <algorithm>\n/' src/foundation/Proximity.h
grep -q 'PerfDriver' src/app/MainWindow.h && grep -q 'installIfRequested' src/app/main.cpp && grep -q 'PerfDriver.cpp' src/app/CMakeLists.txt
