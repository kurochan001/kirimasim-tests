"""Bounded replayable stimuli for three model-based random comparison profiles.

These runtime cases do not enter the registered fixed suite or its coverage
denominators. Arithmetic reuses the existing standard-derived references;
packed writes extend their significance-based state model to operation lists.
"""

import json
from pathlib import Path
import random
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_divide as divide
import interaction_expr as expression

GENERATOR = 'bounded_random_cross@1'
PROFILES = ('expression_context', 'division_context', 'packed_write_sequence')
MAX_CASES = 256
MAX_STIMULI = 32
WIDTHS = (1, 32, 33, 64, 65, 129)


def integer(value, low, high, field):
    if type(value) is not int or not low <= value <= high:
        raise ValueError(f'{field} must be an integer in [{low}, {high}]')
    return value


def bits(value, width, fourstate=False):
    if not isinstance(value, str) or len(value) != width or not set(value) <= set(
            '01xz' if fourstate else '01'):
        raise ValueError(f'expected {width} bits'+(' including optional x/z' if fourstate else ''))


def keys(value, expected):
    if not isinstance(value, dict) or set(value) != set(expected):
        raise ValueError('unexpected fields; expected '+', '.join(expected))


def word(rng, width, fourstate=False):
    values = (0, 1, (1 << width)-1, 1 << (width-1), (1 << (width-1))-1)
    value = rng.choice(values) if rng.randrange(4) == 0 else rng.getrandbits(width)
    result = list(f'{value:0{width}b}')
    if fourstate and rng.randrange(4) == 0:
        for index in rng.sample(range(width), rng.randint(1, min(3, width))):
            result[index] = rng.choice('xz')
    return ''.join(result)


def generate(seed, count=96, steps=8, profiles=PROFILES):
    integer(seed, 0, (1 << 64)-1, 'seed')
    integer(count, 1, MAX_CASES, 'cases')
    integer(steps, 1, MAX_STIMULI, 'vectors')
    if not profiles or len(set(profiles)) != len(profiles) or not set(profiles) <= set(PROFILES):
        raise ValueError('choose distinct supported profiles')
    rng = random.Random(seed)
    schedule = [profiles[i % len(profiles)] for i in range(count)]
    rng.shuffle(schedule)
    cases = []
    for index, profile in enumerate(schedule):
        if profile in PROFILES[:2]:
            rows = expression.MODEL.rows() if profile == PROFILES[0] else tuple(
                row for row in divide.MODEL.rows() if row[6] == 'known')
            row = rng.choice(rows)
            wa, wb = int(row[0]), expression.width(int(row[0]), row[1])
            stimuli = []
            for _ in range(steps):
                a, b = word(rng, wa), word(rng, wb)
                if profile == PROFILES[1] and int(b, 2) == 0:
                    b = f'{rng.randrange(1, 1 << wb):0{wb}b}'
                stimuli.append({'a': a, 'b': b})
            parameters = {'row': list(row)}
        else:
            width = rng.choice(WIDTHS)
            span = rng.randint(1, width)
            parameters = {'width': width, 'span': span, 'direction': rng.choice(('ascending', 'descending')),
                          'select': rng.choice(('plus', 'minus')), 'state': rng.choice(('bit', 'logic'))}
            operations = []
            for step in range(steps):
                kind = ('write', 'read')[step] if step < 2 else rng.choice(('write', 'read'))
                operation = {'kind': kind, 'offset': rng.randrange(width-span+1)}
                if kind == 'write':
                    operation['data'] = word(rng, span, True)
                operations.append(operation)
            stimuli = {'initial': word(rng, width, True), 'operations': operations}
        cases.append({'id': f'case_{index:04d}', 'profile': profile,
                      'parameters': parameters, 'stimuli': stimuli})
    manifest = {'schema': 1, 'generator': GENERATOR, 'seed': seed, 'cases': cases}
    validate(manifest)
    return manifest


def validate_case(case):
    keys(case, ('id', 'profile', 'parameters', 'stimuli'))
    if not isinstance(case['id'], str) or not re.fullmatch(r'case_\d{4}', case['id']):
        raise ValueError('invalid case id')
    profile, parameters, stimuli = case['profile'], case['parameters'], case['stimuli']
    if profile not in PROFILES:
        raise ValueError('unsupported random profile')
    if profile in PROFILES[:2]:
        keys(parameters, ('row',))
        if not isinstance(parameters['row'], list):
            raise ValueError('row must be a list')
        row = tuple(parameters['row'])
        model = expression.MODEL if profile == PROFILES[0] else divide.MODEL
        if row not in model.rows() or (profile == PROFILES[1] and row[6] != 'known'):
            raise ValueError('row is outside this profile')
        if not isinstance(stimuli, list):
            raise ValueError('vectors must be a list')
        integer(len(stimuli), 1, MAX_STIMULI, 'vectors')
        wa, wb = int(row[0]), expression.width(int(row[0]), row[1])
        for vector in stimuli:
            keys(vector, ('a', 'b'))
            bits(vector['a'], wa)
            bits(vector['b'], wb)
            if profile == PROFILES[1] and int(vector['b'], 2) == 0:
                raise ValueError('division profile requires a nonzero known divisor')
    else:
        keys(parameters, ('width', 'span', 'direction', 'select', 'state'))
        width = integer(parameters['width'], 1, 129, 'width')
        if width not in WIDTHS:
            raise ValueError('width is outside the profile')
        span = integer(parameters['span'], 1, width, 'span')
        if parameters['direction'] not in ('ascending', 'descending') or parameters['select'] not in (
                'plus', 'minus') or parameters['state'] not in ('bit', 'logic'):
            raise ValueError('invalid write-sequence parameter')
        keys(stimuli, ('initial', 'operations'))
        bits(stimuli['initial'], width, True)
        operations = stimuli['operations']
        if not isinstance(operations, list):
            raise ValueError('operations must be a list')
        integer(len(operations), 1, MAX_STIMULI, 'operations')
        for operation in operations:
            if not isinstance(operation, dict) or operation.get('kind') not in ('read', 'write'):
                raise ValueError('invalid operation')
            keys(operation, ('kind', 'offset', 'data') if operation['kind'] == 'write' else ('kind', 'offset'))
            integer(operation['offset'], 0, width-span, 'offset')
            if operation['kind'] == 'write':
                bits(operation['data'], span, True)


