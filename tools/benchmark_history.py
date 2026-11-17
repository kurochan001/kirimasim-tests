#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Append-only benchmark runs and bilingual reports; function-test history is untouched."""
import argparse
import copy
from datetime import datetime
import html
import json
import math
import os
from pathlib import Path
import re

import benchmark_compare as shared
from daily_benchmark import BAD, identity, now, summarize, write_json
import results_history as charts

METHOD='https://github.com/kurochan001/kirimasim-tests/blob/main/docs/daily-benchmark.md'


def normalized(value):
    value=copy.deepcopy(value)
    if value['schema']!=1 or value['mode']!='formal':
        raise ValueError('only formal benchmark campaigns enter performance history')
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,100}',value['id']):
        raise ValueError('unsafe run identifier')
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,100}',value['series']):
        raise ValueError('unsafe series identifier')
    if any(not re.fullmatch(r'[A-Za-z0-9_-]{1,100}',g['name']) for g in value['definition_config']['groups']):
        raise ValueError('unsafe group name')
    datetime.fromisoformat(value['started_at'])
    config=value['definition_config']
    if value['environment']['runs']!=5 or config['measurement']['runs']!=5:
        raise ValueError('formal campaigns require five repetitions')
    expected={c['name']:c for c in config['cases']}
    seen=set()
    for case in value['cases']:
        if case['name'] in seen or case['name'] not in expected:
            raise ValueError('duplicate or unknown case')
        seen.add(case['name']);definition=expected[case['name']]
        if case['count']!=definition['count'] or case['sha256']!=definition['sha256']:
            raise ValueError('case identity mismatch')
        if set(case['tools'])!=set(config['tools']):
            raise ValueError('missing tool record')
        for name,record in case['tools'].items():
            declared=definition.get('unsupported',{}).get(name)
            if declared:
                record['error']={'stage':'unsupported','reason':declared}
                continue
            if record.get('error',{}).get('stage')=='unsupported':
                raise ValueError('undeclared unsupported result')
            if record.get('error'):
                continue
            error=None
            if record.get('build') and record['build'].get('error'):
                record['error']={'stage':'build','reason':'build failed'}
                continue
            for kind,n in [('warmup',1),('small',1),('large',definition['count'])]:
                samples=[record.get('warmup')] if kind=='warmup' else record['samples'][kind]
                if (len(samples)!=(1 if kind=='warmup' else 5) or any(s is None for s in samples) or
                    (kind!='warmup' and [s.get('repetition') for s in samples]!=list(range(5)))):
                    error='incomplete repetitions';break
                for sample in samples:
                    expect=definition['expected_small'] if n==1 else definition['expected']
                    if not expect:
                        error='missing fixed expectation';break
                    error=shared.check_sample(sample,case['name'],n,expect)
                    if error:break
                if error:break
            if error:
                record['error']={'stage':kind if error!='incomplete repetitions' else 'aggregation','reason':error}
            else:
                # Recompute from every raw sample; never trust a supplied median.
                shared.aggregate(record,5)
    return summarize(value,config)


def append(directory,value):
    value=normalized(value)
    text=json.dumps(value,sort_keys=True,allow_nan=False)
    if re.search(r'/(?:Users|home|private/tmp|var/folders)/',text) or re.search(r'(?:gh[pousr]_|github_pat_|BEGIN .*PRIVATE KEY)',text):
        raise ValueError('private path or credential pattern in public data')
    target=directory/'runs'/(value['id']+'.json')
    if target.exists():
        if json.loads(target.read_text())!=value:
            raise ValueError('run identifier already exists with different data')
    else:
        write_json(target,value)
    render(directory)


def cell(value):
    return '—' if value is None else f'{value:.5g}'


def safe(value):
    return html.escape(str(value)).replace('|','&#124;').replace('\n',' ')


def report(run, prefix='',ja=False):
    tr=lambda en,jp:jp if ja else en
    lines=[f"**{tr('Run','測定回')}:** `{run['id']}` — {run['status']}",
        f"{run['started_at']} → {run.get('completed_at') or tr('incomplete','未完了')}",
        '',tr('Ratios = latest kirimasim / peer incremental elapsed; below 1 favors latest.',
              '比率は最新kirimasimの差分時間÷比較対象の差分時間です。1未満なら最新kirimasimが速いことを示します。'),
        '',tr('This is a descriptive reference on this environment. Missing/failed values are not zero.',
              'この環境での参考値です。失敗・欠測はゼロ秒ではありません。'),
        '',f"[JSON]({prefix}runs/{run['id']}.json) · [Actions logs / ログ]({run.get('actions',{}).get('url') or METHOD}) · [Method / 測定方法]({METHOD})",'']
    environment=run['environment']
    machine=environment.get('machine',{})
    lines += [f"{tr('Environment','環境')}: {safe(environment.get('environment','unknown'))} / {safe(machine.get('cpu','unknown'))} / {safe(machine.get('os','unknown'))}", '',
              '<details><summary>'+tr('Measurement settings','測定条件')+'</summary>', '', '```json',
              json.dumps(environment,indent=2,ensure_ascii=False), '```', '', '</details>', '']
    for name,tool in run.get('tools',{}).items():
        lines.append(f"- `{name}`: `{tool['commit']}` — {safe(tool['version'])}")
    lines += ['',f"{tr('Definition and measurement identity','定義・測定処理の識別情報')}: `{run.get('definition',{})}`",'',
              tr('| Case | Tool | State | Build s | T(1) median s | T(N) median s | Incremental s | MAD T(N) s | RSS MiB | latest/peer | Reason / warning |',
                 '| ケース | 処理系 | 状態 | ビルド秒 | T(1)中央値秒 | T(N)中央値秒 | 差分秒 | T(N) MAD秒 | RSS MiB | 最新/対象 | 理由・注意 |'),
              '|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|']
    for case in run['cases']:
        for name,r in case['tools'].items():
            message=(r.get('error') or {}).get('reason') or r.get('reason') or '; '.join(r.get('warnings',[]))
            lines.append('| '+' | '.join([f"{case['name']} (N={case['count']})",name,r['status'],cell((r.get('build') or {}).get('seconds')),
                cell(r.get('small_seconds',{}).get('median')),cell(r.get('large_seconds',{}).get('median')),
                cell(r.get('incremental_seconds')) if r['status']=='measured' else '—',cell(r.get('large_seconds',{}).get('mad')),
                cell(r.get('median_peak_rss_mib')),cell(case.get('ratios',{}).get(name)),safe(message)])+' |')
    if run.get('infrastructure_error'):
        lines+=['',safe(run['infrastructure_error'])]
    lines += ['',tr('Fixed comparison sets (all members required):','固定した総合値の集合（全ケースの有効値が必要です）：'),'']
    for g in run['groups']:
        lines.append(f"- **{g['name']}**: {cell(g['ratio'])}; {g['available_count']}/{g['expected_count']}; {', '.join(g['cases'])}"+(' — ⚠ descriptive regression caution' if g['warning'] else '')+(f" — {g['reason']}" if g['reason'] else ''))
    return lines


