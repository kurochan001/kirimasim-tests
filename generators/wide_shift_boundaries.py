# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide shift boundaries with a runtime-produced input bit.

Reuse the existing character-position reference without expanding finite-model
rows or requirements. The configuration list is explicitly frozen.
"""
from dataclasses import replace
import interaction_shift as shifts
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_shift_boundaries'
VERSION = 1
CHAPTER = 11
WIDTHS = (255, 256, 257, 511, 512, 513)
CONFIGURATIONS = (('unsigned', 'shl', 'zero', 'known', 'narrow', 'logic'),
 ('signed', 'shl', 'one', 'known', 'same', 'bit'),
 ('unsigned', 'shl', 'last', 'known', 'wide', 'logic'),
 ('signed', 'shl', 'width', 'known', 'narrow', 'bit'),
 ('unsigned', 'shl', 'beyond', 'known', 'same', 'logic'),
 ('signed', 'shl', 'x', 'known', 'wide', 'bit'),
 ('unsigned', 'shl', 'z', 'known', 'narrow', 'logic'),
 ('signed', 'shr', 'zero', 'known', 'same', 'bit'),
 ('unsigned', 'shr', 'one', 'known', 'wide', 'logic'),
 ('signed', 'shr', 'last', 'known', 'narrow', 'bit'),
 ('unsigned', 'shr', 'width', 'known', 'same', 'logic'),
 ('signed', 'shr', 'beyond', 'known', 'wide', 'bit'),
 ('unsigned', 'shr', 'x', 'known', 'narrow', 'logic'),
 ('signed', 'shr', 'z', 'known', 'same', 'bit'),
 ('unsigned', 'ashl', 'zero', 'known', 'wide', 'logic'),
 ('signed', 'ashl', 'one', 'known', 'narrow', 'bit'),
 ('unsigned', 'ashl', 'last', 'known', 'same', 'logic'),
 ('signed', 'ashl', 'width', 'known', 'wide', 'bit'),
 ('unsigned', 'ashl', 'beyond', 'known', 'narrow', 'logic'),
 ('signed', 'ashl', 'x', 'known', 'same', 'bit'),
 ('unsigned', 'ashl', 'z', 'known', 'wide', 'logic'),
 ('signed', 'ashr', 'zero', 'known', 'narrow', 'bit'),
 ('unsigned', 'ashr', 'one', 'known', 'same', 'logic'),
 ('signed', 'ashr', 'last', 'known', 'wide', 'bit'),
 ('unsigned', 'ashr', 'width', 'known', 'narrow', 'logic'),
 ('signed', 'ashr', 'beyond', 'known', 'same', 'bit'),
 ('unsigned', 'ashr', 'x', 'known', 'wide', 'logic'),
 ('signed', 'ashr', 'z', 'known', 'narrow', 'bit'),
 ('signed', 'ashr', 'width', 'z', 'wide', 'logic'),
 ('signed', 'ashr', 'last', 'x', 'wide', 'bit'),
 ('unsigned', 'shl', 'one', 'x', 'narrow', 'logic'),
 ('unsigned', 'shr', 'beyond', 'z', 'same', 'bit'))


def make_case(width, configuration):
    original = shifts.make_case((str(width), *configuration))
    sign, operator, count, value, relation, state = configuration
    source = shifts.reference((str(width), *configuration))[0]
    middle = width//2
    assert source[width-1-middle] == '1'
    supplied = source[:width-1-middle]+'0'+source[width-middle:]
    name = original.name.replace('test_gen_cross_shift_', 'test_gen_wide_shift_', 1)
    body = original.body.replace('module '+original.name+';', 'module '+name+';', 1)
    body = body.replace('  initial begin', '  integer nonce, found;\n  initial begin', 1)
    body = body.replace('  initial begin',
        '  initial begin\n    nonce = 0;\n'
        '    found = $value$plusargs("nonce=%d", nonce);\n'
        '    $display("nonce=%0d found=%0d", nonce, found != 0);', 1)
    old = '    source = '+shifts.literal(source)+';'
    new = ('    source = '+shifts.literal(supplied)+';\n'
           f'    source[{middle}] = nonce[0];')
    assert body.count(old) == 1
    body = body.replace(old, new, 1)
    expression = 'source '+shifts.OPS[operator]+' count'
    body = body.replace('    $finish;',
        '    $display("widths=%0d,%0d,%0d",\n'
        f'             $bits({expression}), $bits(count), $bits(result));\n'
        '    $finish;', 1)
    result_width = width+{'narrow':-1,'same':0,'wide':1}[relation]
    expected = ('nonce=1 found=1\n'+original.expected+
                f'widths={width},32,{result_width}\n')
    note = ('The runtime plusarg supplies the initially cleared known middle source '
            'bit; all final input bits are observed. Four operators use unsigned '
            'self-determined 32-bit counts at zero/one/W-1/W/W+1 and X/Z, with '
            'signed/unsigned left operands and W-1/W/W+1 bit/logic destinations. '
            'The destination context extends before shifting, then truncation '
            'and final two-state storage conversion apply. Signed arithmetic '
            'right fill can preserve X/Z. The 32 frozen configurations extend '
            'boundary widths without changing existing finite-model rows or '
            'claiming a complete interaction covering set.')
    return replace(original, name=name, body=wrap_generated_unsigned_literals(body),
                   expected=expected, comment=note, extra={'args':'+nonce=1'},
                   lrm='11.4.10 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2 21.6')


def cases():
    return [make_case(width, configuration)
            for width in WIDTHS for configuration in CONFIGURATIONS]
