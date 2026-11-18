#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Append-only benchmark runs and bilingual reports; function-test history is untouched."""
import argparse
import copy
from datetime import datetime, timedelta, timezone
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
HEADLINE='daily-overall-icarus14'
JST=timezone(timedelta(hours=9))


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
    profile=config.get('profile','daily')
    if profile not in ('daily','weekly') or value['environment'].get('profile',profile)!=profile:
        raise ValueError('unknown or mismatched benchmark profile')
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


def headline(runs):
    """Select the last attempt per JST day, including failed attempts, on all 25.

    Older Icarus 13 campaigns have no such group and cannot become Icarus 14
    evidence. Each point retains its original environment/definition series.
    """
    days={}
    for run in sorted(runs,key=lambda r:(charts.parse_time(r['started_at']),r['id'])):
        config=run['definition_config']
        group=next((g for g in run['groups'] if g['name']==HEADLINE),None)
        if config.get('profile','daily')!='daily' or group is None:
            continue
        members=group['cases']
        if group['peer']!='icarus_devel' or len(members)!=25 or len(set(members))!=25 or set(members)!={c['name'] for c in config['cases']}:
            raise ValueError('headline requires exactly the full 25-case Icarus devel set')
        day=charts.parse_time(run['started_at']).astimezone(JST).date().isoformat()
        days[day]={'date':day,'id':run['id'],'series':run['series'],'ratio':group['ratio'],
                   'status':run['status'],'reason':group['reason'],'available_count':group['available_count'],
                   'cases':members,'started_at':run['started_at'],'completed_at':run.get('completed_at'),
                   'commits':{name:tool['commit'] for name,tool in run.get('tools',{}).items()},
                   'environment':run['environment'],'actions_url':run.get('actions',{}).get('url')}
    points=[]
    if days:
        day=datetime.fromisoformat(min(days)).date();end=datetime.fromisoformat(max(days)).date()
        while day<=end:
            key=day.isoformat()
            points.append(days.get(key,{'date':key,'id':None,'ratio':None,'reason':'no attempt'}))
            day+=timedelta(days=1)
    return {'schema':1,'group':HEADLINE,'peer':'icarus_devel','expected_count':25,'timezone':'Asia/Tokyo',
            'metric':'geometric mean of 25 latest / Icarus 14 devel incremental elapsed ratios; lower is faster',
            'selection':'last formal daily attempt per JST date, including failures','points':points}


