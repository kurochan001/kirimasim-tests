"""A force overrides every other assignment, and a release restores by the kind of target."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_force as g
import qualify_force as q


def values(row):
    """The value of each odd read of a program shown with $display."""
    return [line.split()[1] for line in q.independent(row).splitlines() if line.split()[1] != 'r']


class ForceReleaseVisibility(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_triple_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 2160)
        self.assertEqual(len(selected), 72)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 228, 3: 72})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[3]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'history', 'forced_value', 'driven', 'with_part')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// release t;\n'), case.expected)

    def test_a_released_variable_keeps_the_forced_value(self):
        # The procedural write during the force is lost, and only the next write counts.
        self.assertEqual(values(('var', 'const', 'driver', 'blocking', 'display', 'direct')),
                         ['0001', '1010', '1010', '1010', '1100'])

    def test_a_released_net_takes_its_driver_at_once(self):
        out = q.independent(('net', 'const', 'driver', 'blocking', 'display', 'direct')).splitlines()
        self.assertIn('6 r 0011', out)
        self.assertEqual(values(('net', 'const', 'driver', 'blocking', 'display', 'direct')),
                         ['0001', '1010', '1010', '0011', '1100'])

    def test_a_variable_with_a_driver_gets_it_back(self):
        for target in ('cont', 'pca'):
            shown = values((target, 'const', 'driver', 'nba', 'display', 'direct'))
            self.assertEqual(shown[:5], ['0001', '1010', '1010', '0011', '1100'], target)
        self.assertEqual(values(('pca', 'const', 'hold', 'blocking', 'display', 'direct'))[5:], ['1100', '0101'])

    def test_no_read_in_the_time_step_of_a_reevaluation(self):
        for target in ('cont', 'pca'):
            source = g.source((target, 'const', 'hold', 'blocking', 'display', 'direct'))
            with self.assertRaisesRegex(AssertionError, 'races'):
                q.interpret(source.replace('release t;', 'release t;\n    $display("%0d %b", $time, t);'))

    def test_a_forced_expression_keeps_following(self):
        for target in ('var', 'net', 'cont'):
            shown = values((target, 'expr', 'source', 'blocking', 'display', 'direct'))
            self.assertEqual(shown[1:3], ['1001', '0110'], target)
        # A variable without a driver keeps the last value of the expression.
        self.assertEqual(values(('var', 'expr', 'source', 'blocking', 'display', 'direct'))[3], '0110')

    def test_a_part_select_leaves_the_other_bits_to_the_driver(self):
        self.assertEqual(values(('part', 'const', 'driver', 'blocking', 'display', 'direct')),
                         ['00010001', '00101001', '00101011', '00110011', '11001100'])

    def test_wor_resolves_all_drivers_again(self):
        self.assertEqual(values(('wor', 'const', 'driver', 'blocking', 'display', 'direct')),
                         ['0011', '1010', '1010', '0011', '1110'])

    def test_concatenations_force_every_part(self):
        for target in ('vcat', 'ncat'):
            self.assertEqual(values((target, 'const', 'hold', 'blocking', 'display', 'direct'))[1], '1010')

    def test_monitor_and_event_report_only_changes(self):
        row = ('var', 'const', 'driver', 'blocking', 'monitor', 'direct')
        self.assertEqual(q.independent(row), '0 0001\n2 1010\n8 1100\n')
        row = ('var', 'const', 'driver', 'blocking', 'event', 'direct')
        self.assertEqual(q.independent(row), '2 1010\n8 1100\n')

    def test_strobe_reports_the_end_of_the_time_step(self):
        row = ('net', 'const', 'driver', 'nba', 'strobe', 'direct')
        self.assertEqual(q.independent(row).splitlines()[3:5], ['6 0011', '8 1100'])

    def test_queries_read_the_forced_value(self):
        row = ('var', 'unknown', 'hold', 'blocking', 'query', 'direct')
        self.assertEqual(q.independent(row).splitlines()[1], '3 1 1 4')

    def test_the_site_of_a_statement_does_not_change_the_result(self):
        for row in g.MODEL.select():
            expected = g.reference(row)
            for site in ('direct', 'task', 'hier'):
                self.assertEqual(q.independent((*row[:5], site)), expected, site)

    def test_a_select_of_a_variable_is_rejected(self):
        source = g.source(('var', 'const', 'hold', 'blocking', 'display', 'direct'))
        with self.assertRaisesRegex(AssertionError, 'select of a variable'):
            q.interpret(source.replace('force t =', "force t[1:0] =").replace("4'b1010", "2'b10"))

    def test_eight_controls_and_ten_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 8)
        self.assertEqual(len(programs), 18)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('force t =', 'bind t ='),
                    source.replace('logic [3:0] t;', 'tri [3:0] t;'),
                    source.replace('#1;', '#2;')):
            with self.assertRaises((AssertionError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
