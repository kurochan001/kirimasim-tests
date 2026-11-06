#!/usr/bin/env python3
"""Interpret bounded event-loop SV with an independent cooperative scheduler."""

import argparse
import datetime
import hashlib
import heapq
import itertools
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

from qualify_class_import import Type, Value, initial_value, literal
from qualify_genloop import integer
from qualify_gensub import xor
from qualify_ifquery import split_arguments
from qualify_scansel import formatted
import run_kirimasim
import suite_results

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_eventflow as generator


class Parser:
    def __init__(self,text):self.text=text

    def take(self,pattern):
        self.text=self.text.lstrip();match=re.match(pattern,self.text,re.S)
        if match:self.text=self.text[match.end():]
        return match

    def block(self,stop=None):
        nodes=[]
        while self.text.strip():
            if stop and self.take(stop):return nodes
            loop=self.take(r'for \(int (\w+)=(\d+); \1<(\d+); \1\+\+\) begin\b')
            if loop:nodes.append(('for',*loop.groups(),self.block(r'end\b')));continue
            conditional=self.take(r'if \((\w+)==(\d+)\) begin\b')
            if conditional:nodes.append(('if',*conditional.groups(),self.block(r'end\b')));continue
            if self.take(r'fork\b'):
                children=[]
                while not self.take(r'join_none\b'):
                    assert self.take(r'begin\b'),'unsupported fork child'
                    children.append(self.block(r'end\b'))
                assert children;nodes.append(('fork',children));continue
            statement=self.take(r'([^;]+);');assert statement,('unsupported statement',self.text)
            nodes.append(('simple',statement[1].strip()))
        assert stop is None,'unterminated block'
        return nodes


class Break(Exception):pass
class Continue(Exception):pass


