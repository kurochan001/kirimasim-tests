import argparse
import json
from pathlib import Path
import shlex
import subprocess

here=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--worktrees',type=Path,required=True)
parser.add_argument('--outdir',type=Path,default=here)
args=parser.parse_args()
variants={k:Path(v).resolve() for k,v in json.loads(args.worktrees.read_text()).items()}
source=here/'metadata_load.cpp'; here=args.outdir.resolve();here.mkdir(parents=True,exist_ok=True)
base=variants['baseline']
obj=here/'metadata_load.o'
entry=next(x for x in json.loads((base/'build/release/compile_commands.json').read_text())
           if x['file'].endswith('/src/driver/main.cpp'))
original=entry.get('arguments') or shlex.split(entry['command'])
compile_args=[];skip=False
for token in original:
    if skip:skip=False;continue
    if token in ['-o','-MF','-MT','-MQ']:skip=True;continue
    if token in ['-c','-MD','-MMD','-MP',entry['file']]:continue
    compile_args.append(token)
compile_args+=['-c',str(source),'-o',str(obj)]
subprocess.run(compile_args,cwd=entry['directory'],check=True)
for name,work in variants.items():
    build=work/'build/release'
    lines=subprocess.check_output(['ninja','-t','commands','src/driver/kirimasim'],
                                  cwd=build,text=True).splitlines()
    tokens=shlex.split(lines[-1])
    while tokens[0] in [':','&&']:tokens.pop(0)
    if '&&' in tokens:tokens=tokens[:tokens.index('&&')]
    tokens=[str(obj) if x.endswith('kirimasim.dir/main.cpp.o') else x for x in tokens]
    tokens[tokens.index('-o')+1]=str(here/('metadata-load-'+name))
    subprocess.run(tokens,cwd=build,check=True)
    r=subprocess.run([str(here/('metadata-load-'+name)),'10'],
                     capture_output=True,text=True,check=True)
    print(name,r.stdout.strip(),flush=True)
