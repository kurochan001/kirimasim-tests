#!/usr/bin/env python3
"""Interpret emitted generated-enum programs and execute real SV faults."""

import argparse
import ast
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
import interaction_genenum as generator


def integer(source, env, width=None):
    """Evaluate the bounded constant-expression grammar, not generator helpers."""
    source = source.replace("base_t'(", 'cast(').replace("'1", 'ones')
    tree = ast.parse(source.strip(), mode='eval')
    def evaluate(node):
        if isinstance(node, ast.Constant) and type(node.value) is int: return node.value
        if isinstance(node, ast.Name):
            return (1 << width) - 1 if node.id == 'ones' and width else env[node.id]
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id == 'cast':
            assert width and len(node.args) == 1 and not node.keywords
            return evaluate(node.args[0]) & ((1 << width) - 1)
        if isinstance(node, ast.BinOp):
            a, b = evaluate(node.left), evaluate(node.right)
            for kind, function in ((ast.Add, lambda: a+b), (ast.Sub, lambda: a-b),
                                   (ast.LShift, lambda: a<<b), (ast.Mod, lambda: a%b)):
                if isinstance(node.op, kind): return function()
        if isinstance(node, ast.Compare) and len(node.ops) == 1 and isinstance(node.ops[0], ast.Eq):
            return int(evaluate(node.left) == evaluate(node.comparators[0]))
        raise AssertionError('unhandled constant expression: ' + source)
    return evaluate(tree.body)


@dataclass(frozen=True)
class Bits:
    raw: int
    width: int
    signed: bool

    def decimal(self):
        return self.raw - (1 << self.width) if self.signed and self.raw >> (self.width-1) else self.raw


DISPLAY = r'\$display\("(?P<fmt_{0}>[^"]*)",\s*(?P<args_{0}>.*?)\);'
SAMPLE = (r'\s*value = \(phase == 0\) \? value\.(?P<first>first|last)\(\) : '
          r'value\.(?P<last>first|last)\(\);\s*held = value;\s*' + DISPLAY.format('h') +
          r'\s*for \(int k = (?P<start>\d+); k <= (?P<bound>[^;]+); k\+\+\) begin\s*' +
          DISPLAY.format('v') + r'\s*value = value\.(?P<method>next|prev)\((?P<step>[^)]+)\);'
          r'\s*end\s*(?P<damage>held = value;)?\s*')