def validate(manifest):
    keys(manifest, ('schema', 'generator', 'seed', 'cases'))
    if type(manifest['schema']) is not int or manifest['schema'] != 1 or manifest['generator'] != GENERATOR:
        raise ValueError('unsupported manifest version')
    integer(manifest['seed'], 0, (1 << 64)-1, 'seed')
    if not isinstance(manifest['cases'], list):
        raise ValueError('cases must be a list')
    integer(len(manifest['cases']), 1, MAX_CASES, 'cases')
    ids = set()
    for case in manifest['cases']:
        validate_case(case)
        if case['id'] in ids:
            raise ValueError('duplicate case id')
        ids.add(case['id'])


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=True)


def materialize(case):
    validate_case(case)
    profile, p, stimuli = case['profile'], case['parameters'], case['stimuli']
    lines = [f'module random_cross_{case["id"]};']
    expected = []
    if profile in PROFILES[:2]:
        row = tuple(p['row'])
        wa = int(row[0])
        wb, wr = expression.width(wa, row[1]), expression.width(wa, row[2])
        natural = max(wa, wb)
        op = {'add': '+', 'sub': '-', 'mul': '*', 'div': '/', 'mod': '%'}[row[5]]
        lines += [f'  logic {row[3]} [{wa-1}:0] a;', f'  logic {row[4]} [{wb-1}:0] b;',
                  f'  {row[7] if profile == PROFILES[1] else "logic"} [{wr-1}:0] result;']
        if profile == PROFILES[1]:
            lines += [f'  logic [{natural-1}:0] raw;']
        lines += ['  initial begin']
        for index, vector in enumerate(stimuli):
            a, b = vector['a'], vector['b']
            lines += [f"    a = {wa}'b{a}; b = {wb}'b{b};", f'    result = a {op} b;',
                      f'    $display("v{index}_inputs=%b %b", a, b);']
            expected += [f'v{index}_inputs={a} {b}']
            if profile == PROFILES[0]:
                value = expression.reference(row, int(a, 2), int(b, 2))
                lines += [f'    $display("v{index}_result=%b", result);']
                expected += [f'v{index}_result={value:0{wr}b}']
            else:
                lines += [f'    raw = a {op} b;',
                          f'    $display("v{index}_raw=%b result=%b bits=%0d", raw, result, $bits(a {op} b));']
                expected += [f'v{index}_raw={divide.reference(row, a, b, natural)} '
                             f'result={divide.reference(row, a, b, wr)} bits={natural}']
        clauses = '11.6.1 11.8.1 11.8.2'+(' 11.4.3' if profile == PROFILES[1] else '')
    else:
        w, span = p['width'], p['span']
        ascending = p['direction'] == 'ascending'
        left, right = (4, w+3) if ascending else (w+3, 4)
        select = '+:' if p['select'] == 'plus' else '-:'
        selection = f'target[index {select} {span}]'
        lines += [f'  {p["state"]} [{left}:{right}] target;', f'  logic [{span-1}:0] data;',
                  '  int index;', '  initial begin', f"    target = {w}'b{stimuli['initial']};",
                  '    $display("initial=%b", target);']
        convert = lambda value: value.replace('x', '0').replace('z', '0') if p['state'] == 'bit' else value
        state = convert(stimuli['initial'])
        expected += ['initial='+state]
        for step, operation in enumerate(stimuli['operations']):
            offset, kind = operation['offset'], operation['kind']
            base = (right-offset-span+1 if p['select'] == 'plus' else right-offset) if ascending else (
                right+offset if p['select'] == 'plus' else right+offset+span-1)
            lines += [f'    index = {base};']
            start = w-offset-span
            if kind == 'write':
                lines += [f"    data = {span}'b{operation['data']};", f'    {selection} = data;']
                state = state[:start]+convert(operation['data'])+state[start+span:]
            lines += [f'    $display("step={step} kind={kind} whole=%b slice=%b", target, {selection});']
            expected += [f'step={step} kind={kind} whole={state} slice={state[start:start+span]}']
        clauses = '11.5.1 7.4.1 6.11.2'
    lines += ['    $finish;', '  end', 'endmodule']
    header = ['/*', f':name: random_cross_{case["id"]}', ':type: simulation',
              ':lrm: 1800-2023 '+clauses, ':oracle: spec', ':spec_check: ai',
              ':description: Bounded random comparison; replay the saved manifest.', '*/',
              '// Runtime-only case; not part of the registered fixed suite.']
    return '\n'.join(header+lines)+'\n', '\n'.join(expected)+'\n'
