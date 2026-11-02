#!/usr/bin/env python3
"""Interpret emitted checker bindings and Active/NBA/Reactive assertion observations."""

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
import interaction_checksample as generator

FIELDS = ('passed','failed','seen','live','pred','at')
PORTS = ('clk','data',*FIELDS)


def evaluate(value,expression):
    if expression == '(|data)':return int(value != 0)
    if expression == "(data == '0)":return int(not value)
    if expression == '(^data)':return sum(character == '1' for character in bin(value)[2:])%2
    if expression.startswith('!'):return 1-evaluate(value,expression[1:])
    raise AssertionError(expression)


def definition(part):
    raw = re.search(r'target_check: assert property \(([^\n]+)\)\n',part)[1]
    event = re.match(r'@\((posedge|negedge) clk\) (.*)',raw)
    if event:edge,expression = event.groups()
    else:
        edge = re.search(r'default clocking cb @\((posedge|negedge) clk\)',part)[1]
        expression = raw
    actions = part.split('target_check: assert property ',1)[1].split('\n',1)[1]
    blocks = actions.split('end else begin')
    assert len(blocks) == 2
    steps = []
    for block in blocks:
        increments = re.findall(r'\b(\w+)\+\+;',block)
        assignments = re.findall(r'\b(\w+) = ([^;]+);',block)
        assert len(increments)==1 and len(assignments)==4
        steps.append((increments[0],assignments))
    return edge,expression,steps


def interpret(source):
    width = int(re.search(r'input logic \[(\d+):0\] data',source)[1])+1
    mask = 2**width-1
    checker = re.search(r'checker sample_checker\(.*?endchecker',source,re.S)[0]
    reference = re.search(r'module sample_reference\(.*?endmodule',source,re.S)[0]
    definitions = {'checker':definition(checker),'module':definition(reference)}
    connection = re.search(r'sample_checker checked\((.*?)\);',source,re.S)[1]
    if connection.strip() == '.*':bindings = dict(zip(PORTS,PORTS))
    elif connection.lstrip().startswith('.'):
        bindings = dict(re.findall(r'\.(\w+)\(([^)]+)\)',connection))
    else:bindings = dict(zip(PORTS,(word.strip() for word in connection.split(','))))
    assert set(bindings)==set(PORTS) and bindings['clk']=='clk'
    output_vars = dict(re.findall(r'assign (\w+) = (v_\w+);',checker))
    assert set(output_vars) == set(FIELDS)
    refs = {int(n):(int(clk),int(data)) for n,clk,data in re.findall(
        r'r([01])\(p([01])\.clk, p([01])\.data\)',source)}
    assert set(refs)=={0,1}
    inactive = int(re.search(r'bit clk = ([01]);',source)[1])
    clocks = [inactive,inactive];data = [0,0]
    frames = {}
    for lane in (0,1):
        for origin in ('checker','module'):
            prefix = 'v_' if origin=='checker' else ''
            frames[lane,origin] = {prefix+field:(-1 if field=='at' else 0) for field in FIELDS}
    commands = {};clock = 0
    driver = source.split('  initial begin\n',1)[1]
    pattern = r'#(\d+);|\bp([01])\.(data|clk) (<=|=) (\d+\x27h[0-9a-f]+|[01]);|\$display\("phase=(\d+) time='
    for token in re.finditer(pattern,driver):
        if token[1] is not None:clock += int(token[1])
        elif token[2] is not None:
            text = token[5]
            value = int(text.split("'h")[1],16) if "'h" in text else int(text)
            commands.setdefault(clock,[]).append(('write',int(token[2]),token[3],token[4],value))
        else:commands.setdefault(clock,[]).append(('print',int(token[6])))
    def argument(value):
        assert bindings['data'] in ('data','~data')
        return value^mask if bindings['data']=='~data' else value
    def action(lane,origin,sampled,live,tick):
        _,expression,steps = definitions[origin]
        frame = frames[lane,origin]
        good = evaluate(sampled,expression)
        increment,assignments = steps[0 if good else 1]
        frame[increment] += 1
        for name,rhs in assignments:
            if rhs == '$time':value = tick
            elif rhs == 'data':value = live
            elif rhs == '$sampled(data)':value = sampled
            elif rhs.startswith('$sampled(') and rhs.endswith(')'):
                value = evaluate(sampled,rhs[len('$sampled('):-1])
            else:raise AssertionError(rhs)
            frame[name] = value
    lines = []
    for tick,operations in sorted(commands.items()):
        preponed = list(data);triggered = [];nba = [];prints = []
        for operation in operations:
            if operation[0]=='print':prints.append(operation[1]);continue
            _,lane,field,assignment,value = operation
            if assignment=='<=':
                assert field=='data';nba.append((lane,value));continue
            if field=='data':data[lane]=value;continue
            old = clocks[lane];clocks[lane]=value
            for site in (0,1):
                for origin in ('checker','module'):
                    clk_lane = site if origin=='checker' else refs[site][0]
                    edge = definitions[origin][0]
                    if lane==clk_lane and (old,value)==((0,1) if edge=='posedge' else (1,0)):
                        triggered.append((site,origin))
        for lane,value in nba:data[lane]=value
        for site,origin in triggered:
            data_lane = site if origin=='checker' else refs[site][1]
            sampled,live = preponed[data_lane],data[data_lane]
            if origin=='checker':sampled,live = argument(sampled),argument(live)
            action(site,origin,sampled,live,tick)
        for phase in prints:
            lines.append(f'phase={phase} time={tick}')
            for site in (0,1):
                outer = {bindings[port]:frames[site,'checker'][output_vars[port]] for port in FIELDS}
                for origin,frame in (('checker',outer),('module',frames[site,'module'])):
                    lines.append(f'site{site} {origin} pass={frame["passed"]} fail={frame["failed"]} '
                                 f'pred={frame["pred"]} sampled={frame["seen"]:0{width}b} '
                                 f'live={frame["live"]:0{width}b} at={frame["at"]}')
                lines.append(f'site{site} final={data[site]:0{width}b}')
    assert len(lines)==42
    return '\n'.join(lines)+'\n'


