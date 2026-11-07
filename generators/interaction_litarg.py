"""A literal passed to a subroutine is converted to the formal's type as by an assignment."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_litarg'
VERSION = 1
CHAPTER = 13

# The text of each literal, and its width, sign and value; None for a real or a fill.
LITERALS = {'neg': ('-3', 32, True, -3), 'fill1': ("'1", None, False, '1'), 'fillx': ("'x", None, False, 'x'),
            'signed': ("4'sb1010", 4, True, -6), 'unsigned': ("4'b1010", 4, False, 10),
            'based': ("'hff", 32, False, 255), 'real': ('2.5', None, True, 2.5), 'exp': ('1.5e1', None, True, 15.0),
            'negreal': ('-2.5', None, True, -2.5), 'string': ('"AB"', 16, False, 0x4142)}
# Each formal type, its width, sign and whether it holds x.
FORMALS = {'bit8': ('bit [7:0]', 8, False, False), 'byte': ('byte', 8, True, False),
           'logic12': ('logic [11:0]', 12, False, True), 'slogic12': ('logic signed [11:0]', 12, True, True),
           'int': ('int', 32, True, False), 'real': ('real', None, True, False), 'string': ('string', None, False, False)}


def legal(row: Row) -> bool:
    literal, formal, _, _ = row
    if formal == 'string' and literal != 'string': return False
    # An unbased unsized literal takes the width of an integral target only.
    if formal == 'real' and literal in ('fill1', 'fillx'): return False
    return True


MODEL = Model(
    'literal_argument_conversion',
    (('literal', tuple(LITERALS)), ('formal', tuple(FORMALS)),
     ('passing', ('positional', 'named', 'default', 'return')), ('name', ('plain', 'escaped'))),
    legal,
    anchors=(('fill1', 'byte', 'default', 'escaped'), ('fillx', 'slogic12', 'named', 'escaped'),
             ('negreal', 'bit8', 'return', 'plain'), ('string', 'logic12', 'positional', 'escaped'),
             ('signed', 'real', 'named', 'plain'), ('based', 'byte', 'return', 'escaped'),
             ('real', 'int', 'default', 'plain'), ('neg', 'logic12', 'positional', 'plain')),
    constraints=('実引数・既定の引数・戻り値はどれも代入と同じ規則で仮引数の型へ変換する。'
                 'unbased unsizedは整数型の仮引数の幅いっぱいに広がり、二値の型ではxが0になる。'
                 '実数は最も近い整数に丸め、0.5は0から離れる向きに丸める。文字列リテラルは8ビットの文字を並べた符号なしの整数である。'
                 'string型の仮引数には文字列リテラルだけを、real型にはunbased unsizedを渡さない。'
                 'エスケープした識別子はtask・function・仮引数の名前に使い、空白で終える。'
                 'シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_litarg_' + '_'.join(row)


def converted(literal: str, formal: str):
    """The formal's value: a number, a real, a string or a string of bits."""
    _, width, signed, value = LITERALS[literal]
    _, size, fsigned, four = FORMALS[formal]
    if formal == 'string': return 'AB'
    if formal == 'real': return float(value)
    if literal in ('fill1', 'fillx'):
        digit = value if four or value == '1' else '0'
        return digit * size
    if width is None:
        # Round to the nearest integer, a half away from zero.
        number = int(abs(value) + 0.5) * (1 if value >= 0 else -1)
    else:
        number = value
    bits = number % (1 << size)
    return format(bits, f'0{size}b')


def shown(literal: str, formal: str) -> str:
    value = converted(literal, formal)
    _, size, fsigned, _ = FORMALS[formal]
    if formal == 'string': return f'{value} {len(value)}'
    if formal == 'real': return f'{value:.2f}'
    if set(value) == {'x'}: return 'x ' + 'x' * (size // 4)
    number = int(value, 2)
    if fsigned and value[0] == '1': number -= 1 << size
    return f'{number} {int(value, 2):0{size // 4}x}'


def reference(row: Row) -> str: return shown(row[0], row[1]) + '\n'


def source(row: Row) -> str:
    literal, formal, passing, name = row
    text = LITERALS[literal][0]
    kind = FORMALS[formal][0]
    escaped = name == 'escaped'
    task = '\\show+v ' if escaped else 'show'
    function = '\\get+v ' if escaped else 'get'
    arg = '\\a+v ' if escaped else 'a'
    form = {'real': '"%.2f"', 'string': '"%s %0d"'}.get(formal, '"%0d %h"')
    if formal == 'string': values = f'{arg}, {arg}.len()'
    elif formal == 'real': values = arg
    else: values = f'{arg}, {arg}'
    lines = [f'module {case_name(row)};']
    if passing == 'return':
        result = 'r'
        lines += [f'  {kind} r;', f'  function automatic {kind} {function}();', f'    return {text};',
                  '  endfunction', '  initial begin', f'    r = {function}();']
        shown_values = {'string': 'r, r.len()', 'real': 'r'}.get(formal, 'r, r')
        lines += [f'    $display({form}, {shown_values});', '  end']
    else:
        default = f' = {text}' if passing == 'default' else ''
        lines += [f'  task automatic {task}(input {kind} {arg}{default});', f'    $display({form}, {values});',
                  '  endtask', '  initial begin']
        call = {'positional': f'{task}({text});', 'named': f'{task}(.{arg}({text}));',
                'default': f'{task}();'}[passing]
        lines += ['    ' + call, '  end']
    lines.append('endmodule')
    return '\n'.join(lines)


LITERAL_CLAUSE = {'neg': '5.7.1 11.4.3', 'fill1': '5.7.1', 'fillx': '5.7.1', 'signed': '5.7.1', 'unsigned': '5.7.1',
                  'based': '5.7.1', 'real': '5.7.2 6.12.1', 'exp': '5.7.2 6.12.1', 'negreal': '5.7.2 6.12.1',
                  'string': '5.9 6.16'}
PASSING_CLAUSE = {'positional': '13.5.1', 'named': '13.5.4', 'default': '13.5.3', 'return': '13.4.1'}


def make_case(row: Row) -> Case:
    literal, formal, passing, name = row
    escaped = ' 5.6.1' if name == 'escaped' else ''
    return Case(case_name(row), 'A literal passed to a subroutine is converted to the type of the formal',
                f'13.5 {PASSING_CLAUSE[passing]} {LITERAL_CLAUSE[literal]} 10.7{escaped}',
                'An actual argument, a default argument and a return value are each converted to the type of '
                'the formal or of the function as by an assignment. An unbased unsized literal fills the whole '
                'width of an integral formal, and a two-state type turns x into 0. A real rounds to the '
                'nearest integer, a half away from zero, and a string literal is an unsigned number of eight-'
                'bit characters. An escaped identifier names the task, the function or the formal and ends at '
                'white space.',
                source(row), reference(row),
                fourstate=literal == 'fillx',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
