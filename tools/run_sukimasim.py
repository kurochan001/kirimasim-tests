#!/usr/bin/env python3
"""Runs the test suite with sukimasim and compares each test's normalized
output with its expected output.

Usage:
    python3 tools/run_sukimasim.py [--sukimasim PATH] [--include DIR]
                                   [--strip-diagnostics] [-j N] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. No expected output was recorded with sukimasim, so every test
counts.

Each test is run in its own temporary directory with --quiet --quiet-stats
--quiet-exit and SUKIMASIM_FINISH_STRICT_MODE=1. sukimasim still prints lines
of its own on standard output, which are removed before comparing: everything
from "[sukimasim] Simulation completed" on (its statistics and a "TEST PASSED"
line), the lines that its --diff option ignores, and "$finish called at
simulation time N". "TEST PASSED" is not removed anywhere else, because many
tests print it themselves. With --strip-diagnostics the messages that sukimasim
prints while it runs, such as "[TIMING] ..." or "Cover point hit at time N",
are removed too.

A test with `:dpi_c: @<file>.c` or `:vpi_c: @<file>.c` has C code next to it,
which is built into a shared library with $CC (default cc) against sukimasim's
include directory and loaded with --lib. sukimasim has no sv_vpi_user.h, and
its vpi_user.h declares that API itself, so the runner provides an
sv_vpi_user.h that includes vpi_user.h.
"""

import argparse
import concurrent.futures
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
# sukimasim's statistics and its own "TEST PASSED" follow this line.
TRAILER = "[sukimasim] Simulation completed"
# Lines that sukimasim itself prints, not the test: the prefixes that its --diff
# option ignores (except "TEST PASSED"), the lines it prints when it loads a VPI
# application, and its $finish messages.
BANNER = re.compile(
    r"^(?:\[(?:INFO\] \[SUKIMASIM|COVERAGE|DIFF|PREPROCESS|UVM_INFO|CONFIG|WARNING"
    r"|CODE COVERAGE|SEED-SWEEP|SEED|SystemC|CHECKPOINT|ASSERTION|RUNTIME|TRACE|PROFILE"
    r"|sukimasim)\]|Parsing successful|Converted module|Parsed "
    r"|SystemTaskRegistry: Registered |VPI: Processed |VPIIRBridge: TestbenchRuntime connected"
    r"|\$finish called at simulation time \d+|V C S   S i m u l a t i o n   R e p o r t$"
    r"|Time: \d+ time units$)")
# Messages that sukimasim prints while it runs, removed with --strip-diagnostics.
DIAGNOSTIC = re.compile(
    r"^(?:\[IEEE1800-§24\] Program block |\[TIMING\] |\[COMB_EVAL\] |\[CONSTRAINT_MODE\] "
    r"|\w+ check for .*\): delta=|setup/hold aggregate for .*\): setup_delta="
    r"|(?:skew|timeskew|fullskew|nochange) check: |Cover point hit at time \d+$"
    r"|Registered covergroup: |Coverage database saved to: "
    r"|Merging with existing coverage database: "
    r"|Fork-join_(?:none|any) block |MCD: |VPI: |Warning: Invalid (?:hex|binary) value in )")
ANSI = re.compile(r"\x1b\[[0-9;]*m")


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


def run(test: Path, sukimasim: str, include: Path | None, diagnostics: bool) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory() as tmp:
        lib = []
        source = c_source(test, "dpi_c") or c_source(test, "vpi_c")
        if source is not None:
            if include is None:
                return False, "C build failed: no include directory of sukimasim (see --include)"
            (Path(tmp) / "sv_vpi_user.h").write_text('#include "vpi_user.h"\n')
            so = Path(tmp) / "libtest.so"
            # The VPI and DPI routines are defined by the sukimasim executable that
            # loads the library; the macOS linker needs to be told to leave them
            # unresolved until then.
            undefined = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            b = subprocess.run([os.environ.get("CC", "cc"), "-shared", "-fPIC", *undefined,
                                "-o", str(so), str(source), f"-I{include}",
                                f"-I{include / 'sukimasim' / 'vpi'}", f"-I{tmp}"],
                               capture_output=True, text=True)
            if b.returncode != 0:
                err = [l for l in b.stderr.splitlines() if "error:" in l]
                return False, "C build failed: " + (err[0] if err else "")
            lib = ["--lib", str(so)]
        try:
            r = subprocess.run([sukimasim, "--quiet", "--quiet-stats", "--quiet-exit",
                                "--wall-timeout", "60", *lib, str(test.resolve())],
                               capture_output=True, text=True, errors="replace", cwd=tmp,
                               env=dict(os.environ, SUKIMASIM_FINISH_STRICT_MODE="1"), timeout=90)
        except subprocess.TimeoutExpired:
            return False, "timed out"
    kept = []
    for line in r.stdout.splitlines():
        if line.startswith(TRAILER):
            break
        if not BANNER.match(line) and not (diagnostics and DIAGNOSTIC.match(line)):
            kept.append(line + "\n")
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input="".join(kept),
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    if norm == want:
        return True, ""
    if r.returncode < 0:
        return False, f"crashed (signal {-r.returncode})"
    err = [ANSI.sub("", l) for l in r.stderr.splitlines() if re.search(r"error", l, re.I)]
    if r.returncode in (1, 255) and not norm:
        return False, "compile failed: " + (err[0] if err else "")
    return False, "output differs" + (f" (exit {r.returncode}): {err[0]}" if err else "")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--sukimasim", default="sukimasim", help="sukimasim executable")
    ap.add_argument("--include", type=Path, default=None,
                    help="sukimasim's include directory, for tests with C code "
                         "(default: ../include from the directory of the executable)")
    ap.add_argument("--strip-diagnostics", action="store_true",
                    help="also remove the messages that sukimasim prints while it runs")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.sukimasim)
    if exe is None:
        ap.error(f"cannot find {args.sukimasim}")
    include = args.include
    if include is None:
        guess = Path(exe).resolve().parent.parent / "include"
        include = guess if (guess / "svdpi.h").is_file() else None

    tests = args.tests or sorted((ROOT / "tests").rglob("*.sv"))
    failed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, include, args.strip_diagnostics), tests)
        for t, (ok, why) in zip(tests, results):
            if not ok:
                failed += 1
                name = t.relative_to(ROOT) if t.is_absolute() else t
                print(f"FAIL {name}: {why}", flush=True)
    print(f"{len(tests) - failed}/{len(tests)} tests match")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
