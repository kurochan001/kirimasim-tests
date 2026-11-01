#!/usr/bin/env python3
"""Check class-array copies with a separate object graph and observable faults."""

import argparse
import copy as copying
import datetime
import hashlib
import json
from pathlib import Path
import sys
import tempfile

import run_verilator
import suite_results

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_class_array as generator


class Leaf:
    def __init__(self,value):
        self.value=value


class Holder:
    constructed=0

    def __init__(self,words,refs):
        Holder.constructed+=1
        self.stamp=Holder.constructed
        self.words=words
        self.refs=refs


def independent(row):
    container,width,length,position,mode,writer,operation=row
    mask={'1':1,'8':255,'33':0x1FFFFFFFF}[width]
    n=int(length);w=int(width);mark=0 if position=='first' else n-1
    words=[0,mask,0][:n]
    Holder.constructed=0
    source=Holder(words.copy(),[Leaf(mask-v) for v in words])
    guard=Holder([mask-v for v in words],[Leaf(v) for v in words])
    if mode=='alias':
        target=source
    else:
        # Python object allocation/copy bypasses __init__; explicit list copies
        # model SV array values, retaining the referenced Leaf objects.
        target=copying.copy(source)
        target.words=source.words.copy()
        target.refs=source.refs.copy()
    saved=source.refs[mark]
    actor=source if writer=='source' else target
    output=[]

    def snapshot(label):
        source_match=int(mark<len(source.refs) and source.refs[mark] is saved)
        target_match=int(mark<len(target.refs) and target.refs[mark] is saved)
        output.extend([f'stage={label} same_holder={int(source is target)} '
                       f'ctor={Holder.constructed} old={saved.value:0{w}b}',
                       f'same_first={int(source.refs[0] is target.refs[0])} '
                       f'old_source={source_match} old_copy={target_match}'])
        for name,h in [('source',source),('copy',target),('guard',guard)]:
            output.append(f'{name} stamp={h.stamp} size={len(h.words)}')
            for i,(word,ref) in enumerate(zip(h.words,h.refs)):
                value='null' if ref is None else format(ref.value,f'0{w}b')
                output.append(f'{name}[{i}] word={word:0{w}b} ref={value}')

    snapshot('copied')
    actor.refs[mark].value=words[mark]
    snapshot('shared')
    if operation=='element':
        actor.words[mark]=mask-actor.words[mark]
        actor.refs[mark]=Leaf(mask)
    else:
        size=3 if n==1 else 1
        if container=='dynamic':
            actor.words=actor.words[:size]+[0]*max(0,size-len(actor.words))
            actor.refs=actor.refs[:size]+[None]*max(0,size-len(actor.refs))
        else:
            while len(actor.words)>size:
                actor.words.pop();actor.refs.pop()
            while len(actor.words)<size:
                actor.words.append(0);actor.refs.append(None)
    snapshot('changed')
    saved.value=mask-words[mark]
    snapshot('retained')
    return '\n'.join(output)+'\n'


def source_for(row):
    path=ROOT/'tests/gen/ch8'/(generator.case_name(row)+'.sv')
    source=path.read_text();field=suite_results.header(path)['expected_stdout']
    return source.replace(':expected_stdout: '+field,
                          ':expected_stdout: @'+str((path.parent/field[1:]).resolve()))


def faults(directory,verilator):
    fixed=source_for(generator.MODEL.anchors[0])
    resized=source_for(generator.MODEL.anchors[1])
    clone='    copy = new source;'
    deep=clone+'''
    foreach (copy.refs[i]) begin
      fresh = new; fresh.value = source.refs[i].value;
      copy.refs[i] = fresh;
    end'''
    constructed='''    copy = new;
    copy.words = source.words; copy.refs = source.refs; copy.stamp = source.stamp;'''
    variants={
        'alias_instead_of_copy':fixed.replace(clone,'    copy = source;'),
        'deep_copied_elements':fixed.replace(clone,deep),
        'lost_vector_elements':fixed.replace(clone,clone+"\n    foreach (copy.words[i]) copy.words[i] = '0;"),
        'constructor_reexecuted':fixed.replace(clone,constructed),
        'wrong_element_index':fixed.replace("copy.words[2] = 33'h1ffffffff;","copy.words[0] = 33'h1ffffffff;")
                                   .replace('copy.refs[2] = fresh;','copy.refs[0] = fresh;'),
        'resize_leaks_to_other_holder':resized.replace('    show("changed");',
            '    source.words = copy.words; source.refs = copy.refs;\n    show("changed");'),
    }
    outcomes={}
    for name,source in {'fixed_control':fixed,'resize_control':resized,**variants}.items():
        assert name.endswith('_control') or source not in (fixed,resized)
        path=directory/(name+'.sv');path.write_text(source)
        ok,reason=run_verilator.run(path,verilator,1)
        if name.endswith('_control'):
            assert ok,(name,reason)
        else:
            assert not ok and reason.startswith('output differs'),(name,ok,reason)
        outcomes[name]='pass' if ok else 'detected'
    return outcomes


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator',default='verilator')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    for row in generator.MODEL.rows():
        assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:
        outcomes=faults(Path(folder),args.verilator)
    sources=('generators/interaction_class_array.py','tools/qualify_class_array.py')
    tests=[ROOT/'tests/gen/ch8'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()]
    report={'model':generator.MODEL.name,'version':generator.MODEL.version,
            'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'independent_rows':len(generator.MODEL.rows()),'fault_injection':outcomes,
            'simulator':suite_results.tool_version([args.verilator,'--version']),
            'sources_sha256':{s:hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
            'inputs_sha256':{p.relative_to(ROOT).as_posix():suite_results.input_digest(p) for p in tests}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(generator.MODEL.rows())} independent object graphs; two controls; six output-difference faults.')


if __name__=='__main__':
    main()
