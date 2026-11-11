#!/usr/bin/env python3
"""Prepare a reviewed failure's fixed-regression draft without replacing evidence.

Language cases go to a chNN draft. Model/runner/specification problems stay in
triage, for correction at their own mechanism. This never registers an oracle.
"""

import argparse
import json
from pathlib import Path
import re
import shutil

import lint_metadata
import random_cross_evidence as evidence
import random_cross_models as models


def promote(artifact, case_id, output, classification, mechanism, explanation,
            *, confirmed=False, chapter=None, lrm=None, simulator='kirimasim'):
    if not re.fullmatch(r'[a-z][a-z0-9_]{0,60}', mechanism):
        raise ValueError('mechanism must be a short lowercase identifier')
    if classification not in ('simulator', 'reference', 'runner', 'specification') or not explanation.strip():
        raise ValueError('classification and an explanation are required')
    report = json.loads((artifact/'run.json').read_text(encoding='utf-8'))
    manifest = json.loads((artifact/'manifest.json').read_text(encoding='utf-8'))
    models.validate(manifest)
    if evidence.sha(artifact/'manifest.json') != report['manifest_sha256']:
        raise ValueError('original manifest changed')
    case = next((row for row in manifest['cases'] if row['id'] == case_id), None)
    if case is None:
        raise ValueError('case is absent from manifest')
    record = report['inputs'][case_id]
    source, expected = evidence.local_path(artifact, record['source']), evidence.local_path(artifact, record['expected'])
    if (evidence.sha(source) != record['source_sha256'] or evidence.sha(expected) != record['expected_sha256']
            or evidence.digest(case) != record['stimulus_sha256']
            or (record.get('inputs_sha256') and evidence.input_digest(source, artifact) != record['inputs_sha256'])):
        raise ValueError('original failure inputs changed')
    result = report.get('comparisons', {report.get('simulator', 'kirimasim'): report['results']}).get(simulator, {}).get(case_id)
    if not result or result['status'] not in ('fail', 'known'):
        raise ValueError('select a recorded fail/known observation, not pass/unsupported/not_run/stale')
    if output.exists():
        raise ValueError('use a new draft directory; preserve previous triage')
    # Validate every promotion condition before making a draft directory.
    language = classification == 'simulator' and confirmed
    if language:
        if not report.get('valid') or report.get('interrupted'):
            raise ValueError('invalid or interrupted run must be investigated before promotion')
        if not chapter or not re.fullmatch(r'ch[1-9][0-9]?', chapter) or not (models.ROOT/'tests'/chapter).is_dir():
            raise ValueError('select an existing chNN language-mechanism chapter')
        clauses = lrm.split() if lrm else []
        if (len(clauses) < 2 or clauses[0] != '1800-2023'
                or not all(lint_metadata.CLAUSE.match(clause) for clause in clauses[1:])):
            raise ValueError('cite the reviewed IEEE 1800-2023 clauses')
        if 'ch'+clauses[1].split('.')[0] != chapter:
            raise ValueError('first reviewed clause must belong to the selected chapter')
        current_source, current_expected = models.materialize(case)
        if source.read_bytes() != current_source.encode() or expected.read_bytes() != current_expected.encode():
            raise ValueError('saved/reference drift requires separate review before drafting a regression')
    output.mkdir(parents=True)
    for name in ('manifest.json', 'run.json', 'events.jsonl', record['source'], record['expected'],
                 result.get('stdout'), result.get('stderr')):
        if name:
            path = evidence.local_path(artifact, name)
            if path.is_file():
                target = output/'origin'/name
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
    if result.get('evidence'):
        directory = evidence.local_path(artifact, result['evidence'])
        for path in directory.rglob('*'):
            if path.is_file():
                relative = path.relative_to(artifact)
                evidence.local_path(artifact, relative)
                target = output/'origin'/relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
    triage = {'schema': 'random-cross-triage@1', 'classification': classification,
              'confirmed': confirmed, 'mechanism': mechanism, 'explanation': explanation,
              'case': case, 'simulator': simulator, 'observation': result,
              'manifest_sha256': report['manifest_sha256'], 'run_sha256': evidence.sha(artifact/'run.json'),
              'input': record, 'build': report.get('builds', {'kirimasim': report.get('build')}),
              'sources_sha256': report['sources_sha256'], 'regression_draft': None}
    triage['lint_problems'] = []
    if language:
        name = 'test_random_'+mechanism+'_'+models.content_digest(case)[:12]
        target = output/'tests'/chapter/(name+'.sv')
        target.parent.mkdir(parents=True)
        text = source.read_text(encoding='utf-8')
        body = text.split('*/', 1)[1]
        header = ('/*\n:name: '+name+'\n:description: Regression for '+mechanism+'\n'
                  ':tags: '+chapter+'\n:type: simulation\n:lrm: '+lrm+'\n:oracle: spec\n:spec_check: ai\n'
                  ':fourstate: '+('yes' if models.requires_fourstate(case) else 'no')+'\n'
                  ':nondeterministic: no\n:expected_exit: 0\n:expected_stdout: @'+name+'.expected\n*/')
        target.write_text(header+body, encoding="utf-8")
        target.with_suffix('.expected').write_bytes(expected.read_bytes())
        triage['regression_draft'] = target.relative_to(output).as_posix()
        # Keep the failure-triggering HDL byte-for-byte, including wide
        # literals. Report formatting work instead of silently rewriting the
        # literal representation and possibly hiding a parser defect.
        triage['lint_problems'] = lint_metadata.check(target)
    (output/'triage.json').write_text(json.dumps(triage, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    return triage


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--artifact', type=Path, required=True)
    parser.add_argument('--case', required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--classification', choices=('simulator', 'reference', 'runner', 'specification'), required=True)
    parser.add_argument('--mechanism', required=True)
    parser.add_argument('--explanation', required=True)
    parser.add_argument('--confirmed', action='store_true')
    parser.add_argument('--chapter')
    parser.add_argument('--lrm')
    parser.add_argument('--simulator', choices=('kirimasim', 'icarus', 'verilator'), default='kirimasim')
    args = parser.parse_args()
    try:
        result = promote(args.artifact.resolve(), args.case, args.output.resolve(), args.classification,
                         args.mechanism, args.explanation, confirmed=args.confirmed,
                         chapter=args.chapter, lrm=args.lrm, simulator=args.simulator)
    except (ValueError, OSError, KeyError) as error:
        parser.exit(2, str(error)+'\n')
    print('regression draft: '+str(result['regression_draft']))
    for rule, detail in result['lint_problems']:
        print('draft lint '+rule+': '+detail)


if __name__ == '__main__':
    main()
