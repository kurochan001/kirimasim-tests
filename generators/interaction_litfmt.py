"""A literal keeps its size, sign and unknown digits from the text to every formatted output."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_litfmt'
VERSION = 1
CHAPTER = 21

# The text of each literal, its width, whether it is signed, and its bits,
# most significant first. The string is two characters, 'A' by hexadecimal
# and by octal escape.
LITERALS = {
    'unsized': ('13', 32, True, format(13, '032b')),
    'sized': ("8'd200", 8, False, format(200, '08b')),
    'xpad': ("12'hx5", 12, False, 'x' * 8 + '0101'),
    'zpad': ("12'hz3", 12, False, 'z' * 8 + '0011'),
    'qmark': ("8'b0?0?_10z1", 8, False, '0z0z10z1'),
    'octal': ("9'o7x5", 9, False, '111xxx101'),
    'under': ("16'hab_cd", 16, False, format(0xabcd, '016b')),
    'fill': ("'1", 1, False, '1'),
    'negate': ("-8'd5", 8, False, format(251, '08b')),
    'signed': ("4'shf", 4, True, '1111'),
    'string': ('"\\x41\\101"', 16, False, format(0x4141, '016b')),
}
FORMATS = {'d': '%d', '0d': '%0d', 'h': '%h', '0h': '%0h', 'o': '%o', 'b': '%b', 'wd': '%8d', 'wh': '%8h',
           's': '%s'}
# The task that prints an argument without a format in the radix of the format.
DEFAULT_TASK = {'d': '$display', 'h': '$displayh', 'o': '$displayo', 'b': '$displayb'}
FIELD = 8


def legal(row: Row) -> bool:
    literal, form, route, carrier = row
    if form == 's' and literal != 'string': return False
    if route == 'default' and form not in DEFAULT_TASK: return False
    if carrier == 'concat' and literal in ('unsized', 'fill'): return False
    _, _, signed, _ = LITERALS[literal]
    # An unsized number has at least 32 bits, so the full width is not fixed.
    if literal == 'unsized' and form in ('d', 'h', 'o', 'b'): return False
    # The full decimal width of a signed value is read in two ways.
    if signed and carrier != 'concat' and form == 'd': return False
    return True


MODEL = Model(
    'literal_format_display',
    (('literal', tuple(LITERALS)), ('form', tuple(FORMATS)),
     ('route', ('display', 'write', 'sformatf', 'swrite', 'fdisplay', 'default')),
     ('carrier', ('direct', 'param', 'macro', 'concat'))),
    legal,
    anchors=(('xpad', 'wh', 'display', 'direct'), ('octal', 'o', 'default', 'macro'),
             ('qmark', '0h', 'sformatf', 'param'),
             ('signed', 'd', 'swrite', 'concat'), ('string', 'd', 'default', 'direct'),
             ('string', 'h', 'default', 'param'), ('fill', 'wh', 'fdisplay', 'macro'),
             ('unsized', 'wd', 'write', 'param'), ('zpad', 'd', 'display', 'concat')),
    constraints=('リテラルの字句から幅・符号・各ビットを決め、%d・%h・%o・%b・%sと幅0・幅8の書式で1行に表示する。'
                 '無サイズ数は少なくとも32ビットで全幅の桁数が定まらないので、幅0と幅指定の書式だけにする。'
                 '符号付きの値の%dの既定の桁数は読み方が分かれるので除外し、連結で符号なしになる場合だけ残す。'
                 '%sは文字列リテラルだけに使う。書式のない$displayh・$displayo・$displaybは基数の書式だけで置く。'
                 '書式のない引数の文字列リテラルは書式の文字列として表示される。'
                 '連結は無サイズ数を含められないので、無サイズ数とunbased unsizedを除く。'
                 'シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_litfmt_' + '_'.join(row)


def value_type(row: Row) -> tuple[int, bool, str]:
    """The width, sign and bits of the argument the task receives."""
    literal, _, _, carrier = row
    _, width, signed, bits = LITERALS[literal]
    return width, signed and carrier != 'concat', bits


def digits(bits: str, step: int) -> str:
    """Hexadecimal or octal digits, by the groups of bits from the right."""
    bits = bits.rjust(-(-len(bits) // step) * step, '0')
    out = []
    for i in range(0, len(bits), step):
        group = bits[i:i + step]
        if set(group) == {'x'}: out.append('x')
        elif set(group) == {'z'}: out.append('z')
        elif 'x' in group: out.append('X')
        elif 'z' in group: out.append('Z')
        else: out.append(format(int(group, 2), 'x'))
    return ''.join(out)


def decimal(width: int, signed: bool, bits: str) -> str:
    if set(bits) == {'x'}: return 'x'
    if set(bits) == {'z'}: return 'z'
    if 'x' in bits: return 'X'
    if 'z' in bits: return 'Z'
    value = int(bits, 2)
    if signed and bits[0] == '1': value -= 1 << width
    return str(value)


def formatted(row: Row) -> str:
    literal, form, route, carrier = row
    width, signed, bits = value_type(row)
    if route == 'default' and literal == 'string' and carrier in ('direct', 'macro'):
        # A string literal argument is text to print, not a value.
        return 'AA'
    if form == 's': return ''.join(chr(int(bits[i:i + 8], 2)) for i in range(0, width, 8))
    if form in ('d', '0d', 'wd'):
        text = decimal(width, signed, bits)
        size = {'d': len(str((1 << width) - 1)), '0d': 0, 'wd': FIELD}[form]
        return text.rjust(size)
    step = {'h': 4, '0h': 4, 'wh': 4, 'o': 3, 'b': 1}[form]
    text = bits if step == 1 else digits(bits, step)
    if form in ('0h', 'wh'):
        text = text.lstrip('0') or '0'
        if form == 'wh': text = text.rjust(FIELD, '0')
    return text


def reference(row: Row) -> str: return ':' + formatted(row) + ':\n'


def source(row: Row) -> str:
    literal, form, route, carrier = row
    text = LITERALS[literal][0]
    decl = []
    if carrier == 'param':
        decl.append(f'localparam P = {text};')
        argument = 'P'
    elif carrier == 'macro':
        decl.append(f'`define LIT {text}')
        argument = '`LIT'
    elif carrier == 'concat':
        argument = '{' + text + '}'
    else:
        argument = text
    spec = f'":{FORMATS[form]}:"'
    if route in ('sformatf', 'swrite'): decl.append('string s;')
    body = {
        'display': [f'$display({spec}, {argument});'],
        'write': [f'$write({spec}, {argument});', '$write("\\n");'],
        'sformatf': [f's = $sformatf({spec}, {argument});', '$display("%s", s);'],
        'swrite': [f'$swrite(s, {spec}, {argument});', '$display("%s", s);'],
        'fdisplay': [f"$fdisplay(32'h8000_0001, {spec}, {argument});"],
        'default': [f'{DEFAULT_TASK.get(form, "$display")}(":", {argument}, ":");'],
    }[route]
    lines = [f'module {case_name(row)};', *['  ' + line for line in decl if not line.startswith('`')],
             '  initial begin', *['    ' + line for line in body], '  end', 'endmodule']
    macros = [line for line in decl if line.startswith('`')]
    return '\n'.join([*macros, *lines])


LITERAL_CLAUSE = {'unsized': '5.7.1', 'sized': '5.7.1', 'xpad': '5.7.1', 'zpad': '5.7.1', 'qmark': '5.7.1',
                  'octal': '5.7.1', 'under': '5.7.1', 'fill': '5.7.1', 'negate': '5.7.1 11.4.3',
                  'signed': '5.7.1', 'string': '5.9 5.9.1'}
ROUTE_CLAUSE = {'display': '21.2.1', 'write': '21.2.1', 'sformatf': '21.3.3', 'swrite': '21.3.3',
                'fdisplay': '21.3.2', 'default': '21.2.1'}
CARRIER_CLAUSE = {'direct': '', 'param': ' 6.20.2', 'macro': ' 22.5.1', 'concat': ' 11.4.12'}


def make_case(row: Row) -> Case:
    literal, form, route, carrier = row
    width, signed, bits = value_type(row)
    return Case(case_name(row), 'A literal keeps its size, sign and unknown digits to the formatted output',
                f'21.2.1.2 21.2.1.3 {ROUTE_CLAUSE[route]} {LITERAL_CLAUSE[literal]}{CARRIER_CLAUSE[carrier]}',
                'The text of a literal fixes its width, its sign and every bit, also an x or z that pads it on '
                'the left and a question mark that stands for z. Each radix shows groups of bits, an x or z '
                'digit for a whole group and X or Z for a part, and a decimal value shows one character. The '
                'full width comes from the largest value, a width of 0 drops the leading zeros, and a wider '
                'field pads hexadecimal with zeros and decimal with spaces. A parameter or a macro keeps the '
                'literal, a concatenation makes it unsigned, and a string literal without a format is text.',
                source(row), reference(row), fourstate=any(bit in 'xz' for bit in bits),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
