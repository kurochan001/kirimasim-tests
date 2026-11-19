"""Bound the existing public Icarus/Verilator runners and retain their evidence.

The worker is isolated so subprocess instrumentation never patches other cases.
Saved SystemVerilog bytes are passed directly to each existing runner. This is
not a fixed-suite runner or oracle registrar.
"""

import argparse
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import time

import random_cross_evidence as evidence
import suite_results


def stage(record, output, simulator):
    source = output/record['source']
    directory = output/'comparisons'/simulator/source.stem
    directory.mkdir(parents=True)
    return source, directory


def expectation(source, simulator, fallback, reader=None):
    want = (reader or suite_results.expected_output)(source, simulator)
    return fallback.read_text() if want is None else want


def worker(simulator, source, expected, executable, seed, directory):
    import run_icarus
    import run_verilator

    phases = []
    original_run = subprocess.run
    original_expectation = suite_results.expected_output
    original_icarus_execute = run_icarus.execute
    original_verilator_execute = run_verilator.execute
    phase_file = directory/'phases.json'
    phase_file.write_text('[]\n')

    def save():
        phase_file.write_text(json.dumps(phases, indent=2)+'\n')

    def begin(args, kind):
        command = list(map(str, args))
        index = len(phases)
        stdout, stderr = directory/f'phase-{index}.stdout', directory/f'phase-{index}.stderr'
        stdout.write_text('')
        stderr.write_text('')
        resolved = __import__('shutil').which(command[0])
        before = evidence.sha(resolved) if resolved and Path(resolved).is_file() else None
        phase = {'kind': kind, 'command': command, 'stdout': stdout.name,
                 'stderr': stderr.name, 'binary_sha256': before, 'returncode': None,
                 'timed_out': False,
                 'compiled_inputs': {name: evidence.sha(name) for name in command[1:]
                                     if kind == 'simulation' and name.endswith('.vvp') and Path(name).is_file()}}
        phases.append(phase)
        save()
        return phase, resolved, stdout, stderr

    def finish(phase, resolved):
        before = phase['binary_sha256']
        phase['binary_changed'] = bool(before and (not Path(resolved).exists()
                                                   or evidence.sha(resolved) != before))
        phase['compiled_inputs_changed'] = any(not Path(name).is_file() or evidence.sha(name) != digest
                                               for name, digest in phase['compiled_inputs'].items())
        save()

    def text(value):
        return value.decode(errors='replace') if isinstance(value, bytes) else value or ''

    def observe_build(original_execute):
        def captured(command, timeout, cwd=None):
            phase, resolved, stdout, stderr = begin(command, 'build')
            try:
                # Keep adapter process groups, timeouts and return semantics intact.
                result = original_execute(command, timeout, cwd)
                phase['returncode'] = result.returncode
                stdout.write_text(text(result.stdout))
                stderr.write_text(text(result.stderr))
                return result
            except subprocess.TimeoutExpired as error:
                phase['timed_out'] = True
                stdout.write_text(text(error.output))
                stderr.write_text(text(error.stderr))
                raise
            except BaseException as error:
                phase['exception'] = type(error).__name__
                raise
            finally:
                finish(phase, resolved)
        return captured

    def observed_run(args, **kwargs):
        command = list(map(str, args))
        name = Path(command[0]).name
        kind = ('simulation' if name in ('vvp', 'Vt') else 'normalization'
                if any(Path(value).name == 'normalize_output.py' for value in command[:2]) else 'helper')
        phase, resolved, stdout, stderr = begin(command, kind)
        kwargs.pop('capture_output', None)
        try:
            with stdout.open('w') as out, stderr.open('w') as err:
                result = original_run(args, stdout=out, stderr=err, **kwargs)
            phase['returncode'] = result.returncode
            result.stdout, result.stderr = stdout.read_text(errors='replace'), stderr.read_text(errors='replace')
            return result
        except subprocess.TimeoutExpired:
            phase['timed_out'] = True
            raise
        finally:
            finish(phase, resolved)

    subprocess.run = observed_run
    run_icarus.execute = observe_build(original_icarus_execute)
    run_verilator.execute = observe_build(original_verilator_execute)
    # Scope the missing-metadata fallback to this isolated worker.
    suite_results.expected_output = lambda test, sim=None: expectation(test, sim, expected, original_expectation)
    try:
        if simulator == 'icarus':
            ok, reason = run_icarus.run(source, Path(executable).parent)
            oracle = 'iverilog@13.0'
        else:
            ok, reason = run_verilator.run(source, executable, seed)
            oracle = 'verilator@5.052'
        runtime = next((phase for phase in reversed(phases) if phase['kind'] == 'simulation'), None)
        code = runtime['returncode'] if runtime else None
        if ok and (code != 0 or re.search(r'(?:^|\s)%?(?:error|fatal):',
                                         (directory/runtime['stdout']).read_text(errors='replace')+'\n'+
                                         (directory/runtime['stderr']).read_text(errors='replace'), re.I)):
            ok, reason = False, 'runtime exit/diagnostic violates random comparison contract'
        if ok and any(phase['kind'] in ('normalization', 'helper') and phase['returncode'] != 0
                      for phase in phases):
            ok, reason = False, 'normalization/helper exit violates random comparison contract'
        registered = oracle in (suite_results.header(source).get('oracle') or '').split()
        status = 'pass' if ok else 'fail' if registered else 'known'
        if any(phase['binary_changed'] or phase['compiled_inputs_changed'] for phase in phases):
            status, reason = 'stale', 'compiler or generated executable changed during execution'
        result = {'status': status, 'reason': reason, 'returncode': code,
                  'stdout': runtime['stdout'] if runtime else None,
                  'stderr': runtime['stderr'] if runtime else None,
                  'phases': 'phases.json'}
        (directory/'worker.json').write_text(json.dumps(result, indent=2)+'\n')
    finally:
        subprocess.run = original_run
        run_icarus.execute = original_icarus_execute
        run_verilator.execute = original_verilator_execute
        suite_results.expected_output = original_expectation


