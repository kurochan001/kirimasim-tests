#!/usr/bin/env python3
"""Verify Annex N.2 against the caller's local IEEE 1800-2023 layout text."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


CHECKER = "tools/run_annex_n_reference.py"
CASE = "ch20/test_annex_n_reference_helpers"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
PROFILES = {"signatures": "ghost-annex-n-helper-signatures", "ranges": "ghost-annex-n-uniform-ranges"}
CASE_RESULT = re.compile(r"reference signatures=([01]) ranges=([01])")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def extract_reference(text: str) -> bytes:
    start = re.search(r"(?m)^N\.2 Source code[ \t]*$", text)
    if start is None:
        raise ValueError("the layout text does not contain the Annex N source section")
    section = re.split(r"(?m)^Annex O[ \t]*$", text[start.end():], maxsplit=1)
    if len(section) != 2:
        raise ValueError("the layout text does not contain the end of Annex N")
    bodies = []
    for index, page in enumerate(section[0].split("\f")):
        if index:
            page = re.split(r"(?m)^[ \t]*IEEE Standard for SystemVerilog[^\n]*\n", page, maxsplit=1)[-1]
        bodies.append(re.split(r"(?m)^ {20,}\d+ *$", page, maxsplit=1)[0])
    source = "\n".join(bodies)
    begin = source.find("#include <limits.h>")
    if begin < 0 or not source.rstrip().endswith("}"):
        raise ValueError("the Annex N source appears incomplete")
    return (source[begin:].strip() + "\n").encode("utf-8")


def verify(source: bytes, fixture: Path, compiler: Path, ghost: Path, profile: dict, work: Path) -> dict:
    # Keep the user's licensed text in this temporary translation unit only.
    (work / "annex_n_reference_input.h").write_bytes(source)
    c_source = fixture.parent / suite_results.header(fixture)["dpi_c"].removeprefix("@")
    library = work / "annex_n_reference.so"
    compile_result = subprocess.run(
        [str(compiler), "-std=gnu11", "-fwrapv", "-Werror=incompatible-pointer-types",
         "-Werror=implicit-function-declaration", "-DANNEX_N_REFERENCE_CHECK", "-shared", "-fPIC",
         f"-I{work}", "-o", str(library), str(c_source), "-lm"],
        cwd=work, capture_output=True, timeout=60,
    )
    if compile_result.returncode:
        return {"compile_exit": compile_result.returncode, "simulation_exit": None, "control": False,
                "results": dict.fromkeys(PROFILES, "unsupported")}
    result = subprocess.run(
        [str(ghost), *profile["arguments"], "--lib", str(library), "-top", fixture.stem,
         str(fixture), "+verify_annex_n_reference"],
        cwd=work, env={**os.environ, **profile["environment"]},
        capture_output=True, text=True, errors="replace", timeout=90,
    )
    output = run_ghost.normalize(result.stdout, profile).splitlines()
    control = len(output) == 2 and output[0] == suite_results.expected_output(fixture).strip()
    values = CASE_RESULT.fullmatch(output[1]) if control else None
    results = dict.fromkeys(PROFILES, "unsupported")
    if result.returncode == 0 and values is not None:
        results = {name: "pass" if value == "1" else "fail" for name, value in zip(PROFILES, values.groups())}
    return {"compile_exit": 0, "simulation_exit": result.returncode, "control": control, "results": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lrm-layout", required=True, type=Path)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--signatures-json", required=True, type=Path)
    parser.add_argument("--ranges-json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    compiler, ghost = (shutil.which(name) for name in (os.environ.get("CC", "cc"), args.ghost))
    if compiler is None or ghost is None:
        parser.error("a C compiler and Ghost are required")
    artifacts = {"compiler": Path(compiler).absolute(), "simulator": Path(ghost).absolute()}
    source = extract_reference(args.lrm_layout.read_text(encoding="utf-8"))
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checksum = checker_digest()
    fingerprints = {name: digest(path) for name, path in artifacts.items()}
    runner = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    with tempfile.TemporaryDirectory() as directory:
        observation = verify(source, fixture, artifacts["compiler"], artifacts["simulator"], profile, Path(directory))
    if (checksum != checker_digest() or fingerprints != {name: digest(path) for name, path in artifacts.items()}
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])
            or profile_bytes != args.profile.read_bytes()
            or source != extract_reference(args.lrm_layout.read_text(encoding="utf-8"))):
        parser.exit(2, "Tool, checker, or input changed during qualification.\n")
    configuration = {"checker_sha256": checksum, "artifact_sha256": fingerprints,
                     "reference_sha256": hashlib.sha256(source).hexdigest(),
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    version = f"private build {fingerprints['simulator'][:12]}"
    for kind, output in (("signatures", args.signatures_json), ("ranges", args.ranges_json)):
        status = observation["results"][kind]
        reason = {"pass": "", "fail": "reference witness differed",
                  "unsupported": "reference source or simulator could not be qualified"}[status]
        suite_results.write(output, "ghost", "Ghost", version, {CASE: (status, reason)}, inputs=inputs,
                            configuration={**configuration, "evidence_profile": PROFILES[kind]}, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(observation)
    return int(any(status != "pass" for status in observation["results"].values()))


if __name__ == "__main__":
    raise SystemExit(main())
