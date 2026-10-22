#!/usr/bin/env python3
"""Runs the test suite with Icarus Verilog and compares each test's
normalized output with its expected output.

Usage:
    python3 tools/run_icarus.py [--iverilog-bin DIR] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. The expected outputs were recorded with Icarus Verilog 13.0
(`:oracle:` lists iverilog@13.0), so other versions may differ.

A test whose `:oracle:` does not list iverilog@13.0 has an expected output
that Icarus Verilog 13.0 does not produce, because Icarus Verilog does not
follow the standard there or cannot compile the test (such a test lists
verilator@5.052 instead; see tools/run_verilator.py). Such a test is
reported as a known difference and does not make the run fail, or as NOW
MATCHES when it matches. An illegal design that Icarus Verilog 13.0 rejects at
the place the test names only because it does not support a construct there
shows as NOW MATCHES as well; the comment of the test says so.

A test with `:vpi_c: @<file>.c` has a VPI application next to it: the file is
built with iverilog-vpi and loaded with vvp -m. Icarus Verilog has no DPI, so a
test with `:dpi_c:` does not compile and lists another oracle.

A test with `:should_fail_because:` is an illegal design, which matches when
iverilog rejects it with an error at the place `:expected_stderr_regex:`
names. The sources and include files of `:files:` are passed to iverilog, the
macros of `:defines:` as -D, the directories of `:incdirs:` as -I and the
module of `:top_module:` as -s, the arguments of `:args:` to vvp, and the exit
code and messages of vvp are
checked against `:expected_exit:` and `:expected_stderr_regex:` (see
tools/suite_results.py). The messages of the severity tasks, such as $error,
are removed from the output before it is compared.

With --json, the result of every test is also written to FILE in the form
that tools/suite_results.py describes.
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
# The messages of the severity tasks (IEEE 1800-2023 20.10), whose form the
# standard leaves to the tool: Icarus Verilog prints "ERROR: <file>:<line>:
# <message>" and then a line with the time and the scope.
SEVERITY = re.compile(r"^(?:(?:INFO|WARNING|ERROR|FATAL): \S+:\d+: |\s+Time: \d+\s+Scope: )")
# This diagnostic announces the output file; it is not part of the HDL output.
VCD_BANNER = re.compile(r"^VCD info: dumpfile .+ opened for output\.$")


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


def run(test: Path, bindir: Path | None) -> tuple[bool, str]:
    iverilog = str(bindir / "iverilog") if bindir else "iverilog"
    vvp = str(bindir / "vvp") if bindir else "vvp"
    sources, include_dirs = suite_results.files(test)
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "a.vvp"
        vvp_args = []
        vpi = c_source(test, "vpi_c")
        if vpi is not None:
            b = subprocess.run([str(bindir / "iverilog-vpi") if bindir else "iverilog-vpi",
                                "--name=app", str(vpi)], capture_output=True, text=True, cwd=tmp)
            if b.returncode != 0:
                return False, "VPI build failed: " + (b.stderr.strip().splitlines() or [""])[-1]
            vvp_args = ["-M", tmp, "-mapp"]
        # Without -gspecify Icarus Verilog ignores specify blocks, and without
        # -ginterconnect it cannot annotate SDF interconnect delays.
        top = suite_results.top_module(test)
        c = subprocess.run([iverilog, "-g2012", "-gspecify", "-ginterconnect",
                            *[f"-I{d}" for d in include_dirs],
                            *[f"-D{d}" for d in suite_results.defines(test)],
                            *(["-s", top] if top else []), "-o", str(out),
                            *map(str, sources), str(test)],
                           capture_output=True, text=True)
        if header_field(test, "should_fail_because") is not None:
            return suite_results.judge_illegal(test, c.returncode == 0, c.stdout + c.stderr)
        if c.returncode != 0:
            return False, "compile failed: " + c.stderr.strip().splitlines()[0]
        try:
            r = subprocess.run([vvp, *vvp_args, str(out), *suite_results.run_args(test)],
                               capture_output=True, text=True, errors="replace", cwd=tmp,
                               timeout=60)
        except subprocess.TimeoutExpired:
            return False, "timed out"
    raw = "".join(l + "\n" for l in r.stdout.splitlines()
                  if not SEVERITY.match(l) and not VCD_BANNER.match(l))
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
    ap.add_argument("--iverilog-bin", type=Path, default=None,
                    help="directory that contains iverilog and vvp (default: PATH)")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    if args.iverilog_bin:
        args.iverilog_bin = args.iverilog_bin.resolve()   # iverilog-vpi runs in another directory
    tests = args.tests or suite_results.find_tests()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("icarus") if args.json else None
    failed = known = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, args.iverilog_bin), tests)
        for t, (ok, why) in zip(tests, results):
            name = t.relative_to(ROOT) if t.is_absolute() else t
            icarus_oracle = "iverilog@13.0" in (header_field(t, "oracle") or "").split()
            if not icarus_oracle:
                known += 1
                print(f"{'KNOWN' if not ok else 'NOW MATCHES'} {name}: "
                      f"the expected output is not from Icarus Verilog 13.0", flush=True)
            elif not ok:
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[suite_results.test_id(t)] = (
                "pass" if ok else "fail" if icarus_oracle else "known", why)
    print(f"{len(tests) - known - failed}/{len(tests) - known} tests match"
          + (f"; {known} known differences not counted" if known else ""))
    if args.json:
        iverilog = str(args.iverilog_bin / "iverilog") if args.iverilog_bin else "iverilog"
        suite_results.write(args.json, "icarus", "Icarus Verilog",
                            suite_results.tool_version([iverilog, "-V"]), statuses,
                            inputs=inputs, runner_sha256=runner_hash)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
