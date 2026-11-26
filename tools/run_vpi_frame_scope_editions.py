#!/usr/bin/env python3
"""Verify a frame-model change from the published clauses and a Ghost execution."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

import run_ghost
import suite_results


CHECKER = "tools/run_vpi_frame_scope_editions.py"
PROFILE = "ghost-vpi-frame-scope-editions"
CASE = "ch37/test_vpi_frame_scope_editions"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
EDITIONS = {
    "2017": ("37.41", "automatic variables declared in a given task or function", "1364-2005"),
    "2023": ("37.43", "any dynamically activated procedural scope", "1800-2017"),
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def source_check(pdf: Path, pdftotext: str, edition: str) -> dict:
    clause, scope, boundary = EDITIONS[edition]
    raw = subprocess.check_output([pdftotext, "-layout", str(pdf), "-"], text=True, timeout=90)
    heading = re.search(rf"^[ \t]*{re.escape(clause)}[ \t]+Frames[ \t]*$", raw, re.M)
    if heading is None:
        raise ValueError(f"could not locate the {edition} Frames clause")
    suffix = raw[heading.end():]
    next_clause = re.search(r"^[ \t]*37\.\d+[ \t]+[A-Z]", suffix, re.M)
    if next_clause is None:
        raise ValueError(f"could not bound the {edition} Frames clause")
    section = " ".join(suffix[:next_clause.start()].split())
    return {"clause": clause, "expected_scope_found": scope in section,
            "historical_boundary": boundary,
            "boundary_found": f"not backwards compatible with IEEE Std {boundary}" in section}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", type=Path, required=True)
    parser.add_argument("--include", type=Path, required=True, help="directory with the Ghost VPI headers")
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--pdf-2017", type=Path, required=True)
    parser.add_argument("--pdf-2023", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    extractor = shutil.which("pdftotext")
    if extractor is None:
        parser.error("pdftotext is required")
    include = args.include.resolve()
    tools = {"2017": args.pdf_2017.resolve(), "2023": args.pdf_2023.resolve(), "extractor": Path(extractor),
             "ghost": args.ghost.resolve(), **{name: include / name for name in ("vpi_user.h", "sv_vpi_user.h")}}
    if not all(path.is_file() for path in tools.values()):
        parser.error("both standards, the Ghost executable, and the public VPI headers are required")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: digest(path) for name, path in tools.items()}
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    try:
        clauses = {edition: source_check(tools[edition], extractor, edition) for edition in EDITIONS}
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(2, f"Frame source comparison stopped ({error}).\n")
    status, reason = run_ghost.run(fixture, str(tools["ghost"]), include, profile)
    if not all(row["expected_scope_found"] and row["boundary_found"] for row in clauses.values()):
        status, reason = "fail", "the two editions did not yield the expected frame definitions"
    if (hashes != {name: digest(path) for name, path in tools.items()}
            or checker != checker_digest() or runner != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints([fixture]) or profile_bytes != args.profile.read_bytes()):
        parser.exit(2, "Tools or inputs changed during the edition comparison.\n")

    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: (status, reason)}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "clauses": clauses, "status": status, "reason": reason}}},
    indent=2) + "\n", encoding="utf-8")
    print(status, CASE, reason)
    return int(status != "pass")


if __name__ == "__main__":
    raise SystemExit(main())
