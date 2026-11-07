"""Literal forms keep their bits and sign through carriers and expression context."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_literal'
VERSION = 1
CHAPTER = 5


def legal(row: Row) -> bool:
    base, sign, fit, top, context, _, _ = row
    if base == 'fill' and (sign != 'unsigned' or fit != 'unsized'): return False
    if base == 'd' and top in 'xz' and fit not in ('narrow', 'unsized'): return False
    # The width of an unsized number above 32 is implementation-defined. Only an
    # unknown leading digit makes it visible, by what a right shift brings in.
    if base != 'fill' and fit == 'unsized' and context == 'ashr' and top in 'xz': return False
    return True


MODEL = Model(
    'literal_context_extension',
    (('base', ('b', 'o', 'd', 'h', 'fill')), ('sign', ('unsigned', 'signed')),
     ('fit', ('narrow', 'exact', 'truncate', 'unsized')), ('top', ('zero', 'one', 'x', 'z')),
     ('context', ('assign', 'add_signed', 'add_unsigned', 'cond', 'negate', 'ashr')),
     ('target', ('logic', 'signed', 'bit')), ('width', ('8', '33', '65'))),
    legal,
    groups=(('sign', 'top', 'context'), ('base', 'fit', 'top'), ('sign', 'context', 'width')),
    anchors=(('h', 'signed', 'truncate', 'one', 'negate', 'logic', '65'),
             ('b', 'unsigned', 'narrow', 'x', 'assign', 'signed', '33'),
             ('o', 'signed', 'exact', 'z', 'ashr', 'logic', '33'),
             ('d', 'signed', 'unsized', 'x', 'cond', 'bit', '65'),
             ('fill', 'unsigned', 'unsized', 'one', 'add_signed', 'logic', '65'),
             ('fill', 'unsigned', 'unsized', 'x', 'assign', 'bit', '8'),
             ('h', 'unsigned', 'unsized', 'x', 'assign', 'logic', '65'),
             ('b', 'unsigned', 'unsized', 'z', 'cond', 'signed', '33')),
    constraints=('文法に合わない形（unbasedのs・サイズ、xやzを複数桁に含む10進）を除外する。'
                 '32ビットを超える無サイズ数は幅が処理系依存なので、桁はすべて32ビット以内に収める。'
                 '先頭がxまたはzの無サイズ数の右シフトは、その幅が結果に現れるので除外する。'
                 '先頭がxまたはzの符号なし無サイズ数は式の幅まで同じ値で広がる（5.7.1の例4）。'
                 '同じリテラルをinitial内の直接の記述・型なしlocalparam・三字句のマクロ展開・continuous assignで運ぶ。'
                 'localparamはリテラル自身の幅になるので、unbased unsizedは1ビットとして広がる。'
                 'bitの代入先ではX/Zを0へ変換する。continuous assignの網は4値のまま観測する。'
                 '無サイズ数の$bitsは「少なくとも32」で値が定まらないので観測しない。',),
)

SIZE = {'b': 6, 'o': 6, 'd': 6, 'h': 12}
STEP = {'b': 1, 'o': 3, 'h': 4}
DIGIT = {'x': {'b': 'x', 'o': 'X', 'h': 'X', 'd': 'x'}, 'z': {'b': 'z', 'o': '?', 'h': 'Z', 'd': '?'}}
# Pattern of known bits, most significant first, for the digits below the top.
PATTERN = '0101100101101001'
MATE = 3


def case_name(row: Row) -> str: return 'test_gen_cross_literal_' + '_'.join(row)


def group(bits: str, base: str) -> str:
    step = STEP[base]
    assert len(bits) % step == 0
    return ''.join(format(int(bits[i:i + step], 2), 'x') for i in range(0, len(bits), step))


def parts(row: Row):
    """The size, base and digit tokens and the bits of the literal, MSB first."""
    base, sign, fit, top = row[:4]
    if base == 'fill':
        digit = {'zero': '0', 'one': '1', 'x': 'x', 'z': 'z'}[top]
        return '', "'" + digit, '', digit, False
    marker = "'" + ('s' if sign == 'signed' else '') + base
    signed = sign == 'signed'
    if base == 'd':
        if top in 'xz':
            bits = top * (SIZE['d'] if fit == 'narrow' else 32)
            return (str(SIZE['d']) if fit == 'narrow' else ''), marker, DIGIT[top]['d'], bits, signed
        chosen = {('narrow', 'zero'): 2, ('narrow', 'one'): 5, ('exact', 'zero'): 13, ('exact', 'one'): 45,
                  ('truncate', 'zero'): 141, ('truncate', 'one'): 173, ('unsized', 'zero'): 13,
                  ('unsized', 'one'): 45}[fit, top]
        width = 32 if fit == 'unsized' else SIZE['d']
        bits = format(chosen % (1 << width), f'0{width}b')
        if fit == 'unsized' and signed and top == 'zero': return '', '', str(chosen), bits, True
        return (str(SIZE['d']) if fit != 'unsized' else ''), marker, str(chosen), bits, signed
    size, step = SIZE[base], STEP[base]
    if fit in ('narrow', 'unsized'):
        count = 3 if base == 'b' else step
        if top in 'xz':
            tail = PATTERN[:count - step]
            text = DIGIT[top][base] + (group(tail, base) if tail else '')
            low, fill = top * step + tail, top
        else:
            low, fill = ('1' if top == 'one' else '0') + PATTERN[:count - 1], '0'
            text = group(low, base)
        total = 32 if fit == 'unsized' else size
        return ('' if fit == 'unsized' else str(size)), marker, text, low.rjust(total, fill), signed
    # Exact digits have the top digit first. Truncated digits add one digit whose
    # value differs from the kept part, so the kept top decides the sign.
    extra = step if fit == 'truncate' else 0
    if top in 'xz':
        tail = PATTERN[:size - step]
        kept = top * step + tail
        text = DIGIT[top][base] + group(tail, base)
    else:
        tail = PATTERN[:size - 1]
        kept = ('1' if top == 'one' else '0') + tail
        text = group(kept, base)
    if extra: text = {'x': '0', 'z': '1', 'zero': DIGIT['x'][base], 'one': DIGIT['z'][base]}[top] + text
    return str(size), marker, text, kept, signed


def literal_text(row: Row) -> str:
    size, marker, digits, *_ = parts(row)
    return size + marker + digits


def extend(bits: str, signed: bool, width: int) -> str:
    if len(bits) >= width: return bits[-width:]
    return bits.rjust(width, bits[0] if signed else '0')


def known(bits: str) -> bool: return set(bits) <= set('01')


def to_bits(value: int, width: int) -> str: return format(value % (1 << width), f'0{width}b')


def grows(row: Row) -> bool:
    """An unsized unsigned number led by x or z extends to the expression's size (5.7.1)."""
    return row[0] != 'fill' and row[2] == 'unsized' and row[1] == 'unsigned' and row[3] in 'xz'


