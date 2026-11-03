#!/usr/bin/env python3
"""Generate, run and replay bounded random comparisons against Python models.

Results have a separate schema and are not fixed-suite coverage evidence.
The caller resolves/builds the latest kirimasim commit immediately before a
run; --commit verifies that the supplied executable identifies that build.
"""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
import datetime
import hashlib
import json
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time

import normalize_output
import random_cross_compare as compare
import random_cross_evidence as evidence
import random_cross_history as history_store
import random_cross_identity as identity
import random_cross_models as models
import suite_results

ROOT = models.ROOT
SOURCES = ('tools/run_random_cross.py', 'tools/random_cross_models.py', 'tools/normalize_output.py',
           'tools/random_cross_compare.py', 'tools/random_cross_evidence.py',
           'tools/random_cross_history.py', 'tools/random_cross_identity.py',
           'tools/run_icarus.py', 'tools/run_verilator.py', 'tools/run_kirimasim.py',
           'tools/suite_results.py', 'generators/interaction_expr.py', 'generators/interaction_divide.py',
           'generators/interaction_bits.py', 'generators/interaction_cond.py',
           'generators/interaction_pkgwatch.py', 'generators/interaction_shift.py',
           'generators/interaction_stream.py', 'generators/interaction_concat.py',
           'generators/interaction_compare.py', 'generators/interaction_logic.py',
           'generators/interaction_cover.py', 'generators/common.py')
STATES = ('pass', 'fail', 'known', 'unsupported', 'not_run', 'stale')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def source_hashes():
    return {name: sha(ROOT/name) if (ROOT/name).is_file() else 'MISSING' for name in SOURCES}


def input_changed(record, output):
    try:
        return (sha(output/record['source']) != record['source_sha256']
                or sha(output/record['expected']) != record['expected_sha256']
                or evidence.input_digest(output/record['source'], output) != record['inputs_sha256'])
    except (OSError, ValueError):
        return True


def repository_revision():
    try:
        commit = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=ROOT, capture_output=True,
                                text=True, timeout=5, check=True).stdout.strip()
        changed = subprocess.run(['git', 'status', '--porcelain', '--', *SOURCES], cwd=ROOT,
                                 capture_output=True, text=True, timeout=5, check=True).stdout
        return {'commit': commit, 'source_changes': bool(changed.strip())}
    except (OSError, subprocess.SubprocessError):
        return {'commit': None, 'source_changes': None}


def normalize(text):
    return ''.join(line+'\n' for line in text.splitlines()
                   if line.strip() and not normalize_output.FINISH.match(line))


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n')


def prepare(manifest, output):
    return evidence.prepare(manifest, output)[0]


def verify_binary(binary, commit):
    if not re.fullmatch(r'[0-9a-f]{40}', commit or ''):
        raise ValueError('--commit must be the verified full upstream commit')
    resolved = shutil.which(str(binary))
    if not resolved:
        raise ValueError('cannot find kirimasim executable')
    executable = str(Path(resolved).resolve())
    before = sha(executable)
    result = subprocess.run([executable, '--version'], capture_output=True, text=True, timeout=15)
    version = (result.stdout or result.stderr).strip().splitlines()
    version = version[0] if version else ''
    found = re.search(r'\bcommit ([0-9a-f]{7,40})\b', version)
    if result.returncode or not version.startswith('kirimasim ') or not found or not commit.startswith(found[1]):
        raise ValueError('executable version does not identify --commit: '+version)
    if sha(executable) != before:
        raise ValueError('kirimasim changed while identifying its build')
    return {'executable': executable, 'version': version, 'commit': commit,
            'binary_sha256': before}


