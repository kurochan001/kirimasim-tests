#!/usr/bin/env python3
"""Interpret actual structure literal programs independently.

The typedefs are read into types: int, byte and integer as 32-, 8- and 32-bit
signed vectors, two-state for int and byte, a typedef of logic [3:0] as a
4-bit unsigned four-state vector, structures and fixed arrays. Two vector
types match when they agree in width, signedness and number of states (6.22.1),
so int and integer do not match. The assignment pattern is parsed and applied
by 10.9.1 and 10.9.2: positions in declaration order, replication repeating
its items, a member name first, then the last type key whose type matches,
then default, and an unmatched structure or array member takes the type and
default keys again inside it. A value is converted as an assignment to the
member (10.7, 6.12.1): an unbased unsized literal fills the member, a signed
literal is sign-extended, an unsigned one zero-extended, a real number rounds
half away from zero, and a two-state member turns x and z into 0. The task
then prints the members with %b and %0d.
"""

import re
import sys
from decimal import ROUND_HALF_UP, Decimal

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_agglit as generator

BUILTIN = {'int': ('vector', 32, True, False), 'byte': ('vector', 8, True, False),
           'integer': ('vector', 32, True, True)}


def vector_type(text):
    found = re.fullmatch(r'(logic|bit)\s*\[(\d+):0\]', text.strip())
    assert found, ('unknown type', text)
    return ('vector', int(found[2]) + 1, False, found[1] == 'logic')


class Types:
    def __init__(self, code):
        self.named = {}
        for found in re.finditer(r'typedef\s+(?:struct\s*\{(.*?)\}|((?:logic|bit)\s*\[\d+:0\]))\s*(\w+)\s*;', code,
                                 flags=re.S):
            inner, body, name = found.groups()
            if inner is not None:
                members = []
                for declaration in inner.split(';'):
                    if not declaration.strip(): continue
                    found = re.fullmatch(r'\s*(\w+)\s+(\w+)\s*(?:\[(\d+)\])?\s*', declaration)
                    assert found, ('member', declaration)
                    kind = self.lookup(found[1])
                    if found[3]: kind = ('array', kind, int(found[3]))
                    members.append((found[2], kind))
                self.named[name] = ('struct', name, members)
            else: self.named[name] = vector_type(body)

    def lookup(self, name): return BUILTIN.get(name) or self.named[name]


def same(a, b):
    if a[0] != b[0]: return False
    if a[0] == 'vector': return a == b
    if a[0] == 'struct': return a[1] == b[1]
    return a[2] == b[2] and same(a[1], b[1])


TOKEN = re.compile(r"\s*(?:('\{)|(\d+'s?[bodh][0-9a-fA-FxXzZ?_]+|'[01xXzZ])|(-?\d+\.\d+)|(-?\d+)|(\w+)|([{}:,]))")


def tokens(text):
    out, at = [], 0
    while text[at:].strip():
        found = TOKEN.match(text, at)
        assert found, ('pattern', text[at:at + 20])
        opener, based, real, integer, word, punct = found.groups()
        out.append(('open',) if opener else ('based', based) if based else ('real', real) if real else
                   ('int', integer) if integer else ('word', word) if word else ('punct', punct))
        at = found.end()
    return out


def parse(items, at=0):
    """A pattern node and the next position: ('list', [nodes]) or ('keys', [(key, node)]); a value is a token."""
    if items[at] != ('open',): return items[at], at + 1
    at += 1
    if items[at][0] == 'int' and items[at + 1] == ('punct', '{'):
        count = int(items[at][1])
        at += 2
        inner = []
        while True:
            node, at = parse(items, at)
            inner.append(node)
            if items[at] == ('punct', ','): at += 1; continue
            break
        assert items[at] == ('punct', '}') and items[at + 1] == ('punct', '}')
        return ('list', inner * count), at + 2
    entries, keyed = [], items[at + 1] == ('punct', ':')
    while True:
        if keyed:
            key = items[at][1]
            assert items[at + 1] == ('punct', ':')
            node, at = parse(items, at + 2)
            entries.append((key, node))
        else:
            node, at = parse(items, at)
            entries.append(node)
        if items[at] == ('punct', ','): at += 1; continue
        assert items[at] == ('punct', '}'), items[at]
        return ('keys' if keyed else 'list', entries), at + 1


def literal_bits(token, width):
    """The bits of a value converted for an assignment to a vector of this width."""
    kind, text = token
    if kind == 'based' and text.startswith("'"): return text[1].lower() * width
    if kind == 'based':
        found = re.fullmatch(r"(\d+)'(s?)([bodh])(.+)", text)
        size, signed, base, digits = int(found[1]), found[2] == 's', found[3], found[4].lower()
        assert base in 'bh' and not set(digits) & set('xz?'), text
        bits = format(int(digits, 2 if base == 'b' else 16), f'0{size}b')[-size:]
        fill = bits[0] if signed else '0'
    else:
        value = int(Decimal(text).quantize(Decimal(1), rounding=ROUND_HALF_UP)) if kind == 'real' else int(text)
        bits, fill = format(value & (2 ** 32 - 1), '032b'), None
        fill = bits[0]
    return (fill * width + bits)[-width:]


