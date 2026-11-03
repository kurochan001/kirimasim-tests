#!/usr/bin/env python3
"""Independently interpret emitted deferred-argument stimuli and run SV faults."""

import argparse
from dataclasses import dataclass
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

import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_deferarg as generator


@dataclass(frozen=True)
class Word:
    value: int
    width: int
    signed: bool = False

    def decimal(self):
        return self.value - (1 << self.width) if self.signed and self.value >> (self.width - 1) else self.value

    def resize(self, width, signed):
        return Word((self.decimal() if self.signed else self.value) & ((1 << width) - 1), width, signed)


def interpret(source):
    """Read the actual emitted declarations, values, call and display statements.

    Queue priorities model this bounded program: all producer statements and
    NBAs finish before reports; there is no Reactive writer. This does not
    distinguish the two report regions or order unrelated same-slot processes.
    """
    types = {}
    for sign, top, name in re.findall(r'typedef logic (signed|unsigned) \[(\d+):0\] (\w+);', source):
        types[name] = (int(top) + 1, sign == 'signed')
    assert set(types) == {'word_t', 'report_t'}
    signature = re.search(r'(?:function automatic void|task automatic) report\(input int phase, '
                          r'input word_t captured,\s*(input|const ref) (\w+) arg\);', source)
    assert signature
    passing, formal = signature.groups()
    report_body = source[signature.end():].split('endfunction' if source[signature.start():].startswith('function') else 'endtask', 1)[0]
    report_display = re.search(r'\$display\("([^"]*)",\s*(.*?)\);', report_body, re.S)
    assert report_display
    capture = re.search(r'function automatic word_t capture\(input word_t x\);(.*?)endfunction', source, re.S)[1]
    capture_statements = [s.strip() for s in capture.split(';') if s.strip()]
    assert capture_statements in (['calls++', 'return x'], ['calls += 0', 'return x'])
    state = {'value': None, 'ready': Word(0, 1), 'calls': Word(0, 32, True)}
    events = []; serial = 0; output = []

    def put(tick, priority, kind, data):
        nonlocal serial
        serial += 1
        heapq.heappush(events, (tick, priority, serial, kind, data))

    def expression(text, tick, frame=None):
        text = text.strip(); frame = frame or {}
        if text in frame: return frame[text]
        if text in state:
            value = state[text]; assert value is not None
            return value
        if text == '$time': return Word(tick, 64)
        if text == '$bits(arg)': return Word(types[formal][0], 32, True)
        if text.isdecimal(): return Word(int(text), 32, True)
        lit = re.fullmatch(r"(\d+)'h([0-9a-f]+)", text)
        if lit: return Word(int(lit[2], 16) & ((1 << int(lit[1])) - 1), int(lit[1]))
        part = re.fullmatch(r'arg\[(\d+):0\]', text)
        if part: return Word(frame['arg'].value & ((1 << (int(part[1]) + 1)) - 1), int(part[1]) + 1)
        raise AssertionError('unhandled expression: ' + text)

    def display(fmt, args, tick, frame=None):
        values = iter(expression(arg, tick, frame) for arg in args.split(','))
        def field(match):
            v = next(values)
            return format(v.value, f'0{v.width}b') if match[0] in ('%b', '%0b') else str(v.decimal())
        output.append(re.sub(r'%0d|%0b|%b', field, fmt))
        assert next(values, None) is None

    def emit(tick, frame):
        current = dict(frame)
        if passing == 'const ref': current['arg'] = state['value'].resize(*types[formal])
        display(report_display[1], report_display[2], tick, current)

    tick = 0
    driver = source.split('  initial begin\n', 1)[1].split('$finish;', 1)[0]
    for statement in driver.split(';'):
        statement = statement.strip()
        if not statement: continue
        delay = re.fullmatch(r'#(\d+)', statement)
        if delay: tick += int(delay[1]); continue
        assignment = re.fullmatch(r'(value|ready) (=|<=) (.+)', statement)
        if assignment:
            put(tick, 0, 'assign', assignment.groups()); continue
        show = re.fullmatch(r'\$display\("([^"]*)",\s*(.*?)\)', statement, re.S)
        if show: put(tick, 0, 'display', show.groups()); continue
        call = re.fullmatch(r'(?:probe_\d+: assert (#0|final) \(1\)\s*)?'
                            r'report\((\d+), (capture\(value\)|value), value\)', statement)
        assert call, statement
        put(tick, 0, 'register', call.groups())
    while events:
        now, _, _, kind, data = heapq.heappop(events)
        if kind == 'assign':
            name, operation, value = data; v = expression(value, now)
            v = v.resize(*(types['word_t'] if name == 'value' else (1, False)))
            if operation == '<=': put(now, 1, 'nba', (name, v))
            else: state[name] = v
        elif kind == 'nba': state[data[0]] = data[1]
        elif kind == 'register':
            queue, phase, capture_expr = data
            old = state['value']; assert old is not None
            if capture_expr.startswith('capture') and capture_statements[0] == 'calls++':
                state['calls'] = Word(state['calls'].value + 1, 32, True)
            frame = {'phase': Word(int(phase), 32, True), 'captured': old}
            if passing == 'input': frame['arg'] = old.resize(*types[formal])
            if queue is None: emit(now, frame)
            else: put(now, 2 if queue == '#0' else 3, 'emit', frame)
        elif kind == 'emit': emit(now, data)
        elif kind == 'display': display(*data, now)
        else: raise AssertionError(kind)
    return '\n'.join(output) + '\n'


