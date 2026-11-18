#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Validated serial campaigns. Uses benchmark_compare and the pinned bench adapter."""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import re
import signal
import statistics
import subprocess
import tempfile
import threading
import time
import uuid

import benchmark_compare as shared

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = ROOT / 'bench/daily.json'
BAD = {'output_mismatch', 'build_failed', 'run_failed', 'timeout'}


def now():
    return datetime.now(timezone.utc).isoformat()


def identity(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'), allow_nan=False).encode()).hexdigest()


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(value, indent=2, allow_nan=False) + '\n')
    temporary.replace(path)


def config_at(path, profile='daily'):
    config = json.loads(Path(path).read_text())
    profiles = config.pop('profiles', None)
    if profiles is not None:
        if profile not in profiles:
            raise ValueError('unknown benchmark profile')
        selected = profiles[profile]
        cases = {c['name']: c for c in config['cases']}
        groups = {g['name']: g for g in config['groups']}
        if len(cases) != len(config['cases']) or len(groups) != len(config['groups']):
            raise ValueError('duplicate manifest entry')
        if (len(set(selected['cases'])) != len(selected['cases']) or
            len(set(selected['groups'])) != len(selected['groups']) or
            not set(selected['cases']) <= cases.keys() or not set(selected['groups']) <= groups.keys()):
            raise ValueError('invalid profile selection')
        config.update(definition=selected['definition'], profile=profile,
                      cases=[cases[name] for name in selected['cases']],
                      groups=[groups[name] for name in selected['groups']])
    elif profile != 'daily':
        raise ValueError('definition has no weekly profile')
    if config['schema'] != 1 or config['measurement']['runs'] != 5:
        raise ValueError('unsupported definition or formal repetition count')
    names = [c['name'] for c in config['cases']]
    if len(names) != len(set(names)) or not names:
        raise ValueError('empty or duplicate cases')
    for c in config['cases']:
        if c['count'] <= 1 or not re.fullmatch(r'[a-z0-9_]+', c['name']):
            raise ValueError('invalid case')
        for key, n in [('expected', c['count']), ('expected_small', 1)]:
            if not c[key].startswith(f"{c['name']} n={n} "):
                raise ValueError('missing fixed expectation or incorrect count')
    for g in config['groups']:
        if not g['cases'] or len(g['cases']) != len(set(g['cases'])) or not set(g['cases']) <= set(names):
            raise ValueError('invalid fixed comparison group')
        if g['peer'] not in config['tools'] or g['peer'] == 'latest':
            raise ValueError('invalid comparison peer')
    return config


@contextmanager
def machine_lock(path):
    """A shared local lock also prevents overlapping CLI campaigns on fixed hosts."""
    import fcntl
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise ValueError('another benchmark owns the measurement lock') from error
        yield


