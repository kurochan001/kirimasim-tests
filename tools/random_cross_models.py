"""Bounded replayable stimuli for model-based random comparison profiles.

These runtime cases do not enter the registered fixed suite or its coverage
denominators. Arithmetic reuses the existing standard-derived references;
packed writes extend their significance-based state model to operation lists.
"""

import hashlib
import json
from pathlib import Path
import random
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_divide as divide
import interaction_expr as expression
import interaction_cond as conditional
import interaction_pkgwatch as package_watch
import interaction_bits as bit_values
import interaction_shift as shifts
import interaction_stream as streams
import interaction_concat as concatenation
import interaction_compare as comparisons
import interaction_logic as logical

GENERATOR = 'bounded_random_cross@1'
LEGACY_PROFILES = ('expression_context', 'division_context', 'packed_write_sequence')
FIVE_PROFILES = LEGACY_PROFILES + ('conditional_context', 'package_change_sequence')
SEVEN_PROFILES = FIVE_PROFILES + ('shift_context', 'cast_pipeline')
NINE_PROFILES = SEVEN_PROFILES + ('streaming_context', 'concat_assignment_sequence')
PROFILES = NINE_PROFILES + ('comparison_context', 'packed_logic_context')
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
        elif profile == 'conditional_context':
            parameters, stimuli = generate_conditional(rng, steps)
        elif profile == 'package_change_sequence':
            parameters, stimuli = generate_package(rng, steps)
        elif profile == 'shift_context':
            parameters, stimuli = generate_shift(rng, steps)
        elif profile == 'cast_pipeline':
            parameters, stimuli = generate_cast(rng, steps)
        elif profile == 'streaming_context':
            parameters, stimuli = generate_stream(rng, steps)
        elif profile == 'concat_assignment_sequence':
            parameters, stimuli = generate_concat(rng, steps)
        elif profile == 'comparison_context':
            parameters, stimuli = generate_comparison(rng, steps)
        elif profile == 'packed_logic_context':
            parameters, stimuli = generate_logic(rng, steps)
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
    elif profile == 'conditional_context':
        validate_conditional(parameters, stimuli)
    elif profile == 'package_change_sequence':
        validate_package(parameters, stimuli)
    elif profile in ('shift_context', 'cast_pipeline'):
        validate_bit_profile(profile, parameters, stimuli)
    elif profile == 'streaming_context':
        validate_stream(parameters, stimuli)
    elif profile == 'concat_assignment_sequence':
        validate_concat(parameters, stimuli)
    elif profile == 'comparison_context':
        validate_comparison(parameters, stimuli)
    elif profile == 'packed_logic_context':
        validate_logic(parameters, stimuli)
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


def content_digest(case):
    """Actual ordered stimulus/parameters, excluding only the administrative ID.

    Keep canonical(case) and the old stimulus_sha256 unchanged. In particular,
    do not sort, collapse or discard writes, reads or repeated operations.
    """
    validate_case(case)
    return hashlib.sha256(canonical({key: value for key, value in case.items()
                                     if key != 'id'}).encode()).hexdigest()


def requires_fourstate(case):
    validate_case(case)
    if case['profile'] in ('comparison_context', 'packed_logic_context'):
        return any(set(''.join(v.values())) & set('xz') for v in case['stimuli'])
    if case['profile'] == 'streaming_context':
        return any(set(''.join(v.values())) & set('xz') for v in case['stimuli'])
    if case['profile'] == 'concat_assignment_sequence':
        s = case['stimuli']
        return bool(set(s['initial_left']+s['initial_right']+''.join(
            op['source']+op['after'] for op in s['operations'])) & set('xz'))
    if case['profile'] in ('shift_context', 'cast_pipeline'):
        return any(set(v['source']+v.get('count', '')) & set('xz') for v in case['stimuli'])
    if case['profile'] == 'conditional_context':
        return any(set(v['a']+v['b']+v['condition']) & set('xz') for v in case['stimuli'])
    if case['profile'] == 'package_change_sequence':
        return any(set(v) & set('xz') for v in case['stimuli']['initial'].values()) or any(
            set(op['data']) & set('xz') for op in case['stimuli']['operations'])
    if case['profile'] != 'packed_write_sequence':
        return False
    stimuli = case['stimuli']
    words = [stimuli['initial'], *(op['data'] for op in stimuli['operations'] if op['kind'] == 'write')]
    return any(set(word) & set('xz') for word in words)


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
    elif profile == 'comparison_context':
        lines, expected = materialize_comparison(case)
        clauses = '11.4.4 11.4.5 11.4.6 11.6.1 11.8.2 6.11.2'
    elif profile == 'packed_logic_context':
        lines, expected = materialize_logic(case)
        clauses = '11.4.9 11.4.7 11.6.1 11.8.1 6.11.2 11.5.1 11.4.12'
    elif profile == 'streaming_context':
        lines, expected = materialize_stream(case)
        clauses = '11.4.14.1 11.4.14.2 11.4.14.3 6.11.2'
    elif profile == 'concat_assignment_sequence':
        lines, expected = materialize_concat(case)
        clauses = '11.4.12 10.7 10.4.1 10.4.2 6.11.2 11.8.1 11.8.2'
    elif profile == 'shift_context':
        lines, expected = materialize_shift(case)
        clauses = '11.4.10 11.6.1 11.8.1 11.8.2 6.11.2'
    elif profile == 'cast_pipeline':
        lines, expected = materialize_cast(case)
        clauses = '6.24.1 6.11.2 11.6.1 11.8.1 11.8.2'
    elif profile == 'conditional_context':
        lines, expected = materialize_conditional(case)
        clauses = '11.4.11 11.6.1 11.8.1 11.8.2 6.11.2'
    elif profile == 'package_change_sequence':
        lines, expected = materialize_package(case)
        clauses = '26.3 26.4 9.4.2 9.4.3 9.2.2.2.1 11.4.6 4.4.2.2 4.4.2.4 7.4.1'
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


