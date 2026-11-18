# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Cache receipts bind installed artifacts to commits, compilers and settings."""
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import benchmark_setup as setup
from daily_benchmark import config_at, DEFAULT_CONFIG


class BenchmarkSetupTests(unittest.TestCase):
    def test_resolve_fetches_latest_only_once(self):
        sha='a'*40
        with patch.object(setup,'command',side_effect=[sha+'\trefs/heads/main','b'*40+'\trefs/heads/master']) as call:
            self.assertEqual(setup.resolve(config_at(DEFAULT_CONFIG))['latest_commit'],sha)
            self.assertEqual(call.call_count,2)
            self.assertEqual([c.args[0][-1] for c in call.call_args_list],['refs/heads/main','refs/heads/master'])
        with patch.object(setup,'command',return_value='not-a-sha'):
            with self.assertRaises(ValueError):setup.resolve(config_at(DEFAULT_CONFIG))

    def test_checkout_rejects_an_unpeeled_tag_identity(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(setup,'command',side_effect=['','','','b'*40]):
            with self.assertRaises(ValueError):
                setup.checkout('https://example.invalid/repo.git','a'*40,Path(tmp)/'source',None)

    def test_complete_build_log_scrubs_commands_and_output(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);prefix=base/'private-install';log=base/'build.log'
            result=SimpleNamespace(returncode=0,stdout='install '+str(prefix)+' and '+str(Path.home()))
            with patch.object(setup.subprocess,'run',return_value=result):
                setup.command(['./configure','--prefix='+str(prefix)],log=log,private_roots=(prefix,))
            text=log.read_text()
            self.assertNotIn(str(prefix),text);self.assertNotIn(str(Path.home()),text)
            self.assertIn('--prefix=${PRIVATE_ROOT}',text)

    def prepare_twice(self,mutate=None):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            args=SimpleNamespace(root=base/'build',install=base/'install',out=base/'inventory.json',plan=base/'plan.json',jobs=2)
            args.plan.write_text(json.dumps({'latest_commit':'a'*40,'resolved_tools':{'icarus_devel':'c'*40},'resolved_at':'2026-11-17T00:00:00+00:00','config_sha256':setup.digest(DEFAULT_CONFIG)}))
            calls=[]
            def checkout(repository,commit,path,log):
                path.mkdir(parents=True,exist_ok=True)
            def command(command,cwd=None,log=None,**kwargs):
                calls.append(command)
                if '--version' in command:return 'test compiler 1.0'
                if command[:2]==['cmake','--build']:
                    p=Path(cwd)/'build/release/src/driver/kirimasim';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('compiled kirimasim')
                if command[0]=='./configure':
                    prefix=Path(command[1].split('=',1)[1]);(prefix/'bin').mkdir(parents=True,exist_ok=True)
                    names=['iverilog','vvp'] if 'icarus' in str(cwd) else ['verilator','verilator_bin']
                    for name in names:(prefix/'bin'/name).write_text('compiled '+name)
                return ''
            with patch.object(setup,'checkout',side_effect=checkout),patch.object(setup,'command',side_effect=command):
                config=config_at(DEFAULT_CONFIG);setup.prepare(args,config)
                self.assertEqual(sum(c[:2]==['cmake','--build'] for c in calls),2)
                first=json.loads(args.out.read_text());self.assertTrue(all(not t['cache_hit'] for t in first['tools'].values()))
                if mutate:mutate(args)
                calls.clear();setup.prepare(args,config)
                return json.loads(args.out.read_text()),calls

    def test_intact_installations_skip_all_builds(self):
        result,calls=self.prepare_twice()
        self.assertTrue(all(t['cache_hit'] for t in result['tools'].values()))
        self.assertFalse(any(c[0] in ('cmake','make','./configure') for c in calls))

    def test_corrupted_companion_rebuilds_just_that_tool(self):
        def mutate(args):(args.install/'verilator/bin/verilator_bin').write_text('corrupt')
        result,calls=self.prepare_twice(mutate)
        self.assertFalse(result['tools']['verilator']['cache_hit'])
        self.assertTrue(all(result['tools'][n]['cache_hit'] for n in ('latest','baseline','icarus')))
        self.assertTrue(any(c[0]=='make' for c in calls))

    def test_new_latest_commit_preserves_fixed_builds(self):
        def mutate(args):
            plan=json.loads(args.plan.read_text());plan['latest_commit']='b'*40;args.plan.write_text(json.dumps(plan))
        result,calls=self.prepare_twice(mutate)
        self.assertFalse(result['tools']['latest']['cache_hit'])
        self.assertEqual(result['tools']['latest']['commit'],'b'*40)
        self.assertTrue(all(result['tools'][n]['cache_hit'] for n in ('baseline','icarus','icarus_devel','verilator')))
        self.assertEqual(sum(c[:2]==['cmake','--build'] for c in calls),1)



    def test_new_icarus_head_preserves_other_builds(self):
        def mutate(args):
            plan=json.loads(args.plan.read_text());plan['resolved_tools']['icarus_devel']='d'*40;args.plan.write_text(json.dumps(plan))
        result,calls=self.prepare_twice(mutate)
        self.assertFalse(result['tools']['icarus_devel']['cache_hit'])
        self.assertEqual(result['tools']['icarus_devel']['commit'],'d'*40)
        self.assertTrue(all(result['tools'][n]['cache_hit'] for n in ('latest','baseline','icarus','verilator')))

    def test_tracking_companion_is_verified(self):
        def mutate(args):(args.install/'icarus_devel/bin/vvp').write_text('corrupt')
        result,_=self.prepare_twice(mutate)
        self.assertFalse(result['tools']['icarus_devel']['cache_hit'])
        self.assertTrue(result['tools']['icarus']['cache_hit'])

    def test_invalid_resolved_tracking_identity_is_rejected(self):
        config=config_at(DEFAULT_CONFIG)
        for moving in ({},{'icarus_devel':'master'},{'icarus_devel':'b'*40,'extra':'c'*40}):
            with self.subTest(moving=moving), self.assertRaises(ValueError):
                setup.commits(config,{'latest_commit':'a'*40,'resolved_tools':moving})

    def test_cache_revision_covers_both_moving_commits(self):
        config=config_at(DEFAULT_CONFIG)
        values=[]
        for latest,peer in [('a','b'),('a','c'),('d','b')]:
            with patch.object(setup,'command',side_effect=[latest*40+' refs/heads/main',peer*40+' refs/heads/master']):
                plan=setup.resolve(config);values.append(plan['cache_revision'])
                self.assertEqual(plan['resolved_tools'],{'icarus_devel':peer*40})
        self.assertEqual(len(set(values)),3)

if __name__=='__main__':unittest.main()
