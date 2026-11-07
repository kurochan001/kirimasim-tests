#!/usr/bin/env python3
"""Interpret actual gate-array programs independently.

Terminal expressions become lists of named bits from the declarations in the
text. One gate is simulated for each instance, and outputs change at exact
times taken from the delay table. A read before an output's first event, a
pulse shorter than a delay and any other form outside the rules are errors.
"""

from fractions import Fraction
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_gatearray as generator


def truth(kind, a, b):
    if kind == 'and':
        if '0' in (a, b): return '0'
        return '1' if (a, b) == ('1', '1') else 'x'
    if kind == 'xnor':
        if {a, b} <= {'0', '1'}: return '1' if a == b else '0'
        return 'x'
    if kind == 'not': return '1' if a == '0' else '0' if a == '1' else 'x'
    if kind == 'bufif1':
        if b == '0': return 'z'
        if b == '1' and a in ('0', '1'): return a
        return 'x'
    assert kind == 'nmos', kind
    if b == '0' or a == 'z': return 'z'
    if b == '1': return a
    return 'x'


class Design:
    def __init__(self, source):
        code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
        parsed = re.fullmatch(r'\s*module \w+;\s*timeunit 1ns / 1ps;(.*?)initial begin(.*?)\$finish;'
                              r'\s*end\s*endmodule\s*', code, re.S)
        assert parsed, 'unsupported program'
        self.ranges, self.nets = {}, set()
        self.values = {}
        self.gate = None
        for item in (part.strip() for part in parsed[1].split(';') if part.strip()):
            self.declare(item)
        assert self.gate
        self.program = parsed[2]
        self.events = {}
        self.pending = {}

    def declare(self, item):
        vector = re.fullmatch(r'(wire|logic) \[(\d+):(\d+)\] (\w+)', item)
        scalars = re.fullmatch(r'(wire|logic) ([\w, ]+)', item)
        gate = re.fullmatch(r'(and|xnor|not|bufif1|nmos)(?: #(\d+|\(\d+, \d+(?:, \d+)?\)))? '
                            r'g\[(\d+):(\d+)\] \((.*)\)', item)
        if vector:
            self.ranges[vector[4]] = int(vector[2]), int(vector[3])
            names = [(vector[4], i) for i in self.indices(vector[4])]
            self.add(vector[1], names)
        elif scalars:
            names = [(name.strip(), None) for name in scalars[2].split(',')]
            self.add(scalars[1], names)
        elif gate:
            assert self.gate is None
            kind, timing, left, right, terminals = gate.groups()
            self.gate = dict(kind=kind, delays=self.delays(timing), left=int(left), right=int(right),
                             terminals=self.split_terminals(terminals))
        else:
            raise AssertionError(('unsupported item', item))

    def add(self, kind, names):
        for name in names:
            if kind == 'wire': self.nets.add(name)
            else: self.values[name] = 'x'

    def indices(self, name):
        left, right = self.ranges[name]
        step = 1 if left < right else -1
        return list(range(left, right + step, step))

    @staticmethod
    def delays(text):
        if not text: return 0, 0, 0
        numbers = [int(part) for part in re.findall(r'\d+', text)]
        if len(numbers) == 1: return numbers[0], numbers[0], numbers[0]
        if len(numbers) == 2: return numbers[0], numbers[1], min(numbers)
        return tuple(numbers)

    @staticmethod
    def split_terminals(text):
        parts, depth, current = [], 0, ''
        for char in text:
            if char == ',' and not depth:
                parts.append(current.strip())
                current = ''
            else:
                depth += (char == '{') - (char == '}')
                current += char
        return parts + [current.strip()]

    def bits(self, expression):
        """Named bits of an expression, least significant first."""
        expression = expression.strip()
        if expression.startswith('{'):
            names = []
            for part in reversed(self.split_terminals(expression[1:-1])): names += self.bits(part)
            return names
        part = re.fullmatch(r'(\w+)\[(\d+):(\d+)\]', expression)
        if part:
            assert int(part[2]) > int(part[3]) and self.ranges[part[1]][0] > self.ranges[part[1]][1]
            return [(part[1], i) for i in range(int(part[3]), int(part[2]) + 1)]
        if expression in self.ranges: return [(expression, i) for i in reversed(self.indices(expression))]
        return [(expression, None)]

    def connect(self):
        count = abs(self.gate['left'] - self.gate['right']) + 1
        terminals = [self.bits(term) for term in self.gate['terminals']]
        assert len(terminals[0]) == count, 'an output must have one bit for each instance'
        for term in terminals:
            assert len(term) in (1, count), 'too many or too few bits to connect'
        # Position 0 is the instance of the right-hand index, on the LSB (28.3.6).
        return [[term[position] if len(term) == count else term[0] for term in terminals]
                for position in range(count)]

    def delay_of(self, value):
        rise, fall, off = self.gate['delays']
        return {'1': rise, '0': fall, 'z': off}.get(value, min(rise, fall, off))

    def settle(self, now):
        for wiring in self.connect():
            output, inputs = wiring[0], wiring[1:]
            values = [self.values[name] for name in inputs]
            value = truth(self.gate['kind'], values[0], values[1] if len(values) > 1 else None)
            history = self.events.setdefault(output, [])
            if history: assert history[-1][0] <= now, 'a pulse shorter than the delay has no rule here'
            current = history[-1][1] if history else None
            if value != current: history.append((now + self.delay_of(value), value))

    def read(self, name, now):
        if name in self.values: return self.values[name]
        assert name in self.nets, ('unknown bit', name)
        history = self.events.get(name)
        if history is None: return 'z'  # no driver reaches this bit
        assert history[0][0] <= now, 'the standard gives no output before the first delay'
        return [value for time, value in history if time <= now][-1]

    def show(self, expression, now):
        return ''.join(self.read(name, now) for name in reversed(self.bits(expression)))

    def assign(self, target, text):
        literal = re.fullmatch(r"(\d+)'b([01xz]+)", text)
        assert literal and int(literal[1]) == len(literal[2]), ('unsupported value', text)
        names = self.bits(target)
        assert len(names) == len(literal[2]) and all(name in self.values for name in names)
        for name, bit in zip(names, reversed(literal[2])): self.values[name] = bit

    def run(self):
        now, dirty, lines = Fraction(0), False, []
        for statement in (part.strip() for part in self.program.split(';') if part.strip()):
            delay = re.fullmatch(r'#(\d+(?:\.\d+)?)', statement)
            write = re.fullmatch(r'(\w+) = (.*)', statement)
            shown = re.fullmatch(r'\$display\("([^"]*)", (.*)\)', statement, re.S)
            if delay:
                if dirty: self.settle(now)
                dirty = False
                now += Fraction(delay[1])
            elif write:
                self.assign(write[1], write[2])
                dirty = True
            elif shown:
                arguments = iter(self.split_terminals(shown[2]))
                lines.append(re.sub('%b', lambda _: self.show(next(arguments), now), shown[1]))
            else:
                raise AssertionError(('unsupported statement', statement))
        return '\n'.join(lines) + '\n'


def interpret(source): return Design(source).run()


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index]) for name, index in
                (('and_zero', 0), ('bufif_three', 1), ('nmos_part', 2), ('not_two', 3), ('xnor_concat', 4),
                 ('and_part', 5))}
    faults = (
        ('reversed_concat', 'xnor_concat', [('({y3, y2, y1, y0},', '({y0, y1, y2, y3},')]),
        ('other_part', 'nmos_part', [('(y[6:3],', '(y[5:2],')]),
        ('wider_control', 'and_part', [('en[4:1]);\n', 'en[3:0]);\n')]),
        ('swapped_delays', 'not_two', [('#(1, 3)', '#(3, 1)')]),
        ('turn_off_delay', 'bufif_three', [('#(1, 3, 2)', '#(1, 3, 1)')]),
        ('other_gate', 'and_zero', [('  and g[', '  xnor g[')]),
        ('other_switch', 'nmos_part', [('  nmos #', '  bufif1 #')]),
        ('stale_value', 'and_zero', [("a_in = 4'b0011;", "a_in = 4'b0101;")]),
        ('late_read', 'not_two', [('#0.5;', '#1.5;')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_gatearray.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_gatearray.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent terminal mapping, truth tables and per-bit delays of actual gate arrays. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