def generate_conditional(rng, steps):
    width = rng.choice(WIDTHS)
    p = {'width': width, 'relation': rng.choice(('same', 'wide') if width == 1 else ('narrow', 'same', 'wide')),
         'sign_a': rng.choice(('signed', 'unsigned')), 'sign_b': rng.choice(('signed', 'unsigned')),
         'state': rng.choice(('bit', 'logic'))}
    vectors = []
    for _ in range(steps):
        a = word(rng, width, True)
        # Equal branches exercise identical X/Z merging; independent branches
        # explore arbitrary differing bits rather than fixed pattern names.
        b = a if rng.randrange(4) == 0 else word(rng, width, True)
        vectors.append({'a': a, 'b': b, 'condition': rng.choice('01xz')})
    return p, vectors


def validate_conditional(p, vectors):
    keys(p, ('width', 'relation', 'sign_a', 'sign_b', 'state'))
    width = integer(p['width'], 1, 129, 'width')
    if width not in WIDTHS or p['relation'] not in ('narrow', 'same', 'wide') or (
            width == 1 and p['relation'] == 'narrow') or p['sign_a'] not in ('signed', 'unsigned') or (
            p['sign_b'] not in ('signed', 'unsigned')) or p['state'] not in ('bit', 'logic'):
        raise ValueError('invalid conditional-context parameter')
    if not isinstance(vectors, list):
        raise ValueError('vectors must be a list')
    integer(len(vectors), 1, MAX_STIMULI, 'vectors')
    for vector in vectors:
        keys(vector, ('a', 'b', 'condition'))
        bits(vector['a'], width, True);bits(vector['b'], width, True);bits(vector['condition'], 1, True)


def materialize_conditional(case):
    p = case['parameters'];w = p['width'];wr = w + {'narrow': -1, 'same': 0, 'wide': 1}[p['relation']]
    lines = [f'module random_cross_{case["id"]};', f'  logic {p["sign_a"]} [{w-1}:0] a;',
             f'  logic {p["sign_b"]} [{w-1}:0] b;', '  logic condition;',
             f'  {p["state"]} [{wr-1}:0] result;', '  initial begin']
    expected = []
    for index, vector in enumerate(case['stimuli']):
        a, b, condition = vector['a'], vector['b'], vector['condition']
        lines += [f'    a = {conditional.literal(a)}; b = {conditional.literal(b)};',
                  f"    condition = 1'b{condition};", '    result = condition ? a : b;',
                  f'    $display("v{index}_inputs=%b %b condition=%b", a, b, condition);',
                  f'    $display("v{index}_result=%b", result);']
        n = max(w, wr)
        signed = p['sign_a'] == p['sign_b'] == 'signed'
        a_ext = (a[0] if signed else '0')*(n-w)+a
        b_ext = (b[0] if signed else '0')*(n-w)+b
        value = a_ext if condition == '1' else b_ext if condition == '0' else ''.join(
            x if x == y and x in '01' else 'x' for x, y in zip(a_ext, b_ext))
        value = value[-wr:]
        if p['state'] == 'bit':value = value.replace('x', '0').replace('z', '0')
        expected += [f'v{index}_inputs={a} {b} condition={condition}', f'v{index}_result={value}']
    return lines, expected


