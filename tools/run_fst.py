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

The exit code of the simulator must be 0, or what :expected_exit: says, and
its messages must match :expected_stderr_regex: when the test has one, as for
the simulation runners. --json records the fingerprint of the inputs of each
test and of this runner, as the other runners do, and the digest of the FST
reader (tools/fst_reader.py and tools/fst_read.c) in "configuration".

With no TEST arguments, runs every test that has :fst_expected:. FST is not
an IEEE 1800-2023 format; these tests are tool-format tests and are not part
of the simulation runners' normal selection.
"""

import argparse
import concurrent.futures
import hashlib
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
        normalized = subprocess.run([sys.executable, str(NORMALIZE)], input=result.stdout,
                                    capture_output=True, text=True, encoding="utf-8")
        if normalized.returncode != 0:
            # Its empty output would match an empty expected output.
            return "fail", f"normalize_output.py failed (exit code {normalized.returncode})"
        norm = normalized.stdout
        if norm != want_stdout:
            return "fail", "standard output differs: " + suite_results.first_difference(
                norm, want_stdout)
    want = expected_fst(test)
    if got != want:
        return "fail", "FST differs: " + suite_results.first_difference(got, want)
    # A simulator that ends with an error did not pass, whatever it wrote
    # before, unless the test expects that exit code.
    if header_field(test, "expected_exit") is None and result.returncode != 0:
        return "fail", f"exit code {result.returncode}, expected 0"
    why = suite_results.judge_run(test, result.returncode, result.stderr)
    return ("fail" if why else "pass"), why


def reader_digest() -> str:
    """The digest of the FST reader, which judges with this runner but is not
    in suite_results.runner_digest."""
    digest = hashlib.sha256()
    for name in ("fst_reader.py", "fst_read.c"):
        digest.update(name.encode() + b"\0")
        digest.update((ROOT / "tools" / name).read_bytes())
    return digest.hexdigest()


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
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("fst") if args.json else None
    reader_hash = reader_digest() if args.json else None

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
                            f"libfst {args.libfst_src or 'auto'}", statuses,
                            inputs=inputs, runner_sha256=runner_hash,
                            configuration={"fst_reader_sha256": reader_hash,
                                           "fst_reader_changed": reader_hash != reader_digest()})
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    raise SystemExit(main())