def interpret(source):
    """Read actual types/statements; private loop frames share typed globals.

    Active and NBA queues are distinct. join_none children start when their
    parent yields, and triggered state is indexed by simulation tick. This is
    an interpreter for the emitted grammar, not a general SystemVerilog engine.
    """
    code=re.sub(r'/\*.*?\*/|//[^\n]*|`timescale[^\n]*','',source,flags=re.S)
    parsed=re.fullmatch(r'\s*module \w+;(.*?)initial begin(.*?)end\s*endmodule\s*',code,re.S)
    assert parsed;declarations,body=parsed.groups();aliases={};types={};values={};events={}
    for declaration in (s.strip() for s in declarations.split(';') if s.strip()):
        typedef=re.fullmatch(r'typedef (bit|logic) \[(\d+):0\] word_t',declaration)
        if typedef:aliases['word_t']=Type(int(typedef[2])+1,typedef[1],False);continue
        event=re.fullmatch(r'event (.*)',declaration)
        if event:
            for name in event[1].split(','):
                name=name.strip();assert re.fullmatch(r'\w+',name) and name not in events;events[name]=None
            continue
        typed=re.fullmatch(r'(logic \[\d+:0\]|word_t|int) (.*)',declaration);assert typed
        word,names=typed.groups()
        kind=aliases[word] if word in aliases else Type(32,'logic',True) if word=='int' else Type(int(re.search(r'\d+',word)[0])+1,'logic',False)
        for item in names.split(','):
            match=re.fullmatch(r'\s*(\w+)((?:\[\d+\])*)(?:=(0|\x270))?\s*',item);assert match,item
            name,dims,initializer=match.groups();shape=[range(int(n)) for n in re.findall(r'\d+',dims)]
            for indices in itertools.product(*shape):
                key=name+''.join(f'[{n}]' for n in indices);assert key not in types
                types[key]=None if word=='int' else kind
                values[key]=0 if word=='int' else Value(kind.width) if initializer else initial_value(kind)
    assert set(events)=={'go','other'} and set(aliases)=={'word_t'}
    nodes=Parser(body).block();queue=[];serial=itertools.count();processes=[];waiters={e:[] for e in events};output=[];now=0

    def target(text,env):
        match=re.fullmatch(r'(\w+)((?:\[[^]]+\])*)',text.strip());assert match,('invalid target',text)
        name,dims=match.groups()
        return name+''.join(f'[{integer(n,env)}]' for n in re.findall(r'\[([^]]+)\]',dims))

    def expression(text,env):
        text=text.strip()
        if text=='$time':return now
        if text in env:return env[text]
        if re.fullmatch(r'\w+(?:\[[^]]+\])*',text):
            key=target(text,env)
            if key in values:return values[key]
        triggered=re.fullmatch(r'(\w+)\.triggered',text)
        if triggered:return int(events[triggered[1]]==now)
        if ' ^ ' in text:
            a,b=text.split(' ^ ');return xor(expression(a,env),expression(b,env))
        shifted=re.fullmatch(r'\((.*) << (\d+)\)',text)
        if shifted:
            value=expression(shifted[1],env);amount=int(shifted[2]);mask=(1<<value.width)-1
            return Value(value.width,value.bits<<amount&mask,value.x<<amount&mask,value.z<<amount&mask)
        if "'" in text:return literal(text)
        return integer(text,env)

    def store(text,value,env,op='='):
        key=target(text,env);assert key in values,key
        if types[key] is None:
            assert isinstance(value,int)
            values[key]=value if op=='=' else values[key]+value
        else:
            assert op=='='
            if isinstance(value,int):value=Value(32,value,signed=True)
            assert isinstance(value,Value);values[key]=value.convert(types[key])

    def execute(nodes,env):
        for node in nodes:
            if node[0]=='for':
                _,name,start,limit,body=node;env[name]=int(start);assert 0<=int(limit)<=8
                while env[name]<int(limit):
                    try:yield from execute(body,env)
                    except Continue:pass
                    except Break:break
                    env[name]+=1
                continue
            if node[0]=='if':
                _,name,value,body=node
                if env[name]==int(value):yield from execute(body,env)
                continue
            if node[0]=='fork':yield ('spawn',node[1],dict(env));continue
            statement=node[1]
            if statement=='break':raise Break
            if statement=='continue':raise Continue
            if statement=='disable fork':yield ('cancel',);continue
            if statement=='$finish':yield ('finish',);continue
            delay=re.fullmatch(r'#(\d+)',statement)
            if delay:yield ('delay',int(delay[1]));continue
            trigger=re.fullmatch(r'(->>|->) (\w+)',statement)
            if trigger:
                assert trigger[2] in events;yield ('trigger',trigger[2],trigger[1]=='->>');continue
            wait=re.fullmatch(r'@\((\w+)\)|wait \((\w+)\.triggered\)',statement)
            if wait:
                name=wait[1] or wait[2];assert name in events
                yield ('wait',name,bool(wait[2]));continue
            display=re.fullmatch(r'\$(write|display)\("([^"\n]*)"(?:,\s*(.*))?\)',statement,re.S)
            if display:
                operation,fmt,args=display.groups()
                output.append(formatted(fmt,[expression(a,env) for a in split_arguments(args)] if args else [])+
                              ('\n' if operation=='display' else ''));continue
            increment=re.fullmatch(r'([\w\[\]]+)\+\+',statement)
            if increment:store(increment[1],1,env,'+=');continue
            assignment=re.fullmatch(r'([\w\[\]]+)\s*(\+=|=)\s*(.*)',statement,re.S)
            assert assignment,('unsupported statement',statement)
            name,op,rhs=assignment.groups()
            if rhs=="'0":
                kind=types[target(name,env)];assert kind;value=Value(kind.width)
            else:value=expression(rhs,env)
            store(name,value,env,op)

    def schedule(tick,phase,kind,item):heapq.heappush(queue,(tick,phase,next(serial),kind,item))
    def spawn(nodes,env,parent):
        pid=len(processes);processes.append({'gen':execute(nodes,env),'parent':parent,'dead':False})
        schedule(now,0,'process',pid)
    def dispatch(name):
        events[name]=now
        for pid in waiters[name]:
            if not processes[pid]['dead']:schedule(now,0,'process',pid)
        waiters[name]=[]
    spawn(nodes,{},None)
    while queue:
        now,_,_,kind,item=heapq.heappop(queue)
        if kind=='trigger':dispatch(item);continue
        pid=item;process=processes[pid]
        if process['dead']:continue
        while True:
            try:action=next(process['gen'])
            except StopIteration:process['dead']=True;break
            if action[0]=='finish':return ''.join(output)
            if action[0]=='delay':schedule(now+action[1],0,'process',pid);break
            if action[0]=='wait':
                _,name,persistent=action
                if persistent and events[name]==now:continue
                waiters[name].append(pid);break
            if action[0]=='spawn':
                for child in action[1]:spawn(child,dict(action[2]),pid)
            elif action[0]=='trigger':
                _,name,nba=action
                if nba:schedule(now,1,'trigger',name)
                else:dispatch(name)
            elif action[0]=='cancel':
                for child in processes:
                    parent=child['parent']
                    while parent is not None and parent!=pid:parent=processes[parent]['parent']
                    if parent==pid:child['dead']=True
            else:raise AssertionError(action)
    raise AssertionError('missing explicit finish')


def independent(row):return interpret(generator.source(row))


