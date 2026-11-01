"""Offline documentation localization with exact technical literals and cached prose."""
from pathlib import Path
from collections import Counter
import hashlib
import json
import re
from functools import lru_cache
from urllib.parse import unquote
import os
import csv
import io

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / 'docs/languages.json'
LOCALES = ROOT / 'tools/doc_locales'
CSV_DOCUMENTS={
    'coverage/chapter-cross-models.csv':(1,),
    'coverage/chapter-cross-passed-models.csv':(1,),
    'coverage/chapter-cross-details.csv':(1,3,4,6,15),
    'coverage/chapter-cross-status.csv':(1,),
    'coverage/chapter-cross-triage.csv':(1,3,5,8,9,10,11,16),
}


class MissingTranslation(ValueError):
    """Do not silently publish source-language prose as a completed translation."""


@lru_cache(maxsize=1)
def documents():
    return json.loads(MANIFEST.read_text(encoding='utf-8'))['documents']


@lru_cache(maxsize=2)
def translations(language):
    data=json.loads((LOCALES/(language+'.json')).read_text(encoding='utf-8'))
    return data['translations']


@lru_cache(maxsize=1)
def document_map():
    records=documents()
    for record in records:
        for language in ('en','ja'):
            name=record[language];path=Path(name)
            if path.is_absolute() or '..' in path.parts or path.suffix!='.md':
                raise ValueError('documentation paths must be repository-relative Markdown: '+name)
            try:(ROOT/path).resolve().relative_to(ROOT)
            except ValueError:raise ValueError('documentation path escapes repository: '+name)
    return {record[lang]:record for record in records for lang in ('en','ja')}


def slug(title):
    title=re.sub(r'!?\[([^\]]*)\]\([^)]*\)',r'\1',title)
    title=re.sub(r'<[^>]*>','',title).replace('`','').replace('\\','').lower()
    return re.sub(r'[^\w\- ]','',title,flags=re.UNICODE).replace(' ','-')


def localized_url(url,language,source_path,target_path):
    if not url or url.startswith(('#','http:','https:','mailto:','data:')):
        return url
    path,separator,fragment=url.partition('#')
    if '?' in path:return url
    if Path(unquote(path)).suffix.lower() not in ('.md','.csv'):return url
    absolute=(source_path.parent/unquote(path)).resolve()
    try:name=absolute.relative_to(ROOT).as_posix()
    except ValueError:return url
    if name.endswith('.en.csv') and name.removesuffix('.en.csv')+'.csv' in CSV_DOCUMENTS:
        name=name.removesuffix('.en.csv')+'.csv'
    if name in CSV_DOCUMENTS:
        localized=ROOT/(name.removesuffix('.csv')+'.en.csv' if language=='en' else name)
    else:
        record=document_map().get(name)
        if record is None:return url
        localized=ROOT/record[language]
    relative=os.path.relpath(localized,target_path.parent).replace(os.sep,'/')
    return relative+(separator+fragment if separator else '')


def rewrite_links(text,language,source_path,target_path,label_transform=None):
    """Localize navigation in authored pages without translating their prose."""
    output=[];fence=None
    for line in text.splitlines(keepends=True):
        if line.lstrip().startswith(('```','~~~')):
            marker=line.lstrip()[:3]
            fence=None if fence==marker else marker if fence is None else fence
        if fence is not None or line.lstrip().startswith(('```','~~~')):
            output.append(line);continue
        spans=[]
        def code(match):
            spans.append(match.group());return f'ZXQCODE{len(spans)-1}QXZ'
        protected=CODE.sub(code,line)
        def link(match):
            parts=re.fullmatch(r'(!?)\[(.*)\]\((.*)\)',match.group())
            image,label,url=parts.groups()
            destination='en' if label.strip() in ('English','英語') else 'ja' if label.strip()=='日本語' else language
            if label_transform is not None:label=label_transform(label)
            return image+'['+label+']('+localized_url(url,destination,Path(source_path),Path(target_path))+')'
        protected=LINK.sub(link,protected)
        for index,value in enumerate(spans):protected=protected.replace(f'ZXQCODE{index}QXZ',value)
        output.append(protected)
    return ''.join(output)