def generate_package(rng, steps):
    width = rng.choice(WIDTHS)
    p = {'width': width, 'state': rng.choice(('bit', 'logic')),
         'access': rng.choice(('qualified', 'wildcard', 'explicit')),
         'storage': rng.choice(('scalar', 'up', 'down')), 'update': rng.choice(('blocking', 'nba')),
         'event': rng.choice(('full', 'lsb')), 'wait': rng.choice(('logical', 'case'))}
    initial = {name: word(rng, width, True) for name in ('payload', 'neighbor', 'control', 'other_guard')}
    operations = []
    for index in range(steps):
        if index == steps-1:
            operation = {'target': 'payload', 'data': '0'*width}  # eventual progress
        elif operations and rng.randrange(4) == 0:
            operation = dict(operations[-1])  # do not collapse repeated writes
        else:
            target = 'payload' if index == 0 else rng.choice(('payload', 'payload', 'payload', 'payload', 'neighbor', 'control'))
            operation = {'target': target, 'data': word(rng, width, True)}
        operations.append(operation)
    return p, {'initial': initial, 'operations': operations}


def validate_package(p, stimuli):
    choices = {'state': ('bit', 'logic'), 'access': ('qualified', 'wildcard', 'explicit'),
               'storage': ('scalar', 'up', 'down'), 'update': ('blocking', 'nba'),
               'event': ('full', 'lsb'), 'wait': ('logical', 'case')}
    keys(p, ('width', *choices))
    width = integer(p['width'], 1, 129, 'width')
    if width not in WIDTHS or any(p[name] not in values for name, values in choices.items()):
        raise ValueError('invalid package-sequence parameter')
    keys(stimuli, ('initial', 'operations'))
    keys(stimuli['initial'], ('payload', 'neighbor', 'control', 'other_guard'))
    for value in stimuli['initial'].values():bits(value, width, True)
    operations = stimuli['operations']
    if not isinstance(operations, list):raise ValueError('operations must be a list')
    integer(len(operations), 1, MAX_STIMULI, 'operations')
    for operation in operations:
        keys(operation, ('target', 'data'))
        if operation['target'] not in ('payload', 'neighbor', 'control'):
            raise ValueError('invalid package target')
        bits(operation['data'], width, True)


def materialize_package(case):
    p, stimuli = case['parameters'], case['stimuli'];w = p['width'];zero = '0'*w
    row = (str(w), p['state'], 'known', p['access'], p['storage'], p['update'], p['event'], p['wait'])
    address = lambda name: package_watch.address(row, 'control_pkg' if name in ('control', 'other_guard') else 'payload_pkg',
                                                name in ('neighbor', 'other_guard'))
    lines = ['`timescale 1ns/1ns']
    for package in ('payload_pkg', 'control_pkg'):
        left, right = package_watch.indices(row)
        lines += [f'package {package};', f'  typedef {p["state"]} [{w-1}:0] word_t;']
        lines += ['  word_t target, neighbor;'] if p['storage'] == 'scalar' else [f'  word_t target[{left}:{right}];']
        lines += ['endpackage']
    lines += package_watch.observer(row, 'payload_pkg', 'payload_watch')
    lines += package_watch.observer(row, 'control_pkg', 'control_watch')
    lines += [f'module random_cross_{case["id"]};', f'  logic [{w-1}:0] drive;',
              '  payload_watch a();', '  payload_watch b();', '  control_watch g();', '  initial begin']
    convert = lambda value: value.replace('x', '0').replace('z', '0') if p['state'] == 'bit' else value
    values = {name: convert(value) for name, value in stimuli['initial'].items()}
    history = {name: {'hits': 0, 'last': zero, 'at': -1, 'wakes': int(values[name] == zero),
                      'wt': 1 if values[name] == zero else -1, 'held': zero} for name in ('payload', 'control')}
    for name, value in stimuli['initial'].items():lines += [f'    {address(name)} = {conditional.literal(value)};']
    drive = stimuli['initial']['payload']
    lines += [f'    drive = {conditional.literal(drive)};', '    #2;']
    expected = []

    def snapshot(tag, tick):
        lines.extend([f'    $display("snap tag={tag} t=%0d drive=%b neighbor=%b other_guard=%b",',
                      f'             $time, drive, {address("neighbor")}, {address("other_guard")});'])
        expected.append(f'snap tag={tag} t={tick} drive={drive} neighbor={values["neighbor"]} other_guard={values["other_guard"]}')
        for name, target in (('a', 'payload'), ('b', 'payload'), ('g', 'control')):
            value = values[target];state = history[target]
            predicate = '1' if value == zero else 'x' if p['wait'] == 'logical' and '1' not in value and set(value)&set('xz') else '0'
            lines.extend([f'    $write("o name={name} data=%b copy=%b hits=%0d last=%b at=%0d pred=%b ",',
                          f'             {address(target)}, {name}.copy, {name}.hits, {name}.last, {name}.at, {name}.predicate_now());',
                          '    $display("wakes=%0d wt=%0d held=%b",', f'             {name}.wakes, {name}.wt, {name}.held);'])
            expected.append(f'o name={name} data={value} copy={value} hits={state["hits"]} last={state["last"]} '
                            f'at={state["at"]} pred={predicate} wakes={state["wakes"]} wt={state["wt"]} held={state["held"]}')
    snapshot('armed', 2)
    for step, operation in enumerate(stimuli['operations'], 1):
        target, drive = operation['target'], operation['data'];tick = step*5
        lines += ['    #3;' if step == 1 else '    #4;', f'    drive = {conditional.literal(drive)};',
                  f'    {address(target)} '+('<=' if p['update'] == 'nba' else '=')+' drive;',
                  f'    $display("drive step={step} t=%0d raw=%b active=%b", $time, drive, {address(target)});', '    #1;']
        old, value = values[target], convert(drive)
        expected.append(f'drive step={step} t={tick} raw={drive} active={value if p["update"] == "blocking" else old}')
        values[target] = value
        if target in history:
            state = history[target]
            if (old if p['event'] == 'full' else old[-1]) != (value if p['event'] == 'full' else value[-1]):
                state.update(hits=state['hits']+1, last=value, at=tick)
            if value == zero and not state['wakes']:state.update(wakes=1, wt=tick, held=value)
        snapshot(str(step), tick+1)
    lines += ['    #4;']
    snapshot('idle', len(stimuli['operations'])*5+5)
    return lines, expected


