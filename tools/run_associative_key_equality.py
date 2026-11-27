#!/usr/bin/env python3
"""Check associative key controls and derive an event-key oracle from measured equality."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import run_vpi_extended_attributes as helpers
import suite_results


CHECKER = "tools/run_associative_key_equality.py"
CASES = {
    feature: suite_results.ROOT / "tests/ch7" / f"{filename}.sv"
    for feature, filename in {
        "event": "test_associative_event_key_identity",
        "dynamic_array": "test_associative_dynamic_array_key_equality",
        "queue_and_string": "test_associative_key_uses_queue_and_string_values_structurally",
        "real_member": "test_illegal_associative_index_contains_nested_real",
    }.items()
}


def checker_digest() -> str:
    return hashlib.sha256((helpers.digest(suite_results.ROOT / CHECKER) + helpers.checker_digest()).encode()).hexdigest()


def event_oracle(line: str) -> list[str]:
    match = re.fullmatch(r"equality=([01]{3})/([01]{3})/([01]{3})", line)
    if not match:
        raise ValueError(f"expected a 3-by-3 event equality matrix, got {line!r}")
    matrix = [[bit == "1" for bit in row] for row in match.groups()]
    if any(not matrix[i][i] for i in range(3)) or any(
        matrix[i][j] and matrix[i] != matrix[j] for i in range(3) for j in range(3)
    ):
        raise ValueError("event comparisons do not give an equivalence relation")

    original, alias_handle, other = range(3)
    entries: dict[int, int] = {}

    def representative(key: int) -> int:
        return next((existing for existing in entries if matrix[key][existing]), key)

    entries[representative(original)] = 13
    entries[representative(other)] = 59
    first = f"alias-value={entries[representative(alias_handle)]} other-value={entries[representative(other)]}"
    first += f" entries={len(entries)}"
    entries[representative(alias_handle)] += 4
    second = (f"updated-original={entries[representative(original)]} "
              f"unchanged-other={entries[representative(other)]} entries={len(entries)}")
    return [line, first, second]


def observe(tools: dict, profile: dict, work: Path) -> dict:
    environment = {**os.environ, **profile["environment"]}

    def ghost(source: Path, *flags: str) -> dict:
        result = helpers.execute([tools["ghost"], *profile["arguments"], *flags,
                                  "-top", source.stem, source], work, env=environment)
        return {"exit": result.returncode,
                "completed": any(line.startswith(profile["trailer"]) for line in result.stdout.splitlines()),
                "output": run_ghost.normalize(result.stdout, profile).splitlines()}

    slang = {}
    for name, source in CASES.items():
        compiled = helpers.execute([tools["slang"], "--std=1800-2023", "--top", source.stem, source], work)
        slang[name] = {"exit": compiled.returncode, "rejected_floating_key":
                       "index type cannot be or contain floating point types" in compiled.stderr}

    # Preserve the rejected type and replace only its use as an associative key.
    real = CASES["real_member"]
    equality_source = work / f"{real.stem}.sv"
    source = real.read_text()
    key = "  int data[invalid_key]; // illegal\n  initial $display(\"unexpected associative index\");"
    if source.count(key) != 1:
        raise ValueError("the real-containing key control changed")
    equality_source.write_text(source.replace(key, """  invalid_key first, second;
  initial begin
    first.label_text = "gain";
    first.part.serial = 8;
    first.part.gain = 1.25;
    second = first;
    $display("real-aggregate equal=%b", first == second);
    second.part.gain = 2.5;
    $display("real-aggregate distinct=%b", first != second);
    $finish(0);
  end"""))
    compiled = helpers.execute([tools["slang"], "--std=1800-2023", "--top", real.stem, equality_source], work)
    slang["real_equality_control"] = {"exit": compiled.returncode}
    trials = {name: ghost(CASES[name]) for name in ("event", "dynamic_array", "queue_and_string")}
    trials["real_equality_control"] = ghost(equality_source)
    comparison = ghost(CASES["event"], "+define+COMPARE_ONLY")
    trials["event_equality_only"] = comparison
    oracle = event_oracle(comparison["output"][0]) if len(comparison["output"]) == 1 else []
    expected = suite_results.expected_output(CASES["event"]).splitlines()
    checks = {
        "event_and_dynamically_sized_keys_elaborate": all(
            slang[name]["exit"] == 0 for name in ("event", "dynamic_array", "queue_and_string")),
        "ghost_dynamically_sized_keys_match": all(trials[name] == {
            "exit": 0, "completed": True, "output": suite_results.expected_output(CASES[name]).splitlines(),
        } for name in ("dynamic_array", "queue_and_string")),
        "event_reference_uses_measured_equality": (comparison["exit"] == 0 and comparison["completed"]
                                                   and oracle == expected),
        "floating_member_is_an_exception_to_key_eligibility": (
            slang["real_member"]["exit"] > 0 and slang["real_member"]["rejected_floating_key"]
            and slang["real_equality_control"]["exit"] == 0 and trials["real_equality_control"] == {
                "exit": 0, "completed": True,
                "output": ["real-aggregate equal=1", "real-aggregate distinct=1"],
            }),
    }
    return {"checks": checks, "slang": slang, "ghost": trials, "event_reference": oracle,
            "native_event_matches": trials["event"] == {"exit": 0, "completed": True, "output": expected},
            "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    paths = {name: shutil.which(path) for name, path in {"ghost": args.ghost, "slang": args.slang}.items()}
    if not all(paths.values()):
        parser.error("Ghost and Slang are required")
    tools = {name: Path(path).absolute() for name, path in paths.items()}

    def provenance():
        return {"checker_sha256": checker_digest(),
                "inputs_sha256": {name: suite_results.input_digest(test) for name, test in CASES.items()},
                "runtime_profile_sha256": helpers.digest(args.profile),
                "artifact_sha256": {name: helpers.digest(path) for name, path in tools.items()}}

    try:
        before = provenance()
        profile = json.loads(args.profile.read_bytes())
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, profile, Path(directory))
        if before != provenance():
            raise ValueError("qualification inputs changed during the run")
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"associative key qualification stopped: {error}\n")
    args.json.write_text(json.dumps({
        **before, "slang_version": suite_results.tool_version([str(tools["slang"]), "--version"]), **result,
    }, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    print(f"Native event-key trace: {'match' if result['native_event_matches'] else 'difference'}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
