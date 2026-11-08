"""Delay values: literals, rounding to the precision, unknown and negative delays."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_delayval as g
import qualify_delayval as q


class DelayValueForm(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 222)
        self.assertEqual(len(selected), 60)
        self.assertEqual(len(g.MODEL.universe()), 126)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in ('source', 'reference', 'rounded')]
        patches += [patch.object(g, 'VALUES', {}), patch.object(g, 'START', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('endmodule', '  // timeprecision 1ns;\nendmodule')), case.expected)

    def test_rounding_follows_the_precision(self):
        self.assertEqual(q.independent(('real_down', 'stmt', 'zero', 'unit')), '2.0 stmt\n50.0 end a=0\n')
        self.assertEqual(q.independent(('real_down', 'stmt', 'zero', 'tenth')), '2.4 stmt\n50.0 end a=0\n')
        self.assertEqual(q.independent(('time_fine', 'repeat', 'later', 'unit')), '13.0 repeat\n16.0 repeat\n50.0 end a=0\n')
        self.assertEqual(q.independent(('real_up', 'repeat', 'zero', 'tenth')), '2.6 repeat\n5.2 repeat\n50.0 end a=0\n')

    def test_unknown_bits_wait_zero_and_a_negative_delay_never_ends(self):
        self.assertEqual(q.independent(('xpart', 'nba', 'later', 'unit')), '10.0 nba a=7\n50.0 end a=7\n')
        self.assertEqual(q.independent(('z', 'repeat', 'zero', 'tenth')), '0.0 repeat\n0.0 repeat\n50.0 end a=0\n')
        self.assertEqual(q.independent(('neg', 'blocking', 'zero', 'unit')), '50.0 end a=0\n')

    def test_rounding_ties_and_unknown_forms_are_rejected(self):
        source = g.source(('real_down', 'stmt', 'zero', 'unit'))
        for bad in (source.replace('#2.4', '#2.5'), source.replace('#2.4', "#'h4"), source.replace('#2.4', '#2.4us2'),
                    source.replace('timeprecision 1ns;', 'timeprecision 10ns;')):
            with self.assertRaises((AssertionError, KeyError, TypeError)): q.interpret(bad)

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
