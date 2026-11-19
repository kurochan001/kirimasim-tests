# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Focused integral negative-power table controls from saved random findings.

Keep zero-base X results separate from known-only ±1/other-base programs,
so four-state requirements do not hide comparable two-state controls.
"""
from common import Case
from bitvector_queries import assign_literal
from interaction_bits import resize, two_state
from power_boundaries import binary, power

NAME = 'negative_power_controls'
VERSION = 1
CHAPTER = 11
EXPONENT_WIDTHS = (3, 8, 32, 65)
BASES = {'zero': (65, True, 0, 'nonce - 1'),
         'one': (128, True, 1, 'nonce'),
         'minus_one': (33, True, -1, '-nonce'),
         'other': (2, False, 3, 'nonce + 2')}
DESCRIPTIONS = {
    'zero': 'Integral zero to negative powers remains unknown before storage conversion',
    'one': 'Integral one to negative powers remains one with independent exponent width',
    'minus_one': 'Signed minus one to negative powers follows exponent parity at full width',
    'other': 'Unsigned nonunit bases with signed negative integral exponents produce zero',
}


def negative_exponents(width):
    return list(dict.fromkeys([-1, -2, -3, -(1 << (width-1))+1,
                               -(1 << (width-1))]))


def make_case(category, exponent_width):
    width, signed, value, expression = BASES[category]
    sign = 'signed' if signed else 'unsigned'
    name = f'test_gen_negative_power_{category}_e{exponent_width}'
    body = [f'module {name};', f'  localparam int W = {width};',
            f'  localparam int EW = {exponent_width};',
            f'  logic {sign} [W-1:0] base, narrow;',
            '  logic signed [EW-1:0] exponent;', '  logic [2*W:0] full, captured;',
            '  bit [2*W:0] converted;', '  integer nonce, found;', '  initial begin',
            f'    $display("category={category} base_width={width} exponent_width={exponent_width}");',
            '    nonce = 0;', '    found = $value$plusargs("nonce=%d", nonce);',
            '    $display("nonce=%0d found=%0d", nonce, found != 0);',
            f'    base = {expression};']
    expected = [f'category={category} base_width={width} exponent_width={exponent_width}',
                'nonce=1 found=1']
    exponents = negative_exponents(exponent_width)
    for phase, exponent in enumerate(exponents):
        bits = binary(exponent, exponent_width)
        supplied = bits[:-1] + ('1' if bits[-1]=='0' else '0')
        assign_literal(body, 'exponent', supplied)
        body += ['    exponent[0] = exponent[0] ^ nonce[0];',
                 '    narrow = base ** exponent;', '    full = base ** exponent;',
                 '    captured = narrow;', '    converted = full;']
        base = binary(value, width)
        narrow = power(base, bits, signed, True, width)
        full = power(base, bits, signed, True, 2*width+1)
        observations = [('base',base),('exponent',bits),('narrow',narrow),('full',full),
                        ('captured',resize(narrow,2*width+1,signed)),('converted',two_state(full))]
        for label, result in observations:
            body.append(f'    $display("p{phase}_{label}=%b", {label});')
            expected.append(f'p{phase}_{label}={result}')
        body += [f'    $display("p{phase}_widths=%0d,%0d,%0d",',
                 '             $bits(base ** exponent), $bits(exponent), $bits(full));']
        expected.append(f'p{phase}_widths={width},{exponent_width},{2*width+1}')
    body += ['    $finish;', '  end', 'endmodule']
    note = ('Focused controls retain mechanisms found in our saved random-power inputs, '
            'without adopting simulator output as an oracle. Base values are produced from '
            'the recorded +nonce=1; the known low exponent bit changes at runtime without '
            'changing its signed declared width. Negative one, two, three and the lower '
            'signed bound with its neighbor exercise Table 11-4; duplicate small-width '
            'exponents are omitted. The exponent remains self-determined. Natural-width, '
            'direct 2W+1-bit and subsequently extended captured results are distinct; all '
            'inputs, output bits, final bit conversion and expression widths are observed. '
            'Zero-base programs require X results and remain separate from known-only '
            'one, signed minus-one and unsigned other-base programs.')
    return Case(name,DESCRIPTIONS[category],
                '11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2 21.6',
                note,'\n'.join(body),'\n'.join(expected)+'\n',
                fourstate=category=='zero',extra={'args':'+nonce=1'})


def cases():
    return [make_case(category,width) for category in BASES for width in EXPONENT_WIDTHS]
