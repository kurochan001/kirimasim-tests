#!/usr/bin/env python3
"""Independently parse and enumerate the generated distribution constraints."""

import argparse
from dataclasses import dataclass
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
import interaction_dist as generator

LITERAL = r"\d+'s?h[0-9a-f]+"


@dataclass(frozen=True)
class Word:
    bits: int
    width: int
    signed: bool

    @property
    def number(self):
        return self.bits-(1 << self.width) if self.signed and self.bits>>(self.width-1) else self.bits


def literal(text):
    m=re.fullmatch(r"(\d+)'(s?)h([0-9a-f]+)",text)
    assert m,text
    width=int(m[1]);bits=int(m[3],16)
    assert bits < 1 << width
    return Word(bits,width,bool(m[2]))


def evaluate(text,x):
    tokens=re.findall(LITERAL+r'|x|<<|[+*<()]',text)
    assert ''.join(tokens)==re.sub(r'\s+','',text),text
    position=0
    precedence={'<':1,'<<':2,'+':3,'*':4}

    def expression(level=0):
        nonlocal position
        token=tokens[position];position+=1
        if token=='(':
            left=expression();assert tokens[position]==')';position+=1
        else:left=x if token=='x' else literal(token)
        while position<len(tokens) and tokens[position] in precedence and precedence[tokens[position]]>=level:
            operator=tokens[position];position+=1
            right=expression(precedence[operator]+1)
            if operator=='<<':
                left=Word((left.bits << right.bits) % (1 << left.width),left.width,left.signed)
            else:
                width=max(left.width,right.width);signed=left.signed and right.signed
                a=left.number if signed else left.bits
                b=right.number if signed else right.bits
                if operator=='<':left=Word(int(a<b),1,False)
                else:left=Word((a+b if operator=='+' else a*b) % (1 << width),width,signed)
        return left

    result=expression();assert position==len(tokens)
    return result


def source_model(row):
    # Parse the rendered stimulus; do not reuse the generator's arithmetic,
    # desired solution, distribution support or failure-retention calculation.
    source=generator.make_case(row).body
    declaration=re.search(r'rand bit (unsigned|signed) \[(\d+):0\] x;',source)
    assert declaration
    width=int(declaration[2])+1; signed=declaration[1]=='signed'
    domain=re.search(r'constraint c_domain \{ x inside \{(.*?)\}; \}',source)[1]
    values=[literal(part.strip()) for part in domain.split(',')]
    assert all(word.width==width for word in values)
    candidates=[Word(word.bits,width,signed) for word in values]
    match=re.search(r'constraint c_dist \{\s*(.*?) dist \{(.*?)\};',source,re.S)
    lhs=match[1].strip();entries=[]
    for entry in match[2].strip().split(','):
        m=re.fullmatch(r'\s*(\['+LITERAL+':'+LITERAL+r'\]|'+LITERAL+r')\s*(:=|:/)\s*(\d+|\(impossible \? 0 : 3\))\s*',entry)
        assert m,entry
        if m[1].startswith('['):
            a,b=m[1][1:-1].split(':');lo,hi=literal(a).number,literal(b).number
        else:lo=hi=literal(m[1]).number
        assert lo<=hi
        entries.append((lo,hi,m[2],m[3]))
    phases=[int(m[1]) for m in re.finditer(r'target\.impossible = ([01]);',source)]
    assert len(phases)==3
    return candidates,lhs,entries,phases


def independent(row):
    candidates,lhs,entries,phases=source_model(row)
    first=candidates[0]
    current=Word((1 << first.width)-1,first.width,first.signed)
    lines=[]
    for phase,fail in enumerate(phases):
        for name,impossible in (('target',fail),('guard',0)):
            solutions=[]
            for candidate in candidates:
                value=evaluate(lhs,candidate).number
                total=0
                for lo,hi,operator,weight in entries:
                    amount=(0 if impossible else 3) if weight.startswith('(') else int(weight)
                    if lo<=value<=hi:
                        total+=amount if operator==':=' else amount/(hi-lo+1)
                if total>0:solutions.append(candidate)
            assert len(solutions)==(0 if impossible else 1),(row,solutions)
            if name=='target':
                if solutions:current=solutions[0]
                word=current
            else:word=solutions[0]
            value=evaluate(lhs,word)
            lines.append(f'{name} phase={phase} impossible={impossible} ok={int(bool(solutions))} '
                         f'x={word.number} bits={word.bits:0{word.width}b} '
                         f'expr={value.number} expr_bits={value.width}')
    return '\n'.join(lines)+'\n'


