"""Admission is not a cached verdict; replay and every required tool stay distinct."""

import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import promote_random_cross as promotion
import random_cross_compare as compare
import random_cross_evidence as evidence
import random_cross_history as history
import random_cross_identity as identity
import random_cross_models as models
import run_random_cross as runner
import suite_results
import lint_metadata
from test_random_cross import sequence_case


class Fixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.manifest = models.generate(731, 3, 2)
        self.binary = self.root/'binary'; self.binary.write_bytes(b'build one')
        self.build = {'executable': str(self.binary), 'binary_sha256': evidence.sha(self.binary),
                      'commit': 'a'*40, 'version': 'fixture'}
        self.inventory = {'files': {str(self.binary): evidence.sha(self.binary)}, 'complete': True}
        self.db = self.root/'history.sqlite3'

    def run_job(self, name, status='pass', **kwargs):
        def execute(*args):
            return {'status': status, 'reason': '', 'returncode': 0 if status == 'pass' else None}
        with patch.object(runner, 'verify_binary', return_value=self.build), \
                patch.object(identity, 'dependencies', return_value=self.inventory), \
                patch.object(runner, 'execute', side_effect=execute) as invoke:
            report = runner.run(self.manifest, self.root/name, self.binary, self.build['commit'],
                                explore=True, history=self.db, **kwargs)
        return report, invoke.call_count


