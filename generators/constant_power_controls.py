# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Pair explicit typed constant and runtime negative integral powers."""
from dataclasses import replace
from negative_power_controls import (BASES, EXPONENT_WIDTHS, make_case as runtime_case,
                                     negative_exponents)
from power_boundaries import binary
from wide_literals import wrap_generated_unsigned_literals

NAME = 'constant_power_controls'
VERSION = 1
CHAPTER = 11
DESCRIPTIONS = {
    'zero': 'Constant and runtime zero to negative powers preserve unknown results',
    'one': 'Constant and runtime unit bases agree for signed negative exponents',
    'minus_one': 'Constant and runtime signed minus one preserve negative exponent parity',
    'other': 'Constant and runtime nonunit integral bases agree for negative exponents',
}


def make_case(category, exponent_width):
    original = runtime_case(category, exponent_width)
    width, signed, value, _ = BASES[category]
    sign = 'signed' if signed else 'unsigned'
    name = original.name.replace('test_gen_negative_power_',
                                 'test_gen_constant_negative_power_', 1)
    exponents = negative_exponents(exponent_width)
    declarations = [f'  localparam logic {sign} [W-1:0] C_BASE = '
                    f"{width}'b{binary(value, width)};"]
    for phase, exponent in enumerate(exponents):
        declarations += [
            f'  localparam logic signed [EW-1:0] C_EXP_{phase} = '
            f"{exponent_width}'b{binary(exponent, exponent_width)};",
            f'  localparam logic {sign} [W-1:0] C_NARROW_{phase} = '
            f'C_BASE ** C_EXP_{phase};',
            f'  localparam logic [2*W:0] C_FULL_{phase} = C_BASE ** C_EXP_{phase};',
            f'  localparam logic [2*W:0] C_CAPTURED_{phase} = C_NARROW_{phase};',
            f'  localparam bit [2*W:0] C_CONVERTED_{phase} = C_FULL_{phase};',
        ]
    source = original.body.replace('module '+original.name+';', 'module '+name+';', 1)
    source = source.replace('  integer nonce, found;',
                            '\n'.join(declarations)+'\n  integer nonce, found;', 1)
    body, phase = [], 0
    for line in source.splitlines():
        body.append(line)
        if line != '             $bits(base ** exponent), $bits(exponent), $bits(full));':
            continue
        for label in ('base', 'exponent', 'narrow', 'full', 'captured', 'converted'):
            constant = 'C_BASE' if label == 'base' else (
                f'C_EXP_{phase}' if label == 'exponent' else f'C_{label.upper()}_{phase}')
            body.append(f'    $display("c{phase}_{label}=%b", {constant});')
        body += [f'    $display("c{phase}_widths=%0d,%0d,%0d",',
                 f'             $bits(C_BASE ** C_EXP_{phase}), '
                 f'$bits(C_EXP_{phase}), $bits(C_FULL_{phase}));',
                 f'    $display("p{phase}_equal=%b,%b,%b,%b,%b,%b",',
                 f'             base === C_BASE, exponent === C_EXP_{phase},',
                 f'             narrow === C_NARROW_{phase}, full === C_FULL_{phase},',
                 f'             captured === C_CAPTURED_{phase}, '
                 f'converted === C_CONVERTED_{phase});']
        phase += 1
    assert phase == len(exponents)
    runtime_lines = original.expected.splitlines()
    assert len(runtime_lines) == 2+7*len(exponents)
    expected = runtime_lines[:2]
    for phase in range(len(exponents)):
        observations = runtime_lines[2+7*phase:2+7*(phase+1)]
        expected += observations
        expected += [line.replace(f'p{phase}_', f'c{phase}_', 1)
                     for line in observations]
        expected.append(f'p{phase}_equal=1,1,1,1,1,1')
    note = ('Typed local parameters repeat each runtime base/exponent, natural-width '
            'power, direct 2W+1-bit power, later captured extension and bit storage '
            'conversion. Each result and input is checked independently against '
            'Table 11-4, then case equality compares both paths including X. '
            'The original runtime +nonce=1 path is retained. Identical correct '
            'outputs are required without prescribing internal compilation phases. '
            'These sixteen focused controls do not establish broad assignment '
            'context discrimination or cover real exponents and arbitrary constants.')
    return replace(original, name=name, description=DESCRIPTIONS[category],
                   body=wrap_generated_unsigned_literals('\n'.join(body)),
                   expected='\n'.join(expected)+'\n', comment=note,
                   lrm='11.4.3 11.2.1 6.20.2 6.20.4 11.6.1 11.8.1 11.8.2 '
                       '6.11.2 11.4.5 20.6.2 21.6')


def cases():
    return [make_case(category, width)
            for category in BASES for width in EXPONENT_WIDTHS]
