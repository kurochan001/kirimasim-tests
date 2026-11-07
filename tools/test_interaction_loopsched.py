"""Loop control and scheduling regions: when a loop reads its control and which write it sees."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_loopsched as g
import qualify_loopsched as q


def done(row): return next(line for line in q.independent(row).splitlines() if 'done' in line)


class LoopControlScheduling(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 165)
        self.assertEqual(len(selected), 55)
        self.assertEqual(len(g.MODEL.universe()), 137)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'iterations', 'end_count', 'end_n', 'order_by_time', 'final_n')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// n = 8'd9;\n"), case.expected)

    def test_repeat_counts_once(self):
        for wait in ('none', 'zero', 'delay'):
            for change in ('nba', 'later', 'self'):
                self.assertIn('done count=3', done(('repeat', wait, change, 'display')), (wait, change))

    def test_a_loop_that_waits_sees_the_new_bound(self):
        for loop in ('while', 'for', 'forever', 'do'):
            for change in ('nba', 'zero', 'later'):
                self.assertIn('done count=5 n=5', done((loop, 'delay', change, 'display')), (loop, change))

    def test_a_loop_within_one_slot_keeps_the_old_bound(self):
        for loop in ('while', 'for', 'forever', 'do'):
            for wait, change in (('none', 'nba'), ('none', 'zero'), ('zero', 'nba'), ('none', 'later')):
                self.assertEqual(done((loop, wait, change, 'display')), '1 done count=3 n=3', (loop, wait))

    def test_strobe_and_monitor_show_the_end_of_the_slot(self):
        # The loop sees 3, the nonblocking update makes it 5 before the postponed region.
        self.assertEqual(q.independent(('while', 'none', 'nba', 'strobe')).splitlines(),
                         ['1 done count=3 n=3'] + ['1 st count=3 n=5'] * 3)
        self.assertEqual(q.independent(('while', 'zero', 'nba', 'monitor')).splitlines(),
                         ['1 done count=3 n=3', '1 mon count=3 n=5'])
        self.assertEqual(q.independent(('while', 'none', 'later', 'monitor')).splitlines(),
                         ['1 done count=3 n=3', '1 mon count=3 n=3', '2 mon count=3 n=5'])

    def test_do_runs_the_body_before_the_test(self):
        self.assertEqual(done(('do', 'none', 'self', 'display')), '1 done count=2 n=1')
        self.assertEqual(done(('while', 'none', 'self', 'display')), '1 done count=2 n=1')
        self.assertEqual(done(('repeat', 'none', 'self', 'display')), '1 done count=3 n=0')

    def test_the_excluded_race_is_found(self):
        for loop in g.LOOPS:
            with self.assertRaises(AssertionError): q.interpret(g.source((loop, 'zero', 'zero', 'display')))

    def test_six_controls_and_six_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 12)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('while', 'delay', 'nba', 'display'))
        for bad in (source.replace('while (count < n)', 'while (count != n)'),
                    source.replace('#2;', '@(n);'),
                    source.replace('$display("%0d it', '$write("%0d it')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
