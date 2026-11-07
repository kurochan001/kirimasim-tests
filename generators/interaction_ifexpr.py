"""An interface member keeps its type on every access path, and statements share its storage."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_ifexpr'
VERSION = 1
CHAPTER = 25

# The declaration of v, its width, sign and bits.
DECLS = {'s8': ('logic signed [7:0]', "8'shfa", 8, True), 'u8': ('logic [7:0]', "8'hfa", 8, False),
         's4': ('logic signed [3:0]', "4'sha", 4, True)}
# Each expression, with V for the operand.
EXPRS = {'div': 'V / 4', 'shift': 'V >>> 2', 'mixed': "V + 1'b0", 'part': 'V[3:0]', 'cmp': '(V < 0)',
         'neg': '-V', 'mul': "V * 2'sb11"}
START = 3
ARRAY = (1, 2, 3)


def legal(row: Row) -> bool: return True


MODEL = Model(
    'interface_member_expression',
    (('path', ('port', 'modport', 'generic', 'element', 'hier')), ('decl', tuple(DECLS)),
     ('expr', tuple(EXPRS)), ('stmt', ('if', 'case', 'repeat', 'while', 'for', 'do', 'foreach')),
     ('update', ('direct', 'compound', 'task', 'inside'))),
    legal,
    anchors=(('modport', 'u8', 'mul', 'repeat', 'task'), ('generic', 's4', 'mixed', 'foreach', 'inside'),
             ('element', 's8', 'shift', 'while', 'compound'), ('hier', 'u8', 'neg', 'if', 'direct'),
             ('port', 's4', 'part', 'do', 'task'), ('modport', 's8', 'cmp', 'case', 'inside'),
             ('generic', 'u8', 'div', 'for', 'direct')),
    constraints=('vは同じビット8hfa（4ビットはha）を符号付き8・符号なし8・符号付き4ビットで宣言し、'
                 'インタフェースのポート・modport・総称インタフェース・インタフェース配列の要素・階層名から読む。'
                 '式の幅と符号は経路で変わらず、宣言の型と演算子の規則で決まる。'
                 '更新は直接代入・複合代入・modportでimportしたtask（引数で値を渡す）・'
                 'インタフェースの中で式を計算するtaskのどれでも結果が同じになる。'
                 '文の制御はインタフェースのnを経路から読み、更新のたびにnを1減らす。repeatは回数を一度だけ評価する。'
                 'Icarus 13.0はインタフェースのポートを解析できないが、シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_ifexpr_' + '_'.join(row)


def operand(decl: str) -> int:
    """The value of v as the expression sees it, before sizing."""
    _, _, width, signed = DECLS[decl]
    bits = 0xfa & (1 << width) - 1
    return bits - (1 << width) if signed and bits >> width - 1 else bits


def term(decl: str, expr: str) -> int:
    """What one update adds to acc, as a 16-bit signed number."""
    _, _, width, signed = DECLS[decl]
    v = operand(decl)
    raw = v & (1 << width) - 1
    if expr == 'div':
        # 4 is a signed integer: signed division truncates toward zero.
        value = int(v / 4) if signed else raw // 4
    elif expr == 'shift':
        # The left operand is extended to the width of the context first.
        value = v >> 2 if signed else raw >> 2
    elif expr == 'mixed':
        value = raw
    elif expr == 'part':
        value = raw & 0xf
    elif expr == 'cmp':
        value = 1 if signed and v < 0 else 0
    elif expr == 'neg':
        value = -v if signed else -raw
    else:
        # 2'sb11 is -1 when the expression is signed and 3 when it is not.
        value = v * -1 if signed else raw * 3
    value &= 0xffff
    return value - 0x10000 if value >> 15 else value


def updates(row: Row) -> int:
    """How many updates the statement runs."""
    _, decl, _, stmt, _ = row
    n, count = START, 0
    if stmt == 'if':
        return 1 if DECLS[decl][3] else 3
    if stmt == 'case':
        return 2
    if stmt == 'repeat':
        return START
    if stmt == 'while':
        while n > 1: n, count = n - 1, count + 1
        return count
    if stmt == 'for':
        i = 0
        while i < n: n, count, i = n - 1, count + 1, i + 1
        return count
    if stmt == 'do':
        while True:
            n, count = n - 1, count + 1
            if not n > 2: return count
    for element in ARRAY:
        if element <= n: n, count = n - 1, count + 1
    return count


def reference(row: Row) -> str:
    path, decl, expr, _, _ = row
    count = updates(row)
    total = (count * term(decl, expr)) & 0xffff
    acc = total - 0x10000 if total >> 15 else total
    n = START - count
    lines = [f'user acc={acc} n={n}', f'top acc={acc} n={n}']
    if path == 'element': lines.append('other acc=0 n=3')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    path, decl, expr, stmt, update = row
    name = case_name(row)
    kind, init, _, _ = DECLS[decl]
    ifc = 'member_if'
    ref = 'i0' if path == 'hier' else 'ia[1]' if path == 'element' else 'p'
    if path == 'hier': ref = 'i0'
    inside_expr = EXPRS[expr].replace('V', 'v')
    outer_expr = EXPRS[expr].replace('V', f'{ref}.v')
    one = {'direct': [f'{ref}.acc = {ref}.acc + ({outer_expr});', f'{ref}.n = {ref}.n - 1;'],
           'compound': [f'{ref}.acc += {outer_expr};', f'{ref}.n--;'],
           'task': [f'{ref}.step({outer_expr});'],
           'inside': [f'{ref}.fold();']}[update]
    p = ref

    def block(times=1):
        inner = [line for _ in range(times) for line in one]
        return ['begin', *['  ' + line for line in inner], 'end']

    body = {
        'if': [f'if ({p}.v < 0)', *['  ' + line for line in block()], 'else',
               *['  ' + line for line in block(3)]],
        'case': [f'case ({p}.n)', f"  8'd{START}:", *['    ' + line for line in block(2)], '  default:',
                 *['    ' + line for line in block()], 'endcase'],
        'repeat': [f'repeat ({p}.n)', *['  ' + line for line in block()]],
        'while': [f'while ({p}.n > 1)', *['  ' + line for line in block()]],
        'for': [f'for (int i = 0; i < {p}.n; i++)', *['  ' + line for line in block()]],
        'do': ['do', *['  ' + line for line in block()], f'while ({p}.n > 2);'],
        'foreach': [f'foreach ({p}.m[i])', f'  if ({p}.m[i] <= {p}.n)', *['    ' + line for line in block()]],
    }[stmt]
    interface = [f'interface {ifc};', f'  {kind} v = {init};', f"  logic [7:0] n = 8'd{START};",
                 "  logic signed [15:0] acc = 16'sd0;",
                 "  logic [7:0] m [3] = '{" + ', '.join(f"8'd{x}" for x in ARRAY) + '};',
                 '  modport mp (input v, input m, ref n, ref acc, import step, import fold);',
                 '  task automatic step(input logic signed [15:0] x);', '    acc += x;', '    n--;', '  endtask',
                 '  task automatic fold();', f'    acc += {inside_expr};', '    n--;', '  endtask',
                 'endinterface']
    report = '$display("user acc=%0d n=%0d", ' + f'{p}.acc, {p}.n);'
    lines = interface
    if path != 'hier':
        header = {'port': f'{ifc} p', 'modport': f'{ifc}.mp p', 'generic': 'interface p',
                  'element': f'{ifc}.mp p'}[path]
        body = [line.replace(f'{ref}.', 'p.') for line in body]
        report = report.replace(f'{ref}.', 'p.')
        lines += [f'module member_user({header});', '  initial begin', '    #1;', *['    ' + line for line in body],
                  '    ' + report, '  end', 'endmodule']
    top = [f'module {name};']
    if path == 'element':
        top += [f'  {ifc} ia[2] ();', '  member_user u (ia[1]);']
        shown = 'ia[1]'
    else:
        top += [f'  {ifc} i0 ();']
        if path == 'generic': top.append('  member_user u (i0.mp);')
        elif path != 'hier': top.append('  member_user u (i0);')
        shown = 'i0'
    top += ['  initial begin']
    if path == 'hier': top += ['    #1;', *['    ' + line for line in body], '    ' + report]
    top += ['    #2;', f'    $display("top acc=%0d n=%0d", {shown}.acc, {shown}.n);']
    if path == 'element': top.append('    $display("other acc=%0d n=%0d", ia[0].acc, ia[0].n);')
    top += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines + top)


EXPR_CLAUSE = {'div': '11.4.3', 'shift': '11.4.10', 'mixed': '11.8.1', 'part': '11.5.1 11.8.1',
               'cmp': '11.4.4', 'neg': '11.4.3', 'mul': '11.4.3 11.8.2'}
STMT_CLAUSE = {'if': '12.4', 'case': '12.5', 'repeat': '12.7.2', 'while': '12.7.4', 'for': '12.7.1',
               'do': '12.7.5', 'foreach': '12.7.3'}
PATH_CLAUSE = {'port': '25.3', 'modport': '25.5', 'generic': '25.3.3', 'element': '25.5', 'hier': '25.3'}


def make_case(row: Row) -> Case:
    path, decl, expr, stmt, update = row
    task = ' 25.7' if update in ('task', 'inside') else ''
    return Case(case_name(row), 'An interface member keeps its type on every path, and statements share it',
                f'{PATH_CLAUSE[path]}{task} 11.6.1 {EXPR_CLAUSE[expr]} {STMT_CLAUSE[stmt]}',
                'The member v has the same bits declared signed, unsigned or four bits wide, and a module '
                'reads it through an interface port, a modport, a generic interface port, an element of an '
                'array of interfaces or a hierarchical name. The type of v, not the path, decides how it '
                'extends and divides, shifts, compares and negates. A statement reads n of the interface for '
                'its control and every update decrements it, by direct or compound assignment or by a task '
                'that the modport imports, so repeat counts once and the other loops see each decrement.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
