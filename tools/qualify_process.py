#!/usr/bin/env python3
"""Fault controls for implicit sensitivity, disabled gates and instance isolation."""

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
import interaction_process as model


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
    parents = {"direct": model.MODEL.anchors[0], "latch": model.MODEL.anchors[1],
               "function": model.MODEL.anchors[2]}
    faults = (
        ("comb_loses_default", "direct", "else q = '0;", ";"),
        ("latch_loses_hold", "latch", "if (en) q <= compute();", "if (en) q <= compute(); else q <= '0;"),
        ("unknown_gate_is_true", "function", "if (en) q", "if (en !== 1'b0) q"),
        ("function_omits_data", "latch", "return data ^ mask;", "return mask;"),
        ("function_omits_mask", "function", "return data ^ mask;", "return data;"),
        ("noise_enters_sensitivity", "function", "q = compute();", "q = compute() ^ noise;"),
        ("lose_execution_count", "direct", "if (events < 512) events++;", ";"),
        ("lose_time_zero_run", "direct", "always_comb begin", "always @(en or data or mask) begin"),
        ("update_wrong_instance", "direct", "b.data =", "a.data ="),
        ("logic_storage_becomes_bit", "latch", "typedef logic [128:0] word_t;", "typedef bit [128:0] word_t;"),
        ("wrong_comb_default", "direct", "else q = '0;", "else q = '1;"),
        ("latch_ignores_enable", "latch", "if (en) q", "if (1'b1) q"),
        ("function_xor_becomes_or", "function", "return data ^ mask;", "return data | mask;"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "one-bit direct comb/module, 129-bit logic Z function/latch/interface, "
                                      "65-bit logic X function/comb/interface; known controls in all parents"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
