"""Loops take their bounds from the array query functions of a fixed, packed, dynamic or queue dimension."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_arrayloop'
VERSION = 1
CHAPTER = 20

# The range of each fixed dimension as written, left first.
FIXED = {'asc': (0, 3), 'desc': (3, 0), 'offset': (5, 2), 'neg': (-2, 1), 'packed': (1, 4)}
DYNAMIC = ('dynamic', 'queue', 'empty')
BYTES = ("8'h11", "8'h22", "8'h33", "8'h44")


def legal(row: Row) -> bool:
    shape, form, loop, bounds = row
    # A type name and a dimension after the first are fixed-size only (20.7, 20.7.1).
    if form in ('type', 'dim') and shape in DYNAMIC: return False
    if loop == 'foreach' and bounds != 'leftright': return False
    # A do-while from $left to $right never meets the end of an empty array.
    return not (loop == 'do' and shape == 'empty' and bounds == 'leftright')


MODEL = Model(
    'array_query_loop',
    (('shape', (*FIXED, *DYNAMIC)), ('form', ('var', 'type', 'dim', 'elem')),
     ('loop', ('for', 'while', 'do', 'repeat', 'foreach')), ('bounds', ('leftright', 'lowhigh', 'highlow', 'size'))),
    legal,
    anchors=(('empty', 'elem', 'do', 'highlow'), ('neg', 'dim', 'for', 'leftright'),
             ('packed', 'type', 'while', 'size'), ('queue', 'elem', 'foreach', 'leftright'),
             ('offset', 'var', 'repeat', 'lowhigh'), ('dynamic', 'var', 'do', 'leftright'),
             ('desc', 'elem', 'for', 'highlow')),
    constraints=('要素は左の添字から8\'h11・8\'h22・8\'h33・8\'h44で、空の動的配列は要素を持たない。'
                 '$incrementは固定の次元で左が右以上なら1、そうでなければ-1、動的配列とキューでは-1を返す。'
                 '$lowと$highは$incrementで$leftと$rightから決まり、空の動的配列では$rightと$highが-1になる。'
                 '型の名前と2番目の次元の問い合わせは固定の大きさの次元だけに使う。'
                 'foreachは左の添字から右へ進む。do-whileは空の配列でも一度実行して、ない要素のxを読む。'
                 'do-whileで$leftから$rightへ進む空の配列は終わらないので除く。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_arrayloop_' + '_'.join(row)


def query(row: Row) -> dict[str, int]:
    shape, form, _, _ = row
    if shape in FIXED:
        left, right = FIXED[shape]
        increment = 1 if left >= right else -1
    else:
        left, right, increment = 0, -1 if shape == 'empty' else 3, -1
    low, high = (right, left) if increment == 1 else (left, right)
    unpacked = {'var': 1, 'type': 1, 'dim': 2, 'elem': 1}[form] if shape != 'packed' else 0
    return {'left': left, 'right': right, 'inc': increment, 'low': low, 'high': high,
            'size': high - low + 1, 'dims': 3 if form == 'dim' else 2, 'unpacked': unpacked}


def visits(row: Row) -> list[int]:
    _, _, loop, bounds = row
    q = query(row)
    forward = list(range(q['left'], q['right'] - q['inc'], -q['inc']))
    order = {'leftright': forward, 'size': forward, 'lowhigh': sorted(forward), 'highlow': sorted(forward)[::-1]}
    seen = order[bounds]
    if loop == 'do' and not seen:
        # The body runs once at the first index, which the empty array does not have.
        return [{'lowhigh': q['low'], 'highlow': q['high'], 'size': q['left']}[bounds]]
    return seen


def reference(row: Row) -> str:
    q = query(row)
    forward = list(range(q['left'], q['right'] - q['inc'], -q['inc']))
    value = {index: BYTES[place][-2:] for place, index in enumerate(forward)}
    shown = ''.join(f' {index}:{value.get(index, "xx")}' for index in visits(row))
    return (f'left={q["left"]} right={q["right"]} inc={q["inc"]}\nlow={q["low"]} high={q["high"]} size={q["size"]}\n'
            f'dims={q["dims"]} unpacked={q["unpacked"]}\nvisit{shown}\n')


def declaration(row: Row) -> list[str]:
    shape, form, _, _ = row
    if shape in FIXED:
        left, right = FIXED[shape]
        packed = shape == 'packed'
        span = f'[{left}:{right}]'
    else:
        packed, span = False, '[$]' if shape == 'queue' else '[]'
    if form == 'var': return [f'logic {span}[7:0] a;' if packed else f'logic [7:0] a {span};']
    if form == 'type':
        return [f'typedef logic {span}[7:0] arr_t;' if packed else f'typedef logic [7:0] arr_t {span};', 'arr_t a;']
    return [f'logic [1:1]{span}[7:0] w;' if packed else f'logic [7:0] w [1:1]{span};']


def fill(row: Row) -> list[str]:
    shape, form, _, _ = row
    name = 'a' if form in ('var', 'type') else 'w[1]'
    if shape == 'empty': return []
    if shape == 'queue': return [f'{name}.push_back({byte});' for byte in BYTES]
    if shape == 'dynamic': return [f'{name} = new[4];'] + [f'{name}[{i}] = {byte};' for i, byte in enumerate(BYTES)]
    left, right = FIXED[shape]
    step = 1 if right >= left else -1
    return [f'{name}[{left + step * i}] = {byte};' for i, byte in enumerate(BYTES)]


def loop_lines(row: Row) -> list[str]:
    _, form, loop, bounds = row
    target = {'var': 'a', 'type': 'arr_t', 'dim': 'w, 2', 'elem': 'w[1]'}[form]
    element = 'a' if form in ('var', 'type') else 'w[1]'
    show = f'$write(" %0d:%h", i, {element}[i]);'
    if loop == 'foreach':
        if form in ('var', 'type'): return ['foreach (a[j]) $write(" %0d:%h", j, a[j]);']
        return ['foreach (w[m, j]) $write(" %0d:%h", j, w[m][j]);']

    def q(name): return f'${name}({target})'
    start, condition, step = {
        'leftright': (f'i = {q("left")}', f'i != {q("right")} - {q("increment")}', f'i -= {q("increment")}'),
        'lowhigh': (f'i = {q("low")}', f'i <= {q("high")}', 'i++'),
        'highlow': (f'i = {q("high")}', f'i >= {q("low")}', 'i--'),
        'size': ('k = 0', f'k < {q("size")}', 'k++')}[bounds]
    body = ([f'i = {q("left")} - k * {q("increment")};'] if bounds == 'size' else []) + [show]
    if loop == 'for': return [f'for ({start}; {condition}; {step}) begin', *['  ' + b for b in body], 'end']
    if loop == 'while': return [f'{start};', f'while ({condition}) begin', *['  ' + b for b in body], f'  {step};', 'end']
    if loop == 'do': return [f'{start};', 'do begin', *['  ' + b for b in body], f'  {step};', f'end while ({condition});']
    return [f'{start};', f'repeat ({q("size")}) begin', *['  ' + b for b in body], f'  {step};', 'end']


def source(row: Row) -> str:
    _, form, _, _ = row
    target = {'var': 'a', 'type': 'arr_t', 'dim': 'w, 2', 'elem': 'w[1]'}[form]
    whole = {'var': 'a', 'type': 'arr_t', 'dim': 'w', 'elem': 'w[1]'}[form]
    body = [*fill(row),
            f'$display("left=%0d right=%0d inc=%0d", $left({target}), $right({target}), $increment({target}));',
            f'$display("low=%0d high=%0d size=%0d", $low({target}), $high({target}), $size({target}));',
            f'$display("dims=%0d unpacked=%0d", $dimensions({whole}), $unpacked_dimensions({whole}));',
            '$write("visit");', *loop_lines(row), '$display;']
    return '\n'.join([f'module {case_name(row)};', *['  ' + line for line in declaration(row)], '  int i, k;',
                      '  initial begin', *['    ' + line for line in body], '  end', 'endmodule'])


SHAPE_CLAUSE = {'asc': '7.4.2', 'desc': '7.4.2', 'offset': '7.4.2', 'neg': '7.4.2', 'packed': '7.4.1',
                'dynamic': '7.5 7.5.1', 'queue': '7.10 7.10.2.7', 'empty': '7.5 7.4.5'}
FORM_CLAUSE = {'var': '', 'type': '6.18', 'dim': '20.7.1 7.4.5', 'elem': '20.7.1 7.4.5'}
LOOP_CLAUSE = {'for': '12.7.1', 'while': '12.7.4', 'do': '12.7.5', 'repeat': '12.7.2', 'foreach': '12.7.3'}


def make_case(row: Row) -> Case:
    shape, form, loop, _ = row
    clauses = f'20.7 {FORM_CLAUSE[form]} {SHAPE_CLAUSE[shape]} {LOOP_CLAUSE[loop]}'.split()
    return Case(case_name(row), 'Loops take their bounds from the array query functions',
                ' '.join(dict.fromkeys(clauses)),
                'A loop walks an ascending, descending, offset or negative unpacked dimension, a packed '
                'dimension, a dynamic array, a queue or an empty dynamic array, asking $left, $right, $low, '
                '$high, $increment and $size of the variable, of its type, of its second dimension or of an '
                'element select. A fixed dimension has $increment 1 when its left bound is not less than its '
                'right bound, a dynamic dimension -1, and $low and $high follow from it. The loop goes from '
                'left to right, from low to high, from high to low or counts $size, and foreach goes from left '
                'to right. A do-while runs once even on an empty array and reads x there.',
                source(row), reference(row), fourstate='xx' in reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
