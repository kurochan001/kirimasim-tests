#!/usr/bin/env python3
"""Serial three-build orchestration using kirimasim-tests' measurement functions."""
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import argparse
import threading
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--test-repo', type=Path, required=True)
parser.add_argument('--current-source', type=Path, required=True)
parser.add_argument('--baseline-source', type=Path, required=True)
parser.add_argument('--iverilog', type=Path, required=True)
parser.add_argument('--current-commit', required=True)
parser.add_argument('--baseline-commit', default='c152d237ac8dbd1b81349e7d578c25504d4ae8d5')
parser.add_argument('--icarus-commit', default='1eba3690d8314d79927df8690a7d97642dd93ce0')
parser.add_argument('--runs', type=int, default=5)
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--allow-external-work', action='store_true')
args = parser.parse_args()
if args.runs < 1:
    parser.error('--runs must be positive')
OUT = args.out.resolve()
OUT.mkdir(parents=True, exist_ok=True)
TESTS = args.test_repo.resolve()
ROOT = args.current_source.resolve()
BASE = args.baseline_source.resolve()
ICARUS = args.iverilog.resolve()
COMMITS = {'baseline': args.baseline_commit, 'kirimasim': args.current_commit, 'icarus': args.icarus_commit}
EXECUTABLES = {'baseline': str(BASE/'build/release/src/driver/kirimasim'),
               'kirimasim': str(ROOT/'build/release/src/driver/kirimasim'),
               'icarus': str(ICARUS)}
RUNS = args.runs

def load(path,name):
    spec=importlib.util.spec_from_file_location(name,path)
    mod=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

def revision(root):
    return subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()

def dirty(root):
    return bool(subprocess.check_output(['git','-C',str(root),'status','--porcelain'],text=True).strip())

def external_work():
    raw=subprocess.check_output(['ps','-A','-o','pid=,ppid=,comm='],text=True)
    rows={}
    for line in raw.splitlines():
        fields=line.strip().split(None,2)
        if len(fields)==3:
            rows[int(fields[0])]=(int(fields[1]),Path(fields[2]).name)
    observed=[]
    for pid,(parent,name) in rows.items():
        if not (name in {'ctest','kirimasim','iverilog','vvp','ninja','clang','clang++','clang-tidy','verilator','lyra','cmake'} or name.startswith('clang-')):
            continue
        chain={pid}
        while parent in rows and parent not in chain:
            chain.add(parent)
            parent=rows[parent][0]
        if os.getpid() not in chain:
            observed.append(name)
    return sorted(observed)

mod=load(TESTS/'tools/benchmark_compare.py','comparison')
adapter=mod.load_adapter(ROOT)
real_prepare=adapter.prepare
adapter.prepare=lambda tool,exe,design,work: real_prepare('kirimasim' if tool=='baseline' else tool,exe,design,work)
real_run,real_sample=adapter.run,adapter.sample

def measured_run(command,cwd,env=None):
    before=list(os.getloadavg())
    result=real_run(command,cwd,env)
    result['load_average_before']=before
    result['load_average_after']=list(os.getloadavg())
    return result

def measured_sample(name,result):
    sample=real_sample(name,result)
    sample['load_average_before']=result['load_average_before']
    sample['load_average_after']=result['load_average_after']
    return sample

adapter.run=measured_run
adapter.sample=measured_sample
cases=[mod.case_description(p.resolve(),adapter,'kirimasim/bench/'+p.name) for p in sorted((ROOT/'bench').glob('*.sv'))]
cases.append(mod.case_description(TESTS/'bench/fourstate_mix.sv',adapter,'kirimasim-tests/bench/fourstate_mix.sv'))
assert len(cases)==13 and len({c['name'] for c in cases})==13
assert revision(BASE)==COMMITS['baseline'] and revision(ROOT)==COMMITS['kirimasim']
assert not dirty(BASE) and not dirty(ROOT) and not dirty(TESTS)
versions={name:adapter.text_of([exe,'-V' if name=='icarus' else '--version']) for name,exe in EXECUTABLES.items()}
for name,commit in COMMITS.items():
    assert commit[:7] in versions[name], (name,versions[name])
vvp=str(ICARUS.with_name('vvp'))
protected=[Path(__file__),TESTS/'tools/benchmark_compare.py',ROOT/'tools/bench.py',*map(Path,EXECUTABLES.values()),Path(vvp),*(c['path'] for c in cases)]
protected += [p/f for p in [BASE,ROOT] for f in ['src/kernel/wide.cpp','src/vm/vm.cpp']]
fingerprints={str(p):mod.digest(p) for p in protected}
replacements={str(ROOT):'${CURRENT_SOURCE}',str(BASE):'${BASELINE_SOURCE}',str(TESTS):'${TEST_REPO}',str(Path.home()):'${HOME}',**{p:'${'+n.upper()+'}' for n,p in {**EXECUTABLES,'vvp':vvp}.items()}}

