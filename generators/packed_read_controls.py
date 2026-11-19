# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Separate packed read coordinates from mutations with independent flat controls."""
from common import Case
from packed_lanes import Bank
from wide_literals import wrap_generated_unsigned_literals

NAME = 'packed_read_controls'
VERSION = 1
CHAPTER = 7
WIDTHS = (255, 256, 257, 511, 512, 513)
DIRECTIONS = ('up', 'down')
MODES = ('row', 'bit')


def make_case(width, outer, inner, origin, mode):
    name = f'test_gen_packed_read_control_{mode}_{outer}_{inner}_{"zero" if origin==0 else "offset"}_w{width}'
    bank = Bank(width, outer, inner, 'bit', origin)
    payload = bank.whole()
    middle = len(payload)//2
    supplied = list(payload)
    supplied[-1-middle] = '0' if supplied[-1-middle]=='1' else '1'
    lines = [f'module {name};', f'  localparam int W = {width};',
             f'  bit signed [{bank.rows[0]}:{bank.rows[-1]}]'
             f'[{bank.columns[0]}:{bank.columns[-1]}] bank;',
             '  bit [3*W-1:0] flat;', '  integer row, col, flat_base, flat_index;',
             '  integer nonce, found;', '  initial begin', '    nonce = 0;',
             '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);',
             f"    flat = {3*width}'b{''.join(supplied)};",
             f'    flat[{middle}] = flat[{middle}] ^ nonce[0];', '    bank = flat;',
             '    $display("flat=%b", flat);', '    $display("bank=%b", bank);']
    expected = ['nonce=1 found=1', 'flat='+payload, 'bank='+payload]
    for phase, row in enumerate(bank.rows):
        lines.append(f'    row = {row} + (nonce - 1);')
        low = (2-phase)*width
        if mode == 'row':
            lines += [f'    flat_base = {low} + (nonce - 1);',
                      f'    $display("p{phase} literal=%b", bank[{row}]);',
                      f'    $display("p{phase} variable=%b", bank[row]);',
                      f'    $display("p{phase} flat_literal=%b", flat[{low+width-1}:{low}]);',
                      f'    $display("p{phase} flat_variable=%b", flat[flat_base +: W]);']
            value = bank.word(row)
        else:
            column_position = (0, width//2, width-1)[phase]
            column = bank.columns[column_position]
            bit_index = low+width-1-column_position
            lines += [f'    col = {column} + (nonce - 1);',
                      f'    flat_index = {bit_index} + (nonce - 1);',
                      f'    $display("p{phase} literal=%b", bank[{row}][{column}]);',
                      f'    $display("p{phase} variable=%b", bank[row][col]);',
                      f'    $display("p{phase} flat_literal=%b", flat[{bit_index}]);',
                      f'    $display("p{phase} flat_variable=%b", flat[flat_index]);']
            value = bank.bit(row, column)
        expected += [f'p{phase} {label}={value}' for label in
                     ('literal', 'variable', 'flat_literal', 'flat_variable')]
    observed = 'bank[row]' if mode=='row' else 'bank[row][col]'
    literal_observed = (f'bank[{row}]' if mode=='row' else f'bank[{row}][{column}]')
    result_width = width if mode=='row' else 1
    lines += ['    $display("bank_after=%b", bank);',
              '    $display("flat_after=%b", flat);',
              '    $display("widths=%0d,%0d,%0d",',
              f'             $bits(bank), $bits({literal_observed}), $bits({observed}));',
              '    $finish;', '  end', 'endmodule']
    expected += ['bank_after='+payload, 'flat_after='+payload,
                 f'widths={3*width},{result_width},{result_width}']
    note = ('The same known payload is printed as a flat vector and a whole '
            'two-dimensional packed array. Each declared row is then read using '
            'literal coordinates, runtime coordinates and independent static/'
            'runtime flat-vector coordinates. Row-only programs avoid a second '
            'packed index, while bit programs sample the left, middle and right '
            'column positions on separate rows. Both dimension directions and '
            'zero/nonzero inner origins retain significance order. The payload '
            'and runtime index variables depend on +nonce=1. There are no element '
            'or slice writes after whole-array initialization, separating read '
            'coordinate behavior from the existing packed-lane write regressions. '
            'Full flat and bank values remain visible before and after all reads. '
            'Existing Bank reference data and all old tests remain unchanged.')
    return Case(name, 'Packed reads match literal and flat-vector controls without element writes',
                '7.4.1 7.4.5 11.5.1 11.4.5 11.4.8 20.6.2 21.6 21.2.1',
                note, wrap_generated_unsigned_literals('\n'.join(lines)),
                '\n'.join(expected)+'\n', extra={'args':'+nonce=1'})


def cases():
    return [make_case(width, outer, inner, origin, mode) for width in WIDTHS
            for outer in DIRECTIONS for inner in DIRECTIONS for origin in (-5,0)
            for mode in MODES]
