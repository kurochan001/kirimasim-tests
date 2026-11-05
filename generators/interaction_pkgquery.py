"""Package array imports drive query bounds, scans and typed observations."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_pkgquery'
VERSION = 1
CHAPTER = 26
MODEL = Model(
    'package_array_query_scope',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('bounds', ('up', 'down')), ('origin', ('negative', 'positive')),
     ('length', ('one', 'three')), ('binding', ('explicit', 'wildcard', 'qualified')),
     ('source', ('first', 'second')), ('query', ('default', 'explicit'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('binding', 'source', 'query'),
            ('bounds', 'origin', 'length'), ('width', 'source', 'binding'),
            ('bounds', 'length', 'source'), ('binding', 'value', 'query')),
    anchors=(('1', 'bit', 'known', 'up', 'negative', 'one', 'explicit', 'first', 'default'),
             ('129', 'logic', 'z', 'down', 'positive', 'three', 'wildcard', 'second', 'explicit'),
             ('65', 'logic', 'x', 'up', 'negative', 'three', 'qualified', 'first', 'default'),
             ('33', 'bit', 'z', 'down', 'negative', 'one', 'wildcard', 'first', 'explicit'),
             ('32', 'logic', 'known', 'up', 'positive', 'three', 'explicit', 'second', 'explicit'),
             ('64', 'bit', 'known', 'down', 'positive', 'one', 'qualified', 'second', 'default')),
    constraints=('全行が合法で未対応による除外なし。二packageの同名固定配列は幅・長さ・添字原点・向きが異なる。'
                 '各moduleには幅も長さも異なる同名のローカル配列を置く。'
                 'automatic function内の明示import・ワイルドカードimport・修飾参照で対象packageを選ぶ。'
                 '$left/$size/$incrementが走査の開始位置・回数・方向を決め、左シフトとXORで全幅を集計する。'
                 '省略次元と明示次元1、packed次元2、$bits/$dimensions/$unpacked_dimensionsを観測する。'
                 '既知・既知またはX/Z・既知への回復の三相で、二つの呼出し元と以前の結果を保持する。'
                 '非選択packageの更新後も再呼出しし、次に選択packageと両moduleのローカル配列だけを更新する。'
                 '全配列要素・型付き結果・呼出し回数・訪問数・重み・終端添字を各操作後に観測する。'
                 'bitへのX/Z変換もfourstateを指定する。export・動的配列・符号付き演算・task・時間制御・並行呼出しは対象外。',),
)

QUERIES = ('bits', 'dimensions', 'unpacked_dimensions',
           'left', 'right', 'low', 'high', 'increment', 'size',
           'pleft', 'pright', 'plow', 'phigh', 'pincrement', 'psize')
COUNTS = ('calls', 'visited', 'weight', 'terminal')
PACKAGES = ('first_pkg', 'second_pkg')


def case_name(row: Row) -> str: return 'test_gen_cross_pkgquery_' + '_'.join(row)


def layout(row: Row, slot: int):
    width = int(row[0]) + slot * 2
    count = (1 if row[5] == 'one' else 3) + slot
    left = (-4 if slot == 0 else 5) if row[4] == 'negative' else (3 if slot == 0 else -6)
    step = 1 if (row[3] == 'up') != bool(slot) else -1
    return width, count, left, left + step * (count - 1)


def stimulus(width, phase, slot, ordinal, value='known'):
    bits = list((('10' if (phase + slot + ordinal) % 2 == 0 else '01') * width)[:width])
    for index in range(min(2, width)): bits[-1-index] = str(((ordinal + phase + slot) >> index) & 1)
    if phase == 1 and value != 'known':
        bits[0] = value
        if ordinal % 2 == 0: bits[-1] = value
    return ''.join(bits)


def query_values(width, count, left, right):
    return (width * count, 2, 1, left, right, min(left, right), max(left, right),
            1 if left >= right else -1, count, width - 1, 0, 0, width - 1, 1, width)


def reference(row: Row) -> str:
    selected = int(row[7] == 'second'); rw = int(row[0]) + 5; lines = []
    packages = [[], []]; locals_ = []; readers = []
    for slot in range(2):
        lw = int(row[0]) + 5 + 2 * slot
        locals_.append([stimulus(lw, 0, slot, i) for i in range(5)])
        readers.append(dict(result='0' * rw, checksum='0' * rw,
                            **{key: 0 for key in (*COUNTS, *QUERIES)}))
    def snapshot(phase, label):
        lines.append(f'h p={phase} step={label}')
        for slot in range(2):
            lines.append(f'p id={slot} ' + ' '.join(f'{i}={bits}' for i, bits in enumerate(packages[slot])))
            lines.append(f'l id={slot} ' + ' '.join(f'{i}={bits}' for i, bits in enumerate(locals_[slot])))
            values = readers[slot]
            lines.append(f'v id={slot} result={values["result"]} checksum={values["checksum"]} ' +
                         ' '.join(f'{k}={values[k]}' for k in COUNTS))
            lines.append(f'q id={slot} ' + ' '.join(f'{k}={values[k]}' for k in QUERIES))
    def call(slot):
        width, count, left, right = layout(row, selected)
        acc = '0' * width
        for bits in packages[selected]:
            acc = assigned(''.join(str(int(a) ^ int(b)) if a in '01' and b in '01' else 'x'
                                   for a, b in zip(acc[1:] + '0', bits)), width, row[1])
        v = readers[slot]; v['result'] = v['checksum'] = assigned(acc, rw, 'logic')
        v.update(zip(QUERIES, query_values(width, count, left, right)))
        v.update(calls=v['calls'] + 1, visited=count,
                 weight=sum((i + 1) * (left + (1 if left < right else -1) * i) for i in range(count)),
                 terminal=left + (1 if left < right else -1) * count)
    for phase in range(3):
        for slot in range(2):
            width, count, *_ = layout(row, slot)
            packages[slot] = [assigned(stimulus(width, phase, slot, i, row[2]), width, row[1]) for i in range(count)]
        snapshot(phase, 'before')
        for slot in (0, 1): call(slot); snapshot(phase, 'first' + str(slot))
        other = 1 - selected
        packages[other][-1] = packages[other][-1].translate(str.maketrans('01xz', '10xx'))
        snapshot(phase, 'unselected'); call(0); snapshot(phase, 'recheck')
        packages[selected][-1] = packages[selected][-1].translate(str.maketrans('01xz', '10xx'))
        locals_[0][0] = locals_[0][0].translate(str.maketrans('01xz', '10xx'))
        locals_[1][-1] = locals_[1][-1].translate(str.maketrans('01xz', '10xx'))
        snapshot(phase, 'refresh')
        for slot in (1, 0): call(slot); snapshot(phase, 'again' + str(slot))
        snapshot(phase, 'idle')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    selected = int(row[7] == 'second'); package = PACKAGES[selected]
    target = package + '::data' if row[6] == 'qualified' else 'data'
    explicit = ', 1' if row[8] == 'explicit' else ''
    rw = int(row[0]) + 5; lines = []
    for slot, name in enumerate(PACKAGES):
        width, count, left, right = layout(row, slot)
        lines += [f'package {name};', f'  typedef {row[1]} [{width-1}:0] word_t;',
                  f'  word_t data[{left}:{right}];', 'endpackage']
    for slot in range(2):
        lines += [f'module reader_{slot};', f'  logic [{rw+2*slot-1}:0] data[7:11];',
                  f"  logic [{rw-1}:0] checksum='0;"]
        lines += [f'  int {key}=0;' for key in (*COUNTS, *QUERIES)]
        lines += [f'  function automatic {package}::word_t scan();']
        if row[6] != 'qualified': lines += [f'    import {package}::{"*" if row[6] == "wildcard" else "data"};']
        lines += [f'    {package}::word_t acc;', '    int at;',
                  f"    acc='0; at=$left({target}{explicit}); visited=0; weight=0;",
                  f'    repeat ($size({target}{explicit})) begin', f'      acc=(acc << 1) ^ {target}[at];',
                  '      visited++; weight+=visited*at;', f'      at-=$increment({target}{explicit});', '    end',
                  '    terminal=at; checksum=acc; calls++;']
        for key in QUERIES:
            query = key[1:] if key.startswith('p') else key
            dimension = ', 2' if key.startswith('p') else '' if key in QUERIES[:3] else explicit
            lines.append(f'    {key}=${query}({target}{dimension});')
        lines += ['    return acc;', '  endfunction', 'endmodule']
    lines += [f'module {case_name(row)};', '  reader_0 a(); reader_1 b();',
              f"  logic [{rw-1}:0] ra='0, rb='0;", '  initial begin']
    for slot, name in enumerate(('a', 'b')):
        for ordinal in range(5):
            lines.append(f'    {name}.data[{7+ordinal}]={literal(stimulus(rw+2*slot, 0, slot, ordinal))};')
    def display(prefix, args, formats):
        nonlocal lines
        lines += [f'    $display("{prefix}' + ' '.join(f'{key}={fmt}' for key, fmt in formats) + '",',
                  *['      ' + ', '.join(args[i:i+3]) + (',' if i+3 < len(args) else ');') for i in range(0, len(args), 3)]]
    def snapshot(phase, label):
        nonlocal lines
        lines.append(f'    $display("h p={phase} step={label}");')
        for slot, name in enumerate(('a', 'b')):
            _, count, left, right = layout(row, slot)
            display(f'p id={slot} ', [f'{PACKAGES[slot]}::data[{left+(1 if left<right else -1)*i}]' for i in range(count)],
                    [(str(i), '%b') for i in range(count)])
            display(f'l id={slot} ', [f'{name}.data[{7+i}]' for i in range(5)], [(str(i), '%b') for i in range(5)])
            display(f'v id={slot} ', ['r'+name, name+'.checksum', *[name+'.'+k for k in COUNTS]],
                    [('result', '%b'), ('checksum', '%b'), *[(k, '%0d') for k in COUNTS]])
            # Split long query records with $write, without fixing simulator line wrapping.
            for start in range(0, len(QUERIES), 3):
                group = QUERIES[start:start+3]
                prefix = f'q id={slot} ' if start == 0 else ''
                fmt = prefix + ' '.join(k+'=%0d' for k in group)
                last = start+3 >= len(QUERIES)
                lines += [f'    ${"display" if last else "write"}("{fmt + ("" if last else " ")}",',
                          '      ' + ', '.join(name+'.'+k for k in group) + ');']
    def call(slot, phase, label):
        name = ('a', 'b')[slot]; lines.append(f'    r{name}={name}.scan();'); snapshot(phase, label)
    for phase in range(3):
        for slot, name in enumerate(PACKAGES):
            width, count, left, right = layout(row, slot)
            for i in range(count):
                lines.append(f'    {name}::data[{left+(1 if left<right else -1)*i}]={literal(stimulus(width, phase, slot, i, row[2]))};')
        snapshot(phase, 'before')
        for slot in (0, 1): call(slot, phase, 'first'+str(slot))
        other = PACKAGES[1-selected]; last = layout(row, 1-selected)[3]
        lines.append(f'    {other}::data[{last}]=~{other}::data[{last}];')
        snapshot(phase, 'unselected'); call(0, phase, 'recheck')
        last = layout(row, selected)[3]
        lines += [f'    {package}::data[{last}]=~{package}::data[{last}];',
                  '    a.data[7]=~a.data[7]; b.data[11]=~b.data[11];']
        snapshot(phase, 'refresh')
        for slot in (1, 0): call(slot, phase, 'again'+str(slot))
        snapshot(phase, 'idle')
    return '\n'.join(lines + ['    $finish;', '  end', 'endmodule'])


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Package array query binding controls scans while retaining local namesakes',
                '26.3 20.6.2 20.7 7.4.2 13.4 6.11.2 11.4.10',
                'Two packages have same-named arrays of distinct widths, bounds and lengths. '
                'Two caller modules also have local arrays named data. An inner explicit/wildcard '
                'import or a qualified package reference determines the actual array queried and '
                'walked by an automatic function. Observe query tuples for both dimensions, all '
                'package and local elements, full typed checksums and return values, call/visit '
                'counts, weighted indices and terminal indices. Update the unselected package '
                'and call again before changing the selected package and local namesakes; '
                'reversed followup calls retain previous results until called. Three phases '
                'cover known values, X/Z and known recovery without resetting history. No '
                'export, dynamic arrays, signed arithmetic, task, timing or concurrent calls.',
                source(row), reference(row), fourstate=row[2] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
