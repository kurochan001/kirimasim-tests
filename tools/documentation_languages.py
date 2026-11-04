#!/usr/bin/env python3
"""Inventory and validate English/Japanese document pairs without online translation.

--record records the current versions after both language pages were updated.
--update writes the paired documentation indexes. Generated report tools verify
their own localized outputs; handwritten pairs also use content fingerprints.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

import doc_localization as locale


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory(root=locale.ROOT):
    found=subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','*.md'],
                                  cwd=root,text=True).splitlines()
    return set(found)


def validate(data,root=locale.ROOT,check_hashes=True):
    errors=[];paths=set()
    for entry in data['documents']:
        bodies={}
        for language,other in (('en','ja'),('ja','en')):
            name=entry[language]
            if name in paths:errors.append('duplicate document: '+name)
            paths.add(name)
            path=root/name
            if not path.is_file():
                errors.append('missing '+language+' document: '+name)
                continue
            text=path.read_text(encoding='utf-8')
            bodies[language]=text
            if not re.search(r'^# .+',text,re.M):errors.append('missing title: '+name)
            counterpart=os.path.relpath(root/entry[other],path.parent).replace(os.sep,'/')
            if ']('+counterpart+')' not in text:
                errors.append('missing language link: '+name+' -> '+counterpart)
            if re.search(r'ZXQPH\d+QXZ',text):errors.append('unresolved translation placeholder: '+name)
            visible=re.sub(r'```.*?```|~~~.*?~~~','',text,flags=re.S)
            visible=re.sub(r'`[^`]*`|<[^>]*>','',visible)
            visible=re.sub(r'\]\([^)]*\)',']',visible).replace('日本語','')
            japanese=len(locale.JP.findall(visible))
            if language=='ja' and japanese<10:
                errors.append('Japanese documentation has no substantive Japanese prose: '+name)
            if language=='en' and locale.JP.search(locale.QUOTED.sub('',visible)):
                errors.append('English documentation contains untranslated Japanese prose: '+name)
            if check_hashes and not entry['generated']:
                recorded=entry.get('sha256',{}).get(language)
                if recorded!=sha(path):
                    errors.append('document pair changed; update both languages and run --record: '+name)
        if len(bodies)==2:
            levels={lang:[row[1] for row in locale.heading_rows(text)] for lang,text in bodies.items()}
            if levels['en']!=levels['ja']:
                errors.append('English/Japanese heading structures differ: '+entry['source'])
    unregistered=inventory(root)-paths
    errors.extend('unregistered Markdown documentation: '+name for name in sorted(unregistered))
    return errors


def category(entry):
    if entry['generated']:return 'generated'
    if re.search(r'\d{8}',entry['source']) or '/history' in entry['source']:
        return 'history'
    return 'guides'


def title(path):
    if not path.is_file():return path.stem
    text=path.read_text(encoding='utf-8')
    match=re.search(r'^# (.+)$',text,re.M)
    return match.group(1).replace('|','\\|') if match else path.stem


def indexes(data,root=locale.ROOT):
    outputs={}
    for lang,other in (('en','ja'),('ja','en')):
        filename=root/('docs/README.md' if lang=='en' else 'docs/README.ja.md')
        japanese=lang=='ja'
        lines=['# ドキュメント一覧' if japanese else '# Documentation', '',
               '[English](README.md) / [日本語](README.ja.md)', '',
               ('日英の資料を同じ章立て・内容で管理します。現在の数値と実行手順は'
                '[README](../README.ja.md)、過去の作業と測定は[履歴](history.ja.md)を参照してください。'
                if japanese else
                'Documents have English and Japanese counterparts. Use the [README](../README.md) '
                'for current counts and commands, and [history](history.md) for dated work and measurements.'), '',
               ('コード・識別子・生の実行記録・ライセンス条文は原形を保ちます。生成資料も両言語を同時に更新します。'
                if japanese else
                'Code, identifiers, raw execution evidence and license terms retain their original form. '
                'Generated reports update both language versions together.'), '',
               ('[章間マトリクス](chapter-cross-matrix.md)と[未登録章対の仕分け](chapter-cross-triage.md)からは、日英のCSVにも辿れます。'
                if japanese else '[Chapter matrices](chapter-cross-matrix.en.md) and '
                '[unregistered-pair triage](chapter-cross-triage.en.md) also link to English and Japanese CSV exports.'), '']
        lines += ['## '+('目的から読む' if japanese else 'Read by purpose'), '',
                  ('- 初めてテストを1本読む：[実在する短いテストの読み解き](faq.md#q49-read-a-real-test) → [テストカタログ](tests/README.ja.md)。'
                   if japanese else '- Read one test: [walk through a real short test](faq.en.md#q49-read-a-real-test) → [test catalog](tests/README.md).'),
                  ('- Nightlyの結果を読む：[緑でもDifferが残る理由](faq.md#q11-why-can-nightly-be-green-with-differ-results) → [版・日時と結果の確認手順](nightly-results.md#read-a-result-row)。'
                   if japanese else '- Read Nightly: [why green can coexist with Differ](faq.en.md#q11-why-can-nightly-be-green-with-differ-results) → [check versions, dates and outcomes](nightly-results.en.md#read-a-result-row).'),
                  ('- 何が検証済みか調べる：[設計と実行確認の違い](faq.md#q16-how-do-design-and-execution-coverage-differ) → [要求の集計](behavior-coverage-summary.md)／[章間表](chapter-cross-matrix.md)。'
                   if japanese else '- Find what is verified: [design versus confirmed execution](faq.en.md#q16-how-do-design-and-execution-coverage-differ) → [requirement summary](behavior-coverage-summary.en.md) / [chapter matrix](chapter-cross-matrix.en.md).'), '']
        headings={'guides':('Guides and technical references','ガイド・技術資料'),
                  'generated':('Generated reports and catalogs','自動生成レポート・カタログ'),
                  'history':('Historical records','過去の作業・測定記録')}
        for kind in ('guides','generated','history'):
            lines += ['## '+headings[kind][japanese], '',
                      '| 資料 | 日本語 | English |' if japanese else '| Document | English | 日本語 |',
                      '| --- | --- | --- |']
            for entry in data['documents']:
                if category(entry)!=kind or entry['source']=='docs/README.md':continue
                label=title(root/entry[lang])
                left=os.path.relpath(root/entry[lang],filename.parent).replace(os.sep,'/')
                right=os.path.relpath(root/entry[other],filename.parent).replace(os.sep,'/')
                lines.append(f'| {label} | [{"日本語" if japanese else "English"}]({left}) | '
                             f'[{"English" if japanese else "日本語"}]({right}) |')
            lines.append('')
        outputs[filename]='\n'.join(lines)
    paired=locale.parallel_anchors({lang:outputs[root/name] for lang,name in
        [('en','docs/README.md'),('ja','docs/README.ja.md')]})
    return {root/name:paired[lang] for lang,name in
        [('en','docs/README.md'),('ja','docs/README.ja.md')]}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    mode=parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--check',action='store_true')
    mode.add_argument('--record',action='store_true')
    mode.add_argument('--update',action='store_true')
    mode.add_argument('--inventory',action='store_true')
    args=parser.parse_args()
    data=json.loads(locale.MANIFEST.read_text(encoding='utf-8'))
    if args.inventory:
        complete=sum(all((locale.ROOT/e[l]).is_file() for l in ('en','ja')) for e in data['documents'])
        print(f'{complete}/{len(data["documents"])} document pairs exist')
        return 0
    if args.update:
        for path,text in indexes(data).items():path.write_text(text,encoding='utf-8')
        return 0
    if args.record:
        errors=validate(data,check_hashes=False)
        if not errors:
            for entry in data['documents']:
                if not entry['generated']:
                    entry['sha256']={l:sha(locale.ROOT/entry[l]) for l in ('en','ja')}
            locale.MANIFEST.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    else:
        errors=validate(data)
        for path,expected in indexes(data).items():
            if not path.is_file() or path.read_text(encoding='utf-8')!=expected:
                errors.append('stale documentation index: '+str(path.relative_to(locale.ROOT)))
    for error in errors:print(error,file=sys.stderr)
    if not errors:print(f'{len(data["documents"])} English/Japanese document pairs are current.')
    return int(bool(errors))


if __name__=='__main__':
    raise SystemExit(main())
