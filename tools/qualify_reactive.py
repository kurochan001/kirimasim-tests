#!/usr/bin/env python3
"""Normal-exit controls for NBA fixed points, program context and Re-NBA readback."""

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
import interaction_reactive as model


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
    parents = dict(zip(("continuous", "nba", "blocking", "bit_unknown", "known", "bit_nba"),
                       model.MODEL.anchors))
    faults = []
    for label in ("continuous", "nba", "blocking"):
        original = "\n".join(model.producer_block(parents[label]))
        module = original.replace("program region_producer", "module region_producer").replace("endprogram", "endmodule")
        faults.append(("program_" + label + "_runs_in_module_region", label, original, module))
    wide_name = model.case_name(parents["nba"])
    bit_name = model.case_name(parents["bit_unknown"])
    block_name = model.case_name(parents["blocking"])
    faults += [
        ("program_nba_becomes_blocking", "nba", "y <= ~src;", "y = ~src;"),
        ("program_blocking_becomes_nba", "blocking", "y = ~src;", "y <= ~src;"),
        ("logic_source_becomes_bit", "nba", "logic [128:0] source", "bit [128:0] source"),
        ("bit_source_becomes_logic", "bit_unknown", "bit [32:0] source", "logic [32:0] source"),
        ("program_bypasses_source_conversion", "bit_unknown", "~src", "~" + bit_name + ".raw"),
        ("lose_final_pipeline_value", "nba", "s2 <= s1 ^ 129'd3;", "s2 <= '0;"),
        ("wrong_stage_transform", "blocking", "s1 <= s0 ^ 65'd2;", "s1 <= s0 ^ 65'd0;"),
        ("program_samples_wrong_stage", "blocking", block_name + ".s1", block_name + ".s0"),
        ("wrong_early_control_expression", "continuous", "assign tap = source;", "assign tap = ~source;"),
        ("lose_early_count", "continuous", "early_count++;", ";"),
        ("lose_late_count", "continuous", "late_count++;", ";"),
        ("lose_module_step_count", "nba", "module_steps++;", ";"),
        ("lose_program_visit_count", "nba", "visits++;", ";"),
        ("truncate_program_output", "nba", "y <= ~src;", "y <= 64'(~src);"),
        ("pipeline_bypasses_source_conversion", "bit_unknown", "s0 <= source ^ 33'd1;", "s0 <= raw ^ 33'd1;"),
        ("nba_readback_uses_rhs", "nba", "captured = y;", "captured = ~src;"),
    ]
    result = helper.qualify(model, parents, tuple(faults), lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: early module counterpart, NBA depths, three "
                                      "program producers, exported context, conversion and Re-NBA readback"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