def independent(row):return interpret(generator.make_case(row).body)


def execute(directory,verilator):
    rows = {f'control{n}':row for n,row in enumerate(generator.MODEL.anchors[1:])}
    original = {};expected = {};paths = {}
    for name,row in rows.items():
        assert row in generator.MODEL.select()
        path = ROOT/'tests/gen/ch17'/(generator.case_name(row)+'.sv')
        source = path.read_text();field = suite_results.header(path)['expected_stdout']
        original[name] = source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
        expected[name] = generator.reference(row);paths[name] = path.relative_to(ROOT).as_posix()
    before,after,edge = original['control0'],original['control1'],original['control2']
    named = original['control3']
    variants = {name:(name,source) for name,source in original.items()} | {
        'capture_live_instead_of_sample':('control2',edge.replace('v_seen = $sampled(data);','v_seen = data;')),
        'capture_sample_instead_of_live':('control2',edge.replace('v_live = data;','v_live = $sampled(data);')),
        'wrong_checker_predicate':('control0',before.replace('assert property ((data == \'0))','assert property (!(data == \'0))')),
        'swap_output_counters':('control0',before.replace('.passed(passed), .failed(failed)',
                                                         '.passed(failed), .failed(passed)')),
        'alias_reference_instance':('control2',edge.replace('r1(p1.clk, p1.data)','r1(p0.clk, p0.data)')),
        'wrong_explicit_edge':('control3',named.replace('assert property (@(negedge clk)',
                                                     'assert property (@(posedge clk)',1)),
        'missing_fail_counter':('control1',after.replace('v_failed++;','v_failed += 0;')),
    }
    known = {'known_width1_module':generator.MODEL.anchors[0],
             'known_width1_interface':('1','interface','wildcard','edge','nba','negedge','explicit','zero')}
    for name,row in known.items():
        assert row in generator.MODEL.select()
        path = ROOT/'tests/gen/ch17'/(generator.case_name(row)+'.sv')
        source = path.read_text();field = suite_results.header(path)['expected_stdout']
        source = source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
        variants[name] = (name,source);expected[name] = generator.reference(row)
        paths[name] = path.relative_to(ROOT).as_posix()
    executions = {}
    for name,(control,source) in variants.items():
        assert name in rows or name in known or source!=original[control],name
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
                            'returncode':actual.returncode,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
                            'stdout':normalized,'stderr':actual.stderr,'reason':reason}
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
    sources = ('generators/interaction_checksample.py','tools/qualify_checksample.py')
    report = {'model':generator.MODEL.name,'version':1,
              'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope':'Independent parsing of rendered predicates, static connections, output propagation and stimulus; separate Preponed, Active, NBA and Reactive state. Five original controls and seven actual SV mutants; two one-bit-vector edge/NBA differences replayed separately and not counted as controls or detected faults.',
              'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
              'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
              'controls_and_replays':paths,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; controls: 5 pass; SV faults: 7 detected; known replays: 2')


if __name__=='__main__':main()
