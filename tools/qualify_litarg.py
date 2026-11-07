#!/usr/bin/env python3
"""Interpret actual literal argument programs independently.

The task or function, its formal and its default are read from the program,
with escaped identifiers ending at white space. The literal of the call, of
the default or of the return statement is lexed into a value: an integral
one with width, sign and bits, an unbased unsized fill, a real or the
characters of a string. Passing it is an assignment to the formal's type:
extend by the literal's sign and keep the low bits, fill the whole width,
turn x into 0 for a two-state type, and round a real half away from zero.
The display then formats the formal as its type shows it.
"""

from decimal import Decimal, ROUND_HALF_UP
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_litarg as generator

IDENT = r'(?:\\\S+ |[A-Za-z_]\w*)'
ATOMS = {'byte': (8, True, False), 'shortint': (16, True, False), 'int': (32, True, False)}


def integral(kind):
    """The width, sign and four-state flag of an integral type."""
    if kind in ATOMS: return ATOMS[kind]
    vector = re.fullmatch(r'(bit|logic)( signed)? \[(\d+):0\]', kind)
    assert vector, ('unsupported type', kind)
    return int(vector[3]) + 1, bool(vector[2]), vector[1] == 'logic'


def lexed(text):
    """('int', width, signed, bits) | ('fill', digit) | ('real', value) | ('string', text)."""
    text = text.strip()
    if text.startswith('"'): return ('string', text[1:-1])
    negative = text.startswith('-')
    body = text[1:] if negative else text
    if re.fullmatch(r'\d+\.\d+(?:[eE][-+]?\d+)?|\d+[eE][-+]?\d+', body):
        value = Decimal(body)
        return ('real', -value if negative else value)
    fill = re.fullmatch(r"'([01xz])", body)
    if fill:
        assert not negative
        return ('fill', fill[1])
    if re.fullmatch(r'\d+', body):
        number = -int(body) if negative else int(body)
        return ('int', 32, True, number % (1 << 32))
    based = re.fullmatch(r"(\d*)'(s?)([bodh])([0-9a-fA-F_]+)", body)
    assert based, ('unsupported literal', text)
    width = int(based[1]) if based[1] else 32
    bits = int(based[4].replace('_', ''), {'b': 2, 'o': 8, 'd': 10, 'h': 16}[based[3]]) % (1 << width)
    if negative: bits = -bits % (1 << width)
    return ('int', width, bool(based[2]), bits)


def assigned(value, kind):
    """The formal's value after an assignment of the literal."""
    if kind == 'string':
        assert value[0] == 'string', 'only a string literal goes to a string'
        return ('string', value[1])
    if kind == 'real':
        if value[0] == 'real': return ('real', value[1])
        assert value[0] != 'fill', 'a fill has no width for a real'
        number = string_number(value[1]) if value[0] == 'string' else signed_number(value[1:])
        return ('real', Decimal(number))
    width, signed, four = integral(kind)
    if value[0] == 'fill':
        digit = value[1] if four or value[1] in '01' else '0'
        return ('bits', width, signed, digit * width)
    if value[0] == 'real':
        number = int(value[1].quantize(Decimal(1), rounding=ROUND_HALF_UP))
    elif value[0] == 'string':
        number = string_number(value[1])
    else:
        number = signed_number(value[1:])
    return ('bits', width, signed, format(number % (1 << width), f'0{width}b'))


def string_number(text):
    number = 0
    for char in text: number = number << 8 | ord(char)
    return number


def signed_number(value):
    width, signed, bits = value
    return bits - (1 << width) if signed and bits >> width - 1 else bits


