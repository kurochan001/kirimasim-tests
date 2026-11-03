"""Artifact-local fingerprints and immutable random-comparison replay evidence.

Use suite_results' existing input algorithm without changing its fixed-suite
ROOT or runner digests. A separate module namespace scopes it to each artifact.
"""

import hashlib
import importlib.util
import json
from pathlib import Path
import shutil

import random_cross_models as models
import suite_results


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def digest(value):
    return hashlib.sha256(models.canonical(value).encode()).hexdigest()


def local_path(root, name):
    path = (Path(root) / name).resolve()
    if Path(name).is_absolute() or not path.is_relative_to(Path(root).resolve()):
        raise ValueError('artifact path escapes its root')
    return path


def input_digest(source, root):
    spec = importlib.util.spec_from_file_location('_random_cross_inputs', suite_results.__file__)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.ROOT = Path(root).resolve()
    return module.input_digest(Path(source))


def records(manifest, output):
    result = {}
    for case in manifest['cases']:
        name = case['id']
        source, expected = output/'cases'/(name+'.sv'), output/'cases'/(name+'.expected')
        result[name] = {'profile': case['profile'], 'source': 'cases/'+name+'.sv',
                        'expected': 'cases/'+name+'.expected',
                        'source_sha256': sha(source), 'expected_sha256': sha(expected),
                        'stimulus_sha256': digest(case), 'content_sha256': models.content_digest(case),
                        'inputs_sha256': input_digest(source, output),
                        'fourstate': models.requires_fourstate(case)}
    return result


def prepare(manifest, output, replay=None, reference_policy='saved'):
    models.validate(manifest)
    if reference_policy not in ('saved', 'current'):
        raise ValueError('unknown replay reference policy')
    if output.exists() and (not output.is_dir() or any(output.iterdir())):
        raise ValueError('output must be a new or empty directory; preserve previous evidence')
    output.mkdir(parents=True, exist_ok=True)
    (output/'cases').mkdir()
    (output/'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
    origin_report = None
    origin = Path(replay).resolve().parent if replay else None
    comparison = {'policy': reference_policy, 'baseline': 'not_replay', 'cases': {}}
    if replay:
        (output/'origin').mkdir()
        shutil.copyfile(replay, output/'origin/manifest.json')
        comparison['baseline'] = 'manifest_only'
        if (origin/'run.json').exists():
            origin_report = json.loads((origin/'run.json').read_text())
            if origin_report.get('manifest_sha256') != sha(replay):
                raise ValueError('saved manifest does not match its original run fingerprint')
            shutil.copyfile(origin/'run.json', output/'origin/run.json')
            comparison['origin_run_sha256'] = sha(origin/'run.json')
            comparison['origin_sources_sha256'] = origin_report.get('sources_sha256')
    for case in manifest['cases']:
        name = case['id']
        current_source, current_expected = models.materialize(case)
        saved_source, saved_expected = current_source.encode(), current_expected.encode()
        has_saved = False
        if replay:
            source, expected = origin/'cases'/(name+'.sv'), origin/'cases'/(name+'.expected')
            has_files = source.exists() or expected.exists()
            if has_files or origin_report is not None:
                if not source.is_file() or not expected.is_file():
                    raise ValueError('saved replay source or expectation is missing: '+name)
                local_path(origin, 'cases/'+name+'.sv')
                local_path(origin, 'cases/'+name+'.expected')
                saved_source, saved_expected = source.read_bytes(), expected.read_bytes()
                has_saved = True
                if origin_report is not None:
                    record = origin_report.get('inputs', {}).get(name, {})
                    if (record.get('source_sha256') != sha(source)
                            or record.get('expected_sha256') != sha(expected)
                            or record.get('stimulus_sha256') != digest(case)):
                        raise ValueError('saved replay inputs do not match original fingerprints: '+name)
                    if record.get('inputs_sha256') and record['inputs_sha256'] != input_digest(source, origin):
                        raise ValueError('saved helper or simulator-specific expectation changed: '+name)
                comparison['baseline'] = 'saved_artifact'
                (output/'origin/cases').mkdir(exist_ok=True)
                # Retain all metadata-declared helpers/expectations, not just stdout.
                for path in set(suite_results.input_files(source)) | {expected}:
                    relative = path.relative_to(origin)
                    local_path(origin, relative)
                    if not path.is_file():
                        raise ValueError('saved dependency is missing: '+str(relative))
                    target = output/'origin'/relative
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(path, target)
                    if path not in (source, expected):
                        target = output/relative
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copyfile(path, target)
                (output/'current-reference').mkdir(exist_ok=True)
                (output/'current-reference'/(name+'.sv')).write_text(current_source)
                (output/'current-reference'/(name+'.expected')).write_text(current_expected)
            comparison['cases'][name] = {
                'source_changed': saved_source != current_source.encode() if has_saved else None,
                'expected_changed': saved_expected != current_expected.encode() if has_saved else None,
                'saved_source_sha256': hashlib.sha256(saved_source).hexdigest() if has_saved else None,
                'saved_expected_sha256': hashlib.sha256(saved_expected).hexdigest() if has_saved else None,
                'current_source_sha256': hashlib.sha256(current_source.encode()).hexdigest(),
                'current_expected_sha256': hashlib.sha256(current_expected.encode()).hexdigest()}
        source, expected = ((current_source.encode(), current_expected.encode()) if reference_policy == 'current'
                            else (saved_source, saved_expected))
        (output/'cases'/(name+'.sv')).write_bytes(source)
        (output/'cases'/(name+'.expected')).write_bytes(expected)
    return records(manifest, output), comparison


def all_pass(report):
    if (report.get('mode') != 'comparison' or not report.get('valid')
            or not report.get('completed') or report.get('interrupted')):
        return False
    names = set(report.get('inputs', {}))
    comparisons = report.get('comparisons', {report.get('simulator', 'kirimasim'): report.get('results', {})})
    required = report.get('required_simulators', ['kirimasim'])
    return bool(names) and bool(required) and report.get('case_count') == len(names) and all(
        set(comparisons.get(simulator, {})) == names and all(
            row.get('status') == 'pass' and row.get('returncode') == 0
            for row in comparisons[simulator].values()) for simulator in required)


def receipt(output):
    """Names and bytes of the complete saved evidence; never trust status alone."""
    result = {}
    for path in sorted(output.rglob('*')):
        if path.is_symlink():
            raise ValueError('evidence must not contain symbolic links')
        if path.is_file():
            result[path.relative_to(output).as_posix()] = sha(path)
    return result


def reusable(output, expected_receipt, job):
    try:
        if receipt(output) != expected_receipt:
            return False
        report = json.loads((output/'run.json').read_text())
        return report.get('execution_identity', {}).get('sha256') == job and all_pass(report)
    except (OSError, ValueError, TypeError, KeyError):
        return False
