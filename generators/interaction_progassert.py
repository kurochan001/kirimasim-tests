"""Program and module assertion attempts across sampling and implication."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_progassert'
VERSION = 1
CHAPTER = 24
MODEL = Model(
    'program_assertion_attempts',
    (('width', ('1', '8', '33')), ('property', ('plain', 'overlap', 'next')),
     ('timing', ('before', 'edge', 'after')), ('update', ('blocking', 'nba')),
     ('edge', ('posedge', 'negedge')), ('connection', ('positional', 'named', 'wildcard')),
     ('ticks', ('3', '5'))),
    lambda row: True,
    groups=(('width', 'property', 'timing'), ('property', 'ticks', 'edge'),
            ('connection', 'timing', 'update'), ('property', 'timing', 'update')),
    anchors=(('1', 'plain', 'edge', 'nba', 'posedge', 'positional', '3'),
             ('33', 'overlap', 'before', 'blocking', 'negedge', 'named', '5'),
             ('8', 'next', 'after', 'nba', 'posedge', 'wildcard', '5'),
             ('33', 'next', 'edge', 'blocking', 'negedge', 'positional', '3'),
             ('8', 'plain', 'before', 'nba', 'negedge', 'named', '5'),
             ('1', 'overlap', 'after', 'blocking', 'posedge', 'wildcard', '3')),
    constraints=('全648行が合法。programとmodule参照モデルの各2実体へ同じ入力を渡す。'
                 'programにinitialを置かず、外部からの階層参照も行わない。'
                 '各20 tick周期の時刻8/12をクロックとし、入力を2 tick前/同時刻/2 tick後に更新する。'
                 '単周期判定と同サイクル/次サイクル含意について、空虚な成功を含むpass/fail数と、'
                 'アクション時のサンプル値の総和を時刻16に照合する。'
                 '最後の次サイクル試行は未完了なら集計しない。'
                 'X/Z、disable iff、履歴関数、programの手続きと終了、clocking block、'
                 'checker、bind、複数クロックproperty、アクション制御は対象外。未対応による除外なし。',),
)
FIELDS = ('passed', 'failed', 'reqsum', 'acksum')


def case_name(row: Row) -> str:
    return 'test_gen_cross_progassert_' + '_'.join(row)


def stimulus(width: int, lane: int):
    mask = (1 << width)-1
    high = 1 << (width-1)
    # (old req, new req, old ack, new ack); two distinct instances.
    values = ((0,mask,mask,0), (mask,0,0,high), (high,mask,high,0),
              (0,high,mask,mask), (mask,0,0,mask))
    return [tuple(value^mask for value in phase) if lane else phase for phase in values]


def reference(row: Row) -> str:
    width,kind,timing,_,_,_,ticks = row
    state = [[0,0,0,0],[0,0,0,0]];pending = [False,False];lines = []
    for phase in range(int(ticks)):
        lines.append(f'phase={phase} time={phase*20+16}')
        for lane in (0,1):
            oldreq,newreq,oldack,newack = stimulus(int(width),lane)[phase]
            req,ack = (newreq,newack) if timing=='before' else (oldreq,oldack)
            outcomes = ([bool(ack)] if kind=='plain' else [not req or bool(ack)]
                        if kind=='overlap' else ([bool(ack)] if pending[lane] else [])+
                        ([True] if not req else []))
            pending[lane] = bool(req) if kind=='next' else False
            for good in outcomes:
                state[lane][0 if good else 1] += 1
                state[lane][2] += req;state[lane][3] += ack
            for origin in ('program','module'):
                passed,failed,reqsum,acksum = state[lane]
                lines.append(f'site{lane} {origin} pass={passed} fail={failed} '
                             f'reqsum={reqsum} acksum={acksum}')
    return '\n'.join(lines)+'\n'


def declaration(row: Row, home: str) -> list[str]:
    width,kind,_,_,edge,_,_ = row;w = int(width)
    expr = {'plain':'(|ack)', 'overlap':'(|req) |-> (|ack)',
            'next':'(|req) |=> (|ack)'}[kind]
    lines = [f'{home} assertion_{home}(',
             f'  input logic clk, input logic [{w-1}:0] req, ack,',
             '  output int passed, failed, output longint unsigned reqsum, acksum);',
             '  int v_passed = 0, v_failed = 0;',
             '  longint unsigned v_reqsum = 0, v_acksum = 0;']
    lines += [f'  assign {field} = v_{field};' for field in FIELDS]
    lines += [f'  target_check: assert property (@({edge} clk) {expr})',
              '    begin', '      v_passed++;',
              "      v_reqsum += 64'($sampled(req));", "      v_acksum += 64'($sampled(ack));",
              '    end else begin', '      v_failed++;',
              "      v_reqsum += 64'($sampled(req));", "      v_acksum += 64'($sampled(ack));",
              '    end',f'end{home}']
    return lines


def make_case(row: Row) -> Case:
    width,_,timing,update,edge,connection,ticks = row;w = int(width)
    inactive = int(edge=='negedge')
    lines = ['`timescale 1ns/1ns',*declaration(row,'program'),*declaration(row,'module'),
             'module assertion_site;', f'  logic clk = {inactive};',
             f'  logic [{w-1}:0] req, ack;', '  int passed, failed;',
             '  longint unsigned reqsum, acksum;']
    if connection=='positional':
        lines += ['  assertion_program checked(clk, req, ack, passed, failed, reqsum, acksum);']
    elif connection=='named':
        lines += ['  assertion_program checked(.clk(clk), .req(req), .ack(ack),',
                  '                            .passed(passed), .failed(failed),',
                  '                            .reqsum(reqsum), .acksum(acksum));']
    else:lines += ['  assertion_program checked(.*);']
    lines += ['endmodule',f'module {case_name(row)};', '  assertion_site p0(), p1();']
    for lane in (0,1):
        lines += [f'  int r{lane}_passed, r{lane}_failed;',
                  f'  longint unsigned r{lane}_reqsum, r{lane}_acksum;',
                  f'  assertion_module r{lane}(p{lane}.clk, p{lane}.req, p{lane}.ack,',
                  f'                      r{lane}_passed, r{lane}_failed, r{lane}_reqsum, r{lane}_acksum);']
    lines += ['  initial begin'];now = 0
    for phase in range(int(ticks)):
        start = phase*20
        if start!=now:lines += [f'    #{start-now};']
        now = start;events = {}
        for lane in (0,1):
            oldreq,newreq,oldack,newack = stimulus(w,lane)[phase]
            lines += [f"    p{lane}.req = {w}'h{oldreq:x}; p{lane}.ack = {w}'h{oldack:x};"]
            tick = start+8+4*lane
            offset = {'before':-2,'edge':0,'after':2}[timing]
            op = '<=' if update=='nba' else '='
            events.setdefault(tick+offset,[]).extend(
                [f"    p{lane}.{field} {op} {w}'h{value:x};"
                 for field,value in (('req',newreq),('ack',newack))])
            events.setdefault(tick,[]).append(f'    p{lane}.clk = {1-inactive};')
        for tick,commands in sorted(events.items()):
            lines += [f'    #{tick-now};',*commands];now = tick
        lines += [f'    #{start+16-now};',f'    $display("phase={phase} time=%0d", $time);'];now = start+16
        for lane in (0,1):
            for origin,prefix in (('program',f'p{lane}.'),('module',f'r{lane}_')):
                lines += [f'    $display("site{lane} {origin} pass=%0d fail=%0d reqsum=%0d acksum=%0d",',
                          f'             {prefix}passed, {prefix}failed, {prefix}reqsum, {prefix}acksum);']
        lines += ['    #2;',f'    p0.clk = {inactive}; p1.clk = {inactive};'];now = start+18
    lines += ['    #1;', '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Program and module assertions retain sampling and implication attempts across clock counts',
                '24.3 24.3.1 16.14.5 16.5.1 16.12.7 16.14.1 16.9.3 20.11 10.4.1 10.4.2',
                'Two program instances and two module references receive identical '
                'actual inputs per site, with complementary data and distinct clock '
                'ticks. No initial procedure exists in a program, and no external '
                'hierarchical reference enters it. Output connections expose '
                'initialized counters and sampled-value sums. A plain predicate, '
                'overlapping implication or nonoverlapping implication begins an '
                'attempt on each leading edge. Count vacuous successes as well as '
                'completed nonvacuous attempts; a final pending attempt is not '
                'counted before its consequent clock. Same-tick actions can execute '
                'in either order, so only commutative counts and 64-bit sums of '
                'sampled req/ack are observed. Both action branches sample at the '
                'completion tick, including delayed consequences. Known data changes '
                'before, on or after a clock via blocking or NBA assignment; '
                'assertions use Preponed samples, with output observations at a '
                'later tick. No X/Z, disable conditions, history functions, program '
                'procedures/termination, clocking blocks, checkers, bind, '
                'multiclock properties or assertion action controls are used.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{key}={value}' for key,value in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
