#!/usr/bin/env python3
"""Qualify generate/default-disable references with a lexical event scoreboard."""

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
import interaction_gendisable as generator


def independent(row):
    """Resolve scope symbols, then advance live attempts one time step at a time."""
    _, default, shadow, mode, timing, _ = row
    gates = ('root', 'local0', 'local1', 'manual0', 'manual1')
    root = {'symbols': {'rst': ('root', False)}, 'default': 'rst'}
    conditions = {'root': ('root', False)}
    for lane in range(2):
        outer = {'symbols': {'own_reset': ('local'+str(lane), False)},
                 'default': 'own_reset' if default == 'override' else None}
        leaf = {'symbols': {'rst': ('root', True), 'own_reset': ('local'+str(lane), True)}
                           if shadow == 'present' else {}, 'default': None}
        scopes = [root, outer, leaf]
        if mode == 'zero':
            condition = None
        elif mode == 'explicit':
            condition = ('manual'+str(lane), False)
        else:
            declaration = next(i for i in range(2, -1, -1) if scopes[i]['default'])
            name = scopes[declaration]['default']
            condition = next(scopes[i]['symbols'][name] for i in range(declaration, -1, -1)
                             if name in scopes[i]['symbols'])
        conditions['lane'+str(lane)] = condition
        conditions['guard'+str(lane)] = None
    counters = {name: [0, 0] for name in conditions}
    phases = [('none', False), ('root', False), ('local0', False), ('local1', False),
              ('manual0', False), ('manual1', False), ('none', True)]
    lines = []
    for phase, (pulse, datum) in enumerate(phases):
        live = dict.fromkeys(gates, False)
        pending = dict.fromkeys(conditions, False)
        for tick in range(20):
            pulse_tick = {'at_start': 2, 'between': 8, 'at_end': 15}[timing]
            if tick == pulse_tick and pulse != 'none':
                live[pulse] = True
            if tick in (12, 18):
                live = dict.fromkeys(gates, False)
            for name, condition in conditions.items():
                disabled = bool(condition and live[condition[0]] != condition[1])
                if disabled:
                    pending[name] = False
                if tick not in (5, 15) or disabled:
                    continue
                if pending[name]:
                    counters[name][0 if datum else 1] += 1
                    pending[name] = False
                if tick == 5:
                    pending[name] = True
                else:
                    counters[name][0] += 1
        assert not any(pending.values())
        lines += [f'phase={phase} pulse={pulse} data={int(datum)}',
                  f'root pass={counters["root"][0]} fail={counters["root"][1]}']
        for lane in range(2):
            p, f = counters['lane'+str(lane)]
            gp, gf = counters['guard'+str(lane)]
            lines.append(f'lane{lane} pass={p} fail={f} guard_pass={gp} guard_fail={gf}')
    return '\n'.join(lines)+'\n'


def check_faults(directory, verilator):
    rows = {
        'inherit_control': ('case', 'inherit', 'absent', 'default', 'at_start', 'after'),
        'shadow_zero_control': ('if', 'inherit', 'present', 'zero', 'at_start', 'before'),
        'zero_control': generator.MODEL.anchors[2],
        'explicit_control': ('case', 'override', 'present', 'explicit', 'at_start', 'after'),
    }
    controls, expected, paths = {}, {}, {}
    for name, row in rows.items():
        assert row in generator.MODEL.select()
        path = ROOT/'tests/gen/ch16'/(generator.case_name(row)+'.sv')
        source = path.read_text()
        field = suite_results.header(path)['expected_stdout']
        source = source.replace(':expected_stdout: '+field, ':expected_stdout: @'+name+'.expected')
        controls[name] = source
        expected[name] = generator.reference(row)
        paths[name] = path.relative_to(ROOT).as_posix()
    zero = controls['zero_control']
    explicit = controls['explicit_control']
    inherited = controls['inherit_control']
    mutants = {
        'drop_inherited_disable': ('inherit_control', inherited.replace(
            'target_check: assert property (@(posedge clk) start',
            "target_check: assert property (@(posedge clk) disable iff (1'b0) start")),
        'wrong_default_source': ('inherit_control', inherited.replace(
            'target_check: assert property (@(posedge clk) start',
            'target_check: assert property (@(posedge clk) disable iff (manual_reset[0]) start')),
        'ignore_explicit_zero': ('zero_control', zero.replace(
            "target_check: assert property (@(posedge clk) disable iff (1'b0) start",
            'target_check: assert property (@(posedge clk) start')),
        'ignore_explicit_condition': ('explicit_control', re.sub(
            r'target_check: assert property \(@\(posedge clk\) disable iff \(manual_reset\[\d\]\) start',
            'target_check: assert property (@(posedge clk) start', explicit)),
        'alias_explicit_instances': ('explicit_control', explicit.replace(
            'disable iff (manual_reset[1])', 'disable iff (manual_reset[0])')),
        'missing_guard_action': ('zero_control', zero.replace('else guard_fail++;', 'else begin end')),
    }
    executions = {}
    variants = {name: (name, source) for name, source in controls.items()} | mutants
    for name, (control, source) in variants.items():
        assert name in controls or source != controls[control]
        path = directory/(name+'.sv')
        path.write_text(source)
        (directory/(control+'.expected')).write_text(expected[control])
        runtime = []
        actual_run = subprocess.run

        def capture(*args, **kwargs):
            result = actual_run(*args, **kwargs)
            if isinstance(args[0], (tuple, list)) and Path(args[0][0]).name == 'Vt':
                runtime.append(result)
            return result

        with patch.object(run_verilator.subprocess, 'run', side_effect=capture):
            ok, reason = run_verilator.run(path, verilator, 1)
        assert len(runtime) == 1 and runtime[0].returncode == 0, (name, reason)
        result = runtime[0]
        assert not re.search(r'unsupported|%Error|%Fatal', result.stdout+'\n'+result.stderr, re.I), name
        assert ok if name in controls else (not ok and reason.startswith('output differs')), (name, reason)
        raw = ''.join(line+'\n' for line in result.stdout.splitlines()
                      if not run_verilator.BANNER.match(line))
        normalized = actual_run([sys.executable, str(run_verilator.NORMALIZE)], input=raw,
                                capture_output=True, text=True, check=True).stdout
        executions[name] = {'status': 'pass' if ok else 'detected', 'control': control,
                            'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                            'returncode': result.returncode, 'stdout': normalized,
                            'stderr': result.stderr, 'reason': reason}
    return executions, paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        parser.error('output already exists; preserve earlier evidence')
    version = subprocess.check_output([args.verilator, '--version'], text=True).strip()
    if not version.startswith('Verilator 5.052 '):
        parser.error('qualification requires pinned Verilator 5.052')
    for row in generator.MODEL.rows():
        assert independent(row) == generator.reference(row), row
    with tempfile.TemporaryDirectory() as folder:
        executions, controls = check_faults(Path(folder), args.verilator)
    files = ['generators/interaction_gendisable.py', 'tools/qualify_gendisable.py']
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Independent lexical/event scoreboard and actual SV controls/faults. Controls use four matching at_start selections; they do not qualify the implicit generate override, interclock cancellation or end-clock NBA cases.',
              'independent_rows': len(generator.MODEL.rows()), 'simulator_version': version,
              'sources_sha256': {name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in files},
              'controls': controls, 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    print('independent rows:', report['independent_rows'], '; controls: 4 pass; SV faults: 6 detected')


if __name__ == '__main__':
    main()
