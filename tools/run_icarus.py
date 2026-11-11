#!/usr/bin/env python3
"""Runs the test suite with Icarus Verilog and compares each test's
normalized output with its expected output.

Usage:
    python3 tools/run_icarus.py [--iverilog-bin DIR] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every test whose :type: is not formal. A formal
test belongs to tools/run_sby.py and has no expected output. Exits with 1 if
any test does not match. The expected outputs were recorded with Icarus
Verilog 13.0
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

A run that a signal ends fails even when it printed the expected output, and
a compiler that a signal ends did not reject an illegal design;
a step that takes longer than its time limit fails as "timed out". An
error of this script fails only the test it happened in. A reason names no
directory of the machine (see neutral()).

With --json, the result of every test is also written to FILE in the form
that tools/suite_results.py describes.
"""

import argparse
import concurrent.futures
import functools
import os
import re
import shutil
import signal
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
# The seconds that iverilog-vpi, iverilog and vvp may take for one test. A
# build takes a few seconds at most, so a longer one hangs.
VPI_BUILD_TIMEOUT = 300
COMPILE_TIMEOUT = 300
RUN_TIMEOUT = 60
# The shortest beginning of a directory that neutral() takes for a cut path.
CUT = 8


def header_field(test: Path, name: str) -> str | None:
    header = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not header:
        return None
    m = re.search(rf"^:{name}:\s*(.*)$", header.group(1), re.MULTILINE)
    return m.group(1).strip() if m else None


def expected_output(test: Path) -> str | None:
    return suite_results.expected_output(test, "icarus")


def simulation_tests(tests: list[Path]) -> list[Path]:
    """The tests that a simulator runs. A test with :type: formal names a
    :formal_case: and belongs to tools/run_sby.py; it has no expected output,
    so counting it as a simulation failure would be wrong."""
    return [test for test in tests if header_field(test, "type") != "formal"]


def c_source(test: Path, name: str) -> Path | None:
    value = header_field(test, name)
    if value is None:
        return None
    return (test.parent / value.removeprefix("@")).resolve()


def neutral(text: str, tmp: str | None = None, prefix: Path | None = None) -> str:
    """A reason without the directories of this machine, so that the results
    can be published and compared between machines: a path under the
    repository becomes relative to it, and the temporary directory of the
    test and the directory for temporary files become <tmp>, the directory
    Icarus Verilog is installed in <icarus> and the home directory <home>.
    The longest directory is replaced first, as one may lie in another. A
    simulator may cut a long file name short in a message; what is left of a
    directory then, CUT characters or more before a space, a quote, "..." or
    the end of a line, becomes <path>."""
    places = [(str(ROOT) + os.sep, ""), (str(ROOT), ".")]
    for path, name in ((tmp, "<tmp>"), (tempfile.gettempdir(), "<tmp>"),
                       (prefix, "<icarus>"), (Path.home(), "<home>")):
        if path is not None:
            places += [(p, name) for p in {str(path), os.path.realpath(path)} if len(p) > 1]
    places.sort(key=lambda place: -len(place[0]))
    for path, name in places:
        text = text.replace(path, name)
    for path, _ in places:
        if len(path) > CUT and path[:CUT] in text:
            text = cut_path(path).sub("<path>", text)
    return text


@functools.lru_cache(maxsize=None)
def cut_path(path: str) -> re.Pattern:
    """Matches the longest beginning of the path, of CUT characters or more,
    that a space, a quote, "..." or the end of a line follows."""
    rest = path[CUT:]
    return re.compile(re.escape(path[:CUT]) + "".join("(?:" + re.escape(c) for c in rest)
                      + ")?" * len(rest) + r"""(?=\s|$|\.\.\.|['"])""", re.MULTILINE)


def execute(command: list[str], timeout: int, cwd: str | None = None):
    """Runs a build step and returns its exit code and output. A step that
    takes longer than `timeout` seconds is ended together with the processes
    it started, and subprocess.TimeoutExpired is raised."""
    with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                          errors="replace", cwd=cwd, start_new_session=True) as process:
        try:
            stdout, stderr = process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.kill()
            process.wait()
            raise
    return subprocess.CompletedProcess(command, process.returncode, stdout, stderr)


