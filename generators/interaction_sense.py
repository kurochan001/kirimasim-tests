"""An update wakes only what reads the changed bits, by the implicit sensitivity of each form."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_sense'
VERSION = 1
CHAPTER = 4

READS = {'plain': 'a', 'element': 'arr[1]', 'index': 'arr[i]', 'member': 's.f', 'packed': 's.f',
         'part': 'v[7:0]', 'fnarg': 'fa(a)', 'fnglobal': 'fg()', 'cond': '(sel ? a : c)',
         'concat': '{a[3:0], c[3:0]}'}
# What a write of each kind targets, with the new value and the same value.
READ_TARGET = {'plain': 'a', 'element': 'arr[1]', 'index': 'arr[1]', 'member': 's.f', 'packed': 's.f',
               'part': 'v[7:0]', 'fnarg': 'a', 'fnglobal': 'a', 'cond': 'a', 'concat': 'a[3:0]'}
UNREAD_TARGET = {'plain': 'u', 'element': 'arr[2]', 'index': 'arr[2]', 'member': 's.g', 'packed': 's.g',
                 'part': 'v[15:8]', 'fnarg': 'u', 'fnglobal': 'u', 'cond': 'c', 'concat': 'a[7:4]'}
PROCEDURES = ('comb', 'latch')


def legal(row: Row) -> bool:
    return row[2] != 'index' or row[1] in ('index', 'cond')


MODEL = Model(
    'implicit_sensitivity_update',
    (('process', ('comb', 'latch', 'star', 'assign', 'netdecl')),
     ('read', tuple(READS)),
     ('change', ('read', 'unread', 'same', 'second', 'index')),
     ('writer', ('blocking', 'nba', 'task'))),
    legal,
    # Pairs alone could leave a write of an unread part to a form that shows no
    # evaluation, so each read also has a witness on always_comb.
    anchors=(*[('comb', read, 'unread', 'blocking') for read in READS],
             *[('latch', read, 'read', 'nba') for read in READS],
             ('star', 'fnglobal', 'read', 'blocking'),
             ('assign', 'fnglobal', 'read', 'task'),
             ('netdecl', 'fnglobal', 'read', 'nba'),
             ('netdecl', 'cond', 'index', 'blocking'),
             ('comb', 'part', 'same', 'nba')),
    constraints=('always_comb・always_latchの評価は本体の$displayの回数で、全形式の値は別の時刻の読出しで観測する。'
                 '@*と連続代入は再評価の回数が値に現れないので値だけを読む。'
                 '初期値は宣言の初期化で与え、時刻0の競合を避ける。各段階の書込みは一つの変数だけにする。'
                 '関数の中で読む変数はalways_combだけが感度に含み、@*と連続代入は実引数だけに反応する。'
                 '添字が変数の選択は最長静的接頭辞が配列全体なので、他の要素の変更でも再評価する。'
                 'シミュレータの未対応による除外はしない。',),
)

B0, B1, B2, B3 = 1, 10, 15, 20


def case_name(row: Row) -> str: return 'test_gen_cross_sense_' + '_'.join(row)


def initial_state(read: str) -> dict:
    state = {'b': B0, 'u': 7}
    if read in ('plain', 'fnarg', 'fnglobal'): state['a'] = 2
    if read in ('element', 'index'): state['arr'] = [1, 2, 3]
    if read == 'index': state['i'] = 1
    if read in ('member', 'packed'): state['s'] = {'f': 2, 'g': 5}
    if read == 'part': state['v'] = 0x0502
    if read == 'cond': state.update(sel=1, a=2, c=9)
    if read == 'concat': state.update(a=0x12, c=0x09)
    return state


def read_value(read: str, state: dict) -> int:
    if read in ('plain', 'fnarg', 'fnglobal'): return state['a']
    if read == 'element': return state['arr'][1]
    if read == 'index': return state['arr'][state['i']]
    if read in ('member', 'packed'): return state['s']['f']
    if read == 'part': return state['v'] & 0xff
    if read == 'cond': return state['a'] if state['sel'] else state['c']
    return (state['a'] & 0xf) << 4 | state['c'] & 0xf


def write(read: str, change: str, state: dict) -> None:
    """The write of the middle step, in the model of the program's state."""
    if change == 'second': state['b'] = B2
    elif change == 'index':
        if read == 'index': state['i'] = 2
        else: state['sel'] = 0
    elif change == 'read':
        if read in ('plain', 'fnarg', 'fnglobal', 'cond'): state['a'] = 40
        elif read in ('element', 'index'): state['arr'][1] = 40
        elif read in ('member', 'packed'): state['s']['f'] = 40
        elif read == 'part': state['v'] = state['v'] & 0xff00 | 40
        else: state['a'] = state['a'] & 0xf0 | 0xc
    elif change == 'unread':
        if read in ('plain', 'fnarg', 'fnglobal'): state['u'] = 77
        elif read in ('element', 'index'): state['arr'][2] = 77
        elif read in ('member', 'packed'): state['s']['g'] = 77
        elif read == 'part': state['v'] = state['v'] & 0xff | 0x4d00
        elif read == 'cond': state['c'] = 77
        else: state['a'] = state['a'] & 0xf | 0xd0


def new_value(read: str, change: str) -> str:
    """The text of the new value of the middle step, as the program writes it."""
    if change == 'second': return f"8'd{B2}"
    if change == 'index': return '2' if read == 'index' else "1'b0"
    if change == 'read': return "4'hc" if read == 'concat' else "8'd40"
    if change == 'unread': return "4'hd" if read == 'concat' else "8'd77"
    return "4'h2" if read == 'concat' else "8'd2"