def macro_prose(text):
    """Escape bare SV backticks that would otherwise hide prose as Markdown code.

    Requirement observations can contain raw directives, not balanced inline
    code. Keep real code examples and their quoted/template arguments intact.
    """
    for _ in range(10):
        def repair(match):
            body=match.group(2)
            if len(match.group(1))!=1:return match.group()
            prose=re.sub(r"<[^>]*>|\([^)]*\)|（[^）]*）|\"[^\"]*\"|'[^']*'",'',body)
            following=text[match.end():]
            embedded=re.match(r'[A-Za-z_\\`]',following)
            english=embedded and re.search(r'\b(?:the|and|after|before|on|its|which|where|must|shall|is)\b',prose,re.I)
            if not JP.search(body) and not english:return match.group()
            if not JP.search(prose) and not embedded:return match.group()
            directive=re.match(r'(?:timescale|define|undef|resetall|include|ifdef|ifndef|elsif|else|endif|default_nettype|unconnected_drive|nounconnected_drive|celldefine|endcelldefine|begin_keywords|end_keywords|line|SV_COV_\w*)\b',body)
            if directive or embedded or re.search(r'区別[:：]|として|誤実装',body):
                return r'\`'+body+r'\`'
            return match.group()
        revised=CODE.sub(repair,text)
        if revised==text:break
        text=revised
    # A single remaining grave accent is also a Verilog macro/directive prefix.
    # Escape only outside balanced inline code, leaving actual examples exact.
    output=[];end=0
    def escape(part):return re.sub(r'(?<![\\`])`(?=[A-Za-z_\\])',lambda m:r'\`',part)
    for match in CODE.finditer(text):
        output.extend((escape(text[end:match.start()]),match.group()));end=match.end()
    output.append(escape(text[end:]))
    return ''.join(output)


def inline(text,language,source_path,target_path):
    text=macro_prose(text)
    if text in ('English','日本語'):
        return text
    if re.fullmatch(r'[a-z][a-z_0-9]*: [a-z_0-9, ./-]+[。.]?',text.strip()):
        return text
    raw_field=re.fullmatch(r'(環境|実行日時|ケース状態)[:：]\s*(.*)',text,re.S)
    if raw_field:
        labels={'環境':'Environment','実行日時':'Execution timestamp','ケース状態':'Case statuses'}
        label,value=raw_field.groups()
        return ((labels[label]+': '+value.rstrip('。')+'.') if language=='en' else text)
    # Report field names are metadata, separate from their prose values. In
    # particular, an English acceptance criterion must not be retranslated just
    # because the canonical report gives it a Japanese field label.
    fields={'合格基準':'Acceptance criterion','区別':'Distinguishing observation',
            '根拠':'Rationale','計測元':'Measurement source','規定の性質':'Normative role',
            '対象':'Scope','制約':'Constraints','修正案':'Proposed correction',
            '範囲・制限':'Scope and limits','観測できない':'Not observed',
            '観測できた':'Observed','実行結果':'Execution results','条項':'Clause',
            '対応登録済み':'Registered bindings','規格':'Standard','版':'Edition'}
    field=re.fullmatch(r'\s*('+ '|'.join(map(re.escape,fields))+r')[:：]\s*(.*)',text,re.S)
    if field:
        label,value=field.groups()
        return (fields[label] if language=='en' else label)+':'+(
            ' '+inline(value,language,source_path,target_path) if value else '')
    masked,literals=protect(text)
    def original(part,values=literals):
        for index in reversed(range(len(values))):
            part=part.replace(f'ZXQPH{index}QXZ',values[index])
        return part.strip()
    boundary=r'\s+(?=(?:合格基準|区別)[:：])'
    def split_field(masked_prefix):
        # Restoration is only for locating the boundary. Its placeholder
        # padding must never be reparsed as source (real'(x) is not real ' (x)).
        def normalized(value):return re.sub(r'\s+','',value)
        wanted=normalized(original(masked_prefix))
        for candidate in re.finditer(boundary,text):
            prefix,values=protect(text[:candidate.start()])
            if normalized(original(prefix,values))==wanted:
                return inline(text[:candidate.start()],language,source_path,target_path)+' '+inline(
                    text[candidate.end():],language,source_path,target_path)
        raise MissingTranslation('cannot locate original metadata boundary: '+text[:220])
    if language=='en':
        embedded=re.search(boundary,masked)
        if embedded:
            # Report observations often join original English prose to a
            # Japanese field. Translate the field independently so that the
            # English observations and their value/count associations survive.
            return split_field(masked[:embedded.start()])
    sections=list(sentences(masked))
    def mixed_field(part):
        # A long Japanese field must not hide a short English observation tail.
        # Keep existing complete translations; split only otherwise-skipped text.
        if language!='ja' or needed(part,language):return None
        match=re.search(boundary,part)
        return match if match and needed(part[:match.start()],language) else None
    if language=='ja':
        cursor=0
        for part,ids in sections:
            def global_ids(value):
                return re.sub(r'ZXQPH(\d+)QXZ',lambda m:ids[int(m.group(1))],value)
            expanded=global_ids(part)
            start=masked.index(expanded,cursor);cursor=start+len(expanded)
            embedded=mixed_field(part)
            if embedded:
                return split_field(masked[:start]+global_ids(part[:embedded.start()]))
    requires=any(needed(part,language) for part,ids in sections)

    def link(match):
        parsed=re.fullmatch(r'(!?)\[(.*)\]\((.*)\)',match.group(),re.S)
        if parsed is None:return match.group()
        image,label,url=parsed.groups()
        destination='en' if label.strip() in ('English','英語') else 'ja' if label.strip()=='日本語' else language
        label=inline(label,language,source_path,target_path)
        return image+'['+label+']('+localized_url(url,destination,source_path,target_path)+')'

    if not requires:
        # Keep original emphasis and spacing when the prose is already localized.
        return rewrite_links(text,language,source_path,target_path,
                             lambda label:inline(label,language,source_path,target_path))
    converted=[]
    for part,ids in sections:
        if language=='en':
            # An English observation can contain a canonical Japanese field
            # name in its middle. Localize that metadata without retranslating
            # the already-English statement (or changing its technical meaning).
            labels=re.sub(r'('+ '|'.join(map(re.escape,fields))+r')[:：]',
                          lambda match:fields[match.group(1)]+':',part)
            if not JP.search(labels):part=labels
        if needed(part,language):
            translated=translations(language).get(part)
            if translated is None:
                raise MissingTranslation(f'missing {language} documentation translation: {part[:220]}')
            expected=re.findall(r'ZXQPH\d+QXZ',part)
            actual=re.findall(r'ZXQPH\d+QXZ',translated)
            if Counter(expected)!=Counter(actual):
                raise MissingTranslation(f'corrupt {language} literal placeholders: {part[:220]}')
            if re.search(r'https?://|<\s*(?:script|iframe)\b',translated,re.I):
                raise MissingTranslation('translation introduced unprotected links or active HTML')
        else:
            translated=part
        translated=re.sub(r'ZXQPH(\d+)QXZ',lambda m:ids[int(m.group(1))],translated)
        converted.append(translated)
    result=(' ' if language=='en' else '').join(converted)
    for index in reversed(range(len(literals))):
        value=literals[index]
        is_link=LINK.fullmatch(value) is not None
        # Code nested in a link label was protected before the whole link.
        # Restore it before translating that label in its own local namespace.
        for earlier in reversed(range(index)):
            value=value.replace(f'ZXQPH{earlier}QXZ',literals[earlier])
        if is_link:value=link(re.fullmatch(r'.*',value,re.S))
        result=result.replace(f'ZXQPH{index}QXZ',value)
    if re.search(r'ZXQPH\d+QXZ',result):
        raise MissingTranslation('unresolved technical literal placeholder')
    return result


