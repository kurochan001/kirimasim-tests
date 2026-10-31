#!/usr/bin/env python3
"""Fault controls for generate hierarchy and package/local lookup decisions."""

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
import interaction_generate as model


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
    parents = {"plain": model.MODEL.anchors[0], "import": model.MODEL.anchors[1],
               "qualified": model.MODEL.anchors[2]}
    faults = (
        ("wrong_package_width", "plain", "localparam int WIDTH = 1;", "localparam int WIDTH = 2;"),
        ("wrong_package_constant", "plain", "localparam int ORIGIN = 5;", "localparam int ORIGIN = 4;"),
        ("lose_genvar_index", "plain", "localparam int INDEX = g;", "localparam int INDEX = 0;"),
        ("ignore_loop_in_branch_selection", "plain", "SELECT + g", "SELECT"),
        ("wrong_instance_parameter", "plain", "#(.SELECT(1)) b()", "#(.SELECT(0)) b()"),
        ("wrong_local_width", "import", "scope_pkg::WIDTH + 1;", "scope_pkg::WIDTH + 2;"),
        ("wrong_local_constant", "import", "localparam int ORIGIN = 9;", "localparam int ORIGIN = 5;"),
        ("wrong_local_state_type", "import", "typedef bit [WIDTH-1:0] word_t;", "typedef logic [WIDTH-1:0] word_t;"),
        ("ignore_import_shadow", "import", "typedef word_t used_t;", "typedef scope_pkg::word_t used_t;"),
        ("ignore_explicit_qualification", "qualified",
         "typedef bit [WIDTH-1:0] word_t;\n      typedef scope_pkg::word_t used_t;",
         "typedef bit [WIDTH-1:0] word_t;\n      typedef word_t used_t;"),
        ("lose_continuous_source", "plain", "assign value = source ^", "assign value = '0 ^"),
        ("update_wrong_instance", "plain", "b.source =", "a.source ="),
        ("xor_becomes_or", "plain", "source ^ used_t'", "source | used_t'"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "one-bit import/no-shadow, 129-bit logic Z nested case/import/local, "
                                      "65-bit logic X nested if/qualified/local; known controls in all parents"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
