"""Generated-scope subroutine defaults, typed results and independent arrays."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_gensub'
VERSION = 1
CHAPTER = 27
MODEL = Model(
    'generated_subroutine_binding',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('sign', ('u', 's')),
     ('form', ('if', 'case')), ('argument', ('default', 'explicit')),
     ('routine', ('function', 'task')), ('order', ('forward', 'reverse')),
     ('value', ('known', 'x', 'z')), ('range', ('up', 'down'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('width', 'sign', 'argument'),
            ('form', 'argument', 'routine'), ('order', 'argument', 'value'),
            ('width', 'form', 'range'), ('argument', 'routine', 'range')),
    anchors=(('1', 'bit', 'u', 'if', 'default', 'function', 'forward', 'known', 'up'),
             ('129', 'logic', 's', 'case', 'default', 'task', 'reverse', 'z', 'down'),
             ('65', 'logic', 'u', 'if', 'explicit', 'function', 'reverse', 'x', 'up'),
             ('33', 'bit', 's', 'case', 'explicit', 'task', 'forward', 'z', 'down'),
             ('32', 'logic', 's', 'if', 'default', 'task', 'reverse', 'known', 'down'),
             ('64', 'logic', 'u', 'case', 'explicit', 'function', 'forward', 'known', 'up')),
    constraints=('全行が合法で、未対応による除外なし。二インスタンスと各二つの生成要素を使う。'
                 'genvarと条件分岐が局所幅・負や非零の添字を含む配列範囲・更新定数を決める。'
                 '既定引数は宣言スコープの現在の配列要素を毎回読み、明示引数は呼出し元の値を渡す。'
                 '全ケースで既知値の相と、既知値またはX/Zの相を実行する。'
                 '各呼出し後に全スコープの配列要素・隣接要素・型付き結果を観測する。'
                 '途中の外部更新と再呼出し、隣接要素だけの更新と再呼出し、最終保持も照合する。'
                 '単一initialで呼び、時間制御・再帰・ref・並行呼出し・動的配列は対象外。'
                 'X/Z入力を使う場合はbit型への変換でもfourstateを指定する。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_gensub_' + '_'.join(row)


def layout(row: Row, slot: int) -> tuple[int, int, int, int, int]:
    instance, lane = divmod(slot, 2)
    kind = (instance + lane) % 2
    width = int(row[0]) + lane + kind
    left = lane + kind + (-2 if row[8] == 'up' else 3)
    right = left + (1 if row[8] == 'up' else -1)
    return width, kind, left, right, 1 + 2 * lane + kind


def address(row: Row, slot: int, guard=False) -> str:
    _, _, left, right, _ = layout(row, slot)
    prefix = ('a' if slot < 2 else 'b') + f'.g[{slot % 2}].slot'
    return f'{prefix}.data[{right if guard else left}]'


def prefix(slot: int) -> str:
    return ('a' if slot < 2 else 'b') + f'.g[{slot % 2}].slot'


def initial(row: Row, phase: int, slot: int) -> tuple[str, str]:
    width = layout(row, slot)[0]
    marker = (('10' if (slot + phase) % 2 == 0 else '01') * width)[:width]
    raw = row[7] * width if phase and row[7] != 'known' else marker
    guard = marker.translate(str.maketrans('01', '10'))
    return raw, guard


def drive_value(row: Row, phase: int) -> str:
    width = int(row[0])
    return row[7] * width if phase and row[7] != 'known' else (('10' if phase == 0 else '01') * width)[:width]


def order(row: Row) -> tuple[int, ...]:
    return tuple(range(4)) if row[6] == 'forward' else tuple(reversed(range(4)))


def xor(data: str, tag: int) -> str:
    mask = format(tag & ((1 << len(data)) - 1), f'0{len(data)}b')
    return ''.join(str(int(a) ^ int(b)) if a in '01' else 'x' for a, b in zip(data, mask))


def reference(row: Row) -> str:
    base, state, sign = int(row[0]), row[1], row[2] == 's'
    lines = []
    for phase in (0, 1):
        data, guards = {}, {}
        returns = {slot: '0' * (base + 4) for slot in range(4)}
        for slot in range(4):
            width = layout(row, slot)[0]
            raw, guard = initial(row, phase, slot)
            data[slot], guards[slot] = assigned(raw, width, state), guard
        drive = drive_value(row, phase)
        def snapshot(tag):
            lines.append(f'h p={phase} step={tag} drive={drive}')
            for slot in range(4):
                width, _, left, right, tag_value = layout(row, slot)
                lines.append(f'v id={slot} left={left} right={right} bits={width} tag={tag_value} '
                             f'data={data[slot]} guard={guards[slot]} ret={returns[slot]}')
        def call(slot):
            width, _, _, _, tag_value = layout(row, slot)
            before = data[slot]
            arg = before if row[4] == 'default' else assigned(drive, width, state)
            data[slot] = assigned(xor(arg, tag_value), width, state)
            returns[slot] = assigned(before, base + 4, 'logic', sign)
        snapshot('init')
        for index, slot in enumerate(order(row)):
            call(slot); snapshot(f'first{index}')
        drive = '0' * (base - 1) + '1'
        data[0] = '1' * layout(row, 0)[0]
        snapshot('refresh')
        for index, slot in enumerate(reversed(order(row))):
            call(slot); snapshot(f'again{index}')
        # This scope is at least two bits wide: a low-bit flip distinguishes
        # both the target and its initially complementary guard in known runs.
        guards[3] = xor(data[3], 1)
        snapshot('guard')
        call(3); snapshot('probe'); snapshot('idle')
    return '\n'.join(lines) + '\n'


def block(row: Row, kind: int) -> list[str]:
    left = 'lane + KIND - 2' if row[8] == 'up' else 'lane + KIND + 3'
    right = 'LEFT + 1' if row[8] == 'up' else 'LEFT - 1'
    signed = ' signed' if row[2] == 's' else ''
    lines = [f'      localparam int KIND = {kind};',
             '      localparam int W = BASE + lane + KIND;',
             f'      localparam int LEFT = {left};', f'      localparam int RIGHT = {right};',
             '      localparam int TAG = 1 + lane + lane + KIND;',
             f'      typedef {row[1]}{signed} [W-1:0] word_t;',
             '      word_t data[LEFT:RIGHT];']
    function = row[5] == 'function'
    lines += ['      function automatic word_t step(input word_t arg = data[LEFT]);' if function else
              '      task automatic step(output word_t previous, input word_t arg = data[LEFT]);',
              '        word_t saved;', '        saved = data[LEFT];',
              "        data[LEFT] = arg ^ word_t'(TAG);",
              '        return saved;' if function else '        previous = saved;',
              '      endfunction' if function else '      endtask']
    return lines


def source(row: Row) -> str:
    base = int(row[0])
    lines = ['module generated_worker #(parameter int BASE = 1, parameter int SEL = 0);',
             '  for (genvar lane = 0; lane < 2; lane++) begin : g']
    if row[3] == 'if':
        lines += ['    if ((SEL + lane) % 2 == 0) begin : slot'] + block(row, 0)
        lines += ['    end else begin : slot'] + block(row, 1) + ['    end']
    else:
        lines += ['    case ((SEL + lane) % 2)', '      0: begin : slot'] + block(row, 0)
        lines += ['      end', '      default: begin : slot'] + block(row, 1)
        lines += ['      end', '    endcase']
    lines += ['  end', 'endmodule', f'module {case_name(row)};',
              f'  generated_worker #(.BASE({base}), .SEL(0)) a();',
              f'  generated_worker #(.BASE({base}), .SEL(1)) b();',
              f'  logic [{base-1}:0] drive;', f'  logic [{base+3}:0] r0, r1, r2, r3;',
              '  initial begin']
    def snapshot(phase, tag):
        lines.append(f'    $display("h p={phase} step={tag} drive=%b", drive);')
        for slot in range(4):
            p, target, guard = prefix(slot), address(row, slot), address(row, slot, True)
            lines.extend([f'    $write("v id={slot} left=%0d right=%0d bits=%0d tag=%0d ",',
                          f'           $left({p}.data), $right({p}.data),',
                          f'           $bits({target}), {p}.TAG);',
                          f'    $display("data=%b guard=%b ret=%b", {target},',
                          f'             {guard}, r{slot});'])
    def call(slot):
        arg = '' if row[4] == 'default' else 'drive'
        lines.append(f'    r{slot} = {prefix(slot)}.step({arg});' if row[5] == 'function' else
                     f'    {prefix(slot)}.step(r{slot}' + (', drive' if arg else '') + ');')
    for phase in (0, 1):
        lines += [f'    drive = {literal(drive_value(row, phase))};']
        for slot in range(4):
            raw, guard = initial(row, phase, slot)
            lines += [f'    {address(row,slot)} = {literal(raw)};',
                      f'    {address(row,slot,True)} = {literal(guard)};', f"    r{slot} = '0;"]
        snapshot(phase, 'init')
        for index, slot in enumerate(order(row)):
            call(slot); snapshot(phase, f'first{index}')
        lines += [f'    drive = {literal("0"*(base-1)+"1")};', f"    {address(row,0)} = '1;"]
        snapshot(phase, 'refresh')
        for index, slot in enumerate(reversed(order(row))):
            call(slot); snapshot(phase, f'again{index}')
        lines += [f"    {address(row,3,True)} = {address(row,3)} ^ 1'b1;"]
        snapshot(phase, 'guard'); call(3); snapshot(phase, 'probe'); snapshot(phase, 'idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row),
                'Generated subroutines bind defaults and typed array state to their own elaborated scope',
                '27.4 27.5 13.5.3 13.5.2 13.3 13.4 7.4.2 11.8.2',
                'Two differently parameterized instances each contain two generated scopes. '
                'Each selected branch declares its own type, indexed array, constants and routine. '
                'Compare current callee-scope default inputs with explicit caller inputs, function '
                'returns with task copy-out, and signed result extension into a wider destination. '
                'After every call, read every target, neighbor and retained result. Change an '
                'actual and one target before reusing the routines; update a neighbor and probe '
                'again. Run known data first and then known/X/Z data. Calls occur in one initial '
                'process; no time controls, concurrency or unspecified argument ordering is used.',
                source(row), reference(row), fourstate=row[7] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