def check_faults(directory,verilator):
    rows=dict(zip(('shift_control','mul_control','rel_control','overlap_control'),generator.MODEL.anchors[4:]))
    rows['auxiliary_failure_control']=generator.MODEL.anchors[1]
    controls={};expected={};paths={}
    for name,row in rows.items():
        path=ROOT/'tests/gen/ch18'/(generator.case_name(row)+'.sv')
        source=path.read_text();field=suite_results.header(path)['expected_stdout']
        if name=='auxiliary_failure_control':
            source=source.replace('  constraint c_dist {',
                '  constraint c_aux_fail { if (impossible) x != x; }\n  constraint c_dist {')
        controls[name]=source.replace(':expected_stdout: '+field,':expected_stdout: @'+name+'.expected')
        expected[name]=generator.reference(row);paths[name]=path.relative_to(ROOT).as_posix()
    mutants={}
    for name,control in (('wrong_shift_grouping','shift_control'),('wrong_multiply_grouping','mul_control'),('wrong_relation_grouping','rel_control')):
        row=rows[control];altered=(*row[:3],'altered',*row[4:])
        old=generator.expression(row);new=generator.expression(altered)
        source=controls[control].replace('    '+old+' dist {','    '+new+' dist {')
        mutants[name]=(control,source)
    row=rows['mul_control'];value,width,signed=generator.expression_value(row,generator.solution(row))
    target=generator.literal(value,width,signed)
    alternative=generator.literal(generator.expression_value(row,generator.domain(row)[0])[0],width,signed)
    swapped=controls['mul_control'].replace(target+' :/ (impossible ? 0 : 3)',target+' :/ 0')
    swapped=swapped.replace(alternative+' :/ 0',alternative+' :/ (impossible ? 0 : 3)')
    mutants['swap_positive_support']=('mul_control',swapped)
    overlap=controls['overlap_control']
    row=rows['overlap_control'];value,width,signed=generator.expression_value(row,generator.domain(row)[0])
    endpoint=generator.literal(value,width,signed)
    moved,count=re.subn(r'\['+LITERAL+':'+LITERAL+r'\](\s*:=\s*\(impossible \? 0 : 3\))',
                        '['+endpoint+':'+endpoint+r']\1',overlap)
    assert count==1
    mutants['wrong_overlap_range']=('overlap_control',moved)
    mutants['clobber_failed_value']=('auxiliary_failure_control',controls['auxiliary_failure_control'].replace(
        '    ok = target.randomize();',"    ok = target.randomize(); if (!ok) target.x = '0;"))
    mutants['alias_guard']=('auxiliary_failure_control',controls['auxiliary_failure_control'].replace(
        'target = new; guard_object = new;','target = new; guard_object = target;'))
    variants={name:(name,source) for name,source in controls.items()}|mutants
    executions={}
    for name,(control,source) in variants.items():
        assert name in controls or source!=controls[control]
        path=directory/(name+'.sv');path.write_text(source)
        (directory/(control+'.expected')).write_text(expected[control])
        runtime=[];actual_run=subprocess.run
        def capture(*args,**kwargs):
            result=actual_run(*args,**kwargs)
            if isinstance(args[0],(tuple,list)) and Path(args[0][0]).name=='Vt':runtime.append(result)
            return result
        with patch.object(run_verilator.subprocess,'run',side_effect=capture):
            ok,reason=run_verilator.run(path,verilator,1)
        assert len(runtime)==1 and runtime[0].returncode==0,(name,reason)
        result=runtime[0]
        diagnostics=(result.stdout+'\n'+result.stderr).splitlines()
        unexpected=[line for line in diagnostics if line.startswith('%Warning') and not line.startswith('%Warning-UNSATCONSTR:')]
        assert not unexpected and not re.search(r'unsupported|%Error|%Fatal','\n'.join(diagnostics),re.I),name
        assert ok if name in controls else not ok and reason.startswith('output differs'),(name,reason)
        raw=''.join(line+'\n' for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line))
        normalized=actual_run([sys.executable,str(run_verilator.NORMALIZE)],input=raw,capture_output=True,text=True,check=True).stdout
        executions[name]={'status':'pass' if ok else 'detected','control':control,'returncode':result.returncode,
                          'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'stdout':normalized,
                          'stderr':result.stderr,'reason':reason,'constraint_diagnostics':[line for line in diagnostics if line.startswith('%Warning-UNSATCONSTR:')]}
    return executions,paths


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator');parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version=subprocess.check_output([args.verilator,'--version'],text=True).strip()
    if not version.startswith('Verilator 5.052 '):parser.error('pinned Verilator 5.052 is required')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as directory:executions,controls=check_faults(Path(directory),args.verilator)
    files=('generators/interaction_dist.py','tools/qualify_dist.py')
    report={'model':generator.MODEL.name,'version':1,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent typed-expression parser and finite-domain enumeration. Four original sat_only controls and one auxiliary failure-after-success control with a redundant contradiction. The auxiliary does not qualify all-zero-weight infeasibility or first-failure observations. No statistical ratio claims.',
            'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
            'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in files},
            'controls':controls,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; controls: 5 pass; SV faults: 7 detected')


if __name__=='__main__':main()
