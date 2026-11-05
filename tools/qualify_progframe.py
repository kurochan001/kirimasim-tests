#!/usr/bin/env python3
"""Interpret the emitted program/task grammar with private frames and events."""

import argparse
import datetime
import hashlib
import heapq
import itertools
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

from qualify_class_import import Type, Value, initial_value, literal
from qualify_gensub import xor
from qualify_ifquery import split_arguments
from qualify_scansel import formatted
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_progframe as generator


def statements(text):
    """Parse the small task grammar, rejecting unconsumed syntax."""
    result = []
    while text.strip():
        text = text.lstrip()
        branch = re.match(r'if\s*\(id==0\)\s*begin(.*?)end\s*else\s*begin(.*?)end', text, re.S)
        if branch:
            result.append(('if', statements(branch[1]), statements(branch[2])))
            text = text[branch.end():]
        else:
            simple = re.match(r'([^;]+);', text, re.S); assert simple, ('missing semicolon', text)
            result.append(('simple', simple[1].strip())); text = text[simple.end():]
    return result


def interpret(source):
    """Read actual types, bindings, task statements and delays, without row data.

    Module updates/observations use Active priority and program events Reactive
    priority. No supported observation shares a task return or cancellation tick.
    This bounded interpreter is deliberately not a general SystemVerilog engine.
    """
    code = re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*', '', source, flags=re.S)
    module = re.fullmatch(r'\s*module \w+;(.*)endmodule\s*', code, re.S); assert module
    programs = dict(re.findall(r'program ([pq]);(.*?)endprogram', module[1], re.S))
    assert set(programs) == {'p', 'q'}
    rest = re.sub(r'program [pq];.*?endprogram', '', module[1], flags=re.S)
    structure = re.fullmatch(r'(.*?)initial begin(.*?)end\s*', rest, re.S); assert structure
    declarations, driver = structure.groups()
    types, values, aliases = {}, {}, {}
    for declaration in (s.strip() for s in declarations.split(';') if s.strip()):
        typedef = re.fullmatch(r'typedef (bit|logic)( signed)? \[(\d+):0\] (word_t|actual_t)', declaration)
        if typedef:
            state, sign, high, name = typedef.groups(); assert name not in aliases
            aliases[name] = Type(int(high) + 1, state, bool(sign)); continue
        typed = re.fullmatch(r'(word_t|actual_t|int|logic \[\d+:0\]) (.*)', declaration)
        assert typed, ('unsupported declaration', declaration)
        kind, names = typed.groups()
        kind = aliases[kind] if kind in aliases else Type(32, 'bit', True) if kind == 'int' else Type(int(re.search(r'\d+', kind)[0]) + 1, 'logic', False)
        for item in names.split(','):
            field = re.fullmatch(r'\s*(\w+)(?:\[(\d+):(\d+)\])?(?:=(0|\x270))?\s*', item)
            assert field, ('unsupported variable', item)
            name, low, high, initializer = field.groups()
            targets = [name] if low is None else [f'{name}[{i}]' for i in range(int(low), int(high) + 1)]
            assert targets
            for target in targets:
                assert target not in types; types[target] = kind
                values[target] = Value(kind.width, signed=kind.signed) if initializer else initial_value(kind)
    assert set(aliases) == {'word_t', 'actual_t'}
    word = aliases['word_t']; queue, serial, output = [], itertools.count(), []
    invokers = {}
    alive, roots, pending = dict(p=True, q=True), dict(p=2, q=2), dict(p=2, q=2)

    def schedule(tick, priority, action): heapq.heappush(queue, (tick, priority, next(serial), action))

    def expression(text, frame=None):
        text = text.strip(); frame = {} if frame is None else frame
        if ' ^ ' in text:
            a, b = text.split(' ^ '); return xor(expression(a, frame), expression(b, frame))
        cast = re.fullmatch(r"word_t'\(id\+(\d+)\)", text)
        if cast: return Value(32, frame['id'] + int(cast[1]), signed=True).convert(word)
        if text in frame: return frame[text]
        if text in values: return values[text]
        if text == '$time': return now
        if re.fullmatch(r'\d+', text): return int(text)
        return literal(text)

    def execute(nodes, frame=None, owner=None):
        frame = {} if frame is None else frame
        for node in nodes:
            if node[0] == 'if':
                reason = execute(node[1] if frame['id'] == 0 else node[2], frame, owner)
                if reason: return reason
                continue
            text = node[1]
            if text in ('return', '$exit', '$finish'): return text
            display = re.fullmatch(r'\$(write|display)\("([^"\n]*)",\s*(.*?)\)', text, re.S)
            if display:
                operation, fmt, args = display.groups()
                arguments = [expression(a, frame) for a in split_arguments(args)]
                arguments = [v.bits if isinstance(v, Value) and '%b' not in fmt else v for v in arguments]
                output.append(formatted(fmt, arguments) + ('\n' if operation == 'display' else '')); continue
            increment = re.fullmatch(r'(\w+)\+\+', text)
            if increment:
                target = increment[1]; assert target in types
                values[target] = Value(32, values[target].bits + 1, signed=True).convert(types[target]); continue
            assignment = re.fullmatch(r'([\w\[\]]+)=(.*)', text, re.S)
            assert assignment, ('unsupported statement', text)
            target, rhs = assignment.groups(); value = expression(rhs, frame)
            if isinstance(value, int): value = Value(32, value, signed=True)
            if target in ('held', 'result'):
                assert target in frame; frame[target] = value.convert(word)
            else:
                assert target in types; values[target] = value.convert(types[target])

    def finish_root(owner):
        roots[owner] -= 1
        if roots[owner] == 0: alive[owner] = False

    for owner, program in programs.items():
        parsed = re.fullmatch(r'\s*task automatic transfer\(input word_t sampled, (output|inout|input) word_t result,\s*input int id, input int delay\);\s*word_t held;(.*?)endtask\s*initial begin\s*fork(.*?)join(.*?)end\s*initial begin(.*?)end\s*', program, re.S)
        assert parsed, ('unsupported program', owner)
        direction, body, forks, after_join, other = parsed.groups()
        parts = body.split('#delay;'); assert len(parts) == 2
        head, tail = map(statements, parts)
        branches = re.findall(r'begin #(\d+);\s*(transfer\([^;]+\);)(.*?)end', forks, re.S)
        assert len(branches) == 2 and not re.sub(r'begin #\d+;\s*transfer\([^;]+\);.*?end', '', forks, flags=re.S).strip()
        continuation = re.fullmatch(r'\s*(\w+=1;)\s*#(\d+);\s*(transfer\([^;]+\);)(.*?)\s*', after_join, re.S)
        assert continuation
        joined, recovery_delay, recovery_call, recovery_suffix = continuation.groups()

        def invoke(call, suffix, first, owner=owner, direction=direction, head=head, tail=tail,
                   joined=joined, recovery_delay=int(recovery_delay), recovery_call=recovery_call,
                   recovery_suffix=recovery_suffix):
            if not alive[owner]: return
            match = re.fullmatch(r'transfer\((.*)\);', call.strip()); assert match
            args = split_arguments(match[1]); assert len(args) == 4 and args[1] in types
            sampled, target, identifier, delay = args
            frame = {'sampled': expression(sampled).convert(word), 'result': initial_value(word),
                     'held': initial_value(word), 'id': int(identifier), 'delay': int(delay)}
            if direction in ('inout', 'input'): frame['result'] = values[target].convert(word)
            assert execute(head, frame, owner) is None
            def complete():
                if not alive[owner]: return
                reason = execute(tail, frame, owner)
                if reason == '$exit': alive[owner] = False; return
                assert reason in (None, 'return')
                if direction in ('output', 'inout'): values[target] = frame['result'].convert(types[target])
                assert execute(statements(suffix), owner=owner) is None
                if first:
                    pending[owner] -= 1
                    if pending[owner] == 0:
                        execute(statements(joined), owner=owner)
                        schedule(now + recovery_delay, 1,
                                 lambda: invokers[owner](recovery_call, recovery_suffix, False))
                else: finish_root(owner)
            schedule(now + frame['delay'], 1, complete)

        # Bind this program's invoke function before the next loop iteration.
        bound_invoke = invokers[owner] = invoke
        for start, call, suffix in branches:
            schedule(int(start), 1, lambda call=call, suffix=suffix, invoke=bound_invoke: invoke(call, suffix, True))
        delayed = re.fullmatch(r'\s*#(\d+);(.*)', other, re.S); assert delayed
        def other_root(owner=owner, body=statements(delayed[2])):
            if not alive[owner]: return
            reason = execute(body, owner=owner)
            if reason == '$exit': alive[owner] = False
            else:
                assert reason is None; finish_root(owner)
        schedule(int(delayed[1]), 1, other_root)

    tick = 0
    for statement in statements(driver):
        assert statement[0] == 'simple'
        delay = re.fullmatch(r'#(\d+)', statement[1])
        if delay: tick += int(delay[1]); continue
        schedule(tick, 0, lambda statement=statement: execute([statement]))
    while queue:
        now, _, _, action = heapq.heappop(queue)
        if not any(alive.values()): break
        reason = action()
        if reason == '$finish': break
    return ''.join(output)


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[i]) for name, i in
                (('before', 0), ('between', 1), ('natural_x', 2), ('bit_z', 3), ('signed', 4), ('inout', 5))}
    faults = (
        ('lost_exit', 'before', [('$exit;', '')]),
        ('late_exit', 'inout', [('#9; p_stop=1;', '#12; p_stop=1;')]),
        ('return_kills_program', 'signed', [('return;', '$exit;')]),
        ('lost_return', 'natural_x', [('return;', '')]),
        ('lost_copyout', 'signed', [('output word_t result', 'input word_t result')]),
        ('lost_signed_extension', 'signed', [('typedef logic signed', 'typedef logic')]),
        ('wrong_sample', 'before', [('transfer(p_src_a, p_a, 0, 6)', 'transfer(p_src_b, p_a, 0, 6)')]),
        ('wrong_destination', 'signed', [('transfer(p_src_a, p_a, 0, 6)', 'transfer(p_src_a, p_b, 0, 6)')]),
        ('resampled_local', 'between', [('#delay;', '#delay; held=p_src_a;')]),
    )
    programs = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, edits in faults:
        source = controls[parent].body
        for old, new in edits:
            assert old in source, (name, old); source = source.replace(old, new)
        assert interpret(source) != controls[parent].expected, name
        programs[name] = parent, source, 'fault'
    return controls, programs


