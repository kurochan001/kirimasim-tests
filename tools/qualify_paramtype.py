#!/usr/bin/env python3
"""Interpret actual parameter override programs independently.

The child's parameter declaration gives an optional type and range; the
instantiation, a defparam and a local parameter of the parent give the
override values. The last override wins, a defparam over the instantiation.
Each value is computed from its tokens with its own width and sign, and the
declaration then fixes the result: no type or range keeps the value's type,
a range alone is unsigned, signed alone keeps the value's range, and a type
with a range converts to both. A packed structure is read through its members.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_paramtype as generator

TOKEN = re.compile(r"\s*(\d+'s?[bdh][0-9a-fA-F_]+|\d+|[A-Za-z_]\w*|[-+{}(),])")


class Value:
    def __init__(self, width, signed, bits):
        self.width, self.signed = width, signed
        self.bits = bits & ((1 << width) - 1)

    def number(self):
        return self.bits - (1 << self.width) if self.signed and self.bits >> self.width - 1 else self.bits

    def to(self, width, signed):
        """Conversion as by an assignment: extend by this value's sign, keep the low bits."""
        bits = self.number() if self.signed else self.bits
        return Value(width, signed, bits)


def lex(text):
    out, at = [], 0
    text = text.strip()
    while at < len(text):
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:])
        out.append(found[1])
        at = found.end()
    return out


def evaluate(text, names):
    """A self-determined value of + - unary minus, concatenation, literals and names."""
    items, at = lex(text), 0

    def take():
        nonlocal at
        at += 1
        return items[at - 1]

    def primary():
        item = take()
        if item == '-':
            inner = primary()
            return Value(inner.width, inner.signed, -inner.number())
        if item == '(':
            inner = expression()
            assert take() == ')'
            return inner
        if item == '{':
            parts = [expression()]
            while items[at] == ',':
                take()
                parts.append(expression())
            assert take() == '}'
            bits, width = 0, 0
            for part in parts:
                bits, width = bits << part.width | part.bits, width + part.width
            return Value(width, False, bits)
        based = re.fullmatch(r"(\d+)'(s?)([bdh])([0-9a-fA-F_]+)", item)
        if based:
            return Value(int(based[1]), bool(based[2]), int(based[4].replace('_', ''), {'b': 2, 'd': 10, 'h': 16}[based[3]]))
        assert not item.isdigit(), 'an unsized number has no fixed range'
        return names[item]

    def expression():
        left = primary()
        while at < len(items) and items[at] in ('+', '-'):
            op = take()
            right = primary()
            width, signed = max(left.width, right.width), left.signed and right.signed
            a, b = left.to(width, signed).bits, right.to(width, signed).bits
            left = Value(width, signed, a + b if op == '+' else a - b)
        return left
    result = expression()
    assert at == len(items), ('unread tokens', items[at:])
    return result


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        self.fields = None
        packed = re.search(r'typedef struct packed \{(.*?)\} (\w+);', code, re.S)
        if packed:
            self.fields = [(m[3], bool(m[1]), int(m[2]) + 1)
                           for m in re.finditer(r'logic( signed)? \[(\d+):0\] (\w+);', packed[1])]
            self.struct_name = packed[2]
        child = re.search(r'module (\w+) #\(parameter (.*?)P = (.*?)\) \(\);(.*?)endmodule', code, re.S)
        assert child, 'no child'
        self.child, self.kind, self.default, body = child[1], child[2].strip(), child[3], child[4]
        self.shows = re.findall(r'\$display\("(.*?)", (.*?)\);', body)
        top = re.search(r'module (\w+);(.*?)endmodule', code[child.end():], re.S)
        assert top, 'no top'
        self.parent = top[2]

    def declared(self):
        """The width and sign the declaration fixes, None where the value decides."""
        kind = self.kind
        if kind == '': return None, None
        if kind == 'int': return 32, True
        if kind == 'signed': return None, True
        if self.fields and kind == self.struct_name: return sum(w for _, _, w in self.fields), False
        ranged = re.fullmatch(r'(?:(logic) )?(signed )?\[(\d+):(\d+)\]', kind)
        assert ranged, ('unsupported declaration', kind)
        return int(ranged[3]) - int(ranged[4]) + 1, bool(ranged[2])

    def final(self):
        names = {}
        for local in re.finditer(r'localparam (\w+) = (.*?);', self.parent):
            names[local[1]] = evaluate(local[2], names)
        override = evaluate(self.default, names)
        instances = re.findall(rf'{self.child}( #\((.*?)\))? (\w+) \(\);', self.parent)
        assert len(instances) == 1, 'one instance'
        _, given, instance = instances[0]
        if given:
            named = re.fullmatch(r'\.P\((.*)\)', given)
            override = evaluate(named[1] if named else given, names)
        for target, text in re.findall(r'defparam (\w+)\.P = (.*?);', self.parent):
            assert target == instance, 'defparam of another instance'
            override = evaluate(text, names)
        width, signed = self.declared()
        return override.to(width or override.width, override.signed if signed is None else signed)

    def run(self):
        value = self.final()
        out = []
        for text, arguments in self.shows:
            values = []
            for argument in (a.strip() for a in arguments.split(',')):
                if argument == 'P': values.append(value.number())
                elif argument == '$bits(P)': values.append(value.width)
                elif argument == 'P < 0': values.append(int(value.number() < 0))
                else:
                    member = re.fullmatch(r'P\.(\w+)', argument)
                    assert member and self.fields, ('unsupported argument', argument)
                    low = 0
                    for name, signed, width in reversed(self.fields):
                        if name == member[1]:
                            values.append(Value(width, signed, value.bits >> low).number())
                            break
                        low += width
                    else:
                        raise AssertionError(('no member', argument))
            assert text.count('%0d') == len(values), 'arguments'
            out.append(re.sub('%0d', lambda _: str(values.pop(0)), text) + '\n')
        return ''.join(out)


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def selected(row):
    assert row in generator.MODEL.select(), row
    return generator.make_case(row)


