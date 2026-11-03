#!/usr/bin/env python3
"""Independently interpret the bounded saved SV of the two random array profiles.

This is a qualification reader, not a simulator runner or general SV parser.
No generator parameters, stimulus lists or reference helpers determine output.
"""

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

from qualify_pkgnba import literal


@dataclass(frozen=True)
class Value:
    bits: str
    signed: bool = False

    def assign(self, kind):
        state, signed, width = kind
        assert 1<=width<=131,'out-of-scope word width'
        result = self.bits[-width:].rjust(width, self.bits[0] if self.signed else '0')
        if state == 'bit':result = result.translate(str.maketrans('xz', '00'))
        return Value(result, signed)


def indices(left, right):
    assert abs(right-left)<5,'out-of-scope array length'
    return list(range(left, right+(1 if left<=right else -1), 1 if left<=right else -1))


def split(text, separator=','):
    depth=0;start=0;result=[]
    for i,char in enumerate(text):
        if char in '({[':depth+=1
        elif char in ')}]':depth-=1
        elif char==separator and depth==0:result.append(text[start:i].strip());start=i+1
        assert depth>=0,'unbalanced expression'
    assert depth==0,'unbalanced expression'
    result.append(text[start:].strip())
    return result


def binary(left, right, method):
    assert len(left.bits)==len(right.bits)
    n=len(left.bits)
    if method in ('sum','product'):
        if set(left.bits+right.bits)&set('xz'):bits='x'*n
        else:
            a,b=int(left.bits,2),int(right.bits,2)
            result=a+b if method=='sum' else a*b
            bits=f'{result % (1<<n):0{n}b}'
    else:
        alphabet='01xz'
        tables={'and':('0000','01xx','0xxx','0xxx'),
                'or':('01xx','1111','x1xx','x1xx'),
                'xor':('01xx','10xx','xxxx','xxxx')}
        assert method in tables,'unknown binary method'
        bits=''.join(tables[method][alphabet.index(a)][alphabet.index(b)] for a,b in zip(left.bits,right.bits))
    return Value(bits,left.signed)


