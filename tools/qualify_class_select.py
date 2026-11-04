#!/usr/bin/env python3
"""Interpret bounded class selection SV and qualify real source mutations."""

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

from qualify_class_import import Type, Value, initial_value, literal
from qualify_gensub import xor
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_class_select as generator


def merged(condition, yes, no):
    assert condition.width == 1 and yes.width == no.width
    if not (condition.x | condition.z): return yes if condition.bits else no
    mask = (1 << yes.width) - 1
    same = ~(yes.bits ^ no.bits | yes.x ^ no.x | yes.z ^ no.z) & mask
    return Value(yes.width, yes.bits & same, yes.x & same | mask ^ same,
                 yes.z & same, yes.signed and no.signed)


def interpret(source):
    """Parse real types, static handle types, bodies, writes and observations."""
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    match = re.fullmatch(r'\s*typedef (bit|logic)\s*(signed\s+)?\[(\d+):0\] word_t;'
        r'\s*class base_t;\s*word_t data, backup, guard;\s*int base, leaf, dead;(.*?)endclass'
        r'\s*class leaf_t extends base_t;(.*?)endclass\s*module \w+;'
        r'\s*leaf_t a, old, b;\s*base_t view;\s*logic sel;'
        r'\s*logic \[(\d+):0\] ra, ro, rb;\s*initial begin(.*?)end\s*endmodule\s*', code, re.S)
    assert match, 'unsupported class/producer structure'
    state, sign, top, base, leaf, high, program = match.groups()
    word = Type(int(top)+1, state, bool(sign))
    methods = {}
    for name, body in (('base_t', base), ('leaf_t', leaf)):
        method = re.fullmatch(r'\s*(virtual\s+)?function automatic word_t choose\(input logic sel\);(.*?)endfunction\s*', body, re.S)
        assert method, 'unsupported method declaration'
        methods[name] = (bool(method[1]), method[2])
    types = {'sel': Type(1, 'logic', False)}
    types.update({r: Type(int(high)+1, 'logic', False) for r in ('ra','ro','rb')})
    values = {n: initial_value(t) for n,t in types.items()}
    objects, handles = [], {}
    static = {n: 'leaf_t' for n in ('a','old','b')}; static['view'] = 'base_t'

    def invoke(handle, argument):
        selected = 'leaf_t' if static[handle] == 'leaf_t' or methods['base_t'][0] else 'base_t'
        obj = objects[handles[handle]]
        frame = {'sel': argument.convert(Type(1, 'logic', False)), 'saved': initial_value(word)}
        def expr(text):
            text = text.strip()
            conditional = re.fullmatch(r"(sel|\(sel === 1'b1\)) \? (.*?) : (.*)", text)
            if conditional:
                cond = frame['sel']
                if conditional[1] != 'sel': cond = Value(1, int(cond.bits == 1 and not(cond.x | cond.z)))
                return merged(cond, expr(conditional[2]), expr(conditional[3]))
            if text in frame:return frame[text]
            if text.startswith('this.') and text[5:] in ('data','backup','guard'):return obj[text[5:]]
            parts = text.split(' ^ ')
            if len(parts)==2:return xor(expr(parts[0]),expr(parts[1]))
            cast = re.fullmatch(r"word_t'\((\d+)\)", text)
            if cast:return Value(32,int(cast[1]),signed=True).convert(word)
            if text == "'0":return Value(word.width).convert(word)
            return literal(text)
        def execute(statements):
            for statement in (s.strip() for s in statements.split(';') if s.strip()):
                if statement == 'word_t saved':continue
                if statement.startswith('return '):return expr(statement[7:]).convert(word)
                count = re.fullmatch(r'this\.(base|leaf|dead)\+\+',statement)
                if count:obj[count[1]]+=1;continue
                write = re.fullmatch(r'(saved|this\.(?:data|backup|guard))\s*=\s*(.*)',statement,re.S)
                assert write, ('unsupported method statement',statement)
                value=expr(write[2]).convert(word)
                if write[1]=='saved':frame['saved']=value
                else:obj[write[1][5:]]=value
            return None
        body=methods[selected][1]
        branch=re.fullmatch(r'(.*?)if \(sel\) begin(.*?)end else begin(.*?)end(.*)',body,re.S)
        case=re.fullmatch(r"(.*?)case \(sel\)\s*1'b1: begin(.*?)end\s*default: begin(.*?)end\s*endcase(.*)",body,re.S)
        if branch or case:
            first,yes,no,last=(branch or case).groups()
            result=execute(first)
            if result is None:
                condition=frame['sel']
                result=execute(yes if condition.bits==1 and not(condition.x|condition.z) else no)
            if result is None:result=execute(last)
        else:result=execute(body)
        assert result is not None, 'method falls through'
        return result

    def expression(text, target=None):
        text=text.strip()
        if text in values:return values[text]
        equal=re.fullmatch(r'(a|old|b) == (a|old|b)',text)
        if equal:return int(handles[equal[1]]==handles[equal[2]])
        member=re.fullmatch(r'(a|old|b)\.(data|backup|guard|base|leaf|dead)',text)
        if member:return objects[handles[member[1]]][member[2]]
        call=re.fullmatch(r'(a|old|b|view)\.choose\(sel\)',text)
        if call:return invoke(call[1],values['sel'])
        if text=="'0":
            assert target
            return Value(target.width).convert(target)
        return literal(text)

    output=[]
    statements=[s.strip() for s in program.split(';') if s.strip()]
    assert statements[-1]=='$finish'
    for statement in statements[:-1]:
        display=re.fullmatch(r'\$display\("([^"]*)",\s*(.*?)\)',statement,re.S)
        if display:
            fmt,args=display.groups(); args=iter(expression(arg) for arg in args.split(','))
            def render(token):
                value=next(args)
                if token[0]=='%b':
                    assert isinstance(value,Value)
                    return value.binary()
                assert isinstance(value,int)
                return str(value)
            output.append(re.sub(r'%b|%0d',render,fmt)+'\n')
            assert next(args,None) is None
            continue
        write=re.fullmatch(r'(.*?)\s*=\s*(.*)',statement,re.S)
        assert write, ('unsupported producer statement',statement)
        target,rhs=write.groups()
        if target in static:
            if rhs=='new':
                assert static[target]=='leaf_t'
                handles[target]=len(objects)
                objects.append({**{p:initial_value(word) for p in ('data','backup','guard')},
                                **{p:0 for p in ('base','leaf','dead')}})
            else:
                assert rhs in handles and (static[target]=='base_t' or static[rhs]=='leaf_t')
                handles[target]=handles[rhs]
        elif target in types:values[target]=expression(rhs,types[target]).convert(types[target])
        else:
            member=re.fullmatch(r'(a|old|b)\.(data|backup|guard|base|leaf|dead)',target)
            assert member,('unsupported write target',target)
            field=member[2]
            objects[handles[member[1]]][field]=int(rhs) if field in ('base','leaf','dead') else expression(rhs,word).convert(word)
    return ''.join(output)


