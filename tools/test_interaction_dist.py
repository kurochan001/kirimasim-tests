"""Distribution support, precedence, narrow overflow and failed state."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_dist as generator
import qualify_dist as qualification


class DistributionSemantics(unittest.TestCase):
    def test_all_rows_match_independent_source_parser_and_domain_enumeration(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_parentheses_change_arithmetic_and_relational_result_types(self):
        base=('4','signed','add_rel','implicit','each','singleton','sat_fail_sat')
        self.assertEqual(generator.expression_value(base,-3),(0,1,False))
        altered=(*base[:3],'altered',*base[4:])
        self.assertEqual(generator.expression_value(altered,-3),(13,4,False))

    def test_failed_unsigned_sentinel_wraps_before_comparison(self):
        row=('4','unsigned','add_rel','implicit','each','singleton','fail_sat_fail')
        self.assertIn('ok=0 x=15 bits=1111 expr=1 expr_bits=1',generator.reference(row))

    def test_failed_signed_sentinel_and_prior_solution_are_retained(self):
        text=generator.reference(generator.MODEL.anchors[0])
        self.assertIn('target phase=0 impossible=1 ok=0 x=-1 bits=1111 expr=0',text)
        self.assertIn('target phase=2 impossible=1 ok=0 x=-3 bits=1101 expr=-4',text)

    def test_wide_unsigned_solution_exceeds_signed_thirty_two_bits(self):
        row=generator.MODEL.anchors[1]
        self.assertEqual(generator.solution(row),4294967297)
        self.assertIn('x=4294967297 bits=100000000000000000000000000000001 expr=4294967299',generator.reference(row))
        self.assertIn('target phase=1 impossible=1 ok=0 x=4294967297',generator.reference(row))

    def test_redundant_parentheses_and_weight_spelling_keep_unique_results(self):
        outputs={generator.reference(('8','signed','add_shift',group,weight,layout,'sat_fail_sat'))
                 for group in ('implicit','whole') for weight in ('each','total')
                 for layout in ('singleton','zero','overlap')}
        self.assertEqual(len(outputs),1)


if __name__=='__main__':unittest.main()
