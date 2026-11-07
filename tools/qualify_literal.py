#!/usr/bin/env python3
"""Interpret actual literal-context programs independently.

Literals are read from their tokens after macro substitution, and each
expression gets its width and sign from its own operands and the assignment
target, with no use of the row or of the generator's bit patterns.
"""

from dataclasses import dataclass
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_literal as generator


@dataclass(frozen=True)
class Operand:
    bits: str              # most significant first
    signed: bool = False
    fills: bool = False    # an unbased unsized literal takes every bit in context
    sized: bool = True     # the width of an unsized number is only "at least 32"
    grows: bool = False    # an unsized unsigned number led by x or z (5.7.1)

    def widened(self, width, signed):
        if self.fills: return self.bits[0] * width
        if self.grows: return self.bits.rjust(width, self.bits[0])
        if len(self.bits) >= width: return self.bits
        return self.bits.rjust(width, self.bits[0] if signed else '0')


def digits_to_bits(base, digits):
    digits = digits.replace('_', '').lower().replace('?', 'z')
    if base == 'd':
        if digits in ('x', 'z'): return digits
        assert digits.isdigit(), ('decimal digit', digits)
        return format(int(digits), 'b')
    width = {'b': 1, 'o': 3, 'h': 4}[base]
    legal = {'b': '01', 'o': '01234567', 'h': '0123456789abcdef'}[base]
    out = ''
    for digit in digits:
        if digit in 'xz': out += digit * width
        else:
            assert digit in legal, ('digit', digit, base)
            out += format(int(digit, 16), f'0{width}b')
    return out


def read_literal(text):
    text = text.strip()
    fill = re.fullmatch(r"'([01xzXZ])", text)
    if fill: return Operand(fill[1].lower(), fills=True, sized=False)
    if re.fullmatch(r'\d+', text):
        bits = format(int(text), 'b')
        assert len(bits) < 32, 'a wider simple decimal has an implementation-defined width'
        return Operand(bits.rjust(32, '0'), True, sized=False)
    based = re.fullmatch(r"(\d+)?\s*'([sS]?)([bBoOdDhH])\s*([0-9a-fA-FxXzZ?_]+)", text)
    assert based, ('unsupported literal', text)
    size, marker, base, digits = based.groups()
    bits = digits_to_bits(base.lower(), digits)
    width = int(size) if size else 32
    if not size: assert len(bits.lstrip('0')) <= 32, 'a wider unsized number has no fixed width'
    pad = bits[0] if bits[0] in 'xz' else '0'
    grows = not size and not marker and pad != '0'
    return Operand(bits.rjust(width, pad)[-width:], bool(marker), sized=bool(size), grows=grows)


