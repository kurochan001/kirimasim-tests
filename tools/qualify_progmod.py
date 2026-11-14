#!/usr/bin/env python3
"""Interpret actual program hierarchy programs independently.

The program text is parsed into programs and modules declared in the
compilation unit or nested in a module, their parameters with defaults,
ports, variables, instances with named parameter values and port
connections, defparam statements, and initial and final procedures.
Elaboration follows the hierarchy rules: a module or program that no one
instantiates is a top-level instance (23.3.1, 24.3); a nested program without
ports is instantiated once under its own name, and a nested program with
ports that its parent does not instantiate is ignored (24.3, 23.4).
Parameters take their default, then the value of the instance, then a
defparam that names them (23.10). A simple name is looked up in the scope of
the code and then in the scopes that enclose its declaration (23.9), and a
dotted name from the name of a top-level instance down (23.6).

The procedures run on a small scheduler: an initial procedure of a module in
the Active region and one of a program in the Reactive region of its time
(24.3.1). When every initial procedure of every program has ended, the
implicit $finish of 24.3 ends the run; otherwise the run ends when nothing is
left. Final procedures then run (9.2.3). Every program runs with the
processes of one region in forward and in reverse order, and both runs must
print the same lines.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_progmod as generator

TOKEN = re.compile(r'\s*(?:(?P<str>"(?:[^"\\]|\\.)*")|(?P<num>\d+)|(?P<id>\$?[A-Za-z_]\w*)|'
                   r'(?P<op>\+=|[#@();,=+.])|(?P<other>\S))')


def tokens(text):
    text = re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*', '', text, flags=re.S)
    out, pos = [], 0
    while pos < len(text):
        m = TOKEN.match(text, pos)
        if not m:
            assert not text[pos:].strip(), ('cannot read', text[pos:pos + 40])
            break
        assert m.lastgroup != 'other', ('unexpected', m.group('other'))
        out.append((m.lastgroup, m.group(m.lastgroup)))
        pos = m.end()
    return out


class Parser:
    def __init__(self, text): self.t, self.i = tokens(text), 0

    def peek(self, k=0): return self.t[self.i + k][1] if self.i + k < len(self.t) else None

    def take(self, want=None):
        value = self.t[self.i][1]
        assert want is None or value == want, ('expected', want, 'got', value, self.t[self.i - 3:self.i + 3])
        self.i += 1
        return value

    def design(self):
        units = {}
        while self.peek() is not None:
            kind = self.take()
            assert kind in ('module', 'program'), kind
            name, unit = self.unit(kind)
            units[name] = unit
        return units

    def unit(self, kind):
        name = self.take()
        params, ports = {}, []
        if self.peek() == '#':
            self.take('#'); self.take('(')
            while True:
                self.take('parameter'); self.take('int')
                pname = self.take(); self.take('='); params[pname] = int(self.take())
                if self.take() == ')': break
        if self.peek() == '(':
            self.take('(')
            while self.peek() != ')':
                self.take('input'); self.take('var'); self.take('int'); ports.append(self.take())
                if self.peek() == ',': self.take(',')
            self.take(')')
        self.take(';')
        unit = {'kind': kind, 'params': params, 'ports': ports, 'vars': {}, 'procs': [], 'instances': [],
                'defparams': [], 'nested': {}}
        end = 'end' + kind
        while self.peek() != end:
            word = self.take()
            if word == 'int':
                while True:
                    vname = self.take(); self.take('='); unit['vars'][vname] = int(self.take())
                    if self.take() == ';': break
            elif word in ('initial', 'final'):
                unit['procs'].append((word, self.statement()))
            elif word == 'defparam':
                while True:
                    path = self.reference(); self.take('='); unit['defparams'].append((path, int(self.take())))
                    if self.take() == ';': break
            elif word in ('module', 'program'):
                nested_name, nested = self.unit(word)
                unit['nested'][nested_name] = nested
            else:
                overrides = {}
                if self.peek() == '#':
                    self.take('#'); self.take('(')
                    while True:
                        self.take('.'); pname = self.take(); self.take('('); overrides[pname] = int(self.take())
                        self.take(')')
                        if self.take() == ')': break
                instance = self.take(); self.take('(')
                connections = {}
                while self.peek() != ')':
                    self.take('.'); port = self.take(); self.take('('); connections[port] = self.expression()
                    self.take(')')
                    if self.peek() == ',': self.take(',')
                self.take(')'); self.take(';')
                unit['instances'].append((word, instance, overrides, connections))
        self.take(end)
        return name, unit

    def reference(self):
        path = [self.take()]
        while self.peek() == '.':
            self.take('.'); path.append(self.take())
        return tuple(path)

    def statement(self):
        word = self.peek()
        if word == 'begin':
            self.take()
            body = []
            while self.peek() != 'end': body.append(self.statement())
            self.take('end')
            return ('block', body)
        if word == '#':
            self.take(); amount = self.expression()
            if self.peek() == ';':
                self.take(); return ('delay', amount, ('block', []))
            return ('delay', amount, self.statement())
        if word == '$display':
            self.take(); self.take('(')
            args = []
            while True:
                args.append(self.expression())
                if self.take() == ')': break
            self.take(';')
            return ('display', args)
        target = self.reference()
        op = self.take()
        assert op in ('=', '+='), op
        value = self.expression(); self.take(';')
        return ('assign', op, target, value)

    def expression(self):
        left = self.operand()
        while self.peek() == '+':
            self.take('+'); left = ('add', left, self.operand())
        return left

    def operand(self):
        kind, value = self.t[self.i]
        if kind == 'num':
            self.i += 1; return ('num', int(value))
        if kind == 'str':
            self.i += 1; return ('str', value[1:-1])
        if value == '$time':
            self.i += 1; return ('time',)
        return ('ref', self.reference())


class Finish(Exception):
    pass


class Simulation:
    def __init__(self, units, reverse):
        self.reverse = reverse
        self.out, self.time, self.timed, self.sequence = [], 0, [], 0
        self.finals, self.threads = [], []
        used = set()
        for unit in units.values():
            used.update(kind for kind, _, _, _ in unit['instances'])
        self.tops = {}
        for name, unit in units.items():
            if name not in used:      # 23.3.1, 24.3: top-level and implicitly instantiated
                self.tops[name] = self.build(units, unit, name, name, None, {}, {}, None)
        self.apply_defparams()
        for scope in self.all_scopes():
            for kind, body in scope['unit']['procs']:
                if kind == 'final':
                    self.finals.append((scope, body))
                else:
                    self.spawn(scope, body)

    def build(self, units, unit, kind, name, parent, overrides, connections, outer):
        scope = {'unit': unit, 'kind': unit['kind'], 'name': name, 'parent': parent, 'outer': outer,
                 'params': dict(unit['params']), 'vars': dict(unit['vars']), 'children': {}}
        scope['params'].update(overrides)
        for port in unit['ports']:
            scope['vars'][port] = self.read(parent, connections[port]) if port in connections else 0
        local = dict(units)
        local.update({n: (u, scope) for n, u in unit['nested'].items()})
        declared = set()
        for child_kind, child_name, child_overrides, child_connections in unit['instances']:
            entry = local[child_kind]
            child_unit, child_outer = entry if isinstance(entry, tuple) else (entry, None)
            declared.add(child_kind)
            scope['children'][child_name] = self.build(units, child_unit, child_kind, child_name, scope,
                                                       child_overrides, child_connections, child_outer)
        for nested_name, nested in unit['nested'].items():
            if nested_name in declared:
                continue
            if not nested['ports']:   # 24.3, 23.4: implicitly instantiated once under its own name
                scope['children'][nested_name] = self.build(units, nested, nested_name, nested_name, scope, {}, {},
                                                            scope)
            # A nested unit with ports that no one instantiates is ignored (23.4).
        return scope

    def all_scopes(self):
        stack = list(self.tops.values())
        while stack:
            scope = stack.pop(0)
            yield scope
            stack[:0] = list(scope['children'].values())

    def path_scope(self, scope, path):
        """The instance named by the dotted path, from a top-level instance or a child of an enclosing scope."""
        first = path[0]
        start = None
        probe = scope
        while probe is not None:
            if first in probe['children']:
                start = probe['children'][first]
                break
            probe = probe['parent']
        if start is None:
            start = self.tops[first]
        for name in path[1:]:
            start = start['children'][name]
        return start

    def apply_defparams(self):
        for scope in list(self.all_scopes()):
            for path, value in scope['unit']['defparams']:
                target = self.path_scope(scope, path[:-1])
                assert path[-1] in target['params']
                target['params'][path[-1]] = value

    def resolve(self, scope, path):
        """The dictionary that holds the named variable or parameter, and its name."""
        if len(path) > 1:
            target = self.path_scope(scope, path[:-1])
            return (target['vars'] if path[-1] in target['vars'] else target['params']), path[-1]
        name = path[0]
        probe = scope
        while probe is not None:      # 23.9: the scope of the code, then the scopes that enclose its declaration
            if name in probe['vars']: return probe['vars'], name
            if name in probe['params']: return probe['params'], name
            probe = probe['outer']
        raise AssertionError(('unresolved', path))

    def read(self, scope, expression):
        kind = expression[0]
        if kind == 'num': return expression[1]
        if kind == 'time': return self.time
        if kind == 'add': return self.read(scope, expression[1]) + self.read(scope, expression[2])
        store, name = self.resolve(scope, expression[1])
        return store[name]

    def hierarchical_name(self, scope):
        names = []
        while scope is not None:
            names.append(scope['name'])
            scope = scope['parent']
        return '.'.join(reversed(names))

    def text(self, scope, args):
        fmt, values = args[0][1], [self.read(scope, a) for a in args[1:]]
        out = []
        for piece in re.split(r'(%m|%0t|%0d)', fmt):
            if piece == '%m': out.append(self.hierarchical_name(scope))
            elif piece in ('%0t', '%0d'): out.append(str(values.pop(0)))
            else: out.append(piece)
        assert not values, fmt
        return ''.join(out)

    def spawn(self, scope, body):
        thread = {'scope': scope, 'stack': [body], 'program': scope['kind'] == 'program', 'id': len(self.threads),
                  'alive': True}
        self.threads.append(thread)
        self.schedule(thread, 0)

    def schedule(self, thread, delay):
        self.sequence += 1
        self.timed.append((self.time + delay, self.sequence, thread))

    def step(self, thread):
        scope = thread['scope']
        while thread['stack']:
            item = thread['stack'].pop()
            kind = item[0]
            if kind == 'block':
                thread['stack'].extend(reversed(item[1])); continue
            if kind == 'delay':
                thread['stack'].append(item[2]); self.schedule(thread, self.read(scope, item[1])); return
            if kind == 'display':
                self.out.append(self.text(scope, item[1]) + '\n'); continue
            if kind == 'assign':
                _, op, target, value = item
                store, name = self.resolve(scope, target)
                assert store is not scope['params']
                new = self.read(scope, value)
                store[name] = store[name] + new if op == '+=' else new
                continue
            raise AssertionError(item)
        thread['alive'] = False
        programs = [t for t in self.threads if t['program']]
        if thread['program'] and not any(t['alive'] for t in programs):
            raise Finish      # 24.3: the implicit $finish

    def run(self, limit=1000):
        try:
            while self.timed:
                self.time = min(t for t, _, _ in self.timed)
                assert self.time <= limit
                now = sorted((s, th) for t, s, th in self.timed if t == self.time)
                self.timed = [e for e in self.timed if e[0] != self.time]
                # 24.3.1: module processes in the Active region before program processes in the Reactive region.
                for program in (False, True):
                    batch = [th for _, th in now if th['program'] == program]
                    batch.sort(key=lambda th: th['id'], reverse=self.reverse)
                    for thread in batch: self.step(thread)
        except Finish:
            pass
        for scope, body in self.finals:
            self.step({'scope': scope, 'stack': [body], 'program': False, 'id': -1, 'alive': True})
        return ''.join(self.out)


def interpret(source):
    results = {r: Simulation(Parser(source).design(), r).run() for r in (False, True)}
    assert len(set(results.values())) == 1, results
    return next(iter(results.values()))


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    # kirimasim does not instantiate a nested program with parameters and no ports, so no control uses that form.
    controls = {'implicit_top': anchor(('implicit_top', 'one', 'absolute', 'default', 'none', 'ignored')),
                'child_defparam_peer': anchor(('child_inst', 'two', 'absolute', 'defparam', 'read', 'none')),
                'nested_inst_override_peer': anchor(('nested_inst', 'two', 'upward', 'override', 'read', 'ignored')),
                'top_override_peer': anchor(('top_inst', 'two', 'absolute', 'override', 'read', 'none')),
                'top_default': anchor(('top_inst', 'one', 'absolute', 'default', 'none', 'ignored'))}
    faults = (
        ('ignored_program_has_no_ports', 'top_default', [('program unused(input var int base);', 'program unused;')]),
        ('second_instance_ends_first', 'top_override_peer', [('#(.D(6), .K(5)) p2', '#(.D(2), .K(5)) p2')]),
        ('defparam_value_changes', 'child_defparam_peer', [('c.p2.K = 6;', 'c.p2.K = 9;')]),
        ('peer_reads_the_second', 'child_defparam_peer', [('.c.p1.local_count);', '.c.p2.local_count);')]),
        ('input_port_value_changes', 'nested_inst_override_peer', [('p2(.base(20));', 'p2(.base(30));')]),
        ('local_name_hides_parent', 'nested_inst_override_peer', [
            ('    int local_count = 0;\n', '    int local_count = 0;\n    int total = 0;\n')]),
        ('program_becomes_module', 'top_override_peer', [('program worker', 'module worker'),
                                                         ('endprogram', 'endmodule')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_progmod.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_progmod.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent elaboration and event-driven reading of the actual programs by 24.3, 23.4, 23.3.1, 23.6, '
            '23.9, 23.10 and 24.3.1, with both process orders. Auxiliary controls and faults are not fixed-suite or '
            'coverage passes.', __doc__)


if __name__ == '__main__': main()
