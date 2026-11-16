# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

"""Opt-in packed-boundary and packed-field operation histories.

Reference values are MSB-first character strings, not simulator outputs.
11.5.1 defines declared-label selects and clipped/unknown-address writes;
7.2.1 defines packed field order and signedness; 6.11.2, 10.7 and 11.4.10
define storage conversion, field-copy extension and whole-struct shifts.
"""

PROFILES = ('packed_bounds_sequence', 'packed_field_sequence')
WIDTHS = (1, 2, 3, 4, 7, 8, 31, 32, 33, 63, 64, 65, 127, 128, 129,
          255, 256, 257, 511, 512, 513)
LAYOUTS = ((1, 7, 1), (7, 1, 8), (31, 1, 33), (32, 32, 1),
           (1, 63, 1), (64, 1, 64), (65, 63, 1), (127, 1, 129),
           (255, 1, 255), (255, 1, 257))


def fields(value, names):
    if not isinstance(value, dict) or set(value) != set(names):
        raise ValueError('unexpected packed-profile fields')


def number(value, low, high):
    if type(value) is not int or not low <= value <= high:
        raise ValueError('packed-profile integer is out of range')
    return value


def word(value, width):
    if not isinstance(value, str) or len(value) != width or not set(value) <= set('01xz'):
        raise ValueError('invalid packed-profile bit string')


def convert(value, state):
    return value.translate(str.maketrans('xz', '00')) if state == 'bit' else value


def extend(value, width, signed):
    return value[-width:].rjust(width, value[0] if signed else '0')


def signed_index(value):
    if set(value) & set('xz'):
        return None
    raw = int(value, 2)
    return raw - (1 << 32) if value[0] == '1' else raw


def labels(p, base):
    """Return a selected part's declared labels, most significant first."""
    if base is None:
        return [None] * p['span']
    first = base if p['select'] == 'plus' else base - p['span'] + 1
    result = list(range(first, first + p['span']))
    return result[::-1] if p['direction'] == 'descending' else result


def position(p, label):
    if label is None or not p['low'] <= label < p['low'] + p['width']:
        return None
    offset = label - p['low']
    return p['width'] - 1 - offset if p['direction'] == 'descending' else offset


def select(value, p, addressed):
    return ''.join('x' if position(p, i) is None else value[position(p, i)]
                   for i in addressed)


def generate(profile, rng, steps, draw):
    if profile == PROFILES[0]:
        width = rng.choice(WIDTHS)
        span = rng.choice([n for n in (1, 2, 7, 8, 31, 32, 33, 63, 64, 65) if n <= width])
        p = {'width': width, 'span': span, 'low': rng.choice((-17, -1, 0, 5)),
             'direction': rng.choice(('ascending', 'descending')),
             'select': rng.choice(('plus', 'minus')),
             'target_state': rng.choice(('bit', 'logic'))}
        valid = p['low'] + rng.randrange(width - span + 1)
        if p['select'] == 'minus':
            valid += span - 1
        operations = []
        for step in range(steps):
            base = valid if step < 2 else rng.choice((valid, p['low'] - 1,
                   p['low'] + width - 1, p['low'] - span - 1,
                   p['low'] + width + span, None, 'z'))
            if base is None or base == 'z':
                index = list(f'{valid & 0xffffffff:032b}')
                index[rng.randrange(32)] = 'x' if base is None else 'z'
                index = ''.join(index)
            else:
                index = f'{base & 0xffffffff:032b}'
            kind = ('write', 'read')[step] if step < 2 else rng.choice(('write', 'read'))
            op = {'kind': kind, 'index': index}
            if kind == 'write':
                op['data'] = draw(rng, span, True)
            operations.append(op)
        return p, {'initial': draw(rng, width, True), 'operations': operations}
    widths = rng.choice(LAYOUTS)
    p = {'widths': list(widths), 'signs': [rng.choice(('signed', 'unsigned')) for _ in widths],
         'state': rng.choice(('bit', 'logic')),
         'aggregate_sign': rng.choice(('signed', 'unsigned'))}
    operations = []
    for step in range(steps):
        kind = ('field', 'copy', 'shift')[step] if step < 3 else rng.choice(('whole', 'field', 'copy', 'shift'))
        op = {'kind': kind}
        if kind == 'whole':
            op['data'] = draw(rng, sum(widths), True)
        elif kind == 'field':
            op['field'] = rng.randrange(3)
            op['data'] = draw(rng, widths[op['field']], True)
        elif kind == 'copy':
            op['source'], op['target'] = rng.sample(range(3), 2)
        else:
            op['amount'] = rng.choice((0, 1, 63, 64, 65, sum(widths)-1, sum(widths), sum(widths)+1))
            op['operator'] = rng.choice(('<<', '>>', '>>>'))
        operations.append(op)
    return p, {'initial': draw(rng, sum(widths), True), 'operations': operations}


