"""Open-array shape, element indexing and copyback across repeated DPI calls.

Expectation corrected on 2026-11-12 (model version unchanged, rows and
selection unchanged): svIncrement of a dynamic array or queue dimension is
always -1 (IEEE 1800-2023 20.7, which H.12.2 follows). The rule "1 if left >=
right" holds for a fixed-size dimension only; it had also been applied to a
dynamic array or queue of one element, where left and right are both 0.
"""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_dpi_array'
VERSION = 1
CHAPTER = 35


def legal(row: Row) -> bool:
    actual, direction, _, _, _, calls = row
    # 7.7 forbids dynamic/queue actuals for unsized output formals.
    return not (actual in ('dynamic', 'queue') and direction == 'output') and not (
        actual in ('ascending', 'descending') and calls == 'resize')


MODEL = Model(
    'dpi_openarray_shape',
    (('actual', ('ascending', 'descending', 'dynamic', 'queue')),
     ('direction', ('input', 'output', 'inout')),
     ('length', ('1', '3', '5')),
     ('pattern', ('positive', 'mixed')),
     ('walk', ('ascending', 'descending')),
     ('calls', ('stable', 'resize'))),
    legal,
    groups=(('actual', 'direction', 'length'), ('actual', 'calls', 'walk'),
            ('direction', 'pattern', 'walk'), ('actual', 'length', 'calls')),
    anchors=(('ascending', 'output', '1', 'mixed', 'descending', 'stable'),
             ('descending', 'inout', '5', 'mixed', 'ascending', 'stable'),
             ('dynamic', 'inout', '1', 'mixed', 'descending', 'resize'),
             ('queue', 'input', '5', 'positive', 'ascending', 'resize')),
    constraints=('直積288行のうち合法168行。7.7で禁止される動的配列/キューのopen outputを除き、'
                 '固定配列のresizeは水準の意味に合わないため除く。未対応による除外なし。'
                 'int要素の1次元open arrayだけを使い、2回の呼出しで全要素を再設定する。'
                 'resizeは1→3、3→5、5→2とし、Cの各呼出しの範囲と全要素、復帰後の書戻しを照合する。'
                 'outputの初期値は読まない。Cでは要素ポインタを毎回取得し、全体の連続配置を仮定しない。'
                 'X/Z、空配列、多次元、sized formal、ref、Cからの再入、ハンドルの持越しは対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_dpi_array_' + '_'.join(row)


def extent(row: Row, phase: int) -> int:
    n = int(row[2])
    return {1: 3, 3: 5, 5: 2}[n] if phase and row[5] == 'resize' else n


def bounds(actual: str, n: int) -> tuple[int, int]:
    if actual == 'ascending':
        return -2, n - 3
    if actual == 'descending':
        return n + 2, 3
    return 0, n - 1


def before_value(pattern: str, phase: int, ordinal: int) -> int:
    value = 11 + 7 * ordinal + 13 * phase
    return -value if pattern == 'mixed' and (ordinal + phase) % 2 else value


def reference(row: Row) -> str:
    actual, direction, _, pattern, walk, _ = row
    lines = []
    for phase in (0, 1):
        n = extent(row, phase)
        left, right = bounds(actual, n)
        low, high = min(left, right), max(left, right)
        declared = list(range(left, right + (1 if left <= right else -1),
                              1 if left <= right else -1))
        values = {i: before_value(pattern, phase, i - low) for i in declared}
        lines += [f'call phase={phase} size={n}']
        lines += [f'before[{i}]={values[i]}' for i in declared]
        # 20.7: -1 for a dynamic array or queue dimension whatever its size;
        # 1 for a fixed-size dimension whose left bound is not below its right.
        increment = -1 if actual in ('dynamic', 'queue') or left < right else 1
        lines += [f'c phase={phase} dims=1 left={left} right={right} low={low} high={high} '
                  f'inc={increment} size={n}']
        indices = list(range(low, high + 1))
        if walk == 'descending':
            indices.reverse()
        checksum = 0
        for pos, i in enumerate(indices):
            before = 0 if direction == 'output' else values[i]
            after = (-100 * (phase + 1) + 3 * i if direction == 'output' else
                     before + 100 * (phase + 1) + i if direction == 'inout' else before)
            values[i] = after
            lines += [f'c index={i} before={before} after={after}']
            checksum += (pos + 1) * after
        lines += [f'returned={checksum}']
        lines += [f'after[{i}]={values[i]}' for i in declared]
        lines += ['guard=31,-47,83']
    return '\n'.join(lines) + '\n'


def make_case(row: Row) -> Case:
    actual, direction, size, pattern, walk, calls = row
    n = int(size)
    left, right = bounds(actual, n)
    declaration = ('[]' if actual == 'dynamic' else '[$]' if actual == 'queue'
                   else f'[{left}:{right}]')
    lines = [f'module {case_name(row)};',
             f'  import "DPI-C" function int cross_dpi_array_{direction}(',
             f'    {direction} int a[], input int reverse_walk, input int phase);',
             f'  int data{declaration};', '  int guard[0:2];', '  int returned;',
             '  initial begin', '    guard[0] = 31; guard[1] = -47; guard[2] = 83;']
    for phase in (0, 1):
        count = extent(row, phase)
        if phase == 0 or calls == 'resize':
            if actual == 'dynamic':
                lines += [f'    data = new[{count}];']
            elif actual == 'queue':
                lines += ['    data.delete();',
                          f'    repeat ({count}) data.push_back(0);']
        lo = min(bounds(actual, count))
        lines += ['    foreach (data[i]) begin',
                  f'      data[i] = 11 + 7 * (i - ({lo})) + 13 * {phase};']
        if pattern == 'mixed':
            lines += [f'      if (((i - ({lo})) + {phase}) % 2) data[i] = -data[i];']
        lines += ['    end', f'    $display("call phase={phase} size=%0d", $size(data));',
                  '    foreach (data[i]) $display("before[%0d]=%0d", i, data[i]);',
                  f'    returned = cross_dpi_array_{direction}(data, '
                  f'{int(walk == "descending")}, {phase});',
                  '    $display("returned=%0d", returned);',
                  '    foreach (data[i]) $display("after[%0d]=%0d", i, data[i]);',
                  '    $display("guard=%0d,%0d,%0d", guard[0], guard[1], guard[2]);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Open-array DPI calls preserve actual bounds and copy back every legal element',
                '35.5.6.1 35.6.1.1 7.7 7.5 7.10 H.7.6 H.12.2 H.12.4 20.7',
                'One imported open-array function is called twice with signed int elements. '
                'Fixed actuals use offset ascending or descending bounds; dynamic arrays and '
                'queues use zero-based bounds. Between calls a dynamic array or queue keeps '
                'its size, grows or shrinks, and every input element is reset. C queries all '
                'unpacked bounds, size, increment and dimensions, then obtains each element '
                'pointer using its actual SV index in ascending or descending numerical order. '
                'It reports every before/after value and returns an order-sensitive checksum. '
                'Input remains unchanged, output writes without reading its initial value, '
                'and inout transforms known positive or mixed-sign words. SV reports all '
                'elements before and after each call and an untouched independent guard array. '
                'Clause 7.7 forbids dynamic/queue actuals for open output arguments; these are '
                'not legal rows. Fixed-array resize has no meaning in this model. No rows are '
                'excluded for tool limitations. No empty arrays, X/Z, multidimensional arrays, '
                'sized formals, ref arguments, callbacks or retained foreign handles are used.',
                '\n'.join(lines), reference(row),
                extra={'dpi_c': '@../../ch35/cross_dpi_array.c',
                       'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
