#!/usr/bin/env python3
"""Independently elaborate generated SV processes and execute loop transfers."""

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

from qualify_class_import import Type, Value, initial_value, literal
from qualify_gensub import xor
import run_kirimasim
import suite_results

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_genloop as generator


def integer(source,env):
    """Bounded integer AST evaluation, independently of primary layout logic."""
    def evaluate(node):
        if isinstance(node,ast.Constant) and type(node.value) is int:return node.value
        if isinstance(node,ast.Name):return env[node.id]
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.USub):return -evaluate(node.operand)
        if isinstance(node,ast.BinOp):
            a,b=evaluate(node.left),evaluate(node.right)
            if isinstance(node.op,ast.Add):return a+b
            if isinstance(node.op,ast.Sub):return a-b
            if isinstance(node.op,ast.Mult):return a*b
            if isinstance(node.op,ast.Mod):return a%b
        if isinstance(node,ast.Compare) and len(node.ops)==1 and isinstance(node.ops[0],ast.Eq):
            return int(evaluate(node.left)==evaluate(node.comparators[0]))
        raise AssertionError('unsupported integer expression: '+source)
    return evaluate(ast.parse(source.strip(),mode='eval').body)


class Scope:
    def __init__(self,source,env):
        self.constants=dict(env)
        process=re.fullmatch(r'(.*?)always @\((posedge|negedge) clk\) begin(.*?)end\s*',source,re.S)
        assert process,'unsupported process declaration'
        head,edge,body=process.groups()
        self.edge_kind=edge
        for name,expr in re.findall(r'localparam int (\w+) = ([^;]+);',head):
            assert name not in self.constants
            self.constants[name]=integer(expr,self.constants)
        head=re.sub(r'localparam int \w+ = [^;]+;','',head)
        parsed=re.fullmatch(r'\s*typedef (bit|logic) \[W-1:0\] word_t;'
            r'\s*word_t data\[([^:]+):([^]]+)\], guard, checksum;\s*int ([\w, ]+);\s*',head)
        assert parsed,'unsupported scope declarations'
        state,left,right,counters=parsed.groups()
        assert set(counters.replace(' ','').split(','))=={'runs','done','visited','kept','hits','weight','kept_weight','i','ordinal','at'}
        self.word=Type(self.constants['W'],state,False)
        self.left,self.right=integer(left,self.constants),integer(right,self.constants)
        assert self.word.width>0 and abs(self.right-self.left)+1==self.constants['N']
        self.data={i:initial_value(self.word) for i in range(min(self.left,self.right),max(self.left,self.right)+1)}
        self.values={k:0 for k in counters.replace(' ','').split(',')}
        self.values.update(guard=initial_value(self.word),checksum=initial_value(self.word))
        loop=re.fullmatch(r'(.*?)(for \(i=0; i < ([^;]+); i\+\+\)|while \(i < ([^)]+)\)|repeat \(([^)]+)\)) begin'
            r'(.*?)if \((.*?)\) begin(.*?)end(.*?)end(.*)',body,re.S)
        assert loop,'unsupported process control structure'
        self.head,form,for_end,while_end,repetitions,self.before,self.condition,self.transfer,self.after,self.tail=loop.groups()
        self.kind='for' if for_end else 'while' if while_end else 'repeat'
        self.limit=for_end or while_end or repetitions

    def number(self,text):return integer(text,{**self.constants,**{k:v for k,v in self.values.items() if isinstance(v,int)}})

    def expression(self,text):
        text=text.strip()
        if text in self.values:return self.values[text]
        if text=="'0":return Value(self.word.width).convert(self.word)
        parts=text.split(' ^ ')
        if len(parts)==2:return xor(self.expression(parts[0]),self.expression(parts[1]))
        array=re.fullmatch(r'data\[([^]]+)\]',text)
        if array:
            at=self.number(array[1]);assert at in self.data
            return self.data[at]
        return self.number(text)

    def execute(self,program):
        for statement in (s.strip() for s in program.split(';') if s.strip()):
            if statement in ('break','continue'):return statement
            add=re.fullmatch(r'(\w+)\+\+',statement)
            if add:
                assert add[1] in self.values and isinstance(self.values[add[1]],int)
                self.values[add[1]]+=1;continue
            write=re.fullmatch(r'(\w+|data\[[^]]+\])\s*(\+=|=)\s*(.*)',statement,re.S)
            assert write,('unsupported loop statement',statement)
            target,op,rhs=write.groups();value=self.expression(rhs)
            if target.startswith('data['):
                at=self.number(target[5:-1]);assert at in self.data and op=='='
                self.data[at]=value.convert(self.word)
            elif target in ('guard','checksum'):
                assert op=='=' and isinstance(value,Value)
                self.values[target]=value.convert(self.word)
            else:
                assert target in self.values and isinstance(value,int)
                self.values[target]=value+(self.values[target] if op=='+=' else 0)
        return None

    def edge(self):
        assert self.execute(self.head) is None
        condition=re.fullmatch(r"data\[([^]]+)\]\[0\] (!==|===) 1'b0",self.condition)
        assert condition,'unsupported branch condition'
        if self.kind=='for':self.values['i']=0
        repetitions=self.number(self.limit);iterations=0
        while self.values['i']<self.number(self.limit) if self.kind!='repeat' else iterations<repetitions:
            iterations+=1;assert iterations<=16,'unbounded loop outside qualifier scope'
            assert self.execute(self.before) is None
            at=self.number(condition[1]);assert at in self.data
            value=self.data[at]
            equal=not((value.bits|value.x|value.z)&1)
            jump=self.execute(self.transfer) if (not equal if condition[2]=='!==' else equal) else None
            if jump=='break':break
            if jump is None:assert self.execute(self.after) is None
            else:assert jump=='continue'
            if self.kind=='for':self.values['i']+=1
        assert self.execute(self.tail) is None


