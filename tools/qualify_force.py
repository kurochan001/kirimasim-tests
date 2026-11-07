#!/usr/bin/env python3
"""Interpret actual force and release programs independently.

Declarations become named bits with their own state: a stored value, continuous
drivers, an assign procedural continuous assignment and a force. A read works out
the value of a bit from that state, by the order of 10.6.2. Blocking writes happen
in place, nonblocking writes at the end of the time step, and observers report by
21.2.2 and 21.2.3. A read in the time step of a release of a variable with a
driver, whose new value is only scheduled, is an error.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_force as generator


def split_top(text):
    parts, depth, current = [], 0, ''
    for char in text:
        if char == ',' and not depth:
            parts.append(current.strip())
            current = ''
        else:
            depth += (char in '({[') - (char in ')}]')
            current += char
    return parts + [current.strip()]


class Design:
    def __init__(self, source):
        code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
        self.width, self.nets, self.wor = {}, set(), set()
        self.value, self.force, self.procedural = {}, {}, {}
        self.drivers = {}
        self.changing = set()
        self.tasks = {}
        self.monitor = self.watch = None
        modules = re.findall(r'\bmodule (\w+)\s*;(.*?)\bendmodule\b', code, re.S)
        assert modules, 'no module'
        self.prefix = ''
        for name, body in modules[:-1]:
            assert name == 'force_inner', ('unknown module', name)
        body = modules[-1][1]
        if len(modules) == 2:
            assert 'force_inner u ();' in body, 'the inner module has no instance'
            self.prefix = 'u.'
            body = body.replace('force_inner u ();', '')
            self.declare_all(modules[0][1])
        found = re.fullmatch(r'(.*)initial begin(.*)\$finish;\s*end\s*', body, re.S)
        assert found, 'unsupported program'
        self.declare_all(found[1])
        self.program = [part.strip() for part in found[2].split(';') if part.strip()]

    def declare_all(self, text):
        for task in re.finditer(r'task automatic (\w+)\(\);\s*(.*?);\s*endtask', text, re.S):
            self.tasks[task[1]] = task[2].strip()
        text = re.sub(r'task automatic .*?endtask', '', text, flags=re.S)
        event = re.search(r'always @\((.*?)\) if \(\$time > 0\) \$display\("%0d %b", \$time, (.*?)\);', text)
        if event:
            assert event[1] == event[2], 'an event and a report of different things'
            self.watch = dict(expression=event[1], last=None)
            text = text[:event.start()] + text[event.end():]
        for item in (part.strip() for part in text.split(';') if part.strip()):
            declared = re.fullmatch(r'(logic|wire|wor) \[(\d+):0\] ([\w, ]+)', item)
            driver = re.fullmatch(r'assign (.*?) = (\w+)', item)
            if declared:
                for name in declared[3].split(','):
                    name = self.prefix + name.strip()
                    self.width[name] = int(declared[2]) + 1
                    for bit in range(self.width[name]):
                        if declared[1] == 'logic': self.value[name, bit] = 'x'
                        else: self.nets.add((name, bit))
                        if declared[1] == 'wor': self.wor.add((name, bit))
            elif driver:
                bits = self.bits(self.local(driver[1]))
                for index, name_bit in enumerate(bits):
                    self.drivers.setdefault(name_bit, []).append((self.prefix + driver[2], index))
            else:
                raise AssertionError(('unsupported item', item))

    def local(self, text):
        """Add the instance prefix to the names of an inner declaration."""
        return re.sub(r'\b(\w+)\b', lambda match: self.prefix + match[1], text) if self.prefix else text

    def bits(self, expression):
        """Named bits, least significant first."""
        expression = expression.strip()
        if expression.startswith('{'):
            names = []
            for part in reversed(split_top(expression[1:-1])): names += self.bits(part)
            return names
        part = re.fullmatch(r'([\w.]+)\[(\d+):(\d+)\]', expression)
        if part:
            name, high, low = part[1], int(part[2]), int(part[3])
            assert all((name, bit) in self.nets for bit in range(low, high + 1)), \
                'a select of a variable cannot be forced'
            return [(name, bit) for bit in range(low, high + 1)]
        assert expression in self.width, ('unknown name', expression)
        return [(expression, bit) for bit in range(self.width[expression])]

    def read_bit(self, name_bit):
        if name_bit in self.changing:
            raise AssertionError('this read races with the reevaluation that a release schedules')
        if name_bit in self.force: return self.right_bit(*self.force[name_bit])
        if name_bit in self.procedural: return self.right_bit(*self.procedural[name_bit])
        if name_bit in self.drivers:
            values = [self.value[name, bit] for name, bit in self.drivers[name_bit]]
            if name_bit in self.wor:
                if '1' in values: return '1'
                return 'x' if 'x' in values else '0'
            assert len(values) == 1, 'several drivers on a plain net'
            return values[0]
        if name_bit in self.nets: return 'z'
        return self.value[name_bit]

    def right_bit(self, right, index):
        literal = re.fullmatch(r"(\d+)'b([01xz]+)", right)
        if literal: return literal[2][int(literal[1]) - 1 - index]
        return self.read_bit((right, index))

    def show(self, expression):
        return ''.join(self.read_bit(item) for item in reversed(self.bits(expression)))

    def write(self, left, right):
        bits = self.bits(left)
        literal = re.fullmatch(r"(\d+)'b([01xz]+)", right)
        assert literal and len(literal[2]) == len(bits), ('unsupported value', right)
        for item, bit in zip(bits, reversed(literal[2])):
            assert item not in self.nets, 'a procedural write to a net'
            if item not in self.force and item not in self.procedural:
                assert item not in self.drivers, 'a mixture of continuous and procedural assignments'
                self.value[item] = bit

    def execute(self, statement):
        if statement.endswith('_force') or statement.endswith('_release'):
            statement = self.tasks[statement]
        force = re.fullmatch(r'force (.*?) = (.*)', statement, re.S)
        procedural = re.fullmatch(r'assign (.*?) = (.*)', statement)
        release = re.fullmatch(r'release (.*)', statement)
        deassign = re.fullmatch(r'deassign (.*)', statement)
        late = re.fullmatch(r'(.*?) <= (.*)', statement)
        blocking = re.fullmatch(r'(.*?) = (.*)', statement)
        if force:
            for index, item in enumerate(self.bits(force[1])): self.force[item] = (force[2], index)
        elif procedural:
            for index, item in enumerate(self.bits(procedural[1])): self.procedural[item] = (procedural[2], index)
        elif release:
            for item in self.bits(release[1]):
                current = self.read_bit(item)
                self.force.pop(item, None)
                # A plain variable keeps the value; one with a driver takes it back later.
                if item in self.value and item not in self.drivers and item not in self.procedural:
                    self.value[item] = current
                elif item not in self.nets: self.changing.add(item)
        elif deassign:
            for item in self.bits(deassign[1]):
                self.value[item] = self.read_bit(item)
                del self.procedural[item]
        elif late: self.pending.append((late[1], late[2]))
        elif blocking: self.write(blocking[1], blocking[2])
        else: return False
        return True

    def report(self, line_format, arguments):
        values = iter(arguments)
        return re.sub(r'%0d|%b', lambda _: str(next(values)), line_format)

    def calls(self, text):
        call = re.fullmatch(r'\$(display|strobe|monitor)\("([^"]*)", (.*)\)', text, re.S)
        return (call[1], call[2], split_top(call[3])) if call else None

    def argument(self, text):
        if text == '$time': return self.now
        query = re.fullmatch(r'\$(countones|isunknown|bits)\((.*)\)', text)
        if query:
            value = self.show(query[2])
            return {'countones': value.count('1'), 'isunknown': int('x' in value or 'z' in value),
                    'bits': len(value)}[query[1]]
        return self.show(text)

    def finish_step(self):
        for left, right in self.pending: self.write(left, right)
        self.pending = []
        self.changing = set()
        if self.watch:
            value = self.show(self.watch['expression'])
            if value != self.watch['last'] and self.now > 0:
                self.lines.append(f'{self.now} {value}')
            self.watch['last'] = value
        for line_format, arguments in self.strobes:
            self.lines.append(self.report(line_format, [self.argument(item) for item in arguments]))
        self.strobes = []
        if self.monitor:
            values = [self.argument(item) for item in self.monitor['arguments'] if item != '$time']
            if values != self.monitor['last']:
                if self.monitor['last'] is None:
                    assert any('x' not in str(v) for v in values), 'the first display would not be a change'
                self.lines.append(self.report(self.monitor['format'],
                                              [self.argument(item) for item in self.monitor['arguments']]))
            self.monitor['last'] = values

    def run(self):
        self.now, self.lines, self.pending, self.strobes = 0, [], [], []
        for statement in self.program:
            call = self.calls(statement)
            if statement == '#1':
                self.finish_step()
                self.now += 1
            elif call and call[0] == 'display':
                self.lines.append(self.report(call[1], [self.argument(item) for item in call[2]]))
            elif call and call[0] == 'strobe': self.strobes.append((call[1], call[2]))
            elif call:
                assert self.monitor is None, 'one monitor only'
                self.monitor = dict(format=call[1], arguments=call[2], last=None)
            elif not self.execute(statement):
                raise AssertionError(('unsupported statement', statement))
        self.finish_step()
        return '\n'.join(self.lines) + '\n'


def interpret(source): return Design(source).run()


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index]) for name, index in
                (('var_driver', 0), ('net_source', 1), ('cont_task', 2), ('pca_strobe', 3), ('part_event', 4),
                 ('wor_query', 5), ('vcat_hier', 6), ('ncat_monitor', 7))}
    faults = (
        ('write_after_release', 'var_driver', [('release t;\n    $display("%0d r %b", $time, t);\n    #1;',
                                                "release t;\n    t = 4'b0011;\n    #1;\n    #1;\n    #1;")]),
        ('released_early', 'net_source', [("force t = src;\n", "force t = src;\n    release t;\n")]),
        ('constant_force', 'net_source', [('force t = src;', "force t = 4'b1001;")]),
        ('other_driver_value', 'cont_task', [("d = 4'b1100;", "d = 4'b1101;")]),
        ('no_release', 'pca_strobe', [('    release t;\n', '')]),
        ('deassign_removed', 'pca_strobe', [('    deassign t;\n', '')]),
        ('other_part', 'part_event', [('force u.t[5:2]', 'force u.t[4:1]')]),
        ('and_net', 'wor_query', [("e = 4'b0010;", "e = 4'b0100;")]),
        ('swapped_concat', 'vcat_hier', [('force {u.t1, u.t0}', 'force {u.t0, u.t1}')]),
        ('forced_known', 'ncat_monitor', [("4'b1x0z", "4'b1100")]),
    )

    def checked(source):
        try: return interpret(source)
        except (AssertionError, KeyError, ValueError) as error: return f'rejected: {error}'
    return controls, apply_faults(controls, faults, checked)


FILES = ('generators/interaction_force.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_force.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent bit state for force, release and procedural continuous assignments of actual programs. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
