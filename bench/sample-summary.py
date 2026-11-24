#!/usr/bin/env python3
"""Summarise a macOS `sample` report: inclusive samples per interesting frame, and callers of a frame.

Usage: sample-summary.py <report.txt> [caller-of-substring ...]
"""
import collections
import re
import sys

lines = open(sys.argv[1]).read().split("\n")
targets = sys.argv[2:]
pat = re.compile(r"^([ +!:|]*?)(\d+) (.+?)  \(in ([^)]+)\)")
stack = []
incl = collections.Counter()
callers = {t: collections.Counter() for t in targets}
for line in lines:
    m = pat.match(line)
    if not m:
        continue
    depth, n, func, lib = len(m.group(1)), int(m.group(2)), m.group(3), m.group(4)
    while stack and stack[-1][0] >= depth:
        stack.pop()
    name = re.sub(r"\(.*", "", func)
    if "scantailor" in lib and not any(s[1] == name for s in stack):
        incl[name] += n
    for t in targets:
        if t in func and stack:
            chain = [s[1] for s in stack if "scantailor" in s[2]][-3:]
            callers[t][" <- ".join(reversed(chain))] += n
    stack.append((depth, name, lib))
print("inclusive samples (app frames):")
for name, n in incl.most_common(28):
    print(f"{n:8d}  {name[:110]}")
for t in targets:
    print(f"\ncallers of {t}:")
    for chain, n in callers[t].most_common(6):
        print(f"{n:8d}  {chain[:200]}")
