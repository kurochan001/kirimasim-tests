#!/usr/bin/env python3
"""Interpret saved scan programs, field stopping and lvalue writes independently."""

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

from qualify_class_import import Type, Value, literal
from qualify_gensub import xor
from qualify_ifquery import split_arguments
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_scansel as generator


def region(text, types):
    """Resolve an actual whole or indexed part-select lvalue, without row data."""
    m = re.fullmatch(r'(a|b|wa|wb)(?:\[(\d+) ([+-]): (\d+)\])?', text.strip())
    assert m, ('unsupported lvalue', text)
    name, base, direction, width = m.groups()
    if base is None: return name, 0, types[name].width
    base, width = int(base), int(width)
    low = base if direction == '+' else base - width + 1
    assert width > 0 and 0 <= low and low + width <= types[name].width
    return name, low, width


def view(target, types, values):
    name, low, width = region(target, types)
    value = values[name]; mask = (1 << width) - 1
    return Value(width, (value.bits >> low) & mask, (value.x >> low) & mask, (value.z >> low) & mask)


def store(target, value, types, values):
    name, low, width = region(target, types)
    word = types[name]; value = value.convert(Type(width, word.state, False))
    mask = ((1 << width) - 1) << low; previous = values[name]
    values[name] = Value(word.width, (previous.bits & ~mask) | (value.bits << low),
                        (previous.x & ~mask) | (value.x << low), (previous.z & ~mask) | (value.z << low))


def digits(text, radix):
    """Keep leading zeroes and X/Z planes while decoding the actual consumed token."""
    assert text
    step = 1 if radix == 'b' else 4
    bits = x = z = 0
    for char in text:
        bits <<= step; x <<= step; z <<= step
        if char == 'x': x |= (1 << step) - 1
        elif char == 'z': z |= (1 << step) - 1
        else: bits |= int(char, 2 if radix == 'b' else 16)
    return Value(len(text) * step, bits, x, z)


def scan(text, fmt, outputs, types, values, numbers):
    """A bounded sequential scanner: stop at the first failed literal/conversion."""
    assert re.fullmatch(r'%\d+[bh]\|%b\|%d', fmt), 'unsupported scan format'
    assert len(outputs) == 3 and outputs[2] == 'tag'
    cursor = assigned = at = 0
    while at < len(fmt):
        if fmt[at] != '%':
            if cursor == len(text) or text[cursor] != fmt[at]: return assigned
            cursor += 1; at += 1; continue
        conversion = re.match(r'%(\d*)([bhd])', fmt[at:]); assert conversion
        maximum, code = conversion.groups(); at += conversion.end()
        if cursor == len(text): return assigned if assigned else -1
        available = text[cursor:cursor + int(maximum)] if maximum else text[cursor:]
        pattern = '[01xz]+' if code == 'b' else '[0-9a-fxz]+' if code == 'h' else '[+-]?[0-9]+'
        token = re.match(pattern, available)
        if not token: return assigned
        consumed = token[0]; cursor += len(consumed)
        target = outputs[assigned]
        if code == 'd':
            assert target == 'tag'; numbers[target] = int(consumed)
        else:
            value = digits(consumed, code)
            # The emitted based tokens contain at least the destination width.
            # Do not guess the leading-X/Z extension rule outside this scope.
            assert not (value.x or value.z) or value.width >= region(target, types)[2]
            store(target, value, types, values)
        assigned += 1
    return assigned


def string_expression(text):
    text = text.strip()
    if text.startswith('{') and text.endswith('}'):
        return ''.join(string_expression(part) for part in split_arguments(text[1:-1]))
    match = re.fullmatch(r'"([^"\\]*)"', text, re.S)
    assert match, ('unsupported string literal', text)
    return match[1]


def formatted(fmt, args):
    args = iter(args)
    def replace(match):
        if match[0] == '%%': return '%'
        value = next(args)
        if match[0] == '%b':
            assert isinstance(value, Value)
            return value.binary()
        if match[0] == '%s':
            assert isinstance(value, str)
            return value
        assert isinstance(value, int)
        return str(value)
    result = re.sub(r'%%|%0d|%b|%s', replace, fmt)
    assert list(args) == []
    return result


