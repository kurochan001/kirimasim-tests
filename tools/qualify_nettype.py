#!/usr/bin/env python3
"""Normal-exit fault controls for default net type and implicit port boundaries."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

import qualify_assertion_wait as helper
import run_kirimasim
import run_icarus
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import interaction_nettype as model


def fixed_diagnostics(bindir):
    """Retain complete first differences from mandatory fixed-engine controls."""
    def redact(text):
        return re.sub(r"/(?:private/)?(?:var/folders|tmp)/[^\s'\"]+", "<temporary>",
                      text.replace(str(ROOT) + "/", ""))

    records = []
    for row in model.MODEL.anchors:
        test = ROOT / "tests/gen/ch22" / (model.case_name(row) + ".sv")
        codes, diagnostics, normalized = [], [], []
        original = subprocess.run

        def observed(*args, **kwargs):
            result = original(*args, **kwargs)
            codes.append(result.returncode)
            if result.stderr:
                diagnostics.append(redact(result.stderr))
            if len(args[0]) > 1 and str(args[0][1]).endswith("normalize_output.py"):
                normalized.append(result.stdout)
            return result

        subprocess.run = observed
        try:
            matched, reason = run_icarus.run(test, bindir.resolve())
        finally:
            subprocess.run = original
        difference = None
        if normalized:
            actual = normalized[-1].strip().splitlines()
            expected = suite_results.expected_output(test, "icarus").strip().splitlines()
            for i in range(max(len(actual), len(expected))):
                a = actual[i] if i < len(actual) else None
                e = expected[i] if i < len(expected) else None
                if a != e:
                    difference = {"line": i+1, "actual": redact(a) if a else a, "expected": e}
                    break
        records.append({"test": test.relative_to(ROOT).as_posix(),
                        "inputs_sha256": suite_results.input_digest(test), "matched": matched,
                        "reason": redact(reason), "subprocess_returncodes": codes,
                        "diagnostics": diagnostics, "first_difference_full": difference})
    return {"version": suite_results.tool_version([str(bindir.resolve() / "iverilog"), "-V"]),
            "runner_sha256": suite_results.runner_digest("icarus"), "temporary_paths_redacted": True,
            "scope": "Six mandatory controls only; not kirimasim fault controls.", "records": records}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--icarus-bin", type=Path)
    args = parser.parse_args()
    binary = Path(shutil.which(args.kirimasim) or args.kirimasim).resolve()
    version = suite_results.tool_version([str(binary), "--version"])
    if not re.fullmatch(r"[0-9a-f]{12,40}", args.commit) or args.commit[:12] not in version:
        parser.error("binary version must match the verified latest upstream commit")
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    parents = dict(zip(("wire", "wand", "wor", "triand", "trior", "tri"), model.MODEL.anchors))
    faults = (
        ("wand_becomes_wire", "wand", "`default_nettype wand", "`default_nettype wire"),
        ("wor_becomes_wire", "wor", "`default_nettype wor", "`default_nettype wire"),
        ("triand_becomes_trior", "triand", "`default_nettype triand", "`default_nettype trior"),
        ("trior_becomes_triand", "trior", "`default_nettype trior", "`default_nettype triand"),
        ("lose_explicit_vector_wire", "wor", "output wire [64:0] y", "output [64:0] y"),
        ("force_implicit_vector_to_wire", "wand", "output [128:0] y", "output wire [128:0] y"),
        ("ignore_resetall", "wand", "`resetall", ""),
        ("ignore_explicit_reset", "wor", "`default_nettype wire", ""),
        ("lose_first_vector_driver", "wire", "assign y = a;", "assign y = b;"),
        ("lose_second_vector_driver", "wand", "assign y = b;", ";"),
        ("lose_second_scalar_driver", "wor", "assign g = b[0];", ";"),
        ("scalar_uses_wrong_source_bit", "wand", "assign g = a[0];", "assign g = a[1];"),
        ("truncate_vector_port_above_64", "wand", "output [128:0] y", "output [63:0] y"),
        ("truncate_input_ports_above_64", "wand", "input [128:0] a, b", "input [63:0] a, b"),
        ("upper_word_reuses_lower_word", "wand", "assign y = a;", "assign y = {a[64:0], a[63:0]};"),
        ("scalar_port_inherits_vector_width", "trior", "output g;", "output [1:0] g;"),
        ("source_storage_becomes_two_state", "wand", "logic [128:0] a, b", "bit [128:0] a, b"),
        ("later_module_reuses_earlier_definition", "wand", "reset_port r(a, b, post, post_g);",
         "selected_port r(a, b, post, post_g);"),
        ("scalar_inherits_explicit_vector_net_kind", "wor", "output g);", "output wire g);"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "six mandatory controls: all net keywords, ANSI/non-ANSI declarations, "
                                      "vector/scalar defaults, explicit wire override, both resets and wide four-state data"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    wide = next(r for r in result["faults"] if r["name"] == "upper_word_reuses_lower_word")
    line = re.search(r"output differs: line (\d+)", wide["reason"])
    result["wide_word_reuse_detected_only_by_index_tags"] = bool(line and int(line[1]) > 16*4)
    if args.icarus_bin:
        result["fixed_icarus_diagnostics"] = fixed_diagnostics(args.icarus_bin)
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    passed = (result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"]
              and result["wide_word_reuse_detected_only_by_index_tags"])
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
