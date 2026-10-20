#!/usr/bin/env python3
"""Normalizes a simulator's standard output before comparing it with a
test's expected output.

Reads standard input and writes standard output. It removes:

* empty lines, and
* the line Icarus Verilog prints when $finish runs
  ("<file>:<line>: $finish called at <time> (<unit>)", or "$finish(<n>)"
  when it has an argument).

Everything else is kept exactly. Runners for other simulators should strip
their own banners the same way before comparing.
"""

import re
import sys

FINISH = re.compile(r"^\S+:\d+: \$finish(?:\(\d\))? called at \d+ \(\d*\w*s\)$")


def main() -> int:
    for line in sys.stdin:
        text = line.rstrip("\n")
        if not text.strip() or FINISH.match(text):
            continue
        sys.stdout.write(text + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