def render(text,language,source_path,target_path,record):
    source_path=Path(source_path);target_path=Path(target_path)
    tokens=list(pieces(text));output=[];counts=Counter()
    existing=set(re.findall(r'<a\s+id="([^"]+)"',text))
    for index,(kind,body) in enumerate(tokens):
        if kind=='text':
            output.append(markdown_angles(inline(body,language,source_path,target_path)))
            continue
        summary=re.fullmatch(r'(\s*<summary>)(.*)(</summary>\s*\n?)',body,re.S)
        if summary:
            output.append(summary.group(1)+markdown_angles(inline(summary.group(2),language,source_path,target_path))
                          +summary.group(3))
            continue
        if re.fullmatch(r'#{1,6} ',body) and index+1<len(tokens):
            title=tokens[index+1][1]
            original=slug(title);number=counts[original];counts[original]+=1
            anchor=original+(f'-{number}' if number else '')
            translated=inline(title,language,source_path,target_path)
            if anchor and slug(translated)!=original and anchor not in existing:
                output.append(f'<a id="{anchor}"></a>\n\n')
                existing.add(anchor)
        output.append(body)
    result=''.join(output).rstrip()+'\n'
    counterpart=ROOT/record['ja' if language=='en' else 'en']
    relative=os.path.relpath(counterpart,target_path.parent).replace(os.sep,'/')
    if ']('+relative+')' not in result:
        en=os.path.relpath(ROOT/record['en'],target_path.parent).replace(os.sep,'/')
        ja=os.path.relpath(ROOT/record['ja'],target_path.parent).replace(os.sep,'/')
        navigation=f'\n\n[English]({en}) / [日本語]({ja})'
        result=re.sub(r'^(# .+)$',lambda m:m.group()+navigation,result,count=1,flags=re.M)
    return result


def versions(path,text):
    """Expand a registered Markdown report; external exports/fixtures pass through."""
    path=Path(path)
    if path.suffix!='.md':return {path:text}
    try:name=path.resolve().relative_to(ROOT).as_posix()
    except ValueError:return {path:text}
    record=document_map().get(name)
    if record is None:return {path:text}
    output={lang:render(text,lang,path,ROOT/record[lang],record) for lang in ('en','ja')}
    output=parallel_anchors(output)
    return {ROOT/record[lang]:output[lang] for lang in ('en','ja')}


