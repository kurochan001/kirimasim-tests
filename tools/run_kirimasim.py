#!/usr/bin/env python3
"""Runs the test suite with kirimasim and compares each test's normalized
output with its expected output.

Usage:
    python3 tools/run_kirimasim.py [--kirimasim PATH] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every test whose :type: is not formal. A formal
test belongs to tools/run_sby.py and has no expected output, so a simulation
runner must not count it. Exits with 1 if any test does not match. No expected
output was recorded with kirimasim, so every simulation test counts, except a
test whose output was recorded only with another simulator: that is a known
difference, not a failure.

Each test runs in its own temporary directory as `kirimasim <test>.sv`.
kirimasim writes only what the design prints to standard output and its own
messages to standard error, so nothing more than what
tools/normalize_output.py removes is removed. A test that uses a construct
kirimasim does not support yet, which it reports with exit code 2 and an
"error: unsupported:" message, is reported as unsupported. kirimasim cannot
load C code yet, so the tests with `:dpi_c:` or `:vpi_c:` are reported as
unsupported without running them.

A test with `:should_fail_because:` is an illegal design, which matches when
kirimasim rejects it (exit code 2) with an error at the place
`:expected_stderr_regex:` names; when the error says the design uses what
kirimasim does not support yet, the test is unsupported. The sources of
`:files:` are passed before the test, the directories of its include files
and of `:incdirs:` as +incdir+, the macros of `:defines:` as +define+, the
module of `:top_module:` as --top=, the arguments of `:args:` after the test,
and the exit code and
standard error are checked against `:expected_exit:` and
`:expected_stderr_regex:` (see tools/suite_results.py).

A run that a signal ends fails even when it printed the expected output, and
such a run did not reject an illegal design;
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
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
UNSUPPORTED = re.compile(r"error: unsupported: (.*)")
# The seconds that kirimasim may take for one test.
RUN_TIMEOUT = 120
# The shortest beginning of a directory that neutral() takes for a cut path.
CUT = 8


def header_field(test: Path, name: str) -> str | None:
    header = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not header:
        return None
    m = re.search(rf"^:{name}:\s*(.*)$", header.group(1), re.MULTILINE)
    return m.group(1).strip() if m else None


def expected_output(test: Path) -> str | None:
    return suite_results.expected_output(test, "kirimasim")


def simulation_tests(tests: list[Path]) -> list[Path]:
    """The tests that a simulator runs. A test with :type: formal names a
    :formal_case: and belongs to tools/run_sby.py; it has no expected output,
    so counting it as a simulation failure would be wrong."""
    return [test for test in tests if header_field(test, "type") != "formal"]


def expectation_of_other_simulator(test: Path) -> str | None:
    """The simulator whose own expected output the test records, when the test
    records none for kirimasim. Such a test is a known difference, not a
    failure, because its output was recorded for another simulator."""
    fields = suite_results.header(test)
    if any(name in fields for name in suite_results.expected_fields("kirimasim")):
        return None
    return next((other for other in suite_results.SIMULATORS
                 if other != "kirimasim"
                 and f"{suite_results.EXPECTED}_{other}" in fields), None)


def neutral(text: str, tmp: str | None = None, prefix: Path | None = None) -> str:
    """A reason without the directories of this machine, so that the results
    can be published and compared between machines: a path under the
    repository becomes relative to it, and the temporary directory of the
    test and the directory for temporary files become <tmp>, the directory
    kirimasim is installed in <kirimasim> and the home directory <home>.
    The longest directory is replaced first, as one may lie in another. A
    simulator may cut a long file name short in a message; what is left of a
    directory then, CUT characters or more before a space, a quote, "..." or
    the end of a line, becomes <path>."""
    places = [(str(ROOT) + os.sep, ""), (str(ROOT), ".")]
    for path, name in ((tmp, "<tmp>"), (tempfile.gettempdir(), "<tmp>"),
                       (prefix, "<kirimasim>"), (Path.home(), "<home>")):
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


def install_prefix(kirimasim: str) -> Path | None:
    """The directory kirimasim is installed in: the one above the directory
    of the executable."""
    exe = shutil.which(kirimasim)
    return Path(exe).resolve().parent.parent if exe else None


def run(test: Path, kirimasim: str, prefix: Path | None = None) -> tuple[str, str]:
    """The status of the test (pass, fail, known or unsupported) and the
    reason. Whatever goes wrong with one test, such as an error of this
    script, is a failure of that test and does not end the run of the others."""
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        try:
            status, why = judge(test, kirimasim, tmp, prefix)
        except Exception as error:   # one test must not end the run
            status, why = "fail", f"runner error: {type(error).__name__}: {error}"
        return status, neutral(why, tmp, prefix)


def judge(test: Path, kirimasim: str, tmp: str,
          prefix: Path | None = None) -> tuple[str, str]:
    if header_field(test, "dpi_c") is not None or header_field(test, "vpi_c") is not None:
        return "unsupported", "kirimasim cannot load C code yet"
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    try:
        r = subprocess.run([kirimasim, *[f"+incdir+{d}" for d in include_dirs],
                            *[f"+define+{d}" for d in suite_results.defines(test)],
                            *([f"--top={top}"] if top else []),
                            *map(str, sources), str(test.resolve()),
                            *suite_results.run_args(test)],
                           capture_output=True, text=True, errors="replace", cwd=tmp,
                           timeout=RUN_TIMEOUT)
    except subprocess.TimeoutExpired:
        return "fail", "timed out"
    # A run that a signal ended is a failure whatever it printed before, and
    # it did not reject an illegal design.
    if r.returncode < 0:
        return "fail", f"crashed (signal {-r.returncode})"
    unsupported = UNSUPPORTED.search(r.stderr)
    if header_field(test, "should_fail_because") is not None:
        if r.returncode == 2 and unsupported:
            return "unsupported", unsupported.group(1).strip()
        # kirimasim rejects a design with exit code 2.
        if r.returncode not in (0, 2):
            return "fail", f"exit code {r.returncode}, expected 2"
        ok, why = suite_results.judge_illegal(test, r.returncode == 0, r.stderr)
        return ("pass" if ok else "fail"), why
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=r.stdout,
                          capture_output=True, text=True).stdout
    if r.returncode == 2 and unsupported:
        return "unsupported", unsupported.group(1).strip()
    want = expected_output(test)
    if want is None:
        other = expectation_of_other_simulator(test)
        if other is not None:
            return "known", f"the expected output is recorded with {other}"
        return "fail", "no :expected_stdout:"
    if norm == want:
        why = suite_results.judge_run(test, r.returncode, r.stderr)
        return ("fail" if why else "pass"), why
    err = [l for l in r.stderr.splitlines() if ": error: " in l or ": fatal: " in l]
    # The directories are replaced before the lines are compared and cut
    # short, so that no part of one stays in the reason.
    return "fail", "output differs" + (f" (exit {r.returncode})" if r.returncode else "") + (
        f": {err[0].split(': ', 1)[-1]}" if err
        else ": " + suite_results.first_difference(neutral(norm, tmp, prefix),
                                                   neutral(want, tmp, prefix)))


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

    tests = simulation_tests(args.tests or suite_results.find_tests())
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("kirimasim") if args.json else None
    prefix = install_prefix(exe)
    failed = unsupported = known = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, prefix), tests)
        for t, (status, why) in zip(tests, results):
            name = t.relative_to(ROOT) if t.is_absolute() else t
            if status == "unsupported":
                unsupported += 1
                print(f"UNSUPPORTED {name}: {why}", flush=True)
            elif status == "known":
                known += 1
                print(f"KNOWN {name}: {why}", flush=True)
            elif status == "fail":
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[suite_results.test_id(t)] = (status, why)
    print(f"{len(tests) - failed - unsupported - known}/{len(tests) - known} tests match"
          + (f"; {known} known differences not counted" if known else "")
          + (f"; {unsupported} use what kirimasim does not support yet" if unsupported else ""))
    if args.json:
        suite_results.write(args.json, "kirimasim", "kirimasim",
                            suite_results.tool_version([exe, "--version"]), statuses,
                            inputs=inputs, runner_sha256=runner_hash)
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
