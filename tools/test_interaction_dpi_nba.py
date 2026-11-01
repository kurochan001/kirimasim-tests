"""Hand-calculated boundary cases for DPI conversion and NBA capture."""

import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_dpi_nba as dpi


class DpiNbaSemantics(unittest.TestCase):
    def test_narrow_signedness_and_wide_truncation_at_the_int_boundary(self):
        self.assertEqual(dpi.as_int(0xea, 8, False), 234)
        self.assertEqual(dpi.as_int(0xea, 8, True), -22)
        self.assertEqual(dpi.as_int((1 << 64) | 9, 65, False), 9)
        self.assertEqual(dpi.as_int((1 << 64) | 9, 65, True), 9)
        self.assertEqual(dpi.as_int(0x80000009, 32, True), -2147483639)

    def test_copy_in_preserves_the_actual_and_nba_uses_its_original_bits(self):
        row = ('input', 'nba_first', 'same', '8', 'signed', 'logic')
        self.assertEqual(dpi.reference(row),
                         'return=-22\nafter_call 15 ea 89\nmutated 15 2b 89\n'
                         'indices=0,0 payload=ff\npostponed 15 69 89\nsettled 15 69 89\n')

    def test_inout_on_another_element_changes_the_rhs_only_when_called_first(self):
        row = ('inout', 'dpi_first', 'other', '8', 'unsigned', 'bit')
        self.assertEqual(dpi.reference(row),
                         'return=137\nafter_call 15 ea 40\nmutated 15 ea 2b\n'
                         'indices=0,0 payload=ff\npostponed 15 c3 2b\nsettled 15 c3 2b\n')
        before = ('inout', 'nba_first', 'other', '8', 'unsigned', 'bit')
        self.assertIn('postponed 15 0a 2b\n', dpi.reference(before))

    def test_negative_int_copyback_sign_extends_to_a_wide_unsigned_actual(self):
        row = ('output', 'dpi_first', 'same', '65', 'unsigned', 'logic')
        self.assertEqual(dpi.reference(row),
                         'return=53\n'
                         'after_call 00000000000000015 1ffffffffffffffc3 10000000000000009\n'
                         'mutated 00000000000000015 0000000000000002b 10000000000000009\n'
                         'indices=0,0 payload=1ffffffffffffffff\n'
                         'postponed 00000000000000015 0ffffffffffffffc0 10000000000000009\n'
                         'settled 00000000000000015 0ffffffffffffffc0 10000000000000009\n')


if __name__ == '__main__':
    unittest.main()
