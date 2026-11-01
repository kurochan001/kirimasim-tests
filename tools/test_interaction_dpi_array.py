"""Concrete DPI open-array range, output and repeated-call observations."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_dpi_array as array


class DpiArraySemantics(unittest.TestCase):
    def test_single_output_never_uses_initial_values(self):
        row = ('ascending', 'output', '1', 'mixed', 'descending', 'stable')
        self.assertEqual(array.reference(row),
            'call phase=0 size=1\nbefore[-2]=11\n'
            'c phase=0 dims=1 left=-2 right=-2 low=-2 high=-2 inc=1 size=1\n'
            'c index=-2 before=0 after=-106\nreturned=-106\n'
            'after[-2]=-106\nguard=31,-47,83\n'
            'call phase=1 size=1\nbefore[-2]=-24\n'
            'c phase=1 dims=1 left=-2 right=-2 low=-2 high=-2 inc=1 size=1\n'
            'c index=-2 before=0 after=-206\nreturned=-206\n'
            'after[-2]=-206\nguard=31,-47,83\n')

    def test_descending_actual_retains_sv_indices_and_signed_input(self):
        text = array.reference(('descending', 'inout', '3', 'mixed', 'ascending', 'stable'))
        self.assertIn('left=5 right=3 low=3 high=5 inc=1 size=3\n', text)
        self.assertIn('before[5]=25\nbefore[4]=-18\nbefore[3]=11\n', text)
        self.assertIn('c index=3 before=11 after=114\n', text)
        self.assertIn('after[5]=130\nafter[4]=86\nafter[3]=114\n', text)

    def test_resizing_refreshes_the_second_call_extent(self):
        for actual in ('dynamic', 'queue'):
            row = (actual, 'input', '5', 'positive', 'descending', 'resize')
            text = array.reference(row)
            self.assertIn('call phase=1 size=2\nbefore[0]=24\nbefore[1]=31\n', text)
            self.assertIn('c phase=1 dims=1 left=0 right=1 low=0 high=1 inc=-1 size=2\n', text)
            self.assertIn('c index=1 before=31 after=31\nc index=0 before=24 after=24\nreturned=79\n', text)

    def test_legal_domain_excludes_prohibited_output_and_meaningless_resize(self):
        self.assertEqual(len(array.MODEL.rows()), 168)
        self.assertEqual(len(array.MODEL.select()), 30)
        for row in array.MODEL.rows():
            self.assertFalse(row[0] in ('dynamic', 'queue') and row[1] == 'output')
            self.assertFalse(row[0] in ('ascending', 'descending') and row[5] == 'resize')
        self.assertFalse(array.legal(('dynamic', 'output', '1', 'mixed', 'ascending', 'stable')))
        self.assertFalse(array.legal(('descending', 'input', '3', 'positive', 'ascending', 'resize')))


if __name__ == '__main__':
    unittest.main()
