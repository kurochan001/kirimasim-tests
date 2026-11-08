"""Case items with ?, z and x digits: the literal pads by 5.7.1, and each kind of case compares it its own way."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_casedigit as g
import qualify_casedigit as q


class CaseLiteralWildcard(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 312)
        self.assertEqual(len(selected), 24)
        self.assertEqual(len(g.MODEL.universe()), 136)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        patches = [patch.object(g, name, side_effect=AssertionError(name))
                   for name in ('source', 'reference', 'literal', 'item_bits', 'selectors', 'matches')]
        patches += [patch.object(g, 'DIGITS', {}), patch.object(g, 'BITS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('  initial begin', '  // casex (s)\n  initial begin')),
                         case.expected)

    def test_literal_padding_and_digit_widths(self):
        self.assertEqual(q.number("12'b?1?0"), 'zzzzzzzzz1z0')
        self.assertEqual(q.number("12'b1?0?"), '000000001z0z')
        self.assertEqual(q.number("6'oz5"), 'zzz101')
        self.assertEqual(q.number("8'h5x"), '0101xxxx')
        self.assertEqual(q.number("6'dx"), 'xxxxxx')
        self.assertEqual(len(q.number("'bz1z0")), 32)

    def test_the_case_extends_a_narrow_item_with_zeros(self):
        # 6'bz1z0 pads with z to six bits; the case then adds zeros above them.
        self.assertTrue(q.compare('casez', '00110110', q.number("6'bz1z0")))
        self.assertFalse(q.compare('casez', '10110110', q.number("6'bz1z0")))

    def test_case_inside_is_asymmetric(self):
        self.assertTrue(q.compare('inside', '1011z110', '1011x110'))
        self.assertFalse(q.compare('inside', '1011z110', '10110110'))
        self.assertTrue(q.compare('casez', '1011z110', '10110110'))
        self.assertFalse(q.compare('casez', '1011x110', '10110110'))
        self.assertTrue(q.compare('casex', '1011x110', '10110110'))

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
