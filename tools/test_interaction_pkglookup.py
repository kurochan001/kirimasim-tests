"""Package lookup: the search of 26.3 binds a name in a loop to a package, a declaration or another import."""

from itertools import product
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_pkglookup as g
import qualify_pkglookup as q


class PackageNameLookup(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 148)
        self.assertEqual(len(selected), 37)
        self.assertEqual(len(g.MODEL.universe()), 125)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_excluded_descriptions_are_errors_for_the_interpretation(self):
        rows = [row for row in product(*(values for _, values in g.MODEL.factors)) if not g.legal(row)
                and not (row[1] == 'inner_decl' and row[2] == 'call')]
        self.assertEqual(len(rows), 28)
        for row in rows:
            with self.subTest(row=row), self.assertRaises(AssertionError): q.independent(row)

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in ('source', 'reference', 'bound')]
        patches += [patch.object(g, 'VALUE', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('  int n = 5;', '  // import lk_q::*;\n  int n = 5;')), case.expected)

    def test_an_inner_wildcard_import_wins_over_an_outer_declaration(self):
        self.assertEqual(q.independent(('block_wild', 'outer_decl', 'var', 'while')), 'value=3 count=3\n')
        self.assertEqual(q.independent(('module_wild', 'outer_decl', 'var', 'while')), 'value=5 count=5\n')
        self.assertEqual(q.independent(('explicit', 'inner_import', 'call', 'do')), 'value=40 count=40\n')

    def test_a_call_sees_later_declarations_and_ignores_later_imports(self):
        self.assertEqual(q.independent(('module_wild', 'later_decl', 'call', 'for')), 'value=70 count=70\n')
        self.assertEqual(q.independent(('block_wild', 'later_decl', 'call', 'for')), 'value=30 count=30\n')
        self.assertEqual(q.independent(('module_wild', 'later_import', 'var', 'repeat')), 'value=3 count=3\n')

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
