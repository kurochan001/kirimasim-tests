"""Disable scopes, deferred report queues and input-argument capture."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_deferdis'
VERSION = 1
CHAPTER = 16
MODEL = Model(
    'deferred_disable_reports',
    (('scope', ('none', 'assertion', 'outer', 'inner', 'task')),
     ('directive', ('assert', 'assume', 'cover')), ('cancel', ('odd', 'even')),
     ('predicate', ('alternating', 'inverse', 'positive')), ('sibling', ('before', 'after')),
     ('argument', ('variable', 'function')), ('payload', ('stable', 'change'))),
    lambda row: True,
    groups=(('scope', 'directive', 'sibling'), ('scope', 'cancel', 'predicate'),
            ('directive', 'argument', 'payload'), ('scope', 'argument', 'payload')),
    anchors=(('none','assert','odd','alternating','before','function','stable'),
             ('inner','assume','even','inverse','after','variable','stable'),
             ('task','cover','odd','positive','before','function','stable'),
             ('none','cover','even','inverse','after','variable','stable'),
             ('task','assert','even','alternating','after','function','stable'),
             ('inner','cover','odd','alternating','before','function','stable'),
             ('assertion','assert','odd','inverse','before','function','change'),
             ('outer','assume','even','positive','after','variable','stable'),
             ('none','assert','even','positive','before','function','change'),
             ('outer','cover','odd','alternating','before','function','stable')),
    constraints=('全720行が合法。observed deferredのassert/assume/cover #0を使い、'
                 'workerの各10 tickと、別プロセスの対照を2 tick後に評価し、さらに1 tick後に観測する。'
                 'ラベル指定は対象だけ、最外workerスコープはそのプロセスの全未成熟報告を取り消す。'
                 '内側ブロック/taskのdisableでは報告を消さない。'
                 '3回の処理で奇数回/偶数回にdisableし、通常の制御移動と既に報告済みの履歴を別に観測する。'
                 '入力引数は登録時に値を取得し、関数引数の副作用は報告が取り消されても残る。'
                 '報告関数内の生値はReactiveで読む。noneのcancel因子は同じ結果となる対照。'
                 'final/Postponed、always_comb、再開によるflush、同時刻の複数起動、task出力/ref引数、'
                 'NBA、assertion control、X/Zは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:return 'test_gen_cross_deferdis_' + '_'.join(row)


def predicate(row: Row, phase: int) -> bool:
    return bool(phase%2) if row[3]=='alternating' else not phase%2 if row[3]=='inverse' else True


def reference(row: Row) -> str:
    scope,directive,cancel,_,order,argument,payload = row
    passed=[0]*3;failed=[0]*3;captured=[0]*3;live=[0]*3;evals=[0]*3;last=[-1]*3
    target_tail=worker_tail=0;lines=[]
    for phase in range(1,4):
        data=phase*10+1;guard=phase*10+2;good=predicate(row,phase)
        active=scope!='none' and phase%2==int(cancel=='odd')
        pending=[]
        def enqueue(item,result,value):
            if directive=='cover' and not result:return
            if argument=='function':evals[item]+=1
            pending.append((item,result,value))
        if order=='before':enqueue(1,not good,data)
        enqueue(0,good,data)
        if payload=='change':data+=100
        if not active or scope not in ('outer','inner','task'):target_tail+=1
        if not(active and scope=='outer'):
            if order=='after':enqueue(1,not good,data)
            worker_tail+=1
        if active and scope=='outer':pending=[]
        if active and scope=='assertion':pending=[r for r in pending if r[0]!=0]
        for item,result,value in pending:
            (passed if result else failed)[item]+=1
            captured[item]+=value;live[item]+=data;last[item]=phase*10
        pending=[];enqueue(2,not good,guard)
        for item,result,value in pending:
            (passed if result else failed)[item]+=1
            captured[item]+=value;live[item]+=guard;last[item]=phase*10+2
        lines.append(f'phase={phase} time={phase*10+3} target_tail={target_tail} '
                     f'worker_tail={worker_tail} wdata={data} gdata={guard}')
        for item in range(3):
            lines.append(f'item={item} pass={passed[item]} fail={failed[item]} '
                         f'captured={captured[item]} live={live[item]} eval={evals[item]} last={last[item]}')
    return '\n'.join(lines)+'\n'


def assertion(row: Row, label: str, item: int, expression: str, indent: str) -> list[str]:
    directive=row[1];phase='gphase' if item==2 else 'wphase';data='gdata' if item==2 else 'wdata'
    actual=f'capture({item}, {data})' if row[5]=='function' else data
    call=lambda bit:f"report({item}, {phase}, 1'b{bit}, {actual});"
    lines=[f'{indent}{label}: {directive} #0 ({expression}) '+call(1)]
    if directive!='cover':lines += [indent+'  else '+call(0)]
    return lines


def target(row: Row, indent: str) -> list[str]:
    lines=assertion(row,'target_chk',0,'w_pred',indent)
    if row[6]=='change':lines += [indent+'wdata += 100;']
    destination={'assertion':'target_chk','outer':'worker','inner':'inner','task':'target_op'}.get(row[0])
    if destination:lines += [indent+f'if (cancel(wphase)) disable {destination};']
    return lines+[indent+'target_tail++;']


def make_case(row: Row) -> Case:
    scope,_,cancel,kind,order,_,_=row
    condition={'alternating':'(phase % 2) == 1','inverse':'(phase % 2) == 0','positive':"1'b1"}[kind]
    lines=['`timescale 1ns/1ns',f'module {case_name(row)};',
           "  int passed[3] = '{0, 0, 0}, failed[3] = '{0, 0, 0};",
           "  int captured_sum[3] = '{0, 0, 0}, live_sum[3] = '{0, 0, 0};",
           "  int evaluations[3] = '{0, 0, 0}, last[3] = '{-1, -1, -1};",
           '  int target_tail = 0, worker_tail = 0;', '  int wphase = 0, gphase = 0, wdata = 0, gdata = 0;',
           '  bit w_pred = 0, g_pred = 0;',
           '  function automatic bit predicate(input int phase);',f'    return {condition};','  endfunction',
           '  function automatic bit cancel(input int phase);',
           f'    return (phase % 2) == {int(cancel=="odd")};','  endfunction',
           '  function automatic int capture(input int item, input int value);',
           '    evaluations[item]++;', '    return value;', '  endfunction',
           '  function automatic void report(input int item, input int phase,',
           '                                 input bit success, input int value);',
           '    if (success) passed[item]++; else failed[item]++;',
           '    captured_sum[item] += value;', '    live_sum[item] += (item == 2 ? gdata : wdata);',
           '    last[item] = $time;', '  endfunction']
    if scope=='task':lines += ['  task automatic target_op;',*target(row,'    '),'  endtask']
    lines += ['  always begin : worker', '    #10;', '    wphase++;',
              '    w_pred = predicate(wphase);', '    wdata = wphase * 10 + 1;']
    sibling=assertion(row,'sibling_chk',1,'!w_pred','    ')
    if order=='before':lines += sibling
    if scope=='task':lines += ['    target_op();']
    else:lines += ['    begin : inner',*target(row,'      '),'    end']
    if order=='after':lines += sibling
    lines += ['    worker_tail++;', '  end', '  initial begin : guard', '    #2;', '    forever begin',
              '      #10;', '      gphase++;', '      g_pred = !predicate(gphase);',
              '      gdata = gphase * 10 + 2;',*assertion(row,'guard_chk',2,'g_pred','      '),
              '    end', '  end', '  task automatic show(input int phase);',
              '    $display("phase=%0d time=%0d target_tail=%0d worker_tail=%0d wdata=%0d gdata=%0d",',
              '             phase, $time, target_tail, worker_tail, wdata, gdata);',
              '    for (int item = 0; item < 3; item++)',
              '      $display("item=%0d pass=%0d fail=%0d captured=%0d live=%0d eval=%0d last=%0d",',
              '               item, passed[item], failed[item], captured_sum[item],',
              '               live_sum[item], evaluations[item], last[item]);', '  endtask',
              '  initial begin', '    #13; show(1);', '    #10; show(2);', '    #10; show(3);',
              '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Disable scopes distinguish deferred report cancellation from captured inputs and live actions',
                '16.4.4 16.4 16.4.1 16.4.2 16.3 9.6.2',
                'Observed deferred assert, assume or cover directives queue reports '
                'in one worker process. A label cancels only the target; disabling '
                'the outermost worker scope flushes its pending reports. Disabling '
                'an inner block or called task changes control flow but does not '
                'flush reports. Odd/even cancellation across three activations '
                'retains already reported history. A sibling is encountered before '
                'or after the target; outer disable may skip the later sibling. '
                'A separate offset process is an uncancelled control. Input values '
                'and optional capture-function side effects occur on registration, '
                'even if a report is later cancelled. Mutate worker payload after '
                'target registration to distinguish captured input from Reactive '
                'live data read in the report function. Report counts, captured/live '
                'sums, evaluation counts, last report time and control-flow tails '
                'at later ticks. Failed cover has no action or input evaluation. '
                'Final/Postponed assertions, always_comb, resume flush points, '
                'same-tick repeated activations, task outputs/ref arguments, NBA, '
                'assertion controls and X/Z are outside scope. Fixed Verilator '
                '5.052 matches 13 of the 31 selected cases; 18 differ on '
                'label/outer cancellation or live action data. These counts '
                'describe only the selected suite. See the interaction guide '
                'for saved runs and qualification limits.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{key}={value}' for key,value in MODEL.values(row).items())})


def cases() -> list[Case]:return [make_case(row) for row in MODEL.select()]
