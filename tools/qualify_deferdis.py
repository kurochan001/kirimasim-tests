#!/usr/bin/env python3
"""Interpret emitted disable control flow and separate deferred-report queues."""

import argparse
import ast
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

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_deferdis as generator


class Disabled(Exception):
    pass


def parse(lines):
    result=[];index=0
    while index<len(lines):
        line=lines[index].strip();index+=1
        if not line:continue
        block=re.fullmatch(r'begin : (\w+)',line)
        if block:
            depth=1;start=index
            while depth:
                current=lines[index].strip()
                if current.startswith('begin : '):depth+=1
                elif current=='end':depth-=1
                index+=1
            result.append(('block',block[1],parse(lines[start:index-1])));continue
        assertion=re.fullmatch(r'(\w+): (assert|assume|cover) #0 \((.*?)\) (report\(.*\));',line)
        if assertion:
            label,directive,condition,passing=assertion.groups();failing=None
            if directive!='cover':
                failing=re.fullmatch(r'else (report\(.*\));',lines[index].strip())[1];index+=1
            result.append(('assertion',label,condition,passing,failing));continue
        disable=re.fullmatch(r'if \((.*)\) disable (\w+);',line)
        if disable:result.append(('disable',*disable.groups()));continue
        delay=re.fullmatch(r'#(\d+);',line)
        if delay:result.append(('delay',int(delay[1])));continue
        increment=re.fullmatch(r'(\w+)\+\+;',line)
        if increment:result.append(('increment',increment[1]));continue
        assignment=re.fullmatch(r'(\w+) (=|\+=) (.*);',line)
        if assignment:result.append(('assignment',*assignment.groups()));continue
        call=re.fullmatch(r'(target_op)\(\);',line)
        if call:result.append(('call',call[1]));continue
        raise AssertionError('unhandled statement: '+line)
    return result