def generate_shift(rng, steps):
    w = rng.choice(WIDTHS)
    p = {'width': w, 'sign': rng.choice(('signed', 'unsigned')), 'operator': rng.choice(tuple(shifts.OPS)),
         'relation': rng.choice(('same', 'wide') if w == 1 else ('narrow', 'same', 'wide')),
         'state': rng.choice(('bit', 'logic')), 'count_width': rng.choice((8, 32, 65)),
         'count_sign': rng.choice(('signed', 'unsigned'))}
    n = w + int(p['relation'] == 'wide')
    vectors = []
    for _ in range(steps):
        # Counts are self-determined. Include huge known counts without any
        # allocation proportional to their value, plus partially unknown counts.
        count = (f'{rng.choice((0, 1, w-1, w, w+1, n, n+1, (1 << p["count_width"])-1)):0{p["count_width"]}b}'
                 if rng.randrange(2) == 0 else word(rng, p['count_width'], True))
        vectors.append({'source': word(rng, w, True), 'count': count})
    return p, vectors


def generate_cast(rng, steps):
    w = rng.choice(WIDTHS);kind = rng.choice(('size', 'signed', 'unsigned', 'typed_bit', 'typed_logic'))
    p = {'width': w, 'sign': rng.choice(('signed', 'unsigned')), 'cast': kind,
         'relation': 'same' if kind in ('signed', 'unsigned') else rng.choice(
             ('same', 'wide') if w == 1 else ('narrow', 'same', 'wide')),
         'operation': rng.choice(('plain', 'add')), 'state': rng.choice(('bit', 'logic'))}
    return p, [{'source': word(rng, w, True)} for _ in range(steps)]


def validate_bit_profile(profile, p, vectors):
    shift = profile == 'shift_context'
    keys(p, ('width', 'sign', 'operator', 'relation', 'state', 'count_width', 'count_sign') if shift else
         ('width', 'sign', 'cast', 'relation', 'operation', 'state'))
    w = integer(p['width'], 1, 129, 'width')
    if w not in WIDTHS or p['sign'] not in ('signed', 'unsigned') or p['state'] not in ('bit', 'logic') or (
            p['relation'] not in ('narrow', 'same', 'wide')) or (w == 1 and p['relation'] == 'narrow'):
        raise ValueError('invalid bit-profile parameter')
    if shift:
        cw = integer(p['count_width'], 8, 65, 'count width')
        if cw not in (8, 32, 65) or p['count_sign'] not in ('signed', 'unsigned') or p['operator'] not in tuple(shifts.OPS):
            raise ValueError('invalid shift parameter')
    elif p['cast'] not in ('size', 'signed', 'unsigned', 'typed_bit', 'typed_logic') or (
            p['cast'] in ('signed', 'unsigned') and p['relation'] != 'same') or p['operation'] not in ('plain', 'add'):
        raise ValueError('invalid cast parameter')
    if not isinstance(vectors, list):raise ValueError('vectors must be a list')
    integer(len(vectors), 1, MAX_STIMULI, 'vectors')
    for vector in vectors:
        keys(vector, ('source', 'count') if shift else ('source',))
        bits(vector['source'], w, True)
        if shift:bits(vector['count'], p['count_width'], True)