def evaluate(row: Row, bits: str, signed: bool, target_width: int, carried: bool = False) -> str:
    """The context-determined value of the expression, cut to the target's width.

    A value carried by a localparam is an ordinary vector of its own width.
    """
    context = row[4]
    width = max(target_width, len(bits), 1)
    if grows(row) and not carried: bits = bits.rjust(width, bits[0])
    if context == 'assign': return extend(bits, signed, target_width)
    if context in ('add_signed', 'add_unsigned'):
        kind = signed and context == 'add_signed'
        left = extend(bits, kind, width)
        if not known(left): return 'x' * target_width
        return to_bits(int(left, 2) + MATE, width)[-target_width:]
    if context == 'cond':
        # The false arm is a signed variable, so only the literal's own sign counts.
        return extend(extend(bits, signed, width), False, target_width)
    if context == 'negate':
        operand = extend(bits, signed, width)
        if not known(operand): return 'x' * target_width
        return to_bits(-int(operand, 2), width)[-target_width:]
    operand = extend(bits, signed, width)
    fill = operand[0] if signed else '0'
    return (fill + operand[:-1])[-target_width:]


def convert(bits: str, target: str) -> str:
    return bits.replace('x', '0').replace('z', '0') if target == 'bit' else bits


def expression(row: Row, operand: str) -> str:
    return {'assign': operand, 'add_signed': f'{operand} + sv', 'add_unsigned': f'{operand} + uv',
            'cond': f'c ? {operand} : sv', 'negate': f'-{operand}', 'ashr': f'{operand} >>> 1'}[row[4]]


