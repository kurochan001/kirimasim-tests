#!/usr/bin/env python3
"""Normal-exit controls for interface header imports and package formal conversion."""

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
import interaction_ifimport as model


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
    relay = "\n".join(model.packages(parents["wide"]))
    relay = relay[relay.index("package bridge_pkg;"):]
    wide_name = model.case_name(parents["wide"])
    faults = [
        ("explicit_header_imports_wrong_package", "bit_x", "import pkg_a::", "import pkg_b::"),
        ("reexport_binds_wrong_original_package", "wide", relay, relay.replace("pkg_b", "pkg_a")),
        ("defaults_use_caller_scope", "base", "#(parameter int W=BASE, TAG=MARK)",
         "#(parameter int W=4, TAG=99)"),
        ("actual_arguments_use_package_defaults", "known", "#(.W(BASE), .TAG(MARK))",
         "#(.W(32), .TAG(11))"),
        ("lose_narrow_width_override", "bit_x", "#(.W(LOW)) ", ""),
        ("target_overrides_leak_to_guard", "known", "  imported_bus guard(",
         "  imported_bus #(.W(BASE), .TAG(MARK)) guard("),
        ("instance_width_changes_imported_input_type", "wide", "input raw_t incoming;",
         "input logic [W-1:0] incoming;"),
        ("internal_type_binds_wrong_package", "wide", "word_t typed, stored;",
         "pkg_a::word_t typed, stored;"),
        ("function_binds_caller_shadow", "wide", "encode(incoming)", wide_name+".encode(incoming)"),
        ("inline_operation_bypasses_formal_conversion", "bit_x", "encode(incoming)", "~incoming"),
        ("bit_formal_and_storage_become_logic", "bit_x", "typedef bit [BASE-1:0] word_t;",
         "typedef logic [BASE-1:0] word_t;"),
        ("logic_formal_and_storage_become_bit", "wide", "typedef logic [BASE-1:0] word_t;",
         "typedef bit [BASE-1:0] word_t;"),
        ("raw_input_type_becomes_word_type", "bit_x", "input raw_t incoming;", "input word_t incoming;"),
        ("wrong_package_operation", "bit_x", "return ~data;", "return data;"),
        ("function_formal_loses_early_conversion", "bit_x",
         "typedef bit [BASE-1:0] word_t;\n  function automatic word_t encode(input word_t data);",
         "typedef bit [BASE-1:0] word_t;\n  function automatic word_t encode(input raw_t data);"),
        ("unsigned_word_is_sign_extended", "wide", "W'(stored)", "W'($signed(stored))"),
        ("encoded_word_truncates_above_64", "wide", "W'(stored)", "W'(64'(stored))"),
        ("tag_missing_from_functional_output", "known", "W'(TAG)", "W'(0)"),
        ("guard_input_aliases_target", "wide", "guard(.incoming(raw_guard))",
         "guard(.incoming(raw_target))"),
        ("upper_input_word_reuses_lower_bits", "wide", "target(.incoming(raw_target))",
         "target(.incoming({raw_target[66:0], raw_target[63:0]}))"),
    ]
    result = helper.qualify(model, parents, tuple(faults), lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: header binding, exported declaration identity, "
                                      "caller/default scopes, package formal conversion and independent guard parameters"})
    conversion = next(r for r in result["faults"] if r["name"]=="inline_operation_bypasses_formal_conversion")
    difference = re.search(r"output differs: line (\d+)", conversion["reason"])
    result["conversion_fault_known_prefix"] = {
        "known_trace_lines": 55, "first_difference_line": int(difference.group(1)) if difference else None,
        "known_frames_still_match": bool(difference and int(difference.group(1))==56)}
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if all((result["binary_unchanged"], result["all_controls_pass"], result["all_faults_detected"],
                     result["conversion_fault_known_prefix"]["known_frames_still_match"])) else 1


if __name__ == "__main__":
    sys.exit(main())
