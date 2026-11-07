#!/usr/bin/env python3
"""Interpret actual time-scope programs independently.

Time scopes come from reading the declarations, directives and nesting in the
order of the text. Time is an exact count of femtoseconds, delays are rounded
from exact fractions, and output comes from the $display statements.
"""

from fractions import Fraction
from math import floor
from pathlib import Path
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_timescope as generator

UNITS = {'s': 10**15, 'ms': 10**12, 'us': 10**9, 'ns': 10**6, 'ps': 10**3, 'fs': 1}
SCALE = r'(?:1|10|100)(?:s|ms|us|ns|ps|fs)'


def scale(text):
    found = re.fullmatch(r'(1|10|100)(s|ms|us|ns|ps|fs)', text.strip())
    assert found, ('not a time scale', text)
    return int(found[1]) * UNITS[found[2]]


class Element:
    def __init__(self, kind, name):
        self.kind, self.name = kind, name
        self.unit = self.precision = None
        self.statics, self.children, self.instances = {}, {}, {}
        self.task = self.program = self.imported = None
        self.takes_delay = False


def read_elements(lines):
    state = {'directive': None, 'unit': None}
    elements = {}
    position = 0
    started = False

    def statements_until(end):
        nonlocal position
        taken = []
        while lines[position] != end:
            taken.append(lines[position])
            position += 1
        position += 1
        return ' '.join(taken)

    def read(kind, name, parent):
        nonlocal position
        element = Element(kind, name)
        declared = re.fullmatch(rf'timeunit ({SCALE}) / ({SCALE});', lines[position])
        single = re.fullmatch(rf'timeunit ({SCALE});', lines[position])
        if declared:
            element.unit, element.precision = scale(declared[1]), scale(declared[2])
            position += 1
        elif single:
            second = re.fullmatch(rf'timeprecision ({SCALE});', lines[position + 1])
            assert second, 'a timeunit without a precision is not in this grammar'
            element.unit, element.precision = scale(single[1]), scale(second[1])
            position += 2
        elif parent is not None:  # rule (a): nesting wins over the directive
            element.unit, element.precision = parent.unit, parent.precision
        elif state['directive']:  # rule (b)
            element.unit, element.precision = state['directive']
        else:  # rule (c)
            assert state['unit'], 'no time scope applies'
            element.unit, element.precision = state['unit']
        assert element.precision <= element.unit
        while lines[position] != 'end' + kind:
            line = lines[position]
            position += 1
            nested = re.fullmatch(r'(module|interface) (\w+);', line)
            if nested:
                assert kind != 'package'
                element.children[nested[2]] = read(nested[1], nested[2], element)
                continue
            variable = re.fullmatch(r'(int|real) (\w+) = 0;', line)
            task = re.fullmatch(r'task automatic work\(input int tag(, input real d)?\);', line)
            instance = re.fullmatch(r'(\w+) (\w+)\(\);', line)
            imported = re.fullmatch(r'import (\w+)::work;', line)
            if variable: element.statics[variable[2]] = Fraction(0)
            elif task:
                element.takes_delay = task[1] is not None
                element.task = statements_until('endtask')
            elif line == 'initial begin':
                assert element.program is None
                element.program = statements_until('end')
            elif instance: element.instances[instance[2]] = instance[1]
            elif imported: element.imported = imported[1]
            else: raise AssertionError(('unsupported item', line))
        position += 1
        return element

    while position < len(lines):
        line = lines[position]
        position += 1
        directive = re.fullmatch(rf'`timescale ({SCALE})/({SCALE})', line)
        unit_scope = re.fullmatch(rf'timeunit ({SCALE}) / ({SCALE});', line)
        element = re.fullmatch(r'(module|interface|package) (\w+);', line)
        if directive:
            state['directive'] = scale(directive[1]), scale(directive[2])
        elif unit_scope:
            assert not started and state['unit'] is None and state['directive'] is None
            state['unit'] = scale(unit_scope[1]), scale(unit_scope[2])
        elif element:
            started = True
            assert element[2] not in elements
            elements[element[2]] = read(element[1], element[2], None)
        else:
            raise AssertionError(('unsupported compilation-unit item', line))
    return elements


def split_list(text):
    parts, depth, current, quoted = [], 0, '', False
    for char in text:
        if char == '"': quoted = not quoted
        if char == ',' and not depth and not quoted:
            parts.append(current.strip())
            current = ''
        else:
            depth += (char == '(') - (char == ')')
            current += char
    return parts + [current.strip()] if current.strip() else parts


