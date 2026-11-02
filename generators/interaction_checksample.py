"""Static checker connections, declaration contexts and assertion sampling."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_checksample'
VERSION = 1
CHAPTER = 17
MODEL = Model(
    'checker_assertion_sampling',
    (('width', ('1', '8', '33')), ('home', ('module', 'interface')),
     ('connection', ('positional', 'named', 'wildcard')),
     ('timing', ('before', 'edge', 'after')), ('update', ('blocking', 'nba')),
     ('edge', ('posedge', 'negedge')), ('clocking', ('explicit', 'default')),
     ('predicate', ('nonzero', 'zero', 'parity'))),
    lambda row: True,
    groups=(('home', 'connection', 'clocking'), ('timing', 'update', 'edge'),
            ('width', 'predicate', 'timing'), ('home', 'timing', 'update')),
    anchors=(('1', 'module', 'positional', 'edge', 'nba', 'posedge', 'explicit', 'nonzero'),
             ('33', 'interface', 'named', 'before', 'blocking', 'negedge', 'default', 'zero'),
             ('8', 'interface', 'wildcard', 'after', 'nba', 'posedge', 'default', 'parity'),
             ('33', 'module', 'wildcard', 'edge', 'blocking', 'negedge', 'default', 'parity'),
             ('8', 'module', 'named', 'before', 'nba', 'negedge', 'explicit', 'nonzero'),
             ('1', 'interface', 'positional', 'after', 'blocking', 'posedge', 'explicit', 'zero')),
    constraints=('全1296行が合法。静的checkerをmodule/interfaceの2実体に配置し、'
                 '同じ実引数を別のmodule参照アサーションへ渡す。checker出力引数だけで観測し、'
                 'checker内部への階層参照は行わない。2クロックは各周期の時刻8/12、'
                 'データ更新は各クロックの2 tick前/同時刻/2 tick後、観測は時刻16に分離する。'
                 '既知値の6周期と相補の別実体を使う。サンプルはPreponed、actionはReactiveで比較する。'
                 'X/Z、手続き内checker、bind、checker手続き、free variable、出力NBA、'
                 'disable iff、複数サイクルproperty、履歴関数、programは対象外。'
                 '未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_checksample_' + '_'.join(row)


def phases(width: int, lane: int):
    mask = (1 << width)-1
    alternating = sum(1 << bit for bit in range(width) if bit % 2 == 0)
    values = ((0,mask),(mask,0),(1,1 << (width-1)),
              (1 << (width-1),1),(alternating,mask^alternating),(1,0))
    return [(a^mask,b^mask) if lane else (a,b) for a,b in values]


def predicate(value: int, kind: str) -> int:
    return int(value != 0) if kind == 'nonzero' else int(value == 0) if kind == 'zero' else value.bit_count()%2


def reference(row: Row) -> str:
    width = int(row[0]);counts = [[0,0],[0,0]];lines = []
    for phase in range(6):
        lines.append(f'phase={phase} time={phase*20+16}')
        for lane in (0,1):
            before,incoming = phases(width,lane)[phase]
            sampled = incoming if row[3] == 'before' else before
            live = before if row[3] == 'after' else incoming
            result = predicate(sampled,row[7])
            counts[lane][0 if result else 1] += 1
            for origin in ('checker','module'):
                lines.append(f'site{lane} {origin} pass={counts[lane][0]} fail={counts[lane][1]} '
                             f'pred={result} sampled={sampled:0{width}b} live={live:0{width}b} '
                             f'at={phase*20+8+4*lane}')
            lines.append(f'site{lane} final={incoming:0{width}b}')
    return '\n'.join(lines)+'\n'


def expression(kind: str) -> str:
    return {'nonzero':'(|data)','zero':"(data == '0)",'parity':'(^data)'}[kind]


def assertion(row: Row, checker: bool) -> list[str]:
    condition = expression(row[7])
    event = '' if checker and row[6] == 'default' else f'@({row[5]} clk) '
    lines = [f'  target_check: assert property ({event}{condition})']
    prefix = 'v_' if checker else ''
    for n,field in enumerate(('passed','failed')):
        lines += ['    begin' if not n else '    end else begin',
                  f'      {prefix}{field}++;', f'      {prefix}seen = $sampled(data);',
                  f'      {prefix}pred = $sampled({condition});',
                  f'      {prefix}live = data;', f'      {prefix}at = $time;']
    return lines+['    end']


def make_case(row: Row) -> Case:
    width,home,connection,timing,update,edge,clocking,_ = row
    w = int(width);inactive = int(edge == 'negedge')
    lines = ['`timescale 1ns/1ns', 'checker sample_checker(',
             f'  input logic clk, input logic [{w-1}:0] data,',
             '  output int passed, output int failed,',
             f'  output logic [{w-1}:0] seen, output logic [{w-1}:0] live,',
             '  output logic pred, output int at);',
             '  int v_passed = 0, v_failed = 0, v_at = -1;',
             f"  logic [{w-1}:0] v_seen = '0, v_live = '0;",'  logic v_pred = 0;']
    for field in ('passed','failed','seen','live','pred','at'):
        lines += [f'  assign {field} = v_{field};']
    if clocking == 'default':
        lines += [f'  default clocking cb @({edge} clk); endclocking']
    lines += assertion(row,True)+['endchecker',
              f'{home} sample_site;', f'  bit clk = {inactive};',
              f'  logic [{w-1}:0] data;', '  wire signed [31:0] passed, failed, at;',
              f'  wire [{w-1}:0] seen, live;', '  wire pred;']
    if connection == 'positional':
        lines += ['  sample_checker checked(clk, data, passed, failed, seen, live, pred, at);']
    elif connection == 'named':
        lines += ['  sample_checker checked(.clk(clk), .data(data), .passed(passed), .failed(failed),',
                  '                         .seen(seen), .live(live), .pred(pred), .at(at));']
    else:
        lines += ['  sample_checker checked(.*);']
    lines += [f'end{home}',
              f'module sample_reference(input logic clk, input logic [{w-1}:0] data);',
              '  int passed = 0, failed = 0, at = -1;',
              f"  logic [{w-1}:0] seen = '0, live = '0;",'  logic pred = 0;']
    lines += assertion(row,False)+['endmodule',f'module {case_name(row)};',
                                 '  sample_site p0(), p1();',
                                 '  sample_reference r0(p0.clk, p0.data), r1(p1.clk, p1.data);',
                                 '  initial begin']
    now = 0
    for phase in range(6):
        start = phase*20
        if start != now:lines += [f'    #{start-now};']
        now = start
        inputs = [phases(w,lane)[phase] for lane in (0,1)]
        for lane,(before,_) in enumerate(inputs):lines += [f"    p{lane}.data = {w}'h{before:x};"]
        events = {}
        for lane,(_,incoming) in enumerate(inputs):
            tick = start+8+4*lane
            offset = {'before':-2,'edge':0,'after':2}[timing]
            events.setdefault(tick+offset,[]).append(
                f"    p{lane}.data {'<=' if update == 'nba' else '='} {w}'h{incoming:x};")
            events.setdefault(tick,[]).append(f'    p{lane}.clk = {1-inactive};')
        for tick,commands in sorted(events.items()):
            lines += [f'    #{tick-now};',*commands];now = tick
        lines += [f'    #{start+16-now};',f'    $display("phase={phase} time=%0d", $time);'];now = start+16
        for lane in (0,1):
            for origin,prefix in (('checker',f'p{lane}'),('module',f'r{lane}')):
                lines += [f'    $display("site{lane} {origin} pass=%0d fail=%0d pred=%0d sampled=%b live=%b at=%0d",',
                          f'             {prefix}.passed, {prefix}.failed, {prefix}.pred,',
                          f'             {prefix}.seen, {prefix}.live, {prefix}.at);']
            lines += [f'    $display("site{lane} final=%b", p{lane}.data);']
        lines += ['    #2;',f'    p0.clk = {inactive}; p1.clk = {inactive};'];now = start+18
    lines += ['    #1;', '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Static checker assertions and module references share sampling across connections and homes',
                '17.7.3 17.2 17.3 17.7.1 16.5.1 16.9.3 16.14.1 14.12 10.4.1 10.4.2'+
                (' 25.3' if home == 'interface' else ''),
                'Two static checker instances use independent clock ticks, complementary '
                'known data and either module or interface containers. Positional, named '
                'or wildcard connections pass clocks, data and output arguments driven '
                'from initialized checker state. '
                'Checker variables are observed only through output connections, never '
                'hierarchical references into a checker. Separate module reference '
                'assertions receive the same actual clocks and data. Explicit or local '
                'default clocking governs checker assertions; module references always '
                'use explicit events. Both action branches record counts, sampled data, '
                'sampled predicates, live data and action time. Six periods include zeros, '
                'ones, single-bit values and complementary backgrounds. Blocking/NBA '
                'updates occur before, on or after the edge; the driver prints at a '
                'later tick after output propagation. All inputs are known. Procedural '
                'checker instances, bind, checker procedures, free variables, output '
                'NBA updates, disable conditions, temporal operators, history functions '
                'and programs are outside scope.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{key}={value}' for key,value in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
