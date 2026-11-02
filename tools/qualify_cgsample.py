#!/usr/bin/env python3
"""Interpret emitted container operations and independent coverage-bin histories."""

import argparse
from collections import Counter
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
import interaction_cgsample as generator


def interpret(source):
    shape = re.search(r'  int a(\[[^;]*?\]), b',source)[1]
    fixed = re.fullmatch(r'\[0:(\d+)\]',shape)
    arrays = {name:([0]*(int(fixed[1])+1) if fixed else []) for name in ('a','b')}
    size_body = source.split('function automatic int current_size',1)[1].split('endfunction',1)[0]
    size_exprs = re.findall(r'return ([^;]+);',size_body)
    value_body = source.split('function automatic int current_value',1)[1].split('endfunction',1)[0]
    empty = int(re.search(r'== 0\) return (-?\d+);',value_body)[1])
    accesses = re.findall(r'return ([ab])\[([^]]+)\];',value_body)
    assert len(size_exprs)==len(accesses)==2
    def size(lane):
        expression = size_exprs[lane]
        if expression.isdigit():return int(expression)
        name = re.fullmatch(r'([ab])\.size\(\)',expression)[1]
        return len(arrays[name])
    def value(lane):
        if size(lane)==0:return empty
        name,index = accesses[lane]
        if index.isdigit():position=int(index)
        elif re.fullmatch(r'\d+-1',index):position=int(index[:-2])-1
        else:
            other = re.fullmatch(r'([ab])\.size\(\)-1',index)[1]
            position = len(arrays[other])-1
        assert 0<=position<len(arrays[name])
        return arrays[name][position]
    def expression(text,lane=None,arguments=None):
        text=text.strip()
        if text=="1'b1":return 1
        if text in ('value','enabled'):return arguments[text]
        query = re.fullmatch(r'current_(size|value)\((which|[01])\)( != 0)?',text)
        assert query is not None,text
        site = lane if query[2]=='which' else int(query[2])
        result = size(site) if query[1]=='size' else value(site)
        return int(result!=0) if query[3] else result
    groups = {}
    for match in re.finditer(r'covergroup (\w+)(.*?)endgroup',source,re.S):
        name,body = match.groups()
        covered,guard = re.search(r'cp: coverpoint (.*?) iff \((.*?)\) \{',body).groups()
        low,high = re.search(r'bins b\[\] = \{\[(-?\d+):(-?\d+)\]\};',body).groups()
        bins = list(range(int(low),int(high)+1))
        singleton = re.search(r'bins empty = \{(-?\d+)\};',body)
        if singleton:bins.append(int(singleton[1]))
        assert len(bins)==len(set(bins))
        groups[name] = {'covered':covered,'guard':guard,'bins':bins,
                        'threshold':int(re.search(r'option.at_least = (\d+);',body)[1]),
                        'arguments':'with function sample' in body}
    instances = {}
    for group,name,lane in re.findall(r'(size_cg|value_cg) (\w+) = new\(([01]?)\);',source):
        instances[name]={'group':groups[group],'lane':int(lane) if lane else None,'counts':Counter()}
    assert set(instances)=={'gs','gv','hs','hv'}
    show_body = source.split('task automatic show',1)[1].split('endtask',1)[0]
    reported = re.findall(r'(\w+)\.get_inst_coverage\(\)',show_body)
    assert len(reported)==4 and all(name in instances for name in reported)
    sample_body = source.split('task automatic sample_now',1)[1].split('endtask',1)[0]
    repeats = int(re.search(r'repeat_id < (\d+);',sample_body)[1])
    calls = re.findall(r'(\w+)\.sample\((.*?)\);',sample_body)
    def sample():
        for name,args in calls:
            instance = instances[name];group = instance['group'];lane = instance['lane']
            arguments = None
            if group['arguments']:
                parts = args.split(',');assert len(parts)==2
                arguments = dict(zip(('value','enabled'),(expression(item) for item in parts)))
            else:assert not args
            if expression(group['guard'],lane,arguments):
                sampled = expression(group['covered'],lane,arguments)
                if sampled in group['bins']:instance['counts'][sampled] += 1
    lines = []
    def show(phase,stage,index):
        lines.append(f'phase={phase} stage={stage} repeat={index} '
                     f'a_size={size(0)} a_value={value(0)} b_size={size(1)} b_value={value(1)}')
        percentages = []
        for name in reported:
            instance = instances[name];group = instance['group']
            covered = sum(instance['counts'][key]>=group['threshold'] for key in group['bins'])
            percentages.append(100*covered/len(group['bins']))
        lines.append('g size=%.2f value=%.2f h size=%.2f value=%.2f'%tuple(percentages))
    driver = source.split('  initial begin\n',1)[1].split('    $finish;',1)[0]
    pattern = (r'([ab]) = new\[(\d+)\];|([ab])\[(\d+)\] = (-?\d+);|'
               r"([ab]) = '\{([^}]+)\};|([ab]) = ([ab]);|([ab])\.(reverse|delete)\(\);|"
               r'(sample_now|show)\((\d+), "(before|after)"(?:, (-?\d+))?\);')
    assert not re.sub(pattern,'',driver).strip(),re.sub(pattern,'',driver)
    for command in re.finditer(pattern,driver):
        if command[1]:arrays[command[1]]=[0]*int(command[2])
        elif command[3]:arrays[command[3]][int(command[4])]=int(command[5])
        elif command[6]:arrays[command[6]]=[int(word) for word in command[7].split(',')]
        elif command[8]:arrays[command[8]]=list(arrays[command[9]])
        elif command[10]:
            if command[11]=='reverse':arrays[command[10]].reverse()
            else:arrays[command[10]].clear()
        elif command[12]=='show':show(int(command[13]),command[14],int(command[15]))
        else:
            for index in range(repeats):sample();show(int(command[13]),command[14],index)
    assert lines
    return '\n'.join(lines)+'\n'


