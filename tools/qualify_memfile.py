#!/usr/bin/env python3
"""Fault controls for typed memory files and an independent canonical input path."""

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
import interaction_memfile as model


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
    parents = dict(zip(("plain", "enum_wide", "logic", "enum_bit", "enum_known", "hex"),
                       model.MODEL.anchors))
    dump = '    $writememb("written.mem", source, 2, 6);'
    words = model.phases(parents["plain"])[0][2]
    poisoned = "\n".join(f"    source[{i}] = source_t'({model.literal(model.poison(bits))});"
                         for i, bits in enumerate(words, 2))
    body = model.make_case(parents["plain"]).body
    mirrored = body.replace('source, 2, 6);', 'source, 6, 2);').replace(
        'loaded, 11, 15);', 'loaded, 15, 11);').replace('canonical, 11, 15);', 'canonical, 15, 11);')
    with_address = dump + '\n    fd = $fopen("written.mem", "a");\n' + \
        '    $fdisplay(fd, "@b");\n    $fclose(fd);'
    faults = (
        ("paired_write_read_reversal", "plain", body, mirrored),
        ("read_ignores_reverse_direction", "logic", ", 15, 11);", ", 11, 15);"),
        ("bit_enum_becomes_logic", "enum_bit", "enum bit [32:0]", "enum logic [32:0]"),
        ("bit_target_becomes_logic", "enum_wide", "bit [128:0] loaded", "logic [128:0] loaded"),
        ("logic_source_becomes_bit", "logic", "typedef logic [64:0] source_t;", "typedef bit [64:0] source_t;"),
        ("enum_numerical_value_changes", "enum_known", "source_t'(raw[i])", "source_t'(raw[i] + 1)"),
        ("write_wrong_source_span", "enum_known", 'source, 3, 5);', 'source, 2, 4);'),
        ("write_into_target_guard", "plain", 'loaded, 11, 15);', 'loaded, 10, 14);'),
        ("lose_written_file_load", "plain", '$readmemb("written.mem", loaded, 11, 15);', ";"),
        ("lose_canonical_file_load", "plain", '$readmemb("canonical.mem", canonical, 11, 15);', ";"),
        ("stale_file_after_first_dump", "plain", '$writememb("written.mem", source, 2, 6);',
         'if (phase == 0) $writememb("written.mem", source, 2, 6);'),
        ("source_never_receives_input", "plain", "source_t'(raw[i])", "source_t'('0)"),
        ("truncate_enum_base_width", "enum_wide", "enum logic [128:0]", "enum logic [63:0]"),
        ("wrong_written_file_radix", "hex", '$writememh("written.mem"', '$writememb("written.mem"'),
        ("written_file_contains_address", "plain", dump, with_address),
        ("comment_addresses_are_counted", "plain", "while (c != -1) begin",
         "while (c != -1) begin\n      if (c == 8'd64) count++;"),
        ("dump_observes_mutated_source", "plain", dump + "\n" + poisoned, poisoned + "\n" + dump),
    )
    result = helper.qualify(model, parents, faults, lambda test: run_kirimasim.run(test, str(binary)),
                            {"simulator": "kirimasim", "version": version, "commit": args.commit,
                             "runner_sha256": suite_results.runner_digest("kirimasim"),
                             "binary_sha256": before,
                             "scope": "all six mandatory witnesses: enum/plain and source/target states, "
                                      "both radices, guarded bounds/directions, independent input and overwrite"})
    paired = next(r for r in result["faults"] if r["name"] == "paired_write_read_reversal")
    match = re.search(r"is '([^']+)', expected '([^']+)'", paired["reason"])
    if match:
        actual, expected = [dict(re.findall(r"(written|canonical)=([01xz]+)", line)) for line in match.groups()]
        result["paired_reversal_first_difference_is_canonical_only"] = (
            actual.get("written") == expected.get("written")
            and actual.get("canonical") != expected.get("canonical"))
    else:
        result["paired_reversal_first_difference_is_canonical_only"] = False
    result["qualification_helper_sha256"] = result.pop("qualification_sha256")
    result["qualification_sha256"] = helper.sha(Path(__file__).read_text())
    result["binary_unchanged"] = before == hashlib.sha256(binary.read_bytes()).hexdigest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    passed = (result["binary_unchanged"] and result["all_controls_pass"] and result["all_faults_detected"]
              and result["paired_reversal_first_difference_is_canonical_only"])
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
