#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Holdout speed campaign: designs outside the daily and weekly sets, measured
and reported only.

The holdout definition (bench/holdout.json) is not used to tune kirimasim. It
reuses tools/daily_benchmark.py unchanged, so the daily and weekly series keep
their fingerprints; this driver adds only what the holdout conditions need:

- a condition may print the result line of another name (result_name), so the
  two waveform conditions run bench/bus_fabric.sv unchanged;
- a condition may compile extra files next to its design (files), add
  compiler flags (icarus_flags, verilator_flags) or request a waveform
  (waveform: vcd or fst; kirimasim --wave=FILE, Icarus Verilog vvp -fst and
  Verilator --trace/--trace-fst with bench/holdout_waveform.sv);
- files a run writes in its working directory (outputs, and the waveform) are
  measured and removed after every run; a waveform's size is kept per sample.

Conditions without these fields run with exactly the pinned adapter's
commands. The manifest records this driver's SHA-256, so a change to it is a
change of the holdout definition and starts a new series.
"""
import argparse
import hashlib
import json
import re
import tempfile
from pathlib import Path

import benchmark_compare as shared
import daily_benchmark as daily

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = ROOT / 'bench/holdout.json'
PROFILE = 'holdout'
EXTRA_FIELDS = ('result_name', 'files', 'icarus_flags', 'verilator_flags', 'waveform', 'outputs')
WAVEFORMS = ('vcd', 'fst')


def result_name(case):
    return case.get('result_name', case['name'])


def config_at(path, profile=PROFILE):
    """The holdout definition with the checks of daily_benchmark.config_at,
    where the result line may carry the name of the design it runs."""
    config = json.loads(Path(path).read_text())
    profiles = config.pop('profiles', None)
    if profile != PROFILE or not profiles or set(profiles) != {PROFILE}:
        raise ValueError('the holdout definition has exactly the holdout profile')
    selected = profiles[PROFILE]
    cases = {c['name']: c for c in config['cases']}
    groups = {g['name']: g for g in config['groups']}
    if len(cases) != len(config['cases']) or len(groups) != len(config['groups']):
        raise ValueError('duplicate manifest entry')
    if (len(set(selected['cases'])) != len(selected['cases']) or
            len(set(selected['groups'])) != len(selected['groups']) or
            not set(selected['cases']) <= cases.keys() or not set(selected['groups']) <= groups.keys()):
        raise ValueError('invalid profile selection')
    config.update(definition=selected['definition'], profile=PROFILE,
                  cases=[cases[name] for name in selected['cases']],
                  groups=[groups[name] for name in selected['groups']])
    if config['schema'] != 1 or config['measurement']['runs'] != 5:
        raise ValueError('unsupported definition or formal repetition count')
    if config['measurement'].get('waveforms') is not False:
        raise ValueError('waveforms are requested per condition, not for the campaign')
    names = [c['name'] for c in config['cases']]
    if len(names) != len(set(names)) or not names:
        raise ValueError('empty or duplicate cases')
    for c in config['cases']:
        if c['count'] <= 1 or not re.fullmatch(r'[a-z0-9_]+', c['name']):
            raise ValueError('invalid case')
        if not re.fullmatch(r'[a-z0-9_]+', result_name(c)):
            raise ValueError('invalid result name')
        for key, n in [('expected', c['count']), ('expected_small', 1)]:
            if not c[key].startswith(f"{result_name(c)} n={n} "):
                raise ValueError('missing fixed expectation or incorrect count')
        if c.get('waveform') not in (None, *WAVEFORMS) or bool(c.get('waveform')) != bool(c.get('waveforms')):
            raise ValueError('a waveform condition names vcd or fst and sets waveforms')
        if c.get('waveform') and not c.get('files'):
            raise ValueError('a waveform condition compiles the dump module for Icarus and Verilator')
        for path in c.get('files', {}):
            if Path(path).is_absolute() or '..' in Path(path).parts:
                raise ValueError('extra files are relative to the suite')
        if not set(c.get('unsupported', {})) <= set(config['tools']) - {'latest'}:
            raise ValueError('unsupported declarations name comparison tools')
    for g in config['groups']:
        if not g['cases'] or len(g['cases']) != len(set(g['cases'])) or not set(g['cases']) <= set(names):
            raise ValueError('invalid fixed comparison group')
        if g['peer'] not in config['tools'] or g['peer'] == 'latest':
            raise ValueError('invalid comparison peer')
        declared = [name for name in g['cases'] if g['peer'] in cases[name].get('unsupported', {})]
        if declared:
            raise ValueError('a group cannot require a condition its peer is declared not to run')
    return config


def check_definition(path=DEFAULT_CONFIG):
    """The recorded driver and extra-file hashes must be those of the files."""
    config = json.loads(Path(path).read_text())
    if config.get('driver_sha256') != shared.digest(Path(__file__)):
        raise ValueError('holdout driver hash differs from the frozen definition')
    for case in config['cases']:
        for name, expected in case.get('files', {}).items():
            if shared.digest(ROOT / name) != expected:
                raise ValueError(case['name'] + ': extra file differs from the frozen definition')
    return config


class HoldoutAdapter(daily.Adapter):
    """daily_benchmark.Adapter, plus the per-condition commands of the holdout."""
    case = None

    def prepare(self, tool, exe, design, work):
        case = self.case or {}
        if not any(case.get(key) for key in ('files', 'icarus_flags', 'verilator_flags', 'waveform')):
            return self.module.prepare(tool, exe, design, work)
        wave = case.get('waveform')
        extra = [str(ROOT / name) for name in case.get('files', {})]
        define = ['-DHOLDOUT_WAVE_FILE="bench.' + wave + '"'] if wave else []
        if tool == 'kirimasim':
            option = ['--wave=' + str(Path(work) / ('bench.' + wave))] if wave else []
            return None, lambda n: [exe, *option, str(design), f'+n={n}']
        if tool == 'icarus':
            compiled = Path(work) / 'bench.vvp'
            build = self.module.build_steps([[exe, '-g2012', *case.get('icarus_flags', []), *define,
                                              '-o', str(compiled), str(design), *extra]], work)
            vvp = str(Path(exe).with_name('vvp'))
            fst = ['-fst'] if wave == 'fst' else []
            return build, lambda n: [vvp, '-n', str(compiled), *fst, f'+n={n}']
        if tool == 'verilator':
            build = self.module.build_steps([[exe, '--binary', '--timing', '-Wno-fatal', '-Wno-lint',
                                              '-Wno-style', *case.get('verilator_flags', []), *define,
                                              '--build-jobs', '0', '-Mdir', str(Path(work) / 'obj'),
                                              '--prefix', 'Vbench', str(design), *extra]], work)
            program = str(Path(work) / 'obj' / 'Vbench')
            return build, lambda n: [program, f'+n={n}']
        raise ValueError('no holdout command for ' + tool)

    def run(self, command, work, env=None):
        result = super().run(command, work, env)
        case = self.case or {}
        if case.get('waveform'):
            wave = Path(work) / ('bench.' + case['waveform'])
            result['waveform_bytes'] = wave.stat().st_size if wave.is_file() else None
            wave.unlink(missing_ok=True)
        for name in case.get('outputs', []):
            (Path(work) / name).unlink(missing_ok=True)
        return result

    def sample(self, name, result):
        sample = super().sample(name, result)
        if 'waveform_bytes' in result:
            sample['waveform_bytes'] = result['waveform_bytes']
        return sample


def holdout_collect(original, adapter, extra_files):
    """collect_case for one condition: checks run on its result name, and the
    row keeps the condition name. Extra files must not change meanwhile."""
    def collect(case, *args, **kwargs):
        adapter.case = case
        try:
            row = original({**case, 'name': result_name(case)}, *args, **kwargs)
        finally:
            adapter.case = None
        if any(shared.digest(path) != expected for path, expected in extra_files.items()):
            raise ValueError('inputs changed during measurement')
        row['name'] = case['name']
        return row
    return collect


def measure(args):
    """daily_benchmark.measure with the holdout definition, adapter and rows."""
    config = check_definition(args.config)
    extra = {ROOT / name: digest for case in config['cases'] for name, digest in case.get('files', {}).items()}
    adapters = []

    class Adapter(HoldoutAdapter):
        def __init__(self, *a, **k):
            super().__init__(*a, **k)
            adapters.append(self)
    original_collect = shared.collect_case
    original = (daily.config_at, daily.Adapter)

    def collect(case, adapter, *a, **k):
        return holdout_collect(original_collect, adapter, extra)(case, adapter, *a, **k)
    daily.config_at, daily.Adapter, shared.collect_case = config_at, Adapter, collect
    try:
        return daily.measure(args)
    finally:
        daily.config_at, daily.Adapter = original
        shared.collect_case = original_collect


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument('--config', type=Path, default=DEFAULT_CONFIG)
    p.add_argument('--inventory', type=Path)
    p.add_argument('--benchmark-root', type=Path)
    p.add_argument('--tool', action='append', default=[], metavar='NAME=EXECUTABLE')
    p.add_argument('--tool-commit', action='append', default=[], metavar='NAME=SHA')
    p.add_argument('--latest-commit')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--smoke', action='store_true')
    p.add_argument('--only', nargs='+')
    p.add_argument('--environment', default='local-reference', help='non-identifying measurement profile')
    p.add_argument('--run-id')
    p.add_argument('--run-url')
    p.add_argument('--lock', type=Path, default=Path(tempfile.gettempdir()) / 'kirimasim-benchmark.lock')
    args = p.parse_args()
    args.profile = PROFILE
    try:
        return measure(args)
    except (ValueError, OSError, KeyError) as error:
        p.exit(2, str(error) + '\n')


if __name__ == '__main__':
    raise SystemExit(main())