def validate(case):
    p, s = case['parameters'], case['stimuli']
    fields(s, ('initial', 'operations'))
    if not isinstance(s['operations'], list):
        raise ValueError('operations must be a list')
    number(len(s['operations']), 1, 32)
    if case['profile'] == PROFILES[0]:
        fields(p, ('width', 'span', 'low', 'direction', 'select', 'target_state'))
        w = number(p['width'], 1, 513)
        if w not in WIDTHS or p['low'] not in (-17, -1, 0, 5) or type(p['low']) is not int:
            raise ValueError('unsupported packed bounds')
        number(p['span'], 1, min(w, 65))
        if p['direction'] not in ('ascending', 'descending') or p['select'] not in ('plus', 'minus') or p['target_state'] not in ('bit', 'logic'):
            raise ValueError('invalid packed selection type')
        for op in s['operations']:
            if not isinstance(op, dict) or op.get('kind') not in ('read', 'write'):
                raise ValueError('invalid packed selection operation')
            fields(op, ('kind', 'index', 'data') if op['kind'] == 'write' else ('kind', 'index'))
            word(op['index'], 32)
            if op['kind'] == 'write':
                word(op['data'], p['span'])
    else:
        fields(p, ('widths', 'signs', 'state', 'aggregate_sign'))
        if not isinstance(p['widths'], list) or len(p['widths']) != 3:
            raise ValueError('three packed fields are required')
        for n in p['widths']:
            number(n, 1, 257)
        if tuple(p['widths']) not in LAYOUTS:
            raise ValueError('unsupported packed field layout')
        if not isinstance(p['signs'], list) or len(p['signs']) != 3 or any(v not in ('signed', 'unsigned') for v in p['signs']):
            raise ValueError('invalid field signing')
        if p['state'] not in ('bit', 'logic') or p['aggregate_sign'] not in ('signed', 'unsigned'):
            raise ValueError('invalid packed structure type')
        w = sum(p['widths'])
        for op in s['operations']:
            if not isinstance(op, dict) or op.get('kind') not in ('whole', 'field', 'copy', 'shift'):
                raise ValueError('invalid packed field operation')
            kind = op['kind']
            fields(op, {'whole': ('kind', 'data'), 'field': ('kind', 'field', 'data'),
                        'copy': ('kind', 'source', 'target'), 'shift': ('kind', 'operator', 'amount')}[kind])
            if kind == 'whole':
                word(op['data'], w)
            elif kind == 'field':
                word(op['data'], p['widths'][number(op['field'], 0, 2)])
            elif kind == 'copy':
                number(op['source'], 0, 2)
                number(op['target'], 0, 2)
                if op['source'] == op['target']:
                    raise ValueError('copy requires different fields')
            else:
                number(op['amount'], 0, max(65, w + 1))
                if op['operator'] not in ('<<', '>>', '>>>'):
                    raise ValueError('invalid packed shift operator')
    word(s['initial'], w)


def requires_fourstate(case):
    def unknown(value):
        if isinstance(value, dict):
            return any(unknown(v) for v in value.values())
        if isinstance(value, list):
            return any(unknown(v) for v in value)
        return isinstance(value, str) and set(value) <= set('01xz') and bool(set(value) & set('xz'))
    if unknown(case['stimuli']):
        return True
    if case['profile'] == PROFILES[0]:
        p = case['parameters']
        for operation in case['stimuli']['operations']:
            base = signed_index(operation['index'])
            if position(p, base) is None or any(position(p, i) is None for i in labels(p, base)):
                return True
    return False


def materialize(case):
    return bounds(case) if case['profile'] == PROFILES[0] else structure(case)


