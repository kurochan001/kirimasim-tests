"""SDF path matching, annotation scope and conditional rise/fall propagation."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_sdfpath'
VERSION = 1
CHAPTER = 32
MODEL = Model(
    'sdf_conditional_paths',
    (('path', ('plain', 'cond', 'else')), ('mode', ('absolute', 'increment')),
     ('profile', ('balanced', 'rise', 'fall')), ('scope', ('cell', 'parent')),
     ('target', ('v', 'g')), ('first', ('high', 'low')),
     ('guard', ('same', 'opposite'))),
    lambda row: True,
    groups=(('path', 'mode', 'profile'), ('path', 'scope', 'target'),
            ('target', 'first', 'guard'), ('mode', 'scope', 'first')),
    anchors=(('plain', 'absolute', 'balanced', 'cell', 'v', 'high', 'same'),
             ('plain', 'absolute', 'rise', 'parent', 'g', 'low', 'opposite'),
             ('plain', 'absolute', 'fall', 'cell', 'g', 'high', 'opposite'),
             ('cond', 'absolute', 'rise', 'cell', 'v', 'low', 'same'),
             ('cond', 'increment', 'balanced', 'parent', 'g', 'high', 'opposite'),
             ('else', 'absolute', 'balanced', 'parent', 'v', 'low', 'opposite'),
             ('else', 'increment', 'fall', 'cell', 'g', 'high', 'same')),
    constraints=('全288行が合法。単一のSDFファイルでIOPATH/COND/CONDELSEを1回注釈する。'
                 'ABSOLUTEは置換し、INCREMENTは既定の立上り/立下り遅延へ加算する。'
                 '2インスタンスの片方だけを選び、もう片方と各インスタンスの別出力を対照にする。'
                 '条件変更は入力遷移の2 tick前に行う。全遅延は正の偶数で最大14、'
                 '入力遷移は20 tick間隔、観測は遷移後1/3/5/7/9/11/13/15 tickに置く。'
                 '短パルス、X/Z、edge-qualified path、条件式の同値変形、複数注釈、'
                 'min/typ/max、timescale変換、INTERCONNECT、TIMINGCHECKは対象外。'
                 '未対応による除外なし。',),
)
PROFILES = {'balanced': (4, 4), 'rise': (8, 2), 'fall': (2, 8)}
LANES = ('v_y', 'v_z', 'g_y', 'g_z')


def case_name(row: Row) -> str:
    return 'test_gen_cross_sdfpath_' + '_'.join(row)


def selector(row: Row, phase: int, instance: str) -> int:
    value = int(row[5] == 'high') ^ int(phase >= 2)
    return value ^ int(instance == 'g' and row[6] == 'opposite')


def delay(row: Row, phase: int, lane: str) -> int:
    path, mode, profile, _, target, _, _ = row
    edge = phase % 2
    if lane.endswith('z'):
        return (4, 6)[edge]
    condition = selector(row,phase,lane[0])
    base = (2, 4)[edge] if path == 'plain' or condition else (6, 2)[edge]
    selected = path == 'plain' or (condition == int(path == 'cond'))
    if lane[0] == target and selected:
        value = PROFILES[profile][edge]
        return base+value if mode == 'increment' else value
    return base


def reference(row: Row) -> str:
    lines = []
    for phase in range(4):
        start = 20*(phase+1)
        new = 1-phase%2
        for offset in range(1,16,2):
            tick = start+offset
            lines += [f'phase={phase} time={tick} vsel={selector(row,phase,"v")} '
                      f'gsel={selector(row,phase,"g")} a={new}']
            for lane in LANES:
                arrived = offset > delay(row,phase,lane)
                last = start+delay(row,phase,lane) if arrived else (
                    start-20+delay(row,phase-1,lane) if phase else -1)
                lines.append(f'phase={phase} lane={lane} value={new if arrived else 1-new} '
                             f'hits={phase+int(arrived)} last={last}')
    return '\n'.join(lines)+'\n'


def sdf_text(row: Row) -> str:
    path, mode, profile, scope, target, _, _ = row
    rise, fall = PROFILES[profile]
    entry = f'(IOPATH a y ({rise}) ({fall}))'
    if path == 'cond':
        entry = '(COND sel '+entry+')'
    elif path == 'else':
        entry = '(CONDELSE '+entry+')'
    instance = '' if scope == 'cell' else target
    return ('(DELAYFILE (SDFVERSION "3.0") (TIMESCALE 1ns)\n'
            '  (CELL (CELLTYPE "cross_sdf_cell") (INSTANCE '+instance+')\n'
            '    (DELAY ('+mode.upper()+'\n'
            '      '+entry+'\n'
            '))))\n')


def snapshot(phase: int) -> list[str]:
    lines = [f'    $display("phase={phase} time=%0d vsel=%0d gsel=%0d a=%0d",',
             '             $time, vsel, gsel, a);']
    for lane in LANES:
        lines += [f'    $display("phase={phase} lane={lane} value=%0d hits=%0d last=%0d",',
                  f'             {lane}, {lane}_hits, {lane}_last);']
    return lines


def make_case(row: Row) -> Case:
    path, _, _, scope, target, _, _ = row
    lines = ['`timescale 1ns/1ns',
             'module cross_sdf_cell(output y, output z, input a, input sel);',
             '  buf (y, a);', '  buf (z, a);', '  specify']
    if path == 'plain':
        lines += ['    (a => y) = (2, 4);']
    else:
        lines += ['    if (sel) (a => y) = (2, 4);',
                  '    '+('ifnone' if path == 'else' else 'if (!sel)')+' (a => y) = (6, 2);']
    lines += ['    (a => z) = (4, 6);', '  endspecify', 'endmodule',
              f'module {case_name(row)};', '  reg a = 0;',
              f'  reg vsel = {selector(row,0,"v")}, gsel = {selector(row,0,"g")};',
              '  wire v_y, v_z, g_y, g_z;', '  integer fd;',
              '  cross_sdf_cell v(v_y, v_z, a, vsel);',
              '  cross_sdf_cell g(g_y, g_z, a, gsel);']
    for lane in LANES:
        lines += [f'  integer {lane}_hits = 0, {lane}_last = -1;',
                  f'  always @({lane}) if ($time >= 20) begin',
                  f'    {lane}_hits++; {lane}_last = $time;', '  end']
    lines += ['  initial begin', '    fd = $fopen("cross_path.sdf", "w");']
    for line in sdf_text(row).splitlines():
        escaped = line.replace('"','\\"')
        lines += [f'    $fdisplay(fd, "{escaped}");']
    lines += ['    $fclose(fd);', '    #1;',
              '    $sdf_annotate("cross_path.sdf"'+(', '+target if scope == 'cell' else '')+');']
    now = 1
    for phase in range(4):
        start = 20*(phase+1)
        if phase == 2:
            lines += [f'    #{start-2-now};',
                      f'    vsel = {selector(row,phase,"v")}; gsel = {selector(row,phase,"g")};']
            now = start-2
        lines += [f'    #{start-now};', f'    a = {1-phase%2};']
        now = start
        for offset in range(1,16,2):
            lines += [f'    #{start+offset-now};', *snapshot(phase)]
            now = start+offset
    lines += ['    #1;', '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'SDF annotations select conditional paths and instances without changing sibling delays',
                '32.4.1 30.4.4 30.4.4.2 32.5 32.8 32.9',
                'Two buffered cells receive identical isolated data transitions. '
                'A single SDF entry selects one instance and its y path; z and '
                'the sibling cell remain controls. Plain IOPATH, COND sel and '
                'CONDELSE match the corresponding unconditional, conditional '
                'or ifnone path. ABSOLUTE replaces rise/fall values and '
                'INCREMENT adds to their specified defaults. The file uses '
                'a named child relative to the caller or an empty INSTANCE '
                'relative to an explicit cell scope. Both conditions are '
                'tested with a rise and fall each; the sibling uses the same '
                'or opposite select. Data changes are 20 ticks apart and '
                'select changes two ticks before the next rise. All delays '
                'are even and at most 14; odd-tick snapshots avoid races '
                'while capturing every output value, edge count and exact '
                'last-change time. Startup settles before observation. '
                'No short pulses, X/Z, edge-qualified paths, condition '
                'equivalence, repeated annotations, min/typ/max, timescale '
                'conversion, interconnect or timing-check annotation is used.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{key}={value}' for key,value in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