def export_versions(path,text,canonical_path,*,source_url=None,siblings=None):
    """Explicitly export a registered document to a Japanese/English file pair.

    Unlike versions(), this never infers registration from an export filename.
    Siblings explicitly map canonical documents to Japanese export paths. Other
    registered repository links use source_url when supplied; arbitrary remote
    links and raw examples remain unchanged.
    """
    path=Path(path)
    if path.suffix!='.md':
        raise ValueError('bilingual exports require a Markdown output path')
    records=document_map()
    def registered(name):
        candidate=Path(name)
        if not candidate.is_absolute():candidate=ROOT/candidate
        try:key=candidate.resolve().relative_to(ROOT).as_posix()
        except ValueError:key=None
        record=records.get(key)
        if record is None:
            raise ValueError('bilingual export requires a registered canonical document: '+str(name))
        return record
    record=registered(canonical_path)
    bindings={}
    exported={}
    for name,target in {**(siblings or {}),canonical_path:path}.items():
        sibling=registered(name)
        target=Path(target)
        if target.suffix!='.md':
            raise ValueError('bilingual export siblings require Markdown output paths')
        pair={'ja':target.resolve(),'en':target.with_suffix('.en.md').resolve()}
        for language in ('en','ja'):
            bindings[sibling[language]]=pair
            exported[pair[language]]=pair
    targets={'ja':path,'en':path.with_suffix('.en.md')}
    exported_record={**record,**{lang:str(target.resolve()) for lang,target in targets.items()}}
    prefix=source_url.rstrip('/')+'/' if source_url else None

    def links(text,language,target):
        def destination(url,wanted):
            if not url or url.startswith(('#','mailto:','data:')):return url
            name,separator,fragment=url.partition('#')
            if '?' in name:return url
            pair=None;repository_name=None
            if prefix and name.startswith(prefix):
                repository_name=unquote(name[len(prefix):])
            elif re.match(r'[a-zA-Z][a-zA-Z0-9+.-]*:',name):
                return url
            else:
                absolute=(target.resolve().parent/unquote(name)).resolve()
                pair=exported.get(absolute)
                try:repository_name=absolute.relative_to(ROOT).as_posix()
                except ValueError:pass
            if pair is None:pair=bindings.get(repository_name)
            if pair is not None:
                result=os.path.relpath(pair[wanted],target.resolve().parent).replace(os.sep,'/')
            elif repository_name in records:
                localized=records[repository_name][wanted]
                result=prefix+localized if prefix else os.path.relpath(
                    ROOT/localized,target.resolve().parent).replace(os.sep,'/')
            elif repository_name in CSV_DOCUMENTS or (
                    repository_name and repository_name.endswith('.en.csv') and
                    repository_name.removesuffix('.en.csv')+'.csv' in CSV_DOCUMENTS):
                base=repository_name.removesuffix('.en.csv')+'.csv' if repository_name.endswith('.en.csv') else repository_name
                localized=base.removesuffix('.csv')+'.en.csv' if wanted=='en' else base
                result=prefix+localized if prefix else os.path.relpath(
                    ROOT/localized,target.resolve().parent).replace(os.sep,'/')
            else:return url
            return result+(separator+fragment if separator else '')
        output=[];fence=None
        for line in text.splitlines(keepends=True):
            if line.lstrip().startswith(('```','~~~')):
                marker=line.lstrip()[:3]
                fence=None if fence==marker else marker if fence is None else fence
            if fence is not None or line.lstrip().startswith(('```','~~~')):
                output.append(line);continue
            spans=[]
            def code(match):
                spans.append(match.group());return f'ZXQCODE{len(spans)-1}QXZ'
            protected=CODE.sub(code,line)
            def link(match):
                parts=re.fullmatch(r'(!?)\[(.*)\]\((.*)\)',match.group())
                image,label,url=parts.groups()
                wanted='en' if label.strip() in ('English','英語') else 'ja' if label.strip()=='日本語' else language
                return image+'['+label+']('+destination(url,wanted)+')'
            protected=LINK.sub(link,protected)
            for index,value in enumerate(spans):protected=protected.replace(f'ZXQCODE{index}QXZ',value)
            output.append(protected)
        return ''.join(output)
    output={lang:links(render(text,lang,ROOT/record['ja'],target.resolve(),exported_record),lang,target)
            for lang,target in targets.items()}
    output=parallel_anchors(output)
    return {targets[lang]:output[lang] for lang in ('en','ja')}


def heading_rows(text):
    rows=[];counts=Counter();fence=None
    for index,line in enumerate(text.splitlines()):
        if line.lstrip().startswith(('```','~~~')):
            marker=line.lstrip()[:3]
            fence=None if fence==marker else marker if fence is None else fence
            continue
        if fence is not None:continue
        heading=re.fullmatch(r'(#{1,6}) (.+)',line)
        if heading:
            base=slug(heading.group(2));number=counts[base];counts[base]+=1
            rows.append((index,len(heading.group(1)),base+(f'-{number}' if number else '')))
    return rows


