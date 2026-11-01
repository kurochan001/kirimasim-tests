#!/usr/bin/env python3
"""Check strength-format expectations and output-difference faults with fixed Icarus."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import sys
import tempfile

import run_icarus
import suite_results

ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_strengthfmt as generator


def independent(row):
    net,strengths,order,_,polarity=row
    ranks={'equal_weak':[3,3],'equal_pull':[5,5],'equal_strong':[6,6],
           'a_stronger':[6,3],'b_stronger':[3,6]}[strengths]
    patterns=([(0,1),(1,0),(0,0),(1,1)] if polarity=='normal' else
              [(1,0),(0,1),(1,1),(0,0)])
    drives=['z','z'];events=[('idle',drives.copy())]
    owners=[0,1] if order=='ab' else [1,0]
    for phase,pair in enumerate(patterns):
        for step,owner in enumerate(owners):
            drives[owner]=str(pair[owner])
            events.append((f'p{phase}_{("half","full")[step]}',drives.copy()))
    for label,owner in zip(('release_half','release_full'),owners):
        drives[owner]='z';events.append((label,drives.copy()))
    lines=[]
    for label,values in events:
        contributions=list(zip(values,ranks))
        if net=='tri0':contributions.append(('0',5))
        if net=='tri1':contributions.append(('1',5))
        value,formatted='z','HiZ'
        for level,mnemonic in [(6,'St'),(5,'Pu'),(3,'We')]:
            zero=any(bit=='0' and rank==level for bit,rank in contributions)
            one=any(bit=='1' and rank==level for bit,rank in contributions)
            if zero or one:
                value={(True,False):'0',(False,True):'1',(True,True):'x'}[(zero,one)]
                formatted=mnemonic+value.upper()
                break
        lines += [f'slot={label} a={values[0]} b={values[1]} value={value}',
                  f'strength={formatted} guard0=Su0 guard1=Su1']
    return '\n'.join(lines)+'\n'


def source_for(row):
    path=ROOT/'tests/gen/ch21'/(generator.case_name(row)+'.sv')
    source=path.read_text();field=suite_results.header(path)['expected_stdout']
    return source.replace(':expected_stdout: '+field,
                          ':expected_stdout: @'+str((path.parent/field[1:]).resolve()))


def faults(directory,bindir):
    string=source_for(generator.MODEL.anchors[0])
    display=source_for(generator.MODEL.anchors[1])
    swrite=source_for(generator.MODEL.anchors[2])
    statement=f'    rendered = $sformatf("{generator.FORMAT}", bus, guard0, guard1);'
    detached=string.replace('  string rendered;','  string rendered;\n  logic detached;')
    detached=detached.replace(statement,'    detached = bus;\n'+statement.replace(', bus,',', detached,'))
    variants={
        'ignore_drive_strengths':string.replace('assign (weak0, weak1)','assign'),
        'swap_driver_strengths':display.replace('assign (strong0, strong1) bus = a;',
                                                'assign (weak0, weak1) bus = a;')
                                      .replace('assign (weak0, weak1) bus = b;',
                                                'assign (strong0, strong1) bus = b;'),
        'format_detached_variable':detached,
        'wrong_format_code':string.replace(generator.FORMAT,'strength=%b guard0=%b guard1=%b'),
        'stale_formatted_string':string.replace(statement,'    if ($time == 1) '+statement.strip()),
    }
    outcomes={}
    for name,source in {'sformatf_control':string,'display_control':display,
                        'swrite_control':swrite,**variants}.items():
        assert name.endswith('_control') or source not in (string,display,swrite)
        path=directory/(name+'.sv');path.write_text(source)
        ok,reason=run_icarus.run(path,bindir)
        if name.endswith('_control'):
            assert ok,(name,reason)
        else:
            assert not ok and reason.startswith('output differs'),(name,ok,reason)
        outcomes[name]='pass' if ok else 'detected'
    return outcomes


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--iverilog-bin',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();bindir=args.iverilog_bin.resolve()
    version=suite_results.tool_version([str(bindir/'iverilog'),'-V'])
    if not re.search(r'version 13\.0(?:\s|$)',version):
        parser.error('qualification requires the fixed Icarus Verilog 13.0 binary')
    for row in generator.MODEL.rows():assert independent(row)==generator.reference(row),row
    with tempfile.TemporaryDirectory() as folder:outcomes=faults(Path(folder),bindir)
    sources=('generators/interaction_strengthfmt.py','tools/qualify_strength_format.py')
    tests=[ROOT/'tests/gen/ch21'/(generator.case_name(r)+'.sv') for r in generator.MODEL.select()]
    report={'model':generator.MODEL.name,'version':generator.MODEL.version,
            'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'independent_rows':len(generator.MODEL.rows()),'fault_injection':outcomes,
            'simulator':version,
            'sources_sha256':{s:hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
            'inputs_sha256':{p.relative_to(ROOT).as_posix():suite_results.input_digest(p) for p in tests}}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(generator.MODEL.rows())} independent drive-resolution rows; '
          'three format controls; five output-difference faults.')


if __name__=='__main__':
    main()
