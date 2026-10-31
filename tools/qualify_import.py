#!/usr/bin/env python3
"""Fault controls for package imports, wildcard port binding and scoped defaults."""

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
import interaction_import as model


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
    parents = dict(zip(("star", "short", "explicit", "shadow", "qualified", "zero"),
                       model.MODEL.anchors))
    parents["named"] = next(row for row in model.MODEL.select()
                            if row[3:] == ("wild", "none", "named"))
    shadow_before = "\n".join(model.parent(parents["shadow"]))
    shadow_after = shadow_before.replace(".y(left), .*", ".y(left), .p(port_source::p), .*").replace(
        ".y(right), .*", ".y(right), .p(port_source::p), .*")
    faults = (
        ("force_import_in_star_scope", "star", "module port_parent;\n  import port_source::*;",
         "module port_parent;\n  import port_source::*;\n  wire force_p = ^p;"),
        ("leak_import_into_guard", "star", "module port_guard;\n  import port_source::*;",
         "module port_guard;\n  import port_source::p;"),
        ("explicit_import_becomes_wildcard", "explicit", "import port_source::p;", "import port_source::*;"),
        ("lose_short_name_reference", "short", ".p, .*", ".*"),
        ("lose_named_reference", "named", ".p(p), .*", ".*"),
        ("qualified_connection_loses_qualification", "qualified", ".p(port_source::p)", ".p(p)"),
        ("ignore_local_shadow", "shadow", shadow_before, shadow_after),
        ("explicit_zero_uses_package", "zero", ".p('0)", ".p(port_source::p)"),
        ("collapse_opposite_defaults", "star", ".FALLBACK('1)", ".FALLBACK('0)"),
        ("lose_package_updates", "explicit", "writer.drive(raw);", ";"),
        ("local_shadow_gets_package_stimulus", "shadow", "dut.p = local_stimulus;", "dut.p = raw;"),
        ("bit_sample_becomes_logic", "shadow", "bit [32:0] left_sample", "logic [32:0] left_sample"),
        ("logic_sample_becomes_bit", "short", "logic [128:0] left_sample", "bit [128:0] left_sample"),
        ("invert_child_output", "star", "assign y = p;", "assign y = ~p;"),
        ("truncate_child_output", "short", "output wire [128:0] y", "output wire [127:0] y"),
        ("explicit_zero_becomes_one", "zero", ".p('0)", ".p('1)"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "all six mandatory witnesses plus one selected unqualified named "
                                      "connection; default pairs, scope isolation, shadows, live values "
                                      "and final bit/logic conversion"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