def interpret(source):
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    parsed = re.fullmatch(r'\s*module \w+;(.*?)initial begin(.*?)\$finish;\s*end\s*endmodule\s*', code, re.S)
    assert parsed, 'unsupported compilation-unit structure'
    declarations, program = parsed.groups(); types = {}
    for state, high, name in re.findall(r'(bit|logic) \[(\d+):0\] (\w+);', declarations):
        assert name not in types
        types[name] = Type(int(high) + 1, state, False)
    rest = re.sub(r'(bit|logic) \[\d+:0\] \w+;', '', declarations)
    assert re.fullmatch(r'\s*string fmt, text;\s*int rc, tag;\s*', rest)
    assert set(types) == {'a', 'b', 'wa', 'wb'}
    values = {name: Value(kind.width, x=(1 << kind.width) - 1 if kind.state == 'logic' else 0)
              for name, kind in types.items()}
    strings, numbers, lines = {}, {}, []

    def expression(text):
        text = text.strip()
        if text in strings: return strings[text]
        if text in numbers: return numbers[text]
        if text.startswith(('"', '{')): return string_expression(text)
        query = re.fullmatch(r'\$bits\((.+)\)', text)
        if query: return region(query[1], types)[2]
        if ' ^ ' in text:
            a, b = text.split(' ^ ')
            return xor(expression(a), expression(b))
        if re.fullmatch(r'(a|b|wa|wb)(\[.+\])?', text): return view(text, types, values)
        if re.fullmatch(r'-?\d+', text): return int(text)
        return literal(text)

    for statement in (s.strip() for s in program.split(';') if s.strip()):
        display = re.fullmatch(r'\$display\("([^"\n]*)",\s*(.*)\)', statement, re.S)
        if display:
            lines.append(formatted(display[1], [expression(a) for a in split_arguments(display[2])]))
            continue
        assignment = re.fullmatch(r'(.+?)=(.+)', statement, re.S)
        assert assignment, ('unsupported top statement', statement)
        target, rhs = (s.strip() for s in assignment.groups())
        call = re.fullmatch(r'\$sscanf\((.*)\)', rhs, re.S)
        if call:
            assert target == 'rc'
            args = split_arguments(call[1]); assert len(args) == 5
            numbers[target] = scan(expression(args[0]), expression(args[1]), args[2:], types, values, numbers)
            continue
        make_format = re.fullmatch(r'\$sformatf\("([^"\n]*)",\s*(.*)\)', rhs, re.S)
        if make_format:
            assert target == 'fmt'
            strings[target] = formatted(make_format[1], [expression(a) for a in split_arguments(make_format[2])])
        elif target in ('text', 'fmt'): strings[target] = expression(rhs)
        elif target in ('rc', 'tag'): numbers[target] = expression(rhs)
        else:
            value = Value(region(target, types)[2]) if rhs == "'0" else expression(rhs)
            assert isinstance(value, Value)
            store(target, value, types, values)
    return '\n'.join(lines) + '\n'


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[i]) for name, i in
                (('scalar', 0), ('runtime_z', 1), ('literal_x', 2), ('empty_bit_z', 3), ('wide_hex', 4), ('runtime_whole', 5))}
    faults = (
        ('wrong_query_target', 'runtime_z', [('$bits(wa));', '$bits(wa[135 -: 129]));')]),
        ('wrong_select_base', 'literal_x', [('wa[7 +: 65]', 'wa[6 +: 65]')]),
        ('wrong_destination', 'runtime_whole', [('a, b, tag);', 'b, a, tag);')]),
        ('failed_word_clobber', 'literal_x', [('rc=$sscanf(text,', "wb='0; rc=$sscanf(text,")]),
        ('failed_marker_clobber', 'empty_bit_z', [('rc=$sscanf(text,', 'tag=0; rc=$sscanf(text,')]),
        ('lost_partial_preservation', 'wide_hex', [('wa[0 +: 32]', 'wa')]),
        ('wrong_literal_limit', 'wide_hex', [('$sscanf(text, "%39h|%b|%d"', '$sscanf(text, "%38h|%b|%d"')]),
        ('wrong_guard_target', 'scalar', [("wa=wa ^ 1'b1;", "a=a ^ 1'b1;")]),
        ('wrong_input_digit', 'scalar', [('text="1|01|7";', 'text="0|01|7";')]),
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
        original = ROOT / 'tests/gen/ch21' / (case.name + '.sv')
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
    files = ('generators/interaction_scansel.py', 'generators/interaction_class_import.py', 'generators/interaction_cond.py',
             'generators/interaction_genloop.py', 'generators/interaction_cover.py', 'generators/common.py',
             'tools/qualify_scansel.py', 'tools/qualify_class_import.py', 'tools/qualify_gensub.py', 'tools/qualify_ifquery.py')
    def hashes(): return {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}
    sources = hashes(); runner = suite_results.runner_digest('kirimasim'); binary = Path(args.kirimasim).resolve()
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    paths = [ROOT / 'tests/gen/ch21' / (generator.case_name(row) + '.sv') for row in generator.MODEL.select()]
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
              'scope': 'Independent bounded scanning, literal stopping and actual lvalue merge interpretation; auxiliary runs are not fixed or coverage passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths), 'source_and_expectation_sha256': evidence.hexdigest(),
              'source_sha256': sources, 'runner_sha256': runner, 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True, 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; native controls: 6; detected SV faults: 9')


if __name__ == '__main__': main()
