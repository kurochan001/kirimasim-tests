#!/usr/bin/env python3
"""Interpret bounded interface/query SV independently and execute SV faults."""

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

from qualify_class_import import Type, Value, initial_value, literal
from qualify_genloop import integer
from qualify_gensub import xor
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_ifquery as generator


def split_arguments(text):
    """Split only commas outside calls/indices, rejecting unbalanced input."""
    depth, start, parts = 0, 0, []
    for at, char in enumerate(text):
        if char in '([': depth += 1
        elif char in ')]':
            depth -= 1
            assert depth >= 0
        elif char == ',' and depth == 0:
            parts.append(text[start:at].strip()); start = at + 1
    assert depth == 0
    return parts + [text[start:].strip()]


def number(text, env):
    ternary = re.fullmatch(r'\s*(\w+)\s*\?\s*([^:]+):\s*(.+)', text)
    if ternary:
        condition, yes, no = ternary.groups()
        return integer(yes if env[condition] else no, env)
    return integer(text, env)


class Interface:
    def __init__(self, body, parameters):
        self.constants = dict(parameters)
        head = re.fullmatch(r'\s*localparam int R = ([^;]+);\s*typedef (bit|logic) '
                           r'\[\(([^)]+)\):\(([^)]+)\)\] word_t;'
                           r'\s*word_t data\[([^:]+):([^]]+)\], guard, checksum;'
                           r'\s*int calls, visited, weight, terminal;\s*(.*)', body, re.S)
        assert head, 'unsupported interface declarations'
        right, state, pl, pr, left, bound, method = head.groups()
        self.constants['R'] = number(right, self.constants)
        self.packed = number(pl, self.constants), number(pr, self.constants)
        self.bounds = number(left, self.constants), number(bound, self.constants)
        self.word = Type(abs(self.packed[0] - self.packed[1]) + 1, state, False)
        self.data = {i: initial_value(self.word) for i in range(min(self.bounds), max(self.bounds) + 1)}
        assert 0 < len(self.data) <= 8 and 0 < self.word.width <= 256
        self.values = {k: 0 for k in ('calls', 'visited', 'weight', 'terminal')}
        self.values.update(guard=initial_value(self.word), checksum=initial_value(self.word))
        parsed = re.fullmatch(r'(function automatic word_t scan\(\);|task automatic scan\(output word_t result\);)'
                              r'\s*word_t acc;\s*int at;(.*?)repeat \((.*?)\) begin(.*?)end(.*?)end(function|task)\s*', method, re.S)
        assert parsed, 'unsupported interface subroutine'
        start, self.head, self.limit, self.loop, self.tail, self.kind = parsed.groups()
        assert start.startswith(self.kind)
        self.returned = None

    def query(self, name, dim):
        if name == 'bits':
            assert dim is None
            return self.word.width * len(self.data)
        if name in ('dimensions', 'unpacked_dimensions'):
            assert dim is None
            return 2 if name == 'dimensions' else 1
        assert dim in (None, 1, 2), 'query dimension outside qualifier scope'
        left, right = self.bounds if dim in (None, 1) else self.packed
        return {'left': left, 'right': right, 'low': min(left, right), 'high': max(left, right),
                'increment': 1 if left >= right else -1, 'size': abs(right - left) + 1}[name]

    def expression(self, text):
        text = text.strip()
        if text in self.values: return self.values[text]
        if text == "'0": return Value(self.word.width)
        if ' ^ ' in text:
            a, b = text.split(' ^ ')
            return xor(self.expression(a), self.expression(b))
        shifted = re.fullmatch(r'\((\w+) << (\d+)\)', text)
        if shifted:
            value, amount = self.values[shifted[1]], int(shifted[2])
            mask = (1 << value.width) - 1
            return Value(value.width, (value.bits << amount) & mask,
                         (value.x << amount) & mask, (value.z << amount) & mask)
        element = re.fullmatch(r'data\[([^]]+)\]', text)
        if element:
            at = self.expression(element[1]); assert at in self.data, 'out-of-range array read'
            return self.data[at]
        text = re.sub(r'\$(\w+)\(data(?:,\s*(\d+))?\)',
                      lambda m: str(self.query(m[1], int(m[2]) if m[2] else None)), text)
        env = {**self.constants, **{k: v for k, v in self.values.items() if isinstance(v, int)}}
        return integer(text, env)

    def execute(self, text):
        for statement in (s.strip() for s in text.split(';') if s.strip()):
            if statement.startswith('return '):
                assert self.kind == 'function' and self.returned is None
                self.returned = self.expression(statement[7:]).convert(self.word)
                continue
            increment = re.fullmatch(r'(\w+)\+\+', statement)
            if increment:
                self.values[increment[1]] += 1
                continue
            assignment = re.fullmatch(r'(\w+)\s*(\+=|-=|=)\s*(.+)', statement, re.S)
            assert assignment, ('unsupported scan statement', statement)
            target, op, rhs = assignment.groups()
            value = self.expression(rhs)
            if target == 'result':
                assert self.kind == 'task' and op == '=' and self.returned is None
                self.returned = value.convert(self.word)
            elif target in ('acc', 'guard', 'checksum'):
                assert op == '=' and isinstance(value, Value)
                self.values[target] = value.convert(self.word)
            else:
                assert target in ('at', 'calls', 'visited', 'weight', 'terminal') and isinstance(value, int)
                self.values[target] = value if op == '=' else self.values[target] + (value if op == '+=' else -value)

    def call(self):
        self.values.update(acc=initial_value(self.word), at=0)
        self.returned = None
        self.execute(self.head)
        count = self.expression(self.limit)
        assert 0 <= count <= 8
        for _ in range(count): self.execute(self.loop)
        self.execute(self.tail)
        assert self.returned is not None
        return self.returned


