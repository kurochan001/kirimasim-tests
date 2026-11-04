#!/usr/bin/env python3
"""Interpret bounded class/import SV independently and execute real SV faults."""

import argparse
from dataclasses import dataclass
import datetime
import hashlib
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
import interaction_class_import as generator


@dataclass(frozen=True)
class Type:
    width: int
    state: str
    signed: bool


@dataclass(frozen=True)
class Value:
    width: int
    bits: int = 0
    x: int = 0
    z: int = 0
    signed: bool = False

    def convert(self, target):
        mask = (1 << target.width) - 1
        bits, x, z = self.bits, self.x, self.z
        if self.signed and target.width > self.width:
            extension = mask ^ ((1 << self.width) - 1)
            sign = 1 << (self.width - 1)
            if bits & sign: bits |= extension
            elif x & sign: x |= extension
            elif z & sign: z |= extension
        if target.state == 'bit':
            bits &= ~(x | z)
            x = z = 0
        return Value(target.width, bits & mask, x & mask, z & mask, target.signed)

    def binary(self):
        return ''.join('x' if self.x & (1 << i) else 'z' if self.z & (1 << i)
                       else str((self.bits >> i) & 1) for i in reversed(range(self.width)))


def literal(text):
    text = text.strip()
    if text.startswith('{') and text.endswith('}'):
        words = [literal(part) for part in text[1:-1].split(',')]
        width = bits = x = z = 0
        for value in words:
            width += value.width
            bits = (bits << value.width) | value.bits
            x = (x << value.width) | value.x
            z = (z << value.width) | value.z
        return Value(width, bits, x, z)
    match = re.fullmatch(r"(\d+)'([bh])([0-9a-fxz]+)", text, re.I)
    assert match, ('unsupported literal', text)
    width, base, digits = match.groups()
    # Emitted unknown literals use exact-size binary chunks. Reject other
    # unknown spellings instead of guessing their unsized-digit extension.
    if base.lower() == 'b':
        assert set(digits.lower()) <= set('01xz') and len(digits) == int(width)
    else:
        assert set(digits.lower()) <= set('0123456789abcdef')
    assert int(width) > 0
    bits = x = z = 0
    step = 1 if base.lower() == 'b' else 4
    for digit in digits.lower():
        bits <<= step; x <<= step; z <<= step
        if digit == 'x': x |= (1 << step) - 1
        elif digit == 'z': z |= (1 << step) - 1
        else: bits |= int(digit, 2 if step == 1 else 16)
    return Value(max(int(width), step * len(digits)), bits, x, z).convert(Type(int(width), 'logic', False))


TYPE = r'(bit|logic)\s*(signed\s+)?\[(\d+):0\]'


def parsed_type(state, sign, top):
    return Type(int(top) + 1, state, bool(sign))


def initial_value(kind):
    return Value(kind.width, x=(1 << kind.width) - 1 if kind.state == 'logic' else 0,
                 signed=kind.signed)


def interpret(source):
    """Read declarations, lexical imports, handles and typed writes from actual SV.

    This is an interpreter for the deliberately bounded emitted grammar, not a
    general compiler. It never uses generator parameters or reference helpers.
    """
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    packages = {}
    for name, body in re.findall(r'package (\w+);(.*?)endpackage', code, re.S):
        match = re.fullmatch(r'\s*typedef\s+' + TYPE + r'\s+source_t;\s*source_t data;\s*', body)
        assert match, 'unsupported package body'
        assert name not in packages
        kind = parsed_type(*match.groups())
        packages[name] = [kind, initial_value(kind)]
    assert set(packages) == {'source_pkg', 'outer_pkg'}
    module = re.sub(r'package \w+;.*?endpackage', '', code, flags=re.S)
    match = re.fullmatch(
        r'\s*module \w+;\s*import (\w+)::\*;\s*typedef\s+' + TYPE +
        r'\s+word_t;\s*class box_t;(.*?)endclass\s*box_t a, old, b;'
        r'\s*word_t ra, rr, rb;\s*initial begin(.*?)end\s*endmodule\s*', module, re.S)
    assert match, 'unsupported module structure'
    outer, state, sign, top, body, program = match.groups()
    assert outer in packages
    word = parsed_type(state, sign, top)
    methods = {}
    pattern = (r'(function automatic word_t (\w+)\(\);(.*?)endfunction|'
               r'task automatic (\w+)\(output word_t result\);(.*?)endtask)')
    for found in re.finditer(pattern, body, re.S):
        function, name, statements, task_name, task_statements = found.groups()
        is_task = task_name is not None
        if is_task: name, statements = task_name, task_statements
        parsed = re.fullmatch(r'\s*(?:import (\w+)::(\*|data);)?\s*' +
                              (r'result\s*=\s*' if is_task else r'return\s+') +
                              r'([\w:.]+);\s*', statements)
        assert parsed, 'unsupported method statements'
        imported, _, expression = parsed.groups()
        assert imported is None or imported in packages
        assert name not in methods
        methods[name] = (is_task, imported, expression)
    leftovers = re.sub(pattern, '', body, flags=re.S)
    assert re.fullmatch(r'\s*word_t data;\s*', leftovers)
    assert set(methods) == {'sample', 'local_read'}
    handles, objects, variables = {}, [], {}

    def expression(text, owner=None, imported=None):
        text = text.strip()
        if re.fullmatch(r'a\s*==\s*old', text):
            return Value(1, int(handles['a'] == handles['old']))
        if text == 'this.data':
            assert owner is not None
            return objects[owner]
        if text == 'data':
            if owner is not None and imported is None: return objects[owner]
            return packages[imported if imported is not None else outer][1]
        if text in ('source_pkg::data', 'outer_pkg::data'):
            return packages[text.split('::')[0]][1]
        if text in variables: return variables[text]
        call = re.fullmatch(r'(a|old|b)\.(sample|local_read)\(\)', text)
        if call: return invoke(*call.groups(), task=False)
        field = re.fullmatch(r'(a|old|b)\.data', text)
        if field: return objects[handles[field[1]]]
        return literal(text)

    def invoke(handle, method, task):
        is_task, imported, expr = methods[method]
        assert is_task == task, 'wrong method calling convention'
        return expression(expr, handles[handle], imported).convert(word)

    output = []
    statements = [statement.strip() for statement in program.split(';') if statement.strip()]
    assert statements[-1] == '$finish'
    for statement in statements[:-1]:
        display = re.fullmatch(r'\$(write|display)\("([^"]*)",\s*(.*?)\)', statement, re.S)
        if display:
            operation, fmt, args = display.groups()
            args = iter(expression(item.strip()) for item in args.split(','))
            def render(token):
                value = next(args)
                if token[0] == '%b': return value.binary()
                assert value.x == value.z == 0
                return str(value.bits)
            text = re.sub(r'%b|%0d', render, fmt)
            assert next(args, None) is None
            output.append(text + ('\n' if operation == 'display' else ''))
            continue
        task = re.fullmatch(r'(a|old|b)\.sample\((ra|rr|rb)\)', statement)
        if task:
            variables[task[2]] = invoke(task[1], 'sample', task=True)
            continue
        write = re.fullmatch(r'([\w:.]+)\s*=\s*(.*)', statement, re.S)
        assert write, ('unsupported statement', statement)
        target, rhs = write.groups(); rhs = rhs.strip()
        if target in ('a', 'old', 'b'):
            if rhs == 'new':
                handles[target] = len(objects); objects.append(initial_value(word))
            else:
                assert rhs in handles
                handles[target] = handles[rhs]
        elif target in ('source_pkg::data', 'outer_pkg::data'):
            package = packages[target.split('::')[0]]
            package[1] = expression(rhs).convert(package[0])
        elif target in ('a.data', 'old.data', 'b.data'):
            objects[handles[target.split('.')[0]]] = expression(rhs).convert(word)
        else:
            assert target in ('ra', 'rr', 'rb')
            variables[target] = expression(rhs).convert(word)
    return ''.join(output)


