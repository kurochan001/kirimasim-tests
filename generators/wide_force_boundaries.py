# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Lift existing deterministic force phases to wide words with guarded net slices.

Keep the old scheduler fixture and phase model intact. Query programs also
print complete values so popcount equality cannot hide misplaced forced bits.
"""
from dataclasses import replace
import re
import interaction_force as forces
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_force_boundaries'
VERSION = 1
CHAPTER = 10
WIDTHS = (255, 256, 257, 511, 512, 513)
TARGETS = ('var', 'cont', 'pca', 'net', 'part', 'wor')
CONFIGURATIONS = tuple(row for index, target in enumerate(TARGETS) for row in (
    (target, 'const', 'driver', 'blocking', 'display', 'direct'),
    (target, 'expr', 'source', 'nba', 'display', 'direct'),
    (target, 'unknown', 'driver', 'nba' if index % 2 else 'blocking',
     'query', ('direct', 'task', 'hier')[index % 3]),
))


def lift(value, width):
    if len(value) == 8:
        return value[:2]+lift(value[2:6], width)+value[6:]
    assert len(value) == 4
    return (value*((width+3)//4))[-width:]


def reference(width, configuration):
    target, _, _, _, observer, _ = configuration
    lines = []
    for time, label, original in forces.history(configuration):
        value = lift(original, width)
        if observer == 'display':
            if label == 'release' and target in forces.IMMEDIATE:
                lines.append(f'{time} r {value}')
            lines.append(f'{time+1} {value}')
        else:
            assert observer == 'query'
            lines.append(f'{time+1} {value.count("1")} '
                         f'{int(any(bit in "xz" for bit in value))} {len(value)}')
            lines.append(f'{time+1} bits={value}')
    return '\n'.join(lines)+'\n'


def make_case(width, configuration):
    original = forces.make_case(configuration)
    target, _, _, _, observer, site = configuration
    name = original.name.replace('test_gen_cross_force_', f'test_gen_wide_force_w{width}_', 1)
    body = original.body.replace('module '+original.name+';', 'module '+name+';', 1)

    def literal(match):
        size, value = int(match[1]), match[2]
        assert len(value) == size
        bits = lift(value, width)
        return f"{len(bits)}'b{bits}"

    body = re.sub(r"(?<![\w'])(4|8)'b([01xz]+)", literal, body)
    body = body.replace('[7:0]', f'[{width+3}:0]')
    body = body.replace('[3:0]', f'[{width-1}:0]')
    body = body.replace('[5:2]', f'[{width+1}:2]')
    if observer == 'query':
        observed = 'u.t' if site == 'hier' else 't'
        query = (f'$display("%0d %0d %0d %0d", $time, $countones({observed}), '
                 f'$isunknown({observed}), $bits({observed}));')
        assert body.count(query) == len(forces.history(configuration))
        body = body.replace(query, query+'\n    '+
                            f'$display("%0d bits=%b", $time, {observed});')
    clauses = ('10.6.2 '+forces.TARGET_CLAUSE[target]+' '+
               forces.OBSERVER_CLAUSE[observer]+' 4.4 6.11.2 11.4.12')
    if observer == 'query':
        clauses += ' 20.6.2'
    clauses = ' '.join(dict.fromkeys((clauses+' 21.2.1').split()))
    note = ('Wide force/release phases reuse the existing deterministic scheduler '
            'fixture and phase reference. Four-bit data patterns repeat to W bits; '
            'the net-part target has W+4 bits and preserves two guards at each end '
            'around the W-bit forced slice. Variables, continuously driven variables, '
            'procedural continuous assignments, nets, net slices and wired-or drivers '
            'retain their distinct release behavior. Constants, source-following '
            'expressions and explicit X/Z forces are observed across driver/source '
            'changes. Unknown-force queries also print full bit values. Eighteen '
            'frozen configurations do not expand old finite-model rows or bindings; '
            'variable slices, user-defined nettypes, strengths and force stacks are '
            'outside this scope.')
    return replace(original, name=name,
                   body=wrap_generated_unsigned_literals(body),
                   expected=reference(width, configuration), lrm=clauses,
                   comment=note, extra={})


def cases():
    return [make_case(width, configuration)
            for width in WIDTHS for configuration in CONFIGURATIONS]