class Program:
    def __init__(self, source):
        code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
        macros = dict(re.findall(r'^`define (\w+) (\S+)$', code, re.M))
        code = re.sub(r'^`define .*\n', '', code, flags=re.M)
        code = re.sub(r'`(\w+)', lambda found: macros[found[1]], code)
        parsed = re.fullmatch(r'\s*module (\w+);\s*(.*?)initial begin(.*?)\$finish;\s*end\s*endmodule\s*', code, re.S)
        assert parsed, 'unsupported program'
        self.declarations, self.program = parsed[2], parsed[3]
        self.names = {}
        self.target = self.net = None
        self.wire_text = None
        for line in (item.strip() for item in self.declarations.split(';') if item.strip()):
            self.declare(line)
        assert self.target and self.net and self.wire_text

    def declare(self, line):
        local = re.fullmatch(r'localparam (\w+) = (.*)', line)
        variable = re.fullmatch(r"(logic|bit)( signed)? \[(\d+):0\] (\w+)( = (\d+))?", line)
        single = re.fullmatch(r"logic (\w+) = 1'b([01])", line)
        net = re.fullmatch(r'wire( signed)? \[(\d+):0\] (\w+)', line)
        wire = re.fullmatch(r'assign (\w+) = (.*)', line)
        if local:
            # An untyped parameter takes the type of its value, so a literal that
            # would take the size of an expression is an ordinary vector from here on.
            value = read_literal(local[2])
            self.names[local[1]] = Operand(value.bits, value.signed, False, value.sized)
        elif variable:
            width = int(variable[3]) + 1
            if variable[5]:
                self.names[variable[4]] = Operand(format(int(variable[6]), f'0{width}b'), bool(variable[2]))
            else:
                assert self.target is None and variable[4] == 't'
                self.target = variable[1], width, bool(variable[2])
        elif single: self.names[single[1]] = Operand(single[2])
        elif net:
            assert net[3] == 'w'
            self.net = int(net[2]) + 1
        elif wire:
            assert wire[1] == 'w'
            self.wire_text = wire[2]
        else: raise AssertionError(('unsupported declaration', line))

    def operand(self, text):
        text = text.strip()
        return self.names[text] if text in self.names else read_literal(text)

    def evaluate(self, text, context):
        """The value of an assignment source, cut to the context width (11.6.1, 11.8.2)."""
        text = text.strip()
        choice = re.fullmatch(r'c \? (.*) : (\w+)', text)
        negation = re.fullmatch(r'-(.*)', text)
        addition = re.fullmatch(r'(.*) \+ (\w+)', text)
        shift = re.fullmatch(r'(.*) (>>>|>>) 1', text)
        if choice:
            first, second = self.operand(choice[1]), self.operand(choice[2])
            width = max(context, len(first.bits), len(second.bits))
            signed = first.signed and second.signed
            chosen = first if self.names['c'].bits == '1' else second
            return chosen.widened(width, signed)[-context:]
        if addition:
            first, second = self.operand(addition[1]), self.operand(addition[2])
            width = max(context, len(first.bits), len(second.bits))
            signed = first.signed and second.signed
            left, right = first.widened(width, signed), second.widened(width, signed)
            if set(left + right) - set('01'): return 'x' * context
            total = (int(left, 2) + int(right, 2)) % (1 << width)
            return format(total, f'0{width}b')[-context:]
        if negation:
            value = self.operand(negation[1])
            width = max(context, len(value.bits))
            bits = value.widened(width, value.signed)
            if set(bits) - set('01'): return 'x' * context
            return format(-int(bits, 2) % (1 << width), f'0{width}b')[-context:]
        if shift:
            value = self.operand(shift[1])
            width = max(context, len(value.bits))
            bits = value.widened(width, value.signed)
            return ((bits[0] if value.signed and shift[2] == '>>>' else '0') + bits[:-1])[-context:]
        value = self.operand(text)
        return value.widened(max(context, len(value.bits)), value.signed)[-context:]

    def run(self):
        state, width, _ = self.target
        target = None
        lines = []
        for statement in (item.strip() for item in self.program.split(';') if item.strip()):
            write = re.fullmatch(r't = (.*)', statement, re.S)
            shown = re.fullmatch(r'\$display\("(\w) %b", ([tw])\)', statement)
            size = re.fullmatch(r'\$display\("s %0d", \$bits\((.*)\)\)', statement)
            if statement == '#1': continue
            if write:
                target = self.evaluate(write[1], width)
                if state == 'bit': target = re.sub('[xz]', '0', target)
            elif shown:
                value = target if shown[2] == 't' else self.evaluate(self.wire_text, self.net)
                lines.append(f'{shown[1]} {value}')
            elif size:
                value = read_literal(size[1])
                assert value.sized or value.fills, 'the width of an unsized number is not fixed'
                lines.append(f's {len(value.bits)}')
            else: raise AssertionError(('unsupported statement', statement))
        return '\n'.join(lines) + '\n'


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index]) for name, index in
                (('negate', 0), ('assign_x', 1), ('shift_z', 2), ('cond_bit', 3), ('fill_add', 4), ('fill_bit', 5))}
    faults = (
        ('lost_sign', 'negate', [("12'shZacb", "12'hZacb")]),
        ('wrong_digit', 'negate', [("12'shZacb", "12'shZbcb")]),
        ('wider_size', 'negate', [("12'shZacb", "13'shZacb")]),
        ('lost_macro_sign', 'negate', [("`define BS 'sh", "`define BS 'h")]),
        ('zero_pad', 'assign_x', [("6'bx01", "6'b0x01")]),
        ('state_kept', 'fill_bit', [('bit [7:0] t;', 'logic [7:0] t;')]),
        ('wrong_mate', 'fill_add', [("'1 + sv", "'0 + sv")]),
        ('logical_shift', 'shift_z', [(">>> 1", ">> 1")]),
        ('other_arm', 'cond_bit', [("logic c = 1'b1", "logic c = 1'b0")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_literal.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_literal.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent reading of literal tokens and of expression width and sign in actual SV. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
