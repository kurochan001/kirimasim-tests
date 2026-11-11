"""Random corpus replay, independent observations and strict execution verdicts."""

import copy
from contextlib import redirect_stderr, redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tempfile
import time
import unittest
from unittest.mock import patch

import random_cross_models as models
import run_random_cross as runner


def expression_case():
    return {'id': 'case_0000', 'profile': 'expression_context',
            'parameters': {'row': ['33', 'narrow', 'wide', 'signed', 'signed', 'add']},
            'stimuli': [{'a': '1'+'0'*32, 'b': '0'*31+'1'}]}


def sequence_case(state='logic', direction='ascending', select='minus'):
    return {'id': 'case_0000', 'profile': 'packed_write_sequence',
            'parameters': {'width': 32, 'span': 3, 'direction': direction, 'select': select, 'state': state},
            'stimuli': {'initial': '0'*32,
                        'operations': [{'kind': 'write', 'offset': 0, 'data': '1xz'},
                                       {'kind': 'read', 'offset': 0},
                                       {'kind': 'write', 'offset': 1, 'data': '011'}]}}


class RandomModelTests(unittest.TestCase):
    def test_signed_context_literal(self):
        source, expected = models.materialize(expression_case())
        self.assertIn('logic signed [32:0] a;', source)
        self.assertIn('v0_result='+'11'+'0'*31+'1'+'\n', expected)

    def test_signed_division_and_remainder_toward_zero(self):
        case = {'id': 'case_0000', 'profile': 'division_context',
                'parameters': {'row': ['32', 'same', 'same', 'signed', 'signed', 'mod', 'known', 'bit']},
                'stimuli': [{'a': '1'*29+'001', 'b': '0'*30+'11'}]}
        source, expected = models.materialize(case)
        self.assertIn('bit [31:0] result;', source)
        self.assertIn('raw='+'1'*32+' result='+'1'*32+' bits=32', expected)
        case['parameters']['row'][5] = 'div'
        self.assertIn('result='+'1'*31+'0', models.materialize(case)[1])

    def test_overlapping_writes_preserve_others_and_four_state_values(self):
        _, expected = models.materialize(sequence_case())
        self.assertEqual(expected, 'initial='+'0'*32+'\n'
                         +'step=0 kind=write whole='+'0'*29+'1xz slice=1xz\n'
                         +'step=1 kind=read whole='+'0'*29+'1xz slice=1xz\n'
                         +'step=2 kind=write whole='+'0'*28+'011z slice=011\n')

    def test_bit_storage_converts_unknowns_before_future_reads(self):
        _, expected = models.materialize(sequence_case('bit'))
        self.assertIn('whole='+'0'*29+'100 slice=100', expected)
        self.assertIn('whole='+'0'*28+'0110 slice=011', expected)
        self.assertNotIn('x', expected)
        self.assertNotIn('z', expected)

    def test_all_index_directions_map_the_same_significance(self):
        expectations = set()
        for direction in ('ascending', 'descending'):
            for selection in ('plus', 'minus'):
                case = sequence_case(direction=direction, select=selection)
                source, expected = models.materialize(case)
                # At low significance: ascending + starts at 33, - at 35;
                # descending + starts at 4, - at 6.
                base = {('ascending', 'plus'): 33, ('ascending', 'minus'): 35,
                        ('descending', 'plus'): 4, ('descending', 'minus'): 6}[direction, selection]
                self.assertIn(f'index = {base};', source)
                expectations.add(expected)
        self.assertEqual(len(expectations), 1)

    def test_seed_is_deterministic_and_profiles_are_balanced(self):
        first = models.generate(731, 52, 4)
        self.assertEqual(first, models.generate(731, 52, 4))
        self.assertNotEqual(first['cases'], models.generate(732, 52, 4)['cases'])
        self.assertEqual({profile: sum(c['profile'] == profile for c in first['cases'])
                          for profile in models.PROFILES}, {profile: 4 for profile in models.PROFILES})

    def test_saved_stimuli_replay_without_random_generation(self):
        manifest = json.loads(json.dumps(models.generate(1234, 6, 5)))
        with patch.object(models.random, 'Random', side_effect=AssertionError('replay drew random data')):
            models.validate(manifest)
            for case in manifest['cases']:
                self.assertEqual(models.materialize(case), models.materialize(copy.deepcopy(case)))

    def test_case_and_operation_caps(self):
        for args in [(1, 0, 8), (1, 257, 8), (1, 1, 0), (1, 1, 33), (-1, 1, 1), (True, 1, 1)]:
            with self.subTest(args=args), self.assertRaises(ValueError):
                models.generate(*args)

    def test_invalid_or_injected_stimuli_are_rejected(self):
        invalid = []
        case = sequence_case();case['id'] = '../escape';invalid.append(case)
        case = sequence_case();case['stimuli']['operations'][0]['offset'] = 30;invalid.append(case)
        case = sequence_case();case['stimuli']['operations'][0]['data'] = '1; $finish;';invalid.append(case)
        case = expression_case();case['parameters']['row'][0] = '999999';invalid.append(case)
        for case in invalid:
            with self.subTest(case=case), self.assertRaises(ValueError):
                models.materialize(case)

    def test_duplicate_case_ids_and_boolean_schema_are_rejected(self):
        for kind in ('duplicate', 'schema'):
            manifest = models.generate(1, 2, 1)
            if kind == 'duplicate':manifest['cases'][1]['id'] = manifest['cases'][0]['id']
            else:manifest['schema'] = True
            with self.assertRaises(ValueError):models.validate(manifest)


class RandomRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.output = self.root/'result'
        self.manifest = models.generate(17, 3, 2)
        self.commit = '8'*40
        self.binary = self.root/'kirimasim'
        self.binary.write_text('binary fixture', encoding='utf-8')
        self.build = {'executable': str(self.binary), 'version': 'kirimasim 0.0.0 (commit '+'8'*12+')',
                      'commit': self.commit, 'binary_sha256': runner.sha(self.binary)}

    def test_generation_only_has_no_execution_passes(self):
        with patch.object(runner, 'verify_binary', side_effect=AssertionError('must not run')):
            report = runner.run(self.manifest, self.output, generate_only=True)
        self.assertFalse(report['completed'])
        self.assertEqual(report['counts']['pass'], 0)
        self.assertEqual(report['counts']['not_run'], 3)
        self.assertEqual(json.loads((self.output/'manifest.json').read_text(encoding='utf-8')), self.manifest)
        self.assertTrue((self.output/'report.ja.md').is_file())

    def test_existing_evidence_cannot_be_overwritten(self):
        runner.prepare(self.manifest, self.output)
        before = (self.output/'manifest.json').read_bytes()
        with self.assertRaises(ValueError):runner.prepare(self.manifest, self.output)
        self.assertEqual((self.output/'manifest.json').read_bytes(), before)

    def test_single_case_replay_keeps_source_and_expected_bytes(self):
        records = runner.prepare(self.manifest, self.output)
        selected = copy.deepcopy(self.manifest)
        selected['cases'] = [selected['cases'][1]]
        destination = self.root/'replay'
        replay = runner.prepare(selected, destination)
        for field in ('source', 'expected'):
            path = records['case_0001'][field]
            self.assertEqual((self.output/path).read_bytes(), (destination/replay['case_0001'][field]).read_bytes())

    def execute_result(self, code, stdout, stderr=''):
        records = runner.prepare(self.manifest, self.output)
        record = records['case_0000']
        want = (self.output/record['expected']).read_text(encoding='utf-8')
        result = subprocess.CompletedProcess(['kirimasim'], code, want if stdout is None else stdout, stderr)
        with patch.object(runner.subprocess, 'run', return_value=result):
            return runner.execute(record, self.output, 'fixture', 1, time.monotonic()+10)

    def test_matching_output_and_zero_exit_pass(self):
        self.assertEqual(self.execute_result(0, None,
                         'kirimasim: info: args: /tmp/error:reports/case.sv')['status'], 'pass')

    def test_matching_output_with_nonzero_exit_fails(self):
        result = self.execute_result(2, None)
        self.assertEqual(result['status'], 'fail')
        self.assertEqual(result['returncode'], 2)

    def test_unsupported_is_never_a_pass(self):
        result = self.execute_result(2, '', 'test.sv:1: error: unsupported: a feature')
        self.assertEqual(result['status'], 'unsupported')

    def test_zero_exit_error_diagnostic_fails(self):
        self.assertEqual(self.execute_result(0, None, 'test.sv:1: error: broken')['status'], 'fail')

    def test_output_difference_and_crash_fail(self):
        result = self.execute_result(-11, '')
        self.assertEqual(result['status'], 'fail')
        self.assertIn('-11', result['reason'])

    def test_timeout_preserves_partial_output(self):
        records = runner.prepare(self.manifest, self.output)
        error = subprocess.TimeoutExpired(['fixture'], 1, output=b'partial\n', stderr=b'diagnostic\n')
        with patch.object(runner.subprocess, 'run', side_effect=error):
            result = runner.execute(records['case_0000'], self.output, 'fixture', 1, time.monotonic()+10)
        self.assertEqual(result['reason'], 'timed out')
        self.assertEqual((self.output/result['stdout']).read_text(encoding='utf-8'), 'partial\n')

    def test_exhausted_budget_does_not_start_a_process(self):
        records = runner.prepare(self.manifest, self.output)
        with patch.object(runner.subprocess, 'run', side_effect=AssertionError('process started')):
            result = runner.execute(records['case_0000'], self.output, 'fixture', 1, time.monotonic()-1)
        self.assertEqual(result['status'], 'not_run')

    def test_changed_expectations_invalidate_observed_success(self):
        def change(record, output, *_):
            (output/record['expected']).write_text('changed\n', encoding='utf-8')
            return {'status': 'pass', 'reason': '', 'returncode': 0}
        with patch.object(runner, 'verify_binary', return_value=self.build), patch.object(runner, 'execute', side_effect=change):
            report = runner.run(self.manifest, self.output, 'fixture', self.commit)
        self.assertFalse(report['valid'])
        self.assertEqual(report['counts']['stale'], 3)
        self.assertEqual(report['counts']['pass'], 0)
        self.assertTrue((self.output/'events.jsonl').read_text(encoding='utf-8'))

    def test_changed_binary_invalidates_all_results(self):
        def change(*_):
            self.binary.write_text('changed executable', encoding='utf-8')
            return {'status': 'pass', 'reason': '', 'returncode': 0}
        with patch.object(runner, 'verify_binary', return_value=self.build), patch.object(runner, 'execute', side_effect=change):
            report = runner.run(self.manifest, self.output, 'fixture', self.commit, jobs=1)
        self.assertTrue(report['binary_changed'])
        self.assertEqual(report['counts']['stale'], 3)

    def test_version_must_identify_the_requested_commit(self):
        self.binary.chmod(0o755)
        good = subprocess.CompletedProcess([], 0, self.build['version'], '')
        with patch.object(runner.subprocess, 'run', return_value=good):
            self.assertEqual(runner.verify_binary(self.binary, self.commit)['commit'], self.commit)
            with self.assertRaises(ValueError):runner.verify_binary(self.binary, '9'*40)

    def test_normalization_retains_real_output(self):
        self.assertEqual(runner.normalize('\nvalue= 01\nfile.sv:2: $finish called at 1 (1s)\n'), 'value= 01\n')

    def test_cli_nonpass_is_a_failure_even_when_all_cases_completed(self):
        report = {'seed': 1, 'case_count': 1, 'completed': True, 'valid': True,
                  'counts': {state: int(state == 'unsupported') for state in runner.STATES}}
        args = ['run_random_cross.py', '--output', str(self.output), '--kirimasim', 'fixture',
                '--commit', self.commit, '--cases', '1']
        with patch('sys.argv', args), patch.object(runner, 'run', return_value=report), redirect_stdout(io.StringIO()):
            self.assertEqual(runner.main(), 1)

    def test_cli_replay_refuses_generation_overrides(self):
        manifest = self.root/'manifest.json'
        manifest.write_text(json.dumps(self.manifest), encoding="utf-8")
        args = ['run_random_cross.py', '--output', str(self.output), '--generate-only',
                '--replay', str(manifest), '--seed', '2']
        with patch('sys.argv', args), redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
            runner.main()
        self.assertEqual(error.exception.code, 2)

    def test_cli_replays_one_case_without_rng(self):
        manifest = self.root/'manifest.json'
        manifest.write_text(json.dumps(self.manifest), encoding="utf-8")
        args = ['run_random_cross.py', '--output', str(self.output), '--generate-only',
                '--replay', str(manifest), '--case', 'case_0001']
        with patch('sys.argv', args), patch.object(models.random, 'Random', side_effect=AssertionError('RNG used')), redirect_stdout(io.StringIO()):
            self.assertEqual(runner.main(), 0)
        saved = json.loads((self.output/'manifest.json').read_text(encoding='utf-8'))
        self.assertEqual(saved['seed'], 17)
        self.assertEqual(saved['cases'], [self.manifest['cases'][1]])


class RandomWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        workflow = (models.ROOT/'.github/workflows/nightly.yml').read_text(encoding='utf-8')
        cls.job = workflow.split('\n  kirimasim:\n', 1)[1].split('\n  lyra:\n', 1)[0]
        cls.random_step = cls.job.split('      - name: Run bounded random cross comparisons\n', 1)[1].split('\n      - ', 1)[0]

    def test_random_run_refreshes_and_builds_upstream_before_execution(self):
        step = self.random_step
        self.assertLess(step.index('git fetch'), step.index('git checkout'))
        self.assertLess(step.index('git checkout'), step.index('cmake --build'))
        self.assertLess(step.index('cmake --build'), step.index('tools/run_random_cross.py'))
        self.assertIn('--commit "$random_commit"', step)

    def test_limits_and_failure_status_are_not_suppressed(self):
        self.assertIn('--cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120', self.random_step)
        self.assertIn('|| status=$?', self.random_step)
        self.assertIn('exit "$status"', self.random_step)
        self.assertNotIn('|| true', self.random_step)

    def test_random_artifact_does_not_join_fixed_history(self):
        self.assertIn('name: random-cross-kirimasim', self.job)
        self.assertIn('--output random-results', self.random_step)
        self.assertNotIn('--output results/', self.random_step)
        self.assertIn('Compare with the previous night\n        if: ${{ !cancelled() }}', self.job)

    def test_check_only_generates_and_replays_the_corpus(self):
        check = (models.ROOT/'.github/workflows/check.yml').read_text(encoding='utf-8')
        step = check.split('      - name: Check deterministic random corpus generation\n', 1)[1].split('\n      - ', 1)[0]
        self.assertIn('--generate-only --seed 1', step)
        self.assertIn('--replay', step)
        self.assertIn('cmp ', step)
        self.assertNotIn('--kirimasim', step)


if __name__ == '__main__':
    unittest.main()
