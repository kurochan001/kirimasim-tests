#!/usr/bin/env python3
"""Check gated clocking with a separate event queue and observable SV faults."""

import argparse
import datetime
import hashlib
import heapq
import json
from pathlib import Path
import sys
import tempfile

import run_verilator
import suite_results

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_clockiff as generator


def independent(row):
    width,_,_,skew,update,shape,timing=row
    w=int(width)
    stimuli={'1':[(1,0),(0,1),(0,1),(1,0)],
             '8':[(255,0),(0,255),(85,170),(170,85)],
             '33':[(0x1FFFFFFFF,0),(0,0x1FFFFFFFF),
                   (0xAAAAAAAA,0x155555555),(0x155555555,0xAAAAAAAA)]}[width]
    true={'scalar':'1','wide_low':'0'*32+'1','wide_high':'1'+'0'*32}[shape]
    false='0'*len(true)
    # Abstract relative order: raw edge, module write, sample, cb observer.
    # Reports are at later ticks, so no observation assumes a region race.
    events=[(0,0,'guard',true),(0,0,'data',0),(2,0,'edge',0),(4,5,'report','warm')]
    for phase,(before,incoming) in enumerate(stimuli):
        base=6+12*phase
        events += [(base,0,'data',before),
                   (base+(2 if timing=='before' else 8),0,'guard',true if phase%2 else false),
                   (base+4,0,'edge',incoming)]
        events += [(base+at,5,'report',f'p{phase}_{label}')
                   for at,label in [(3,'pre'),(6,'edge'),(9,'late')]]
    heapq.heapify(events)
    data=held=seen=raw=hits=0
    gate=false
    lines=[]
    while events:
        time,order,kind,value=heapq.heappop(events)
        if kind=='guard':gate=value
        elif kind=='data':data=value
        elif kind=='edge':
            raw+=1
            heapq.heappush(events,(time,1 if update=='blocking' else 2,'data',value))
            if '1' in gate:
                heapq.heappush(events,(time,3,'sample',data if skew=='step' else None))
        elif kind=='sample':
            held=data if value is None else value
            heapq.heappush(events,(time,4,'wake',0))
        elif kind=='wake':
            seen=held;hits+=1
        else:
            lines += [f'{value} gate={gate} raw={raw} hits={hits}',
                      f'data={data:0{w}b} cb={held:0{w}b} seen={seen:0{w}b}']
    return '\n'.join(lines)+'\n'


def source_for(row):
    path=ROOT/'tests/gen/ch14'/(generator.case_name(row)+'.sv')
    source=path.read_text();field=suite_results.header(path)['expected_stdout']
    return source.replace(':expected_stdout: '+field,
                          ':expected_stdout: @'+str((path.parent/field[1:]).resolve()))


def faults(directory,verilator):
    step=source_for(generator.MODEL.anchors[0])
    # Explicit reduction OR is an equivalent Boolean condition for these
    # known-vector controls. It avoids the fixed tool's internal build error
    # on the original vector iff expression; original rows remain unchanged.
    zero=source_for(generator.MODEL.anchors[1]).replace('iff enabled','iff (|enabled)')
    negative=source_for(generator.MODEL.anchors[2]).replace('iff enabled','iff (|enabled)')
    variants={
        'drop_iff':step.replace('posedge clk iff enabled','posedge clk'),
        'guard_becomes_clock_edge':zero.replace('posedge clk iff (|enabled)','posedge (clk && (|enabled))'),
        'wrong_input_skew':step.replace('input #1step data;','input #0 data;'),
        'low_bit_only_guard':zero.replace('posedge clk iff (|enabled)','posedge clk iff enabled[0]'),
        'missing_observer_capture':step.replace('      seen = cb.data;',"      seen = '0;"),
        'wrong_clocking_polarity':step.replace('clocking cb @(posedge clk iff enabled);',
                                               'clocking cb @(negedge clk iff enabled);'),
    }
    outcomes={}
    for name,source in {'step_control':step,'zero_control':zero,'negedge_control':negative,**variants}.items():
        assert name.endswith('_control') or source not in (step,zero,negative)
        path=directory/(name+'.sv');path.write_text(source)
        ok,reason=run_verilator.run(path,verilator,1)
        if name.endswith('_control'):
            assert ok,(name,reason)
        else:
            assert not ok and reason.startswith('output differs'),(name,ok,reason)
        outcomes[name]='pass' if ok else 'detected'
    return outcomes


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:outcomes=faults(Path(folder),args.verilator)
    sources=('generators/interaction_clockiff.py','tools/qualify_clockiff.py')
    tests=[ROOT/'tests/gen/ch14'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()]
    report={'model':generator.MODEL.name,'version':generator.MODEL.version,
            'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'independent_rows':len(generator.MODEL.rows()),'fault_injection':outcomes,
            'equivalent_auxiliary_controls':{'zero_control':'Vector iff is replaced by explicit reduction OR.',
                                            'negedge_control':'Vector iff is replaced by explicit reduction OR.'},
            'scope':'Auxiliary controls are not execution passes for the original vector-guard cases.',
            'simulator':suite_results.tool_version([args.verilator,'--version']),
            'sources_sha256':{s:hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
            'inputs_sha256':{p.relative_to(ROOT).as_posix():suite_results.input_digest(p) for p in tests}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(generator.MODEL.rows())} independent event-queue rows; three controls; six output-difference faults.')


if __name__=='__main__':
    main()
