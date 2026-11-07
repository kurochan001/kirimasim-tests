"""Time-scope precedence decides how delays scale, round and read back."""

from fractions import Fraction
from math import floor

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_timescope'
VERSION = 1
CHAPTER = 3


def legal(row: Row) -> bool:
    return not (row[0] == 'nested' and row[1] == 'package')


MODEL = Model(
    'time_scope_delay',
    (('binding', ('keyword', 'slash', 'directive', 'unit_scope', 'nested')),
     ('container', ('module', 'interface', 'package')),
     ('unit', ('1us', '10ns', '100ps')),
     ('precision', ('same', 'tenth', 'milli')),
     ('delay', ('real', 'suffix', 'fine', 'argument')),
     ('rounding', ('exact', 'down', 'tie', 'up')),
     ('caller', ('coarser', 'finer')),
     ('control', ('statement', 'nba'))),
    legal,
    groups=(('binding', 'container', 'caller'), ('unit', 'precision', 'rounding'),
            ('delay', 'rounding', 'precision'), ('container', 'control', 'delay')),
    anchors=(('keyword', 'module', '10ns', 'tenth', 'real', 'up', 'finer', 'statement'),
             ('slash', 'interface', '100ps', 'milli', 'fine', 'tie', 'coarser', 'nba'),
             ('directive', 'package', '1us', 'same', 'argument', 'down', 'finer', 'statement'),
             ('unit_scope', 'package', '10ns', 'milli', 'suffix', 'tie', 'coarser', 'nba'),
             ('nested', 'module', '100ps', 'tenth', 'real', 'exact', 'coarser', 'statement'),
             ('nested', 'interface', '1us', 'same', 'argument', 'up', 'finer', 'nba')),
    constraints=('packageは入れ子にできないのでnestedとの組合せだけ除外する。シミュレータの未対応による除外はしない。'
                 '遅延を持つtaskの時間スコープを、宣言・`timescale・$unitのtimeunit・入れ子の継承で決める。'
                 '効かないはずの`timescaleと$unitのtimeunitを置き、優先順位の誤りを出力の違いにする。'
                 '呼出し元は別の時間単位を持ち、同じ数値の遅延でも経過時間が変わる。'
                 '値は精度の桁で切下げ・二進で正確な同点・切上げ・端数なしを選ぶ。'
                 'コピーした$time・$stime・$realtime・%tを両スコープで各段階の後に観測する。'
                 '$timeの同点と、$timeunit・$printtimescale・program・クラスメソッドは対象外。',),
)

SCALE = {'1us': 10**9, '10ns': 10**7, '100ps': 10**5}
NAMES = {10**i * j: f'{j}{suffix}' for i, suffix in ((0, 'fs'), (3, 'ps'), (6, 'ns'), (9, 'us'), (12, 'ms'))
         for j in (1, 10, 100)}
AMOUNT = {('same', 'down'): '2.3', ('same', 'tie'): '2.5', ('same', 'up'): '2.7',
          ('tenth', 'down'): '1.23', ('tenth', 'tie'): '1.25', ('tenth', 'up'): '1.27',
          ('milli', 'down'): '1.0623', ('milli', 'tie'): '1.0625', ('milli', 'up'): '1.0627'}
TEXT_UNIT = {'1us': (1, 'us', 'ns'), '10ns': (10, 'ns', 'ps'), '100ps': (100, 'ps', 'fs')}
DECOY = '1ms/1us'
OFFSET = Fraction(47, 100)
CALLS = 3


def case_name(row: Row) -> str: return 'test_gen_cross_timescope_' + '_'.join(row)


