#!/usr/bin/env python3
"""Check the DPI/NBA oracle with bit strings, a C ABI probe and SV faults."""

import argparse
import ctypes
import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_dpi_nba as generator


def independently_calculated(row, library):
    direction, order, actual, size, signedness, _ = row
    width = int(size)
    # Explicit stimulus words; do not call the generator's initialization or
    # conversion helpers. XOR and sign extension use character strings here.
    stimuli = {8: ('15', 'ea', '89'),
               32: ('15', 'ffffffea', '80000009'),
               65: ('15', '1ffffffffffffffea', '10000000000000009')}
    words = [format(int(value, 16), f'0{width}b') for value in stimuli[width]]
    source = 1 if actual == 'same' else 2
    payload = '1' + '0' * (width - 3) + '11'
    exclusive_or = lambda left, right: ''.join('0' if a == b else '1'
                                               for a, b in zip(left, right))
    captured = exclusive_or(words[source], payload)
    extension = words[source][0] if signedness == 'signed' else '0'
    incoming = (extension * 32 + words[source])[-32:]
    argument = ctypes.c_int(int(incoming, 2)).value
    if direction == 'input':
        returned = library.cross_dpi_nba_input(argument)
        assert returned == argument
    else:
        formal = ctypes.c_int(argument if direction == 'inout' else 0x13579)
        returned = getattr(library, 'cross_dpi_nba_' + direction)(ctypes.byref(formal))
        expected = -61 if direction == 'output' else int(incoming[-8:], 2) - 73
        assert formal.value == expected
        assert returned == (53 if direction == 'output' else argument)
        outgoing = format(ctypes.c_uint(formal.value).value, '032b')
        words[source] = (outgoing[0] * width + outgoing)[-width:]
    if order == 'dpi_first':
        captured = exclusive_or(words[source], payload)

    def snapshot(label):
        return label + ' ' + ' '.join(format(int(bits, 2), f'0{(width+3)//4}x')
                                      for bits in words)

    lines = [f'return={returned}', snapshot('after_call')]
    words[source] = format(43, f'0{width}b')
    lines += [snapshot('mutated'),
              'indices=0,0 payload=' + format(int('1' * width, 2), f'0{(width+3)//4}x')]
    words[1] = captured
    lines += [snapshot('postponed'), snapshot('settled')]
    return '\n'.join(lines) + '\n'


def check_faults(directory, verilator):
    row = generator.MODEL.anchors[0]
    path = ROOT / 'tests/gen/ch35' / (generator.case_name(row) + '.sv')
    text = path.read_text()
    fields = suite_results.header(path)
    for name in ('expected_stdout', 'dpi_c'):
        value = fields[name]
        text = text.replace(':' + name + ': ' + value,
                            ':' + name + ': @' + str((path.parent / value[1:]).resolve()))
    enqueue = '    cells[nba_index] <= cells[dpi_index] ^ payload;'
    late = text.replace(enqueue + '\n', '').replace('    $strobe(', enqueue + '\n    $strobe(')
    mutations = {
        'blocking_update': text.replace(enqueue, enqueue.replace(' <= ', ' = ')),
        'late_value_and_index_capture': late,
        'lost_copyback': text.replace('cross_dpi_nba_inout(', 'cross_dpi_nba_input(')
                             .replace('(inout int value)', '(input int value)'),
        'wrong_signedness': text.replace('logic signed [7:0]', 'logic unsigned [7:0]'),
    }
    outcomes = {}
    for name, source in {'baseline': text, **mutations}.items():
        assert name == 'baseline' or source != text
        test = directory / (name + '.sv')
        test.write_text(source)
        ok, reason = run_verilator.run(test, verilator, 1)
        if name == 'baseline':
            assert ok, reason
        else:
            # A compile failure does not demonstrate observation sensitivity.
            assert not ok and reason.startswith('output differs'), (name, ok, reason)
        outcomes[name] = 'pass' if ok else 'detected'
    return outcomes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    helper = ROOT / 'tests/ch35/cross_dpi_nba.c'
    with tempfile.TemporaryDirectory() as folder:
        directory = Path(folder)
        library_path = directory / 'helper.so'
        subprocess.run([args.cc, '-shared', '-fPIC', str(helper), '-o', str(library_path)], check=True)
        library = ctypes.CDLL(str(library_path))
        for direction in ('input', 'output', 'inout'):
            function = getattr(library, 'cross_dpi_nba_' + direction)
            function.argtypes = [ctypes.c_int if direction == 'input' else ctypes.POINTER(ctypes.c_int)]
            function.restype = ctypes.c_int
        rows = generator.MODEL.rows()
        for row in rows:
            assert independently_calculated(row, library) == generator.reference(row), row
        faults = check_faults(directory, args.verilator)
    tests = [ROOT / 'tests/gen/ch35' / (generator.case_name(row) + '.sv')
             for row in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(rows), 'c_abi_checked': True,
              'fault_injection': faults,
              'simulator': suite_results.tool_version([args.verilator, '--version']),
              'sources_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                                 for name in ('generators/interaction_dpi_nba.py',
                                              'tools/qualify_dpi_nba.py',
                                              'tests/ch35/cross_dpi_nba.c')},
              'inputs_sha256': {test.relative_to(ROOT).as_posix(): suite_results.input_digest(test)
                                for test in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(f'{len(rows)} independent rows; C ABI checked; {len(faults)-1} observable faults detected.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
