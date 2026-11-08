#!/usr/bin/env python3
"""Interpret actual escaped identifier programs independently.

The text is split into tokens by the rules of 5.6: an escaped identifier runs
from the backslash to the next white space (space, tab or newline), and its
name leaves out both, so \\abc and abc are the same name. An escaped keyword is
an ordinary name. The child module, its parameter, ports, variables, task and
generate block, and the instance in the top module are then bound by these
names, and the continuous assignment, the task and the displays are evaluated
directly.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_escname as generator

KEYWORDS = {'module', 'endmodule', 'parameter', 'localparam', 'int', 'input', 'output', 'logic', 'assign', 'task',
            'endtask', 'if', 'begin', 'end', 'initial', 'reg'}
TOKEN = re.compile(r"\\(\S+)(?=\s)|([A-Za-z_][A-Za-z0-9_$]*)|(\d+'d\d+|\d+)|(\"[^\"]*\")|(\$\w+)|([#().,;:=+\[\]])")


def lex(text):
    """(kind, text) pairs: 'name' for an identifier, 'keyword', 'number', 'string', 'system' or 'punct'."""
    out, at = [], 0
    while at < len(text):
        if text[at] in ' \t\n': at += 1; continue
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:at + 30])
        escaped, plain, number, string, system, punct = found.groups()
        if escaped is not None: out.append(('name', escaped))
        elif plain is not None: out.append(('keyword' if plain in KEYWORDS else 'name', plain))
        elif number is not None: out.append(('number', number))
        elif string is not None: out.append(('string', string[1:-1]))
        elif system is not None: out.append(('system', system))
        else: out.append(('punct', punct))
        at = found.end()
    return out


class Stream:
    def __init__(self, tokens): self.tokens, self.at = tokens, 0

    def peek(self, ahead=0): return self.tokens[self.at + ahead] if self.at + ahead < len(self.tokens) else (None, None)

    def take(self, kind=None, text=None):
        item = self.peek()
        assert item[0] is not None, 'unexpected end'
        assert (kind is None or item[0] == kind) and (text is None or item[1] == text), ('expected', kind, text, item)
        self.at += 1
        return item[1]

    def word(self, text): return self.take('keyword', text)

    def punct(self, text): return self.take('punct', text)

    def name(self): return self.take('name')


def number(text):
    sized = re.fullmatch(r"(\d+)'d(\d+)", text)
    return int(sized[2]) % (1 << int(sized[1])) if sized else int(text)


def skip_expression(s):
    """Step over a sum of names and numbers, to evaluate it later."""
    while True:
        s.take('number' if s.peek()[0] == 'number' else 'name')
        if s.peek() != ('punct', '+'): return
        s.punct('+')


def expression(s, names):
    """A sum of names and numbers."""
    total = 0
    while True:
        kind, text = s.peek()
        if kind == 'number': value = number(s.take())
        else: value = names[s.name()]
        total += value
        if s.peek() != ('punct', '+'): return total
        s.punct('+')


class Program:
    def __init__(self, source):
        code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
        s = Stream(lex(code))
        self.modules = {}
        while s.peek()[0] is not None:
            s.word('module')
            name = s.name()
            assert name not in self.modules, ('module declared twice', name)
            start = s.at
            while s.peek() != ('keyword', 'endmodule'): s.take()
            self.modules[name] = Stream(s.tokens[start:s.at])
            s.word('endmodule')
        children = [n for n, body in self.modules.items() if ('punct', '#') in body.tokens[:2]]
        assert len(children) == 1 and len(self.modules) == 2, 'one child and one top module'
        self.child = children[0]
        self.top = next(n for n in self.modules if n != self.child)

    def elaborate_child(self, override, formal, port_value):
        s = self.modules[self.child]
        s.at = 0
        names, child = {}, {'tasks': {}, 'blocks': {}}
        s.punct('#')
        s.punct('(')
        s.word('parameter')
        s.word('int')
        parameter = s.name()
        s.punct('=')
        default = number(s.take('number'))
        assert override[0] == parameter, ('no such parameter', override[0])
        names[parameter] = override[1] if override else default
        s.punct(')')
        s.punct('(')
        s.word('input')
        s.word('logic')
        for part in ('[', '7', ':', '0', ']'): s.take(None, part)
        port = s.name()
        assert port == formal, ('no such port', formal)
        names[port] = port_value
        s.punct(',')
        s.word('output')
        s.word('logic')
        for part in ('[', '7', ':', '0', ']'): s.take(None, part)
        output = s.name()
        s.punct(')')
        s.punct(';')
        while s.peek()[0] is not None:
            kind, text = s.peek()
            if text == 'localparam':
                s.take()
                s.word('int')
                local = s.name()
                s.punct('=')
                assert local not in names, ('declared twice', local)
                names[local] = number(s.take('number'))
                s.punct(';')
            elif text == 'logic':
                s.take()
                for part in ('[', '7', ':', '0', ']'): s.take(None, part)
                variable = s.name()
                s.punct('=')
                assert variable not in names, ('declared twice', variable)
                names[variable] = number(s.take('number'))
                s.punct(';')
            elif text == 'assign':
                s.take()
                assert s.name() == output, 'assign the output'
                s.punct('=')
                child['out'] = ('later', s.at)
                skip_expression(s)
                s.punct(';')
            elif text == 'task':
                s.take()
                task = s.name()
                s.punct('(')
                s.word('input')
                s.word('int')
                argument = s.name()
                s.punct(')')
                s.punct(';')
                s.take('system', '$display')
                s.punct('(')
                fmt = s.take('string')
                s.punct(',')
                child['tasks'][task] = (argument, fmt, s.at)
                skip_expression(s)
                s.punct(')')
                s.punct(';')
                s.word('endtask')
            elif text == 'if':
                s.take()
                for part in ('(', '1', ')'): s.take(None, part)
                s.word('begin')
                s.punct(':')
                block = s.name()
                s.word('logic')
                for part in ('[', '7', ':', '0', ']'): s.take(None, part)
                inner = s.name()
                s.punct('=')
                child['blocks'][block] = {inner: number(s.take('number'))}
                s.punct(';')
                s.word('end')
            else:
                raise AssertionError(('unsupported item', text))
        # Evaluate the continuous assignment with the final names.
        s.at = child['out'][1]
        child['out'] = expression(s, names) % 256
        child['names'] = names
        child['stream'] = s
        return child

    def run(self):
        s = self.modules[self.top]
        s.at = 0
        s.punct(';')
        s.word('logic')
        for part in ('[', '7', ':', '0', ']'): s.take(None, part)
        names = {}
        first = s.name()
        s.punct('=')
        names[first] = number(s.take('number'))
        s.punct(',')
        second = s.name()
        s.punct(';')
        assert s.name() == self.child, 'instantiate the child module'
        s.punct('#')
        s.punct('(')
        s.punct('.')
        parameter = s.name()
        s.punct('(')
        override = number(s.take('number'))
        s.punct(')')
        s.punct(')')
        instance = s.name()
        s.punct('(')
        connections = {}
        while True:
            s.punct('.')
            formal = s.name()
            s.punct('(')
            connections[formal] = s.name()
            s.punct(')')
            if s.peek() == ('punct', ')'): break
            s.punct(',')
        s.punct(')')
        s.punct(';')
        port = next(f for f in connections if f != 'q')
        child = self.elaborate_child((parameter, override), port, names[connections[port]])
        names[connections['q']] = child['out']
        assert connections['q'] == second
        out = []
        s.word('initial')
        s.word('begin')
        s.punct('#')
        s.take('number')
        s.punct(';')
        while s.peek() != ('keyword', 'end'):
            if s.peek() == ('system', '$display'):
                s.take()
                s.punct('(')
                fmt = s.take('string')
                s.punct(',')
                value = self.read(s, names, instance, child)
                s.punct(')')
                s.punct(';')
                out.append(fmt.replace('%0d', str(value)) + '\n')
            else:
                assert s.name() == instance, 'call through the instance'
                s.punct('.')
                task = s.name()
                argument, fmt, at = child['tasks'][task]
                s.punct('(')
                given = number(s.take('number'))
                s.punct(')')
                s.punct(';')
                body = child['stream']
                body.at = at
                out.append(fmt.replace('%0d', str(expression(body, child['names'] | {argument: given}))) + '\n')
        s.word('end')
        return ''.join(out)

    def read(self, s, names, instance, child):
        first = s.name()
        if s.peek() != ('punct', '.'): return names[first]
        assert first == instance, ('no such instance', first)
        s.punct('.')
        second = s.name()
        if s.peek() == ('punct', '.'):
            s.punct('.')
            return child['blocks'][second][s.name()]
        return child['names'][second]


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'inst_newline': anchor(('inst', 'special', 'same', 'newline')),
                'var_tab': anchor(('var', 'special', 'same', 'tab')),
                'block_keyword': anchor(('block', 'keyword', 'same', 'many')),
                'module_swapped': anchor(('module', 'escaped', 'swapped', 'space')),
                'port_swapped': anchor(('port', 'plain', 'swapped', 'tab')),
                'param_special': anchor(('param', 'special', 'same', 'space')),
                'task_keyword': anchor(('task', 'keyword', 'same', 'newline'))}
    faults = (
        ('other_override', 'inst_newline', [('.EC_P(5)', '.EC_P(6)')]),
        ('decoy_read', 'var_tab', [('ec_u.\\ec_v+1\t', 'ec_u.ec_v')]),
        ('other_member', 'block_keyword', [("logic [7:0] g = 8'd6;", "logic [7:0] g = 8'd16;")]),
        ('wider_sum', 'module_swapped', [("x = 8'd10", "x = 8'd11")]),
        ('other_variable', 'port_swapped', [("logic [7:0] ec_v = 8'd3;", "logic [7:0] ec_v = 8'd2;")]),
        ('decoy_parameter', 'param_special', [('ec_in+ \\EC_P+1 ;', 'ec_in+ EC_P;')]),
        ('other_argument', 'task_keyword', [('(2);', '(3);')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_escname.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_escname.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent lexing of escaped identifiers and binding of the actual programs by name. Auxiliary '
            'controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
