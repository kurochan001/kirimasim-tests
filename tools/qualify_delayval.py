#!/usr/bin/env python3
"""Interpret actual delay value programs independently.

The time unit and precision come from the timeunit and timeprecision
declarations. Each delay is read from its text: an unsigned or real number in
time units, a time literal scaled by its own unit, or a parenthesized based or
signed number. A value with an x or z bit waits zero time, and a negative value
is taken as a 64-bit unsigned time (9.4.1). The delay is rounded to the
precision (3.14.1). Processes run under a scheduler with active, inactive and
NBA regions, in every start order, and must print the same text.
"""

from fractions import Fraction
from itertools import permutations
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_delayval as generator

UNITS = {'s': Fraction(1), 'ms': Fraction(1, 10**3), 'us': Fraction(1, 10**6), 'ns': Fraction(1, 10**9),
         'ps': Fraction(1, 10**12), 'fs': Fraction(1, 10**15)}
TIME_MAX = 2**64


def seconds(text):
    found = re.fullmatch(r'(\d+)(s|ms|us|ns|ps|fs)', text)
    assert found, ('unsupported time', text)
    return int(found[1]) * UNITS[found[2]]


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;\n(.*)endmodule\s*', code, re.S)
        assert found, 'one module'
        body = found[1]
        self.unit = seconds(re.search(r'^\s*timeunit (\w+);', body, re.M)[1])
        self.precision = seconds(re.search(r'^\s*timeprecision (\w+);', body, re.M)[1])
        assert self.precision <= self.unit
        self.tasks, self.processes, self.store = {}, [], {}
        for declared in re.finditer(r"^\s*logic \[7:0\] (\w+) = 8'd(\d+);", body, re.M):
            self.store[declared[1]] = int(declared[2])
        for task in re.finditer(r'^  task automatic (\w+);\n(.*?)\n  endtask', body, re.S | re.M):
            self.tasks[task[1]] = self.block(task[2])
        for one in re.finditer(r'^  initial (@\(\w+\) .*?;)$', body, re.M):
            self.processes.append(self.block(one[1]))
        for block in re.finditer(r'^  initial begin\n(.*?)\n  end$', body, re.S | re.M):
            self.processes.append(self.block(block[1]))
        rest = re.sub(r'^  (task automatic \w+;\n.*?\n  endtask|initial begin\n.*?\n  end|initial @.*?;)$', '', body,
                      flags=re.S | re.M)
        rest = re.sub(r"^\s*(timeunit \w+|timeprecision \w+|logic \[7:0\] \w+ = 8'd\d+);$", '', rest, flags=re.M)
        assert not rest.strip(), ('unsupported items', rest.strip())

    def block(self, text):
        statements, lines = [], [line.strip() for line in text.split('\n') if line.strip()]
        at = 0
        while at < len(lines):
            line = lines[at]
            if line == 'fork':
                end = lines.index('join_none', at)
                statements.append(('fork', [self.statement(inner) for inner in lines[at + 1:end]]))
                at = end + 1
                continue
            statements.append(self.statement(line))
            at += 1
        return statements

    def statement(self, text):
        if text == '$finish;': return ('finish',)
        repeat = re.fullmatch(r'repeat \((\d+)\) (.*)', text)
        if repeat: return ('repeat', int(repeat[1]), self.statement(repeat[2]))
        event = re.fullmatch(r'@\((\w+)\) (.*)', text)
        if event: return ('event', event[1], self.statement(event[2]))
        delay = re.fullmatch(r'#(\([^()]*\)|[\w.]+)(;| (.*))', text)
        if delay: return ('delay', self.delay(delay[1]), self.statement(delay[3]) if delay[3] else None)
        intra = re.fullmatch(r"(\w+) (=|<=) #(\([^()]*\)|[\w.]+) 8'd(\d+);", text)
        if intra: return ('intra', intra[2], intra[1], self.delay(intra[3]), int(intra[4]))
        show = re.fullmatch(r'\$display\("(.*?)", (.*)\);', text)
        if show: return ('display', show[1], [a.strip() for a in show[2].split(',')])
        call = re.fullmatch(r'(\w+);', text)
        if call and call[1] in self.tasks: return ('call', call[1])
        raise AssertionError(('unsupported statement', text))

    def delay(self, text):
        """The delay in ticks of the precision; None for a delay past any end."""
        inner = text[1:-1] if text.startswith('(') else text
        literal = re.fullmatch(r'(\d+)(s|ms|us|ns|ps|fs)', inner)
        if literal: value = seconds(inner) / self.unit
        elif re.fullmatch(r'\d+', inner): value = Fraction(int(inner))
        elif re.fullmatch(r'\d+\.\d+', inner): value = Fraction(inner)
        else:
            negative = re.fullmatch(r'-(\d+)', inner)
            based = re.fullmatch(r"(\d+)'([bdh])([0-9a-fA-FxXzZ_]+)", inner)
            if negative: value = Fraction(TIME_MAX - int(negative[1]))
            elif based:
                digits = based[3].replace('_', '').lower()
                if 'x' in digits or 'z' in digits: value = Fraction(0)
                else: value = Fraction(int(digits, {'b': 2, 'd': 10, 'h': 16}[based[2]]) % (1 << int(based[1])))
            else:
                raise AssertionError(('unsupported delay', text))
        ticks = value * self.unit / self.precision
        whole, part = divmod(ticks, 1)
        assert part != Fraction(1, 2), ('a rounding tie', text)
        return int(whole + (part > Fraction(1, 2)))

    def run(self, order):
        self.output, self.now, self.finished = [], 0, False
        self.values = dict(self.store)
        self.waiting = {}
        self.timed = {}
        self.active = [self.process(self.processes[i]) for i in order]
        self.inactive, self.nba = [], []
        while not self.finished:
            while (self.active or self.inactive or self.nba) and not self.finished:
                if self.active: self.step(self.active.pop(0))
                elif self.inactive: self.active, self.inactive = self.inactive, []
                else:
                    updates, self.nba = self.nba, []
                    for name, value in updates: self.write(name, value)
            if self.finished or not self.timed: break
            self.now = min(self.timed)
            if self.now >= TIME_MAX: break
            self.active = self.timed.pop(self.now)
        return ''.join(line + '\n' for line in self.output)

    def step(self, process):
        try: request = next(process)
        except StopIteration: return
        if request[0] == 'finish': self.finished = True
        elif request[0] == 'delay':
            if request[1] == 0: self.inactive.append(process)
            else: self.timed.setdefault(self.now + request[1], []).append(process)
        elif request[0] == 'event': self.waiting.setdefault(request[1], []).append(process)

    def write(self, name, value):
        if self.values[name] != value:
            self.values[name] = value
            self.active += self.waiting.pop(name, [])

    def process(self, statements):
        for item in statements: yield from self.execute(item)

    def execute(self, item):
        kind = item[0]
        if kind == 'delay':
            yield ('delay', item[1])
            if item[2]: yield from self.execute(item[2])
        elif kind == 'repeat':
            for _ in range(item[1]): yield from self.execute(item[2])
        elif kind == 'event':
            yield ('event', item[1])
            yield from self.execute(item[2])
        elif kind == 'intra':
            _, how, name, delay, value = item
            if how == '=':
                yield ('delay', delay)
                self.write(name, value)
            else:
                self.schedule_nba(name, value, delay)
        elif kind == 'fork':
            for inner in item[1]: self.active.append(self.process([inner]))
        elif kind == 'call':
            yield from self.process(self.tasks[item[1]])
        elif kind == 'display':
            self.output.append(self.format(item[1], item[2]))
        elif kind == 'finish':
            yield ('finish',)
        else:
            raise AssertionError(('unknown statement', kind))

    def schedule_nba(self, name, value, delay):
        if delay == 0:
            self.nba.append((name, value))
            return

        def later():
            yield ('delay', delay)
            self.nba.append((name, value))
        self.timed.setdefault(self.now + delay, []).append(self.resume(later()))

    def resume(self, generator):
        next(generator)
        return generator

    def format(self, text, arguments):
        values = []
        for argument in arguments:
            if argument == '$realtime': values.append(('real', Fraction(self.now) * self.precision / self.unit))
            else: values.append(('int', self.values[argument]))
        specifiers = re.findall(r'%0\.1f|%0d', text)
        assert len(specifiers) == len(values), 'arguments'
        out = text
        for spec, (kind, value) in zip(specifiers, values):
            if spec == '%0.1f':
                assert kind == 'real'
                tenths = value * 10
                whole, part = divmod(tenths, 1)
                shown = whole + (part >= Fraction(1, 2))
                text_value = f'{shown // 10}.{shown % 10}'
            else:
                assert kind == 'int'
                text_value = str(value)
            out = out.replace(spec, text_value, 1)
        return out


