#!/usr/bin/env python3
"""Independently interpret emitted package NBA programs and real SV faults."""

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
sys.path.insert(0, str(ROOT/'generators'))
import interaction_pkgnba as generator


@dataclass(frozen=True)
class Word:
    bits: str

    def convert(self, width, state='logic'):
        bits = self.bits[-width:].rjust(width, '0')
        return Word(bits.replace('x', '0').replace('z', '0') if state == 'bit' else bits)


def literal(text, width):
    text = text.strip()
    if text.startswith('{') and text.endswith('}'):
        return Word(''.join(literal(part, width).bits for part in text[1:-1].split(',')))
    match = re.fullmatch(r"(\d+)'([hb])([0-9a-fxz]+)", text)
    if match:
        size, base, digits = match.groups(); size = int(size)
        bits = format(int(digits, 16), f'0{size}b')[-size:] if base == 'h' else digits.rjust(size, '0')[-size:]
        return Word(bits)
    match = re.fullmatch(r"'([01xz])", text)
    assert match, 'unknown literal: '+text
    return Word(match[1]*width)


def interpret(source):
    """A bounded event queue for one producer and synchronous module-task calls.

    Parse actual declarations, bindings, values, task statements, addresses and
    displays. Active producer statements precede due-time NBAs; FIFO resolves
    only calls originating in this single thread, never independent writers.
    """
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    assert len(re.findall(r'\binitial\s+begin', code)) == 1, 'exactly one producer is required'
    assert not re.search(r'\b(?:always|always_comb|always_ff|always_latch)\b', code), 'independent producer'
    types = {}; objects = {}; arrays = {}
    for name, body in re.findall(r'package (\w+);(.*?)endpackage', source, re.S):
        declaration = re.fullmatch(r'\s*typedef (bit|logic) \[(\d+):0\] word_t;\s*word_t (.*?);\s*', body, re.S)
        assert declaration
        state, top, shape = declaration.groups(); width = int(top)+1
        types[name] = (width, state)
        dims = re.fullmatch(r'target\[(-?\d+):(-?\d+)\]', shape)
        if dims:
            lo, hi = sorted(map(int, dims.groups())); arrays[name] = set(range(lo, hi+1))
            keys = [('target', i) for i in arrays[name]]
        else:
            assert shape == 'target, neighbor'; keys = [('target', None), ('neighbor', None)]
        for field, index in keys: objects[name, field, index] = Word(('0' if state == 'bit' else 'x')*width)
    assert set(types) == {'payload_pkg', 'control_pkg'}
    worker = re.search(r'module pkg_writer.*?endmodule', source, re.S)[0]
    probe = re.search(r'module pkg_probe;.*?endmodule', source, re.S)[0]
    data_type = re.search(r'typedef (logic|bit) \[(\d+):0\] source_t;', worker)
    assert data_type
    data_state, data_width = data_type[1], int(data_type[2])+1
    task = re.search(r'task automatic enqueue\(input int phase, input source_t data, input integer where\);'
                     r'(.*?)endtask', worker, re.S)
    assert task
    reader = re.search(r'function automatic (\w+)::word_t read_target\(input integer index\);'
                       r'\s*return ([^;]+);\s*endfunction', probe)
    assert reader
    source_width = int(re.search(r'logic \[(\d+):0\] source;', source)[1])+1
    identities = {m[1]: int(m[0]) for m in re.findall(r'pkg_writer #\(\.ID\((\d+)\)\) ([ab])\(\);', source)}
    assert set(identities) == {'a', 'b'}
    env = {'source': Word('x'*source_width), 'index': 0}
    events = []; serial = 0; output = []

    def put(tick, priority, kind, data):
        nonlocal serial
        serial += 1; heapq.heappush(events, (tick, priority, serial, kind, data))

    def integer(text, frame):
        text = text.strip()
        if re.fullmatch(r'-?\d+', text): return int(text)
        assert text in frame and type(frame[text]) is int, 'unknown integer: '+text
        return frame[text]

    def address(text, frame, context=''):
        m = re.fullmatch(r'(?:(\w+)::)?(target|neighbor)(?:\[([^\]]+)\])?', text.strip())
        assert m, 'unknown place: '+text
        package, field, index = m.groups()
        if package is None:
            imported = re.search(r'import (\w+)::(?:\*|target);', context)
            assert imported, 'unbound imported name'; package = imported[1]
        key = (package, field, integer(index, frame) if index is not None else None)
        assert key in objects, key
        return key

    def operand(text, frame, tick, context=''):
        text = text.strip()
        if text == '$time': return tick
        if text in frame: return frame[text]
        if re.fullmatch(r'-?\d+', text): return int(text)
        call = re.fullmatch(r'probe.read_target\((.*?)\)', text)
        if call:
            key = address(reader[2], {'index': integer(call[1], frame)}, probe)
            return objects[key].convert(*types[reader[1]])
        return objects[address(text, frame, context)]

    def display(statement, frame, tick, context=''):
        match = re.fullmatch(r'\$display\("([^"]*)",\s*(.*?)\)', statement, re.S)
        assert match, 'unknown display: '+statement
        values = iter(operand(a, frame, tick, context) for a in match[2].split(','))
        def field(m):
            value = next(values)
            if m[0] == '%b': assert isinstance(value, Word); return value.bits
            assert type(value) is int
            return str(value)
        output.append(re.sub(r'%0d|%b', field, match[1]))
        assert next(values, None) is None

    def write(key, value):
        assert isinstance(value, Word)
        objects[key] = value.convert(*types[key[0]])

    def enqueue(who, phase, tick):
        frame = {'ID': identities[who], 'phase': phase, 'data': env['source'].convert(data_width, data_state),
                 'where': env['index']}
        for raw in task[1].split(';'):
            statement = raw.strip()
            if not statement: continue
            if statement.startswith('$display('): display(statement, frame, tick, worker); continue
            a = re.fullmatch(r'(.+?)\s+(<=|=)\s+(?:#(\d+)\s+)?(.+)', statement, re.S)
            assert a, 'unknown task statement: '+statement
            target, operation, delay, rhs = a.groups(); delay = int(delay or 0)
            if target in ('data', 'where'):
                assert operation == '=' and delay == 0
                frame[target] = literal(rhs, data_width).convert(data_width, data_state) if target == 'data' else integer(rhs, frame)
                continue
            key = address(target, frame, worker)
            value = frame[rhs].convert(*types[key[0]]) if rhs in frame else literal(rhs, types[key[0]][0]).convert(*types[key[0]])
            if operation == '<=': put(tick+delay, 1, 'write', (key, value))
            else: assert delay == 0; write(key, value)

    tick = 0
    driver = source.split('  initial begin\n', 1)[1].split('$finish;', 1)[0]
    for raw in driver.split(';'):
        statement = raw.strip()
        if not statement: continue
        delay = re.fullmatch(r'#(\d+)', statement)
        if delay: tick += int(delay[1])
        else: put(tick, 0, 'producer', statement)
    while events:
        tick, _, _, kind, data = heapq.heappop(events)
        if kind == 'write': write(*data); continue
        statement = data
        if statement.startswith('$display('): display(statement, env, tick); continue
        call = re.fullmatch(r'([ab]).enqueue\(([01]), source, index\)', statement)
        if call: enqueue(call[1], int(call[2]), tick); continue
        a = re.fullmatch(r'(.+?) = (.+)', statement, re.S)
        assert a, 'unknown producer statement: '+statement
        target, rhs = a.groups()
        if target == 'index': env['index'] = integer(rhs, env)
        elif target == 'source': env['source'] = literal(rhs, source_width).convert(source_width)
        else:
            key = address(target, env); write(key, literal(rhs, types[key[0]][0]))
    return '\n'.join(output)+'\n'


