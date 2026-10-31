#!/usr/bin/env python3
"""Normal-exit fault controls for generated interface bindings and guards."""

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
import interaction_ifgenerate as model


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
    parents = dict(zip(("scalar", "wide", "unknown", "bit_flip", "bit_known", "plain"), model.MODEL.anchors))
    expr = "assign p.payload = FLIP ? ~raw : raw;"
    faults = (
        ("wrong_selected_branch", "scalar", "localparam bit SELECT = 0;", "localparam bit SELECT = 1;"),
        ("lose_selected_complement", "wide", expr, "assign p.payload = raw;"),
        ("force_complement_on_direct_route", "scalar", expr, "assign p.payload = ~raw;"),
        ("logic_payload_becomes_bit", "wide", "logic [W-1:0] payload;", "bit [W-1:0] payload;"),
        ("bit_payload_becomes_logic", "bit_flip", "bit [W-1:0] payload;", "logic [W-1:0] payload;"),
        ("convert_before_complement", "bit_flip", expr,
         "bit [W-1:0] converted;\n  assign converted = raw;\n  assign p.payload = FLIP ? ~converted : converted;"),
        ("reader_binds_guard_interface", "wide", "r(.p(b), .seen", "r(.p(a), .seen"),
        ("lose_reader_tag", "wide", "assign sid = p.tag;", "assign sid = 0;"),
        ("lose_guard_payload", "scalar", "= guard_data;", "= '0;"),
        ("guard_tags_alias_first_element", "wide", "= -1-i;", "= -1;"),
        ("active_tags_alias_first_element", "wide", ".ID(111+i)", ".ID(111)"),
        ("writer_reads_first_element", "wide", ".raw(raw)", ".raw(g[0].raw)"),
        ("generated_width_loses_index", "wide", "W = BASE+i;", "W = BASE;"),
        ("interface_parameter_loses_index", "wide", "lane_if #(W) a(), b();", "lane_if #(BASE) a(), b();"),
        ("lose_writer_payload", "wide", expr, "assign p.payload = '0;"),
        ("truncate_reader_above_64", "wide", "assign seen = p.payload;", "assign seen = 64'(p.payload);"),
        ("reader_reuses_lower_word", "wide", "assign seen = p.payload;",
         "assign seen = {p.payload[64:0], p.payload[63:0]};"),
        ("corrupt_guard_payload", "wide", "= guard_data;", "= ~guard_data;"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: generated widths, if/case routes, whole/modport "
                                      "bindings, live guards, position/role histories and conversion order"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
