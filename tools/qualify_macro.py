#!/usr/bin/env python3
"""Interpret actual macro programs independently.

A small preprocessor reads the text by the rules of 22.5 and 22.6: comments and
string literals, definitions with defaults, conditional blocks and expansion at
the point of use. The expanded text is then matched against the few design shapes
the model uses, and each expression is evaluated by an operator precedence parser.
Anything else, such as a recursive macro or a missing argument, is an error.
"""

import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_macro as generator

IDENTIFIER = re.compile(r'[A-Za-z_]\w*')
PAIRS = {'(': ')', '[': ']', '{': '}'}


def split_arguments(text):
    """Split at commas outside matched pairs and string literals."""
    parts, stack, current, position = [], [], '', 0
    while position < len(text):
        char = text[position]
        if char == '"':
            end = text.index('"', position + 1)
            current += text[position:end + 1]
            position = end + 1
            continue
        if char in PAIRS: stack.append(PAIRS[char])
        elif stack and char == stack[-1]: stack.pop()
        if char == ',' and not stack:
            parts.append(current)
            current = ''
        else:
            current += char
        position += 1
    assert not stack, 'unmatched pair in an argument list'
    return parts + [current]


class Preprocessor:
    def __init__(self):
        self.macros = {}
        self.conditions = []

    def active(self): return all(state['on'] for state in self.conditions)

    def read_definition(self, text, position):
        """The name, formals and body of a `define; a body ends at a bare newline."""
        name = IDENTIFIER.match(text, position)
        assert name, 'a macro needs a name'
        position = name.end()
        formals = None
        if text[position:position + 1] == '(':
            depth, end = 0, position
            while True:
                depth += (text[end] in '([{') - (text[end] in ')]}')
                if depth == 0: break
                end += 1
            formals = []
            for part in split_arguments(text[position + 1:end]):
                formal, equal, default = part.partition('=')
                formals.append((formal.strip(), default.strip() if equal else None))
            position = end + 1
        body = ''
        while position < len(text):
            if text.startswith('\\\n', position):
                body += '\n'
                position += 2
            elif text[position] == '\n':
                break
            elif text.startswith('//', position):
                while text[position] != '\n' and not text.startswith('\\\n', position): position += 1
            elif text.startswith('/*', position):
                position = text.index('*/', position) + 2
            elif text[position] == '"':
                end = text.index('"', position + 1)
                body += text[position:end + 1]
                position = end + 1
            else:
                body += text[position]
                position += 1
        # A definition in an inactive block is hidden text, not a definition.
        if self.active(): self.macros[name[0]] = (formals, body.strip())
        return position

    def substitute(self, body, values):
        out, position = '', 0
        while position < len(body):
            if body.startswith('`\\`"', position):
                out += '\\"'
                position += 4
            elif body.startswith('`"', position):
                out += '"'
                position += 2
            elif body.startswith('``', position):
                position += 2
            elif body[position] == '"':
                end = body.index('"', position + 1)
                out += body[position:end + 1]
                position = end + 1
            elif body[position] == '`':
                name = IDENTIFIER.match(body, position + 1)
                assert name, 'a lone ` in a macro body'
                out += '`' + name[0]
                position = name.end()
            elif IDENTIFIER.match(body, position):
                name = IDENTIFIER.match(body, position)
                out += values.get(name[0], name[0])
                position = name.end()
            else:
                out += body[position]
                position += 1
        return out

    def use(self, name, text, position, depth):
        assert name in self.macros, ('undefined macro', name)
        assert depth < 16, 'recursive macro'
        formals, body = self.macros[name]
        values = {}
        if formals is not None:
            while text[position:position + 1].isspace(): position += 1
            assert text[position:position + 1] == '(', 'a macro with arguments needs parentheses'
            level, end = 0, position
            while True:
                level += (text[end] in '([{') - (text[end] in ')]}')
                if level == 0: break
                end += 1
            actuals = [part.strip() for part in split_arguments(text[position + 1:end])]
            position = end + 1
            assert len(actuals) <= len(formals), 'more actual than formal arguments'
            for index, (formal, default) in enumerate(formals):
                actual = actuals[index] if index < len(actuals) else None
                if not actual:
                    assert actual is not None or default is not None, ('no default', formal)
                    actual = default or ''
                values[formal] = actual
        return self.expand(self.substitute(body, values), depth + 1), position

    def expand(self, text, depth=0):
        out, position = '', 0
        while position < len(text):
            if text.startswith('//', position):
                position = text.find('\n', position)
                if position < 0: break
            elif text.startswith('/*', position):
                position = text.index('*/', position) + 2
            elif text[position] == '"':
                end = position + 1
                while text[end] != '"': end += 2 if text[end] == '\\' else 1
                if self.active(): out += text[position:end + 1]
                position = end + 1
            elif text[position] == '`':
                name = IDENTIFIER.match(text, position + 1)
                assert name, 'a lone ` in the source'
                position = name.end()
                directive = name[0]
                if directive in ('ifdef', 'ifndef', 'elsif'):
                    while text[position].isspace(): position += 1
                    flag = IDENTIFIER.match(text, position)
                    position = flag.end()
                    defined = flag[0] in self.macros
                    if directive == 'elsif':
                        state = self.conditions[-1]
                        state['on'] = not state['done'] and defined
                    else:
                        wanted = defined if directive == 'ifdef' else not defined
                        state = {'on': wanted, 'done': False}
                        self.conditions.append(state)
                    state['done'] = state['done'] or state['on']
                elif directive == 'else':
                    state = self.conditions[-1]
                    state['on'] = not state['done']
                    state['done'] = True
                elif directive == 'endif':
                    self.conditions.pop()
                elif directive == 'define':
                    while text[position] in ' \t': position += 1
                    position = self.read_definition(text, position)
                elif not self.active():
                    pass
                elif directive == 'undef':
                    while text[position].isspace(): position += 1
                    flag = IDENTIFIER.match(text, position)
                    self.macros.pop(flag[0], None)
                    position = flag.end()
                else:
                    expansion, position = self.use(directive, text, position, depth)
                    out += expansion
            else:
                if self.active(): out += text[position]
                position += 1
        return out


