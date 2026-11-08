"""An escaped identifier names a module, instance, port, parameter, variable, task or generate block, and binds as its plain form."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_escname'
VERSION = 1
CHAPTER = 5

# The plain name of each item, and the keyword it takes when it is spelled as an escaped keyword.
ITEMS = {'module': ('ec_mod', 'module'), 'inst': ('ec_u', 'begin'), 'port': ('ec_in', 'input'),
         'param': ('EC_P', 'parameter'), 'var': ('ec_v', 'reg'), 'task': ('ec_t', 'task'), 'block': ('ec_g', 'end')}
# The white space that ends an escaped identifier in a reference.
GAPS = {'space': ' ', 'tab': '\t', 'newline': '\n      ', 'many': '   '}
# A plain declaration that a wrong split of \name+1 would read instead.
DECOYS = {'port': "logic [7:0] ec_in = 8'd50;", 'param': 'localparam int EC_P = 60;', 'var': "logic [7:0] ec_v = 8'd40;"}


def escaped_reference(row: Row) -> bool:
    _, spelling, ref, _ = row
    return spelling in ('special', 'keyword') or (spelling == 'escaped') == (ref == 'same')


def legal(row: Row) -> bool:
    _, spelling, ref, gap = row
    if ref == 'swapped' and spelling not in ('plain', 'escaped'): return False
    # A plain reference has no escaped identifier to end, so only one gap applies.
    return escaped_reference(row) or gap == 'space'


MODEL = Model(
    'escaped_name_binding',
    (('item', tuple(ITEMS)), ('spelling', ('plain', 'escaped', 'special', 'keyword')), ('ref', ('same', 'swapped')),
     ('gap', tuple(GAPS))),
    legal,
    anchors=(('inst', 'special', 'same', 'newline'), ('var', 'special', 'same', 'tab'), ('block', 'keyword', 'same', 'many'),
             ('module', 'escaped', 'swapped', 'space'), ('port', 'plain', 'swapped', 'tab'),
             ('param', 'special', 'same', 'space'), ('task', 'keyword', 'same', 'newline')),
    constraints=('エスケープした識別子は\\で始まり空白で終わり、\\と終わりの空白は名前に含まない。'
                 'そのため\\abcとabcは同じ名前で、エスケープしたキーワードは利用者の名前になる。'
                 '階層名ではエスケープした名前の後に空白を置いてからピリオドを続ける。'
                 '名前の読み違いが値に出るように、+を含む名前には、+の前の部分と同じ名前の宣言を別に置く。'
                 '平易な参照には終わりの空白がないので、空白の種類は一つだけにする。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_escname_' + '_'.join(row)


def reference(row: Row) -> str: return 'y=15\nv=3\ntask 5\ng=6\n'


def names(row: Row) -> tuple[dict, dict]:
    """The declared and the referenced text of each item; an escaped name keeps its ending white space."""
    item, spelling, ref, gap = row
    declared = {key: base + ' ' for key, (base, _) in ITEMS.items()}
    used = {key: base for key, (base, _) in ITEMS.items()}
    base, keyword = ITEMS[item]
    form = {'plain': base, 'escaped': '\\' + base, 'special': '\\' + base + '+1', 'keyword': '\\' + keyword}[spelling]
    declared[item] = form + ' '
    if ref == 'swapped': form = '\\' + base if spelling == 'plain' else base
    used[item] = form + GAPS[gap] if form.startswith('\\') else form
    return declared, used


def source(row: Row) -> str:
    item, spelling, _, _ = row
    d, u = names(row)
    decoy = DECOYS.get(item) if spelling == 'special' else None
    lines = [f"module {d['module']}#(parameter int {d['param']}= 1) (input logic [7:0] {d['port']}, "
             'output logic [7:0] q);']
    if decoy: lines.append('  ' + decoy)
    lines += [f"  logic [7:0] {d['var']}= 8'd3;", f"  assign q = {u['port']}+ {u['param']};",
              f"  task {d['task']}(input int k);", f'    $display("task %0d", k + {u["var"]});', '  endtask',
              f"  if (1) begin : {d['block']}", "    logic [7:0] g = 8'd6;", '  end', 'endmodule',
              f'module {case_name(row)};', "  logic [7:0] x = 8'd10, y;",
              f"  {u['module']}#(.{u['param']}(5)) {d['inst']}(.{u['port']}(x), .q(y));",
              '  initial begin', '    #1;', '    $display("y=%0d", y);', f'    $display("v=%0d", {u["inst"]}.{u["var"]});',
              f"    {u['inst']}.{u['task']}(2);", f'    $display("g=%0d", {u["inst"]}.{u["block"]}.g);', '  end',
              'endmodule']
    # A newline ends an escaped name at the end of a line, so no line keeps trailing white space.
    return '\n'.join(line.rstrip() for line in '\n'.join(lines).split('\n'))


ITEM_CLAUSE = {'module': '23.2.1 23.3.2', 'inst': '23.3.2 23.6', 'port': '23.3.2.2', 'param': '23.10.2.2',
               'var': '23.6', 'task': '13.3 23.6', 'block': '27.5 23.6'}


def make_case(row: Row) -> Case:
    item, spelling, _, gap = row
    keyword = ' 5.6.2' if spelling == 'keyword' else ''
    space = ' 5.3' if gap != 'space' else ''
    return Case(case_name(row), 'An escaped identifier binds as the identifier without its backslash',
                f'5.6.1 {ITEM_CLAUSE[item]}{keyword}{space}',
                'A module, instance, port, parameter, variable, task or generate block is declared with a plain '
                'name, an escaped name of the same letters, an escaped name with a plus sign, or an escaped '
                'keyword, and is referenced the same way or in the other of the plain and escaped forms. The '
                'backslash and the ending white space are not part of the name, so \\abc and abc are one name. '
                'An escaped name in a reference ends with a space, a tab, a newline or several spaces, also '
                'before the period of a hierarchical name. A plain declaration of the part before the plus sign '
                'shows a name split in the wrong place.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
