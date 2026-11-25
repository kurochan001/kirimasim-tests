#!/usr/bin/env python3
"""Observe VPI interactive-scope changes inside the control call."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import suite_results


PROFILE = "ghost-vpi-interactive-scope"
CHECKER = "tools/run_ghost_vpi_interactive_scope.py"
CASE = "ch38/test_vpi_control_requires_an_interactive_scope_handle"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SCOPE_LOG = "VPI: Interactive scope set to: "
VARIABLE_BEGIN = "begin variable handle=1 type=1"
VARIABLE_RESULT = re.compile(r"end variable accepted=([01]) error=([01])")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def variable_result(lines: list[str], expected: list[str]) -> dict:
    if lines[:3] != expected[:3] or lines[-3:] != expected[3:] or len(lines) < 8:
        return {"observed": False, "pass": False}
    invalid_call = lines[3:-3]
    result = VARIABLE_RESULT.fullmatch(invalid_call[-1])
    redirects = [line.removeprefix(SCOPE_LOG) for line in invalid_call if line.startswith(SCOPE_LOG)]
    observed = invalid_call[0] == VARIABLE_BEGIN and result is not None
    accepted, error = map(int, result.groups()) if observed else (None, None)
    return {"observed": observed, "accepted": accepted, "error": error, "redirected_to": redirects,
            "pass": observed and accepted == 0 and not redirects}


def observe(simulator: str, compiler: str, fixture: Path, include_dirs: list[Path],
            profile: dict, directory: Path) -> dict:
    source = fixture.parent / suite_results.header(fixture)["vpi_c"].removeprefix("@")
    helper = directory / "libtest.so"
    platform_flags = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    compiled = subprocess.run(
        [compiler, "-shared", "-fPIC", *platform_flags, *[f"-I{path}" for path in include_dirs],
         "-o", str(helper), str(source)],
        cwd=directory, capture_output=True, text=True, errors="replace", timeout=60,
    )
    if compiled.returncode:
        return {"qualified": False, "pass": False, "build_exit": compiled.returncode}
    arguments = [arg for arg in profile["arguments"] if arg != "--quiet"]
    launcher = [simulator, *arguments, "--lib", str(helper), "-top", fixture.stem, str(fixture)]
    environment = {**os.environ, **profile["environment"]}
    first_begin, first_end, second_begin, second_end = suite_results.expected_output(fixture).splitlines()
    expected = [first_begin, SCOPE_LOG + fixture.stem + ".first", first_end,
                second_begin, SCOPE_LOG + fixture.stem + ".second", second_end]
    results = {}
    for mode, options in (("control", []), ("invalid", ["+observe_bad_scope"])):
        result = subprocess.run([*launcher, *options], cwd=directory, env=environment,
                                capture_output=True, text=True, errors="replace", timeout=60)
        stdout = [line for line in run_ghost.ANSI.sub("", result.stdout).splitlines()
                  if line.startswith(("begin ", "end ", SCOPE_LOG))]
        results[mode] = {"returncode": result.returncode, "stdout": stdout}
    control = results["control"]
    invalid = results["invalid"]
    control["pass"] = control["returncode"] == 0 and control["stdout"] == expected
    invalid.update(variable_result(invalid["stdout"], expected))
    qualified = control["pass"] and invalid["returncode"] == 0 and invalid["observed"]
    return {"qualified": qualified, "pass": qualified and invalid["pass"], "build_exit": compiled.returncode,
            "expected_control": expected, "trials": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    found = shutil.which(args.ghost)
    cc = shutil.which(os.environ.get("CC", "cc"))
    if not (found and cc):
        parser.error("Ghost and a native C compiler are required")
    simulator = str(Path(found).absolute())
    compiler = str(Path(cc).absolute())
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    include = args.include.resolve()
    dirs = [include, *(include / name for name in profile["include_subdirs"])]
    header = next((d / "vpi_user.h" for d in dirs if (d / "vpi_user.h").is_file()), None)
    if header is None:
        parser.error("the VPI header is unavailable")
    files = {"simulator": Path(simulator).resolve(), "compiler": Path(compiler).resolve(), "vpi_user_h": header}
    hashes = {name: digest(path) for name, path in files.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = observe(simulator, compiler, fixture, dirs, profile, Path(directory))
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (hashes != {name: digest(path) for name, path in files.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("ghost") or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or inputs changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "artifact_sha256": hashes,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    if observation["pass"]:
        status = ("pass", "")
    elif observation["qualified"]:
        status = ("fail", "a non-scope handle was accepted or changed the interactive scope")
    else:
        status = ("unsupported", "the control or the non-scope trial was unverified")
    version = f"private build {hashes['simulator'][:12]}"
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: status},
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": status[0], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(CASE, observation)
    return {"pass": 0, "fail": 1, "unsupported": 2}[status[0]]


if __name__ == "__main__":
    raise SystemExit(main())