def variants():
    controls={name:generator.make_case(generator.MODEL.anchors[i]) for name,i in
              (('early',0),('persistent',1),('stop',2),('late_stop',3),('nba',4),('missed',5))}
    faults=(
        ('lost_persistence','late_stop',[('wait (go.triggered);','@(go);')]),
        ('lost_rearm_delay','persistent',[('#1;\n            continue;','continue;')]),
        ('break_continues','stop',[('break;','continue;')]),
        ('skip_falls_through','nba',[('continue;','')]),
        ('wrong_payload','nba',[('seen[0][i]=payload_a;','seen[0][i]=payload_b;')]),
        ('lost_cancellation','missed',[('disable fork; cancelled=1;','cancelled=1;')]),
        ('short_loop','early',[('i<4','i<3')]),
        ('lost_shift','nba',[(' << 1',' << 0')]),
        ('changed_trigger_region','missed',[('-> go;','->> go;')]),
    )
    programs={name:(name,case.body,'control') for name,case in controls.items()}
    for name,parent,edits in faults:
        source=controls[parent].body
        for old,new in edits:
            assert old in source,(name,old);source=source.replace(old,new)
        assert interpret(source)!=controls[parent].expected,name
        programs[name]=parent,source,'fault'
    return controls,programs


def runtime(executable,directory):
    import common
    controls,programs=variants();records={}
    for name,(parent,body,kind) in programs.items():
        case=controls[parent];source,_=common.render(case,generator.NAME,generator.VERSION,generator.CHAPTER,'spec')
        source=source.replace(case.body.strip('\n'),body.strip('\n'))
        original=ROOT/'tests/gen/ch15'/(case.name+'.sv');folder=directory/name;folder.mkdir();path=folder/original.name
        path.write_text(source);path.with_suffix('.expected').write_text(case.expected)
        calls,run=[],subprocess.run
        def capture(*args,**kwargs):
            result=run(*args,**kwargs)
            if args[0][0]==executable:calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess,'run',side_effect=capture):status,reason=run_kirimasim.run(path,executable)
        assert len(calls)==1 and calls[0].returncode==0,(name,status,reason)
        assert status==('pass' if kind=='control' else 'fail'),(name,status,reason)
        if kind=='fault':assert reason.startswith('output differs'),(name,reason)
        normalized=run([sys.executable,str(run_kirimasim.NORMALIZE)],input=calls[0].stdout,text=True,capture_output=True,check=True).stdout
        records[name]={'kind':kind,'control':parent,'status':'pass' if kind=='control' else 'detected',
                       'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'original_test':original.relative_to(ROOT).as_posix(),
                       'original_input_sha256':suite_results.input_digest(original),'expected_stdout':case.expected,
                       'stdout':normalized,'stderr':calls[0].stderr.replace(str(folder),'<case>'),'returncode':0}
    return records


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--kirimasim',required=True)
    parser.add_argument('--output',required=True,type=Path);args=parser.parse_args()
    if args.output.exists():parser.error('preserve prior qualification evidence')
    files=('generators/interaction_eventflow.py','generators/interaction_class_import.py','generators/interaction_cond.py',
           'generators/interaction_cover.py','generators/common.py','tools/qualify_eventflow.py','tools/qualify_class_import.py',
           'tools/qualify_genloop.py','tools/qualify_gensub.py','tools/qualify_ifquery.py','tools/qualify_scansel.py')
    def hashes():return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in files}
    sources=hashes();runner=suite_results.runner_digest('kirimasim');binary=Path(args.kirimasim).resolve()
    before=hashlib.sha256(binary.read_bytes()).hexdigest();paths=[ROOT/'tests/gen/ch15'/(generator.case_name(row)+'.sv') for row in generator.MODEL.select()]
    inputs={p:suite_results.input_digest(p) for p in paths};evidence=hashlib.sha256()
    for row in generator.MODEL.rows():
        source,expected=generator.source(row),generator.reference(row);assert interpret(source)==expected,row
        evidence.update(source.encode()+b'\0'+expected.encode()+b'\0')
    with tempfile.TemporaryDirectory() as tmp:executions=runtime(str(binary),Path(tmp))
    assert hashes()==sources and runner==suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(p)==v for p,v in inputs.items()) and hashlib.sha256(binary.read_bytes()).hexdigest()==before
    result={'model':generator.MODEL.name,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent typed globals, private for-loop frames, Active/NBA queues, persistent event flags and descendant cancellation of actual SV. Auxiliary controls/faults are not fixed-suite or coverage passes.',
            'rows_interpreted':len(generator.MODEL.rows()),'selected':len(paths),'source_and_expectation_sha256':evidence.hexdigest(),
            'source_sha256':sources,'runner_sha256':runner,'binary_sha256':before,'version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
            'sources_unchanged':True,'inputs_unchanged':True,'binary_unchanged':True,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows:',result['rows_interpreted'],'; native controls: 6; detected SV faults: 9')


if __name__=='__main__':main()
