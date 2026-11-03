#!/usr/bin/env python3
"""Interpret emitted SV stimuli and sample/event waiters independently of the oracle."""

import argparse
import datetime
import hashlib
import heapq
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
import common
import interaction_clockevent as generator


def interpret(source):
    """Read emitted declarations/statements; never call the generator's value model.

    Priorities order the writer, clockvar sampling, bridge and event consumers.
    There is no observation between the blocking/NBA notification phases, and
    separate consumers only write their own slots. No same-region order oracle
    is inferred from this interpreter's deterministic queue tie-breaker.
    """
    width = int(re.search(r'logic \[(\d+):0\] data, incoming;', source)[1])+1
    mask = (1 << width)-1
    edge, skew = re.search(r'clocking cb @\((posedge|negedge) clk\);\s*input #(0|1step) data;', source).groups()
    writer_edge, assign, writer_value = re.search(r'always @\((posedge|negedge) clk\) data (=|<=) (\w+);', source).groups()
    bridge = re.search(r'always begin : bridge\s*@(.*?)\n  end', source, re.S)[1]
    assert bridge.lstrip().startswith('(cb);')
    notify = re.search(r'(->>|->) (\w+);', bridge)
    displays = re.findall(r'\$display\("([^"]*)",\s*(.*?)\);',
                          source.split('task automatic show', 1)[1].split('endtask', 1)[0], re.S)
    assert len(displays) == 2
    arrays = {}
    initial = source.split('initial begin : initialize', 1)[1].split('\n  end', 1)[0]
    for name, value in re.findall(r'(\w+)\[slot\] = ([^;]+);', initial):
        arrays[name] = [0 if value == "'0" else int(value)]*2
    state = {'clk': int(re.search(r"bit clk = 1'b([01]);", source)[1]),
             'data': None, 'incoming': None, 'cb.data': None, 'bridges': 0, 'noise_hits': 0}
    listeners = []
    for forever, name, body in re.findall(r'initial (forever )?begin : (listener_\d+)\n(.*?)\n  end', source, re.S):
        event = re.match(r'\s*@\((\w+)\);', body)[1]
        delay = re.search(r'#(\d+);', body)
        assert delay
        before, after = body.split(delay[0], 1)
        before = re.sub(r'^\s*@\(\w+\);', '', before)
        listeners.append({'name': name, 'event': event, 'armed': True, 'repeat': bool(forever),
                          'delay': int(delay[1]), 'before': before, 'after': after})
    queue = []; serial = 0

    def put(tick, order, kind, value):
        nonlocal serial
        serial += 1
        heapq.heappush(queue, (tick, order, serial, kind, value))

    def literal(text):
        m = re.fullmatch(r"(\d+)'([hb])([0-9a-f]+)", text)
        assert m, text
        return int(m[3], 16 if m[2] == 'h' else 2) & ((1 << int(m[1]))-1)

    def expression(text, tick, local=None):
        text = text.strip(); local = local or {}
        if text == "'0": return 0
        if text == '$time': return tick
        if text == '$time + 1': return tick+1
        if text in local: return local[text]
        if text in state: return state[text]
        selected = re.fullmatch(r'(\w+)\[(i|\d+)\]', text)
        if selected: return arrays[selected[1]][local['i'] if selected[2] == 'i' else int(selected[2])]
        truncated = re.fullmatch(r'cb.data\[(\d+):0\]', text)
        if truncated: return None if state['cb.data'] is None else state['cb.data'] & ((1 << (int(truncated[1])+1))-1)
        raise AssertionError('unhandled expression: '+text)

    def execute(text, tick):
        for statement in text.split(';'):
            statement = statement.strip()
            if not statement: continue
            inc = re.fullmatch(r'(\w+)\[(\d+)\]\+\+', statement)
            if inc:
                arrays[inc[1]][int(inc[2])] += 1; continue
            assign = re.fullmatch(r'(\w+)\[(\d+)\] = (.*)', statement)
            assert assign, statement
            arrays[assign[1]][int(assign[2])] = expression(assign[3], tick)

    driver = source.split('initial begin : stimulus\n', 1)[1].split('$finish;', 1)[0]
    now = 0
    for statement in driver.split(';'):
        statement = statement.strip()
        if not statement: continue
        delay = re.fullmatch(r'#(\d+)', statement)
        if delay: now += int(delay[1]); continue
        show = re.fullmatch(r'show\((\d+)\)', statement)
        if show: put(now, 9, 'show', int(show[1])); continue
        trigger = re.fullmatch(r'(->>|->) (\w+)', statement)
        if trigger: put(now, 6 if trigger[1] == '->>' else 0, 'notify', trigger[2]); continue
        assignment = re.fullmatch(r'(data|incoming|clk) = (.*)', statement)
        assert assignment, statement
        put(now, 0, 'assign', (assignment[1], literal(assignment[2])))
    output = []
    while queue:
        tick, _, _, kind, value = heapq.heappop(queue)
        if kind == 'assign':
            name, new = value; old = state[name]; state[name] = new
            if name == 'clk' and old != new:
                actual = 'posedge' if new else 'negedge'
                if actual == writer_edge:
                    put(tick, 1 if assign == '=' else 2, 'write', None)
                if actual == edge:
                    put(tick, 3, 'sample', state['data'])
        elif kind == 'write': state['data'] = state[writer_value]
        elif kind == 'sample':
            state['cb.data'] = value if skew == '1step' else state['data']
            if 'bridges++;' in bridge: state['bridges'] += 1
            if notify: put(tick, 5 if notify[1] == '->' else 6, 'notify', notify[2])
        elif kind == 'notify':
            if value == 'noise': state['noise_hits'] += 1
            for listener in listeners:
                if listener['armed'] and listener['event'] == value:
                    listener['armed'] = False; put(tick, 7, 'wake', listener)
        elif kind == 'wake':
            execute(value['before'], tick)
            put(tick+value['delay'], 0, 'late', value)
        elif kind == 'late':
            execute(value['after'], tick); value['armed'] = value['repeat']
        elif kind == 'show':
            def render(display, local):
                text, arguments = display
                values = iter(expression(arg, tick, local) for arg in arguments.split(','))
                def substitute(match):
                    item = next(values)
                    return ('x'*width if item is None else format(item & mask, f'0{width}b')) if match[0] == '%b' else str(item)
                rendered = re.sub(r'%0d|%b', substitute, text)
                assert next(values, 'END') == 'END'
                return rendered
            output.append(render(displays[0], {'phase': value}))
            output.extend(render(displays[1], {'i': slot}) for slot in range(2))
        else: raise AssertionError(kind)
    return '\n'.join(output)+'\n'