def materialize_shift(case):
    p = case['parameters'];w = p['width'];wr = w + {'narrow': -1, 'same': 0, 'wide': 1}[p['relation']]
    lines = [f'module random_cross_{case["id"]};', f'  logic {p["sign"]} [{w-1}:0] source;',
             f'  logic {p["count_sign"]} [{p["count_width"]-1}:0] count;',
             f'  {p["state"]} [{wr-1}:0] result;', '  initial begin']
    expected = []
    for index, vector in enumerate(case['stimuli']):
        source, count = vector['source'], vector['count']
        lines += [f'    source = {conditional.literal(source)};', f'    count = {conditional.literal(count)};',
                  f'    result = source {shifts.OPS[p["operator"]]} count;',
                  f'    $display("v{index}_source=%b count=%b", source, count);',
                  f'    $display("v{index}_result=%b", result);']
        operand = bit_values.resize(source, max(w, wr), p['sign'] == 'signed')
        if set(count) & set('xz'):
            value = 'x'*len(operand)
        else:
            amount = int(count, 2)
            fill = operand[0] if p['operator'] == 'ashr' and p['sign'] == 'signed' else '0'
            def at(position):
                origin = position+amount if p['operator'] in ('shl', 'ashl') else position-amount
                return operand[origin] if 0 <= origin < len(operand) else fill
            value = ''.join(at(i) for i in range(len(operand)))
        value = value[-wr:]
        if p['state'] == 'bit':value = bit_values.two_state(value)
        expected += [f'v{index}_source={source} count={count}', f'v{index}_result={value}']
    return lines, expected


def materialize_cast(case):
    p = case['parameters'];w = p['width'];cw = w + {'narrow': -1, 'same': 0, 'wide': 1}[p['relation']]
    kind = p['cast']
    expression = f"{cw}'(source)" if kind == 'size' else "cast_t'(source)" if kind.startswith('typed_') else f"{kind}'(source)"
    lines = [f'module random_cross_{case["id"]};', f'  logic {p["sign"]} [{w-1}:0] source;',
             f'  {p["state"]} [{w+1}:0] result;']
    if kind.startswith('typed_'):lines += [f'  typedef {kind[6:]} [{cw-1}:0] cast_t;']
    lines += ['  initial begin'];expected = []
    for index, vector in enumerate(case['stimuli']):
        source = vector['source'];signed = p['sign'] == 'signed'
        if kind in ('signed', 'unsigned'):
            intermediate = source;signed = kind == 'signed'
        else:
            intermediate = bit_values.resize(source, cw, signed)
            if kind.startswith('typed_'):
                signed = False
                if kind == 'typed_bit':intermediate = bit_values.two_state(intermediate)
        value = bit_values.resize(intermediate, w+2, signed)
        if p['operation'] == 'add':
            value = 'x'*(w+2) if set(value)&set('xz') else f'{(int(value,2)+1) % (1 << (w+2)):0{w+2}b}'
        if p['state'] == 'bit':value = bit_values.two_state(value)
        lines += [f'    source = {conditional.literal(source)};',
                  f'    result = {expression}'+(" + 2'sb01;" if p['operation'] == 'add' else ';'),
                  f'    $display("v{index}_source=%b", source);', f'    $display("v{index}_cast=%b", {expression});',
                  f'    $display("v{index}_result=%b", result);']
        expected += [f'v{index}_source={source}', f'v{index}_cast={intermediate}', f'v{index}_result={value}']
    return lines, expected


def generate_stream(rng, steps):
    w = rng.choice(WIDTHS)
    p = {'width': w, 'direction': rng.choice(('left', 'right')),
         'slice': rng.choice((1, 2, 3, 4, 7, 8, 16, 17, 32, 33, w, w+1, w+3)),
         'form': rng.choice(('plain', 'tagged')), 'operation': rng.choice(('pack', 'unpack')),
         'state': rng.choice(('bit', 'logic'))}
    vectors = []
    for _ in range(steps):
        vector = {'source': word(rng, w, True)}
        if p['form'] == 'tagged':vector['tag'] = word(rng, 3, True)
        vectors.append(vector)
    return p, vectors


