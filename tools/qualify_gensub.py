#!/usr/bin/env python3
"""Independently elaborate and interpret bounded generated-subroutine SV."""

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
from qualify_genenum import integer
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_gensub as generator


def index(text, env):
    return int(text) if re.fullmatch(r'-?\d+', text.strip()) else integer(text, env)


def xor(left, right):
    width, signed = max(left.width, right.width), left.signed and right.signed
    # Mixed-sign operands use the common unsigned type before extending.
    left = Value(left.width, left.bits, left.x, left.z, signed).convert(Type(width, 'logic', signed))
    right = Value(right.width, right.bits, right.x, right.z, signed).convert(Type(width, 'logic', signed))
    mask = (1 << left.width) - 1
    unknown = left.x | left.z | right.x | right.z
    return Value(left.width, (left.bits ^ right.bits) & ~unknown & mask, unknown, 0,
                 left.signed and right.signed)


class Scope:
    def __init__(self, source, constants):
        self.constants = dict(constants)
        head, separator, method = re.split(r'\b(function|task) automatic ', source, maxsplit=1)
        for name, expression in re.findall(r'localparam int (\w+)\s*=\s*([^;]+);', head):
            assert name not in self.constants
            self.constants[name] = integer(expression, self.constants)
        assert set(self.constants) == {'BASE', 'SEL', 'lane', 'KIND', 'W', 'LEFT', 'RIGHT', 'TAG'}
        head = re.sub(r'localparam int \w+\s*=\s*[^;]+;', '', head)
        parsed = re.fullmatch(r'\s*typedef (bit|logic)\s*(signed\s+)?\[([^:]+):([^]]+)\] word_t;'
                              r'\s*word_t data\[([^:]+):([^]]+)\];\s*', head)
        assert parsed, 'unsupported generated declarations'
        state, signed, high, low, left, right = parsed.groups()
        high, low = integer(high, self.constants), integer(low, self.constants)
        assert low == 0 and high >= 0
        self.word = Type(high + 1, state, bool(signed))
        self.left, self.right = integer(left, self.constants), integer(right, self.constants)
        assert abs(self.left - self.right) == 1, 'only two-element arrays are supported'
        self.data = {i: initial_value(self.word) for i in range(min(self.left, self.right), max(self.left, self.right) + 1)}
        self.task = separator == 'task'
        signature = (r'step\(output word_t previous, input word_t arg = ([^)]+)\);(.*?)endtask\s*'
                     if self.task else r'word_t step\(input word_t arg = ([^)]+)\);(.*?)endfunction\s*')
        match = re.fullmatch(signature, method, re.S)
        assert match, 'unsupported generated routine'
        self.default, body = match.groups()
        assert re.match(r'\s*word_t saved;', body)
        body = re.sub(r'^\s*word_t saved;', '', body)
        self.statements = [s.strip() for s in body.split(';') if s.strip()]

    def expression(self, source, frame):
        source = source.strip()
        if source in frame: return frame[source]
        field = re.fullmatch(r'data\[([^]]+)\]', source)
        if field:
            selected = index(field[1], self.constants)
            assert selected in self.data
            return self.data[selected]
        cast = re.fullmatch(r"word_t'\((.*?)\)", source)
        if cast:
            value = integer(cast[1], self.constants)
            return Value(32, value & ((1 << 32) - 1), signed=True).convert(self.word)
        parts = source.split('^')
        if len(parts) == 2: return xor(self.expression(parts[0], frame), self.expression(parts[1], frame))
        assert len(parts) == 1
        return literal(source)

    def invoke(self, argument, task):
        assert self.task == task, 'wrong routine calling convention'
        frame = {'saved': initial_value(self.word), 'previous': initial_value(self.word)}
        frame['arg'] = (self.expression(self.default, {}) if argument is None else argument).convert(self.word)
        result = None
        for number, statement in enumerate(self.statements):
            if statement.startswith('return '):
                assert not task and number == len(self.statements) - 1
                result = self.expression(statement[7:], frame).convert(self.word)
                continue
            match = re.fullmatch(r'(saved|previous|data\[[^]]+\])\s*=\s*(.*)', statement, re.S)
            assert match, ('unsupported routine statement', statement)
            target, rhs = match.groups()
            value = self.expression(rhs, frame).convert(self.word)
            if target.startswith('data['):
                selected = index(target[5:-1], self.constants)
                assert selected in self.data
                self.data[selected] = value
            else:
                frame[target] = value
        assert task or result is not None
        return frame['previous'] if task else result


