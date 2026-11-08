"""A delay written as a sized, real, time, unknown or negative literal waits for its value in each kind of statement."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_delayval'
VERSION = 1
CHAPTER = 9

# The delay as written, and its value in nanoseconds (None for an unknown or a negative value).
VALUES = {'unsized': ('3', 3.0), 'sized': ("(3'b101)", 5.0), 'real_down': ('2.4', 2.4), 'real_up': ('2.6', 2.6),
          'time': ('3ns', 3.0), 'time_fine': ('2700ps', 2.7), 'x': ("(1'bx)", 0.0), 'z': ("(1'bz)", 0.0),
          'xpart': ("(4'b00x1)", 0.0), 'neg': ('(-1)', None)}
SITES = ('stmt', 'blocking', 'nba', 'fork', 'task', 'repeat')
START = {'zero': 0, 'later': 10}
END = 50


def legal(row: Row) -> bool:
    value, _, start, precision = row
    # A negative delay is the largest time; added to a later time, or scaled to a finer precision, it
    # would pass the largest time, which the standard does not define.
    return value != 'neg' or (start == 'zero' and precision == 'unit')


MODEL = Model(
    'delay_value_form',
    (('value', tuple(VALUES)), ('site', SITES), ('start', tuple(START)), ('precision', ('unit', 'tenth'))),
    legal,
    anchors=(('x', 'nba', 'later', 'tenth'), ('neg', 'repeat', 'zero', 'unit'), ('real_down', 'repeat', 'later', 'unit'),
             ('time_fine', 'task', 'zero', 'unit'), ('xpart', 'fork', 'later', 'unit'), ('z', 'blocking', 'zero', 'tenth'),
             ('sized', 'stmt', 'later', 'tenth')),
    constraints=('時間単位は1ns、精度は1nsか100psで、遅延はその精度へ丸めてから待つ。丸めの境目の値は使わない。'
                 '値にxかzのビットを含む遅延は0、負の遅延は時間変数と同じ幅の符号なしの値として扱う。'
                 '負の遅延は時刻0で精度1nsのときだけ使い、時間の最大値を超える場合を除く。'
                 '待つ文はプロセスごとに一つで、時刻は実数で小数点以下を一桁まで表示する。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_delayval_' + '_'.join(row)


def rounded(value: float, precision: str) -> float:
    step = 1.0 if precision == 'unit' else 0.1
    return round(value / step) * step


def reference(row: Row) -> str:
    value, site, start, precision = row
    begin = START[start]
    delay = VALUES[value][1]
    lines = []
    if delay is not None:
        wait = rounded(delay, precision)
        times = [begin + wait, begin + 2 * wait] if site == 'repeat' else [begin + wait]
        label = {'stmt': 'stmt', 'blocking': 'blocking a=7', 'nba': 'nba a=7', 'fork': 'fork', 'task': 'task',
                 'repeat': 'repeat'}[site]
        lines += [f'{time:.1f} {label}' for time in times]
    written = delay is not None and site in ('blocking', 'nba')
    lines.append(f'{END:.1f} end a={7 if written else 0}')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    value, site, start, precision = row
    text = VALUES[value][0]
    show = '$display("%0.1f {}", $realtime);'
    lines = [f'module {case_name(row)};', '  timeunit 1ns;', f'  timeprecision {"1ns" if precision == "unit" else "100ps"};',
             "  logic [7:0] a = 8'd0;"]
    if site == 'task': lines += ['  task automatic wait_once;', f'    #{text} {show.format("task")}', '  endtask']
    if site == 'nba': lines.append('  initial @(a) $display("%0.1f nba a=%0d", $realtime, a);')
    body = {'stmt': [f'#{text} {show.format("stmt")}'],
            'blocking': [f"a = #{text} 8'd7;", '$display("%0.1f blocking a=%0d", $realtime, a);'],
            'nba': [f"a <= #{text} 8'd7;"],
            'fork': ['fork', f'  #{text} {show.format("fork")}', 'join_none'],
            'task': ['wait_once;'],
            'repeat': [f'repeat (2) #{text} {show.format("repeat")}']}[site]
    lines.append('  initial begin')
    if START[start]: lines.append(f'    #{START[start]};')
    lines += ['    ' + line for line in body] + ['  end']
    lines += ['  initial begin', f'    #{END};', '    $display("%0.1f end a=%0d", $realtime, a);', '    $finish;', '  end',
              'endmodule']
    return '\n'.join(lines)


VALUE_CLAUSE = {'unsized': '5.7.1', 'sized': '5.7.1', 'real_down': '5.7.2 3.14.1', 'real_up': '5.7.2 3.14.1',
                'time': '5.8', 'time_fine': '5.8 3.14.1', 'x': '5.7.1', 'z': '5.7.1', 'xpart': '5.7.1', 'neg': '11.4.3'}
SITE_CLAUSE = {'stmt': '', 'blocking': '9.4.5', 'nba': '9.4.5 10.4.2', 'fork': '9.3.2', 'task': '13.3',
               'repeat': '12.7.2'}


def make_case(row: Row) -> Case:
    value, site, _, _ = row
    clauses = f'9.4.1 {VALUE_CLAUSE[value]} {SITE_CLAUSE[site]} 3.14.2.2'.split()
    return Case(case_name(row), 'A delay waits for the value of its literal, rounded to the time precision',
                ' '.join(dict.fromkeys(clauses)),
                'A delay is written as an unsized or a sized number, a real number, a time literal, a value with '
                'an x or z bit, or a negative value, before a statement, inside a blocking or a nonblocking '
                'assignment, in a fork branch, in a task or in a repeat loop. It is rounded to the time '
                'precision of 1ns or 100ps. A value with an x or z bit waits zero time, and a negative value is '
                'the largest unsigned time, so its statement never runs before the end.',
                source(row), reference(row), fourstate=value in ('x', 'z', 'xpart'),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
