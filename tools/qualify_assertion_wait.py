#!/usr/bin/env python3
"""Fault controls for container waits and stable-timing assertion observations.

Wait controls use the verified latest kirimasim. Assertion controls use fixed
Verilator on known inputs updated before/after the edge; they do not qualify
edge-coincident Reactive values or four-state assertion behavior.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_kirimasim
import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import common
import interaction_assertion as assertion
import interaction_wait as waiting


def sha(text):
    return hashlib.sha256(text.encode()).hexdigest()


def qualify(generator, parents, faults, runner, metadata):
    controls, mutations = [], []
    selected = generator.MODEL.select()
    with tempfile.TemporaryDirectory() as directory:
        for label, row in parents.items():
            assert row in selected
            case = generator.make_case(row)
            source, expected = common.render(case, generator.NAME, generator.VERSION,
                                             generator.CHAPTER, "spec")
            test = Path(directory) / (case.name + ".sv")
            test.with_suffix(".expected").write_text(expected)
            variants = [("control", source, None)]
            for name, parent, before, after in faults:
                if parent == label:
                    assert before in source, name
                    variants.append((name, source.replace(before, after),
                                     {"before": before, "after": after,
                                      "replacements": source.count(before)}))
            for name, design, mutation in variants:
                test.write_text(design)
                # The runners compare output before checking the exit status.
                # Keep a truncated trace from a crash out of fault detections.
                codes = []
                original_run = subprocess.run

                def observed_run(*args, **kwargs):
                    completed = original_run(*args, **kwargs)
                    codes.append(completed.returncode)
                    return completed

                subprocess.run = observed_run
                try:
                    status, reason = runner(test)
                finally:
                    subprocess.run = original_run
                record = {"name": name, "case": case.name, "values": generator.MODEL.values(row),
                          "source_sha256": sha(design), "expected_sha256": sha(expected),
                          "status": status, "reason": reason, "subprocess_returncodes": codes}
                if mutation is None:
                    controls.append(record)
                else:
                    record["mutation"] = mutation
                    mutations.append(record)
    result = {"schema": 1, "purpose": generator.MODEL.name + " fault controls", **metadata,
              "generator_sha256": sha(Path(generator.__file__).read_text()),
              "qualification_sha256": sha(Path(__file__).read_text()),
              "controls": controls, "faults": mutations,
              "all_controls_pass": all(r["status"] == "pass" and r["subprocess_returncodes"]
                                       and all(c == 0 for c in r["subprocess_returncodes"]) for r in controls),
              "all_faults_detected": all(r["status"] == "fail"
                  and r["reason"].startswith("output differs: line ") and r["subprocess_returncodes"]
                  and all(c == 0 for c in r["subprocess_returncodes"]) for r in mutations)}
    print(generator.MODEL.name, f"controls {sum(r['status']=='pass' for r in controls)}/{len(controls)}; "
          f"output differences {sum(r['status']=='fail' for r in mutations)}/{len(mutations)}", flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    binary = Path(shutil.which(args.kirimasim) or args.kirimasim).resolve()
    native = str(Path(shutil.which(args.verilator) or args.verilator).resolve())
    version = suite_results.tool_version([str(binary), "--version"])
    fixed_version = suite_results.tool_version([native, "--version"])
    if not re.fullmatch(r"[0-9a-f]{12,40}", args.commit) or args.commit[:12] not in version:
        parser.error("kirimasim version must match the verified latest upstream commit")
    if not fixed_version.startswith("Verilator 5.052 "):
        parser.error("assertion controls require fixed Verilator 5.052")
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    queue = waiting.MODEL.anchors[0]
    unknown = waiting.MODEL.anchors[1]
    wait_faults = (
        ("wait_never_matches", "queue", "wait (cells.size() == 2);", "wait (1'b0);"),
        ("wait_always_matches", "queue", "wait (cells.size() == 2);", "wait (1'b1);"),
        ("wait_on_unrelated_container", "queue", "wait (cells.size() == 2);", "wait (noise.size() == 2);"),
        ("update_wrong_container", "queue", "cells.push_front(marker);", "noise.push_front(marker);"),
        ("lose_capture", "queue", "captured = cells;", ";"),
        ("lose_wake_count", "queue", "wakes++;", ";"),
        ("case_equality_becomes_logical", "unknown", "cells[0] === marker", "cells[0] == marker"),
        ("logic_storage_becomes_bit", "unknown", "typedef logic [128:0] word_t;", "typedef bit [128:0] word_t;"),
        ("reuse_wrong_initializer", "unknown", "cells = new[2](prepared);", "cells = new[2](cells);"),
    )
    wr = qualify(waiting, {"queue": queue, "unknown": unknown}, wait_faults,
                 lambda test: run_kirimasim.run(test, str(binary)),
                 {"simulator": "kirimasim", "version": version, "commit": args.commit,
                  "runner_sha256": suite_results.runner_digest("kirimasim"), "binary_sha256": before,
                  "scope": "typed queue growth and dynamic-array element-sensitive replacement"})
    wr["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    before_row, after_row = assertion.MODEL.anchors[-2:]
    assert_faults = (
        ("assert_always_passes", "before", "assert property (@(negedge clk) (|data))",
         "assert property (@(negedge clk) 1'b1)"),
        ("assert_always_fails", "before", "assert property (@(negedge clk) (|data))",
         "assert property (@(negedge clk) 1'b0)"),
        ("lose_pass_count", "before", "passed++;", ";"),
        ("lose_fail_count", "before", "failed++;", ";"),
        ("sample_stuck_zero", "before", "seen_sample = $sampled(data);", "seen_sample = '0;"),
        ("predicate_stuck_zero", "before", "seen_predicate = $sampled((|data));", "seen_predicate = 1'b0;"),
        ("live_uses_future_input", "after", "seen_live = data;", "seen_live = incoming;"),
        ("lose_late_update", "after", "data <= incoming;", ";"),
    )

    def native_run(test):
        matched, reason = run_verilator.run(test, native, 1)
        return ("pass" if matched else "fail"), reason

    ar = qualify(assertion, {"before": before_row, "after": after_row}, assert_faults, native_run,
                 {"simulator": "verilator", "version": fixed_version, "seed": 1,
                  "runner_sha256": suite_results.runner_digest("verilator"),
                  "scope": "known inputs, before/after updates only; no qualification of edge updates or X/Z"})
    for name, result in [("20261031-wait.json", wr), ("20261031-assertion.json", ar)]:
        (args.output_dir / name).write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if wr["binary_unchanged"] and all(
        r["all_controls_pass"] and r["all_faults_detected"] for r in (wr, ar)) else 1


if __name__ == "__main__":
    sys.exit(main())
