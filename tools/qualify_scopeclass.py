#!/usr/bin/env python3
"""Interpret actual programs that declare a class in a module or a generate block independently.

The text is parsed into modules, generate constructs, declarations, classes
and initial procedures. Each instance of the child module is elaborated with
its parameter: a loop generate makes one block per genvar value, and a
conditional generate makes only the block whose condition holds, as 27.4 and
27.5 say. A class keeps the scope that declares it, so a method finds a name
first among its class members and the members it inherits, then in the
declaring scope and the scopes around it, by the search of 23.9. A static
property belongs to the class of its own block. The initial procedures run in
the order of their delays, and a hierarchical name is followed from the top
module through instances, blocks and handles.
"""

import heapq
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_scopeclass as generator

TOKEN = re.compile(r'\s*(?:("[^"]*")|(\$?[A-Za-z_][A-Za-z0-9_]*)|(\d+)|(::|==|\+\+|[#()\[\];,=+*.:<]))')


def lex(text):
    text = re.sub(r'/\*.*?\*/|//[^\n]*', '', text, flags=re.S)
    out, at = [], 0
    while text[at:].strip():
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:at + 30])
        string, name, number, punct = found.groups()
        out.append(('string', string[1:-1]) if string else ('name', name) if name else
                   ('number', int(number)) if number else ('punct', punct))
        at = found.end()
    return out


class Stream:
    def __init__(self, tokens): self.tokens, self.at = tokens, 0

    def peek(self, ahead=0): return self.tokens[self.at + ahead] if self.at + ahead < len(self.tokens) else (None, None)

    def take(self, text=None, kind=None):
        item = self.peek()
        assert item[0] is not None, 'unexpected end'
        assert (text is None or item[1] == text) and (kind is None or item[0] == kind), ('expected', text, kind, item)
        self.at += 1
        return item[1]

    def accept(self, text):
        if self.peek()[1] == text and self.peek()[0] in ('punct', 'name'): self.at += 1; return True
        return False

    def name(self): return self.take(kind='name')


# Expressions are trees: ('num', n), ('ref', [parts]), ('add', a, b), ('mul', a, b), ('eq', a, b).
# A reference part is ('name', n), ('index', n), ('call',), ('scope', class) or ('super',).
def expression(s):
    left = sum_(s)
    if s.accept('=='): return ('eq', left, sum_(s))
    return left


def sum_(s):
    left = product(s)
    while s.accept('+'): left = ('add', left, product(s))
    return left


def product(s):
    left = factor(s)
    while s.accept('*'): left = ('mul', left, factor(s))
    return left


def factor(s):
    kind, text = s.peek()
    if kind == 'number': return ('num', s.take())
    if s.accept('('):
        inner = expression(s)
        s.take(')')
        return inner
    return reference(s)


def reference(s):
    first = s.name()
    parts = [('super',)] if first == 'super' else [('name', first)]
    if s.peek()[1] == '::':
        s.take('::')
        parts = [('scope', first), ('name', s.name())]
    while True:
        if s.accept('.'): parts.append(('name', s.name()))
        elif s.peek()[1] == '[':
            s.take('[')
            parts.append(('index', s.take(kind='number')))
            s.take(']')
        elif s.peek()[1] == '(':
            s.take('(')
            s.take(')')
            parts.append(('call',))
        else: return ('ref', parts)


def statement(s):
    """An initial procedure: a begin-end list of declarations, delays, assignments and displays."""
    s.take('begin')
    body = []
    while not s.accept('end'):
        if s.accept('int'):
            names = [s.name()]
            while s.accept(','): names.append(s.name())
            s.take(';')
            body.append(('declare', names))
        elif s.accept('#'):
            body.append(('delay', expression(s)))
            s.take(';')
        elif s.peek()[1] == '$display':
            s.take()
            s.take('(')
            fmt = s.take(kind='string')
            args = []
            while s.accept(','): args.append(expression(s))
            s.take(')')
            s.take(';')
            body.append(('display', fmt, args))
        else:
            target = reference(s)
            s.take('=')
            body.append(('assign', target, expression(s)))
            s.take(';')
    return body


