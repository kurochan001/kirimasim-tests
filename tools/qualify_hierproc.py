#!/usr/bin/env python3
"""Interpret actual hierarchical process control programs independently.

The modules are elaborated into a tree of instance, generate block, task and
named block scopes. A name resolves as 23.6 and 23.8 say: from $root; or in
the scopes of its own module, then upward through the parents of the
instance, where a scope name or the module name of an enclosing instance
matches. Each process runs as a generator under a scheduler with an active
region and an NBA region. Delays, event controls, wait statements, event
triggers, task calls, fork-join_none and disable act on the resolved objects.
Processes start in every order, and each order must print the same text.
"""

from itertools import permutations
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_hierproc as generator

NAME = r"\$root(?:\.\w+(?:\[\d+\])?)+|\w+(?:\[\d+\])?(?:\.\w+(?:\[\d+\])?)*"
TOKEN = re.compile(rf'\s*("(?:[^"\\]|\\.)*"|\$display|\$finish|\$time|\d+\'d\d+|{NAME}|\d+|->|<=|==|\+\+|[<#@();:,=\[\]])')


def lex(text):
    out, at = [], 0
    while at < len(text):
        if text[at:].strip() == '': break
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:at + 40])
        out.append(found[1])
        at = found.end()
    return out


class Stream:
    def __init__(self, tokens): self.tokens, self.at = tokens, 0

    def peek(self): return self.tokens[self.at] if self.at < len(self.tokens) else None

    def take(self, expected=None):
        item = self.peek()
        assert item is not None, 'unexpected end'
        assert expected is None or item == expected, ('expected', expected, item)
        self.at += 1
        return item


def statement(s):
    item = s.peek()
    if item in ('begin', 'fork'):
        s.take()
        name = None
        if s.peek() == ':':
            s.take()
            name = s.take()
        body = []
        end = 'end' if item == 'begin' else 'join_none'
        while s.peek() != end: body.append(statement(s))
        s.take(end)
        return ('block', name, body) if item == 'begin' else ('fork', body)
    if item == '#':
        s.take()
        amount = int(s.take())
        if s.peek() == ';':
            s.take()
            return ('delay', amount, None)
        return ('delay', amount, statement(s))
    if item == '@':
        s.take()
        s.take('(')
        target = s.take()
        s.take(')')
        return ('edge', target, statement(s))
    if item == 'wait':
        s.take()
        s.take('(')
        target = s.take()
        s.take('==')
        number = s.take()
        s.take(')')
        return ('level', target, number, statement(s))
    if item == 'disable':
        s.take()
        target = s.take()
        s.take(';')
        return ('disable', target)
    if item == '->':
        s.take()
        target = s.take()
        s.take(';')
        return ('trigger', target)
    if item == '$display':
        s.take()
        s.take('(')
        text = s.take()
        arguments = []
        while s.peek() == ',':
            s.take()
            arguments.append(s.take())
        s.take(')')
        s.take(';')
        return ('display', text[1:-1], arguments)
    if item == '$finish':
        s.take()
        s.take(';')
        return ('finish',)
    target = s.take()
    following = s.take()
    if following == ';': return ('call', target, None)
    if following == '(':
        argument = s.take()
        s.take(')')
        s.take(';')
        return ('call', target, argument)
    assert following in ('=', '<='), ('unsupported statement', target, following)
    number = s.take()
    s.take(';')
    return ('write' if following == '=' else 'nba', target, number)


def number(text, frame):
    sized = re.fullmatch(r"(\d+)'d(\d+)", text)
    if sized: return int(sized[2]) % (1 << int(sized[1]))
    return frame[text]


class Variable:
    def __init__(self, value): self.value, self.waiters = value, []


class Event:
    def __init__(self): self.waiters = []


class Scope:
    def __init__(self, name, kind, parent, module=None):
        self.name, self.kind, self.parent, self.module = name, kind, parent, module
        self.children = {}
        if parent is not None: parent.children[name] = self

    def path(self):
        return self.name if self.parent is None else self.parent.path() + '.' + self.name

    def instance(self):
        scope = self
        while scope.kind != 'instance': scope = scope.parent
        return scope


def declare(item, scope):
    """Each named block is a scope from elaboration on, so it can be named before it runs."""
    kind = item[0]
    if kind == 'block':
        inner = Scope(item[1], 'block', scope) if item[1] else scope
        for part in item[2]: declare(part, inner)
    elif kind == 'fork':
        for part in item[1]: declare(part, scope)
    elif kind in ('delay', 'edge') and item[2]: declare(item[2], scope)
    elif kind == 'level': declare(item[3], scope)


class Disabled(Exception):
    def __init__(self, block): self.block = block


class Process:
    def __init__(self, body): self.body, self.blocks, self.pending = body, [], None


