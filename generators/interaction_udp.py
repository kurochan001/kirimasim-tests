"""Combinational UDP array terminals and driven-net strength resolution."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_udp'
VERSION = 1
CHAPTER = 29
DRIVES = {'default': (6, 6), 'pull': (5, 5), 'strong_weak': (6, 3), 'weak_strong': (3, 6)}
LEVELS = {'weak': 3, 'pull': 5, 'strong': 6}
STRENGTH = {'default': '', 'pull': '(pull0, pull1)',
            'strong_weak': '(strong0, weak1)', 'weak_strong': '(weak0, strong1)'}

MODEL = Model(
    'udp_array_strength',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('udp', ('andnot', 'ornot')),
     ('drive', tuple(DRIVES)), ('contender', tuple(LEVELS)),
     ('array_order', ('down', 'up')), ('port_order', ('down', 'up')),
     ('input_mode', ('scalar', 'vector'))),
    lambda row: True,
    groups=(('udp', 'drive', 'contender'), ('width', 'input_mode', 'port_order'),
            ('array_order', 'port_order', 'input_mode'), ('width', 'udp', 'input_mode')),
    anchors=(('1', 'andnot', 'default', 'strong', 'down', 'down', 'scalar'),
             ('129', 'ornot', 'weak_strong', 'pull', 'up', 'up', 'vector'),
             ('65', 'andnot', 'strong_weak', 'pull', 'down', 'up', 'vector'),
             ('33', 'ornot', 'pull', 'strong', 'up', 'down', 'scalar'),
             ('32', 'andnot', 'pull', 'weak', 'up', 'up', 'scalar'),
             ('64', 'ornot', 'default', 'weak', 'down', 'down', 'vector')),
    constraints=('全1152行が合法。組合せUDPのみ。両配列は同じ強度と入力を持ち、一方だけ別ドライバと競合する。'
                 '既知入力の識別刺激では競合値0/1/Zをすべて観測する。4状態の全入力対では競合側をZに解放する。'
                 '逐次UDP・遅延・%v・名前付き配列要素の階層参照・個別要素への設定は対象外。未対応による除外なし',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_udp_' + '_'.join(row)


def epochs(row: Row):
    width, udp, drive, contender, array_order, port_order, input_mode = row
    w = int(width)
    for phase in range(10):
        a = ''.join(str(((bit+1) >> phase) & 1) if phase < 8 else str(phase-8)
                    for bit in range(w-1, -1, -1))
        b = (''.join('1' if v == '0' else '0' for v in a) if input_mode == 'vector'
             else '1' if udp == 'ornot' else '0')
        for rival in '01z':
            yield f'k{phase}_{rival}', a, b, rival
    for phase in range(16):
        a = ''.join('01xz'[(phase+bit)%4] for bit in range(w-1, -1, -1))
        b = (''.join('01xz'[(phase//4+bit//4)%4] for bit in range(w-1, -1, -1))
             if input_mode == 'vector' else '01xz'[phase//4])
        yield f't{phase}', a, b, 'z'


def logic(udp: str, a: str, b: str) -> str:
    if udp == 'andnot':
        return '0' if a == '0' or b == '1' else '1' if a == '1' and b == '0' else 'x'
    return '1' if a == '1' or b == '0' else '0' if a == '0' and b == '1' else 'x'


def resolved(value: str, rival: str, drive: str, contender: str) -> str:
    if rival == 'z':
        return value
    assert value in '01', 'unknown UDP output is observed only with contender released'
    if value == rival:
        return value
    own, other = DRIVES[drive][int(value)], LEVELS[contender]
    return value if own > other else rival if own < other else 'x'


def reference(row: Row) -> str:
    lines = []
    for label, a, b, rival in epochs(row):
        other = b if row[6] == 'vector' else b*int(row[0])
        solo = ''.join(logic(row[1], x, y) for x, y in zip(a, other))
        net = ''.join(resolved(v, rival, row[2], row[3]) for v in solo)
        lines += [f'{label} a={a} b={b} rival={rival}',
                  f'{label} solo={solo} net={net} sample={solo[-1]}']
    return '\n'.join(lines)+'\n'


def assign_bits(name: str, bits: str) -> list[str]:
    if len(bits) <= 64:
        return [f"    {name} = {len(bits)}'b{bits};"]
    parts = [bits[i:i+64] for i in range(0, len(bits), 64)]
    return [f'    {name} = {{'] + [f"      {len(part)}'b{part}" + (',' if i+1 < len(parts) else '')
                                  for i, part in enumerate(parts)] + ['    };']


def make_case(row: Row) -> Case:
    width, udp, drive, contender, array_order, port_order, input_mode = row
    w, name = int(width), case_name(row)
    arange = f'[{w+2}:3]' if array_order == 'down' else f'[3:{w+2}]'
    out = f'[{w-1}:0]' if port_order == 'down' else f'[0:{w-1}]'
    bdecl = f'[0:{w-1}] ' if input_mode == 'vector' else ''
    bsample = f'b[{w-1}]' if input_mode == 'vector' else 'b'
    strength = STRENGTH[drive]
    # Both tables distinguish A from B and intentionally leave unknown rows unmatched.
    table = ('    0 ? : 0;\n    ? 1 : 0;\n    1 0 : 1;' if udp == 'andnot' else
             '    1 ? : 1;\n    ? 0 : 1;\n    0 1 : 0;')
    lines = ['`timescale 1ns/1ns', 'primitive cross_udp(y, a, b);',
             '  output y;', '  input a, b;', '  table', table, '  endtable', 'endprimitive',
             f'module {name};', f'  logic [{w-1}:0] a;', f'  logic {bdecl}b;',
             '  logic rival;', f'  wire {out} solo, net;', '  wire sample;',
             f'  cross_udp {strength} isolated{arange}(solo, a, b);',
             f'  cross_udp {strength} competing{arange}(net, a, b);',
             f'  cross_udp {strength} (sample, a[0], {bsample});',
             f'  assign ({contender}0, {contender}1) net = {{{w}{{rival}}}};', '  initial begin']
    for label, a, b, rival in epochs(row):
        lines += [*assign_bits('a', a), *assign_bits('b', b), f"    rival = 1'b{rival};", '    #1;',
                  f'    $display("{label} a=%b b=%b rival=%b", a, b, rival);',
                  f'    $display("{label} solo=%b net=%b sample=%b", solo, net, sample);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(name, 'UDP array terminal distribution and scalar broadcast retain drive strengths under contention',
                '29.8 29.3.2 29.4 29.2 28.3.6 28.12.1 28.12.2',
                'Two combinational UDP arrays receive the same vector A and scalar or vector B. '
                'B vectors have an ascending packed range, while A descends; output packed '
                'ranges and nonzero instance-array ranges vary independently. Only one array '
                'has a contending driver. An unnamed scalar UDP independently observes the '
                'rightmost input bit. Ten known bit-identity frames include all-zero and '
                'all-one controls, each with rival 0/1/Z. Both UDP functions act as identity '
                'on these frames, exposing strengths for both values at every bit. Sixteen '
                'further frames exercise every 0/1/X/Z input pair at every terminal, with '
                'the contender released to avoid mixing ambiguous-strength rules into this '
                'scope. Z inputs act as X and unspecified table rows produce X. Array '
                'port ordering is observed externally; individual named instance indices '
                'are not hierarchically inspected. No sequential table, delay or strength '
                'formatting is included. All cases require four-state observation.',
                '\n'.join(lines), reference(row), fourstate=True,
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
