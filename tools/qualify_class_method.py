#!/usr/bin/env python3
"""Executable fault controls for the finite class-method interaction model.

Fixed Verilator 5.052 qualifies known inputs; fixed Icarus 13.0 qualifies
four-state direct/input observations. Neither qualifies all X/Z reference
or virtual behavior. A fault counts only on a normally exited output mismatch.
"""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import run_icarus
import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import common
import interaction_class_method as model


def digest(text):
    return hashlib.sha256(text.encode()).hexdigest()


def qualifies(record, control=False):
    return bool(record["subprocess_returncodes"]) and all(
        code == 0 for code in record["subprocess_returncodes"]) and (
        record["status"] == "pass" if control else
        record["status"] == "fail" and record["reason"].startswith("output differs: line "))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    icarus = args.iverilog_bin.resolve()
    vv = suite_results.tool_version([args.verilator, "--version"])
    iv = suite_results.tool_version([str(icarus / "iverilog"), "-V"])
    if not vv.startswith("Verilator 5.052 ") or "Icarus Verilog version 13.0" not in iv:
        parser.error("fixed Verilator 5.052 and Icarus 13.0 are required")
    parents = {
        "ref": model.MODEL.anchors[0],
        "base": model.MODEL.anchors[4],
        "virtual": ("65", "logic", "known", "base_virtual", "function", "input", "3"),
        "const": ("32", "bit", "known", "base_virtual", "function", "const_ref", "0"),
        "unknown": ("129", "logic", "x", "direct", "function", "input", "0"),
    }
    faults = (
        ("ref_becomes_input", "ref", "ref word_t formal", "input word_t formal"),
        ("omit_formal_marker", "ref", "formal = this.m", "formal = this.u"),
        ("omit_property_update", "ref", "this.payload = this.u", "this.guard = this.u"),
        ("lose_automatic_depth", "ref", "+ d;", "+ 0;"),
        ("omit_recursion", "ref", "if (d > 0)", "if (d > 3)"),
        ("lose_visit_counter", "ref", "this.leaf_visits++;", ";"),
        ("corrupt_guard", "ref", "this.leaf_visits++;", "this.leaf_visits++; this.guard = '0;"),
        ("nonvirtual_becomes_virtual", "base", "task automatic walk", "virtual task automatic walk"),
        ("virtual_becomes_nonvirtual", "virtual", "virtual function", "function"),
        ("input_becomes_ref", "virtual", "input word_t formal", "ref word_t formal"),
        ("switch_wrong_receiver", "virtual", "view = b;", "view = a;"),
        ("const_ref_becomes_input", "const", "const ref word_t formal", "input word_t formal"),
        ("logic_becomes_bit", "unknown", "typedef logic [128:0] word_t;", "typedef bit [128:0] word_t;"),
    )
    controls, mutations = [], []
    with tempfile.TemporaryDirectory() as directory:
        for label, row in parents.items():
            assert row in model.MODEL.select()
            case = model.make_case(row)
            source, expected = common.render(case, model.NAME, model.VERSION, model.CHAPTER, "spec")
            test = Path(directory) / (case.name + ".sv")
            test.with_suffix(".expected").write_text(expected)
            variants = [("control", source, None)]
            for name, parent, before, after in faults:
                if parent == label:
                    assert before in source and before != after, name
                    variants.append((name, source.replace(before, after),
                                     {"before": before, "after": after,
                                      "replacements": source.count(before)}))
            for name, design, mutation in variants:
                test.write_text(design)
                codes = []
                original = subprocess.run

                def observed(*a, **kw):
                    result = original(*a, **kw)
                    codes.append(result.returncode)
                    return result

                subprocess.run = observed
                try:
                    ok, reason = (run_icarus.run(test, icarus) if label == "unknown" else
                                  run_verilator.run(test, args.verilator, 1))
                finally:
                    subprocess.run = original
                record = {"name": name, "case": case.name, "values": model.MODEL.values(row),
                          "simulator": "icarus" if label == "unknown" else "verilator",
                          "status": "pass" if ok else "fail", "reason": reason,
                          "subprocess_returncodes": codes,
                          "source_sha256": digest(design), "expected_sha256": digest(expected)}
                if mutation is None:
                    controls.append(record)
                else:
                    record["mutation"] = mutation
                    mutations.append(record)
                print(label, name, record["status"], reason, flush=True)
    result = {
        "schema": 1, "purpose": model.MODEL.name + " fault controls",
        "versions": {"verilator": vv, "icarus": iv}, "verilator_seed": 1,
        "scope": "Verilator known input/ref/const-ref and dispatch/recursion; Icarus X input "
                 "through direct derived handles only. No qualification of X/Z virtual or ref behavior.",
        "generator_sha256": digest(Path(model.__file__).read_text()),
        "qualification_sha256": digest(Path(__file__).read_text()),
        "runner_sha256": {s: suite_results.runner_digest(s) for s in ("icarus", "verilator")},
        "controls": controls, "faults": mutations,
        "all_controls_pass": all(qualifies(r, True) for r in controls),
        "all_faults_detected": all(qualifies(r) for r in mutations),
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
