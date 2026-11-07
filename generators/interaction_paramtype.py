"""A value parameter takes its type and range from its declaration or, without one, from the final override."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_paramtype'
VERSION = 1
CHAPTER = 23

DECLS = {'untyped': '', 'range': '[7:0] ', 'srange': 'signed [7:0] ', 'signed': 'signed ', 'int': 'int ',
         'logic': 'logic [3:0] ', 'struct': 'pair_t '}
# The text of each override value, its width, whether it is signed, and its value.
VALUES = {'sized': ("8'd200", 8, False, 200), 'ssized': ("-8'sd3", 8, True, -3),
          'narrow': ("4'b1010", 4, False, 10), 'wide': ("12'hf0f", 12, False, 0xf0f),
          'concat': ("{2'b11, 2'b01}", 4, False, 13), 'sum': ("8'd25 + 8'sd10", 8, False, 35)}
# A different first override, which a defparam replaces.
EARLIER = "16'd7"


def legal(row: Row) -> bool: return True


MODEL = Model(
    'parameter_override_type',
    (('decl', tuple(DECLS)), ('value', tuple(VALUES)),
     ('method', ('default', 'ordered', 'named', 'defparam', 'both', 'local'))),
    legal,
    anchors=(('untyped', 'wide', 'defparam'), ('signed', 'concat', 'both'), ('signed', 'narrow', 'default'),
             ('range', 'ssized', 'ordered'), ('int', 'ssized', 'named'), ('logic', 'sum', 'local'),
             ('struct', 'sized', 'defparam'), ('srange', 'sized', 'both')),
    constraints=('型も範囲もない値パラメータは最終的な上書きの値の型と範囲になり、範囲だけは符号なし、'
                 '型だけの符号付きは値の範囲になり、型と範囲があればその型と範囲へ変換する。'
                 'defparamは同じインスタンスの#()より優先し、そのときも型と範囲はdefparamの値から決まる。'
                 '上書きの式は、それ自身の幅で評価してから変換しても、パラメータの幅で評価しても同じ値になるものだけを使う。'
                 '無サイズの値は範囲が処理系依存なので使わない。'
                 'シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_paramtype_' + '_'.join(row)


def final_type(decl: str, value: str) -> tuple[int, bool, int]:
    """The width, sign and bits of the parameter after the override."""
    _, width, signed, number = VALUES[value]
    target = {'untyped': (width, signed), 'range': (8, False), 'srange': (8, True), 'signed': (width, True),
              'int': (32, True), 'logic': (4, False), 'struct': (8, False)}[decl]
    # Converting extends by the value's own sign, then keeps the low bits.
    bits = number % (1 << max(width, target[0]))
    return target[0], target[1], bits % (1 << target[0])


def signed_value(width: int, signed: bool, bits: int) -> int:
    return bits - (1 << width) if signed and bits >> width - 1 else bits


def reference(row: Row) -> str:
    decl, value, _ = row
    width, signed, bits = final_type(decl, value)
    number = signed_value(width, signed, bits)
    lines = [f'P={number} bits={width} neg={int(number < 0)}']
    if decl == 'struct':
        lines.append(f'hi={signed_value(4, True, bits >> 4)} lo={bits & 0xf}')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    decl, value, method = row
    text = VALUES[value][0]
    default = text if method == 'default' else "1'b0"
    lines = []
    if decl == 'struct': lines.append('typedef struct packed { logic signed [3:0] hi; logic [3:0] lo; } pair_t;')
    lines += [f'module param_child #(parameter {DECLS[decl]}P = {default}) ();', '  initial begin', '    #1;',
              '    $display("P=%0d bits=%0d neg=%0d", P, $bits(P), P < 0);']
    if decl == 'struct': lines.append('    $display("hi=%0d lo=%0d", P.hi, P.lo);')
    lines += ['  end', 'endmodule', f'module {case_name(row)};']
    if method == 'local': lines.append(f'  localparam L = {text};')
    instance = {'default': 'param_child u ();', 'ordered': f'param_child #({text}) u ();',
                'named': f'param_child #(.P({text})) u ();', 'defparam': 'param_child u ();',
                'both': f'param_child #(.P({EARLIER})) u ();', 'local': 'param_child #(.P(L)) u ();'}[method]
    lines.append('  ' + instance)
    if method in ('defparam', 'both'): lines.append(f'  defparam u.P = {text};')
    lines += ['  initial #2 $finish;', 'endmodule']
    return '\n'.join(lines)


METHOD_CLAUSE = {'default': '6.20.2', 'ordered': '23.10.2.1', 'named': '23.10.2.2', 'defparam': '23.10.1',
                 'both': '23.10.1 23.10.2.2', 'local': '23.10.2.2 6.20.4'}
VALUE_CLAUSE = {'sized': '5.7.1', 'ssized': '11.4.3', 'narrow': '5.7.1', 'wide': '5.7.1', 'concat': '11.4.12',
                'sum': '11.4.3 11.8.1'}


def make_case(row: Row) -> Case:
    decl, value, method = row
    struct = ' 7.2.1' if decl == 'struct' else ''
    return Case(case_name(row), 'A value parameter takes its type and range from its declaration or the final override',
                f'23.10 6.20.2 {METHOD_CLAUSE[method]} {VALUE_CLAUSE[value]}{struct}',
                'A value parameter without a type or range takes the type and range of the final value '
                'assigned to it, after all overrides. A range alone makes it unsigned, a signed type alone '
                'keeps the range of the value, and a type with a range converts the value to both. A '
                'defparam wins over a value given in the instantiation, and then the type also comes from the '
                'defparam. Each value is the same whether it is evaluated at its own width or at the width of '
                'the parameter, so only the declaration decides the result.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