class Parser:
    """Operator precedence over the expressions of the model, as in Table 11-2."""

    LEVELS = (('|',), ('<<',), ('+', '-'), ('*',))

    def __init__(self, text, scope):
        self.tokens = re.findall(r"\d+'b[01]+|\d+|[A-Za-z_]\w*|<<|[-+*|?:(){},]", text)
        assert ''.join(self.tokens) == re.sub(r'\s+', '', text), ('unsupported expression', text)
        self.position, self.scope = 0, scope

    def peek(self): return self.tokens[self.position] if self.position < len(self.tokens) else None

    def take(self):
        self.position += 1
        return self.tokens[self.position - 1]

    def conditional(self):
        condition = self.binary(0)[0]
        if self.peek() != '?': return condition, None
        self.take()
        chosen = self.conditional()[0]
        assert self.take() == ':', 'a conditional needs a colon'
        other = self.conditional()[0]
        return (chosen if condition else other), None

    def binary(self, level):
        if level == len(self.LEVELS): return self.primary()
        value = self.binary(level + 1)
        while self.peek() in self.LEVELS[level]:
            operator = self.take()
            right = self.binary(level + 1)[0]
            value = ({'|': value[0] | right, '<<': value[0] << right, '+': value[0] + right,
                      '-': value[0] - right, '*': value[0] * right}[operator], None)
        return value

    def primary(self):
        token = self.take()
        if token == '(':
            value = self.conditional()
            assert self.take() == ')', 'unbalanced parenthesis'
            return value
        if token == '{':
            value, width = 0, 0
            while True:
                item, size = self.primary()
                assert size is not None, 'a concatenation needs sized operands'
                value, width = value << size | item, width + size
                if self.take() == '}': return value, width
        sized = re.fullmatch(r"(\d+)'b([01]+)", token)
        if sized:
            assert int(sized[1]) == len(sized[2]), 'a literal of another size'
            return int(sized[2], 2), int(sized[1])
        if token.isdigit(): return int(token), None
        assert token in self.scope, ('undeclared identifier', token)
        return self.scope[token], None

    def run(self):
        value = self.conditional()[0]
        assert self.peek() is None, 'text after the expression'
        return value


def evaluate(text, scope=None): return Parser(text, scope or {}).run()


def element(text, keyword, name):
    found = re.search(rf'\b{keyword} {name}\s*;(.*?)\bend{keyword}\b', text, re.S)
    return found[1] if found else None


def with_scope(body):
    """Separate the local parameters of an element from the rest of its text."""
    scope = {}

    def declare(match):
        scope[match[1]] = int(match[2])
        return ''
    return re.sub(r'localparam int (VAL_\d+) = (\d+);', declare, body).strip(), scope


def squeeze(text): return re.sub(r'\s+', ' ', text).strip()