def execute(record, output, executable, timeout, deadline):
    remaining = deadline-time.monotonic()
    if remaining <= 0:
        return {'status': 'not_run', 'reason': 'run time budget exhausted', 'returncode': None}
    source = (output/record['source']).resolve()
    started = time.monotonic()
    with tempfile.TemporaryDirectory() as directory:
        try:
            result = subprocess.run([executable, str(source)], cwd=directory,
                                    capture_output=True, text=True, errors='replace',
                                    timeout=min(timeout, remaining))
            stdout, stderr, code = result.stdout, result.stderr, result.returncode
            unsupported = re.search(r'error: unsupported: (.*)', stderr)
            if code == 2 and unsupported:
                status, reason = 'unsupported', unsupported[1].strip()
            elif code != 0:
                status, reason = 'fail', f'exit code {code}'
            elif re.search(r'(?:^|\s)(?:error|fatal):', stderr):
                status, reason = 'fail', 'error diagnostic despite zero exit status'
            else:
                want = suite_results.expected_output(source, 'kirimasim')
                if want is None:
                    want = (output/record['expected']).read_text()
                got = normalize(stdout)
                status = 'pass' if got == want else 'fail'
                reason = '' if status == 'pass' else 'output differs: '+suite_results.first_difference(got, want)
        except subprocess.TimeoutExpired as error:
            stdout = error.stdout or b''
            stderr = error.stderr or b''
            stdout = stdout.decode(errors='replace') if isinstance(stdout, bytes) else stdout
            stderr = stderr.decode(errors='replace') if isinstance(stderr, bytes) else stderr
            code, status, reason = None, 'fail', 'timed out'
        except OSError as error:
            stdout, stderr, code, status, reason = '', str(error), None, 'fail', 'could not execute simulator'
    stem = source.with_suffix('')
    stem.with_suffix('.stdout').write_text(stdout)
    stem.with_suffix('.stderr').write_text(stderr)
    return {'status': status, 'reason': reason, 'returncode': code,
            'seconds': round(time.monotonic()-started, 6),
            'stdout': 'cases/'+stem.name+'.stdout', 'stderr': 'cases/'+stem.name+'.stderr'}


def markdown(report, japanese):
    counts = report['counts']
    lines = ['# 件数制限付きランダムクロス比較' if japanese else '# Bounded random cross comparison', '',
             ('実行していません。刺激と期待値の生成だけです。' if japanese else
              'Not executed: stimulus and expectation generation only.') if report['mode'] == 'generate-only' else
             ('全ケースの実行完了: ' if japanese else 'All cases completed: ')+str(report['completed']), '',
             f'Seed: `{report["seed"]}`', f'Cases: {report["case_count"]}',
             ' / '.join(f'{status}={counts[status]}' for status in STATES), '',
             ('固定回帰の本数・合格数・要求カバレッジには加算しません。' if japanese else
              'These samples are not added to fixed-suite counts, passes or requirement coverage.'),
             ('再現にはmanifest.jsonとcases/内のSV・期待値・出力を使います。' if japanese else
              'Replay uses manifest.json and the SV, expectations and output in cases/.'), '']
    if report.get('admission'):
        lines += ['Admission: `'+report['admission']['decision']+'`',
                  ('省略は今回のpassではありません。' if japanese else
                   'Admission skips are not passes in this execution.'), '']
    if report.get('build'):
        lines += ['Commit: `'+report['build']['commit']+'`', 'Version: `'+report['build']['version']+'`', '']
    for simulator, results in report.get('comparisons', {}).items():
        lines += [simulator+': '+str(dict(Counter(row['status'] for row in results.values()))), '']
    if report.get('replay'):
        lines += ['Replay reference: `'+report['replay']['policy']+'`; baseline: `'
                  +report['replay']['baseline']+'`',
                  'Reference drift: '+str(report.get('reference_drift', [])), '']
    for name, result in report['results'].items():
        if result['status'] != 'pass':
            lines.append(f'- `{name}`: {result["status"]}; `cases/{name}.sv`')
    return '\n'.join(lines).rstrip()+'\n'


