# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""The holdout definition is measured and reported apart from the daily and
weekly ones and never changes them."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

import benchmark_compare as shared
import benchmark_history as history
import daily_benchmark as daily
import holdout_benchmark as holdout
import holdout_history

ROOT = Path(__file__).resolve().parent.parent

# The inputs of the fingerprint of the daily series cc3a300591d1 and of the
# weekly one, as the published runs record them. A change here starts new
# daily and weekly series: it needs a definition review of its own.
SERIES_INPUTS = {
    'bench/daily.json': '4006a76543b7c88eed78ba128e7459c54ac2ee82a78efdd401ac2d85643bef9b',
    'tools/daily_benchmark.py': '0edb91f5cbc17e8d1eec9e77ab4c87fb7dbcf4b9ff57d233c5e94628770ad077',
    'tools/benchmark_compare.py': '2896f429781d5eaff2d0ecec465726de342f840892056d20304d2df179ad6be0',
    'tools/benchmark_history.py': 'bda014f86bbbea0bd769b5458656bfda07cbcaec712624cfad17960b10b5c887',
    'tools/benchmark_setup.py': 'aa89dd6c7df5268f361f96049069cfe68b524ff93819afc4351fcb557c91d8f9',
}
DAILY_DEFINITION = '2f571b4f96a8d5da7a836a09b932a45984d73acd64b4b205de6b2b03aee2aa4e'
WEEKLY_DEFINITION = '4f4e38888bbf9f9c9d32b8dfe7a1cb94c0c7934127c1a8eca1ebf791be1b3d00'


def campaign(identifier='actions-9-1', time='2026-11-23T04:00:00+00:00', series='holdout-series'):
    config = holdout.config_at(holdout.DEFAULT_CONFIG)
    value = {'schema': 1, 'id': identifier, 'started_at': time, 'completed_at': time, 'mode': 'formal',
             'series': series, 'environment': {'runs': 5, 'profile': 'holdout', 'machine': {'cpu': 'Example CPU'}},
             'actions': {}, 'tools': {n: {'commit': 'a' * 40, 'version': 'test'} for n in config['tools']},
             'definition': {}, 'inputs_unchanged': True, 'definition_config': config, 'cases': []}
    for definition in config['cases']:
        row = {**definition, 'tools': {}}
        for tool in config['tools']:
            if tool in definition.get('unsupported', {}):
                row['tools'][tool] = {'build': None, 'warmup': None, 'samples': {'small': [], 'large': []},
                                      'error': {'stage': 'unsupported', 'reason': definition['unsupported'][tool]}}
                continue

            def sample(n, repetition=0):
                value = {'seconds': 1 if n == 1 else 11, 'exit_code': 0, 'timed_out': False, 'max_rss_mib': 16,
                         'repetition': repetition, 'correctness_checked': True, 'result_line_count': 1,
                         'result_line': definition['expected_small' if n == 1 else 'expected']}
                if definition.get('waveform'):
                    value['waveform_bytes'] = 1000 if n == 1 else 5000
                return value
            row['tools'][tool] = {'warmup': sample(1), 'build': None,
                                  'samples': {'small': [sample(1, i) for i in range(5)],
                                              'large': [sample(definition['count'], i) for i in range(5)]}}
        value['cases'].append(row)
    return value


