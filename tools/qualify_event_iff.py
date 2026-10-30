#!/usr/bin/env python3
"""Run positive controls and deliberate faults for the event-OR/iff model.

This is qualification evidence, not a saved pass run or requirement mapping.
Use a freshly built upstream revision and pass its commit explicitly.
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
import interaction_iff as generator


def sha(data: str) -> str:
    return hashlib.sha256(data.encode()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--commit", required=True, help="verified upstream commit (at least 12 hex digits)")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    executable = str(Path(shutil.which(args.kirimasim) or args.kirimasim).resolve())
    if not Path(executable).is_file():
        parser.error("kirimasim executable not found")
    version = suite_results.tool_version([executable, "--version"])
    if not re.fullmatch(r"[0-9a-f]{12,40}", args.commit) or args.commit[:12] not in version:
        parser.error("binary --version does not identify the verified upstream commit")
    rows = {
        "precedence": ("comma", "signals", "change", "first", "known", "blocking"),
        "wide_truth": ("or", "signals", "change", "both", "mixed", "blocking"),
        "repeat": ("or", "named", "change", "both", "known", "blocking"),
        "nba": ("or", "mixed", "posedge", "both", "mixed", "nba"),
    }
    term = "signal_a iff gate_a, signal_b"
    faults = (
        ("wrong_guard", "precedence", term, "signal_a iff gate_b, signal_b"),
        ("guard_both_terms", "precedence", term, term + " iff gate_a"),
        ("drop_right_term", "precedence", term, "signal_a iff gate_a"),
        ("guard_is_an_event", "precedence", term, term + ", gate_a"),
        ("reject_known_one_with_x", "wide_truth", "iff gate_a",
         "iff (gate_a === 33'b1)"),
        ("drop_named_repeat", "repeat",
         '    -> event_a;\n    $display("p0_left_repeat_scheduled=',
         '    ;\n    $display("p0_left_repeat_scheduled='),
        ("nba_becomes_blocking", "nba", "signal_a <=", "signal_a ="),
    )
    controls, mutations = [], []
    with tempfile.TemporaryDirectory() as tmp:
        for label, row in rows.items():
            assert row in generator.MODEL.select(), (label, "control must be a selected case")
            case = generator.make_case(row)
            source, expected = common.render(case, generator.NAME, generator.VERSION,
                                             generator.CHAPTER, "spec")
            test = Path(tmp) / (case.name + ".sv")
            test.with_suffix('.expected').write_text(expected)
            variants = [("control", source, None)]
            for name, parent, before, after in faults:
                if parent == label:
                    assert source.count(before) >= 1, name
                    variants.append((name, source.replace(before, after, 1),
                                     {"before": before, "after": after}))
            for name, design, mutation in variants:
                test.write_text(design)
                status, reason = run_kirimasim.run(test, executable)
                result = {"name": name, "case": case.name, "values": generator.MODEL.values(row),
                          "source_sha256": sha(design), "expected_sha256": sha(expected),
                          "status": status, "reason": reason}
                if mutation is None:
                    controls.append(result)
                else:
                    result['mutation'] = mutation
                    mutations.append(result)
    passed = all(r['status'] == 'pass' for r in controls)
    # A parse error, crash or timeout is not evidence of detecting a wrong result.
    detected = all(r['status'] == 'fail' and r['reason'].startswith('output differs: line ')
                   for r in mutations)
    result = {"schema": 1, "purpose": "event_or_iff positive and fault controls",
              "simulator": "kirimasim", "version": version, "commit": args.commit,
              "generator_sha256": sha((ROOT / 'generators/interaction_iff.py').read_text()),
              "qualification_sha256": sha(Path(__file__).read_text()),
              "runner_sha256": suite_results.runner_digest('kirimasim'),
              "controls": controls, "faults": mutations,
              "all_controls_pass": passed, "all_faults_detected": detected}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(f"controls: {sum(r['status'] == 'pass' for r in controls)}/{len(controls)} pass; "
          f"faults: {sum(r['status'] == 'fail' for r in mutations)}/{len(mutations)} detected")
    return 0 if passed and detected else 1


if __name__ == "__main__":
    sys.exit(main())