def interpret(source):
    count = len(Program(source).processes)
    results = {Program(source).run(order) for order in permutations(range(count))}
    assert len(results) == 1, ('depends on the order of processes', results)
    return results.pop()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'x_nba': anchor(('x', 'nba', 'later', 'tenth')),
                'neg_repeat': anchor(('neg', 'repeat', 'zero', 'unit')),
                'real_repeat': anchor(('real_down', 'repeat', 'later', 'unit')),
                'fine_task': anchor(('time_fine', 'task', 'zero', 'unit')),
                'xpart_fork': anchor(('xpart', 'fork', 'later', 'unit')),
                'z_blocking': anchor(('z', 'blocking', 'zero', 'tenth')),
                'sized_stmt': anchor(('sized', 'stmt', 'later', 'tenth'))}
    faults = (
        ('known_delay', 'x_nba', [("#(1'bx) 8'd7", "#(1'b1) 8'd7")]),
        ('positive_delay', 'neg_repeat', [('#(-1)', '#(1)')]),
        ('finer_precision', 'real_repeat', [('timeprecision 1ns;', 'timeprecision 100ps;')]),
        ('coarser_literal', 'fine_task', [('#2700ps', '#2700ns')]),
        ('known_bits', 'xpart_fork', [("#(4'b00x1)", "#(4'b0011)")]),
        ('later_start', 'z_blocking', [('  initial begin\n    a =', '  initial begin\n    #4;\n    a =')]),
        ('other_size', 'sized_stmt', [("#(3'b101)", "#(2'b101)")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_delayval.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_delayval.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent delay values, rounding and region scheduling of actual programs in every start order. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
