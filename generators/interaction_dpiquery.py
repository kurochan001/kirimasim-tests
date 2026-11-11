"""SV and DPI-C shape queries on the same actual, including per-call ranges.

Model version 2: a row is legal only when no other value of "bounds" declares
the same ranges. A one-element range has no direction, and a normalized packed
range is always [width-1:0]. So with one-element dimensions and a normalized
packed range only "down" is legal; with one-element dimensions and an offset
packed range "mixed" equals "up" or "down"; and with one unpacked dimension
and a normalized packed range "mixed" equals "up". Version 1 took all 1,152
rows as legal and selected one such pair of equal tests.
"""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_dpiquery'
VERSION = 2
CHAPTER = 20


def legal(row: Row) -> bool:
    """False for a row whose declared ranges another value of bounds also gives."""
    rank, bounds, _, extent, _, _, packed, _, _ = row
    if extent == 'one':
        # A one-element range [n:n] is the same for every direction; only an
        # offset packed range still shows one.
        return bounds == 'down' if packed == 'normal' else bounds != 'mixed'
    # "mixed" alternates from an ascending first dimension, so with a single
    # unpacked dimension it differs from "up" only in the packed range.
    return not (rank == '1' and packed == 'normal' and bounds == 'mixed')


MODEL = Model(
    'sv_dpi_array_queries',
    (('rank', ('1', '2', '3')), ('bounds', ('up', 'down', 'mixed')),
     ('origin', ('neg', 'pos')), ('extent', ('one', 'varied')),
     ('width', ('4', '33')), ('formal', ('sized', 'open')),
     ('packed', ('normal', 'offset')),
     ('calls', ('same', 'switch')), ('query', ('literal', 'variable'))),
    legal,
    groups=(('rank', 'bounds', 'extent'), ('width', 'formal', 'calls'),
            ('rank', 'formal', 'query'), ('origin', 'bounds', 'calls'),
            ('formal', 'packed', 'query'), ('width', 'packed', 'calls')),
    anchors=(('1', 'up', 'neg', 'varied', '33', 'sized', 'normal', 'switch', 'literal'),
             ('3', 'mixed', 'pos', 'varied', '4', 'sized', 'normal', 'switch', 'variable'),
             ('2', 'down', 'neg', 'one', '33', 'sized', 'normal', 'same', 'literal'),
             ('3', 'down', 'neg', 'varied', '33', 'open', 'offset', 'switch', 'variable'),
             ('1', 'down', 'pos', 'one', '4', 'open', 'normal', 'same', 'literal'),
             ('2', 'up', 'pos', 'varied', '4', 'open', 'offset', 'switch', 'variable'),
             ('3', 'mixed', 'neg', 'varied', '33', 'sized', 'offset', 'same', 'literal')),
    version=2,
    constraints=('1152行のうち832行が合法。boundsの値を変えても宣言する範囲が同じになる行は一つに統一する。'
                 '全次元が1要素でpackedが正規化済みならdownだけ、全次元が1要素でpackedがオフセット付きならupとdownだけ、'
                 '1次元でpackedが正規化済みならupとdownだけが合法。固定配列の1/2/3次元とbitのpacked次元を使い、'
                 '同じ実引数をSVの配列問い合わせとDPI-Cの問い合わせで観測する。'
                 'packed実引数は正規化済み範囲とオフセット付き範囲を区別する。'
                 'Cの次元0は正規化したpacked範囲で、正の次元は実引数のunpacked範囲を保持する。'
                 'switchでは別の実引数へ切り替えて範囲を変更し、open packedだけは幅も4と33の間で変える。'
                 'sized packedは幅を保持する。singletonのincrementは方向にかかわらず1。'
                 '動的配列、キュー、空配列、X/Z、要素の値・書戻し、sized unpacked、'
                 '範囲外の次元、Cからの再入、ハンドルの持越しは対象外。未対応による除外なし。',),
)
METRICS = ('left', 'right', 'low', 'high', 'increment', 'size')


def case_name(row: Row) -> str:
    return 'test_gen_cross_dpiquery_' + '_'.join(row)


def shape(row: Row, alternate: bool) -> tuple[tuple[int, int], ...]:
    rank, mode, origin, extent, width, formal, packed, _, _ = row
    bounds = []
    for dim in range(int(rank)+1):
        if dim == int(rank):
            n = (37-int(width)) if alternate and formal == 'open' else int(width)
            low = 4
        else:
            n = 1 if extent == 'one' else dim+2+int(alternate)
            low = (-7-3*dim if origin == 'neg' else 3+4*dim) * (-1 if alternate else 1)
        ascending = mode == 'up' or mode == 'mixed' and dim % 2 == 0
        if alternate:
            ascending = not ascending
        if dim == int(rank) and packed == 'normal':
            low, ascending = 0, False
        bounds.append((low, low+n-1) if ascending else (low+n-1, low))
    return tuple(bounds)