def reference(row: Row) -> str:
    size, marker, digits, bits, signed = parts(row)
    width = int(row[6])
    lines = []
    for label in 'dpm':
        if row[0] == 'fill' and label != 'p': result = fill_value(row, width)
        else: result = evaluate(row, bits, signed, width, label == 'p')
        lines.append(f'{label} {convert(result, row[5])}')
    wired = fill_value(row, width) if row[0] == 'fill' else evaluate(row, bits, signed, width)
    lines.append(f'w {wired}')
    if row[0] == 'fill' or row[2] != 'unsized': lines.append(f's {1 if row[0] == "fill" else int(size)}')
    return '\n'.join(lines) + '\n'


def fill_value(row: Row, width: int) -> str:
    """An unbased unsized literal takes the context width, with every bit set to its digit."""
    digit = parts(row)[3]
    context = row[4]
    if context == 'assign': return digit * width
    size = max(width, 1)
    if context in ('add_signed', 'add_unsigned'):
        if digit in 'xz': return 'x' * width
        return to_bits(int(digit * size, 2) + MATE, size)[-width:]
    if context == 'cond': return digit * width
    if context == 'negate':
        if digit in 'xz': return 'x' * width
        return to_bits(-int(digit * size, 2), size)[-width:]
    return ('0' + digit * (size - 1))[-width:]


def source(row: Row) -> str:
    size, marker, digits, *_ = parts(row)
    width = int(row[6])
    high = width - 1
    target = {'logic': f'logic [{high}:0]', 'signed': f'logic signed [{high}:0]', 'bit': f'bit [{high}:0]'}[row[5]]
    net = f'wire signed [{high}:0]' if row[5] == 'signed' else f'wire [{high}:0]'
    text = size + marker + digits
    tokens = []
    if size: tokens.append(('SZ', size))
    if marker: tokens.append(('BS', marker))
    if digits: tokens.append(('DG', digits))
    lines = [f'`define {name} {value}' for name, value in tokens]
    macro = ' '.join('`' + name for name, _ in tokens)
    lines += [f'module {case_name(row)};', f'  localparam lp = {text};', f'  {target} t;',
              f'  logic signed [{high}:0] sv = {MATE};', f'  logic [{high}:0] uv = {MATE};', "  logic c = 1'b1;",
              f'  {net} w;', f'  assign w = {expression(row, text)};', '  initial begin', '    #1;',
              f'    t = {expression(row, text)};', '    $display("d %b", t);',
              f'    t = {expression(row, "lp")};', '    $display("p %b", t);',
              f'    t = {expression(row, macro)};', '    $display("m %b", t);', '    $display("w %b", w);']
    if row[0] == 'fill' or row[2] != 'unsized': lines.append(f'    $display("s %0d", $bits({text}));')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'A literal keeps its bits and sign through carriers and expression context',
                '5.7.1 5.8 6.20.2 10.3.2 11.3.3 11.4.10 11.6.1 11.8.1 11.8.2 22.5.1 20.6.2',
                'One literal spelled by base, sign designator, digit count and leading digit is used '
                'directly, through an untyped localparam, through macro-substituted tokens and in a '
                'continuous assignment. Padding comes from the literal rules, then the expression '
                'context widens the operand by its sign, and the assignment cuts it to the target. '
                'An unsized unsigned number led by X or Z extends to the size of the expression, and '
                'an unbased unsized literal fills it, while a localparam holds either at its own '
                'width. A bit target turns X and Z to 0, and the net keeps them.',
                source(row), reference(row), fourstate=any(c in literal_text(row).lower() for c in 'xz?'),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
