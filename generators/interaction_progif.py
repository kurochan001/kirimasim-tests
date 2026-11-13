"""A program or a module writes a variable of an interface, directly or from an interface task or function, through a port, a modport or a hierarchical name; reads before and after #0 and the phase that a design process sees show the region set of the write and of the reaction."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_progif'
VERSION = 1
CHAPTER = 24

CALLERS = ('program', 'module')
ROUTES = ('port', 'modport', 'hier')
ACTIONS = ('direct', 'task', 'delayed', 'function', 'wrapper')
WRITES = ('blocking', 'nba')
REACTORS = ('always', 'comb', 'assign', 'nba')
PLACES = ('interface', 'module')

# The caller writes at time 5 and reads at 5, after #0 and at 6. Nothing else
# runs at 5 except the design processes that the write wakes.
CALL_TIME = 5
OLD = 0x11
NEW = 0x5a


def legal(row: Row) -> bool:
    # Every combination is legal: functions may hold nonblocking assignments
    # (13.4.4) and a program may call interface subroutines (24.5).
    return True


MODEL = Model(
    'program_interface_regions',
    (('caller', CALLERS), ('route', ROUTES), ('action', ACTIONS), ('write', WRITES),
     ('reactor', REACTORS), ('place', PLACES)),
    legal,
    groups=(('caller', 'write', 'reactor'), ('caller', 'action', 'write'), ('caller', 'route', 'action'),
            ('caller', 'reactor', 'place')),
    anchors=(('program', 'port', 'task', 'blocking', 'always', 'interface'),
             ('module', 'port', 'task', 'blocking', 'always', 'interface'),
             ('program', 'hier', 'delayed', 'nba', 'nba', 'module'),
             ('module', 'hier', 'delayed', 'blocking', 'comb', 'module'),
             ('program', 'port', 'function', 'nba', 'assign', 'interface'),
             ('module', 'modport', 'function', 'blocking', 'nba', 'interface'),
             ('program', 'modport', 'wrapper', 'blocking', 'assign', 'module'),
             ('module', 'modport', 'direct', 'nba', 'always', 'module'),
             ('program', 'port', 'direct', 'blocking', 'comb', 'interface'),
             ('module', 'hier', 'wrapper', 'blocking', 'assign', 'interface')),
    constraints=('呼出し側はprogramかmoduleで、時刻5にinterfaceの変数xへ書く。書き方は直接の代入・'
                 'interfaceのtask・#0の後に書くtask・void function・呼出し側のtaskを経由する'
                 'interfaceのtaskで、それぞれblockingかNBAで書く。interfaceへはポート・modport・'
                 '階層名で届く。virtual interfaceはkirimasimが未実装なので、実装後に経路へ加える。xへ反応する設計側はalways・always_comb・'
                 '連続代入・NBAのalwaysで、interfaceの中か、interfaceを受けるmoduleに置く。'
                 '反応はyを書き、時刻1から待つ観測プロセスがyの変化を数え、その時点の進捗を記録する。'
                 '進捗は書込みの前に1、#0の後に2とするので、moduleからblockingで書いた場合に限り、'
                 '#0より先に動く反応が1を見る。moduleからの書込みの直後にyを読むと、4.7の'
                 '割込みで値が定まらないので、その読取りはprogramの場合だけ置く。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_progif_' + '_'.join(row)


def hexbyte(value: int) -> str: return f'{value & 0xff:02x}'


def reacts_before_zero_delay(row: Row) -> bool:
    """Whether y has its new value when the caller resumes from #0.

    A program write and everything it wakes in the design wait until the
    reactive region set is empty (4.5, 24.3.1, 24.3.2), and the program's #0
    resumes in the Re-Inactive region, which is part of that set. A module's
    blocking write wakes a blocking reaction in the Active region, which runs
    before the Inactive region where #0 resumes (4.4.2.3). A nonblocking write,
    or a reaction that writes y with a nonblocking assignment, updates in the
    NBA region, after that Inactive region (4.4.2.4)."""
    caller, _, _, write, reactor, _ = row
    return caller == 'module' and write == 'blocking' and reactor != 'nba'


def reference(row: Row) -> str:
    caller, _, _, write, _, _ = row
    written = NEW if write == 'blocking' else OLD
    late = reacts_before_zero_delay(row)
    values = [('a0', hexbyte(written))]
    if caller == 'program':
        values.append(('b0', hexbyte(OLD + 1)))
    values += [('a1', hexbyte(written)), ('b1', hexbyte(NEW + 1 if late else OLD + 1)),
               ('a2', hexbyte(NEW)), ('b2', hexbyte(NEW + 1)),
               ('ph', '1' if late else '2'), ('wt', str(CALL_TIME)), ('nw', '1')]
    return ' '.join(f'{k}={v}' for k, v in values) + '\n'


def interface_lines(row: Row, name: str) -> list[str]:
    caller, route, action, write, reactor, place = row
    op = '=' if write == 'blocking' else '<='
    y = {'always': 'logic [7:0] y = 8\'h%s;' % hexbyte(OLD + 1), 'nba': 'logic [7:0] y = 8\'h%s;' % hexbyte(OLD + 1),
         'comb': 'logic [7:0] y;', 'assign': 'wire [7:0] y;'}[reactor]
    lines = ['interface bus_if;', f"  logic [7:0] x = 8'h{hexbyte(OLD)};", f'  {y}',
             '  int phase = 0, ph = 0, wt = 0, nw = 0;']
    if action in ('task', 'wrapper'):
        lines += ['  task put(input logic [7:0] v);', f'    x {op} v;', '  endtask']
    elif action == 'delayed':
        lines += ['  task put(input logic [7:0] v);', '    #0;', f'    x {op} v;', '  endtask']
    elif action == 'function':
        lines += ['  function void set(input logic [7:0] v);', f'    x {op} v;', '  endfunction']
    if route == 'modport':
        imports = {'direct': '', 'function': ', import set'}.get(action, ', import put')
        lines += [f'  modport tb (output x, phase, input y, ph, wt, nw{imports});']
    if place == 'interface':
        lines += design_lines(reactor, '', '  ')
    lines += ['endinterface']
    return lines


def design_lines(reactor: str, prefix: str, indent: str) -> list[str]:
    """The reaction to x and the process that observes y."""
    p = prefix
    reaction = {'always': f'always @({p}x) {p}y = {p}x + 8\'d1;',
                'comb': f'always_comb {p}y = {p}x + 8\'d1;',
                'assign': f'assign {p}y = {p}x + 8\'d1;',
                'nba': f'always @({p}x) {p}y <= {p}x + 8\'d1;'}[reactor]
    lines = [reaction, 'initial begin', '  #1;', '  forever begin', f'    @({p}y);', f'    {p}ph = {p}phase;',
             f'    {p}wt = $time;', f'    {p}nw++;', '  end', 'end']
    return [indent + line for line in lines]


def caller_lines(row: Row, name: str) -> list[str]:
    caller, route, action, write, _, _ = row
    keyword = 'program' if caller == 'program' else 'module'
    header = {'port': '(bus_if i)', 'modport': '(bus_if.tb i)'}.get(route, '')
    p = {'port': 'i.', 'modport': 'i.', 'hier': f'{name}.u.'}[route]
    op = '=' if write == 'blocking' else '<='
    value = f"8'h{hexbyte(NEW)}"
    act = {'direct': f'{p}x {op} {value};', 'task': f'{p}put({value});', 'delayed': f'{p}put({value});',
           'function': f'{p}set({value});', 'wrapper': f'drive({value});'}[action]
    lines = [f'{keyword} driver{header};', '  logic [7:0] a0, b0, a1, b1, a2, b2;']
    if action == 'wrapper':
        lines += ['  task drive(input logic [7:0] d);', f'    {p}put(d);', '  endtask']
    lines += ['  initial begin']
    lines += [f'    #{CALL_TIME};', f'    {p}phase = 1;', f'    {act}', f'    a0 = {p}x;']
    if caller == 'program':
        lines += [f'    b0 = {p}y;']
    lines += ['    #0;', f'    {p}phase = 2;', f'    a1 = {p}x;', f'    b1 = {p}y;', '    #1;', f'    a2 = {p}x;',
              f'    b2 = {p}y;']
    if caller == 'program':
        lines += ['    $display("a0=%h b0=%h a1=%h b1=%h a2=%h b2=%h ph=%0d wt=%0d nw=%0d",',
                  '             a0, b0, a1, b1, a2, b2,']
    else:
        lines += ['    $display("a0=%h a1=%h b1=%h a2=%h b2=%h ph=%0d wt=%0d nw=%0d",',
                  '             a0, a1, b1, a2, b2,']
    lines += [f'             {p}ph,', f'             {p}wt,', f'             {p}nw);']
    if caller == 'module':
        lines += ['    $finish;']
    lines += ['  end', f'end{keyword}']
    return lines


def source(row: Row) -> str:
    caller, route, action, write, reactor, place = row
    name = case_name(row)
    lines = ['`timescale 1ns/1ns', *interface_lines(row, name), '']
    if place == 'module':
        lines += ['module observer(bus_if i);', *design_lines(reactor, 'i.', '  '), 'endmodule', '']
    lines += [*caller_lines(row, name), '']
    connect = 'u' if route in ('port', 'modport') else ''
    lines += [f'module {name};', '  bus_if u();', f'  driver d({connect});']
    if place == 'module':
        lines += ['  observer m(u);']
    lines += ['endmodule']
    return '\n'.join(lines)


ROUTE_CLAUSE = {'port': '25.3', 'modport': '25.5', 'hier': '25.10'}
ACTION_CLAUSE = {'direct': '', 'task': '25.7', 'delayed': '25.7', 'function': '25.7 13.4', 'wrapper': '25.7 13.3'}
REACTOR_CLAUSE = {'always': '9.2.2.1', 'comb': '9.2.2.2', 'assign': '4.9.1', 'nba': '9.2.2.1 4.9.4 4.4.2.4'}


def clauses(row: Row) -> str:
    """24.3.1 first; 24.3.2 for a program that reaches the interface through
    its port; 24.5 when a program calls a subroutine; the region of #0 and of
    a nonblocking write in the caller's region set; 13.4.4 for a nonblocking
    assignment in a function; 4.7 where a module's read is left out."""
    caller, route, action, write, reactor, _ = row
    program = caller == 'program'
    parts = ['24.3.1']
    if program and route in ('port', 'modport'): parts.append('24.3.2')
    if program and action != 'direct': parts.append('24.5')
    parts += ['4.4.2.7' if program else '4.4.2.3', '4.5', ROUTE_CLAUSE[route], ACTION_CLAUSE[action]]
    if action == 'function' and write == 'nba': parts.append('13.4.4')
    parts += ['4.9.3'] if write == 'blocking' else ['4.9.4', '4.4.2.8' if program else '4.4.2.4']
    parts.append(REACTOR_CLAUSE[reactor])
    if not program: parts.append('4.7')
    return ' '.join(dict.fromkeys(' '.join(parts).split()))


