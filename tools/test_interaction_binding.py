"""Check binding expectations with shared cells and a private input cell."""

from dataclasses import dataclass
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_binding as cases


@dataclass
class Word:
    bits: str


def simulate(row, phase, value):
    w = int(row[0]); mask = (1 << w) - 1
    initial = [f"{mask if i == phase else 0:0{w}b}" for i in range(3)]
    cells = [Word(v) for v in initial]
    argument = Word(cells[0].bits) if row[3] == 'input' else cells[0]
    raw = f"{mask ^ int(initial[0], 2):0{w}b}" if value == 'known' else value * w
    stored = raw.translate(str.maketrans('xz', '00')) if row[1] == 'bit' else raw
    if all(c in '01' for c in stored):
        other = f"{mask ^ int(stored, 2):0{w}b}"
        write = other
    else:
        other, write = '1' * w, '0' * w
    tail = f"{mask ^ int(write, 2):0{w}b}"
    cells[0].bits, cells[1].bits = stored, other
    changed = [v.bits for v in cells]
    seen = argument.bits
    if row[3] != 'const_ref':
        argument.bits = write
    after = argument.bits
    after_write = [v.bits for v in cells]
    cells[0].bits = tail
    return {'initial': initial, 'source': raw, 'other': other, 'write': write, 'tail': tail,
            'changed': changed, 'seen': seen, 'formal_after': after,
            'after_write': after_write, 'returning': argument.bits,
            'final': [v.bits for v in cells]}


class ArgumentBindingOracle(unittest.TestCase):
    def test_all_legal_rows_match_shared_cells_and_a_private_input_copy(self):
        for row in cases.MODEL.rows():
            for _, phase, value in cases.phases(row):
                expected = simulate(row, phase, value)
                actual = cases.reference(row, phase, value)
                actual.pop('selector')
                self.assertEqual(actual, expected, (row, phase, value))

    def test_index_changes_do_not_redirect_any_existing_binding(self):
        for mode in ('input', 'ref', 'const_ref'):
            for storage in ('fixed', 'dynamic', 'queue'):
                observations = []
                for index in ('same', 'next', 'invalid'):
                    row = ('65', 'logic', 'z', mode, storage, index)
                    r = cases.reference(row, 0, 'z')
                    self.assertEqual(r.pop('selector'),
                                     -1 if index == 'invalid' else
                                     (2 if storage == 'fixed' else 0) + int(index == 'next'))
                    observations.append(r)
                self.assertEqual(observations[0], observations[1])
                self.assertEqual(observations[1], observations[2])

    def test_const_ref_reads_late_caller_updates_without_writing(self):
        row = ('129', 'logic', 'z', 'const_ref', 'dynamic', 'invalid')
        r = cases.reference(row, 0, 'z')
        self.assertEqual(r['seen'], 'z' * 129)
        self.assertEqual(r['formal_after'], 'z' * 129)
        self.assertEqual(r['after_write'][0], 'z' * 129)
        self.assertEqual(r['returning'], '1' * 129)
        self.assertEqual(r['final'][0], '1' * 129)

    def test_input_is_private_while_ref_writes_the_original_element(self):
        base = ('1', 'bit', 'x', 'input', 'queue', 'next')
        by_value = cases.reference(base, 0, 'x')
        by_ref = cases.reference((*base[:3], 'ref', *base[4:]), 0, 'x')
        self.assertEqual((by_value['seen'], by_ref['seen']), ('1', '0'))
        self.assertEqual((by_value['after_write'][0], by_ref['after_write'][0]), ('0', '1'))
        self.assertEqual((by_value['returning'], by_ref['returning']), ('1', '0'))
        self.assertEqual(by_value['final'], by_ref['final'])

    def test_selection_keeps_all_mode_storage_index_triples_and_known_controls(self):
        selected = cases.MODEL.select()
        self.assertEqual({r[3:] for r in selected}, {r[3:] for r in cases.MODEL.rows()})
        for row in selected:
            self.assertEqual(len(cases.phases(row)), 3 if row[2] == 'known' else 6)
            self.assertIn('known', {value for _, _, value in cases.phases(row)})


if __name__ == '__main__':
    unittest.main()
