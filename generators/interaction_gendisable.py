"""Lexical default-disable binding across generate forms and reset intervals."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_gendisable'
VERSION = 1
CHAPTER = 16
MODEL = Model(
    'generate_default_disable',
    (('form', ('if', 'case', 'loop')), ('default', ('inherit', 'override')),
     ('shadow', ('absent', 'present')), ('mode', ('default', 'zero', 'explicit')),
     ('timing', ('at_start', 'between', 'at_end')), ('order', ('before', 'after'))),
    lambda row: True,
    groups=(('default', 'shadow', 'mode'), ('form', 'default', 'order'),
            ('mode', 'timing', 'default'), ('form', 'shadow', 'timing')),
    anchors=(('if', 'inherit', 'present', 'default', 'between', 'after'),
             ('case', 'override', 'present', 'default', 'at_end', 'before'),
             ('loop', 'override', 'absent', 'zero', 'at_start', 'after'),
             ('loop', 'inherit', 'present', 'explicit', 'at_end', 'after')),
    constraints=('全216行が合法。二つのgenerate実体の子スコープで、親のdefaultの継承、'
                 '外側generateでの上書き、内側の同名信号、明示disableとゼロによる取消しを比較する。'
                 '各行は無効化なし・親・各実体の局所条件・各実体の明示条件と正常終了の7フェーズ。'
                 '開始前の条件、クロック間だけのパルス、終了クロックのNBA更新を区別する。'
                 'vacuous passも計数し、無効化された試行は成功にも失敗にも含めない。'
                 'X/Z、複数クロック、ネストしたmodule宣言、interface/program、'
                 'property内の明示disable、アサーション制御は対象外。未対応による除外なし。',),
)

PHASES = (('none', 0), ('root', 0), ('local0', 0), ('local1', 0),
          ('manual0', 0), ('manual1', 0), ('none', 1))
MASKS = {'none': 0, 'root': 16, 'local0': 4, 'local1': 8, 'manual0': 1, 'manual1': 2}


def case_name(row: Row) -> str:
    return 'test_gen_cross_gendisable_' + '_'.join(row)


def reference(row: Row) -> str:
    counts = {name: [0, 0] for name in ('root', 'lane0', 'lane1', 'guard')}
    lines = []
    for phase, (pulse, datum) in enumerate(PHASES):
        lines.append(f'phase={phase} pulse={pulse} data={datum}')
        for name in ('root', 'lane0', 'lane1', 'guard'):
            gate = 'root'
            if name == 'guard' or (name != 'root' and row[3] == 'zero'):
                gate = 'none'
            elif name != 'root':
                lane = name[-1]
                gate = 'manual'+lane if row[3] == 'explicit' else (
                    'local'+lane if row[1] == 'override' else 'root')
            disabled = pulse != 'none' and pulse == gate
            counts[name][0] += int(not (disabled and row[4] == 'at_end'))
            counts[name][0 if datum else 1] += int(not disabled)
        lines.append(f'root pass={counts["root"][0]} fail={counts["root"][1]}')
        for lane in range(2):
            p, f = counts['lane'+str(lane)]
            gp, gf = counts['guard']
            lines.append(f'lane{lane} pass={p} fail={f} guard_pass={gp} guard_fail={gf}')
    return '\n'.join(lines)+'\n'


def assertion(label: str, condition: str, prefix: str) -> list[str]:
    return [f'  {label}: assert property (@(posedge clk) {condition}start |=> datum)',
            f'    {prefix}pass++; else {prefix}fail++;']


def make_case(row: Row) -> Case:
    form, default, shadow, mode, timing, order = row
    top = case_name(row)

    def lane_body(index):
        lines = [f'  wire own_reset = local_reset[{index}];']
        declaration = ['  default disable iff own_reset;'] if default == 'override' else []
        if order == 'before':
            lines += declaration
        lines += ['  if (1) begin : leaf', '    int target_pass = 0, target_fail = 0;',
                  '    int guard_pass = 0, guard_fail = 0;']
        if shadow == 'present':
            lines += [f'    wire rst = !{top}.rst;', '    wire own_reset =',
                      f'      !{top}.local_reset[{index}];']
        condition = '' if mode == 'default' else 'disable iff ('+(
            "1'b0" if mode == 'zero' else f'manual_reset[{index}]')+') '
        lines += ['  '+line for line in assertion('target_check', condition, 'target_')]
        lines += ['  '+line for line in assertion('guard_check', "disable iff (1'b0) ", 'guard_')]
        lines += ['  end']
        if order == 'after':
            lines += declaration
        return lines

    lines = ['`timescale 1ns/1ns', f'module {top};',
             '  bit clk = 0, start = 0, datum = 0, rst = 0;',
             "  bit [1:0] local_reset = 2'b00, manual_reset = 2'b00;",
             "  bit nba_reset = 0; bit [4:0] pending_reset = 5'b00000;",
             '  int root_pass = 0, root_fail = 0;']
    if order == 'before':
        lines += ['  default disable iff rst;']
    lines += assertion('root_check', '', 'root_')
    if form == 'loop':
        lines += ['  for (genvar i = 0; i < 2; i++) begin : lane', *lane_body('i'), '  end']
        paths = [f'lane[{i}].leaf' for i in range(2)]
    else:
        paths = [f'lane{i}.leaf' for i in range(2)]
        for i in range(2):
            opening = f'  if (1) begin : lane{i}' if form == 'if' else f'  case (1)\n    1: begin : lane{i}'
            lines += [opening, *lane_body(str(i)), '  end']
            if form == 'case':
                lines += ['  endcase']
    if order == 'after':
        lines += ['  default disable iff rst;']
    lines += ['  always @(posedge clk)',
              '    if (nba_reset) {rst, local_reset, manual_reset} <= pending_reset;',
              '  initial begin']
    for phase, (pulse, datum) in enumerate(PHASES):
        lines += ["    {rst, local_reset, manual_reset} = 5'b00000;",
                  f'    start = 1; datum = {datum}; nba_reset = 0;',
                  f"    pending_reset = 5'b{MASKS[pulse]:05b};", '    #2;']
        if timing == 'at_start':
            lines += ['    {rst, local_reset, manual_reset} = pending_reset;']
        lines += ['    #3 clk = 1;', '    #1 clk = 0;', '    #2;']
        if timing == 'between':
            lines += ['    {rst, local_reset, manual_reset} = pending_reset;']
        lines += ['    #2 start = 0;', "    #2 {rst, local_reset, manual_reset} = 5'b00000;", '    #1;']
        if timing == 'at_end':
            lines += ['    nba_reset = 1;']
        lines += ['    #2 clk = 1;', '    #1 clk = 0;',
                  "    #2 {rst, local_reset, manual_reset} = 5'b00000; nba_reset = 0;", '    #1;',
                  f'    $display("phase={phase} pulse={pulse} data=%0d", datum);',
                  '    $display("root pass=%0d fail=%0d", root_pass, root_fail);']
        for i, path in enumerate(paths):
            lines += [f'    $display("lane{i} pass=%0d fail=%0d guard_pass=%0d guard_fail=%0d",',
                      f'      {path}.target_pass, {path}.target_fail,',
                      f'      {path}.guard_pass, {path}.guard_fail);']
        lines += ['    #1;']
    lines += ['    $finish;', '  end', 'endmodule']
    clauses = '16.15 16.12 16.12.7 16.14.1 27.5 4.4.2'
    if form == 'loop':
        clauses += ' 27.4'
    if timing == 'at_end':
        clauses += ' 10.4.2'
    return Case(top, 'Default disable conditions retain lexical binding across generate scopes',
                clauses,
                'Two generated sites each contain a nested assertion scope. A module default '
                'is inherited or replaced in the outer generate scope. Inverse same-name '
                'signals in the inner scope must not rebind that default. An explicit '
                'disable condition or explicit zero takes precedence. Declarations before '
                'and after the assertions have the same effect. Independent site resets '
                'distinguish the two instances. Seven phases pulse root, local and explicit '
                'conditions separately and include an unreset passing consequent. Pulses '
                'occur before the first tick, only between ticks, or by NBA at the final '
                'tick. Disabled attempts have neither action; vacuous and nonvacuous '
                'successes are counted. Explicit-zero guards and a module-scope assertion '
                'provide separate controls. Reports occur after actions and reset cleanup. '
                'No X/Z, multiple clocks, nested module declarations, interface/program, '
                'property-level explicit disable or assertion control is used.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