def independent(row):
    return interpret(generator.source(row))


def variants():
    controls={name:generator.make_case(generator.MODEL.anchors[i]) for name,i in
              (('scalar',0),('virtual_z',1),('base_x',2),('bit_x',3),('virtual_known',4))}
    faults=(
        ('lost_virtual_dispatch','virtual_known','virtual function','function'),
        ('wrong_selected_property','scalar','saved = this.backup;','saved = this.guard;'),
        ('wrong_update_constant','virtual_known',"this.data ^ word_t'(2)","this.data ^ word_t'(1)"),
        ('wrong_captured_return','scalar','return saved;','return this.data;'),
        ('effects_after_return','virtual_known','return saved;','this.dead++; return saved;'),
        ('lost_signed_extension','virtual_known','typedef logic signed','typedef logic'),
        ('lost_unknown_merge','virtual_z','saved = sel ? this.backup : this.data;',"saved = (sel === 1'b1) ? this.backup : this.data;"),
        ('wrong_retained_alias','virtual_known','old = a;','old = b;'),
        ('wrong_called_receiver','scalar','ra = a.choose(sel);','ra = b.choose(sel);'),
    )
    programs={n:(n,c.body,'control') for n,c in controls.items()}
    for name,parent,old,new in faults:
        source=controls[parent].body
        assert old in source,name
        source=source.replace(old,new)
        assert interpret(source)!=controls[parent].expected,name
        programs[name]=(parent,source,'fault')
    return controls,programs


