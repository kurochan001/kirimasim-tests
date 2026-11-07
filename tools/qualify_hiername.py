#!/usr/bin/env python3
"""Interpret actual %m programs independently.

The modules are elaborated into a tree of instance, generate block,
subroutine and named block scopes. Each generate construct of a scope gets a
number in the order of the text, and an unnamed generate block takes the name
genblk with that number (27.6). A named begin or fork block, a statement label
and the label of a for loop with a declared variable are named scopes (9.3.4,
9.3.5). A subroutine name resolves as 23.6 and 23.8 say. %m prints the names
of the scopes from the top instance to the scope that holds the display.
Initial procedures run first and final procedures at the end; only one
procedure may print.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_hiername as generator

NAME = r"\$root(?:\.\w+(?:\[\d+\])?)+|\w+(?:\[\d+\])?(?:\.\w+(?:\[\d+\])?)*"
TOKEN = re.compile(rf'\s*("(?:[^"\\]|\\.)*"|\$display|\$finish|{NAME}|\d+|\+\+|[<#();:,=\[\]])')


def lex(text):
    out, at = [], 0
    while text[at:].strip():
        found = TOKEN.match(text, at)
        assert found, ('cannot read', text[at:at + 40])
        out.append(found[1])
        at = found.end()
    return out


class Stream:
    def __init__(self, tokens): self.tokens, self.at = tokens, 0

    def peek(self, ahead=0): return self.tokens[self.at + ahead] if self.at + ahead < len(self.tokens) else None

    def take(self, expected=None):
        item = self.peek()
        assert item is not None, 'unexpected end'
        assert expected is None or item == expected, ('expected', expected, item)
        self.at += 1
        return item


class Scope:
    def __init__(self, name, kind, parent, module=None):
        self.name, self.kind, self.parent, self.module = name, kind, parent, module
        self.children = {}
        if parent is not None:
            assert name not in parent.children, ('declared twice', name)
            parent.children[name] = self

    def path(self): return self.name if self.parent is None else self.parent.path() + '.' + self.name


def statement(s, scope):
    """A statement as a tuple; named blocks and labels become scopes now."""
    if s.peek(1) == ':' and s.peek() not in ('begin', 'fork'):
        label = Scope(s.take(), 'label', scope)
        s.take(':')
        return ('scope', label, statement(s, label))
    item = s.peek()
    if item in ('begin', 'fork'):
        s.take()
        inner = scope
        if s.peek() == ':':
            s.take()
            inner = Scope(s.take(), 'block', scope)
        body = []
        end = 'end' if item == 'begin' else 'join'
        while s.peek() != end: body.append(statement(s, inner))
        s.take(end)
        # A fork-join with one statement runs it and waits for it, as a block does.
        return ('scope', inner, ('sequence', body))
    if item == 'for':
        for part in ('for', '(', 'int'): s.take(part)
        variable = s.take()
        s.take('=')
        first = int(s.take())
        for part in (';', variable, '<'): s.take(part)
        last = int(s.take())
        for part in (';', variable, '++', ')'): s.take(part)
        return ('repeat', last - first, statement(s, scope))
    if item == '$display':
        s.take()
        s.take('(')
        text = s.take()
        s.take(')')
        s.take(';')
        assert re.fullmatch(r'"\w+ %m"', text), ('unsupported display', text)
        return ('display', text[1:-1])
    target = s.take()
    if s.peek() == '(':
        s.take('(')
        s.take(')')
    s.take(';')
    return ('call', target)


class Design:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        self.modules = {m[1]: m[2] for m in re.finditer(r'^module (\w+);\n(.*?)^endmodule', code, re.S | re.M)}
        assert re.sub(r'^module \w+;\n.*?^endmodule\s*', '', code, flags=re.S | re.M).strip() == '', \
            'unsupported text outside modules'
        used = {m[1] for body in self.modules.values() for m in re.finditer(r'^\s*(\w+) \w+(?: \[\d+:\d+\])? \(\);',
                                                                             body, re.M)}
        tops = [name for name in self.modules if name not in used]
        assert len(tops) == 1, ('one top module', tops)
        self.roots, self.procedures = {}, []
        self.elaborate(tops[0], tops[0], None)

    def elaborate(self, module, name, parent):
        scope = Scope(name, 'instance', parent, module)
        if parent is None: self.roots[name] = scope
        self.items(Stream(lex(self.modules[module])), scope, None)

    def items(self, s, scope, end):
        constructs = 0
        while s.peek() != end:
            item = s.take()
            if item in ('initial', 'final'):
                if s.peek() == '#':
                    for part in ('#', '1', '$finish', ';'): s.take(part)
                    continue
                self.procedures.append((item, statement(s, scope), scope))
            elif item in ('task', 'function'):
                automatic = s.peek() == 'automatic'
                if automatic: s.take()
                if item == 'function': s.take('void')
                sub = Scope(s.take(), item, scope)
                if item == 'function':
                    s.take('(')
                    s.take(')')
                s.take(';')
                body = []
                while s.peek() != 'end' + item: body.append(statement(s, sub))
                s.take('end' + item)
                sub.body = ('sequence', body)
            elif item == 'logic':
                s.take()
                s.take(';')
            elif item == 'for':
                constructs += 1
                for part in ('(', 'genvar'): s.take(part)
                variable = s.take()
                s.take('=')
                first = int(s.take())
                for part in (';', variable, '<'): s.take(part)
                last = int(s.take())
                for part in (';', variable, '++', ')', 'begin'): s.take(part)
                name = f'genblk{constructs}'
                if s.peek() == ':':
                    s.take(':')
                    name = s.take()
                start = s.at
                for index in range(first, last):
                    s.at = start
                    self.items(s, Scope(f'{name}[{index}]', 'generate', scope), 'end')
                s.take('end')
            elif item == 'if':
                constructs += 1
                for part in ('(', '1', ')', 'begin'): s.take(part)
                name = f'genblk{constructs}'
                if s.peek() == ':':
                    s.take(':')
                    name = s.take()
                self.items(s, Scope(name, 'generate', scope), 'end')
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
        while scope is not None:
            if scope.module == parts[0] and len(parts) > 1: return self.down(scope, parts[1:])
            outer = scope.parent
            while outer is not None:
                if parts[0] in outer.children: return self.down(outer.children[parts[0]], parts[1:])
                if outer.kind == 'instance': break
                outer = outer.parent
            scope = outer
        if parts[0] in self.roots: return self.down(self.roots[parts[0]], parts[1:])
        raise KeyError(('unresolved name', name))

    def down(self, item, parts):
        for part in parts: item = item.children[part]
        return item

    def execute(self, item, scope, out):
        kind = item[0]
        if kind == 'scope': self.execute(item[2], item[1], out)
        elif kind == 'sequence':
            for inner in item[1]: self.execute(inner, scope, out)
        elif kind == 'repeat':
            for _ in range(item[1]): self.execute(item[2], scope, out)
        elif kind == 'display': out.append(item[1].replace('%m', scope.path()) + '\n')
        elif kind == 'call':
            target = self.resolve(item[1], scope)
            assert target.kind in ('task', 'function'), ('not a subroutine', item[1])
            self.execute(target.body, target, out)
        else:
            raise AssertionError(('unknown statement', kind))

    def run(self):
        printed = []
        for when in ('initial', 'final'):
            for kind, body, scope in self.procedures:
                if kind != when: continue
                out = []
                self.execute(body, scope, out)
                if out: printed.append(''.join(out))
        assert len(printed) == 1, ('one procedure prints', printed)
        return printed[0]


def interpret(source): return Design(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'unnamedgen_up': anchor(('unnamedgen', 'task', 'up', 'initial')),
                'loopgen_root': anchor(('loopgen', 'function', 'root', 'final')),
                'array_loop': anchor(('array', 'loop', 'own', 'initial')),
                'nested_label': anchor(('nested', 'label', 'own', 'final')),
                'top_auto_root': anchor(('top', 'auto', 'root', 'initial')),
                'namedgen_fork': anchor(('namedgen', 'fork', 'own', 'initial')),
                'inst_function_down': anchor(('inst', 'function', 'down', 'final'))}
    root = generator.case_name(('loopgen', 'function', 'root', 'final'))
    faults = (
        ('no_earlier_construct', 'unnamedgen_up',
         [('  for (genvar i = 0; i < 1; i++) begin : pre\n    logic unused;\n  end\n', '')]),
        ('other_loop_index', 'loopgen_root', [('i = 1; i < 2;', 'i = 2; i < 3;'), (f'{root}.g[1].u.f();',
                                                                                    f'{root}.g[2].u.f();')]),
        ('unlabeled_loop', 'array_loop', [('lp: for', 'for')]),
        ('other_label', 'nested_label', [('lb: $display', 'la: $display')]),
        ('caller_in_block', 'top_auto_root', [('    $display("from %m");', '    begin : c\n      $display("from %m");\n'
                                               '    end')]),
        ('other_generate_name', 'namedgen_fork', [('if (1) begin : n', 'if (1) begin : m')]),
        ('other_instance_name', 'inst_function_down', [('hn_child u ();', 'hn_child v ();'), ('    u.f();', '    v.f();')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_hiername.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_hiername.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent elaboration, generate block naming and name resolution of actual %m programs. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
