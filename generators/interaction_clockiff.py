"""Conditional clocking events retain samples across suppressed raw edges."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_clockiff'
VERSION = 1
CHAPTER = 14
MODEL = Model(
    'clocking_event_iff',
    (('width', ('1', '8', '33')), ('state', ('bit', 'logic')),
     ('edge', ('posedge', 'negedge')), ('skew', ('step', 'zero')),
     ('update', ('blocking', 'nba')), ('guard_shape', ('scalar', 'wide_low', 'wide_high')),
     ('guard_timing', ('before', 'after'))),
    lambda row: True,
    groups=(('skew', 'update', 'guard_timing'), ('guard_shape', 'guard_timing', 'edge'),
            ('width', 'state', 'skew'), ('guard_shape', 'skew', 'update')),
    anchors=(('1', 'bit', 'posedge', 'step', 'nba', 'scalar', 'before'),
             ('33', 'logic', 'posedge', 'zero', 'nba', 'wide_high', 'after'),
             ('8', 'bit', 'negedge', 'step', 'blocking', 'wide_low', 'after'),
             ('33', 'bit', 'negedge', 'zero', 'blocking', 'wide_high', 'before')),
    constraints=('全288行が合法。既知の0/1ガードだけを使い、33ビットの下位/上位1による真偽も確認する。'
                 'ウォームアップでclockvarを既知の0にし、ガードだけの変更・rawエッジ・後続のガード変更を別時刻にする。'
                 '入力はmoduleのrawエッジで更新し、cbイベントを待つ観測器で採取する。'
                 '通過しないエッジとガードだけの変更では前のサンプルを保持する。'
                 'blocking/NBAはObservedより後の同じ結果を照合する経路対照。'
                 'X/Z、同時刻のガード更新、出力skew、program、interface、複数クロック、アサーションは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_clockiff_' + '_'.join(row)


def gate_bits(shape: str, enabled: bool) -> str:
    w = 1 if shape=='scalar' else 33
    value = 0 if not enabled else (1 << 32) if shape=='wide_high' else 1
    return f'{value:0{w}b}'


def words(width: int) -> list[tuple[int, int]]:
    mask = (1 << width) - 1
    pattern = int(('01' * width)[:width], 2)
    return [(value, mask ^ value) for value in (mask, 0, pattern, mask ^ pattern)]


def reference(row: Row) -> str:
    width, _, _, skew, _, shape, timing = row
    w = int(width)
    raw = hits = 1
    held = 0
    enabled = True
    lines = []

    def report(label, data):
        lines.extend([f'{label} gate={gate_bits(shape, enabled)} raw={raw} hits={hits}',
                      f'data={data:0{w}b} cb={held:0{w}b} seen={held:0{w}b}'])

    report('warm', 0)
    for phase, (before, incoming) in enumerate(words(w)):
        desired = bool(phase % 2)
        if timing=='before':
            enabled = desired
        report(f'p{phase}_pre', before)
        raw += 1
        if enabled:
            hits += 1
            held = before if skew=='step' else incoming
        report(f'p{phase}_edge', incoming)
        if timing=='after':
            enabled = desired
        report(f'p{phase}_late', incoming)
    return '\n'.join(lines) + '\n'


def make_case(row: Row) -> Case:
    width, state, edge, skew, update, shape, timing = row
    w = int(width)
    inactive = 0 if edge=='posedge' else 1
    gw = 1 if shape=='scalar' else 33
    gate_type = 'logic' if gw==1 else 'logic [32:0]'
    gate_literal = lambda enabled: f"{gw}'b{gate_bits(shape, enabled)}"
    literal = lambda value: f"{w}'h{value:x}"
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             f'  bit clk = {inactive};', f'  {gate_type} enabled;',
             f'  {state} [{w-1}:0] data;', f'  logic [{w-1}:0] incoming, seen = \'0;',
             '  int raw = 0, hits = 0;', '  bit ready = 0;',
             f'  clocking cb @({edge} clk iff enabled);',
             '    input #' + ('1step' if skew=='step' else '0') + ' data;', '  endclocking',
             f'  always @({edge} clk) begin', '    raw++;',
             '    data ' + ('<=' if update=='nba' else '=') + ' incoming;', '  end',
             '  initial begin', '    ready = 1;', '    forever begin', '      @(cb);',
             '      seen = cb.data;', '      hits++;', '    end', '  end',
             '  task automatic show(input string label);',
             '    $display("%s gate=%b raw=%0d hits=%0d", label, enabled, raw, hits);',
             '    $display("data=%b cb=%b seen=%b", data, cb.data, seen);', '  endtask',
             '  initial begin', f'    enabled = {gate_literal(True)};',
             "    data = '0; incoming = '0;", '    wait (ready);',
             f'    #2; clk = {1-inactive};', '    #2; show("warm");',
             f'    clk = {inactive}; #2;']
    for phase, (before, incoming) in enumerate(words(w)):
        lines += [f'    data = {literal(before)}; incoming = {literal(incoming)};', '    #2;']
        if timing=='before':
            lines += [f'    enabled = {gate_literal(bool(phase % 2))};']
        lines += [f'    #1; show("p{phase}_pre");', f'    #1; clk = {1-inactive};',
                  f'    #2; show("p{phase}_edge");', '    #2;']
        if timing=='after':
            lines += [f'    enabled = {gate_literal(bool(phase % 2))};']
        lines += [f'    #1; show("p{phase}_late");', f'    #1; clk = {inactive}; #2;']
    lines += ['    $finish;', '  end', 'endmodule']
    note = (' The saved fixed Verilator 5.052 run has an internal build failure '
            'for this legal vector iff condition. The standard-derived expected '
            'output is retained; scalar-normalized auxiliary controls are separate.'
            if shape!='scalar' else '')
    return Case(case_name(row),
                'Clocking iff gates sample updates and ignores guard-only changes across skew and update paths',
                '14.3 14.13 14.10 14.4 9.4.2.3 12.4 10.4.1 10.4.2 6.11.2',
                'A qualified warm-up edge establishes a known zero clockvar. Four isolated '
                'raw edges then alternate desired guard values zero and one, set two ticks '
                'before or four ticks after each edge. Scalar and 33-bit guards use a '
                'single known low or high one. Guard-only changes must not create clocking '
                'events. An unconditional module writer updates known typed data on every '
                'raw edge using blocking or NBA assignment. Explicit one-step skew retains '
                'the pre-edge word; zero skew sees the settled Observed word, but only when '
                'iff permits the event. Suppressed edges retain the previous clockvar. '
                'A separate observer waits on cb and records the updated sample and wake '
                'count. Warm-up plus three snapshots per phase compare live data, clockvar, '
                'saved sample, raw count and qualified count. Reads are delayed from all '
                'writes and edges. No assertion references the clockvar. No X/Z, same-slot '
                'guard writes, output skew, program, interface paths, multiple clocks or '
                'time-consuming callbacks are used.' + note,
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
