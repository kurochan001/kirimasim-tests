#!/usr/bin/env python3
"""Qualify queue-reference observations using selected controls and deliberate faults."""

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
sys.path.insert(0, str(ROOT / 'generators'))
import common
import interaction_queue_ref as generator


def sha(text):
    return hashlib.sha256(text.encode()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--commit', required=True, help='verified upstream commit, at least 12 hex digits')
    parser.add_argument('--json', type=Path, required=True)
    args = parser.parse_args()
    executable = Path(shutil.which(args.kirimasim) or args.kirimasim).resolve()
    if not executable.is_file():
        parser.error('kirimasim executable not found')
    version = suite_results.tool_version([str(executable), '--version'])
    if not re.fullmatch(r'[0-9a-f]{12,40}', args.commit) or args.commit[:12] not in version:
        parser.error('binary --version does not identify the verified upstream commit')
    selected = generator.MODEL.select()
    rows = {
        'moved': ('1', 'bit', 'unbounded', 'middle', 'push_front', 'known'),
        'replaced': next(r for r in selected if r[4] == 'copy'),
        'bounded': ('129', 'logic', 'three', 'last', 'push_front', 'z'),
        'removed': ('33', 'logic', 'three', 'last', 'delete_held', 'known'),
    }
    faults = (
        ('capture_wrong_element', 'moved', 'hold(q[1]', 'hold(q[0]'),
        ('ref_becomes_input', 'moved', 'hold(ref word_t r', 'hold(input word_t r'),
        ('method_becomes_assignment', 'moved', 'q.push_front(added);', 'q = {added, q};'),
        ('lose_first_write', 'moved', 'r = first_value;', ';'),
        ('keep_reference_on_whole_assignment', 'replaced', 'q = saved;', 'q[0] = saved[0];'),
        ('write_removed_reference_into_live_queue', 'removed',
         'r = first_value;', 'r = first_value; q[0] = first_value;'),
        ('omit_capacity_bound', 'bounded', 'q[$:2]', 'q[$]'),
        ('convert_logic_input_to_bit', 'bounded',
         'input word_t first_value', 'input bit [128:0] first_value'),
    )
    controls, mutations = [], []
    with tempfile.TemporaryDirectory() as tmp:
        for label, row in rows.items():
            assert row in selected, label
            case = generator.make_case(row)
            source, expected = common.render(case, generator.NAME, generator.VERSION,
                                             generator.CHAPTER, 'spec')
            test = Path(tmp) / (case.name + '.sv')
            test.with_suffix('.expected').write_text(expected)
            variants = [('control', source, None)]
            for name, parent, before, after in faults:
                if parent == label:
                    assert before in source, name
                    variants.append((name, source.replace(before, after, 1),
                                     {'before': before, 'after': after}))
            for name, design, mutation in variants:
                test.write_text(design)
                status, reason = run_kirimasim.run(test, str(executable))
                record = {'name': name, 'case': case.name, 'values': generator.MODEL.values(row),
                          'source_sha256': sha(design), 'expected_sha256': sha(expected),
                          'status': status, 'reason': reason}
                if mutation is None:
                    controls.append(record)
                else:
                    record['mutation'] = mutation
                    mutations.append(record)
    passed = all(r['status'] == 'pass' for r in controls)
    # Compilation errors, unsupported diagnostics and crashes are not detections.
    detected = all(r['status'] == 'fail' and r['reason'].startswith('output differs: line ')
                   for r in mutations)
    result = {'schema': 1, 'purpose': 'queue_element_reference positive and fault controls',
              'simulator': 'kirimasim', 'version': version, 'commit': args.commit,
              'binary_sha256': hashlib.sha256(executable.read_bytes()).hexdigest(),
              'generator_sha256': sha((ROOT / 'generators/interaction_queue_ref.py').read_text()),
              'qualification_sha256': sha(Path(__file__).read_text()),
              'runner_sha256': suite_results.runner_digest('kirimasim'),
              'controls': controls, 'faults': mutations,
              'all_controls_pass': passed, 'all_faults_detected': detected}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(f"controls: {sum(r['status'] == 'pass' for r in controls)}/{len(controls)} pass; "
          f"faults: {sum(r['status'] == 'fail' for r in mutations)}/{len(mutations)} detected")
    return 0 if passed and detected else 1


if __name__ == '__main__':
    sys.exit(main())