def parallel_anchors(output):
    """Both pages accept both languages' fragments, including duplicate headings."""
    rows={language:heading_rows(text) for language,text in output.items()}
    if [r[1] for r in rows['en']] != [r[1] for r in rows['ja']]:
        raise ValueError('English/Japanese heading structures differ')
    result={}
    for language,other in (('en','ja'),('ja','en')):
        existing=set(re.findall(r'<a\s+id="([^"]+)"',output[language]))
        insert={}
        for own,alternate in zip(rows[language],rows[other]):
            anchor=alternate[2]
            if anchor and anchor!=own[2] and anchor not in existing:
                insert[own[0]]=f'<a id="{anchor}"></a>\n\n'
                existing.add(anchor)
        lines=output[language].splitlines()
        result[language]='\n'.join((insert.get(index,'')+line) for index,line in enumerate(lines))+'\n'
    return result


def expand(outputs,root=ROOT):
    """Keep caller key/value types for generated Markdown alongside JSON/CSV."""
    if Path(root).resolve()!=ROOT:
        return outputs
    result={}
    for name,content in outputs.items():
        original=Path(name)
        path=original if original.is_absolute() else ROOT/original
        try:csv_name=path.relative_to(ROOT).as_posix()
        except ValueError:csv_name=None
        if path.suffix=='.csv' and csv_name in CSV_DOCUMENTS:
            text=content.decode('utf-8-sig') if isinstance(content,bytes) else content
            translated=csv_version(path,text)
            target=path.with_suffix('.en.csv')
            key=target if isinstance(name,Path) else (
                str(target) if original.is_absolute() else target.relative_to(ROOT).as_posix())
            result[name]=content
            result[key]=translated.encode('utf-8-sig') if isinstance(content,bytes) else translated
            continue
        if path.suffix!='.md':
            result[name]=content
            continue
        text=content.decode('utf-8') if isinstance(content,bytes) else content
        for target,localized in versions(path,text).items():
            key=target if isinstance(name,Path) else (
                str(target) if original.is_absolute() else target.relative_to(ROOT).as_posix())
            result[key]=localized.encode('utf-8') if isinstance(content,bytes) else localized
    return result


def csv_version(path,text):
    """Translate documented prose columns; retain raw expectations and evidence."""
    from suite_stats import CHAPTERS,CHAPTERS_JA
    name=path.relative_to(ROOT).as_posix()
    fields={
        '章番号':'Chapter number','章名':'Chapter name','章A':'Chapter A','章A名':'Chapter A name',
        '章B':'Chapter B','章B名':'Chapter B name','区分':'Kind','モデルID':'Model ID',
        '対応根拠':'Mapping rationale','該当条件':'Applicable conditions',
        '該当選択ケース数':'Applicable selected cases','該当pass':'Applicable pass',
        '該当fail':'Applicable fail','該当known':'Applicable known',
        '該当unsupported':'Applicable unsupported','モデル選択ケース数':'Model selected cases',
        'モデル全選択ケースpass':'All model selections passed','モデルの観測目的':'Model observation scope',
        '代表テスト':'Representative test','代表テストの規格条項':'Representative standard clauses',
        '代表期待値':'Representative expectation','実行結果JSON':'Execution result JSON',
        'シミュレータ':'Simulator','版':'Version','実行日時':'Execution timestamp',
        '対応付けレビュー日':'Mapping review date','対応付けレビュー者':'Mapping reviewer',
        '分類コード':'Category code','分類':'Category','優先度':'Priority','登録モデル数':'Registered models',
        '判断理由':'Rationale','検証目標':'Verification objective','因子候補':'Candidate factors',
        '期待する観測':'Expected observation','確認済みテスト数':'Reviewed tests',
        '確認済みテスト':'Reviewed test paths','同時引用件数（探索用）':'Joint citations (discovery only)',
        '未レビュー探索候補（最大3件）':'Unreviewed candidates (up to 3)',
        '次の作業':'Next action','レビュー日':'Review date','レビュー者':'Reviewer',
        '主題章':'Primary chapter','章間クロス':'Cross-chapter interaction',
        '主題章のモデル':'Model for the primary chapter',
        '概要':'Overview','引用規格':'Normative references','データ読出しAPI':'Data read API',
        **{title:CHAPTERS[number] for number,title in CHAPTERS_JA.items()},
    }
    rows=list(csv.reader(io.StringIO(text.lstrip('\ufeff'))))
    target=path.with_suffix('.en.csv')
    for index,row in enumerate(rows):
        columns=range(len(row)) if index==0 else CSV_DOCUMENTS[name]
        for column in columns:
            value=row[column]
            if value in fields:row[column]=fields[value]
            elif JP.search(value):row[column]=inline(value,'en',path,target)
    stream=io.StringIO(newline='')
    csv.writer(stream,lineterminator='\n').writerows(rows)
    return stream.getvalue()

