#!/usr/bin/env python3
"""Check virtual-interface binding graphs and observable rebinding faults."""

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
import interaction_vif_class as generator


class Bus:
    def __init__(self,tag,data):
        self.tag,self.data=tag,data


class Holder:
    def __init__(self,bus):
        self.vif,self.writes=bus,0

    def read(self):
        return (-1,0) if self.vif is None else (self.vif.tag,self.vif.data)

    def send(self,data):
        if self.vif is None:return 0
        self.vif.data=data
        self.writes+=1
        return 1


def independent(row):
    width,_,_,initial,mode,actor,access=row
    w=int(width)
    mask={'1':1,'8':255,'33':0x1FFFFFFFF}[width]
    guard_value={'1':0,'8':0x55,'33':0xAAAAAAAA}[width]
    a,b,g=Bus(11,0),Bus(22,mask),Bus(33,guard_value)
    start,other=(a,b) if initial=='a' else (b,a)
    source,guard=Holder(start),Holder(g)
    target=source if mode=='alias' else copying.copy(source)
    saved=source.vif
    writer=source if actor=='source' else target
    output=[]

    def snapshot(label,ok):
        s_value,t_value=source.read(),target.read()
        output.extend([
            f'stage={label} ok={ok} object={int(source is target)} '
            f'vif={int(source.vif is target.vif)} saved_source={int(source.vif is saved)} '
            f'saved_copy={int(target.vif is saved)}',
            f'a={a.data:0{w}b} b={b.data:0{w}b} guard={g.data:0{w}b} saved={saved.tag}:{saved.data:0{w}b}',
            f'source={s_value[0]}:{s_value[1]:0{w}b} writes={source.writes} '
            f'copy={t_value[0]}:{t_value[1]:0{w}b} writes={target.writes}',
            f'guard={guard.read()[0]}:{guard.read()[1]:0{w}b} writes={guard.writes}'])

    def write(value):
        if access=='method':return writer.send(value)
        if writer.vif is None:return 0
        writer.vif.data=value
        writer.writes+=1
        return 1

    snapshot('copied',-1)
    snapshot('initial_write',write(mask-start.data))
    writer.vif=other
    snapshot('rebound',-1)
    snapshot('other_write',write(mask-other.data))
    writer.vif=None
    snapshot('null_write',write(mask))
    saved.data=mask-saved.data
    snapshot('saved_write',-1)
    writer.vif=start
    snapshot('restored',-1)
    return '\n'.join(output)+'\n'


def source_for(row):
    path=ROOT/'tests/gen/ch25'/(generator.case_name(row)+'.sv')
    source=path.read_text();field=suite_results.header(path)['expected_stdout']
    return source.replace(':expected_stdout: '+field,
                          ':expected_stdout: @'+str((path.parent/field[1:]).resolve()))


def faults(directory,verilator):
    full=source_for(generator.MODEL.anchors[0])
    modport=source_for(generator.MODEL.anchors[1])
    alias=source_for(generator.MODEL.anchors[2])
    variants={
        'alias_instead_of_shallow_copy':full.replace('    copy = new source;','    copy = source;'),
        'lost_rebinding':full.replace('    copy.vif = b;','    copy.vif = a;'),
        'saved_reference_follows_actor':full.replace('    copy.vif = b;',
                            '    copy.vif = b;\n    saved = copy.vif;'),
        'lost_write':full.replace('    vif.data = value;','    vif.data = vif.data;'),
        'null_write_changes_state':full.replace('    if (vif == null) return 0;',
                            '    if (vif == null) begin writes++; return 0; end'),
        'stale_read':full.replace('    return vif.data;',"    return '0;"),
    }
    outcomes={}
    for name,source in {'full_control':full,'modport_control':modport,'alias_control':alias,**variants}.items():
        assert name.endswith('_control') or source not in (full,modport,alias)
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
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:outcomes=faults(Path(folder),args.verilator)
    sources=('generators/interaction_vif_class.py','tools/qualify_vif_class.py')
    tests=[ROOT/'tests/gen/ch25'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()]
    report={'model':generator.MODEL.name,'version':generator.MODEL.version,
            'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'independent_rows':len(generator.MODEL.rows()),'fault_injection':outcomes,
            'simulator':suite_results.tool_version([args.verilator,'--version']),
            'sources_sha256':{s:hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
            'inputs_sha256':{p.relative_to(ROOT).as_posix():suite_results.input_digest(p) for p in tests}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(generator.MODEL.rows())} independent binding graphs; three controls; six output-difference faults.')


if __name__=='__main__':
    main()