class Leaf:
    def __init__(self, source, env):
        self.env = dict(env)
        declarations, rest = source.split('task automatic sample(input int phase);', 1)
        sample, peek = rest.split('endtask', 1)
        self.sample = re.fullmatch(SAMPLE, sample, re.S)
        assert self.sample, sample
        peek = re.fullmatch(r'\s*task automatic peek\(input int phase\);\s*' + DISPLAY.format('p') +
                            r'\s*endtask', peek, re.S)
        assert peek
        self.peek_display = (peek['fmt_p'], peek['args_p'])
        declaration = re.fullmatch(
            r'\s*localparam int KIND = ([^;]+);\s*localparam int WIDTH = ([^;]+);'
            r'\s*localparam int COUNT = ([^;]+);\s*localparam int STEP = ([^;]+);'
            r'\s*typedef logic (signed|unsigned) \[WIDTH-1:0\] base_t;'
            r'\s*typedef enum base_t \{(.*?)\} enum_t;\s*enum_t value, held;\s*', declarations, re.S)
        assert declaration, declarations
        for key, expr in zip(('KIND', 'WIDTH', 'COUNT', 'STEP'), declaration.groups()[:4]):
            self.env[key] = integer(expr, self.env)
        self.width = self.env['WIDTH']; assert self.width > 0
        self.signed = declaration[5] == 'signed'
        self.names = []; self.values = []
        for member in declaration[6].split(','):
            name, expression = member.strip().split(' = ', 1)
            assert re.fullmatch('E[0-9]+', name)
            self.names.append(name)
            self.values.append(integer(expression, self.env, self.width) & ((1 << self.width)-1))
        assert len(set(self.names)) == len(self.names) and len(set(self.values)) == len(self.values)
        self.value = self.held = None

    def operand(self, source, env):
        text = source.strip()
        if text == '$bits(enum_t)': return self.width
        if text in ('value', 'held'):
            index = getattr(self, text); assert index is not None
            return Bits(self.values[index], self.width, self.signed)
        part = re.fullmatch(r'value\[(\d+):0\]', text)
        if part:
            word = self.operand('value', env); n = int(part[1])+1
            return Bits(word.raw & ((1 << n)-1), n, False)
        method = re.fullmatch(r'(value|held)\.(first|last|num|name|next|prev)\((.*?)\)', text)
        if method:
            owner, op, count = method.groups(); at = getattr(self, owner)
            if op == 'num': return len(self.values)
            if op == 'name': return self.names[at]
            if op == 'first': at = 0
            elif op == 'last': at = len(self.values)-1
            else:
                assert at is not None
                delta = integer(count, env) if count else 1
                at = (at + (delta if op == 'next' else -delta)) % len(self.values)
            return Bits(self.values[at], self.width, self.signed)
        return integer(text, env)

    def display(self, fmt, args, env):
        values = iter(self.operand(a, env) for a in args.split(','))
        def field(match):
            value = next(values)
            if match[0] == '%b':
                assert isinstance(value, Bits)
                return format(value.raw, f'0{value.width}b')
            if match[0] == '%s': assert isinstance(value, str); return value
            return str(value.decimal() if isinstance(value, Bits) else value)
        result = re.sub(r'%0d|%b|%s', field, fmt)
        assert next(values, None) is None
        return result

    def call(self, operation, phase):
        env = dict(self.env, phase=phase)
        if operation == 'peek': return [self.display(*self.peek_display, env)]
        m = self.sample
        initial = m['first' if phase == 0 else 'last']
        self.value = 0 if initial == 'first' else len(self.values)-1
        self.held = self.value
        output = [self.display(m['fmt_h'], m['args_h'], env)]
        for k in range(int(m['start']), integer(m['bound'], env)+1):
            env['k'] = k
            output.append(self.display(m['fmt_v'], m['args_v'], env))
            step = integer(m['step'], env)
            self.value = (self.value + (step if m['method'] == 'next' else -step)) % len(self.values)
        if m['damage']: self.held = self.value
        return output


def interpret(source):
    """Unroll actual emitted scopes, declarations, task bodies and top-level calls.

    The bounded program is sequential; no scheduling or type-compatibility proof
    is inferred. Unsupported emitted syntax is rejected rather than skipped.
    """
    base = int(re.search(r'parameter int SELECT = 0, ID = 0, BASE = (\d+)', source)[1])
    loop = re.search(r'for \(genvar g = (\d+); g < (\d+); g\+\+\)', source)
    assert loop
    bodies = re.findall(r'begin : choice\n(.*?endtask\s*task automatic peek.*?endtask)', source, re.S)
    assert len(bodies) == 2
    guard = re.search(r'if \((\(SELECT \+ g\) % 2 == [01])\) begin : choice', source)
    if guard: selector = guard[1]
    else:
        guard = re.search(r'case \((\(SELECT \+ g\) % 2)\)\s*0: begin : choice', source)
        assert guard
        selector = guard[1] + ' == 0'
    leaves = {}
    instances = re.findall(r'enum_worker #\(\.SELECT\((\d+)\), \.ID\((\d+)\)\) ([ab])\(\);', source)
    assert len(instances) == 2
    for select, identity, owner in instances:
        for lane in range(int(loop[1]), int(loop[2])):
            env = {'SELECT': int(select), 'ID': int(identity), 'BASE': base, 'g': lane}
            body = bodies[0 if integer(selector, env) else 1]
            leaves[owner, lane] = Leaf(body, env)
    driver = source.split('  initial begin\n', 1)[1].split('$finish;', 1)[0]
    output = []
    for statement in driver.split(';'):
        statement = statement.strip()
        if not statement or re.fullmatch(r'#\d+', statement): continue
        call = re.fullmatch(r'([ab])\.lanes\[(\d+)\]\.choice\.(sample|peek)\(([012])\)', statement)
        assert call, statement
        output.extend(leaves[call[1], int(call[2])].call(call[3], int(call[4])))
    return '\n'.join(output) + '\n'


