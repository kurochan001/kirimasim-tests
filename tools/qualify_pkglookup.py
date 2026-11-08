#!/usr/bin/env python3
"""Interpret actual package lookup programs independently.

Packages, imports, declarations and the procedure are read in their order of
text. A reference is resolved by the search of 26.3: in each scope from the
inside out, first the locally visible names (declarations, explicit imports
and names a wildcard import already made visible) before the point of the
reference, or up to the end of the scope for a function call, and then the
wildcard imports before the point of the reference. Two wildcard imports that
both supply the name, an explicit import and a declaration of one name in a
scope, and a declaration after a wildcard name became visible are errors. The
loop and the display are then evaluated directly.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_pkglookup as generator


class Scope:
    def __init__(self, parent):
        self.parent, self.items = parent, []   # (position, kind, name, payload)

    def add(self, position, kind, name, payload=None): self.items.append((position, kind, name, payload))


class Program:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        self.packages = {}
        for package in re.finditer(r'^package (\w+);\n(.*?)^endpackage', code, re.S | re.M):
            members = {}
            for line in (l.strip() for l in package[2].split('\n') if l.strip()):
                var = re.fullmatch(r'int (\w+) = (\d+);', line)
                function = re.fullmatch(r'function automatic int (\w+)\(\); return (\d+); endfunction', line)
                assert var or function, ('unsupported package item', line)
                if var: members[var[1]] = ('var', int(var[2]))
                else: members[function[1]] = ('call', int(function[2]))
            self.packages[package[1]] = members
        modules = re.findall(r'^module (\w+);\n(.*?)^endmodule', code, re.S | re.M)
        assert len(modules) == 1, 'one module'
        self.module = Scope(None)
        self.block = None
        lines = modules[0][1].split('\n')
        at = 0
        position = 0
        while at < len(lines):
            line = lines[at].strip()
            at += 1
            position += 1
            if not line: continue
            if line == 'initial begin':
                end = lines.index('  end', at)
                self.procedure = position
                self.read_block([l.strip() for l in lines[at:end]], position)
                at = end + 1
                continue
            self.item(self.module, position, line)

    def item(self, scope, position, line):
        wild = re.fullmatch(r'import (\w+)::\*;', line)
        explicit = re.fullmatch(r'import (\w+)::(\w+);', line)
        var = re.fullmatch(r'int (\w+)(?: = (\d+))?;', line)
        function = re.fullmatch(r'function automatic int (\w+)\(\); return (\d+); endfunction', line)
        if wild:
            assert wild[1] in self.packages
            scope.add(position, 'wildcard', None, wild[1])
        elif explicit:
            assert explicit[2] in self.packages[explicit[1]], 'no such package item'
            scope.add(position, 'explicit', explicit[2], explicit[1])
        elif var: scope.add(position, 'var', var[1], int(var[2]) if var[2] else 0)
        elif function: scope.add(position, 'call', function[1], int(function[2]))
        else: raise AssertionError(('unsupported item', line))

    def read_block(self, lines, base):
        self.block = Scope(self.module)
        self.statements = []
        declarations = True
        for offset, line in enumerate(lines, 1):
            position = base + offset / 1000
            if declarations and re.match(r'(import |int \w+;)', line):
                self.item(self.block, position, line)
                continue
            declarations = False
            self.statements.append((position, line))

    def resolve(self, name, kind, scope, position):
        """Where a reference binds (a package name or the declaring scope) and its value, by the steps of 26.3."""
        while scope is not None:
            limit = float('inf') if kind == 'call' else position
            local = [item for item in scope.items if item[0] < limit and item[2] == name and
                     item[1] in ('var', 'call', 'explicit', 'imported')]
            if local:
                assert len({(i[1], i[3]) for i in local}) == 1 or all(i[1] == 'imported' for i in local), \
                    ('two local declarations', name)
                _, how, _, payload = local[0]
                if how in ('var', 'call'):
                    assert how == kind, ('wrong kind', name)
                    return scope, payload
                return payload, self.member(payload, name, kind)
            wild = [item for item in scope.items if item[1] == 'wildcard' and item[0] < position and
                    name in self.packages[item[3]]]
            assert len({item[3] for item in wild}) <= 1, ('ambiguous wildcard imports', name)
            if wild:
                package = wild[0][3]
                scope.add(position, 'imported', name, package)
                return package, self.member(package, name, kind)
            # The point of the reference in the outer scope is the procedure that holds it.
            position = self.procedure if scope is self.block else position
            scope = scope.parent
        raise AssertionError(('no declaration', name))

    def member(self, package, name, kind):
        found = self.packages[package][name]
        assert found[0] == kind, ('wrong kind', name)
        return found[1]

    def check(self):
        """The errors of 26.3 that do not depend on one reference."""
        for scope in (self.module, self.block):
            declared = {i[2] for i in scope.items if i[1] in ('var', 'call')}
            explicit = {i[2] for i in scope.items if i[1] == 'explicit'}
            assert not declared & explicit, 'an explicit import and a declaration of one name'
            for position, how, name, _ in scope.items:
                if how != 'imported': continue
                later = [i for i in scope.items if i[1] in ('var', 'call') and i[2] == name and i[0] > position]
                assert not later, ('a declaration after the name was imported', name)

    def value(self, text, position, store):
        text = text.strip()
        if re.fullmatch(r'\d+', text): return int(text)
        scoped = re.fullmatch(r'(\w+)::(\w+)(\(\))?', text)
        if scoped: return self.member(scoped[1], scoped[2], 'call' if scoped[3] else 'var')
        call = re.fullmatch(r'(\w+)\(\)', text)
        if call: return self.resolve(call[1], 'call', self.block, position)[1]
        origin, value = self.resolve(text, 'var', self.block, position)
        # A block variable holds what the statements wrote; the others keep their initial values.
        return store.get(text, value) if origin is self.block else value

    def run(self):
        store, out = {}, []
        locals_ = {i[2] for i in self.block.items if i[1] == 'var'}
        for position, line in self.statements:
            assign = re.fullmatch(r'(\w+) = (\d+);', line)
            loop_for = re.fullmatch(r'for \(int i = 0; i < (.+); i\+\+\) count\+\+;', line)
            loop_while = re.fullmatch(r'while \(count < (.+)\) count\+\+;', line)
            loop_repeat = re.fullmatch(r'repeat \((.+)\) count\+\+;', line)
            loop_do = re.fullmatch(r'do count\+\+; while \(count < (.+)\);', line)
            show = re.fullmatch(r'\$display\("value=%0d count=%0d", (.+), count\);', line)
            if assign:
                assert assign[1] in locals_, ('not a block variable', assign[1])
                store[assign[1]] = int(assign[2])
            elif loop_for:
                i = 0
                while i < self.value(loop_for[1], position, store):
                    store['count'] += 1
                    i += 1
            elif loop_while:
                while store['count'] < self.value(loop_while[1], position, store): store['count'] += 1
            elif loop_repeat:
                for _ in range(self.value(loop_repeat[1], position, store)): store['count'] += 1
            elif loop_do:
                store['count'] += 1
                while store['count'] < self.value(loop_do[1], position, store): store['count'] += 1
            elif show:
                out.append(f'value={self.value(show[1], position, store)} count={store["count"]}\n')
            else:
                raise AssertionError(('unsupported statement', line))
        self.check()
        return ''.join(out)


def interpret(source): return Program(source).run()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'block_over_outer': anchor(('block_wild', 'outer_decl', 'var', 'for')),
                'later_function': anchor(('module_wild', 'later_decl', 'call', 'repeat')),
                'explicit_inner': anchor(('explicit', 'inner_import', 'var', 'while')),
                'block_later': anchor(('block_wild', 'later_decl', 'call', 'do')),
                'inner_wild_call': anchor(('module_wild', 'inner_import', 'call', 'for')),
                'block_variable': anchor(('block_wild', 'inner_decl', 'var', 'repeat')),
                'explicit_later': anchor(('explicit', 'later_import', 'call', 'while'))}
    faults = (
        ('no_block_import', 'block_over_outer', [('    import lk_p::*;\n', '')]),
        ('no_later_function', 'later_function', [('  function automatic int f(); return 70; endfunction\n', '')]),
        ('no_inner_import', 'explicit_inner', [('    import lk_q::*;\n', '')]),
        ('other_package', 'block_later', [('    import lk_p::*;', '    import lk_q::*;')]),
        ('no_inner_import_call', 'inner_wild_call', [('    import lk_q::*;\n', '')]),
        ('other_value', 'block_variable', [('    n = 6;', '    n = 9;')]),
        ('explicit_other', 'explicit_later', [('  import lk_p::f;', '  import lk_q::f;')]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_pkglookup.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_pkglookup.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent package search of actual programs by the steps of 26.3. Auxiliary controls and faults '
            'are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
