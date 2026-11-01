"""Dynamic constraint inheritance, external completion and failure retention."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_constraint'
VERSION = 1
CHAPTER = 18
MODEL = Model(
    'constraint_inheritance',
    (('handle', ('base', 'derived')),
     ('rule', ('replace', 'add')),
     ('origin', ('concrete', 'pure')),
     ('definition', ('inline', 'extern')),
     ('sequence', ('sat_fail_sat', 'fail_sat_fail')),
     ('width', ('4', '8', '33'))),
    lambda row: True,
    groups=(('rule', 'origin', 'definition'), ('rule', 'handle', 'sequence'),
            ('width', 'rule', 'sequence'), ('width', 'origin', 'definition')),
    anchors=(('base', 'replace', 'pure', 'extern', 'fail_sat_fail', '33'),
             ('derived', 'add', 'concrete', 'inline', 'sat_fail_sat', '4'),
             ('base', 'add', 'pure', 'inline', 'fail_sat_fail', '8'),
             ('derived', 'replace', 'concrete', 'extern', 'sat_fail_sat', '33')),
    constraints=('全96行が合法。3階層の継承でpure制約は中間クラスが実装し、'
                 '派生クラスの同名制約は置換、別名制約は追加になる。'
                 '成功時の解は一意で、乱数の値や探索順序に依存しない。'
                 '非randフラグで充足可能と矛盾を切り替え、失敗時の初期値または直前の解を保持する。'
                 '別オブジェクトは反対の静的型のハンドルから毎回成功する対照とする。'
                 'X/Z、randc、soft、constraint_mode、rand_mode、乱数列の一致は対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_constraint_' + '_'.join(row)


def solved_values(row: Row) -> tuple[int, int]:
    value = (1 << (int(row[5]) - 2)) + (3 if row[1] == 'replace' else 1)
    return value, value + 3


def failures(row: Row) -> tuple[bool, ...]:
    return (False, True, False) if row[4] == 'sat_fail_sat' else (True, False, True)


def reference(row: Row) -> str:
    width = int(row[5])
    a, b = (1 << width) - 4, (1 << width) - 3
    expected_a, expected_b = solved_values(row)
    lines = []
    for phase, fail in enumerate(failures(row)):
        if not fail:
            a, b = expected_a, expected_b
        lines += [f'phase={phase} fail={int(fail)} ok={int(not fail)} a={a} b={b}',
                  f'guard={phase} fail=0 ok=1 a={expected_a} b={expected_b}']
    return '\n'.join(lines) + '\n'


def make_case(row: Row) -> Case:
    handle, rule, origin, definition, sequence, width = row
    w = int(width)
    base_value = (1 << (w - 2)) + 1
    expected_a, expected_b = solved_values(row)
    literal = lambda value: f"{w}'d{value}"
    lines = ['virtual class constraint_root;', f'  rand bit [{w-1}:0] a, b;',
             '  bit impossible;', f'  constraint c_keep {{ b == a + {literal(3)}; }}']
    lines += (['  pure constraint c_value;'] if origin == 'pure' else
              [f'  constraint c_value {{ a == {literal(base_value)}; }}'])
    lines += ['endclass', 'class constraint_middle extends constraint_root;']
    if origin == 'pure':
        lines += [f'  constraint c_value {{ a == {literal(base_value)}; }}']
    lines += ['endclass', 'class constraint_leaf extends constraint_middle;']
    constraint = 'c_value' if rule == 'replace' else 'c_added'
    body = ([f'a == {literal(expected_a)};'] if rule == 'replace' else [])
    body += [f'b == (impossible ? {literal(expected_b+1)} : {literal(expected_b)});']
    if definition == 'inline':
        lines += [f'  constraint {constraint} {{', *['    '+s for s in body], '  }']
    else:
        lines += [f'  extern constraint {constraint};']
    lines += ['endclass']
    if definition == 'extern':
        lines += [f'constraint constraint_leaf::{constraint} {{', *['  '+s for s in body], '}']
    lines += [f'module {case_name(row)};',
              '  constraint_leaf target, guard_object;',
              '  constraint_root target_base, guard_base;', '  int ok, guard_ok;',
              '  initial begin', '    target = new; guard_object = new;',
              '    target_base = target; guard_base = guard_object;',
              f'    target.a = {literal((1 << w)-4)}; target.b = {literal((1 << w)-3)};',
              '    guard_object.impossible = 0;']
    target = 'target_base' if handle == 'base' else 'target'
    guard = 'guard_object' if handle == 'base' else 'guard_base'
    for phase, fail in enumerate(failures(row)):
        lines += [f'    target.impossible = {int(fail)};',
                  f'    ok = {target}.randomize();',
                  f'    $display("phase={phase} fail=%0d ok=%0d a=%0d b=%0d",',
                  '             target.impossible, ok, target.a, target.b);',
                  f'    guard_ok = {guard}.randomize();',
                  f'    $display("guard={phase} fail=%0d ok=%0d a=%0d b=%0d",',
                  '             guard_object.impossible, guard_ok, guard_object.a, guard_object.b);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Inherited constraints dispatch dynamically and failed randomization preserves object state',
                '18.5.2 18.5.1 18.6.1 18.6.3 8.13 8.21',
                'A root, middle and leaf class share two random unsigned words. The root '
                'keeps b equal to a plus three; its value constraint is concrete or pure '
                'and completed by the middle class. The leaf replaces the value constraint '
                'or adds another constraint, inline or by an external block. Calls through '
                'base and derived handles must use the leaf constraints. A nonrandom flag '
                'alternates a unique solution with a contradiction. Failure must retain '
                'initial sentinel words or the previous successful values. A separate '
                'object, called through the opposite handle type, is an always-satisfiable '
                'control. Known values and unique solutions avoid random-sequence assumptions. '
                'Widths 4, 8 and 33 cross narrow and 32-bit storage boundaries; no X/Z, '
                'randc, soft constraints, mode APIs, callbacks or concurrent solvers are used.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
