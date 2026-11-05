"""Program cancellation across overlapping automatic task frames and copyout."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_progframe'
VERSION = 1
CHAPTER = 24
MODEL = Model(
    'program_task_frame_lifetime',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('sign', ('u', 's')), ('mode', ('output', 'inout')),
     ('storage', ('scalar', 'element')), ('stop', ('before', 'between', 'natural')),
     ('completion', ('end', 'return')), ('order', ('ab', 'ba'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('stop', 'mode', 'completion'),
            ('sign', 'mode', 'storage'), ('stop', 'completion', 'order'),
            ('width', 'sign', 'mode'), ('storage', 'mode', 'order')),
    anchors=(('1', 'bit', 'known', 'u', 'output', 'scalar', 'before', 'end', 'ab'),
             ('129', 'logic', 'z', 's', 'inout', 'element', 'between', 'return', 'ba'),
             ('65', 'logic', 'x', 'u', 'output', 'element', 'natural', 'return', 'ab'),
             ('33', 'bit', 'z', 's', 'inout', 'scalar', 'before', 'return', 'ba'),
             ('32', 'logic', 'known', 's', 'output', 'scalar', 'natural', 'return', 'ab'),
             ('64', 'logic', 'known', 'u', 'inout', 'element', 'between', 'end', 'ba')),
    constraints=('全行が合法で未対応による除外なし。二つの独立programが各二つのautomatic task呼出しを重ねる。'
                 '開始は1/3、復帰は7/11、外部入力と実引数の更新は5とする。'
                 '対象programだけを6または9で$exitし、自然終了の対照も保持する。'
                 'output/inoutの仮引数と局所語は呼出しごとに保持し、正常なendtaskまたはreturnでだけコピーアウトする。'
                 '実引数は3ビット広いlogicで、符号拡張と固定配列[2:4]の非選択要素も観測する。'
                 '12で既知値に更新し、生存するprogramが同じtaskを再呼出しして13で復帰する。'
                 '監視はmoduleだけで行い、programの書込みと同時刻の観測順序に依存しない。'
                 '相手programのinitialは20まで待ち、moduleは15で明示終了する。暗黙の全体終了は主対象にしない。'
                 'ref・可変添字・NBA・join_none・再帰・同時刻の競合writer・static taskは主対象外。'
                 '入力X/Zからbitへの変換でもfourstateを指定する。',),
)

LANE_COUNTS = ('entered', 'done', 'returned', 'tail')
FLAGS = ('parent', 'recovered', 'stop', 'after', 'natural')


def case_name(row: Row) -> str:
    return 'test_gen_cross_progframe_' + '_'.join(row)


def actual(row: Row, owner: str, lane: str) -> str:
    return f'{owner}_cells[{dict(a=2, b=3, guard=4)[lane]}]' if row[5] == 'element' else owner + '_' + lane


def pattern(width: int, code: int) -> str:
    bits = list((('10' if code % 2 else '01') * width)[:width])
    for index in range(min(3, width)): bits[-1 - index] = str((code >> index) & 1)
    return ''.join(bits)


def inputs(row: Row, phase: int):
    width = int(row[0]); values = {}
    for owner, offset in (('p', 0), ('q', 4)):
        for lane, number in (('a', 0), ('b', 1)):
            raw = pattern(width, offset + number + 1 + phase * 3)
            if phase == 0 and row[2] != 'known' and (owner, lane) in (('p', 'a'), ('q', 'b')):
                raw = (row[2] if owner == 'p' else {'x': 'z', 'z': 'x'}[row[2]]) * width
            values[owner + '_src_' + lane] = raw
    return values


def xor(bits: str, other: str) -> str:
    return ''.join(str(int(a) ^ int(b)) if a in '01' and b in '01' else 'x' for a, b in zip(bits, other))


def reference(row: Row) -> str:
    width, state, signed = int(row[0]), row[1], row[3] == 's'
    src = inputs(row, 0); values, counts, flags, frames, lines = {}, {}, {}, {}, []
    for owner, offset in (('p', 0), ('q', 4)):
        values[owner] = {lane: pattern(width + 3, offset + i + 1) for i, lane in enumerate(('a', 'b', 'guard'))}
        for lane in ('a', 'b'):
            for key in ('entry', 'late', 'local'): values[owner][key + '_' + lane] = '0' * width
            for key in LANE_COUNTS: counts[owner + '_' + key + '_' + lane] = 0
        flags[owner] = {key: 0 for key in FLAGS}
    stop = {'before': 6, 'between': 9, 'natural': None}[row[6]]
    order = ('a', 'b') if row[8] == 'ab' else ('b', 'a')
    events = {}
    for owner in ('p', 'q'):
        for slot, lane in enumerate(order):
            events.setdefault(1 + 2 * slot, []).append(('entry', owner, lane))
            events.setdefault(7 + 4 * slot, []).append(('return', owner, lane))
    if stop is not None: events.setdefault(stop, []).append(('stop', 'p', ''))
    for owner in ('p', 'q'):
        if owner == 'q' or stop is None:
            events.setdefault(12, []).append(('entry', owner, 'a'))
            events.setdefault(13, []).append(('return', owner, 'a'))
    if stop is None: events.setdefault(13, []).append(('natural', 'p', ''))
    def snapshot(label, tick):
        lines.append(f'h step={label} t={tick}')
        for owner in ('p', 'q'):
            v = values[owner]
            lines.append(f'{owner} a={v["a"]} b={v["b"]} guard={v["guard"]} '
                         f'src_a={src[owner + "_src_a"]} src_b={src[owner + "_src_b"]}')
            for lane in ('a', 'b'):
                lines.append(f'{owner} lane={lane} entry={v["entry_" + lane]} late={v["late_" + lane]} local={v["local_" + lane]} ' +
                             ' '.join(f'{key}={counts[owner + "_" + key + "_" + lane]}' for key in LANE_COUNTS))
            lines.append(owner + ' ' + ' '.join(f'{key}={flags[owner][key]}' for key in FLAGS))
    def update(phase):
        src.update(inputs(row, phase))
        for owner, offset in (('p', 0), ('q', 4)):
            for i, lane in enumerate(('a', 'b')): values[owner][lane] = pattern(width + 3, offset + i + 8 + phase * 3)
    observations = {2: 'entry_first', 4: 'entry_both', 8: 'first_return', 10: 'after_stop', 14: 'recovered', 15: 'idle'}
    for tick in range(16):
        if tick == 5: update(1); snapshot('refresh', tick)
        elif tick == 12: snapshot('complete', tick); update(2); snapshot('reset', tick)
        elif tick in observations: snapshot(observations[tick], tick)
        for kind, owner, lane in events.get(tick, []):
            if kind == 'stop': flags[owner]['stop'] = 1; continue
            if kind == 'natural': flags[owner]['natural'] = 1; continue
            if owner == 'p' and stop is not None and tick >= stop: continue
            v = values[owner]; index = int(lane == 'b')
            if kind == 'entry':
                sample = assigned(src[owner + '_src_' + lane], width, state)
                old = assigned(v[lane], width, state)
                held = sample if row[4] == 'output' else xor(sample, old)
                staged = assigned(xor(held, format(index + 1, f'0{width}b')[-width:]), width, state)
                frames[owner, lane] = held, staged
                v['entry_' + lane], v['local_' + lane] = held, staged
                counts[owner + '_entered_' + lane] += 1
            else:
                held, staged = frames[owner, lane]
                final = assigned(xor(staged, format(index + 2, f'0{width}b')[-width:]), width, state)
                v['late_' + lane], v['local_' + lane] = held, final
                v[lane] = assigned(final, width + 3, 'logic', signed)
                for key in ('done', 'returned'): counts[owner + '_' + key + '_' + lane] += 1
                if row[7] == 'end': counts[owner + '_tail_' + lane] += 1
                if tick == 11: flags[owner]['parent'] = 1
                if tick == 13: flags[owner]['recovered'] = 1
    return '\n'.join(lines) + '\n'


def report(owner, stage):
    return ['      if (id==0) begin',
            f'        {owner}_{"entered" if stage == "entry" else "done"}_a++;',
            f'        {owner}_{stage}_a=held; {owner}_local_a=result;', '      end else begin',
            f'        {owner}_{"entered" if stage == "entry" else "done"}_b++;',
            f'        {owner}_{stage}_b=held; {owner}_local_b=result;', '      end']


def program(row: Row, owner: str):
    lines = [f'  program {owner};',
             f'    task automatic transfer(input word_t sampled, {row[4]} word_t result,',
             '                            input int id, input int delay);', '      word_t held;',
             '      held=sampled;' if row[4] == 'output' else '      held=sampled ^ result;',
             "      result=held ^ word_t'(id+1);", *report(owner, 'entry'), '      #delay;',
             "      result=result ^ word_t'(id+2);", *report(owner, 'late')]
    if row[7] == 'return': lines.append('      return;')
    lines += ['      if (id==0) begin', f'        {owner}_tail_a++;', '      end else begin',
              f'        {owner}_tail_b++;', '      end', '    endtask', '    initial begin', '      fork']
    order = ('a', 'b') if row[8] == 'ab' else ('b', 'a')
    for slot, lane in enumerate(order):
        lines += [f'        begin #{1 + 2 * slot};',
                  f'          transfer({owner}_src_{lane}, {actual(row, owner, lane)}, {int(lane == "b")}, {6 + 2 * slot});',
                  f'          {owner}_returned_{lane}++;', '        end']
    lines += ['      join', f'      {owner}_parent=1;', '      #1;',
              f'      transfer({owner}_src_a, {actual(row, owner, "a")}, 0, 1);',
              f'      {owner}_returned_a++; {owner}_recovered=1;', '    end', '    initial begin']
    if owner == 'p' and row[6] != 'natural':
        lines += [f'      #{6 if row[6] == "before" else 9}; {owner}_stop=1;', '      $exit;', f'      {owner}_after=1;']
    else: lines += [f'      #{13 if owner == "p" else 20}; {owner}_natural=1;']
    return lines + ['    end', '  endprogram']


def source(row: Row) -> str:
    width = int(row[0]); sign = ' signed' if row[3] == 's' else ''
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};',
             f'  typedef {row[1]}{sign} [{width - 1}:0] word_t;', f'  typedef logic [{width + 2}:0] actual_t;']
    for owner in ('p', 'q'):
        lines += [f'  actual_t {owner}_cells[2:4];' if row[5] == 'element' else f'  actual_t {owner}_a, {owner}_b, {owner}_guard;',
                  f'  logic [{width - 1}:0] {owner}_src_a, {owner}_src_b;']
        for lane in ('a', 'b'):
            lines += [f"  logic [{width - 1}:0] {owner}_{key}_{lane}='0;" for key in ('entry', 'late', 'local')]
            lines += [f'  int {owner}_{key}_{lane}=0;' for key in LANE_COUNTS]
        lines += [f'  int {owner}_{key}=0;' for key in FLAGS]
    lines += program(row, 'p') + program(row, 'q') + ['  initial begin']
    for owner, offset in (('p', 0), ('q', 4)):
        for i, lane in enumerate(('a', 'b', 'guard')):
            lines.append(f'    {actual(row, owner, lane)}={literal(pattern(width + 3, offset + i + 1))};')
    for name, bits in inputs(row, 0).items(): lines.append(f'    {name}={literal(bits)};')
    def snapshot(label):
        nonlocal lines
        lines += [f'    $display("h step={label} t=%0d", $time);']
        for owner in ('p', 'q'):
            lines += [f'    $write("{owner} a=%b b=%b guard=%b ",',
                      '      ' + ', '.join(actual(row, owner, lane) for lane in ('a', 'b', 'guard')) + ');',
                      f'    $display("src_a=%b src_b=%b", {owner}_src_a, {owner}_src_b);']
            for lane in ('a', 'b'):
                lines += [f'    $write("{owner} lane={lane} entry=%b late=%b local=%b ",',
                          f'      {owner}_entry_{lane}, {owner}_late_{lane}, {owner}_local_{lane});',
                          '    $display("entered=%0d done=%0d returned=%0d tail=%0d",',
                          '      ' + ', '.join(f'{owner}_{key}_{lane}' for key in LANE_COUNTS) + ');']
            lines += [f'    $display("{owner} parent=%0d recovered=%0d stop=%0d after=%0d natural=%0d",',
                      f'      {owner}_parent, {owner}_recovered, {owner}_stop, {owner}_after, {owner}_natural);']
    def update(phase):
        nonlocal lines
        for name, bits in inputs(row, phase).items(): lines.append(f'    {name}={literal(bits)};')
        for owner, offset in (('p', 0), ('q', 4)):
            for i, lane in enumerate(('a', 'b')):
                lines.append(f'    {actual(row, owner, lane)}={literal(pattern(width + 3, offset + i + 8 + phase * 3))};')
    lines += ['    #2;']; snapshot('entry_first'); lines += ['    #2;']; snapshot('entry_both')
    lines += ['    #1;']; update(1); snapshot('refresh'); lines += ['    #3;']; snapshot('first_return')
    lines += ['    #2;']; snapshot('after_stop'); lines += ['    #2;']; snapshot('complete'); update(2); snapshot('reset')
    lines += ['    #2;']; snapshot('recovered'); lines += ['    #1;']; snapshot('idle')
    return '\n'.join(lines + ['    $finish;', '  end', 'endmodule'])


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Program cancellation preserves automatic task frames and suppresses unfinished copyout',
                '24.3 24.7 13.3 13.5 12.8 9.3.2 7.4.2 6.11.2 11.4.8',
                'Two sibling programs overlap two automatic tasks each. Capture input/inout '
                'values and private locals before external updates, then observe delayed '
                'normal completion, early task return or program-wide cancellation. Only '
                'completed tasks copy back into wider scalar/array-element actuals; preserve '
                'the canceled call and an independent program. Observe staged/late locals, '
                'full actuals, guards and per-call counters. A known reset precedes recovery '
                'calls in surviving programs. Observer writes at 5/12 and noncoincident '
                'snapshots avoid races; only the module prints. No ref, variable indices, '
                'NBA, recursion or join_none; implicit global completion is outside the '
                'normal-case scope because the live counterpart waits beyond explicit finish.',
                source(row), reference(row), fourstate=row[2] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