def independent(row):return interpret(generator.make_case(row).body)


def execute(directory,verilator):
    rows={f'control{n}':row for n,row in enumerate(generator.MODEL.anchors)}
    originals={};expected={};paths={}
    for name,row in rows.items():
        path=ROOT/'tests/gen/ch19'/(generator.case_name(row)+'.sv')
        source=path.read_text();field=suite_results.header(path)['expected_stdout']
        originals[name]=source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
        expected[name]=generator.reference(row);paths[name]=path.relative_to(ROOT).as_posix()
    a,b,c,d,e,f=(originals[f'control{n}'] for n in range(6))
    variants={name:(name,source) for name,source in originals.items()} | {
        'omit_target_sample':('control0',a.replace('      gs.sample(current_size(0), 1\'b1);','')),
        'sample_control_value':('control1',b.replace('gv.sample(current_value(0),','gv.sample(current_value(1),')),
        'ignore_empty_guard':('control2',c.replace('current_size(0) != 0',"1'b1")),
        'wrong_threshold':('control3',d.replace('option.at_least = 2;','option.at_least = 1;')),
        'wrong_endpoint':('control3',d.replace('return a[3-1];','return a[0];')),
        'alias_control_lane':('control4',e.replace('hv = new(1);','hv = new(0);')),
        'mutate_control_copy':('control5',f.replace('    sample_now(0, "after");','    b = a;\n    sample_now(0, "after");')),
    }
    executions={}
    for name,(control,source) in variants.items():
        assert name in rows or source!=originals[control],name
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
        executions[name]={'control':control,'status':'pass' if ok else 'detected','returncode':actual.returncode,
                          'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'expected_stdout':expected[control],
                          'stdout':normalized,'raw_stdout':actual.stdout,'stderr':actual.stderr}
    return executions,paths


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator');parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version=subprocess.check_output([args.verilator,'--version'],text=True).strip()
    if not version.startswith('Verilator 5.052 '):parser.error('pinned Verilator 5.052 is required')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:executions,paths=execute(Path(folder),args.verilator)
    sources=('generators/interaction_cgsample.py','tools/qualify_cgsample.py')
    report={'model':generator.MODEL.name,'version':1,
            'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent parsing of emitted container storage/operations, live/argument reads, sample boundaries, guards, explicit bins, thresholds and per-instance histories. Six original controls and seven actual SV mutants. Single-coverpoint groups expose percentages without coverage ref-output or coverpoint-query APIs; at_least is set directly on each coverpoint, with an explicit singleton empty bin.',
            'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
            'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
            'controls':paths,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; controls: 6 pass; SV faults: 7 detected')


if __name__=='__main__':main()
