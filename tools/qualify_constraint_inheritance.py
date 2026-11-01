#!/usr/bin/env python3
"""Independently solve named constraint blocks and inject observable SV faults."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_constraint as generator


def solutions(row, impossible):
    # Explicit stimulus constants, independent of solved_values(). A named
    # block replaces that entire inherited block; a new name adds a block.
    base, leaf = {'4': (5, 7), '8': (65, 67), '33': (2147483649, 2147483651)}[row[5]]
    blocks = {'c_keep': (lambda a, b: b == a + 3,),
              'c_value': (lambda a, b: a == base,)}
    value = leaf if row[1] == 'replace' else base
    rule = (lambda a, b: b == value + 3 + int(impossible),)
    if row[1] == 'replace':
        blocks['c_value'] = (lambda a, b: a == leaf, *rule)
    else:
        blocks['c_added'] = rule
    # The active a-equality limits a to one of the two literal constants;
    # c_keep then determines b. Enumerating neighboring values also checks
    # that an unsatisfiable forced b cannot accidentally become a solution.
    candidates = range(base - 1, leaf + 2)
    return [(a, b) for a in candidates for b in range(base + 1, leaf + 6)
            if all(check(a, b) for block in blocks.values() for check in block)]


def independently_calculated(row):
    initial = {'4': (12, 13), '8': (252, 253), '33': (8589934588, 8589934589)}
    state = initial[row[5]]
    sequence = {'sat_fail_sat': (False, True, False), 'fail_sat_fail': (True, False, True)}[row[4]]
    lines = []
    for phase, fail in enumerate(sequence):
        found = solutions(row, fail)
        assert len(found) == int(not fail)
        if found:
            state = found[0]
        guard, = solutions(row, False)
        lines += [f'phase={phase} fail={int(fail)} ok={len(found)} a={state[0]} b={state[1]}',
                  f'guard={phase} fail=0 ok=1 a={guard[0]} b={guard[1]}']
    return '\n'.join(lines) + '\n'


def source_for(row):
    path = ROOT / 'tests/gen/ch18' / (generator.case_name(row) + '.sv')
    text = path.read_text()
    field = suite_results.header(path)['expected_stdout']
    return text.replace(':expected_stdout: ' + field,
                        ':expected_stdout: @' + str((path.parent / field[1:]).resolve()))


def check_faults(directory, verilator):
    replace = source_for(generator.MODEL.anchors[0])
    add = source_for(generator.MODEL.anchors[1])
    removed, count = re.subn(r'b == \(impossible \?[^;]*\);', '1;', add)
    assert count == 1
    faults = {
        'lost_override': replace.replace('extern constraint c_value;', 'extern constraint c_added;')
                               .replace('constraint constraint_leaf::c_value {',
                                        'constraint constraint_leaf::c_added {'),
        'dropped_added_constraint': removed,
        'failure_clobbers_state': replace.replace('ok = target_base.randomize();',
                                        "ok = target_base.randomize(); if (!ok) target.a = '0;"),
        'aliased_guard_object': replace.replace('target = new; guard_object = new;',
                                               'target = new; guard_object = target;'),
        'base_constraints_instead_of_leaf': replace.replace('constraint_leaf target, guard_object;',
                                        'constraint_middle target; constraint_leaf guard_object;'),
    }
    outcomes = {}
    for name, text in {'replace_control': replace, 'add_control': add, **faults}.items():
        assert name.endswith('_control') or text not in (replace, add)
        test = directory / (name + '.sv')
        test.write_text(text)
        ok, reason = run_verilator.run(test, verilator, 1)
        if name.endswith('_control'):
            assert ok, (name, reason)
        else:
            assert not ok and reason.startswith('output differs'), (name, ok, reason)
        outcomes[name] = 'pass' if ok else 'detected'
    return outcomes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    for row in generator.MODEL.rows():
        assert independently_calculated(row) == generator.reference(row), row
    with tempfile.TemporaryDirectory() as folder:
        faults = check_faults(Path(folder), args.verilator)
    tests = [ROOT / 'tests/gen/ch18' / (generator.case_name(row) + '.sv')
             for row in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(generator.MODEL.rows()), 'fault_injection': faults,
              'simulator': suite_results.tool_version([args.verilator, '--version']),
              'sources_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                                 for name in ('generators/interaction_constraint.py',
                                              'tools/qualify_constraint_inheritance.py')},
              'inputs_sha256': {test.relative_to(ROOT).as_posix(): suite_results.input_digest(test)
                                for test in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(generator.MODEL.rows())} independent rows; two controls; five output-difference faults.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
