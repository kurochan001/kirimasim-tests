# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Reuse typed memory-file semantics beyond the original 129-bit model.

The 23 projected configurations are frozen regressions, not new rows or
bindings in the existing finite interaction model. Wide literal wrapping
preserves each expression's exact unsigned bit width and bit order.
"""
from dataclasses import replace
from wide_literals import wrap_generated_unsigned_literals
from interaction_memfile import make_case as memory_case

NAME = 'memory_file_boundaries'
VERSION = 1
CHAPTER = 21
WIDTHS = (255, 256, 257, 511, 512, 513)
CONFIGURATIONS = (
    ('bit', 'enum', 'known', 'bin', 'single', 'up', 'bit', 'forward'),
    ('bit', 'enum', 'known', 'hex', 'all', 'up', 'bit', 'forward'),
    ('bit', 'enum', 'x', 'bin', 'single', 'up', 'bit', 'forward'),
    ('bit', 'enum', 'x', 'hex', 'single', 'up', 'logic', 'forward'),
    ('bit', 'enum', 'z', 'bin', 'all', 'up', 'bit', 'reverse'),
    ('bit', 'plain', 'known', 'bin', 'all', 'up', 'bit', 'forward'),
    ('bit', 'plain', 'known', 'bin', 'all', 'up', 'logic', 'forward'),
    ('bit', 'plain', 'known', 'hex', 'all', 'down', 'bit', 'forward'),
    ('bit', 'plain', 'known', 'hex', 'single', 'up', 'logic', 'forward'),
    ('bit', 'plain', 'x', 'bin', 'all', 'up', 'bit', 'forward'),
    ('bit', 'plain', 'x', 'hex', 'middle', 'up', 'bit', 'forward'),
    ('bit', 'plain', 'z', 'bin', 'all', 'up', 'bit', 'forward'),
    ('bit', 'plain', 'z', 'bin', 'single', 'down', 'logic', 'forward'),
    ('bit', 'plain', 'z', 'hex', 'middle', 'up', 'logic', 'reverse'),
    ('logic', 'enum', 'known', 'bin', 'middle', 'up', 'bit', 'reverse'),
    ('logic', 'enum', 'x', 'bin', 'single', 'down', 'bit', 'forward'),
    ('logic', 'enum', 'z', 'hex', 'middle', 'down', 'bit', 'reverse'),
    ('logic', 'plain', 'known', 'bin', 'all', 'up', 'bit', 'forward'),
    ('logic', 'plain', 'known', 'bin', 'middle', 'down', 'bit', 'forward'),
    ('logic', 'plain', 'x', 'bin', 'all', 'down', 'logic', 'reverse'),
    ('logic', 'plain', 'x', 'bin', 'all', 'up', 'bit', 'forward'),
    ('logic', 'plain', 'z', 'bin', 'all', 'up', 'bit', 'forward'),
    ('logic', 'plain', 'z', 'bin', 'middle', 'up', 'logic', 'reverse'),
)


def make_case(width, configuration):
    row = (str(width), *configuration)
    original = memory_case(row)
    name = 'test_gen_memory_file_boundary_' + '_'.join(row)
    body = original.body.replace('module '+original.name+';', 'module '+name+';', 1)
    body = wrap_generated_unsigned_literals(body)
    # Do not let the opening star close with the first body slash.
    # This correction is local to the extension; existing inputs stay intact.
    old = "else if (c == 8'd42) state = 3;"
    assert body.count(old) == 1
    body = body.replace(old, "else if (c == 8'd42) state = 4;", 1)
    old = "        3: if (previous == 8'd42 && c == 8'd47) state = 0;"
    assert body.count(old) == 1
    body = body.replace(old, "        4: state = 3;\n" + old, 1)
    old = '/* @ inside a block comment */'
    assert body.count(old) == (3 if configuration[2] == 'known' else 6)
    body = body.replace(old, '/*/ @ inside a valid block comment */')
    note = (original.comment + ' This extension freezes 23 projected configurations at each '
            'new width without changing the original finite model, its rows or its bindings. '
            'Literal concatenations preserve exact source widths; memory-file creation, '
            'independent canonical input, conversion and expected-value logic are reused. '
            'A separate just-opened-block scanner state handles a valid block comment '
            'whose first body character is a slash.')
    clauses = ['21.5', '21.5.1', '21.5.3', '21.4', '21.4.1',
               '6.24.1', '7.4.3', '11.4.12', '5.4']
    source_state, kind, _, _, _, _, target_state, _ = configuration
    if source_state == 'bit' or kind == 'enum':
        clauses.append('21.5.2')
    if target_state == 'bit':
        clauses.append('21.4.2')
    if 'bit' in (source_state, target_state):
        clauses.append('6.11.2')
    if kind == 'enum':
        clauses.append('6.19.4')
    return replace(original, name=name, body=body, comment=note,
                   lrm=' '.join(clauses), extra={})


def cases():
    return [make_case(width, configuration) for width in WIDTHS
            for configuration in CONFIGURATIONS]
