#!/usr/bin/env python3
"""Normal-exit fault controls for program descendants and independent lifetimes."""

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
import interaction_program as model


def fixed_diagnostics(bindir):
    """Keep complete black-box diagnostics; no reference-simulator source reads."""
    def redact(text):
        text = text.replace(str(ROOT) + "/", "")
        return re.sub(r"/(?:private/)?(?:var/folders|tmp)/[^\s'\"]+", "<temporary>", text)

    records = []
    for row in model.MODEL.anchors:
        test = ROOT / "tests/gen/ch24" / (model.case_name(row) + ".sv")
        calls = []
        original = subprocess.run

        def observed(*args, **kwargs):
            result = original(*args, **kwargs)
            calls.append({"program": Path(args[0][0]).name, "returncode": result.returncode,
                          "stdout": redact(result.stdout or ""), "stderr": redact(result.stderr or "")})
            return result

        subprocess.run = observed
        try:
            matched, reason = run_icarus.run(test, bindir.resolve())
        finally:
            subprocess.run = original
        records.append({"test": test.relative_to(ROOT).as_posix(),
                        "inputs_sha256": suite_results.input_digest(test),
                        "matched": matched, "reason": redact(reason), "native_runs": calls})
    return {"version": suite_results.tool_version([str(bindir.resolve() / "iverilog"), "-V"]),
            "runner_sha256": suite_results.runner_digest("icarus"), "temporary_paths_redacted": True,
            "scope": "Four mandatory controls only; fixed-engine mismatches, outside kirimasim fault controls.",
            "records": records}


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
    parents = dict(zip(("natural_one", "natural_two", "exit", "task"), model.MODEL.anchors))
    faults = (
        ("natural_cancels_before_last_initial", "natural_two", "#6 secondary_done++", "#3 secondary_done++"),
        ("natural_keeps_children_alive_too_long", "natural_two", "#6 secondary_done++", "#10 secondary_done++"),
        ("direct_exit_returns", "exit", "$exit;", ";"),
        ("task_exit_returns", "task", "$exit;", ";"),
        ("lose_worker_entry", "natural_one", "entered++;", ";"),
        ("lose_partial_progress", "natural_two", "#1 prepared++;", "#1;"),
        ("lose_pretermination_checkpoint", "natural_two", "#5 checkpoint++;", "#7 checkpoint++;"),
        ("delay_worker_survives_before_shutdown", "natural_one", "#7;", "#2;"),
        ("event_worker_survives_before_shutdown", "natural_two", "#8 released = 1;", "#3 released = 1;"),
        ("level_worker_survives_before_shutdown", "exit", "#8 released = 1;", "#3 released = 1;"),
        ("event_never_releases_live_counterpart", "natural_two", "-> release_event;", ";"),
        ("lose_intermediate_parent_completion", "natural_two", "#2 parent_done++;", "#7 parent_done++;"),
        ("join_none_blocks_until_all_children_end", "natural_one", "join_none", "join"),
        ("lose_join_any_resume_time", "task", "resumed = $time;", "resumed = 0;"),
        ("first_keeper_ends_early", "natural_one", "#12 keeper_a = 1;", "#10 keeper_a = 1;"),
        ("second_keeper_ends_early", "exit", "#15 keeper_b = 1;", "#11 keeper_b = 1;"),
        ("second_keeper_ends_late", "exit", "#15 keeper_b = 1;", "#17 keeper_b = 1;"),
        ("lose_primary_completion", "natural_one", "primary_done = 1;", ";"),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "four mandatory controls: natural/all-initial completion, direct/task exit, "
                                      "delay/event/level liveness, grandchildren, join modes and independent keepers"})
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    if args.icarus_bin:
        result["fixed_icarus_diagnostics"] = fixed_diagnostics(args.icarus_bin)
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return 0 if result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"] else 1


if __name__ == "__main__":
    sys.exit(main())
