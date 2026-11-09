#!/usr/bin/env python3
"""Runs the slang driver on the tests of the suite, as a reference that is
not counted anywhere (see docs/slang-reference.en.md).

Usage:
    python3 tools/run_slang.py --slang PATH --commit SHA [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every test whose :type: is not formal, as the
other runners do. kirimasim and Lyra elaborate a design with slang, so slang
never confirms an expectation on its own; it tells whether a problem lies in
slang or after it, and points at tests to review.

slang gets the options that kirimasim's front end gives it (OPTIONS), the
directories of the include files and of `:incdirs:` as -I, the macros of
`:defines:` as -D, the module of `:top_module:` as --top, and the sources of
`:files:` before the test. Each test runs in its own temporary directory.

A test with `:should_fail_because:` is rejected at the line when slang has an
error at the place `:expected_stderr_regex:` names (the rule of the other
runners, suite_results.judge_illegal), rejected elsewhere when its errors are
elsewhere, and accepted when slang exits with 0. Any other test is clean when
slang exits with 0, and rejected otherwise. A test with `:vpi_c:` is marked
vpi: its C code registers system tasks, such as $vt_..., that slang does not
know.

slang prints only its release for --version, so --commit names the commit
that was built. With --json, the verdicts are written to FILE with the
commit, the options, the date, slang's first error and the input fingerprint
of each test, with files named relative to the repository. The file is not
the results of a simulator: keep it out of coverage/results/.
"""

import argparse
import concurrent.futures
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

# The options that kirimasim's front end gives slang (src/front/front.cpp of
# kirimasim), so that a difference between the two is not one of options.
OPTIONS = ["--std=1800-2023", "-Wno-error=index-oob", "-Wno-error=string-int-concat",
           "-Wno-error=string-in-constraint", "--threads", "1", "-q"]
ILLEGAL = ("rejected_at_line", "rejected_elsewhere", "accepted", "timeout", "crashed")
LEGAL = ("clean", "rejected", "timeout", "crashed")
ERROR = re.compile(r"(?:^|: )(?:fatal )?error: ")
LOCATION = re.compile(r"^(.+?)(:\d+:\d+: .*)$")


def relative(line: str, cwd: str) -> str:
    """The message with the file it names relative to the repository. slang
    names a file relative to the directory it runs in."""
    m = LOCATION.match(line)
    if not m:
        return line
    root = suite_results.ROOT.resolve()
    for base in (os.path.realpath(cwd), cwd):
        path = Path(os.path.normpath(os.path.join(base, m.group(1))))
        if path.is_file() and path.is_relative_to(root):
            return path.relative_to(root).as_posix() + m.group(2)
    return Path(m.group(1)).name + m.group(2)


def run(test: Path, slang: str) -> dict:
    """The verdict of slang on the test: its kind (illegal or legal), its
    status, slang's first error, and whether the test has :vpi_c:."""
    fields = suite_results.header(test)
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    illegal = "should_fail_because" in fields
    verdict = {"kind": "illegal" if illegal else "legal"}
    if "vpi_c" in fields:
        verdict["vpi"] = True
    command = [slang, *OPTIONS, *[f"-I{d}" for d in include_dirs],
               *[f"-D{d}" for d in suite_results.defines(test)],
               *(["--top", top] if top else []), *map(str, sources), str(test.resolve())]
    with tempfile.TemporaryDirectory() as tmp:
        try:
            r = subprocess.run(command, capture_output=True, text=True, errors="replace",
                               cwd=tmp, timeout=120)
        except subprocess.TimeoutExpired:
            return {**verdict, "status": "timeout"}
        messages = r.stdout + r.stderr
        error = next((l.strip() for l in messages.splitlines() if ERROR.search(l)), "")
        error = relative(error, tmp)
    if r.returncode < 0:
        status = "crashed"
    elif illegal:
        ok, _ = suite_results.judge_illegal(test, r.returncode == 0, messages)
        status = ("rejected_at_line" if ok
                  else "accepted" if r.returncode == 0 else "rejected_elsewhere")
    else:
        status = "clean" if r.returncode == 0 else "rejected"
    return {**verdict, "status": status, **({"first_error": error} if error else {})}


def counts(results: dict, kind: str, vpi: bool | None = None) -> dict:
    """How many tests of a kind have each status; vpi chooses the tests with
    :vpi_c: (True), those without (False) or both (None)."""
    chosen = [v for v in results.values() if v["kind"] == kind
              and (vpi is None or v.get("vpi", False) == vpi)]
    return {"tests": len(chosen),
            **{s: sum(v["status"] == s for v in chosen) for s in (ILLEGAL if kind == "illegal"
                                                                  else LEGAL)}}


def suite_commit() -> str:
    try:
        return subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True,
                              cwd=suite_results.ROOT, check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return ""


def write(path: Path, data: dict) -> None:
    """The file, with one line for each test."""
    head = json.dumps({k: v for k, v in data.items() if k != "tests"}, indent=1,
                      ensure_ascii=False)
    tests = ",\n".join(f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)}"
                       for k, v in sorted(data["tests"].items()))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(head[:-2] + ',\n "tests": {\n' + tests + "\n }\n}\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--slang", required=True, help="slang driver executable")
    ap.add_argument("--commit", required=True, help="the commit of slang that was built")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the verdicts to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.slang)
    if exe is None:
        ap.error(f"cannot find {args.slang}")
    exe = str(Path(exe).resolve())   # the tests run in other directories

    tests = [t for t in (args.tests or suite_results.find_tests())
             if suite_results.header(t).get("type") != "formal"]
    inputs = suite_results.fingerprints(tests) if args.json else {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = dict(zip((suite_results.test_id(t) for t in tests),
                           pool.map(lambda t: run(t, exe), tests)))
    for test, v in sorted(results.items()):
        if v["status"] not in ("rejected_at_line", "clean") and not v.get("vpi"):
            print(f"{v['status'].upper()} {test}" + (f": {v['first_error']}"
                                                     if "first_error" in v else ""), flush=True)
    illegal, legal = counts(results, "illegal"), counts(results, "legal", False)
    vpi = counts(results, "legal", True)
    print(f"illegal {illegal['tests']}: {illegal['rejected_at_line']} rejected at the line, "
          f"{illegal['rejected_elsewhere']} elsewhere, {illegal['accepted']} accepted")
    print(f"legal {legal['tests']} without :vpi_c:: {legal['clean']} clean, "
          f"{legal['rejected']} rejected; {vpi['tests']} with :vpi_c:: {vpi['clean']} clean, "
          f"{vpi['rejected']} rejected")
    if args.json:
        for test, v in results.items():
            current = suite_results.input_digest(suite_results.ROOT / "tests" / (test + ".sv"))
            v.update({"inputs_sha256": current} if inputs.get(test) == current
                     else {"inputs_changed": True})
        tool = hashlib.sha256()
        for path in (Path(__file__), Path(suite_results.__file__)):
            tool.update(path.name.encode() + b"\0" + path.read_bytes())
        write(args.json, {
            "reference": "slang", "slang_commit": args.commit,
            "slang_version": suite_results.tool_version([exe, "--version"]),
            "suite_commit": suite_commit(),
            "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "tool_sha256": tool.hexdigest(), "options": OPTIONS,
            "summary": {"illegal": illegal, "legal": legal, "legal_vpi": vpi},
            "tests": results})
    return 0


if __name__ == "__main__":
    sys.exit(main())