def interpret(source):
    """Read actual scopes, arrays, processes, edges and observations, not rows."""
    code=re.sub(r'/\*.*?\*/|//[^\n]*','',source,flags=re.S)
    whole=re.fullmatch(r'\s*`timescale 1ns/1ns\s*module loop_worker #\(parameter int BASE=1, SEL=0\)\(input logic clk\);'
        r'\s*for \(genvar lane=0; lane<2; lane\+\+\) begin:g(.*?)\bend\s*endmodule\s*module \w+;(.*?)endmodule\s*',code,re.S)
    assert whole,'unsupported worker structure'
    branches,top=whole.groups()
    conditional=re.fullmatch(r'\s*if \((.*?)\) begin:slot(.*?)end else begin:slot(.*?)end\s*',branches,re.S)
    case=re.fullmatch(r'\s*case \((.*?)\)\s*0: begin:slot(.*?)end\s*default: begin:slot(.*?)end\s*endcase\s*',branches,re.S)
    assert bool(conditional)!=bool(case)
    cond,yes,no=(conditional or case).groups();scopes={}
    instances=re.findall(r'loop_worker #\(\.BASE\((\d+)\),\.SEL\((\d+)\)\) ([ab])\(clk\);',top)
    assert len(instances)==2 and {r[2] for r in instances}=={'a','b'}
    for base,sel,name in instances:
        for lane in (0,1):
            env={'BASE':int(base),'SEL':int(sel),'lane':lane}
            take=bool(integer(cond,env)) if conditional else integer(cond,env)==0
            scopes[f'{name}.g[{lane}].slot']=Scope(yes if take else no,env)
    top=re.sub(r'loop_worker #\(\.BASE\(\d+\),\.SEL\(\d+\)\) [ab]\(clk\);','',top)
    main=re.fullmatch(r'\s*bit clk=0;\s*initial begin(.*?)end\s*',top,re.S)
    assert main,'unsupported top process'
    tick,clock=0,0
    def member(text):
        match=re.fullmatch(r'([ab]\.g\[[01]\]\.slot)\.(\w+)(?:\[(-?\d+)\])?',text.strip())
        assert match,('unsupported member',text)
        scope=scopes[match[1]];field=match[2];at=int(match[3]) if match[3] is not None else None
        if at is not None:assert field=='data' and at in scope.data
        else:assert field in scope.values
        return scope,field,at
    def expression(text):
        text=text.strip()
        if text=='$time':return tick
        query=re.fullmatch(r'\$(bits|left|right)\((.*?)\)',text)
        if query:
            if query[1]=='bits':return member(query[2])[0].word.width
            assert query[2].endswith('.data')
            scope=scopes[query[2][:-5]];return scope.left if query[1]=='left' else scope.right
        parts=text.split(' ^ ')
        if len(parts)==2:return xor(expression(parts[0]),expression(parts[1]))
        if text.startswith(('a.','b.')):
            scope,field,at=member(text)
            return scope.data[at] if at is not None else scope.values[field]
        return literal(text)
    output=[]
    statements=[s.strip() for s in main[1].split(';') if s.strip()]
    assert statements[-1]=='$finish'
    for statement in statements[:-1]:
        delay=re.match(r'^#(\d+)\s*(.*)',statement,re.S)
        if delay:
            tick+=int(delay[1]);statement=delay[2].strip()
            if not statement:continue
        display=re.fullmatch(r'\$(write|display)\("([^"]*)",\s*(.*?)\)',statement,re.S)
        if display:
            operation,fmt,args=display.groups();args=iter(expression(a) for a in args.split(','))
            def render(token):
                value=next(args)
                if token[0]=='%b':assert isinstance(value,Value);return value.binary()
                assert isinstance(value,int);return str(value)
            output.append(re.sub(r'%0d|%b',render,fmt)+('\n' if operation=='display' else ''));assert next(args,None) is None
            continue
        write=re.fullmatch(r'(.*?)\s*=\s*(.*)',statement,re.S)
        assert write,('unsupported top statement',statement)
        target,rhs=write.groups()
        if target=='clk':
            new=int(rhs);assert new in (0,1)
            if new!=clock:
                for scope in scopes.values():
                    if scope.edge_kind==('posedge' if new else 'negedge'):scope.edge()
            clock=new
        else:
            scope,field,at=member(target)
            if field in ('guard','checksum') or at is not None:
                value=Value(scope.word.width) if rhs=="'0" else expression(rhs)
                if at is not None:scope.data[at]=value.convert(scope.word)
                else:scope.values[field]=value.convert(scope.word)
            else:scope.values[field]=int(rhs)
    return ''.join(output)