def run(manifest, output, binary=None, commit=None, jobs=4, timeout=5, budget=120, generate_only=False,
        *, replay=None, reference_policy='saved', explore=False, history=None, force=False,
        run_kind='comparison', comparators=None, simulator_seed=1, dependency_files=(),
        dependencies_complete=False, workflow_run_id=None, workflow_run_attempt=None):
    models.integer(jobs, 1, 8, 'jobs')
    models.integer(timeout, 1, 30, 'timeout')
    models.integer(budget, 1, 600, 'time budget')
    if (history or force) and not explore:
        raise ValueError('--history/--force require --explore')
    if explore and (not history or generate_only):
        raise ValueError('--explore requires --history and execution')
    if history and Path(history).resolve().is_relative_to(output.resolve()):
        raise ValueError('history must be outside the immutable output artifact')
    models.integer(simulator_seed, 0, 2**31-1, 'simulator seed')
    if run_kind not in ('comparison', 'nightly'):
        raise ValueError('unknown run kind')
    before_sources = source_hashes()
    records, replay_info = evidence.prepare(manifest, output, replay, reference_policy)
    manifest_hash = sha(output/'manifest.json')
    report = {'schema': 'bounded-random-cross-run@1', 'mode': 'generate-only' if generate_only else 'comparison',
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'seed': manifest['seed'], 'generator': models.GENERATOR, 'case_count': len(records),
              'test_repository': repository_revision(),
              'manifest_sha256': manifest_hash, 'sources_sha256': before_sources,
              'limits': {'jobs': jobs, 'case_timeout_seconds': timeout, 'time_budget_seconds': budget},
              'completed': False, 'valid': True, 'counts': {state: 0 for state in STATES},
              'results': {}, 'inputs': records, 'run_kind': run_kind,
              'workflow': {'run_id': workflow_run_id, 'run_attempt': workflow_run_attempt},
              'required_simulators': ['kirimasim', *(comparators or {})],
              'comparisons': {}, 'replay': replay_info if replay else None}
    report['reference_drift'] = [name for name, row in replay_info['cases'].items()
                                 if row['source_changed'] or row['expected_changed']]
    if replay:
        original_sources = replay_info.get('origin_sources_sha256')
        replay_info['code_changed'] = None if original_sources is None else original_sources != before_sources
    store, admission = None, None
    write_json(output/'run.json', report)
    (output/'events.jsonl').touch()
    if generate_only:
        report['counts']['not_run'] = len(records)
    else:
        try:
            build = verify_binary(binary, commit)
            builds = {'kirimasim': build}
            for simulator, executable in (comparators or {}).items():
                if simulator not in ('icarus', 'verilator'):
                    raise ValueError('unsupported public comparator: '+simulator)
                builds[simulator] = identity.external_build(simulator, executable)
            report['build'], report['builds'] = build, builds
            inventory = identity.dependencies(builds, dependency_files, dependencies_complete)
            options = {**report['limits'], 'simulator_seed': simulator_seed,
                       'run_kind': run_kind, 'reference_policy': reference_policy,
                       'workflow': report['workflow'], 'required_simulators': list(builds)}
            execution_identity = identity.execution(manifest, records, before_sources, builds, inventory, options)
            report['execution_identity'] = execution_identity
            if explore and not replay and run_kind != 'nightly':
                if execution_identity['reusable_identity']:
                    store = history_store.History(history)
                    admission = store.admit(execution_identity['sha256'], output, force)
                else:
                    admission = {'decision': 'execute_unverified_dependencies',
                                 'reason': '; '.join(execution_identity['non_reuse_reasons'])}
            else:
                admission = {'decision': 'always_execute',
                             'reason': 'explicit replay or formal comparison/Nightly'}
            report['admission'] = admission
            if admission['decision'] in ('duplicate_completed', 'in_flight'):
                report['mode'] = 'admission-only'
                report['counts']['not_run'] = len(records)
                # A binary/input update racing admission is not evidence of a
                # duplicate current job. Fail closed and ask for a fresh run.
                if (not identity.unchanged(inventory) or source_hashes() != before_sources
                        or identity.environment() != execution_identity['details']['environment']
                        or sha(output/'manifest.json') != manifest_hash
                        or any(input_changed(record, output) for record in records.values())):
                    admission['decision'] = 'stale_admission'
                    admission['reason'] = 'execution identity changed during admission; retry in a new directory'
                    report['valid'] = False
            else:
                report['comparisons'] = {sim: {} for sim in builds}
                write_json(output/'run.json', report)
                deadline = time.monotonic()+budget
                with (output/'events.jsonl').open('w') as events, ThreadPoolExecutor(max_workers=jobs) as pool:
                    futures = {}
                    for simulator, sim_build in builds.items():
                        for name, record in records.items():
                            args = ((execute, record, output, sim_build['executable'], timeout, deadline)
                                    if simulator == 'kirimasim' else
                                    (compare.execute, record, output, simulator, sim_build,
                                     simulator_seed, timeout, deadline))
                            futures[pool.submit(*args)] = (simulator, name)
                    for future in as_completed(futures):
                        simulator, name = futures[future]
                        try:
                            result = future.result()
                        except Exception as error:
                            result = {'status': 'fail', 'reason': 'runner exception: '+str(error), 'returncode': None}
                        report['comparisons'][simulator][name] = result
                        events.write(json.dumps({'simulator': simulator, 'case': name, **result}, ensure_ascii=False)+'\n')
                        events.flush()
                report['binary_changed'] = any(not Path(b['executable']).is_file()
                                              or sha(b['executable']) != b['binary_sha256'] for b in builds.values())
                report['sources_changed'] = source_hashes() != before_sources
                report['manifest_changed'] = sha(output/'manifest.json') != manifest_hash
                report['dependencies_changed'] = not identity.unchanged(inventory)
                report['environment_changed'] = identity.environment() != execution_identity['details']['environment']
                changed = [name for name, record in records.items() if input_changed(record, output)]
                report['changed_inputs'] = changed
                global_change = any(report[key] for key in ('binary_changed', 'sources_changed', 'manifest_changed',
                                                             'dependencies_changed', 'environment_changed'))
                drift = report['reference_drift'] if replay and reference_policy == 'saved' else []
                report['valid'] = not (global_change or changed or drift)
                for results in report['comparisons'].values():
                    for name, result in results.items():
                        if global_change or name in changed or name in drift:
                            result['observed_status'] = result['status']
                            result['status'], result['reason'] = 'stale', 'input/reference, runner, environment or executable changed'
                report['results'] = {name: report['comparisons']['kirimasim'][name] for name in records}
                counts = Counter(result['status'] for result in report['results'].values())
                report['counts'] = {state: counts[state] for state in STATES}
                report['completed'] = all(len(results) == len(records) and all(row['status'] != 'not_run'
                                         for row in results.values()) for results in report['comparisons'].values())
        except BaseException as error:
            report['valid'], report['interrupted'] = False, True
            report['error'] = type(error).__name__+': '+str(error)
            for results in report['comparisons'].values():
                for name in records:
                    results.setdefault(name, {'status': 'not_run', 'reason': 'execution interrupted', 'returncode': None})
            report['results'] = report['comparisons'].get('kirimasim', {})
            counts = Counter(row['status'] for row in report['results'].values())
            report['counts'] = {state: counts[state] for state in STATES}
            if not report['results']:
                report['counts']['not_run'] = len(records)
            if store and admission:
                store.abort(admission)
            raise
        finally:
            save_report(output, report)
            if store and admission and not report.get('interrupted'):
                store.finish(admission, output, report)
    if generate_only:
        save_report(output, report)
    return report


