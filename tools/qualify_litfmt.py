#!/usr/bin/env python3
"""Interpret actual literal formatting programs independently.

The literal is lexed from the text of the program into a list of bit values,
least significant first, with its width and sign. A parameter or a macro
gives the same literal and a concatenation drops its sign. Each format then
walks the bits: groups of four or three for a radix, one character for a
decimal value with an unknown bit, the width of the largest value, a field
width, and the text of a string literal argument as it stands.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_litfmt as generator

RADIX = {'b': 2, 'o': 8, 'd': 10, 'h': 16}


class Value:
    def __init__(self, bits, signed):
        self.bits, self.signed = bits, signed    # least significant bit first

    @property
    def width(self): return len(self.bits)


def unescape(text):
    """The characters of a quoted string, with its escapes."""
    out, i = [], 0
    while i < len(text):
        if text[i] != '\\':
            out.append(text[i])
            i += 1
            continue
        octal = re.match(r'[0-7]{1,3}', text[i + 1:])
        hexadecimal = re.match(r'x([0-9a-fA-F]{1,2})', text[i + 1:])
        if octal:
            out.append(chr(int(octal[0], 8)))
            i += 1 + len(octal[0])
        elif hexadecimal:
            out.append(chr(int(hexadecimal[1], 16)))
            i += 1 + len(hexadecimal[0])
        else:
            out.append({'n': '\n', 't': '\t', '\\': '\\', '"': '"'}[text[i + 1]])
            i += 2
    return ''.join(out)


def literal(text):
    """A Value from the text of a literal."""
    text = text.strip()
    if text.startswith('"'):
        chars = unescape(text[1:-1])
        bits = []
        for char in reversed(chars):
            bits += [str(ord(char) >> k & 1) for k in range(8)]
        return Value(bits, False)
    if text.startswith('-'):
        inner = literal(text[1:])
        assert set(inner.bits) <= {'0', '1'}, 'negating unknown bits'
        number = -int(''.join(reversed(inner.bits)), 2) % (1 << inner.width)
        return Value([str(number >> k & 1) for k in range(inner.width)], inner.signed)
    fill = re.fullmatch(r"'([01xXzZ])", text)
    if fill: return Value([fill[1].lower()], False)
    if re.fullmatch(r'\d[\d_]*', text):
        number = int(text.replace('_', ''))
        return Value([str(number >> k & 1) for k in range(32)], True)
    based = re.fullmatch(r"(\d+)?'([sS]?)([bBoOdDhH])([0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]*)", text)
    assert based, ('unsupported literal', text)
    size = int(based[1]) if based[1] else 32
    base = RADIX[based[3].lower()]
    digits = based[4].replace('_', '').lower().replace('?', 'z')
    if base == 10:
        assert digits.isdigit(), ('decimal digits', digits)
        number = int(digits)
        bits = [str(number >> k & 1) for k in range(max(number.bit_length(), 1))]
    else:
        step = {2: 1, 8: 3, 16: 4}[base]
        bits = []
        for digit in reversed(digits):
            if digit in 'xz': bits += [digit] * step
            else: bits += [str(int(digit, base) >> k & 1) for k in range(step)]
    pad = bits[-1] if bits[-1] in 'xz' else '0'
    bits = (bits + [pad] * size)[:size]
    return Value(bits, bool(based[2]))


def digit(group):
    if all(bit == 'x' for bit in group): return 'x'
    if all(bit == 'z' for bit in group): return 'z'
    if 'x' in group: return 'X'
    if 'z' in group: return 'Z'
    return format(sum(int(bit) << k for k, bit in enumerate(group)), 'x')


def radix_text(value, step):
    groups = [value.bits[i:i + step] for i in range(0, value.width, step)]
    return ''.join(digit(group) for group in reversed(groups))


def format_value(value, letter, field):
    """One format specification, with field None for the automatic width."""
    if letter == 's':
        chars = [sum(int(bit) << k for k, bit in enumerate(value.bits[i:i + 8]))
                 for i in range(0, value.width, 8)]
        return ''.join(chr(c) for c in reversed(chars) if c)
    if letter == 'd':
        if any(bit in 'xz' for bit in value.bits):
            text = digit(value.bits)
        else:
            number = sum(int(bit) << k for k, bit in enumerate(value.bits))
            if value.signed and value.bits[-1] == '1': number -= 1 << value.width
            text = str(number)
        if field is None:
            assert not value.signed, 'the full width of a signed decimal is not fixed'
            field = len(str((1 << value.width) - 1))
        return text.rjust(field)
    text = radix_text(value, {'h': 4, 'x': 4, 'o': 3, 'b': 1}[letter])
    if field is None: return text
    return (text.lstrip('0') or '0').rjust(field, '0')


def apply_format(spec, arguments):
    """The text of a format string with its arguments."""
    out, rest = [], list(arguments)

    def replace(match):
        if match[0] == '%%': return '%'
        value = rest.pop(0)
        field = int(match[1]) if match[1] else None
        if isinstance(value, str):
            assert match[2] == 's', 'a string with a radix'
            return value
        return format_value(value, match[2].lower(), field)
    out = re.sub(r'%(\d*)([dDhHxXoObBsS])|%%', replace, spec)
    assert not rest, 'too many arguments'
    return out


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        # A macro is text: expand it before anything reads the program.
        macros = dict(re.findall(r'^`define (\w+) (.*)$', code, re.M))
        code = re.sub(r'^`define .*$', '', code, flags=re.M)
        for name, text in macros.items(): code = code.replace('`' + name, text)
        assert '`' not in code, 'unknown macro'
        found = re.search(r'module \w+;(.*?)initial begin(.*?)end\s*endmodule', code, re.S)
        assert found, 'unsupported program'
        self.params, self.strings = {}, {}
        for item in (part.strip() for part in found[1].split(';') if part.strip()):
            param = re.fullmatch(r'localparam (\w+) = (.*)', item)
            if param: self.params[param[1]] = param[2]
            elif re.fullmatch(r'string \w+', item): self.strings[item.split()[1]] = ''
            else: raise AssertionError(('unsupported item', item))
        self.statements = self.split(found[2])

    @staticmethod
    def split(text):
        statements, depth, current, quoted = [], 0, '', False
        for i, char in enumerate(text):
            if char == '"' and text[i - 1] != '\\': quoted = not quoted
            if not quoted and char in '({': depth += 1
            if not quoted and char in ')}': depth -= 1
            if char == ';' and depth == 0 and not quoted:
                statements.append(current.strip())
                current = ''
            else:
                current += char
        assert not current.strip(), 'unterminated statement'
        return statements

    @staticmethod
    def arguments(text):
        items, depth, current, quoted = [], 0, '', False
        for i, char in enumerate(text):
            if char == '"' and (i == 0 or text[i - 1] != '\\'): quoted = not quoted
            if not quoted and char in '({': depth += 1
            if not quoted and char in ')}': depth -= 1
            if char == ',' and depth == 0 and not quoted:
                items.append(current.strip())
                current = ''
            else:
                current += char
        items.append(current.strip())
        return items

    def expression(self, text):
        """The Value of an argument, or the text of a string variable."""
        if text in self.strings: return self.strings[text]
        if text in self.params: return literal(self.params[text])
        if text.startswith('{') and text.endswith('}'):
            inner = self.expression(text[1:-1])
            assert inner.width > 0 and not re.fullmatch(r"\d+|'.", text[1:-1].strip()), 'unsized in a concatenation'
            return Value(inner.bits, False)
        return literal(text)

    def formatted(self, items, radix='d'):
        """The text of the arguments of a display task."""
        out, i = [], 0
        while i < len(items):
            item = items[i]
            if item.startswith('"'):
                text = unescape(item[1:-1])
                assert not re.search(r'%(?!\d*[dDhHxXoObBsS]|%)', text), ('unsupported format', text)
                count = len(re.findall(r'%\d*[dDhHxXoObBsS]', text))
                out.append(apply_format(text, [self.expression(a) for a in items[i + 1:i + 1 + count]]))
                i += 1 + count
            else:
                out.append(format_value(self.expression(item), radix, None))
                i += 1
        return ''.join(out)

    def run(self):
        out = []
        for statement in self.statements:
            call = re.fullmatch(r'(\$\w+)\((.*)\)', statement, re.S)
            assign = re.fullmatch(r'(\w+) = \$sformatf\((.*)\)', statement, re.S)
            if assign:
                self.strings[assign[1]] = self.formatted(self.arguments(assign[2]))
                continue
            assert call, ('unsupported statement', statement)
            task, items = call[1], self.arguments(call[2])
            if task == '$swrite':
                self.strings[items[0]] = self.formatted(items[1:])
            elif task == '$fdisplay':
                assert items[0] == "32'h8000_0001", 'not standard output'
                out.append(self.formatted(items[1:]) + '\n')
            elif task in ('$display', '$displayh', '$displayo', '$displayb'):
                out.append(self.formatted(items, {'$display': 'd'}.get(task, task[-1])) + '\n')
            elif task == '$write':
                out.append(self.formatted(items))
            else:
                raise AssertionError(('unsupported task', task))
        return ''.join(out)


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'xpad_field': anchor(('xpad', 'wh', 'display', 'direct')),
                'octal_default': anchor(('octal', 'o', 'default', 'macro')),
                'qmark_minimum': anchor(('qmark', '0h', 'sformatf', 'param')),
                'signed_concat': anchor(('signed', 'd', 'swrite', 'concat')),
                'string_text': anchor(('string', 'd', 'default', 'direct')),
                'string_param': anchor(('string', 'h', 'default', 'param')),
                'fill_field': anchor(('fill', 'wh', 'fdisplay', 'macro')),
                'unsized_field': anchor(('unsized', 'wd', 'write', 'param')),
                'zpad_concat': anchor(('zpad', 'd', 'display', 'concat'))}
    faults = (
        ('zero_padding', 'xpad_field', [("12'hx5", "12'h05")]),
        ('other_radix', 'octal_default', [('$displayo(', '$displayh(')]),
        ('no_question_mark', 'qmark_minimum', [("8'b0?0?_10z1", "8'b0101_10z1")]),
        ('kept_sign', 'signed_concat', [("{4'shf}", "4'shf"), ('":%d:"', '":%0d:"')]),
        ('string_variable', 'string_text', [('$display(":", "\\x41\\101", ":");',
                                             '$display(":", 16\'h4141, ":");')]),
        ('other_escape', 'string_param', [('\\x41', '\\x42')]),
        ('other_field', 'fill_field', [('":%8h:"', '":%6h:"')]),
        ('decimal_field', 'unsized_field', [('localparam P = 13;', 'localparam P = 130;')]),
        ('narrower_value', 'zpad_concat', [("{12'hz3}", "{8'hz3}")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_litfmt.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_litfmt.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent lexing and formatting of actual programs, bit by bit from the text of each literal. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
