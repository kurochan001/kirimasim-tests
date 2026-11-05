#!/usr/bin/env python3
"""Independently interpret bounded typed constants and generated SV shape."""

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
from qualify_ifquery import split_arguments
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_genexpr as generator


def decimal(value):
    assert not value.x and not value.z
    return value.bits - (1 << value.width) if value.signed and value.bits >> (value.width - 1) else value.bits


class Worker:
    def __init__(self, source, select):
        self.numbers = {'SELECT': select}
        declarations, generation = source.split('  if (', 1) if '  if (' in source else source.split('  case (', 1)
        form = 'if' if '  if (' in source else 'case'
        first = re.match(r'\s*localparam int BASE=(\d+), CW=(\d+);', declarations)
        assert first
        self.numbers.update(BASE=int(first[1]), CW=int(first[2]))
        self.types, self.values = {}, {}
        remaining = declarations[first.end():]
        type_pattern = r'\s*typedef logic (signed|unsigned) \[([^]]+):0\] (\w+);'
        for m in re.finditer(type_pattern, remaining):
            sign, top, name = m.groups()
            assert name not in self.types
            self.types[name] = Type(integer(top, self.numbers) + 1, 'logic', sign == 'signed')
        remaining = re.sub(type_pattern, '', remaining)
        assert set(self.types) == {'left_t', 'right_t', 'result_t'}
        for m in re.finditer(r'\s*localparam (left_t|right_t|result_t) (\w+) = ([^;]+);', remaining):
            kind, name, expr = m.groups()
            assert name not in self.values
            self.values[name] = self.expression(expr, self.types[kind]).convert(self.types[kind])
        remaining = re.sub(r'\s*localparam (left_t|right_t|result_t) \w+ = [^;]+;', '', remaining)
        assert set(self.values) == {'A', 'B', 'E'}
        parsed = re.fullmatch(r'\s*localparam bit NEG = (E < 0);\s*localparam int COUNT=([^;]+);'
                              r'\s*localparam int WIDTH=([^;]+);\s*', remaining)
        assert parsed, 'unsupported shape constants'
        self.numbers['NEG'] = int(decimal(self.values['E']) < 0)
        self.numbers['COUNT'] = self.number(parsed[2])
        self.numbers['WIDTH'] = self.number(parsed[3])
        if form == 'if':
            parsed = re.fullmatch(r'NEG\) begin:choice(.*?)end else begin:choice(.*?)end\s*', generation, re.S)
        else:
            parsed = re.fullmatch(r'NEG\)\s*1: begin:choice(.*?)end\s*default: begin:choice(.*?)end\s*endcase\s*', generation, re.S)
        assert parsed, 'unsupported generate selection'
        body = parsed[1] if self.numbers['NEG'] else parsed[2]
        parsed = re.fullmatch(r'\s*localparam int KIND=(\d+), TAG=(\d+);'
                              r'\s*for \(genvar lane=0; lane<([^;]+); lane\+\+\) begin:g'
                              r'\s*typedef (bit|logic) \[([^]]+):0\] word_t;\s*word_t raw, guard;'
                              r'\s*wire \[([^]]+):0\] value;\s*assign value=(.*?);\s*end\s*', body, re.S)
        assert parsed, 'unsupported generated element'
        kind, tag, limit, state, high, wire_high, self.assignment = parsed.groups()
        self.numbers.update(KIND=int(kind), TAG=int(tag))
        count = self.number(limit)
        assert 0 < count <= 4
        self.elements = {}
        for lane in range(count):
            env = {**self.numbers, 'lane': lane}
            word = Type(integer(high, env) + 1, state, False)
            assert word.width == integer(wire_high, env) + 1 and word.width > 0
            self.elements[lane] = {'type': word, 'raw': initial_value(word), 'guard': initial_value(word)}

    def number(self, source):
        source = re.sub(r"int'\(E\[([^]]+)\]\)",
                        lambda m: str((self.values['E'].bits >> integer(m[1], self.numbers)) & 1), source)
        source = re.sub(r'\$bits\(([ABE])\)', lambda m: str(self.values[m[1]].width), source)
        return integer(source, self.numbers)

    def expression(self, source, context=None):
        source = source.strip()
        if source in self.values: return self.values[source]
        if source in ("'1", "'0"):
            assert context
            return Value(context.width, (1 << context.width) - 1 if source == "'1" else 0, signed=context.signed)
        cast = re.fullmatch(r"(\w+)'\((\d+)\)", source)
        if cast:
            return Value(32, int(cast[2]), signed=True).convert(self.types[cast[1]])
        shift = re.fullmatch(r"(\w+'\(\d+\)) << \(([^)]+)\)", source)
        if shift:
            word = self.expression(shift[1]); amount = integer(shift[2], self.numbers)
            return Value(word.width, (word.bits << amount) & ((1 << word.width) - 1), signed=word.signed)
        conditional = re.fullmatch(r'SELECT \? (.+) : (.+)', source)
        binary = re.fullmatch(r'(A) ([+^]) (B)', source)
        assert conditional or binary, ('unsupported typed expression', source)
        a, b = (self.expression(part) for part in conditional.groups()) if conditional else (self.values['A'], self.values['B'])
        width = max(a.width, b.width, context.width if context else 0)
        common_signed = a.signed and b.signed
        def extend(value):
            return Value(value.width, value.bits, signed=common_signed).convert(Type(width, 'logic', common_signed)).bits
        aa, bb = extend(a), extend(b)
        value = (aa if self.numbers['SELECT'] else bb) if conditional else aa + bb if binary[2] == '+' else aa ^ bb
        return Value(width, value & ((1 << width) - 1), signed=common_signed)

    def output(self, lane):
        element = self.elements[lane]
        parsed = re.fullmatch(r"raw \^ word_t'\(([^)]+)\)", self.assignment)
        assert parsed, 'unsupported continuous assignment'
        tag = integer(parsed[1], {**self.numbers, 'lane': lane})
        return xor(element['raw'], Value(element['type'].width, tag & ((1 << element['type'].width) - 1)))