def validate_stream(p, vectors):
    keys(p, ('width', 'direction', 'slice', 'form', 'operation', 'state'))
    w = integer(p['width'], 1, 129, 'width');integer(p['slice'], 1, 132, 'slice')
    if w not in WIDTHS or p['direction'] not in ('left', 'right') or p['form'] not in ('plain', 'tagged') or (
            p['operation'] not in ('pack', 'unpack')) or p['state'] not in ('bit', 'logic'):
        raise ValueError('invalid streaming parameter')
    if not isinstance(vectors, list):raise ValueError('vectors must be a list')
    integer(len(vectors), 1, MAX_STIMULI, 'vectors')
    for vector in vectors:
        keys(vector, ('source', 'tag') if p['form'] == 'tagged' else ('source',))
        bits(vector['source'], w, True)
        if p['form'] == 'tagged':bits(vector['tag'], 3, True)


def materialize_stream(case):
    p = case['parameters'];w = p['width'];tagged = p['form'] == 'tagged';n = w+3*tagged
    symbol = '<<' if p['direction'] == 'left' else '>>';size = p['slice']
    operands = 'tag, source' if tagged else 'source'
    lines = [f'module random_cross_{case["id"]};', f'  logic [{w-1}:0] source;', '  logic [2:0] tag;',
             f'  logic [{n-1}:0] incoming;', f'  {p["state"]} [{n-1}:0] result;', '  initial begin']
    expected = []
    for index, vector in enumerate(case['stimuli']):
        source = vector['source'];incoming = vector.get('tag', '')+source
        lines += [f'    source = {conditional.literal(source)};']
        if tagged:lines += [f'    tag = {conditional.literal(vector["tag"])};']
        lines += [f'    incoming = {{{operands}}};']
        lines += [f'    result = {{{symbol}{size}{{{operands}}}}};'] if p['operation'] == 'pack' else [
            f'    {{{symbol}{size}{{result}}}} = incoming;']
        lines += [f'    $display("v{index}_source=%b incoming=%b", source, incoming);',
                  f'    $display("v{index}_result=%b", result);']
        value = streams.reorder(incoming, p['direction'], size, p['operation'] == 'unpack')
        if p['state'] == 'bit':value = bit_values.two_state(value)
        expected += [f'v{index}_source={source} incoming={incoming}', f'v{index}_result={value}']
    return lines, expected


def generate_concat(rng, steps):
    w = rng.choice((2, 32, 33, 64, 65, 129));left = rng.randrange(1, w)
    relation = rng.choice(('narrow', 'same', 'wide'));sw = w+{'narrow': -1, 'same': 0, 'wide': 1}[relation]
    p = {'width': w, 'left_width': left, 'rhs_relation': relation, 'rhs_sign': rng.choice(('signed', 'unsigned')),
         'states': rng.choice(tuple(concatenation.STATES)), 'member_sign': rng.choice(('signed', 'unsigned')),
         'update': rng.choice(('blocking', 'nba'))}
    initial_left, initial_right = word(rng, left, True), word(rng, w-left, True)
    operations = []
    for _ in range(steps):
        operations.append(dict(operations[-1]) if operations and rng.randrange(4) == 0 else
                          {'source': word(rng, sw, True), 'after': word(rng, sw, True)})
    return p, {'initial_left': initial_left, 'initial_right': initial_right, 'operations': operations}


def validate_concat(p, stimuli):
    keys(p, ('width', 'left_width', 'rhs_relation', 'rhs_sign', 'states', 'member_sign', 'update'))
    w = integer(p['width'], 2, 129, 'width');left = integer(p['left_width'], 1, w-1, 'left width')
    if w not in (2, 32, 33, 64, 65, 129) or p['rhs_relation'] not in ('narrow', 'same', 'wide') or (
            p['rhs_sign'] not in ('signed', 'unsigned')) or p['states'] not in tuple(concatenation.STATES) or (
            p['member_sign'] not in ('signed', 'unsigned')) or p['update'] not in ('blocking', 'nba'):
        raise ValueError('invalid concatenation parameter')
    sw = w+{'narrow': -1, 'same': 0, 'wide': 1}[p['rhs_relation']]
    keys(stimuli, ('initial_left', 'initial_right', 'operations'))
    bits(stimuli['initial_left'], left, True);bits(stimuli['initial_right'], w-left, True)
    if not isinstance(stimuli['operations'], list):raise ValueError('operations must be a list')
    integer(len(stimuli['operations']), 1, MAX_STIMULI, 'operations')
    for op in stimuli['operations']:
        keys(op, ('source', 'after'));bits(op['source'], sw, True);bits(op['after'], sw, True)


