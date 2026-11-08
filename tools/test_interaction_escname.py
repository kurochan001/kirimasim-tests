"""Escaped identifiers: the backslash and the ending white space are not part of the name."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_escname as g
import qualify_escname as q


class EscapedNameBinding(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 126)
        self.assertEqual(len(selected), 29)
        self.assertEqual(len(g.MODEL.universe()), 100)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_no_line_keeps_trailing_white_space(self):
        for row in g.MODEL.rows():
            for line in g.source(row).split('\n'): self.assertEqual(line, line.rstrip(), row)

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in ('source', 'reference', 'names')]
        patches += [patch.object(g, 'ITEMS', {}), patch.object(g, 'GAPS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('    #1;', '    #1; // \\ec_u+1 .ec_v')), case.expected)

    def test_an_escaped_plain_name_is_the_plain_name(self):
        for item in g.ITEMS:
            for spelling, ref in (('plain', 'swapped'), ('escaped', 'swapped'), ('escaped', 'same')):
                row = (item, spelling, ref, 'space')
                with self.subTest(row=row): self.assertEqual(q.independent(row), 'y=15\nv=3\ntask 5\ng=6\n')

    def test_the_lexer_ends_an_escaped_name_only_at_white_space(self):
        self.assertEqual(q.lex('\\ec_v+1\t)'), [('name', 'ec_v+1'), ('punct', ')')])
        self.assertEqual(q.lex('\\begin\n  .g'), [('name', 'begin'), ('punct', '.'), ('name', 'g')])
        self.assertEqual(q.lex('ec_v+1'), [('name', 'ec_v'), ('punct', '+'), ('number', '1')])

    def test_wrong_names_are_rejected(self):
        source = g.source(('var', 'special', 'same', 'space'))
        for bad in (source.replace('ec_u.\\ec_v+1 ', 'ec_u.\\ec_w+1 '), source.replace('.EC_P(5)', '.EC_Q(5)'),
                    source.replace('.ec_in(x)', '.\\ec_in+1 (x)'), source.replace('ec_u.ec_t(2)', 'ec_v.ec_t(2)')):
            with self.assertRaises((AssertionError, KeyError)): q.interpret(bad)

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
