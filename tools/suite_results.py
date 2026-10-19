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
"""

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATUSES = ("pass", "fail", "known", "unsupported")


def test_id(test: Path) -> str:
    path = test.resolve()
    return path.relative_to(ROOT / "tests").with_suffix("").as_posix()


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
