#!/usr/bin/env python3
"""Runs the suite with an unreleased simulator, temporarily called Ghost.

Usage:
    python3 tools/run_ghost.py --simulator PATH --profile PRIVATE.json
                                 [--include DIR] [-j N] [--json FILE] [TEST ...]

The private profile supplies arguments, environment, include_subdirs, trailer,
banner_pattern and severity_pattern. Only tool-generated output is removed;
the expectations and verdicts follow the same rules as the other runners.
Each test runs in a temporary directory. DPI/VPI C sources are compiled into
a shared library and loaded with --lib; a missing sv_vpi_user.h is supplied
as an include of vpi_user.h for implementations that combine those APIs.

All tests count, including illegal designs, expected exits and diagnostics.
Public results contain the alias, a hash of the executable and generic failure
reasons. The private profile, tool version, paths and diagnostics are never
copied to results. Keep the profile and the build outside public artifacts.
"""

import argparse
import concurrent.futures
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

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
NAME = "Ghost"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


def expected_output(test: Path) -> str | None:
    return suite_results.expected_output(test)


def normalize(stdout: str, profile: dict) -> str:
    """Remove only the framework output identified by the private profile."""
    banner = re.compile(profile["banner_pattern"])
    severity = re.compile(profile["severity_pattern"])
    kept = []
    for line in ANSI.sub("", stdout).splitlines():
        if line.startswith(profile["trailer"]):
            break
        if not banner.match(line) and not severity.match(line):
            kept.append(line + "\n")
    return subprocess.run([sys.executable, str(NORMALIZE)], input="".join(kept),
                          capture_output=True, text=True, check=True).stdout


def run(test: Path, simulator: str, include: Path | None,
        profile: dict) -> tuple[str, str]:
    """Return a verdict without exposing private compiler or simulator output."""
    fields = suite_results.header(test)
    with tempfile.TemporaryDirectory() as tmp:
        lib = []
        source = fields.get("dpi_c") or fields.get("vpi_c")
        if source is not None:
            if include is None:
                return "fail", "C build failed: no include directory (see --include)"
            (Path(tmp) / "sv_vpi_user.h").write_text('#include "vpi_user.h"\n')
            shared = Path(tmp) / "libtest.so"
            undefined = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            try:
                build = subprocess.run(
                    [os.environ.get("CC", "cc"), "-shared", "-fPIC", *undefined,
                     "-o", str(shared), str((test.parent / source.removeprefix("@")).resolve()),
                     f"-I{include}", *[f"-I{include / d}" for d in profile["include_subdirs"]],
                     f"-I{tmp}"], capture_output=True, text=True, timeout=60)
            except (OSError, subprocess.TimeoutExpired):
                return "fail", "C build failed or timed out"
            if build.returncode != 0:
                return "fail", "C build failed"
            lib = ["--lib", str(shared)]
        sources, include_dirs = suite_results.files(test)
        top = suite_results.top_module(test)
        try:
            result = subprocess.run(
                [simulator, *profile["arguments"], *lib,
                 *[f"+incdir+{d}" for d in include_dirs],
                 *[f"+define+{d}" for d in suite_results.defines(test)],
                 *(["-top", top] if top else []), *map(str, sources),
                 str(test.resolve()), *suite_results.run_args(test)],
                capture_output=True, text=True, errors="replace", cwd=tmp,
                env={**os.environ, **profile["environment"]}, timeout=90)
        except subprocess.TimeoutExpired:
            return "fail", "timed out"
        except OSError:
            return "fail", "could not start the simulator"
    # A matching prefix of output must never turn a crash into a pass.
    if result.returncode < 0:
        return "fail", f"crashed (signal {-result.returncode})"
    messages = ANSI.sub("", result.stdout + result.stderr)
    if "should_fail_because" in fields:
        ok, why = suite_results.judge_illegal(test, result.returncode == 0, messages)
        # judge_illegal appends the first actual diagnostic for other runners.
        # The regexp comes from the public test; the diagnostic stays private.
        return ("pass" if ok else "fail"), why.split("; the first is:", 1)[0]
    want = expected_output(test)
    if want is None:
        return "fail", "no :expected_stdout:"
    got = normalize(result.stdout, profile)
    if got != want:
        return "fail", "output differs" + (
            f" (exit {result.returncode})" if result.returncode else "")
    why = suite_results.judge_run(test, result.returncode, messages)
    return ("fail" if why else "pass"), why


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--simulator", required=True, help="private simulator executable")
    ap.add_argument("--profile", required=True, type=Path, help="private runtime profile")
    ap.add_argument("--include", type=Path, help="C API include directory")
    ap.add_argument("-j", "--jobs", type=int, default=1)
    ap.add_argument("--json", type=Path, help="also write public results to this file")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()
    if args.jobs < 1:
        ap.error("--jobs must be at least 1")
    exe = shutil.which(args.simulator)
    if exe is None:
        ap.error("cannot find the private simulator executable")
    exe = str(Path(exe).resolve())
    try:
        profile_bytes = args.profile.read_bytes()
        profile = json.loads(profile_bytes)
        for key in ("arguments", "environment", "include_subdirs", "trailer",
                    "banner_pattern", "severity_pattern"):
            profile[key]
        re.compile(profile["banner_pattern"])
        re.compile(profile["severity_pattern"])
        if not profile["trailer"]:
            raise ValueError("empty trailer")
    except (OSError, ValueError, KeyError, TypeError):
        ap.error("cannot read a valid private runtime profile")
    include = args.include.resolve() if args.include else None
    tests = args.tests or suite_results.find_tests()
    inputs = suite_results.fingerprints(tests) if args.json else None
    runner_hash = suite_results.runner_digest("ghost") if args.json else None
    binary_hash = hashlib.sha256(Path(exe).read_bytes()).hexdigest()
    profile_hash = hashlib.sha256(profile_bytes).hexdigest()
    failed, statuses = 0, {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = pool.map(lambda t: run(t, exe, include, profile), tests)
        for test, (status, why) in zip(tests, results):
            if status == "fail":
                failed += 1
                print(f"FAIL {suite_results.test_id(test)}: {why}", flush=True)
            statuses[suite_results.test_id(test)] = (status, why)
    print(f"{len(tests) - failed}/{len(tests)} tests match", flush=True)
    if args.json:
        changed = (hashlib.sha256(Path(exe).read_bytes()).hexdigest() != binary_hash
                   or hashlib.sha256(args.profile.read_bytes()).hexdigest() != profile_hash)
        if changed:
            print("Private build or profile changed during execution; results discarded.",
                  file=sys.stderr)
            return 2
        suite_results.write(
            args.json, "ghost", NAME, f"private build {binary_hash[:12]}", statuses,
            inputs=inputs, runner_sha256=runner_hash,
            configuration={"binary_sha256": binary_hash, "profile_sha256": profile_hash})
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
