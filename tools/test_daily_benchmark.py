# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Bad/incomplete measurements must not become favorable speed results."""
import copy
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
import xml.etree.ElementTree as ET

import benchmark_compare as shared
import benchmark_history as history
import daily_benchmark as daily
from test_benchmark_compare import FakeAdapter as OriginalFakeAdapter


class FakeAdapter(OriginalFakeAdapter):
    def prepare(self,tool,executable,design,work):
        return None,lambda count:[executable,str(count)]


KINDS={'latest':'kirimasim','baseline':'kirimasim','icarus':'icarus','verilator':'verilator'}
CASE={'name':'example','path':Path('example.sv'),'source':'suite','sha256':'test','count':10,
      'expected':'example n=10 answer=7','expected_small':'example n=1 answer=7'}
CONFIG={'schema':1,'tools':{name:{'kind':kind} for name,kind in KINDS.items()},'cases':[{k:v for k,v in CASE.items() if k!='path'}],
        'measurement':{'runs':5,'short_seconds':0.05,'regression_warning_ratio':1.15},
        'groups':[{'name':'regression','peer':'baseline','cases':['example']},{'name':'oss','peer':'icarus','cases':['example']}]}


def case(adapter=None):
    return shared.collect_case(CASE,adapter or FakeAdapter(),{k:k for k in KINDS},5,0,
                               lambda value,work:value,tool_kinds=KINDS,strict=True)


def campaign(adapter=None):
    value={'schema':1,'id':'actions-123-1','started_at':'2026-11-17T00:00:00+00:00','completed_at':'2026-11-17T00:01:00+00:00',
        'mode':'formal','series':'test-series','environment':{'runs':5},'actions':{},'tools':{},'definition':{},
        'inputs_unchanged':True,'definition_config':copy.deepcopy(CONFIG),'cases':[case(adapter)]}
    return daily.summarize(value,CONFIG)