def independent(row):return interpret(generator.source(row))


def variants():
    controls={n:generator.make_case(generator.MODEL.anchors[i]) for n,i in
              (('scalar',0),('repeat_z',1),('while_x',2),('for_known',4),('while_known',5))}
    faults=(('wrong_scope_width','while_x','W = BASE + lane + KIND;','W = BASE;'),
            ('lost_break','while_x','break;','continue;'),
            ('lost_continue','for_known','continue;','break;'),
            ('wrong_condition_element','for_known','data[at][0]','data[LEFT][0]'),
            ('skipped_last_iteration','for_known','i < N;','i < N-1;'),
            ('lost_accumulation','for_known','checksum = checksum ^ data[at];','checksum = data[at];'),
            ('wrong_clock_edge','scalar','posedge clk','negedge clk'),
            ('wrong_guard_write','while_x','runs++;',"runs++; guard='0;"),
            ('reversed_array_range','for_known','data[LEFT:RIGHT]','data[RIGHT:LEFT]'))
    programs={n:(n,c.body,'control') for n,c in controls.items()}
    for name,parent,old,new in faults:
        source=controls[parent].body;assert old in source,name
        source=source.replace(old,new)
        assert interpret(source)!=controls[parent].expected,name
        programs[name]=(parent,source,'fault')
    return controls,programs


def runtime(executable,directory):
    import common
    controls,programs=variants();records={}
    for name,(parent,body,kind) in programs.items():
        case=controls[parent];source,_=common.render(case,generator.NAME,generator.VERSION,generator.CHAPTER,'spec')
        source=source.replace(case.body.strip('\n'),body.strip('\n'));original=ROOT/'tests/gen/ch27'/(case.name+'.sv')
        folder=directory/name;folder.mkdir();path=folder/original.name;path.write_text(source);path.with_suffix('.expected').write_text(case.expected)
        calls=[];run=subprocess.run
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
            'original_input_sha256':suite_results.input_digest(original),'expected_stdout':case.expected,'stdout':normalized,
            'stderr':calls[0].stderr.replace(str(folder),'<case>'),'returncode':0}
    return records


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--kirimasim',required=True);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    if args.output.exists():parser.error('preserve prior qualification evidence')
    files=('generators/interaction_genloop.py','generators/interaction_class_import.py','generators/interaction_cond.py','generators/common.py',
           'tools/qualify_genloop.py','tools/qualify_class_import.py','tools/qualify_gensub.py','tools/qualify_genenum.py')
    def hashes():return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in files}
    sources=hashes();runner=suite_results.runner_digest('kirimasim');binary=Path(args.kirimasim).resolve();before=hashlib.sha256(binary.read_bytes()).hexdigest()
    paths=[ROOT/'tests/gen/ch27'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()];inputs={p:suite_results.input_digest(p) for p in paths}
    evidence=hashlib.sha256()
    for row in generator.MODEL.rows():
        source,expected=generator.source(row),generator.reference(row);assert interpret(source)==expected,row
        evidence.update(source.encode()+b'\0'+expected.encode()+b'\0')
    with tempfile.TemporaryDirectory() as tmp:executions=runtime(str(binary),Path(tmp))
    assert hashes()==sources and runner==suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(p)==v for p,v in inputs.items()) and hashlib.sha256(binary.read_bytes()).hexdigest()==before
    result={'model':generator.MODEL.name,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Actual bounded SV elaboration and edge/process/loop interpretation; auxiliary executions are not additional fixed or coverage passes.',
            'rows_interpreted':len(generator.MODEL.rows()),'selected':len(paths),'source_and_expectation_sha256':evidence.hexdigest(),
            'source_sha256':sources,'runner_sha256':runner,'binary_sha256':before,
            'version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
            'sources_unchanged':True,'inputs_unchanged':True,'binary_unchanged':True,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows:',result['rows_interpreted'],'; native controls: 5; detected SV faults: 9')


if __name__=='__main__':main()
