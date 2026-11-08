"""Classes declared in a module or a generate block: a method binds the names of its declaring scope."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_scopeclass as g
import qualify_scopeclass as q


class ScopedClassDeclaration(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 240)
        self.assertEqual(len(selected), 48)
        self.assertEqual(len(g.MODEL.universe()), 148)
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
                   for name in ('source', 'reference', 'targets', 'scope_items')]
        patches += [patch.object(g, 'OFFSET', {}), patch.object(g, 'TOP_DECOYS', ())]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('    #5;', '    #5; // u1.g[0].v = 0;')), case.expected)

    def test_only_the_taken_branch_of_a_conditional_generate_exists(self):
        self.assertEqual(q.independent(('gen_if', 'local', 'local', 'instance', 'none')), 'P1 3 3\nP2 56 56\n')
        self.assertEqual(q.independent(('gen_case', 'function', 'hier', 'instance', 'none')), 'P1 41 41\nP2 102 102\n')

    def test_the_nearest_declaration_wins(self):
        self.assertEqual(q.independent(('gen_for', 'variable', 'local', 'instance', 'outer')),
                         'P1.0 10 110\nP1.1 17 117\nP2.0 20 120\nP2.1 27 127\n')
        self.assertEqual(q.independent(('module', 'variable', 'hier', 'instance', 'property')), 'P1 900 900\nP2 900 900\n')
        self.assertEqual(q.independent(('module', 'param', 'hier', 'derived', 'outer')), 'P1 1001 1001\nP2 1002 1002\n')

    def test_a_name_outside_the_class_scopes_is_not_found(self):
        source = g.source(('module', 'local', 'local', 'instance', 'none'))
        with self.assertRaises(KeyError): q.interpret(source.replace('return L;', 'return M;'))

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
