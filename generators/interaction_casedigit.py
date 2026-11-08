"""A case item written with ?, z or x digits pads and extends by the literal rules, and each kind of case compares it its own way."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_casedigit'
VERSION = 1
CHAPTER = 5

BITS = {'b': 1, 'o': 3, 'h': 4}
# The digits of the item: the leftmost digit is a wildcard, or a known digit. W stands for the digit under test.
DIGITS = {'bin': {'wild': 'W1W0', 'known': '1W0W'}, 'oct': {'wild': 'W5', 'known': '5W'},
          'hex': {'wild': 'W5', 'known': '5W'}, 'dec': {'wild': 'W'}}
SIZES = {'narrow': 6, 'same': 8, 'wide': 12, 'unsized': None}
SELECTOR = 8
FILLER = '10110010'
TAGS = ('fill', 'flip', 'selz', 'selx', 'exact')


def legal(row: Row) -> bool:
    base, _, lead, size, _ = row
    # A decimal number may hold only one x, z or ? digit, which sets every bit; a hexadecimal pair needs 8 bits.
    return lead in DIGITS[base] and not (base == 'hex' and size == 'narrow')


MODEL = Model(
    'case_literal_wildcard',
    (('base', ('bin', 'oct', 'hex', 'dec')), ('digit', ('q', 'z', 'x')), ('lead', ('wild', 'known')),
     ('size', tuple(SIZES)), ('statement', ('case', 'casez', 'casex', 'inside'))),
    legal,
    groups=(('digit', 'lead', 'statement'),),
    anchors=(('bin', 'q', 'wild', 'wide', 'casez'), ('oct', 'x', 'wild', 'narrow', 'casex'),
             ('hex', 'z', 'known', 'unsized', 'inside'), ('dec', 'q', 'wild', 'unsized', 'case'),
             ('bin', 'z', 'known', 'narrow', 'casez'), ('hex', 'x', 'wild', 'same', 'inside'),
             ('oct', 'q', 'known', 'wide', 'casex')),
    constraints=('選択式はlogic [7:0]とし、?・z・xのどれか一種類の桁を含む項目一つとdefaultで調べる。'
                 '項目は二進・八進・十六進・十進のリテラルで、先頭の桁が不定値か既知の値か、幅が選択式より'
                 '狭いか同じか広いか、無サイズかを変える。先頭が不定値なら、その値でリテラルの幅まで埋まる。'
                 'その後でcaseが全体を最も広い式の幅へ広げ、上のビットはゼロになる。'
                 '一つのプログラムで、不定値の位置を既知の値で埋めた値・既知の位置を一つ反転した値・'
                 '既知の位置をzやxにした値・項目と同じ四値の値を順に比べる。'
                 '十進はx・z・?を一桁だけ書けるので先頭は不定値だけにする。'
                 '十六進の二桁は狭い幅に入らないので除外する。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_casedigit_' + '_'.join(row)


def literal(row: Row) -> str:
    base, digit, lead, size, _ = row
    letter = {'q': '?', 'z': 'z', 'x': 'x'}[digit]
    width = SIZES[size]
    return f"{width if width else ''}'{base[0]}{DIGITS[base][lead].replace('W', letter)}"


def item_bits(row: Row) -> str:
    """The bits of the item after the literal rules and the case extension, most significant first."""
    base, digit, lead, size, _ = row
    letter = 'x' if digit == 'x' else 'z'
    width = SIZES[size] or 32
    if base == 'dec': bits = letter * width
    else:
        bits = ''.join((letter * BITS[base[0]] if d == 'W' else format(int(d, 8 if base == 'oct' else 16),
                                                                        f'0{BITS[base[0]]}b'))
                       for d in DIGITS[base][lead])
        bits = (bits[0] if bits[0] in 'xz' else '0') * (width - len(bits)) + bits
    return bits.rjust(max(width, SELECTOR), '0')


def selectors(row: Row) -> list[tuple[str, str]]:
    item = item_bits(row)[-SELECTOR:]
    fill = ''.join(FILLER[k] if b in 'xz' else b for k, b in enumerate(item))
    known = [k for k, b in enumerate(item) if b in '01']
    at = known[-1] if known else SELECTOR - 1

    def put(value: str) -> str: return fill[:at] + value + fill[at + 1:]
    return [('fill', fill), ('flip', put('1' if fill[at] == '0' else '0')), ('selz', put('z')), ('selx', put('x')),
            ('exact', item)]


def matches(statement: str, selector: str, item: str) -> bool:
    selector = selector.rjust(len(item), '0')
    for s, i in zip(selector, item):
        if statement == 'case' and s != i: return False
        if statement == 'casez' and 'z' not in (s, i) and s != i: return False
        if statement == 'casex' and not ({s, i} & {'x', 'z'}) and s != i: return False
        if statement == 'inside' and i not in 'xz' and (s in 'xz' or s != i): return False
    return True


def reference(row: Row) -> str:
    item = item_bits(row)
    return ''.join(f"{tag} {'hit' if matches(row[4], value, item) else 'miss'}\n" for tag, value in selectors(row))


def source(row: Row) -> str:
    statement = row[4]
    head = {'case': 'case (s)', 'casez': 'casez (s)', 'casex': 'casex (s)', 'inside': 'case (s) inside'}[statement]
    lines = [f'module {case_name(row)};', '  task automatic check(input string tag, input logic [7:0] s);',
             f'    {head}', f'      {literal(row)}: $display("%s hit", tag);', '      default: $display("%s miss", tag);',
             '    endcase', '  endtask', '  initial begin']
    lines += [f"    check(\"{tag}\", 8'b{value});" for tag, value in selectors(row)]
    lines += ['  end', 'endmodule']
    return '\n'.join(lines)


STATEMENT_CLAUSE = {'case': '12.5', 'casez': '12.5 12.5.1', 'casex': '12.5 12.5.1', 'inside': '12.5.4 11.4.13 11.4.6'}


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'A case item with ?, z or x digits matches by the literal and case rules',
                f'5.7.1 {STATEMENT_CLAUSE[row[4]]}',
                'One case item is a binary, octal, hexadecimal or decimal literal with ?, z or x digits, written '
                'with a wildcard or a known leftmost digit, in 6, 8 or 12 bits or unsized. A leftmost x or z '
                'digit pads the literal to its size with that value; the case then extends every expression to '
                'the widest with zeros. An 8-bit selector is compared by case, casez, casex and case inside with '
                'the wildcard bits filled, one known bit flipped, one known bit made z or x, and the item\'s own '
                'four-state bits.',
                source(row), reference(row), fourstate=True,
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