def evaluates(process: str, read: str, change: str) -> bool:
    """Whether the middle step wakes the procedure or reevaluates the assignment."""
    if change == 'same': return False
    if change in ('second', 'index'): return True
    if process in PROCEDURES:
        return change == 'read' or read in ('index', 'cond')
    return change == 'read' and read != 'fnglobal'


def reference(row: Row) -> str:
    process, read, change, _ = row
    state = initial_state(read)
    lines = []
    # A procedure and an assignment evaluate at time 0; always @* first waits for a change.
    output = None if process == 'star' else (read_value(read, state) + state['b']) & 0xff

    def show(time):
        lines.append(f'{time} o={"xx" if output is None else format(output, "02x")}')

    def evaluated(time):
        if process in PROCEDURES: lines.append(f'{time} eval')
    show(1)
    state['b'] = B1
    output = (read_value(read, state) + state['b']) & 0xff
    evaluated(2)
    show(3)
    write(read, change, state)
    if evaluates(process, read, change):
        output = (read_value(read, state) + state['b']) & 0xff
        evaluated(4)
    show(5)
    state['b'] = B3
    output = (read_value(read, state) + state['b']) & 0xff
    evaluated(6)
    show(7)
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    process, read, change, writer = row
    decl = ["logic [7:0] b = 8'd1;", "logic [7:0] u = 8'd7;"]
    if read in ('plain', 'fnarg', 'fnglobal'): decl.append("logic [7:0] a = 8'd2;")
    if read in ('element', 'index'): decl.append("logic [7:0] arr[3] = '{8'd1, 8'd2, 8'd3};")
    if read == 'index': decl.append('int i = 1;')
    if read == 'member':
        decl += ['typedef struct { logic [7:0] f; logic [7:0] g; } st_t;', "st_t s = '{f: 8'd2, g: 8'd5};"]
    if read == 'packed':
        decl += ['typedef struct packed { logic [7:0] g; logic [7:0] f; } st_t;', "st_t s = 16'h0502;"]
    if read == 'part': decl.append("logic [15:0] v = 16'h0502;")
    if read == 'cond': decl += ["logic sel = 1'b1;", "logic [7:0] a = 8'd2;", "logic [7:0] c = 8'd9;"]
    if read == 'concat': decl += ["logic [7:0] a = 8'h12;", "logic [7:0] c = 8'h09;"]
    if read == 'fnarg':
        decl += ['function automatic logic [7:0] fa(logic [7:0] p);', '  return p;', 'endfunction']
    if read == 'fnglobal':
        decl += ['function automatic logic [7:0] fg();', '  return a;', 'endfunction']
    expression = f'{READS[read]} + b'
    trace = 'if ($time > 0) $display("%0d eval", $time);'
    process_text = {
        'comb': ['logic [7:0] o;', 'always_comb begin', f'  o = {expression};', f'  {trace}', 'end'],
        'latch': ["logic en = 1'b1;", 'logic [7:0] o;', 'always_latch begin', f'  if (en) o = {expression};',
                  f'  {trace}', 'end'],
        'star': ['logic [7:0] o;', 'always @* begin', f'  o = {expression};', 'end'],
        'assign': ['logic [7:0] o;', f'assign o = {expression};'],
        'netdecl': [f'wire [7:0] o = {expression};'],
    }[process]
    target = {'second': 'b', 'index': 'i' if read == 'index' else 'sel', 'read': READ_TARGET[read],
              'unread': UNREAD_TARGET[read], 'same': READ_TARGET[read]}[change]
    steps = {'a': ('b', f"8'd{B1}"), 'm': (target, new_value(read, change)), 'z': ('b', f"8'd{B3}")}
    operator = '<=' if writer == 'nba' else '='
    tasks: list[str] = []
    calls = {}
    for key, (left, right) in steps.items():
        if writer == 'task':
            tasks += [f'task automatic step_{key}();', f'  {left} = {right};', 'endtask']
            calls[key] = f'step_{key}();'
        else:
            calls[key] = f'{left} {operator} {right};'
    show = '$display("%0d o=%h", $time, o);'
    run = ['#1;', show, '#1;', calls['a'], '#1;', show, '#1;', calls['m'], '#1;', show, '#1;', calls['z'],
           '#1;', show, '$finish;']
    return '\n'.join([f'module {case_name(row)};', *['  ' + line for line in decl],
                      *['  ' + line for line in process_text], *['  ' + line for line in tasks],
                      '  initial begin', *['    ' + line for line in run], '  end', 'endmodule'])


READ_CLAUSE = {'plain': '6.8', 'element': '7.4', 'index': '7.4', 'member': '7.2', 'packed': '7.2.1',
               'part': '11.5.1', 'fnarg': '13.4', 'fnglobal': '13.4', 'cond': '11.4.11', 'concat': '11.4.12'}
PROCESS_CLAUSE = {'comb': '9.2.2.2.1 11.5.3', 'latch': '9.2.2.3 11.5.3', 'star': '9.4.2.2 9.2.2.2.2',
                  'assign': '10.3.2', 'netdecl': '10.3.1'}


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'An update wakes only what reads the changed bits, by the implicit sensitivity of each form',
                f'4.3 {PROCESS_CLAUSE[row[0]]} {READ_CLAUSE[row[1]]}',
                'always_comb and always_latch wake for the longest static prefix of what they read, also '
                'inside a called function, so a write to another element, member or part of a variable '
                'leaves them asleep unless a variable index makes the prefix the whole array. always @* '
                'and a continuous assignment do not see what a function reads outside its arguments, so '
                'their output stays old until an operand changes. A write of the same value is no update, '
                'and each write has its own time step, apart from the reads.',
                source(row), reference(row), fourstate=row[0] == 'star',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
