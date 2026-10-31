#!/usr/bin/env python3
"""Normal-exit controls for configuration precedence and generated shape."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import qualify_assertion_wait as helper
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import interaction_config as model


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
    parents = dict(zip(("base", "wide", "reset_w", "reset_all", "both", "local"), model.MODEL.anchors))
    base_clause = model.config_lines(parents["base"])[-2]
    wide_clause = model.config_lines(parents["wide"])[-2]
    faults = [
        ("ignore_config_override", "base", base_clause, ""),
        ("config_targets_wrong_sibling", "base", base_clause, base_clause.replace(".target", ".guard")),
        ("config_leaks_to_guard", "base", base_clause,
         base_clause + "\n" + base_clause.replace(".target", ".guard")),
        ("config_loses_to_defparam", "wide", wide_clause,
         "  instance cfg_top.box.target use #(.W(131), .MODE(2));"),
        ("parent_rhs_resolves_wrong_scope", "wide", "#(.W(cfg_top.box.PW), .MODE(cfg_top.box.PM))",
         "#(.W(133), .MODE(0))"),
        ("local_rhs_resolves_parent", "local", "#(.W(PW), .MODE(PM))",
         "#(.W(cfg_top.box.PW), .MODE(cfg_top.box.PM))"),
        ("selective_reset_resets_every_parameter", "reset_w", "use #(.W());", "use #();"),
        ("selective_reset_keeps_defparam_width", "both", "use #(.W());", "use #(.W(34));"),
        ("full_reset_only_resets_width", "reset_all", "use #();", "use #(.W());"),
        ("lose_defparam_other_parameters", "both", "  defparam target.N = 1;", ""),
        ("lose_instance_other_parameters", "local", "#(.W(65), .N(3), .MODE(1), .TAG(20)) ", ""),
        ("omit_last_generated_child", "wide", "i < N;", "i < N-1;"),
        ("select_wrong_generated_operation", "wide", ".OP(1)", ".OP(0)"),
        ("truncate_child_width", "wide", ".W(W), .TAG(TAG)", ".W(64), .TAG(TAG)"),
        ("lose_lane_specific_transform", "local", "W'(TAG+INDEX)", "W'(TAG)"),
        ("lose_instance_identity_in_data", "wide", "(ID+1)*2048", "2048"),
        ("truncate_input_history", "wide", "bitidx+1) >> phase", "(bitidx%64)+1) >> phase"),
        ("wrong_guard_width", "wide", ".ID(1), .W(135)", ".ID(1), .W(134)"),
        ("wrong_reported_child_width", "wide", "assign width_code = W;", "assign width_code = W-1;"),
    ]
    result = helper.qualify(model, parents, tuple(faults), lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: configuration precedence, selective/full reset, "
                                      "shadow scopes, generated count/width/branch and untouched sibling"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    # Keep the discovered failure visible beside independent minimal controls.
    # These diagnostic probes are not fault-injection detections or suite passes.
    diagnostics = []
    for label, prior, reset, expected in (
        ("all_reset_after_defparam", True, "#()", "W=1 N=2 MODE=0 TAG=10\n"),
        ("named_resets_after_defparam", True, "#(.W(), .N(), .MODE(), .TAG())",
         "W=1 N=2 MODE=0 TAG=10\n"),
        ("all_reset_after_instance", False, "#()", "W=1 N=2 MODE=0 TAG=10\n"),
        ("width_reset_after_defparam", True, "#(.W())", "W=1 N=1 MODE=2 TAG=30\n"),
    ):
        source = "\n".join([
            "module reset_leaf #(parameter W=1, N=2, MODE=0, TAG=10)();",
            '  initial $display("W=%0d N=%0d MODE=%0d TAG=%0d", W, N, MODE, TAG);',
            "endmodule", "module reset_top;",
            "  reset_leaf #(.W(2), .N(3), .MODE(1), .TAG(20)) target();",
            *(["  defparam target.W=3, target.N=1, target.MODE=2, target.TAG=30;"] if prior else []),
            "endmodule", "config reset_cfg;", "  design work.reset_top;",
            "  default liblist work;", f"  instance reset_top.target use {reset};", "endconfig", ""])
        with tempfile.TemporaryDirectory() as directory:
            test = Path(directory) / "reset_probe.sv"
            test.write_text(source)
            run = subprocess.run([str(binary), test.name], cwd=directory,
                                 capture_output=True, text=True, timeout=120)
        diagnostics.append({"name": label, "source": source, "source_sha256": helper.sha(source),
                            "expected": expected, "stdout": run.stdout, "stderr": run.stderr,
                            "returncode": run.returncode,
                            "matched": run.returncode == 0 and run.stdout == expected})
    result["reset_diagnostics"] = diagnostics
    result["reset_diagnostics_normal_exit"] = all(r["returncode"] == 0 for r in diagnostics)
    result["reset_diagnostic_controls_pass"] = all(r["matched"] for r in diagnostics[1:])
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if all(result[key] for key in ("binary_unchanged", "all_controls_pass", "all_faults_detected",
                                           "reset_diagnostics_normal_exit", "reset_diagnostic_controls_pass")) else 1


if __name__ == "__main__":
    sys.exit(main())
