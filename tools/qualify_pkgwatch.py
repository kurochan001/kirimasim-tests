#!/usr/bin/env python3
"""Interpret emitted package observer programs and execute real SV faults."""

import argparse
from dataclasses import dataclass
import datetime
import hashlib
import heapq
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

from qualify_pkgnba import Word, literal
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_pkgwatch as generator


def equality(a, b, operator):
    width=max(len(a.bits),len(b.bits));a=a.convert(width).bits;b=b.convert(width).bits
    if operator in ('===','!=='): value='1' if a==b else '0'
    elif any(x in '01' and y in '01' and x!=y for x,y in zip(a,b)): value='0'
    elif set(a+b)<={'0','1'}: value='1'
    else: value='x'
    if operator in ('!=','!==') and value!='x':value='0' if value=='1' else '1'
    return Word(value)


PATTERN = (r'\s*typedef (?P<state>bit|logic) \[(?P<top>\d+):0\] word_t;'
           r'\s*(?:import (?P<package>\w+)::(?:\*|target);)?'
           r'\s*word_t copy = (?P<copy>\d+), last = (?P<last>\d+), held = (?P<held>\d+);'
           r'\s*int hits = (?P<hits>-?\d+), at = (?P<at>-?\d+), wakes = (?P<wakes>-?\d+), wt = (?P<wt>-?\d+);'
           r'\s*function automatic word_t sample_word\(\);\s*return (?P<sample>[^;]+);\s*endfunction'
           r'\s*function automatic logic predicate_now\(\);\s*return (?P<predicate>[^;]+);\s*endfunction'
           r'\s*always_comb copy = (?P<comb>[^;]+);'
           r'\s*initial begin\s*#(?P<event_arm>\d+);\s*forever begin\s*@\((?P<event>[^;]+)\);'
           r'(?P<event_code>.*?)\s*end\s*end'
           r'\s*initial begin\s*#(?P<wait_arm>\d+);\s*wait \((?P<wait>[^;]+)\);'
           r'(?P<wait_code>.*?)\s*end\s*')


class Observer:
    def __init__(self, body):
        self.program=re.fullmatch(PATTERN,body,re.S)
        assert self.program,'unsupported observer body'
        self.width=int(self.program['top'])+1;self.state=self.program['state']
        self.fields={name:Word(format(int(self.program[name]),f'0{self.width}b')[-self.width:])
                     for name in ('copy','last','held')}
        self.fields.update({name:int(self.program[name]) for name in ('hits','at','wakes','wt')})
        self.armed=False;self.waiting=False;self.event_value=None