def runtime(executable,directory):
    import common
    controls,programs=variants();records={}
    for name,(parent,body,kind) in programs.items():
        case=controls[parent]
        source,_=common.render(case,generator.NAME,generator.VERSION,generator.CHAPTER,'spec')
        source=source.replace(case.body.strip('\n'),body.strip('\n'))
        original=ROOT/'tests/gen/ch8'/(case.name+'.sv')
        folder=directory/name;folder.mkdir();path=folder/original.name;path.write_text(source)
        path.with_suffix('.expected').write_text(case.expected)
        calls=[];run=subprocess.run
        def capture(*args,**kwargs):
            result=run(*args,**kwargs)
            if args[0][0]==executable:calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess,'run',side_effect=capture):
            status,reason=run_kirimasim.run(path,executable)
        assert len(calls)==1 and calls[0].returncode==0,(name,status,reason)
        assert status==('pass' if kind=='control' else 'fail'),(name,status,reason)
        if kind=='fault':assert reason.startswith('output differs'),(name,reason)
        normalized=run([sys.executable,str(run_kirimasim.NORMALIZE)],input=calls[0].stdout,text=True,capture_output=True,check=True).stdout
        records[name]={'kind':kind,'control':parent,'status':'pass' if kind=='control' else 'detected',
            'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
            'original_test':original.relative_to(ROOT).as_posix(),
            'original_input_sha256':suite_results.input_digest(original),
            'expected_stdout':case.expected,'stdout':normalized,
            'stderr':calls[0].stderr.replace(str(folder),'<case>'),'returncode':0}
    return records


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kirimasim',required=True);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    if args.output.exists():parser.error('preserve prior qualification evidence')
    files=('generators/interaction_class_select.py','generators/interaction_class_import.py',
           'generators/interaction_cond.py','generators/common.py','tools/qualify_class_select.py',
           'tools/qualify_class_import.py','tools/qualify_gensub.py','tools/qualify_genenum.py')
    def hashes():return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in files}
    sources=hashes();runner=suite_results.runner_digest('kirimasim')
    paths=[ROOT/'tests/gen/ch8'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()]
    inputs={p:suite_results.input_digest(p) for p in paths}
    binary=Path(args.kirimasim).resolve();before=hashlib.sha256(binary.read_bytes()).hexdigest();evidence=hashlib.sha256()
    for row in generator.MODEL.rows():
        source,expected=generator.source(row),generator.reference(row)
        assert interpret(source)==expected,row
        evidence.update(source.encode()+b'\0'+expected.encode()+b'\0')
    with tempfile.TemporaryDirectory() as temporary:executions=runtime(str(binary),Path(temporary))
    assert hashes()==sources and suite_results.runner_digest('kirimasim')==runner
    assert all(suite_results.input_digest(p)==digest for p,digest in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest()==before
    result={'model':generator.MODEL.name,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Actual bounded SV interpretation; auxiliary controls/faults and all-row checks are not fixed-suite or coverage passes.',
            'rows_interpreted':len(generator.MODEL.rows()),'selected':len(paths),
            'source_and_expectation_sha256':evidence.hexdigest(),'source_sha256':sources,
            'runner_sha256':runner,'binary_sha256':before,
            'version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
            'sources_unchanged':True,'inputs_unchanged':True,'binary_unchanged':True,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows:',result['rows_interpreted'],'; native controls: 5; detected SV faults: 9')


if __name__=='__main__':main()