def variants():
    # Native controls must pass on kirimasim, so they avoid a defparam of an
    # untyped or signed-only parameter; the selected tests witness that.
    controls = {'untyped_named': selected(('untyped', 'concat', 'named')),
                'signed_named': selected(('signed', 'wide', 'named')),
                'signed_default': anchor(('signed', 'narrow', 'default')),
                'range_ordered': anchor(('range', 'ssized', 'ordered')),
                'int_named': anchor(('int', 'ssized', 'named')),
                'logic_local': anchor(('logic', 'sum', 'local')),
                'struct_defparam': anchor(('struct', 'sized', 'defparam')),
                'srange_both': anchor(('srange', 'sized', 'both'))}
    faults = (
        ('ranged_parameter', 'untyped_named', [('#(parameter P =', '#(parameter [7:0] P =')]),
        ('other_value', 'signed_named', [("#(.P(12'hf0f))", "#(.P(12'h70f))")]),
        ('unsigned_parameter', 'signed_default', [('#(parameter signed P', '#(parameter P')]),
        ('wider_range', 'range_ordered', [('#(parameter [7:0] P', '#(parameter [11:0] P')]),
        ('positive_value', 'int_named', [("#(.P(-8'sd3))", "#(.P(8'sd3))")]),
        ('wider_logic', 'logic_local', [('#(parameter logic [3:0] P', '#(parameter logic [7:0] P')]),
        ('swapped_members', 'struct_defparam', [('logic signed [3:0] hi; logic [3:0] lo;',
                                                 'logic [3:0] lo; logic signed [3:0] hi;')]),
        ('instance_value', 'srange_both', [("  defparam u.P = 8'd200;\n", '')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_paramtype.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_paramtype.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent override resolution and type conversion of actual parameter programs, from the tokens '
            'of each value. Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