def clean(value,work):
    if value is None: return None
    encoded=json.dumps(value)
    for old,new in sorted({**replacements,str(work):'${WORK}'}.items(),key=lambda x:-len(x[0])):
        encoded=encoded.replace(old,new)
    return json.loads(encoded)

result={'schema':1,'started_at':datetime.now(timezone.utc).isoformat(),'runs':RUNS,'warmups':1,
        'metric':'median(T(N)) - median(T(1)), seconds; no extrapolation',
        'execution':'serial; three-tool order rotates per case and reverses per round; count order alternates per round',
        'measurement_functions':'kirimasim-tests/tools/benchmark_compare.py: collect_case, check_sample, aggregate; baseline aliases the kirimasim adapter',
        'pinned_commits':COMMITS,'test_repository_commit':revision(TESTS),'versions':versions,
        'binary_sha256':{name:mod.digest(exe) for name,exe in {**EXECUTABLES,'vvp':vvp}.items()},
        'driver_sha256':mod.digest(TESTS/'tools/benchmark_compare.py'),'adapter_sha256':mod.digest(ROOT/'tools/bench.py'),
        'orchestrator_sha256':mod.digest(__file__),'machine_start':adapter.machine(),
        'external_work_observed':[],'cases':[],
        'measurement_status':'provisional: concurrent local CI is permitted' if '--allow-external-work' in sys.argv else 'quiet-start requested'}
stop=threading.Event()

def monitor():
    last=[]
    while not stop.wait(2):
        jobs=external_work()
        if jobs!=last and jobs:
            result['external_work_observed'].append({'at':datetime.now(timezone.utc).isoformat(),'jobs':jobs})
            print('External work observed:',','.join(jobs),flush=True)
        last=jobs

if '--allow-external-work' not in sys.argv:
    while jobs:=external_work():
        print('Waiting for external work:',','.join(jobs),flush=True)
        time.sleep(5)
else:
    jobs=external_work()
    print('Provisional campaign: concurrent work permitted:',','.join(jobs),flush=True)
    if jobs:
        result['external_work_observed'].append({'at':datetime.now(timezone.utc).isoformat(),'jobs':jobs})
watch=threading.Thread(target=monitor,daemon=True)
watch.start()
try:
    for index,case in enumerate(cases):
        order=('baseline','kirimasim','icarus')
        turn=index%len(order)
        mod.TOOLS=order[turn:]+order[:turn]
        print(f"{index+1}/13 {case['name']} n={case['count']} order={','.join(mod.TOOLS)} starting",flush=True)
        row=mod.collect_case(case,adapter,EXECUTABLES,RUNS,index,clean)
        row['tool_order_first_round']=list(mod.TOOLS if index%2==0 else reversed(mod.TOOLS))
        records=row['tools']
        valid=not any(rec.get('error') for rec in records.values())
        if valid:
            ds={name:rec['incremental_seconds'] for name,rec in records.items()}
            assert all(x>0 for x in ds.values())
            row['comparisons']={'current_over_icarus':ds['kirimasim']/ds['icarus'],
                                'baseline_over_icarus':ds['baseline']/ds['icarus'],
                                'current_over_baseline':ds['kirimasim']/ds['baseline'],
                                'time_reduction_percent':(1-ds['kirimasim']/ds['baseline'])*100}
        else:
            row['comparisons']=None
        result['cases'].append(row)
        result['inputs_unchanged']=all(mod.digest(p)==digest for p,digest in fingerprints.items())
        assert result['inputs_unchanged'],'Input or binary changed during the campaign'
        (OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n')
        print(case['name'],json.dumps(row['comparisons']),flush=True)
        if not valid:
            raise RuntimeError('Correctness or execution check failed')
finally:
    stop.set()
    watch.join()
result['completed_at']=datetime.now(timezone.utc).isoformat()
result['machine_end']=adapter.machine()
assert revision(BASE)==COMMITS['baseline'] and revision(ROOT)==COMMITS['kirimasim']
assert revision(TESTS)==result['test_repository_commit']
assert not dirty(BASE) and not dirty(ROOT) and not dirty(TESTS)
result['inputs_unchanged']=all(mod.digest(p)==digest for p,digest in fingerprints.items())
assert result['inputs_unchanged']
result['comparable_cases']=len(result['cases'])
result['geometric_mean_ratios']={key:math.exp(statistics.mean(math.log(row['comparisons'][key]) for row in result['cases'])) for key in ['current_over_icarus','baseline_over_icarus','current_over_baseline']}
result['all_outputs_match']=True
result['observed_external_benchmark_or_build_work']=bool(result['external_work_observed'])
(OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print('Completed:',json.dumps(result['geometric_mean_ratios']),flush=True)