def interpret(source, reverse_observers=False):
    """A bounded source interpreter; callbacks read only package/own state.

    A callback can run immediately after a write: the producer reads observer
    fields only at later ticks, so callback ordering cannot affect output. This
    is not a general scheduler or a proof for interacting concurrent writers.
    """
    code=re.sub(r'/\*.*?\*/|//[^\n]*','',source,flags=re.S)
    source=code
    assert len(re.findall(r'\binitial\s+begin',code))==5,'unsupported producers'
    assert len(re.findall(r'\bmodule\s+',code))==3,'unsupported module'
    types={};arrays={};objects={}
    for package,body in re.findall(r'package (\w+);(.*?)endpackage',source,re.S):
        m=re.fullmatch(r'\s*typedef (bit|logic) \[(\d+):0\] word_t;\s*word_t (.*?);\s*',body,re.S)
        assert m
        state,top,shape=m.groups();width=int(top)+1;types[package]=(width,state)
        dimensions=re.fullmatch(r'target\[(-?\d+):(-?\d+)\]',shape)
        if dimensions:
            lo,hi=sorted(map(int,dimensions.groups()));arrays[package]=set(range(lo,hi+1))
            keys=[('target',i) for i in arrays[package]]
        else:assert shape=='target, neighbor';keys=[('target',None),('neighbor',None)]
        for field,index in keys:objects[package,field,index]=Word(('0' if state=='bit' else 'x')*width)
    assert set(types)=={'payload_pkg','control_pkg'}
    templates=dict(re.findall(r'module (payload_watch|control_watch);(.*?)endmodule',source,re.S))
    assert set(templates)=={'payload_watch','control_watch'}
    instances=re.findall(r'(payload_watch|control_watch) ([abg])\(\);',source)
    observers={name:Observer(templates[kind]) for kind,name in instances}
    assert len(instances)==3 and set(observers)=={'a','b','g'}
    if reverse_observers:observers=dict(reversed(tuple(observers.items())))
    source_width=int(re.search(r'logic \[(\d+):0\] drive;',source)[1])+1
    drive=Word('x'*source_width);events=[];serial=0;output=[]

    def put(tick,priority,kind,data):
        nonlocal serial
        serial+=1;heapq.heappush(events,(tick,priority,serial,kind,data))

    def resolve(text,observer=None):
        m=re.fullmatch(r'(?:(\w+)::)?(target|neighbor)((?:\[-?\d+\])*)',text.strip())
        assert m,'unsupported reference: '+text
        package,field,suffix=m.groups()
        if package is None:
            assert observer is not None and observer.program['package'],'unbound name'
            package=observer.program['package']
        indices=[int(value) for value in re.findall(r'\[(-?\d+)\]',suffix)]
        index=indices.pop(0) if package in arrays else None
        key=(package,field,index);assert key in objects,key
        assert len(indices)<=1
        bit=indices[0] if indices else None
        if bit is not None:assert 0<=bit<types[package][0]
        return key,bit

    def read(text,observer=None):
        key,bit=resolve(text,observer);value=objects[key]
        return Word(value.bits[-1-bit]) if bit is not None else value

    def operand(text,tick,observer=None):
        text=text.strip()
        if text=='$time':return tick
        if text=='drive':return drive
        if re.fullmatch(r'-?\d+',text):return int(text)
        if observer:
            if text in observer.fields:return observer.fields[text]
            if text=='sample_word()':
                value=operand(observer.program['sample'],tick,observer)
                return value.convert(observer.width,observer.state)
            if text=='predicate_now()':return condition(observer.program['predicate'],observer,tick)
        member=re.fullmatch(r'([abg])\.(\w+(?:\(\))?)',text)
        if member:return operand(member[2],tick,observers[member[1]])
        if "'" in text:return literal(text,observer.width if observer else source_width)
        return read(text,observer)

    def condition(text,observer,tick):
        m=re.fullmatch(r'(.+?)\s*(===|!==|==|!=)\s*(.+)',text.strip())
        if not m:
            value=operand(text,tick,observer);assert isinstance(value,Word)
            return value.convert(1)
        return equality(operand(m[1],tick,observer),operand(m[3],tick,observer),m[2])

    def execute(statements,observer,tick):
        for raw in statements.split(';'):
            statement=raw.strip()
            if not statement:continue
            increment=re.fullmatch(r'(hits|wakes)\+\+',statement)
            if increment:observer.fields[increment[1]]+=1;continue
            a=re.fullmatch(r'(copy|last|held|hits|at|wakes|wt) (=|\+=) (.+)',statement)
            assert a,'unsupported callback statement: '+statement
            name,op,rhs=a.groups();value=operand(rhs,tick,observer)
            if name in ('copy','last','held'):
                assert isinstance(value,Word) and op=='='
                observer.fields[name]=value.convert(observer.width,observer.state)
            else:
                assert type(value) is int
                observer.fields[name]=value if op=='=' else observer.fields[name]+value

    def update_wait(observer,tick):
        if observer.waiting and condition(observer.program['wait'],observer,tick).bits=='1':
            execute(observer.program['wait_code'],observer,tick);observer.waiting=False

    def refresh(tick):
        for observer in observers.values():
            value=operand(observer.program['comb'],tick,observer)
            assert isinstance(value,Word)
            observer.fields['copy']=value.convert(observer.width,observer.state)
            if observer.armed:
                current=read(observer.program['event'],observer)
                if current!=observer.event_value:
                    observer.event_value=current;execute(observer.program['event_code'],observer,tick)
            update_wait(observer,tick)

    def write(key,value,tick):
        assert isinstance(value,Word)
        objects[key]=value.convert(*types[key[0]]);refresh(tick)

    def display(statement,tick):
        m=re.fullmatch(r'\$(display|write)\("([^"]*)",\s*(.*?)\)',statement,re.S)
        assert m,'unsupported display'
        values=iter(operand(arg,tick) for arg in m[3].split(','))
        def field(match):
            value=next(values)
            if match[0]=='%b':assert isinstance(value,Word);return value.bits
            assert type(value) is int
            return str(value)
        output.append(re.sub(r'%0d|%b',field,m[2])+('\n' if m[1]=='display' else ''))
        assert next(values,None) is None

    tick=0
    driver=source.rsplit('  initial begin\n',1)[1].split('$finish;',1)[0]
    for raw in driver.split(';'):
        statement=raw.strip()
        if not statement:continue
        delay=re.fullmatch(r'#(\d+)',statement)
        if delay:tick+=int(delay[1])
        else:put(tick,0,'producer',statement)
    put(0,0,'refresh',None)
    for name,observer in observers.items():
        put(int(observer.program['event_arm']),0,'arm_event',name)
        put(int(observer.program['wait_arm']),0,'arm_wait',name)
    while events:
        tick,_,_,kind,data=heapq.heappop(events)
        if kind=='refresh':refresh(tick);continue
        if kind=='arm_event':
            observer=observers[data];observer.armed=True;observer.event_value=read(observer.program['event'],observer);continue
        if kind=='arm_wait':
            observer=observers[data];observer.waiting=True;update_wait(observer,tick);continue
        if kind=='write':write(*data,tick);continue
        statement=data
        if statement.startswith(('$display(', '$write(')):display(statement,tick);continue
        a=re.fullmatch(r'(.+?) (<=|=) (.+)',statement,re.S)
        assert a,'unsupported producer statement: '+statement
        target,op,rhs=a.groups()
        value=operand(rhs,tick) if rhs.strip()=='drive' else literal(rhs,source_width)
        if target=='drive':assert op=='=';drive=value.convert(source_width);continue
        key,bit=resolve(target);assert bit is None
        if op=='<=':put(tick,1,'write',(key,value))
        else:write(key,value,tick)
    return ''.join(output)


