#!/usr/bin/env python3
"""Interpret actual interface member programs independently.

The program is tokenized and parsed: the interface becomes storage with the
declared width and sign of each member, a modport becomes the directions and
imports a port may use, and a port, a generic port, an array element or a
hierarchical name resolves to one instance. Each expression is sized by the
rules of 11.6 and 11.8: the self-determined width and sign of every operand,
then the context of the assignment or of the comparison pushed down, then
the value at that width. Statements run in time order, one process at a time.
"""

from itertools import permutations
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_ifexpr as generator

TOKEN = re.compile(r"\s*(?:(\d+'s?[bdh][0-9a-fA-F_]+)|(\d+)|(\$?[A-Za-z_]\w*)|(\"[^\"]*\")"
                   r"|(>>>|<=|>=|\+\+|--|\+=|'\{|[-+*/<>=()\[\]{};:,.#]))")


def lex(text):
    out, at = [], 0
    while at < len(text.rstrip()):
        found = TOKEN.match(text, at)
        assert found and found.end() > at, ('cannot read', text[at:at + 30])
        out.append(found[found.lastindex])
        at = found.end()
    return out


def literal(token):
    based = re.fullmatch(r"(\d+)'(s?)([bdh])([0-9a-fA-F_]+)", token)
    if based:
        width = int(based[1])
        number = int(based[4].replace('_', ''), {'b': 2, 'd': 10, 'h': 16}[based[3]]) % (1 << width)
        return width, bool(based[2]), number
    return 32, True, int(token)


class Var:
    def __init__(self, width, signed, value, size=None):
        self.width, self.signed, self.size = width, signed, size
        self.value = value


class Parser:
    def __init__(self, items):
        self.items, self.at = items, 0

    def peek(self, offset=0):
        return self.items[self.at + offset] if self.at + offset < len(self.items) else None

    def take(self, expected=None):
        item = self.items[self.at]
        assert expected is None or item == expected, ('expected', expected, 'found', item, self.items[self.at:self.at + 8])
        self.at += 1
        return item

    # Expressions, lowest precedence first.

    def expression(self): return self.relation()

    def relation(self):
        left = self.shift()
        while self.peek() in ('<', '>', '<=', '>='):
            op = self.take()
            left = ('rel', op, left, self.shift())
        return left

    def shift(self):
        left = self.additive()
        while self.peek() == '>>>':
            self.take()
            left = ('ashr', left, self.additive())
        return left

    def additive(self):
        left = self.multiplicative()
        while self.peek() in ('+', '-'):
            op = self.take()
            left = ('arith', op, left, self.multiplicative())
        return left

    def multiplicative(self):
        left = self.unary()
        while self.peek() in ('*', '/'):
            op = self.take()
            left = ('arith', op, left, self.unary())
        return left

    def unary(self):
        if self.peek() == '-':
            self.take()
            return ('neg', self.unary())
        return self.primary()

    def primary(self):
        item = self.take()
        if item == '(':
            inner = self.expression()
            self.take(')')
            return inner
        if re.fullmatch(r"\d+('s?[bdh][0-9a-fA-F_]+)?", item): return ('lit',) + literal(item)
        return self.name(item)

    def name(self, first):
        chain = [first]
        if self.peek() == '[' and self.peek(2) == ']' and self.peek(3) == '.':
            self.take('[')
            chain[0] += '[' + self.take() + ']'
            self.take(']')
        while self.peek() == '.':
            self.take()
            chain.append(self.take())
        node = ('ref', tuple(chain))
        if self.peek() == '[':
            self.take()
            index = self.expression()
            if self.peek() == ':':
                self.take()
                low = self.expression()
                self.take(']')
                return ('part', node, index, low)
            self.take(']')
            return ('elem', node, index)
        return node

    # Statements.

    def statement(self):
        item = self.peek()
        if item == 'begin':
            self.take()
            body = []
            while self.peek() != 'end': body.append(self.statement())
            self.take('end')
            return ('block', body)
        if item == '#':
            self.take()
            delay = int(self.take())
            self.take(';')
            return ('delay', delay)
        if item == 'if':
            self.take()
            self.take('(')
            condition = self.expression()
            self.take(')')
            then = self.statement()
            other = None
            if self.peek() == 'else':
                self.take()
                other = self.statement()
            return ('if', condition, then, other)
        if item == 'case':
            self.take()
            self.take('(')
            selector = self.expression()
            self.take(')')
            items = []
            while self.peek() != 'endcase':
                label = None if self.peek() == 'default' else self.expression()
                if label is None: self.take('default')
                self.take(':')
                items.append((label, self.statement()))
            self.take('endcase')
            return ('case', selector, items)
        if item in ('repeat', 'while'):
            self.take()
            self.take('(')
            condition = self.expression()
            self.take(')')
            return (item, condition, self.statement())
        if item == 'do':
            self.take()
            body = self.statement()
            self.take('while')
            self.take('(')
            condition = self.expression()
            self.take(')')
            self.take(';')
            return ('do', body, condition)
        if item == 'for':
            self.take()
            self.take('(')
            self.take('int')
            variable = self.take()
            self.take('=')
            start = self.expression()
            self.take(';')
            condition = self.expression()
            self.take(';')
            assert self.take() == variable and self.take() == '++', 'unsupported step'
            self.take(')')
            return ('for', variable, start, condition, self.statement())
        if item == 'foreach':
            self.take()
            self.take('(')
            array = self.name(self.take())
            assert array[0] == 'elem' and array[2][0] == 'ref', 'unsupported foreach'
            self.take(')')
            return ('foreach', array[1], array[2][1][0], self.statement())
        if item.startswith('$'):
            self.take()
            arguments = []
            if self.peek() == '(':
                self.take()
                arguments = [self.take()]
                while self.peek() == ',':
                    self.take()
                    arguments.append(self.expression())
                self.take(')')
            self.take(';')
            return ('task', item, arguments)
        target = self.name(self.take())
        if self.peek() == '(':
            self.take()
            arguments = [] if self.peek() == ')' else [self.expression()]
            self.take(')')
            self.take(';')
            return ('call', target, arguments)
        op = self.take()
        if op == '--':
            self.take(';')
            return ('assign', target, ('arith', '-', target, ('lit', 32, True, 1)))
        right = self.expression()
        self.take(';')
        if op == '+=': return ('assign', target, ('arith', '+', target, right))
        assert op == '=', ('unsupported operator', op)
        return ('assign', target, right)