def interpret(source):
    code=re.sub(r'/\*.*?\*/|//[^\n]*','',source,flags=re.S)
    program=re.fullmatch(r'\s*module \w+;(?P<declarations>.*?)\binitial begin(?P<body>.*?)\$finish;\s*end\s*endmodule\s*',code,re.S)
    assert program,'one bounded initial block is required'
    types={};kinds={};values={};ranges={};arrays={};output=[]
    for raw in program['declarations'].split(';'):
        declaration=raw.strip()
        if not declaration:continue
        typedef=re.fullmatch(r'typedef (bit|logic) (signed|unsigned) \[(\d+):0\] (\w+)',declaration)
        if typedef:
            types[typedef[4]]=(typedef[1],typedef[2]=='signed',int(typedef[3])+1);continue
        typed=re.fullmatch(r'(bit|logic)(?: (signed|unsigned))? \[(\d+):0\] (.+)',declaration,re.S)
        if typed:kind=(typed[1],typed[2]=='signed',int(typed[3])+1);names=typed[4]
        else:
            custom=re.fullmatch(r'(\w+) (.+)',declaration,re.S)
            assert custom and custom[1] in types,'unsupported declaration: '+declaration
            kind=types[custom[1]];names=custom[2]
        for item in split(names):
            match=re.fullmatch(r'(\w+)(?:\[(-?\d+):(-?\d+)\]|\[(\$)?\])?',item)
            assert match,'unsupported variable: '+item
            name=match[1];assert name not in kinds,'duplicate variable'
            kinds[name]=kind;initial=Value(('0' if kind[0]=='bit' else 'x')*kind[2],kind[1])
            if '[' not in item:values[name]=initial
            else:
                order=indices(int(match[2]),int(match[3])) if match[2] is not None else []
                ranges[name]=order;arrays[name]={i:initial for i in order}

    def place(text):
        match=re.fullmatch(r'(\w+)(?:\[(-?\d+)(?::(-?\d+))?\])?',text.strip())
        assert match,'unsupported address: '+text
        name=match[1];assert name in kinds,'unknown variable: '+name
        if match[2] is None:return name, ranges[name][:] if name in arrays else None
        selected=indices(int(match[2]),int(match[3])) if match[3] is not None else [int(match[2])]
        assert name in arrays and all(i in arrays[name] for i in selected),'out-of-range array access'
        # A slice must follow the declared order, including single-item slices.
        if len(selected)>1:
            positions=[ranges[name].index(i) for i in selected]
            assert positions==list(range(positions[0],positions[0]+len(positions))),'opposite slice direction'
        return name,selected

    def operand(text, frame=None, width=1):
        text=text.strip()
        bits=re.fullmatch(r'\$bits\((.*)\)',text,re.S)
        if bits:
            value=operand(bits[1],frame);assert isinstance(value,Value)
            return len(value.bits)
        size=re.fullmatch(r'\$size\((\w+)\)|(\w+)\.size\(\)',text)
        if size:return len(ranges[size[1] or size[2]])
        method=re.fullmatch(r'(\w+)\.(sum|product|and|or|xor)\(\)(?: with \((.*)\))?',text,re.S)
        if method:
            name,op,transform=method.groups();assert name in arrays and ranges[name],'empty/out-of-scope reduction'
            words=[]
            for i in ranges[name]:
                value=arrays[name][i]
                words.append(operand(transform,{'item':value}) if transform else value)
            result=words[0]
            for value in words[1:]:result=binary(result,value,op)
            return result
        cast=re.fullmatch(r"(\d+|int|integer)'\((.*)\)",text,re.S)
        if cast:
            value=operand(cast[2],frame);assert isinstance(value,Value)
            if cast[1].isdigit():kind=('logic',value.signed,int(cast[1]))
            else:kind=('bit' if cast[1]=='int' else 'logic',True,32)
            return value.assign(kind)
        if frame and text in frame:return frame[text]
        if re.fullmatch(r'\w+(?:\[-?\d+(?::-?\d+)?\])?',text):
            name,selected=place(text)
            if selected is None:return values[name]
            if re.fullmatch(r'\w+\[-?\d+\]',text):return arrays[name][selected[0]]
            return [arrays[name][i] for i in selected]
        try:return Value(literal(text,width).bits)
        except (AssertionError,ValueError):raise AssertionError('unsupported expression: '+text)

    for raw in program['body'].split(';'):
        statement=raw.strip()
        if not statement:continue
        display=re.fullmatch(r'\$display\("([^"]*)",\s*(.*?)\)',statement,re.S)
        if display:
            arguments=iter(operand(arg) for arg in split(display[2]))
            def field(match):
                value=next(arguments)
                if match[0]=='%b':assert isinstance(value,Value);return value.bits
                assert type(value) is int
                return str(value)
            output.append(re.sub(r'%0d|%b',field,display[1])+'\n')
            assert next(arguments,None) is None,'extra display arguments'
            continue
        allocate=re.fullmatch(r'(\w+) = new\[(\d+)\]',statement)
        if allocate:
            name,count=allocate[1],int(allocate[2]);assert name in arrays and 1<=count<=5
            ranges[name]=list(range(count));kind=kinds[name]
            arrays[name]={i:Value(('0' if kind[0]=='bit' else 'x')*kind[2],kind[1]) for i in ranges[name]};continue
        empty=re.fullmatch(r'(\w+) = \{\}',statement)
        if empty:
            name=empty[1];assert name in arrays;ranges[name]=[];arrays[name]={};continue
        push=re.fullmatch(r'(\w+)\.push_back\((.*)\)',statement,re.S)
        if push:
            name=push[1];assert name in arrays and len(ranges[name])<5
            value=operand(push[2]);assert isinstance(value,Value)
            index=len(ranges[name]);ranges[name].append(index);arrays[name][index]=value.assign(kinds[name]);continue
        assignment=re.fullmatch(r'(.+?) = (.+)',statement,re.S)
        assert assignment,'unsupported statement: '+statement
        name,selected=place(assignment[1]);value=operand(assignment[2],width=kinds[name][2])
        if selected is None:
            assert isinstance(value,Value);values[name]=value.assign(kinds[name])
        else:
            word_access=re.fullmatch(r'\w+\[-?\d+\]',assignment[1].strip())
            incoming=[value] if word_access else value
            assert isinstance(incoming,list) and len(incoming)==len(selected),'array-size mismatch'
            copied=[v.assign(kinds[name]) for v in incoming]
            for index,word in zip(selected,copied):arrays[name][index]=word
    return ''.join(output)


def qualify(folders):
    """Read immutable existing artifacts; do not generate or execute any case."""
    results=[]
    for folder in folders:
        folder=Path(folder);run=json.loads((folder/'run.json').read_text())
        assert run['valid'] and run['completed'],'incomplete or stale run'
        for name,record in run['inputs'].items():
            if record['profile'] not in ('array_reduction_context','unpacked_array_copy_sequence'):continue
            source=(folder/record['source']).read_bytes();expected=(folder/record['expected']).read_bytes()
            assert hashlib.sha256(source).hexdigest()==record['source_sha256']
            assert hashlib.sha256(expected).hexdigest()==record['expected_sha256']
            observed=interpret(source.decode())
            assert observed.encode()==expected,(folder.name,name,'independent expectation mismatch')
            results.append({'artifact':folder.as_posix(),'case':name,'profile':record['profile'],
                            'source_sha256':record['source_sha256'],'expected_sha256':record['expected_sha256']})
    return results


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('artifacts',nargs='+',type=Path)
    parser.add_argument('--output',required=True,type=Path);args=parser.parse_args()
    if args.output.exists():parser.error('preserve existing qualification evidence')
    rows=qualify(args.artifacts)
    root=Path(__file__).resolve().parent.parent
    sources=('tools/qualify_random_arrays.py','tools/qualify_pkgnba.py')
    result={'scope':'Bounded interpretation of actual saved array declarations, assignments, ranges, casts, reductions and displays; no generator/reference helper calls.',
            'sources_sha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources},'cases':rows}
    args.output.write_text(json.dumps(result,indent=2)+'\n');print(f'Independent saved-SV checks: {len(rows)}')


if __name__=='__main__':main()
