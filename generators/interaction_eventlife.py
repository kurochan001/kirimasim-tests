"""Automatic scalar/aggregate event owners, retained aliases and returned forks."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_eventlife'
VERSION = 1
CHAPTER = 15
MODEL = Model(
    'aggregate_event_lifetime',
    (('storage', ('scalar', 'struct', 'nested')),
     ('capture', ('direct', 'copy')), ('calls', ('1', '2', '3')),
     ('release', ('before_arm', 'after_arm', 'after_wake')),
     ('trigger', ('blocking', 'nba')), ('order', ('forward', 'reverse')),
     ('listeners', ('1', '2'))),
    lambda row: True,
    groups=(('storage', 'capture', 'calls'), ('capture', 'release', 'listeners'),
            ('release', 'trigger', 'order'), ('calls', 'order', 'listeners')),
    anchors=(('scalar', 'direct', '1', 'before_arm', 'blocking', 'forward', '1'),
             ('struct', 'direct', '3', 'after_arm', 'nba', 'reverse', '2'),
             ('nested', 'copy', '3', 'before_arm', 'blocking', 'reverse', '2'),
             ('struct', 'copy', '2', 'after_wake', 'nba', 'forward', '1'),
             ('nested', 'direct', '2', 'after_wake', 'blocking', 'forward', '2'),
             ('scalar', 'copy', '3', 'after_arm', 'nba', 'reverse', '1')),
    constraints=('全432行が合法。各automatic taskが新しいイベントとpayloadを持ち、'
                 '復帰後に子プロセスが2 tick遅れて待機する。scalarを対照とし、'
                 'struct/入れ子structではメンバ参照と構造体全体のコピーを区別する。'
                 'コピー後は元のイベントをnoiseへ再結合しpayloadも変更する。'
                 '呼出し側の別名は待機登録前・登録後・起床後にnullへ解放するが、'
                 'トリガ用の別名は全起床後まで保持する。待機登録・解放・トリガ・観測は'
                 '別tickに置く。null待機、triggered、GC実行時期、物理的なメモリ回収、'
                 '遅延付き非ブロッキングトリガ、ref引数は対象外。未対応による除外なし。',),
)

SNAPSHOTS = ((0, 'returned'), (5, 'armed'), (7, 'first'), (9, 'second'),
             (11, 'third'), (17, 'repeated'), (19, 'released'),
             (23, 'fresh_armed'), (25, 'fresh_woke'), (27, 'final'))


def case_name(row: Row) -> str:
    return 'test_gen_cross_eventlife_' + '_'.join(row)


def reference(row: Row) -> str:
    """Closed-form first-wakeup and caller-alias observations."""
    count, listeners = int(row[2]), int(row[6])
    order = list(range(count))
    if row[5] == 'reverse':
        order.reverse()
    wakes = {tag: 6 + 2 * order.index(tag) for tag in order} | {3: 24}
    lines = ['created nonnull=1 independent=1']
    for tick, label in SNAPSHOTS:
        if tick == 19:
            lines.append('fresh nonnull=1 independent=1')
        lines.append(f'{label} time={tick}')
        for tag in range(4):
            active = tag < count or tag == 3 and tick >= 19
            when = wakes.get(tag, -1)
            release = ({'before_arm': 1, 'after_arm': 3}.get(row[3], when+1)
                       if tag != 3 else 26)
            primary = active and tick < release
            backup = active and tick < (18 if tag < 3 else 26)
            lines.append(f'{label} tag={tag} pnull={int(not primary)} '
                         f'bnull={int(not backup)} same={int(primary==backup)}')
            for slot in range(2):
                woke = active and slot < listeners and when < tick
                lines.append(f'{label} tag={tag} slot={slot} hits={int(woke)} '
                             f'at={when if woke else -1} value={100+tag if woke else 0} '
                             f'stamp={10*when+int(row[4]=="nba") if woke else 0}')
    return '\n'.join(lines)+'\n'


def snapshot(label: str) -> list[str]:
    lines = [f'    $display("{label} time=%0d", $time);']
    for tag in range(4):
        lines += [f'    $display("{label} tag={tag} pnull=%0d bnull=%0d same=%0d",',
                  f'             primary{tag} == null, backup{tag} == null,',
                  f'             primary{tag} == backup{tag});']
        for slot in range(2):
            lines += [f'    $display("{label} tag={tag} slot={slot} hits=%0d at=%0d value=%0d stamp=%0d",',
                      f'             hits[{tag}][{slot}], at_tick[{tag}][{slot}],',
                      f'             values[{tag}][{slot}], stamps[{tag}][{slot}]);']
    return lines


def make_case(row: Row) -> Case:
    storage, capture, calls, release, trigger, order, listeners = row
    count = int(calls)
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             '  event noise;', '  int stamp;',
             '  int hits[4][2], at_tick[4][2], values[4][2], stamps[4][2];']
    for tag in range(4):
        lines += [f'  event primary{tag}, backup{tag};']
    if storage != 'scalar':
        lines += ['  typedef struct { event go; int value; } leaf_t;']
    if storage == 'nested':
        lines += ['  typedef struct { leaf_t leaf; } item_t;']
    elif storage == 'struct':
        lines += ['  typedef leaf_t item_t;']
    lines += ['  task automatic launch(input int tag, output event retained,',
              '                        output event bridge);']
    if storage == 'scalar':
        lines += ['    event original_go, copied_go;', '    int original_value, copied_value;']
        original_event, original_value = 'original_go', 'original_value'
        copied_event, copied_value = 'copied_go', 'copied_value'
        copying = ['    copied_go = original_go;', '    copied_value = original_value;']
    else:
        lines += ['    item_t original, copied;']
        prefix = '.leaf' if storage == 'nested' else ''
        original_event, original_value = 'original'+prefix+'.go', 'original'+prefix+'.value'
        copied_event, copied_value = 'copied'+prefix+'.go', 'copied'+prefix+'.value'
        copying = ['    copied = original;']
    lines += [f'    {original_value} = 100 + tag;']
    selected_event, selected_value = original_event, original_value
    if capture == 'copy':
        lines += copying + [f'    {original_event} = noise;',
                            f'    {original_value} = -700 - tag;']
        selected_event, selected_value = copied_event, copied_value
    lines += [f'    retained = {selected_event};', '    bridge = retained;', '    fork']
    for slot in range(int(listeners)):
        lines += ['      begin', '        #2;', f'        @({selected_event});',
                  f'        hits[tag][{slot}]++;', f'        at_tick[tag][{slot}] = $time;',
                  f'        values[tag][{slot}] = {selected_value};',
                  f'        stamps[tag][{slot}] = stamp;', '      end']
    lines += ['    join_none', '  endtask', '  initial begin', '    stamp = 0;']
    for tag in range(4):
        lines += [f'    primary{tag} = null; backup{tag} = null;']
        for slot in range(2):
            lines += [f'    hits[{tag}][{slot}] = 0; at_tick[{tag}][{slot}] = -1;',
                      f'    values[{tag}][{slot}] = 0; stamps[{tag}][{slot}] = 0;']
    for tag in range(count):
        lines += [f'    launch({tag}, primary{tag}, backup{tag});']
    # Assertions on identity are deliberately ordinary output observations.
    # Never infer freshness from a simulator's private event-object identifiers.
    lines += ['    $display("created nonnull=%0d independent=%0d",']
    lines += ['             '+f'backup{t} != null && backup{t} != noise'+
              (' &&' if t < count-1 else ',') for t in range(count)]
    comparisons = [f'backup{a} != backup{b}' for a in range(count) for b in range(a+1, count)]
    lines += ['             '+(' && '.join(comparisons) or "1'b1")+');']
    tags = list(range(count))
    if order == 'reverse':
        tags.reverse()
    pulses = {6+2*i: tag for i, tag in enumerate(tags)}
    pulses |= {12+2*i: tag for i, tag in enumerate(tags)}
    pulses[24] = 3
    releases = {tag: {'before_arm': 1, 'after_arm': 3}.get(release, 7+2*tags.index(tag))
                for tag in range(count)}
    observations = dict(SNAPSHOTS)
    ticks = sorted(set(observations) | set(pulses) | set(releases.values()) | {4, 18, 20, 22, 26})
    now = 0
    for tick in ticks:
        if tick != now:
            lines += [f'    #{tick-now};']
        now = tick
        for tag, when in releases.items():
            if tick == when:
                lines += [f'    primary{tag} = null;']
        if tick in (4, 22):
            lines += ['    -> noise;']
        if tick == 18:
            for tag in range(count):
                lines += [f'    backup{tag} = null;']
        if tick == 19:
            lines += ['    launch(3, primary3, backup3);',
                      '    $display("fresh nonnull=%0d independent=%0d",',
                      '             backup3 != null, backup3 != noise);']
        if tick == 20:
            lines += ['    -> primary0;']
        if tick == 26:
            lines += ['    primary3 = null; backup3 = null;']
        if tick in pulses:
            tag = pulses[tick]
            lines += [f'    stamp = {10*tick};', f'    stamp <= {10*tick+1};',
                      f'    {"->" if trigger=="blocking" else "->>"} backup{tag};']
        if tick in observations:
            lines += snapshot(observations[tick])
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(
        case_name(row),
        'Automatic aggregate events retain distinct identities and captured payloads after owner return',
        '15.5.2 7.2 7.2.2 6.8 6.17 6.21 9.3.2 15.5.1 15.5.5.1 15.5.5.2 15.5.5.3 10.4.2',
        'One to three automatic calls create distinct event objects and captured payloads. '
        'Each returned task leaves one or two children that arm two ticks later. '
        'Scalar storage is a control for flat or nested unpacked structures. '
        'Copy cases assign the whole structure (or the two scalar fields), then '
        'rebind and overwrite the original fields. Caller aliases are cleared '
        'before registration, after registration or after waking; another alias '
        'remains available for the trigger. Independent calls receive separate '
        'ordered pulses. A static NBA payload distinguishes Active from NBA '
        'wakeups. Noise and repeated pulses must not wake the one-shot children. '
        'All retained aliases are cleared before a fresh call. Observations '
        'cover null state, identity, hit count, wake time, automatic payload and '
        'live static payload. No waits on null, garbage-collection timing, '
        'physical resource reclamation, ref arguments or delayed NBA triggers '
        'are qualified.',
        '\n'.join(lines), reference(row),
        extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
               'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
