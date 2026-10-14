#!/usr/bin/env python3
"""Runs the test suite with Icarus Verilog and compares each test's
normalized output with its expected output.

Usage:
    python3 tools/run_icarus.py [--iverilog-bin DIR] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. The expected outputs were recorded with Icarus Verilog 13.0
(`:oracle:` lists iverilog@13.0), so other versions may differ.
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"


def expected_output(test: Path) -> str | None:
    text = test.read_text(encoding="utf-8")
    header = re.search(r"/\*(.*?)\*/", text, re.DOTALL)
    if not header:
        return None
    m = re.search(r"^:expected_stdout:\s*(.*)$", header.group(1), re.MULTILINE)
    if not m:
        return None
    value = m.group(1).strip()
    if value.startswith("@"):
        return (test.parent / value[1:]).read_text(encoding="utf-8")
    return value + "\n"


def run(test: Path, bindir: Path | None) -> tuple[bool, str]:
    iverilog = str(bindir / "iverilog") if bindir else "iverilog"
    vvp = str(bindir / "vvp") if bindir else "vvp"
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "a.vvp"
        c = subprocess.run([iverilog, "-g2012", "-o", str(out), str(test)],
                           capture_output=True, text=True)
        if c.returncode != 0:
            return False, "compile failed: " + c.stderr.strip().splitlines()[0]
        r = subprocess.run([vvp, str(out)], capture_output=True, text=True, cwd=tmp,
                           timeout=60)
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=r.stdout,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    return (norm == want), ("" if norm == want else "output differs")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--iverilog-bin", type=Path, default=None,
                    help="directory that contains iverilog and vvp (default: PATH)")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = args.tests or sorted((ROOT / "tests").rglob("*.sv"))
    failed = 0
    for t in tests:
        ok, why = run(t, args.iverilog_bin)
        if not ok:
            failed += 1
            print(f"FAIL {t.relative_to(ROOT) if t.is_absolute() else t}: {why}")
    print(f"{len(tests) - failed}/{len(tests)} tests match")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
