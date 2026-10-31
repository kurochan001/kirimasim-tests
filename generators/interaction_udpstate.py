"""Generated sequential UDP initial states, clock isolation and input conversion."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_udpstate'
VERSION = 1
CHAPTER = 29
MODEL = Model(
    'generated_udp_state',
    (('width', ('1','32','33','64','65','129')), ('storage', ('bit','logic')),
     ('value', ('known','x','z')), ('edge', ('rise','fall')), ('offset', ('0','1','2')),
     ('form', ('if','case')), ('clocks', ('shared','masked'))),
    lambda row: True,
    groups=(('width','storage','value'), ('edge','clocks','form'),
            ('offset','form','clocks'), ('storage','value','clocks')),
    anchors=(('1','bit','known','rise','0','if','shared'),
             ('129','logic','z','fall','2','case','masked'),
             ('65','bit','x','rise','1','if','masked'),
             ('33','logic','x','fall','0','case','shared'),
             ('32','logic','known','rise','1','case','masked'),
             ('64','bit','z','fall','2','if','shared')),
    constraints=('全864行が合法。generateの各ビットで初期値0/1/初期指定なしを(i+offset)%3で選択し、'
                 '対照は一つずらした初期値を持つ別UDPとする。既知の0/1クロックのみで、データ更新とは1 ns離す。'
                 '先にtargetだけ、後でguardだけを駆動する。未知入力の前には全1を採取させ、最後に既知値へ回復する。'
                 '未知クロック・同時入力変化・逐次UDPの遅延・駆動強度・配列形式のプリミティブは対象外。未対応による除外なし',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_udpstate_' + '_'.join(row)


def identity(width: int, phase: int) -> str:
    return ''.join(str(((bit+1) >> phase)&1) if phase < 8 else str(phase-8)
                   for bit in range(width-1,-1,-1))


def actions(row: Row):
    w = int(row[0])

    def pair(label, raw):
        for stroke in (0,1):
            mask = tuple(row[6]=='shared' or bit%2==stroke for bit in range(w))
            yield f'{label}_{stroke}', raw, 'target', mask

    for phase in range(10):
        yield from pair(f'k{phase}',identity(w,phase))
    if row[2] != 'known':
        for phase in range(3):
            yield from pair(f'prime{phase}','1'*w)
            bits = list(identity(w,phase))
            for bit in {0,w-1,(w//2+phase)%w}:
                bits[w-1-bit] = row[2]
            yield from pair(f'u{phase}',''.join(bits))
    yield from pair('recover','1'*w)
    for phase in range(10):
        yield f'guard{phase}', identity(w,phase), 'guard', (False,)*w


def converted(row: Row, raw: str) -> str:
    return raw.translate(str.maketrans('xz','00')) if row[1]=='bit' else raw


def snapshot(label, raw, source, clock, gclock, q, guard):
    return f'{label} raw={raw} source={source} clock={clock} guard_clk={gclock} q={q} guard={guard}'


def reference(row: Row) -> str:
    w, offset = int(row[0]), int(row[4])
    idle, active = ('0','1') if row[3]=='rise' else ('1','0')
    codes = [(bit+offset)%3 for bit in range(w-1,-1,-1)]
    q, guard = ['01x'[code] for code in codes], ['01x'[(code+1)%3] for code in codes]
    lines = [snapshot('initial','0'*w,'0'*w,idle*w,idle,''.join(q),''.join(guard)),
             'initial codes='+''.join(str(code) for code in codes)]
    for label, raw, role, mask in actions(row):
        source = converted(row,raw)
        lines.append(snapshot(label+'_pre',raw,source,idle*w,idle,''.join(q),''.join(guard)))
        if role=='target':
            for index, bit in enumerate(source):
                if mask[w-1-index]:
                    q[index] = bit if bit in '01' else 'x'
            clock = ''.join(active if mask[bit] else idle for bit in range(w-1,-1,-1))
            gc = idle
        else:
            guard = ['1' if bit=='0' else '0' if bit=='1' else 'x' for bit in source]
            clock, gc = idle*w, active
        lines.append(snapshot(label+'_capture',raw,source,clock,gc,''.join(q),''.join(guard)))
        lines.append(snapshot(label+'_return',raw,source,idle*w,idle,''.join(q),''.join(guard)))
    return '\n'.join(lines)+'\n'


def assign_bits(name: str, bits: str) -> list[str]:
    if len(bits)<=64:
        return [f"    {name} = {len(bits)}'b{bits};"]
    parts = [bits[i:i+64] for i in range(0,len(bits),64)]
    return [f'    {name} = {{']+[f"      {len(p)}'b{p}"+(',' if i+1<len(parts) else '')
                               for i,p in enumerate(parts)]+['    };']


def primitives(row: Row) -> list[str]:
    edge, quiet = ('(01)','(?0)') if row[3]=='rise' else ('(10)','(?1)')
    lines=[]
    for kind in range(3):
        lines += [f'primitive seq{kind}(q, clk, d);','  output q;','  reg q;','  input clk, d;']
        if kind<2:
            lines += [f"  initial q = 1'b{kind};"]
        lines += ['  table',f'    {edge} 0 : ? : 0;',f'    {edge} 1 : ? : 1;',
                  f'    {quiet} ? : ? : -;','    ? * : ? : -;','  endtable','endprimitive']
    return lines


def branch(row: Row, kind: int) -> list[str]:
    clock = 'clk' if row[6]=='shared' else 'clocks[i]'
    return ['begin : route',f'  seq{kind} u(q[i], {clock}, source[i]);',
            f'  seq{(kind+1)%3} v(guard[i], guard_clk, guard_data[i]);','end']


def make_case(row: Row) -> Case:
    width, storage, value, edge, offset, form, clocks = row
    w, name = int(width),case_name(row)
    idle, active = ('0','1') if edge=='rise' else ('1','0')
    seen = f'{{{w}{{clk}}}}' if clocks=='shared' else 'clocks'
    lines = ['`timescale 1ns/1ns',*primitives(row),f'module {name};',f'  logic [{w-1}:0] raw;',
             f'  {storage} [{w-1}:0] source;',f'  logic [{w-1}:0] clocks;',
             '  logic clk, guard_clk;',f'  wire [{w-1}:0] q, guard, guard_data, seen_clock;',
             f'  wire [31:0] codes[0:{w-1}];','  assign guard_data = ~source;',
             f'  assign seen_clock = {seen};',f'  for (genvar i=0; i<{w}; i++) begin : g',
             f'    localparam int K = (i+{offset})%3;','    assign codes[i] = K;']
    if form=='if':
        for kind,cond in enumerate(('if (K==0)','else if (K==1)','else')):
            lines += ['    '+cond,*['      '+line for line in branch(row,kind)]]
    else:
        lines += ['    case (K)']
        for kind in range(3):
            lines += [f'      {kind}:',*['        '+line for line in branch(row,kind)]]
        lines += ['    endcase']
    lines += ['  end','  task automatic observe(input string label);',
              '    $display("%s raw=%b source=%b clock=%b guard_clk=%b q=%b guard=%b",',
              '             label, raw, source, seen_clock, guard_clk, q, guard);','  endtask',
              '  initial begin',f"    clk = 1'b{idle}; clocks = '{idle}; guard_clk = 1'b{idle};",
              "    raw = '0; source = raw;",'    #1;','    observe("initial");',
              '    $write("initial codes=");',f'    for (int i={w-1}; i>=0; i--) $write("%0d", codes[i]);',
              '    $display("");']
    for label,raw,role,mask in actions(row):
        lines += [*assign_bits('raw',raw),'    source = raw;','    #1;',f'    observe("{label}_pre");']
        if role=='target':
            bits = ''.join(active if mask[bit] else idle for bit in range(w-1,-1,-1))
            lines += [f"    clk = 1'b{active};",*assign_bits('clocks',bits)]
        else:
            lines += [f"    guard_clk = 1'b{active};"]
        lines += ['    #1;',f'    observe("{label}_capture");',
                  f"    clk = 1'b{idle}; clocks = '{idle}; guard_clk = 1'b{idle};",'    #1;',
                  f'    observe("{label}_return");']
    lines += ['    $finish;','  end','endmodule']
    return Case(name,'Generated sequential UDPs retain per-instance state across independent clocks and source conversion',
                '29.6 29.7 29.3.3 29.2 27.4 27.5 6.11.2',
                'Each generated bit selects initial 0, initial 1 or no UDP initial '
                'statement by (genvar+offset)%3. A second UDP starts in the next '
                'initial category and uses an independent guard clock with inverted '
                'source data. Target clocks first capture shared or alternating '
                'even/odd subsets; data-only changes and return edges must hold '
                'state. Ten known frames identify bits 1 through 129 including '
                'all-zero and all-one controls. X/Z cases prime all state to one '
                'before every unknown pattern. Bit or logic source conversion '
                'occurs before the UDP sees input data; Z at a UDP input behaves '
                'as X and an unmatched capture yields X. Recovery captures known '
                'ones. Ten final guard captures identify every guard bit while '
                'target inputs change but target state must hold. All clocks are '
                'known 0/1 and input changes settle for one ns before each edge. '
                'Unknown clocks, coincident input changes, UDP delay, strength '
                'and primitive-array instantiation are outside this model.',
                '\n'.join(lines),reference(row),
                fourstate=not(width=='1' and offset=='0' and value=='known'),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
