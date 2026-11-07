"""Implicit sensitivity: the longest static prefix, what a function reads, and no-change writes."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_sense as g
import qualify_sense as q


def wakes_in_the_middle(row): return '4 eval' in q.independent(row).splitlines()


def outputs(row): return [line.split('=')[1] for line in q.independent(row).splitlines() if 'o=' in line]


class ImplicitSensitivityUpdate(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 630)
        self.assertEqual(len(selected), 61)
        self.assertEqual(len(g.MODEL.universe()), 177)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'evaluates', 'read_value', 'write', 'initial_state', 'new_value')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// always_comb o = 0;\n'), case.expected)

    def test_a_constant_select_wakes_only_for_its_own_part(self):
        for read in ('element', 'member', 'packed', 'part', 'concat'):
            for process in ('comb', 'latch'):
                self.assertFalse(wakes_in_the_middle((process, read, 'unread', 'blocking')), (process, read))
                self.assertTrue(wakes_in_the_middle((process, read, 'read', 'blocking')), (process, read))

    def test_a_variable_index_makes_the_prefix_the_whole_array(self):
        self.assertTrue(wakes_in_the_middle(('comb', 'index', 'unread', 'blocking')))
        self.assertEqual(outputs(('comb', 'index', 'unread', 'blocking'))[1:3], ['0c', '0c'])

    def test_a_write_of_the_index_changes_the_element_read(self):
        # arr[2] is 3, so 3 + 10 after the index moves.
        self.assertEqual(outputs(('assign', 'index', 'index', 'blocking'))[2], '0d')

    def test_every_operand_of_a_conditional_is_read(self):
        self.assertTrue(wakes_in_the_middle(('comb', 'cond', 'unread', 'blocking')))
        self.assertEqual(outputs(('comb', 'cond', 'index', 'blocking'))[2], '13')

    def test_a_write_of_the_same_value_is_no_update(self):
        for read in g.READS:
            self.assertFalse(wakes_in_the_middle(('comb', read, 'same', 'blocking')), read)

    def test_what_a_function_reads_only_reaches_always_comb(self):
        self.assertTrue(wakes_in_the_middle(('comb', 'fnglobal', 'read', 'blocking')))
        self.assertTrue(wakes_in_the_middle(('latch', 'fnglobal', 'read', 'blocking')))
        for process in ('star', 'assign', 'netdecl'):
            # The output keeps 2 + 10 until b changes, and then reads a of 40 with b of 20.
            self.assertEqual(outputs((process, 'fnglobal', 'read', 'blocking'))[1:], ['0c', '0c', '3c'], process)
        self.assertEqual(outputs(('comb', 'fnglobal', 'read', 'blocking'))[1:], ['0c', '32', '3c'])

    def test_a_function_argument_reaches_all_forms(self):
        for process in ('comb', 'latch', 'star', 'assign', 'netdecl'):
            self.assertEqual(outputs((process, 'fnarg', 'read', 'blocking'))[2], '32', process)

    def test_always_star_waits_for_the_first_change(self):
        for row in g.MODEL.rows():
            first = outputs(row)[0]
            self.assertEqual(first == 'xx', row[0] == 'star', row)

    def test_only_procedures_show_evaluations(self):
        for row in g.MODEL.rows():
            self.assertEqual('eval' in g.reference(row), row[0] in g.PROCEDURES, row)

    def test_the_writer_does_not_change_the_result(self):
        for row in g.MODEL.select():
            expected = g.reference(row)
            for writer in ('blocking', 'nba', 'task'):
                self.assertEqual(q.independent((*row[:3], writer)), expected, writer)

    def test_nine_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 9)
        self.assertEqual(len(programs), 18)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('comb', 'element', 'unread', 'blocking'))
        for bad in (source.replace('always_comb begin', 'always_ff begin'),
                    source.replace('$display("%0d o=%h", $time, o);', '$strobe("%0d o=%h", $time, o);'),
                    source.replace('arr[2]', 'arr[3]')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
