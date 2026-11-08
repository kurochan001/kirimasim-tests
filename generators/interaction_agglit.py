"""A structure literal with positions, member names, replication, type keys and default sets each member through its own type."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_agglit'
VERSION = 1
CHAPTER = 5

# The value under test as written, and as each member type holds it: nib_t (logic [3:0]) bits, then int, byte
# and integer as %0d prints them.
VALUES = {'fill1': ("'1", '1111', '-1', '-1', '-1'), 'fillx': ("'x", 'xxxx', '0', '0', 'x'),
          'neg': ('-2', '1110', '-2', '-2', '-2'), 'real': ('2.5', '0011', '3', '3', '3'),
          'wide': ("12'h9f5", '0101', '2549', '-11', '2549'), 'snarrow': ("3'sb101", '1101', '-3', '-3', '-3')}
# The fixed values the keyed forms give the members that do not take the value under test.
W, U, T = 9, 7, 11
KEYS = {'position': "'{V, '{V, V, V, V}, '{V, V}}",
        'member': "'{q: '{V, V}, n: '{g: V, b: V, l: V, i: V}, a: V}",
        'replicate': "'{V, '{4{V}}, '{2{V}}}",
        'default': "'{default: V}",
        'type': f"'{{a: {W}, n: '{{int: V, nib_t: {W}, byte: {U}, integer: {T}}}, q: '{{int: V}}}}",
        'type_default': f"'{{int: V, default: {W}}}",
        'member_type': f"'{{a: V, nib_t: {W}, default: {U}}}",
        'last_type': f"'{{int: {W}, default: {U}, int: V}}"}
CONTEXTS = ('init', 'assign', 'typed', 'param')


MODEL = Model(
    'aggregate_literal_key',
    (('key', tuple(KEYS)), ('value', tuple(VALUES)), ('context', CONTEXTS)),
    lambda row: True,
    anchors=(('member_type', 'snarrow', 'init'), ('last_type', 'real', 'typed'), ('type', 'fillx', 'init'),
             ('default', 'wide', 'assign'), ('replicate', 'fill1', 'typed'), ('member', 'neg', 'assign'),
             ('type_default', 'fillx', 'assign')),
    constraints=('構造体は、nib_tのメンバーa、int・nib_t・byte・integerのメンバーを持つ構造体n、'
                 'intの非パック配列qを持つ。値を位置・メンバー名・複製・default・型キーで与え、'
                 '型キーはnib_t・int・byte・integerだけを使う。intとintegerは一致する型ではないので、'
                 'intのキーはintegerに当たらない。defaultがあれば、型キーとdefaultは入れ子の構造体と配列へ降りて'
                 '当てはまる。defaultがないときに降りるかは読み方が分かれるので、その形では型キーを入れ子の'
                 'パターンに直接書く。'
                 'メンバー名が型キーより、型キーがdefaultより優先し、同じ型キーは最後の値を使う。'
                 '値は各メンバーへの代入として変換し、二値の型ではxをゼロにする。'
                 'すべての組合せは合法で、宣言の初期値・手続きの代入・型付きのパターン式・localparamで同じ値を運ぶ。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_agglit_' + '_'.join(row)


def members(row: Row) -> dict:
    """The printed value of each member: a, n.i, n.l, n.b, n.g, q[0], q[1]."""
    key, value, _ = row
    bits, int_, byte_, integer_ = VALUES[value][1:]
    every = {'a': bits, 'i': int_, 'l': bits, 'b': byte_, 'g': integer_, 'q0': int_, 'q1': int_}
    if key in ('position', 'member', 'replicate', 'default'): return every

    def fixed(number: int) -> dict:
        return {'a': format(number, '04b'), 'i': str(number), 'l': format(number, '04b'), 'b': str(number),
                'g': str(number), 'q0': str(number), 'q1': str(number)}
    if key == 'type':
        return fixed(W) | {'b': str(U), 'g': str(T), 'i': int_, 'q0': int_, 'q1': int_}
    if key == 'type_default': return fixed(W) | {'i': int_, 'q0': int_, 'q1': int_}
    if key == 'member_type': return fixed(U) | {'a': bits, 'l': format(W, '04b')}
    return fixed(U) | {'i': int_, 'q0': int_, 'q1': int_}


def reference(row: Row) -> str:
    m = members(row)
    return f"a={m['a']} i={m['i']} l={m['l']} b={m['b']} g={m['g']} q={m['q0']},{m['q1']}\n"


def pattern(row: Row) -> str: return KEYS[row[0]].replace('V', VALUES[row[1]][0])


def layout(prefix: str, text: str, suffix: str) -> list[str]:
    """The pattern on one line, or one top-level entry per line when the line would be long."""
    if len(prefix + text + suffix) <= 96: return [prefix + text + suffix]
    entries, depth, start = [], 0, 2
    for at, char in enumerate(text):
        depth += {'{': 1, '}': -1}.get(char, 0)
        if char == ',' and depth == 1: entries.append(text[start:at].strip()); start = at + 1
    entries.append(text[start:-1].strip())
    pad = ' ' * (len(prefix) + 2)
    return [prefix + "'{" + entries[0] + ','] + [pad + e + ',' for e in entries[1:-1]] + [pad + entries[-1] + '}' + suffix]


def source(row: Row) -> str:
    context = row[2]
    p = pattern(row)
    lines = [f'module {case_name(row)};', '  typedef logic [3:0] nib_t;',
             '  typedef struct { int i; nib_t l; byte b; integer g; } in_t;',
             '  typedef struct { nib_t a; in_t n; int q [2]; } out_t;', '  task automatic show(input out_t x);',
             '    $display("a=%b i=%0d l=%b b=%0d g=%0d q=%0d,%0d",',
             '             x.a, x.n.i, x.n.l, x.n.b, x.n.g, x.q[0], x.q[1]);',
             '  endtask']
    lines += {'init': [*layout('  out_t v = ', p, ';'), '  initial show(v);'],
              'assign': ['  out_t v;', '  initial begin', *layout('    v = ', p, ';'), '    show(v);', '  end'],
              'typed': layout('  initial show(out_t', p, ');'),
              'param': [*layout('  localparam out_t C = ', p, ';'), '  initial show(C);']}[context]
    lines.append('endmodule')
    return '\n'.join(lines)


KEY_CLAUSE = {'position': '5.10 10.9.2', 'member': '5.10 10.9.2', 'replicate': '5.10 5.11 10.9.1 10.9.2',
              'default': '5.10 10.9.1 10.9.2', 'type': '5.10 10.9.2 6.22.1', 'type_default': '5.10 10.9.2 6.22.1',
              'member_type': '5.10 10.9.2 6.22.1', 'last_type': '5.10 10.9.2'}
VALUE_CLAUSE = {'fill1': '5.7.1', 'fillx': '5.7.1 6.11', 'neg': '5.7.1 10.7', 'real': '5.7.2 6.12.1',
                'wide': '5.7.1 10.7', 'snarrow': '5.7.1 10.7'}
CONTEXT_CLAUSE = {'init': '10.8 6.8', 'assign': '10.8', 'typed': '10.9 13.3', 'param': '10.8 6.20.4'}


def make_case(row: Row) -> Case:
    key, value, context = row
    clauses = f'{KEY_CLAUSE[key]} {VALUE_CLAUSE[value]} {CONTEXT_CLAUSE[context]}'.split()
    return Case(case_name(row), 'A structure literal sets each member through its key and its type',
                ' '.join(dict.fromkeys(clauses)),
                'A structure with a 4-bit member, a nested structure of int, 4-bit, byte and integer members, '
                'and an int array of two is set by a structure literal by position, by member name, by '
                'replication, by default, by type keys inside the nested patterns, by a type key with default, '
                'by a member name with a type '
                'key and default, or by a type key given twice. The value under test is \'1, \'x, -2, 2.5, a '
                'wide literal or a narrow signed literal, converted as an assignment to each member it reaches. '
                'The literal initializes a variable, is assigned, is a typed pattern argument or a local '
                'parameter.',
                source(row), reference(row), fourstate=value == 'fillx',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
