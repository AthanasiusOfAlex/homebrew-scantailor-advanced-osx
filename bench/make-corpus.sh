#!/bin/bash
# Render the sample PDFs in testdata/pdf into page images ScanTailor can read.
# Usage: bench/make-corpus.sh [set ...]   (default: small medium large)
set -euo pipefail
cd "$(dirname "$0")/.."
PDF=testdata/pdf
OUT=testdata/images
JOBS=${JOBS:-8}

render() { # name pdf extra-pdftoppm-args...
  local name=$1 pdf=$2; shift 2
  local dir="$OUT/$name"
  mkdir -p "$dir"
  local pages
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
  echo "$name: $pages pages from $pdf"
  seq 1 "$pages" | xargs -P "$JOBS" -I{} \
    pdftoppm -f {} -l {} -gray -tiff -tiffcompression lzw "$@" "$pdf" "$dir/page"
  echo "$name: $(ls "$dir" | wc -l | tr -d ' ') files, $(du -sh "$dir" | cut -f1)"
}

sets=("$@"); [ ${#sets[@]} -eq 0 ] && sets=(small medium large)
for s in "${sets[@]}"; do
  case $s in
    small)  render small  "$PDF/eschbach.1872.pdf"  -scale-to 3199
            # The PDF declares 72 ppi for phone-camera pages; tag them as 300 dpi scans.
            for f in "$OUT"/small/*.tif; do tiffset -s 282 300.0 "$f"; tiffset -s 283 300.0 "$f"; done ;;
    medium) render medium "$PDF/leonina.22.1.2.pdf" -r 300 ;;
    large)  render large  "$PDF/leonina.04.pdf"     -r 300 ;;
    stress) render stress "$PDF/leonina.12.pdf"     -r 300 ;;
    *) echo "unknown set: $s" >&2; exit 2 ;;
  esac
done