# The middle dot U+30FB is punctuation, including in otherwise-English lists;
# it is not evidence that an English observation needs translation.
JP=re.compile(r'[\u3040-\u30fa\u30fc-\u30ff\u3400-\u9fff]')
CODE=re.compile(r'(?<!\\)(`+)(.+?)\1',re.S)
LINK=re.compile(r'(?<!\\)!?\[[^\]\n]*(?<!\\)\]\([^\)\n]*\)')
HTML_BOOLEAN=r'allowfullscreen|async|autofocus|autoplay|checked|controls|default|defer|disabled|formnovalidate|hidden|inert|ismap|itemscope|loop|multiple|muted|nomodule|novalidate|open|playsinline|readonly|required|reversed|selected'
HTML_ATTRIBUTE=r'''(?:[A-Za-z_:][A-Za-z0-9_.:-]*[ \t]*=[ \t]*(?:"[^"\n]*"|'[^'\n]*'|[^\s"'=<>`]+)|(?i:'''+HTML_BOOLEAN+r')(?![A-Za-z0-9_.:-]))'
HTML_TAG=r'</?[A-Za-z][A-Za-z0-9-]*(?:[ \t]+'+HTML_ATTRIBUTE+r')*[ \t]*/?>'
HTML_ELEMENTS=set(('a abbr address area article aside audio b base bdi bdo blockquote body br button '
    'canvas caption cite code col colgroup data datalist dd del details dfn dialog div dl dt em embed '
    'fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img '
    'input ins kbd label legend li link main map mark menu meta meter nav noscript object ol optgroup '
    'option output p param picture pre progress q rp rt ruby s samp script search section select slot '
    'small source span strong style sub summary sup table tbody td template textarea tfoot th thead '
    'time title tr track u ul var video wbr acronym big center font nobr strike tt').split())
MARKUP=re.compile(r'''\\`[A-Za-z_][A-Za-z0-9_]*(?:\\`)?|\\["']|\\[\\`*_{}\[\]()#+.!|<>-]|&(?:amp|lt|gt|quot|apos|#\d+|#x[0-9a-fA-F]+);|'''+HTML_TAG)
OPERATOR=re.compile(r'(?:(?:\\)?\|=>|(?:\\)?\|->|#=#|#-#|<->|&&|(?:\\)?\|(?:\\)?\||\*\*)')
ESCAPED_QUOTED=re.compile(r'(?<!\\)\\"(?:\\[^\n]|[^"\\\n])*?\\"')
QUOTED=re.compile(r'''(?<!\\)"""(?:\\[^\n]|(?!""")[^\\\n])*"""|(?<![A-Za-z0-9_'\\])'(?:\\[^\n]|[^'\\\n])*'(?![A-Za-z0-9_])|(?<!\\)"(?:\\[^\n]|[^"\\\n])*"''')
QUOTED_OR_TAG=re.compile('(?:'+QUOTED.pattern+')|(?:'+ESCAPED_QUOTED.pattern+')|(?:'+HTML_TAG+')')
SV_APOSTROPHE=re.compile(r"'(?:[ \t]*[01xXzZ](?![A-Za-z0-9_])|[sS]?(?:[bB][ \t]*[01_xXzZ?]+|[oO][ \t]*[0-7_xXzZ?]+|[dD][ \t]*[0-9_xXzZ?]+|[hH][ \t]*[0-9a-fA-F_xXzZ?]+)(?![A-Za-z0-9_])|[({])")
KEYWORD=re.compile(r'(?<![A-Za-z0-9_])(?:const ref|output/inout|logic|bit|reg|wire|int|integer|byte|shortint|longint|shortreal|realtime|typedef|enum|randcase|randsequence|covergroup|coverpoint|illegal_bins|ignore_bins|randc|genvar|posedge|negedge|always_comb|always_ff|always_latch|localparam|specparam|defparam|join_any|join_none|packed|unpacked)(?![A-Za-z0-9_])')
QUALIFIED=re.compile(r'(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*(?:(?:\.|::)[A-Za-z_][A-Za-z0-9_]*)+|(?<![A-Za-z0-9_])[a-z][A-Za-z0-9_]*[A-Z][A-Za-z0-9_]*(?![A-Za-z0-9_])')
TECHNICAL=re.compile(r"(?<![A-Za-z0-9_])(?:\d+)?'[sS]?[bBoOdDhH][0-9a-fA-F_xXzZ?]+|(?<![A-Za-z0-9_])'[01xXzZ](?!\w)|(?<![A-Za-z0-9_])(?=[0-9a-f]*[a-f])(?=[0-9a-f]*\d)[0-9a-f]{7,40}(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])(?:[A-Za-z0-9_.-]+/)*[A-Za-z0-9_.-]+\.(?:sv|svh|v|vh|py|json|csv|md|yml|yaml|txt|log|pdf)(?![A-Za-z0-9_])")
TOKEN=re.compile(r'https?://[^\s<>]+|(?<![A-Za-z0-9_])[A-Q](?:\.\d+)+(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[A-Q][–-][A-Q](?![A-Za-z0-9_])|(?:(?<=Annex )|(?<=annex )|(?<=Annexes )|(?<=annexes )|(?<=附属書))[A-Q](?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*(?=\s*=)|(?<![A-Za-z0-9_])(?:SystemVerilog|Icarus(?: Verilog)?|Verilator|kirimasim(?:-tests)?|Lyra|Ghost|slang|SymbiYosys|Yosys|Nightly|Check|DPI-C|VPI|BMC|PDR|SVA|IEEE|SHA-256)(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)+(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[A-Za-z][A-Za-z0-9_-]*\d[A-Za-z0-9_-]*(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[A-Z]{2,}[A-Z0-9_-]*(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])[+-]?\d+(?:[.,:/–-]\d+)*(?:%|[a-zA-Z]+)?|\$[A-Za-z_][A-Za-z0-9_]*')

