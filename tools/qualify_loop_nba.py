#!/usr/bin/env python3
"""Fault controls for looped assignments and instance-local NBA destinations."""

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
import interaction_loop_nba as model


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
    parents = {"nba": model.MODEL.anchors[0], "blocking": model.MODEL.anchors[2],
               "rotate": model.MODEL.anchors[1]}
    faults = (
        ("nba_updates_immediately", "nba", "target <= target ^ captured;", "target = target ^ captured;"),
        ("blocking_update_is_deferred", "blocking", "target[index] = target[index] ^ captured;",
         "target[index] <= target[index] ^ captured;"),
        ("lose_target_feedback", "blocking", "target[index] ^ captured", "captured"),
        ("reuse_first_mask", "rotate", "captured = raw;", "captured = raw0;"),
        ("logic_storage_becomes_bit", "rotate", "typedef logic [128:0] word_t;", "typedef bit [128:0] word_t;"),
        ("collapse_rotating_index", "rotate", "index = 2 + (i % 3);", "index = 2;"),
        ("reverse_array_route", "rotate", "target[index]", "target[6 - index]"),
        ("skip_last_iteration", "rotate", "repeat (5)", "repeat (4)"),
        ("invoke_wrong_instance", "rotate", "b.issue(", "a.issue("),
        ("lose_issued_count", "nba", "issued++;", ";"),
        ("lose_call_count", "nba", "calls++;", ";"),
        ("corrupt_guard", "rotate", "issued++;", "issued++; guard = '0;"),
        ("xor_becomes_or", "nba", "target ^ captured", "target | captured"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "one-bit module scalar NBA, 65-bit logic X interface same-element "
                                      "blocking feedback, 129-bit logic Z interface rotated NBA; "
                                      "all retain known controls"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
