#!/usr/bin/env python3
"""Runs the test suite with nvc and compares each test's normalized output
with its expected output.

Usage:
    python3 tools/run_nvc.py [--nvc PATH] [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. No expected output was recorded with nvc, so every test
counts.

nvc (https://github.com/nickg/nvc) is a VHDL simulator whose Verilog and
SystemVerilog support is experimental. Each test runs in its own temporary
directory, which holds nvc's work library, in two steps: `nvc -a` analyses
the sources of `:files:` and the test, then `nvc -e TOP... -r` elaborates
and runs the design. nvc does not choose the top-level modules itself, so
the runner names them: the module of `:top_module:`, or else every module and
program of the sources that none of them instantiates (23.3.1). The
directories of the include files and of `:incdirs:` are passed as -I, the
macros of `:defines:` as -D, and the arguments of `:args:` after the
top-level modules. Every run uses `--messages=compact`, which prints each
message on one line as `<file>:<line>:<column>: <severity>: ...`, and
`--stderr=note`, so that nvc's own messages, including those of the severity
tasks and of `$finish`, go to standard error. Standard output holds only what
the design prints and is passed through tools/normalize_output.py.

nvc reports most constructs that it does not support yet as syntax errors
("unexpected ... while parsing"), as an internal "cannot handle" message, or
as a system task or function that is "not registered". In a legal design,
such a message makes the test unsupported; any other error is a failure.
nvc does not parse DPI imports or start the VPI applications of a Verilog
design (vlog_startup_routines), so the tests with `:dpi_c:` or `:vpi_c:` are
reported as unsupported without running them.

A test with `:should_fail_because:` is an illegal design, which matches when
nvc rejects it while analysing or elaborating it, with an error at the place
`:expected_stderr_regex:` names (see tools/suite_results.py); when nvc
rejects it elsewhere with one of the messages above, the test is
unsupported. The exit code
and messages of a run are checked against `:expected_exit:` and
`:expected_stderr_regex:`.

With --json, the result of every test is also written to FILE in the form
that tools/suite_results.py describes.
"""

import argparse
import concurrent.futures
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
OPTIONS = ["--messages=compact", "--stderr=note"]
UNSUPPORTED = re.compile(r"cannot handle |not (?:yet )?(?:supported|implemented)|\bsorry\b"
                         r"|system (?:task|function) \S+ not registered")
SYNTAX = re.compile(r"error: unexpected .* while parsing ")
# A message of a run, as opposed to one of analysis or elaboration, carries
# the simulation time and delta cycle (for example "0ms+0").
RUN_MESSAGE = re.compile(r"(?:error|fatal|failure): (?:\(init\): )?\d+\w*s\+\d+: ")
COMMENTS = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\\n])*"', re.DOTALL)
UNIT = re.compile(r"\b(extern\s+)?(module|macromodule|program)\s+(?:(?:automatic|static)\s+)?"
                  r"(\\\S+|[A-Za-z_]\w*)")
INCLUDE = re.compile(r'`include\s*"([^"\n]+)"')


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


def source_text(paths: list[Path], include_dirs: list[Path]) -> str:
    """The text of the sources and of the files they include, without
    comments and string literals."""
    seen, pending, texts = set(), list(paths), []
    while pending:
        path = pending.pop(0)
        if path in seen or not path.is_file():
            continue
        seen.add(path)
        text = COMMENTS.sub(lambda m: " " if m.group(0).startswith("/") else '""',
                            path.read_text(encoding="utf-8", errors="replace"))
        texts.append(text)
        for name in INCLUDE.findall(path.read_text(encoding="utf-8", errors="replace")):
            for d in [path.parent, *include_dirs]:
                if (d / name).is_file():
                    pending.append((d / name).resolve())
                    break
    return "\n".join(texts)


def top_modules(test: Path) -> list[str]:
    """The module of :top_module:, or the modules and programs that no source
    instantiates, in the order they are declared."""
    top = suite_results.top_module(test)
    if top:
        return [top]
    sources, include_dirs = suite_results.files(test)
    text = source_text([*sources, test.resolve()], include_dirs)
    declared = [m.group(3) for m in UNIT.finditer(text) if not m.group(1)]
    tops = []
    for name in dict.fromkeys(declared):
        # An instance names its module, then perhaps parameter values, then
        # the instance name, perhaps with a range, and its port list.
        instance = re.compile(rf"(?<![\w$.]){re.escape(name)}(?![\w$])"
                              r"(?:\s*#\s*(?:\((?:[^()]|\((?:[^()]|\([^()]*\))*\))*\)|\w+))?"
                              r"\s+(?:\\\S+|[A-Za-z_]\w*)\s*(?:\[[^\]]*\]\s*)*\(")
        if not instance.search(text):
            tops.append(name)
    return tops