def interpret(source):
    code = re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*', '', source, flags=re.S)
    parsed = re.fullmatch(r'\s*module shape_worker #\(parameter int SELECT=0\);(.*?)endmodule\s*module \w+;(.*?)endmodule\s*', code, re.S)
    assert parsed, 'unsupported compilation-unit structure'
    definition, top = parsed.groups()
    workers = {}
    for parameter, name in re.findall(r'shape_worker #\((.*?)\) (\w+)\(\);', top):
        match = re.fullmatch(r'(?:\.SELECT\((\d+)\)|(\d+))', parameter)
        assert match and name not in workers
        workers[name] = Worker(definition, int(match[1] or match[2]))
    top = re.sub(r'shape_worker #\(.*?\) \w+\(\);', '', top, flags=re.S)
    parsed = re.fullmatch(r'\s*initial begin(.*?)\$finish;\s*end\s*', top, re.S)
    assert parsed and set(workers) == {'a', 'b'}
    lines = []

    def member(text):
        parsed = re.fullmatch(r'([ab])\.choice\.g\[(\d+)\]\.(raw|guard|value)', text.strip())
        assert parsed, ('unsupported member', text)
        owner, lane, field = parsed.groups()
        worker = workers[owner]; lane = int(lane)
        assert lane in worker.elements, 'unelaborated generated element'
        return worker, lane, field

    def expression(text):
        text = text.strip()
        if ' ^ ' in text:
            a, b = text.split(' ^ ')
            return xor(expression(a), expression(b))
        query = re.fullmatch(r'\$bits\((.+)\)', text)
        if query:
            value = expression(query[1]); assert isinstance(value, Value)
            return value.width
        const = re.fullmatch(r'([ab])\.(A|B|E|NEG|COUNT|WIDTH|choice.KIND)', text)
        if const:
            owner, name = const.groups(); worker = workers[owner]
            return worker.values[name] if name in worker.values else worker.numbers[name.split('.')[-1]]
        if '.choice.g[' in text:
            worker, lane, field = member(text)
            return worker.output(lane) if field == 'value' else worker.elements[lane][field]
        return literal(text)

    for statement in (s.strip() for s in parsed[1].split(';') if s.strip()):
        if re.fullmatch(r'#1', statement): continue
        display = re.fullmatch(r'\$display\("([^"\n]*)",\s*(.*)\)', statement, re.S)
        if display:
            fmt, args = display.groups(); args = iter(split_arguments(args))
            def replace(match):
                value = expression(next(args))
                if match[0] == '%b':
                    assert isinstance(value, Value)
                    return value.binary()
                return str(decimal(value) if isinstance(value, Value) else value)
            lines.append(re.sub(r'%b|%0d', replace, fmt)); assert list(args) == []
            continue
        write = re.fullmatch(r'(.+?)=(.*)', statement, re.S)
        assert write, ('unsupported top statement', statement)
        target, rhs = write.groups(); worker, lane, field = member(target)
        assert field in ('raw', 'guard')
        worker.elements[lane][field] = expression(rhs).convert(worker.elements[lane]['type'])
    return '\n'.join(lines) + '\n'


