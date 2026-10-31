#!/usr/bin/env python3
"""Normal-exit controls for UDP array terminals and drive-strength resolution."""

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
import interaction_udp as model


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
    parents = dict(zip(("base", "wide", "asym", "override", "pull", "identity"), model.MODEL.anchors))
    faults = [
        ("swap_zero_one_strengths", "wide", "(weak0, strong1)", "(strong0, weak1)"),
        ("ignore_udp_drive_strength", "wide", "(weak0, strong1)", ""),
        ("weaken_contending_driver", "wide", "assign (pull0, pull1)", "assign (weak0, weak1)"),
        ("lose_contending_driver", "wide", "  assign (pull0, pull1) net = {129{rival}};", ""),
        ("contender_also_drives_isolated_control", "wide", "  assign (pull0, pull1) net = {129{rival}};",
         "  assign (pull0, pull1) net = {129{rival}};\n  assign (pull0, pull1) solo = {129{rival}};"),
        ("contender_never_releases", "wide", "{129{rival}}", "{129{1'b0}}"),
        ("vector_input_uses_wrong_terminal", "wide", "(net, a, b)", "(net, a, a)"),
        ("scalar_broadcast_uses_wrong_source", "override", "(net, a, b)", "(net, a, a[0])"),
        ("rotate_only_a_terminal", "wide", "(net, a, b)", "(net, {a[0], a[128:1]}, b)"),
        ("rotate_only_b_terminal", "wide", "(net, a, b)", "(net, a, {b[128], b[0:127]})"),
        ("truncate_a_above_64", "wide", "(net, a, b)", "(net, 129'(a[63:0]), b)"),
        ("unnamed_udp_samples_wrong_bit", "wide", "(sample, a[0], b[128])", "(sample, a[1], b[128])"),
        ("lose_unnamed_udp", "wide", "  cross_udp (weak0, strong1) (sample, a[0], b[128]);", ""),
        ("andnot_becomes_and", "asym", "    0 ? : 0;\n    ? 1 : 0;\n    1 0 : 1;",
         "    0 ? : 0;\n    ? 0 : 0;\n    1 1 : 1;"),
        ("omit_known_table_row", "asym", "    ? 1 : 0;", ""),
        ("unmatched_partial_unknown_row_becomes_zero", "wide", "  endtable", "    0 x : 0;\n  endtable"),
        ("input_storage_loses_unknowns", "wide", "logic [128:0] a;", "bit [128:0] a;"),
        ("isolated_array_uses_wrong_terminal", "wide", "(solo, a, b)", "(solo, b, b)"),
        ("omit_last_array_element", "wide", "competing[3:131](net, a, b)",
         "competing[3:130](net[0:127], a[127:0], b[0:127])"),
    ]
    result = helper.qualify(model, parents, tuple(faults), lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: UDP truth rows, scalar/vector terminals, "
                                      "packed/instance ranges, drive pairs, contention and isolated controls"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
