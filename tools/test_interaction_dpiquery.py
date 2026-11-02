"""Dimension numbering, normalized packed ranges and per-call descriptor refresh."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_dpiquery as generator
import qualify_dpiquery as qualification


class SvDpiArrayQueries(unittest.TestCase):
    def test_all_rows_match_independent_declaration_and_query_interpretation(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_sv_counts_packed_dimension_while_c_numbers_it_zero(self):
        text = generator.reference(generator.MODEL.anchors[1])
        self.assertIn('sv phase=0 dims=4 unpacked=3',text)
        self.assertIn('sv dim=4 left=3 right=0 low=0 high=3 increment=1 size=4',text)
        self.assertIn('c phase=0 dims=3\nc dim=0 left=3 right=0',text)

    def test_offset_packed_range_is_normalized_without_changing_unpacked_ranges(self):
        text = generator.reference(generator.MODEL.anchors[6])
        self.assertIn('sv dim=4 left=36 right=4 low=4 high=36 increment=1 size=33',text)
        self.assertIn('c dim=0 left=32 right=0 low=0 high=32 increment=1 size=33',text)
        self.assertIn('c dim=1 left=-7 right=-6 low=-7 high=-6 increment=-1 size=2',text)

    def test_singletons_have_positive_increment_even_in_ascending_rows(self):
        row = ('2','up','neg','one','4','sized','offset','switch','literal')
        text = generator.reference(row)
        self.assertIn('sv dim=1 left=-7 right=-7 low=-7 high=-7 increment=1 size=1',text)
        self.assertIn('c dim=2 left=10 right=10 low=10 high=10 increment=1 size=1',text)

    def test_switch_refreshes_open_packed_width_and_each_unpacked_dimension(self):
        text = generator.reference(generator.MODEL.anchors[3])
        second = text.split('c phase=1')[1]
        self.assertIn('c dim=0 left=3 right=0 low=0 high=3 increment=1 size=4',second)
        self.assertIn('c dim=1 left=7 right=9 low=7 high=9 increment=-1 size=3',second)
        self.assertIn('c dim=3 left=13 right=17 low=13 high=17 increment=-1 size=5',second)

    def test_query_spellings_agree_and_parser_detects_a_wrong_packed_dimension(self):
        row = generator.MODEL.anchors[0]
        variable = (*row[:-1],'variable')
        self.assertEqual(generator.reference(row),generator.reference(variable))
        source = generator.make_case(row).body
        changed = source.replace('$size(data_a, 2)','$size(data_a, 1)')
        self.assertNotEqual(qualification.interpret(changed)[0],generator.reference(row))


if __name__ == '__main__':unittest.main()