def first(lines: list[str], pattern: re.Pattern) -> str:
    return next((l for l in lines if pattern.search(l)), "")


def message(line: str) -> str:
    """A message without the place it names."""
    return re.sub(r"^\S+:\d+:\d+: ", "", line).strip()


def run(test: Path, nvc: str) -> tuple[str, str]:
    """The status of the test (pass, fail or unsupported) and the reason."""
    if header_field(test, "dpi_c") is not None or header_field(test, "vpi_c") is not None:
        return "unsupported", "nvc does not load the C code of DPI or VPI applications of Verilog"
    sources, include_dirs = suite_results.files(test)
    tops = top_modules(test)
    illegal = header_field(test, "should_fail_because") is not None
    if not tops and not illegal:
        return "fail", "no top-level module found"
    analyse = [nvc, *OPTIONS, "-a", *[f"-I{d}" for d in include_dirs],
               *[f"-D{d}" for d in suite_results.defines(test)],
               *map(str, sources), str(test.resolve())]
    with tempfile.TemporaryDirectory() as tmp:
        try:
            if illegal:
                # An illegal design without a module is only analysed.
                c = subprocess.run([*analyse, *(["-e", *tops] if tops else [])],
                                   capture_output=True, text=True,
                                   errors="replace", cwd=tmp, timeout=120)
            else:
                c = subprocess.run(analyse, capture_output=True, text=True, errors="replace",
                                   cwd=tmp, timeout=120)
                if c.returncode == 0:
                    r = subprocess.run([nvc, *OPTIONS, "-e", *tops, "-r",
                                        *suite_results.run_args(test)],
                                       capture_output=True, text=True, errors="replace",
                                       cwd=tmp, timeout=120)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
    lines = (c.stdout + c.stderr).splitlines()
    unsupported = first(lines, UNSUPPORTED)
    if illegal:
        if c.returncode < 0:
            return "fail", f"crashed (signal {-c.returncode})"
        ok, why = suite_results.judge_illegal(test, c.returncode == 0, c.stdout + c.stderr)
        # A syntax error elsewhere is a construct of the legal part of the
        # design that nvc does not parse yet.
        if not ok and c.returncode != 0 and (unsupported or first(lines, SYNTAX)):
            return "unsupported", message(unsupported or first(lines, SYNTAX))
        return ("pass" if ok else "fail"), why
    if c.returncode != 0:
        if c.returncode < 0:
            return "fail", f"crashed while analysing (signal {-c.returncode})"
        if unsupported or first(lines, SYNTAX):
            return "unsupported", message(unsupported or first(lines, SYNTAX))
        error = first(lines, re.compile(r"\b(?:error|fatal):"))
        return "fail", "compile failed: " + (message(error) or f"exit code {c.returncode}")
    lines = r.stderr.splitlines()
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=r.stdout,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return "fail", "no :expected_stdout:"
    if norm == want:
        why = suite_results.judge_run(test, r.returncode, r.stdout + r.stderr)
        return ("fail" if why else "pass"), why
    unsupported = first(lines, UNSUPPORTED)
    if unsupported:
        return "unsupported", message(unsupported)
    if r.returncode < 0:
        return "fail", f"crashed (signal {-r.returncode})"
    error = first(lines, re.compile(r"\b(?:error|fatal):"))
    if r.returncode != 0 and error and not RUN_MESSAGE.search(error) and not r.stdout:
        return "fail", "compile failed: " + message(error)
    return "fail", "output differs" + (f" (exit {r.returncode})" if r.returncode else "") + (
        f": {message(error)}" if error and r.returncode
        else ": " + suite_results.first_difference(norm, want))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--nvc", default="nvc", help="nvc executable")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.nvc)
    if exe is None:
        ap.error(f"cannot find {args.nvc}")
    exe = str(Path(exe).resolve())   # the tests run in other directories

    tests = args.tests or suite_results.find_tests()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("nvc") if args.json else None
    failed = unsupported = 0
    statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe), tests)
        for t, (status, why) in zip(tests, results):
            name = t.relative_to(ROOT) if t.is_absolute() else t
            if status == "unsupported":
                unsupported += 1
                print(f"UNSUPPORTED {name}: {why}", flush=True)
            elif status == "fail":
                failed += 1
                print(f"FAIL {name}: {why}", flush=True)
            statuses[suite_results.test_id(t)] = (status, why)
    print(f"{len(tests) - failed - unsupported}/{len(tests)} tests match"
          + (f"; {unsupported} use what nvc does not support yet" if unsupported else ""))
    if args.json:
        suite_results.write(args.json, "nvc", "nvc",
                            suite_results.tool_version([exe, "--version"]), statuses,
                            inputs=inputs, runner_sha256=runner_hash)
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