class Adapter:
    """Reuse preparation, result extraction and RSS observation; bound process trees.

    Builds finish serially. Verilator's existing preparation is retained with
    explicit single-thread/build-job settings. No simulator source is inspected.
    """
    def __init__(self, module, timeout, logs, clean):
        self.module, self.timeout, self.logs, self.clean = module, timeout, Path(logs), clean
        self.logs.mkdir(parents=True, exist_ok=True)
        self.number = 0
        original = module.build_steps

        def build_steps(steps, work, env=None):
            steps = [list(s) for s in steps]
            for step in steps:
                if '--build-jobs' in step:
                    step[step.index('--build-jobs') + 1] = '1'
                    step += ['--threads', '1']
            return original(steps, work, env)
        module.build_steps = build_steps
        module.run = self.run

    def prepare(self, *args):
        return self.module.prepare(*args)

    def sample(self, name, result):
        sample = self.module.sample(name, result)
        sample['result_line_count'] = sum(line.startswith(name + ' ') for line in result['stdout'].splitlines())
        sample['correctness_checked'] = True
        return sample

    def run(self, command, work, env=None):
        # stdout is a file, so a timed-out compiler's descendants cannot keep a
        # pipe open. Killing the process group also stops make/compiler children.
        stopped, done, peak = threading.Event(), threading.Event(), [None]
        with tempfile.TemporaryFile() as stdout, tempfile.TemporaryFile() as stderr:
            start = time.monotonic()
            process = subprocess.Popen(command, cwd=work, env=env, stdout=stdout, stderr=stderr,
                                       start_new_session=True)
            def stop():
                stopped.set()
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            timer = threading.Timer(self.timeout, stop)
            timer.start()
            watcher = None
            if platform.system() == 'Linux':
                watcher = threading.Thread(target=self.module.watch_peak,
                                           args=(process.pid, Path(command[0]).name, done, peak))
                watcher.start()
            try:
                _, status, usage = os.wait4(process.pid, 0)
                elapsed = time.monotonic() - start
            except BaseException:
                stop()
                try:
                    os.wait4(process.pid,0)
                except ChildProcessError:
                    pass
                process.returncode = -signal.SIGKILL
                raise
            finally:
                timer.cancel()
                done.set()
                if watcher:
                    watcher.join()
            process.returncode = os.waitstatus_to_exitcode(status)
            stdout.seek(0); stderr.seek(0)
            output, messages = stdout.read().decode(errors='replace'), stderr.read().decode(errors='replace')
        self.number += 1
        log = {'command': command, 'stdout': output, 'stderr': messages}
        linux = platform.system() == 'Linux'
        rss = (None if peak[0] is None else peak[0]/1024) if linux else usage.ru_maxrss/(1 << 20)
        log.update({'seconds':elapsed,'max_rss_mib':rss,'exit_code':process.returncode,'timed_out':stopped.is_set()})
        write_json(self.logs / f'{self.number:05d}.json', self.clean(log, work))
        return {'seconds': elapsed, 'max_rss_mib': rss, 'rss_source': 'VmHWM sampled 10ms' if linux else 'wait4 ru_maxrss',
                'exit_code': process.returncode, 'timed_out': stopped.is_set(), 'stdout': output, 'stderr': messages}


def status(record):
    error = record.get('error')
    if error:
        if error['stage'] == 'unsupported':
            return 'unsupported'
        samples = [record.get('warmup'), *record['samples']['small'], *record['samples']['large']]
        if any(s and s.get('timed_out') for s in samples) or any(s.get('timed_out') for s in (record.get('build') or {}).get('steps', [])):
            return 'timeout'
        if error['stage'] == 'build':
            return 'build_failed'
        if any(s and s.get('exit_code') != 0 for s in samples):
            return 'run_failed'
        if error.get('status') == 'run_failed':
            return 'run_failed'
        return 'output_mismatch' if error['stage'] != 'aggregation' else 'incomparable'
    delta = record.get('incremental_seconds')
    return 'measured' if delta is not None and math.isfinite(delta) and delta > 0 else 'incomparable'