def render_headline(directory,runs):
    data=headline(runs);write_json(directory/'headline.json',data)
    title='Daily overall elapsed ratio: 25 designs'
    subtitle='Icarus Verilog 14.0 devel = 1; lower is faster; JST; gaps are missing'
    if not data['points']:
        svg=charts.svg_document(880,130,{},[charts.text(20,28,title,'title'),charts.text(20,53,subtitle,'muted'),
            charts.text(20,90,'Awaiting a formal 25-case Icarus 14 devel comparison.')],title)
    else:
        points=data['points']
        if len(points)==1:
            date=datetime.fromisoformat(points[0]['date']).date()
            # Extend only the mathematical reference around a lone measured day.
            points=[{'date':(date-timedelta(days=1)).isoformat(),'ratio':None},*points,
                    {'date':(date+timedelta(days=1)).isoformat(),'ratio':None}]
        series=[('reference','Icarus 14 devel reference',True,'circle',[1.0]*len(points))]
        colors={'reference':('#656d76','#9198a1')}
        palette=[('#0969da','#4493f8'),('#8250df','#a371f7'),('#1a7f37','#3fb950'),('#bc4c00','#f0883e')]
        identities=list(dict.fromkeys(p['series'] for p in points if p.get('series') and p['ratio'] is not None))
        for i,identity in enumerate(identities):
            cls='ratio'+str(i);colors[cls]=palette[i%len(palette)]
            example=next(p for p in points if p.get('series')==identity)
            cpu=example['environment'].get('machine',{}).get('cpu','unknown CPU')
            label='kirimasim '+cpu+' / '+identity[:8]+' (last valid)'
            series.append((cls,label,False,'circle',[p['ratio'] if p.get('series')==identity else None for p in points]))
        # The shared plotter labels dates at UTC noon. These positions are JST
        # calendar-day categories, not the actual timestamps kept in the JSON.
        top=max(1.2,math.ceil(max(v for *_,values in series for v in values if v is not None)*1.1*5)/5)
        svg=charts.line_chart(title,subtitle,[{'time':p['date']+'T12:00:00+00:00'} for p in points],series,colors,y_max=top,shown=lambda v:f'{v:.3f}')
    (directory/'charts').mkdir(parents=True,exist_ok=True)
    (directory/'charts/daily-icarus14.svg').write_text(svg)
    return data


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
    index={'schema':1,'runs':[{'id':r['id'],'started_at':r['started_at'],'completed_at':r.get('completed_at'),'series':r['series'],'status':r['status'],'groups':r['groups'],
                              'profile':r['definition_config'].get('profile','daily')} for r in runs]}
    write_json(directory/'history.json',index)
    write_json(directory/'latest.json',runs[-1])
    latest_by_profile={}
    for r in runs:
        latest_by_profile[r['definition_config'].get('profile','daily')]=r
    for profile, r in latest_by_profile.items():
        if profile not in ('daily','weekly'):
            raise ValueError('unknown history profile')
        write_json(directory/('latest-'+profile+'.json'),r)
    overall=render_headline(directory,runs)
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
        lines=['# '+tr('Daily and weekly simulation-speed benchmarks','日次・週次シミュレーション速度ベンチマーク'),'',
               '[English](README.md) / [日本語](README.ja.md)','',
               tr('Independent of functional Nightly. GitHub-hosted values are reference measurements; five repetitions do not establish statistical significance.',
                  '機能テストのNightlyとは独立しています。GitHub標準ランナーの値は参考値で、5回の測定から統計的有意性を断言しません。'),'',
               ]
        lines += ['!['+tr('Daily overall elapsed ratio: Icarus 14 devel = 1','日次総合所要時間比：Icarus 14 devel = 1')+'](charts/daily-icarus14.svg)','',
            tr('Equal-weight geometric mean of all 25 daily designs (22 common + 3 four-state). Ratio = kirimasim / Icarus 14.0 devel incremental elapsed. 0.97 means 3% less elapsed time; lower is faster.',
               '日次25種類（共通22＋4値3）の等重み幾何平均です。比率はkirimasim÷Icarus 14.0 develの差分所要時間。0.97は所要時間が3%短い意味で、小さいほど高速です。'),'',
            tr('Both development heads are resolved once per campaign. A day uses its last formal attempt in JST; one invalid member makes the mean missing. Different environments/definitions are separate curves. Both simulators can affect the trend; fixed-version comparisons are below.',
               '両開発版のコミットを測定開始時に一度解決します。JSTの各日の最後の正式測定を使い、1種類でも無効なら総合値は欠測です。環境・定義ごとに線を分けます。双方の変更が推移に影響するため、固定版との比較も下に残します。'),'',
            '[JSON](headline.json) · [Method / 測定方法]('+METHOD+')','']
        if overall['points']:
            last=overall['points'][-1]
            lines += [tr('Latest overall attempt','最新の総合測定')+f": **{last['date']} JST — {cell(last['ratio'])}** ({last['available_count']}/25; {last['status']})",'',
                f"[Raw / 生データ](runs/{last['id']}.json) · [Actions logs / ログ]({last.get('actions_url') or METHOD})",'']
        else:
            lines += [tr('Awaiting a formal Icarus 14 devel run. Older Icarus 13 data is retained below and is not relabeled.',
                         'Icarus 14 develの正式測定待ちです。過去のIcarus 13の値は下に残し、14の値として転用しません。'),'']
        lines += ['<details><summary>'+tr('Case results, fixed-version comparisons and earlier series','ケース別結果・固定版との比較・過去の系列')+'</summary>','']
        for profile in ('daily','weekly'):
            if profile not in latest_by_profile:
                continue
            label=tr('Latest daily attempt','最新の日次測定') if profile=='daily' else tr('Latest weekly attempt','最新の週次測定')
            lines += ['## '+label,'',f'[JSON](latest-{profile}.json)','']+report(latest_by_profile[profile],ja=ja)
        lines+=['','## '+tr('Separate environment / definition series','環境・定義別の推移'),'']
        for series_id,items in reversed(list(series.items())):
            lines += [f"### `{series_id[:16]}`",'',f"{len(items)} runs; {items[0]['started_at']} → {items[-1]['started_at']}",'']
            definition=items[-1]['definition_config']
            lines += [tr('Definition','測定定義')+f": `{definition.get('definition','unnamed')}`; "+
                      tr('case count','ケース数')+f": **{len(definition['cases'])}**", '']
            for g in items[-1]['groups']:
                lines+=['!['+g['name']+'](charts/'+series_id+'/'+g['name']+'.svg)','']
            lines += [tr('Runs, including failures:','失敗を含む各回：'),'']
            for r in reversed(items):
                lines.append(f"- [{r['id']}](runs/{r['id']}.json): {r['status']} — `{r.get('tools',{}).get('latest',{}).get('commit','unknown')[:12]}`")
        lines += ['','</details>']
        (directory/('README.ja.md' if ja else 'README.md')).write_text('\n'.join(lines)+'\n')


def failure(args):
    from daily_benchmark import config_at, DEFAULT_CONFIG
    config=config_at(DEFAULT_CONFIG,args.profile)
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
    f.add_argument('--profile',choices=['daily','weekly'],default='daily')
    f.add_argument('--plan',type=Path);f.add_argument('--run-url');f.add_argument('--started-at')
    args=p.parse_args()
    if args.command=='append':append(args.directory,json.loads(args.result.read_text()))
    elif args.command=='render':render(args.directory)
    else:failure(args)


if __name__=='__main__':main()
