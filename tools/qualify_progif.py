#!/usr/bin/env python3
"""Interpret actual program/interface region programs independently.

The program text is parsed into an interface, an optional module that takes
the interface as a port, the calling program or module, and the top module
that instantiates them. Their initial and always procedures, always_comb,
continuous assignments, tasks and functions run on an event scheduler with the
regions of 4.5: the Active, Inactive and NBA regions of the active region set,
then the Reactive, Re-Inactive and Re-NBA regions of the reactive region set,
which run until they are all empty before the active region set runs again.

A thread keeps the region set of the procedure it starts in: a program
initial procedure runs in the reactive region set, and so do the subroutines
it calls, wherever they are declared (24.3.1, 24.5). Everything else runs in
the active region set. A #0 resumes in the Inactive or Re-Inactive region
(4.4.2.3, 4.4.2.7), a later delay in the Active or Reactive region of that
time, and a nonblocking assignment updates in the NBA or Re-NBA region
(4.4.2.4, 4.4.2.8). A process waiting on a design variable wakes in the
region of its own set (24.3.2), a continuous assignment is evaluated in the
Active region (4.9.1), and always_comb runs once at time zero and then on
each change of what it reads (9.2.2.2). A modport port allows only what the
modport lists (25.5). The run ends at $finish or when the last thread from a
program initial procedure ends (24.3).

The standard fixes neither the order of the events of one region nor whether
a thread is interrupted by the processes that its write wakes in the region
that is running (4.6, 4.7), so every program runs four times: events forward
and backward, and woken processes run at once or later. All four must print
the same lines.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_progif as generator

TOKEN = re.compile(r"\s*(?:(?P<str>\"(?:[^\"\\]|\\.)*\")|(?P<num>\d+'[hd][0-9a-fA-F]+|\d+)|"
                   r"(?P<id>\$?[A-Za-z_]\w*)|(?P<op><=|\+\+|[#@();,=+.\[\]:]))")
ACTIVE_SET = ('active', 'inactive', 'nba')
REACTIVE_SET = ('reactive', 'reinactive', 'renba')
WIDTH = {'logic': 8, 'wire': 8, 'int': 32}


def tokens(text):
    text = re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*', '', text, flags=re.S)
    out, pos = [], 0
    while pos < len(text):
        m = TOKEN.match(text, pos)
        if not m:
            assert not text[pos:].strip(), ('cannot read', text[pos:pos + 40])
            break
        out.append((m.lastgroup, m.group(m.lastgroup)))
        pos = m.end()
    return out


def number(text):
    if "'" not in text: return int(text)
    _, rest = text.split("'")
    return int(rest[1:], 16 if rest[0] == 'h' else 10)


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
            assert kind in ('interface', 'module', 'program'), kind
            name = self.take()
            port = None
            if self.peek() == '(':
                self.take('(')
                type_name = self.take()
                modport = None
                if self.peek() == '.':
                    self.take('.'); modport = self.take()
                port = (type_name, modport, self.take())
                self.take(')')
            self.take(';')
            units[name] = {'kind': kind, 'port': port, **self.items('end' + kind)}
        return units

    def width(self):
        """[7:0] after logic or wire."""
        self.take('['); high = int(self.take()); self.take(':'); low = int(self.take()); self.take(']')
        assert (high, low) == (7, 0)

    def items(self, end):
        scope = {'vars': {}, 'nets': set(), 'procs': [], 'subs': {}, 'instances': {}, 'modports': {},
                 'assigns': []}
        while self.peek() != end:
            word = self.take()
            if word in ('logic', 'wire', 'int'):
                if word != 'int': self.width()
                while True:
                    name = self.take()
                    value = None
                    if self.peek() == '=':
                        self.take('='); value = number(self.take())
                    if word == 'wire':
                        assert value is None; scope['nets'].add(name)
                    elif word == 'int' and value is None:
                        value = 0
                    scope['vars'][name] = value
                    if self.take() == ';': break
            elif word in ('task', 'function'):
                if word == 'function': self.take('void')
                name = self.take(); self.take('('); self.take('input'); self.take('logic'); self.width()
                formal = self.take(); self.take(')'); self.take(';')
                body = []
                while self.peek() != 'end' + word: body.append(self.statement())
                self.take('end' + word)
                if word == 'function':
                    assert not any(s[0] in ('delay', 'at') for s in body), 'a function shall not block (13.4)'
                scope['subs'][name] = (word, formal, ('block', body))
            elif word == 'modport':
                name = self.take(); self.take('(')
                access, direction = {}, None
                while True:
                    if self.peek() in ('input', 'output', 'import'): direction = self.take()
                    access[self.take()] = direction
                    if self.take() == ')': break
                self.take(';')
                scope['modports'][name] = access
            elif word in ('initial', 'final'):
                scope['procs'].append((word, self.statement()))
            elif word == 'always':
                self.take('@'); self.take('('); watched = self.reference(); self.take(')')
                scope['procs'].append(('always', (watched, self.statement())))
            elif word == 'always_comb':
                scope['procs'].append(('always_comb', self.statement()))
            elif word == 'assign':
                target = self.reference(); self.take('='); value = self.expression(); self.take(';')
                scope['assigns'].append((target, value))
            else:
                instance = self.take(); self.take('(')
                actual = self.take() if self.peek() != ')' else None
                self.take(')'); self.take(';')
                scope['instances'][instance] = (word, actual)
        self.take(end)
        return scope

    def reference(self):
        path = [self.take()]
        while self.peek() == '.':
            self.take('.'); path.append(self.take())
        return tuple(path)

    def statement(self):
        word = self.peek()
        if word == ';':
            self.take(); return ('null',)
        if word == 'begin':
            self.take()
            body = []
            while self.peek() != 'end': body.append(self.statement())
            self.take('end')
            return ('block', body)
        if word == 'forever':
            self.take(); return ('forever', self.statement())
        if word == '#':
            self.take(); amount = int(self.take())
            return ('delay', amount, self.statement())
        if word == '@':
            self.take(); self.take('('); watched = self.reference(); self.take(')')
            return ('at', watched, self.statement())
        if word == '$display':
            self.take(); self.take('(')
            args = []
            while True:
                args.append(self.expression())
                if self.take() == ')': break
            self.take(';')
            return ('display', args)
        if word == '$finish':
            self.take(); self.take(';'); return ('finish',)
        target = self.reference()
        if self.peek() == '++':
            self.take(); self.take(';'); return ('incr', target)
        if self.peek() in ('=', '<='):
            op = self.take(); value = self.expression(); self.take(';')
            return ('blocking' if op == '=' else 'nba', target, value)
        self.take('('); actual = self.expression(); self.take(')'); self.take(';')
        return ('call', target, actual)

    def expression(self):
        left = self.operand()
        if self.peek() == '+':
            self.take('+'); return ('add', left, self.operand())
        return left

    def operand(self):
        kind, value = self.t[self.i]
        if kind == 'num':
            self.i += 1; return ('num', number(value))
        if kind == 'str':
            self.i += 1; return ('str', value[1:-1])
        if value == '$time':
            self.i += 1; return ('time',)
        return ('ref', self.reference())


class Finish(Exception):
    pass


class Simulation:
    def __init__(self, units, reverse, eager):
        self.reverse, self.eager = reverse, eager
        used = {kind for unit in units.values() for kind, _ in unit['instances'].values()}
        tops = [name for name in units if name not in used]
        assert len(tops) == 1, tops
        self.top_name = tops[0]
        self.time, self.out, self.sequence, self.threads = 0, [], 0, []
        self.regions = {r: [] for r in ACTIVE_SET + REACTIVE_SET}
        self.future = []        # (time, sequence, thread)
        self.watch = []         # (thread, scope, name)
        self.combs = []         # (scope, names, thread)
        self.assigns = []       # (scope, target, value, names)
        self.running = None
        self.root = self.build(units, self.top_name, None, None)
        for scope, target, value, _ in self.assigns:   # 4.9.1: evaluated at time zero
            self.schedule('active', ('assign', scope, target, value))

    def build(self, units, name, port, parent):
        unit = units[name]
        scope = {'name': name, 'kind': unit['kind'], 'vars': dict(unit['vars']), 'nets': set(unit['nets']),
                 'subs': unit['subs'], 'modports': unit['modports'], 'children': {}, 'port': None,
                 'parent': parent}
        if unit['port'] is not None:
            type_name, modport, formal = unit['port']
            assert port is not None and port['name'] == type_name, (name, unit['port'])
            scope['port'] = (formal, port, port['modports'][modport] if modport else None)
        for instance, (kind, actual) in unit['instances'].items():
            bound = scope['children'][actual] if actual is not None else None
            scope['children'][instance] = self.build(units, kind, bound, scope)
        for target, value in unit['assigns']:
            self.assigns.append((scope, target, value, self.reads(value)))
        program = unit['kind'] == 'program'
        for kind, body in unit['procs']:
            assert kind != 'final'
            if kind == 'initial':
                self.spawn(scope, body, 'reactive' if program else 'active', program)
            elif kind == 'always':
                assert not program, 'a program contains no always procedure (24.3)'
                watched, statement = body
                self.spawn(scope, ('forever', ('at', watched, statement)), 'active', False)
            else:
                thread = self.spawn(scope, ('forever', ('comb', body)), 'active', False)
                self.combs.append((scope, self.reads_statement(body), thread))
        return scope

    def reads(self, expression):
        if expression[0] == 'ref': return {expression[1]}
        if expression[0] == 'add': return self.reads(expression[1]) | self.reads(expression[2])
        return set()

    def reads_statement(self, statement):
        assert statement[0] == 'blocking', statement
        return self.reads(statement[2])

    def spawn(self, scope, body, region_set, origin):
        thread = {'scope': scope, 'stack': [(body, scope, {})], 'set': region_set, 'origin': origin,
                  'alive': True, 'id': len(self.threads)}
        self.threads.append(thread)
        self.schedule('active' if region_set == 'active' else 'reactive', ('resume', thread))
        return thread

    def schedule(self, region, event):
        self.sequence += 1
        self.regions[region].append((self.sequence, event))
        if self.eager and self.running == region and event[0] != 'nba':
            # 4.7: the running thread may be suspended here in favour of the woken process.
            self.regions[region].pop()
            self.execute(event)

    def resolve(self, scope, path, frame, access):
        """The scope that holds the last name of path, and that name."""
        if len(path) == 1 and path[0] in frame: return frame, path[0]
        if path[0] == self.top_name:
            home, rest = self.root, path[1:]
        else:
            home, rest = scope, path
            while len(rest) > 1:
                port = home['port']
                if port is not None and port[0] == rest[0]:
                    _, bound, allowed = port
                    if allowed is not None:
                        assert allowed.get(rest[1]) in access, ('not allowed through the modport', rest, access)
                    home, rest = bound, rest[1:]
                    break
                if rest[0] in home['children']:
                    home, rest = home['children'][rest[0]], rest[1:]
                    break
                home = home['parent']
                assert home is not None, path
        while len(rest) > 1:
            home, rest = home['children'][rest[0]], rest[1:]
        name = rest[0]
        while name not in home['vars'] and name not in home['subs']:
            home = home['parent']
            assert home is not None, path
        return home['vars'] if name in home['vars'] else home, name

    def read(self, scope, frame, expression):
        kind = expression[0]
        if kind == 'num': return expression[1]
        if kind == 'time': return self.time
        if kind == 'add':
            left, right = self.read(scope, frame, expression[1]), self.read(scope, frame, expression[2])
            return None if left is None or right is None else (left + right) & 0xff
        store, name = self.resolve(scope, expression[1], frame, ('input', 'output'))
        return store[name]

    def store_of(self, store):
        for scope in self.all_scopes(self.root):
            if scope['vars'] is store: return scope
        return None

    def all_scopes(self, scope):
        yield scope
        for child in scope['children'].values(): yield from self.all_scopes(child)

    def same(self, scope, path, store, name):
        found = self.resolve(scope, path, {}, ('input', 'output'))
        return found[0] is store and found[1] == name

    def write(self, store, name, value):
        old = store[name]
        store[name] = value
        if old == value: return
        for entry in [e for e in self.watch if e[1] is store and e[2] == name]:
            self.watch[:] = [e for e in self.watch if e is not entry]
            thread = entry[0]
            self.schedule('active' if thread['set'] == 'active' else 'reactive', ('resume', thread))
        for scope, target, expression, names in self.assigns:
            if any(self.same(scope, n, store, name) for n in names):
                self.schedule('active', ('assign', scope, target, expression))
        for scope, names, thread in self.combs:
            waiting = any(e[0] is thread for e in self.watch)
            if waiting and any(self.same(scope, n, store, name) for n in names):
                self.watch[:] = [e for e in self.watch if e[0] is not thread]
                self.schedule('active', ('resume', thread))

    def text(self, scope, frame, args):
        fmt, values = args[0][1], [self.read(scope, frame, a) for a in args[1:]]
        pieces = re.split(r'(%h|%0d)', fmt)
        out, values = [], list(values)
        for piece in pieces:
            if piece == '%h':
                out.append(f'{values.pop(0):02x}')
            elif piece == '%0d':
                out.append(str(values.pop(0)))
            else:
                out.append(piece)
        assert not values, fmt
        return ''.join(out)

    def execute(self, event):
        kind = event[0]
        if kind == 'resume':
            self.step(event[1])
        elif kind == 'nba':
            _, store, name, value = event
            self.write(store, name, value)
        else:
            _, scope, target, value = event
            store, name = self.resolve(scope, target, {}, ('output',))
            assert name in self.store_of(store)['nets'], 'a continuous assignment drives a net here'
            self.write(store, name, self.read(scope, {}, value))

    def step(self, thread):
        """Run one thread until it waits or ends."""
        while thread['alive'] and thread['stack']:
            item, scope, frame = thread['stack'].pop()
            kind = item[0]
            if kind == 'null': continue
            if kind == 'block':
                thread['stack'].extend((s, scope, frame) for s in reversed(item[1])); continue
            if kind == 'forever':
                thread['stack'].extend([(item, scope, frame), (item[1], scope, frame)]); continue
            if kind == 'delay':
                thread['stack'].append((item[2], scope, frame))
                if item[1] == 0:
                    self.schedule('inactive' if thread['set'] == 'active' else 'reinactive', ('resume', thread))
                else:
                    self.sequence += 1
                    self.future.append((self.time + item[1], self.sequence, thread))
                return
            if kind == 'at':
                thread['stack'].append((item[2], scope, frame))
                store, name = self.resolve(scope, item[1], frame, ('input', 'output'))
                self.watch.append((thread, store, name))
                return
            if kind == 'comb':
                statement = item[1]
                store, name = self.resolve(scope, statement[1], frame, ('output',))
                self.write(store, name, self.read(scope, frame, statement[2]))
                self.watch.append((thread, None, None))    # woken by write() through self.combs
                return
            if kind in ('blocking', 'nba'):
                store, name = self.resolve(scope, item[1], frame, ('output',))
                assert store is frame or name not in self.store_of(store)['nets'], 'a net is not a variable'
                value = self.read(scope, frame, item[2])
                if kind == 'blocking':
                    self.write(store, name, value)
                else:
                    self.schedule('nba' if thread['set'] == 'active' else 'renba', ('nba', store, name, value))
                continue
            if kind == 'incr':
                store, name = self.resolve(scope, item[1], frame, ('output',))
                self.write(store, name, store[name] + 1); continue
            if kind == 'call':
                home, name = self.resolve(scope, item[1], frame, ('import',))
                sort, formal, body = home['subs'][name]
                thread['stack'].append((body, home, {formal: self.read(scope, frame, item[2])}))
                continue
            if kind == 'display':
                self.out.append(self.text(scope, frame, item[1]) + '\n'); continue
            if kind == 'finish':
                raise Finish
            raise AssertionError(item)
        if thread['alive'] and not thread['stack']:
            thread['alive'] = False
            if thread['origin'] and not any(t['alive'] and t['origin'] for t in self.threads):
                raise Finish       # 24.3: the implicit $finish

    def region(self, name):
        events = self.regions[name]
        self.regions[name] = []
        if name not in ('active', 'reactive') or self.reverse is False or events and events[0][1][0] == 'nba':
            ordered = events
        else:
            ordered = events[::-1]
        for _, event in ordered:
            self.running = name
            self.execute(event)
            self.running = name
        # Events scheduled into this region while it ran.
        if self.regions[name]: self.region(name)

    def slot(self):
        """4.5, execute_time_slot, without the PLI regions."""
        while any(self.regions[r] for r in ACTIVE_SET + REACTIVE_SET):
            while any(self.regions[r] for r in ACTIVE_SET):
                self.region('active')
                for later in ACTIVE_SET[1:]:
                    if self.regions[later]:
                        self.regions['active'] = self.regions[later]; self.regions[later] = []
                        break
            while any(self.regions[r] for r in REACTIVE_SET):
                self.region('reactive')
                for later in REACTIVE_SET[1:]:
                    if self.regions[later]:
                        self.regions['reactive'] = self.regions[later]; self.regions[later] = []
                        break
        self.running = None

    def run(self, limit=100):
        try:
            self.slot()
            while self.future:
                self.time = min(t for t, _, _ in self.future)
                assert self.time <= limit
                now = sorted((s, th) for t, s, th in self.future if t == self.time)
                self.future = [e for e in self.future if e[0] != self.time]
                for _, thread in now:
                    self.schedule('active' if thread['set'] == 'active' else 'reactive', ('resume', thread))
                self.slot()
        except Finish:
            pass
        return ''.join(self.out)


def interpret(source):
    results = {(r, e): Simulation(Parser(source).design(), r, e).run() for r in (False, True) for e in (False, True)}
    assert len(set(results.values())) == 1, results
    return next(iter(results.values()))


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'program_task': anchor(('program', 'port', 'task', 'blocking', 'always', 'interface')),
                'module_task': anchor(('module', 'port', 'task', 'blocking', 'always', 'interface')),
                'program_delayed_nba': anchor(('program', 'hier', 'delayed', 'nba', 'nba', 'module')),
                'module_delayed_comb': anchor(('module', 'hier', 'delayed', 'blocking', 'comb', 'module')),
                'program_function_nba': anchor(('program', 'port', 'function', 'nba', 'assign', 'interface')),
                'program_wrapper_assign': anchor(('program', 'modport', 'wrapper', 'blocking', 'assign', 'module'))}
    faults = (
        # The read of y right after the write would race in a module (4.7), so it becomes a constant.
        ('program_runs_as_module', 'program_task', [('program driver', 'module driver'),
                                                    ('endprogram', 'endmodule'),
                                                    ('    b0 = i.y;', "    b0 = 8'h12;")]),
        ('task_writes_nonblocking', 'module_task', [('    x = v;', '    x <= v;')]),
        ('reaction_writes_nonblocking', 'module_task', [("y = x + 8'd1;", "y <= x + 8'd1;")]),
        ('task_waits_a_unit', 'program_delayed_nba', [('    #0;\n    x <= v;', '    #1;\n    x <= v;')]),
        ('writes_the_old_value', 'module_delayed_comb', [("put(8'h5a);", "put(8'h11);")]),
        ('function_writes_blocking', 'program_function_nba', [('    x <= v;', '    x = v;')]),
        ('observer_starts_late', 'program_function_nba', [('    #1;\n    forever', '    #6;\n    forever')]),
        ('observer_counts_twice', 'program_wrapper_assign', [('i.nw++;', 'begin i.nw++; i.nw++; end')]),
        ('reaction_adds_two', 'program_wrapper_assign', [("i.x + 8'd1;", "i.x + 8'd2;")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_progif.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_progif.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent event-driven reading of the actual programs by 4.5, 4.4.2, 24.3.1, 24.3.2, 24.5, 4.9.1, '
            '9.2.2.2 and 25.5, with both event orders and with and without the interruption of 4.7. Auxiliary '
            'controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