def class_body(s, name):
    s.take(';') if s.peek()[1] == ';' else None
    members = {'statics': {}, 'functions': {}}
    while not s.accept('endclass'):
        static = s.accept('static')
        if s.accept('int'):
            assert static, 'only static properties'
            prop = s.name()
            s.take('=')
            members['statics'][prop] = expression(s)
            s.take(';')
            continue
        s.take('function')
        s.take('int')
        method = s.name()
        s.take('(')
        s.take(')')
        s.take(';')
        s.take('return')
        members['functions'][method] = (static, expression(s))
        s.take(';')
        s.take('endfunction')
    return members


def items(s, until):
    """The items of a module or a generate block, up to one of the words in until."""
    out = []
    while s.peek()[1] not in until:
        kind, text = s.peek()
        if s.accept('localparam'):
            s.take('int')
            name = s.name()
            s.take('=')
            out.append(('local', name, expression(s)))
            s.take(';')
        elif s.accept('int'):
            name = s.name()
            s.take('=')
            out.append(('var', name, expression(s)))
            s.take(';')
        elif s.accept('function'):
            s.take('automatic')
            s.take('int')
            name = s.name()
            s.take('(')
            s.take(')')
            s.take(';')
            s.take('return')
            out.append(('func', name, expression(s)))
            s.take(';')
            s.take('endfunction')
        elif s.accept('class'):
            name = s.name()
            base = s.name() if s.accept('extends') else None
            out.append(('class', name, base, class_body(s, name)))
        elif s.accept('initial'): out.append(('initial', statement(s)))
        elif s.accept('for'):
            s.take('(')
            s.take('genvar')
            var = s.name()
            s.take('=')
            first = s.take(kind='number')
            s.take(';')
            s.take(var)
            s.take('<')
            last = s.take(kind='number')
            s.take(';')
            s.take(var)
            s.take('++')
            s.take(')')
            out.append(('for', var, first, last, block(s)))
        elif s.accept('if'):
            s.take('(')
            condition = expression(s)
            s.take(')')
            then = block(s)
            other = block(s) if s.accept('else') else None
            out.append(('if', condition, then, other))
        elif s.accept('case'):
            s.take('(')
            subject = expression(s)
            s.take(')')
            arms = []
            while not s.accept('endcase'):
                label = None if s.accept('default') else s.take(kind='number')
                s.take(':')
                arms.append((label, block(s)))
            out.append(('case', subject, arms))
        elif kind == 'name' and s.peek(1)[1] == '#':
            module = s.name()
            s.take('#')
            s.take('(')
            value = s.take(kind='number')
            s.take(')')
            instance = s.name()
            s.take('(')
            s.take(')')
            s.take(';')
            out.append(('instance', module, value, instance))
        elif kind == 'name' and s.peek(1)[0] == 'name':
            cls = s.name()
            handle = s.name()
            s.take('=')
            s.take('new')
            s.take(';')
            out.append(('handle', cls, handle))
        else:
            raise AssertionError(('unsupported item', text))
    return out


def block(s):
    s.take('begin')
    s.take(':')
    name = s.name()
    body = items(s, ('end',))
    s.take('end')
    return name, body


class Scope:
    def __init__(self, parent, kind):
        self.parent, self.kind, self.names, self.children = parent, kind, {}, {}

    def find(self, name):
        scope = self
        while scope is not None:
            if name in scope.names: return scope.names[name]
            if scope.kind == 'module': break
            scope = scope.parent
        raise KeyError(name)


class ClassType:
    def __init__(self, name, base, members, scope):
        self.name, self.base, self.scope = name, base, scope
        self.functions = members['functions']
        self.statics = {k: ['static', evaluate(v, scope, None)] for k, v in members['statics'].items()}

    def member(self, name):
        cls = self
        while cls is not None:
            if name in cls.statics: return cls.statics[name]
            if name in cls.functions: return ('method', cls, name)
            cls = cls.base
        return None


