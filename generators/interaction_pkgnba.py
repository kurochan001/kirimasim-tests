"""Shared package objects retain NBA value, target, order and lifetime rules."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_pkgnba'
VERSION = 1
CHAPTER = 26
MODEL = Model(
    'package_nba_capture',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('access', ('qualified', 'wildcard', 'explicit')),
     ('storage', ('scalar', 'up', 'down')), ('timing', ('now', 'delayed')),
     ('order', ('a_b', 'b_a'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('access', 'storage', 'order'),
            ('storage', 'timing', 'order'), ('width', 'storage', 'timing'),
            ('state', 'value', 'order'), ('access', 'timing', 'order')),
    anchors=(('1', 'bit', 'known', 'qualified', 'scalar', 'now', 'a_b'),
             ('129', 'logic', 'z', 'explicit', 'down', 'delayed', 'b_a'),
             ('65', 'logic', 'x', 'wildcard', 'up', 'delayed', 'a_b'),
             ('33', 'bit', 'z', 'qualified', 'down', 'now', 'b_a'),
             ('32', 'logic', 'known', 'explicit', 'up', 'delayed', 'b_a'),
             ('64', 'bit', 'known', 'wildcard', 'scalar', 'now', 'a_b')),
    constraints=('全行が合法で、未対応による除外なし。'
                 '同じinitialから二つのモジュールのautomaticタスクを順に呼ぶため、NBAの予約順序が定まる。'
                 '対象は静的なpackage変数で、入力引数と添字は予約後に書き換え、タスク復帰後に反映する。'
                 '別の参照方法で読むprobe、隣接要素、同名変数を持つ別packageを対照にする。'
                 '昇順配列は負の添字、降順配列は非零の添字を使う。'
                 '独立した並行writer間の順序、動的な配列、実数、net、force、VPIは対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_pkgnba_' + '_'.join(row)


def indices(row: Row) -> tuple[int, int]:
    return {'scalar': (0, 1), 'up': (-2, -1), 'down': (2, 1)}[row[4]]


def address(row: Row, package: str, guard: bool = False, dynamic: str | None = None) -> str:
    if row[4] == 'scalar': return package + ('::neighbor' if guard else '::target')
    index = dynamic if dynamic is not None else str(indices(row)[int(guard)])
    return package + '::target[' + index + ']'


def stimuli(row: Row, phase: int) -> tuple[str, str, str, str, str]:
    w = int(row[0])
    if row[2] == 'known':
        a = ('10'*w)[:w] if phase == 0 else '0'*w
        b = a.translate(str.maketrans('01', '10'))
    else:
        a = row[2]*w
        b = '1'*w if phase == 0 else '1'+'0'*(w-1)
    last = b if row[6] == 'a_b' else a
    final = last.replace('x', '0').replace('z', '0') if row[1] == 'bit' else last
    before = final.translate(str.maketrans('01', '10')) if set(final) <= {'0', '1'} else '0'*w
    other = before.translate(str.maketrans('01', '10'))
    return a, b, before, other, final


def reference(row: Row) -> str:
    lines = []; left, _ = indices(row)
    for phase in (0, 1):
        a, b, before, other, final = stimuli(row, phase)
        for who in ((0, 1) if row[6] == 'a_b' else (1, 0)):
            lines.append(f'put phase={phase} who={who} t={phase*3} index={left} data={(a,b)[who]}')
        for stage, dt in (('active', 0), ('edge', 1), ('after', 2), ('idle', 3)):
            value = before if dt == 0 or (dt == 1 and row[5] == 'delayed') else final
            lines.append(f's phase={phase} at={stage} t={phase*3+dt} value={value} '
                         f'guard={before} other={other} og={other} alias={value}')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    w, state, _, access, storage, timing, order = row
    left, right = indices(row)
    lines = ['`timescale 1ns/1ns']
    for package in ('payload_pkg', 'control_pkg'):
        lines += [f'package {package};', f'  typedef {state} [{int(w)-1}:0] word_t;']
        lines += (['  word_t target, neighbor;'] if storage == 'scalar' else
                  [f'  word_t target[{left}:{right}];'])
        lines += ['endpackage']
    lines += ['module pkg_writer #(parameter int ID = 0);', f'  typedef logic [{int(w)-1}:0] source_t;']
    if access != 'qualified':
        lines += ['  import payload_pkg::' + ('*' if access == 'wildcard' else 'target') + ';']
    target = address(row, 'payload_pkg', dynamic='where')
    if access != 'qualified': target = target.removeprefix('payload_pkg::')
    lines += ['  task automatic enqueue(input int phase, input source_t data, input integer where);',
              '    $display("put phase=%0d who=%0d t=%0d index=%0d data=%b",',
              '             phase, ID, $time, where, data);',
              f'    {target} <=' + (' #1' if timing == 'delayed' else '') + ' data;',
              "    data = '1;", f'    where = {right};', '  endtask', 'endmodule',
              'module pkg_probe;']
    # Read the same object using a different spelling from its writers.
    if access == 'qualified': lines += ['  import payload_pkg::*;']
    elif access == 'wildcard': lines += ['  import payload_pkg::target;']
    read = address(row, 'payload_pkg', dynamic='index')
    if access != 'explicit': read = read.removeprefix('payload_pkg::')
    lines += ['  function automatic payload_pkg::word_t read_target(input integer index);',
              f'    return {read};', '  endfunction', 'endmodule', f'module {case_name(row)};',
              f'  logic [{int(w)-1}:0] source;', '  integer index;',
              '  pkg_writer #(.ID(0)) a();', '  pkg_writer #(.ID(1)) b();', '  pkg_probe probe();',
              '  initial begin']
    for phase in (0, 1):
        a, b, before, other, _ = stimuli(row, phase)
        for package, word in (('payload_pkg', before), ('control_pkg', other)):
            for guard in (False, True): lines += [f'    {address(row, package, guard)} = {literal(word)};']
        lines += [f'    index = {left};']
        for who in ((0, 1) if order == 'a_b' else (1, 0)):
            lines += [f'    source = {literal((a,b)[who])};',
                      f'    {("a", "b")[who]}.enqueue({phase}, source, index);']
        lines += [f'    source = {literal(before)};', f'    index = {right};']
        for stage in ('active', 'edge', 'after', 'idle'):
            if stage != 'active': lines += ['    #1;']
            lines += [f'    $display("s phase={phase} at={stage} t=%0d value=%b guard=%b other=%b og=%b alias=%b",',
                      f'             $time, {address(row, "payload_pkg")},',
                      f'             {address(row, "payload_pkg", True)}, {address(row, "control_pkg")},',
                      f'             {address(row, "control_pkg", True)}, probe.read_target({left}));']
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(
        case_name(row), 'Package NBA updates share one object and preserve captured values, targets and order',
        '26.3 26.4 10.4.2 4.6 4.4.2.2 4.4.2.4 6.11.2 7.4.1 13.5.1',
        'One initial thread calls automatic tasks in two writer instances in a defined '
        'order, scheduling two NBAs to one static package object. Qualified names and '
        'wildcard/explicit imports cross scalar or ascending/descending array targets. '
        'Change task inputs and indices after reservation, return both frames and '
        'change the caller source/index. Read Active, due-time Active, settled and '
        'idle states through the package and a probe using another reference spelling. '
        'A neighboring object and an identically named variable in another package '
        'must remain unchanged. Two frames distinguish known/unknown input capture, '
        'two-state conversion, FIFO ordering and retained static storage. No order '
        'between independent concurrent writer processes is assumed.', source(row), reference(row),
        fourstate=row[2] != 'known',
        extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
               'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
