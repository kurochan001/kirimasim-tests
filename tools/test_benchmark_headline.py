# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""A daily overall graph must not relabel, cherry-pick or join unlike data."""
import json
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET

import benchmark_history as history
import daily_benchmark as daily


def campaign(identifier='actions-1-1',time='2026-11-18T00:00:00+00:00',series='fixed-series'):
    config=daily.config_at(daily.DEFAULT_CONFIG)
    value={'schema':1,'id':identifier,'started_at':time,'completed_at':time,'mode':'formal','series':series,
           'environment':{'runs':5,'profile':'daily','machine':{'cpu':'Example CPU'}},'actions':{},
           'tools':{n:{'commit':'a'*40,'version':'test'} for n in config['tools']},'definition':{},
           'inputs_unchanged':True,'definition_config':config,'cases':[]}
    for definition in config['cases']:
        row={**definition,'tools':{}}
        for tool in config['tools']:
            def sample(n,repetition=0):
                return {'seconds':1 if n==1 else 11,'exit_code':0,'timed_out':False,'max_rss_mib':16,
                        'repetition':repetition,'correctness_checked':True,'result_line_count':1,
                        'result_line':definition['expected_small' if n==1 else 'expected']}
            row['tools'][tool]={'warmup':sample(1),'build':None,
                'samples':{'small':[sample(1,i) for i in range(5)],'large':[sample(definition['count'],i) for i in range(5)]}}
        value['cases'].append(row)
    return history.normalized(value)


class HeadlineTests(unittest.TestCase):
    def test_direct_25_case_geometric_mean_has_equal_case_weights(self):
        value=campaign()
        for case in value['cases']:
            if case['class']=='common':
                for sample in case['tools']['latest']['samples']['large']:sample['seconds']=41
        value=history.normalized(value)
        point=history.headline([value])['points'][0]
        self.assertAlmostEqual(point['ratio'],4**(22/25))
        self.assertEqual(point['available_count'],25)
        self.assertEqual(len(point['cases']),25)

    def test_one_invalid_member_never_produces_a_subset_mean(self):
        changes=[{'exit_code':1},{'timed_out':True},{'result_line':'wrong'}, {'seconds':1}]
        for change in changes:
            value=campaign()
            for sample in value['cases'][-1]['tools']['icarus_devel']['samples']['large']:sample.update(change)
            point=history.headline([history.normalized(value)])['points'][0]
            self.assertIsNone(point['ratio'])
            self.assertEqual(point['available_count'],24)

    def test_single_bad_repetition_invalidates_the_whole_day(self):
        value=campaign();value['cases'][0]['tools']['icarus_devel']['samples']['large'][2]['exit_code']=1
        self.assertIsNone(history.headline([history.normalized(value)])['points'][0]['ratio'])

    def test_icarus13_runs_are_not_reused_as_icarus14(self):
        value=campaign();value['groups']=[g for g in value['groups'] if g['name']!=history.HEADLINE]
        with tempfile.TemporaryDirectory() as tmp:
            data=history.render_headline(Path(tmp),[value])
            self.assertEqual(data['points'],[])
            svg=(Path(tmp)/'charts/daily-icarus14.svg').read_text()
            self.assertIn('Awaiting a formal',svg);ET.fromstring(svg)

    def test_last_jst_attempt_is_selected_even_when_it_fails(self):
        early=campaign(time='2026-11-17T16:00:00+00:00')
        late=campaign('actions-2-1','2026-11-18T14:00:00+00:00')
        late['inputs_unchanged']=False;late=history.normalized(late)
        data=history.headline([late,early]);self.assertEqual(len(data['points']),1)
        self.assertEqual(data['points'][0]['date'],'2026-11-18')
        self.assertEqual(data['points'][0]['id'],'actions-2-1')
        self.assertIsNone(data['points'][0]['ratio'])

    def test_no_attempt_days_are_gaps_and_environments_are_separate(self):
        a=campaign();b=campaign('actions-2-1','2026-11-20T00:00:00+00:00','other-series')
        with tempfile.TemporaryDirectory() as tmp:
            directory=Path(tmp);data=history.render_headline(directory,[a,b])
            self.assertIsNone(data['points'][1]['ratio'])
            self.assertEqual(data['points'][1]['date'],'2026-11-19')
            svg=(directory/'charts/daily-icarus14.svg').read_text();root=ET.fromstring(svg)
            lines=root.findall('.//{http://www.w3.org/2000/svg}polyline')
            self.assertTrue(lines)
            self.assertTrue(all('c-reference' in p.attrib['class'] for p in lines))
            self.assertIn('fixed-se',svg);self.assertIn('other-se',svg)
            self.assertEqual(json.loads((directory/'headline.json').read_text()),data)

    def test_incomplete_setup_is_a_missing_attempt(self):
        value=campaign();value['cases']=[];value['tools']={};value['completed_at']=None;value['inputs_unchanged']=False
        point=history.headline([history.normalized(value)])['points'][0]
        self.assertIsNone(point['ratio']);self.assertEqual(point['available_count'],0)

    def test_member_definition_must_be_the_entire_fixed_25(self):
        value=campaign();group=next(g for g in value['groups'] if g['name']==history.HEADLINE)
        group['cases'].pop()
        with self.assertRaises(ValueError):history.headline([value])

    def test_repeated_day_keeps_raw_attempts_and_one_headline_point(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory=Path(tmp)
            history.append(directory,campaign());history.append(directory,campaign('actions-1-2','2026-11-18T01:00:00+00:00'))
            self.assertEqual(len(list((directory/'runs').glob('*.json'))),2)
            data=json.loads((directory/'headline.json').read_text());self.assertEqual(len(data['points']),1)
            self.assertEqual(data['points'][0]['id'],'actions-1-2')
            readme=(directory/'README.ja.md').read_text()
            self.assertLess(readme.index('daily-icarus14.svg'),readme.index('<details>'))
            self.assertIn('0.97',readme)


if __name__=='__main__':unittest.main()
