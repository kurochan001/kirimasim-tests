#!/usr/bin/env python3
"""Fault controls for default argument selection, scope and evaluation counts."""

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
import interaction_default as model


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
    parents = dict(zip(("plain", "empty", "named", "both", "zero", "function"), model.MODEL.anchors))
    faults = (
        ("use_caller_instead_of_default", "plain", ".pick()", ".pick(source)"),
        ("wrong_variable_default", "plain", "mask_arg = mask_source", "mask_arg = '0"),
        ("wrong_default_function", "function", "data_arg = read_data()", "data_arg = read_mask()"),
        ("evaluate_data_default_twice", "function", "data_reads++;", "data_reads += 2;"),
        ("default_stuck_at_initial_zero", "function", "return source;", "return '0;"),
        ("eager_default_with_explicit_zero", "zero", "calls++; seen_data = data_arg;",
         "calls++; seen_data = read_data(); seen_data = data_arg;"),
        ("explicit_zero_becomes_omitted", "zero", ".pick('0, '0)", ".pick()"),
        ("empty_data_loses_default", "empty", ".pick(, mask_source)", ".pick('0, mask_source)"),
        ("named_data_loses_mask_default", "named", ".pick(.data_arg(source))",
         ".pick(.data_arg(source), .mask_arg('0))"),
        ("swap_named_bindings", "both", ".mask_arg(mask_source), .data_arg(source)",
         ".mask_arg(source), .data_arg(mask_source)"),
        ("invoke_wrong_instance", "function", "b.pick(", "a.pick("),
        ("lose_body_call_count", "function", "calls++;", ";"),
        ("logic_storage_becomes_bit", "empty", "typedef logic [128:0] word_t;", "typedef bit [128:0] word_t;"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "all six mandatory witnesses: every passing mode, both expression forms "
                                      "and both homes, known/X/Z controls and wide values"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