def protect_quotes(text,save):
    """Keep quoted data/HTML exact without pairing SV quotes over prose."""
    output=[];end=0;position=0
    while match:=QUOTED_OR_TAG.search(text,position):
        value=match.group()
        if value.startswith('<'):
            output.extend((text[end:match.start()],save(match)))
            end=position=match.end()
            continue
        width=3 if value.startswith('"""') else 2 if value.startswith(r'\"') else 1
        body=value[width:-width]
        prefix=SV_APOSTROPHE.match(value) if value.startswith("'") else None
        # A genuine quoted token such as '0' or '{a:1}' is still data. A
        # prefix followed by narration and another SV apostrophe is not.
        balanced=False
        if body[:1] in ('{','('):
            pairs={'{':'}','(':')'};stack=[]
            for index,char in enumerate(body):
                if char in pairs:stack.append(pairs[char])
                elif char in pairs.values():
                    if not stack or stack.pop()!=char:break
                    if not stack:
                        balanced=index==len(body)-1
                        break
        structural=body[:1] in ('{','(') and re.match(r'[({]',text[match.end():]) and (
            JP.search(body) or body[-1:].isspace())
        bare_tail=body[-1:].isspace() and JP.search(body) and re.search(
            r'\s+[をがとでのはも]|(?:区別|合格基準)[:：]|行目',body)
        sv_prose=prefix and prefix.end()!=len(value)-1 and not balanced and (structural or bare_tail)
        prose=JP.search(body) and re.search(
            r'^\s+(?:が|を|で|の|と|や|または|および|内で|\\)|\s+を、|^\s+.*(?:区別|合格基準)[:：]',body)
        # Explicit expected output can itself be a Japanese sentence, even
        # one containing a field label or leading whitespace.
        expected=re.search(r'(?:期待出力|expected output)\s*(?:は|:|is)?\s*$',
                           text[:match.start()],re.I)
        if (sv_prose or prose) and not expected:
            position=match.start()+1
            continue
        output.extend((text[end:match.start()],save(match)))
        end=position=match.end()
    output.append(text[end:])
    return ''.join(output)


def protect(text):
    literals=[]
    def save(m):
        literals.append(m.group())
        return f' ZXQPH{len(literals)-1}QXZ '
    text=CODE.sub(save,text)
    # Links/code retain exact labels and syntax at this draft stage.
    text=LINK.sub(save,text)
    text=protect_quotes(text,save)
    text=re.sub(r'(?<![A-Za-z0-9_)\]}])\*\*(?=\S)((?:(?!\*\*).)+?)(?<=\S)\*\*(?![A-Za-z0-9_])',r'\1',text)
    text=OPERATOR.sub(save,text)
    text=MARKUP.sub(save,text)
    # Comparisons become separate literals only after actual HTML is saved.
    text=re.sub(r'[<>]=?',save,text)
    text=TECHNICAL.sub(save,text)
    # Remaining apostrophes and quotation marks are individual punctuation,
    # including cast/pattern prefixes and descriptions of a quote character.
    text=re.sub(r'''(?<!\\)"|(?<![\\A-Za-z])'|(?<!\\)'(?![A-Za-z])''',save,text)
    text=QUALIFIED.sub(save,text)
    text=KEYWORD.sub(save,text)
    text=TOKEN.sub(lambda m:m.group() if m.group().startswith('ZXQPH') else save(m),text)
    return re.sub(r' +',' ',text).strip(),literals


