"""%m prints the name of the scope that holds the display, not the name of the caller."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_hiername as g
import qualify_hiername as q


class HierarchicalNameDisplay(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 177)
        self.assertEqual(len(selected), 65)
        self.assertEqual(len(g.MODEL.universe()), 170)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'instance', 'scope_lines', 'process_lines', 'case_name')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'SCOPES', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// if (1) begin : genblk2 end\n'), case.expected)

    def test_a_subroutine_prints_where_it_is_declared(self):
        row = ('nested', 'task', 'down', 'initial')
        top = g.case_name(row)
        self.assertEqual(q.independent(row), f'from {top}\nin {top}.w.v.t\n')
        row = ('array', 'auto', 'up', 'initial')
        top = g.case_name(row)
        self.assertEqual(q.independent(row), f'from {top}.u[1].h\nin {top}.u[1].t\n')

    def test_an_unnamed_generate_block_counts_the_constructs_before_it(self):
        row = ('unnamedgen', 'module', 'own', 'final')
        top = g.case_name(row)
        self.assertEqual(q.independent(row), f'from {top}.genblk2.u\nin {top}.genblk2.u\n')

    def test_labels_name_a_block(self):
        row = ('loopgen', 'label', 'own', 'initial')
        top = g.case_name(row)
        self.assertEqual(q.independent(row), f'from {top}.g[1].u\nin {top}.g[1].u.lb\n')
        row = ('top', 'loop', 'own', 'final')
        top = g.case_name(row)
        self.assertEqual(q.independent(row), f'from {top}\nin {top}.lp\n')

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_names_and_forms_are_rejected(self):
        source = g.source(('inst', 'task', 'down', 'initial'))
        for bad in (source.replace('    u.t;', '    v.t;'), source.replace('    u.t;', '    u.s;'),
                    source.replace('$display("in %m");', '$display("in %l");'),
                    source.replace('hn_child u ();', 'hn_child u ();\n  hn_child u ();')):
            with self.assertRaises((AssertionError, KeyError, IndexError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
