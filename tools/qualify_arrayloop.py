#!/usr/bin/env python3
"""Interpret actual array query loop programs independently.

Each declaration becomes a list of dimensions, unpacked first and then packed,
as 20.7 numbers them; a typedef is expanded first. A fixed dimension keeps its
bounds, and a dynamic array or queue has its current size. The query
functions follow the rules of 20.7 from these dimensions, for a variable, a
type, a dimension number or an element select. The statements, integer
expressions and loops are evaluated directly. A read of an element that does
not exist gives x (Table 7-1).
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_arrayloop as generator

QUERIES = ('left', 'right', 'low', 'high', 'increment', 'size', 'dimensions', 'unpacked_dimensions')
TOKEN = re.compile(r"\s*(\"[^\"]*\"|\$\w+|\d+'h[0-9a-f]+|\d+|\w+|!=|<=|>=|-=|\+\+|--|[-+*<>()\[\],;=.$:])")


def lex(text):
    out, at = [], 0
    while text[at:].strip():
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:at + 40])
        out.append(found[1])
        at = found.end()
    return out


class Stream:
    def __init__(self, tokens): self.tokens, self.at = tokens, 0

    def peek(self, ahead=0): return self.tokens[self.at + ahead] if self.at + ahead < len(self.tokens) else None

    def take(self, expected=None):
        item = self.peek()
        assert item is not None, 'unexpected end'
        assert expected is None or item == expected, ('expected', expected, item)
        self.at += 1
        return item


def dimension(s, packed):
    """One bracketed dimension as (kind, left, right, packed); kind is fixed, dynamic or queue."""
    s.take('[')
    if s.peek() in (']', '$'):
        kind = 'queue' if s.take() == '$' else 'dynamic'
        if kind == 'queue': s.take(']')
        assert not packed, 'a packed dimension has a fixed size'
        return (kind, None, None, False)
    left = signed_number(s)
    s.take(':')
    right = signed_number(s)
    s.take(']')
    return ('fixed', left, right, packed)


def signed_number(s):
    if s.peek() == '-':
        s.take()
        return -int(s.take())
    return int(s.take())


class Array:
    """A variable: its dimensions, unpacked first, and its elements by index path."""

    def __init__(self, dims):
        self.dims = dims
        self.store = self.empty(dims)

    def empty(self, dims):
        kind = dims[0]
        if len(dims) == 1: return None  # the 8-bit element
        if kind[0] == 'fixed':
            low, high = sorted(kind[1:3])
            return {index: self.empty(dims[1:]) for index in range(low, high + 1)}
        return []


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;\n(.*)endmodule\s*', code, re.S)
        assert found, 'unsupported program'
        s = Stream(lex(found[1]))
        self.types, self.arrays, self.ints, self.body, self.out = {}, {}, {}, None, []
        while s.peek() is not None:
            item = s.peek()
            if item == 'typedef':
                s.take()
                name, dims = self.declaration(s)
                self.types[name] = dims
            elif item == 'logic' or item in self.types:
                name, dims = self.declaration(s)
                self.arrays[name] = Array(dims)
            elif item == 'int':
                s.take()
                self.ints[s.take()] = 0
                while s.peek() == ',':
                    s.take()
                    self.ints[s.take()] = 0
                s.take(';')
            elif item == 'initial':
                s.take()
                self.body = self.statement(s)
            else:
                raise AssertionError(('unsupported item', item))

    def declaration(self, s):
        base = s.take()
        if base == 'logic':
            packed = []
            while s.peek() == '[': packed.append(dimension(s, True))
            assert packed[-1] == ('fixed', 7, 0, True), 'elements of 8 bits'
        else:
            packed = list(self.types[base])
        name = s.take()
        unpacked = []
        while s.peek() == '[': unpacked.append(dimension(s, False))
        s.take(';')
        # The unpacked dimensions of the variable come first, then those of its type, then the packed ones.
        if base != 'logic': return name, unpacked + packed
        return name, unpacked + packed

    # Statements as closures over the program state.
    def statement(self, s):
        item = s.peek()
        if item == 'begin':
            s.take()
            parts = []
            while s.peek() != 'end': parts.append(self.statement(s))
            s.take('end')
            return ('seq', parts)
        if item == 'for':
            s.take()
            s.take('(')
            start = self.simple(s, ';')
            condition = self.expression(s)
            s.take(';')
            step = self.simple(s, ')')
            return ('for', start, condition, step, self.statement(s))
        if item == 'while':
            s.take()
            s.take('(')
            condition = self.expression(s)
            s.take(')')
            return ('while', condition, self.statement(s))
        if item == 'do':
            s.take()
            body = self.statement(s)
            s.take('while')
            s.take('(')
            condition = self.expression(s)
            s.take(')')
            s.take(';')
            return ('do', body, condition)
        if item == 'repeat':
            s.take()
            s.take('(')
            count = self.expression(s)
            s.take(')')
            return ('repeat', count, self.statement(s))
        if item == 'foreach':
            s.take()
            s.take('(')
            name = s.take()
            s.take('[')
            variables = [s.take()]
            while s.peek() == ',':
                s.take()
                variables.append(s.take())
            s.take(']')
            s.take(')')
            return ('foreach', name, variables, self.statement(s))
        if item in ('$display', '$write'):
            s.take()
            arguments = []
            if s.peek() == '(':
                s.take('(')
                arguments.append(s.take())
                while s.peek() == ',':
                    s.take()
                    arguments.append(self.expression(s))
                s.take(')')
            s.take(';')
            return ('show', item == '$display', arguments)
        return self.simple(s, ';')

    def simple(self, s, end):
        """An assignment, an increment, new[], push_back or push_front, up to the end token."""
        target = self.lvalue(s)
        item = s.take()
        if item in ('++', '--'):
            s.take(end)
            return ('step', target, 1 if item == '++' else -1)
        if item == '.':
            method = s.take()
            assert method in ('push_back', 'push_front'), ('unsupported method', method)
            s.take('(')
            value = self.expression(s)
            s.take(')')
            s.take(end)
            return (method, target, value)
        assert item in ('=', '-='), ('unsupported statement', item)
        if s.peek() == 'new':
            s.take()
            s.take('[')
            size = self.expression(s)
            s.take(']')
            s.take(end)
            return ('new', target, size)
        value = self.expression(s)
        s.take(end)
        return ('set' if item == '=' else 'less', target, value)

    def lvalue(self, s):
        name = s.take()
        indices = []
        while s.peek() == '[':
            s.take('[')
            indices.append(self.expression(s))
            s.take(']')
        return (name, indices)

    def expression(self, s):
        left = self.additive(s)
        while s.peek() in ('!=', '<=', '>=', '<', '>'):
            op = s.take()
            right = self.additive(s)
            left = ('op', op, left, right)
        return left

    def additive(self, s):
        left = self.term(s)
        while s.peek() in ('+', '-'):
            op = s.take()
            left = ('op', op, left, self.term(s))
        return left

    def term(self, s):
        left = self.unary(s)
        while s.peek() == '*':
            s.take()
            left = ('op', '*', left, self.unary(s))
        return left

    def unary(self, s):
        item = s.take()
        if item == '-': return ('op', '-', ('number', 0), self.unary(s))
        if item.isdigit(): return ('number', int(item))
        byte = re.fullmatch(r"8'h([0-9a-f]+)", item)
        if byte: return ('number', int(byte[1], 16))
        if item.startswith('$'):
            assert item[1:] in QUERIES, ('unsupported function', item)
            s.take('(')
            argument = self.lvalue(s)
            number = None
            if s.peek() == ',':
                s.take()
                number = self.expression(s)
            s.take(')')
            return ('query', item[1:], argument, number)
        s.at -= 1
        return ('read', self.lvalue(s))

    # Evaluation.
    def dims_of(self, name, indices):
        """The dimensions an expression has, and the elements it holds, after its selects."""
        if name in self.types:
            assert not indices
            return self.types[name], None
        array = self.arrays[name]
        dims, store = array.dims, array.store
        for index in indices:
            store = store[index] if isinstance(store, dict) else store[index]
            dims = dims[1:]
        return dims, store

    def query(self, function, argument, number):
        name, indices = argument
        dims, store = self.dims_of(name, [self.value(i) for i in indices])
        if function == 'dimensions': return len(dims)
        if function == 'unpacked_dimensions': return sum(1 for d in dims if not d[3])
        which = 1 if number is None else self.value(number)
        dim = dims[which - 1]
        if dim[0] == 'fixed':
            left, right = dim[1], dim[2]
            increment = 1 if left >= right else -1
        else:
            assert which == 1, 'a variable-sized dimension after the first'
            assert store is not None, 'a dynamically sized type'
            left, right, increment = 0, len(store) - 1, -1
        low, high = (left, right) if increment == -1 else (right, left)
        return {'left': left, 'right': right, 'increment': increment, 'low': low, 'high': high,
                'size': high - low + 1}[function]

    def value(self, item):
        kind = item[0]
        if kind == 'number': return item[1]
        if kind == 'op':
            a, b = self.value(item[2]), self.value(item[3])
            return {'+': a + b, '-': a - b, '*': a * b, '!=': int(a != b), '<=': int(a <= b), '>=': int(a >= b),
                    '<': int(a < b), '>': int(a > b)}[item[1]]
        if kind == 'query': return self.query(item[1], item[2], item[3])
        name, indices = item[1]
        if name in self.ints and not indices: return self.ints[name]
        return self.element(name, [self.value(i) for i in indices])

    def element(self, name, indices):
        """The element value, or None for x when it does not exist."""
        store = self.arrays[name].store
        dims = self.arrays[name].dims
        for index in indices:
            if dims[0][0] == 'fixed':
                low, high = sorted(dims[0][1:3])
                if not low <= index <= high: return None
                store = store[index]
            else:
                if not 0 <= index < len(store): return None
                store = store[index]
            dims = dims[1:]
        return store

    def assign(self, target, value):
        name, indices = target
        if name in self.ints and not indices:
            self.ints[name] = value
            return
        indices = [self.value(i) for i in indices]
        store = self.arrays[name].store
        for index in indices[:-1]: store = store[index]
        store[indices[-1]] = value

    def container(self, target):
        name, indices = target
        store = self.arrays[name].store
        for index in (self.value(i) for i in indices): store = store[index]
        return store

    def run_statement(self, item):
        kind = item[0]
        if kind == 'seq':
            for part in item[1]: self.run_statement(part)
        elif kind == 'for':
            self.run_statement(item[1])
            while self.value(item[2]):
                self.run_statement(item[4])
                self.run_statement(item[3])
        elif kind == 'while':
            while self.value(item[1]): self.run_statement(item[2])
        elif kind == 'do':
            self.run_statement(item[1])
            while self.value(item[2]): self.run_statement(item[1])
        elif kind == 'repeat':
            for _ in range(self.value(item[1])): self.run_statement(item[2])
        elif kind == 'foreach':
            self.foreach(item[1], item[2], item[3], [])
        elif kind == 'show':
            self.show(item[1], item[2])
        elif kind == 'step':
            self.assign(item[1], self.value(('read', item[1])) + item[2])
        elif kind == 'set':
            self.assign(item[1], self.value(item[2]))
        elif kind == 'less':
            self.assign(item[1], self.value(('read', item[1])) - self.value(item[2]))
        elif kind == 'new':
            name, indices = item[1]
            fresh = [None] * self.value(item[2])
            if indices:
                self.container((name, indices[:-1]))[self.value(indices[-1])] = fresh
            else:
                self.arrays[name].store = fresh
        elif kind == 'push_back':
            self.container(item[1]).append(self.value(item[2]))
        elif kind == 'push_front':
            self.container(item[1]).insert(0, self.value(item[2]))
        else:
            raise AssertionError(('unknown statement', kind))

    def foreach(self, name, variables, body, prefix):
        """The loop variables walk each dimension from its left bound to its right bound."""
        dims, store = self.dims_of(name, prefix)
        dim = dims[0]
        if dim[0] == 'fixed':
            left, right = dim[1], dim[2]
            indices = range(left, right - 1, -1) if left >= right else range(left, right + 1)
        else:
            indices = range(len(store))
        for index in indices:
            self.ints[variables[0]] = index
            if len(variables) > 1: self.foreach(name, variables[1:], body, prefix + [index])
            else: self.run_statement(body)

    def show(self, newline, arguments):
        if not arguments:
            self.out.append('\n' if newline else '')
            return
        text, values = arguments[0][1:-1], [self.value(a) for a in arguments[1:]]
        specifiers = re.findall(r'%0d|%h', text)
        assert len(specifiers) == len(values), 'arguments'

        def format(found):
            value = values.pop(0)
            if found[0] == '%0d': return str(value)
            return 'xx' if value is None else f'{value:02x}'
        self.out.append(re.sub(r'%0d|%h', format, text) + ('\n' if newline else ''))

    def run(self):
        self.run_statement(self.body)
        return ''.join(self.out)


def interpret(source):
    program = Program(source)
    return program.run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'empty_do': anchor(('empty', 'elem', 'do', 'highlow')),
                'neg_dim_for': anchor(('neg', 'dim', 'for', 'leftright')),
                'packed_type_while': anchor(('packed', 'type', 'while', 'size')),
                'queue_foreach': anchor(('queue', 'elem', 'foreach', 'leftright')),
                'offset_repeat': anchor(('offset', 'var', 'repeat', 'lowhigh')),
                'dynamic_do': anchor(('dynamic', 'var', 'do', 'leftright')),
                'desc_elem_for': anchor(('desc', 'elem', 'for', 'highlow'))}
    faults = (
        ('start_low', 'empty_do', [('i = $high(w[1]);', 'i = $low(w[1]);')]),
        ('reversed_range', 'neg_dim_for', [('w [1:1][-2:1];', 'w [1:1][1:-2];')]),
        ('descending_packed', 'packed_type_while', [('typedef logic [1:4][7:0] arr_t;', 'typedef logic [4:1][7:0] arr_t;')]),
        ('push_front', 'queue_foreach', [('push_back', 'push_front')]),
        ('step_down', 'offset_repeat', [('    i++;', '    i--;')]),
        ('larger_array', 'dynamic_do', [('a = new[4];', 'a = new[5];')]),
        ('ascending_range', 'desc_elem_for', [('w [1:1][3:0];', 'w [1:1][0:3];')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_arrayloop.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_arrayloop.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent dimensions, array queries and loop evaluation of actual programs. Auxiliary controls '
            'and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