def markdown_angles(text):
    """Display prose comparisons safely; keep code, link URLs and HTML exact.

    This belongs to Markdown rendering, not inline/CSV translation. English
    prose that needs no translation still must not become an accidental tag.
    """
    literals=[]
    def stash(value):
        literals.append(value)
        return f'ZXQANGLE{len(literals)-1}QXZ'
    def escape(value):return re.sub(r'(?<!\\)[<>]',lambda m:'\\'+m.group(),value)
    text=CODE.sub(lambda m:stash(m.group()),text)
    def link(match):
        image,label,url=re.fullmatch(r'(!?)\[(.*)\]\((.*)\)',match.group(),re.S).groups()
        return stash(image+'['+markdown_angles(label)+']('+url+')')
    text=LINK.sub(link,text)
    def quoted_or_tag(match):
        value=match.group()
        tag=re.match(r'</?([A-Za-z][A-Za-z0-9-]*)',value) if value.startswith('<') else None
        # Tokens such as <file> and <nl> are data placeholders, not elements.
        html=tag and (tag.group(1).lower() in HTML_ELEMENTS or '-' in tag.group(1))
        return stash(value if html else escape(value))
    text=protect_quotes(text,quoted_or_tag)
    text=escape(text)
    for index in reversed(range(len(literals))):
        text=text.replace(f'ZXQANGLE{index}QXZ',literals[index])
    return text

def sentences(masked):
    # Semicolon-separated normative clauses need separate translations: long
    # compound requirements otherwise risk losing a restriction in the draft.
    for part in re.split(r'(?<=[。！？;])|(?<=[.!?])\s+(?=[A-Z(])',masked):
        if not part.strip():continue
        ids=[]
        def renumber(m):
            if m.group() not in ids:ids.append(m.group())
            return f'ZXQPH{ids.index(m.group())}QXZ'
        yield re.sub(r'ZXQPH\d+QXZ',renumber,part.strip()),ids

def needed(text,language):
    plain=re.sub(r'ZXQPH\d+QXZ','',text)
    jp=len(JP.findall(plain));words=re.findall(r'[A-Za-z]{2,}',plain)
    if language=='en':return bool(jp)
    jp+=plain.count('・')  # Preserve the mixed-Japanese-label heuristic.
    if len(words)==1 and words[0] in {'rev','model','width','state','home','value','id','seed','bits','passing','storage','operator'}:return False
    return len(words)>=1 and jp<2*len(words)

def pieces(text):
    lines=text.splitlines();i=0
    while i<len(lines):
        line=lines[i]
        if not line.strip():yield ('literal','\n');i+=1;continue
        if line.lstrip().startswith(('```','~~~')):
            marker=line.lstrip()[:3];block=[line];i+=1
            while i<len(lines):
                block.append(lines[i]);i+=1
                if block[-1].lstrip().startswith(marker):break
            yield ('literal','\n'.join(block)+'\n');continue
        summary=re.fullmatch(r'(\s*<summary>)(.*)(</summary>\s*)',line)
        if summary:
            yield ('literal',summary.group(1))
            yield ('text',summary.group(2))
            yield ('literal',summary.group(3)+'\n')
            i+=1;continue
        if line.lstrip().startswith(('<!--','<a ','</details','<details','<summary','</summary')):
            block=[line];i+=1
            if line.lstrip().startswith('<!--') and '-->' not in line:
                while i<len(lines):
                    block.append(lines[i]);i+=1
                    if '-->' in block[-1]:break
            yield ('literal','\n'.join(block)+'\n');continue
        if re.fullmatch(r'\s*[-*:| ]+\s*',line):yield ('literal',line+'\n');i+=1;continue
        if line.startswith('|'):
            cells=re.split(r'(?<!\\)\|',line)
            for n,cell in enumerate(cells):
                if n:yield ('literal','|')
                if cell.strip():yield ('text',cell)
            yield ('literal','\n');i+=1;continue
        prefix=re.match(r'^(?:#{1,6} |\s*(?:[-*+] |\d+[.)] )|> ?)',line)
        if prefix:
            yield ('literal',prefix.group())
            body=line[prefix.end():];i+=1
            if not line.startswith('#'):
                while i<len(lines) and lines[i].strip() and not re.match(r'^(?:\s*[-*+] |\s*\d+[.)] |#{1,6} |> |\||```|~~~|<)',lines[i]):
                    body+=' '+lines[i].strip();i+=1
            yield ('text',body);yield ('literal','\n');continue
        if line.startswith('    '):yield ('literal',line+'\n');i+=1;continue
        body=line;i+=1
        while i<len(lines) and lines[i].strip() and not re.match(r'^(?:\s*[-*+] |\s*\d+[.)] |#{1,6} |> |\||```|~~~|<)',lines[i]):
            body+=' '+lines[i].strip();i+=1
        yield ('text',body);yield ('literal','\n')
