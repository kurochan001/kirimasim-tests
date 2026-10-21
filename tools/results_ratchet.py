#!/usr/bin/env python3
"""Compares the results of a simulator with those of its previous run and
lists the tests that matched then and differ now.

Usage:
    python3 tools/results_ratchet.py PREVIOUS.json CURRENT.json

Each file is the --json result of a runner (see tools/suite_results.py), or
the latest/<simulator>.json that tools/results_history.py keeps on the results
branch, which maps each test to its status alone. A test whose status was pass
in PREVIOUS and is fail in CURRENT is a regression, printed as
"REGRESSION <test>: <reason>"; the script then exits with 1. Nothing else counts: tests that are new or gone, tests that are
unsupported or known differences now, and tests that did not match before.
"""

import argparse
import json
import sys
from pathlib import Path


def statuses(path: Path) -> dict[str, tuple[str, str]]:
    """The status and the reason of each test."""
    tests = json.loads(path.read_text(encoding="utf-8"))["tests"]
    return {t: (r, "") if isinstance(r, str) else (r["status"], r.get("reason", ""))
            for t, r in tests.items()}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("previous", type=Path)
    ap.add_argument("current", type=Path)
    args = ap.parse_args()

    previous, current = statuses(args.previous), statuses(args.current)
    regressions = sorted(t for t, (status, _) in current.items()
                         if status == "fail" and previous.get(t, ("", ""))[0] == "pass")
    for t in regressions:
        print(f"REGRESSION {t}: {current[t][1]}")
    matched = sum(status == "pass" for status, _ in previous.values())
    print(f"{len(regressions)} of the {matched} tests that matched before differ now")
    return 1 if regressions else 0


if __name__ == "__main__":
    sys.exit(main())
