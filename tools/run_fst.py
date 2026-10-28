#!/usr/bin/env python3
"""Run FST tests with a simulator and check the FST file with libfst.

Usage:
    python3 tools/run_fst.py [--simulator PATH] [--libfst-src DIR]
                             [-j N] [--json FILE] [TEST ...]

A test opts in with these metadata fields:

    :fst_file: wave.fst              # optional, default wave.fst
    :fst_times: 0 10 20              # optional, default start and end
    :fst_expected: @test.fst.expected

The simulator is run in a temporary directory as
`simulator <sources> <test> <args>`, the same shape as run_kirimasim.py, so a
future kirimasim FST backend can be used directly. The FST file is then read
with tools/fst_reader.py (libfst) and compared with :fst_expected:.

With no TEST arguments, runs every test that has :fst_expected:. FST is not
an IEEE 1800-2023 format; these tests are tool-format tests and are not part
of the simulation runners' normal selection.
"""

import argparse
import concurrent.futures
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import fst_reader
import suite_results

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"


def header_field(test: Path, name: str) -> str | None:
    header = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not header:
        return None
    m = re.search(rf"^:{name}:\s*(.*)$", header.group(1), re.MULTILINE)
    return m.group(1).strip() if m else None


def fst_tests(tests: list[Path]) -> list[Path]:
    return [test for test in tests if header_field(test, "fst_expected") is not None]


def expected_fst(test: Path) -> str:
    value = header_field(test, "fst_expected")
    if value is None:
        raise ValueError(f"no :fst_expected: in {test}")
    if value.startswith("@"):
        return (test.parent / value[1:]).read_text(encoding="utf-8")
    return value + "\n"


def run(test: Path, simulator: str, libfst_src: str | None) -> tuple[str, str]:
    """The status (pass, fail or unsupported) and the reason."""
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    fst_name = header_field(test, "fst_file") or "wave.fst"
    times_text = header_field(test, "fst_times")
    times = [int(t) for t in times_text.split()] if times_text else None
    with tempfile.TemporaryDirectory() as tmp:
        try:
            result = subprocess.run(
                [simulator,
                 *[f"+incdir+{d}" for d in include_dirs],
                 *[f"+define+{d}" for d in suite_results.defines(test)],
                 *([f"--top={top}"] if top else []),
                 *map(str, sources), str(test.resolve()),
                 *suite_results.run_args(test)],
                capture_output=True, text=True, errors="replace", cwd=tmp,
                timeout=120)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
        if result.returncode < 0:
            return "fail", f"crashed (signal {-result.returncode})"
        fst_path = Path(tmp) / fst_name
        if not fst_path.is_file():
            return "fail", f"no FST file {fst_name}"
        try:
            got = fst_reader.read(fst_path, times, libfst_src=libfst_src)
        except (FileNotFoundError, RuntimeError) as error:
            return "unsupported", str(error)
    want_stdout = suite_results.expected_output(test)
    if want_stdout is not None:
        norm = subprocess.run([sys.executable, str(NORMALIZE)], input=result.stdout,
                              capture_output=True, text=True).stdout
        if norm != want_stdout:
            return "fail", "standard output differs: " + suite_results.first_difference(
                norm, want_stdout)
    want = expected_fst(test)
    if got != want:
        return "fail", "FST differs: " + suite_results.first_difference(got, want)
    return "pass", ""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--simulator", default="kirimasim", help="simulator executable")
    ap.add_argument("--libfst-src", type=Path, default=None,
                    help="libfst source tree (default: $LIBFST_SRC or a development path)")
    ap.add_argument("-j", "--jobs", type=int, default=1)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.simulator)
    if exe is None:
        ap.error(f"cannot find {args.simulator}")
    exe = str(Path(exe).resolve())
    tests = fst_tests(args.tests or suite_results.find_tests())
    if not tests:
        ap.error("no tests with :fst_expected:")

    failed = unsupported = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, str(args.libfst_src) if args.libfst_src else None),
                           tests)
        for test, (status, why) in zip(tests, results):
            name = suite_results.test_id(test)
            if status == "unsupported":
                unsupported += 1
                print(f"UNSUPPORTED {name}: {why}", flush=True)
            elif status == "fail":
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[name] = (status, why)
    print(f"{len(tests) - failed - unsupported}/{len(tests)} tests match"
          + (f"; {unsupported} unsupported" if unsupported else ""))
    if args.json:
        suite_results.write(args.json, "fst", "FST (libfst)",
                            f"libfst {args.libfst_src or 'auto'}", statuses)
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    raise SystemExit(main())
