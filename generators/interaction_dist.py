"""Operator grouping, typed distribution membership and failed randomization."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_dist'
VERSION = 1
CHAPTER = 18
MODEL = Model(
    'distribution_expression_binding',
    (('width', ('4', '8', '33')), ('sign', ('unsigned', 'signed')),
     ('operation', ('add_shift', 'add_mul', 'add_rel')),
     ('grouping', ('implicit', 'whole', 'altered')),
     ('weight', ('each', 'total')), ('layout', ('singleton', 'zero', 'overlap')),
     ('sequence', ('sat_only', 'sat_fail_sat', 'fail_sat_fail'))),
    lambda row: True,
    groups=(('width', 'sign', 'operation'), ('operation', 'grouping', 'layout'),
            ('layout', 'weight', 'sequence'), ('sign', 'operation', 'layout')),
    anchors=(('4', 'signed', 'add_shift', 'implicit', 'each', 'singleton', 'fail_sat_fail'),
             ('33', 'unsigned', 'add_mul', 'implicit', 'total', 'zero', 'sat_fail_sat'),
             ('8', 'signed', 'add_rel', 'implicit', 'each', 'singleton', 'sat_fail_sat'),
             ('4', 'unsigned', 'add_mul', 'altered', 'each', 'overlap', 'fail_sat_fail'),
             ('4', 'signed', 'add_shift', 'implicit', 'each', 'singleton', 'sat_only'),
             ('33', 'unsigned', 'add_mul', 'implicit', 'total', 'zero', 'sat_only'),
             ('8', 'signed', 'add_rel', 'implicit', 'each', 'singleton', 'sat_only'),
             ('4', 'unsigned', 'add_mul', 'altered', 'each', 'overlap', 'sat_only')),
    constraints=('全972行が合法。幅ごとに二つまたは三つの候補値を定め、正の重みを持つ解を一意にする。'
                 '算術・シフト・比較の既定の優先順位、全体を囲む括弧、結合を変える括弧を比較する。'
                 '単一項目、他候補のゼロ重み、ゼロ項目と正の単一値範囲の重複を確認する。'
                 '重みを全てゼロにして矛盾を作り、失敗時の初期値または直前の解の保持を観測する。'
                 '別オブジェクトは毎回成功する対照とする。確率比や乱数列の一致は要求しない。'
                 '正常系の反復と、成功・失敗を交互に行う二つの順序を分ける。'
                 'X/Z、実数、randc、default分布、継承、コールバック、並行randomizeは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_dist_' + '_'.join(row)


def solution(row: Row) -> int:
    w = int(row[0])
    return -(1 << (w-2))+1 if row[1] == 'signed' else (1 << (w-1))+1


def domain(row: Row) -> tuple[int, ...]:
    x = solution(row)
    return (x-1, x) if row[2] == 'add_rel' and row[3] != 'altered' else (x-1, x, x+2)


def expression_value(row: Row, x: int) -> tuple[int, int, bool]:
    w = int(row[0]); signed = row[1] == 'signed'
    altered = row[3] == 'altered'
    if row[2] == 'add_shift':
        value = x+2 if altered else (x+1)*2
    elif row[2] == 'add_mul':
        value = (x+1)*2 if altered else x+2
    elif not altered:
        summed = (x+1) & ((1 << w)-1)
        if signed and summed & (1 << (w-1)):
            summed -= 1 << w
        return int(summed < solution(row)+1), 1, False
    else:
        # The unsigned one-bit comparison makes the surrounding sum unsigned.
        value = x+int(1 < solution(row)+1)
        signed = False
    value &= (1 << w)-1
    if signed and value & (1 << (w-1)):
        value -= 1 << w
    return value, w, signed


def literal(value: int, width: int, signed: bool) -> str:
    return f"{width}'"+('s' if signed else '')+f'h{value & ((1 << width)-1):x}'


def expression(row: Row, variable: str = 'x') -> str:
    w = int(row[0]); signed = row[1] == 'signed'
    one, two = literal(1,w,signed), literal(2,w,signed)
    threshold = literal(solution(row)+1,w,signed)
    if row[2] == 'add_shift':
        text = f'{variable} + ({one} << {one})' if row[3] == 'altered' else f'{variable} + {one} << {one}'
    elif row[2] == 'add_mul':
        text = f'({variable} + {one}) * {two}' if row[3] == 'altered' else f'{variable} + {one} * {two}'
    else:
        text = f'{variable} + ({one} < {threshold})' if row[3] == 'altered' else f'{variable} + {one} < {threshold}'
    return '('+text+')' if row[3] == 'whole' else text


def failures(row: Row) -> tuple[int, ...]:
    return {'sat_only':(0,0,0),'sat_fail_sat':(0,1,0),'fail_sat_fail':(1,0,1)}[row[6]]


def reference(row: Row) -> str:
    w = int(row[0]); mask = (1 << w)-1
    state = -1 if row[1] == 'signed' else mask
    desired = solution(row); lines = []
    for phase, fail in enumerate(failures(row)):
        if not fail:state = desired
        for name, impossible, value in (('target',fail,state),('guard',0,desired)):
            expr,bits,_ = expression_value(row,value)
            lines.append(f'{name} phase={phase} impossible={impossible} ok={1-impossible} '
                         f'x={value} bits={value & mask:0{w}b} expr={expr} expr_bits={bits}')
    return '\n'.join(lines)+'\n'


def make_case(row: Row) -> Case:
    width,sign,_,_,weight,layout,_ = row
    w = int(width); signed = sign == 'signed'
    value,bits,expr_signed = expression_value(row,solution(row))
    item = literal(value,bits,expr_signed)
    operator = ':=' if weight == 'each' else ':/'
    positive = f'{item} {operator} (impossible ? 0 : 3)'
    entries = [positive] if layout != 'overlap' else [f'{item} {operator} 0',
                                                          f'[{item}:{item}] {operator} (impossible ? 0 : 3)']
    if layout in ('zero','overlap'):
        entries += [f'{literal(expression_value(row,x)[0],bits,expr_signed)} {operator} 0'
                    for x in domain(row) if x != solution(row)]
    lines = ['class dist_box;',f'  rand bit {sign} [{w-1}:0] x;', '  bit impossible;',
             '  constraint c_domain { x inside {'+', '.join(literal(x,w,signed) for x in domain(row))+'}; }',
             '  constraint c_dist {', '    '+expression(row)+' dist {',
             *['      '+entry+(',' if i+1<len(entries) else '') for i,entry in enumerate(entries)],
             '    };', '  }', 'endclass', f'module {case_name(row)};',
             '  dist_box target, guard_object; int ok;',
             '  task automatic show(input string who, input int phase,',
             '                      input dist_box obj, input int success);',
             '    $write("%s phase=%0d impossible=%0d ok=%0d x=%0d bits=%b ",',
             '           who, phase, obj.impossible, success, obj.x, obj.x);',
             '    $display("expr=%0d expr_bits=%0d",',
             '             '+expression(row,'obj.x')+',',
             '             $bits('+expression(row,'obj.x')+'));',
             '  endtask','  initial begin','    target = new; guard_object = new;',
             "    target.x = '1; guard_object.impossible = 0;"]
    for phase,fail in enumerate(failures(row)):
        lines += [f'    target.impossible = {fail};', '    ok = target.randomize();',
                  f'    show("target", {phase}, target, ok);', '    ok = guard_object.randomize();',
                  f'    show("guard", {phase}, guard_object, ok);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Distribution membership respects operator grouping, typed arithmetic and zero weights',
                '18.5.3 11.3.2 11.6.1 11.8.1 11.8.2 11.4.13 18.6.1 18.6.3',
                'A typed random word has two or three candidate values. A distribution '
                'on arithmetic, shift or comparison expressions leaves exactly one '
                'positive-weight solution. Implicit grouping, redundant whole-expression '
                'parentheses and precedence-changing parentheses are compared. Each '
                'or total weight syntax, zero-weight alternatives and an overlapping '
                'zero singleton plus positive singleton range check support membership, '
                'not statistical ratios. A nonrandom flag sets all weights to zero. '
                'Three calls repeat success or alternate success with failure, retaining initial '
                'all-one bits or the prior solution. A separate object always succeeds. '
                'Every call reports status, all word bits, typed decimal values, the '
                'expression result and its width. No X/Z, real values, randc, default '
                'distribution, inheritance, callbacks or concurrent randomization is used.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
