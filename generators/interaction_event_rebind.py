"""Event-object identity across task entry, event-control registration and rebinding."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_event_rebind'
VERSION = 1
CHAPTER = 15
MODEL = Model(
    'event_rebinding',
    (('home', ('module', 'interface', 'package')),
     ('passing', ('direct', 'input', 'ref')),
     ('rebind', ('before_call', 'before_arm', 'after_arm')),
     ('trigger', ('blocking', 'nba')),
     ('aliases', ('single', 'chain')),
     ('order', ('old_new', 'new_old')),
     ('listeners', ('1', '2', '3'))),
    lambda row: True,
    groups=(('home', 'passing', 'rebind'), ('passing', 'rebind', 'trigger'),
            ('aliases', 'order', 'listeners'), ('rebind', 'trigger', 'order')),
    anchors=(('module', 'direct', 'before_call', 'blocking', 'single', 'old_new', '1'),
             ('interface', 'input', 'before_arm', 'nba', 'chain', 'new_old', '3'),
             ('package', 'ref', 'after_arm', 'blocking', 'chain', 'old_new', '2'),
             ('module', 'ref', 'before_arm', 'nba', 'single', 'new_old', '2'),
             ('package', 'input', 'before_call', 'blocking', 'single', 'new_old', '3'),
             ('interface', 'direct', 'after_arm', 'nba', 'chain', 'old_new', '1')),
    constraints=('全648行が合法。静的寿命のイベントを使用し、呼出しは時刻2、'
                 '待機登録は時刻4、再結合は時刻1/3/5に分離する。inputは呼出し時の'
                 'ハンドルをコピーし、refと直接参照は待機登録時の値を用いる。'
                 '登録済みの@は再結合後も元の同期オブジェクトを待つ。'
                 'nullは全待機完了後の代入・比較・無効果のトリガだけに使用する。'
                 'nullへの待機、triggered、wait_order、自動イベントの回収、'
                 '同一tickの再結合と登録の競合は対象外。未対応による除外なし。',),
)

SNAPSHOTS = ((0, 'initial'), (6, 'rebound'), (8, 'bridge_changed'),
             (10, 'noise'), (12, 'first'), (14, 'pair'), (18, 'repeated'), (21, 'cleared'))


def case_name(row: Row) -> str:
    return 'test_gen_cross_event_rebind_' + '_'.join(row)


def rebind_tick(row: Row) -> int:
    return {'before_call': 1, 'before_arm': 3, 'after_arm': 5}[row[2]]


def reference(row: Row) -> str:
    """Closed-form object selection and first-wakeup times, independent of a scheduler."""
    change = rebind_tick(row)
    read_at = 2 if row[1] == 'input' else 4
    primary = 'new' if change < read_at else 'old'
    order = row[5].split('_')
    wakes = {who: 11 + 2 * order.index(who) for who in ('old', 'new')}
    slots = [primary if slot < int(row[6]) else None for slot in range(3)]
    slots += ['new', 'old', 'noise']
    wakes['noise'] = 9
    result = []
    for tick, label in SNAPSHOTS:
        selected = 'null' if tick >= 20 else 'new' if tick > change else 'old'
        bridge = 'noise' if tick >= 8 else 'old'
        result.append(f'{label} time={tick} old={int(selected=="old")} '
                      f'new={int(selected=="new")} null={int(selected=="null")} '
                      f'copy_old=1 bridge_noise={int(bridge=="noise")} second_new=1')
        for slot, who in enumerate(slots):
            woke = who is not None and wakes[who] < tick
            when = wakes[who] if woke else -1
            value = 10 * when + int(row[3] == 'nba') if woke else 0
            result.append(f'{label} slot={slot} hits={int(woke)} at={when} value={value}')
    return '\n'.join(result) + '\n'


def source(row: Row, name: str) -> str:
    return ('event_bank::' if row[0] == 'package' else 'bank.') + name


def launch(row: Row, late: bool = False) -> list[str]:
    slots = [(3, 'selected')] if late else (
        [(slot, 'selected') for slot in range(int(row[6]))] + [(4, 'copied'), (5, 'noise')])
    lines = ['    fork']
    for slot, event in slots:
        if row[1] == 'direct':
            lines += [f'      begin #2; @({source(row, event)}); remember({slot}); end']
        else:
            lines += [f'      observe({source(row, event)}, {slot});']
    return lines + ['    join_none']


def snapshot(row: Row, label: str) -> list[str]:
    selected, old, new, copied, bridge, noise, second = (
        source(row, name) for name in ('selected', 'original', 'replacement', 'copied',
                                      'bridge', 'noise', 'second'))
    lines = [f'    $display("{label} time=%0d old=%0d new=%0d null=%0d",',
             f'             $time, {selected} == {old},',
             f'             {selected} == {new}, {selected} == null);']
    # Keep a single deterministic output line without racing listener printing.
    lines[0] = lines[0].replace('$display(', '$write(')
    lines[0] = lines[0].replace('null=%0d"', 'null=%0d "')
    lines += ['    $display("copy_old=%0d bridge_noise=%0d second_new=%0d",',
              f'             {copied} == {old}, {bridge} == {noise},',
              f'             {second} == {new});']
    for slot in range(6):
        lines += [f'    $display("{label} slot={slot} hits=%0d at=%0d value=%0d",',
                  f'             hits[{slot}], at_tick[{slot}], captured[{slot}]);']
    return lines


def make_case(row: Row) -> Case:
    home, passing, rebind, trigger, aliases, order, listeners = row
    name = case_name(row)
    lines = ['`timescale 1ns/1ns', f'{home} event_bank;',
             '  event original, replacement, noise, selected, bridge, copied, second;',
             f'end{home}', f'module {name};']
    if home != 'package':
        lines += ['  event_bank bank();']
    lines += ['  int hits[6], at_tick[6], captured[6];', '  int stamp;',
              '  task automatic remember(input int slot);',
              '    hits[slot]++;', '    at_tick[slot] = $time;',
              '    captured[slot] = stamp;', '  endtask']
    if passing != 'direct':
        lines += [f'  task automatic observe({passing} event ev, input int slot);',
                  '    #2;', '    @(ev);', '    remember(slot);', '  endtask']
    lines += ['  initial begin', '    stamp = 0;']
    for slot in range(6):
        lines += [f'    hits[{slot}] = 0; at_tick[{slot}] = -1; captured[{slot}] = 0;']
    lines += [f'    {source(row,"bridge")} = {source(row,"original")};',
              f'    {source(row,"selected")} = {source(row,"bridge" if aliases=="chain" else "original")};',
              f'    {source(row,"copied")} = {source(row,"selected")};',
              f'    {source(row,"second")} = {source(row,"replacement")};']
    observations = dict(SNAPSHOTS)
    first, second = order.split('_')
    pulses = {9: 'noise', 11: first, 13: second, 15: first, 17: second}
    now = 0
    ticks = set(observations) | set(pulses) | {2, 6, 7, 20, rebind_tick(row)}
    for tick in sorted(ticks):
        if tick != now:
            lines += [f'    #{tick-now};']
        now = tick
        if tick == rebind_tick(row):
            lines += [f'    {source(row,"selected")} = {source(row,"replacement")};']
        if tick == 7:
            lines += [f'    {source(row,"bridge")} = {source(row,"noise")};']
        if tick == 20:
            lines += [f'    {source(row,"selected")} = null;',
                      f'    -> {source(row,"selected")};']
        if tick in observations:
            lines += snapshot(row, observations[tick])
        if tick in (2, 6):
            lines += launch(row, late=tick == 6)
        if tick in pulses:
            who = {'old': 'copied', 'new': 'second', 'noise': 'noise'}[pulses[tick]]
            lines += [f'    stamp = {10*tick};', f'    stamp <= {10*tick+1};',
                      f'    {"->" if trigger=="blocking" else "->>"} {source(row,who)};']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(name, 'Event rebinding preserves armed objects and distinguishes input copies from ref arguments',
                '15.5.5.1 6.17 15.5.5.2 15.5.5.3 13.5.1 13.5.2 15.5.1 4.4.2.2 4.4.2.4 25.3 26.2',
                'Listeners start at tick 2 and arm at tick 4. The selected '
                'event is rebound at tick 1, 3 or 5. Input task arguments '
                'capture the object at entry; ref arguments and direct '
                'controls read it at registration. Already armed controls '
                'retain that object. One to three primary listeners, a later '
                'listener, a retained original alias and an independent '
                'noise listener write separate slots. Module, interface and '
                'package storage use the same timeline. An intermediate '
                'alias is changed after selection to distinguish copying '
                'object identity from linking variables. Pulses through '
                'retained aliases use both orders and blocking/NBA triggers; '
                'a queued payload distinguishes wakeup regions. Repeated '
                'pulses must not restart one-shot listeners. After completion, '
                'null assignment and a no-effect null trigger leave the '
                'other aliases intact. No null waits, triggered expressions, '
                'automatic event reclamation or same-tick registration races '
                'are used. This model does not qualify other event APIs.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
