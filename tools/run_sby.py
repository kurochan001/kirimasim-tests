#!/usr/bin/env python3
"""Run the suite tests whose :type: is formal with SymbiYosys.

A formal test names a case of tools/sva_reference/formal_cases.py in its
:formal_case: field. The case exports the reference evaluator as a finite
state machine and compares it with an independently written RTL monitor over
symbolic inputs. This runner only records whether that comparison holds; it
does not use a simulator or read an expected-output file.

Usage:
    python3 tools/run_sby.py [--sby PATH] [--json FILE] [--no-prove] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv whose :type: is formal.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
TOOLS = ROOT / "tools"


def formal_tests(tests: list[Path]) -> list[Path]:
    out = []
    for test in tests:
        if suite_results.header(test).get("type") == "formal":
            out.append(test)
    return sorted(out)


def sby_version(sby: Path) -> str:
    proc = subprocess.run([str(sby), "--version"], capture_output=True, text=True,
                          timeout=30)
    text = (proc.stdout + proc.stderr).strip().splitlines()
    return text[0] if text else "unknown SBY version"


def run_case(sby: Path, case: str, prove: bool, timeout: int) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory(prefix="sby-") as tmp:
        out = Path(tmp) / "run"
        cmd = [sys.executable, "-m", "sva_reference.formal", "--sby", str(sby),
               "--case", case, "--timeout", str(timeout), "--output-dir", str(out)]
        if not prove:
            cmd.append("--no-prove")
        env = dict(os.environ)
        env["PYTHONPATH"] = str(TOOLS) + (os.pathsep + env["PYTHONPATH"]
                                          if env.get("PYTHONPATH") else "")
        proc = subprocess.run(cmd, cwd=ROOT, env=env, capture_output=True,
                              text=True, timeout=timeout + 120)
        report_path = out / "results.json"
        if not report_path.is_file():
            detail = (proc.stderr or proc.stdout).strip().splitlines()
            return False, detail[-1] if detail else "no formal result"
        report = json.loads(report_path.read_text())
        if not report.get("ok"):
            bad = [j["case"] + ": " + j["status"] for j in report.get("jobs", [])
                   if not j.get("ok")]
            return False, "; ".join(bad) or "formal check failed"
        return True, ""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--sby", type=Path, default=None)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--no-prove", action="store_true",
                    help="bounded model checking only")
    ap.add_argument("--timeout", type=int, default=30)
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    sby = args.sby or (shutil.which("sby") and Path(shutil.which("sby")))
    if sby is None:
        print("sby not found; pass --sby", file=sys.stderr)
        return 2
    sby = sby.resolve()
    if not sby.is_file():
        print(f"no such sby: {sby}", file=sys.stderr)
        return 2

    tests = formal_tests(args.tests or suite_results.find_tests())
    if not tests:
        print("no formal tests", file=sys.stderr)
        return 2

    inputs = suite_results.fingerprints(tests)
    results = {}
    for test in tests:
        case = suite_results.header(test).get("formal_case", "")
        if not case:
            results[suite_results.test_id(test)] = ("fail", "no :formal_case:")
            continue
        ok, reason = run_case(sby, case, not args.no_prove, args.timeout)
        results[suite_results.test_id(test)] = ("pass" if ok else "fail", reason)
        print(f"{'PASS' if ok else 'FAIL'} {suite_results.test_id(test)} ({case})"
              + (f": {reason}" if reason else ""), flush=True)

    if args.json:
        suite_results.write(args.json, "sby", "SymbiYosys", sby_version(sby),
                            results, inputs=inputs,
                            configuration={"prove": not args.no_prove,
                                           "timeout": args.timeout},
                            runner_sha256=suite_results.runner_digest("sby"))
    return 0 if all(status == "pass" for status, _ in results.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
