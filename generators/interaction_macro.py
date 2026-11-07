"""A text macro expands as text where it is used, so its operands bind by position."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_macro'
VERSION = 1
CHAPTER = 22

ACTUAL = {'simple': '3', 'low': '1 | 6', 'brace': "{2'b01, 2'b10}", 'cond': '1 ? 2 : 3'}
# The value of `body` with `actual` put in as text, times 3 outside the macro:
# bare is A + 1 * 3, wrap is ((A) + 1) * 3 and twice is A + 1 + A * 3.
VALUE = {('bare', 'simple'): 6, ('bare', 'low'): 9, ('bare', 'brace'): 9, ('bare', 'cond'): 2,
         ('wrap', 'simple'): 12, ('wrap', 'low'): 24, ('wrap', 'brace'): 21, ('wrap', 'cond'): 9,
         ('twice', 'simple'): 13, ('twice', 'low'): 27, ('twice', 'brace'): 25, ('twice', 'cond'): 2}
TEXT_FORMS = ('string', 'quote')


def legal(row: Row) -> bool:
    form, body, actual, context, _ = row
    if form in TEXT_FORMS: return body == 'bare' and context == 'show'
    if form == 'paste': return actual == 'simple'
    return True


MODEL = Model(
    'macro_expansion_context',
    (('form', ('function', 'object', 'omit', 'empty', 'second', 'late', 'actual', 'lines',
               'paste', 'string', 'quote')),
     ('body', ('bare', 'wrap', 'twice')),
     ('actual', tuple(ACTUAL)),
     ('context', ('assign', 'case', 'func', 'show', 'pkg', 'ifc', 'gen', 'cls', 'fork', 'dim', 'member')),
     ('arrange', ('unit', 'other', 'same', 'redefine', 'undef', 'elsif', 'ifndef'))),
    legal,
    anchors=(('function', 'bare', 'low', 'show', 'unit'),
             ('function', 'wrap', 'low', 'show', 'unit'),
             ('late', 'twice', 'cond', 'gen', 'same'),
             ('omit', 'wrap', 'brace', 'pkg', 'other'),
             ('actual', 'bare', 'low', 'case', 'redefine'),
             ('lines', 'twice', 'brace', 'dim', 'elsif'),
             ('paste', 'wrap', 'simple', 'cls', 'ifndef'),
             ('string', 'bare', 'brace', 'show', 'undef'),
             ('quote', 'bare', 'cond', 'show', 'same')),
    constraints=('本体を括弧で囲む形・囲まない形・仮引数を二度使う形に、優先順位の低い実引数を置き、外側の演算子との結合を値で確かめる。'
                 '実引数の中のカンマは波括弧の中に置く。'
                 'トークンの連結で作る識別子は単純な実引数だけ、文字列化で作る文字列は表示の文脈だけに置く。'
                 '内側のマクロは外側の定義より後に定義し、使う時点の定義で展開されることを確かめる。'
                 'マクロの定義はコンパイル単位の先頭、別のモジュール、使う要素の中に置き、再定義・undef・elsif・ifndefで選ぶ。'
                 '選ばれない枝には未定義のマクロと対応しないキーワードを置くが、字句としては正しくする。'
                 '__LINE__と__FILE__は別のテストに任せる。シミュレータの未対応による除外はしない。',),
    max_rows=12000,
)


def case_name(row: Row) -> str: return 'test_gen_cross_macro_' + '_'.join(row)


def body_text(body: str, x: str, one: str = '1') -> str:
    return {'bare': f'{x} + {one}', 'wrap': f'(({x}) + {one})', 'twice': f'{x} + {one} + {x}'}[body]


def core(row: Row) -> list[str]:
    """The definition of M and of the macros it needs, one line for each."""
    form, body, actual = row[:3]
    a = ACTUAL[actual]
    return {
        'function': lambda: [f'`define M(x) {body_text(body, "x")}'],
        'object': lambda: [f'`define ARG {a}', f'`define M {body_text(body, "`ARG")}'],
        'omit': lambda: [f'`define M(x={a}) {body_text(body, "x")}'],
        'empty': lambda: [f'`define M(w, x={a}) {body_text(body, "x")}'],
        'second': lambda: [f'`define M(x, k=1) {body_text(body, "x", "k")}'],
        'late': lambda: ['`define M(x) `INNER(x)', f'`define INNER(y) {body_text(body, "y")}'],
        'actual': lambda: [f'`define V {a}', f'`define M(x) {body_text(body, "x")}'],
        'lines': lambda: ['`define M(x) ' + body_text(body, 'x').replace(' + 1', ' \\\n  /* note */ + 1', 1)
                          + ' // tail'],
        'paste': lambda: [f'`define M(x) {body_text(body, "VAL_``x")}'],
        'string': lambda: ['`define M(x) `"x`"'],
        'quote': lambda: ['`define M(x) `"v=`\\`"x`\\`"`"'],
    }[form]()


def definitions(row: Row) -> list[str]:
    arrange, lines = row[4], core(row)
    if arrange == 'redefine': return ['`define M(x) 99 + x', *lines]
    if arrange == 'undef':
        return ['`define M 98', '`undef M', '`ifdef M', '`define M 97', '`else', *lines, '`endif']
    if arrange == 'elsif':
        return ['`define OK_FLAG', '`ifdef NO_FLAG', '`NOT_DEFINED endcase', '`elsif OK_FLAG', *lines,
                '`else', '`define M 96', '`endif']
    if arrange == 'ifndef':
        return ['`ifndef M_GUARD', '`define M_GUARD', *lines, '`endif', '`ifndef M_GUARD', '`define M 95', '`endif']
    return lines


def use(row: Row) -> str:
    form, actual = row[0], ACTUAL[row[2]]
    text = {'object': '`M', 'omit': '`M()', 'empty': '`M(, )', 'actual': '`M(`V)'}.get(form, f'`M({actual})')
    return text if form in TEXT_FORMS else text + ' * 3'


def value(row: Row) -> int:
    return VALUE[row[1], 'simple' if row[0] == 'paste' else row[2]]


def reference(row: Row) -> str:
    form, actual, context = row[0], ACTUAL[row[2]], row[3]
    if form == 'string': return actual + '\n'
    if form == 'quote': return f'v="{actual}"\n'
    return '1\n' if context == 'case' else f'{value(row)}\n'


def source(row: Row) -> str:
    form, _, _, context, arrange = row
    name, expr = case_name(row), use(row)
    defs = definitions(row)
    same = defs if arrange == 'same' else []
    local = ['localparam int VAL_3 = 3;'] if form == 'paste' else []
    format_ = '%s' if form in TEXT_FORMS else '%0d'
    out = list(defs) if arrange not in ('other', 'same') else []
    if arrange == 'other': out += ['module macro_defs;', *defs, 'endmodule']
    inner: list[str] = []
    if context == 'pkg':
        out += ['package macro_pk;', *same, *local, f'  parameter int P = {expr};', 'endpackage']
        inner = ['initial $display("%0d", macro_pk::P);']
    elif context == 'ifc':
        out += ['interface macro_ifc;', *same, *local, '  int y;', f'  assign y = {expr};', 'endinterface']
        inner = ['macro_ifc i ();', 'initial #1 $display("%0d", i.y);']
    elif context == 'cls':
        out += ['class macro_cls;', *same, *local, '  static function int m();', f'    return {expr};',
                '  endfunction', 'endclass']
        inner = ['initial $display("%0d", macro_cls::m());']
    elif context == 'assign':
        inner = ['int y;', f'assign y = {expr};', 'initial #1 $display("%0d", y);']
    elif context == 'case':
        inner = [f'int v = {value(row)};', 'int hit;', 'initial begin', '  case (v)', f'    {expr}: hit = 1;',
                 '    default: hit = 0;', '  endcase', '  $display("%0d", hit);', 'end']
    elif context == 'func':
        inner = ['function automatic int f();', f'  return {expr};', 'endfunction', 'initial $display("%0d", f());']
    elif context == 'show':
        inner = [f'initial $display("{format_}", {expr});']
    elif context == 'gen':
        inner = [f'if (({expr}) > 0) begin : g', f'  localparam int y = {expr};', 'end',
                 'initial $display("%0d", g.y);']
    elif context == 'fork':
        inner = ['int y;', 'initial begin', '  fork', f'    y = {expr};', '  join', '  $display("%0d", y);', 'end']
    elif context == 'dim':
        inner = [f'logic [({expr}) - 1:0] v;', 'initial $display("%0d", $bits(v));']
    elif context == 'member':
        inner = ['typedef struct { int m; int n; } st;', f"st t = '{{m: {expr}, n: 5}};",
                 'initial $display("%0d", t.m);']
    in_module = context not in ('pkg', 'ifc', 'cls')
    out += [f'module {name};', *(same if in_module else []), *(local if in_module else []),
            *['  ' + line for line in inner], 'endmodule']
    return '\n'.join(out)


CONTEXT_CLAUSE = {'assign': '10.3.2', 'case': '12.5', 'func': '13.4', 'show': '21.2.1', 'pkg': '26.2',
                  'ifc': '25.3', 'gen': '27.5', 'cls': '8.10', 'fork': '9.3.2', 'dim': '20.6.2', 'member': '7.2'}
ARRANGE_CLAUSE = {'undef': ' 22.5.2 22.6', 'elsif': ' 22.6', 'ifndef': ' 22.6'}


def make_case(row: Row) -> Case:
    extra = {'interaction_model': f'{MODEL.name}@{MODEL.version}',
             'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())}
    if row[4] == 'other': extra['top_module'] = case_name(row)
    return Case(case_name(row), 'A text macro expands as text where it is used, so its operands bind by position',
                f'22.5.1{ARRANGE_CLAUSE.get(row[4], "")} 11.3.2 {CONTEXT_CLAUSE[row[3]]}',
                'The macro text and the actual argument are substituted as text, so an operator outside '
                'the macro and a low-precedence argument bind by where they land, and an argument used '
                'twice is evaluated twice. A default fills an omitted or empty argument, a macro used '
                'inside another expands when it is used, and the latest definition read prevails. A '
                'definition reaches the rest of the compilation unit, even from another design element, '
                'and an inactive conditional block is not compiled.',
                source(row), reference(row), extra=extra)


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
