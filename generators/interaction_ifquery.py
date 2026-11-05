"""Interface-local array queries drive ordered scans and typed results."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_ifquery'
VERSION = 1
CHAPTER = 25
MODEL = Model(
    'interface_array_query_walk',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('bounds', ('up', 'down')), ('origin', ('negative', 'positive')),
     ('length', ('one', 'three')), ('query', ('default', 'explicit')),
     ('routine', ('function', 'task')), ('order', ('ab', 'ba')),
     ('packed', ('up', 'down'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('bounds', 'length', 'query'),
            ('origin', 'bounds', 'length'), ('routine', 'order', 'value'),
            ('width', 'packed', 'query'), ('routine', 'length', 'query')),
    anchors=(('1', 'bit', 'known', 'up', 'negative', 'one', 'default', 'function', 'ab', 'up'),
             ('129', 'logic', 'z', 'down', 'positive', 'three', 'explicit', 'task', 'ba', 'down'),
             ('65', 'logic', 'x', 'up', 'negative', 'three', 'default', 'task', 'ab', 'down'),
             ('33', 'bit', 'z', 'down', 'negative', 'one', 'explicit', 'function', 'ba', 'up'),
             ('32', 'logic', 'known', 'up', 'positive', 'three', 'explicit', 'function', 'ba', 'down'),
             ('64', 'bit', 'known', 'down', 'positive', 'one', 'default', 'task', 'ab', 'up')),
    constraints=('全行が合法で未対応による除外なし。二interfaceは幅・長さ・添字原点・向きが異なる。'
                 '一番目は幅Wと長さ1/3、二番目は幅W+2と長さ2/4で逆向き。packed範囲も逆向きで原点付き。'
                 'interface内のautomatic function/taskが$left/$size/$incrementで論理位置順に走査し、'
                 '左シフトとXORで順序依存の全幅チェックサムを計算する。単一要素のincrementは1。'
                 '省略した次元と明示次元1を区別し、packed次元2も全問い合わせを観測する。'
                 '既知・既知またはX/Z・既知への回復の三相で、各呼出し後に両実体を読む。'
                 '一方の末尾要素と他方のguardだけを更新し、逆順で再呼出しする。'
                 '戻り値とoutputコピーは幅W+4のlogicへ格納する。bitへのX/Z変換もfourstateを指定する。'
                 '符号付き演算・interfaceポート・modport・virtual interface・動的配列・並行呼出し・時間制御は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_ifquery_' + '_'.join(row)


def layout(row: Row, slot: int) -> tuple[int, int, int, int, int, int]:
    width = int(row[0]) + 2 * slot
    count = (1 if row[5] == 'one' else 3) + slot
    left = (-4 if slot == 0 else 5) if row[4] == 'negative' else (3 if slot == 0 else -6)
    step = 1 if (row[3] == 'up') != bool(slot) else -1
    right = left + step * (count - 1)
    packed_up = (row[9] == 'up') != bool(slot)
    pl, pr = (-2, width - 3) if packed_up else (width + 2, 3)
    return width, count, left, right, pl, pr


def stimulus(row: Row, phase: int, slot: int, ordinal: int) -> str:
    width = layout(row, slot)[0]
    bits = list((('10' if (phase + slot + ordinal) % 2 == 0 else '01') * width)[:width])
    bits[-1] = str((ordinal + phase) % 2)
    if width > 1:
        bits[-2] = str((ordinal // 2) % 2)
    if phase == 1 and row[2] != 'known':
        bits[0] = row[2]
        bits[-1] = row[2] if ordinal % 2 == 0 else bits[-1]
    return ''.join(bits)


def metrics(left: int, right: int) -> tuple[int, ...]:
    return left, right, min(left, right), max(left, right), 1 if left >= right else -1, abs(left - right) + 1


def reference(row: Row) -> str:
    state, lines = [], []
    result_width = int(row[0]) + 4
    for slot in range(2):
        width = layout(row, slot)[0]
        state.append(dict(data=[], guard=('01' * width)[:width], checksum='0' * width,
                          result='0' * result_width, calls=0, visited=0, weight=0, terminal=0))

    def snapshot(phase, label):
        lines.append(f'h p={phase} step={label}')
        for slot, values in enumerate(state):
            width, count, left, right, pl, pr = layout(row, slot)
            lines.append(f'q id={slot} bits={width * count} dims=2 unpacked=1')
            for dimension, bounds in enumerate(((left, right), (pl, pr)), 1):
                lines.append(f'q id={slot} dim={dimension} ' + ' '.join(
                    f'{key}={value}' for key, value in zip(('left', 'right', 'low', 'high', 'increment', 'size'), metrics(*bounds))))
            lines.append(f'v id={slot} guard={values["guard"]} checksum={values["checksum"]} result={values["result"]} ' +
                         ' '.join(f'{key}={values[key]}' for key in ('calls', 'visited', 'weight', 'terminal')))
            lines.append(f'd id={slot} ' + ' '.join(f'{i}={value}' for i, value in enumerate(values['data'])))

    def call(slot):
        values = state[slot]
        width, count, left, right, _, _ = layout(row, slot)
        step = 1 if left < right else -1
        acc = '0' * width
        for bits in values['data']:
            acc = ''.join(str(int(a) ^ int(b)) if a in '01' and b in '01' else 'x'
                          for a, b in zip(acc[1:] + '0', bits))
        values.update(checksum=acc, result=assigned(acc, result_width, 'logic'),
                      calls=values['calls'] + 1, visited=count,
                      weight=sum((i + 1) * (left + step * i) for i in range(count)), terminal=left + step * count)

    order = (0, 1) if row[8] == 'ab' else (1, 0)
    for phase in range(3):
        for slot, values in enumerate(state):
            width, count, *_ = layout(row, slot)
            values['data'] = [assigned(stimulus(row, phase, slot, i), width, row[1]) for i in range(count)]
        snapshot(phase, 'before')
        for slot in order:
            call(slot); snapshot(phase, 'first' + str(slot))
        state[0]['data'][-1] = state[0]['data'][-1].translate(str.maketrans('01xz', '10xx'))
        state[1]['guard'] = state[1]['guard'].translate(str.maketrans('01xz', '10xx'))
        snapshot(phase, 'refresh')
        for slot in reversed(order):
            call(slot); snapshot(phase, 'again' + str(slot))
        snapshot(phase, 'idle')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    explicit = ', 1' if row[6] == 'explicit' else ''
    routine = row[7]
    lines = ['interface query_if #(parameter int W=1, N=1, L=0, UP=1, PUP=1);',
             '  localparam int R = UP ? L+N-1 : L-N+1;',
             f'  typedef {row[1]} [(PUP ? -2 : W+2):(PUP ? W-3 : 3)] word_t;',
             '  word_t data[L:R], guard, checksum;', '  int calls, visited, weight, terminal;',
             '  function automatic word_t scan();' if routine == 'function' else '  task automatic scan(output word_t result);',
             '    word_t acc;', '    int at;', f"    acc='0; at=$left(data{explicit}); visited=0; weight=0;",
             f'    repeat ($size(data{explicit})) begin', '      acc = (acc << 1) ^ data[at];',
             '      visited++; weight += visited * at;', f'      at -= $increment(data{explicit});',
             '    end', '    terminal=at; checksum=acc; calls++;',
             '    return acc;' if routine == 'function' else '    result=acc;', '  end' + routine,
             'endinterface', f'module {case_name(row)};']
    for slot, name in enumerate(('a', 'b')):
        width, count, left, right, pl, pr = layout(row, slot)
        # A singleton's source orientation still varies, although the query increment is 1.
        up = int((row[3] == 'up') != bool(slot))
        pup = int((row[9] == 'up') != bool(slot))
        lines.append(f'  query_if #(.W({width}), .N({count}), .L({left}), .UP({up}), .PUP({pup})) {name}();')
    lines += [f'  logic [{int(row[0]) + 3}:0] ra, rb;', '  initial begin', "    ra='0; rb='0;"]
    for slot, name in enumerate(('a', 'b')):
        width = layout(row, slot)[0]
        lines += [f'    {name}.calls=0; {name}.visited=0; {name}.weight=0; {name}.terminal=0;',
                  f"    {name}.checksum='0; {name}.guard={literal(('01' * width)[:width])};"]

    def snapshot(phase, label):
        nonlocal lines
        lines.append(f'    $display("h p={phase} step={label}");')
        for slot, name in enumerate(('a', 'b')):
            _, count, left, right, _, _ = layout(row, slot)
            lines += [f'    $display("q id={slot} bits=%0d dims=%0d unpacked=%0d",',
                      f'      $bits({name}.data), $dimensions({name}.data), $unpacked_dimensions({name}.data));']
            for dim in (1, 2):
                dimension = explicit if dim == 1 else ', 2'
                lines += [f'    $display("q id={slot} dim={dim} left=%0d right=%0d low=%0d high=%0d increment=%0d size=%0d",',
                          '      ' + ', '.join(f'${q}({name}.data{dimension})' for q in ('left', 'right', 'low')) + ',',
                          '      ' + ', '.join(f'${q}({name}.data{dimension})' for q in ('high', 'increment', 'size')) + ');']
            lines += [f'    $display("v id={slot} guard=%b checksum=%b result=%b calls=%0d visited=%0d weight=%0d terminal=%0d",',
                      f'      {name}.guard, {name}.checksum, r{name},',
                      f'      {name}.calls, {name}.visited, {name}.weight, {name}.terminal);',
                      f'    $display("d id={slot} ' + ' '.join(f'{i}=%b' for i in range(count)) + '",',
                      '      ' + ', '.join(f'{name}.data[{left + (1 if left < right else -1) * i}]' for i in range(count)) + ');']

    def call(slot, phase, label):
        name = ('a', 'b')[slot]
        lines.append(f'    r{name}={name}.scan();' if routine == 'function' else f'    {name}.scan(r{name});')
        snapshot(phase, label + str(slot))

    order = (0, 1) if row[8] == 'ab' else (1, 0)
    for phase in range(3):
        for slot, name in enumerate(('a', 'b')):
            _, count, left, right, _, _ = layout(row, slot)
            for i in range(count):
                at = left + (1 if left < right else -1) * i
                lines.append(f'    {name}.data[{at}]={literal(stimulus(row, phase, slot, i))};')
        snapshot(phase, 'before')
        for slot in order: call(slot, phase, 'first')
        lines += ['    a.data[$right(a.data)]=~a.data[$right(a.data)];', '    b.guard=~b.guard;']
        snapshot(phase, 'refresh')
        for slot in reversed(order): call(slot, phase, 'again')
        snapshot(phase, 'idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Interface-local array queries drive ordered scans and preserve each instance',
                '25.2 25.7 20.6.2 20.7 7.4.2 13.4 13.5 6.11.2 11.4.10',
                'Two parameterized interfaces have distinct word widths, lengths, origins and opposite '
                'unpacked/packed directions. Automatic functions or tasks use array queries to start, '
                'bound and advance an ordered scan. Each step shifts the accumulator then XORs a '
                'whole element. Observe all elements, both dimension query tuples, typed return/output '
                'copyout, per-instance counters and guards after every call. Update only one last '
                'element and the other guard, observe retained results, then call in reverse order. '
                'Known, X/Z stress and known recovery phases retain earlier call history. Singleton '
                'increment is one. No interface ports, modports, virtual handles, signed arithmetic, '
                'dynamic arrays, concurrent calls or time controls are used.',
                source(row), reference(row), fourstate=row[2] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
