"""Literal arguments: assignment conversion at formals, defaults and returns, and escaped names."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_litarg as g
import qualify_litarg as q


def shown(row): return q.independent(row).strip()


class LiteralArgumentConversion(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 472)
        self.assertEqual(len(selected), 62)
        self.assertEqual(len(g.MODEL.universe()), 169)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'converted', 'shown')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'LITERALS', {}), patch.object(g, 'FORMALS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// show(1'b1);\n"), case.expected)

    def test_the_passing_and_the_name_do_not_change_the_result(self):
        for row in g.MODEL.select():
            for passing in ('positional', 'named', 'default', 'return'):
                for name in ('plain', 'escaped'):
                    self.assertEqual(q.independent((row[0], row[1], passing, name)), g.reference(row), row)

    def test_a_fill_takes_the_width_of_the_formal(self):
        self.assertEqual(shown(('fill1', 'bit8', 'positional', 'plain')), '255 ff')
        self.assertEqual(shown(('fill1', 'int', 'positional', 'plain')), '-1 ffffffff')
        self.assertEqual(shown(('fillx', 'logic12', 'positional', 'plain')), 'x xxx')
        self.assertEqual(shown(('fillx', 'int', 'positional', 'plain')), '0 00000000')

    def test_the_sign_of_the_literal_extends_it(self):
        self.assertEqual(shown(('signed', 'logic12', 'positional', 'plain')), '4090 ffa')
        self.assertEqual(shown(('unsigned', 'slogic12', 'positional', 'plain')), '10 00a')
        self.assertEqual(shown(('neg', 'bit8', 'positional', 'plain')), '253 fd')
        self.assertEqual(shown(('based', 'byte', 'positional', 'plain')), '-1 ff')

    def test_a_real_rounds_half_away_from_zero(self):
        self.assertEqual(shown(('real', 'int', 'positional', 'plain')), '3 00000003')
        self.assertEqual(shown(('negreal', 'byte', 'positional', 'plain')), '-3 fd')
        self.assertEqual(shown(('exp', 'bit8', 'positional', 'plain')), '15 0f')

    def test_a_string_literal_is_a_number_of_characters(self):
        self.assertEqual(shown(('string', 'logic12', 'positional', 'plain')), '322 142')
        self.assertEqual(shown(('string', 'int', 'positional', 'plain')), '16706 00004142')
        self.assertEqual(shown(('string', 'real', 'positional', 'plain')), '16706.00')
        self.assertEqual(shown(('string', 'string', 'positional', 'plain')), 'AB 2')

    def test_eight_controls_and_eight_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 8)
        self.assertEqual(len(programs), 16)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('string', 'logic12', 'positional', 'escaped'))
        for bad in (source.replace('\\show+v ("AB")', '\\show+w ("AB")'),
                    source.replace('input logic [11:0]', 'input shortreal'),
                    source.replace('("AB")', '(1.5x)')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
