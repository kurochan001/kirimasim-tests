#!/usr/bin/env python3
"""Fault controls for continuous delay selection and inertial pulse rejection."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys

import qualify_assertion_wait as helper
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import interaction_delay as model


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    binary = Path(shutil.which(args.kirimasim) or args.kirimasim).resolve()
    version = suite_results.tool_version([str(binary), "--version"])
    if not re.fullmatch(r"[0-9a-f]{12,40}", args.commit) or args.commit[:12] not in version:
        parser.error("binary version must match the verified latest upstream commit")
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    parents = dict(zip(("scalar", "vector", "wide", "bit", "invert", "known", "two"),
                       model.MODEL.anchors))
    body = model.make_case(parents["invert"]).body
    declaration = "  wire [32:0] delayed;"
    assignment = "  assign #(5) delayed = rhs;"
    start, end = body.index(declaration), body.index(assignment) + len(assignment)
    inertial = body[start:end]
    transport = inertial.replace(declaration, "  logic [32:0] delayed;").replace(
        assignment, "  always @(rhs) delayed <= #5 rhs;")
    faults = (
        ("wrong_scalar_minimum_delay", "scalar", "#(7, 5, 2)", "#(7, 5, 9)"),
        ("lose_explicit_turnoff_delay", "vector", "#(7, 5, 2)", "#(7, 5)"),
        ("swap_rise_fall", "known", "#(7, 3)", "#(3, 7)"),
        ("wrong_single_delay", "invert", "#(5)", "#(1)"),
        ("lose_source_inversion", "invert", "assign rhs = ~source;", "assign rhs = source;"),
        ("bit_source_becomes_logic", "bit", "bit [64:0] source;", "logic [64:0] source;"),
        ("logic_source_becomes_bit", "vector", "logic [1:0] source;", "bit [1:0] source;"),
        ("lose_source_updates", "known", "source = raw;", ";"),
        ("invert_delayed_driver", "known", "delayed = rhs;", "delayed = ~rhs;"),
        ("short_pulse_becomes_long", "invert", "        #1;\n        raw =",
         "        #10;\n        raw ="),
        ("double_change_count", "scalar", "changes++;", "changes += 2;"),
        ("lose_change_count", "known", "changes++;", ";"),
        ("wrong_transition_timestamp", "two", "last = $time - 20;", "last = $time - 19;"),
        ("truncate_wide_net", "wide", "wire [128:0] delayed;", "wire [63:0] delayed;"),
        ("transport_instead_of_inertial", "invert", inertial, transport),
        ("wrong_vector_rise_delay", "vector", "#(7, 5, 2)", "#(2, 5, 2)"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "all seven mandatory witnesses: scalar/vector, all profiles, bit/logic, "
                                      "known/X/Z, short/long pulses, inversion and word boundaries"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
