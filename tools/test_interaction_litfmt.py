"""Literal formatting: digits of unknown bits, automatic and given widths, and what carries a literal."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_litfmt as g
import qualify_litfmt as q


def shown(row): return q.independent(row)[1:-2]


class LiteralFormatDisplay(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 1778)
        self.assertEqual(len(selected), 91)
        self.assertEqual(len(g.MODEL.universe()), 301)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'formatted', 'value_type', 'digits', 'decimal')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches.append(patch.object(g, 'LITERALS', {}))
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// $display(":%h:", 12\'h005);\n'), case.expected)

    def test_unknown_digits_by_group(self):
        # 12'hx5 pads with x on the left; 9'o7x5 has one unknown octal digit.
        self.assertEqual(shown(('xpad', 'h', 'display', 'direct')), 'xx5')
        self.assertEqual(shown(('xpad', 'o', 'display', 'direct')), 'xxX5')
        self.assertEqual(shown(('octal', 'h', 'display', 'direct')), '1XX')
        self.assertEqual(shown(('qmark', 'b', 'display', 'direct')), '0z0z10z1')
        self.assertEqual(shown(('zpad', 'd', 'display', 'direct')), '   Z')
        self.assertEqual(shown(('octal', 'd', 'display', 'direct')), '  X')

    def test_field_widths(self):
        self.assertEqual(shown(('sized', 'd', 'display', 'direct')), '200')
        self.assertEqual(shown(('sized', 'wd', 'display', 'direct')), '     200')
        self.assertEqual(shown(('sized', 'wh', 'display', 'direct')), '000000c8')
        self.assertEqual(shown(('xpad', 'wh', 'display', 'direct')), '00000xx5')
        self.assertEqual(shown(('under', '0h', 'display', 'direct')), 'abcd')
        self.assertEqual(shown(('unsized', '0d', 'display', 'direct')), '13')
        self.assertEqual(shown(('fill', 'b', 'display', 'direct')), '1')

    def test_sign_and_negation(self):
        self.assertEqual(shown(('negate', 'd', 'display', 'direct')), '251')
        self.assertEqual(shown(('signed', '0d', 'display', 'direct')), '-1')
        self.assertEqual(shown(('signed', 'wd', 'display', 'param')), '      -1')
        self.assertEqual(shown(('signed', '0d', 'display', 'concat')), '15')

    def test_a_string_literal_without_a_format_is_text(self):
        self.assertEqual(shown(('string', 'd', 'default', 'direct')), 'AA')
        self.assertEqual(shown(('string', 'd', 'default', 'macro')), 'AA')
        # A parameter is a logic vector of the literal's width (6.20.2), so it is a number.
        self.assertEqual(shown(('string', 'd', 'default', 'param')), '16705')
        self.assertEqual(shown(('string', 'h', 'default', 'concat')), '4141')
        self.assertEqual(shown(('string', 's', 'display', 'param')), 'AA')

    def test_the_route_does_not_change_the_text(self):
        for row in g.MODEL.select():
            if row[2] == 'default': continue
            for route in ('display', 'write', 'sformatf', 'swrite', 'fdisplay'):
                self.assertEqual(q.independent((row[0], row[1], route, row[3])), g.reference(row), (row, route))

    def test_unsized_and_signed_full_decimal_widths_are_excluded(self):
        for row in g.MODEL.rows():
            literal, form, _, carrier = row
            self.assertFalse(literal == 'unsized' and form in ('d', 'h', 'o', 'b'), row)
            self.assertFalse(literal in ('signed', 'unsized') and form == 'd' and carrier != 'concat', row)

    def test_nine_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 9)
        self.assertEqual(len(programs), 18)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('xpad', 'wh', 'display', 'direct'))
        for bad in (source.replace('$display(', '$monitor('),
                    source.replace("12'hx5", "12'hx5 + 1"),
                    source.replace('%8h', '%8t'),
                    g.source(('unsized', '0d', 'display', 'direct')).replace('%0d', '%d')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