def materialize_concat(case):
    p, stimuli = case['parameters'], case['stimuli'];w = p['width'];left = p['left_width'];right = w-left
    sw = w+{'narrow': -1, 'same': 0, 'wide': 1}[p['rhs_relation']];ls, rs = concatenation.STATES[p['states']]
    convert = lambda value, state: bit_values.two_state(value) if state == 'bit' else value
    a, b = convert(stimuli['initial_left'], ls), convert(stimuli['initial_right'], rs)
    lines = ['`timescale 1ns/1ns', f'module random_cross_{case["id"]};',
             f'  {ls} {p["member_sign"]} [{left-1}:0] left;', f'  {rs} {p["member_sign"]} [{right-1}:0] right;',
             f'  logic {p["rhs_sign"]} [{sw-1}:0] source;', f'  logic [{left}:0] left_wide;',
             f'  logic [{right}:0] right_wide;', f'  logic [{w}:0] concat_wide;', '  initial begin',
             f'    left = {conditional.literal(stimuli["initial_left"])};',
             f'    right = {conditional.literal(stimuli["initial_right"])};', '    $display("initial=%b %b", left, right);']
    expected = [f'initial={a} {b}']
    for index, op in enumerate(stimuli['operations']):
        fitted = bit_values.resize(op['source'], w, p['rhs_sign'] == 'signed')
        na, nb = convert(fitted[:left], ls), convert(fitted[left:], rs)
        immediate = (a, b) if p['update'] == 'nba' else (na, nb)
        lines += [f'    source = {conditional.literal(op["source"])};', f'    $display("v{index}_input=%b", source);',
                  '    {left, right} '+('<=' if p['update'] == 'nba' else '=')+' source;',
                  f'    $display("v{index}_scheduled=%b %b", left, right);',
                  f'    source = {conditional.literal(op["after"])};', f'    $display("v{index}_changed=%b", source);', '    #1;',
                  '    left_wide = left; right_wide = right; concat_wide = {left, right};',
                  f'    $display("v{index}_final=%b %b", left, right);',
                  f'    $display("v{index}_wide=%b %b concat=%b", left_wide, right_wide, concat_wide);']
        a, b = na, nb;signed = p['member_sign'] == 'signed'
        expected += [f'v{index}_input={op["source"]}', f'v{index}_scheduled={immediate[0]} {immediate[1]}',
                     f'v{index}_changed={op["after"]}', f'v{index}_final={a} {b}',
                     f'v{index}_wide={bit_values.resize(a,left+1,signed)} {bit_values.resize(b,right+1,signed)} concat=0{a}{b}']
    return lines, expected


def generate_comparison(rng, steps):
    w = rng.choice(WIDTHS)
    p = {'width': w, 'rhs_relation': rng.choice(('same', 'wide') if w == 1 else ('narrow', 'same', 'wide')),
         'sign_a': rng.choice(('signed', 'unsigned')), 'sign_b': rng.choice(('signed', 'unsigned')),
         'operator': rng.choice(tuple(comparisons.OPERATORS)), 'result_width': rng.choice((1, 7, 33, 65, 130))}
    wb = w+{'narrow': -1, 'same': 0, 'wide': 1}[p['rhs_relation']]
    vectors = []
    for _ in range(steps):
        a = word(rng, w, True)
        b = bit_values.resize(a, wb, p['sign_a'] == p['sign_b'] == 'signed') if rng.randrange(4) == 0 else word(rng, wb, True)
        vectors.append({'a': a, 'b': b})
    return p, vectors


def validate_comparison(p, vectors):
    keys(p, ('width', 'rhs_relation', 'sign_a', 'sign_b', 'operator', 'result_width'))
    w = integer(p['width'], 1, 129, 'width');integer(p['result_width'], 1, 130, 'result width')
    if w not in WIDTHS or p['rhs_relation'] not in ('narrow', 'same', 'wide') or (
            w == 1 and p['rhs_relation'] == 'narrow') or p['sign_a'] not in ('signed', 'unsigned') or (
            p['sign_b'] not in ('signed', 'unsigned')) or p['operator'] not in tuple(comparisons.OPERATORS):
        raise ValueError('invalid comparison parameter')
    wb = w+{'narrow': -1, 'same': 0, 'wide': 1}[p['rhs_relation']]
    if not isinstance(vectors, list):raise ValueError('vectors must be a list')
    integer(len(vectors), 1, MAX_STIMULI, 'vectors')
    for vector in vectors:
        keys(vector, ('a', 'b'));bits(vector['a'], w, True);bits(vector['b'], wb, True)