def independent(row):
    return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[i]) for name, i in
                (('scalar', 0), ('conditional_z', 1), ('xor_x', 2), ('xor_bit_z', 3), ('mixed_add', 4))}
    faults = (
        ('wrong_operand_sign', 'conditional_z', [('logic unsigned [BASE-1:0] right_t', 'logic signed [BASE-1:0] right_t')]),
        ('wrong_result_sign', 'mixed_add', [('logic signed [CW-1:0] result_t', 'logic unsigned [CW-1:0] result_t')]),
        ('lost_context_width', 'conditional_z', [('CW=130', 'CW=129')]),
        ('wrong_expression', 'conditional_z', [('E = SELECT ? A : B', 'E = A + B')]),
        ('wrong_bits_query', 'conditional_z', [('$bits(E)%3', '$bits(A)%3')]),
        ('wrong_branch_tag', 'conditional_z', [('KIND=0, TAG=5', 'KIND=0, TAG=6')]),
        ('wrong_binding', 'mixed_add', [('#(.SELECT(1)) b()', '#(.SELECT(0)) b()')]),
        ('wrong_continuous_mask', 'xor_x', [('TAG+lane', 'TAG')]),
        ('wrong_element_write', 'scalar', [('a.choice.g[0].raw=a.choice.g[0].raw', 'a.choice.g[1].raw=a.choice.g[0].raw')]),
    )
    programs = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, edits in faults:
        source = controls[parent].body
        for old, new in edits:
            assert old in source, (name, old)
            source = source.replace(old, new)
        assert interpret(source) != controls[parent].expected, name
        programs[name] = parent, source, 'fault'
    return controls, programs


def runtime(executable, directory):
    import common
    controls, programs = variants(); records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]; source, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = source.replace(case.body.strip('\n'), body.strip('\n'))
        original = ROOT / 'tests/gen/ch27' / (case.name + '.sv')
        folder = directory / name; folder.mkdir(); path = folder / original.name
        path.write_text(source); path.with_suffix('.expected').write_text(case.expected)
        calls, run = [], subprocess.run
        def capture(*args, **kwargs):
            result = run(*args, **kwargs)
            if args[0][0] == executable: calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture): status, reason = run_kirimasim.run(path, executable)
        assert len(calls) == 1 and calls[0].returncode == 0, (name, status, reason)
        assert status == ('pass' if kind == 'control' else 'fail'), (name, status, reason)
        if kind == 'fault': assert reason.startswith('output differs'), (name, reason)
        normalized = run([sys.executable, str(run_kirimasim.NORMALIZE)], input=calls[0].stdout, text=True, capture_output=True, check=True).stdout
        records[name] = {'kind': kind, 'control': parent, 'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(), 'original_test': original.relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(original), 'expected_stdout': case.expected,
                         'stdout': normalized, 'stderr': calls[0].stderr.replace(str(folder), '<case>'), 'returncode': 0}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', required=True, type=Path); args = parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')
    files = ('generators/interaction_genexpr.py', 'generators/interaction_class_import.py', 'generators/interaction_cond.py',
             'generators/interaction_genloop.py', 'generators/interaction_cover.py', 'generators/common.py',
             'tools/qualify_genexpr.py', 'tools/qualify_class_import.py', 'tools/qualify_genloop.py', 'tools/qualify_gensub.py', 'tools/qualify_ifquery.py')
    def hashes(): return {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}
    sources = hashes(); runner = suite_results.runner_digest('kirimasim'); binary = Path(args.kirimasim).resolve()
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    paths = [ROOT / 'tests/gen/ch27' / (generator.case_name(row) + '.sv') for row in generator.MODEL.select()]
    inputs = {p: suite_results.input_digest(p) for p in paths}; evidence = hashlib.sha256()
    for row in generator.MODEL.rows():
        source, expected = generator.source(row), generator.reference(row)
        assert interpret(source) == expected, row
        evidence.update(source.encode() + b'\0' + expected.encode() + b'\0')
    with tempfile.TemporaryDirectory() as tmp: executions = runtime(str(binary), Path(tmp))
    assert hashes() == sources and runner == suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(p) == v for p, v in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == before
    result = {'model': generator.MODEL.name, 'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Independent bounded typed-constant evaluation, elaboration and actual SV interpretation; auxiliary runs are not fixed or coverage passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths), 'source_and_expectation_sha256': evidence.hexdigest(),
              'source_sha256': sources, 'runner_sha256': runner, 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True, 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; native controls: 5; detected SV faults: 9')


if __name__ == '__main__': main()
