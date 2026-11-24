#!/usr/bin/env python3
"""Write a copy of a .ScanTailor project whose directories point at a new location.

Usage: relocate-project.py <project.ScanTailor> <old-root> <new-root> <out.ScanTailor>
Both slash styles of <old-root> are replaced. The original file is not modified.
"""
import sys

src, old, new, dst = sys.argv[1:5]
text = open(src, encoding="utf-8").read()
old_fwd = old.replace("\\", "/").rstrip("/")
old_back = old_fwd.replace("/", "\\")
new = new.rstrip("/")
count = text.count(old_fwd) + text.count(old_back)
text = text.replace(old_fwd, new)
# Windows-style remainders such as "\book\out" become POSIX paths.
out = []
for line in text.split("\n"):
    while old_back in line:
        start = line.index(old_back)
        end = line.index('"', start)
        line = line[:start] + new + line[start + len(old_back):end].replace("\\", "/") + line[end:]
    out.append(line)
open(dst, "w", encoding="utf-8").write("\n".join(out))
print(f"{count} path(s) rewritten -> {dst}")
