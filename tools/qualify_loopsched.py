#!/usr/bin/env python3
"""Interpret actual loop scheduling programs independently.

Each initial block becomes a process of parsed statements, run by a small
scheduler with the active, inactive, NBA and postponed regions of a time slot.
$strobe formats at the end of its slot, $monitor reports there when a value
it shows changed, and a nonblocking assignment updates in the NBA region.
Processes that are ready together run in every order, and each order must
print the same text, so the result does not depend on the order.
"""

from itertools import permutations
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_loopsched as generator


def tokens(text):
    found = re.findall(r"\d+'[dhb][0-9a-f_]+|\d+|\w+|<=|>=|[-+<>()]", text)
    assert ''.join(found) == text.replace(' ', ''), ('unsupported expression', text)
    return found


def value(text, store):
    """Evaluate a + b, a - b, a < b and a >= b on whole numbers."""
    items = tokens(text)

    def operand(item):
        sized = re.fullmatch(r"(\d+)'([dhb])([0-9a-f_]+)", item)
        if sized: return int(sized[3].replace('_', ''), {'d': 10, 'h': 16, 'b': 2}[sized[2]])
        if item.isdigit(): return int(item)
        return store[item]
    if len(items) == 1: return operand(items[0])
    assert len(items) == 3, ('unsupported expression', text)
    left, op, right = operand(items[0]), items[1], operand(items[2])
    return {'+': left + right, '-': left - right, '<': int(left < right), '>=': int(left >= right)}[op]


def parse(text):
    """Statements of a block as tuples."""
    text = text.strip()
    out = []
    while text:
        loop = re.match(r'(repeat|while) \((.*?)\) begin(.*?)\nend\b', text, re.S) or \
            re.match(r'(for) \((.*?)\) begin(.*?)\nend\b', text, re.S)
        do = re.match(r'do begin(.*?)\nend while \((.*?)\);', text, re.S)
        forever = re.match(r'forever begin\s*if \((.*?)\) break;(.*?)\nend\b', text, re.S)
        if do:
            out.append(('do', parse(dedent(do[1])), do[2]))
            text = text[do.end():].strip()
        elif forever:
            out.append(('forever', forever[1], parse(dedent(forever[2]))))
            text = text[forever.end():].strip()
        elif loop:
            out.append((loop[1], loop[2], parse(dedent(loop[3]))))
            text = text[loop.end():].strip()
        else:
            statement, _, text = text.partition(';')
            out.append(simple(statement.strip()))
            text = text.strip()
    return out


def dedent(text): return '\n'.join(line[2:] if line.startswith('  ') else line for line in text.split('\n'))


def simple(statement):
    delay = re.fullmatch(r'#(\d+)', statement)
    if delay: return ('delay', int(delay[1]))
    task = re.fullmatch(r'\$(display|strobe|monitor)\("(.*?)", \$time, (\w+), (\w+)\)', statement)
    if task: return (task[1], task[2], task[3], task[4])
    late = re.fullmatch(r'(\w+) <= (.*)', statement)
    if late: return ('nba', late[1], late[2])
    now = re.fullmatch(r'(\w+) = (.*)', statement)
    if now: return ('set', now[1], now[2])
    if statement == '$finish': return ('finish',)
    raise AssertionError(('unsupported statement', statement))