class Design:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        self.modules = {m[1]: m[2] for m in re.finditer(r'^module (\w+);\n(.*?)^endmodule', code, re.S | re.M)}
        assert self.modules and re.sub(r'^module \w+;\n.*?^endmodule\s*', '', code, flags=re.S | re.M).strip() == '', \
            'unsupported text outside modules'
        used = {m[1] for body in self.modules.values() for m in re.finditer(r'^\s*(\w+) \w+(?: \[\d+:\d+\])? \(\);',
                                                                             body, re.M)}
        tops = [name for name in self.modules if name not in used]
        assert len(tops) == 1, ('one top module', tops)
        self.roots, self.processes = {}, []
        self.elaborate(tops[0], tops[0], None)

    def elaborate(self, module, name, parent):
        scope = Scope(name, 'instance', parent, module)
        if parent is None: self.roots[name] = scope
        s = Stream(lex(self.modules[module]))
        self.items(s, scope, None)
        return scope

    def items(self, s, scope, end):
        while s.peek() != end:
            item = s.take()
            if item == 'event':
                scope.children[s.take()] = Event()
                s.take(';')
            elif item == 'logic':
                for part in ('[', '7', ':', '0', ']'): s.take(part)
                name = s.take()
                s.take('=')
                scope.children[name] = Variable(number(s.take(), {}))
                s.take(';')
            elif item == 'task':
                task = Scope(s.take(), 'task', scope)
                task.argument = None
                if s.peek() == '(':
                    for part in ('(', 'input', 'logic', '[', '7', ':', '0', ']'): s.take(part)
                    task.argument = s.take()
                    s.take(')')
                    task.children[task.argument] = Variable(0)
                s.take(';')
                task.body = []
                while s.peek() != 'endtask': task.body.append(statement(s))
                s.take('endtask')
                for inner in task.body: declare(inner, task)
            elif item == 'initial':
                body = statement(s)
                declare(body, scope)
                self.processes.append((Process(body), scope))
            elif item == 'for':
                for part in ('(', 'genvar'): s.take(part)
                variable = s.take()
                s.take('=')
                first = int(s.take())
                for part in (';', variable, '<'): s.take(part)
                last = int(s.take())
                for part in (';', variable, '++', ')', 'begin', ':'): s.take(part)
                name, start = s.take(), s.at
                for index in range(first, last):
                    s.at = start
                    self.items(s, Scope(f'{name}[{index}]', 'generate', scope), 'end')
                s.take('end')
            elif item in self.modules:
                name = s.take()
                if s.peek() == '[':
                    s.take('[')
                    first = int(s.take())
                    s.take(':')
                    last = int(s.take())
                    s.take(']')
                    for index in range(first, last + 1): self.elaborate(item, f'{name}[{index}]', scope)
                else:
                    self.elaborate(item, name, scope)
                for part in ('(', ')', ';'): s.take(part)
            else:
                raise AssertionError(('unsupported item', item))

    def resolve(self, name, context):
        parts = re.findall(r'\$root|\w+(?:\[\d+\])?', name)
        if parts[0] == '$root': return self.down(self.roots[parts[1]], parts[2:])
        scope = context
        while True:
            if parts[0] in scope.children: return self.down(scope.children[parts[0]], parts[1:])
            if scope.kind == 'instance': break
            scope = scope.parent
        # Upward: the scopes that hold the instantiation, and the module names of the instances above.
        while scope is not None:
            if scope.module == parts[0] and len(parts) > 1: return self.down(scope, parts[1:])
            outer = scope.parent
            while outer is not None:
                if parts[0] in outer.children: return self.down(outer.children[parts[0]], parts[1:])
                if outer.kind == 'instance': break
                outer = outer.parent
            if outer is None: break
            scope = outer
        if parts[0] in self.roots: return self.down(self.roots[parts[0]], parts[1:])
        raise KeyError(('unresolved name', name))

    def down(self, item, parts):
        for part in parts: item = item.children[part]
        return item