def bounds(case):
    p, s = case['parameters'], case['stimuli']
    w, span = p['width'], p['span']
    lo, hi = p['low'], p['low'] + w - 1
    left, right = (hi, lo) if p['direction'] == 'descending' else (lo, hi)
    operator = '+:' if p['select'] == 'plus' else '-:'
    part = f'value[index {operator} {span}]'
    lines = [f'module random_cross_{case["id"]};', f'  logic [{left}:{right}] value;',
             '  logic signed [31:0] index;', f'  {p["target_state"]} [{span-1}:0] selected;',
             '  logic single;', '  initial begin', f"    value = {w}'b{s['initial']};",
             '    $display("initial=%b", value);']
    state = s['initial']
    expected = ['initial=' + state]
    for step, op in enumerate(s['operations']):
        base = signed_index(op['index'])
        addressed = labels(p, base)
        lines += [f"    index = 32'sb{op['index']};"]
        if op['kind'] == 'write':
            lines += [f"    {part} = {span}'b{op['data']};"]
            changed = list(state)
            for i, bit in zip(addressed, op['data']):
                at = position(p, i)
                if at is not None:
                    changed[at] = bit
            state = ''.join(changed)
        lines += [f'    selected = {part};', '    single = value[index];',
                  f'    $display("step={step} kind={op["kind"]} index=%b whole=%b slice=%b bit=%b",',
                  '             index, value, selected, single);']
        expected += [f'step={step} kind={op["kind"]} index={op["index"]} whole={state} '
                     f'slice={convert(select(state, p, addressed), p["target_state"])} '
                     f'bit={select(state, p, [base])}']
    return lines, expected, '11.5.1 7.4.1 6.11.2'


def structure(case):
    p, s = case['parameters'], case['stimuli']
    widths, signs = p['widths'], p['signs']
    w = sum(widths)
    lines = [f'module random_cross_{case["id"]};',
             f'  typedef struct packed {p["aggregate_sign"]} {{']
    for i, (n, sign) in enumerate(zip(widths, signs)):
        lines += [f'    {p["state"]} {sign} [{n-1}:0] f{i};']
    lines += ['  } record_t;', '  record_t value;']
    for i, n in enumerate(widths):
        lines += [f'  logic [{n+2}:0] extended{i};']
    lines += ['  initial begin', f"    value = {w}'b{s['initial']};"]
    state = convert(s['initial'], p['state'])
    expected = []

    def split(value):
        at = 0
        values = []
        for n in widths:
            values.append(value[at:at+n])
            at += n
        return values

    def observe(label):
        values = split(state)
        for i in range(3):
            lines.append(f'    extended{i} = value.f{i};')
        lines.extend([f'    $display("{label} whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",',
                      '             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);'])
        expected.append(f'{label} whole={state} ' + ' '.join(f'f{i}={v}' for i, v in enumerate(values))
                        + ' ' + ' '.join(f'e{i}={extend(v, widths[i]+3, signs[i] == "signed")}'
                                         for i, v in enumerate(values)))

    observe('initial')
    for step, op in enumerate(s['operations']):
        kind = op['kind']
        if kind == 'whole':
            lines += [f"    value = {w}'b{op['data']};"]
            state = convert(op['data'], p['state'])
        elif kind in ('field', 'copy'):
            values = split(state)
            target = op['field'] if kind == 'field' else op['target']
            if kind == 'field':
                lines += [f"    value.f{target} = {widths[target]}'b{op['data']};"]
                value = op['data']
            else:
                source = op['source']
                lines += [f'    value.f{target} = value.f{source};']
                value = extend(values[source], widths[target], signs[source] == 'signed')
            values[target] = convert(value, p['state'])
            state = ''.join(values)
        else:
            amount = op['amount']
            lines += [f'    value = value {op["operator"]} {amount};']
            if op['operator'] == '<<':
                state = (state + '0' * amount)[-w:]
            else:
                fill = state[0] if op['operator'] == '>>>' and p['aggregate_sign'] == 'signed' else '0'
                state = (fill * amount + state)[:w]
        observe(f'step={step} kind={kind}')
    return lines, expected, '7.2.1 6.11.2 10.7 11.4.10 11.8.1'
