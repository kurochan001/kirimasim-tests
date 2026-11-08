#!/usr/bin/env python3
"""Interpret actual case programs with ?, z and x digits independently.

The case item is read by the rules of 5.7.1: each binary, octal or hexadecimal
digit sets 1, 3 or 4 bits, ? is z, a decimal x, z or ? sets every bit, a
number shorter than its size is padded on the left with zeros, or with x or z
when its leftmost bit is x or z, and an unsized number has 32 bits. The case
of 12.5 then makes the selector and the item as wide as the wider one, with
zeros since both are unsigned. case compares every bit exactly, casez skips a
bit where either side is z, casex where either side is x or z (12.5.1), and
case inside skips a bit only where the item is x or z and otherwise needs a
known equal bit, so that ==? gives 1'b1 (12.5.4, 11.4.6). Each check call
prints hit when the item matches and miss when default runs.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_casedigit as generator

DIGIT_BITS = {'b': 1, 'o': 3, 'h': 4}


def number(text):
    """The bits of a based literal, most significant first."""
    found = re.fullmatch(r"(\d*)'([bohd])([0-9a-fA-FxXzZ?_]+)", text)
    assert found, ('not a based literal', text)
    size = int(found[1]) if found[1] else 32
    base, digits = found[2], found[3].replace('_', '').lower().replace('?', 'z')
    if base == 'd':
        assert len(digits) == 1 and digits in 'xz', ('decimal digits', digits)
        return digits * size
    width = DIGIT_BITS[base]
    bits = ''
    for digit in digits:
        bits += digit * width if digit in 'xz' else format(int(digit, {'b': 2, 'o': 8, 'h': 16}[base]), f'0{width}b')
    if len(bits) < size: bits = (bits[0] if bits[0] in 'xz' else '0') * (size - len(bits)) + bits
    return bits[-size:]


def bit_match(kind, s, i):
    if kind == 'case': return s == i
    if kind == 'casez': return 'z' in (s, i) or s == i
    if kind == 'casex': return bool({s, i} & {'x', 'z'}) or s == i
    return i in 'xz' or (s in '01' and s == i)


def compare(kind, selector, item):
    width = max(len(selector), len(item))
    selector, item = selector.rjust(width, '0'), item.rjust(width, '0')
    return all(bit_match(kind, s, i) for s, i in zip(selector, item))


def interpret(source):
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    head = re.search(r'\b(case|casez|casex)\s*\(\s*s\s*\)\s*(inside\b)?', code)
    assert head, 'no case statement'
    kind = 'inside' if head[2] else head[1]
    assert re.search(r'input\s+logic\s*\[7:0\]\s*s\b', code), 'an 8-bit selector'
    body = code[head.end():code.index('endcase', head.end())]
    arms = [a.strip() for a in body.split(';') if a.strip()]
    assert len(arms) == 2 and arms[1].startswith('default'), 'one item and default'
    label, action = arms[0].split(':', 1)
    item = number(label.strip())
    assert '"%s hit"' in action and '"%s miss"' in arms[1], 'hit and miss actions'
    out = []
    for tag, value in re.findall(r'check\("(\w+)",\s*(\d+\'[bohd][0-9a-fA-FxXzZ?_]+)\);', code):
        out.append(f"{tag} {'hit' if compare(kind, number(value), item) else 'miss'}\n")
    assert out, 'no checks'
    return ''.join(out)


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'bin_wide': anchor(('bin', 'q', 'wild', 'wide', 'casez')),
                'oct_narrow': anchor(('oct', 'x', 'wild', 'narrow', 'casex')),
                'hex_unsized': anchor(('hex', 'z', 'known', 'unsized', 'inside')),
                'dec_case': anchor(('dec', 'q', 'wild', 'unsized', 'case')),
                'bin_narrow': anchor(('bin', 'z', 'known', 'narrow', 'casez')),
                'hex_same': anchor(('hex', 'x', 'wild', 'same', 'inside')),
                'oct_wide': anchor(('oct', 'q', 'known', 'wide', 'casex'))}
    faults = (
        ('known_lead', 'bin_wide', [("12'b?1?0", "12'b01?0")]),
        ('casez_for_x', 'oct_narrow', [('casex (s)', 'casez (s)')]),
        ('plain_case', 'hex_unsized', [('case (s) inside', 'case (s)')]),
        ('casez_for_case', 'dec_case', [('case (s)', 'casez (s)')]),
        ('shorter_item', 'bin_narrow', [("6'b1z0z", "6'b10z")]),
        ('other_digit', 'hex_same', [("8'hx5", "8'hx4")]),
        ('casez_for_casex', 'oct_wide', [('casex (s)', 'casez (s)')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_casedigit.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_casedigit.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent reading of the literals of the actual programs by 5.7.1 and comparison by each kind of '
            'case. Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
