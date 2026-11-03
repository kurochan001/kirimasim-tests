"""Package change fanout, projected events, wait conditions and function sensitivity."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_pkgwatch'
VERSION = 1
CHAPTER = 26
MODEL = Model(
    'package_change_observers',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('access', ('qualified', 'wildcard', 'explicit')),
     ('storage', ('scalar', 'up', 'down')), ('update', ('blocking', 'nba')),
     ('event', ('full', 'lsb')), ('wait', ('logical', 'case'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('access', 'storage', 'event'),
            ('state', 'value', 'wait'), ('event', 'update', 'wait'),
            ('width', 'storage', 'update'), ('access', 'event', 'wait')),
    anchors=(('1', 'bit', 'known', 'qualified', 'scalar', 'blocking', 'full', 'logical'),
             ('129', 'logic', 'z', 'explicit', 'down', 'nba', 'lsb', 'case'),
             ('65', 'logic', 'x', 'wildcard', 'up', 'blocking', 'full', 'logical'),
             ('33', 'bit', 'z', 'qualified', 'down', 'nba', 'lsb', 'logical'),
             ('32', 'logic', 'known', 'explicit', 'up', 'nba', 'full', 'case'),
             ('64', 'bit', 'known', 'wildcard', 'scalar', 'blocking', 'lsb', 'case')),
    constraints=('全行が合法で、未対応による除外なし。'
                 '初期化は時刻零、待機の登録は時刻一、最初の変更は時刻五として登録競合を避ける。'
                 '二つの観測モジュールは同じpackage変数、対照は別packageの同名変数を読む。'
                 'イベントは全体または最下位ビットの変化だけを数え、always_combは関数内の外部参照を追う。'
                 'waitはゼロとの等価または等価性で一回だけ完了し、現在の条件値と保持した起床履歴を別に読む。'
                 '配列の負の昇順添字と非零の降順添字、再書込み、隣接要素、対照の後続更新も確認する。'
                 '可変の監視添字、クラス、動的配列、独立writer間の順序、XからZへの直接遷移は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_pkgwatch_' + '_'.join(row)


def indices(row: Row) -> tuple[int, int]:
    return {'scalar': (0, 1), 'up': (-2, -1), 'down': (2, 1)}[row[4]]


def address(row: Row, package: str, neighbor=False) -> str:
    if row[4] == 'scalar': return package + ('::neighbor' if neighbor else '::target')
    return package + '::target[' + str(indices(row)[int(neighbor)]) + ']'


def actions(row: Row) -> tuple[tuple[str, bool, str], ...]:
    w = int(row[0])
    low, high, zero, one = '0'*(w-1)+'1', '1'+'0'*(w-1), '0'*w, '1'*w
    middle = one if row[2] == 'known' else row[2]*w
    return (('payload_pkg', False, low), ('payload_pkg', False, low),
            ('payload_pkg', False, middle), ('payload_pkg', False, high),
            ('payload_pkg', False, zero), ('payload_pkg', False, zero),
            ('payload_pkg', True, zero), ('control_pkg', False, zero))


def reference(row: Row) -> str:
    w = int(row[0]); one, zero = '1'*w, '0'*w
    values = {('payload_pkg', False): one, ('payload_pkg', True): one,
              ('control_pkg', False): one, ('control_pkg', True): one}
    state = {p: {'hits': 0, 'last': zero, 'at': -1, 'wakes': 0, 'wt': -1, 'held': zero}
             for p in ('payload_pkg', 'control_pkg')}
    lines = []
    def snapshot(tag, tick, drive):
        lines.append(f'snap tag={tag} t={tick} drive={drive} '
                     f'neighbor={values["payload_pkg", True]} other_guard={values["control_pkg", True]}')
        for name, package in (('a', 'payload_pkg'), ('b', 'payload_pkg'), ('g', 'control_pkg')):
            value = values[package, False]; s = state[package]
            pred = '1' if value == zero else ('x' if row[7] == 'logical' and set(value) <= {'x', 'z'} else '0')
            lines.append(f'o name={name} data={value} copy={value} hits={s["hits"]} '
                         f'last={s["last"]} at={s["at"]} pred={pred} wakes={s["wakes"]} '
                         f'wt={s["wt"]} held={s["held"]}')
    snapshot('armed', 2, one)
    for step, (package, neighbor, raw) in enumerate(actions(row), 1):
        tick = step*5; old = values[package, neighbor]
        value = raw.replace('x', '0').replace('z', '0') if row[1] == 'bit' else raw
        active = value if row[5] == 'blocking' else old
        lines.append(f'drive step={step} t={tick} raw={raw} active={active}')
        values[package, neighbor] = value
        if not neighbor:
            prior, now = (old, value) if row[6] == 'full' else (old[-1], value[-1])
            s = state[package]
            if prior != now: s.update(hits=s['hits']+1, last=value, at=tick)
            if value == zero and not s['wakes']: s.update(wakes=1, wt=tick, held=value)
        snapshot(str(step), tick+1, raw)
    snapshot('idle', 45, zero)
    return '\n'.join(lines)+'\n'


def observer(row: Row, package: str, module: str) -> list[str]:
    w = int(row[0]); access = row[3]
    ref = address(row, package)
    if access != 'qualified': ref = ref.removeprefix(package+'::')
    event = ref if row[6] == 'full' else ref+'[0]'
    condition = f'{ref} ' + ('==' if row[7] == 'logical' else '===') + f" {w}'h0"
    lines = [f'module {module};', f'  typedef {row[1]} [{w-1}:0] word_t;']
    if access != 'qualified': lines += [f'  import {package}::' + ('*' if access == 'wildcard' else 'target') + ';']
    lines += ['  word_t copy = 0, last = 0, held = 0;', '  int hits = 0, at = -1, wakes = 0, wt = -1;',
              '  function automatic word_t sample_word();', f'    return {ref};', '  endfunction',
              '  function automatic logic predicate_now();', f'    return {condition};', '  endfunction',
              '  always_comb copy = sample_word();', '  initial begin', '    #1;',
              '    forever begin', f'      @({event});', f'      hits++; last = {ref}; at = $time;',
              '    end', '  end', '  initial begin', '    #1;', f'    wait ({condition});',
              f'    wakes++; wt = $time; held = {ref};', '  end', 'endmodule']
    return lines


def source(row: Row) -> str:
    w = int(row[0]); left, right = indices(row)
    lines = ['`timescale 1ns/1ns']
    for p in ('payload_pkg', 'control_pkg'):
        lines += [f'package {p};', f'  typedef {row[1]} [{w-1}:0] word_t;']
        lines += ['  word_t target, neighbor;'] if row[4] == 'scalar' else [f'  word_t target[{left}:{right}];']
        lines += ['endpackage']
    lines += observer(row, 'payload_pkg', 'payload_watch') + observer(row, 'control_pkg', 'control_watch')
    lines += [f'module {case_name(row)};', f'  logic [{w-1}:0] drive;',
              '  payload_watch a();', '  payload_watch b();', '  control_watch g();', '  initial begin']
    for p in ('payload_pkg', 'control_pkg'):
        for neighbor in (False, True): lines += [f"    {address(row,p,neighbor)} = '1;"]
    lines += ["    drive = '1;", '    #2;']
    def snapshot(tag):
        lines.extend([f'    $display("snap tag={tag} t=%0d drive=%b neighbor=%b other_guard=%b",',
                      f'             $time, drive, {address(row,"payload_pkg",True)},',
                      f'             {address(row,"control_pkg",True)});'])
        for name, p in (('a','payload_pkg'), ('b','payload_pkg'), ('g','control_pkg')):
            lines.extend([f'    $write("o name={name} data=%b copy=%b hits=%0d last=%b at=%0d pred=%b ",',
                          f'             {address(row,p)}, {name}.copy, {name}.hits, {name}.last,',
                          f'             {name}.at, {name}.predicate_now());',
                          '    $display("wakes=%0d wt=%0d held=%b",',
                          f'             {name}.wakes, {name}.wt, {name}.held);'])
    snapshot('armed')
    for step,(p,neighbor,raw) in enumerate(actions(row),1):
        lines += ['    #3;' if step == 1 else '    #4;', f'    drive = {literal(raw)};',
                  f'    {address(row,p,neighbor)} ' + ('=' if row[5]=='blocking' else '<=') + ' drive;',
                  f'    $display("drive step={step} t=%0d raw=%b active=%b",',
                  f'             $time, drive, {address(row,p,neighbor)});', '    #1;']
        snapshot(str(step))
    lines += ['    #4;']; snapshot('idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Package changes wake independent event and wait observers and function-sensitive combinational logic',
                '26.3 26.4 9.4.2 9.4.3 9.2.2.2 9.2.2.2.1 11.4.6 4.4.2.2 4.4.2.4 7.4.1',
                'Two observers share a package object; a third observes an independent package. '
                'Initialize at time zero, arm waiters at one, and start changes at five. '
                'Compare full-vector or low-bit event counts, last-event data/time, a one-shot '
                'logical/case-equality wait, its retained wake history and an always_comb '
                'copy reading the package through a no-argument function. Observe immediate '
                'blocking/NBA data separately from settled observer state. Repeated writes, '
                'upper-only changes, X/Z, recovery, neighbor-only and later guard updates '
                'distinguish missing, extra or misbound notifications. Print only in the '
                'producer after settling; assume no relative ordering of observer processes.',
                source(row), reference(row), fourstate=row[2]!='known',
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