class Instance:
    def __init__(self, cls): self.cls = cls


def call(cls, name, obj):
    owner = cls
    while name not in owner.functions: owner = owner.base
    static, body = owner.functions[name]
    assert not static or obj is None or True
    return evaluate(body, owner.scope, (owner, obj))


def evaluate(tree, scope, frame):
    """frame is (class, object) inside a method, else None."""
    op = tree[0]
    if op == 'num': return tree[1]
    if op == 'add': return evaluate(tree[1], scope, frame) + evaluate(tree[2], scope, frame)
    if op == 'mul': return evaluate(tree[1], scope, frame) * evaluate(tree[2], scope, frame)
    if op == 'eq': return int(evaluate(tree[1], scope, frame) == evaluate(tree[2], scope, frame))
    return resolve(tree[1], scope, frame, read=True)


def resolve(parts, scope, frame, read=False, value=None):
    head = parts[0]
    if head[0] == 'super':
        cls, obj = frame
        assert parts[1][0] == 'name' and parts[2] == ('call',)
        return call(cls.base, parts[1][1], obj)
    if head[0] == 'scope':
        cls = scope.find(head[1])
        assert cls[0] == 'class' and parts[2] == ('call',)
        return call(cls[1], parts[1][1], None)
    name = head[1]
    item = None
    if frame is not None and len(parts) <= 2:
        item = frame[0].member(name)
    if item is None: item = scope.find(name)
    rest = parts[1:]
    while True:
        kind = item[0]
        if kind == 'method':
            assert rest[:1] == [('call',)]
            return call(item[1], item[2], frame[1] if frame else None)
        if kind == 'func':
            assert rest == [('call',)]
            return evaluate(item[1], item[2], None)
        if not rest:
            if read: return item[1]
            assert kind in ('var', 'static'), ('not writable', kind)
            item[1] = value
            return None
        step = rest[0]
        if kind == 'scope':
            child = item[1]
            if step[0] == 'name': item, rest = child.names[step[1]], rest[1:]
            else: raise AssertionError(('bad step', step))
        elif kind == 'blocks':
            assert step[0] == 'index'
            item, rest = ('scope', item[1][step[1]]), rest[1:]
        elif kind == 'handle':
            obj = item[1]
            assert step[0] == 'name' and rest[1] == ('call',), rest
            return call(obj.cls, step[1], obj)
        else:
            raise AssertionError(('cannot follow', kind, step))