def interpret(source):
    prefix=source.split('  function automatic bit predicate',1)[0]
    scalars={name:int(value) for name,value in re.findall(r'(\w+) = (-?\d+)',prefix)}
    arrays={name:[int(value) for value in text.split(',')] for name,text in
            re.findall(r"(\w+)\[3\] = '\{([^}]+)\}",prefix)}
    functions={name:re.search('function automatic bit '+name+r'\(input int phase\);\s*return (.*?);',source)[1]
               for name in ('predicate','cancel')}
    capture=source.split('function automatic int capture',1)[1].split('endfunction',1)[0]
    evaluation_field=re.search(r'(\w+)\[item\]\+\+;',capture)[1]
    assert re.search(r'return value;',capture)
    report=source.split('function automatic void report',1)[1].split('endfunction',1)[0]
    pass_field,fail_field=re.search(r'if \(success\) (\w+)\[item\]\+\+; else (\w+)\[item\]\+\+;',report).groups()
    sums=re.findall(r'(\w+)\[item\] \+= ([^;]+);',report)
    time_field=re.search(r'(\w+)\[item\] = \$time;',report)[1]
    worker_text=re.search(r'  always begin : worker\n(.*?)\n  end\n',source,re.S)[1]
    worker=parse(worker_text.splitlines());assert worker[0][0]=='delay'
    period=worker[0][1];assert all(op[0]!='delay' for op in worker[1:])
    guard_text=re.search(r'  initial begin : guard\n    #(\d+);\n    forever begin\n(.*?)\n    end\n  end',source,re.S)
    offset=int(guard_text[1]);guard=parse(guard_text[2].splitlines());assert guard[0]==('delay',period)
    tasks={}
    for name,body in re.findall(r'  task automatic (target_op);\n(.*?)\n  endtask',source,re.S):tasks[name]=parse(body.splitlines())
    show=source.split('task automatic show',1)[1].split('endtask',1)[0]
    fields=re.findall(r'(\w+)\[item\]',show);assert len(fields)==6 and all(name in arrays for name in fields)
    driver=source.split('  initial begin\n',1)[1].split('    $finish;',1)[0]
    prints=[];now=0
    for delay,phase in re.findall(r'#(\d+); show\((\d+)\);',driver):now+=int(delay);prints.append((now,int(phase)))
    assert len(prints)==3
    labels=set(re.findall(r'(\w+): (?:assert|assume|cover) #0',source))
    def expression(text,local=None):
        text=text.strip().replace("1'b1",'1').replace("1'b0",'0')
        text=re.sub(r'!(?!=)','not ',text).strip()
        ternary=re.fullmatch(r'\((\w+) == (\d+) \? (\w+) : (\w+)\)',text)
        if ternary:
            names=scalars|dict(local or {})
            return names[ternary[3] if names[ternary[1]]==int(ternary[2]) else ternary[4]]
        def evaluate(node):
            if isinstance(node,ast.Constant):return node.value
            if isinstance(node,ast.Name):return (scalars|dict(local or {}))[node.id]
            if isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.Not):return int(not evaluate(node.operand))
            if isinstance(node,ast.BinOp):
                a,b=evaluate(node.left),evaluate(node.right)
                if isinstance(node.op,ast.Add):return a+b
                if isinstance(node.op,ast.Mult):return a*b
                if isinstance(node.op,ast.Mod):return a%b
            if isinstance(node,ast.Compare):
                assert len(node.ops)==1 and isinstance(node.ops[0],ast.Eq)
                return int(evaluate(node.left)==evaluate(node.comparators[0]))
            if isinstance(node,ast.Call):
                name=node.func.id;arguments=[evaluate(arg) for arg in node.args]
                if name in functions:return expression(functions[name],{'phase':arguments[0]})
                if name=='capture':
                    item,value=arguments;arrays[evaluation_field][item]+=1;return value
                if name=='report':return tuple(arguments)
            raise AssertionError(ast.dump(node))
        return evaluate(ast.parse(text,mode='eval').body)
    def execute(operations,queue,root):
        for op in operations:
            kind=op[0]
            if kind=='delay':continue
            if kind=='block':
                try:execute(op[2],queue,root)
                except Disabled as stop:
                    if stop.args[0]!=op[1]:raise
            elif kind=='increment':scalars[op[1]]+=1
            elif kind=='assignment':
                value=expression(op[3]);scalars[op[1]]=value if op[2]=='=' else scalars[op[1]]+value
            elif kind=='assertion':
                action=op[3] if expression(op[2]) else op[4]
                if action is not None:queue.append((op[1],expression(action)))
            elif kind=='disable' and expression(op[1]):
                destination=op[2]
                if destination in labels:queue[:]=[r for r in queue if r[0]!=destination]
                else:
                    if destination==root:queue.clear()
                    raise Disabled(destination)
            elif kind=='call':
                try:execute(tasks[op[1]],queue,root)
                except Disabled as stop:
                    if stop.args[0]!=op[1]:raise
    def step(operations,root,tick):
        queue=[]
        try:execute(operations,queue,root)
        except Disabled as stop:assert stop.args[0]==root
        # Observed maturity then Reactive execution; input arguments are frozen.
        for _,(item,phase,success,value) in queue:
            arrays[pass_field if success else fail_field][item]+=1
            for field,rhs in sums:arrays[field][item]+=expression(rhs,{'item':item,'phase':phase,'success':success,'value':value})
            arrays[time_field][item]=tick
    events=[(tick,'print',phase) for tick,phase in prints]
    events += [(period*p,'worker',None) for p in range(1,4)]
    events += [(period*p+offset,'guard',None) for p in range(1,4)]
    lines=[]
    for tick,kind,phase in sorted(events):
        if kind=='worker':step(worker,'worker',tick)
        elif kind=='guard':step(guard,'guard',tick)
        else:
            lines.append(f'phase={phase} time={tick} target_tail={scalars["target_tail"]} '
                         f'worker_tail={scalars["worker_tail"]} wdata={scalars["wdata"]} gdata={scalars["gdata"]}')
            for item in range(3):
                values=[arrays[name][item] for name in fields]
                lines.append(('item=%d pass=%d fail=%d captured=%d live=%d eval=%d last=%d')%tuple([item,*values]))
    return '\n'.join(lines)+'\n'