def runtime(executable, directory):
    import common
    controls, programs = variants(); records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]; source, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = source.replace(case.body.strip('\n'), body.strip('\n'))
        original = ROOT / 'tests/gen/ch24' / (case.name + '.sv')
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
    files = ('generators/interaction_progframe.py', 'generators/interaction_class_import.py', 'generators/interaction_cond.py',
             'generators/interaction_cover.py', 'generators/common.py', 'tools/qualify_progframe.py',
             'tools/qualify_class_import.py', 'tools/qualify_gensub.py', 'tools/qualify_ifquery.py', 'tools/qualify_scansel.py')
    def hashes(): return {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}
    sources = hashes(); runner = suite_results.runner_digest('kirimasim'); binary = Path(args.kirimasim).resolve()
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    paths = [ROOT / 'tests/gen/ch24' / (generator.case_name(row) + '.sv') for row in generator.MODEL.select()]
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
              'scope': 'Independent typed private-frame and Active/Reactive event interpretation of saved SV; auxiliary controls/faults are not fixed-suite or coverage passes.',
              'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths), 'source_and_expectation_sha256': evidence.hexdigest(),
              'source_sha256': sources, 'runner_sha256': runner, 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True, 'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('Independent rows:', result['rows_interpreted'], '; native controls: 6; detected SV faults: 9')


if __name__ == '__main__': main()
