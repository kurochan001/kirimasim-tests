#!/usr/bin/env python3
"""Runs the test suite with kirimasim and compares each test's normalized
output with its expected output.

Usage:
    python3 tools/run_kirimasim.py [--kirimasim PATH] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. No expected output was recorded with kirimasim, so every test
counts.

Each test runs in its own temporary directory as `kirimasim <test>.sv`.
kirimasim writes only what the design prints to standard output and its own
messages to standard error, so nothing more than what
tools/normalize_output.py removes is removed. A test that uses a construct
kirimasim does not support yet, which it reports with exit code 2 and an
"error: unsupported:" message, is reported as unsupported. kirimasim cannot
load C code yet, so the tests with `:dpi_c:` or `:vpi_c:` are reported as
unsupported without running them.

With --json, the result of every test is also written to FILE in the form
that tools/suite_results.py describes.
"""

import argparse
import concurrent.futures
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
UNSUPPORTED = re.compile(r"error: unsupported: (.*)")


def header_field(test: Path, name: str) -> str | None:
    header = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not header:
        return None
    m = re.search(rf"^:{name}:\s*(.*)$", header.group(1), re.MULTILINE)
    return m.group(1).strip() if m else None


def expected_output(test: Path) -> str | None:
    value = header_field(test, "expected_stdout")
    if value is None:
        return None
    if value.startswith("@"):
        return (test.parent / value[1:]).read_text(encoding="utf-8")
    return value + "\n"


def run(test: Path, kirimasim: str) -> tuple[str, str]:
    """The status of the test (pass, fail or unsupported) and the reason."""
    if header_field(test, "dpi_c") is not None or header_field(test, "vpi_c") is not None:
        return "unsupported", "kirimasim cannot load C code yet"
    with tempfile.TemporaryDirectory() as tmp:
        try:
            r = subprocess.run([kirimasim, str(test.resolve())], capture_output=True, text=True,
                               errors="replace", cwd=tmp, timeout=120)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=r.stdout,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return "fail", "no :expected_stdout:"
    if norm == want:
        return "pass", ""
    unsupported = UNSUPPORTED.search(r.stderr)
    if r.returncode == 2 and unsupported:
        return "unsupported", unsupported.group(1).strip()
    if r.returncode < 0:
        return "fail", f"crashed (signal {-r.returncode})"
    err = [l for l in r.stderr.splitlines() if ": error: " in l or ": fatal: " in l]
    return "fail", "output differs" + (f" (exit {r.returncode})" if r.returncode else "") + (
        f": {err[0].split(': ', 1)[-1]}" if err
        else ": " + suite_results.first_difference(norm, want))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--kirimasim", default="kirimasim", help="kirimasim executable")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.kirimasim)
    if exe is None:
        ap.error(f"cannot find {args.kirimasim}")
    exe = str(Path(exe).resolve())   # the tests run in other directories

    tests = args.tests or sorted((ROOT / "tests").rglob("*.sv"))
    failed = unsupported = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe), tests)
        for t, (status, why) in zip(tests, results):
            name = t.relative_to(ROOT) if t.is_absolute() else t
            if status == "unsupported":
                unsupported += 1
                print(f"UNSUPPORTED {name}: {why}", flush=True)
            elif status == "fail":
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[suite_results.test_id(t)] = (status, why)
    print(f"{len(tests) - failed - unsupported}/{len(tests)} tests match"
          + (f"; {unsupported} use what kirimasim does not support yet" if unsupported else ""))
    if args.json:
        suite_results.write(args.json, "kirimasim", "kirimasim",
                            suite_results.tool_version([exe, "--version"]), statuses)
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
