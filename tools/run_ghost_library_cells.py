#!/usr/bin/env python3
"""Check which design a library-qualified configuration selects in Ghost."""

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


PROFILE = "ghost-library-cells"
CHECKER = "tools/run_ghost_library_cells.py"
CASE = "ch3/test_library_contains_all_seven_cell_categories"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def check_library_cells(test: Path, simulator: str, profile: dict) -> tuple[str, str]:
    sources, _ = suite_results.files(test)
    mapping = test.parent / "library_cell_categories/providers.map"
    match = re.fullmatch(r"library (\w+) ([\w.]+);\s*", mapping.read_text(encoding="utf-8"))
    if not match or sources != [(mapping.parent / match[2]).resolve()]:
        raise ValueError("expected the case's single named library mapping")
    library, source = match[1], sources[0]
    expected = suite_results.expected_output(test)
    for name, output in ((library, expected), ("work", "selected work instead\n")):
        # Ghost assigns files to a named library with -v LIBRARY=FILE.
        with tempfile.TemporaryDirectory() as work:
            try:
                result = subprocess.run(
                    [simulator, *profile["arguments"], "--config", f"{name}.provider_cfg",
                     "-v", f"{library}={source}", str(test)],
                    cwd=work, env={**os.environ, **profile["environment"]},
                    capture_output=True, text=True, errors="replace", timeout=90,
                )
            except (OSError, subprocess.TimeoutExpired):
                return "fail", "named library run could not start or timed out"
        if result.returncode != 0 or run_ghost.normalize(result.stdout, profile) != output:
            return "fail", f"qualified {name} configuration did not produce its expected output"
    return "pass", ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, help="private Ghost executable")
    parser.add_argument("--profile", type=Path, required=True, help="private runtime profile")
    parser.add_argument("--json", type=Path, required=True, help="write public results to this file")
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("Ghost executable is unavailable")
    simulator = Path(program).resolve()
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    binary_hash = hashlib.sha256(simulator.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints(list(CASES.values()))
    status, reason = check_library_cells(CASES[CASE], str(simulator), profile)
    if (binary_hash != hashlib.sha256(simulator.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Ghost, the library checker, the profile or simulation inputs changed.\n")
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}",
                        {CASE: (status, reason)}, inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                                       "binary_sha256": binary_hash,
                                       "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()})
    print(f"{status.upper()} {CASE}" + (f": {reason}" if reason else ""))
    return int(status != "pass")


if __name__ == "__main__":
    raise SystemExit(main())