def independent(row):
    return interpret(generator.make_case(row).body)


def runtime(verilator, directory):
    selected = generator.MODEL.select()
    rows = {'step': generator.MODEL.anchors[0], 'zero': generator.MODEL.anchors[4],
            'wide': next(row for row in selected if row[0] == '129' and row[1] == 'step' and row[4] == 'blocking'),
            'negative': next(row for row in selected if row[1:3] == ('zero', 'negedge') and row[4:] == ('blocking', '2'))}
    controls = {}
    expected = {}
    paths = {}
    for label, row in rows.items():
        case = generator.make_case(row)
        controls[label], expected[label] = common.render(case, generator.NAME, 1, 14, 'spec')
        paths[label] = 'tests/gen/ch14/'+case.name+'.sv'
    faults = (
        ('live_instead_of_sample', 'step', 'seen[0] = cb.data;', 'seen[0] = data;'),
        ('resample_after_live_change', 'zero', 'held[0] = cb.data;', 'held[0] = data;'),
        ('wrong_skew', 'step', 'input #1step data;', 'input #0 data;'),
        ('wrong_event', 'step', '-> ready;', '-> noise;'),
        ('miss_fanout', 'zero', 'listener_1\n    @(ready);', 'listener_1\n    @(noise);'),
        ('missing_update', 'zero', 'data <= incoming;', 'data <= data;'),
        ('wrong_writer_edge', 'negative', 'always @(negedge clk) data', 'always @(posedge clk) data'),
        ('lost_high_bits', 'wide', 'seen[0] = cb.data;', 'seen[0] = cb.data[31:0];'),
        ('no_rearm', 'step', 'initial forever begin : listener_0', 'initial begin : listener_0'),
    )
    variants = {name: (name, source, 'control') for name, source in controls.items()}
    for name, parent, old, new in faults:
        assert controls[parent].count(old) == 1, name
        changed = controls[parent].replace(old, new, 1)
        assert interpret(changed) != expected[parent], name
        variants[name] = (parent, changed, 'fault')
    outcomes = {}
    for name, (parent, source, kind) in variants.items():
        folder = directory/name; folder.mkdir()
        path = folder/'test.sv'
        source = source.replace('@'+generator.case_name(rows[parent])+'.expected', '@control.expected')
        path.write_text(source); (folder/'control.expected').write_text(expected[parent])
        observations = []; original = subprocess.run
        def capture(*args, **kwargs):
            result = original(*args, **kwargs)
            if Path(args[0][0]).name == 'Vt': observations.append(result)
            return result
        with patch.object(run_verilator.subprocess, 'run', side_effect=capture):
            passed, reason = run_verilator.run(path, verilator, 1)
        assert len(observations) == 1 and observations[0].returncode == 0, (name, reason)
        raw = observations[0]
        assert not re.search(r'%Error|%Fatal|%Warning', raw.stdout+'\n'+raw.stderr, re.I), name
        assert passed if kind == 'control' else not passed and reason.startswith('output differs'), (name, reason)
        normalized = original([sys.executable, str(run_verilator.NORMALIZE)],
                              input=''.join(line+'\n' for line in raw.stdout.splitlines() if not run_verilator.BANNER.match(line)),
                              capture_output=True, text=True, check=True).stdout
        outcomes[name] = {'kind': kind, 'control': parent, 'status': 'pass' if passed else 'detected',
                          'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                          'expected_stdout': expected[parent], 'stdout': normalized, 'returncode': raw.returncode,
                          'stderr': raw.stderr}
    return outcomes, paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve previous qualification evidence')
    version = subprocess.check_output([args.verilator, '--version'], text=True).strip()
    if not version.startswith('Verilator 5.052 '): parser.error('fixed Verilator 5.052 is required')
    for row in generator.MODEL.rows(): assert independent(row) == generator.reference(row), row
    with tempfile.TemporaryDirectory() as directory: outcomes, paths = runtime(args.verilator, Path(directory))
    sources = ('generators/interaction_clockevent.py', 'tools/qualify_clockevent.py')
    report = {'model': generator.MODEL.name, 'version': 1,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Independent emitted-statement/event-queue check of all legal rows; four original blocking-notification controls and nine real SV faults. Does not qualify nonblocking notification or same-slot ordering.',
              'independent_rows': len(generator.MODEL.rows()), 'simulator_version': version,
              'sources_sha256': {name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
              'controls': paths, 'executions': outcomes}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    print('independent rows: 192; controls: 4 pass; SV faults: 9 detected')


if __name__ == '__main__': main()
