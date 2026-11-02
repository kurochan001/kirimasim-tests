"""Checker identity, argument forms and sampled/current action observations."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_checksample as generator
import qualify_checksample as qualification


class CheckerAssertionSampling(unittest.TestCase):
    def test_all_rows_match_independent_binding_and_region_interpretation(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_scalar_edge_nba_retains_old_sample_and_reads_new_live_value(self):
        text = generator.reference(generator.MODEL.anchors[0])
        self.assertIn('site0 checker pass=0 fail=1 pred=0 sampled=0 live=1 at=8',text)
        self.assertIn('site0 module pass=0 fail=1 pred=0 sampled=0 live=1 at=8',text)

    def test_complementary_instances_have_distinct_samples_results_and_action_times(self):
        text = generator.reference(generator.MODEL.anchors[0])
        self.assertIn('site1 checker pass=1 fail=0 pred=1 sampled=1 live=0 at=12',text)
        self.assertIn('site1 module pass=1 fail=0 pred=1 sampled=1 live=0 at=12',text)

    def test_wide_parity_and_high_bit_are_observed_without_truncation(self):
        row = generator.MODEL.anchors[3]
        text = generator.reference(row)
        self.assertIn('pred=0 sampled='+33*'0'+' live='+33*'1'+' at=8',text)
        self.assertIn('pred=1 sampled='+('1'+32*'0')+' live='+('0'*32+'1')+' at=68',text)

    def test_connection_home_and_clocking_spellings_preserve_semantics(self):
        base = generator.MODEL.anchors[1]
        expected = generator.reference(base)
        for home in ('module','interface'):
            for connection in ('positional','named','wildcard'):
                for clocking in ('explicit','default'):
                    row=(base[0],home,connection,*base[3:6],clocking,base[7])
                    self.assertEqual(qualification.independent(row),expected)

    def test_independent_parser_exposes_using_live_data_instead_of_sampled_data(self):
        row=generator.MODEL.anchors[3]
        source=generator.make_case(row).body
        changed=source.replace('v_seen = $sampled(data);','v_seen = data;')
        self.assertNotEqual(qualification.interpret(changed),generator.reference(row))


if __name__=='__main__':unittest.main()