def formatted(form, values):
    out = []
    for spec in re.findall(r'%(?:0d|h|\.2f|s)', form):
        value = values.pop(0)
        if spec == '%s': out.append(value)
        elif isinstance(value, int): out.append(str(value))
        elif spec == '%.2f': out.append(format(value, '.2f'))
        else:
            _, width, signed, bits = value
            if 'x' in bits:
                assert set(bits) == {'x'}
                out.append('x' if spec == '%0d' else 'x' * (width // 4))
            elif spec == '%0d':
                number = int(bits, 2)
                out.append(str(number - (1 << width) if signed and bits[0] == '1' else number))
            else:
                out.append(format(int(bits, 2), f'0{width // 4}x'))
    text = re.sub(r'%(?:0d|h|\.2f|s)', '{}', form)
    return text.format(*out)


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;(.*)endmodule\s*', code, re.S)
        assert found, 'unsupported program'
        self.body = found[1]

    def show(self, form, arguments, formal, value):
        """The display line for a formal holding value."""
        items = []
        for argument in (part.strip() for part in re.split(r',(?=\s)', arguments)):
            if argument.endswith('.len()'):
                assert argument[:-6].strip() == formal.strip() and value[0] == 'string'
                items.append(len(value[1]))
            else:
                assert argument.strip() == formal.strip(), ('unknown argument', argument)
                items.append(value[1] if value[0] in ('string', 'real') else value)
        return formatted(form, items) + '\n'

    def run(self):
        body = self.body
        task = re.search(rf'task automatic ({IDENT})\(input (.*?) ({IDENT})( = (.*?))?\);\s*'
                         rf'\$display\("(.*?)", (.*?)\);\s*endtask', body, re.S)
        function = re.search(rf'(\S.*?) r;\s*function automatic (.*?) ({IDENT})\(\);\s*return (.*?);\s*endfunction',
                             body, re.S)
        if task:
            name, kind, formal, default, form, arguments = task[1], task[2], task[3], task[5], task[6], task[7]
            calls = re.findall(rf'initial begin\s*(.*?);\s*end', body, re.S)
            assert len(calls) == 1, 'one call'
            call = calls[0].strip()
            assert call.startswith(name.strip()), ('another task', call)
            inside = call[len(name.strip()):].strip()
            assert inside.startswith('(') and inside.endswith(')')
            inside = inside[1:-1].strip()
            if not inside:
                assert default is not None, 'no default'
                text = default
            else:
                named = re.fullmatch(rf'\.({IDENT})\((.*)\)', inside)
                if named:
                    assert named[1].strip() == formal.strip(), 'another formal'
                    text = named[2]
                else:
                    text = inside
            return self.show(form, arguments, formal, assigned(lexed(text), kind))
        assert function, 'unsupported program'
        variable, kind, name, text = function[1].strip(), function[2], function[3], function[4]
        assert variable == kind, 'variable type'
        shown = re.search(rf'r = {re.escape(name.strip())}\s*\(\);\s*\$display\("(.*?)", (.*?)\);', body)
        assert shown, 'no display'
        return self.show(shown[1], shown[2], 'r', assigned(lexed(text), kind))


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'fill_default': anchor(('fill1', 'byte', 'default', 'escaped')),
                'fillx_named': anchor(('fillx', 'slogic12', 'named', 'escaped')),
                'negreal_return': anchor(('negreal', 'bit8', 'return', 'plain')),
                'string_positional': anchor(('string', 'logic12', 'positional', 'escaped')),
                'signed_real': anchor(('signed', 'real', 'named', 'plain')),
                'based_return': anchor(('based', 'byte', 'return', 'escaped')),
                'real_default': anchor(('real', 'int', 'default', 'plain')),
                'neg_positional': anchor(('neg', 'logic12', 'positional', 'plain'))}
    faults = (
        ('one_bit_default', 'fill_default', [("= '1);", "= 1'b1);")]),
        ('two_state_formal', 'fillx_named', [('input logic signed [11:0]', 'input bit signed [11:0]')]),
        ('truncated_real', 'negreal_return', [('return -2.5;', 'return -2.4;')]),
        ('other_character', 'string_positional', [('("AB")', '("AC")')]),
        ('unsigned_literal', 'signed_real', [("4'sb1010", "4'b1010")]),
        ('wider_return', 'based_return', [('function automatic byte', 'function automatic shortint'),
                                          ('  byte r;', '  shortint r;')]),
        ('lower_real', 'real_default', [('= 2.5)', '= 2.4)')]),
        ('unsigned_formal', 'neg_positional', [('input logic [11:0]', 'input logic [15:0]')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_litarg.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_litarg.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent lexing and assignment conversion of actual subroutine programs. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