class AdmissionTests(Fixture):
    def test_version_and_binary_digest_cannot_describe_different_builds(self):
        self.binary.chmod(0o755)
        def change(*args, **kwargs):
            self.binary.write_text('changed during --version')
            return subprocess.CompletedProcess([], 0, 'kirimasim 0.0.0 (commit '+('a'*12)+')', '')
        with patch.object(runner.subprocess, 'run', side_effect=change), self.assertRaisesRegex(ValueError, 'changed'):
            runner.verify_binary(self.binary, 'a'*40)

    def test_external_dispatch_backend_is_hashed_and_checked_for_updates(self):
        driver, backend = self.root/'verilator', self.root/'verilator_bin'
        driver.write_text('public dispatcher'); driver.chmod(0o755); backend.write_text('actual backend')
        with patch.object(identity, 'command_version', return_value='Verilator fixture'):
            build = identity.external_build('verilator', driver)
        self.assertEqual(build['companions'][str(backend.resolve())], evidence.sha(backend))
        inventory = {'files': build['companions']}
        backend.write_text('updated backend')
        self.assertFalse(identity.unchanged(inventory))

    def test_admission_detects_a_binary_update_racing_duplicate_decision(self):
        self.run_job('first')
        admit = history.History.admit
        def update(store, *args):
            result = admit(store, *args)
            self.binary.write_text('updated after identity snapshot')
            return result
        with patch.object(history.History, 'admit', update):
            report, count = self.run_job('racing')
        self.assertFalse(report['valid']); self.assertEqual(count, 0)
        self.assertEqual(report['admission']['decision'], 'stale_admission')
        self.assertEqual(report['counts']['pass'], 0)

    def test_history_cannot_modify_its_own_immutable_receipt(self):
        output = self.root/'output'
        with self.assertRaisesRegex(ValueError, 'outside'):
            runner.run(self.manifest, output, explore=True, history=output/'history.sqlite3')
        self.assertFalse(output.exists())

    def test_original_manifest_and_materializations_keep_their_random_streams(self):
        hashes = {1: ('b5c0886a823cadd2dc53bb94019708174c87f7b3865b13abc73e70fb656d4aa8',
                      '003b275e9234fee49fdf25c6f2c765030cb1aee266a6ad76a25c87d4ad5784cd'),
                  731: ('f7ae62068a8677a6531f1bf421b9d281cf44f7b1050a5eec95f751926bb56b87',
                        '9d2a9b56e911f5d7a3cc20b117a5b9d6dde6522bce4273b85d3878455a6136f8'),
                  20261103: ('d896e2b76dc28b090692e8543418fedd93f9ccd895681d2e5ae0f9043765f3a1',
                             '63fe530b9a46a6db782b326cfe6c5a73e87372c9e69d98a70468f077fba1c87c')}
        for seed, (manifest_hash, source_hash) in hashes.items():
            manifest = models.generate(seed, 96, 8, models.LEGACY_PROFILES)
            self.assertEqual(evidence.digest(manifest), manifest_hash)
            self.assertEqual(hashlib.sha256(''.join(source+expected for source, expected in
                                                   map(models.materialize, manifest['cases'])).encode()).hexdigest(), source_hash)

    def test_interruption_keeps_inputs_and_never_records_a_completed_pass(self):
        output = self.root/'interrupted'
        with patch.object(runner, 'verify_binary', return_value=self.build), \
                patch.object(identity, 'dependencies', return_value=self.inventory), \
                patch.object(runner, 'execute', side_effect=KeyboardInterrupt), self.assertRaises(KeyboardInterrupt):
            runner.run(self.manifest, output, 'fixture', 'a'*40, explore=True, history=self.db)
        report = json.loads((output/'run.json').read_text())
        self.assertTrue(report['interrupted']); self.assertFalse(evidence.all_pass(report))
        self.assertEqual(report['counts']['pass'], 0)
        self.assertEqual(report['counts']['not_run'], 3)
        self.assertTrue((output/'manifest.json').is_file())
        self.assertTrue((output/'cases/case_0000.expected').is_file())
        with history.History(self.db).connect() as db:
            self.assertEqual(db.execute('SELECT state FROM attempts').fetchone()[0], 'interrupted')

    def test_environment_snapshot_is_stable_in_a_fresh_interpreter(self):
        env = {**os.environ, 'PYTHONPATH': str(models.ROOT/'tools')}
        command = [sys.executable, '-c', 'import random_cross_identity as i; assert i.environment() == i.environment()']
        result = subprocess.run(command, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_only_exact_completed_exploration_is_skipped_with_zero_current_passes(self):
        first, count = self.run_job('first')
        self.assertTrue(evidence.all_pass(first)); self.assertEqual(count, 3)
        second, count = self.run_job('second')
        self.assertEqual(second['admission']['decision'], 'duplicate_completed')
        self.assertEqual(second['mode'], 'admission-only')
        self.assertFalse(second['completed']); self.assertEqual(second['counts']['pass'], 0)
        self.assertEqual(count, 0); self.assertEqual(second['results'], {})

    def test_all_nonpass_states_and_new_failed_attempt_block_reuse(self):
        for state in ('fail', 'known', 'unsupported', 'not_run', 'stale'):
            with self.subTest(state=state):
                self.db = self.root/(state+'.sqlite3')
                self.run_job(state+'-pass')
                failed, count = self.run_job(state+'-forced', status=state, force=True)
                self.assertEqual(count, 3); self.assertFalse(evidence.all_pass(failed))
                retried, count = self.run_job(state+'-retry')
                self.assertEqual(count, 3); self.assertEqual(retried['admission']['decision'], 'execute')

    def test_force_does_not_change_execution_identity(self):
        first, _ = self.run_job('first')
        forced, count = self.run_job('forced', force=True)
        self.assertEqual(first['execution_identity']['sha256'], forced['execution_identity']['sha256'])
        self.assertEqual(forced['admission']['decision'], 'forced'); self.assertEqual(count, 3)

    def test_tampered_or_missing_evidence_is_never_reused(self):
        self.run_job('first')
        (self.root/'first/cases/case_0000.expected').write_text('tampered')
        _, count = self.run_job('second'); self.assertEqual(count, 3)
        (self.root/'second/run.json').unlink()
        _, count = self.run_job('third'); self.assertEqual(count, 3)

    def test_nightly_and_explicit_replay_always_execute(self):
        self.run_job('first')
        for kind, kwargs in [('nightly', {'run_kind': 'nightly'}),
                             ('replay', {'replay': self.root/'first/manifest.json'})]:
            with self.subTest(kind=kind):
                report, count = self.run_job(kind, **kwargs)
                self.assertEqual(count, 3); self.assertEqual(report['admission']['decision'], 'always_execute')

    def test_incomplete_dependencies_disable_deduplication(self):
        self.inventory['complete'] = False
        self.run_job('first')
        report, count = self.run_job('second')
        self.assertEqual(count, 3)
        self.assertEqual(report['admission']['decision'], 'execute_unverified_dependencies')

    def test_parallel_admission_and_interrupted_owner_recovery(self):
        code = ('import sys; from pathlib import Path; import random_cross_history as h; '
                'a=h.History(sys.argv[1]).admit("job",Path(sys.argv[2])); '
                'print(a["decision"],flush=True); sys.stdin.read()')
        env = {**os.environ, 'PYTHONPATH': str(models.ROOT/'tools')}
        owner = subprocess.Popen([sys.executable, '-c', code, str(self.db), str(self.root/'owner')],
                                 env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        try:
            self.assertEqual(owner.stdout.readline().strip(), 'execute')
            store = history.History(self.db)
            admission = store.admit('job', self.root/'parallel')
            self.assertEqual(admission['decision'], 'in_flight')
            forced = store.admit('job', self.root/'forced', force=True)
            self.assertEqual(forced['decision'], 'forced'); store.abort(forced)
            owner.kill(); owner.wait(timeout=5)
            reclaimed = store.admit('job', self.root/'reclaimed')
            self.assertEqual(reclaimed['decision'], 'execute')
            with store.connect() as db:
                self.assertEqual(db.execute("SELECT count(*) FROM attempts WHERE state='interrupted'").fetchone()[0], 2)
            store.abort(reclaimed)
        finally:
            if owner.poll() is None: owner.kill(); owner.wait(timeout=5)
            owner.stdin.close(); owner.stdout.close()

    def test_abort_never_falls_back_to_previous_success(self):
        first, _ = self.run_job('first')
        store = history.History(self.db)
        forced = store.admit(first['execution_identity']['sha256'], self.root/'aborted', force=True)
        store.abort(forced)
        _, count = self.run_job('retry'); self.assertEqual(count, 3)

    def test_partial_other_simulator_success_cannot_be_kirimasim_success(self):
        first, _ = self.run_job('first')
        first['required_simulators'] = ['kirimasim', 'icarus']
        first['comparisons']['icarus'] = copy.deepcopy(first['results'])
        self.assertTrue(evidence.all_pass(first))
        for sim in ('icarus', 'kirimasim'):
            for state in ('known', 'unsupported', 'not_run', 'stale', 'fail'):
                report = copy.deepcopy(first); report['comparisons'][sim]['case_0000']['status'] = state
                self.assertFalse(evidence.all_pass(report))
        del first['comparisons']['icarus']['case_0000']; self.assertFalse(evidence.all_pass(first))

    def test_comparator_results_have_separate_status_and_evidence(self):
        with patch.object(identity, 'external_build', return_value=self.build), \
                patch.object(compare, 'execute', return_value={'status': 'known', 'reason': 'difference', 'returncode': 0}):
            report, _ = self.run_job('multi', comparators={'icarus': 'fixture'})
        self.assertEqual(report['counts']['pass'], 3)
        self.assertEqual(report['comparisons']['icarus']['case_0000']['status'], 'known')
        self.assertFalse(evidence.all_pass(report))
        self.assertFalse(report['execution_identity']['reusable_identity'])
        self.assertEqual(report['admission']['decision'], 'execute_unverified_dependencies')

    def test_identity_mutations_include_all_execution_dimensions(self):
        records = runner.prepare(self.manifest, self.root/'inputs')
        parts = [self.manifest, records, {'reference': 'one'}, {'kirimasim': self.build}, self.inventory,
                 {'seed': 731, 'simulator_seed': 1, 'timeout': 5, 'jobs': 4}]
        with patch.object(identity, 'environment', return_value={'environment': 'one'}):
            first = identity.execution(*parts)['sha256']
            for label, mutate in [
                ('seed', lambda p: p[0].update(seed=732)),
                ('input', lambda p: p[1]['case_0000'].update(source_sha256='changed')),
                ('expected', lambda p: p[1]['case_0000'].update(expected_sha256='changed')),
                ('reference', lambda p: p[2].update(reference='two')),
                ('binary', lambda p: p[3]['kirimasim'].update(binary_sha256='two')),
                ('revision', lambda p: p[3]['kirimasim'].update(commit='b'*40)),
                ('simulator', lambda p: p[3].update(icarus=self.build)),
                ('dependency', lambda p: p[4]['files'].update(runtime='two')),
                ('limit', lambda p: p[5].update(timeout=6)),
                ('initialization seed', lambda p: p[5].update(simulator_seed=2))]:
                with self.subTest(label=label):
                    changed = copy.deepcopy(parts); mutate(changed)
                    self.assertNotEqual(first, identity.execution(*changed)['sha256'])
            with patch.object(suite_results, 'runner_digest', return_value='changed'):
                self.assertNotEqual(first, identity.execution(*parts)['sha256'])
        with patch.object(identity, 'environment', return_value={'environment': 'two'}):
            self.assertNotEqual(first, identity.execution(*parts)['sha256'])

    def test_mid_run_environment_and_dependency_changes_are_stale(self):
        for kind in ('environment', 'dependency', 'source'):
            with self.subTest(kind=kind):
                output = self.root/kind
                def execute(record, *_):
                    if kind == 'environment': os.environ['RANDOM_CROSS_TEST_ONLY'] = 'changed'
                    if kind == 'dependency': self.binary.write_text('changed')
                    if kind == 'source': (output/record['source']).write_text('changed')
                    return {'status': 'pass', 'returncode': 0, 'reason': ''}
                self.binary.write_bytes(b'build one')
                with patch.object(runner, 'verify_binary', return_value=self.build), \
                        patch.object(identity, 'dependencies', return_value=self.inventory), \
                        patch.object(runner, 'execute', side_effect=execute), patch.dict(os.environ, {}, clear=False):
                    report = runner.run(self.manifest, output, 'fixture', 'a'*40, jobs=1)
                self.assertFalse(report['valid']); self.assertEqual(report['counts']['stale'], 3)

    def test_cli_skip_has_separate_nonzero_management_exit(self):
        from contextlib import redirect_stdout
        import io
        report, _ = self.run_job('first'); report, _ = self.run_job('second')
        with patch.object(sys, 'argv', ['run_random_cross.py', '--output', str(self.root/'cli'),
                                      '--kirimasim', 'fixture', '--commit', 'a'*40]), \
                patch.object(runner, 'run', return_value=report), redirect_stdout(io.StringIO()):
            self.assertEqual(runner.main(), 3)


class ReplayAndPromotionTests(Fixture):
    def test_external_zero_exit_error_is_not_hidden_by_runner_normalization(self):
        import run_icarus
        output = self.root/'comparison'
        record = runner.prepare(self.manifest, output)['case_0000']
        vvp = self.root/'vvp'
        for index, message in enumerate(('ERROR: runtime failure\n', '[0] %Error: runtime failure\n')):
            vvp.write_text('#!'+sys.executable+'\nimport sys; sys.stdout.write('+repr(message)+')\n')
            vvp.chmod(0o755)
            directory = self.root/str(index); directory.mkdir()
            def normalized_match(*args):
                subprocess.run([str(vvp)], capture_output=True, text=True)
                return True, ''  # Existing runner removed the severity line.
            with patch.object(run_icarus, 'run', side_effect=normalized_match):
                compare.worker('icarus', output/record['source'], output/record['expected'], str(vvp), 1, directory)
            result = json.loads((directory/'worker.json').read_text())
            self.assertEqual(result['returncode'], 0)
            self.assertEqual(result['status'], 'known')
            self.assertIn('diagnostic', result['reason'])

    def test_manifest_only_replay_does_not_claim_knowledge_of_old_code_or_bytes(self):
        manifest = self.root/'manifest.json'; manifest.write_text(json.dumps(self.manifest))
        with patch.object(models.random, 'Random', side_effect=AssertionError('redrawn')):
            report = runner.run(self.manifest, self.root/'replay', generate_only=True, replay=manifest)
        self.assertEqual(report['replay']['baseline'], 'manifest_only')
        self.assertIsNone(report['replay']['code_changed'])
        self.assertIsNone(report['replay']['cases']['case_0000']['source_changed'])
        self.assertIsNone(report['replay']['cases']['case_0000']['saved_expected_sha256'])

    def test_replay_freezes_bytes_and_exposes_current_reference_drift(self):
        first, _ = self.run_job('first')
        original = evidence.receipt(self.root/'first')
        materialize = models.materialize
        def changed(case):
            source, expected = materialize(case)
            return source, expected+'changed reference\n'
        with patch.object(models, 'materialize', side_effect=changed), \
                patch.object(models.random, 'Random', side_effect=AssertionError('redrawn')):
            saved, _ = self.run_job('saved', replay=self.root/'first/manifest.json')
            current, _ = self.run_job('current', replay=self.root/'first/manifest.json', reference_policy='current')
        self.assertFalse(saved['valid']); self.assertEqual(saved['counts']['stale'], 3)
        self.assertTrue(current['valid']); self.assertTrue(current['reference_drift'])
        self.assertEqual((self.root/'saved/cases/case_0000.expected').read_bytes(),
                         (self.root/'first/cases/case_0000.expected').read_bytes())
        self.assertNotEqual((self.root/'current/cases/case_0000.expected').read_bytes(),
                            (self.root/'current/origin/cases/case_0000.expected').read_bytes())
        self.assertEqual(original, evidence.receipt(self.root/'first'))

    def test_replay_rejects_changed_original_evidence(self):
        self.run_job('first')
        (self.root/'first/cases/case_0000.expected').write_text('tampered')
        with self.assertRaisesRegex(ValueError, 'fingerprints'):
            self.run_job('replay', replay=self.root/'first/manifest.json')

    def test_management_id_is_distinct_from_ordered_stimulus(self):
        case = sequence_case(); renamed = copy.deepcopy(case); renamed['id'] = 'case_0001'
        self.assertNotEqual(evidence.digest(case), evidence.digest(renamed))
        self.assertEqual(models.content_digest(case), models.content_digest(renamed))
        changed = copy.deepcopy(case); changed['stimuli']['operations'].reverse()
        self.assertNotEqual(models.content_digest(case), models.content_digest(changed))
        changed = copy.deepcopy(case); changed['stimuli']['operations'].append(changed['stimuli']['operations'][0])
        self.assertNotEqual(models.content_digest(case), models.content_digest(changed))

    def test_verilator_fourstate_guard_includes_unknown_to_bit_conversion(self):
        for state in ('logic', 'bit'):
            case = sequence_case(state)
            self.assertTrue(models.requires_fourstate(case))
            with patch.object(compare, 'stage', side_effect=AssertionError('two-state job launched')):
                result = compare.execute({'fourstate': True}, self.root, 'verilator', self.build, 1, 5, __import__('time').monotonic()+5)
            self.assertEqual(result['status'], 'unsupported')

    def test_adapter_keeps_body_and_simulator_specific_expectation_priority(self):
        output = self.root/'adapter'
        record = runner.prepare(self.manifest, output)['case_0000']
        source = output/record['source']
        source.write_text(source.read_text().replace('*/', ':expected_stdout_icarus: own\n:expected_stdout_lyra: other\n*/', 1))
        target, directory = compare.stage(record, output, 'icarus')
        self.assertEqual(source, target)
        self.assertEqual(source.read_bytes(), target.read_bytes())
        self.assertEqual(compare.expectation(target, 'icarus', output/record['expected']), 'own\n')
        self.assertEqual(compare.expectation(target, 'verilator', output/record['expected']),
                         (output/record['expected']).read_text())

    def test_confirmed_failure_produces_mechanism_draft_without_editing_origin(self):
        report, _ = self.run_job('failure', status='fail')
        before = evidence.receipt(self.root/'failure')
        triage = promotion.promote(self.root/'failure', 'case_0000', self.root/'draft', 'simulator',
                                   'context_width', 'Fixture: reviewed standard-derived model',
                                   confirmed=True, chapter='ch11', lrm='1800-2023 11.8.2')
        target = self.root/'draft'/triage['regression_draft']
        self.assertEqual(target.read_text().split('*/', 1)[1],
                         (self.root/'failure/cases/case_0000.sv').read_text().split('*/', 1)[1])
        self.assertEqual(target.with_suffix('.expected').read_bytes(),
                         (self.root/'failure/cases/case_0000.expected').read_bytes())
        self.assertEqual(suite_results.header(target)['oracle'], 'spec')
        self.assertEqual(triage['lint_problems'], lint_metadata.check(target))
        self.assertTrue(all(rule == 'width' for rule, detail in triage['lint_problems']))
        self.assertEqual(before, evidence.receipt(self.root/'failure'))

    def test_model_and_runner_triage_never_install_language_regressions(self):
        self.run_job('failure', status='fail')
        for classification in ('reference', 'runner', 'specification'):
            triage = promotion.promote(self.root/'failure', 'case_0000', self.root/classification,
                                       classification, 'mechanism', 'Investigate model/runner/standard first', confirmed=True)
            self.assertIsNone(triage['regression_draft'])

    def test_pass_and_unsupported_are_not_promoted(self):
        for status in ('pass', 'unsupported', 'not_run', 'stale'):
            self.run_job(status, status=status, force=True)
            with self.assertRaisesRegex(ValueError, 'recorded fail/known'):
                promotion.promote(self.root/status, 'case_0000', self.root/(status+'draft'),
                                  'simulator', 'mechanism', 'not a confirmed failure')


if __name__ == '__main__':
    unittest.main()
