# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Explicit wide casts before outer arithmetic and final storage.

Reuse existing clause-based source/reference code with thirty frozen non-width
configurations, without expanding old finite-model rows or their bindings.
"""
from dataclasses import replace
import interaction_cast as casts
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_cast_boundaries'
VERSION = 1
CHAPTER = 6
WIDTHS = (255, 256, 257, 511, 512, 513)
CONFIGURATIONS = (('signed', 'x', 'typed_bit', 'narrow', 'add', 'logic'),
 ('signed', 'z', 'size', 'wide', 'plain', 'logic'),
 ('signed', 'known', 'size', 'narrow', 'add', 'bit'),
 ('unsigned', 'z', 'unsigned', 'same', 'plain', 'logic'),
 ('unsigned', 'z', 'typed_logic', 'wide', 'plain', 'bit'),
 ('unsigned', 'x', 'typed_logic', 'same', 'plain', 'logic'),
 ('unsigned', 'x', 'typed_bit', 'wide', 'plain', 'bit'),
 ('unsigned', 'known', 'signed', 'same', 'plain', 'logic'),
 ('signed', 'z', 'unsigned', 'same', 'add', 'bit'),
 ('signed', 'x', 'signed', 'same', 'plain', 'bit'),
 ('unsigned', 'known', 'typed_logic', 'narrow', 'plain', 'bit'),
 ('signed', 'known', 'typed_logic', 'wide', 'add', 'logic'),
 ('unsigned', 'z', 'typed_bit', 'same', 'plain', 'logic'),
 ('unsigned', 'z', 'typed_bit', 'narrow', 'add', 'logic'),
 ('unsigned', 'z', 'size', 'wide', 'add', 'logic'),
 ('unsigned', 'x', 'size', 'same', 'plain', 'logic'),
 ('unsigned', 'x', 'size', 'narrow', 'add', 'logic'),
 ('signed', 'z', 'typed_logic', 'same', 'add', 'logic'),
 ('signed', 'x', 'typed_logic', 'narrow', 'add', 'logic'),
 ('signed', 'known', 'typed_bit', 'wide', 'plain', 'logic'),
 ('signed', 'known', 'typed_bit', 'same', 'add', 'logic'),
 ('signed', 'known', 'size', 'same', 'plain', 'logic'),
 ('unsigned', 'z', 'signed', 'same', 'plain', 'logic'),
 ('unsigned', 'z', 'signed', 'same', 'add', 'logic'),
 ('unsigned', 'x', 'unsigned', 'same', 'plain', 'logic'),
 ('unsigned', 'x', 'unsigned', 'same', 'add', 'logic'),
 ('unsigned', 'x', 'signed', 'same', 'add', 'logic'),
 ('unsigned', 'known', 'unsigned', 'same', 'plain', 'logic'),
 ('unsigned', 'known', 'unsigned', 'same', 'add', 'logic'),
 ('unsigned', 'known', 'signed', 'same', 'add', 'logic'))


def make_case(width, configuration):
    row = (str(width), *configuration)
    original = casts.make_case(row)
    sign, value, kind, relation, operation, state = configuration
    source = casts.reference(row)[0]
    middle = width//2
    assert source[width-1-middle] == '1'
    supplied = source[:width-1-middle]+'0'+source[width-middle:]
    name = original.name.replace('test_gen_cross_cast_', 'test_gen_wide_cast_', 1)
    body = original.body.replace('module '+original.name+';', 'module '+name+';', 1)
    body = body.replace('  initial begin',
        '  integer nonce, found;\n  initial begin\n    nonce = 0;\n'
        '    found = $value$plusargs("nonce=%d", nonce);\n'
        '    $display("nonce=%0d found=%0d", nonce, found != 0);', 1)
    old = '    source = '+casts.literal(source)+';'
    new = '    source = '+casts.literal(supplied)+';\n'+f'    source[{middle}] = nonce[0];'
    assert body.count(old) == 1
    body = body.replace(old, new, 1)
    cast_width = width+{'narrow':-1,'same':0,'wide':1}[relation]
    expression = (f"{cast_width}'(source)" if kind == 'size' else
                  "cast_t'(source)" if kind.startswith('typed_') else f"{kind}'(source)")
    body = body.replace('    $finish;',
        '    $display("widths=%0d,%0d,%0d",\n'
        f'             $bits(source), $bits({expression}), $bits(result));\n'
        '    $finish;', 1)
    expected = 'nonce=1 found=1\n'+original.expected+f'widths={width},{cast_width},{width+2}\n'
    note = ('Explicit casts produce typed intermediate values before the outer '
            'assignment and optional signed two-bit addition. Size casts preserve '
            'source signing, signing casts preserve source width, and typed bit '
            'conversion removes X/Z before arithmetic; final bit storage converts '
            'only afterward. Runtime +nonce=1 restores a cleared known middle '
            'source bit. Full inputs, intermediate/final values and widths are '
            'observed. Thirty frozen configurations extend the256/512-bit '
            'boundaries without changing old finite-model rows or claiming all '
            'possible context combinations.')
    clauses = '6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 11.4.12 20.6.2 21.6'
    if operation == 'add':
        clauses += ' 11.4.3'
    return replace(original, name=name, body=wrap_generated_unsigned_literals(body),
                   expected=expected, comment=note, lrm=clauses,
                   extra={'args':'+nonce=1'})


def cases():
    return [make_case(width, configuration)
            for width in WIDTHS for configuration in CONFIGURATIONS]