def summarize(result, config):
    rows = {case['name']: case for case in result['cases']}
    valid_campaign = result.get('inputs_unchanged', False) and result.get('completed_at') is not None and not result.get('infrastructure_error')
    for case in rows.values():
        for record in case['tools'].values():
            record['status'] = status(record)
            record['warnings'] = []
            if record.get('error'):
                for key in ('small_seconds','large_seconds','incremental_seconds','median_peak_rss_mib'):
                    record.pop(key,None)
            delta = record.get('incremental_seconds')
            if record['status'] == 'incomparable' and not record.get('error'):
                record['reason'] = 'non-positive or non-finite incremental elapsed time'
            if record['status'] == 'measured':
                if delta < config['measurement']['short_seconds']:
                    record['warnings'].append('short incremental time; sensitive to timing noise')
                if delta <= 5 * max(record['small_seconds']['mad'], record['large_seconds']['mad']):
                    record['warnings'].append('incremental time is close to observed dispersion')
        case['ratios'] = {}
        for peer in config['tools']:
            if peer == 'latest':
                continue
            a, b = case['tools']['latest'], case['tools'][peer]
            ratio = a['incremental_seconds']/b['incremental_seconds'] if valid_campaign and a['status'] == b['status'] == 'measured' else None
            case['ratios'][peer] = ratio if ratio is not None and math.isfinite(ratio) and ratio > 0 else None
    groups = []
    for group in config['groups']:
        ratios = [rows.get(name, {}).get('ratios', {}).get(group['peer']) for name in group['cases']]
        complete = valid_campaign and all(r is not None and math.isfinite(r) and r > 0 for r in ratios)
        mean = math.exp(statistics.mean(math.log(r) for r in ratios)) if complete else None
        groups.append({**group, 'expected_count': len(ratios), 'available_count': sum(r is not None for r in ratios),
                       'ratio': mean, 'warning': bool(group['peer'] == 'baseline' and mean is not None and mean > config['measurement']['regression_warning_ratio']),
                       'reason': None if complete else 'fixed comparison set incomplete or campaign invalid'})
    result['groups'] = groups
    result['status'] = ('smoke_failed' if result.get('mode')=='smoke' and any(r['status'] in BAD for c in rows.values() for r in c['tools'].values()) else
                        'smoke_complete' if result.get('mode')=='smoke' and valid_campaign else
                        'infrastructure_failed' if not valid_campaign else
                        'correctness_or_execution_failed' if any(r['status'] in BAD for c in rows.values() for r in c['tools'].values()) else
                        'incomplete' if any(g['ratio'] is None for g in groups) else 'complete')
    result['ratio_definition'] = 'latest kirimasim incremental elapsed / peer incremental elapsed; below 1 favors latest'
    return result


