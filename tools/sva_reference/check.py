#!/usr/bin/env python3
"""M2 pilot check: generate all selected outputs first, then compare expectations.

Offline by default. --emit-only never reads suite expected-output files.
--pilots is the ten-input M2 population, not an assertion of M3 coverage.
"""

import argparse
from dataclasses import asdict
import difflib
import json
from pathlib import Path
import re
import sys

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from sva_reference.pilots import PILOTS, ROOT, generate
else:
    from .pilots import PILOTS, ROOT, generate


def compare_expected(result):
    """The only M2 boundary that reads expected output, after generation."""
    path = ROOT / "tests/ch16" / (result.name + ".sv")
    metadata = re.search(r"^:expected_stdout:\s*@([^\s]+)\s*$", path.read_text(), re.M)
    if not metadata:
        raise ValueError("pilot needs an expected-output file in its metadata")
    expected_path = path.parent / metadata[1]
    if expected_path.resolve().parent != path.parent.resolve():
        raise ValueError("expected-output file must be next to the pilot source")
    expected = expected_path.read_text()
    diff = "".join(difflib.unified_diff(expected.splitlines(True), result.output.splitlines(True),
                                     fromfile=metadata[1], tofile=result.name + ".actual"))
    return {"test": result.name, "status": "match" if expected == result.output else "mismatch",
            "ticks": result.ticks, "actions": len(result.events), "diff": diff}


def run(names, *, refresh=False, iverilog_bin=None, emit_only=False, output_dir=None):
    # This two-phase boundary is intentional: no expectation can influence
    # generation for a later pilot in the same batch.
    generated = [generate(name, refresh=refresh, iverilog_bin=iverilog_bin) for name in names]
    if output_dir is not None:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        for result in generated:
            (output_dir / (result.name + ".actual")).write_text(result.output)
            payload = {"test": result.name, "attempts": result.attempts,
                       "events": [asdict(event) for event in result.events]}
            (output_dir / (result.name + ".events.json")).write_text(json.dumps(payload, indent=2) + "\n")
    if emit_only:
        return [{"test": result.name, "status": "generated", "ticks": result.ticks,
                 "actions": len(result.events), "diff": ""} for result in generated]
    return [compare_expected(result) for result in generated]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tests", type=Path, nargs="*")
    parser.add_argument("--pilots", action="store_true", help="all ten audited M2 pilot tests")
    parser.add_argument("--refresh-traces", action="store_true")
    parser.add_argument("--iverilog-bin", type=Path)
    parser.add_argument("--emit-only", action="store_true", help="generate without reading any expectation")
    parser.add_argument("--output-dir", type=Path, help="save generated stdout and action evidence")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    if args.pilots == bool(args.tests):
        parser.error("select either --pilots or specific audited tests")
    if args.refresh_traces and args.iverilog_bin is None:
        parser.error("--refresh-traces requires --iverilog-bin (13.0 stable)")
    names = list(PILOTS) if args.pilots else []
    for path in args.tests:
        name = path.stem
        if name not in PILOTS or path.resolve() != (ROOT / "tests/ch16" / (name + ".sv")).resolve():
            parser.error(f"no audited M2 adapter for {path}")
        if name not in names:
            names.append(name)
    try:
        results = run(names, refresh=args.refresh_traces, iverilog_bin=args.iverilog_bin,
                      emit_only=args.emit_only, output_dir=args.output_dir)
    except (ValueError, OSError) as exc:
        parser.exit(2, f"M2 input unsupported or stale: {exc}\n")
    if args.json:
        print(json.dumps(results, indent=2))
    else:
        for result in results:
            print(f"{result['status'].upper()} {result['test']}: {result['ticks']} ticks, {result['actions']} actions")
            if result["diff"]:
                print(result["diff"], end="")
        if args.emit_only:
            print(f"{len(results)} generated; expectations not read")
        else:
            matches = sum(result["status"] == "match" for result in results)
            print(f"{len(results)} generated; {matches} matched; "
                  f"{sum(result['status'] == 'mismatch' for result in results)} mismatched")
    return 1 if any(result["status"] == "mismatch" for result in results) else 0


if __name__ == "__main__":
    sys.exit(main())