def interpret(source):
    """Read actual declarations/calls; never infer behavior from row metadata."""
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    whole = re.fullmatch(r'\s*module generated_worker #\(parameter int BASE = 1, parameter int SEL = 0\);'
                         r'\s*for \(genvar lane = 0; lane < 2; lane\+\+\) begin : g(.*?)'
                         r'\bend\s*endmodule\s*module \w+;(.*?)endmodule\s*', code, re.S)
    assert whole, 'unsupported worker/module structure'
    branches, top = whole.groups()
    conditional = re.fullmatch(r'\s*if\s*\((.*?)\)\s*begin : slot(.*?)\bend\s*else begin : slot(.*?)\bend\s*', branches, re.S)
    case = re.fullmatch(r'\s*case\s*\((.*?)\)\s*0: begin : slot(.*?)\bend\s*default: begin : slot(.*?)\bend\s*endcase\s*', branches, re.S)
    assert bool(conditional) != bool(case)
    condition, zero, one = (conditional or case).groups()
    instances = re.findall(r'generated_worker #\(\.BASE\((\d+)\), \.SEL\((\d+)\)\) ([ab])\(\);', top)
    assert len(instances) == 2 and {p[2] for p in instances} == {'a', 'b'}
    scopes = {}
    for base, selector, name in instances:
        for lane in range(2):
            env = {'BASE': int(base), 'SEL': int(selector), 'lane': lane}
            choose_zero = bool(integer(condition, env)) if conditional else integer(condition, env) == 0
            scopes[f'{name}.g[{lane}].slot'] = Scope(zero if choose_zero else one, env)
    top = re.sub(r'generated_worker #\(\.BASE\(\d+\), \.SEL\(\d+\)\) [ab]\(\);', '', top)
    match = re.fullmatch(r'\s*logic \[(\d+):0\] drive;\s*logic \[(\d+):0\] r0, r1, r2, r3;'
                         r'\s*initial begin(.*?)\bend\s*', top, re.S)
    assert match, 'unsupported producer structure'
    drive_high, result_high, program = match.groups()
    types = {'drive': Type(int(drive_high) + 1, 'logic', False)}
    types.update({f'r{i}': Type(int(result_high) + 1, 'logic', False) for i in range(4)})
    values = {name: initial_value(kind) for name, kind in types.items()}

    def array(source):
        field = re.fullmatch(r'([ab]\.g\[[01]\]\.slot)\.data\[(-?\d+)\]', source.strip())
        assert field, ('unsupported array expression', source)
        scope, at = scopes[field[1]], int(field[2])
        assert at in scope.data
        return scope, at

    def expression(source, target_type=None):
        source = source.strip()
        if source in values: return values[source]
        if source in ("'0", "'1", "'x", "'z"):
            assert target_type
            mask = (1 << target_type.width) - 1
            return Value(target_type.width, mask if source == "'1" else 0,
                         mask if source == "'x" else 0, mask if source == "'z" else 0).convert(target_type)
        parts = source.split('^')
        if len(parts) == 2: return xor(expression(parts[0]), expression(parts[1]))
        assert len(parts) == 1
        query = re.fullmatch(r'\$(left|right|bits)\((.*?)\)', source)
        if query:
            kind, operand = query.groups()
            if kind == 'bits': return array(operand)[0].word.width
            assert operand.endswith('.data')
            scope = scopes[operand[:-5]]
            return scope.left if kind == 'left' else scope.right
        constant = re.fullmatch(r'([ab]\.g\[[01]\]\.slot)\.(TAG|W|LEFT|RIGHT|KIND)', source)
        if constant: return scopes[constant[1]].constants[constant[2]]
        call = re.fullmatch(r'([ab]\.g\[[01]\]\.slot)\.step\((.*?)\)', source)
        if call:
            return scopes[call[1]].invoke(expression(call[2]) if call[2].strip() else None, task=False)
        if '.data[' in source:
            scope, at = array(source); return scope.data[at]
        return literal(source)

    def assign(target, value):
        if target in values: values[target] = value.convert(types[target])
        else:
            scope, at = array(target); scope.data[at] = value.convert(scope.word)

    output = []
    statements = [item.strip() for item in program.split(';') if item.strip()]
    assert statements[-1] == '$finish'
    for statement in statements[:-1]:
        display = re.fullmatch(r'\$(write|display)\("([^"]*)",\s*(.*?)\)', statement, re.S)
        if display:
            operation, fmt, args = display.groups()
            args = iter(expression(arg) for arg in args.split(','))
            def render(token):
                value = next(args)
                if token[0] == '%b':
                    assert isinstance(value, Value)
                    return value.binary()
                assert isinstance(value, int)
                return str(value)
            text = re.sub(r'%b|%0d', render, fmt)
            assert next(args, None) is None
            output.append(text + ('\n' if operation == 'display' else ''))
            continue
        task = re.fullmatch(r'([ab]\.g\[[01]\]\.slot)\.step\((r[0-3])(?:,\s*(.*?))?\)', statement)
        if task:
            scope, result, arg = task.groups()
            assign(result, scopes[scope].invoke(expression(arg) if arg else None, task=True))
            continue
        write = re.fullmatch(r'(.*?)\s*=\s*(.*)', statement, re.S)
        assert write, ('unsupported producer statement', statement)
        target, rhs = write.groups()
        kind = types[target] if target in types else array(target)[0].word
        assign(target, expression(rhs, kind))
    return ''.join(output)