class Definition(unittest.TestCase):
    def test_daily_and_weekly_series_inputs_are_unchanged(self):
        for path, expected in SERIES_INPUTS.items():
            with self.subTest(path=path):
                self.assertEqual(shared.digest(ROOT / path), expected)
        self.assertEqual(daily.identity(daily.config_at(daily.DEFAULT_CONFIG, 'daily')), DAILY_DEFINITION)
        self.assertEqual(daily.identity(daily.config_at(daily.DEFAULT_CONFIG, 'weekly')), WEEKLY_DEFINITION)
        self.assertNotIn('holdout', json.loads((ROOT / 'bench/daily.json').read_text())['profiles'])

    def test_holdout_shares_tools_settings_and_adapter_with_daily(self):
        mine = json.loads(holdout.DEFAULT_CONFIG.read_text())
        theirs = json.loads(daily.DEFAULT_CONFIG.read_text())
        for key in ('benchmark_source', 'latest_repository', 'latest_ref', 'tools', 'measurement'):
            self.assertEqual(mine[key], theirs[key], key)
        self.assertFalse(mine['measurement']['waveforms'])
        holdout.check_definition()
        config = holdout.config_at(holdout.DEFAULT_CONFIG)
        self.assertEqual(config['definition'], 'holdout-v1-icarus14')
        self.assertEqual(len(config['cases']), 9)
        names = {c['name'] for c in config['cases']}
        self.assertFalse(names & {c['name'] for c in theirs['cases']}, 'holdout names are new')
        self.assertEqual({c['name'] for c in config['cases'] if c.get('waveforms')}, {'bus_fabric_vcd', 'bus_fabric_fst'})

    def test_references_match_the_frozen_sources(self):
        spec = importlib.util.spec_from_file_location('reference_holdout', ROOT / 'bench/reference_holdout.py')
        reference = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(reference)
        self.assertEqual(reference.oracle('class_pool', 1), 'class_pool n=1 checksum=6b3154a9 consumed=1 reads=0')
        self.assertEqual(reference.oracle('force_release', 4), 'force_release n=4 checksum=12ca4acf w=5dcb516e v=07910b35')
        self.assertEqual(reference.oracle('file_output', 1), 'file_output n=1 lines=1 bytes=22 checksum=00000016')
        reference.check()

    def test_groups_hold_only_what_their_peer_runs(self):
        config = holdout.config_at(holdout.DEFAULT_CONFIG)
        cases = {c['name']: c for c in config['cases']}
        for group in config['groups']:
            self.assertEqual(group['cases'], [n for n in cases if group['peer'] not in cases[n].get('unsupported', {})])
        broken = json.loads(holdout.DEFAULT_CONFIG.read_text())
        broken['groups'][0]['cases'].insert(0, 'force_release')
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'holdout.json'
            path.write_text(json.dumps(broken))
            with self.assertRaisesRegex(ValueError, 'declared not to run'):
                holdout.config_at(path)

    def test_waveform_and_flag_commands(self):
        config = holdout.config_at(holdout.DEFAULT_CONFIG)
        cases = {c['name']: c for c in config['cases']}

        class Module:
            steps = []

            def build_steps(self, steps, work, env=None):
                Module.steps.append(steps[0])
                return {'seconds': 0, 'steps': []}

            def prepare(self, tool, exe, design, work):
                return None, lambda n: ['pinned', tool, f'+n={n}']
        adapter = holdout.HoldoutAdapter.__new__(holdout.HoldoutAdapter)
        adapter.module = Module()
        work = Path('/w')
        adapter.case = cases['real_filter']
        self.assertEqual(adapter.prepare('icarus', '/i/iverilog', Path('d.sv'), work)[1](3), ['pinned', 'icarus', '+n=3'])
        adapter.case = cases['bus_fabric_fst']
        _, run = adapter.prepare('kirimasim', '/k', Path('bus_fabric.sv'), work)
        self.assertEqual(run(5), ['/k', '--wave=/w/bench.fst', 'bus_fabric.sv', '+n=5'])
        _, run = adapter.prepare('icarus', '/i/iverilog', Path('bus_fabric.sv'), work)
        self.assertEqual(run(5), ['/i/vvp', '-n', '/w/bench.vvp', '-fst', '+n=5'])
        self.assertIn('-DHOLDOUT_WAVE_FILE="bench.fst"', Module.steps[-1])
        self.assertEqual(Module.steps[-1][-1], str(ROOT / 'bench/holdout_waveform.sv'))
        adapter.case = cases['bus_fabric_vcd']
        adapter.prepare('verilator', '/v', Path('bus_fabric.sv'), work)
        self.assertEqual(Module.steps[-1][6:9], ['--trace', '--trace-max-array', '1'])
        adapter.case = cases['specify_paths']
        adapter.prepare('icarus', '/i/iverilog', Path('specify_paths.sv'), work)
        self.assertEqual(Module.steps[-1][:3], ['/i/iverilog', '-g2012', '-gspecify'])


class History(unittest.TestCase):
    def test_holdout_is_kept_apart_from_the_daily_history_and_headline(self):
        value = campaign()
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            holdout_history.append(directory, value)
            self.assertFalse((directory / 'runs').exists())
            self.assertFalse((directory / 'headline.json').exists())
            self.assertTrue((directory / 'holdout/runs/actions-9-1.json').is_file())
            latest = json.loads((directory / 'latest-holdout.json').read_text())
            self.assertEqual({g['name']: g['available_count'] for g in latest['groups']},
                             {'holdout-icarus14': 8, 'holdout-regression': 9, 'holdout-verilator': 8})
            self.assertTrue(all(g['ratio'] == 1 for g in latest['groups']))
            text = (directory / 'README.md').read_text()
            self.assertIn('Latest holdout attempt (reported only)', text)
            self.assertIn('| bus_fabric_vcd (N=100000) | latest | 5,000 |', text)
            japanese = (directory / 'README.ja.md').read_text()
            self.assertIn('最新の別枠の測定（報告のみ）', japanese)

    def test_a_declared_exclusion_is_shown_as_missing(self):
        value = holdout_history.normalized(campaign())
        lines = '\n'.join(history.report(value, prefix='holdout/'))
        row = next(line for line in lines.splitlines() if line.startswith('| class_pool (N=800000) | icarus |'))
        self.assertIn('| unsupported |', row)
        self.assertIn('| — |', row)
        self.assertIn('virtual override', row)
        self.assertIsNone(value['cases'][0]['ratios']['icarus'])
        self.assertIsNotNone(value['cases'][0]['ratios']['icarus_devel'])

    def test_the_holdout_table_survives_a_daily_publication(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            holdout_history.append(directory, campaign())
            # benchmark_history.render writes both READMEs from the daily runs.
            for name in ('README.md', 'README.ja.md'):
                (directory / name).write_text('# x\n\n<details><summary>s</summary>\n\nbody\n\n</details>\n')
            holdout_history.readme(directory)
            holdout_history.readme(directory)
            text = (directory / 'README.md').read_text()
            self.assertEqual(text.count(holdout_history.START), 1)
            self.assertLess(text.index(holdout_history.START), text.index('</details>'))

    def test_daily_history_rejects_a_holdout_run(self):
        with self.assertRaisesRegex(ValueError, 'profile'):
            history.normalized(campaign())

    def test_a_wrong_result_line_is_not_measured(self):
        value = campaign()
        value['cases'][7]['tools']['latest']['samples']['large'][0]['result_line'] = 'bus_fabric n=100000 checksum=0'
        value = holdout_history.normalized(value)
        self.assertEqual(value['cases'][7]['tools']['latest']['status'], 'output_mismatch')
        self.assertIsNone(next(g for g in value['groups'] if g['name'] == 'holdout-icarus14')['ratio'])


if __name__ == '__main__':
    unittest.main()
