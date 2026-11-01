"""DPI copy-in/copy-out across NBA value and destination capture."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_dpi_nba'
VERSION = 1
CHAPTER = 35
MODEL = Model(
    'dpi_nba_capture',
    (('direction', ('input', 'output', 'inout')),
     ('order', ('nba_first', 'dpi_first')),
     ('actual', ('same', 'other')),
     ('width', ('8', '32', '65')),
     ('signedness', ('unsigned', 'signed')),
     ('state', ('bit', 'logic'))),
    lambda row: True,
    groups=(('direction', 'order', 'actual'), ('direction', 'width', 'signedness'),
            ('direction', 'width', 'state')),
    anchors=(('inout', 'nba_first', 'same', '8', 'signed', 'logic'),
             ('inout', 'dpi_first', 'other', '8', 'unsigned', 'bit'),
             ('output', 'dpi_first', 'same', '65', 'unsigned', 'logic'),
             ('input', 'nba_first', 'other', '32', 'signed', 'bit')),
    constraints=('全144行が合法。固定長配列の静的寿命の要素だけを使用する。'
                 'DPIのint仮引数に既知値を渡し、入力の幅・符号変換と復帰直後の書戻しを観測する。'
                 '同一プロセスでNBA予約とDPI呼出しを順序付け、予約後に添字・右辺・元要素を変更する。'
                 'outputの初期値は読まない。X/Z、open array、CからのSV再入、'
                 '時間を消費するDPI task、競合する別プロセスは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_dpi_nba_' + '_'.join(row)


def initial_values(width: int) -> list[int]:
    return [0x15, ((1 << width) - 1) ^ 0x15, (1 << (width - 1)) | 9]


def as_int(value: int, width: int, signed: bool) -> int:
    """SV actual-to-int assignment, followed by the C int representation."""
    if signed and value & (1 << (width - 1)):
        value -= 1 << width
    value &= (1 << 32) - 1
    return value - (1 << 32) if value & (1 << 31) else value


def reference(row: Row) -> str:
    direction, order, actual, width, signedness, _ = row
    w = int(width)
    mask = (1 << w) - 1
    values = initial_values(w)
    source = 1 if actual == 'same' else 2
    payload = (1 << (w - 1)) | 3
    captured = values[source] ^ payload
    argument = as_int(values[source], w, signedness == 'signed')
    returned = 53 if direction == 'output' else argument
    if direction != 'input':
        formal = -61 if direction == 'output' else (argument & 255) - 73
        values[source] = formal & mask
    if order == 'dpi_first':
        captured = values[source] ^ payload

    def snapshot(label):
        return label + ' ' + ' '.join(f'{v:0{(w+3)//4}x}' for v in values)

    lines = [f'return={returned}', snapshot('after_call')]
    values[source] = 0x2b
    lines += [snapshot('mutated'), f'indices=0,0 payload={mask:0{(w+3)//4}x}']
    values[1] = captured
    lines += [snapshot('postponed'), snapshot('settled')]
    return '\n'.join(lines) + '\n'


def make_case(row: Row) -> Case:
    direction, order, actual, width, signedness, state = row
    w = int(width)
    source = 1 if actual == 'same' else 2
    name = case_name(row)
    lines = ['`timescale 1ns/1ns', f'module {name};',
             f'  typedef {state} {signedness} [{w-1}:0] word_t;',
             f'  import "DPI-C" function int cross_dpi_nba_{direction}({direction} int value);',
             '  word_t cells[0:2], payload;', '  int nba_index, dpi_index, returned;',
             '  bit go;', '  initial begin', '    go = 0;']
    for index, value in enumerate(initial_values(w)):
        lines += [f"    cells[{index}] = {w}'h{value:x};"]
    lines += [f"    payload = {w}'h{((1 << (w-1)) | 3):x};",
              f'    nba_index = 1; dpi_index = {source};',
              '    #2; go = 1;', '    #2; $finish;', '  end',
              '  always @(posedge go) begin']
    enqueue = '    cells[nba_index] <= cells[dpi_index] ^ payload;'
    call = f'    returned = cross_dpi_nba_{direction}(cells[dpi_index]);'
    lines += [enqueue, call] if order == 'nba_first' else [call, enqueue]
    lines += ['    $display("return=%0d", returned);',
              '    $display("after_call %h %h %h", cells[0], cells[1], cells[2]);',
              f"    cells[dpi_index] = {w}'h2b;",
              "    nba_index = 0; dpi_index = 0; payload = '1;",
              '    $display("mutated %h %h %h", cells[0], cells[1], cells[2]);',
              '    $display("indices=%0d,%0d payload=%h", nba_index, dpi_index, payload);',
              '    $strobe("postponed %h %h %h", cells[0], cells[1], cells[2]);',
              '    #1;', '    $display("settled %h %h %h", cells[0], cells[1], cells[2]);',
              '  end', 'endmodule']
    return Case(name, 'DPI copyback and argument conversion cross NBA value and destination capture',
                '35.6.1 35.6.1.1 35.6.2 10.4.2 10.8 4.4.2.2 4.4.2.4 4.4.2.9 H.8.8',
                'A module process calls one imported function and schedules one NBA at time 2. '
                'The C function returns the converted input, writes a defined output without '
                'reading its unspecified initial value, or changes an inout value. The actual '
                'is the NBA destination or a different static array element. Scheduling before '
                'or after the call distinguishes old values from DPI copyback in the NBA RHS. '
                'The actual element, both indices and payload then change. Immediate output '
                'checks copyback; postponed and next-time output check captured bits and '
                'destination plus both other elements. Narrow/wide, signed/unsigned, bit/logic '
                'actuals cross the signed 32-bit int formal. C arithmetic cannot overflow. '
                'Known values only; no open arrays, reentry, blocking DPI tasks or process races.',
                '\n'.join(lines), reference(row),
                extra={'dpi_c': '@../../ch35/cross_dpi_nba.c',
                       'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
