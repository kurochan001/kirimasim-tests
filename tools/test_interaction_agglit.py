"""Structure literals: positions, member names, replication, type keys and default set each member through its type."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_agglit as g
import qualify_agglit as q


class AggregateLiteralKey(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 192)
        self.assertEqual(len(selected), 48)
        self.assertEqual(len(g.MODEL.universe()), 104)
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
                   for name in ('source', 'reference', 'members', 'pattern', 'layout')]
        patches += [patch.object(g, 'VALUES', {}), patch.object(g, 'KEYS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('  initial show(C);', "  // C = '{default: 0};\n  initial show(C);")),
                         case.expected)

    def test_int_does_not_match_integer(self):
        self.assertEqual(q.independent(('type_default', 'neg', 'assign')), 'a=1001 i=-2 l=1001 b=9 g=9 q=-2,-2\n')

    def test_default_descends_into_the_nested_structure_and_array(self):
        self.assertEqual(q.independent(('default', 'real', 'init')), 'a=0011 i=3 l=0011 b=3 g=3 q=3,3\n')
        self.assertEqual(q.independent(('default', 'fillx', 'typed')), 'a=xxxx i=0 l=xxxx b=0 g=x q=0,0\n')

    def test_member_name_then_last_type_key_then_default(self):
        self.assertEqual(q.independent(('member_type', 'wide', 'init')), 'a=0101 i=7 l=1001 b=7 g=7 q=7,7\n')
        self.assertEqual(q.independent(('last_type', 'snarrow', 'param')), 'a=0111 i=-3 l=0111 b=7 g=7 q=-3,-3\n')

    def test_a_member_left_uncovered_is_an_error(self):
        source = g.source(('type', 'neg', 'assign'))
        with self.assertRaises(AssertionError): q.interpret(source.replace(', integer: 11', ''))

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