def worker_scale(row: Row):
    unit = SCALE[row[2]]
    return unit, {'same': unit, 'tenth': unit // 10, 'milli': unit // 1000}[row[3]]


def caller_scale(row: Row):
    unit = SCALE[row[2]] * 10 if row[6] == 'coarser' else SCALE[row[2]] // 10
    return unit, unit // 100


def amount(row: Row) -> Fraction:
    return Fraction(2) if row[5] == 'exact' else Fraction(AMOUNT[row[3], row[5]])


def decimal(value: Fraction) -> str:
    whole, part = divmod(value, 1)
    digits = ''
    while part:
        part *= 10
        digit, part = divmod(part, 1)
        digits += str(digit)
    return str(whole) + ('.' + digits if digits else '')


def delay_text(row: Row) -> str:
    multiple, coarse, fine = TEXT_UNIT[row[2]]
    if row[4] == 'suffix': return decimal(amount(row) * multiple) + coarse
    if row[4] == 'fine': return decimal(amount(row) * multiple * 1000) + fine
    return 'd' if row[4] == 'argument' else decimal(amount(row))


def elapsed(value: Fraction, unit: int, precision: int) -> int:
    return floor(value * unit / precision + Fraction(1, 2)) * precision


def reading(tag, side, now, unit) -> str:
    whole = floor(Fraction(now, unit) + Fraction(1, 2))
    assert Fraction(now, unit) % 1 != Fraction(1, 2), 'a $time tie is outside this model'
    real = f'{float(Fraction(now, unit)):.9f}'
    return f'{side} {tag} {whole} {whole} {real} {whole * unit}fs {now}fs\n'


def reference(row: Row) -> str:
    unit, precision = worker_scale(row)
    outer, outer_precision = caller_scale(row)
    step = elapsed(amount(row), unit, precision)
    own = elapsed(amount(row), outer, outer_precision)
    now = elapsed(OFFSET, outer, outer_precision)
    lines = reading(0, 'c', now, outer)
    for tag in range(1, CALLS + 1):
        now += step
        lines += reading(tag, 'w', now, unit) + reading(tag, 'c', now, outer)
        if tag == 2:
            now += own
            lines += reading(tag, 'o', now, outer)
    return lines


FORMAT = '"%s %0d %0d %0d %.9f %t %t"'


def report(side: str, tag: str, indent: str) -> list[str]:
    return [f'{indent}$display({FORMAT.replace("%s", side, 1)}, {tag},',
            f'{indent}  $time, $stime, $realtime, $time, $realtime);']


def body_lines(row: Row, indent: str):
    head = 'task automatic work(input int tag' + (', input real d);' if row[4] == 'argument' else ');')
    # An intra-assignment control of a nonblocking assignment reads a static copy.
    target = delay_text(row)
    copy = row[4] == 'argument' and row[7] == 'nba'
    wait = [f'#{target};'] if row[7] == 'statement' else [f'v <= #{"dv" if copy else target} tag;', '@(v);']
    lines = ['int v = 0;'] + (['real dv = 0;'] if copy else []) + [head]
    lines += ['  dv = d;'] * copy + ['  ' + line for line in wait] + report('w', 'tag', '  ')
    return [indent + line for line in lines + ['endtask']]


def source(row: Row) -> str:
    unit, precision = worker_scale(row)
    outer, outer_precision = caller_scale(row)
    binding, container = row[:2]
    declared = f'{NAMES[unit]} / {NAMES[precision]}'
    lines = []
    if binding == 'unit_scope': lines.append(f'timeunit {declared};')
    if binding == 'directive':
        lines += [f'timeunit {DECOY.replace("/", " / ")};', f'`timescale {NAMES[unit]}/{NAMES[precision]}']
    if binding in ('keyword', 'slash', 'nested'): lines.append(f'`timescale {DECOY}')
    keyword = {'module': 'module', 'interface': 'interface', 'package': 'package'}[container]
    if binding == 'nested':
        lines += [f'{keyword} enclosing;', f'  timeunit {declared};', f'  {keyword} worker;']
        lines += body_lines(row, '    ')
        lines += [f'  end{keyword}', '  worker n();', f'end{keyword}']
    else:
        lines.append(f'{keyword} worker;')
        if binding == 'keyword':
            lines += [f'  timeunit {NAMES[unit]};', f'  timeprecision {NAMES[precision]};']
        if binding == 'slash': lines.append(f'  timeunit {declared};')
        lines += body_lines(row, '  ')
        lines.append(f'end{keyword}')
    lines.append(f'`timescale {DECOY}')
    lines += [f'module {case_name(row)};', f'  timeunit {NAMES[outer]} / {NAMES[outer_precision]};']
    if container == 'package': lines.append('  import worker::work;')
    elif binding == 'nested': lines.append('  enclosing o();')
    else: lines.append('  worker u();')
    path = ('' if container == 'package' else 'o.n.' if binding == 'nested' else 'u.')
    tail = f', {decimal(amount(row))}' if row[4] == 'argument' else ''
    lines += ['  initial begin', '    $timeformat(-15, 0, "fs", 0);', f'    #{decimal(OFFSET)};',
              *report('c', '0', '    ')]
    for tag in range(1, CALLS + 1):
        lines += [f'    {path}work({tag}{tail});', *report('c', str(tag), '    ')]
        if tag == 2: lines += [f'    #{decimal(amount(row))};', *report('o', str(tag), '    ')]
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


CLAUSES = '3.14.1 3.14.2.1 3.14.2.2 3.14.2.3 3.14.3 20.3.1 20.3.2 20.3.3 20.4.3 21.2.1.1 5.8 9.4.1 13.3 22.7'


def make_case(row: Row) -> Case:
    extra = {'module': '23.4' if row[0] == 'nested' else '', 'interface': '25.3',
             'package': '26.3'}[row[1]]
    return Case(case_name(row), 'A time scope decides how a task delay scales, rounds and reads back',
                ' '.join(part for part in (CLAUSES, extra, '10.4.2' if row[7] == 'nba' else '') if part),
                'A task holds one delay in its own time scope, set by a timeunit declaration, the '
                'last `timescale, the compilation-unit timeunit or an enclosing definition, with '
                'decoys that must lose by the precedence rules. The caller has another time unit, '
                'so the same number waits a different time there. Each delay is rounded alone to '
                'the precision of its scope, even when a finer one exists elsewhere. Copies of '
                '$time, $stime, $realtime and %t are read in both scopes after every step, and '
                'the read value uses the unit of the scope that made the call.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
