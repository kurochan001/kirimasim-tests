#!/usr/bin/env python3
"""Check reduction constraints with bit-serial arithmetic and auxiliary SV faults."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_randreduce as generator


def folded(values, width, signed, method):
    mask = (1 << width)-1

    def add(left, right):
        while right:
            left, right = (left ^ right) & mask, ((left & right) << 1) & mask
        return left

    def multiply(left, right):
        result = 0
        for bit in range(width):
            if right & (1 << bit):
                result = add(result, (left << bit) & mask)
        return result

    result = 0 if method == 'sum' else 1
    for value in values:
        result = (add if method == 'sum' else multiply)(result, value & mask)
    if signed and result & (1 << (width-1)):
        result -= mask+1
    return result


def independent(row):
    width, sign, kind, method, projection, length, sequence = row
    limits = {('4', 'unsigned'): 15, ('8', 'unsigned'): 255,
              ('33', 'unsigned'): 8589934591, ('4', 'signed'): -8,
              ('8', 'signed'): -128, ('33', 'signed'): -4294967296}
    desired = [limits[(width, sign)]]+([-3] if sign == 'signed' else [3])*(int(length)-1)
    w = int(width)
    natural = folded(desired, w, sign == 'signed', method)
    wide = folded(desired, 64, True, method)
    assert natural != wide
    target = natural if projection == 'element' else wide
    # Size plus per-element equalities determine exactly this candidate.
    # Contradicting only its reduction leaves no alternative assignment.
    state = [2]*(int(length)+(kind == 'dynamic'))
    lines = []
    attempts = {'sat_fail_sat': [0, 1, 0], 'fail_sat_fail': [1, 0, 1]}[sequence]
    for phase, fail in enumerate(attempts):
        solution_exists = (natural if projection == 'element' else wide) == target+fail
        assert solution_exists == (fail == 0)
        if solution_exists:
            state = desired.copy()
        for name, impossible, ok, values in [('target', fail, solution_exists, state),
                                             ('guard', 0, True, desired)]:
            lines += [f'{name} phase={phase} impossible={impossible} ok={int(ok)} size={len(values)}',
                      'values='+','.join(format(value % (1 << w), f'0{w}b') for value in values),
                      f'natural={folded(values, w, sign == "signed", method)} '
                      f'wide={folded(values, 64, True, method)} natural_bits={w} wide_bits=64']
    return '\n'.join(lines)+'\n'


def auxiliary_source(row):
    path = ROOT/'tests/gen/ch18'/(generator.case_name(row)+'.sv')
    source = path.read_text()
    field = suite_results.header(path)['expected_stdout']
    source = source.replace(':expected_stdout: '+field,
                            ':expected_stdout: @'+str((path.parent/field[1:]).resolve()))
    source = source.replace('  reduction_box target, guard_object;',
                            f'  typedef bit {row[1]} [{int(row[0])-1}:0] elem_t;\n'
                            '  reduction_box target, guard_object;')
    source = source.replace(f'    natural = obj.data.{row[3]}();',
                            f"    natural = elem_t'(obj.data.{row[3]}());")
    return source


def check_faults(directory, verilator):
    rows = {'unsigned_element_control': generator.MODEL.anchors[0],
            'signed_element_control': generator.MODEL.anchors[2],
            'signed_wide_control': ('4', 'signed', 'fixed', 'product', 'wide', '2', 'fail_sat_fail'),
            'wide_word_control': ('33', 'unsigned', 'fixed', 'sum', 'element', '2', 'sat_fail_sat')}
    assert all(row in generator.MODEL.select() and row[2] == 'fixed' for row in rows.values())
    controls = {name: auxiliary_source(row) for name, row in rows.items()}
    element = controls['unsigned_element_control']
    signed = controls['signed_element_control']
    wide = controls['signed_wide_control']
    removed, count = re.subn(r'  constraint c_reduce \{.*?\n  \}', '', element, flags=re.S)
    assert count == 1
    variants = {
        'drop_reduction_constraint': removed,
        'widen_element_reduction': element.replace('    data.sum() ==',
                                                  "    data.sum() with (longint'(item)) =="),
        'cast_after_reduction': wide.replace("    data.product() with (longint'(item)) ==",
                                             "    longint'(4'(data.product())) =="),
        'zero_extend_signed_items': wide.replace("    data.product() with (longint'(item)) ==",
                                                 "    data.product() with (longint'($unsigned(item))) =="),
        'failure_clobbers_value': signed.replace('    ok = target.randomize();',
                                                 "    ok = target.randomize(); if (!ok) target.data[0] = '0;"),
        'aliased_guard_object': element.replace('target = new; guard_object = new;',
                                               'target = new; guard_object = target;'),
        'wrong_reduction_method': element.replace('    data.sum() ==', '    data.product() =='),
    }
    outcomes, executions = {}, {}
    for name, source in {**controls, **variants}.items():
        assert name.endswith('_control') or source not in controls.values()
        path = directory/(name+'.sv')
        path.write_text(source)
        runtime = []
        actual_run = subprocess.run

        def capture(*args, **kwargs):
            result = actual_run(*args, **kwargs)
            command = args[0]
            if isinstance(command, (tuple, list)) and Path(command[0]).name == 'Vt':
                runtime.append(result)
            return result

        with patch.object(run_verilator.subprocess, 'run', side_effect=capture):
            ok, reason = run_verilator.run(path, verilator, 1)
        assert len(runtime) == 1 and runtime[0].returncode == 0, (name, runtime)
        observed = runtime[0]
        diagnostics = (observed.stdout+'\n'+observed.stderr).splitlines()
        unexpected = [line for line in diagnostics if line.startswith('%Warning')
                      and not line.startswith('%Warning-UNSATCONSTR:')]
        assert not unexpected and not re.search(r'unsupported', '\n'.join(diagnostics), re.I), (
            name, observed.stdout, observed.stderr)
        if name.endswith('_control'):
            assert ok, (name, reason)
        else:
            assert not ok and reason.startswith('output differs'), (name, ok, reason)
        outcomes[name] = 'pass' if ok else 'detected'
        raw = ''.join(line+'\n' for line in observed.stdout.splitlines()
                      if not run_verilator.BANNER.match(line))
        normalized = actual_run([sys.executable, str(run_verilator.NORMALIZE)], input=raw,
                                capture_output=True, text=True, check=True).stdout
        executions[name] = {'returncode': observed.returncode, 'stderr': observed.stderr,
                            'stdout': normalized, 'reason': reason,
                            'constraint_diagnostics': [line for line in diagnostics
                                                       if line.startswith('%Warning-UNSATCONSTR:')]}
    return (outcomes,
            {name: 'tests/gen/ch18/'+generator.case_name(row)+'.sv' for name, row in rows.items()},
            executions)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    for row in generator.MODEL.rows():
        assert independent(row) == generator.reference(row), row
    with tempfile.TemporaryDirectory() as folder:
        outcomes, controls, executions = check_faults(Path(folder), args.verilator)
    sources = ('generators/interaction_randreduce.py', 'tools/qualify_randreduce.py')
    tests = [ROOT/'tests/gen/ch18'/(generator.case_name(row)+'.sv') for row in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(generator.MODEL.rows()), 'fault_injection': outcomes,
              'execution_details': executions,
              'auxiliary_controls': controls,
              'transformation': 'Only the natural observation gains an explicit element-type cast; '
                                'constraint expressions and expected output stay unchanged.',
              'scope': 'Auxiliary fixed-array controls are not passes for the original cases. '
                       'They do not qualify dynamic-array shape retention by execution.',
              'simulator': suite_results.tool_version([args.verilator, '--version']),
              'sources_sha256': {s: hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
              'inputs_sha256': {p.relative_to(ROOT).as_posix(): suite_results.input_digest(p) for p in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(f'{report["independent_rows"]} independent bit-serial rows; '
          'four auxiliary controls; seven output-difference faults.')


if __name__ == '__main__':
    main()
