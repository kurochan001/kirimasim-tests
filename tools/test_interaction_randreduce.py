"""Narrow overflow, pre-reduction extension and failed-state retention."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_randreduce as g
import qualify_randreduce as q


class ReductionConstraintTests(unittest.TestCase):
    def test_literal_unsigned_trace(self):
        self.assertEqual(g.reference(g.MODEL.anchors[0]), '''target phase=0 impossible=0 ok=1 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
guard phase=0 impossible=0 ok=1 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
target phase=1 impossible=1 ok=0 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
guard phase=1 impossible=0 ok=1 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
target phase=2 impossible=0 ok=1 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
guard phase=2 impossible=0 ok=1 size=2
values=1111,0011
natural=2 wide=18 natural_bits=4 wide_bits=64
''')

    def test_failed_dynamic_shape_and_sentinel_retention(self):
        text = g.reference(g.MODEL.anchors[1])
        self.assertTrue(text.startswith('target phase=0 impossible=1 ok=0 size=4\n'))
        self.assertIn('natural=16 wide=16 natural_bits=33 wide_bits=64', text)
        self.assertIn('target phase=1 impossible=0 ok=1 size=3', text)
        self.assertIn('target phase=2 impossible=1 ok=0 size=3', text)
        self.assertIn('natural=8589934583 wide=77309411319', text)

    def test_signed_extension_precedes_wide_product(self):
        row = ('4', 'signed', 'fixed', 'product', 'wide', '2', 'fail_sat_fail')
        self.assertEqual(g.reductions(row, [-8, -3]), (-8, 24))
        self.assertEqual(q.folded([-8, -3], 64, True, 'product'), 24)
        self.assertEqual(q.folded([8, 13], 64, True, 'product'), 104)

    def test_all_independent_traces_and_widths(self):
        for row in g.MODEL.rows():
            self.assertEqual(q.independent(row), g.reference(row), row)
            natural, wide = g.reductions(row, g.solution(row))
            self.assertNotEqual(natural, wide)
            self.assertLess(abs(wide), 1 << 63)


if __name__ == '__main__':
    unittest.main()