def interpret(source):
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    elements = read_elements([line.strip() for line in code.splitlines() if line.strip()])
    tops = [e for e in elements.values() if e.program is not None]
    assert len(tops) == 1
    top = tops[0]
    now = 0
    pending = None
    output = []
    time_format = None

    def rounded(value, element):
        ticks = value / element.precision + Fraction(1, 2)
        return floor(ticks) * element.precision

    def delay(text, element, frame):
        text = text.strip()
        literal = re.fullmatch(r'(\d+(?:\.\d+)?)(s|ms|us|ns|ps|fs)', text)
        if literal: return rounded(Fraction(literal[1]) * UNITS[literal[2]], element)
        if text in frame: return rounded(frame[text] * element.unit, element)
        if text in element.statics: return rounded(element.statics[text] * element.unit, element)
        assert re.fullmatch(r'\d+(\.\d+)?', text), ('unsupported delay', text)
        return rounded(Fraction(text) * element.unit, element)

    def read_time(name, element):
        exact = Fraction(now, element.unit)
        if name == '$realtime': return exact
        assert exact % 1 != Fraction(1, 2), 'the standard does not settle a tie here'
        whole = floor(exact + Fraction(1, 2))
        return whole % 2**32 if name == '$stime' else whole

    def show(statement, element, frame):
        parsed = re.fullmatch(r'\$display\("([^"]*)"\s*,\s*(.*)\)', statement, re.S)
        assert parsed, ('unsupported display', statement)
        arguments = iter(split_list(parsed[2]))

        def replace(match):
            text = next(arguments)
            if text in ('$time', '$stime', '$realtime'): value = read_time(text, element)
            elif text in frame: value = frame[text]
            else: value = int(text)
            if match[0] == '%0d':
                assert value == int(value)
                return str(int(value))
            if match[0] == '%.9f': return f'{float(value):.9f}'
            units, digits, suffix, width = time_format
            shown = Fraction(value) * element.unit / 10 ** (units + 15)
            body = f'{float(shown):.{digits}f}' + suffix
            return body.rjust(width)

        output.append(re.sub(r'%0d|%\.9f|%t', replace, parsed[1]) + '\n')
        assert next(arguments, None) is None

    def run(text, element, frame):
        nonlocal now, pending, time_format
        for statement in (s.strip() for s in text.split(';') if s.strip()):
            pause = re.fullmatch(r'#([\w.]+)', statement)
            nba = re.fullmatch(r'(\w+) <= #([\w.]+) (\w+)', statement)
            copy = re.fullmatch(r'(\w+) = (\w+)', statement)
            event = re.fullmatch(r'@\((\w+)\)', statement)
            call = re.fullmatch(r'([\w.]*)work\((.*)\)', statement)
            setup = re.fullmatch(r'\$timeformat\((-?\d+), (\d+), "(\w*)", (\d+)\)', statement)
            if pause: now += delay(pause[1], element, frame)
            elif nba:
                assert pending is None and nba[1] in element.statics
                pending = now + delay(nba[2], element, frame), nba[1], Fraction(frame[nba[3]])
            elif copy:
                assert copy[1] in element.statics
                element.statics[copy[1]] = frame[copy[2]]
            elif event:
                assert pending and pending[1] == event[1]
                assert pending[2] != element.statics[event[1]], 'no change would wake this wait'
                now, name, value = pending
                element.statics[name] = value
                pending = None
            elif call:
                owner = element
                if call[1]:
                    for name in call[1].rstrip('.').split('.'):
                        kind = owner.instances[name]
                        owner = owner.children.get(kind) or elements[kind]
                else:
                    owner = elements[element.imported]
                values = split_list(call[2])
                inner = {'tag': int(values[0])}
                assert owner.takes_delay == (len(values) == 2), 'wrong actual arguments'
                if len(values) == 2: inner['d'] = Fraction(values[1])
                run(owner.task, owner, inner)
            elif setup:
                time_format = int(setup[1]), int(setup[2]), setup[3], int(setup[4])
            elif statement == '$finish': return
            else: show(statement, element, frame)

    run(top.program, top, {})
    return ''.join(output)


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(row) for name, row in
                (('keyword', generator.MODEL.anchors[0]), ('slash_nba', generator.MODEL.anchors[1]),
                 ('directive_package', generator.MODEL.anchors[2]), ('unit_scope', generator.MODEL.anchors[3]),
                 ('nested', generator.MODEL.anchors[4]))}
    faults = (
        ('lost_keyword', 'keyword', [('  timeunit 10ns;\n  timeprecision 1ns;\n', '')]),
        ('coarser_precision', 'keyword', [('timeprecision 1ns;', 'timeprecision 10ns;')]),
        ('wrong_slash_precision', 'slash_nba', [('timeunit 100ps / 100fs;', 'timeunit 100ps / 1ps;')]),
        ('wrong_literal_suffix', 'slash_nba', [('#106250fs', '#106250ps')]),
        ('lost_last_directive', 'directive_package', [('`timescale 1us/1us\n', '')]),
        ('caller_unit', 'directive_package', [('timeunit 100ns / 1ns;', 'timeunit 1us / 1ns;')]),
        ('unit_scope_changed', 'unit_scope', [('timeunit 10ns / 10ps;', 'timeunit 100ns / 10ps;')]),
        ('lost_call', 'keyword', [('    u.work(2);\n', '')]),
        ('nested_decoy_wins', 'nested', [('  timeunit 100ps / 10ps;\n  module worker;',
                                          '  module worker;\n  timeunit 1ms / 1us;')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_timescope.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_timescope.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent time-scope resolution, delay rounding and read-back of actual SV. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