def independent(row):
    return interpret(generator.source(row))


def runtime(executable, directory):
    selected = generator.MODEL.select()
    rows = {'scalar': generator.MODEL.anchors[0], 'reference': generator.MODEL.anchors[1],
            'narrow': generator.MODEL.anchors[2],
            'same': next(row for row in selected if row[0] != '1' and row[1:4] == ('signed', 'input', 'same'))}
    controls = {}
    for key, row in rows.items():
        path = ROOT/'tests/gen/ch13'/(generator.case_name(row) + '.sv')
        controls[key] = (path.read_text(), suite_results.expected_output(path, 'kirimasim'), path)
    faults = (
        ('input_becomes_reference', 'same', 'input report_t arg', 'const ref report_t arg'),
        ('reference_becomes_copy', 'reference', 'const ref word_t arg', 'input word_t arg'),
        ('captured_reads_live', 'scalar', 'phase, $time, captured, arg, value', 'phase, $time, value, arg, value'),
        ('missing_capture_side_effect', 'scalar', 'calls++;', 'calls += 0;'),
        ('lost_high_bits', 'reference', 'captured, arg, value, arg', 'captured, arg[31:0], value, arg'),
        ('wrong_formal_width', 'narrow', '[31:0] report_t;', '[32:0] report_t;'),
        ('unsigned_formal', 'same', 'typedef logic signed', 'typedef logic unsigned'),
        ('missing_ready_marker', 'scalar', 'ready = 1;', 'ready = 0;'),
    )
    variants = {key: (key, source, 'control') for key, (source, _, _) in controls.items()}
    for name, parent, old, new in faults:
        source = controls[parent][0]
        if name == 'unsigned_formal':
            # Change only the formal typedef, preserving signed source/capture types.
            old = next(line for line in source.splitlines() if 'report_t;' in line)
            new = old.replace('signed', 'unsigned')
        assert old in source, name
        changed = source.replace(old, new, 1)
        assert interpret(changed) != controls[parent][1], name
        variants[name] = (parent, changed, 'fault')
    source = controls['scalar'][0]
    old = 'probe_0: assert #0 (1)\n      report(0, capture(value), value);'
    assert old in source
    variants['immediate_call'] = ('scalar', source.replace(old, 'report(0, capture(value), value);', 1), 'fault')
    source = controls['reference'][0]
    old = re.search(r'value <= [^;]+;', source)[0]
    variants['missing_nba_update'] = ('reference', source.replace(old, 'value <= value;', 1), 'fault')
    records = {}
    for name, (parent, source, kind) in variants.items():
        expected = controls[parent][1]; assert expected is not None
        if kind == 'fault': assert interpret(source) != expected, name
        folder = directory/name; folder.mkdir()
        path = folder/controls[parent][2].name
        path.write_text(source); path.with_suffix('.expected').write_text(expected)
        results = []; original = subprocess.run
        def capture(*a, **kw):
            result = original(*a, **kw)
            if a[0][0] == executable: results.append(result)
            return result
        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture):
            status, reason = run_kirimasim.run(path, executable)
        assert len(results) == 1 and results[0].returncode == 0, (name, reason)
        assert status == ('pass' if kind == 'control' else 'fail'), (name, status, reason)
        if kind == 'fault': assert reason.startswith('output differs'), (name, reason)
        raw = results[0]
        stdout = original([sys.executable, str(run_kirimasim.NORMALIZE)], input=raw.stdout,
                          capture_output=True, text=True, check=True).stdout
        records[name] = {'kind': kind, 'control': parent, 'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                         'expected_stdout': expected, 'stdout': stdout, 'returncode': raw.returncode,
                         'stderr': raw.stderr.replace(str(folder), '<case>'),
                         'original_test': controls[parent][2].relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(controls[parent][2])}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve previous qualification evidence')
    for row in generator.MODEL.rows(): assert independent(row) == generator.reference(row), row
    binary = Path(args.kirimasim).resolve(); before = hashlib.sha256(binary.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as directory: records = runtime(str(binary), Path(directory))
    assert before == hashlib.sha256(binary.read_bytes()).hexdigest(), 'binary changed during qualification'
    data = {'model': generator.MODEL.name, 'version': 1,
            'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope': 'Independent interpretation of all emitted legal stimuli and displays; four selected native controls and ten real SV faults. No comparison of Observed/Reactive/Postponed relative ordering beyond settled producer updates.',
            'independent_rows': len(generator.MODEL.rows()), 'binary_sha256': before,
            'simulator_version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
            'runner_sha256': suite_results.runner_digest('kirimasim'),
            'sources_sha256': {n: hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in
                              ('generators/interaction_deferarg.py', 'tools/qualify_deferarg.py')},
            'executions': records}
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print(f'independent rows: {len(generator.MODEL.rows())}; controls: 4 pass; SV faults: 10 detected')


if __name__ == '__main__':
    main()