def install_prefix(bindir: Path | None) -> Path | None:
    """The directory Icarus Verilog is installed in: the one above the
    directory of iverilog, which its messages name for its own files."""
    exe = shutil.which(str(bindir / "iverilog") if bindir else "iverilog")
    return Path(exe).resolve().parent.parent if exe else None


def run(test: Path, bindir: Path | None, prefix: Path | None = None) -> tuple[bool, str]:
    """Whether the test matches, and the reason if it does not. Whatever goes
    wrong with one test, a build that hangs or an error of this script, is a
    failure of that test and does not end the run of the others."""
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        try:
            ok, why = judge(test, bindir, tmp, prefix)
        except Exception as error:   # one test must not end the run
            ok, why = False, f"runner error: {type(error).__name__}: {error}"
        return ok, neutral(why, tmp, prefix)


def judge(test: Path, bindir: Path | None, tmp: str,
          prefix: Path | None = None) -> tuple[bool, str]:
    iverilog = str(bindir / "iverilog") if bindir else "iverilog"
    vvp = str(bindir / "vvp") if bindir else "vvp"
    sources, include_dirs = suite_results.files(test)
    out = Path(tmp) / "a.vvp"
    vvp_args = []
    vpi = c_source(test, "vpi_c")
    if vpi is not None:
        try:
            b = execute([str(bindir / "iverilog-vpi") if bindir else "iverilog-vpi",
                         "--name=app", str(vpi)], VPI_BUILD_TIMEOUT, cwd=tmp)
        except subprocess.TimeoutExpired:
            return False, "timed out (VPI build)"
        if b.returncode < 0:
            return False, f"VPI build crashed (signal {-b.returncode})"
        if b.returncode != 0:
            return False, "VPI build failed: " + (b.stderr.strip().splitlines() or [""])[-1]
        vvp_args = ["-M", tmp, "-mapp"]
    # Without -gspecify Icarus Verilog ignores specify blocks, and without
    # -ginterconnect it cannot annotate SDF interconnect delays.
    top = suite_results.top_module(test)
    try:
        c = execute([iverilog, "-g2012", "-gspecify", "-ginterconnect",
                     *[f"-I{d}" for d in include_dirs],
                     *[f"-D{d}" for d in suite_results.defines(test)],
                     *(["-s", top] if top else []), "-o", str(out),
                     *map(str, sources), str(test)], COMPILE_TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, "timed out (compile)"
    # A compiler that a signal ended did not reject the design: it crashed.
    if c.returncode < 0:
        return False, f"compiler crashed (signal {-c.returncode})"
    if header_field(test, "should_fail_because") is not None:
        return suite_results.judge_illegal(test, c.returncode == 0, c.stdout + c.stderr)
    if c.returncode != 0:
        return False, "compile failed: " + (c.stderr.strip().splitlines() or [""])[0]
    try:
        r = subprocess.run([vvp, *vvp_args, str(out), *suite_results.run_args(test)],
                           capture_output=True, text=True, errors="replace", cwd=tmp,
                           timeout=RUN_TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, "timed out"
    # A run that a signal ended is a failure whatever it printed before.
    if r.returncode < 0:
        return False, f"crashed (signal {-r.returncode})"
    raw = "".join(l + "\n" for l in r.stdout.splitlines()
                  if not SEVERITY.match(l) and not VCD_BANNER.match(l))
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=raw,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    if norm != want:
        # The directories are replaced before the lines are compared and cut
        # short, so that no part of one stays in the reason.
        return False, "output differs: " + suite_results.first_difference(
            neutral(norm, tmp, prefix), neutral(want, tmp, prefix))
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
    tests = simulation_tests(args.tests or suite_results.find_tests())
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("icarus") if args.json else None
    prefix = install_prefix(args.iverilog_bin)
    failed = known = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, args.iverilog_bin, prefix), tests)
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
