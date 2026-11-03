"""Deferred report calls distinguish input capture from static const-ref reads."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_deferarg'
VERSION = 1
CHAPTER = 13
MODEL = Model(
    'deferred_argument_capture',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('sign', ('unsigned', 'signed')), ('passing', ('input', 'constref')),
     ('formal', ('same', 'narrow', 'wide')), ('routine', ('function', 'task')),
     ('queue', ('observed', 'final')), ('update', ('blocking', 'nba'))),
    lambda row: (row[2] == 'input' or row[3] == 'same')
    and not (row[0] == '1' and row[3] == 'narrow'),
    groups=(('width', 'passing', 'formal'), ('width', 'passing', 'queue'),
            ('passing', 'update', 'queue'), ('routine', 'passing', 'queue'),
            ('sign', 'passing', 'formal')),
    anchors=(('1', 'signed', 'input', 'wide', 'function', 'observed', 'blocking'),
             ('129', 'signed', 'constref', 'same', 'task', 'final', 'nba'),
             ('33', 'unsigned', 'input', 'narrow', 'task', 'observed', 'nba'),
             ('65', 'signed', 'input', 'wide', 'function', 'final', 'nba'),
             ('32', 'signed', 'constref', 'same', 'task', 'observed', 'blocking'),
             ('64', 'unsigned', 'input', 'same', 'function', 'final', 'blocking'),
             ('32', 'signed', 'input', 'same', 'function', 'observed', 'blocking')),
    constraints=('const refは型が同値の静的変数だけを渡すためformalはsameに限る。'
                 '幅一のnarrowは正の幅にならないため除外する。残る全行が合法。'
                 '既知値の三組を使い、入力引数は登録時に取得し、参照引数と生値は報告時に読む。'
                 '最終報告の動作は表示だけで、Postponedの静的変数へ書かない。'
                 '自動変数の参照渡し、動的な実引数の選択、出力引数、取消し、flush、X/Zは対象外。'
                 '未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_deferarg_' + '_'.join(row)


def frames(row: Row) -> tuple[tuple[str, str], ...]:
    w = int(row[0])
    old = (('10' * w)[:w], '1' + '0' * (w - 1), '0' * w)
    return tuple((word, word.translate(str.maketrans('01', '10'))) for word in old)


def formal_width(row: Row) -> int:
    return int(row[0]) + {'same': 0, 'narrow': -1, 'wide': 1}[row[3]]


def converted(bits: str, width: int, signed: bool) -> str:
    fill = bits[0] if signed else '0'
    return (fill * max(0, width - len(bits)) + bits)[-width:]


def reference(row: Row) -> str:
    f = formal_width(row)
    lines = []
    for phase, (old, new) in enumerate(frames(row)):
        arg = converted(old, f, row[1] == 'signed') if row[2] == 'input' else new
        number = int(arg, 2) - ((1 << f) if row[1] == 'signed' and arg[0] == '1' else 0)
        lines += [f'r p={phase} t={10 * phase + 2} cap={old} arg={arg} live={new} '
                  f'dec={number} bits={f} ready=1 calls={phase + 1}',
                  f's p={phase} t={10 * phase + 3} live={new} ready=1 calls={phase + 1}']
    lines.append(f'end t=30 live={frames(row)[-1][1]} ready=1 calls=3')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    width, sign, passing, _, routine, queue, update = row
    w = int(width); f = formal_width(row)
    actual = 'input report_t arg' if passing == 'input' else 'const ref word_t arg'
    head = 'function automatic void report' if routine == 'function' else 'task automatic report'
    tail = 'endfunction' if routine == 'function' else 'endtask'
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             f'  typedef logic {sign} [{w - 1}:0] word_t;',
             f'  typedef logic {sign} [{f - 1}:0] report_t;',
             '  word_t value;', '  bit ready = 0;', '  int calls = 0;',
             '  function automatic word_t capture(input word_t x);',
             '    calls++;', '    return x;', '  endfunction',
             f'  {head}(input int phase, input word_t captured,',
             f'                {actual});',
             '    $display("r p=%0d t=%0d cap=%b arg=%b live=%b dec=%0d bits=%0d ready=%0b calls=%0d",',
             '             phase, $time, captured, arg, value, arg, $bits(arg), ready, calls);',
             f'  {tail}', '  initial begin']
    for phase, (old, new) in enumerate(frames(row)):
        lines += [f'    value = {literal(old)};', '    ready = 0;', '    #2;',
                  f'    probe_{phase}: assert {"#0" if queue == "observed" else "final"} (1)',
                  f'      report({phase}, capture(value), value);',
                  f'    value {"=" if update == "blocking" else "<="} {literal(new)};',
                  '    ready = 1;', '    #1;',
                  '    $display("s p=%0d t=%0d live=%b ready=%0b calls=%0d",',
                  f'             {phase}, $time, value, ready, calls);', '    #7;']
    lines += ['    $display("end t=%0d live=%b ready=%0b calls=%0d", $time, value, ready, calls);',
              '    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(
        case_name(row),
        'Deferred report arguments preserve input capture, static references and formal conversion',
        '13.5.1 13.5.2 16.4 16.4.1 4.4.2.4 4.4.2.7 4.4.2.9 6.11.2 10.4.1 10.4.2 11.8.2',
        'A deferred assertion calls a function or nonwaiting task with one always-captured '
        'input and one input or const-ref argument. All ref actuals are equivalent-type '
        'static variables. Input formals additionally cross narrower and wider types. '
        'After registration, change the source by blocking assignment or NBA and set a '
        'ready marker. The action only displays, including in Postponed. Compare the '
        'captured control, argument, live source, signed decimal value, formal width, '
        'time and capture side-effect count. Three complementary known-value frames '
        'distinguish every bit and retain the final idle observation. Automatic/dynamic '
        'ref actuals, changed selectors, output arguments, cancellation, flushing and '
        'unknown inputs are outside scope.', source(row), reference(row),
        extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
               'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