def save_report(output, report):
    write_json(output/'run.json', report)
    for name, japanese in [('report.md', False), ('report.ja.md', True)]:
        (output/name).write_text(markdown(report, japanese))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seed', type=int)
    parser.add_argument('--cases', type=int)
    parser.add_argument('--vectors', type=int)
    parser.add_argument('--models', nargs='+', choices=models.PROFILES)
    parser.add_argument('--replay', type=Path)
    parser.add_argument('--case', help='one saved case id; requires --replay')
    parser.add_argument('--generate-only', action='store_true')
    parser.add_argument('--kirimasim')
    parser.add_argument('--commit')
    parser.add_argument('--icarus', help='also compare the saved inputs; path to iverilog (vvp next to it)')
    parser.add_argument('--verilator', help='also compare the saved inputs; path to verilator')
    parser.add_argument('--simulator-seed', type=int, default=1, help='Verilator initialization seed, not stimulus seed')
    parser.add_argument('--reference-policy', choices=('saved', 'current'), default='saved')
    parser.add_argument('--explore', action='store_true', help='optional local exploration admission')
    parser.add_argument('--history', type=Path, help='local SQLite admission history')
    parser.add_argument('--force', action='store_true', help='execute even a duplicate exploration job')
    parser.add_argument('--dependency', type=Path, action='append', default=[])
    parser.add_argument('--dependencies-complete', action='store_true',
                        help='attest the explicitly supplied compiler/runtime dependency closure is complete')
    parser.add_argument('--run-kind', choices=('comparison', 'nightly'), default='comparison')
    parser.add_argument('--workflow-run-id')
    parser.add_argument('--workflow-run-attempt')
    parser.add_argument('-j', '--jobs', type=int, default=4)
    parser.add_argument('--timeout', type=int, default=5)
    parser.add_argument('--time-budget', type=int, default=120)
    args = parser.parse_args()
    try:
        if args.replay:
            if any(value is not None for value in (args.seed, args.cases, args.vectors, args.models)):
                raise ValueError('replay uses saved stimuli; do not supply generation options')
            if args.replay.stat().st_size > 8*1024*1024:
                raise ValueError('manifest exceeds 8 MiB')
            manifest = json.loads(args.replay.read_text())
            models.validate(manifest)
            if args.case:
                manifest['cases'] = [case for case in manifest['cases'] if case['id'] == args.case]
                if not manifest['cases']:
                    raise ValueError('case id is absent from replay manifest')
        else:
            if args.case:
                raise ValueError('--case requires --replay')
            manifest = models.generate(args.seed if args.seed is not None else 0,
                                       args.cases if args.cases is not None else 96,
                                       args.vectors if args.vectors is not None else 8,
                                       args.models if args.models is not None else models.PROFILES)
        if not args.generate_only and (not args.kirimasim or not args.commit):
            raise ValueError('execution requires --kirimasim and the verified --commit')
        report = run(manifest, args.output.resolve(), args.kirimasim, args.commit,
                     args.jobs, args.timeout, args.time_budget, args.generate_only,
                     replay=args.replay, reference_policy=args.reference_policy,
                     explore=args.explore, history=args.history, force=args.force, run_kind=args.run_kind,
                     comparators={sim: exe for sim, exe in [('icarus', args.icarus), ('verilator', args.verilator)] if exe},
                     simulator_seed=args.simulator_seed, dependency_files=args.dependency,
                     dependencies_complete=args.dependencies_complete,
                     workflow_run_id=args.workflow_run_id, workflow_run_attempt=args.workflow_run_attempt)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        parser.exit(2, 'random cross: '+str(error)+'\n')
    print(f'Random cross seed={report["seed"]} cases={report["case_count"]}: '
          +' '.join(f'{name}={count}' for name, count in report['counts'].items()))
    for simulator, results in report.get('comparisons', {}).items():
        print(simulator+': '+' '.join(f'{state}={sum(row["status"] == state for row in results.values())}'
                                     for state in STATES))
    if report.get('admission'):
        print('Admission: '+report['admission']['decision'])
    if report.get('mode') == 'admission-only':
        return 3 if report['valid'] else 1
    success = evidence.all_pass(report) if 'inputs' in report else (
        report['valid'] and report['completed'] and report['counts']['pass'] == report['case_count'])
    return 0 if args.generate_only or success else 1


if __name__ == '__main__':
    def interrupted(signum, frame):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, interrupted)
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