def materialize_comparison(case):
    p = case['parameters'];w = p['width'];wb = w+{'narrow': -1, 'same': 0, 'wide': 1}[p['rhs_relation']];wr = p['result_width']
    expr = 'a '+comparisons.OPERATORS[p['operator']]+' b'
    lines = [f'module random_cross_{case["id"]};', f'  logic {p["sign_a"]} [{w-1}:0] a;',
             f'  logic {p["sign_b"]} [{wb-1}:0] b;', '  logic raw;',
             f'  logic [{wr-1}:0] wide;', f'  bit [{wr-1}:0] binary;', '  initial begin']
    expected = []
    for index, vector in enumerate(case['stimuli']):
        a, b = vector['a'], vector['b'];r = comparisons.compare(a, b, p['sign_a'], p['sign_b'], p['operator'])
        lines += [f'    a = {conditional.literal(a)}; b = {conditional.literal(b)};',
                  f'    raw = {expr}; wide = {expr}; binary = {expr};',
                  f'    $display("v{index}_inputs=%b %b", a, b);',
                  f'    $display("v{index}_result=%b wide=%b binary=%b bits=%0d", raw, wide, binary, $bits({expr}));']
        expected += [f'v{index}_inputs={a} {b}',
                     f'v{index}_result={r} wide={"0"*(wr-1)+r} binary={"0"*(wr-1)+bit_values.two_state(r)} bits=1']
    return lines, expected


def generate_logic(rng, steps):
    w = rng.choice(WIDTHS);shape = rng.choice(('direct', 'slice', 'prefix_zero', 'prefix_one'))
    span = rng.randint(1, w) if shape == 'slice' else w
    p = {'width': w, 'state': rng.choice(('bit', 'logic')), 'sign': rng.choice(('signed', 'unsigned')),
         'shape': shape, 'span': span, 'offset': rng.randrange(w-span+1) if shape == 'slice' else 0,
         'result_state': rng.choice(('bit', 'logic')), 'result_width': rng.choice((1, 7, 33, 65, 130))}
    return p, [{'source': word(rng, w, True)} for _ in range(steps)]


def validate_logic(p, vectors):
    keys(p, ('width', 'state', 'sign', 'shape', 'span', 'offset', 'result_state', 'result_width'))
    w = integer(p['width'], 1, 129, 'width');span = integer(p['span'], 1, w, 'span')
    integer(p['offset'], 0, w-span, 'offset');integer(p['result_width'], 1, 130, 'result width')
    if w not in WIDTHS or p['state'] not in ('bit', 'logic') or p['result_state'] not in ('bit', 'logic') or (
            p['sign'] not in ('signed', 'unsigned')) or p['shape'] not in ('direct', 'slice', 'prefix_zero', 'prefix_one') or (
            p['shape'] != 'slice' and (span != w or p['offset'] != 0)):
        raise ValueError('invalid logical-reduction parameter')
    if not isinstance(vectors, list):raise ValueError('vectors must be a list')
    integer(len(vectors), 1, MAX_STIMULI, 'vectors')
    for vector in vectors:keys(vector, ('source',));bits(vector['source'], w, True)


def materialize_logic(case):
    p = case['parameters'];w, span, offset, wr = (p[key] for key in ('width', 'span', 'offset', 'result_width'))
    shape = p['shape']
    expr = f'source[{offset+span-1}:{offset}]' if shape == 'slice' else "{1'b0, source}" if shape == 'prefix_zero' else "{1'b1, source}" if shape == 'prefix_one' else 'source'
    ew = span if shape == 'slice' else w+int(shape.startswith('prefix'))
    lines = [f'module random_cross_{case["id"]};', f'  logic [{w-1}:0] raw_input;',
             f'  {p["state"]} {p["sign"]} [{w-1}:0] source;', f'  logic [{ew-1}:0] expression_bits;']
    for op in logical.OPERATORS:lines += [f'  logic r_{op};', f'  {p["result_state"]} [{wr-1}:0] wide_{op};']
    lines += ['  initial begin'];expected = []
    for index, vector in enumerate(case['stimuli']):
        raw = vector['source'];source = bit_values.two_state(raw) if p['state'] == 'bit' else raw
        operand = source[w-offset-span:w-offset] if shape == 'slice' else '0'+source if shape == 'prefix_zero' else '1'+source if shape == 'prefix_one' else source
        lines += [f'    raw_input = {conditional.literal(raw)};', '    source = raw_input;',
                  f'    expression_bits = {expr};', f'    $display("v{index}_input=%b source=%b expr=%b", raw_input, source, expression_bits);']
        expected += [f'v{index}_input={raw} source={source} expr={operand}']
        reductions = logical.evaluate(operand)
        for op, symbol in logical.OPERATORS.items():
            operation = f'{symbol}({expr})';r = reductions[op];wide = '0'*(wr-1)+r
            if p['result_state'] == 'bit':wide = bit_values.two_state(wide)
            lines += [f'    r_{op} = {operation}; wide_{op} = {operation};',
                      f'    $display("v{index}_{op}=%b wide=%b bits=%0d", r_{op}, wide_{op}, $bits({operation}));']
            expected += [f'v{index}_{op}={r} wide={wide} bits=1']
    return lines, expected
