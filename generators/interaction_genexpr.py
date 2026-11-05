"""Typed constant expressions determine generated branches, counts and widths."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row
from interaction_genloop import flipped

NAME = 'interaction_genexpr'
VERSION = 1
CHAPTER = 27
MODEL = Model(
    'generated_constant_expression_shape',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('left_sign', ('s', 'u')), ('right_sign', ('s', 'u')),
     ('result_sign', ('s', 'u')), ('context', ('same', 'wide')),
     ('operation', ('add', 'xor', 'conditional')), ('form', ('if', 'case')),
     ('binding', ('named', 'positional'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('width', 'left_sign', 'context'),
            ('left_sign', 'right_sign', 'operation'), ('result_sign', 'context', 'operation'),
            ('operation', 'form', 'binding'), ('width', 'right_sign', 'operation')),
    anchors=(('1', 'bit', 'known', 's', 's', 's', 'wide', 'add', 'if', 'named'),
             ('129', 'logic', 'z', 's', 'u', 's', 'wide', 'conditional', 'case', 'positional'),
             ('65', 'logic', 'x', 'u', 's', 'u', 'same', 'xor', 'if', 'positional'),
             ('33', 'bit', 'z', 's', 's', 's', 'wide', 'xor', 'case', 'named'),
             ('32', 'logic', 'known', 's', 'u', 's', 'wide', 'add', 'case', 'named'),
             ('64', 'logic', 'known', 's', 's', 'u', 'same', 'conditional', 'if', 'positional')),
    constraints=('全行が合法で未対応による除外なし。二moduleのSELECTは0/1で、'
                 '定数Aは最上位ビットだけが1または値1、Bは全ビット1。両オペランドの幅は基底幅で独立に符号を選ぶ。'
                 '加算・XOR・条件演算子の結果は基底幅または一つ広い型付きlocalparamへ格納する。'
                 '式は両オペランドがsignedのときだけ符号拡張し、結果の宣言符号とは区別する。'
                 '格納後の負判定がif/case generateを選び、最上位と最下位のビットが生成個数1から4を決める。'
                 '$bitsの剰余が生成幅を決め、genvarでさらに幅を変える。各要素は独立したraw・guard・連続代入結果を持つ。'
                 '既知・既知またはX/Z・既知への回復の三相で全要素を読み、一方の先頭入力と他方の末尾guardだけを更新する。'
                 'X/Zは実行時刺激だけに使い、定数式とgenerate条件は既知値。bitへの変換でもfourstateを指定する。'
                 'config・defparam・未定義の階層参照・動的な生成添字・符号付きruntime演算は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_genexpr_' + '_'.join(row)


def constants(row: Row, slot: int) -> dict[str, int | str]:
    width, wide = int(row[0]), row[6] == 'wide'
    cw = width + int(wide)
    a, b = (1 if slot else 1 << (width - 1)), (1 << width) - 1
    signed = row[3] == row[4] == 's'
    def extend(value):
        if signed and value & (1 << (width - 1)):
            value -= 1 << width
        return value
    aa, bb = extend(a), extend(b)
    value = aa + bb if row[7] == 'add' else aa ^ bb if row[7] == 'xor' else aa if slot else bb
    value &= (1 << cw) - 1
    negative = int(row[5] == 's' and bool(value & (1 << (cw - 1))))
    return dict(a=format(a, f'0{width}b'), b=format(b, f'0{width}b'), e=format(value, f'0{cw}b'),
                dec=value - (1 << cw) if negative else value, neg=negative,
                count=1 + (value & 1) + 2 * ((value >> (cw - 1)) & 1),
                width=width + 1 + cw % 3, bits=cw, kind=negative, tag=3 if negative else 5)


def word(width: int, phase: int, slot: int, lane: int, unknown='known') -> str:
    bits = list((('10' if (slot + lane + phase) % 2 == 0 else '01') * width)[:width])
    bits[-1] = str((lane + phase) % 2)
    if width > 1: bits[-2] = str((lane // 2) % 2)
    if unknown != 'known':
        for index in {0, width // 2, width - 1}: bits[index] = unknown
    return ''.join(bits)


def reference(row: Row) -> str:
    info = [constants(row, slot) for slot in range(2)]
    states, lines = {}, []
    for slot, c in enumerate(info):
        for lane in range(c['count']):
            width = c['width'] + lane
            states[slot, lane] = ['', word(width, 0, slot, lane + 1)]
    def snapshot(phase, label):
        for slot, c in enumerate(info):
            lines.append(f'h p={phase} step={label} id={slot} a={c["a"]} b={c["b"]} e={c["e"]} dec={c["dec"]}')
            lines.append(f'q id={slot} ' + ' '.join(f'{key}={c[key]}' for key in ('neg', 'count', 'width', 'bits', 'kind')))
            for lane in range(c['count']):
                raw, guard = states[slot, lane]
                width = len(raw); mask = format((c['tag'] + lane) & ((1 << width) - 1), f'0{width}b')
                value = ''.join(str(int(a) ^ int(b)) if a in '01' else 'x' for a, b in zip(raw, mask))
                lines.append(f'v id={slot} lane={lane} bits={width} raw={raw} guard={guard} value={value}')
    for phase in range(3):
        for (slot, lane), values in states.items():
            width = info[slot]['width'] + lane
            values[0] = assigned(word(width, phase, slot, lane, row[2] if phase == 1 else 'known'), width, row[1])
        snapshot(phase, 'all')
        states[0, 0][0] = flipped(states[0, 0][0]); snapshot(phase, 'input')
        last = info[1]['count'] - 1
        states[1, last][1] = flipped(states[1, last][1]); snapshot(phase, 'guard'); snapshot(phase, 'idle')
    return '\n'.join(lines) + '\n'


def branch(row: Row, kind: int) -> list[str]:
    return [f'    localparam int KIND={kind}, TAG={3 if kind else 5};',
            '    for (genvar lane=0; lane<COUNT; lane++) begin:g',
            f'      typedef {row[1]} [WIDTH+lane-1:0] word_t;', '      word_t raw, guard;',
            '      wire [WIDTH+lane-1:0] value;', "      assign value=raw ^ word_t'(TAG+lane);", '    end']


def source(row: Row) -> str:
    w = int(row[0]); cw = w + int(row[6] == 'wide')
    sign = lambda key: 'signed' if row[key] == 's' else 'unsigned'
    expr = {'add': 'A + B', 'xor': 'A ^ B', 'conditional': 'SELECT ? A : B'}[row[7]]
    lines = ['`timescale 1ns/1ns', 'module shape_worker #(parameter int SELECT=0);',
             f'  localparam int BASE={w}, CW={cw};',
             f'  typedef logic {sign(3)} [BASE-1:0] left_t;',
             f'  typedef logic {sign(4)} [BASE-1:0] right_t;',
             f'  typedef logic {sign(5)} [CW-1:0] result_t;',
             "  localparam left_t A = SELECT ? left_t'(1) : left_t'(1) << (BASE-1);",
             "  localparam right_t B = '1;", f'  localparam result_t E = {expr};',
             '  localparam bit NEG = E < 0;', "  localparam int COUNT=1+int'(E[0])+2*int'(E[CW-1]);",
             '  localparam int WIDTH=BASE+1+($bits(E)%3);']
    if row[8] == 'if':
        lines += ['  if (NEG) begin:choice', *branch(row, 1), '  end else begin:choice', *branch(row, 0), '  end']
    else:
        lines += ['  case (NEG)', '    1: begin:choice', *branch(row, 1), '    end',
                  '    default: begin:choice', *branch(row, 0), '    end', '  endcase']
    lines += ['endmodule', f'module {case_name(row)};']
    for slot, name in enumerate(('a', 'b')):
        actual = f'.SELECT({slot})' if row[9] == 'named' else str(slot)
        lines.append(f'  shape_worker #({actual}) {name}();')
    lines.append('  initial begin')
    info = [constants(row, slot) for slot in range(2)]
    for slot, name in enumerate(('a', 'b')):
        c = info[slot]
        for lane in range(c['count']):
            lines.append(f'    {name}.choice.g[{lane}].guard={literal(word(c["width"] + lane, 0, slot, lane + 1))};')
    def snapshot(phase, label):
        nonlocal lines
        for slot, name in enumerate(('a', 'b')):
            c = info[slot]
            lines += [f'    $display("h p={phase} step={label} id={slot} a=%b b=%b e=%b dec=%0d", {name}.A, {name}.B, {name}.E, {name}.E);',
                      f'    $display("q id={slot} neg=%0d count=%0d width=%0d bits=%0d kind=%0d",',
                      f'      {name}.NEG, {name}.COUNT, {name}.WIDTH, $bits({name}.E), {name}.choice.KIND);']
            for lane in range(c['count']):
                p = f'{name}.choice.g[{lane}]'
                lines += [f'    $display("v id={slot} lane={lane} bits=%0d raw=%b guard=%b value=%b",',
                          f'      $bits({p}.raw), {p}.raw, {p}.guard, {p}.value);']
    for phase in range(3):
        for slot, name in enumerate(('a', 'b')):
            c = info[slot]
            for lane in range(c['count']):
                bits = word(c['width'] + lane, phase, slot, lane, row[2] if phase == 1 else 'known')
                lines.append(f'    {name}.choice.g[{lane}].raw={literal(bits)};')
        lines += ['    #1;']; snapshot(phase, 'all')
        lines += ["    a.choice.g[0].raw=a.choice.g[0].raw ^ 1'b1;", '    #1;']; snapshot(phase, 'input')
        last = info[1]['count'] - 1
        lines += [f"    b.choice.g[{last}].guard=b.choice.g[{last}].guard ^ 1'b1;", '    #1;']; snapshot(phase, 'guard')
        lines += ['    #1;']; snapshot(phase, 'idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Typed constant expressions determine generated branch, count and per-element width',
                '27.4 27.5 11.8.2 11.4.3 11.4.4 11.4.8 11.4.11 20.6.2 6.11.2',
                'Independently signed operands form an add, XOR or conditional constant expression. '
                'Assignment context is the same width or one bit wider; the result declaration has '
                'independent signedness. The stored negative test selects if/case generate, its end '
                'bits determine loop count, and $bits determines element width. Two module SELECT '
                'values use named or positional overrides. Observe constants, decimal interpretation, '
                'branch identity, shape and full raw/guard/continuous-result words in every generated '
                'element. Known, X/Z and recovery phases change only one raw word and another guard. '
                'Constants and generate conditions remain known; runtime X/Z conversion is separate. '
                'No config, defparam, variable hierarchy indices or signed runtime arithmetic.',
                source(row), reference(row), fourstate=row[2] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
