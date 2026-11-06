"""Bounded event-consumer loops, same-slot readiness and loop transfers."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_eventflow'
VERSION = 1
CHAPTER = 15
MODEL = Model(
    'named_event_loop_transfer',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('waiting', ('edge', 'triggered')), ('arm', ('early', 'late')),
     ('trigger', ('blocking', 'nba')), ('flow', ('all', 'skip', 'stop')),
     ('pivot', ('first', 'middle', 'last'))),
    lambda row: row[6] != 'all' or row[7] == 'middle',
    groups=(('width', 'state', 'value'), ('waiting', 'arm', 'trigger'),
            ('flow', 'pivot', 'waiting'), ('flow', 'pivot', 'trigger'),
            ('arm', 'flow', 'pivot'), ('width', 'trigger', 'flow'),
            ('state', 'value', 'flow')),
    anchors=(('1', 'bit', 'known', 'edge', 'early', 'blocking', 'all', 'middle'),
             ('129', 'logic', 'z', 'triggered', 'late', 'nba', 'skip', 'first'),
             ('65', 'logic', 'x', 'edge', 'late', 'blocking', 'stop', 'middle'),
             ('33', 'bit', 'z', 'triggered', 'late', 'blocking', 'stop', 'first'),
             ('32', 'logic', 'known', 'edge', 'late', 'nba', 'skip', 'middle'),
             ('64', 'logic', 'known', 'edge', 'late', 'blocking', 'all', 'middle')),
    constraints=('全2592行のうちallで使わないpivotをmiddleに代表させ、576行を整理して2016合法行とする。'
                 '静的な二つの名前付きイベントを使い、イベント値のコピーや再結合は行わない。'
                 '対象は時刻2/8/14/20、対照は5/11/17/23で発火する。payloadは発火前に代入する。'
                 'lateでは最初の発火文の後にjoin_noneで待機者を作り、親の時間待ちで同じ時刻に開始する。'
                 '@待機は過去の発火を保持せず、triggered待機は同じタイムスロットの発火を検出する。'
                 '四回までのforループで一回だけcontinueまたはbreakし、再待機前には必ず1 tick進める。'
                 '各発火の2 tick後に観測し、子プロセスの再待機と同時刻の観測を避ける。'
                 '26で残る子を終了し、28で新しい待機者を作り、30/33の既知入力で再確認する。'
                 '全保存語・受信時刻・保持マスク・集計値・回数を保持し、bitへの変換前のX/Zも表示する。'
                 '未対応による除外なし。動的イベント・null・ref・遅延付き発火・同時発火・GCは対象外。',),
)

COUNTERS = ('armed', 'hits', 'kept', 'skipped', 'stopped', 'tails', 'done', 'weight', 'scheduled')
FRESH = ('fresh_armed', 'recovered', 'fresh_at')
SNAPSHOTS = {1:'before', 4:'a0', 7:'b0', 10:'a1', 13:'b1', 16:'a2', 19:'b2',
             22:'a3', 25:'b3', 27:'cancelled', 29:'rearmed', 32:'fresh_a', 35:'fresh_b', 37:'idle'}


def case_name(row: Row) -> str: return 'test_gen_cross_eventflow_' + '_'.join(row)


def payload(row, lane, ordinal):
    width = int(row[0]); bits = list((('10' if (lane+ordinal)%2 else '01')*width)[:width])
    for offset in range(min(3,width)): bits[-1-offset] = str(((ordinal+lane+1)>>offset)&1)
    if lane == 0 and ordinal in (1,2) and row[2] != 'known':
        bits[0] = row[2]; bits[-1] = row[2]
    return ''.join(bits)


def reference(row: Row) -> str:
    width, lines = int(row[0]), []; zero = '0'*width
    states = []
    for lane in range(2):
        state = dict.fromkeys((*COUNTERS, *FRESH),0)
        state.update(armed=int(lane==1 or row[4]=='early'),fresh_at=-1,
                     checksum=zero,fresh=zero,seen=[zero]*4,at=[-1]*4,valid=[0]*4)
        states.append(state)
    raw, live, cancelled = zero,[zero,zero],0
    pivot = {'first':0,'middle':1,'last':3}[row[7]]
    def consume(lane,tick):
        state=states[lane]
        if state['done'] or state['hits']==4:return
        index=state['hits'];state['hits']+=1;state['weight']+=index+1
        state['seen'][index]=live[lane];state['at'][index]=tick
        transfer=row[6] if lane==0 and index==pivot else 'all'
        if transfer=='skip':state['skipped']+=1
        elif transfer=='stop':state['stopped']+=1
        else:
            state['kept']+=1;state['tails']+=1;state['valid'][index]=1
            state['checksum']=assigned(''.join(str(int(a)^int(b)) if a in '01' and b in '01' else 'x'
                                               for a,b in zip(state['checksum'][1:]+'0',live[lane])),width,row[1])
        if transfer=='stop' or index==3:state['done']=1
        else:state['armed']+=1
    def snapshot(tick,label):
        lines.append(f'h step={label} t={tick} cancelled={cancelled}')
        lines.append(f'g raw={raw} a={live[0]} b={live[1]} a_trig=0 b_trig=0')
        for lane,state in enumerate(states):
            lines.append(f'c id={lane} '+' '.join(f'{key}={state[key]}' for key in COUNTERS))
            lines.append(f'v id={lane} checksum={state["checksum"]} fresh={state["fresh"]} '+
                         ' '.join(f'{key}={state[key]}' for key in FRESH))
            for index in range(4):
                lines.append(f'd id={lane} slot={index} seen={state["seen"][index]} at={state["at"][index]} kept={state["valid"][index]}')
    for tick in range(38):
        for lane,base in ((0,2),(1,5)):
            if tick in (base+6*i for i in range(4)):
                ordinal=(tick-base)//6;word=payload(row,lane,ordinal)
                if lane==0:raw=word
                live[lane]=assigned(word,width,row[1]);states[lane]['scheduled']=int(row[5]=='blocking')
                if lane==0 and tick==2 and row[4]=='late':states[0]['armed']=1
                missed=lane==0 and tick==2 and row[4]=='late' and row[3]=='edge' and row[5]=='blocking'
                if not missed:consume(lane,tick)
        if tick==26:cancelled=1
        if tick==28:
            for state in states:state['fresh_armed']=1
        if tick in (30,33):
            lane=int(tick==33);word=payload(row,lane,4)
            if lane==0:raw=word
            live[lane]=assigned(word,width,row[1]);states[lane]['scheduled']=int(row[5]=='blocking')
            states[lane].update(fresh=live[lane],recovered=1,fresh_at=tick)
        if tick in SNAPSHOTS:snapshot(tick,SNAPSHOTS[tick])
    return '\n'.join(lines)+'\n'


def waiter(row,lane,fresh=False):
    event=('go','other')[lane];data=('payload_a','payload_b')[lane]
    waiting=f'wait ({event}.triggered);' if lane==0 and row[3]=='triggered' else f'@({event});'
    if fresh:
        return ['      begin',f'        fresh_armed[{lane}]=1;',f'        {waiting}',
                f'        recovered[{lane}]++; fresh_at[{lane}]=$time; fresh[{lane}]={data};','      end']
    lines=['      begin','        for (int i=0; i<4; i++) begin',f'          armed[{lane}]++;',
           f'          {waiting}',f'          hits[{lane}]++; weight[{lane}]+=i+1;',
           f'          seen[{lane}][i]={data}; arrived[{lane}][i]=$time;']
    if lane==0 and row[6]!='all':
        pivot={'first':0,'middle':1,'last':3}[row[7]]
        lines += [f'          if (i=={pivot}) begin',f'            {"skipped" if row[6]=="skip" else "stopped"}[0]++;',
                  '            #1;',f'            {"continue" if row[6]=="skip" else "break"};','          end']
    lines += [f'          kept[{lane}]++; valid[{lane}][i]=1;',
              f'          checksum[{lane}]=(checksum[{lane}] << 1) ^ seen[{lane}][i];',
              f'          tails[{lane}]++;','          #1;','        end',f'        done[{lane}]=1;','      end']
    return lines


def source(row: Row) -> str:
    width=int(row[0]);lines=['`timescale 1ns/1ns',f'module {case_name(row)};',
        f'  typedef {row[1]} [{width-1}:0] word_t;',f"  logic [{width-1}:0] raw_a='0;",
        "  word_t payload_a='0, payload_b='0;",'  event go, other;',
        '  word_t checksum[2], fresh[2], seen[2][4];','  int arrived[2][4], valid[2][4];',
        '  int '+', '.join(k+'[2]' for k in COUNTERS[:4])+';',
        '  int '+', '.join(k+'[2]' for k in COUNTERS[4:])+';',
        '  int fresh_armed[2], recovered[2], fresh_at[2];','  int cancelled=0;','  initial begin']
    for lane in range(2):
        for key in (*COUNTERS,*FRESH):lines.append(f'    {key}[{lane}]={-1 if key=="fresh_at" else 0};')
        lines += [f"    checksum[{lane}]='0; fresh[{lane}]='0;"]
        for index in range(4):
            lines += [f"    seen[{lane}][{index}]='0; arrived[{lane}][{index}]=-1; valid[{lane}][{index}]=0;"]
    lines += ['    fork',*waiter(row,1)]
    if row[4]=='early':lines+=waiter(row,0)
    lines+=['    join_none']
    def snapshot(tick,label):
        nonlocal lines
        lines += [f'    $display("h step={label} t=%0d cancelled=%0d", $time, cancelled);',
                  '    $display("g raw=%b a=%b b=%b a_trig=%0d b_trig=%0d",',
                  '      raw_a, payload_a, payload_b, go.triggered, other.triggered);']
        for lane in range(2):
            for start in range(0,len(COUNTERS),3):
                group=COUNTERS[start:start+3];last=start+3>=len(COUNTERS)
                fmt=(f'c id={lane} ' if start==0 else '')+' '.join(k+'=%0d' for k in group)
                lines += [f'    ${"display" if last else "write"}("{fmt+("" if last else " ")}",',
                          '      '+', '.join(f'{k}[{lane}]' for k in group)+');']
            lines += [f'    $display("v id={lane} checksum=%b fresh=%b fresh_armed=%0d recovered=%0d fresh_at=%0d",',
                      f'      checksum[{lane}], fresh[{lane}], fresh_armed[{lane}],',
                      f'      recovered[{lane}], fresh_at[{lane}]);']
            for index in range(4):
                lines += [f'    $display("d id={lane} slot={index} seen=%b at=%0d kept=%0d",',
                          f'      seen[{lane}][{index}], arrived[{lane}][{index}], valid[{lane}][{index}]);']
    def pulse(lane,ordinal):
        nonlocal lines
        if lane==0:lines += [f'    raw_a={literal(payload(row,lane,ordinal))};','    payload_a=raw_a;']
        else:lines += [f'    payload_b={literal(payload(row,lane,ordinal))};']
        event=('go','other')[lane]
        lines += [f'    {"->" if row[5]=="blocking" else "->>"} {event};',f'    scheduled[{lane}]={event}.triggered;']
    pulses={2+6*i:(0,i) for i in range(4)}|{5+6*i:(1,i) for i in range(4)}|{30:(0,4),33:(1,4)}
    now=0
    for tick in sorted(set(SNAPSHOTS)|set(pulses)|{26,28}):
        lines.append(f'    #{tick-now};');now=tick
        if tick in pulses:pulse(*pulses[tick])
        if tick==2 and row[4]=='late':lines+=['    fork',*waiter(row,0),'    join_none']
        if tick==26:lines+=['    disable fork; cancelled=1;']
        if tick==28:lines+=['    fork',*waiter(row,0,True),*waiter(row,1,True),'    join_none']
        if tick in SNAPSHOTS:snapshot(tick,SNAPSHOTS[tick])
    return '\n'.join(lines+['    $finish;','  end','endmodule'])


def make_case(row: Row) -> Case:
    return Case(case_name(row),'Named-event loop transfers preserve delivery history and bounded recovery',
                '15.5.1 15.5.2 15.5.3 12.7.1 12.8 9.4.3 9.3.2 4.4.2.4 6.11.2',
                'Two independent static named events carry typed payloads at distinct ticks. '
                'A four-iteration consumer either keeps all deliveries, continues once or breaks '
                'at a selected delivery index. Compare early versus same-slot late registration, '
                'edge waits versus persistent triggered waits, and blocking versus NBA triggers. '
                'Late edge registration loses only the first blocking pulse; triggered waits '
                'can see it and NBA dispatch occurs after late registration. Every consumed '
                'iteration delays one tick before rearming or leaving. Module-only observations '
                'occur two ticks after pulses, avoiding races with rearming. Preserve every '
                'captured word/time, retention mask, checksum and counter. Cancel pending children '
                'before fresh one-shot waiters and known recovery inputs. Raw X/Z remains visible '
                'even with bit storage. No event copying/rebinding, null, ref, delayed triggers, '
                'simultaneous pulses or garbage collection is used.',
                source(row),reference(row),fourstate=row[2]!='known',
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:return [make_case(row) for row in MODEL.select()]