def measure(args):
    config = config_at(args.config, args.profile)
    args.out.mkdir(parents=True, exist_ok=True)
    if (args.out/'results.json').exists():
        raise ValueError('output already contains a campaign; choose a new directory')
    inventory = json.loads(args.inventory.read_text()) if args.inventory else None
    benchmark_root = Path(inventory['benchmark_root'] if inventory else args.benchmark_root).resolve()
    executables = dict(s.split('=', 1) for s in args.tool)
    if inventory:
        executables.update({k:v['executable'] for k,v in inventory['tools'].items()})
    if set(executables) != set(config['tools']):
        raise ValueError('provide executables for every configured tool: '+', '.join(config['tools']))
    executables = {k:shared.executable(v) for k,v in executables.items()}
    latest = inventory['latest_commit'] if inventory else args.latest_commit
    if not latest or not re.fullmatch('[0-9a-f]{40}', latest):
        raise ValueError('latest commit must be resolved once to a full SHA')
    if shared.git_revision(benchmark_root) != config['benchmark_source']['commit']:
        raise ValueError('benchmark checkout differs from the fixed definition commit')
    source = benchmark_root/'tools/bench.py'
    if shared.digest(source) != config['benchmark_source']['adapter_sha256']:
        raise ValueError('pinned adapter hash differs')
    adapter_module = shared.load_adapter(benchmark_root)
    replacements = {str(Path.home()): '${HOME}', str(benchmark_root): '${BENCHMARK_ROOT}', str(ROOT): '${SUITE}', str(args.out.resolve()): '${OUTPUT}'}
    if inventory:
        replacements[str(args.inventory.resolve().parent)] = '${BUILD_ROOT}'
    replacements.update({path: '${'+key.upper()+'}' for key,path in executables.items()})
    def clean(value, work):
        text = json.dumps(value)
        for old,new in sorted({**replacements, str(work): '${WORK}'}.items(), key=lambda x:-len(x[0])):
            text = text.replace(old,new)
        text = re.sub(r'/(?:Users|home)/[^/\\\s"\']+', '${HOME}', text)
        text = re.sub(r'/(?:private/)?(?:tmp|var/folders)/[^\s"\']+', '${TEMP}', text)
        return json.loads(text)
    external_commits=dict(s.split('=',1) for s in args.tool_commit)
    if not set(external_commits)<={name for name,spec in config['tools'].items() if spec.get('ref')}:
        raise ValueError('--tool-commit is only for configured tracking tools')
    tools = {}
    protected = {str(Path(__file__)): shared.digest(__file__), str(ROOT/'tools/benchmark_compare.py'):shared.digest(ROOT/'tools/benchmark_compare.py'), str(ROOT/'tools/benchmark_history.py'):shared.digest(ROOT/'tools/benchmark_history.py'), str(args.config.resolve()): shared.digest(args.config), str(source): shared.digest(source)}
    for name, executable in executables.items():
        kind = config['tools'][name]['kind']
        flag = '-V' if kind == 'icarus' else '--version'
        version = adapter_module.text_of([executable, flag])
        spec=config['tools'][name]
        if name=='latest':
            commit=latest
        elif spec.get('ref'):
            commit=inventory['tools'][name]['commit'] if inventory else external_commits.get(name)
        else:
            commit=spec['commit']
        if not commit or not re.fullmatch('[0-9a-f]{40}',commit):
            raise ValueError(name+' commit must be resolved once to a full SHA')
        if kind == 'kirimasim' and commit[:12] not in version:
            raise ValueError(name+' version does not match declared commit')
        if kind=='icarus' and spec.get('ref') and commit[:7] not in version:
            raise ValueError(name+' development version does not match declared commit')
        pattern = config['tools'][name].get('version_pattern')
        if pattern and not re.search(pattern, version):
            raise ValueError(name+' does not match the configured version family')
        binary_hash = shared.digest(executable)
        if inventory and (inventory['tools'][name]['commit'] != commit or inventory['tools'][name]['binary_sha256'] != binary_hash):
            raise ValueError('prepared binary receipt mismatch')
        protected[executable] = binary_hash
        tools[name] = {'kind':kind,'commit':commit,'version':version,'binary_sha256':binary_hash,
                       'simulator_build':inventory['tools'][name]['build'] if inventory else {'provenance':'externally supplied; verify build flags separately'}}
    for name,executable in executables.items():
        companion={'icarus':'vvp','verilator':'verilator_bin'}.get(config['tools'][name]['kind'])
        if companion:
            path=Path(executable).with_name(companion)
            protected[str(path)]=shared.digest(path)
            tools[name][companion+'_sha256']=protected[str(path)]
    selected = config['cases']
    if args.only:
        if not args.smoke or not set(args.only) <= {c['name'] for c in selected}:
            raise ValueError('--only is restricted to smoke and known cases')
        selected = [c for c in selected if c['name'] in args.only]
    cases = []
    for path, expected in config.get('reference_sources', {}).items():
        reference = ROOT/path
        if shared.digest(reference) != expected:
            raise ValueError('reference source differs from frozen definition')
        protected[str(reference)] = expected
    for c in selected:
        path = (benchmark_root if c['source']=='kirimasim' else ROOT)/c['path']
        if shared.digest(path) != c['sha256']:
            raise ValueError(c['name']+' source differs from frozen definition')
        protected[str(path)] = c['sha256']
        cases.append({**c,'path':path})
    machine = adapter_module.machine()
    machine['architecture'] = platform.machine()
    compiler = adapter_module.text_of([os.environ.get('CXX','c++'), '--version'])
    conditions = {'machine':{k:v for k,v in machine.items() if k!='load_average'}, 'compiler':compiler,
                  'profile':config.get('profile', 'daily'),
                  'environment':args.environment,'image_os':os.environ.get('ImageOS'), 'image_version':os.environ.get('ImageVersion'),
                  'settings':config['measurement'], 'mode':'smoke' if args.smoke else 'formal',
                  'runs':1 if args.smoke else config['measurement']['runs'],
                  'tool_builds':{name:{key:value for key,value in tool['simulator_build'].items() if key in ('compiler','c_compiler','flags','provenance')} for name,tool in tools.items()},
                  'verilator_options':'--binary --timing --threads 1 --build-jobs 1; default C++ optimization; assertions/tracing off',
                  'icarus_options':'-g2012; vvp -n; single process', 'kirimasim_options':'default four-state; interpreter; no waveform/assertion request'}
    definition = {'config_sha256':shared.digest(args.config),'driver_sha256':shared.digest(__file__),
                  'comparison_sha256':shared.digest(ROOT/'tools/benchmark_compare.py'),
                  'history_sha256':shared.digest(ROOT/'tools/benchmark_history.py'),
                  'setup_sha256':shared.digest(ROOT/'tools/benchmark_setup.py'),
                  'adapter_sha256':shared.digest(source),'benchmark_commit':config['benchmark_source']['commit'],
                  'reference_sha256':config.get('reference_sources', {})}
    run_id = args.run_id or ('local-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S')+'-'+uuid.uuid4().hex[:12])
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,100}',run_id):
        raise ValueError('invalid run identifier')
    result = {'schema':1,'id':run_id,'started_at':now(),'completed_at':None,'mode':conditions['mode'],
              'suite_commit':shared.git_revision(ROOT),'latest_resolved_at':inventory.get('resolved_at') if inventory else None,'actions':{'run_id':os.environ.get('GITHUB_RUN_ID'), 'attempt':os.environ.get('GITHUB_RUN_ATTEMPT'),
              'url':args.run_url},'environment':conditions,'machine_start':machine,'tools':tools,'definition':definition,
              'definition_config':config,'series':identity({'definition':definition,'conditions':conditions}),
              'metric':'incremental elapsed = median T(N) - median T(1); not isolated simulation CPU time',
              'execution':'serial; tool order reverses by case/round; count order reverses by round; one n=1 warmup',
              'cases':[],'inputs_unchanged':True}
    adapter = Adapter(adapter_module,config['measurement']['timeout_seconds'],args.out/'logs',clean)
    with machine_lock(args.lock):
        if (args.out/'results.json').exists():
            raise ValueError('output already contains a campaign; choose a new directory')
        write_json(args.out/'results.json',clean(result,args.out))
        try:
            for index,case in enumerate(cases):
                print(f"{index+1}/{len(cases)} {case['name']}",flush=True)
                row = shared.collect_case(case,adapter,executables,conditions['runs'],index,clean,
                    tool_kinds={k:v['kind'] for k,v in tools.items()},unsupported=case.get('unsupported',{}),strict=True)
                result['cases'].append(row)
                result['inputs_unchanged'] = all(shared.digest(p)==h for p,h in protected.items())
                write_json(args.out/'results.json',clean(result,args.out))
                if not result['inputs_unchanged']:
                    raise ValueError('inputs changed during measurement')
            result['completed_at'] = now()
        except (OSError,ValueError,KeyboardInterrupt) as error:
            result['infrastructure_error'] = clean(str(error) or type(error).__name__,args.out)
        finally:
            result['machine_end'] = adapter_module.machine()
            summarize(result,config)
            write_json(args.out/'results.json',clean(result,args.out))
    print(result['status'],flush=True)
    return 2 if result['status']=='infrastructure_failed' else int(result['status'] in ('correctness_or_execution_failed','smoke_failed'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,default=DEFAULT_CONFIG)
    p.add_argument('--profile',choices=['daily','weekly'],default='daily')
    p.add_argument('--inventory',type=Path)
    p.add_argument('--benchmark-root',type=Path)
    p.add_argument('--tool',action='append',default=[],metavar='NAME=EXECUTABLE')
    p.add_argument('--tool-commit',action='append',default=[],metavar='NAME=SHA',help='resolved full SHA for externally supplied tracking tools')
    p.add_argument('--latest-commit')
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--smoke',action='store_true')
    p.add_argument('--only',nargs='+')
    p.add_argument('--environment',default='local-reference',help='non-identifying measurement profile')
    p.add_argument('--run-id')
    p.add_argument('--run-url')
    p.add_argument('--lock',type=Path,default=Path(tempfile.gettempdir())/'kirimasim-benchmark.lock')
    args = p.parse_args()
    try:
        return measure(args)
    except (ValueError,OSError,KeyError) as error:
        p.exit(2,str(error)+'\n')


if __name__=='__main__':
    raise SystemExit(main())
