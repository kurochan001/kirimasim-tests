#!/usr/bin/env python3
"""Interpret actual implicit sensitivity programs independently.

Declarations become storage, and the right-hand side is read to find what it
depends on: the longest static prefix for always_comb and always_latch, also inside
a called function, and only the identifiers of the statement for always @* and a
continuous assignment. A write wakes what overlaps its bits, and only if the bits
change. The expression then runs on the current storage.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_sense as generator

MASK = 0xff


def number(text):
    found = re.fullmatch(r"(?:(\d+)'([bdh]))?(\w+)", text)
    assert found, ('unsupported number', text)
    return int(found[3], {'b': 2, 'h': 16}.get(found[2], 10))


class Design:
    def __init__(self, source):
        code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;(.*?)initial begin(.*?)\$finish;\s*end\s*endmodule\s*', code, re.S)
        assert found, 'unsupported program'
        self.store, self.fields, self.tasks, self.functions = {}, {}, {}, {}
        self.process = self.right = None
        self.condition = None
        self.declare(found[1])
        assert self.process, 'no process'
        self.program = [part.strip() for part in found[2].split(';') if part.strip()]

    def declare(self, text):
        for function in re.finditer(r'function automatic logic \[7:0\] (\w+)\((.*?)\);\s*return (\w+);\s*endfunction',
                                    text, re.S):
            self.functions[function[1]] = (function[2].split()[-1] if function[2] else None, function[3])
        text = re.sub(r'function automatic .*?endfunction', '', text, flags=re.S)
        for task in re.finditer(r'task automatic (\w+)\(\);\s*(.*?);\s*endtask', text, re.S):
            self.tasks[task[1]] = task[2].strip()
        text = re.sub(r'task automatic .*?endtask', '', text, flags=re.S)
        forms = (('comb', r'always_comb begin o = (.*?); if \(\$time > 0\) \$display\("%0d eval", \$time\); end'),
                 ('latch', r'always_latch begin if \(en\) o = (.*?); if \(\$time > 0\) \$display\("%0d eval", \$time\); end'),
                 ('star', r'always @\* begin o = (.*?); end'),
                 ('assign', r'assign o = (.*?);'),
                 ('netdecl', r'wire \[7:0\] o = (.*?);'))
        flat = re.sub(r'\s+', ' ', text)
        for kind, pattern in forms:
            match = re.search(pattern, flat)
            if match:
                assert self.process is None, 'two processes'
                self.process, self.right = kind, match[1]
                flat = flat[:match.start()] + flat[match.end():]
        structure = re.search(r'typedef struct( packed)? \{ logic \[7:0\] (\w+); logic \[7:0\] (\w+); \} st_t;', flat)
        if structure:
            self.fields = dict(packed=bool(structure[1]), order=(structure[2], structure[3]))
            flat = flat[:structure.start()] + flat[structure.end():]
        for item in (part.strip() for part in flat.split(';') if part.strip()):
            array = re.fullmatch(r"logic \[7:0\] (\w+)\[3\] = '\{(.*)\}", item)
            vector = re.fullmatch(r'(?:logic(?: \[\d+:0\])?|int) (\w+)(?: = (.*))?', item)
            pattern = re.fullmatch(r"st_t (\w+) = '\{(\w+): (\S+), (\w+): (\S+)\}", item)
            packed = re.fullmatch(r"st_t (\w+) = 16'h([0-9a-f]{4})", item)
            if array:
                self.store[array[1]] = [number(value.strip()) for value in array[2].split(',')]
            elif pattern:
                self.store[pattern[1]] = {pattern[2]: number(pattern[3]), pattern[4]: number(pattern[5])}
            elif packed:
                word = int(packed[2], 16)
                high, low = self.fields['order']
                self.store[packed[1]] = {high: word >> 8, low: word & MASK}
            elif vector:
                if vector[1] != 'o': self.store[vector[1]] = number(vector[2])
            else:
                raise AssertionError(('unsupported item', item))

    # What the right-hand side depends on, as (name, selector); None selects it all.

    def term(self, text):
        return re.findall(r"\w+\(\w*\)|\w+\[\w+:\w+\]|\w+\[\w+\]|\w+\.\w+|(?<![\w'])[a-z_]\w*", text)

    def static_prefixes(self, text):
        reads = []
        for item in self.term(text):
            call = re.fullmatch(r'(\w+)\((\w*)\)', item)
            element = re.fullmatch(r'(\w+)\[(\w+)\]', item)
            bits = re.fullmatch(r'(\w+)\[(\d+):(\d+)\]', item)
            field = re.fullmatch(r'(\w+)\.(\w+)', item)
            if call:
                parameter, result = self.functions[call[1]]
                if call[2]: reads.append((call[2], None))
                if result != parameter: reads.append((result, None))
            elif element and element[2].isdigit(): reads.append((element[1], int(element[2])))
            elif element: reads += [(element[1], None), (element[2], None)]
            elif bits: reads.append((bits[1], (int(bits[2]), int(bits[3]))))
            elif field: reads.append((field[1], field[2]))
            else: reads.append((item, None))
        return reads

    def identifiers(self, text):
        reads = []
        for item in self.term(text):
            call = re.fullmatch(r'(\w+)\((\w*)\)', item)
            if call:
                if call[2]: reads.append((call[2], None))
            else:
                reads += [(name, None) for name in re.findall(r'[a-z_]\w*', item) if name in self.store]
        return reads

    def dependencies(self):
        if self.process in ('comb', 'latch'):
            reads = self.static_prefixes(self.right)
            return reads + ([('en', None)] if self.process == 'latch' else [])
        return self.identifiers(self.right)

    @staticmethod
    def overlap(selected, written):
        if selected is None or written is None: return True
        if isinstance(selected, tuple) and isinstance(written, tuple):
            return selected[1] <= written[0] and written[1] <= selected[0]
        return selected == written

    # The value of the right-hand side now.

    def value(self, text):
        text = text.strip()
        addition = re.fullmatch(r'(.*) \+ (\w+)', text)
        if addition: return (self.value(addition[1]) + self.value(addition[2])) & MASK
        condition = re.fullmatch(r'\((\w+) \? (\w+) : (\w+)\)', text)
        if condition: return self.value(condition[2]) if self.value(condition[1]) else self.value(condition[3])
        joined = re.fullmatch(r'\{(\w+\[3:0\]), (\w+\[3:0\])\}', text)
        if joined: return self.value(joined[1]) << 4 | self.value(joined[2])
        call = re.fullmatch(r'(\w+)\((\w*)\)', text)
        if call:
            parameter, result = self.functions[call[1]]
            return self.value(call[2] if result == parameter else result)
        element = re.fullmatch(r'(\w+)\[(\w+)\]', text)
        if element: return self.store[element[1]][int(element[2]) if element[2].isdigit() else self.store[element[2]]]
        bits = re.fullmatch(r'(\w+)\[(\d+):(\d+)\]', text)
        if bits:
            high, low = int(bits[2]), int(bits[3])
            return self.store[bits[1]] >> low & (1 << (high - low + 1)) - 1
        field = re.fullmatch(r'(\w+)\.(\w+)', text)
        if field: return self.store[field[1]][field[2]]
        return self.store[text]

    def write(self, left, right):
        """Store the value; the name and selector if the bits changed, else None."""
        new = number(right)
        element = re.fullmatch(r'(\w+)\[(\d+)\]', left)
        bits = re.fullmatch(r'(\w+)\[(\d+):(\d+)\]', left)
        field = re.fullmatch(r'(\w+)\.(\w+)', left)
        if element:
            old, selected = self.store[element[1]][int(element[2])], int(element[2])
            self.store[element[1]][selected] = new
            name = element[1]
        elif bits:
            high, low = int(bits[2]), int(bits[3])
            mask = (1 << (high - low + 1)) - 1
            old = self.store[bits[1]] >> low & mask
            self.store[bits[1]] = self.store[bits[1]] & ~(mask << low) | new << low
            name, selected = bits[1], (high, low)
        elif field:
            old, name, selected = self.store[field[1]][field[2]], field[1], field[2]
            self.store[name][selected] = new
        else:
            assert left in self.store, ('unknown name', left)
            old, name, selected = self.store[left], left, None
            self.store[left] = new
        return None if old == new else (name, selected)

    def run(self):
        reads = self.dependencies()
        now, lines, pending, changes = 0, [], [], []
        output = None if self.process == 'star' else self.value(self.right)

        def settle():
            nonlocal output
            nonlocal changes
            for left, right in pending:
                changes.append(self.write(left, right))
            pending.clear()
            woken = any(change and any(change[0] == name and self.overlap(selected, change[1])
                                       for name, selected in reads) for change in changes)
            changes = []
            if woken:
                output = self.value(self.right)
                if self.process in ('comb', 'latch') and now > 0: lines.append(f'{now} eval')
        for statement in self.program:
            if statement in (f'{key}()' for key in self.tasks): statement = self.tasks[statement[:-2]]
            late = re.fullmatch(r'(.*?) <= (.*)', statement)
            blocking = re.fullmatch(r'(.*?) = (.*)', statement)
            if statement == '#1':
                settle()
                now += 1
            elif statement == '$display("%0d o=%h", $time, o)':
                lines.append(f'{now} o={"xx" if output is None else format(output, "02x")}')
            elif late: pending.append((late[1], late[2]))
            elif blocking: changes.append(self.write(blocking[1], blocking[2]))
            else: raise AssertionError(('unsupported statement', statement))
        return '\n'.join(lines) + '\n'


def interpret(source): return Design(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'comb_element': anchor(('comb', 'element', 'unread', 'blocking')),
                'comb_index': anchor(('comb', 'index', 'unread', 'blocking')),
                'comb_member': anchor(('comb', 'member', 'unread', 'blocking')),
                'comb_global': anchor(('comb', 'fnglobal', 'unread', 'blocking')),
                'latch_global': anchor(('latch', 'fnglobal', 'read', 'nba')),
                'star_global': anchor(('star', 'fnglobal', 'read', 'blocking')),
                'assign_global': anchor(('assign', 'fnglobal', 'read', 'task')),
                'netdecl_cond': anchor(('netdecl', 'cond', 'index', 'blocking')),
                'comb_same': anchor(('comb', 'part', 'same', 'nba'))}
    faults = (
        ('read_element_written', 'comb_element', [('arr[2] = 8', 'arr[1] = 8')]),
        ('constant_index', 'comb_index', [('o = arr[i] + b', 'o = arr[1] + b')]),
        ('other_member_read', 'comb_member', [('o = s.f + b', 'o = s.g + b')]),
        ('other_write', 'comb_global', [("    u = 8'd77;", "    a = 8'd77;")]),
        ('argument_read', 'star_global', [('fg() + b', 'fa(a) + b'),
                                          ('function automatic logic [7:0] fg();\n    return a;',
                                           'function automatic logic [7:0] fa(logic [7:0] p);\n    return p;')]),
        ('other_function_result', 'latch_global', [('return a;', 'return u;')]),
        ('other_value', 'assign_global', [("a = 8'd40", "a = 8'd41")]),
        ('other_select', 'netdecl_cond', [("sel = 1'b0", "sel = 1'b1")]),
        ('new_value', 'comb_same', [("v[7:0] <= 8'd2", "v[7:0] <= 8'd3")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_sense.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_sense.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent sensitivity and storage of actual programs, from the text of each right-hand side. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