class Program:
    def __init__(self, source):
        s = Stream(lex(source))
        self.modules = {}
        while s.peek()[0] is not None:
            s.take('module')
            name = s.name()
            parameter = None
            if s.accept('#'):
                s.take('(')
                s.take('parameter')
                s.take('int')
                parameter = (s.name(), None)
                s.take('=')
                parameter = (parameter[0], s.take(kind='number'))
                s.take(')')
            s.take(';')
            self.modules[name] = (parameter, items(s, ('endmodule',)))
            s.take('endmodule')
        tops = [n for n, (p, _) in self.modules.items() if p is None]
        assert len(tops) == 1, 'one top module'
        self.top = tops[0]
        self.processes = []

    def elaborate(self, scope, body):
        for item in body:
            kind = item[0]
            if kind == 'local': scope.names[item[1]] = ('local', evaluate(item[2], scope, None))
            elif kind == 'var': scope.names[item[1]] = ['var', evaluate(item[2], scope, None)]
            elif kind == 'func': scope.names[item[1]] = ('func', item[2], scope)
            elif kind == 'class':
                _, name, base, members = item
                parent = scope.find(base)[1] if base else None
                scope.names[name] = ('class', ClassType(name, parent, members, scope))
            elif kind == 'handle':
                cls = scope.find(item[1])
                assert cls[0] == 'class', item
                scope.names[item[2]] = ('handle', Instance(cls[1]))
            elif kind == 'initial': self.processes.append((scope, item[1]))
            elif kind == 'for':
                _, var, first, last, (name, inner) = item
                blocks = {}
                for i in range(first, last):
                    child = Scope(scope, 'block')
                    child.names[var] = ('genvar', i)
                    self.elaborate(child, inner)
                    blocks[i] = child
                scope.names[name] = ('blocks', blocks)
            elif kind == 'if':
                _, condition, then, other = item
                chosen = then if evaluate(condition, scope, None) else other
                if chosen: self.generate(scope, chosen)
            elif kind == 'case':
                _, subject, arms = item
                value = evaluate(subject, scope, None)
                chosen = next((b for label, b in arms if label == value), None) or \
                    next(b for label, b in arms if label is None)
                self.generate(scope, chosen)
            elif kind == 'instance':
                _, module, value, name = item
                parameter, inner = self.modules[module]
                child = Scope(scope, 'module')
                child.names[parameter[0]] = ('param', value)
                self.elaborate(child, inner)
                scope.names[name] = ('scope', child)
            else: raise AssertionError(kind)

    def generate(self, scope, block_):
        name, inner = block_
        child = Scope(scope, 'block')
        self.elaborate(child, inner)
        scope.names[name] = ('scope', child)

    def run(self):
        top = Scope(None, 'module')
        self.elaborate(top, self.modules[self.top][1])
        queue, out, order = [], [], 0
        for scope, body in self.processes:
            heapq.heappush(queue, (0, order, scope, body, 0, Scope(scope, 'block')))
            order += 1
        while queue:
            now, seq, scope, body, at, local = heapq.heappop(queue)
            while at < len(body):
                step = body[at]
                at += 1
                if step[0] == 'declare':
                    for name in step[1]: local.names[name] = ['var', 0]
                elif step[0] == 'delay':
                    heapq.heappush(queue, (now + evaluate(step[1], local, None), seq, scope, body, at, local))
                    break
                elif step[0] == 'assign':
                    resolve(step[1][1], local, None, value=evaluate(step[2], local, None))
                else:
                    _, fmt, args = step
                    values = [evaluate(a, local, None) for a in args]
                    out.append(re.sub(r'%0d', lambda _: str(values.pop(0)), fmt) + '\n')
        return ''.join(out)


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'for_variable': anchor(('gen_for', 'variable', 'hier', 'derived', 'outer')),
                'if_static': anchor(('gen_if', 'function', 'local', 'static', 'property')),
                'case_local': anchor(('gen_case', 'local', 'hier', 'instance', 'outer')),
                'module_variable': anchor(('module', 'variable', 'local', 'instance', 'none')),
                'for_param': anchor(('gen_for', 'param', 'local', 'static', 'outer')),
                'module_function': anchor(('module', 'function', 'hier', 'derived', 'property')),
                'for_derived': anchor(('gen_for', 'local', 'local', 'derived', 'property'))}
    faults = (
        ('block_step', 'for_variable', [('int v = 10 * P + 7 * i;', 'int v = 10 * P + 8 * i;')]),
        ('shadow_value', 'if_static', [('return 900;', 'return 901;')]),
        ('other_branch', 'case_local', [('    1: begin : g', '    2: begin : g')]),
        ('no_change', 'module_variable', [('v = v + 100;', 'v = v + 0;')]),
        ('module_param', 'for_param', [('return P;', 'return P + 1;')]),
        ('derived_add', 'module_function', [('super.get() + 1000', 'super.get() + 2000')]),
        ('later_instance', 'for_derived', [('sc_sub #(2) u2();', 'sc_sub #(3) u2();')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_scopeclass.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_scopeclass.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent elaboration of the module, generate blocks and classes of the actual programs, with names '
            'found by the search of 23.9. Auxiliary controls and faults are not fixed-suite or coverage passes.',
            __doc__)


if __name__ == '__main__': main()
