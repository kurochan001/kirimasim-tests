#!/usr/bin/env python3
"""Check clockvar/assertion observations using a separate event timeline."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import sys
import tempfile

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_clockassert as generator


def independently_calculated(row):
    width, _, _, _, timing, update, _ = row
    w = int(width)
    words = {'1': ((0, 1), (1, 0), (0, 1)),
             '8': ((0, 255), (255, 0), (0x55, 0xAA)),
             '33': ((0, 0x1FFFFFFFF), (0x1FFFFFFFF, 0), (0xAAAAAAAA, 0x155555555))}
    counts = {name: [0, 0] for name in ('clock', 'held', 'raw')}
    lines = []
    for phase, (before, incoming) in enumerate(words[width]):
        base = 20 * phase
        # Preponed=0, Active=2, NBA=4, Reactive=6, Postponed=8.
        history = [(base, 2, before),
                   (base + {'early': 6, 'edge': 8, 'between': 10}[timing],
                    4 if update == 'nba' else 2, incoming)]

        def at(time, region):
            return max(item for item in history if item[:2] <= (time, region))[2]

        clockvar = at(base + 7, 8)  # #1step, with 1ns time precision.
        seen = {'clock': clockvar, 'held': clockvar, 'raw': at(base + 12, 0)}
        live = {'clock': at(base + 8, 6), 'held': at(base + 12, 6), 'raw': at(base + 12, 6)}
        lines.append(f'phase={phase} before={before:0{w}b} source={incoming:0{w}b}')
        for name in ('clock', 'held', 'raw'):
            counts[name][0 if seen[name] else 1] += 1
            lines.append(f'{name} pass={counts[name][0]} fail={counts[name][1]} '
                         f'sampled={seen[name]:0{w}b} live={live[name]:0{w}b}')
        lines.append(f'final clockvar={clockvar:0{w}b} data={at(base+14,8):0{w}b}')
    return '\n'.join(lines) + '\n'


def source_for(row):
    test = ROOT / 'tests/gen/ch16' / (generator.case_name(row) + '.sv')
    text = test.read_text()
    field = suite_results.header(test)['expected_stdout']
    return text.replace(':expected_stdout: ' + field,
                        ':expected_stdout: @' + str((test.parent / field[1:]).resolve()))


def check_faults(directory, verilator):
    edge = source_for(generator.MODEL.anchors[0])
    between = source_for(generator.MODEL.anchors[1])
    faults = {
        'resample_on_probe': edge.replace(
            'check_held: assert property (@(negedge probe_clk) (|cb.data))',
            'check_held: assert property (@(negedge probe_clk) (|data))')
            .replace('held_seen = $sampled(cb.data);', 'held_seen = $sampled(data);'),
        'sampled_instead_of_action_live': edge.replace('clock_live = data;',
                                                     'clock_live = $sampled(data);'),
        'wrong_clocking_assertion_event': between.replace(
            'check_clock: assert property (@(cb) (|cb.data))',
            'check_clock: assert property (@(posedge probe_clk) (|cb.data))'),
        'wrong_sampling_edge': edge.replace('clocking cb @(posedge sample_clk);',
                                           'clocking cb @(negedge sample_clk);'),
        'missing_failure_action': edge.replace('held_fail++;', 'held_fail += 0;'),
    }
    outcomes = {}
    for name, source in {'edge_control': edge, 'between_control': between, **faults}.items():
        assert name.endswith('_control') or source not in (edge, between)
        test = directory / (name + '.sv')
        test.write_text(source)
        ok, reason = run_verilator.run(test, verilator, 1)
        if name.endswith('_control'):
            assert ok, (name, reason)
        else:
            assert not ok and reason.startswith('output differs'), (name, ok, reason)
        outcomes[name] = 'pass' if ok else 'detected'
    return outcomes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    for row in generator.MODEL.rows():
        assert independently_calculated(row) == generator.reference(row), row
    with tempfile.TemporaryDirectory() as folder:
        faults = check_faults(Path(folder), args.verilator)
    tests = [ROOT / 'tests/gen/ch16' / (generator.case_name(row) + '.sv')
             for row in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(generator.MODEL.rows()), 'fault_injection': faults,
              'simulator': suite_results.tool_version([args.verilator, '--version']),
              'sources_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                                 for name in ('generators/interaction_clockassert.py',
                                              'tools/qualify_clockassert.py')},
              'inputs_sha256': {test.relative_to(ROOT).as_posix(): suite_results.input_digest(test)
                                for test in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(generator.MODEL.rows())} independent timelines; two controls; five output-difference faults.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