def independent(row):
    return interpret(generator.source(row))


def runtime(executable, directory):
    controls = {}
    for name, index in (('scalar', 0), ('wide', 1), ('imported', 2), ('bit_array', 3)):
        row = generator.MODEL.anchors[index]
        path = ROOT/'tests/gen/ch26'/(generator.case_name(row)+'.sv')
        controls[name] = (path.read_text(), suite_results.expected_output(path, 'kirimasim'), path)
    scalar = controls['scalar'][0]
    a = re.search(r'    source = [^;]+;\n    a.enqueue\(0, source, index\);', scalar)[0]
    b = re.search(r'    source = [^;]+;\n    b.enqueue\(0, source, index\);', scalar)[0]
    faults = (
        ('wrong_package', 'scalar', 'payload_pkg::target <=', 'control_pkg::target <='),
        ('wrong_import', 'imported', 'import payload_pkg::*;', 'import control_pkg::*;'),
        ('blocking_update', 'scalar', 'payload_pkg::target <= data;', 'payload_pkg::target = data;'),
        ('omitted_delay', 'wide', '<= #1 data;', '<= data;'),
        ('reversed_order', 'scalar', a+'\n'+b, b+'\n'+a),
        ('wrong_element', 'bit_array', 'target[where] <=', 'target[1] <='),
        ('lost_unknowns', 'wide', 'typedef logic', 'typedef bit'),
        ('clobbered_argument', 'scalar', "    payload_pkg::target <= data;\n    data = '1;",
         "    data = '1;\n    payload_pkg::target <= data;"),
    )
    variants = {name:(name,source,'control') for name,(source,_,_) in controls.items()}
    for name, parent, old, new in faults:
        source = controls[parent][0]; assert old in source, name
        variants[name] = (parent, source.replace(old, new, 1), 'fault')
    records = {}
    for name, (parent, source, kind) in variants.items():
        expected = controls[parent][1]; assert expected is not None
        if kind == 'fault': assert interpret(source) != expected, name
        folder = directory/name; folder.mkdir()
        path = folder/controls[parent][2].name
        path.write_text(source); path.with_suffix('.expected').write_text(expected)
        calls = []; original = subprocess.run
        def capture(*a, **kw):
            r = original(*a, **kw)
            if a[0][0] == executable: calls.append(r)
            return r
        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture):
            status, reason = run_kirimasim.run(path, executable)
        assert len(calls)==1 and calls[0].returncode==0, (name,reason)
        assert status == ('pass' if kind=='control' else 'fail'), (name,status,reason)
        if kind=='fault': assert reason.startswith('output differs'), (name,reason)
        raw = calls[0]
        stdout = original([sys.executable,str(run_kirimasim.NORMALIZE)],input=raw.stdout,
                          capture_output=True,text=True,check=True).stdout
        records[name] = {'kind':kind,'control':parent,'status':'pass' if kind=='control' else 'detected',
                         'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'expected_stdout':expected,
                         'stdout':stdout,'stderr':raw.stderr.replace(str(folder),'<case>'),'returncode':raw.returncode,
                         'original_test':controls[parent][2].relative_to(ROOT).as_posix(),
                         'original_input_sha256':suite_results.input_digest(controls[parent][2])}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')
    for row in generator.MODEL.rows(): assert independent(row)==generator.reference(row),row
    binary = Path(args.kirimasim).resolve(); digest = hashlib.sha256(binary.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as directory: records = runtime(str(binary),Path(directory))
    assert digest==hashlib.sha256(binary.read_bytes()).hexdigest(),'binary changed'
    result = {'model':generator.MODEL.name,'version':1,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope':'Independent parsing of actual package types, bindings, task and producer statements, data and displays; one producer event queue with captured targets/values and due-time Active-before-NBA ordering. Four selected native controls and eight real SV faults; no ordering claim for independent writer threads.',
              'independent_rows':len(generator.MODEL.rows()),'binary_sha256':digest,
              'simulator_version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
              'runner_sha256':suite_results.runner_digest('kirimasim'),
              'sources_sha256':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in
                                ('generators/interaction_pkgnba.py','tools/qualify_pkgnba.py')},'executions':records}
    args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows: 1296; native controls: 4 pass; real SV faults: 8 detected')


if __name__=='__main__':
    main()