def interpret(source):
    text = squeeze(Preprocessor().expand(source))
    modules = re.findall(r'\bmodule (\w+)\s*;(.*?)\bendmodule\b', text, re.S)
    assert modules, 'no module'
    assert all(not squeeze(body) for name, body in modules[:-1]), 'an unused module with text'
    body, scope = with_scope(modules[-1][1])

    def whole(pattern, within=None):
        return re.fullmatch(pattern, within if within is not None else body)
    text_shown = whole(r'initial \$display\("%s", "(.*)"\);')
    if text_shown: return text_shown[1].replace('\\"', '"') + '\n'
    assigned = whole(r'int y; assign y = (.*?); initial #1 \$display\("%0d", y\);')
    if assigned: return f'{evaluate(assigned[1], scope)}\n'
    case = whole(r'int v = (\d+); int hit; initial begin case \(v\) (.*?): hit = 1; default: hit = 0; endcase '
                 r'\$display\("%0d", hit\); end')
    if case: return f'{int(evaluate(case[2], scope) == int(case[1]))}\n'
    function = whole(r'function automatic int f\(\); return (.*?); endfunction initial \$display\("%0d", f\(\)\);')
    if function: return f'{evaluate(function[1], scope)}\n'
    generate = whole(r'if \(\((.*?)\) > 0\) begin : g localparam int y = (.*?); end '
                     r'initial \$display\("%0d", g\.y\);')
    if generate:
        assert evaluate(generate[1], scope) > 0, 'the generate block would not exist'
        return f'{evaluate(generate[2], scope)}\n'
    forked = whole(r'int y; initial begin fork y = (.*?); join \$display\("%0d", y\); end')
    if forked: return f'{evaluate(forked[1], scope)}\n'
    dimension = whole(r'logic \[\((.*?)\) - 1:0\] v; initial \$display\("%0d", \$bits\(v\)\);')
    if dimension: return f'{evaluate(dimension[1], scope)}\n'
    member = whole(r"typedef struct \{ int m; int n; \} st; st t = '\{m: (.*), n: 5\}; "
                   r'initial \$display\("%0d", t\.m\);')
    if member: return f'{evaluate(member[1], scope)}\n'
    if whole(r'initial \$display\("%0d", macro_pk::P\);'):
        inner, local = with_scope(element(text, 'package', 'macro_pk'))
        return f'{evaluate(whole(r"parameter int P = (.*);", inner)[1], local)}\n'
    if whole(r'macro_ifc i \(\); initial #1 \$display\("%0d", i\.y\);'):
        inner, local = with_scope(element(text, 'interface', 'macro_ifc'))
        return f'{evaluate(whole(r"int y; assign y = (.*);", inner)[1], local)}\n'
    if whole(r'initial \$display\("%0d", macro_cls::m\(\)\);'):
        inner, local = with_scope(element(text, 'class', 'macro_cls'))
        return f'{evaluate(whole(r"static function int m\(\); return (.*); endfunction", inner)[1], local)}\n'
    shown = whole(r'initial \$display\("%0d", (.*)\);')
    if shown: return f'{evaluate(shown[1], scope)}\n'
    raise AssertionError(('unsupported program', body))


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[index]) for name, index in
                (('bare_low', 0), ('wrap_low', 1), ('late_gen', 2), ('omit_pkg', 3), ('redefine_case', 4),
                 ('lines_elsif', 5), ('paste_cls', 6), ('string_undef', 7), ('quote_same', 8))}
    faults = (
        ('parenthesized_body', 'bare_low', [('`define M(x) x + 1', '`define M(x) (x) + 1')]),
        ('unparenthesized_body', 'wrap_low', [('((x) + 1)', '(x + 1)')]),
        ('other_outer_operator', 'wrap_low', [('* 3', '* 4')]),
        ('other_default', 'omit_pkg', [("x={2'b01, 2'b10}", "x={2'b01, 2'b11}")]),
        ('old_definition_last', 'redefine_case', [('`define M(x) x + 1\n', '`define M(x) x + 1\n`define M(x) 99 + x\n')]),
        ('other_branch', 'lines_elsif', [('`define OK_FLAG', '`define OTHER_FLAG'),
                                         ('`define M 96', '`define M(x) 96')]),
        ('parenthesized_inner', 'late_gen', [('y + 1 + y', '(y) + 1 + (y)')]),
        ('other_local_value', 'paste_cls', [('VAL_3 = 3;', 'VAL_3 = 5;')]),
        ('undef_removed', 'string_undef', [('`undef M\n', ''), ('`define M 97', '`define M(x) "old"')]),
        ('escape_removed', 'quote_same', [('`\\`"x`\\`"', 'x')]),
    )

    def checked(source):
        try: return interpret(source)
        except (AssertionError, KeyError, ValueError) as error: return f'rejected: {error}'
    return controls, apply_faults(controls, faults, checked)


FILES = ('generators/interaction_macro.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_macro.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent preprocessing of the text and evaluation of the expanded expressions. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