def render(directory):
    runs=sorted([normalized(json.loads(p.read_text())) for p in (directory/'runs').glob('*.json')],key=lambda r:(r['started_at'],r['id']))
    if not runs:
        raise ValueError('no runs')
    index={'schema':1,'runs':[{'id':r['id'],'started_at':r['started_at'],'completed_at':r.get('completed_at'),'series':r['series'],'status':r['status'],'groups':r['groups']} for r in runs]}
    write_json(directory/'history.json',index)
    write_json(directory/'latest.json',runs[-1])
    series={}
    for r in runs:
        series.setdefault(r['series'],[]).append(r)
    for series_id,items in series.items():
        chartdir=directory/'charts'/series_id;chartdir.mkdir(parents=True,exist_ok=True)
        for group in items[-1]['groups']:
            values=[next((g['ratio'] for g in r['groups'] if g['name']==group['name']),None) for r in items]
            svg=charts.line_chart(group['name'],'latest / peer incremental elapsed; lower is faster; gaps are missing',
                [{'time':r['started_at']} for r in items],[('ratio','last available latest / '+group['peer'],False,'circle',values)],{'ratio':('#0969da','#4493f8')})
            (chartdir/(group['name']+'.svg')).write_text(svg)
    for ja in (False,True):
        tr=lambda en,jp:jp if ja else en
        lines=['# '+tr('Daily simulation-speed benchmarks','日次シミュレーション速度ベンチマーク'),'',
               '[English](README.md) / [日本語](README.ja.md)','',
               tr('Independent of functional Nightly. GitHub-hosted values are reference measurements; five repetitions do not establish statistical significance.',
                  '機能テストのNightlyとは独立しています。GitHub標準ランナーの値は参考値で、5回の測定から統計的有意性を断言しません。'),'',
               '## '+tr('Latest attempt','最新の測定回'),'']+report(runs[-1],ja=ja)
        lines+=['','## '+tr('Separate environment / definition series','環境・定義別の推移'),'']
        for series_id,items in reversed(list(series.items())):
            lines += [f"### `{series_id[:16]}`",'',f"{len(items)} runs; {items[0]['started_at']} → {items[-1]['started_at']}",'']
            for g in items[-1]['groups']:
                lines+=['!['+g['name']+'](charts/'+series_id+'/'+g['name']+'.svg)','']
            lines += [tr('Runs, including failures:','失敗を含む各回：'),'']
            for r in reversed(items):
                lines.append(f"- [{r['id']}](runs/{r['id']}.json): {r['status']} — `{r.get('tools',{}).get('latest',{}).get('commit','unknown')[:12]}`")
        (directory/('README.ja.md' if ja else 'README.md')).write_text('\n'.join(lines)+'\n')


def failure(args):
    from daily_benchmark import config_at, DEFAULT_CONFIG
    config=config_at(DEFAULT_CONFIG)
    plan=json.loads(args.plan.read_text()) if args.plan and args.plan.exists() else {}
    result={'schema':1,'id':args.run_id,'mode':'formal','started_at':args.started_at or now(),'completed_at':None,
        'actions':{'url':args.run_url,'run_id':os.environ.get('GITHUB_RUN_ID'),'attempt':os.environ.get('GITHUB_RUN_ATTEMPT')},'environment':{'runs':5,'environment':'github-hosted-ubuntu-24.04'},
        'series':identity({'infrastructure_failure':True,'definition':identity(config)}),'definition_config':config,
        'definition':{'config_sha256':identity(config)},'resolved_plan':plan,'tools':{},'cases':[],
        'inputs_unchanged':False,'infrastructure_error':'Preparation or measurement did not finish; inspect Actions artifacts'}
    summarize(result,config);write_json(args.out,result)


def main():
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='command',required=True)
    a=sub.add_parser('append');a.add_argument('--directory',type=Path,required=True);a.add_argument('result',type=Path)
    r=sub.add_parser('render');r.add_argument('--directory',type=Path,required=True)
    f=sub.add_parser('failure');f.add_argument('--out',type=Path,required=True);f.add_argument('--run-id',required=True)
    f.add_argument('--plan',type=Path);f.add_argument('--run-url');f.add_argument('--started-at')
    args=p.parse_args()
    if args.command=='append':append(args.directory,json.loads(args.result.read_text()))
    elif args.command=='render':render(args.directory)
    else:failure(args)


if __name__=='__main__':main()
