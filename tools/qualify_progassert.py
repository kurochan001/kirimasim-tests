#!/usr/bin/env python3
"""Independently interpret emitted program/module attempts and execute SV faults."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_progassert as generator

FIELDS = ('passed','failed','reqsum','acksum')
PORTS = ('clk','req','ack',*FIELDS)


def definition(part):
    event,expression = re.search(
        r'target_check: assert property \(@\((posedge|negedge) clk\) (.*)\)\n',part).groups()
    assert expression in ('(|ack)','!(|ack)','(|req) |-> (|ack)','(|req) |=> (|ack)')
    blocks = part.split('target_check:',1)[1].split('\n',1)[1].split('end else begin')
    assert len(blocks)==2
    actions = []
    for block in blocks:
        increments = re.findall(r'(v_\w+)\+\+;',block)
        sums = re.findall(r"(v_\w+) \+= 64'\((\$sampled\((?:req|ack)\)|req|ack)\);",block)
        assert len(increments)==1 and len(sums)==2
        actions.append((increments[0],sums))
    outputs = dict(re.findall(r'assign (\w+) = (v_\w+);',part))
    assert set(outputs)==set(FIELDS)
    return event,expression,actions,outputs


def interpret(source):
    width = int(re.search(r'input logic \[(\d+):0\] req, ack',source)[1])+1
    mask = (1 << width)-1
    definitions = {home:definition(re.search(
        home+r' assertion_'+home+r'\(.*?end'+home,source,re.S)[0])
        for home in ('program','module')}
    call = re.search(r'assertion_program checked\((.*?)\);',source,re.S)[1].strip()
    if call=='.*':bindings = dict(zip(PORTS,PORTS))
    elif call.startswith('.'):bindings = dict(re.findall(r'\.(\w+)\(([^)]+)\)',call))
    else:bindings = dict(zip(PORTS,(word.strip() for word in call.split(','))))
    assert set(bindings)==set(PORTS) and bindings['clk']=='clk'
    refs = {int(n):(int(clk),int(req),int(ack)) for n,clk,req,ack in re.findall(
        r'r([01])\(p([01])\.clk, p([01])\.req, p([01])\.ack,',source)}
    assert set(refs)=={0,1}
    inactive = int(re.search(r'logic clk = ([01]);',source)[1])
    clocks = [inactive,inactive];data = [{'req':0,'ack':0} for _ in range(2)]
    frames = {(lane,home):{'v_'+field:0 for field in FIELDS}
              for lane in (0,1) for home in definitions}
    # Pending attempts are explicit per-instance records, not a shared previous bit.
    pending = {(lane,home):[] for lane in (0,1) for home in definitions}
    commands = {};now = 0
    driver = source.split('  initial begin\n',1)[1]
    pattern = r'#(\d+);|\bp([01])\.(req|ack|clk) (<=|=) (\d+\x27h[0-9a-f]+|[01]);|\$display\("phase=(\d+) time='
    for token in re.finditer(pattern,driver):
        if token[1] is not None:now += int(token[1])
        elif token[2] is not None:
            raw = token[5];value = int(raw.split("'h")[1],16) if "'h" in raw else int(raw)
            commands.setdefault(now,[]).append(('write',int(token[2]),token[3],token[4],value))
        else:commands.setdefault(now,[]).append(('print',int(token[6])))
    lines = []
    for tick,operations in sorted(commands.items()):
        snapshot = [dict(item) for item in data];triggers = [];nba = [];prints = []
        for operation in operations:
            if operation[0]=='print':prints.append(operation[1]);continue
            _,lane,field,op,value = operation
            if op=='<=':nba.append((lane,field,value));continue
            if field!='clk':data[lane][field]=value;continue
            old = clocks[lane];clocks[lane]=value
            for site in (0,1):
                for home,(edge,_,_,_) in definitions.items():
                    clk_lane = site if home=='program' else refs[site][0]
                    if lane==clk_lane and (old,value)==((0,1) if edge=='posedge' else (1,0)):
                        triggers.append((site,home))
        for lane,field,value in nba:data[lane][field]=value
        for site,home in triggers:
            edge,expression,actions,_ = definitions[home]
            if home=='program':
                sampled = {field:snapshot[site][bindings[field]] for field in ('req','ack')}
                live = {field:data[site][bindings[field]] for field in ('req','ack')}
            else:
                sampled = {field:snapshot[refs[site][index]][field]
                           for index,field in ((1,'req'),(2,'ack'))}
                live = {field:data[refs[site][index]][field] for index,field in ((1,'req'),(2,'ack'))}
            frame = frames[site,home];results = []
            for attempt in pending[site,home]:
                assert attempt=='ack';results.append(bool(sampled['ack']))
            pending[site,home] = []
            if '|=>' in expression:
                if sampled['req']:pending[site,home].append('ack')
                else:results.append(True)
            elif '|->' in expression:results.append(not sampled['req'] or bool(sampled['ack']))
            else:results.append(bool(sampled['ack']) ^ expression.startswith('!'))
            for good in results:
                increment,sums = actions[0 if good else 1];frame[increment] += 1
                for field,rhs in sums:
                    variable = rhs[len('$sampled('):-1] if rhs.startswith('$sampled(') else rhs
                    frame[field] = (frame[field]+(sampled if rhs.startswith('$sampled(') else live)[variable])%(1<<64)
        for phase in prints:
            lines.append(f'phase={phase} time={tick}')
            for site in (0,1):
                for home in ('program','module'):
                    frame = frames[site,home];outputs = definitions[home][3]
                    if home=='program':
                        values = {bindings[field]:frame[outputs[field]] for field in FIELDS}
                    else:values = {field:frame[outputs[field]] for field in FIELDS}
                    lines.append(f'site{site} {home} pass={values["passed"]} fail={values["failed"]} '
                                 f'reqsum={values["reqsum"]} acksum={values["acksum"]}')
    assert lines
    return '\n'.join(lines)+'\n'


def independent(row):return interpret(generator.make_case(row).body)


def execute(directory,verilator):
    selected = generator.MODEL.select()
    controls = (generator.MODEL.anchors[0],generator.MODEL.anchors[1],
                selected[7],selected[9],generator.MODEL.anchors[4],generator.MODEL.anchors[5])
    rows = {f'control{n}':row for n,row in enumerate(controls)}
    originals = {};expected = {};paths = {}
    for name,row in rows.items():
        path = ROOT/'tests/gen/ch24'/(generator.case_name(row)+'.sv')
        source = path.read_text();field = suite_results.header(path)['expected_stdout']
        originals[name] = source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
        expected[name] = generator.reference(row);paths[name] = path.relative_to(ROOT).as_posix()
    plain,overlap,nxt,edge = (originals[f'control{n}'] for n in range(4))
    variants = {name:(name,text) for name,text in originals.items()} | {
        'capture_live_not_sample':('control2',nxt.replace("64'($sampled(req))","64'(req)",2)),
        'invert_program_predicate':('control0',plain.replace('clk) (|ack))','clk) !(|ack))',1)),
        'swap_output_counters':('control1',overlap.replace('.passed(passed), .failed(failed)',
                                                         '.passed(failed), .failed(passed)')),
        'delay_overlap_one_tick':('control1',overlap.replace('|->','|=>',1)),
        'alias_reference_instance':('control3',edge.replace('r1(p1.clk, p1.req, p1.ack,',
                                                          'r1(p0.clk, p0.req, p0.ack,')),
        'reverse_program_clock':('control4',originals['control4'].replace('@(negedge clk)','@(posedge clk)',1)),
        'swap_program_inputs':('control5',originals['control5'].replace('checked(.*);',
            'checked(.clk(clk), .req(ack), .ack(req), .passed(passed), .failed(failed),\n'
            '                            .reqsum(reqsum), .acksum(acksum));')),
    }
    known = {'known_next_after':generator.MODEL.anchors[2],
             'known_next_edge':generator.MODEL.anchors[3]}
    for name,row in known.items():
        path = ROOT/'tests/gen/ch24'/(generator.case_name(row)+'.sv')
        source = path.read_text();field = suite_results.header(path)['expected_stdout']
        variants[name] = (name,source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected'))
        expected[name] = generator.reference(row);paths[name] = path.relative_to(ROOT).as_posix()
    executions = {}
    for name,(control,source) in variants.items():
        assert name in rows or name in known or source!=originals[control],name
        folder = directory/name;folder.mkdir();path = folder/'test.sv'
        path.write_text(source);(folder/'control.expected').write_text(expected[control])
        runtime = [];real_run = subprocess.run
        def capture(*args,**kwargs):
            result = real_run(*args,**kwargs)
            if isinstance(args[0],(list,tuple)) and Path(args[0][0]).name=='Vt':runtime.append(result)
            return result
        with patch.object(run_verilator.subprocess,'run',side_effect=capture):ok,reason=run_verilator.run(path,verilator,1)
        assert len(runtime)==1 and runtime[0].returncode==0,(name,reason)
        actual = runtime[0]
        assert not re.search(r'unsupported|%Error|%Fatal|%Warning',actual.stdout+'\n'+actual.stderr,re.I),name
        assert ok if name in rows else not ok and reason.startswith('output differs'),(name,reason)
        raw = ''.join(line+'\n' for line in actual.stdout.splitlines() if not run_verilator.BANNER.match(line))
        normalized = real_run([sys.executable,str(run_verilator.NORMALIZE)],input=raw,capture_output=True,text=True,check=True).stdout
        executions[name] = {'control':control,'status':'pass' if ok else 'known_difference' if name in known else 'detected',
                            'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
                            'returncode':actual.returncode,'expected_stdout':expected[control],
                            'stdout':normalized,'raw_stdout':actual.stdout,'stderr':actual.stderr}
    return executions,paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator');parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version = subprocess.check_output([args.verilator,'--version'],text=True).strip()
    if not version.startswith('Verilator 5.052 '):parser.error('pinned Verilator 5.052 is required')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:executions,paths=execute(Path(folder),args.verilator)
    sources = ('generators/interaction_progassert.py','tools/qualify_progassert.py')
    report = {'model':generator.MODEL.name,'version':1,
              'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope':'Independent parsing of emitted program/module bindings, leading-clock attempts, pending consequences, Preponed samples and commutative actions; six original plain/overlap controls and seven actual SV mutants. Two original next-cycle cases are separately replayed as known differences, not controls or detected faults; runtime nonoverlap behavior remains unqualified.',
              'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
              'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
              'controls':paths,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; controls: 6 pass; SV faults: 7 detected; known replays: 2')


if __name__=='__main__':main()