def independent(row):
    return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index])
                for name, index in (('scalar', 0), ('signed_wide', 1), ('logic_x', 2), ('member', 3))}
    faults = (
        ('wrong_inner_package', 'scalar', 'import source_pkg::*;', 'import outer_pkg::*;'),
        ('property_instead_of_import', 'scalar', 'return data;', 'return this.data;'),
        ('wrong_alias', 'scalar', 'old = a;', 'old = b;'),
        ('wrong_plain_method', 'logic_x', 'word_t local_read();\n      return data;',
         'word_t local_read();\n      return source_pkg::data;'),
        ('lost_sign_extension', 'signed_wide', 'logic signed [127:0]', 'logic [127:0]'),
        ('wrong_source_width', 'signed_wide', 'logic signed [127:0]', 'logic signed [126:0]'),
        ('lost_four_state', 'logic_x', 'logic [65:0]', 'bit [65:0]'),
        ('leaked_method_import', 'scalar', 'import outer_pkg::*;', 'import source_pkg::*;'),
    )
    result = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, old, new in faults:
        source = controls[parent].body
        assert old in source, name
        mutant = source.replace(old, new, 1)
        assert interpret(mutant) != controls[parent].expected, name
        result[name] = (parent, mutant, 'fault')
    return controls, result


def runtime(executable, directory):
    controls, programs = variants()
    results = {}
    sys.path.insert(0, str(ROOT / 'generators'))
    import common
    for name, (parent, source, kind) in programs.items():
        case = controls[parent]
        original = ROOT / 'tests/gen/ch26' / (case.name + '.sv')
        header, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = header.replace(case.body.strip('\n'), source.strip('\n'))
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
        observed = run([sys.executable, str(run_kirimasim.NORMALIZE)], input=calls[0].stdout,
                       capture_output=True, text=True, check=True).stdout
        results[name] = {'kind': kind, 'control': parent, 'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                         'original_test': original.relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(original),
                         'expected_stdout': case.expected, 'stdout': observed,
                         'stderr': calls[0].stderr.replace(str(folder), '<case>'), 'returncode': 0}
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve existing qualification evidence')
    binary = Path(args.kirimasim).resolve()
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    evidence = hashlib.sha256()
    for row in generator.MODEL.rows():
        source, expected = generator.source(row), generator.reference(row)
        assert interpret(source) == expected, row
        evidence.update(source.encode() + b'\0' + expected.encode() + b'\0')
    with tempfile.TemporaryDirectory() as temp:
        executions = runtime(str(binary), Path(temp))
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == before
    result = {'model': generator.MODEL.name, 'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Bounded actual-SV interpretation and independent execution controls; not additional suite passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(generator.MODEL.select()),
              'source_and_expectation_sha256': evidence.hexdigest(), 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'source_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in
                  ('generators/interaction_class_import.py', 'tools/qualify_class_import.py')},
              'runner_sha256': suite_results.runner_digest('kirimasim'), 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; controls: 4; detected SV faults: 8')


if __name__ == '__main__':
    main()