def independent(row):return interpret(generator.make_case(row).body)


def execute_runtime(directory,verilator):
    rows={f'control{n}':row for n,row in enumerate(generator.MODEL.anchors[:6])}
    originals={};expected={};paths={}
    def original(name,row):
        path=ROOT/'tests/gen/ch16'/(generator.case_name(row)+'.sv')
        source=path.read_text();field=suite_results.header(path)['expected_stdout']
        expected[name]=generator.reference(row);paths[name]=path.relative_to(ROOT).as_posix()
        return source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
    for name,row in rows.items():originals[name]=original(name,row)
    a,b,c,d,e,f=(originals[f'control{n}'] for n in range(6))
    variants={name:(name,source) for name,source in originals.items()} | {
        'omit_fail_counts':('control0',a.replace('failed[item]++;','failed[item] += 0;')),
        'invert_worker_predicate':('control0',a.replace('w_pred = predicate(wphase);','w_pred = !predicate(wphase);')),
        'capture_other_payload':('control0',a.replace('capture(0, wdata)','capture(0, gdata)')),
        'omit_argument_side_effect':('control0',a.replace('evaluations[item]++;','evaluations[item] += 0;')),
        'disable_outer_instead_of_inner':('control1',b.replace('disable inner;','disable worker;')),
        'omit_target_task':('control4',e.replace('    target_op();','    ;')),
        'alias_guard_report':('control5',f.replace('report(2, gphase','report(1, gphase')),
    }
    known={'known_label_cancel':generator.MODEL.anchors[6],
           'known_outer_flush':generator.MODEL.anchors[7],
           'known_live_action':generator.MODEL.anchors[8]}
    for name,row in known.items():variants[name]=(name,original(name,row))
    results={}
    for name,(control,source) in variants.items():
        assert name in rows or name in known or source!=originals[control],name
        folder=directory/name;folder.mkdir();path=folder/'test.sv'
        path.write_text(source);(folder/'control.expected').write_text(expected[control])
        runtime=[];real_run=subprocess.run
        def capture(*args,**kwargs):
            result=real_run(*args,**kwargs)
            if isinstance(args[0],(list,tuple)) and Path(args[0][0]).name=='Vt':runtime.append(result)
            return result
        with patch.object(run_verilator.subprocess,'run',side_effect=capture):ok,reason=run_verilator.run(path,verilator,1)
        assert len(runtime)==1 and runtime[0].returncode==0,(name,reason)
        actual=runtime[0]
        assert not re.search(r'unsupported|%Error|%Fatal|%Warning',actual.stdout+'\n'+actual.stderr,re.I),name
        assert ok if name in rows else not ok and reason.startswith('output differs'),(name,reason)
        raw=''.join(line+'\n' for line in actual.stdout.splitlines() if not run_verilator.BANNER.match(line))
        normalized=real_run([sys.executable,str(run_verilator.NORMALIZE)],input=raw,capture_output=True,text=True,check=True).stdout
        results[name]={'control':control,'status':'pass' if ok else 'known_difference' if name in known else 'detected',
                       'returncode':actual.returncode,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
                       'expected_stdout':expected[control],'stdout':normalized,'raw_stdout':actual.stdout,'stderr':actual.stderr}
    return results,paths


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator');parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version=subprocess.check_output([args.verilator,'--version'],text=True).strip()
    if not version.startswith('Verilator 5.052 '):parser.error('pinned Verilator 5.052 is required')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:executions,paths=execute_runtime(Path(folder),args.verilator)
    sources=('generators/interaction_deferdis.py','tools/qualify_deferdis.py')
    report={'model':generator.MODEL.name,'version':1,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent source AST, disable unwinding, per-process pending queues, input evaluation and Observed/Reactive state. Six stable-payload none/inner/task controls and seven actual SV faults; three known label/outer/live differences replayed separately. Controls do not qualify runtime label cancellation, outer queue flushing or Reactive phase timing.',
            'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
            'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
            'controls_and_replays':paths,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; controls: 6 pass; SV faults: 7 detected; known replays: 3')


if __name__=='__main__':main()
