#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Resolve once, then prepare release binaries serially; never inspect OSS source."""
import argparse
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import time
import tempfile

from daily_benchmark import config_at, identity, machine_lock, now, write_json
from benchmark_compare import digest

ROOT=Path(__file__).resolve().parent.parent


def command(args,cwd=None,log=None):
    result=subprocess.run(args,cwd=cwd,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=3600)
    if log:
        text=result.stdout.replace(str(Path.home()),'${HOME}')
        text=re.sub(r'/(?:private/)?(?:tmp|var/folders)/[^\s]+','${TEMP}',text)
        with Path(log).open('a') as stream:
            stream.write('$ '+' '.join(Path(a).name if a.startswith('/') else a for a in args)+'\n'+text)
    if result.returncode:
        raise ValueError('command failed: '+Path(args[0]).name+'; see build artifact')
    return result.stdout.strip()


def resolve(config):
    output=command(['git','ls-remote','--exit-code',config['latest_repository'],config['latest_ref']])
    sha=output.split()[0]
    if not re.fullmatch('[0-9a-f]{40}',sha):
        raise ValueError('could not resolve latest commit')
    return {'schema':1,'resolved_at':now(),'latest_commit':sha,'config_sha256':digest(ROOT/'bench/daily.json')}


def checkout(repository,commit,path,log):
    path.mkdir(parents=True,exist_ok=True)
    command(['git','init','-q',str(path)],log=log)
    command(['git','fetch','-q','--depth','1',repository,commit],cwd=path,log=log)
    command(['git','checkout','-q','--detach','FETCH_HEAD'],cwd=path,log=log)
    if command(['git','rev-parse','HEAD'],cwd=path)!=commit:
        raise ValueError('checkout commit mismatch')


def prepare(args,config):
    plan=json.loads(args.plan.read_text())
    if plan['config_sha256']!=digest(ROOT/'bench/daily.json'):
        raise ValueError('definition changed since resolution')
    args.root.mkdir(parents=True,exist_ok=True)
    args.install.mkdir(parents=True,exist_ok=True)
    compiler=command([os.environ.get('CXX','c++'),'--version']).splitlines()[0]
    c_compiler=command([os.environ.get('CC','cc'),'--version']).splitlines()[0]
    flags={'CC':os.environ.get('CC','cc'),'CXX':os.environ.get('CXX','c++'),'CFLAGS':os.environ.get('CFLAGS',''),'CXXFLAGS':os.environ.get('CXXFLAGS',''),
           'preset':'release','cmake':'-O3 -DNDEBUG -ffp-contract=off, no fast-math','make_jobs':args.jobs}
    tools={}
    for name,spec in config['tools'].items():
        commit=plan['latest_commit'] if name=='latest' else spec['commit']
        repository=config['latest_repository'] if name=='latest' else spec['repository']
        prefix=args.install/name
        executable=prefix/('bin/iverilog' if name=='icarus' else 'bin/verilator' if name=='verilator' else 'bin/kirimasim')
        receipt=prefix/'receipt.json'
        cache_identity=identity({'commit':commit,'compiler':compiler,'c_compiler':c_compiler,'flags':flags,
            'os':platform.platform(),'arch':platform.machine(),'setup_sha256':digest(__file__)})
        previous=json.loads(receipt.read_text()) if receipt.exists() else None
        cached=bool(previous and previous['cache_identity']==cache_identity and executable.exists() and previous['binary_sha256']==digest(executable))
        if name=='icarus' and cached:
            cached=previous.get('vvp_sha256')==digest(executable.with_name('vvp'))
        if cached:
            cached=all((prefix/p).is_file() and digest(prefix/p)==h for p,h in previous.get('components_sha256',{}).items()) and bool(previous.get('components_sha256'))
        start=time.monotonic()
        if not cached:
            source=args.root/('source-'+name)
            log=args.root/(name+'-build.log')
            checkout(repository,commit,source,log)
            prefix.mkdir(parents=True,exist_ok=True)
            if spec['kind']=='kirimasim':
                command(['cmake','--preset','release'],source,log)
                command(['cmake','--build','--preset','release','--target','kirimasim','--parallel',str(args.jobs)],source,log)
                command(['python3','tools/check_release_flags.py'],source,log)
                executable.parent.mkdir(parents=True,exist_ok=True)
                shutil.copy2(source/'build/release/src/driver/kirimasim',executable)
            else:
                # Build-only black boxes: no source text or upstream tests are read.
                command(['sh','autoconf.sh'] if name=='icarus' else ['autoconf'],source,log)
                options=['./configure','--prefix='+str(prefix.resolve())]
                command(options,source,log)
                command(['make','-j'+str(args.jobs)],source,log)
                command(['make','install'],source,log)
            previous={'cache_identity':cache_identity,'commit':commit,'binary_sha256':digest(executable),
                'build':{'seconds':time.monotonic()-start,'compiler':compiler,'c_compiler':c_compiler,'flags':flags,'finished_at':now()}}
            if name=='icarus':
                previous['vvp_sha256']=digest(executable.with_name('vvp'))
            previous['components_sha256']={p.relative_to(prefix).as_posix():digest(p) for p in prefix.rglob('*') if p.is_file() and p!=receipt}
            write_json(receipt,previous)
        tools[name]={**previous,'executable':str(executable.resolve()),'cache_hit':cached}
    benchmark=args.root/'benchmark-definition'
    checkout(config['benchmark_source']['repository'],config['benchmark_source']['commit'],benchmark,args.root/'definition-checkout.log')
    write_json(args.out,{'schema':1,'latest_commit':plan['latest_commit'],'resolved_at':plan['resolved_at'],
                         'benchmark_root':str(benchmark.resolve()),'tools':tools})


def main():
    p=argparse.ArgumentParser(description=__doc__)
    sub=p.add_subparsers(dest='command',required=True)
    r=sub.add_parser('resolve');r.add_argument('--out',type=Path,required=True)
    b=sub.add_parser('prepare');b.add_argument('--plan',type=Path,required=True);b.add_argument('--root',type=Path,required=True)
    b.add_argument('--install',type=Path,required=True);b.add_argument('--out',type=Path,required=True);b.add_argument('--jobs',type=int,default=2);b.add_argument('--lock',type=Path,default=Path(tempfile.gettempdir())/'kirimasim-benchmark.lock')
    args=p.parse_args();config=config_at(ROOT/'bench/daily.json')
    if args.command=='resolve':
        plan=resolve(config);write_json(args.out,plan)
        print(plan['latest_commit'])
    else:
        with machine_lock(args.lock):
            prepare(args,config)


if __name__=='__main__':
    main()