def interpret(source):
    """Use actual declarations, queries, calls, writes and display operands."""
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    parsed = re.fullmatch(r'\s*interface query_if #\(parameter int W=1, N=1, L=0, UP=1, PUP=1\);'
                          r'(.*?)endinterface\s*module \w+;(.*?)\s*endmodule\s*', code, re.S)
    assert parsed, 'unsupported compilation-unit structure'
    definition, top = parsed.groups()
    instances = {}
    for params, name in re.findall(r'query_if #\((.*?)\) (\w+)\(\);', top):
        options = dict(re.findall(r'\.(\w+)\((-?\d+)\)', params))
        assert set(options) == {'W', 'N', 'L', 'UP', 'PUP'} and name not in instances
        assert re.sub(r'\.(\w+)\((-?\d+)\)', '', params).replace(',', '').strip() == ''
        instances[name] = Interface(definition, {k: int(v) for k, v in options.items()})
    top = re.sub(r'query_if #\(.*?\) \w+\(\);', '', top, flags=re.S)
    parsed = re.fullmatch(r'\s*logic \[(\d+):0\] ra, rb;\s*initial begin(.*?)\$finish;\s*end\s*', top, re.S)
    assert parsed and set(instances) == {'a', 'b'}
    top_bit, program = parsed.groups()
    result_type = Type(int(top_bit) + 1, 'logic', False)
    results = {name: initial_value(result_type) for name in ('ra', 'rb')}
    lines = []

    def member(text):
        m = re.fullmatch(r'([ab])\.(data\[([^]]+)\]|guard|checksum|calls|visited|weight|terminal)', text.strip())
        assert m, ('unsupported member', text)
        owner, field, index = m.groups()
        return instances[owner], field if index is None else 'data', expression(index) if index is not None else None

    def expression(text):
        text = text.strip()
        if text in results: return results[text]
        if text.startswith('~'):
            value = expression(text[1:]); mask = (1 << value.width) - 1
            return Value(value.width, (~(value.bits | value.x | value.z)) & mask, value.x | value.z)
        query = re.fullmatch(r'\$(\w+)\(([ab])\.data(?:,\s*(\d+))?\)', text)
        if query:
            name, owner, dim = query.groups()
            return instances[owner].query(name, int(dim) if dim else None)
        if re.fullmatch(r'[ab]\..+', text):
            owner, field, index = member(text)
            if index is not None:
                assert index in owner.data
                return owner.data[index]
            return owner.values[field]
        if "'" in text: return literal(text)
        return integer(text, {})

    for statement in (s.strip() for s in program.split(';') if s.strip()):
        display = re.fullmatch(r'\$display\("([^"\n]*)"(?:,\s*(.*))?\)', statement, re.S)
        if display:
            fmt, arguments = display.groups()
            arguments = iter(split_arguments(arguments) if arguments else [])
            def replace(match):
                value = expression(next(arguments))
                if match[0] == '%b':
                    assert isinstance(value, Value)
                    return value.binary()
                assert isinstance(value, int)
                return str(value)
            lines.append(re.sub(r'%0d|%b', replace, fmt))
            assert list(arguments) == []
            continue
        call = re.fullmatch(r'(ra|rb)=([ab])\.scan\(\)|([ab])\.scan\((ra|rb)\)', statement)
        if call:
            result, receiver, task_receiver, task_result = call.groups()
            owner = instances[receiver or task_receiver]
            assert owner.kind == ('task' if task_receiver else 'function')
            results[result or task_result] = owner.call().convert(result_type)
            continue
        write = re.fullmatch(r'(.+?)\s*=\s*(.+)', statement, re.S)
        assert write, ('unsupported top statement', statement)
        target, rhs = write.groups()
        if target in results:
            assert rhs == "'0"
            results[target] = Value(result_type.width)
            continue
        owner, field, at = member(target)
        value = Value(owner.word.width) if rhs == "'0" else expression(rhs)
        if field == 'data':
            assert at in owner.data and isinstance(value, Value)
            owner.data[at] = value.convert(owner.word)
        elif field in ('guard', 'checksum'):
            assert isinstance(value, Value)
            owner.values[field] = value.convert(owner.word)
        else:
            assert isinstance(value, int)
            owner.values[field] = value
    return '\n'.join(lines) + '\n'


