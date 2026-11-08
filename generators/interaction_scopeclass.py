"""A class declared in a module or a generate block reads the parameter, local parameter, variable or function of its own scope."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_scopeclass'
VERSION = 1
CHAPTER = 8

# The value each branch of a conditional generate adds, so that the taken branch shows in the output.
OFFSET = {'gen_if': (0, 50), 'gen_case': (0, 60)}
SHADOW_VALUE = 900
DERIVED_ADD = 1000
CHANGE = 100
# The same names declared in the top module, and in the module around a generate block.
TOP_DECOYS = ('localparam int P = 66;', 'localparam int L = 88;', 'int v = 77;',
              'function automatic int f();', '  return 99;', 'endfunction')
MODULE_DECOYS = ('localparam int L = 500;', 'int v = 500;', 'function automatic int f();', '  return 500;', 'endfunction')


def legal(row: Row) -> bool:
    _, _, caller, method, _ = row
    # A static method is called through the class scope, which only the scope that declares the class can name.
    return not (method == 'static' and caller == 'hier')


MODEL = Model(
    'scoped_class_declaration',
    (('scope', ('module', 'gen_for', 'gen_if', 'gen_case')), ('item', ('param', 'local', 'variable', 'function')),
     ('caller', ('local', 'hier')), ('method', ('instance', 'static', 'derived')),
     ('shadow', ('none', 'property', 'outer'))),
    legal,
    groups=(('scope', 'item', 'shadow'),),
    anchors=(('gen_for', 'variable', 'hier', 'derived', 'outer'), ('gen_if', 'function', 'local', 'static', 'property'),
             ('gen_case', 'local', 'hier', 'instance', 'outer'), ('module', 'variable', 'local', 'instance', 'none'),
             ('gen_for', 'param', 'local', 'static', 'outer'), ('module', 'function', 'hier', 'derived', 'property'),
             ('gen_for', 'local', 'local', 'derived', 'property')),
    constraints=('クラスは子moduleの中か、そのgenerateブロック（for・if・case）の中で宣言し、子moduleを'
                 'パラメータの値が異なる二つのインスタンスにする。メソッドは、クラスを宣言したスコープの'
                 'パラメータ・局所パラメータ・変数・関数を名前で読む。'
                 '変数は二回の読み出しの間に増やし、メソッドが呼出し時の値を読むことを確かめる。'
                 '同じ名前を、クラスの静的メンバーか、外側のスコープ（topと、generateブロックを囲むmodule）に'
                 '宣言した場合も作る。静的メソッドはクラススコープで呼ぶので、宣言したスコープの中から'
                 'だけ呼ぶ。読み出しの時刻はインスタンスごとにずらす。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_scopeclass_' + '_'.join(row)


def targets(scope: str) -> list[tuple[int, int, int, str]]:
    """(P, i, offset, label) of each place that declares the class, in the order of the output."""
    out = []
    for p in (1, 2):
        if scope == 'module': out.append((p, 0, 0, f'P{p}'))
        elif scope == 'gen_for': out += [(p, i, 0, f'P{p}.{i}') for i in (0, 1)]
        else: out.append((p, 0, OFFSET[scope][p - 1], f'P{p}'))
    return out


def reference(row: Row) -> str:
    scope, item, _, method, shadow = row
    lines = []
    for p, i, offset, label in targets(scope):
        base = {'param': p, 'local': p * 3 + 7 * i + offset, 'variable': 10 * p + 7 * i + offset,
                'function': p + 40 + 7 * i + offset}[item]
        first, second = base, base + (CHANGE if item == 'variable' else 0)
        if shadow == 'property': first = second = SHADOW_VALUE
        if method == 'derived': first, second = first + DERIVED_ADD, second + DERIVED_ADD
        lines.append(f'{label} {first} {second}')
    return '\n'.join(lines) + '\n'


def plus(*terms: str) -> str: return ' + '.join(t for t in terms if t)


def scope_items(row: Row, loop: bool, offset: int) -> list[str]:
    """The items, the class, the handle and the local caller of one declaring scope."""
    _, item, caller, method, shadow = row
    extra = '7 * i' if loop else ''
    tail = str(offset) if offset else ''
    lines = [f"localparam int L = {plus('P * 3', extra, tail)};", f"int v = {plus('10 * P', extra, tail)};",
             'function automatic int f();', f"  return {plus('P + 40', extra, tail)};", 'endfunction', 'class C;']
    if shadow == 'property':
        name = {'param': 'P', 'local': 'L', 'variable': 'v', 'function': 'f'}[item]
        if item == 'function': lines += ['  static function int f();', f'    return {SHADOW_VALUE};', '  endfunction']
        else: lines.append(f'  static int {name} = {SHADOW_VALUE};')
    read = {'param': 'P', 'local': 'L', 'variable': 'v', 'function': 'f()'}[item]
    lines += [f"  {'static ' if method == 'static' else ''}function int get();", f'    return {read};', '  endfunction',
              'endclass']
    if method == 'derived':
        lines += ['class D extends C;', '  function int get();', f'    return super.get() + {DERIVED_ADD};',
                  '  endfunction', 'endclass']
    lines.append(f"{'D' if method == 'derived' else 'C'} h = new;")
    if caller == 'local':
        call = 'C::get()' if method == 'static' else 'h.get()'
        label = ('"P%0d.%0d %0d %0d", P, i' if loop else '"P%0d %0d %0d", P') + ', a, b'
        lines += ['initial begin', '  int a, b;', f"  #({plus('10 * P', 'i' if loop else '')});", f'  a = {call};',
                  f'  v = v + {CHANGE};', f'  b = {call};', f'  $display({label});', 'end']
    return lines


def indent(lines: list[str], depth: int) -> list[str]: return ['  ' * depth + line for line in lines]


def source(row: Row) -> str:
    scope, _, caller, _, shadow = row
    lines = ['module sc_sub #(parameter int P = 1);']
    if shadow == 'outer' and scope != 'module': lines += indent(list(MODULE_DECOYS), 1)
    if scope == 'module': lines += indent(scope_items(row, False, 0), 1)
    elif scope == 'gen_for':
        lines += ['  for (genvar i = 0; i < 2; i++) begin : g', *indent(scope_items(row, True, 0), 2), '  end']
    elif scope == 'gen_if':
        first, second = OFFSET[scope]
        lines += ['  if (P == 1) begin : g', *indent(scope_items(row, False, first), 2),
                  '  end else begin : g', *indent(scope_items(row, False, second), 2), '  end']
    else:
        first, second = OFFSET[scope]
        lines += ['  case (P)', '    1: begin : g', *indent(scope_items(row, False, first), 3), '    end',
                  '    default: begin : g', *indent(scope_items(row, False, second), 3), '    end', '  endcase']
    lines += ['endmodule', f'module {case_name(row)};']
    if shadow == 'outer': lines += indent(list(TOP_DECOYS), 1)
    lines += ['  sc_sub #(1) u1();', '  sc_sub #(2) u2();']
    if caller == 'hier':
        lines += ['  initial begin', '    int a, b;', '    #5;']
        for p, i, _, label in targets(scope):
            path = f'u{p}' + {'module': '', 'gen_for': f'.g[{i}]'}.get(scope, '.g')
            lines += [f'    a = {path}.h.get();', f'    {path}.v = {path}.v + {CHANGE};', f'    b = {path}.h.get();',
                      f'    $display("{label} %0d %0d", a, b);']
        lines.append('  end')
    lines.append('endmodule')
    return '\n'.join(lines)


SCOPE_CLAUSE = {'module': '23.2.1', 'gen_for': '27.4', 'gen_if': '27.5', 'gen_case': '27.5'}
ITEM_CLAUSE = {'param': '6.20.2', 'local': '6.20.4', 'variable': '6.8', 'function': '13.4'}
METHOD_CLAUSE = {'instance': '', 'static': '8.10', 'derived': '8.13 8.15'}
SHADOW_CLAUSE = {'none': '', 'property': '8.9', 'outer': ''}


def make_case(row: Row) -> Case:
    scope, item, caller, method, shadow = row
    clauses = (f"8.3 23.9 {SCOPE_CLAUSE[scope]} {ITEM_CLAUSE[item]} {METHOD_CLAUSE[method]} {SHADOW_CLAUSE[shadow]} "
               f"{'23.6' if caller == 'hier' else ''}").split()
    return Case(case_name(row), 'A class method binds the names of the scope that declares the class',
                ' '.join(dict.fromkeys(clauses)),
                'A class is declared in a child module, or in a loop, if or case generate block in it, and the '
                'child is instantiated with the parameter 1 and 2. Its method returns a parameter, a local '
                'parameter, a variable or a function result of the declaring scope. The method is an instance '
                'method, a static method called through the class scope, or a method of a derived class that '
                'adds 1000 to super.get(). It is called from the declaring scope or through a hierarchical name '
                'from the top module, before and after the variable is increased by 100. A static member of the '
                'class with the same name hides the scope item, and the same names in the top module and around '
                'a generate block are not used.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