class Simulation:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;(.*)endmodule\s*', code, re.S)
        assert found, 'unsupported program'
        body = found[1]
        self.store, self.blocks = {}, []
        for initial in re.finditer(r'initial begin\n(.*?)\n  end\n|initial #(\d+) \$finish;', body, re.S):
            if initial[2]: self.blocks.append([('delay', int(initial[2])), ('finish',)])
            else: self.blocks.append(parse(dedent(dedent(initial[1]))))
        rest = re.sub(r'initial begin\n.*?\n  end\n|initial #\d+ \$finish;', '', body, flags=re.S)
        for item in (part.strip() for part in rest.split(';') if part.strip()):
            declared = re.fullmatch(r"(?:logic \[7:0\]|int) (\w+) = (.*)", item)
            assert declared, ('unsupported item', item)
            self.store[declared[1]] = value(declared[2], {})
        self.widths = {name: 8 for name in re.findall(r'logic \[7:0\] (\w+)', rest)}

    def write(self, name, number):
        self.store[name] = number % 256 if name in self.widths else number

    def process(self, statements):
        """A generator that yields ('delay', n) to suspend."""
        for statement in statements:
            yield from self.execute(statement)

    def execute(self, statement):
        kind = statement[0]
        if kind == 'delay': yield statement
        elif kind == 'set': self.write(statement[1], value(statement[2], self.store))
        elif kind == 'nba': self.nba.append((statement[1], value(statement[2], self.store)))
        elif kind == 'display': self.output.append(self.line(statement))
        elif kind == 'strobe': self.strobes.append(statement)
        elif kind == 'monitor': self.monitor, self.shown = statement, None
        elif kind == 'finish': yield ('finish',)
        elif kind == 'repeat':
            for _ in range(value(statement[1], self.store)): yield from self.process(statement[2])
        elif kind == 'while':
            while value(statement[1], self.store): yield from self.process(statement[2])
        elif kind == 'for':
            start, condition, step = (part.strip() for part in statement[1].split(';'))
            yield from self.execute(simple(start))
            while value(condition, self.store):
                yield from self.process(statement[2])
                yield from self.execute(simple(step))
        elif kind == 'do':
            yield from self.process(statement[1])
            while value(statement[2], self.store): yield from self.process(statement[1])
        elif kind == 'forever':
            while not value(statement[1], self.store): yield from self.process(statement[2])
        else:
            raise AssertionError(('unknown statement', kind))

    def line(self, statement):
        _, text, a, b = statement
        return re.sub('%0d', '{}', text, count=3).format(self.now, self.store[a], self.store[b])

    def run(self, order):
        self.output, self.nba, self.strobes, self.monitor, self.shown, self.now = [], [], [], None, None, 0
        waiting = {0: [self.process(self.blocks[i]) for i in order]}
        while waiting:
            self.now = min(waiting)
            active, inactive = waiting.pop(self.now), []
            finished = False
            while active or inactive or self.nba:
                if not active and inactive: active, inactive = inactive, []
                if not active:
                    for name, number in self.nba: self.write(name, number)
                    self.nba = []
                    continue
                current = active.pop(0)
                suspended = next(current, None)
                if suspended is None: continue
                if suspended[0] == 'finish':
                    finished = True
                    break
                if suspended[1] == 0: inactive.append(current)
                else: waiting.setdefault(self.now + suspended[1], []).append(current)
            for statement in self.strobes: self.output.append(self.line(statement))
            self.strobes = []
            if self.monitor and not finished:
                state = (self.store[self.monitor[2]], self.store[self.monitor[3]])
                if state != self.shown: self.output.append(self.line(self.monitor))
                self.shown = state
            if finished: break
        return '\n'.join(self.output) + '\n'


def interpret(source):
    simulation = Simulation(source)
    results = set()
    for order in permutations(range(len(simulation.blocks))):
        simulation = Simulation(source)
        results.add(simulation.run(order))
    assert len(results) == 1, ('depends on the order of processes', results)
    return results.pop()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'repeat_delay': anchor(('repeat', 'delay', 'nba', 'display')),
                'while_delay': anchor(('while', 'delay', 'nba', 'display')),
                'do_zero_strobe': anchor(('do', 'zero', 'nba', 'strobe')),
                'forever_monitor': anchor(('forever', 'none', 'zero', 'monitor')),
                'for_later_monitor': anchor(('for', 'delay', 'later', 'monitor')),
                'repeat_self_strobe': anchor(('repeat', 'none', 'self', 'strobe'))}
    faults = (
        ('change_before_loop', 'repeat_delay', [("    #1;\n    n <= 8'd5;", "    n <= 8'd5;")]),
        ('shorter_period', 'while_delay', [('#2;', '#1;')]),
        ('display_in_loop', 'do_zero_strobe', [('$strobe(', '$display(')]),
        ('next_slot_change', 'forever_monitor', [("    #0;\n    n = 8'd5;", "    #1;\n    n = 8'd5;")]),
        ('later_than_loop', 'for_later_monitor', [("#2;\n    n = 8'd5;", "#20;\n    n = 8'd5;")]),
        ('while_self', 'repeat_self_strobe', [('repeat (n) begin', 'while (count < n) begin')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_loopsched.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_loopsched.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent region scheduling of actual programs in every order of the processes. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
