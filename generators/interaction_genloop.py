"""Generated processes, private loop transfers and typed array observations."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_genloop'
VERSION = 1
CHAPTER = 27
MODEL = Model(
    'generated_process_loop_transfer',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('loop', ('for', 'while', 'repeat')), ('transfer', ('break', 'continue')),
     ('hit', ('head', 'middle', 'tail', 'miss')), ('form', ('if', 'case')),
     ('range', ('up', 'down')), ('count', ('1', '3'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('form', 'loop', 'transfer'),
            ('loop', 'transfer', 'hit'), ('count', 'hit', 'transfer'),
            ('range', 'loop', 'hit'), ('width', 'count', 'range'),
            ('value', 'transfer', 'hit')),
    anchors=(('1', 'bit', 'known', 'for', 'break', 'head', 'if', 'up', '1'),
             ('129', 'logic', 'z', 'repeat', 'continue', 'miss', 'case', 'down', '3'),
             ('65', 'logic', 'x', 'while', 'break', 'middle', 'if', 'down', '3'),
             ('33', 'bit', 'z', 'repeat', 'break', 'tail', 'case', 'up', '1'),
             ('32', 'logic', 'known', 'for', 'continue', 'tail', 'case', 'down', '3'),
             ('64', 'bit', 'known', 'while', 'continue', 'middle', 'if', 'up', '3')),
    constraints=('全行が合法で未対応による除外なし。二moduleインスタンスの各二生成要素が独立した'
                 'posedgeプロセス、局所型・配列・カウンタを持つ。分岐とgenvarで局所幅・配列範囲が変わる。'
                 'for/while/repeatは同じ論理位置順に走査し、最下位ビットの!==0でbreak/continueする。'
                 'while/repeatは分岐前に添字を進めるため、continueでも停止性を保つ。'
                 'head/middle/tailは奇数スコープで反転し、回復相では一つ回す。長さ一の位置の重複も保持する。'
                 '既知・既知またはX/Z・既知への回復の各相で二回起動し、その間に一スコープの入力と'
                 '別スコープのguardだけを変える。クロックを下げた後と待機中も保持を読む。'
                 '符号付き演算・foreach・動的配列・NBA・名前付きdisable・並行writer・可変階層添字は対象外。'
                 'X/Z入力ではbit格納への変換でもfourstateを指定する。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_genloop_' + '_'.join(row)


def layout(row: Row, slot: int):
    instance, lane = divmod(slot, 2)
    kind = (instance + lane) % 2
    step = 1 if row[7] == 'up' else -1
    left = lane + kind + (-2 if step == 1 else 3)
    return int(row[0]) + lane + kind, left, left + step * (int(row[8])-1), step


def prefix(slot):
    return ('a' if slot < 2 else 'b') + f'.g[{slot % 2}].slot'


def stimulus(row: Row, phase: int, slot: int):
    w, _, _, _ = layout(row, slot); n = int(row[8])
    hit = None if row[5] == 'miss' else {'head': 0, 'middle': n//2, 'tail': n-1}[row[5]]
    if hit is not None:
        if slot % 2: hit = n-1-hit
        if phase == 2: hit = (hit+1) % n
    words = []
    for ordinal in range(n):
        bits = list((('10' if (slot+ordinal+phase)%2 == 0 else '01') * w)[:w])
        bits[-1] = str(int(ordinal == hit))
        if phase == 1 and row[2] != 'known':
            if ordinal == hit: bits[-1] = row[2]
            if w > 1: bits[w-1-w//2] = row[2]
        words.append(''.join(bits))
    return words


def flipped(bits):
    return bits[:-1].replace('z','x') + ('1' if bits[-1] == '0' else '0' if bits[-1] == '1' else 'x')


def reference(row: Row) -> str:
    n, states = int(row[8]), []
    for slot in range(4):
        w, left, _, _ = layout(row, slot)
        states.append({'data': [], 'guard': ('10' * w)[:w], 'checksum': '0' * w,
                       'runs': 0, 'done': 0, 'visited': 0, 'kept': 0, 'hits': 0,
                       'weight': 0, 'kept_weight': 0, 'i': 0, 'ordinal': 0, 'at': 0})
    output = []
    def snapshot(phase, label, tick):
        output.append(f'h p={phase} step={label} t={tick}')
        for slot, state in enumerate(states):
            w, left, right, _ = layout(row, slot)
            output.append(f'v id={slot} bits={w} left={left} right={right} guard={state["guard"]} '
                          f'checksum={state["checksum"]} ' + ' '.join(f'{k}={state[k]}' for k in
                          ('runs','done','visited','kept','hits','weight','kept_weight','i','ordinal','at')))
            output.append('d id=' + str(slot) + ' ' + ' '.join(f'{i}={bits}' for i,bits in enumerate(state['data'])))
    def edge():
        for slot, state in enumerate(states):
            w, left, _, step = layout(row, slot)
            state.update(checksum='0'*w, visited=0, kept=0, hits=0, weight=0,
                         kept_weight=0, i=0, ordinal=-1, at=left)
            state['runs'] += 1; state['done'] += 1
            for ordinal, bits in enumerate(state['data']):
                state['ordinal'], state['at'] = ordinal, left + step * ordinal
                state['visited'] += 1; state['weight'] += ordinal+1
                state['i'] = ordinal if row[3] == 'for' else ordinal+1
                if bits[-1] != '0':
                    state['hits'] += 1
                    if row[4] == 'break': break
                else:
                    state['kept'] += 1; state['kept_weight'] += ordinal+1
                    state['checksum'] = ''.join(str(int(a)^int(b)) if a in '01' and b in '01' else 'x'
                                                for a,b in zip(state['checksum'],bits))
            else: state['i'] = n
    for phase in range(3):
        for slot, state in enumerate(states):
            w = layout(row, slot)[0]
            state['data'] = [assigned(bits,w,row[1]) for bits in stimulus(row,phase,slot)]
        snapshot(phase,'before',phase*5)
        edge(); snapshot(phase,'after',phase*5+2)
        states[0]['data'][0] = flipped(states[0]['data'][0])
        states[3]['guard'] = flipped(states[3]['guard'])
        snapshot(phase,'refresh',phase*5+2)
        edge(); snapshot(phase,'again',phase*5+4)
        snapshot(phase,'idle',phase*5+5)
    return '\n'.join(output)+'\n'


COUNTERS = ('runs','done','visited','kept','hits','weight','kept_weight','i','ordinal','at')


def body(row: Row, kind: int):
    left = 'lane + KIND - 2' if row[7] == 'up' else 'lane + KIND + 3'
    lines = [f'      localparam int KIND = {kind};', '      localparam int W = BASE + lane + KIND;',
             f'      localparam int N = {row[8]};', f'      localparam int LEFT = {left};',
             f'      localparam int STEP = {1 if row[7] == "up" else -1};',
             '      localparam int RIGHT = LEFT + STEP * (N-1);',
             f'      typedef {row[1]} [W-1:0] word_t;', '      word_t data[LEFT:RIGHT], guard, checksum;',
             '      int ' + ', '.join(COUNTERS) + ';', '      always @(posedge clk) begin',
             '        runs++;', '        visited=0; kept=0; hits=0; weight=0; kept_weight=0;',
             "        checksum='0; i=0; ordinal=-1; at=LEFT;"]
    if row[3] == 'for': lines += ['        for (i=0; i < N; i++) begin']
    else: lines += ['        while (i < N) begin' if row[3] == 'while' else '        repeat (N) begin']
    lines += ['          ordinal=i;']
    if row[3] != 'for': lines += ['          i++;']
    lines += ['          at=LEFT + STEP * ordinal;', '          visited++; weight += ordinal+1;',
              "          if (data[at][0] !== 1'b0) begin", '            hits++;',
              f'            {row[4]};', '          end', '          kept++; kept_weight += ordinal+1;',
              '          checksum = checksum ^ data[at];', '        end', '        done++;', '      end']
    return lines


def source(row: Row) -> str:
    lines = ['`timescale 1ns/1ns',
             'module loop_worker #(parameter int BASE=1, SEL=0)(input logic clk);',
             '  for (genvar lane=0; lane<2; lane++) begin:g']
    if row[6] == 'if': lines += ['    if ((SEL+lane)%2==0) begin:slot', *body(row,0),
                               '    end else begin:slot', *body(row,1), '    end']
    else: lines += ['    case ((SEL+lane)%2)', '      0: begin:slot', *body(row,0), '      end',
                   '      default: begin:slot', *body(row,1), '      end', '    endcase']
    lines += ['  end', 'endmodule', f'module {case_name(row)};', '  bit clk=0;',
              f'  loop_worker #(.BASE({row[0]}),.SEL(0)) a(clk);',
              f'  loop_worker #(.BASE({row[0]}),.SEL(1)) b(clk);', '  initial begin']
    for slot in range(4):
        p = prefix(slot); w = layout(row,slot)[0]
        lines += [f'    {p}.{k}=0;' for k in COUNTERS]
        lines += [f"    {p}.checksum='0;", f'    {p}.guard={literal(("10"*w)[:w])};']
    def snapshot(phase,label):
        nonlocal lines
        lines.append(f'    $display("h p={phase} step={label} t=%0d", $time);')
        for slot in range(4):
            p=prefix(slot);w,left,_,step=layout(row,slot)
            fmt=' '.join(f'{k}=%0d' for k in COUNTERS)
            lines += [f'    $write("v id={slot} bits=%0d left=%0d right=%0d guard=%b checksum=%b ",',
                      f'      $bits({p}.checksum), $left({p}.data), $right({p}.data),',
                      f'      {p}.guard, {p}.checksum);']
            for group in (COUNTERS[:5],COUNTERS[5:]):
                fmt=' '.join(f'{k}=%0d' for k in group)
                operation='write' if group==COUNTERS[:5] else 'display'
                if operation=='write':fmt+=' '
                lines.append(f'    ${operation}("{fmt}",')
                args=[p+'.'+k for k in group]
                for at in range(0,len(args),3):
                    lines.append('      '+', '.join(args[at:at+3])+(');' if at+3>=len(args) else ','))
            lines += [f'    $display("d id={slot} '+' '.join(f'{i}=%b' for i in range(int(row[8])))+'",',
                      '      '+', '.join(f'{p}.data[{left+step*i}]' for i in range(int(row[8])))+');']
    for phase in range(3):
        for slot in range(4):
            p=prefix(slot);_,left,_,step=layout(row,slot)
            lines += [f'    {p}.data[{left+step*i}]={literal(bits)};' for i,bits in enumerate(stimulus(row,phase,slot))]
        snapshot(phase,'before');lines += ['    #1 clk=1;', '    #1;'];snapshot(phase,'after')
        p=prefix(0);left=layout(row,0)[1]
        lines += ['    clk=0;', f"    {p}.data[{left}]={p}.data[{left}] ^ 1'b1;",
                  f"    {prefix(3)}.guard={prefix(3)}.guard ^ 1'b1;"]
        snapshot(phase,'refresh');lines += ['    #1 clk=1;', '    #1;'];snapshot(phase,'again')
        lines += ['    clk=0;', '    #1;'];snapshot(phase,'idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row),
                'Generated edge processes keep loop transfers, array observations and retained state local',
                '27.4 27.5 9.2.2.1 9.4.2 12.7.1 12.7.2 12.7.4 12.8 7.4.2 11.4.6 6.11.2',
                'Two parameterized workers each generate two private edge processes. Branch and '
                'genvar constants determine word widths and ascending/descending indexed arrays. '
                'Scan in logical position order with for, while or repeat. Compare break and '
                'continue on a known or X/Z low-bit marker, recording visited/kept counts and '
                'weights, checksum, loop indices and run/completion counts. Observe every scope '
                'before and after each edge, after changing only one input and another guard, '
                'and during idle. Known, stress and known-recovery phases each rearm twice. '
                'Each process owns its state; no NBA, concurrent writers, dynamic hierarchy '
                'indices, recursion or dynamic containers are used.',
                source(row),reference(row),fourstate=row[2]!='known',
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