def independent(row):
    return interpret(generator.source(row))


def runtime(executable, directory):
    controls = {}
    for name, index in (('scalar', 0), ('wide', 1), ('walk', 4), ('descending', 5)):
        row = generator.MODEL.anchors[index]
        path = ROOT/'tests/gen/ch6'/(generator.case_name(row)+'.sv')
        controls[name] = (path.read_text(), suite_results.expected_output(path, 'kirimasim'), path)
    faults = [
        ('width_loses_genvar', 'scalar', 'WIDTH = BASE + g + KIND;', 'WIDTH = BASE + 0 + KIND;'),
        ('wrong_instance_selection', 'wide', '.SELECT(1), .ID(1)', '.SELECT(0), .ID(1)'),
        ('reversed_walk', 'walk', 'value = value.prev(STEP);', 'value = value.next(STEP);'),
        ('wrong_step', 'walk', 'STEP = 1;', 'STEP = 0;'),
        ('unsigned_base', 'descending', 'typedef logic signed', 'typedef logic unsigned'),
        ('lost_high_bits', 'wide', 'phase, ID, g, k, value, value,',
         'phase, ID, g, k, value[31:0], value,'),
        ('held_copy_overwritten', 'walk', '        end\n      endtask',
         '        end\n        held = value;\n      endtask'),
        ('wrong_member_name', 'descending', 'E0 =', 'E9 ='),
    ]
    variants = {name: (name, source, 'control') for name, (source, _, _) in controls.items()}
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
            result = original(*a, **kw)
            if a[0][0] == executable: calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture):
            status, reason = run_kirimasim.run(path, executable)
        assert len(calls) == 1 and calls[0].returncode == 0, (name, reason)
        assert status == ('pass' if kind == 'control' else 'fail'), (name, status, reason)
        if kind == 'fault': assert reason.startswith('output differs'), (name, reason)
        raw = calls[0]
        normalized = original([sys.executable, str(run_kirimasim.NORMALIZE)], input=raw.stdout,
                              capture_output=True, text=True, check=True).stdout
        records[name] = {'kind': kind, 'control': parent, 'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                         'expected_stdout': expected, 'stdout': normalized, 'returncode': raw.returncode,
                         'stderr': raw.stderr.replace(str(folder), '<case>'),
                         'original_test': controls[parent][2].relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(controls[parent][2])}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')
    for row in generator.MODEL.rows(): assert independent(row) == generator.reference(row), row
    binary = Path(args.kirimasim).resolve(); digest = hashlib.sha256(binary.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as directory: records = runtime(str(binary), Path(directory))
    assert digest == hashlib.sha256(binary.read_bytes()).hexdigest(), 'binary changed'
    result = {'model': generator.MODEL.name, 'version': 1,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Independent parsing and unrolling of emitted declarations, enum tables, task bodies and calls for every legal row; four selected native controls and eight real SV faults. Known-member navigation only, no scheduler or illegal type-assignment proof.',
              'independent_rows': len(generator.MODEL.rows()), 'binary_sha256': digest,
              'simulator_version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'runner_sha256': suite_results.runner_digest('kirimasim'),
              'sources_sha256': {n: hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in
                                ('generators/interaction_genenum.py', 'tools/qualify_genenum.py')},
              'executions': records}
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n')
    print('Independent rows: 1056; native controls: 4 pass; real SV faults: 8 detected')


if __name__ == '__main__':
    main()
