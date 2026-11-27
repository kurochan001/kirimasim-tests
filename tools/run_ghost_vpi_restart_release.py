#!/usr/bin/env python3
"""Check Ghost handle retirement at restart without using expired VPI handles."""

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


CHECKER = "tools/run_ghost_vpi_restart_release.py"
PROFILE = "ghost-vpi-restart-release"
CASE = "ch37/test_vpi_restart_releases_previous_handles"
FIXTURE = suite_results.ROOT / "tests" / (CASE + ".sv")
CASES = {CASE: FIXTURE}
HANDLES = ("module_scope", "register", "packed_bit", "scheduled_event", "value_change_callback",
           "end_of_simulation_callback", "start_restart_callback", "end_restart_callback")
ALL_LIVE = "11111111"
RESTART_CALLBACKS_ONLY = "00000011"
TABLE = re.compile(r"restart table (before|start|end|resumed)=([01]{8})")
CHECKPOINT_LOG = re.compile(
    r"(?:Checkpoint 'handle-lifetime\.chk' saved successfully at time \d+"
    r"|Simulation restored from checkpoint 'handle-lifetime\.chk' at time \d+"
    r"|Simulation restart initiated from checkpoint 'handle-lifetime\.chk')")
CONTROL_OUTPUT = [
    "armed scope=1 watched=1 bit=1 event=1 callbacks=1111",
    "restored value=17",
    "fresh register=1 callback=1",
    "restart hits=0,0 old pre=3 old post=0 fresh=1",
    "old end-of-simulation callback fired",
]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    fingerprint = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    fingerprint.update(suite_results.runner_digest("ghost").encode())
    return fingerprint.hexdigest()


def observe(executable: Path, library: Path, profile: dict, work: Path, no_restart: bool = False) -> dict:
    sources, includes = suite_results.files(FIXTURE)
    command = [
        str(executable), *profile["arguments"], "--lib", str(library), *[f"+incdir+{path}" for path in includes],
        "-top", suite_results.top_module(FIXTURE), *map(str, sources), str(FIXTURE),
    ]
    if no_restart:
        command.append("+no_restart")
    work.mkdir()
    run = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                         text=True, errors="replace", capture_output=True, timeout=45)
    tables, output = [], []
    for line in run_ghost.normalize(run.stdout, profile).splitlines():
        if table := TABLE.fullmatch(line):
            tables.append({"phase": table[1], "present": table[2]})
        elif not CHECKPOINT_LOG.fullmatch(line):
            output.append(line)
    return {"exit": run.returncode, "handle_tables": tables, "stdout": output}


def evaluate(restart: dict, control: dict, expected: list[str]) -> tuple[str, str]:
    control_tables = [{"phase": phase, "present": ALL_LIVE} for phase in ("before", "resumed")]
    restart_tables = restart["handle_tables"]
    if (control["exit"] != 0 or control["stdout"] != CONTROL_OUTPUT or control["handle_tables"] != control_tables
            or restart["exit"] != 0 or restart["stdout"][:5] != expected[:5]
            or [table["phase"] for table in restart_tables] != ["before", "start", "end", "resumed"]
            or restart_tables[0]["present"] != ALL_LIVE):
        return "unsupported", "the live handles, successful restart, or native table observations were unavailable"
    if (any(table["present"] != RESTART_CALLBACKS_ONLY for table in restart_tables[2:])
            or restart["stdout"] != expected):
        return "fail", "old handles or callbacks survived a successful restart"
    return "pass", ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True, type=Path)
    parser.add_argument("--include", required=True, type=Path, help="directory containing the Ghost VPI headers")
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    compiler = shutil.which(os.environ.get("CC", "cc"))
    paths = {"ghost": args.ghost.resolve(), "header": args.include.resolve() / "vpi_user.h"}
    if not compiler or not all(path.is_file() for path in paths.values()):
        parser.error("Ghost, its VPI header and a C compiler are required")
    paths["compiler"] = Path(compiler).resolve()
    profile = args.profile.read_bytes()
    config = json.loads(profile)
    if "--lrm-strict" not in config["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    artifact_hashes = {name: digest(path) for name, path in paths.items()}
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    inputs = suite_results.input_digest(FIXTURE)
    expected = suite_results.expected_output(FIXTURE).splitlines()
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            library = work / "restart-probe.so"
            link = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else ["-ldl"]
            build = subprocess.run(
                [compiler, "-shared", "-fPIC", "-DRESTART_HANDLE_TABLE", f"-I{paths['header'].parent}",
                 str(FIXTURE.with_suffix(".c")), *link, "-o", str(library)],
                cwd=work, capture_output=True, text=True, timeout=30)
            if build.returncode:
                parser.exit(2, f"The restart observation library did not compile (exit {build.returncode}).\n")
            restart = observe(paths["ghost"], library, config, work / "restart")
            control = observe(paths["ghost"], library, config, work / "control", no_restart=True)
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Restart observation stopped ({error}).\n")

    if (artifact_hashes != {name: digest(path) for name, path in paths.items()}
            or checker != checker_digest() or inputs != suite_results.input_digest(FIXTURE)
            or profile != args.profile.read_bytes()):
        parser.exit(2, "Tools or inputs changed during the restart observation.\n")
    verdict = evaluate(restart, control, expected)
    version = f"private build {artifact_hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": artifact_hashes,
                     "profile_sha256": hashlib.sha256(profile).hexdigest()}
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs={CASE: inputs},
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs, "status": verdict[0], "handle_order": HANDLES,
                         "expected_after_restart": RESTART_CALLBACKS_ONLY, "expected_stdout": expected,
                         "restart": restart, "control": control}},
    }, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE, verdict[1])
    return int(verdict[0] != "pass")


if __name__ == "__main__":
    raise SystemExit(main())
