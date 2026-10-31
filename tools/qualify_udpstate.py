#!/usr/bin/env python3
"""Normal-exit controls for generated sequential UDP states and independent clocks."""

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
import interaction_udpstate as model


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
    parents = dict(zip(("base", "wide", "bit_x", "logic_x", "known", "bit_z"), model.MODEL.anchors))
    unknown_prefix = "primitive seq2(q, clk, d);\n  output q;\n  reg q;\n  input clk, d;\n"
    original_table = "\n".join(model.primitives(parents["base"]))
    wrong_edge = original_table.replace("(01)", "(10)").replace("(?0)", "(?1)")
    faults = [
        ("lose_zero_initial_state", "wide", "  initial q = 1'b0;", ""),
        ("wrong_one_initial_state", "base", "  initial q = 1'b1;", "  initial q = 1'b0;"),
        ("uninitialized_state_becomes_zero", "wide", unknown_prefix,
         unknown_prefix + "  initial q = 1'b0;\n"),
        ("wrong_generate_selector", "wide", "(i+2)%3", "(i+1)%3"),
        ("selected_branch_uses_wrong_udp", "base", "seq0 u(q[i]", "seq1 u(q[i]"),
        ("guard_reuses_target_initial_category", "base", "seq1 v(guard[i]", "seq0 v(guard[i]"),
        ("logic_storage_becomes_bit", "wide", "logic [128:0] source;", "bit [128:0] source;"),
        ("bit_storage_becomes_logic", "bit_x", "bit [64:0] source;", "logic [64:0] source;"),
        ("target_bypasses_storage_conversion", "bit_x", "u(q[i], clocks[i], source[i])",
         "u(q[i], clocks[i], raw[i])"),
        ("guard_loses_data_inversion", "wide", "guard_data = ~source", "guard_data = source"),
        ("guard_uses_target_clock", "wide", "v(guard[i], guard_clk, guard_data[i])",
         "v(guard[i], clocks[i], guard_data[i])"),
        ("target_uses_guard_clock", "wide", "u(q[i], clocks[i], source[i])",
         "u(q[i], guard_clk, source[i])"),
        ("masked_target_uses_shared_clock", "wide", "u(q[i], clocks[i], source[i])",
         "u(q[i], clk, source[i])"),
        ("capture_edge_reversed", "base", original_table, wrong_edge),
        ("capture_zero_becomes_one", "wide", "(10) 0 : ? : 0;", "(10) 0 : ? : 1;"),
        ("lose_data_change_hold", "wide", "    ? * : ? : -;", ""),
        ("lose_return_edge_hold", "base", "    (?0) ? : ? : -;", ""),
        ("unknown_capture_holds_previous_state", "wide", "    ? * : ? : -;",
         "    (10) x : ? : -;\n    ? * : ? : -;"),
        ("upper_word_reuses_lower_bits", "wide", "source = raw;", "source = {raw[64:0], raw[63:0]};"),
        ("guard_clock_never_activates", "base", "    guard_clk = 1'b1;", "    guard_clk = 1'b0;"),
        ("target_states_share_one_output_bit", "wide", "u(q[i],", "u(q[0],"),
    ]
    result = helper.qualify(model, parents, tuple(faults), lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: generated initial categories, separate states, "
                                      "data/return holds, rising/falling capture, source conversion and guard recovery"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
