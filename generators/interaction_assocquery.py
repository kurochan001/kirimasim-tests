"""Separate associative-array index domains from currently allocated entries."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_assocquery'
VERSION = 1
CHAPTER = 20
MODEL = Model(
    'associative_array_queries',
    (('width', ('4', '8', '33')), ('sign', ('unsigned', 'signed')),
     ('keys', ('compact', 'extreme')), ('order', ('ascending', 'descending', 'zigzag')),
     ('delete', ('low', 'middle', 'high')), ('dimension', ('implicit', 'explicit'))),
    lambda row: True,
    groups=(('width', 'sign', 'keys'), ('keys', 'order', 'delete'),
            ('sign', 'delete', 'dimension'), ('width', 'keys', 'dimension')),
    anchors=(('4', 'unsigned', 'compact', 'ascending', 'low', 'implicit'),
             ('33', 'unsigned', 'extreme', 'descending', 'high', 'explicit'),
             ('8', 'signed', 'extreme', 'zigzag', 'middle', 'implicit'),
             ('33', 'signed', 'compact', 'descending', 'low', 'explicit')),
    constraints=('全216行が合法。既知の整数型添字を使い、3個の異なるキーを挿入する。'
                 '型の範囲と割当て済みの範囲、上書きと新規割当て、単独削除と全削除を区別する。'
                 '問い合わせの戻り値は32ビット符号付きintegerへ変換する。'
                 '空配列のlow/highとfirst/lastの出力引数は読まない。'
                 'X/Zの添字、文字列/ワイルドカード添字、多次元配列、並行更新は対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_assocquery_' + '_'.join(row)


def keys(row: Row) -> tuple[list[int], int]:
    width, sign, layout, *_ = row
    w = int(width)
    if layout == 'compact':
        return ([-3, 0, 2], 1) if sign == 'signed' else ([1, 3, 6], 0)
    return ([-(1 << (w-1)), -1, (1 << (w-1))-1], 0) if sign == 'signed' else (
        [0, 1 << (w-1), (1 << w)-1], 1)


def integer(value: int) -> int:
    value &= (1 << 32)-1
    return value-(1 << 32) if value & (1 << 31) else value


def reference(row: Row) -> str:
    width, sign, _, order, deletion, _ = row
    indices, missing = keys(row)
    right = integer((1 << (int(width)-(sign == 'signed')))-1)
    contents = {}
    lines = ['dimensions=2 unpacked=1']

    def report(label):
        ordered = sorted(contents)
        n = len(ordered)
        lines.append(f'{label} left=0 right={right} increment=-1 '
                     f'size={n} num={n} method_size={n}')
        if n:
            lo, hi = ordered[0], ordered[-1]
            lines.append(f'low={integer(lo)} high={integer(hi)} '
                         f'first_ok=1 first={lo} last_ok=1 last={hi}')
        else:
            lines.append('bounds=empty first_ok=0 last_ok=0')
        lines.extend(f'entry key={key} value={contents[key]}' for key in ordered)

    report('empty')
    permutation = {'ascending': (0, 1, 2), 'descending': (2, 1, 0),
                   'zigzag': (1, 2, 0)}[order]
    for step, i in enumerate(permutation, 1):
        contents[indices[i]] = 11*(i+1)
        report(f'insert{step}')
    contents[indices[1]] = 29
    report('overwrite')
    target = indices[{'low': 0, 'middle': 1, 'high': 2}[deletion]]
    del contents[target]
    report('delete')
    contents.pop(missing, None)
    report('delete_missing')
    contents[target] = 47
    report('reinsert')
    contents.clear()
    report('clear')
    contents[missing] = 91
    report('reuse')
    return '\n'.join(lines)+'\n'


def make_case(row: Row) -> Case:
    width, sign, _, order, deletion, dimension = row
    indices, missing = keys(row)
    literal = lambda value: "key_t'(" + ('-' if value < 0 else '') + f"64'sd{abs(value)})"
    argument = 'a, 1' if dimension == 'explicit' else 'a'
    query = lambda name: f'${name}({argument})'
    lines = [f'module {case_name(row)};',
             f'  typedef bit {sign} [{int(width)-1}:0] key_t;', '  int a[key_t];',
             '  task automatic show(input string label);', '    key_t first_key, last_key;',
             '    integer qleft, qright, qinc, qsize, qlow, qhigh;', '    int first_ok, last_ok;',
             f'    qleft = {query("left")}; qright = {query("right")};',
             f'    qinc = {query("increment")}; qsize = {query("size")};',
             '    first_ok = a.first(first_key); last_ok = a.last(last_key);',
             '    $display("%s left=%0d right=%0d increment=%0d size=%0d num=%0d method_size=%0d",',
             '             label, qleft, qright, qinc, qsize, a.num(), a.size());',
             '    if (a.num() != 0) begin',
             f'      qlow = {query("low")}; qhigh = {query("high")};',
             '      $display("low=%0d high=%0d first_ok=%0d first=%0d last_ok=%0d last=%0d",',
             '               qlow, qhigh, first_ok, first_key, last_ok, last_key);',
             '    end else',
             '      $display("bounds=empty first_ok=%0d last_ok=%0d", first_ok, last_ok);',
             '    foreach (a[k]) $display("entry key=%0d value=%0d", k, a[k]);',
             '  endtask', '  initial begin',
             '    $display("dimensions=%0d unpacked=%0d", $dimensions(a), $unpacked_dimensions(a));',
             '    show("empty");']
    permutation = {'ascending': (0, 1, 2), 'descending': (2, 1, 0),
                   'zigzag': (1, 2, 0)}[order]
    for step, i in enumerate(permutation, 1):
        lines += [f'    a[{literal(indices[i])}] = {11*(i+1)}; show("insert{step}");']
    target = indices[{'low': 0, 'middle': 1, 'high': 2}[deletion]]
    lines += [f'    a[{literal(indices[1])}] = 29; show("overwrite");',
              f'    a.delete({literal(target)}); show("delete");',
              f'    a.delete({literal(missing)}); show("delete_missing");',
              f'    a[{literal(target)}] = 47; show("reinsert");',
              '    a.delete(); show("clear");',
              f'    a[{literal(missing)}] = 91; show("reuse");',
              '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Associative-array queries separate the index type from live allocation across updates',
                '20.7 7.8 7.8.4 7.8.7 7.9.1 7.9.2 7.9.4 7.9.5 12.7.3',
                'Integral keys are known and distinct. Ten snapshots cover empty state, three '
                'insertions, overwrite, deleting one key, deleting a missing key, reinsertion, '
                'clearing and reuse. Left/right/increment describe the index domain; '
                'low/high and size describe current allocation. Query results have the '
                'standard integer return type, including 32-bit conversion of wide keys. '
                'First/last retain full key width and signedness, and foreach lists every '
                'allocated key/value in index order. Size is cross-checked against num and '
                'size methods. The default dimension and explicit dimension one are separate '
                'paths. No low/high or first/last output argument is read for an empty '
                'array. X/Z keys, nonintegral or wildcard keys, multidimensional arrays '
                'and concurrent updates are outside scope. Fixed Icarus Verilog 13.0 rejects '
                'the typed associative declaration. Fixed Verilator 5.052 gives different '
                'right/increment results already in the empty snapshot. Neither fixed '
                'oracle is registered; the standard-derived output is retained.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
