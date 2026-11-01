"""Literal allocation traces and wide signed boundary checks."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_assocquery as g
import qualify_assocquery as q


class AssociativeQueryTests(unittest.TestCase):
    def test_literal_lifecycle(self):
        self.assertEqual(g.reference(g.MODEL.anchors[0]), '''dimensions=2 unpacked=1
empty left=0 right=15 increment=-1 size=0 num=0 method_size=0
bounds=empty first_ok=0 last_ok=0
insert1 left=0 right=15 increment=-1 size=1 num=1 method_size=1
low=1 high=1 first_ok=1 first=1 last_ok=1 last=1
entry key=1 value=11
insert2 left=0 right=15 increment=-1 size=2 num=2 method_size=2
low=1 high=3 first_ok=1 first=1 last_ok=1 last=3
entry key=1 value=11
entry key=3 value=22
insert3 left=0 right=15 increment=-1 size=3 num=3 method_size=3
low=1 high=6 first_ok=1 first=1 last_ok=1 last=6
entry key=1 value=11
entry key=3 value=22
entry key=6 value=33
overwrite left=0 right=15 increment=-1 size=3 num=3 method_size=3
low=1 high=6 first_ok=1 first=1 last_ok=1 last=6
entry key=1 value=11
entry key=3 value=29
entry key=6 value=33
delete left=0 right=15 increment=-1 size=2 num=2 method_size=2
low=3 high=6 first_ok=1 first=3 last_ok=1 last=6
entry key=3 value=29
entry key=6 value=33
delete_missing left=0 right=15 increment=-1 size=2 num=2 method_size=2
low=3 high=6 first_ok=1 first=3 last_ok=1 last=6
entry key=3 value=29
entry key=6 value=33
reinsert left=0 right=15 increment=-1 size=3 num=3 method_size=3
low=1 high=6 first_ok=1 first=1 last_ok=1 last=6
entry key=1 value=47
entry key=3 value=29
entry key=6 value=33
clear left=0 right=15 increment=-1 size=0 num=0 method_size=0
bounds=empty first_ok=0 last_ok=0
reuse left=0 right=15 increment=-1 size=1 num=1 method_size=1
low=0 high=0 first_ok=1 first=0 last_ok=1 last=0
entry key=0 value=91
''')

    def test_wide_signed_query_conversion_preserves_full_method_keys(self):
        row = ('33', 'signed', 'extreme', 'ascending', 'middle', 'explicit')
        output = g.reference(row)
        self.assertIn('right=-1 increment=-1', output)
        self.assertIn('low=0 high=-1 first_ok=1 first=-4294967296 last_ok=1 last=4294967295', output)
        self.assertIn('entry key=-1 value=29', output)

    def test_insertion_order_and_dimension_controls(self):
        row = list(g.MODEL.anchors[1])
        final = g.reference(tuple(row)).split('insert3', 1)[1]
        for order in ('ascending', 'descending', 'zigzag'):
            for dimension in ('implicit', 'explicit'):
                row[3], row[5] = order, dimension
                self.assertEqual(g.reference(tuple(row)).split('insert3', 1)[1], final)

    def test_independent_rows_and_reference_faults(self):
        results = q.qualify()
        self.assertEqual(set(results), set(q.FAULTS))
        self.assertEqual(results['unsigned_order']['different_legal_rows'], 108)
        self.assertTrue(all(result['different_selected_rows'] for result in results.values()))


if __name__ == '__main__':
    unittest.main()
