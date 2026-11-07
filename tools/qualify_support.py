#!/usr/bin/env python3
"""What the independent model qualifications share.

Each qualify_<model>.py interprets the actual SV of every legal row and lists
normal controls and source faults. This module runs those programs natively,
checks that nothing moved during the run, and writes the record. Controls and
faults are auxiliary evidence, never fixed-suite passes or coverage.
"""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from unittest.mock import patch

import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import common


def apply_faults(controls, faults, interpret):
    """Controls and edited sources as programs; every fault must change the result."""
    programs = {name: (name, case.body, 'control') for name, case in controls.items()}
    for name, parent, edits in faults:
        source = controls[parent].body
        for old, new in edits:
            assert old in source, (name, old)
            source = source.replace(old, new)
        assert interpret(source) != controls[parent].expected, name
        programs[name] = parent, source, 'fault'
    return programs


def run_programs(generator, controls, programs, executable, directory):
    records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]
        source, _ = common.render(case, generator.NAME, generator.VERSION, generator.CHAPTER, 'spec')
        source = source.replace(case.body.strip('\n'), body.strip('\n'))
        original = ROOT / f'tests/gen/ch{generator.CHAPTER}' / (case.name + '.sv')
        folder = directory / name
        folder.mkdir()
        path = folder / original.name
        path.write_text(source)
        path.with_suffix('.expected').write_text(case.expected)
        calls, run = [], subprocess.run

        def capture(*args, **kwargs):
            result = run(*args, **kwargs)
            if args[0][0] == executable: calls.append(result)
            return result

        with patch.object(run_kirimasim.subprocess, 'run', side_effect=capture):
            status, reason = run_kirimasim.run(path, executable)
        assert len(calls) == 1 and calls[0].returncode == 0, (name, status, reason)
        assert status == ('pass' if kind == 'control' else 'fail'), (name, status, reason)
        if kind == 'fault': assert reason.startswith('output differs'), (name, reason)
        normalized = run([sys.executable, str(run_kirimasim.NORMALIZE)], input=calls[0].stdout,
                         text=True, capture_output=True, check=True).stdout
        records[name] = {'kind': kind, 'control': parent,
                         'status': 'pass' if kind == 'control' else 'detected',
                         'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                         'original_test': original.relative_to(ROOT).as_posix(),
                         'original_input_sha256': suite_results.input_digest(original),
                         'expected_stdout': case.expected, 'stdout': normalized,
                         'stderr': calls[0].stderr.replace(str(folder), '<case>'), 'returncode': 0}
    return records


def qualify(generator, interpret, variants, files, scope, description):
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('--kirimasim', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')

    def hashes(): return {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in files}
    sources = hashes()
    runner = suite_results.runner_digest('kirimasim')
    binary = Path(args.kirimasim).resolve()
    before = hashlib.sha256(binary.read_bytes()).hexdigest()
    folder = ROOT / f'tests/gen/ch{generator.CHAPTER}'
    paths = [folder / (generator.case_name(row) + '.sv') for row in generator.MODEL.select()]
    inputs = {path: suite_results.input_digest(path) for path in paths}
    evidence = hashlib.sha256()
    for row in generator.MODEL.rows():
        source, expected = generator.source(row), generator.reference(row)
        assert interpret(source) == expected, row
        evidence.update(source.encode() + b'\0' + expected.encode() + b'\0')
    controls, programs = variants()
    with tempfile.TemporaryDirectory() as tmp:
        executions = run_programs(generator, controls, programs, str(binary), Path(tmp))
    assert hashes() == sources and runner == suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(path) == digest for path, digest in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == before
    result = {'model': generator.MODEL.name,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': scope, 'rows_interpreted': len(generator.MODEL.rows()), 'selected': len(paths),
              'source_and_expectation_sha256': evidence.hexdigest(), 'source_sha256': sources,
              'runner_sha256': runner, 'binary_sha256': before,
              'version': subprocess.check_output([str(binary), '--version'], text=True).strip(),
              'sources_unchanged': True, 'inputs_unchanged': True, 'binary_unchanged': True,
              'executions': executions}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    faults = sum(record['kind'] == 'fault' for record in executions.values())
    print(f'Independent rows: {result["rows_interpreted"]}; native controls: '
          f'{len(executions) - faults}; detected SV faults: {faults}')
