# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Opt-in integral powers with arbitrary data and self-determined exponents.

Reuse the fixed standard-based power reference. Materialized inputs, natural
width results, context results and conversion observations remain separate.
Unknown bases raised to zero are excluded from this bounded profile.
"""
from power_boundaries import power
from interaction_bits import resize, two_state

PROFILES = ('integral_power_context',)
WIDTHS = (2, 7, 31, 32, 33, 63, 64, 65, 127, 128, 129, 255, 256, 257)
EXPONENT_WIDTHS = (3, 8, 32, 65)


def destination_width(parameters):
    width = parameters['width']
    return {'narrow': width - 1, 'same': width, 'wide': 2 * width + 1}[parameters['relation']]


def generate(profile, rng, steps, draw):
    if profile not in PROFILES:
        raise ValueError('unknown integral-power profile')
    p = {'width': rng.choice(WIDTHS), 'exponent_width': rng.choice(EXPONENT_WIDTHS),
         'base_sign': rng.choice(('signed', 'unsigned')),
         'exponent_sign': rng.choice(('signed', 'unsigned')),
         'relation': rng.choice(('narrow', 'same', 'wide')),
         'state': rng.choice(('bit', 'logic'))}
    width, ew = p['width'], p['exponent_width']
    mask = (1 << ew) - 1
    boundaries = (0, 1, 2, 3, 7, -1, -2, -3,
                  1 << (ew - 1), (1 << (ew - 1)) - 1,
                  1 << min(32, ew - 1), (1 << min(64, ew - 1)) + 1)
    stimuli = []
    for _ in range(steps):
        base = draw(rng, width, True)
        exponent = (f'{rng.choice(boundaries) & mask:0{ew}b}'
                    if rng.randrange(4) else draw(rng, ew, True))
        # Keep the unknown-base/zero-exponent special case outside this scope.
        if set(base) & set('xz') and set(exponent) == {'0'}:
            exponent = '0' * (ew - 1) + '1'
        stimuli.append({'base': base, 'exponent': exponent})
    return p, stimuli


def validate(case):
    p, vectors = case['parameters'], case['stimuli']
    if (not isinstance(p, dict) or set(p) != {'width', 'exponent_width', 'base_sign',
            'exponent_sign', 'relation', 'state'} or type(p['width']) is not int
            or p['width'] not in WIDTHS or type(p['exponent_width']) is not int
            or p['exponent_width'] not in EXPONENT_WIDTHS
            or p['base_sign'] not in ('signed', 'unsigned')
            or p['exponent_sign'] not in ('signed', 'unsigned')
            or p['relation'] not in ('narrow', 'same', 'wide')
            or p['state'] not in ('bit', 'logic')):
        raise ValueError('invalid integral-power parameters')
    if not isinstance(vectors, list) or not 1 <= len(vectors) <= 32:
        raise ValueError('invalid integral-power vector count')
    for vector in vectors:
        if not isinstance(vector, dict) or set(vector) != {'base', 'exponent'}:
            raise ValueError('invalid integral-power vector fields')
        for name, width in [('base', p['width']), ('exponent', p['exponent_width'])]:
            value = vector[name]
            if not isinstance(value, str) or len(value) != width or not set(value) <= set('01xz'):
                raise ValueError('invalid integral-power input bits')
        if set(vector['base']) & set('xz') and set(vector['exponent']) == {'0'}:
            raise ValueError('unknown base raised to zero is outside this profile')


def requires_fourstate(case):
    p = case['parameters']
    for vector in case['stimuli']:
        if set(vector['base'] + vector['exponent']) & set('xz'):
            return True
        if (p['exponent_sign'] == 'signed' and vector['exponent'][0] == '1'
                and set(vector['base']) == {'0'}):
            return True
    return False


def materialize(case):
    p, vectors = case['parameters'], case['stimuli']
    width, ew, rw = p['width'], p['exponent_width'], destination_width(p)
    signed, esigned = p['base_sign'] == 'signed', p['exponent_sign'] == 'signed'
    lines = [f'module random_cross_{case["id"]};',
             f'  logic {p["base_sign"]} [{width-1}:0] base, narrow;',
             f'  logic {p["exponent_sign"]} [{ew-1}:0] exponent;',
             f'  logic [{rw-1}:0] full, captured;',
             f'  {p["state"]} [{rw-1}:0] stored;',
             f'  bit [{rw-1}:0] converted;', '  initial begin']
    expected = []
    for index, vector in enumerate(vectors):
        base, exponent = vector['base'], vector['exponent']
        lines += [f"    base = {width}'b{base};", f"    exponent = {ew}'b{exponent};",
                  '    narrow = base ** exponent;', '    full = base ** exponent;',
                  '    captured = narrow;', '    stored = base ** exponent;',
                  '    converted = full;']
        narrow = power(base, exponent, signed, esigned, width)
        full = power(base, exponent, signed, esigned, max(width, rw))[-rw:]
        captured = resize(narrow, rw, signed)
        for label, expression, value in [
                ('base', 'base', base), ('exponent', 'exponent', exponent),
                ('narrow', 'narrow', narrow), ('full', 'full', full),
                ('captured', 'captured', captured),
                ('stored', 'stored', two_state(full) if p['state'] == 'bit' else full),
                ('converted', 'converted', two_state(full))]:
            lines.append(f'    $display("v{index}_{label}=%b", {expression});')
            expected.append(f'v{index}_{label}={value}')
        lines += [f'    $display("v{index}_widths=%0d,%0d,%0d",',
                  '             $bits(base ** exponent), $bits(exponent), $bits(full));']
        expected.append(f'v{index}_widths={width},{ew},{rw}')
    return lines, expected, '11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2'