class Scope:
    """Names a statement can use: instances by name, a port, interface members and locals."""

    def __init__(self, instances=None, port=None, members=None, local=None):
        self.instances, self.port, self.members = instances or {}, port, members
        self.local = local or {}

    def resolve(self, chain, write=False):
        head, rest = chain[0], chain[1:]
        if not rest:
            if head in self.local: return self.local[head]
            assert self.members is not None and head in self.members.vars, ('unknown name', head)
            return self.members.vars[head]
        if self.port and head == self.port[0]:
            instance, modport = self.port[1], self.port[2]
            if modport is not None:
                direction = instance.modports[modport].get(rest[0])
                assert direction is not None, ('not in the modport', rest[0])
                assert not write or direction == 'ref', ('written through an input', rest[0])
        else:
            assert head in self.instances, ('unknown instance', head)
            instance = self.instances[head]
        assert len(rest) == 1, 'nested name'
        if rest[0] in instance.tasks: return (instance, rest[0])
        return instance.vars[rest[0]]


class Instance:
    def __init__(self, decl):
        self.vars, self.modports, self.tasks = {}, {}, {}
        for item in decl['vars']:
            self.vars[item[0]] = Var(*item[1:])
        self.modports = decl['modports']
        self.tasks = decl['tasks']


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        units = re.findall(r'(interface|module) (\w+)(\(.*?\))?;(.*?)end(?:interface|module)', code, re.S)
        assert units, 'unsupported program'
        self.interfaces, self.modules = {}, {}
        for kind, name, ports, body in units:
            if kind == 'interface': self.interfaces[name] = self.interface(body)
            else: self.modules[name] = (ports.strip('()') if ports else None, body)

    def interface(self, body):
        decl = {'vars': [], 'modports': {}, 'tasks': {}}
        for task in re.finditer(r'task automatic (\w+)\((.*?)\);(.*?)endtask', body, re.S):
            formal = re.fullmatch(r'input logic signed \[(\d+):0\] (\w+)', task[2]) if task[2] else None
            assert formal or not task[2], ('unsupported formal', task[2])
            parser = Parser(lex(task[3]))
            statements = []
            while parser.peek() is not None: statements.append(parser.statement())
            decl['tasks'][task[1]] = ((formal[2], int(formal[1]) + 1) if formal else None, statements)
        body = re.sub(r'task automatic .*?endtask', '', body, flags=re.S)
        for item in (part.strip() for part in body.split(';') if part.strip()):
            variable = re.fullmatch(r"logic( signed)? \[(\d+):0\] (\w+)( \[(\d+)\])? = (.*)", item)
            modport = re.fullmatch(r'modport (\w+) \((.*)\)', item)
            if variable:
                width, signed, size = int(variable[2]) + 1, bool(variable[1]), variable[5]
                if size:
                    values = [literal(v.strip())[2] for v in re.fullmatch(r"'\{(.*)\}", variable[6])[1].split(',')]
                    assert len(values) == int(size), 'array size'
                    decl['vars'].append((variable[3], width, signed, values, int(size)))
                else:
                    decl['vars'].append((variable[3], width, signed, literal(variable[6])[2]))
            elif modport:
                directions = {}
                for entry in modport[2].split(','):
                    direction, member = entry.split()
                    directions[member] = direction
                decl['modports'][modport[1]] = directions
            else:
                raise AssertionError(('unsupported interface item', item))
        return decl

    # Sizing (11.6) and typing (11.8), then the value at the context width.

    def self_type(self, node, scope):
        kind = node[0]
        if kind == 'lit': return node[1], node[2]
        if kind == 'ref':
            var = scope.resolve(node[1])
            assert var.size is None, 'an array as a value'
            return var.width, var.signed
        if kind == 'elem':
            var = scope.resolve(node[1][1])
            return var.width, var.signed
        if kind == 'part':
            return self.constant(node[2]) - self.constant(node[3]) + 1, False
        if kind == 'neg': return self.self_type(node[1], scope)
        if kind == 'ashr': return self.self_type(node[1], scope)
        if kind == 'rel': return 1, False
        (lw, ls), (rw, rs) = self.self_type(node[2], scope), self.self_type(node[3], scope)
        return max(lw, rw), ls and rs

    @staticmethod
    def constant(node):
        assert node[0] == 'lit', 'a variable bound'
        return node[3]

    def evaluate(self, node, scope, width, signed):
        """The value of node as an unsigned number of width bits, in a context of that width and sign."""
        mask = (1 << width) - 1

        def extend(bits, own_width):
            # Sign extension only for a signed operand in a signed context.
            if signed and bits >> own_width - 1 & 1: bits |= mask ^ ((1 << own_width) - 1)
            return bits & mask

        def number(bits):
            return bits - (1 << width) if signed and bits >> width - 1 else bits
        kind = node[0]
        if kind == 'lit':
            return extend(node[3], node[1])
        if kind == 'ref':
            var = scope.resolve(node[1])
            return extend(var.value, var.width)
        if kind == 'elem':
            var = scope.resolve(node[1][1])
            index = self.value(node[2], scope)
            return extend(var.value[index], var.width)
        if kind == 'part':
            var = scope.resolve(node[1][1])
            high, low = self.constant(node[2]), self.constant(node[3])
            return (var.value >> low) & ((1 << high - low + 1) - 1)   # unsigned: zero-extended
        if kind == 'neg':
            return -self.evaluate(node[1], scope, width, signed) & mask
        if kind == 'ashr':
            left = self.evaluate(node[1], scope, width, signed)
            amount = self.value(node[2], scope)
            return (number(left) >> amount) & mask
        if kind == 'rel':
            (lw, ls), (rw, rs) = self.self_type(node[2], scope), self.self_type(node[3], scope)
            inner_width, inner_signed = max(lw, rw), ls and rs
            left = self.evaluate(node[2], scope, inner_width, inner_signed)
            right = self.evaluate(node[3], scope, inner_width, inner_signed)
            if inner_signed:
                left -= (left >> inner_width - 1) << inner_width
                right -= (right >> inner_width - 1) << inner_width
            result = {'<': left < right, '>': left > right, '<=': left <= right, '>=': left >= right}[node[1]]
            return int(result)
        left = self.evaluate(node[2], scope, width, signed)
        right = self.evaluate(node[3], scope, width, signed)
        op = node[1]
        if op == '+': return (left + right) & mask
        if op == '-': return (left - right) & mask
        if op == '*': return (number(left) * number(right)) & mask
        a, b = number(left), number(right)
        quotient = abs(a) // abs(b)
        return (quotient if (a < 0) == (b < 0) else -quotient) & mask

    def value(self, node, scope):
        """A self-determined value as a Python number with its sign."""
        width, signed = self.self_type(node, scope)
        bits = self.evaluate(node, scope, width, signed)
        return bits - (1 << width) if signed and bits >> width - 1 else bits

    def store(self, target, right, scope):
        """An assignment: the context is the wider of the target and the right side, the sign the right side's."""
        if target[0] == 'ref': var = scope.resolve(target[1], write=True)
        else: raise AssertionError('unsupported target')
        width, signed = self.self_type(right, scope)
        context = max(width, var.width)
        var.value = self.evaluate(right, scope, context, signed) & ((1 << var.width) - 1)

    def execute(self, node, scope):
        kind = node[0]
        if kind == 'block':
            for item in node[1]: yield from self.execute(item, scope)
        elif kind == 'delay':
            yield node[1]
        elif kind == 'assign':
            self.store(node[1], node[2], scope)
        elif kind == 'call':
            instance, name = scope.resolve(node[1][1])
            if scope.port and node[1][1][0] == scope.port[0] and scope.port[2] is not None:
                assert scope.port[1].modports[scope.port[2]].get(name) == 'import', ('not imported', name)
            formal, statements = instance.tasks[name]
            local = {}
            if formal:
                # The actual is assigned to the formal, in the caller's scope.
                assert len(node[2]) == 1, 'arguments'
                width, signed = self.self_type(node[2][0], scope)
                bits = self.evaluate(node[2][0], scope, max(width, formal[1]), signed)
                local[formal[0]] = Var(formal[1], True, bits & ((1 << formal[1]) - 1))
            else:
                assert not node[2], 'arguments'
            task_scope = Scope(members=instance, local=local)
            for item in statements: yield from self.execute(item, task_scope)
        elif kind == 'if':
            if self.value(node[1], scope): yield from self.execute(node[2], scope)
            elif node[3]: yield from self.execute(node[3], scope)
        elif kind == 'case':
            selector = node[1]
            for label, body in node[2]:
                if label is None or self.equal(selector, label, scope):
                    yield from self.execute(body, scope)
                    break
        elif kind == 'repeat':
            for _ in range(self.value(node[1], scope)): yield from self.execute(node[2], scope)
        elif kind == 'while':
            while self.value(node[1], scope): yield from self.execute(node[2], scope)
        elif kind == 'do':
            yield from self.execute(node[1], scope)
            while self.value(node[2], scope): yield from self.execute(node[1], scope)
        elif kind == 'for':
            variable = Var(32, True, self.value(node[2], scope) & 0xffffffff)
            inner = Scope(scope.instances, scope.port, scope.members, {**scope.local, node[1]: variable})
            while self.value(node[3], inner):
                yield from self.execute(node[4], inner)
                variable.value = (variable.value + 1) & 0xffffffff
        elif kind == 'foreach':
            array = scope.resolve(node[1][1])
            for index in range(array.size):
                inner = Scope(scope.instances, scope.port, scope.members,
                              {**scope.local, node[2]: Var(32, True, index)})
                yield from self.execute(node[3], inner)
        elif kind == 'task':
            name, arguments = node[1], node[2]
            if name == '$finish':
                yield 'finish'
                return
            assert name == '$display', ('unsupported task', name)
            text = arguments[0][1:-1]
            values = [str(self.value(argument, scope)) for argument in arguments[1:]]
            assert text.count('%0d') == len(values), 'arguments'
            self.output.append((self.now, re.sub('%0d', lambda _: values.pop(0), text)))
        else:
            raise AssertionError(('unknown statement', kind))

    def equal(self, left, right, scope):
        (lw, ls), (rw, rs) = self.self_type(left, scope), self.self_type(right, scope)
        width, signed = max(lw, rw), ls and rs
        return self.evaluate(left, scope, width, signed) == self.evaluate(right, scope, width, signed)

    def processes(self, name, port_binding, instances):
        """The initial blocks of a module, each a generator, with its scope."""
        ports, body = self.modules[name]
        out = []
        local_instances = dict(instances)
        for item in re.finditer(r'(\w+) (\w+)(\[(\d+)\])? \(\);', body):
            interface = self.interfaces[item[1]]
            if item[3]:
                for index in range(int(item[4])):
                    local_instances[f'{item[2]}[{index}]'] = Instance(interface)
            else:
                local_instances[item[2]] = Instance(interface)
        scope = Scope(local_instances, port_binding)
        for child in re.finditer(r'(\w+) (\w+) \(([\w\[\].]+)\);', body):
            if child[1] not in self.modules: continue
            connection = child[3].split('.')
            instance = local_instances[connection[0]]
            given = connection[1] if len(connection) > 1 else None
            header = self.modules[child[1]][0]
            declared = re.fullmatch(r'(\w+)(?:\.(\w+))? (\w+)', header)
            assert declared, ('unsupported port', header)
            if declared[1] != 'interface':
                assert declared[1] in self.interfaces and self.interfaces[declared[1]] is not None, 'port type'
            modport = declared[2] or given
            assert not (declared[2] and given and declared[2] != given), 'two modports'
            out += self.processes(child[1], (declared[3], instance, modport), {})
        for initial in re.finditer(r'initial begin(.*?)\n  end\n', body + '\n', re.S):
            parser = Parser(lex(initial[1]))
            statements = []
            while parser.peek() is not None: statements.append(parser.statement())
            out.append(self.execute(('block', statements), scope))
        return out

    def run(self, order=None):
        tops = [name for name in self.modules if self.modules[name][0] is None]
        assert len(tops) == 1, 'one top'
        self.output, self.now = [], 0
        processes = self.processes(tops[0], None, {})
        self.count = len(processes)
        waiting = {0: [processes[i] for i in (order or range(len(processes)))]}
        finished = False
        while waiting and not finished:
            self.now = min(waiting)
            ready = waiting.pop(self.now)
            while ready:
                current = ready.pop(0)
                step = next(current, None)
                if step == 'finish':
                    finished = True
                    break
                if step is not None:
                    assert step > 0, 'no zero delay here'
                    waiting.setdefault(self.now + step, []).append(current)
        return ''.join(line + '\n' for _, line in self.output)