def make_case(row: Row) -> Case:
    caller, route, action, write, reactor, place = row
    lrm = clauses(row)
    return Case(case_name(row),
                'A program or module write to an interface variable and the design reaction in their region sets',
                lrm,
                'At time 5 a program or a module writes the interface variable x with a blocking or nonblocking '
                'assignment, directly, from an interface task (with or without a #0 before the write), from an '
                'interface void function, or from its own task that calls the interface task. It reaches the '
                'interface through a port, a modport or a hierarchical name. A design '
                'process in the interface or in a module that takes the interface as a port writes y = x + 1 with '
                'an always procedure, always_comb, a continuous assignment or a nonblocking always procedure, and '
                'a process that waits from time 1 counts the changes of y and records the progress of the caller: '
                '1 before the write and 2 after its #0. Program code, and the subroutines it calls wherever they '
                'are declared, runs in the reactive region set, and the design reaction waits until that set is '
                'empty (4.5, 24.3.1, 24.3.2, 24.5): the program sees the old y right after the write and after '
                '#0, and the design sees progress 2. A module blocking write wakes a blocking reaction in the '
                'Active region before the Inactive region of #0 (4.4.2.3), so the module then reads the new y and '
                'the design sees progress 1. A nonblocking write, or a nonblocking reaction, updates in the NBA or '
                'Re-NBA region after #0 resumes. The read of y right after a module write is left out, because 4.7 '
                'lets the reaction interleave there.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
