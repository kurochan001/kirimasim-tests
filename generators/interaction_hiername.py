"""%m prints the hierarchical name of the scope that holds the display, wherever the call comes from."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_hiername'
VERSION = 1
CHAPTER = 21

PLACES = ('top', 'inst', 'nested', 'array', 'loopgen', 'namedgen', 'unnamedgen')
# The name of each scope that holds the display, after the name of its module instance.
SCOPES = {'module': '', 'block': '.b', 'nested': '.b.c', 'fork': '.k', 'label': '.lb', 'loop': '.lp',
          'task': '.t', 'auto': '.t', 'function': '.f'}
SUBROUTINES = ('task', 'auto', 'function')


def legal(row: Row) -> bool:
    place, scope, call, process = row
    if call != 'own' and scope not in SUBROUTINES: return False
    # A final procedure holds only what a function may hold: no task call and no fork-join.
    if process == 'final' and scope in ('fork', 'task', 'auto'): return False
    if place == 'top' and call == 'down': return False
    # A name in an unnamed generate block cannot be reached from outside the block.
    return not (place == 'unnamedgen' and call in ('down', 'root'))


MODEL = Model(
    'hierarchical_name_display',
    (('place', PLACES), ('scope', tuple(SCOPES)), ('call', ('own', 'down', 'root', 'up')),
     ('process', ('initial', 'final'))),
    legal,
    groups=(('scope', 'call', 'process'),),
    anchors=(('unnamedgen', 'task', 'up', 'initial'), ('loopgen', 'function', 'root', 'final'),
             ('array', 'loop', 'own', 'initial'), ('nested', 'label', 'own', 'final'),
             ('top', 'auto', 'root', 'initial'), ('namedgen', 'fork', 'own', 'initial'),
             ('inst', 'function', 'down', 'final')),
    constraints=('%mは表示を含むスコープの階層名を出し、サブルーチンでは呼び出し元ではなく定義の場所の名前になる。'
                 '文のラベルとforの宣言付きループのラベルは名前付きのブロックを作る。'
                 '名前のない生成ブロックは、その前の生成構文を数えたgenblkの名前になる。'
                 '外から名前のない生成ブロックの中は参照できないので、下向きと$rootの呼び出しは除く。'
                 'finalには関数に書ける文だけを書けるので、taskの呼び出しとfork-joinは除く。'
                 'どのテストも表示するプロセスは一つだけで、表示の順序を競わない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_hiername_' + '_'.join(row)


def instance(row: Row) -> str:
    """The hierarchical name of the module instance that holds the scope."""
    top = case_name(row)
    return top + {'top': '', 'inst': '.u', 'nested': '.w.v', 'array': '.u[1]', 'loopgen': '.g[1].u',
                  'namedgen': '.n.u', 'unnamedgen': '.genblk2.u'}[row[0]]


def reference(row: Row) -> str:
    _, scope, call, _ = row
    caller = {'own': instance(row), 'down': case_name(row), 'root': case_name(row), 'up': instance(row) + '.h'}[call]
    return f'from {caller}\nin {instance(row)}{SCOPES[scope]}\n'


def scope_lines(scope: str) -> list[str]:
    """The statement of the display in its scope, or the subroutine that holds it."""
    show = '$display("in %m");'
    return {'module': [show], 'block': ['begin : b', '  ' + show, 'end'],
            'nested': ['begin : b', '  begin : c', '    ' + show, '  end', 'end'],
            'fork': ['fork : k', '  ' + show, 'join'], 'label': ['lb: ' + show],
            'loop': ['lp: for (int j = 0; j < 1; j++) ' + show],
            'task': ['task t;', '  ' + show, 'endtask'], 'auto': ['task automatic t;', '  ' + show, 'endtask'],
            'function': ['function void f();', '  ' + show, 'endfunction']}[scope]


def process_lines(process: str, statement: str) -> list[str]:
    return [f'  {process} begin', '    $display("from %m");', *['    ' + line for line in statement], '  end']


def source(row: Row) -> str:
    place, scope, call, process = row
    top = case_name(row)
    sub = scope in SUBROUTINES
    called = 'f();' if scope == 'function' else 't;'
    # The module that holds the display: the top module itself, or hn_child.
    held = ['  ' + line for line in scope_lines(scope)] if sub else []
    if call == 'own': held += process_lines(process, [called] if sub else scope_lines(scope))
    if call == 'up': held.append('  hn_helper h ();')
    lines = []
    if call == 'up':
        owner = top if place == 'top' else 'hn_child'
        lines += ['module hn_helper;', *process_lines(process, [f'{owner}.{called}']), 'endmodule']
    if place != 'top': lines += ['module hn_child;', *held, 'endmodule']
    if place == 'nested': lines += ['module hn_wrap;', '  hn_child v ();', 'endmodule']
    lines.append(f'module {top};')
    lines += {'top': held, 'inst': ['  hn_child u ();'], 'nested': ['  hn_wrap w ();'],
              'array': ['  hn_child u [1:1] ();'],
              'loopgen': ['  for (genvar i = 1; i < 2; i++) begin : g', '    hn_child u ();', '  end'],
              'namedgen': ['  if (1) begin : n', '    hn_child u ();', '  end'],
              'unnamedgen': ['  for (genvar i = 0; i < 1; i++) begin : pre', '    logic unused;', '  end',
                             '  if (1) begin', '    hn_child u ();', '  end']}[place]
    if call in ('down', 'root'):
        path = instance(row)[len(top) + 1:]
        target = f'$root.{top}.' if call == 'root' else ''
        target += f'{path}.' if path else ''
        lines += process_lines(process, [target + called])
    lines += ['  initial #1 $finish;', 'endmodule']
    return '\n'.join(lines)


PLACE_CLAUSE = {'top': '23.3.1', 'inst': '23.3.2', 'nested': '23.3.2', 'array': '23.3.2', 'loopgen': '27.4',
                'namedgen': '27.5', 'unnamedgen': '27.6 27.5'}
SCOPE_CLAUSE = {'module': '', 'block': '9.3.4', 'nested': '9.3.4', 'fork': '9.3.2 9.3.4', 'label': '9.3.5',
                'loop': '9.3.5 12.7.1', 'task': '13.3', 'auto': '13.3.1', 'function': '13.4'}
CALL_CLAUSE = {'own': '', 'down': '', 'root': '', 'up': '23.8 23.8.1'}
PROCESS_CLAUSE = {'initial': '9.2.1', 'final': '9.2.3'}


def make_case(row: Row) -> Case:
    place, scope, call, process = row
    clauses = (f'21.2.1.5 23.6 {PLACE_CLAUSE[place]} {SCOPE_CLAUSE[scope]} {CALL_CLAUSE[call]} '
               f'{PROCESS_CLAUSE[process]}').split()
    return Case(case_name(row), '%m prints the hierarchical name of the scope that holds the display',
                ' '.join(dict.fromkeys(clauses)),
                'The %m format prints the hierarchical name of the module instance, named block, labeled '
                'statement or subroutine that holds the display. The instance is the top module, a child, a '
                'grandchild, an element of an instance array, or sits in a loop, a named or an unnamed generate '
                'block, which is named genblk with the number of its generate construct. A subroutine prints '
                'the name where it is declared, whether it is called from its own module, downward, from '
                '$root, or upward by the module name. The process that calls first prints its own name.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