def independent(row):
    return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index]) for name, index in
                (('scalar', 0), ('signed_z', 1), ('explicit_x', 2), ('task', 4))}
    faults = (
        ('wrong_scope_constant', 'scalar', 'TAG = 1 + lane + lane + KIND;', 'TAG = 1 + KIND;'),
        ('wrong_default_element', 'scalar', 'arg = data[LEFT]', 'arg = data[RIGHT]'),
        ('wrong_write_element', 'scalar', 'data[LEFT] = arg ^', 'data[RIGHT] = arg ^'),
        ('wrong_function_capture', 'scalar', 'return saved;', 'return data[LEFT];'),
        ('wrong_task_copyout', 'task', 'previous = saved;', 'previous = data[LEFT];'),
        ('lost_signed_return', 'signed_z', 'typedef logic signed [W-1:0]', 'typedef logic [W-1:0]'),
        ('wrong_generated_width', 'signed_z', 'W = BASE + lane + KIND;', 'W = BASE;'),
        ('wrong_called_scope', 'scalar', 'r0 = a.g[0].slot.step();', 'r0 = b.g[0].slot.step();'),
        ('reversed_array_range', 'scalar', 'data[LEFT:RIGHT]', 'data[RIGHT:LEFT]'),
    )
    programs = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, old, new in faults:
        source = controls[parent].body
        assert old in source, name
        mutant = source.replace(old, new, 1)
        assert interpret(mutant) != controls[parent].expected, name
        programs[name] = (parent, mutant, 'fault')
    return controls, programs


def runtime(executable, directory):
    import common
    controls, programs = variants()
    records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]
        source, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = source.replace(case.body.strip('\n'), body.strip('\n'))
        original = ROOT / 'tests/gen/ch27' / (case.name + '.sv')
        folder = directory / name; folder.mkdir()
        path = folder / original.name; path.write_text(source)
        path.with_suffix('.expected').write_text(case.expected)
        calls = []; run = subprocess.run
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
    files = ('generators/interaction_gensub.py', 'generators/interaction_class_import.py',
             'generators/interaction_cond.py', 'generators/common.py', 'tools/qualify_gensub.py',
             'tools/qualify_class_import.py', 'tools/qualify_genenum.py')
    def hashes(): return {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}
    sources = hashes(); runner = suite_results.runner_digest('kirimasim')
    paths = [ROOT / 'tests/gen/ch27' / (generator.case_name(row) + '.sv') for row in generator.MODEL.select()]
    inputs = {p: suite_results.input_digest(p) for p in paths}
    binary = Path(args.kirimasim).resolve(); before = hashlib.sha256(binary.read_bytes()).hexdigest()
    evidence = hashlib.sha256()
    for row in generator.MODEL.rows():
        source, expected = generator.source(row), generator.reference(row)
        assert interpret(source) == expected, row
        evidence.update(source.encode() + b'\0' + expected.encode() + b'\0')
    with tempfile.TemporaryDirectory() as temporary:
        executions = runtime(str(binary), Path(temporary))
    assert hashes() == sources and suite_results.runner_digest('kirimasim') == runner
    assert all(suite_results.input_digest(p) == digest for p, digest in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == before
    result = {'model': generator.MODEL.name, 'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Bounded elaboration and interpretation of actual generated SV; controls/faults are auxiliary, not additional fixed or coverage passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths),
              'source_and_expectation_sha256': evidence.hexdigest(), 'source_sha256': sources,
              'runner_sha256': runner, 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True,
              'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; native controls: 4; detected SV faults: 9')


if __name__ == '__main__':
    main()
