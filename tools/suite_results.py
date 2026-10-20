"""Writes the results of a runner as JSON (the --json option of the run_*.py
scripts), which tools/results_history.py turns into the nightly report.

The file holds one object:

    {"simulator": "icarus", "name": "Icarus Verilog",
     "version": "Icarus Verilog version 13.0 (stable) (v13_0)",
     "tests": {"ch6/test_x": {"status": "pass"},
               "ch7/test_y": {"status": "fail", "reason": "output differs"}}}

The keys of "tests" are the paths under tests/ without ".sv". A status is one
of:

    pass         the output matches the expected output
    fail         it does not, or the test could not be built or run
    known        it does not, and the expected output was not recorded with
                 this simulator (a known difference, see README.md)
    unsupported  the simulator reported a construct it does not support yet,
                 or it cannot run this kind of test

It also holds what the runners share about the tests: how they are found,
and the metadata fields that change how a test is run and judged
(:should_fail_because:, :expected_exit:, :expected_stderr_regex:, :args: and
:files:, see "Metadata" in README.md).
"""

import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATUSES = ("pass", "fail", "known", "unsupported")


def test_id(test: Path) -> str:
    path = test.resolve()
    return path.relative_to(ROOT / "tests").with_suffix("").as_posix()


def find_tests(root: Path = ROOT) -> list[Path]:
    """Every test of the suite. Other .sv files under tests/ are sources that
    tests name in :files:, and their names do not start with "test_"."""
    return sorted((root / "tests").rglob("test_*.sv"))


def header(test: Path) -> dict[str, str]:
    """The fields of the metadata comment at the top of a test."""
    m = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not m:
        return {}
    return {k: v.strip() for k, v in re.findall(r"^:(\w+):\s*(.*)$", m.group(1), re.MULTILINE)}


def files(test: Path) -> tuple[list[Path], list[Path]]:
    """The files that :files: names next to the test: the sources (.sv and .v)
    that are compiled before the test, in the order written, and the
    directories of the others, which the design includes with `include."""
    sources, include_dirs = [], []
    for name in header(test).get("files", "").split():
        path = (test.parent / name).resolve()
        if path.suffix in (".sv", ".v"):
            sources.append(path)
        elif path.parent not in include_dirs:
            include_dirs.append(path.parent)
    return sources, include_dirs


def run_args(test: Path) -> list[str]:
    """The arguments that :args: gives the simulation, such as plusargs."""
    return header(test).get("args", "").split()


def judge_illegal(test: Path, accepted: bool, messages: str) -> tuple[bool, str]:
    """For a test with :should_fail_because:, whether the simulator rejected
    the design as it should, given whether it accepted it and the messages it
    printed: a line of them must say "error" (in any case) and match
    :expected_stderr_regex:, which names the place of the error."""
    if accepted:
        return False, "the design was accepted, but it is illegal"
    regex = header(test).get("expected_stderr_regex")
    if regex is None:
        return False, "no :expected_stderr_regex:"
    lines = messages.splitlines()
    if any(re.search(regex, l) and "error" in l.lower() for l in lines):
        return True, ""
    first = next((l.strip() for l in lines if "error" in l.lower()), "")
    return False, f"no error matches {regex!r}" + (f"; the first is: {first}" if first else "")


def judge_run(test: Path, returncode: int, messages: str) -> str:
    """Why the exit code of a simulation or its messages are not what
    :expected_exit: and :expected_stderr_regex: say, or "" if they are (or
    the test has neither). "nonzero" asks for an exit code above 0: a run
    killed by a signal does not end with an error code."""
    fields = header(test)
    want = fields.get("expected_exit")
    if want is not None and not (returncode > 0 if want == "nonzero"
                                 else returncode == int(want)):
        return f"exit code {returncode}, expected {want}"
    regex = fields.get("expected_stderr_regex")
    if regex is not None and not re.search(regex, messages, re.MULTILINE):
        return f"no message matches {regex!r}"
    return ""


def tool_version(command: list[str]) -> str:
    """The first line a tool prints for its version option, or "" if it fails."""
    try:
        r = subprocess.run(command, capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired):
        return ""
    lines = (r.stdout or r.stderr).strip().splitlines()
    return lines[0].strip() if lines else ""


def first_difference(got: str, want: str) -> str:
    """Where an output first differs from the expected output, for the reason
    of a failure, such as "line 3 is 'a=1', expected 'a=0'"."""
    def quote(line: str) -> str:
        return repr(line if len(line) <= 60 else line[:57] + "...")
    got_lines, want_lines = got.splitlines(), want.splitlines()
    for n, (g, w) in enumerate(zip(got_lines, want_lines), 1):
        if g != w:
            return f"line {n} is {quote(g)}, expected {quote(w)}"
    n = min(len(got_lines), len(want_lines)) + 1
    if len(got_lines) < len(want_lines):
        return f"line {n} is missing, expected {quote(want_lines[n - 1])}"
    if len(got_lines) > len(want_lines):
        return f"line {n} is extra: {quote(got_lines[n - 1])}"
    return "the line ends differ"


def write(path: Path, simulator: str, name: str, version: str,
          results: dict[str, tuple[str, str]]) -> None:
    """results maps a test id to its status and the reason for it."""
    tests = {}
    for test, (status, reason) in sorted(results.items()):
        assert status in STATUSES, status
        tests[test] = {"status": status, **({"reason": reason} if reason else {})}
    data = {"simulator": simulator, "name": name, "version": version, "tests": tests}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
