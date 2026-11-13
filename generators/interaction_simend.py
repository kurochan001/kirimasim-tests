"""$finish, $fatal and $exit end the simulation from initial, always, fork, task and function contexts in a module, a child instance or a program, before later events and a later terminator."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_simend'
VERSION = 1
CHAPTER = 20

ENDERS = ('finish', 'fatal', 'exit')
SITES = ('initial', 'always', 'fork', 'task', 'function')
TRIGGERS = ('delay', 'event', 'change')
SCOPES = ('top', 'child', 'program')
SECONDS = ('none', 'finish', 'fatal')

# The call is made at time 5. Every other activity is at another time, so that
# no two processes of the design run in the same time step as the call.
CALL_TIME = 5
EARLY_TIME = 3
LATE_TIME = 7
SECOND_TIME = 8
CHILD_TIME = 1      # after the call, in the calling thread
PARENT_TIME = 20    # the parent of a forked caller
SENTINEL_TIME = 40
HALF_PERIOD = 2

FIELDS = ('early', 'ticks', 'caller_after', 'parent_after', 'late_delay', 'late_event', 'second_seen')


def legal(row: Row) -> bool:
    ender, site, _, scope, _ = row
    # 24.3: a program contains no always procedure. $exit is only called from
    # a program: 20.2 and 24.7 disagree on a call from a module thread.
    return not (scope == 'program' and site == 'always') and (ender != 'exit' or scope == 'program')


MODEL = Model(
    'simulation_end_sources',
    (('ender', ENDERS), ('site', SITES), ('trigger', TRIGGERS), ('scope', SCOPES), ('second', SECONDS)),
    legal,
    groups=(('ender', 'site', 'scope'), ('site', 'trigger', 'scope'), ('ender', 'scope', 'second')),
    anchors=(('finish', 'function', 'delay', 'child', 'fatal'),
             ('fatal', 'always', 'event', 'child', 'finish'),
             ('exit', 'fork', 'change', 'program', 'none'),
             ('exit', 'task', 'event', 'program', 'fatal'),
             ('finish', 'fork', 'event', 'top', 'none'),
             ('fatal', 'function', 'change', 'program', 'none'),
             ('finish', 'always', 'delay', 'top', 'finish'),
             ('exit', 'function', 'delay', 'program', 'finish'),
             ('finish', 'task', 'change', 'child', 'none'),
             ('finish', 'initial', 'event', 'program', 'finish')),
    constraints=('終了は時刻5に、$finish・$fatal・$exitのどれかで要求する。呼ぶ場所はinitial・always・'
                 'join_noneでforkした子・task・functionで、時刻5まで遅延・イベント・変数の変化で待つ。'
                 '呼ぶ側はトップのmodule・子のインスタンス・入れ子のprogramに置く。'
                 'programにはalwaysを置けないので(24.3)、その組は除く。$exitはprogramからだけ呼ぶ。'
                 'moduleのスレッドからの$exitは、20.2では全programの完了を待つ暗黙の$finish、'
                 '24.7では無視となり、読み方で結果が変わるためである。'
                 '時刻3の書込み・偶数時刻のクロック・時刻7の遅延とイベント・時刻8の2番目の終了・'
                 '呼んだスレッドの1後と親の20後の書込みを置き、時刻5と同じ時刻には他のプロセスを動かさない。'
                 '終了を呼んだ後、同じ時刻のうちに実行される文は規格が定めないので観測しない。'
                 'final手続きは実行順が定まらないので一つだけにする。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_simend_' + '_'.join(row)


def call(row: Row) -> str:
    ender, site = row[0], row[1]
    return {'finish': '$finish;', 'fatal': f'$fatal(1, "end requested from {site}");', 'exit': '$exit;'}[ender]


def ends_at(row: Row) -> int:
    """Every legal call ends the simulation at once: $finish and $fatal by 20.2
    and 20.10, $exit by ending the only program (24.7), after which 24.3 makes
    the implicit $finish."""
    return CALL_TIME


def reference(row: Row) -> str:
    ender, site, _, scope, _ = row
    end = ends_at(row)
    ticks = sum(1 for t in range(HALF_PERIOD, end + 1, 2 * HALF_PERIOD))
    values = {'early': int(EARLY_TIME < end), 'ticks': ticks,
              'caller_after': int(CALL_TIME + CHILD_TIME < end),
              'parent_after': int(site == 'fork' and PARENT_TIME < end),
              'late_delay': int(LATE_TIME < end), 'late_event': int(LATE_TIME < end),
              'second_seen': int(row[4] != 'none' and SECOND_TIME <= end)}
    lines = [f'request t={CALL_TIME} site={site} scope={scope} ender={ender}',
             f'final t={end} ' + ' '.join(f'{k}={values[k]}' for k in FIELDS)]
    return '\n'.join(lines) + '\n'


def exit_status(row: Row) -> str:
    return 'nonzero' if row[0] == 'fatal' else '0'


def caller_lines(row: Row, indent: str) -> list[str]:
    """The trigger and the calling procedure, in the scope of the caller."""
    ender, site, trigger, scope, _ = row
    request = f'$display("request t=%0d site={site} scope={scope} ender={ender}", $time);'
    lines = []
    if trigger == 'event':
        lines += ['event go;', f'initial #{CALL_TIME} -> go;']
    elif trigger == 'change':
        lines += ['bit flag = 0;', f'initial #{CALL_TIME} flag = 1;']
    wait = {'delay': f'#{CALL_TIME};', 'event': '@(go);', 'change': 'wait (flag);'}[trigger]
    after = f'#{CHILD_TIME} caller_after = 1;'
    if site == 'initial':
        lines += ['initial begin', f'  {wait}', f'  {request}', f'  {call(row)}', f'  {after}', 'end']
    elif site == 'always':
        if trigger == 'delay':
            lines += ['always begin', f'  #{CALL_TIME};', f'  {request}', f'  {call(row)}', f'  {after}',
                      f'  #{SENTINEL_TIME * 2};', 'end']
        else:
            control = '@(go)' if trigger == 'event' else '@(flag)'
            lines += [f'always {control} begin', f'  {request}', f'  {call(row)}', f'  {after}', 'end']
    elif site == 'fork':
        lines += ['initial begin', '  fork', '    begin', f'      {wait}', f'      {request}',
                  f'      {call(row)}', f'      {after}', '    end', '  join_none',
                  f'  #{PARENT_TIME} parent_after = 1;', 'end']
    elif site == 'task':
        lines += ['task automatic stop_now();', f'  {request}', f'  {call(row)}', f'  {after}', 'endtask',
                  'initial begin', f'  {wait}', '  stop_now();', 'end']
    else:
        lines += ['function automatic void stop_now();', f'  {request}', f'  {call(row)}', 'endfunction',
                  'initial begin', f'  {wait}', '  stop_now();', f'  {after}', 'end']
    return [indent + line for line in lines]


def source(row: Row) -> str:
    ender, site, trigger, scope, second = row
    name = case_name(row)
    lines = ['`timescale 1ns/1ns']
    if scope == 'child':
        lines += [f'module {name}_child;', '  int caller_after = 0, parent_after = 0;',
                  *caller_lines(row, '  '), 'endmodule', '']
    lines += [f'module {name};',
              '  int early = 0, ticks = 0, late_delay = 0, late_event = 0, second_seen = 0;',
              '  bit clk = 0;', '  event late_ev;']
    if scope != 'child':
        lines += ['  int caller_after = 0, parent_after = 0;']
    lines += [f'  always #{HALF_PERIOD} clk = ~clk;', '  always @(posedge clk) ticks++;',
              f'  initial #{EARLY_TIME} early = 1;', f'  initial #{LATE_TIME} late_delay = 1;',
              f'  initial #{LATE_TIME} -> late_ev;', '  initial begin', '    @(late_ev);',
              '    late_event = 1;', '  end']
    if second != 'none':
        stop = '$finish;' if second == 'finish' else '$fatal(1, "second end");'
        lines += ['  initial begin', f'    #{SECOND_TIME} second_seen = 1;', f'    {stop}', '  end']
    lines += ['  initial begin', f'    #{SENTINEL_TIME} $display("sentinel t=%0d", $time);', '    $finish;', '  end']
    if scope == 'child':
        lines += [f'  {name}_child u();']
    elif scope == 'program':
        lines += ['  program target;', *caller_lines(row, '    '), '  endprogram']
    else:
        lines += caller_lines(row, '  ')
    where = 'u.' if scope == 'child' else ''
    lines += ['  final begin', '    $write("final t=%0d early=%0d ticks=%0d ", $time, early, ticks);',
              '    $write("caller_after=%0d parent_after=%0d ",', f'           {where}caller_after, {where}parent_after);',
              '    $display("late_delay=%0d late_event=%0d second_seen=%0d",',
              '             late_delay, late_event, second_seen);', '  end', 'endmodule']
    return '\n'.join(lines)


ENDER_CLAUSE = {'finish': '20.2', 'fatal': '20.10 20.2', 'exit': '20.2 24.7 24.3'}
SITE_CLAUSE = {'initial': '9.2.1', 'always': '9.2.2', 'fork': '9.3.2', 'task': '13.3', 'function': '13.4'}


def make_case(row: Row) -> Case:
    ender, site, trigger, scope, second = row
    lrm = f'{ENDER_CLAUSE[ender]} 9.2.3 {SITE_CLAUSE[site]}' + (' 24.3' if scope == 'program' and ender != 'exit'
                                                                 else '') + (' 23.3' if scope == 'child' else '')
    return Case(case_name(row), 'A simulation control task ends the run from a process context before later events',
                lrm,
                'At time 5 a process calls $finish, $fatal or $exit, from an initial or always procedure, from a '
                'child forked with join_none, or from an automatic task or function. It waits for that time by a '
                'delay, an event or a variable change, and it sits in the top module, in a child instance or in a '
                'nested program. The run ends at time 5: $fatal makes an implicit $finish (20.10), and $exit ends '
                'the only program, so 24.3 makes the implicit $finish. The one final procedure then shows the '
                'writes at 3 and the clock edge at 2, and none of the writes scheduled after 5: one unit after the '
                'call in the calling thread, 20 units into the parent of a fork, at 7 by a delay and an event, and '
                'just before a second $finish or $fatal at 8. A second $fatal that never runs leaves the exit code '
                'at 0. No other process runs at time 5, and statements after the call in that time step are not '
                'observed.',
                source(row), reference(row),
                extra={'expected_exit': exit_status(row),
                       'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