def independent(row):
    return interpret(generator.source(row))


def runtime(executable,directory):
    controls={}
    for name,index in (('scalar',0),('wide',1),('array',4),('logic_x',2)):
        row=generator.MODEL.anchors[index]
        p=ROOT/'tests/gen/ch26'/(generator.case_name(row)+'.sv')
        controls[name]=(p.read_text(),suite_results.expected_output(p,'kirimasim'),p)
    faults=(
        ('wrong_function_package','scalar','return payload_pkg::target;','return control_pkg::target;'),
        ('missing_fanout','scalar','payload_watch b();','control_watch b();'),
        ('projected_event','array','@(target[-2]);','@(target[-2][0]);'),
        ('missing_event_count','array','hits++;','hits += 0;'),
        ('early_wait','scalar',"wait (payload_pkg::target == 1'h0);","wait (payload_pkg::target != 1'h0);"),
        ('wrong_held_value','array','held = target[-2];',"held = '1;"),
        ('lost_unknown_state','logic_x','typedef logic','typedef bit'),
        ('blocking_instead_of_nba','wide','payload_pkg::target[2] <= drive;','payload_pkg::target[2] = drive;'),
    )
    variants={name:(name,src,'control') for name,(src,_,_) in controls.items()}
    for name,parent,old,new in faults:
        src=controls[parent][0];assert old in src,name
        variants[name]=(parent,src.replace(old,new,1),'fault')
    executions={}
    for name,(parent,src,kind) in variants.items():
        expected=controls[parent][1];assert expected is not None
        if kind=='fault':assert interpret(src)!=expected,name
        folder=directory/name;folder.mkdir();p=folder/controls[parent][2].name
        p.write_text(src);p.with_suffix('.expected').write_text(expected)
        calls=[];original=subprocess.run
        def capture(*a,**kw):
            result=original(*a,**kw)
            if a[0][0]==executable:calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess,'run',side_effect=capture):status,reason=run_kirimasim.run(p,executable)
        assert len(calls)==1 and calls[0].returncode==0,(name,reason)
        assert status==('pass' if kind=='control' else 'fail'),(name,status,reason)
        if kind=='fault':assert reason.startswith('output differs'),(name,reason)
        raw=calls[0]
        stdout=original([sys.executable,str(run_kirimasim.NORMALIZE)],input=raw.stdout,capture_output=True,text=True,check=True).stdout
        executions[name]={'kind':kind,'control':parent,'status':'pass' if kind=='control' else 'detected',
                          'source_sha256':hashlib.sha256(src.encode()).hexdigest(),'expected_stdout':expected,
                          'stdout':stdout,'stderr':raw.stderr.replace(str(folder),'<case>'),'returncode':raw.returncode,
                          'original_test':controls[parent][2].relative_to(ROOT).as_posix(),
                          'original_input_sha256':suite_results.input_digest(controls[parent][2])}
    return executions


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--kirimasim',required=True);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args()
    if args.output.exists():p.error('preserve prior qualification evidence')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    binary=Path(args.kirimasim).resolve();digest=hashlib.sha256(binary.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as folder:executions=runtime(str(binary),Path(folder))
    assert digest==hashlib.sha256(binary.read_bytes()).hexdigest(),'binary changed'
    files=('generators/interaction_pkgwatch.py','tools/qualify_pkgwatch.py','tools/qualify_pkgnba.py')
    record={'model':generator.MODEL.name,'version':1,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent parsing of emitted package types, references, observer bodies, callbacks, producer assignments and displays. One producer and read-only independent observers; callback ordering cannot affect settled samples. No general concurrent-scheduler proof.',
            'independent_rows':len(generator.MODEL.rows()),'binary_sha256':digest,
            'simulator_version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
            'runner_sha256':suite_results.runner_digest('kirimasim'),
            'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in files},'executions':executions}
    args.output.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows: 2592; native controls: 4 pass; real SV faults: 8 detected')


if __name__=='__main__':main()
