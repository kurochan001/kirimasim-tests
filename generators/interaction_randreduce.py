"""Array-reduction widths in constraints and state retention after failure."""

from math import prod

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_randreduce'
VERSION = 1
CHAPTER = 18
MODEL = Model(
    'array_reduction_constraint',
    (('width', ('4', '8', '33')), ('sign', ('unsigned', 'signed')),
     ('kind', ('fixed', 'dynamic')), ('method', ('sum', 'product')),
     ('projection', ('element', 'wide')), ('length', ('2', '3')),
     ('sequence', ('sat_fail_sat', 'fail_sat_fail'))),
    lambda row: True,
    groups=(('width', 'sign', 'projection'), ('method', 'projection', 'length'),
            ('kind', 'sequence', 'length'), ('width', 'method', 'sign')),
    anchors=(('4', 'unsigned', 'fixed', 'sum', 'element', '2', 'sat_fail_sat'),
             ('33', 'unsigned', 'dynamic', 'product', 'wide', '3', 'fail_sat_fail'),
             ('8', 'signed', 'fixed', 'product', 'element', '3', 'fail_sat_fail'),
             ('33', 'signed', 'dynamic', 'sum', 'wide', '2', 'sat_fail_sat')),
    constraints=('全192行が合法。各要素の制約で成功時の解を一意にし、リダクション条件だけを矛盾させる。'
                 '先頭を型の端点、残りを3または-3にして、要素幅とlongint拡張後の結果を区別する。'
                 '動的配列は初期サイズを要求より1要素多くし、失敗時のサイズと値の保持を観測する。'
                 '別オブジェクトは毎回成功する対照とする。乱数列の一致を要求しない。'
                 '全演算は拡張後64ビットの範囲内。空配列、X/Z、キュー、soft制約、継承、コールバック、並行実行は対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_randreduce_' + '_'.join(row)


def solution(row: Row) -> list[int]:
    width, sign, _, _, _, length, _ = row
    first = -(1 << (int(width)-1)) if sign == 'signed' else (1 << int(width))-1
    tail = -3 if sign == 'signed' else 3
    return [first]+[tail]*(int(length)-1)


def reductions(row: Row, values: list[int]) -> tuple[int, int]:
    total = sum(values) if row[3] == 'sum' else prod(values)
    mask = (1 << int(row[0]))-1
    natural = total & mask
    if row[1] == 'signed' and natural & (1 << (int(row[0])-1)):
        natural -= mask+1
    return natural, total


def reference(row: Row) -> str:
    w = int(row[0])
    values = [2]*(int(row[5])+(row[2] == 'dynamic'))
    solved = solution(row)
    failures = (False, True, False) if row[6] == 'sat_fail_sat' else (True, False, True)
    lines = []

    def report(who, phase, fail, words):
        natural, wide = reductions(row, words)
        bits = ','.join(f'{value & ((1 << w)-1):0{w}b}' for value in words)
        lines.extend([f'{who} phase={phase} impossible={int(fail)} ok={int(not fail)} size={len(words)}',
                      'values='+bits,
                      f'natural={natural} wide={wide} natural_bits={w} wide_bits=64'])

    for phase, fail in enumerate(failures):
        if not fail:
            values = solved.copy()
        report('target', phase, fail, values)
        report('guard', phase, False, solved)
    return '\n'.join(lines)+'\n'


def make_case(row: Row) -> Case:
    width, sign, kind, method, projection, length, _ = row
    w, n = int(width), int(length)
    literal = lambda value: f"{w}'"+('s' if sign == 'signed' else '')+f'h{value & ((1 << w)-1):x}'
    wide_literal = lambda value: ('-' if value < 0 else '')+f"64'sd{abs(value)}"
    solved = solution(row)
    expected = reductions(row, solved)[projection == 'wide']
    target_literal = wide_literal if projection == 'wide' else literal
    expression = 'data.'+method+'()'+(' with (longint\'(item))' if projection == 'wide' else '')
    lines = ['class reduction_box;',
             f'  rand bit {sign} [{w-1}:0] data'+('[];' if kind == 'dynamic' else f'[{n}];'),
             '  bit impossible;']
    if kind == 'dynamic':
        lines += [f'  constraint c_shape {{ data.size() == {n}; }}']
    lines += ['  constraint c_values {',
              f'    foreach (data[i]) data[i] == ((i == 0) ? {literal(solved[0])} : {literal(solved[1])});',
              '  }', '  constraint c_reduce {',
              f'    {expression} ==',
              f'      (impossible ? {target_literal(expected+1)} : {target_literal(expected)});',
              '  }', 'endclass', f'module {case_name(row)};',
              '  reduction_box target, guard_object;', '  int ok;',
              '  task automatic show(input string who, input int phase,',
              '                      input reduction_box obj, input int success);',
              '    longint natural, wide;', f'    natural = obj.data.{method}();',
              f"    wide = obj.data.{method}() with (longint'(item));",
              '    $display("%s phase=%0d impossible=%0d ok=%0d size=%0d",',
              '             who, phase, obj.impossible, success, $size(obj.data));',
              '    $write("values=");', '    foreach (obj.data[i]) begin',
              '      if (i != 0) $write(",");', '      $write("%b", obj.data[i]);', '    end',
              '    $display("");',
              '    $display("natural=%0d wide=%0d natural_bits=%0d wide_bits=%0d",',
              f'             natural, wide, $bits(obj.data.{method}()),',
              f"             $bits(obj.data.{method}() with (longint'(item))));", '  endtask',
              '  initial begin', '    target = new; guard_object = new;']
    if kind == 'dynamic':
        lines += [f'    target.data = new[{n+1}]; guard_object.data = new[{n+1}];']
    lines += [f'    foreach (target.data[i]) target.data[i] = {literal(2)};',
              f'    foreach (guard_object.data[i]) guard_object.data[i] = {literal(2)};',
              '    guard_object.impossible = 0;']
    failures = (False, True, False) if row[6] == 'sat_fail_sat' else (True, False, True)
    for phase, fail in enumerate(failures):
        lines += [f'    target.impossible = {int(fail)};', '    ok = target.randomize();',
                  f'    show("target", {phase}, target, ok);', '    ok = guard_object.randomize();',
                  f'    show("guard", {phase}, guard_object, ok);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Array reductions in constraints retain element or with-expression types and failed state',
                '18.5.7.2 7.12.3 18.5.7.1 18.6.1 18.6.3 6.24.1',
                'Each array element is fixed by constraints, making the successful solution '
                'unique. A nonrandom flag contradicts only the sum or product reduction. '
                'The reduction uses the element type or a longint cast inside with. Typed '
                'endpoints and signed or unsigned threes distinguish narrow overflow from '
                'extension before reduction. Three attempts alternate success and failure; '
                'failure retains sentinel or previously solved elements. Dynamic arrays '
                'start one element larger than their constrained size, so first-attempt '
                'failure must also retain shape. A separate object succeeds every time. '
                'Every attempt reports return status, size, all element bits, natural and '
                'wide arithmetic results and the actual reduction-expression widths. '
                'All wide products and sums fit signed 64 bits. No random-sequence '
                'matching, empty arrays, X/Z, queues, soft constraints, inheritance, '
                'callbacks or concurrent randomization is used. Fixed Verilator 5.052 '
                'differs from the original full output. Separate auxiliary controls cast '
                'only the natural observation to its element type and cover fixed '
                'arrays; these controls are not passes for the original cases.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
