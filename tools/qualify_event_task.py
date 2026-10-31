#!/usr/bin/env python3
"""Executable fault controls for scoped named-event tasks and Active/NBA payloads."""

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
import interaction_event_task as model


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
    parents = dict(zip(("basic", "interface", "package", "nba", "late", "ref_package"),
                       model.MODEL.anchors))
    faults = (
        ("lose_event_wait", "basic", "@(ev);", ";"),
        ("early_listener_becomes_late", "basic", "#1;", "#6;"),
        ("listen_to_other_instance", "basic", "observe(bank_a.go,", "observe(bank_b.go,"),
        ("listen_to_noise", "basic", "observe(bank_a.go,", "observe(bank_a.noise,"),
        ("lose_payload_capture", "basic", "captured[slot] = stamp;", "captured[slot] = 0;"),
        ("lose_wake_time", "basic", "at_tick[slot] = $time;", "at_tick[slot] = -1;"),
        ("late_listener_remembers_past_pulse", "interface", "#6;", "#1;"),
        ("double_wake_count", "interface", "hits[slot]++;", "hits[slot] += 2;"),
        ("listeners_share_counter_slot", "interface", "hits[slot]++;", "hits[0]++;"),
        ("helper_ignores_event_actual", "package", "-> ev;", "-> a;"),
        ("lose_fanout_listener", "package", "listen_a.observe(event_source::a, 1);", ";"),
        ("trigger_wrong_instance", "nba", "->> bank_b.go;", "->> bank_a.go;"),
        ("lose_queued_payload", "nba", "stamp <= token + 1;", ";"),
        ("nba_event_becomes_blocking", "nba", "->> bank_a.go;", "-> bank_a.go;"),
        ("payload_nba_becomes_blocking", "ref_package", "stamp <= token + 1;", "stamp = token + 1;"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "all six mandatory witnesses: all source scopes, input/ref, "
                                      "direct/task triggers, Active/NBA capture, early/late, 1/2/3 listeners"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
