# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Observe formatted strings and parsed wide values independently at each phase."""
from common import Case
from function_formal_contexts import alternating, decimal, literal, mask
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_format_roundtrips'
VERSION = 1
CHAPTER = 21
WIDTHS = (255, 256, 257, 511, 512, 513)
RADICES = ('b', 'h', 'd')


def make_case(width, signed, radix):
    sign = 'signed' if signed else 'unsigned'
    name = f'test_gen_wide_format_roundtrip_w{width}_{sign}_{radix}'
    lines = [f'module {name};', f'  typedef bit {sign} [{width-1}:0] word_t;',
             '  word_t source, parsed;', '  string text;',
             '  integer nonce, found, scanned;', '  initial begin', '    nonce = 0;',
             '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);']
    expected = ['nonce=1 found=1']
    middle = width//2
    for phase, seed in enumerate((0, mask(width), 1 << (width-1), alternating(width))):
        text = (format(seed, 'b') if radix == 'b' else format(seed, 'x') if radix == 'h'
                else str(decimal(seed, width, signed)))
        lines += [f'    source = {literal(width, seed ^ (1 << middle))};',
                  f'    source[{middle}] = source[{middle}] ^ nonce[0];',
                  f'    text = $sformatf("%0{radix}", source);',
                  *(['    text = text.tolower();'] if radix == 'h' else []),
                  "    parsed = '1;",
                  f'    scanned = $sscanf(text, "%{radix}", parsed);',
                  f'    $display("p{phase} input=%b", source);',
                  f'    $display("p{phase} text=%s length=%0d", text, text.len());',
                  f'    $display("p{phase} parsed=%b count=%0d source_after=%b",',
                  '             parsed, scanned, source);']
        bits = f'{seed:0{width}b}'
        expected += [f'p{phase} input={bits}', f'p{phase} text={text} length={len(text)}',
                     f'p{phase} parsed={bits} count=1 source_after={bits}']
    lines += ['    $display("widths=%0d,%0d", $bits(source), $bits(parsed));',
              '    $finish;', '  end', 'endmodule']
    expected.append(f'widths={width},{width}')
    note = ('Four known seeds at a frozen word width acquire a true runtime '
            'dependency from +nonce=1 before minimum-field-width binary, '
            'hexadecimal or decimal formatting. Hexadecimal letter case is '
            'normalized explicitly with tolower; raw capitalization is outside '
            'this scope. The actual formatted string and its length are checked '
            'independently of the parsed result, preventing two matching mistakes '
            'from hiding in a round trip. The parser destination starts at all '
            'ones, and every returned bit plus the successful-conversion count '
            'is visible. Signed decimal text and unsigned large values both '
            'retain the declared source semantics. These programs perform no '
            'file I/O and do not test arbitrary formats or four-state values.')
    return Case(name, 'Wide numeric formatting and scanning preserve text and full values',
                '21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 '
                + ('6.16.5 ' if radix == 'h' else '')
                + '11.4.5 11.4.8 20.6.2 21.6', note,
                wrap_generated_unsigned_literals('\n'.join(lines)),
                '\n'.join(expected)+'\n', extra={'args':'+nonce=1'})


def cases():
    return [make_case(width, signed, radix) for width in WIDTHS
            for signed in (False, True) for radix in RADICES]
