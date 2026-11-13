#!/usr/bin/env python3
"""Interpret actual simulation-end programs independently.

The program text is parsed into modules, child instances and nested programs,
and their initial, always and final procedures, tasks and functions run on a
small event scheduler: delays, named events (15.5), changes and posedges
(9.4.2), wait (9.4.3), fork join_none (9.3.2), and module processes in the
Active region before program processes in the Reactive region (4.5, 24.3.1).
$finish ends the run (20.2), $fatal also sets a failing exit code (20.10),
and $exit from a thread that begins in an initial procedure of a program ends
every initial procedure of that program and its descendants (24.7); a call
from any other thread is ignored. When the last thread that begins in an
initial procedure of a program has ended, the implicit $finish of 24.3 ends
the run. The final procedures then print (9.2.3).

The standard fixes neither the order of processes in one region nor whether
the rest of a time step runs after $finish, so every program runs four times:
processes forward and backward, and $finish at once or at the end of the time
step. All four must print the same lines with the same exit code.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_simend as generator

TOKEN = re.compile(r'\s*(?:(?P<str>"(?:[^"\\]|\\.)*")|(?P<num>\d+)|(?P<id>\$?[A-Za-z_]\w*)|(?P<op>->|\+\+|[#@();,=~.]))')


def tokens(text):
    text = re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*', '', text, flags=re.S)
    out, pos = [], 0
    while pos < len(text):
        m = TOKEN.match(text, pos)
        if not m:
            assert not text[pos:].strip(), ('cannot read', text[pos:pos + 40])
            break
        kind = m.lastgroup
        out.append((kind, m.group(kind)))
        pos = m.end()
    return out


class Parser:
    def __init__(self, text): self.t, self.i = tokens(text), 0

    def peek(self, k=0): return self.t[self.i + k][1] if self.i + k < len(self.t) else None

    def take(self, want=None):
        kind, value = self.t[self.i]
        assert want is None or value == want, ('expected', want, 'got', value, self.t[self.i - 3:self.i + 3])
        self.i += 1
        return value

    def design(self):
        units = {}
        while self.peek() is not None:
            kind = self.take()
            assert kind == 'module', kind
            name = self.take(); self.take(';')
            units[name] = self.items('endmodule')
        return units

    def items(self, end):
        scope = {'vars': {}, 'events': set(), 'procs': [], 'subs': {}, 'instances': {}, 'programs': {}}
        while self.peek() != end:
            word = self.take()
            if word in ('int', 'bit'):
                while True:
                    name = self.take(); self.take('='); value = int(self.take())
                    scope['vars'][name] = value
                    if self.take() == ';': break
            elif word == 'event':
                scope['events'].add(self.take()); self.take(';')
            elif word in ('initial', 'always', 'final'):
                scope['procs'].append((word, self.statement()))
            elif word in ('task', 'function'):
                self.take('automatic')
                if word == 'function': self.take('void')
                name = self.take(); self.take('('); self.take(')'); self.take(';')
                body = []
                while self.peek() != 'end' + word: body.append(self.statement())
                self.take('end' + word)
                scope['subs'][name] = (word, ('block', body))
            elif word == 'program':
                name = self.take(); self.take(';')
                scope['programs'][name] = self.items('endprogram')
            else:
                instance = self.take(); self.take('('); self.take(')'); self.take(';')
                scope['instances'][instance] = word
        self.take(end)
        return scope

    def statement(self):
        word = self.peek()
        if word == ';':
            self.take(); return ('null',)
        if word in ('begin', 'fork'):
            self.take()
            body, close = [], 'end' if word == 'begin' else 'join_none'
            while self.peek() != close: body.append(self.statement())
            self.take(close)
            return ('block', body) if word == 'begin' else ('fork', body)
        if word == '#':
            self.take(); amount = int(self.take())
            return ('delay', amount, self.statement())
        if word == '@':
            self.take(); self.take('(')
            edge = self.take() if self.peek() == 'posedge' else None
            name = self.take(); self.take(')')
            return ('at', edge, name, self.statement())
        if word == 'wait':
            self.take(); self.take('('); name = self.take(); self.take(')')
            return ('wait', name, self.statement())
        if word == '->':
            self.take(); name = self.take(); self.take(';')
            return ('trigger', name)
        if word in ('$display', '$write', '$fatal'):
            self.take()
            args = []
            if self.peek() == '(':
                self.take('(')
                while True:
                    args.append(self.expression())
                    if self.take() == ')': break
            self.take(';')
            return ('task', word, args)
        if word in ('$finish', '$exit'):
            self.take(); self.take(';')
            return ('task', word, [])
        name = self.take()
        if self.peek() == '++':
            self.take(); self.take(';'); return ('incr', name)
        if self.peek() == '=':
            self.take(); value = self.expression(); self.take(';')
            return ('assign', name, value)
        self.take('('); self.take(')'); self.take(';')
        return ('call', name)

    def expression(self):
        if self.peek() == '~':
            self.take(); return ('not', self.take())
        kind, value = self.t[self.i]
        self.i += 1
        if kind == 'num': return ('num', int(value))
        if kind == 'str': return ('str', value[1:-1])
        path = [value]
        while self.peek() == '.':
            self.take(); path.append(self.take())
        return ('ref', tuple(path))


class Finish(Exception):
    pass


class Simulation:
    def __init__(self, units, reverse, at_once):
        self.reverse, self.at_once = reverse, at_once
        tops = set(units) - {kind for unit in units.values() for kind in unit['instances'].values()}
        assert len(tops) == 1, tops
        self.scopes, self.threads, self.out = [], [], []
        self.time, self.finishing, self.status = 0, False, 0
        self.watch = []         # (thread, kind, scope, name)
        self.timed = []         # (time, sequence, thread)
        self.sequence = 0
        self.build(units, units[tops.pop()], None, False)

    def build(self, units, unit, parent, program):
        scope = {'vars': dict(unit['vars']), 'events': set(unit['events']), 'subs': unit['subs'],
                 'parent': parent, 'children': {}, 'program': program}
        self.scopes.append(scope)
        for name, kind in unit['instances'].items():
            scope['children'][name] = self.build(units, units[kind], None, False)
        for name, body in unit['programs'].items():
            scope['children'][name] = self.build(units, body, scope, True)
        for kind, body in unit['procs']:
            if kind == 'final': scope.setdefault('finals', []).append(body)
            else: self.spawn(scope, body if kind == 'initial' else ('loop', body), program and kind == 'initial')
        return scope

    def spawn(self, scope, body, origin):
        thread = {'scope': scope, 'stack': [body], 'origin': scope if origin else None, 'alive': True,
                  'program': scope['program'], 'id': len(self.threads)}
        self.threads.append(thread)
        self.ready(thread)
        return thread

    def ready(self, thread):
        self.sequence += 1
        self.timed.append((self.time, self.sequence, thread))

    def lookup(self, scope, path):
        if len(path) > 1:
            return self.lookup(scope['children'][path[0]], path[1:])
        name = path[0]
        while name not in scope['vars'] and name not in scope['events'] and name not in scope['subs']:
            scope = scope['parent']
            assert scope is not None, name
        return scope, name

    def value(self, scope, expression):
        kind = expression[0]
        if kind == 'num': return expression[1]
        if kind == 'not':
            home, name = self.lookup(scope, (expression[1],))
            return 1 - home['vars'][name]
        if expression[1] == ('$time',): return self.time
        home, name = self.lookup(scope, expression[1])
        return home['vars'][name]

    def write(self, scope, name, value):
        home, name = self.lookup(scope, (name,))
        old = home['vars'][name]
        home['vars'][name] = value
        if old == value: return
        for entry in list(self.watch):
            thread, kind, wscope, wname = entry
            if wscope is home and wname == name and (kind == 'change' or (kind == 'posedge' and old == 0 and value == 1)
                                                     or (kind == 'true' and value)):
                self.watch.remove(entry)
                self.ready(thread)

    def text(self, scope, args):
        fmt, values = args[0][1], [self.value(scope, a) for a in args[1:]]
        pieces = fmt.split('%0d')
        assert len(pieces) == len(values) + 1, fmt
        return pieces[0] + ''.join(str(v) + p for v, p in zip(values, pieces[1:]))

    def system(self, thread, name, args):
        scope = thread['scope']
        if name in ('$display', '$write'):
            self.out.append(self.text(scope, args) + ('\n' if name == '$display' else ''))
        elif name in ('$finish', '$fatal'):
            if name == '$fatal': self.status = 1
            self.finish()
        elif name == '$exit':
            origin = thread['origin']
            if origin is None: return
            for other in self.threads:
                if other['origin'] is origin: other['alive'] = False
            self.ended()

    def finish(self):
        if self.at_once: raise Finish
        self.finishing = True

    def ended(self):
        """24.3: after the last thread from a program initial procedure ends."""
        program_threads = [t for t in self.threads if t['origin'] is not None]
        if program_threads and not any(t['alive'] for t in program_threads): self.finish()

    def step(self, thread):
        """Run one thread until it waits or ends."""
        scope = thread['scope']
        while thread['alive'] and thread['stack']:
            item = thread['stack'].pop()
            kind = item[0]
            if kind == 'null': continue
            if kind == 'block': thread['stack'].extend(reversed(item[1])); continue
            if kind == 'loop': thread['stack'].extend([item, item[1]]); continue
            if kind == 'fork':
                for body in item[1]:
                    child = self.spawn(scope, body, False)
                    child['origin'] = thread['origin']
                continue
            if kind == 'delay':
                thread['stack'].append(item[2])
                self.sequence += 1
                self.timed.append((self.time + item[1], self.sequence, thread))
                return
            if kind == 'at':
                thread['stack'].append(item[3])
                home, name = self.lookup(scope, (item[2],))
                self.watch.append((thread, 'posedge' if item[1] else ('event' if name in home['events'] else 'change'),
                                   home, name))
                return
            if kind == 'wait':
                thread['stack'].append(item[2])
                home, name = self.lookup(scope, (item[1],))
                if home['vars'][name]: continue
                self.watch.append((thread, 'true', home, name))
                return
            if kind == 'trigger':
                home, name = self.lookup(scope, (item[1],))
                for entry in list(self.watch):
                    if entry[1] == 'event' and entry[2] is home and entry[3] == name:
                        self.watch.remove(entry); self.ready(entry[0])
                continue
            if kind == 'assign': self.write(scope, item[1], self.value(scope, item[2])); continue
            if kind == 'incr':
                home, name = self.lookup(scope, (item[1],))
                self.write(scope, item[1], home['vars'][name] + 1); continue
            if kind == 'call':
                home, name = self.lookup(scope, (item[1],))
                thread['stack'].append(home['subs'][name][1]); continue
            if kind == 'task': self.system(thread, item[1], item[2]); continue
            raise AssertionError(item)
        if thread['alive'] and thread['origin'] is not None:
            thread['alive'] = False
            self.ended()
        thread['alive'] = False if not thread['stack'] else thread['alive']

    def run(self, limit=1000):
        try:
            while self.timed and not self.finishing:
                self.time = min(t for t, _, _ in self.timed)
                assert self.time <= limit
                while True:
                    now = sorted((s, th) for t, s, th in self.timed if t == self.time)
                    if not now: break
                    self.timed = [e for e in self.timed if e[0] != self.time]
                    # 4.5: the Active region (module processes) before the Reactive region (programs).
                    active = [th for _, th in now if not th['program']]
                    batch = active or [th for _, th in now]
                    rest = [th for _, th in now if th not in batch]
                    for th in rest:
                        self.sequence += 1; self.timed.append((self.time, self.sequence, th))
                    # Two different orders of the processes of one region: by creation, and reversed.
                    unique = {th['id']: th for th in batch}
                    batch = [unique[k] for k in sorted(unique, reverse=self.reverse)]
                    for th in batch:
                        if th['alive']: self.step(th)
        except Finish:
            pass
        for scope in self.scopes:
            for body in scope.get('finals', []):
                thread = {'scope': scope, 'stack': [body], 'origin': None, 'alive': True, 'program': False}
                self.step(thread)
        return ''.join(self.out), self.status


def outcome(source):
    results = {(r, a): Simulation(Parser(source).design(), r, a).run() for r in (False, True) for a in (False, True)}
    assert len(set(results.values())) == 1, results
    return next(iter(results.values()))


def interpret(source): return outcome(source)[0]


def exit_code(source): return 'nonzero' if outcome(source)[1] else '0'


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'finish_fork_top': anchor(('finish', 'fork', 'event', 'top', 'none')),
                'exit_fork_program': anchor(('exit', 'fork', 'change', 'program', 'none')),
                'finish_always_top': anchor(('finish', 'always', 'delay', 'top', 'finish')),
                'exit_function_program': anchor(('exit', 'function', 'delay', 'program', 'finish')),
                'finish_task_child': anchor(('finish', 'task', 'change', 'child', 'none')),
                'finish_initial_program': anchor(('finish', 'initial', 'event', 'program', 'finish'))}
    faults = (
        ('finish_does_not_end', 'finish_fork_top', [('$finish;\n        #1 caller_after', ';\n        #1 caller_after')]),
        ('exit_does_not_end', 'exit_fork_program', [('$exit;', ';')]),
        ('parent_writes_before_end', 'finish_fork_top', [('#20 parent_after = 1;', '#4 parent_after = 1;')]),
        ('late_delay_before_end', 'finish_always_top', [('#7 late_delay = 1;', '#4 late_delay = 1;')]),
        ('late_event_before_end', 'exit_function_program', [('initial #7 -> late_ev;', 'initial #4 -> late_ev;')]),
        ('call_after_second_end', 'exit_function_program', [('      #5;\n', '      #9;\n')]),
        ('early_write_after_end', 'finish_task_child', [('#3 early = 1;', '#6 early = 1;')]),
        ('task_writes_before_call', 'finish_task_child', [('$finish;\n    #1 caller_after = 1;',
                                                           '#0 caller_after = 1;\n    $finish;')]),
        ('second_end_before_call', 'finish_initial_program', [('#8 second_seen = 1;', '#4 second_seen = 1;')]),
        ('clock_counts_twice', 'finish_always_top', [('ticks++;', 'begin ticks++; ticks++; end')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_simend.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_simend.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent event-driven reading of the actual programs by 20.2, 20.10, 24.7, 24.3, 9.2.3 and 4.5, '
            'with both process orders and both readings of the rest of the time step after $finish. Auxiliary '
            'controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
