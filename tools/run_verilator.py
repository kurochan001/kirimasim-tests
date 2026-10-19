#!/usr/bin/env python3
"""Runs the tests whose expected output was recorded with Verilator and
compares each test's normalized output with its expected output.

Usage:
    python3 tools/run_verilator.py [--verilator PATH] [--seed N] [--all] [-j N]
                                   [--json FILE] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv whose `:oracle:` lists
verilator@5.052 (with --all, every test). These are tests that Icarus
Verilog 13.0 cannot compile or run; their expected outputs were recorded
with Verilator 5.052 and checked against the standard. Verilator is a
two-state simulator, so these tests do not depend on x or z values
(`:fourstate: no`). Each test is built with `verilator --binary --timing`
and run with random initial values, so a test that depended on
uninitialized values would show up as a difference.
Exits with 1 if any test does not match.

A test with `:dpi_c: @<file>.c` or `:vpi_c: @<file>.c` has C code next to it,
which is built with the model (Verilator compiles it as C++); for `:vpi_c:` the
model is also built with --vpi and --public-flat-rw.

With --all, or when a test is named, a test whose `:oracle:` does not list
verilator@5.052 is reported as a known difference when it does not match,
and does not make the run fail. With --json, the result of every test is also
written to FILE in the form that tools/suite_results.py describes.
"""

import argparse
import concurrent.futures
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
# Lines that Verilator itself prints, not the test: its banners and its run-time
# warnings, such as the one for a randomize() call whose constraints fail.
BANNER = re.compile(r"^(?:- (?:\S+:\d+: Verilog \$finish|S i m u l a t i o n|Verilator: )|%Warning-)")


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


def c_source(test: Path, name: str) -> Path | None:
    value = header_field(test, name)
    if value is None:
        return None
    return (test.parent / value.removeprefix("@")).resolve()


def run(test: Path, verilator: str, seed: int) -> tuple[bool, str]:
    extra = []
    dpi, vpi = c_source(test, "dpi_c"), c_source(test, "vpi_c")
    if dpi is not None:
        extra.append(str(dpi))
    if vpi is not None:
        extra += ["--vpi", "--public-flat-rw", str(vpi)]
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run([verilator, "--binary", "--timing", "-Wno-fatal", "-Wno-lint",
                            "-Wno-style", "--x-assign", "unique", "--x-initial", "unique",
                            "-Mdir", str(obj), "--prefix", "Vt", str(test), *extra],
                           capture_output=True, text=True, errors="replace")
        if b.returncode != 0:
            err = [l for l in b.stderr.splitlines() if l.startswith("%Error")]
            return False, "build failed: " + (err[0] if err else "")
        try:
            r = subprocess.run([str(obj / "Vt"), "+verilator+rand+reset+2",
                                f"+verilator+seed+{seed}"], capture_output=True, text=True,
                               errors="replace", cwd=tmp, timeout=60)
        except subprocess.TimeoutExpired:
            return False, "timed out"
    raw = "".join(l + "\n" for l in r.stdout.splitlines() if not BANNER.match(l))
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=raw,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    if norm == want:
        return True, ""
    return False, "output differs: " + suite_results.first_difference(norm, want)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--verilator", default="verilator", help="verilator executable")
    ap.add_argument("--seed", type=int, default=1, help="seed for random initial values")
    ap.add_argument("--all", action="store_true",
                    help="run every test, not only those recorded with Verilator")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = args.tests or [t for t in sorted((ROOT / "tests").rglob("*.sv"))
                           if args.all
                           or "verilator@5.052" in (header_field(t, "oracle") or "").split()]
    failed = known = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, args.verilator, args.seed), tests)
        for t, (ok, why) in zip(tests, results):
            name = t.relative_to(ROOT) if t.is_absolute() else t
            verilator_oracle = "verilator@5.052" in (header_field(t, "oracle") or "").split()
            if not verilator_oracle:
                known += 1
                if not ok:
                    print(f"KNOWN {name}: the expected output is not from Verilator 5.052",
                          flush=True)
            elif not ok:
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[suite_results.test_id(t)] = (
                "pass" if ok else "fail" if verilator_oracle else "known", why)
    print(f"{len(tests) - known - failed}/{len(tests) - known} tests match"
          + (f"; {known} other tests not counted" if known else ""))
    if args.json:
        suite_results.write(args.json, "verilator", "Verilator",
                            suite_results.tool_version([args.verilator, "--version"]), statuses)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