def interpret(source):
    """The output, which must be the same in every order of the processes of a slot."""
    first = Program(source)
    results = {first.run()}
    for order in permutations(range(first.count)):
        results.add(Program(source).run(order))
    assert len(results) == 1, ('depends on the order of processes', results)
    return results.pop()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'modport_mul_task': anchor(('modport', 'u8', 'mul', 'repeat', 'task')),
                'generic_mixed_inside': anchor(('generic', 's4', 'mixed', 'foreach', 'inside')),
                'element_shift': anchor(('element', 's8', 'shift', 'while', 'compound')),
                'hier_neg_if': anchor(('hier', 'u8', 'neg', 'if', 'direct')),
                'port_part_task': anchor(('port', 's4', 'part', 'do', 'task')),
                'modport_cmp_case': anchor(('modport', 's8', 'cmp', 'case', 'inside')),
                'generic_div_for': anchor(('generic', 'u8', 'div', 'for', 'direct'))}
    faults = (
        ('signed_member', 'modport_mul_task', [("logic [7:0] v = 8'hfa;", "logic signed [7:0] v = 8'shfa;")]),
        ('wide_member', 'generic_mixed_inside', [("logic signed [3:0] v = 4'sha;", "logic signed [7:0] v = 8'shfa;")]),
        ('other_element', 'element_shift', [('member_user u (ia[1]);', 'member_user u (ia[0]);')]),
        ('other_bound', 'hier_neg_if', [('if (i0.v < 0)', 'if (i0.v > 8)')]),
        ('upper_part', 'port_part_task', [('p.step(p.v[3:0]);', 'p.step(p.v[3:1]);')]),
        ('other_label', 'modport_cmp_case', [("8'd3:", "8'd2:")]),
        ('repeat_count', 'generic_div_for', [('for (int i = 0; i < p.n; i++)', 'repeat (p.n)')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_ifexpr.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_ifexpr.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent sizing, typing and storage of actual interface programs, from the tokens of each '
            'statement. Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