def assign(kind, node, keys=None):
    """The value of a member of this type: a bit string, a list or a dict."""
    if kind[0] == 'vector':
        assert node[0] not in ('list', 'keys'), ('pattern for a vector', node)
        bits = literal_bits(node, kind[1])
        return bits if kind[3] else bits.replace('x', '0').replace('z', '0')
    if node is not None and node[0] == 'list':
        parts = node[1]
        if kind[0] == 'struct':
            assert len(parts) == len(kind[2]), 'one item per member'
            return {name: assign(t, p) for (name, t), p in zip(kind[2], parts)}
        assert len(parts) == kind[2], 'one item per element'
        return [assign(kind[1], p) for p in parts]
    entries = node[1] if node is not None else keys
    names = {k: v for k, v in entries if kind[0] == 'struct' and k in [n for n, _ in kind[2]]}
    types, default = [], None
    for k, v in entries:
        if k == 'default': default = v
        elif k not in names: types.append((k, v))
    targets = kind[2] if kind[0] == 'struct' else [(i, kind[1]) for i in range(kind[2])]
    out = {} if kind[0] == 'struct' else [None] * kind[2]
    for name, t in targets:
        typed = [v for k, v in types if same(TYPES.lookup(k), t)]
        if name in names: out[name] = assign(t, names[name])
        elif typed: out[name] = assign(t, typed[-1])
        elif t[0] in ('struct', 'array'):
            assert default is not None or typed, ('member not covered', name)
            out[name] = assign(t, None, [(k, v) for k, v in entries if k not in names])
        else:
            assert default is not None, ('member not covered', name)
            out[name] = assign(t, default)
    return out


def show(bits, signed, spec):
    if spec == 'b': return bits
    if set(bits) <= {'x'}: return 'x'
    if set(bits) <= {'z'}: return 'z'
    if 'x' in bits: return 'X'
    if 'z' in bits: return 'Z'
    value = int(bits, 2)
    if signed and bits[0] == '1': value -= 2 ** len(bits)
    return str(value)


TYPES = None


def interpret(source):
    global TYPES
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    TYPES = Types(code)
    top = TYPES.lookup('out_t')
    found = re.search(r"(?:out_t\s+\w+\s*=|\bv\s*=|show\(out_t|localparam\s+out_t\s+\w+\s*=)\s*('\{)", code)
    assert found, 'no pattern'
    start, depth, at = found.start(1), 0, found.start(1) + 1
    while True:
        depth += {'{': 1, '}': -1}.get(code[at], 0)
        at += 1
        if depth == 0: break
    items = tokens(code[start:at])
    node, end = parse(items)
    assert end == len(items)
    value = assign(top, node)
    display = re.search(r'\$display\("([^"]*)",\s*(.*?)\);', code)
    fmt, args = display[1], [a.strip() for a in display[2].split(',')]
    out = fmt
    for arg in args:
        path = re.fullmatch(r'x\.(\w+)(?:\.(\w+))?(?:\[(\d+)\])?', arg)
        kind, member = top, value
        for step in (path[1], path[2]):
            if step is None: continue
            kind = dict(kind[2])[step]
            member = member[step]
        if path[3] is not None: kind, member = kind[1], member[int(path[3])]
        spec = re.search(r'%(0d|b)', out)
        out = out[:spec.start()] + show(member, kind[2] if kind[0] == 'vector' else False, spec[1][-1]) + \
            out[spec.end():]
    return out + '\n'


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'member_type_init': anchor(('member_type', 'snarrow', 'init')),
                'last_type_typed': anchor(('last_type', 'real', 'typed')),
                'type_init': anchor(('type', 'fillx', 'init')),
                'default_assign': anchor(('default', 'wide', 'assign')),
                'replicate_typed': anchor(('replicate', 'fill1', 'typed')),
                'member_assign': anchor(('member', 'neg', 'assign')),
                'type_default_assign': anchor(('type_default', 'fillx', 'assign'))}
    faults = (
        ('unsigned_narrow', 'member_type_init', [("3'sb101", "3'b101")]),
        ('first_type', 'last_type_typed', [("int: 9, default: 7, int: 2.5", "int: 2.5, default: 7, int: 9")]),
        ('logic_member', 'type_init', [('int i; nib_t l;', 'integer i; nib_t l;')]),
        ('narrower_value', 'default_assign', [("12'h9f5", "8'hf5")]),
        ('zero_fill', 'replicate_typed', [("'1", "'0")]),
        ('other_value', 'member_assign', [('a: -2', 'a: -3')]),
        ('integer_key', 'type_default_assign', [("int: 'x", "integer: 'x")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_agglit.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_agglit.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent reading of the typedefs and the structure literal of the actual programs by 10.9 and '
            '6.22.1. Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
