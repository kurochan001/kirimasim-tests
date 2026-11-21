#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Append-only holdout runs on the benchmark-results branch, apart from the
daily and weekly history.

Holdout runs are kept in holdout/runs/, which tools/benchmark_history.py does
not read, so they never enter the daily overall value, headline.json or the
daily/weekly charts. The latest one is latest-holdout.json, and the README and
README.ja.md of the branch get it as a separate table inside their folded
section. tools/benchmark_history.py rewrites both READMEs, so the publish
step runs `readme` after every publication.
"""
import argparse
import copy
from datetime import datetime
import json
import os
from pathlib import Path
import re
import statistics

import benchmark_compare as shared
import benchmark_history as history
from daily_benchmark import identity, now, summarize, write_json
import holdout_benchmark as holdout

START = '<!-- holdout-start -->'
END = '<!-- holdout-end -->'


def normalized(value):
    """benchmark_history.normalized for the holdout profile: every sample is
    checked again, on the result name of its condition."""
    value = copy.deepcopy(value)
    if value['schema'] != 1 or value['mode'] != 'formal':
        raise ValueError('only formal benchmark campaigns enter performance history')
    for key in ('id', 'series'):
        if not re.fullmatch(r'[A-Za-z0-9_-]{1,100}', value[key]):
            raise ValueError('unsafe ' + key + ' identifier')
    config = value['definition_config']
    if any(not re.fullmatch(r'[A-Za-z0-9_-]{1,100}', g['name']) for g in config['groups']):
        raise ValueError('unsafe group name')
    datetime.fromisoformat(value['started_at'])
    if config.get('profile') != holdout.PROFILE or value['environment'].get('profile', holdout.PROFILE) != holdout.PROFILE:
        raise ValueError('not a holdout campaign')
    if value['environment']['runs'] != 5 or config['measurement']['runs'] != 5:
        raise ValueError('formal campaigns require five repetitions')
    expected = {c['name']: c for c in config['cases']}
    seen = set()
    for case in value['cases']:
        if case['name'] in seen or case['name'] not in expected:
            raise ValueError('duplicate or unknown case')
        seen.add(case['name'])
        definition = expected[case['name']]
        if case['count'] != definition['count'] or case['sha256'] != definition['sha256']:
            raise ValueError('case identity mismatch')
        if set(case['tools']) != set(config['tools']):
            raise ValueError('missing tool record')
        name = holdout.result_name(definition)
        for tool, record in case['tools'].items():
            declared = definition.get('unsupported', {}).get(tool)
            if declared:
                record['error'] = {'stage': 'unsupported', 'reason': declared}
                continue
            if record.get('error', {}).get('stage') == 'unsupported':
                raise ValueError('undeclared unsupported result')
            if record.get('error'):
                continue
            if record.get('build') and record['build'].get('error'):
                record['error'] = {'stage': 'build', 'reason': 'build failed'}
                continue
            error = None
            for kind, n in [('warmup', 1), ('small', 1), ('large', definition['count'])]:
                samples = [record.get('warmup')] if kind == 'warmup' else record['samples'][kind]
                if (len(samples) != (1 if kind == 'warmup' else 5) or any(s is None for s in samples) or
                        (kind != 'warmup' and [s.get('repetition') for s in samples] != list(range(5)))):
                    error = 'incomplete repetitions'
                    break
                for sample in samples:
                    expect = definition['expected_small'] if n == 1 else definition['expected']
                    error = shared.check_sample(sample, name, n, expect)
                    if error:
                        break
                if error:
                    break
            if error:
                record['error'] = {'stage': kind if error != 'incomplete repetitions' else 'aggregation', 'reason': error}
            else:
                shared.aggregate(record, 5)
    return summarize(value, config)


def runs_of(directory):
    return sorted([json.loads(p.read_text()) for p in (directory / 'holdout/runs').glob('*.json')],
                  key=lambda r: (r['started_at'], r['id']))


def append(directory, value):
    value = normalized(value)
    text = json.dumps(value, sort_keys=True, allow_nan=False)
    if re.search(r'/(?:Users|home|private/tmp|var/folders)/', text) or \
            re.search(r'(?:gh[pousr]_|github_pat_|BEGIN .*PRIVATE KEY)', text):
        raise ValueError('private path or credential pattern in public data')
    target = directory / 'holdout/runs' / (value['id'] + '.json')
    if target.exists():
        if json.loads(target.read_text()) != value:
            raise ValueError('run identifier already exists with different data')
    else:
        write_json(target, value)
    render(directory)


def render(directory):
    runs = runs_of(directory)
    if not runs:
        raise ValueError('no holdout runs')
    write_json(directory / 'holdout/history.json', {'schema': 1, 'runs': [
        {'id': r['id'], 'started_at': r['started_at'], 'completed_at': r.get('completed_at'),
         'series': r['series'], 'status': r['status'], 'groups': r['groups']} for r in runs]})
    write_json(directory / 'latest-holdout.json', runs[-1])
    readme(directory)


def waveform_lines(run, ja):
    tr = lambda en, jp: jp if ja else en
    rows = []
    for case in run['cases']:
        if not case.get('waveform'):
            continue
        for tool, record in case['tools'].items():
            sizes = [s.get('waveform_bytes') for s in record['samples']['large'] if s.get('waveform_bytes') is not None]
            value = f'{statistics.median(sizes):,.0f}' if sizes and record.get('status') == 'measured' else '—'
            rows.append(f"| {case['name']} (N={case['count']}) | {tool} | {value} |")
    if not rows:
        return []
    return ['', tr('Waveform file size at full N (median bytes; contents are not compared):',
                   '完全なNでの波形ファイルの大きさ（バイトの中央値。中身は比べていません）：'), '',
            tr('| Condition | Tool | Bytes |', '| 条件 | 処理系 | バイト |'), '|---|---|---:|', *rows]


def section(runs, ja):
    tr = lambda en, jp: jp if ja else en
    latest = runs[-1]
    lines = [START, '', '## ' + tr('Latest holdout attempt (reported only)', '最新の別枠の測定（報告のみ）'), '',
             tr('Designs outside the daily and weekly sets, measured once a week. They are not used to decide '
                'kirimasim optimizations and never enter the daily overall value, headline.json or the overall '
                'graph. Only conditions a peer runs are in its comparison set; a declared exclusion is shown as missing.',
                '日次・週次の集合に入らない設計で、週に1回測ります。kirimasimの最適化の判断には使わず、日次の総合値・'
                'headline.json・総合グラフにも入れません。比較の集合には相手が実行できる条件だけを入れ、宣言した非対応は欠測として示します。'),
             '', '[JSON](latest-holdout.json)', '']
    lines += history.report(latest, prefix='holdout/', ja=ja)
    lines += waveform_lines(latest, ja)
    lines += ['', tr('Holdout runs, including failures:', '失敗を含む別枠の各回：'), '']
    for r in reversed(runs[-10:]):
        lines.append(f"- [{r['id']}](holdout/runs/{r['id']}.json): {r['status']} — "
                     f"`{r.get('tools', {}).get('latest', {}).get('commit', 'unknown')[:12]}`")
    return lines + ['', END]


def insert(text, block):
    """The README text with the holdout block replaced, inside its folded
    section when it has one. Inserting the same block again changes nothing."""
    text = re.sub(r'\n' + re.escape(START) + r'.*?' + re.escape(END), '', text, flags=re.S)
    if not block:
        return text
    marker = '\n</details>'
    at = text.rfind(marker)
    if at < 0:
        return text.rstrip('\n') + '\n\n' + block + '\n'
    return text[:at] + '\n' + block + text[at:]


def readme(directory):
    runs = runs_of(directory) if (directory / 'holdout/runs').is_dir() else []
    for ja in (False, True):
        path = directory / ('README.ja.md' if ja else 'README.md')
        if not runs:
            if path.is_file():
                path.write_text(insert(path.read_text(), ''))
            continue
        if path.is_file():
            text = path.read_text()
        else:
            title = '日次・週次シミュレーション速度ベンチマーク' if ja else 'Daily and weekly simulation-speed benchmarks'
            text = f'# {title}\n\n[English](README.md) / [日本語](README.ja.md)\n'
        path.write_text(insert(text, '\n'.join(section(runs, ja))))


def failure(args):
    config = holdout.config_at(holdout.DEFAULT_CONFIG)
    plan = json.loads(args.plan.read_text()) if args.plan and args.plan.exists() else {}
    result = {'schema': 1, 'id': args.run_id, 'mode': 'formal', 'started_at': args.started_at or now(), 'completed_at': None,
              'actions': {'url': args.run_url, 'run_id': os.environ.get('GITHUB_RUN_ID'), 'attempt': os.environ.get('GITHUB_RUN_ATTEMPT')},
              'environment': {'runs': 5, 'environment': 'github-hosted-ubuntu-24.04', 'profile': holdout.PROFILE},
              'series': identity({'infrastructure_failure': True, 'definition': identity(config)}), 'definition_config': config,
              'definition': {'config_sha256': identity(config)}, 'resolved_plan': plan, 'tools': {}, 'cases': [],
              'inputs_unchanged': False, 'infrastructure_error': 'Preparation or measurement did not finish; inspect Actions artifacts'}
    summarize(result, config)
    write_json(args.out, result)


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = p.add_subparsers(dest='command', required=True)
    a = sub.add_parser('append'); a.add_argument('--directory', type=Path, required=True); a.add_argument('result', type=Path)
    r = sub.add_parser('readme'); r.add_argument('--directory', type=Path, required=True)
    f = sub.add_parser('failure'); f.add_argument('--out', type=Path, required=True); f.add_argument('--run-id', required=True)
    f.add_argument('--plan', type=Path); f.add_argument('--run-url'); f.add_argument('--started-at')
    args = p.parse_args()
    if args.command == 'append':
        append(args.directory, json.loads(args.result.read_text()))
    elif args.command == 'readme':
        readme(args.directory)
    else:
        failure(args)


if __name__ == '__main__':
    main()
