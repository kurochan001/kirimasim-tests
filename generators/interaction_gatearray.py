"""Arrays of gate instances map terminal bits by position and keep per-bit delays."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_gatearray'
VERSION = 1
CHAPTER = 28
COUNT = 4


def legal(row: Row) -> bool:
    gate, _, _, _, control, delay, _ = row
    if (gate == 'not') != (control == 'none'): return False
    if delay == 'three' and gate not in ('bufif1', 'nmos'): return False
    return True


MODEL = Model(
    'gate_array_connection',
    (('gate', ('and', 'xnor', 'not', 'bufif1', 'nmos')),
     ('range', ('down', 'up', 'offset')),
     ('output', ('whole_down', 'whole_up', 'part', 'concat')),
     ('input', ('whole_down', 'whole_up', 'concat', 'scalar')),
     ('control', ('scalar', 'vector', 'none')),
     ('delay', ('none', 'one', 'two', 'three')),
     ('value', ('known', 'x', 'z'))),
    legal,
    groups=(('range', 'output', 'input'), ('gate', 'delay', 'value'), ('gate', 'control', 'input')),
    anchors=(('and', 'down', 'whole_down', 'whole_down', 'scalar', 'none', 'known'),
             ('bufif1', 'up', 'whole_up', 'concat', 'vector', 'three', 'x'),
             ('nmos', 'offset', 'part', 'scalar', 'vector', 'three', 'z'),
             ('not', 'up', 'concat', 'whole_up', 'none', 'two', 'x'),
             ('xnor', 'offset', 'concat', 'concat', 'vector', 'one', 'z'),
             ('and', 'up', 'part', 'scalar', 'vector', 'two', 'known')),
    constraints=('notは第二入力を持たない。三つの遅延はbufif1とnmosだけに許される。シミュレータの未対応による除外はしない。'
                 '端子の式は昇順・降順のベクタ、部分選択、連結、スカラで、幅が同じなら全インスタンスへ共有し、'
                 '異なれば配列範囲の右端のインスタンスが式のLSBを受ける。'
                 '入力は既知値から行のX/Zを含む値へ変え、再び既知値へ戻す。'
                 '変化の間隔は遅延より十分長く、出力の最後の値と遅延を規格の表から決める。'
                 '読出しは遅延の時刻と重ならない半時刻で行い、全ビットを観測する。'
                 '最初の遅延が終わる前の出力は規格が定めないので、第一段階は全出力が落ち着いてから読む。'
                 '遅延より短いパルスは第28章に規則がないので使わない。%vの強度はstrengthモデルに任せる。',),
)

RANGE = {'down': (3, 0), 'up': (0, 3), 'offset': (6, 9)}
DELAYS = {'none': (0, 0, 0), 'one': (2, 2, 2), 'two': (1, 3, 1), 'three': (1, 3, 2)}
PERIOD = 10
SAMPLES = (0, 1, 2, 3)


def samples(phase: int) -> tuple[int, ...]:
    # The standard gives no output before the first delay of a gate has run
    # (6.5), so the first phase is read only after every output has settled.
    return SAMPLES[-1:] if phase == 0 else SAMPLES
KNOWN = ('0101', '0011', '1010')
CONTROL = ('1111', '1100', '0110')


def case_name(row: Row) -> str: return 'test_gen_cross_gatearray_' + '_'.join(row)


def word(row: Row, phase: int) -> str:
    """Data input bits, MSB first; a scalar input has a single bit."""
    unknown = row[6] != 'known'
    if row[3] == 'scalar': return ('1', row[6] if unknown else '0', '1')[phase]
    bits = KNOWN[phase]
    return bits[:1] + row[6] + bits[2:] if phase == 1 and unknown else bits


def enable(row: Row, phase: int) -> str:
    unknown = row[6] != 'known'
    if row[4] == 'none': return ''
    if row[4] == 'scalar': return ('1', row[6] if unknown else '0', '1')[phase]
    bits = CONTROL[phase]
    return bits[:3] + row[6] if phase == 1 and unknown else bits


def table_and(a, b):
    if a == '0' or b == '0': return '0'
    return '1' if a == b == '1' else 'x'


def table_xnor(a, b):
    return 'x' if a in 'xz' or b in 'xz' else ('1' if a == b else '0')


def table_not(a):
    return {'0': '1', '1': '0'}.get(a, 'x')


def table_bufif1(data, control):
    """Table 28-5; an unknown control gives L or H, which %b shows as x."""
    if control == '0': return 'z'
    return data if control == '1' and data in '01' else 'x'


def table_nmos(data, control):
    """Table 28-6; L and H again read as x."""
    if control == '0' or data == 'z': return 'z'
    return data if control == '1' else 'x'


def gate_output(row: Row, data: str, control: str) -> str:
    return {'and': lambda: table_and(data, control), 'xnor': lambda: table_xnor(data, control),
            'not': lambda: table_not(data), 'bufif1': lambda: table_bufif1(data, control),
            'nmos': lambda: table_nmos(data, control)}[row[0]]()


def propagation(row: Row, value: str) -> int:
    rise, fall, off = DELAYS[row[5]]
    if value == '1': return rise
    if value == '0': return fall
    if value == 'z': return off
    return min(rise, fall, off)


def output_history(row: Row):
    """Change times and values of each instance output, from LSB to MSB."""
    history = []
    for position in range(COUNT):
        events = [(-1, 'x')]
        current = 'x'
        for phase in range(3):
            data = word(row, phase)
            control = enable(row, phase)
            a = data[-1] if len(data) == 1 else data[COUNT - 1 - position]
            b = '' if not control else control[-1] if len(control) == 1 else control[COUNT - 1 - position]
            value = gate_output(row, a, b)
            if value != current:
                events.append((phase * PERIOD + propagation(row, value), value))
                current = value
        history.append(events)
    return history


def observed(history, position: int, doubled_time: int) -> str:
    value = 'x'
    for time, new in history[position]:
        if 2 * time <= doubled_time: value = new
    return value


def reference(row: Row) -> str:
    history = output_history(row)
    lines = []
    for phase in range(3):
        for offset in samples(phase):
            doubled = 2 * (phase * PERIOD + offset) + 1
            bits = ''.join(observed(history, position, doubled) for position in reversed(range(COUNT)))
            if row[2] == 'part': bits = 'z' + bits + 'zzz'
            lines.append(f'p{phase} t{offset} {bits} a={word(row, phase)}'
                         + (f' c={enable(row, phase)}' if row[4] != 'none' else ''))
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    gate, array, output, input_, control, delay, _ = row
    left, right = RANGE[array]
    decl = ['logic [3:0] a_in;'] if input_ != 'scalar' else ['logic a_in;']
    drive = {'whole_down': 'a_in', 'scalar': 'a_in'}.get(input_)
    if input_ == 'whole_up':
        decl = ['logic [0:3] a_in;']; drive = 'a_in'
    if input_ == 'concat':
        decl = ['logic a3, a2, a1, a0;']; drive = '{a3, a2, a1, a0}'
    if output == 'whole_down': outputs = 'wire [3:0] y;'; target = 'y'; read = 'y'
    if output == 'whole_up': outputs = 'wire [0:3] y;'; target = 'y'; read = 'y'
    if output == 'part': outputs = 'wire [7:0] y;'; target = 'y[6:3]'; read = 'y'
    if output == 'concat':
        outputs = 'wire y3, y2, y1, y0;'; target = '{y3, y2, y1, y0}'; read = '{y3, y2, y1, y0}'
    if control == 'scalar': decl.append('logic en;'); second = ', en'
    elif control == 'vector': decl.append('logic [5:0] en;'); second = ', en[4:1]'
    else: second = ''
    timing = {'none': '', 'one': ' #2', 'two': ' #(1, 3)', 'three': ' #(1, 3, 2)'}[delay]
    lines = [f'module {case_name(row)};', '  timeunit 1ns / 1ps;', '  ' + outputs, *['  ' + item for item in decl],
             f'  {gate}{timing} g[{left}:{right}] ({target}, {drive}{second});']

    def assign(phase):
        out = []
        data = word(row, phase)
        if input_ == 'concat':
            out += [f"    a{3 - i} = 1'b{bit};" for i, bit in enumerate(data)]
        elif input_ == 'scalar': out.append(f"    a_in = 1'b{data};")
        else: out.append(f"    a_in = 4'b{data};")
        if control == 'scalar': out.append(f"    en = 1'b{enable(row, phase)};")
        if control == 'vector': out.append(f"    en = 6'b1{enable(row, phase)}0;")
        return out
    shown = 'a_in' if input_ != 'concat' else '{a3, a2, a1, a0}'
    extra = '' if control == 'none' else ' c=%b'
    args = f'{read}, {shown}' + ('' if control == 'none' else ', en' if control == 'scalar' else ', en[4:1]')
    lines.append('  initial begin')
    for phase in range(3):
        lines += assign(phase)
        lines.append(f'    #{samples(phase)[0] + 0.5};')
        for offset in samples(phase):
            lines.append(f'    $display("p{phase} t{offset} %b a=%b{extra}", {args});')
            lines.append('    #1;' if offset != SAMPLES[-1] else f'    #{PERIOD - SAMPLES[-1] - 0.5};')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    clause = {'and': '28.4', 'xnor': '28.4', 'not': '28.5', 'bufif1': '28.6', 'nmos': '28.7'}[row[0]]
    return Case(case_name(row), 'An array of gate instances maps terminal bits by position and keeps per-bit delays',
                f'28.3.6 28.3.5 {clause} 28.16 7.4.1 11.4.12 11.5.1 23.3.3.5',
                'Four instances share a terminal of the single-instance width and split a wider '
                'expression, with the least significant bit at the instance of the right-hand array '
                'index, so the array direction does not change which bit reaches which output. '
                'Terminals are vectors of both directions, part-selects, concatenations or a scalar. '
                'Values go from known to the X or Z of the row and back, and every output bit takes '
                'its rise, fall, turn-off or smallest delay from the table of its final value. All '
                'bits are read at half times, between any two output events.',
                source(row), reference(row), fourstate=any(c in reference(row) for c in 'xz'),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
