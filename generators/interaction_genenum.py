"""Per-generated-scope enum tables, navigation, signedness and retained state."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_genenum'
VERSION = 1
CHAPTER = 6
MODEL = Model(
    'generated_enum_navigation',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('sign', ('unsigned', 'signed')), ('form', ('if', 'case')),
     ('encoding', ('dense', 'high', 'descending')), ('count', ('2', '3')),
     ('method', ('next', 'prev')), ('step', ('zero', 'one', 'cycle', 'beyond'))),
    lambda row: row[0] != '1' or row[4] == '2',
    groups=(('width', 'sign', 'encoding'), ('width', 'form', 'count'),
            ('encoding', 'method', 'step'), ('count', 'method', 'step'),
            ('form', 'encoding', 'count')),
    anchors=(('1', 'signed', 'if', 'descending', '2', 'next', 'one'),
             ('129', 'signed', 'case', 'high', '3', 'prev', 'beyond'),
             ('33', 'signed', 'if', 'high', '3', 'next', 'cycle'),
             ('65', 'unsigned', 'case', 'descending', '2', 'next', 'zero'),
             ('32', 'unsigned', 'if', 'dense', '3', 'prev', 'one'),
             ('64', 'signed', 'case', 'descending', '3', 'next', 'beyond')),
    constraints=('幅一の生成要素には三つの異なる列挙値を表せないためcountは二に限る。'
                 '他の全行は合法で、未対応による除外なし。'
                 '二つのインスタンスは反対の分岐を選び、それぞれ二つの生成要素を持つ。'
                 '局所幅は基底幅にgenvarと分岐値を加え、分岐一では列挙値の宣言順を一つ回す。'
                 '各ケースで先頭と末尾の二初期状態を実行し、他要素の操作後とアイドル時にも値を読む。'
                 'X/Zの列挙子、非メンバ値、型不一致の代入、負の移動数、config、defparamは対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_genenum_' + '_'.join(row)


def step_value(row: Row) -> int:
    return {'zero': 0, 'one': 1, 'cycle': int(row[4]), 'beyond': int(row[4]) + 2}[row[6]]


def table(row: Row, instance: int, lane: int) -> tuple[int, int, list[int]]:
    kind = (instance + lane) % 2
    width = int(row[0]) + lane + kind
    n, mask = int(row[4]), (1 << width) - 1
    if row[3] == 'dense': values = list(range(n))
    elif row[3] == 'high': values = [0, 1 << (width - 1), mask][:n]
    else: values = [mask - i for i in range(n)]
    return width, kind, values[kind:] + values[:kind]


def reference(row: Row) -> str:
    lines = []; states = {}
    n, step = int(row[4]), step_value(row)
    direction = 1 if row[5] == 'next' else -1
    for phase in (0, 1):
        for instance in (0, 1):
            for lane in (0, 1):
                w, kind, values = table(row, instance, lane)
                bits = lambda index: format(values[index], f'0{w}b')
                at = 0 if phase == 0 else n - 1
                held = at
                lines.append(f'h phase={phase} id={instance} lane={lane} kind={kind} '
                             f'bits={w} num={n} first={bits(0)} last={bits(n-1)}')
                for k in range(n + 1):
                    number = values[at]
                    if row[1] == 'signed' and number & (1 << (w-1)): number -= 1 << w
                    lines.append(f'v phase={phase} id={instance} lane={lane} k={k} '
                                 f'value={bits(at)} dec={number} name=E{at} '
                                 f'next={bits((at+step)%n)} prev={bits((at-step)%n)}')
                    at = (at + direction * step) % n
                states[instance, lane] = (bits(at), f'E{at}', bits(held), f'E{held}')
        for instance in (0, 1):
            for lane in (0, 1):
                value, name, held, held_name = states[instance, lane]
                lines.append(f'p phase={phase} id={instance} lane={lane} '
                             f'value={value} name={name} held={held} held_name={held_name}')
    for instance in (0, 1):
        for lane in (0, 1):
            value, name, held, held_name = states[instance, lane]
            lines.append(f'p phase=2 id={instance} lane={lane} '
                         f'value={value} name={name} held={held} held_name={held_name}')
    return '\n'.join(lines) + '\n'


def branch(row: Row, kind: int) -> list[str]:
    n = int(row[4])
    if row[3] == 'dense': values = [str(i) for i in range(n)]
    elif row[3] == 'high': values = ['0', "base_t'(1) << (WIDTH-1)", "'1"][:n]
    else: values = [f"base_t'('1) - {i}" for i in range(n)]
    values = values[kind:] + values[:kind]
    lines = [f'      localparam int KIND = {kind};',
             '      localparam int WIDTH = BASE + g + KIND;',
             f'      localparam int COUNT = {n};', f'      localparam int STEP = {step_value(row)};',
             f'      typedef logic {row[1]} [WIDTH-1:0] base_t;', '      typedef enum base_t {']
    lines += [f"        E{i} = base_t'({v})" + (',' if i < n-1 else '') for i, v in enumerate(values)]
    lines += ['      } enum_t;', '      enum_t value, held;',
              '      task automatic sample(input int phase);',
              '        value = (phase == 0) ? value.first() : value.last();', '        held = value;',
              '        $display("h phase=%0d id=%0d lane=%0d kind=%0d bits=%0d num=%0d first=%b last=%b",',
              '                 phase, ID, g, KIND, $bits(enum_t), value.num(),',
              '                 value.first(), value.last());',
              '        for (int k = 0; k <= COUNT; k++) begin',
              '          $display("v phase=%0d id=%0d lane=%0d k=%0d value=%b dec=%0d name=%s next=%b prev=%b",',
              '                   phase, ID, g, k, value, value, value.name(),',
              '                   value.next(STEP), value.prev(STEP));',
              f'          value = value.{row[5]}(STEP);', '        end', '      endtask',
              '      task automatic peek(input int phase);',
              '        $display("p phase=%0d id=%0d lane=%0d value=%b name=%s held=%b held_name=%s",',
              '                 phase, ID, g, value, value.name(), held, held.name());',
              '      endtask']
    return lines


def source(row: Row) -> str:
    lines = ['`timescale 1ns/1ns',
             f'module enum_worker #(parameter int SELECT = 0, ID = 0, BASE = {row[0]});',
             '  for (genvar g = 0; g < 2; g++) begin : lanes']
    if row[2] == 'if':
        lines += ['    if ((SELECT + g) % 2 == 0) begin : choice', *branch(row, 0),
                  '    end else begin : choice', *branch(row, 1), '    end']
    else:
        lines += ['    case ((SELECT + g) % 2)', '      0: begin : choice', *branch(row, 0),
                  '      end', '      default: begin : choice', *branch(row, 1), '      end', '    endcase']
    lines += ['  end', 'endmodule', f'module {case_name(row)};',
              '  enum_worker #(.SELECT(0), .ID(0)) a();', '  enum_worker #(.SELECT(1), .ID(1)) b();',
              '  initial begin']
    for phase in (0, 1):
        for operation in ('sample', 'peek'):
            for owner in ('a', 'b'):
                for lane in (0, 1): lines.append(f'    {owner}.lanes[{lane}].choice.{operation}({phase});')
        lines.append('    #1;')
    for owner in ('a', 'b'):
        for lane in (0, 1): lines.append(f'    {owner}.lanes[{lane}].choice.peek(2);')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(
        case_name(row), 'Generated scopes keep distinct enum tables, navigation and retained values',
        '6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5',
        'Two workers with opposite if/case selections each generate two enum scopes. '
        'Their implicit genvar constant and selected branch determine integral base width '
        'and declaration-order value rotation. Compare enum num/first/last, next/prev '
        'counts, binary and signed decimal values and names. Walk in the selected '
        'direction from both first and last, retaining an independent held copy. '
        'Read every scope again after all other walks and at idle. Count-zero, full-cycle '
        'and beyond-cycle calls remain distinct stimuli even when their modulo result '
        'matches. All values are known members; no illegal casts, nonmember values, '
        'negative counts, X/Z, config or defparam is used.', source(row), reference(row),
        extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
               'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
