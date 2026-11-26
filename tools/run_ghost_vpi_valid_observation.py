#!/usr/bin/env python3
"""Check Ghost frame retirement without calling VPI on an expired handle."""

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


CHECKER = "tools/run_ghost_vpi_valid_observation.py"
PROFILE = "ghost-vpi-frame-validity"
CASE = "ch37/test_vpi_frame_status_without_vpi_valid"
FIXTURE = suite_results.ROOT / "tests" / f"{CASE}.sv"
CASES = {CASE: FIXTURE}
TABLE = re.compile(r"native table (live|after end) direct=([01])/(-?\d+) traversed=([01])/(-?\d+)")
OBSOLETE = re.compile(r"obsolete query value=(-?\d+) undefined=([01])")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe(tools: dict[str, Path], profile: dict, work: Path) -> dict:
    source = FIXTURE.with_suffix(".c")
    library = work / "frame-watch.so"
    link = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else ["-ldl"]
    build = subprocess.run([tools["cc"], "-shared", "-fPIC", "-DFRAME_TABLE_OBSERVATION",
                            f"-I{tools['sv_vpi_user.h'].parent}", source, *link, "-o", library],
                           cwd=work, capture_output=True, timeout=30)
    if build.returncode:
        raise ValueError(f"VPI observation library did not compile ({build.returncode})")
    result = subprocess.run([tools["ghost"], *profile["arguments"], "--lib", library, FIXTURE],
                            cwd=work, env={**os.environ, **profile["environment"]}, capture_output=True,
                            text=True, errors="replace", timeout=30)
    lines = run_ghost.normalize(result.stdout, profile).splitlines()
    tables, obsolete, output = [], [], []
    for line in lines:
        if table := TABLE.fullmatch(line):
            tables.append({"site": table[1], "direct_present": int(table[2]), "direct_active": int(table[3]),
                           "traversed_present": int(table[4]), "traversed_active": int(table[5])})
        elif query := OBSOLETE.fullmatch(line):
            obsolete.append({"value": int(query[1]), "undefined": bool(int(query[2]))})
        else:
            output.append(line)
    control_matches = result.returncode == 0 and output == suite_results.expected_output(FIXTURE).splitlines()
    measured = (control_matches and len(obsolete) == 1 and [t["site"] for t in tables] == ["live", "after end"]
                and tables[0]["direct_present"] == tables[0]["traversed_present"] == 1)
    return {"build_exit": build.returncode, "exit": result.returncode, "stdout": output,
            "control_matches": control_matches, "obsolete_query": obsolete, "native_tables": tables,
            "measured": measured, "ended_keys_absent": measured and
            tables[1]["direct_present"] == tables[1]["traversed_present"] == 0}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", type=Path, required=True)
    parser.add_argument("--include", type=Path, required=True, help="directory with the Ghost VPI headers")
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if compiler is None:
        parser.error("a C compiler is required")
    tools = {"ghost": args.ghost.resolve(), "cc": Path(compiler).resolve(),
             **{name: args.include.resolve() / name for name in ("sv_vpi_user.h", "vpi_user.h")}}
    if not all(path.is_file() for path in tools.values()):
        parser.error("the Ghost executable and both VPI headers are required")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: digest(path) for name, path in tools.items()}
    runner = suite_results.runner_digest("ghost")
    checker = checker_digest()
    fingerprint = suite_results.input_digest(FIXTURE)
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, profile, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Frame observation stopped ({error}).\n")
    if (hashes != {name: digest(path) for name, path in tools.items()}
            or fingerprint != suite_results.input_digest(FIXTURE) or runner != suite_results.runner_digest("ghost")
            or checker != checker_digest() or profile_bytes != args.profile.read_bytes()):
        parser.exit(2, "Tools or inputs changed during the frame observation.\n")

    if not result["measured"]:
        verdict = ("unsupported", "the callback control or native table observations were unavailable")
    elif not result["ended_keys_absent"]:
        verdict = ("fail", "the native resolver still recognized an ended frame key")
    else:
        verdict = ("pass", "")
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs={CASE: fingerprint},
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": fingerprint, "status": verdict[0], **result}},
    }, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE, verdict[1])
    return int(verdict[0] != "pass")


if __name__ == "__main__":
    raise SystemExit(main())
