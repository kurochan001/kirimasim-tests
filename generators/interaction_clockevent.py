"""Clocking inputs retain their samples across named-event notification and waits.

14.4/14.10/14.13 put input sampling before the clocking-block event.
15.5.1/15.5.2 deliver the notification to already armed event controls.
Observations use later ticks, without assuming ordering among active waiters.
"""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_clockevent'
VERSION = 1
CHAPTER = 14
MODEL = Model(
    'clocking_named_event',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('skew', ('step', 'zero')), ('edge', ('posedge', 'negedge')),
     ('update', ('blocking', 'nba')), ('trigger', ('blocking', 'nba')),
     ('listeners', ('1', '2'))),
    lambda row: True,
    groups=(('width', 'skew', 'trigger'), ('skew', 'update', 'trigger'),
            ('edge', 'trigger', 'listeners')),
    anchors=(('1', 'step', 'posedge', 'blocking', 'blocking', '1'),
             ('129', 'zero', 'negedge', 'nba', 'nba', '2'),
             ('65', 'zero', 'posedge', 'blocking', 'nba', '2'),
             ('33', 'step', 'negedge', 'nba', 'blocking', '1'),
             ('32', 'zero', 'posedge', 'nba', 'blocking', '2'),
             ('64', 'step', 'negedge', 'blocking', 'nba', '1')),
    constraints=('全192行が合法。既知値だけを使い、各クロック後に名前付きイベントで待機者へ通知する。'
                 '生信号だけを翌tickに変更し、受信直後と二tick後の採取値・生値を分けて観測する。'
                 '別イベントを周期間に発火して誤起床を検出する。'
                 '同一tick内の待機者の順序と通知領域の区別、X/Z、イベント再結合、仮想interface、'
                 '出力skew、programは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_clockevent_' + '_'.join(row)


def frames(row: Row) -> tuple[tuple[str, str], ...]:
    width = int(row[0])
    originals = (('01' * width)[:width], '1' + '0' * (width-1), '0' * width)
    return tuple((word, word.translate(str.maketrans('01', '10'))) for word in originals)


def reference(row: Row) -> str:
    width, skew, _, _, _, listeners = row
    zeros = '0' * int(width)
    lines = []
    for phase in range(4):
        index = min(phase, 2)
        old, new = frames(row)[index]
        sampled = old if skew == 'step' else new
        count = index+1
        lines.append(f'phase={phase} time={10*phase+5 if phase<3 else 30} '
                     f'bridge={count} noise={phase} sample={sampled} live={old}')
        for slot in range(2):
            active = slot < int(listeners)
            lines.append(f'slot={slot} hits={count if active else 0} '
                         f'woke={10*index+2 if active else -1} late_at={10*index+4 if active else -1} '
                         f'seen={sampled if active else zeros} raw={new if active else zeros} '
                         f'held={sampled if active else zeros} late_raw={old if active else zeros}')
    return '\n'.join(lines)+'\n'


def make_case(row: Row) -> Case:
    width, skew, edge, update, trigger, listeners = row
    w = int(width)
    inactive, active = (0, 1) if edge == 'posedge' else (1, 0)
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             f"  bit clk = 1'b{inactive};", f'  logic [{w-1}:0] data, incoming;',
             '  event ready, noise;', '  int bridges = 0, noise_hits = 0;',
             '  int hits[2], woke[2], late_at[2];',
             f'  logic [{w-1}:0] seen[2], raw[2], held[2], late_raw[2];',
             f'  clocking cb @({edge} clk);',
             f'    input #{"1step" if skew=="step" else "0"} data;', '  endclocking',
             f'  always @({edge} clk) data {"<=" if update=="nba" else "="} incoming;',
             '  always @(noise) noise_hits++;', '  always begin : bridge',
             '    @(cb);', '    bridges++;', f'    {"->>" if trigger=="nba" else "->"} ready;', '  end']
    for slot in range(int(listeners)):
        lines += [f'  initial forever begin : listener_{slot}', '    @(ready);',
                  f'    hits[{slot}]++;', f'    woke[{slot}] = $time;',
                  f'    seen[{slot}] = cb.data;', f'    raw[{slot}] = data;', '    #2;',
                  f'    late_at[{slot}] = $time;', f'    held[{slot}] = cb.data;',
                  f'    late_raw[{slot}] = data;', '  end']
    lines += ['  initial begin : initialize', '    for (int slot = 0; slot < 2; slot++) begin',
              '      hits[slot] = 0;', '      woke[slot] = -1;', '      late_at[slot] = -1;',
              "      seen[slot] = '0;", "      raw[slot] = '0;", "      held[slot] = '0;",
              "      late_raw[slot] = '0;", '    end', '  end',
              '  task automatic show(input int phase);',
              '    $display("phase=%0d time=%0d bridge=%0d noise=%0d sample=%b live=%b",',
              '             phase, $time, bridges, noise_hits, cb.data, data);',
              '    for (int i = 0; i < 2; i++)',
              '      $display("slot=%0d hits=%0d woke=%0d late_at=%0d seen=%b raw=%b held=%b late_raw=%b",',
              '               i, hits[i], woke[i], late_at[i], seen[i], raw[i], held[i], late_raw[i]);',
              '  endtask', '  initial begin : stimulus']
    for phase, (old, new) in enumerate(frames(row)):
        lines += [f'    data = {literal(old)};', f'    incoming = {literal(new)};',
                  '#2;', f"    clk = 1'b{active};", '    #1;', f'    data = {literal(old)};',
                  f'    #2; show({phase});', '    #1;', f"    clk = 1'b{inactive};",
                  '    #2;', '    -> noise;', '    #2;']
    lines += ['    show(3);', '    $finish;', '  end', 'endmodule']
    lines = ['    #2;' if line == '#2;' else line for line in lines]
    return Case(
        case_name(row), 'Named-event consumers retain clocking samples while live inputs change',
        '14.10 14.13 14.4 15.5.1 15.5.2 4.4.2 10.4.1 10.4.2',
        'A module process waits on its clocking block before notifying one or two '
        'already armed named-event consumers. Three isolated clock pulses use '
        'complementary before/after data at all bits. The raw signal changes '
        'back one tick after the clock; each consumer reads the sample and raw '
        'signal immediately and two ticks later. The sampled clockvar must '
        'remain unchanged until the next clock, for both blocking and NBA '
        'notifications. A distinct event is triggered between pulses; only '
        'its guard count changes. Snapshot counts, times and both data paths '
        'at later ticks, including the final idle period. This model does not '
        'compare execution order among same-tick waiters or distinguish the '
        'notification regions. Unknown inputs, rebinding and programs are '
        'outside scope.',
        '\n'.join(lines), reference(row),
        extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
               'interaction_values': ' '.join(f'{key}={value}' for key, value in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
