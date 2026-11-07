"""A loop reads its control when its form says, and sees another process's write by its region."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_loopsched'
VERSION = 1
CHAPTER = 12

START, NEW, PERIOD, LATER = 3, 5, 2, 2
LOOPS = ('repeat', 'while', 'for', 'do', 'forever')


def legal(row: Row) -> bool:
    _, wait, change, _ = row
    # Two processes resumed from #0 in the same inactive region run in either order.
    return not (wait == 'zero' and change == 'zero')


MODEL = Model(
    'loop_control_scheduling',
    (('loop', LOOPS), ('wait', ('none', 'zero', 'delay')),
     ('change', ('nba', 'zero', 'later', 'self')),
     ('observer', ('display', 'strobe', 'monitor'))),
    legal,
    groups=(('loop', 'wait', 'change'),),
    anchors=(('repeat', 'delay', 'nba', 'display'), ('while', 'delay', 'nba', 'display'),
             ('do', 'zero', 'nba', 'strobe'), ('forever', 'none', 'zero', 'monitor'),
             ('for', 'delay', 'later', 'monitor'), ('repeat', 'none', 'self', 'strobe')),
    constraints=('制御変数nは3から始まり、別のプロセスが時刻1のNBA・時刻1の#0の後・時刻2のどれかで5に変えるか、'
                 'ループ本体が自分で1ずつ減らす。本体はcountを増やし、待ちなし・#0・#2のどれかで止まる。'
                 '#0で止まる本体と#0の後の書込みは同じInactive領域で順序が決まらないので除外する。'
                 '$strobeと$monitorはタイムスロットの最後の値を表示し、$displayは呼んだ時点の値を表示する。'
                 '時刻0の競合を避けるため、両方のプロセスは#1から始める。'
                 'シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_loopsched_' + '_'.join(row)


def iterations(row: Row) -> list[tuple[int, int, int]]:
    """Each iteration as (time, count, n) when the body observes it, and the final state."""
    loop, wait, change, _ = row
    n, count, time = START, 0, 1
    # The time from which the write of the other process is visible to the loop.
    visible = {'nba': 1 if wait == 'delay' else None, 'zero': 1 if wait == 'delay' else None,
               'later': LATER if wait == 'delay' else None, 'self': None}[change]
    steps = []
    repeat_count = n

    def current():
        return NEW if visible is not None and time > visible else n

    def body():
        nonlocal count, n, time
        count += 1
        if change == 'self': n -= 1
        steps.append((time, count, current()))
        if wait == 'delay': time += PERIOD
    if loop == 'repeat':
        for _ in range(repeat_count): body()
    elif loop in ('while', 'for'):
        while count < current(): body()
    elif loop == 'do':
        body()
        while count < current(): body()
    else:
        while count < current(): body()
    return steps + [(time, count, current())]


def final_n(row: Row) -> int:
    """n after everything settled."""
    _, _, change, _ = row
    if change == 'self': return iterations(row)[-1][2]
    return NEW


def reference(row: Row) -> str:
    loop, wait, change, observer = row
    steps = iterations(row)
    *body, (done_time, done_count, done_n) = steps
    lines = []
    if observer == 'display':
        lines += [f'{t} it count={c} n={v}' for t, c, v in body]
    elif observer == 'strobe':
        # Each strobe shows the values at the end of its time slot.
        lines += [f'{t} st count={end_count(row, t)} n={end_n(row, t)}' for t, _, _ in body]
    else:
        times = sorted(set([1] + [t for t, _, _ in body] + ([LATER] if change == 'later' else [])))
        shown = None
        for t in times:
            state = (end_count(row, t), end_n(row, t))
            if state != shown: lines.append(f'{t} mon count={state[0]} n={state[1]}')
            shown = state
    lines.append(f'{done_time} done count={done_count} n={done_n}')
    # The done line comes from the loop process before the end of its time slot.
    if observer in ('strobe', 'monitor'):
        lines = order_by_time(lines, done_time)
    return '\n'.join(lines) + '\n'


def end_count(row: Row, time: int) -> int:
    """count at the end of a time slot."""
    steps = iterations(row)
    return max([c for t, c, _ in steps if t <= time] + [0])


def end_n(row: Row, time: int) -> int:
    _, _, change, _ = row
    if change == 'self':
        values = [v for t, _, v in iterations(row) if t <= time]
        return values[-1] if values else START
    return NEW if time >= {'nba': 1, 'zero': 1, 'later': LATER}[change] else START


def order_by_time(lines: list[str], done_time: int) -> list[str]:
    """Reports of the end of a slot follow the displays of that slot."""
    done = lines.pop()
    keyed = [(int(line.split()[0]), 1, i, line) for i, line in enumerate(lines)]
    keyed.append((done_time, 0, -1, done))
    return [line for *_, line in sorted(keyed)]


def source(row: Row) -> str:
    loop, wait, change, observer = row
    show = {'display': '$display("%0d it count=%0d n=%0d", $time, count, n);',
            'strobe': '$strobe("%0d st count=%0d n=%0d", $time, count, n);', 'monitor': None}[observer]
    body = ['count = count + 1;']
    if change == 'self': body.append('n = n - 1;')
    if show: body.append(show)
    body += {'none': [], 'zero': ['#0;'], 'delay': [f'#{PERIOD};']}[wait]
    inner = ['  ' + line for line in body]
    statement = {
        'repeat': ['repeat (n) begin', *inner, 'end'],
        'while': ['while (count < n) begin', *inner, 'end'],
        'for': ['for (k = 0; k < n; k = k + 1) begin', *inner, 'end'],
        'do': ['do begin', *inner, 'end while (count < n);'],
        'forever': ['forever begin', '  if (count >= n) break;', *inner, 'end'],
    }[loop]
    decl = [f"logic [7:0] n = 8'd{START};", 'int count = 0;']
    if loop == 'for': decl.append('int k = 0;')
    worker = ['#1;']
    if observer == 'monitor': worker.append('$monitor("%0d mon count=%0d n=%0d", $time, count, n);')
    worker += [*statement, '$display("%0d done count=%0d n=%0d", $time, count, n);']
    changer = {'nba': ['#1;', f"n <= 8'd{NEW};"], 'zero': ['#1;', '#0;', f"n = 8'd{NEW};"],
               'later': [f'#{LATER};', f"n = 8'd{NEW};"], 'self': []}[change]
    lines = [f'module {case_name(row)};', *['  ' + line for line in decl],
             '  initial begin', *['    ' + line for line in worker], '  end']
    if changer: lines += ['  initial begin', *['    ' + line for line in changer], '  end']
    lines += ['  initial #40 $finish;', 'endmodule']
    return '\n'.join(lines)


LOOP_CLAUSE = {'repeat': '12.7.2', 'while': '12.7.4', 'for': '12.7.1', 'do': '12.7.5', 'forever': '12.7.6 12.8'}
CHANGE_CLAUSE = {'nba': '4.4.2.4 10.4.2', 'zero': '4.4.2.3 9.4.1', 'later': '9.4.1', 'self': '10.4.1'}
OBSERVER_CLAUSE = {'display': '21.2.1', 'strobe': '21.2.2 4.4.2.9', 'monitor': '21.2.3 4.4.2.9'}


def make_case(row: Row) -> Case:
    loop, wait, change, observer = row
    return Case(case_name(row), 'A loop reads its control when its form says, and sees a write by its region',
                f'{LOOP_CLAUSE[loop]} 4.4.2.2 {CHANGE_CLAUSE[change]} {OBSERVER_CLAUSE[observer]}',
                'repeat evaluates its count once, while, for and forever with break test the variable before '
                'each pass, and do tests it after the body. Another process changes the variable by a '
                'nonblocking assignment, after #0 or at a later time, so a body that does not wait or waits '
                'only #0 finishes the slot with the old value, and a body that waits #2 sees the new one. '
                '$display shows the value at the call, and $strobe and $monitor the value at the end of the '
                'time slot, after the nonblocking update.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
