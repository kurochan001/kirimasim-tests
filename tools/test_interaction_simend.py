"""$finish, $fatal and $exit from process contexts: the run ends at the call, and later events and terminators never run."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_simend as g
import qualify_simend as q


class SimulationEndSources(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_rows_exclude_program_always_and_module_exit(self):
        rows = g.MODEL.rows()
        self.assertEqual(len(rows), 288)
        self.assertFalse(any(r[1] == 'always' and r[3] == 'program' for r in rows))
        self.assertFalse(any(r[0] == 'exit' and r[3] != 'program' for r in rows))

    def test_pair_group_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 42)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):
                source = g.source(row)
                self.assertEqual(q.interpret(source), g.reference(row))
                self.assertEqual(q.exit_code(source), g.exit_status(row))
                self.assertEqual(g.make_case(row).extra['expected_exit'], g.exit_status(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'call', 'caller_lines', 'ends_at', 'exit_status', 'legal')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, constant, -1) for constant in
                    ('CALL_TIME', 'EARLY_TIME', 'LATE_TIME', 'SECOND_TIME', 'PARENT_TIME', 'HALF_PERIOD')]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('  bit clk = 0;', '  // $exit;\n  bit clk = 0;')),
                         case.expected)

    def test_exit_from_a_module_thread_is_ignored(self):
        # 24.7: the thread does not begin in an initial procedure of a program.
        source = g.source(('finish', 'initial', 'delay', 'top', 'none')).replace(
            '$finish;\n    #1 caller_after', '$exit;\n    #1 caller_after')
        output = q.interpret(source)
        self.assertIn('sentinel t=40', output)
        self.assertIn('caller_after=1', output)

    def test_last_program_thread_ending_makes_the_implicit_finish(self):
        # 24.3: without the call, the program ends when its parent initial ends at 20.
        source = g.source(('exit', 'fork', 'change', 'program', 'none')).replace('$exit;', ';')
        self.assertIn('final t=20 ', q.interpret(source))

    def test_a_later_fatal_that_never_runs_leaves_exit_code_zero(self):
        source = g.source(('finish', 'function', 'delay', 'child', 'fatal'))
        self.assertEqual(q.exit_code(source), '0')
        self.assertEqual(q.exit_code(source.replace('#8 second_seen = 1;', '#4 second_seen = 1;')), 'nonzero')

    def test_a_race_in_one_time_step_is_rejected(self):
        source = g.source(('finish', 'initial', 'delay', 'top', 'none')).replace(
            'initial #3 early = 1;', 'initial #3 early = 1;\n  initial #3 early = 2;')
        with self.assertRaises(AssertionError): q.interpret(source)

    def test_six_controls_and_ten_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 16)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)
        for case in controls.values():
            self.assertEqual(case.extra['expected_exit'], '0')


if __name__ == '__main__': unittest.main()
