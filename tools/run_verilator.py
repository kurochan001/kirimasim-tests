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
(`:fourstate: no`). Each test is built with `verilator --binary --timing
--coverage-user`, without which Verilator does not run cover statements, and
run with random initial values, so a test that depended on uninitialized
values would show up as a difference. With OBJCACHE=ccache in the
environment, the makefile of each model compiles through ccache, so the
runtime library of Verilator, the same for every test, is compiled only once.
Exits with 1 if any test does not match.

A test with `:dpi_c: @<file>.c` or `:vpi_c: @<file>.c` has C code next to it,
which is built with the model (Verilator compiles it as C++); for `:vpi_c:` the
model is also built with --vpi and --public-flat-rw.

A test with `:should_fail_because:` is an illegal design, which matches when
Verilator rejects it with an error at the place `:expected_stderr_regex:`
names. The sources and include files of `:files:` are passed to verilator,
the arguments of `:args:` to the model, and the exit code and messages of the
model are checked against `:expected_exit:` and `:expected_stderr_regex:`
(see tools/suite_results.py). The model runs with
+verilator+error+limit+1000000, so that $error does not stop it, and the
messages of the severity tasks are removed from the output before it is
compared.

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
# Lines that Verilator itself prints, not the test: its banners, its run-time
# warnings, such as the one for a randomize() call whose constraints fail, and
# the messages of the severity tasks (IEEE 1800-2023 20.10), whose form the
# standard leaves to the tool, such as "[0] %Error: <file>:<line>: ...", with
# the lines it prints when $fatal ends the run.
BANNER = re.compile(r"^(?:- (?:\S+:\d+: Verilog \$finish|S i m u l a t i o n|Verilator: )|%Warning-"
                    r"|\[\d+\] (?:-Info|%Warning|%Error|%Fatal): "
                    r"|(?:-Info|%Error): \S+:\d+: Verilog \$stop|Aborting\.\.\.$)")
# Verilator stops the run at the first $error unless told to allow more; the
# standard has $error report the error and the run go on (20.10).
ERROR_LIMIT = 1000000


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
    sources, include_dirs = suite_results.files(test)
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run([verilator, "--binary", "--timing", "--coverage-user", "-Wno-fatal",
                            "-Wno-lint", "-Wno-style", "--x-assign", "unique", "--x-initial", "unique",
                            *[f"-I{d}" for d in include_dirs], "-Mdir", str(obj),
                            "--prefix", "Vt", *map(str, sources), str(test), *extra],
                           capture_output=True, text=True, errors="replace")
        if header_field(test, "should_fail_because") is not None:
            return suite_results.judge_illegal(test, b.returncode == 0, b.stdout + b.stderr)
        if b.returncode != 0:
            err = [l for l in b.stderr.splitlines() if l.startswith("%Error")]
            return False, "build failed: " + (err[0] if err else "")
        try:
            r = subprocess.run([str(obj / "Vt"), "+verilator+rand+reset+2",
                                f"+verilator+seed+{seed}", f"+verilator+error+limit+{ERROR_LIMIT}",
                                *suite_results.run_args(test)],
                               capture_output=True, text=True, errors="replace", cwd=tmp,
                               timeout=60)
        except subprocess.TimeoutExpired:
            return False, "timed out"
    raw = "".join(l + "\n" for l in r.stdout.splitlines() if not BANNER.match(l))
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=raw,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    if norm != want:
        return False, "output differs: " + suite_results.first_difference(norm, want)
    why = suite_results.judge_run(test, r.returncode, r.stdout + r.stderr)
    return not why, why


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

    tests = args.tests or [t for t in suite_results.find_tests()
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