def execute(record, output, simulator, build, seed, timeout, deadline):
    remaining = deadline-time.monotonic()
    if remaining <= 0:
        return {'status': 'not_run', 'reason': 'run time budget exhausted', 'returncode': None}
    if simulator == 'verilator' and record['fourstate']:
        return {'status': 'unsupported', 'reason': 'saved stimulus requires X/Z semantics; two-state comparison excluded',
                'returncode': None}
    source, directory = stage(record, output, simulator)
    command = [sys.executable, str(Path(__file__).resolve()), '--worker', simulator,
               '--source', str(source.resolve()), '--executable', build['executable'],
               '--expected', str((output/record['expected']).resolve()),
               '--seed', str(seed), '--directory', str(directory.resolve())]
    started = time.monotonic()
    with (directory/'worker.stdout').open('w') as out, (directory/'worker.stderr').open('w') as err:
        process = subprocess.Popen(command, stdout=out, stderr=err, start_new_session=True)
        try:
            process.wait(timeout=min(timeout, remaining))
            if process.returncode or not (directory/'worker.json').is_file():
                result = {'status': 'fail', 'reason': 'comparison worker failed', 'returncode': None}
            else:
                result = json.loads((directory/'worker.json').read_text())
        except BaseException as error:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
            if not isinstance(error, subprocess.TimeoutExpired):
                raise
            result = {'status': 'fail', 'reason': 'timed out (compile and simulation budget)', 'returncode': None}
    for key in ('stdout', 'stderr', 'phases'):
        if result.get(key):
            result[key] = (directory/result[key]).relative_to(output).as_posix()
    result['evidence'] = directory.relative_to(output).as_posix()
    result['seconds'] = round(time.monotonic()-started, 6)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--worker', choices=('icarus', 'verilator'), required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--expected', type=Path, required=True)
    parser.add_argument('--executable', required=True)
    parser.add_argument('--seed', type=int, required=True)
    parser.add_argument('--directory', type=Path, required=True)
    args = parser.parse_args()
    worker(args.worker, args.source, args.expected, args.executable, args.seed, args.directory)
