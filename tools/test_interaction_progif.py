"""Program and module writes to an interface variable: the region set of the write, of the interface subroutine and of the design reaction."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_progif as g
import qualify_progif as q


class ProgramInterfaceRegions(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_every_row_is_legal(self):
        self.assertEqual(len(g.MODEL.rows()), 2 * 3 * 5 * 2 * 4 * 2)

    def test_pair_group_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 30)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(q.interpret(g.source(row)), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'reacts_before_zero_delay', 'interface_lines', 'design_lines',
                 'caller_lines', 'hexbyte', 'legal')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, constant, -1) for constant in ('CALL_TIME', 'OLD', 'NEW')]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('interface bus_if;', '// module driver;\ninterface bus_if;')),
                         case.expected)

    def test_the_program_and_module_differ_only_by_region_set(self):
        # The same task call: from a program the reaction waits for the reactive
        # region set (24.3.1, 24.5); from a module it runs before the #0 resumes.
        program = q.interpret(g.source(('program', 'port', 'task', 'blocking', 'always', 'interface')))
        module = q.interpret(g.source(('module', 'port', 'task', 'blocking', 'always', 'interface')))
        self.assertIn('b1=12 ', program)
        self.assertIn('ph=2 ', program)
        self.assertIn('b1=5b ', module)
        self.assertIn('ph=1 ', module)

    def test_the_last_program_thread_ending_makes_the_implicit_finish(self):
        # 24.3: the program caller has no $finish, and the observer loops forever.
        source = g.source(('program', 'hier', 'direct', 'blocking', 'always', 'interface'))
        self.assertNotIn('$finish', source)
        self.assertEqual(q.interpret(source), g.reference(('program', 'hier', 'direct', 'blocking', 'always',
                                                           'interface')))

    def test_a_read_that_races_with_the_reaction_is_rejected(self):
        # 4.7: right after a module write, the reaction may or may not have run.
        source = g.source(('module', 'port', 'task', 'blocking', 'always', 'interface'))
        source = source.replace('    a0 = i.x;\n', '    a0 = i.x;\n    b0 = i.y;\n')
        source = source.replace('a0=%h a1', 'a0=%h b0=%h a1').replace('a0, a1, b1', 'a0, b0, a1, b1')
        with self.assertRaises(AssertionError): q.interpret(source)

    def test_a_modport_allows_only_what_it_lists(self):
        source = g.source(('module', 'modport', 'direct', 'nba', 'always', 'module'))
        with self.assertRaises(AssertionError):
            q.interpret(source.replace('output x, phase, input y', 'output x, input phase, y'))

    def test_a_procedural_write_to_a_net_is_rejected(self):
        source = g.source(('program', 'port', 'direct', 'blocking', 'assign', 'interface'))
        with self.assertRaises(AssertionError):
            q.interpret(source.replace("assign y = x + 8'd1;", "always @(x) y = x + 8'd1;"))

    def test_six_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 15)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