class DailyBenchmarkTests(unittest.TestCase):
    def test_serial_four_tool_schedule_and_raw_samples(self):
        adapter=FakeAdapter();row=case(adapter)
        self.assertEqual(len(adapter.calls),44)
        self.assertEqual(adapter.calls[:4],[(name,1) for name in KINDS])
        self.assertEqual(adapter.calls[4:8],[('latest',1),('latest',10),('baseline',1),('baseline',10)])
        self.assertEqual(adapter.calls[12:16],[('verilator',10),('verilator',1),('icarus',10),('icarus',1)])
        self.assertEqual(history.normalized(campaign())['groups'][0]['ratio'],1)
        self.assertEqual(len(row['tools']['latest']['samples']['large']),5)

    def test_one_bad_repetition_invalidates_entire_record(self):
        value=campaign();record=value['cases'][0]['tools']['latest']
        record['samples']['large'][2]['result_line']='example n=10 answer=8'
        result=history.normalized(value)
        self.assertIsNone(result['groups'][0]['ratio'])
        self.assertEqual(result['cases'][0]['tools']['latest']['status'],'output_mismatch')
        self.assertEqual(len(record['samples']['large']),5)
        self.assertNotIn('incremental_seconds',result['cases'][0]['tools']['latest'])

    def test_nonzero_exit_timeout_and_bad_count(self):
        for change,expected in [({'exit_code':3},'run_failed'),({'timed_out':True},'timeout'),
                                ({'result_line':'example n=100 answer=7'},'output_mismatch')]:
            with self.subTest(change=change):
                value=campaign();value['cases'][0]['tools']['latest']['samples']['large'][1].update(change)
                got=history.normalized(value)
                self.assertIsNone(got['groups'][0]['ratio'])
                self.assertEqual(got['cases'][0]['tools']['latest']['status'],expected)

    def test_missing_repetition_and_warmup_never_count_as_success(self):
        for kind in ('small','large','warmup'):
            value=campaign();r=value['cases'][0]['tools']['latest']
            if kind=='warmup':r['warmup']=None
            else:r['samples'][kind].pop()
            self.assertIsNone(history.normalized(value)['groups'][0]['ratio'])

    def test_nonpositive_delta_is_missing(self):
        for seconds in (0.5,1):
            value=campaign()
            for sample in value['cases'][0]['tools']['latest']['samples']['large']:sample['seconds']=seconds
            got=history.normalized(value)
            self.assertEqual(got['cases'][0]['tools']['latest']['status'],'incomparable')
            self.assertIsNone(got['groups'][0]['ratio'])

    def test_nonfinite_sample_duplicate_output_and_no_small_expectation(self):
        for change in ({'seconds':float('nan')},{'seconds':float('inf')},{'result_line_count':2}):
            value=campaign();value['cases'][0]['tools']['latest']['samples']['large'][0].update(change)
            self.assertIsNone(history.normalized(value)['groups'][0]['ratio'])
        c={**CASE,'expected_small':None}
        row=shared.collect_case(c,FakeAdapter(),{k:k for k in KINDS},5,0,lambda v,w:v,tool_kinds=KINDS,strict=True)
        self.assertIn('missing fixed',row['tools']['latest']['error']['reason'])

    def test_known_fourstate_exclusion_runs_no_verilator(self):
        adapter=FakeAdapter()
        row=shared.collect_case(CASE,adapter,{k:k for k in KINDS},5,0,lambda v,w:v,tool_kinds=KINDS,
                                unsupported={'verilator':'requires X/Z'},strict=True)
        self.assertFalse(any(tool=='verilator' for tool,_ in adapter.calls))
        self.assertEqual(daily.status(row['tools']['verilator']),'unsupported')
        value=campaign();value['cases'][0]['tools']['verilator']['error']={'stage':'unsupported','reason':'guess'}
        with self.assertRaises(ValueError):history.normalized(value)

    def test_build_failure_is_not_unsupported(self):
        class BuildFails(FakeAdapter):
            def prepare(self,tool,executable,design,work):
                return {'error':'compile error','seconds':1,'steps':[]},None
        for r in case(BuildFails())['tools'].values():
            self.assertEqual(daily.status(r),'build_failed')

    def test_missing_fixed_group_member_no_successful_subset_mean(self):
        value=campaign();value['definition_config']['groups'][0]['cases'].append('absent')
        got=history.normalized(value)
        self.assertIsNone(got['groups'][0]['ratio'])
        self.assertEqual(got['groups'][0]['available_count'],1)
        self.assertEqual(got['groups'][0]['expected_count'],2)

    def test_incomplete_campaign_and_changed_inputs_no_ratio(self):
        for change in ({'completed_at':None},{'inputs_unchanged':False},{'infrastructure_error':'failure'}):
            value=campaign();value.update(change)
            self.assertIsNone(history.normalized(value)['groups'][0]['ratio'])

    def test_history_recomputes_medians_not_reported_values(self):
        value=campaign();value['cases'][0]['tools']['latest']['incremental_seconds']=0.000001
        self.assertEqual(history.normalized(value)['groups'][0]['ratio'],1)

    def test_same_day_rerun_append_idempotent_and_collision(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory=Path(tmp);value=campaign();history.append(directory,value);history.append(directory,value)
            other=campaign();other['id']='actions-123-2';history.append(directory,other)
            self.assertEqual(len(list((directory/'runs').glob('*.json'))),2)
            other['cases'][0]['tools']['latest']['samples']['large'][0]['seconds']=3
            with self.assertRaises(ValueError):history.append(directory,other)

    def test_smoke_private_paths_and_credentials_rejected(self):
        for change in ({'mode':'smoke'},{'infrastructure_error':'/Users/private/person/file'},
                       {'infrastructure_error':'github_pat_canary'}):
            with tempfile.TemporaryDirectory() as tmp:
                value=campaign();value.update(change)
                with self.assertRaises(ValueError):history.append(Path(tmp),value)

    def test_conditions_and_definitions_are_separate_series(self):
        self.assertNotEqual(daily.identity({'os':'linux'}),daily.identity({'os':'macOS'}))
        with tempfile.TemporaryDirectory() as tmp:
            directory=Path(tmp);history.append(directory,campaign())
            other=campaign();other['series']='different-definition';other['id']='other';history.append(directory,other)
            self.assertEqual(len(list((directory/'charts').iterdir())),2)

    def test_svg_breaks_at_missing_data_and_reports_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory=Path(tmp)
            for i in range(3):
                value=campaign();value['id']=f'run-{i}';value['started_at']=f'2026-11-17T00:0{i}:00+00:00'
                if i==1:value['cases'][0]['tools']['latest']['samples']['large'][0]['exit_code']=2
                history.append(directory,value)
            svg=(directory/'charts/test-series/regression.svg').read_text()
            ET.fromstring(svg)
            self.assertNotIn('<polyline',svg)
            self.assertIn('Fixed comparison sets',(directory/'README.md').read_text())
            self.assertIn('固定した総合値',(directory/'README.ja.md').read_text())

    def test_warning_is_descriptive_not_a_failure(self):
        value=campaign()
        for s in value['cases'][0]['tools']['latest']['samples']['large']:s['seconds']=14
        got=history.normalized(value)
        self.assertTrue(got['groups'][0]['warning'])
        self.assertEqual(got['status'],'complete')

    def test_shared_local_lock_excludes_second_campaign(self):
        with tempfile.TemporaryDirectory() as tmp:
            with daily.machine_lock(Path(tmp)/'lock'):
                with self.assertRaises(ValueError):
                    with daily.machine_lock(Path(tmp)/'lock'):pass

    def test_real_subprocess_timeout_and_log_retention(self):
        with tempfile.TemporaryDirectory() as tmp:
            module=SimpleNamespace(build_steps=lambda *args:None,watch_peak=lambda *args:None)
            adapter=daily.Adapter(module,0.05,Path(tmp)/'logs',lambda v,w:v)
            r=adapter.run([sys.executable,'-c','import time;time.sleep(10)'],Path(tmp))
            self.assertTrue(r['timed_out']);self.assertNotEqual(r['exit_code'],0)
            self.assertLess(r['seconds'],3)
            self.assertEqual(len(list((Path(tmp)/'logs').glob('*.json'))),1)

    def test_actual_definition_has_fixed_pins_and_comparison_sets(self):
        config=daily.config_at(daily.DEFAULT_CONFIG)
        self.assertEqual(len(config['cases']),5)
        self.assertEqual(len(config['groups']),5)
        self.assertEqual(config['benchmark_source']['commit'],config['tools']['baseline']['commit'])
        for name in ('baseline','icarus','verilator'):
            self.assertRegex(config['tools'][name]['commit'],r'^[0-9a-f]{40}$')

    def test_workflow_is_separate_single_measurement_job_and_limited_writer(self):
        text=(daily.ROOT/'.github/workflows/benchmark.yml').read_text()
        self.assertIn("cron: '17 20 * * *'",text)
        self.assertIn('group: daily-benchmark',text)
        self.assertEqual(text.count('contents: write'),1)
        self.assertNotIn('pull_request:',text)
        self.assertNotIn('strategy:',text)
        self.assertIn('HEAD:benchmark-results',text)
        self.assertNotIn('--force',text)
        self.assertIn('always()',text)


if __name__=='__main__':unittest.main()
