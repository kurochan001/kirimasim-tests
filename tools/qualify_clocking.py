#!/usr/bin/env python3
"""Qualify supported clocking observations with controls and output-changing faults.

The #0 and virtual-modport paths remain in the model even when kirimasim cannot
run them. This qualification exercises supported #1step observations only.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile

import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import common
import interaction_clocking as generator


def sha(text):
    return hashlib.sha256(text.encode()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    executable = Path(shutil.which(args.kirimasim) or args.kirimasim).resolve()
    version = suite_results.tool_version([str(executable), "--version"])
    if not re.fullmatch(r"[0-9a-f]{12,40}", args.commit) or args.commit[:12] not in version:
        parser.error("binary --version must match the verified upstream commit")
    selected = generator.MODEL.select()
    rows = {"step": generator.MODEL.anchors[0], "unknown": generator.MODEL.anchors[2],
            "bit": next(r for r in selected if r[1:3] == ("bit", "x") and r[3] == "local"
                        and r[4] == "step" and int(r[0]) > 32)}
    bit_width = int(rows["bit"][0]) - 1
    faults = (
        ("sample_live_instead_of_pre_edge", "step", "seen_sample = cb.data;", "seen_sample = data;"),
        ("lose_data_update", "step", "data <= incoming;", "data <= data;"),
        ("writer_uses_wrong_edge", "step", "always @(posedge clk)", "always @(negedge clk)"),
        ("lose_wake_count", "step", "hits++;", ";"),
        ("sample_stuck_at_zero", "step", "seen_sample = cb.data;", "seen_sample = '0;"),
        ("truncate_upper_bits", "unknown", "seen_sample = bus.cb.data;",
         "seen_sample = bus.cb.data[31:0];"),
        ("logic_storage_becomes_bit", "unknown", "logic [64:0] data;", "bit [64:0] data;"),
        ("bit_storage_becomes_logic", "bit", f"bit [{bit_width}:0] data;",
         f"logic [{bit_width}:0] data;"),
        ("live_observation_uses_sample", "unknown", "seen_live = bus.data;",
         "seen_live = bus.cb.data;"),
    )
    controls, mutations = [], []
    binary_before = hashlib.sha256(executable.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as directory:
        for label, row in rows.items():
            assert row in selected
            case = generator.make_case(row)
            source, expected = common.render(case, generator.NAME, generator.VERSION,
                                             generator.CHAPTER, "spec")
            test = Path(directory) / (case.name + ".sv")
            test.with_suffix(".expected").write_text(expected)
            variants = [("control", source, None)]
            for name, parent, before, after in faults:
                if parent == label:
                    assert source.count(before) == 1, name
                    variants.append((name, source.replace(before, after, 1),
                                     {"before": before, "after": after}))
            for name, design, mutation in variants:
                test.write_text(design)
                status, reason = run_kirimasim.run(test, str(executable))
                record = {"name": name, "case": case.name, "values": generator.MODEL.values(row),
                          "source_sha256": sha(design), "expected_sha256": sha(expected),
                          "status": status, "reason": reason}
                if mutation is None:
                    controls.append(record)
                else:
                    record["mutation"] = mutation
                    mutations.append(record)
    stable = binary_before == hashlib.sha256(executable.read_bytes()).hexdigest()
    passed = stable and all(r["status"] == "pass" for r in controls)
    detected = stable and all(r["status"] == "fail" and r["reason"].startswith("output differs: line ")
                              for r in mutations)
    result = {"schema": 1, "purpose": "clocking_input_sampling supported-path fault controls",
              "scope": "#1step local/interface paths only; does not qualify unsupported #0 or virtual paths",
              "simulator": "kirimasim", "version": version, "commit": args.commit,
              "binary_sha256": binary_before, "binary_changed": not stable,
              "generator_sha256": sha((ROOT / "generators/interaction_clocking.py").read_text()),
              "qualification_sha256": sha(Path(__file__).read_text()),
              "runner_sha256": suite_results.runner_digest("kirimasim"),
              "controls": controls, "faults": mutations,
              "all_controls_pass": passed, "all_faults_detected": detected}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    print(f"controls {sum(r['status'] == 'pass' for r in controls)}/{len(controls)} pass; "
          f"faults {sum(r['status'] == 'fail' for r in mutations)}/{len(mutations)} output differences")
    return 0 if passed and detected else 1


if __name__ == "__main__":
    sys.exit(main())
