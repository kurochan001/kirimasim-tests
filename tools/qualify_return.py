#!/usr/bin/env python3
"""Early-return fault controls on the verified latest kirimasim binary."""

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
import interaction_return as model


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
    parents = {"local": model.MODEL.anchors[0], "package": model.MODEL.anchors[1],
               "unknown": model.MODEL.anchors[2]}
    faults = (
        ("omit_early_return", "local", "return data;", ";"),
        ("wrong_early_value", "local", "return data;", "return '0;"),
        ("lose_scan_count", "local", "scanned++;", ";"),
        ("wrong_index_weight", "local", "weight += i + 1;", "weight += i;"),
        ("invoke_wrong_instance", "local", "b.invoke(", "a.invoke("),
        ("lose_wrapper_count", "local", "runs++;", ";"),
        ("lose_tail_count", "package", "tails++;", ";"),
        ("wrong_fallback_value", "package", "return backup;", "return data;"),
        ("execute_after_return", "package", "return backup;", "dead += 1000; return backup;"),
        ("write_caller_shadow", "package", "answer = return_pkg::pick(data, backup);",
         "answer = return_pkg::pick(data, backup); calls++;"),
        ("corrupt_package_guard", "package", "calls++; last = -2;", "calls++; guard = '0; last = -2;"),
        ("case_inequality_becomes_logical", "unknown", "data[i] !== 1'b0", "data[i] != 1'b0"),
        ("logic_storage_becomes_bit", "unknown", "typedef logic [64:0] word_t;", "typedef bit [64:0] word_t;"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "one-bit local for/head, 129-bit logic Z package repeat/none, "
                                      "65-bit logic X local while/middle; all retain known controls"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