def independent(row):
    return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[i]) for name, i in
                (('scalar', 0), ('task_z', 1), ('task_x', 2), ('function_known', 4), ('task_known', 5))}
    faults = (
        ('wrong_width', 'function_known', [('.W(32)', '.W(31)')]),
        ('reverse_walk', 'function_known', [('at=$left(data, 1)', 'at=$right(data, 1)'), ('at -=', 'at +=')]),
        ('skip_last', 'function_known', [('repeat ($size(data, 1))', 'repeat ($size(data, 1)-1)')]),
        ('lost_shift', 'function_known', [('(acc << 1) ^ data[at]', 'acc ^ data[at]')]),
        ('lost_accumulation', 'function_known', [('(acc << 1) ^ data[at]', 'data[at]')]),
        ('lost_terminal', 'task_x', [('terminal=at', 'terminal=0')]),
        ('lost_call_count', 'task_z', [('calls++', 'calls+=0')]),
        ('wrong_receiver', 'scalar', [('ra=a.scan()', 'ra=b.scan()')]),
        ('guard_clobber', 'task_known', [('calls++;', "calls++; guard='0;")]),
    )
    programs = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, edits in faults:
        source = controls[parent].body
        for old, new in edits:
            assert old in source
            source = source.replace(old, new)
        assert interpret(source) != controls[parent].expected, name
        programs[name] = parent, source, 'fault'
    return controls, programs


def runtime(executable, directory):
    import common
    controls, programs = variants()
    records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]
        source, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = source.replace(case.body.strip('\n'), body.strip('\n'))
        original = ROOT / 'tests/gen/ch25' / (case.name + '.sv')
        folder = directory / name; folder.mkdir()
        path = folder / original.name
        path.write_text(source); path.with_suffix('.expected').write_text(case.expected)
        calls, run = [], subprocess.run
        def capture(*args, **kwargs):
            result = run(*args, **kwargs)
            if args[0][0] == executable: calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture):
            status, reason = run_kirimasim.run(path, executable)
        assert len(calls) == 1 and calls[0].returncode == 0, (name, status, reason)
        assert status == ('pass' if kind == 'control' else 'fail'), (name, status, reason)
        if kind == 'fault': assert reason.startswith('output differs'), (name, reason)
        normalized = run([sys.executable, str(run_kirimasim.NORMALIZE)], input=calls[0].stdout,
                         text=True, capture_output=True, check=True).stdout
        records[name] = {'kind': kind, 'control': parent, 'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                         'original_test': original.relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(original),
                         'expected_stdout': case.expected, 'stdout': normalized,
                         'stderr': calls[0].stderr.replace(str(folder), '<case>'), 'returncode': 0}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')
    files = ('generators/interaction_ifquery.py', 'generators/interaction_class_import.py',
             'generators/interaction_cond.py', 'generators/interaction_cover.py', 'generators/common.py',
             'tools/qualify_ifquery.py', 'tools/qualify_class_import.py', 'tools/qualify_genloop.py', 'tools/qualify_gensub.py')
    def hashes(): return {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}
    sources = hashes(); runner = suite_results.runner_digest('kirimasim')
    binary = Path(args.kirimasim).resolve(); before = hashlib.sha256(binary.read_bytes()).hexdigest()
    paths = [ROOT / 'tests/gen/ch25' / (generator.case_name(r) + '.sv') for r in generator.MODEL.select()]
    inputs = {p: suite_results.input_digest(p) for p in paths}
    evidence = hashlib.sha256()
    for row in generator.MODEL.rows():
        source, expected = generator.source(row), generator.reference(row)
        assert interpret(source) == expected, row
        evidence.update(source.encode() + b'\0' + expected.encode() + b'\0')
    with tempfile.TemporaryDirectory() as tmp: executions = runtime(str(binary), Path(tmp))
    assert hashes() == sources and runner == suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(p) == v for p, v in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == before
    result = {'model': generator.MODEL.name, 'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Actual bounded interface/query declarations, typed calls and array walk; auxiliary executions are not fixed/coverage passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths),
              'source_and_expectation_sha256': evidence.hexdigest(), 'source_sha256': sources, 'runner_sha256': runner,
              'binary_sha256': before, 'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True, 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; native controls: 5; detected SV faults: 9')


if __name__ == '__main__':
    main()
