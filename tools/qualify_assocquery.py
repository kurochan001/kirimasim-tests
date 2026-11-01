#!/usr/bin/env python3
"""Independently check associative-query expectations, without simulator oracles.

The mutation checks alter a Python specification model. They are not executed
SystemVerilog faults and must not be reported as simulator execution passes.
"""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import sys

import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_assocquery as generator

FAULTS = ('right_from_allocation', 'reverse_extrema', 'size_from_span',
          'overwrite_allocates', 'ignore_delete', 'unsigned_order')


def independent(row, fault=None):
    width, sign, layout, order, deletion, _ = row
    # Literal boundary tables and a list of entries are deliberately separate
    # from the generator's computed keys and dictionary state transitions.
    tables = {
        ('4', 'unsigned'): ([0, 8, 15], 15),
        ('8', 'unsigned'): ([0, 128, 255], 255),
        ('33', 'unsigned'): ([0, 4294967296, 8589934591], -1),
        ('4', 'signed'): ([-8, -1, 7], 7),
        ('8', 'signed'): ([-128, -1, 127], 127),
        ('33', 'signed'): ([-4294967296, -1, 4294967295], -1),
    }
    indices, right = tables[(width, sign)]
    if layout == 'compact':
        indices = [-3, 0, 2] if sign == 'signed' else [1, 3, 6]
    absent = (1 if sign == 'signed' else 0) if layout == 'compact' else (
        0 if sign == 'signed' else 1)
    sequence = {'ascending': indices, 'descending': indices[::-1],
                'zigzag': [indices[1], indices[2], indices[0]]}[order]
    values = list(zip(indices, (11, 22, 33)))
    target = {'low': indices[0], 'middle': indices[1], 'high': indices[2]}[deletion]
    operations = [('empty', 'none', 0, 0)]
    operations += [(f'insert{i}', 'put', key, dict(values)[key])
                   for i, key in enumerate(sequence, 1)]
    operations += [('overwrite', 'put', absent if fault == 'overwrite_allocates' else indices[1], 29),
                   ('delete', 'none' if fault == 'ignore_delete' else 'remove', target, 0),
                   ('delete_missing', 'remove', absent, 0), ('reinsert', 'put', target, 47),
                   ('clear', 'clear', 0, 0), ('reuse', 'put', absent, 91)]
    entries = []
    lines = ['dimensions=2 unpacked=1']

    def signed32(value):
        bits = format(value % 4294967296, '032b')
        return int(bits[1:], 2) - (2147483648 if bits[0] == '1' else 0)

    for label, operation, key, value in operations:
        if operation in ('put', 'remove'):
            entries = [(k, v) for k, v in entries if k != key]
        if operation == 'put':
            entries.append((key, value))
        elif operation == 'clear':
            entries = []
        ordered = sorted(entries, key=lambda entry: entry[0] % (1 << int(width))
                         if fault == 'unsigned_order' else entry[0])
        n = len(entries)
        first, last = (ordered[0][0], ordered[-1][0]) if n else (0, 0)
        low, high = (min(k for k, _ in entries), max(k for k, _ in entries)) if n else (0, 0)
        qright = signed32(high) if fault == 'right_from_allocation' else right
        qsize = high-low+1 if fault == 'size_from_span' and n else n
        lines.append(f'{label} left=0 right={qright} increment=-1 '
                     f'size={qsize} num={n} method_size={n}')
        if n:
            if fault == 'reverse_extrema':
                low, high = high, low
            lines.append(f'low={signed32(low)} high={signed32(high)} '
                         f'first_ok=1 first={first} last_ok=1 last={last}')
        else:
            lines.append('bounds=empty first_ok=0 last_ok=0')
        lines += [f'entry key={key} value={value}' for key, value in ordered]
    return '\n'.join(lines)+'\n'


def qualify():
    for row in generator.MODEL.rows():
        assert independent(row) == generator.reference(row), row
    results = {}
    for fault in FAULTS:
        different = [row for row in generator.MODEL.rows()
                     if independent(row, fault) != generator.reference(row)]
        selected = [row for row in generator.MODEL.select() if row in different]
        assert selected, fault
        results[fault] = {'different_legal_rows': len(different),
                          'different_selected_rows': len(selected),
                          'witness': 'tests/gen/ch20/'+generator.case_name(selected[0])+'.sv'}
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    results = qualify()
    sources = ('generators/interaction_assocquery.py', 'tools/qualify_assocquery.py')
    tests = [ROOT/'tests/gen/ch20'/(generator.case_name(row)+'.sv')
             for row in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(generator.MODEL.rows()), 'reference_mutations': results,
              'scope': 'Python specification-model mutations only; no executed SystemVerilog '
                       'faults and no simulator execution passes are claimed.',
              'sources_sha256': {s: hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},
              'inputs_sha256': {p.relative_to(ROOT).as_posix(): suite_results.input_digest(p)
                                for p in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(f'{report["independent_rows"]} independent entry-list rows; '
          f'{len(results)} Python specification-model mutations distinguished.')


if __name__ == '__main__':
    main()
