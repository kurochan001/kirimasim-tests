#!/usr/bin/env python3
"""Runs the test suite with Lyra and compares each test's normalized output
with its expected output.

Usage:
    python3 tools/run_lyra.py [--lyra PATH] [--commit SHA] [--cache-dir DIR]
                              [-j N] [--json FILE] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv. Exits with 1 if any test
does not match. No expected output was recorded with Lyra, so every test
counts.

Lyra (https://github.com/hankhsu1996/lyra) compiles a design through slang
and LLVM into a program and runs it; it has no releases, so --commit names
the commit that was built, and the version in the results is "Lyra (commit
<SHA>)". Each test runs in its own temporary directory as `lyra run`, with
`--top` for `:top_module:` (otherwise slang takes every module that nothing
instantiates), the directories of the include files and of `:incdirs:` as
-I, the macros of `:defines:` as -D, the sources of `:files:` before the
test, the C file of `:dpi_c:` as --dpi-link, and the arguments of `:args:`
after `--`, which is where the program's own arguments go. Lyra keeps what it
builds for reuse in a cache directory, which the tests share: --cache-dir, or
else a temporary directory that is removed at the end. Each test is built
with `-j 1`, as the tests themselves run in parallel.

Lyra prints its diagnostics on standard error as
`<file>:<line>:<column>: error: ...`, and says of every construct that it
does not carry out yet that it "is not yet supported"; such a message makes
the test unsupported. Lines of that form on standard output, such as those of
the severity tasks, are removed before the output is compared. Lyra has no
VPI, so the tests with `:vpi_c:` are unsupported without running them.

A test with `:should_fail_because:` is an illegal design, which matches when
`lyra check` rejects it with an error at the place `:expected_stderr_regex:`
names (see tools/suite_results.py). The exit code and messages of a run are
checked against `:expected_exit:` and `:expected_stderr_regex:`.

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
OPTIONS = ["--no-color", "--progress", "none"]
UNSUPPORTED = re.compile(r"is not yet supported")
# Lyra's messages, which open with the place they are about and a severity
# word, or are a note of their own (for example "note: in 'Test' at time 0").
MESSAGE = re.compile(r"^(?:\S+:\d+:\d+: )?(?:internal error|error|warning|note): ")


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


def message(line: str) -> str:
    """A message without the place it names."""
    return re.sub(r"^\S+:\d+:\d+: ", "", line).strip()


def run(test: Path, lyra: str, cache: Path) -> tuple[str, str]:
    """The status of the test (pass, fail or unsupported) and the reason."""
    if header_field(test, "vpi_c") is not None:
        return "unsupported", "Lyra has no VPI"
    sources, include_dirs = suite_results.files(test)
    top = suite_results.top_module(test)
    design = [*(["--top", top] if top else []), *[f"-I{d}" for d in include_dirs],
              *[f"-D{d}" for d in suite_results.defines(test)],
              *map(str, sources), str(test.resolve())]
    illegal = header_field(test, "should_fail_because") is not None
    dpi = c_source(test, "dpi_c")
    if illegal:
        command = [lyra, "check", *OPTIONS, *design]
    else:
        command = [lyra, "run", *OPTIONS, "-j", "1", "--cache-dir", str(cache),
                   *(["--dpi-link", str(dpi)] if dpi else []), *design,
                   "--", *suite_results.run_args(test)]
    with tempfile.TemporaryDirectory() as tmp:
        try:
            r = subprocess.run(command, capture_output=True, text=True, errors="replace",
                               cwd=tmp, timeout=300)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
    lines = r.stderr.splitlines()
    unsupported = next((l for l in lines if UNSUPPORTED.search(l)), "")
    if illegal:
        if r.returncode < 0:
            return "fail", f"crashed (signal {-r.returncode})"
        ok, why = suite_results.judge_illegal(test, r.returncode == 0, r.stdout + r.stderr)
        if not ok and r.returncode != 0 and unsupported:
            return "unsupported", message(unsupported)
        return ("pass" if ok else "fail"), why
    raw = "".join(l + "\n" for l in r.stdout.splitlines() if not MESSAGE.match(l))
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=raw,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return "fail", "no :expected_stdout:"
    if norm == want:
        why = suite_results.judge_run(test, r.returncode, r.stdout + r.stderr)
        return ("fail" if why else "pass"), why
    if unsupported:
        return "unsupported", message(unsupported)
    if r.returncode < 0:
        return "fail", f"crashed (signal {-r.returncode})"
    internal = next((l for l in lines if "internal error:" in l), "")
    if internal:
        return "fail", message(internal)
    error = next((l for l in lines if re.search(r"\berror: ", l)), "")
    if r.returncode != 0 and error and not r.stdout:
        return "fail", "compile failed: " + message(error)
    return "fail", "output differs" + (f" (exit {r.returncode})" if r.returncode else "") + (
        f": {message(error)}" if error and r.returncode
        else ": " + suite_results.first_difference(norm, want))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--lyra", default="lyra", help="lyra executable")
    ap.add_argument("--commit", default=None, help="the commit of Lyra that was built")
    ap.add_argument("--cache-dir", type=Path, default=None,
                    help="where Lyra keeps what it builds (default: a temporary directory)")
    ap.add_argument("-j", "--jobs", type=int, default=1, help="number of tests run at once")
    ap.add_argument("--json", type=Path, default=None, help="also write the results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    exe = shutil.which(args.lyra)
    if exe is None:
        ap.error(f"cannot find {args.lyra}")
    exe = str(Path(exe).resolve())   # the tests run in other directories

    tests = args.tests or suite_results.find_tests()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("lyra") if args.json else None
    failed = unsupported = 0
    statuses = {}
    with tempfile.TemporaryDirectory() as tmp:
        cache = args.cache_dir.resolve() if args.cache_dir else Path(tmp)
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            results = pool.map(lambda t: run(t, exe, cache), tests)
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
          + (f"; {unsupported} use what Lyra does not support yet" if unsupported else ""))
    if args.json:
        version = (f"Lyra (commit {args.commit[:12]})" if args.commit
                   else suite_results.tool_version([exe, "--version"]) or "Lyra")
        suite_results.write(args.json, "lyra", "Lyra", version, statuses,
                            inputs=inputs, runner_sha256=runner_hash)
    return 1 if failed or unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