def metrics(bounds: tuple[int, int]) -> tuple[int, ...]:
    left, right = bounds
    return left, right, min(left, right), max(left, right), (1 if left >= right else -1), abs(left-right)+1


def c_reference(bounds: tuple[tuple[int, int], ...], phase: int) -> str:
    rank = len(bounds)-1
    width = abs(bounds[-1][0]-bounds[-1][1])+1
    normalized = ((width-1, 0), *bounds[:-1])
    lines = [f'c phase={phase} dims={rank}']
    checksum = 0
    for dim, bound in enumerate(normalized):
        values = metrics(bound)
        lines.append(f'c dim={dim} '+ ' '.join(f'{key}={value}' for key,value in zip(METRICS,values)))
        checksum += (dim+1)*sum(w*v for w,v in zip((7,11,13,17,19,23),values))
    return '\n'.join(lines)+f'\nreturned={checksum}\n'


def reference(row: Row) -> str:
    lines = []
    rank = int(row[0])
    for phase in (0, 1):
        bounds = shape(row, phase == 1 and row[7] == 'switch')
        lines.append(f'sv phase={phase} dims={rank+1} unpacked={rank}')
        for dim, bound in enumerate(bounds, 1):
            lines.append(f'sv dim={dim} '+ ' '.join(
                f'{key}={value}' for key,value in zip(METRICS,metrics(bound))))
        lines.append(c_reference(bounds,phase).rstrip())
    return '\n'.join(lines)+'\n'


def make_case(row: Row) -> Case:
    rank, _, _, _, width, formal, _, calls, query = row
    packed = '[]' if formal == 'open' else f'[{int(width)-1}:0]'
    lines = [f'module {case_name(row)};',
             '  import "DPI-C" function int cross_dpiquery(',
             f'    input bit {packed} a'+ '[]'*int(rank)+', input int phase);']
    for alternate, name in ((False,'data_a'), (True,'data_b')):
        bounds = shape(row,alternate)
        p, unpacked = bounds[-1], bounds[:-1]
        lines.append(f'  bit [{p[0]}:{p[1]}] {name}'+
                     ''.join(f'[{l}:{r}]' for l,r in unpacked)+';')
    lines += ['  int returned;', '  initial begin']
    for phase in (0, 1):
        data = 'data_b' if phase and calls == 'switch' else 'data_a'
        lines += [f'    $display("sv phase={phase} dims=%0d unpacked=%0d",',
                  f'             $dimensions({data}), $unpacked_dimensions({data}));']
        dims = [str(d) for d in range(1,int(rank)+2)] if query == 'literal' else ['d']
        if query == 'variable':
            lines += [f'    for (int d = 1; d <= $dimensions({data}); d++) begin']
        for dim in dims:
            lines += ['    $display("sv dim=%0d left=%0d right=%0d low=%0d high=%0d increment=%0d size=%0d",',
                      f'             {dim}, $left({data}, {dim}), $right({data}, {dim}),',
                      f'             $low({data}, {dim}), $high({data}, {dim}),',
                      f'             $increment({data}, {dim}), $size({data}, {dim}));']
        if query == 'variable':
            lines += ['    end']
        lines += [f'    returned = cross_dpiquery({data}, {phase});',
                  '    $display("returned=%0d", returned);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'SV and DPI-C array queries agree after dimension mapping and refresh each call',
                '20.7 35.5.6.1 35.6.1.1 H.7.5 H.7.6 H.12.1 H.12.2',
                'SV queries every actual packed/unpacked dimension with literal or variable '
                'dimension arguments. C queries the same actual through an open-array '
                'handle, including normalized packed dimension zero. SV dimensions count '
                'packed and unpacked dimensions, whereas svDimensions counts unpacked '
                'dimensions. One to three fixed unpacked dimensions use offset ascending, '
                'descending or mixed ranges, either singleton or distinct lengths. The '
                'same import receives the same actual twice or a second actual with changed '
                'unpacked bounds. Only open packed formals also change packed width; sized '
                'packed formals keep the declared width. All six query results and a C '
                'checksum are compared with standard-derived expectations. Bit elements '
                'have known default values; no element access or copyback is claimed. '
                'No dynamic, queue or empty actuals, invalid dimension numbers, X/Z, '
                'callbacks, sized unpacked formals or retained C handles are used.',
                '\n'.join(lines), reference(row),
                extra={'dpi_c':'@../../ch35/cross_dpiquery.c',
                       'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
