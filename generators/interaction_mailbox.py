"""Class handles through mailbox FIFO operations, capacity and alias updates."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_mailbox'
VERSION = 1
CHAPTER = 15
MODEL = Model(
    'mailbox_class_alias',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('storage', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('typing', ('typed', 'typeless')),
     ('operation', ('get', 'try_get', 'peek', 'try_peek')),
     ('update', ('before', 'after', 'both')),
     ('capacity', ('bounded', 'unbounded')), ('tail', ('object', 'null'))),
    lambda row: True,
    groups=(('width', 'storage', 'value'), ('typing', 'operation', 'capacity'),
            ('operation', 'update', 'capacity'), ('operation', 'capacity', 'tail')),
    anchors=(('1', 'bit', 'known', 'typed', 'get', 'before', 'bounded', 'object'),
             ('129', 'logic', 'known', 'typed', 'peek', 'both', 'unbounded', 'null'),
             ('65', 'logic', 'known', 'typed', 'try_get', 'after', 'bounded', 'null'),
             ('33', 'bit', 'known', 'typed', 'try_peek', 'both', 'bounded', 'object'),
             ('32', 'logic', 'known', 'typed', 'get', 'after', 'unbounded', 'object'),
             ('64', 'bit', 'known', 'typed', 'peek', 'before', 'bounded', 'null'),
             ('129', 'logic', 'z', 'typeless', 'try_peek', 'both', 'unbounded', 'null'),
             ('65', 'bit', 'x', 'typed', 'try_get', 'before', 'bounded', 'object'),
             ('33', 'logic', 'x', 'typeless', 'try_get', 'after', 'bounded', 'null')),
    constraints=('全3456行が合法。同じpacket型のハンドルだけを送り、型不一致は対象外。'
                 '満杯/空の確認には非ブロッキングメソッドを使い、get/peekは格納後に呼ぶ。'
                 '1プロセス内の直列操作で、待機プロセスの選択順や同時実行の競合は対象外。'
                 'typeless、4状態、nullも未対応を理由に除外しない。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_mailbox_' + '_'.join(row)


def stimuli(row: Row):
    width = int(row[0])
    # Ten binary position bits plus all-zero/all-one frames identify 4 banks.
    for phase in range(12):
        banks = [''.join(str(((role * width + bit + 1) >> phase) & 1)
                         if phase < 10 else str(phase - 10)
                         for bit in reversed(range(width))) for role in range(4)]
        yield f'k{phase}', banks
    if row[2] != 'known':
        for phase, bit in enumerate((0, width - 1, width // 2)):
            banks = []
            for role in range(4):
                bits = list(''.join(str(((role * width + i + 1) >> phase) & 1)
                                    for i in reversed(range(width))))
                bits[width - 1 - bit] = row[2]
                banks.append(''.join(bits))
            yield f'u{phase}', banks


def invert(bits):
    return ''.join('1' if c == '0' else '0' if c == '1' else 'x' for c in bits)


def store(bits, row):
    return bits.translate(str.maketrans('xz', '00')) if row[1] == 'bit' else bits


def reference(row: Row) -> str:
    lines = []
    for label, raw in stimuli(row):
        a, b, c, g = [store(word, row) for word in raw]
        before = store(invert(raw[0]), row)
        through = store(invert(raw[1]), row)
        after = store(invert(raw[2]), row)
        guard_update = store(invert(raw[3]), row)
        admitted = int(row[6] == 'unbounded')
        size = 2 + admitted
        lines.append(f'{label} put ok={admitted} num={size} guard=1')
        if row[5] in ('before', 'both'):
            a = before
        lines.append(f'{label} source a={a} b={b} c={c} guard={g}')
        size -= int(row[4] in ('get', 'try_get'))
        lines.append(f'{label} fetch ok=1 same=1 tag=11 value={a} num={size}')
        a = through
        lines.append(f'{label} through source={a} received={a} other={b} guard={g}')
        if row[5] in ('after', 'both'):
            a = after
        lines.append(f'{label} after source={a} received={a} num={size}')
        queue = [(11, a), (22, b)]
        if admitted:
            queue.append((0, '-') if row[7] == 'null' else (33, c))
        if row[4] in ('get', 'try_get'):
            queue.pop(0)
        for index, (tag, payload) in enumerate(queue):
            lines.append(f'{label} drain{index} null={int(tag == 0)} tag={tag} value={payload}')
        lines.append(f'{label} empty get=0 peek=0 num=0')
        lines.append(f'{label} guard ok=1 same=1 tag=99 value={g} num=0')
        lines.append(f'{label} guard_update source={guard_update} received={guard_update} other={b}')
    return '\n'.join(lines) + '\n'


def assignment(name, bits):
    chunks = [bits[i:i + 64] for i in range(0, len(bits), 64)]
    if len(chunks) == 1:
        return [f"    {name} = {len(bits)}'b{bits};"]
    return [f'    {name} = {{'] + [
        f"      {len(part)}'b{part}" + (',' if i + 1 < len(chunks) else '')
        for i, part in enumerate(chunks)] + ['    };']


def make_case(row: Row) -> Case:
    width, storage, value, typing, operation, update, capacity, tail = row
    name = case_name(row)
    box = 'mailbox #(packet)' if typing == 'typed' else 'mailbox'
    lines = ['`timescale 1ns/1ns', f'typedef {storage} [{int(width)-1}:0] word_t;',
             'class packet;', '  word_t payload;', '  int tag;', 'endclass',
             f'typedef {box} box_t;', f'module {name};',
             f"  localparam int BOUND = {2 if capacity == 'bounded' else 0};",
             '  box_t target_box, guard_box;',
             '  packet a, b, c, g, r, tail_item, held_guard, empty_item, message;',
             '  word_t init_a, init_b, init_c, init_g;',
             '  word_t before_value, through_value, after_value, guard_value;',
             '  int result, get_result, peek_result, index;',
             '  task automatic exercise(input string label);',
             '    target_box = new(BOUND);', '    guard_box = new();',
             '    a = new; b = new; c = new; g = new;',
             '    a.payload = init_a; a.tag = 11;',
             '    b.payload = init_b; b.tag = 22;',
             '    c.payload = init_c; c.tag = 33;',
             '    g.payload = init_g; g.tag = 99;',
             '    target_box.put(a);', '    target_box.put(b);',
             '    guard_box.put(g);',
             f"    message = {'c' if tail == 'object' else 'null'};",
             '    result = target_box.try_put(message);',
             '    $display("%s put ok=%0d num=%0d guard=%0d",',
             '             label, result > 0, target_box.num(), guard_box.num());']
    if update in ('before', 'both'):
        lines += ['    a.payload = before_value;']
    lines += ['    $display("%s source a=%b b=%b c=%b guard=%b",',
              '             label, a.payload, b.payload, c.payload, g.payload);',
              '    r = b;', '    result = 1;']
    if operation.startswith('try_'):
        lines += [f'    result = target_box.{operation}(r);']
    else:
        lines += [f'    target_box.{operation}(r);']
    lines += ['    $display("%s fetch ok=%0d same=%0d tag=%0d value=%b num=%0d",',
              '             label, result > 0, r == a, r.tag, r.payload, target_box.num());',
              '    r.payload = through_value;',
              '    $display("%s through source=%b received=%b other=%b guard=%b",',
              '             label, a.payload, r.payload, b.payload, g.payload);']
    if update in ('after', 'both'):
        lines += ['    a.payload = after_value;']
    lines += ['    $display("%s after source=%b received=%b num=%0d",',
              '             label, a.payload, r.payload, target_box.num());',
              '    index = 0;', '    while (target_box.try_get(tail_item) > 0) begin',
              '      if (tail_item == null)',
              '        $display("%s drain%0d null=1 tag=0 value=-", label, index);',
              '      else',
              '        $display("%s drain%0d null=0 tag=%0d value=%b",',
              '                 label, index, tail_item.tag, tail_item.payload);',
              '      index++;', '    end',
              '    empty_item = b;', '    get_result = target_box.try_get(empty_item);',
              '    $write("%s empty get=%0d ", label, get_result);',
              '    empty_item = b;', '    peek_result = target_box.try_peek(empty_item);',
              '    $display("peek=%0d num=%0d",',
              '             peek_result, target_box.num());',
              '    held_guard = b;', '    result = guard_box.try_get(held_guard);',
              '    $display("%s guard ok=%0d same=%0d tag=%0d value=%b num=%0d",',
              '             label, result > 0, held_guard == g, held_guard.tag,',
              '             held_guard.payload, guard_box.num());',
              '    held_guard.payload = guard_value;',
              '    $display("%s guard_update source=%b received=%b other=%b",',
              '             label, g.payload, held_guard.payload, b.payload);',
              '  endtask', '  initial begin']
    for label, words in stimuli(row):
        for variable, bits in zip(('init_a', 'init_b', 'init_c', 'init_g'), words):
            lines += assignment(variable, bits)
        for variable, bits in zip(('before_value', 'through_value', 'after_value', 'guard_value'),
                                  (invert(word) for word in words)):
            lines += assignment(variable, bits)
        lines += [f'    exercise("{label}");']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(name, 'Mailbox methods retain FIFO class-handle identity across alias writes and capacity',
                '15.4.3 15.4.4 15.4.5 15.4.6 15.4.7 15.4.8 15.4.9 15.4.2 8.4 8.12 6.11.2',
                'Mailbox messages are handles to objects, not object copies. '
                'Typed and typeless boxes carry the same packet type. A bounded '
                'box rejects a third message while an unbounded box admits it, '
                'including null as a real queued message. Get removes and peek '
                'retains the oldest handle. Source writes before/after retrieval '
                'and writes through the retrieved handle must reach the same '
                'object without changing its sibling or a separate guard box. '
                'Drain order, message counts and empty nonblocking return values '
                'are observed without assuming an output argument value on empty calls. '
                'Known bit histories distinguish four input banks and their '
                'complements through 129 bits, then X/Z frames check bit/logic '
                'conversion before storage and after alias updates. Operations '
                'run serially in one process with data present for blocking '
                'reads. Blocking wakeup order, type mismatches, derived handles '
                'and concurrent callers are outside this model.',
                '\n'.join(lines), reference(row), fourstate=value != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases():
    return [make_case(row) for row in MODEL.select()]
