"""Literal preservation, strict translation coverage and language-local navigation."""

from pathlib import Path
import csv
import io
import tempfile
import unittest
import contextlib
import json
import sys
from unittest import mock

import doc_localization as locale
import documentation_languages as audit


class DocumentLocalization(unittest.TestCase):
    def setUp(self):
        self.source=locale.ROOT/'docs/sample.md'
        self.target=locale.ROOT/'docs/sample.en.md'
        self.record={'source':'docs/sample.md','source_language':'ja',
                     'en':'docs/sample.en.md','ja':'docs/sample.md','generated':False}
        self.map={self.record[lang]:self.record for lang in ('en','ja')}

    def test_numbers_versions_code_and_identifiers_are_exact_literals(self):
        source='全1,740節と `a <= b`、Verilator 5.052、SV2023_SAMPLE_1を確認します。'
        masked,literals=locale.protect(source)
        self.assertIn('1,740',literals)
        self.assertIn('`a <= b`',literals)
        self.assertIn('Verilator',literals)
        self.assertIn('5.052',literals)
        self.assertIn('SV2023_SAMPLE_1',literals)
        self.assertNotIn('1,740',masked)

    def test_missing_or_corrupt_translations_fail_instead_of_falling_back(self):
        source='全27件を検査します。'
        key=next(locale.sentences(locale.protect(source)[0]))[0]
        for cache in ({},{key:'All cases are checked.'}):
            with mock.patch.object(locale,'translations',return_value=cache):
                with self.assertRaises(locale.MissingTranslation):
                    locale.inline(source,'en',self.source,self.target)

    def test_escaped_directives_and_entities_remain_literal(self):
        source=r'The \`define directive compares a &lt; b and a \| b.'
        masked,literals=locale.protect(source)
        self.assertIn(r'\`define',literals)
        self.assertIn('&lt;',literals)
        self.assertIn(r'\|',literals)
        self.assertIn('directive compares',masked)

        raw='`resetall の前に `define WIDTH 4 を置き、`resetall の後で確認する。'
        repaired=locale.macro_prose(raw)
        self.assertEqual(repaired.count(r'\`'),3)
        self.assertFalse(any(locale.JP.search(m.group(2)) for m in locale.CODE.finditer(repaired)))
        masked,literals=locale.protect(repaired)
        self.assertIn('の前に',masked)
        self.assertIn(r'\`resetall',literals)
        english='`include names the file and `define supplies its macro.'
        self.assertNotIn('names the file', ''.join(m.group() for m in locale.CODE.finditer(locale.macro_prose(english))))
        self.assertIn(r'\`include',locale.macro_prose(english))
        english='`SV_COV_MODULE has scope semantics; a conforming tool is not required to predefine `OTHER.'
        self.assertEqual(locale.macro_prose(english).count(r'\`'),2)
        for example in ('`define NAME a`', '`begin_keywords "版"`','`run.py <作業dir>/bin`','`$sampled(式)`'):
            self.assertEqual(locale.macro_prose(example),example)
        source=r'\`" が引用符となる。区別: \`" の中で置換する。\`""" 内で置換する。'
        masked,literals=locale.protect(locale.macro_prose(source))
        for prose in ('が引用符となる。','区別:','の中で置換する。','内で置換する。'):
            self.assertIn(prose,masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        source=r'\`""" 内で置換する。区別: \`""" を引用符にする。'
        masked,literals=locale.protect(locale.macro_prose(source))
        self.assertIn('内で置換する。区別:',masked)
        self.assertIn('を引用符にする。',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))

    def test_escaped_array_index_is_not_mistaken_for_a_markdown_link(self):
        source=r'arr\[2\](配列要素)を観測します。'
        self.assertEqual(list(locale.LINK.finditer(source)),[])
        masked,literals=locale.protect(source)
        self.assertIn('配列要素',masked)
        self.assertIn(r'\[',literals)
        self.assertIn(r'\]',literals)

    def test_annex_clause_ids_and_assignment_keys_are_exact(self):
        source='Annex F and H.7.4, 附属書A–Q、pass=27, not_run=0'
        _,literals=locale.protect(source)
        for item in ('F','H.7.4','A–Q','pass','not_run','27','0'):
            self.assertIn(item,literals)

    def test_quoted_outputs_verilog_literals_paths_and_commit_ids_are_exact(self):
        source='期待出力は \'a=1 b=x\'。4\'b10xz、\'1、89bf5e833とresults/run.jsonを参照。'
        _,literals=locale.protect(source)
        for item in ("'a=1 b=x'","4'b10xz","'1",'89bf5e833','results/run.json'):
            self.assertIn(item,literals)
        source="'0 を代入した後、'1 と比較する。区別: '{1, 2} と '{3, 4} は異なる。"
        masked,literals=locale.protect(source)
        for prose in ('を代入した後、','と比較する。区別:','は異なる。'):
            self.assertIn(prose,masked)
        for value in ("'0","'1"):
            self.assertIn(value,literals)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        masked,literals=locale.protect("(W - 8)'(v) でエラーを求め、(W - 5)'(v) と比較する。")
        self.assertIn('でエラーを求め、',masked)
        self.assertIn('と比較する。',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        masked,literals=locale.protect(r'""、"___"、"say \"hi\"" の文字列を比較します。')
        for item in ('""','"___"',r'"say \"hi\""'):
            self.assertIn(item,literals)
        self.assertIn('の文字列を比較します。',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        for quoted in ("'日本語です。'",'"区別: 日本語です。"',"'{a:1}'","'(v)'","'0'",
                       "'bad output'","'dead beef'",'" が1つ。区別: 日本語です。"',
                       r'\"日本語です。\"',r'\"\"',"'a <b> 日本語'"):
            _,literals=locale.protect('期待出力は '+quoted+'。')
            self.assertIn(quoted,literals)
        _,literals=locale.protect("値は'日本語です。'です。")
        self.assertIn("'日本語です。'",literals)
        for quoted in ("'x index: null=1'","'x index: r=0.0 sr=0.0'","'0 iterations'",
                       "'x on again: ok=1 x=6'","""'{a3, b3} == "abcd": 0'""","'1: x'"):
            _,literals=locale.protect('比較すると '+quoted+' と表示する。')
            self.assertIn(quoted,literals)
        _,literals=locale.protect("後の項目'1: x'(x=1)を使わない。")
        self.assertIn("'1: x'",literals)
        _,literals=locale.protect("値'x 日本語'と比較する。")
        self.assertIn("'x 日本語'",literals)
        masked,literals=locale.protect("Each element's value uses the unit's scale; don't change it.")
        for word in ("element's","unit's","don't"):
            self.assertIn(word,masked)
        self.assertNotIn("'",literals)
        triple=r'''"""q\"r\ns"t<改行>u"""'''
        _,literals=locale.protect('三重引用符文字列 '+triple+' を使う。')
        self.assertIn(triple,literals)
        masked,literals=locale.protect('文字列 "first part ... を、改行で次の行 second part" まで続ける。')
        self.assertIn('を、改行で次の行',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        masked,_=locale.protect('For i<=j<length it contains both endpoints. The cases i>j are outside.')
        self.assertIn('length it contains both endpoints. The cases',masked)
        masked,literals=locale.protect(r'''値は'a=1'です。q = \"x\ty\" と、内部の \" や \"\" を比較します。''')
        self.assertIn("'a=1'",literals)
        self.assertIn(r'\"x\ty\"',literals)
        self.assertIn('を比較します。',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        masked,literals=locale.protect(r'\" \v \f \a、表にない \q を入れ、\" を比較します。')
        self.assertIn('表にない',masked)
        self.assertIn('を入れ、',masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        masked,literals=locale.protect('内部の " や "" を保持します。')
        self.assertIn('や',masked)
        self.assertIn('"',literals)
        self.assertIn('""',literals)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        _,literals=locale.protect('Compare `a ** b` and "**" with **the result**.')
        self.assertIn('`a ** b`',literals)
        self.assertIn('"**"',literals)
        masked,literals=locale.protect('Compare 2**64 and 2 ** -52 with **the result**.')
        self.assertEqual(literals.count('**'),2)
        self.assertIn('64',literals)
        self.assertIn('-52',literals)
        self.assertIn('the result',masked)
        for source in ('(a+b)**2 and **result**','(a+b) **2 and **result**'):
            masked,literals=locale.protect(source)
            self.assertIn('**',literals)
            self.assertIn('2',literals)
            self.assertIn('result',masked)
            self.assertNotIn('**result',masked)
        masked,literals=locale.protect('値は**暫定値と確定値を併記**します。')
        self.assertEqual(masked,'値は暫定値と確定値を併記します。')
        self.assertNotIn('**',literals)

    def test_acceptance_field_does_not_retranslate_already_english_body(self):
        with mock.patch.object(locale,'translations',side_effect=AssertionError('already English')):
            self.assertEqual(locale.inline('合格基準: Reject invalid input.','en',self.source,self.target),
                             'Acceptance criterion: Reject invalid input.')
        self.assertFalse(locale.needed('Issue #ZXQPH0QXZ の照合記録','ja'))
        self.assertTrue(locale.needed('The write is deferred. 区別: It must not run immediately.','ja'))
        with mock.patch.object(locale,'translations',side_effect=AssertionError('already English')):
            result=locale.inline('Write `a <= b`. 区別: It must not run immediately.',
                                 'en',self.source,self.target)
            self.assertEqual(locale.inline('Known n・h states.','en',self.source,self.target),
                             'Known n・h states.')
        self.assertEqual(result,'Write `a <= b`. Distinguishing observation: It must not run immediately.')
        self.assertEqual(locale.inline('対象: ','en',self.source,self.target),'Scope:')
        self.assertEqual(locale.inline('対象: ','ja',self.source,self.source),'対象:')
        with mock.patch.object(locale,'translations',return_value={
                '条件を検査します。':'Check the condition.'}):
            result=locale.inline('The result is `a[0]`. 区別: 条件を検査します。',
                                 'en',self.source,self.target)
        self.assertEqual(result,'The result is `a[0]`. Distinguishing observation: Check the condition.')
        source='Read `q[0]` here. 区別: 前後の値を比較して誤りを検出します。'
        with mock.patch.object(locale,'translations',return_value={
                'Read ZXQPH0QXZ here.':'ここでZXQPH0QXZを読みます。'}):
            result=locale.inline(source,'ja',self.target,self.source)
        self.assertEqual(result,'ここで`q[0]`を読みます。 区別: 前後の値を比較して誤りを検出します。')
        # This real observation used to lose the legal cases when metadata
        # splitting reinserted padding around cast apostrophes and reparsed it.
        observation=("int配列aについて、withなしの a.and() と、加算が定義される real 式での "
            "a.sum with (real'(item)) は合法で、ビットANDが定義されない real 式を with に与えた "
            "a.and with (real'(item))(30行)だけが違反となり、30行でのエラーを期待する。")
        seen=[]
        class Capture(dict):
            def get(self,key,default=None):
                seen.append(key)
                return key  # In-memory lookup probe, not a production fallback.
        source=observation+' 区別: 要求の条件を比較する。'
        with mock.patch.object(locale,'translations',return_value=Capture()), \
             mock.patch.object(locale,'inline',wraps=locale.inline) as calls:
            locale.inline(source,'en',self.source,self.target)
        self.assertIn(observation,[call.args[0] for call in calls.call_args_list])
        self.assertTrue(any('は合法で、ビット' in key and 'だけが違反' in key for key in seen))
        # The boundary-like label in quoted UTF data is not metadata. In JA,
        # a split after an earlier sentence still passes the exact raw prefix.
        prefix="Read real'(item); output \"区別: 生の値\" then real'(other)"
        source=prefix+' 区別: 前後の値を比較し、要求の条件を刺激して誤りを検出する。'
        with mock.patch.object(locale,'translations',return_value=Capture()), \
             mock.patch.object(locale,'inline',wraps=locale.inline) as calls:
            locale.inline(source,'ja',self.target,self.source)
        self.assertIn(prefix,[call.args[0] for call in calls.call_args_list])
        self.assertNotIn("Read real ' (item)",[call.args[0] for call in calls.call_args_list])

    def test_language_type_names_stay_literal_and_compound_clauses_stay_separate(self):
        masked,literals=locale.protect('The logic type is four-state; randcase is a keyword.')
        self.assertIn('logic',literals)
        self.assertIn('randcase',literals)
        parts=list(locale.sentences(masked))
        self.assertEqual(len(parts),2)
        self.assertIn('four-state;',parts[0][0])

    def test_api_names_and_hierarchical_member_names_are_literals(self):
        _,literals=locale.protect('Query cbAssertionLock and svGetUserData, then u.pair.lo and std::randomize.')
        for item in ('cbAssertionLock','svGetUserData','u.pair.lo','std::randomize'):
            self.assertIn(item,literals)

    def test_identifier_protection_does_not_hide_adjacent_japanese_prose(self):
        source='$exitでは子を取り消し、u.valueを観測し、\\`defineで定義します。'
        masked,literals=locale.protect(source)
        for item in ('$exit','u.value',r'\`define'):self.assertIn(item,literals)
        for prose in ('では子を取り消し','を観測し','で定義します'):self.assertIn(prose,masked)
        self.assertFalse(any(locale.JP.search(value) for value in literals))

    def test_temporal_and_logical_operators_survive_prose_translation(self):
        masked,literals=locale.protect(r'r #=# p is not(r |=> not p); a \|-> b && c || d')
        for operator in ('#=#','|=>',r'\|->','&&','||'):self.assertIn(operator,literals)
        self.assertIn('is not',masked)
        source='left<right なので負、left>right なら正。i<=j<length の両端を含み、i>j は範囲外。'
        masked,literals=locale.protect(source)
        for prose in ('なので負、','なら正。','の両端を含み、','は範囲外。'):
            self.assertIn(prose,masked)
        for operator in ('<','>','<='):
            self.assertIn(operator,literals)
        self.assertFalse(any(locale.JP.search(value) for value in literals))
        source='<details open><span title="日本語">本文</span></details> と <file>。'
        masked,literals=locale.protect(source)
        restored=[]
        for index,value in enumerate(literals):
            for earlier in reversed(range(index)):
                value=value.replace(f'ZXQPH{earlier}QXZ',restored[earlier])
            restored.append(value)
        for tag in ('<details open>','<span title="日本語">','</span>','</details>','<file>'):
            self.assertIn(tag,restored)
        self.assertIn('本文',masked)
        source='# Comparisons\n\nFor i<=j<length it contains both endpoints. The cases i>j are outside.\n\n'
        source+='<span title="日本語">HTML body</span> and `a < b > c`.\n\n```sv\na <= b;\n```\n'
        # The already-English paragraph takes inline's needed=False path.
        with mock.patch.object(locale,'translations',side_effect=AssertionError('already English')):
            rendered=locale.render(source,'en',self.source,self.target,self.record)
        self.assertIn(r'i\<=j\<length it contains both endpoints. The cases i\>j are outside.',rendered)
        self.assertIn('<span title="日本語">HTML body</span>',rendered)
        self.assertIn('`a < b > c`',rendered)
        self.assertIn('```sv\na <= b;\n```',rendered)
        self.assertEqual(locale.markdown_angles('[i<j](sample.md?q=a<b)'),r'[i\<j](sample.md?q=a<b)')
        self.assertEqual(locale.markdown_angles('"a <b> 日本語"'),r'"a \<b\> 日本語"')
        self.assertEqual(locale.markdown_angles('Use <file>; output <nl> and <my-note open>text</my-note>.'),
                         r'Use \<file\>; output \<nl\> and <my-note open>text</my-note>.')

    def test_placeholder_reordering_retains_all_original_values(self):
        source='値32と値65を比較します。'
        key=next(locale.sentences(locale.protect(source)[0]))[0]
        cache={key:'Compare ZXQPH1QXZ with ZXQPH0QXZ.'}
        with mock.patch.object(locale,'translations',return_value=cache):
            self.assertEqual(locale.inline(source,'en',self.source,self.target),
                             'Compare 65 with 32.')

    def test_code_inside_link_labels_and_fragment_urls_survive(self):
        source='[参照 `q[0]`](sample.md#元の節)を確認します。'
        cache={'ZXQPH0QXZ を確認します。':'Check ZXQPH0QXZ.',
               '参照 ZXQPH0QXZ':'Reference ZXQPH0QXZ'}
        with mock.patch.object(locale,'translations',return_value=cache), \
             mock.patch.object(locale,'document_map',return_value=self.map):
            rendered=locale.inline(source,'en',self.source,self.target)
        self.assertEqual(rendered,'Check [Reference `q[0]`](sample.en.md#元の節).')

    def test_code_fences_are_not_translated_or_reformatted(self):
        source='# sample\n\n```sh\npython3 tool.py --input "$INPUT_FILE"\n# 原文コメント\n```\n'
        with mock.patch.object(locale,'document_map',return_value=self.map):
            result=locale.render(source,'en',self.source,self.target,self.record)
        self.assertIn('```sh\npython3 tool.py --input "$INPUT_FILE"\n# 原文コメント\n```',result)
        # A Markdown example inside inline code is data, even when its URL
        # points to a registered document that normally switches languages.
        for source in ('Example `[label](sample.md)`.', '例 `[label](sample.md)`。'):
            key=next(locale.sentences(locale.protect(source)[0]))[0]
            with mock.patch.object(locale,'document_map',return_value=self.map), \
                 mock.patch.object(locale,'translations',return_value={key:'Example ZXQPH0QXZ.'}):
                result=locale.inline(source,'en',self.source,self.target)
            self.assertIn('`[label](sample.md)`',result)

    def test_language_switch_keeps_its_explicit_destination(self):
        with mock.patch.object(locale,'document_map',return_value=self.map):
            en=locale.inline('[日本語](sample.md)','en',self.source,self.target)
            ja=locale.inline('[English](sample.en.md)','ja',self.source,self.source)
        self.assertEqual(en,'[日本語](sample.md)')
        self.assertEqual(ja,'[English](sample.en.md)')
        with mock.patch.object(locale,'document_map',return_value=self.map):
            ja=locale.rewrite_links('[英語](sample.en.md)','ja',self.source,self.source)
        self.assertEqual(ja,'[英語](sample.en.md)')

    def test_authored_link_rewrite_preserves_words_spacing_and_code_examples(self):
        source='Read  [元の節](sample.md#元の節).\n\n```md\n[example](sample.md)\n```\n'
        with mock.patch.object(locale,'document_map',return_value=self.map):
            result=locale.rewrite_links(source,'en',self.source,self.target)
        self.assertEqual(result,'Read  [元の節](sample.en.md#元の節).\n\n```md\n[example](sample.md)\n```\n')

    def test_original_heading_ids_remain_available_after_translation(self):
        source='# 元の見出し\n\n## 同じ節\n\n## 同じ節\n\n<details>\n<summary>技術補足</summary>\n</details>\n'
        cache={'元の見出し':'Translated title','同じ節':'Repeated section','技術補足':'Technical note'}
        with mock.patch.object(locale,'translations',return_value=cache):
            result=locale.render(source,'en',self.source,self.target,self.record)
        for anchor in ('元の見出し','同じ節','同じ節-1'):
            self.assertIn(f'<a id="{anchor}"></a>',result)
        self.assertIn('[日本語](sample.md)',result)
        self.assertIn('<summary>Technical note</summary>',result)

    def test_both_languages_accept_the_other_languages_heading_fragments(self):
        source={'en':'# Guide\n\n## Results\n\n```sh\n# comment\n```\n',
                'ja':'# ガイド\n\n## 結果\n\n```sh\n# comment\n```\n'}
        converted=locale.parallel_anchors(source)
        self.assertIn('<a id="results"></a>',converted['ja'])
        self.assertIn('<a id="結果"></a>',converted['en'])
        for language in source:
            self.assertIn('```sh\n# comment\n```',converted[language])
        with self.assertRaisesRegex(ValueError,'heading structures'):
            locale.parallel_anchors({'en':'# Guide\n## Results\n','ja':'# ガイド\n'})

    def test_external_exports_and_json_are_unchanged(self):
        external=Path('/tmp/standalone-evidence-fixture.md')
        self.assertEqual(locale.versions(external,'# fixture\n'),{external:'# fixture\n'})
        value={Path('/tmp/evidence.json'):'{"pass": 27}\n'}
        self.assertEqual(locale.expand(value),value)
        value={Path('/tmp/evidence.csv'):b'raw,unchanged\n'}
        self.assertEqual(locale.expand(value),value)

    def test_explicit_exports_use_local_siblings_and_language_local_repository_links(self):
        base='https://example.test/repo/blob/revision'
        guide={'ja':'docs/guide.md','en':'docs/guide.en.md'}
        summary={'ja':'docs/summary.md','en':'docs/summary.en.md'}
        records={**self.map,**{r[lang]:r for r in (guide,summary) for lang in ('en','ja')}}
        source=('# 元の見出し\n\n[参照](guide.md#元の節) / '
                f'[概要]({base}/docs/summary.md#raw) / '
                '[兄弟](../summary/short.md#raw) / '
                '[外部](https://outside.test/docs/guide.md#raw)\n\n'
                f'`[raw]({base}/docs/guide.md)`\n\n'
                '```text\npass=27, raw a<b and c>d\n[raw](guide.md)\n```\n')
        cache={'元の見出し':'Export','参照':'Guide','概要':'Summary',
               '兄弟':'Sibling','外部':'External','詳細':'Details'}
        with tempfile.TemporaryDirectory() as directory:
            full=Path(directory)/'reports/full.md'
            short=Path(directory)/'summary/short.md'
            siblings={self.source:full,locale.ROOT/'docs/summary.md':short}
            with mock.patch.object(locale,'document_map',return_value=records), \
                 mock.patch.object(locale,'translations',return_value=cache):
                outputs=locale.export_versions(full,source,self.source,source_url=base,siblings=siblings)
                summaries=locale.export_versions(short,'# 概要\n\n[詳細](../reports/full.md#raw)\n',
                              'docs/summary.md',source_url=base,siblings=siblings)
            en=outputs[full.with_suffix('.en.md')];ja=outputs[full]
            self.assertIn(f'[Guide]({base}/docs/guide.en.md#元の節)',en)
            self.assertIn(f'[参照]({base}/docs/guide.md#元の節)',ja)
            self.assertIn('[Summary](../summary/short.en.md#raw)',en)
            self.assertIn('[Sibling](../summary/short.en.md#raw)',en)
            self.assertIn('[概要](../summary/short.md#raw)',ja)
            self.assertIn('[Details](../reports/full.en.md#raw)',summaries[short.with_suffix('.en.md')])
            self.assertIn('[日本語](full.md)',en)
            self.assertIn('[English](full.en.md)',ja)
            for text in outputs.values():
                self.assertIn('https://outside.test/docs/guide.md#raw',text)
                self.assertIn(f'`[raw]({base}/docs/guide.md)`',text)
                self.assertIn('```text\npass=27, raw a<b and c>d\n[raw](guide.md)\n```',text)

    def test_explicit_export_requires_registered_canonical_source_and_complete_translation(self):
        with mock.patch.object(locale,'document_map',return_value=self.map):
            with self.assertRaisesRegex(ValueError,'registered canonical'):
                locale.export_versions('/tmp/out.md','# text\n','docs/unregistered.md')
            with mock.patch.object(locale,'translations',return_value={}):
                with self.assertRaises(locale.MissingTranslation):
                    locale.export_versions('/tmp/out.md','# 未翻訳の資料\n',self.source)

    def test_interaction_cli_keeps_plain_exports_default_and_bilingual_exports_explicit(self):
        import interaction_coverage as coverage
        data={'models':[],'runs':[]}
        source='# 元の見出し\n\n```text\npass=27\n```\n'
        for bilingual in (False,True):
            with self.subTest(bilingual=bilingual), tempfile.TemporaryDirectory() as directory:
                path=Path(directory)/'report.md';raw=Path(directory)/'report.json'
                argv=['interaction','--output',str(path),'--json',str(raw)]
                if bilingual:argv.append('--bilingual-export')
                with mock.patch.object(sys,'argv',argv), \
                     mock.patch.object(coverage.interaction_models,'registered',return_value=()), \
                     mock.patch.object(coverage,'build',return_value=data), \
                     mock.patch.object(coverage,'markdown',return_value=source), \
                     mock.patch.object(locale,'translations',return_value={'元の見出し':'Export'}):
                    self.assertEqual(coverage.main(),0)
                self.assertEqual(raw.read_text(),json.dumps(data,ensure_ascii=False,indent=2)+'\n')
                self.assertEqual(path.with_suffix('.en.md').is_file(),bilingual)
                if bilingual:
                    self.assertIn('# Export',path.with_suffix('.en.md').read_text())
                    for output in (path,path.with_suffix('.en.md')):
                        self.assertIn('```text\npass=27\n```',output.read_text())
                else:self.assertEqual(path.read_text(),source)

    def test_behavior_cli_exports_both_reports_with_unchanged_compact_json(self):
        import behavior_coverage as coverage
        import requirement_audit
        base='https://example.test/repo/blob/revision'
        source=f'# 元の見出し\n\n[概要]({base}/docs/behavior-coverage-summary.md)\n\n```text\npass=27\n```\n'
        summary='# 概要\n\n[詳細](full.md)\n\n```text\npass=27\n```\n'
        compact={'registered':27,'executed':17}
        with tempfile.TemporaryDirectory() as directory, contextlib.ExitStack() as stack:
            folder=Path(directory);full=folder/'full.md';short=folder/'short.md'
            stack.enter_context(mock.patch.object(sys,'argv',['behavior','--output',str(full),
                '--summary-output',str(short),'--summary-json',str(folder/'summary.json'),
                '--source-url',base,'--bilingual-export']))
            for name,value in {'validate':({},[]),'baseline':{'inventory_sha256':'fixture'},
                    'check_baseline':None,'execution':({'executed':[]},[]),'summarize':{},
                    'measurement':{},'report':source,'summary_data':compact,'compact_report':summary}.items():
                stack.enter_context(mock.patch.object(coverage,name,return_value=value))
            stack.enter_context(mock.patch.object(requirement_audit,'load_and_validate',return_value={
                'source_index_sha256':'fixture','source_review_complete':False}))
            stack.enter_context(mock.patch.object(locale,'translations',return_value={
                '元の見出し':'Export','概要':'Summary','詳細':'Details'}))
            stack.enter_context(contextlib.redirect_stdout(io.StringIO()))
            self.assertEqual(coverage.main(),0)
            self.assertIn('[Summary](short.en.md)',full.with_suffix('.en.md').read_text())
            self.assertIn('[Details](full.en.md)',short.with_suffix('.en.md').read_text())
            self.assertIn('[概要](short.md)',full.read_text())
            self.assertIn('[詳細](full.md)',short.read_text())
            for output in (full,short,full.with_suffix('.en.md'),short.with_suffix('.en.md')):
                self.assertIn('```text\npass=27\n```',output.read_text())
            self.assertEqual((folder/'summary.json').read_text(),
                             json.dumps(compact,ensure_ascii=False,indent=2)+'\n')

    def test_csv_translates_prose_without_changing_raw_expectations_or_status_data(self):
        path=locale.ROOT/'coverage/chapter-cross-details.csv'
        row=['']*25
        for column,value in {0:'4',1:'スケジューリングの意味論',3:'データ型',4:'主題章',
                             5:'model_id',6:'根拠の説明。',8:'27',15:'観測の説明。',
                             18:'原形の期待出力=27, a<b, c>d',21:'build-v123'}.items():row[column]=value
        stream=io.StringIO();csv.writer(stream,lineterminator='\n').writerows([['章A']+['']*24,row])
        original=stream.getvalue().encode('utf-8-sig')
        with mock.patch.object(locale,'translations',return_value={
                '根拠の説明。':'Mapping rationale.','観測の説明。':'Observation scope.'}):
            outputs=locale.expand({path:original})
        self.assertEqual(outputs[path],original)
        translated=list(csv.reader(io.StringIO(outputs[path.with_suffix('.en.csv')].decode('utf-8-sig'))))
        self.assertEqual(translated[0][0],'Chapter A')
        self.assertEqual(translated[1][1],'Scheduling semantics')
        self.assertEqual(translated[1][6],'Mapping rationale.')
        for column in (0,5,8,18,21):self.assertEqual(translated[1][column],row[column])
        self.assertEqual(locale.inline('Compare a<b and c>d.','en',self.source,self.target),
                         'Compare a<b and c>d.')

    def test_manifest_cannot_redirect_document_writes_outside_repository(self):
        malicious={**self.record,'en':'../outside.md'}
        locale.document_map.cache_clear()
        with mock.patch.object(locale,'documents',return_value=[malicious]):
            with self.assertRaisesRegex(ValueError,'repository-relative'):
                locale.document_map()

    def test_raw_status_and_version_metadata_are_not_machine_translated(self):
        for source,want in [
            ('ケース状態: pass=2170, unsupported=179, fail=6。',
             'Case statuses: pass=2170, unsupported=179, fail=6.'),
            ('環境: Verilator 5.052 rev vUNKNOWN-built20260905。',
             'Environment: Verilator 5.052 rev vUNKNOWN-built20260905.')]:
            with mock.patch.object(locale,'translations',side_effect=AssertionError('not prose')):
                self.assertEqual(locale.inline(source,'en',self.source,self.target),want)

    def test_manifest_detects_missing_language_links_and_unregistered_docs(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'docs').mkdir()
            (root/'docs/sample.md').write_text('# 日本語資料\n\nこの資料は日本語で操作手順を説明します。\n')
            record={'en':'docs/sample.en.md','ja':'docs/sample.md','generated':True}
            with mock.patch.object(audit,'inventory',return_value={'docs/sample.md','extra.md'}):
                problems=audit.validate({'documents':[record]},root)
            self.assertTrue(any('missing en document' in p for p in problems))
            self.assertTrue(any('missing language link' in p for p in problems))
            self.assertTrue(any('unregistered Markdown' in p for p in problems))
            # Teaching the generic notation must not be mistaken for an
            # unresolved numeric marker left by translation.
            (root/'docs/sample.md').write_text('# 日本語資料\n\n[English](sample.en.md)\n\n'
                'この資料は日本語で操作手順と `ZXQPH<n>QXZ` の記法を説明します。\n')
            english=root/'docs/sample.en.md'
            english.write_text('# English guide\n\n[日本語](sample.md)\n\nUse `ZXQPH<n>QXZ` notation.\n')
            with mock.patch.object(audit,'inventory',return_value={'docs/sample.md','docs/sample.en.md'}):
                self.assertEqual(audit.validate({'documents':[record]},root),[])
                english.write_text(english.read_text()+'\nUnresolved ZXQPH0QXZ\n')
                problems=audit.validate({'documents':[record]},root)
                self.assertTrue(any('unresolved translation placeholder' in p for p in problems))
                english.write_text('# English guide\n\n[日本語](sample.md)\n\nこの説明は未翻訳です。\n')
                problems=audit.validate({'documents':[record]},root)
                self.assertTrue(any('untranslated Japanese prose' in p for p in problems))


if __name__=='__main__':
    unittest.main()
