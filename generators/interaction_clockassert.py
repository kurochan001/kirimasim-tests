"""Clockvar retention across assertion clocks, skews and update regions."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_clockassert'
VERSION = 1
CHAPTER = 16
MODEL = Model(
    'clocking_assertion_sampling',
    (('width', ('1', '8', '33')),
     ('state', ('bit', 'logic')),
     ('sample_edge', ('posedge', 'negedge')),
     ('probe_edge', ('posedge', 'negedge')),
     ('timing', ('early', 'edge', 'between')),
     ('update', ('blocking', 'nba')),
     ('declaration', ('default', 'explicit'))),
    lambda row: True,
    groups=(('declaration', 'sample_edge', 'probe_edge'), ('timing', 'update', 'declaration'),
            ('width', 'state', 'timing'), ('sample_edge', 'probe_edge', 'timing')),
    anchors=(('1', 'bit', 'posedge', 'negedge', 'edge', 'nba', 'explicit'),
             ('33', 'logic', 'negedge', 'posedge', 'between', 'blocking', 'default'),
             ('8', 'bit', 'posedge', 'posedge', 'early', 'nba', 'default'),
             ('33', 'bit', 'negedge', 'negedge', 'edge', 'blocking', 'explicit')),
    constraints=('全288行が合法。アサーションが参照するclocking入力は16.5.1に従い'
                 '#1stepだけを使い、既定と明示指定を比較する。サンプル用と評価用の'
                 'クロックは別信号で、各周期の時刻8と12に駆動する。'
                 '更新は時刻6/8/10、観測は時刻14に分離する。'
                 '同じslotの#1step値とReactiveの生信号、後続の別クロックでの保持値を照合する。'
                 'X/Z、非#1step入力の不正な使用、出力skew、program、時間演算、'
                 'disable iff、同時クロックは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_clockassert_' + '_'.join(row)


def phases(row: Row) -> tuple[tuple[int, int], ...]:
    width = int(row[0])
    mask = (1 << width) - 1
    pattern = int(('01' * width)[:width], 2)
    return ((0, mask), (mask, 0), (pattern, mask ^ pattern))


def reference(row: Row) -> str:
    width = int(row[0])
    counts = {'clock': [0, 0], 'held': [0, 0], 'raw': [0, 0]}
    lines = []
    for phase, (before, incoming) in enumerate(phases(row)):
        sampled = incoming if row[4] == 'early' else before
        clock_live = before if row[4] == 'between' else incoming
        for name, value in (('clock', sampled), ('held', sampled), ('raw', incoming)):
            counts[name][0 if value else 1] += 1
        lines += [f'phase={phase} before={before:0{width}b} source={incoming:0{width}b}',
                  f'clock pass={counts["clock"][0]} fail={counts["clock"][1]} '
                  f'sampled={sampled:0{width}b} live={clock_live:0{width}b}',
                  f'held pass={counts["held"][0]} fail={counts["held"][1]} '
                  f'sampled={sampled:0{width}b} live={incoming:0{width}b}',
                  f'raw pass={counts["raw"][0]} fail={counts["raw"][1]} '
                  f'sampled={incoming:0{width}b} live={incoming:0{width}b}',
                  f'final clockvar={sampled:0{width}b} data={incoming:0{width}b}']
    return '\n'.join(lines) + '\n'


def action(name: str, expression: str, clock: str) -> list[str]:
    lines = [f'  check_{name}: assert property (@({clock}) (|{expression}))']
    for index, result in enumerate(('pass', 'fail')):
        lines += ['    begin' if index == 0 else '    end else begin',
                  f'      {name}_{result}++;', f'      {name}_seen = $sampled({expression});',
                  f'      {name}_live = data;']
    return lines + ['    end']


def make_case(row: Row) -> Case:
    width, state, sample_edge, probe_edge, timing, update, declaration = row
    w = int(width)
    sinactive = 0 if sample_edge == 'posedge' else 1
    pinactive = 0 if probe_edge == 'posedge' else 1
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             f'  bit sample_clk = {sinactive}, probe_clk = {pinactive};',
             f'  {state} [{w-1}:0] data, incoming;',
             '  clocking cb @(' + sample_edge + ' sample_clk);',
             '    input ' + ('#1step ' if declaration == 'explicit' else '') + 'data;',
             '  endclocking']
    for name in ('clock', 'held', 'raw'):
        lines += [f'  int {name}_pass = 0, {name}_fail = 0;',
                  f'  logic [{w-1}:0] {name}_seen, {name}_live;']
    lines += action('clock', 'cb.data', 'cb')
    lines += action('held', 'cb.data', probe_edge + ' probe_clk')
    lines += action('raw', 'data', probe_edge + ' probe_clk')
    assign = '    data ' + ('<=' if update == 'nba' else '=') + ' incoming;'
    if timing == 'edge':
        lines += [f'  always @({sample_edge} sample_clk) begin', assign, '  end']
    lines += ['  initial begin']
    for phase, (before, incoming) in enumerate(phases(row)):
        lines += [f"    data = {w}'h{before:x}; incoming = {w}'h{incoming:x};", '    #6;']
        if timing == 'early':
            lines += [assign]
        lines += ['    #2;', f'    sample_clk = {1-sinactive};', '    #2;']
        if timing == 'between':
            lines += [assign]
        lines += ['    #2;', f'    probe_clk = {1-pinactive};', '    #2;',
                  f'    $display("phase={phase} before=%b source=%b", {w}\'h{before:x}, incoming);']
        for name in ('clock', 'held', 'raw'):
            lines += [f'    $display("{name} pass=%0d fail=%0d sampled=%b live=%b",',
                      f'             {name}_pass, {name}_fail, {name}_seen, {name}_live);']
        lines += ['    $display("final clockvar=%b data=%b", cb.data, data);',
                  f'    sample_clk = {sinactive}; probe_clk = {pinactive};', '    #6;']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Clocking inputs retain their own samples across concurrent assertion clocks',
                '16.18 16.5.1 16.9.3 16.14.1 14.13 14.10 14.4 10.4.1 10.4.2 4.4.2',
                'A clocking block samples known typed data at ticks 8, 28 and 48 with '
                'default or explicit one-step input skew. Three assertions separately '
                'observe the clockvar on the clocking event, that clockvar on a later '
                'independent clock, and raw data on the later clock. Both action branches '
                'capture sampled and live vectors and separate counters; delayed reports '
                'avoid racing any action. Writes occur two ticks before, at the sample '
                'edge, or two ticks after, using blocking or NBA assignments. The later '
                'clock must not resample the clockvar. The same-slot action sees settled '
                'live data after edge updates. Complementary known inputs exercise pass '
                'and fail controls and every vector bit. Clock polarities are independent; '
                'the events do not coincide. Non-one-step skew is forbidden for clockvar '
                'assertion sampling by 16.5.1, not excluded for tool compatibility. '
                'No X/Z, output skew, program, disable condition or temporal operator is used.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