class Simulation:
    def __init__(self, source, order):
        self.design = Design(source)
        self.output, self.now, self.nba, self.finished = [], 0, [], False
        self.active = []
        self.timed = {}
        processes = [self.design.processes[i] for i in order]
        for process, scope in processes: self.start(process, process.body, scope)

    def start(self, process, body, scope):
        process.generator = self.execute(process, body, scope)
        self.active.append(process)

    def execute(self, process, item, scope, frame=None):
        kind = item[0]
        if kind == 'block':
            if item[1] is None:
                for inner in item[2]: yield from self.execute(process, inner, scope, frame)
                return
            block = scope.children[item[1]]
            process.blocks.append(block)
            try:
                for inner in item[2]: yield from self.execute(process, inner, block, frame)
            except Disabled as disabled:
                if disabled.block is not block: raise
            finally:
                process.blocks.remove(block)
        elif kind == 'fork':
            for inner in item[1]:
                child = Process(inner)
                child.generator = self.execute(child, inner, scope, frame)
                self.active.append(child)
        elif kind == 'delay':
            yield ('delay', item[1])
            if item[2]: yield from self.execute(process, item[2], scope, frame)
        elif kind == 'edge':
            target = self.design.resolve(item[1], scope)
            yield ('wait', target, None)
            yield from self.execute(process, item[2], scope, frame)
        elif kind == 'level':
            target = self.design.resolve(item[1], scope)
            wanted = number(item[2], {})
            while target.value != wanted: yield ('wait', target, None)
            yield from self.execute(process, item[3], scope, frame)
        elif kind == 'disable':
            self.disable(self.design.resolve(item[1], scope))
        elif kind == 'trigger':
            self.wake(self.design.resolve(item[1], scope))
        elif kind == 'write':
            self.write(self.design.resolve(item[1], scope), number(item[2], frame or {}))
        elif kind == 'nba':
            self.nba.append((self.design.resolve(item[1], scope), number(item[2], frame or {})))
        elif kind == 'call':
            task = self.design.resolve(item[1], scope)
            assert task.kind == 'task', ('not a task', item[1])
            if task.argument: task.children[task.argument].value = number(item[2], frame or {})
            else: assert item[2] is None
            values = {task.argument: task.children[task.argument].value} if task.argument else {}
            for inner in task.body: yield from self.execute(process, inner, task, values)
        elif kind == 'display':
            values = []
            for argument in item[2]:
                if argument == '$time': values.append(self.now)
                else: values.append(self.design.resolve(argument, scope).value)
            text = item[1]
            assert len(re.findall('%0[td]', text)) == len(values), 'arguments'
            self.output.append(re.sub('%0[td]', lambda _: str(values.pop(0)), text))
        elif kind == 'finish':
            self.finished = True
            yield ('finish',)
        else:
            raise AssertionError(('unknown statement', kind))

    def write(self, variable, value):
        if variable.value != value:
            variable.value = value
            self.wake(variable)

    def wake(self, target):
        waiters, target.waiters = target.waiters, []
        self.active += waiters

    def disable(self, block):
        assert isinstance(block, Scope) and block.kind == 'block', 'disable needs a named block'
        for waiting in [target for target in self.waiting_lists()]:
            for process in list(waiting):
                if block in process.blocks:
                    waiting.remove(process)
                    process.pending = Disabled(block)
                    self.active.append(process)

    def waiting_lists(self):
        lists = [items for items in self.timed.values()]
        seen = []

        def walk(scope):
            for child in scope.children.values():
                if isinstance(child, (Variable, Event)): seen.append(child.waiters)
                elif isinstance(child, Scope): walk(child)
        for root in self.design.roots.values(): walk(root)
        return lists + seen

    def step(self, process):
        pending, process.pending = process.pending, None
        try:
            request = process.generator.throw(pending) if pending else next(process.generator)
        except StopIteration:
            return
        if request[0] == 'delay': self.timed.setdefault(self.now + request[1], []).append(process)
        elif request[0] == 'wait': request[1].waiters.append(process)

    def run(self):
        while not self.finished:
            while (self.active or self.nba) and not self.finished:
                if self.active:
                    self.step(self.active.pop(0))
                    continue
                updates, self.nba = self.nba, []
                for variable, value in updates: self.write(variable, value)
            if self.finished or not self.timed: break
            self.now = min(self.timed)
            self.active = self.timed.pop(self.now)
        return ''.join(line + '\n' for line in self.output)


def interpret(source):
    count = len(Design(source).processes)
    results = {Simulation(source, order).run() for order in permutations(range(count))}
    assert len(results) == 1, ('depends on the order of processes', results)
    return results.pop()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'disable_up': anchor(('disable', 'up', 'waiting', 'task')),
                'trigger_sibling': anchor(('trigger', 'sibling', 'waiting', 'fork')),
                'level_generate': anchor(('level', 'generate', 'late', 'initial')),
                'nba_array': anchor(('nba', 'array', 'waiting', 'initial')),
                'call_nested': anchor(('call', 'nested', 'waiting', 'fork')),
                'disable_root_late': anchor(('disable', 'root', 'late', 'initial')),
                'write_down_late': anchor(('write', 'down', 'late', 'task'))}
    up = generator.case_name(('disable', 'up', 'waiting', 'task'))
    faults = (
        ('disable_whole_process', 'disable_up', [(f'disable {up}.run.blk;', f'disable {up}.run;')]),
        ('target_waits_late', 'trigger_sibling', [('  initial begin : run\n    #1;', '  initial begin : run\n    #3;')]),
        ('edge_instead_of_level', 'level_generate', [("wait (x == 8'd5)", '@(x)')]),
        ('blocking_instead_of_nba', 'nba_array', [("u[1].x <= 8'd5;", "u[1].x = 8'd5;")]),
        ('longer_task_delay', 'call_nested', [('#1 x = k;', '#2 x = k;')]),
        ('target_runs_early', 'disable_root_late', [('  initial begin : run\n    #4;', '  initial begin : run\n    #1;')]),
        ('action_after_start', 'write_down_late', [('    #2;\n    act;', '    #5;\n    act;')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_hierproc.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_hierproc.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent elaboration, hierarchical name resolution and scheduling of actual programs in every '
            'order of the processes. Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
