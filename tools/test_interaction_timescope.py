"""Time-scope precedence, per-delay rounding and read-back in each scope."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_timescope as g
import qualify_timescope as q


def lines(row): return q.independent(row).splitlines()


class TimeScopeDelay(unittest.TestCase):
    keyword = g.MODEL.anchors[0]

    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_triple_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 8064)
        self.assertEqual(len(selected), 48)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 291, 3: 136})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[1]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'worker_scale', 'caller_scale', 'amount', 'elapsed', 'reading')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(self.keyword)
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// `timescale 1s/1s\n'), case.expected)

    def test_hand_calculated_rounding_and_read_back(self):
        # 1.27 units of 10 ns is 12.7 ns, rounded to the 1 ns precision: 13 ns.
        # The caller waits 0.47 ns first, in units of 1 ns.
        output = lines(self.keyword)
        self.assertEqual(output[0], 'c 0 0 0 0.470000000 0fs 470000fs')
        self.assertEqual(output[1], 'w 1 1 1 1.347000000 10000000fs 13470000fs')
        self.assertEqual(output[2], 'c 1 13 13 13.470000000 13000000fs 13470000fs')
        self.assertEqual(output[3], 'w 2 3 3 2.647000000 30000000fs 26470000fs')

    def test_each_delay_rounds_alone(self):
        # Two 12.7 ns delays are 13 ns each, 26 ns and not a rounded 25.4 ns.
        output = lines(self.keyword)
        self.assertIn('26470000fs', output[3])
        self.assertNotIn('25870000fs', output[3])

    def test_the_same_number_waits_by_the_scope_of_the_statement(self):
        # After the second call the caller waits 1.27 of its own 1 ns units.
        self.assertIn('27740000fs', lines(self.keyword)[5])

    def test_every_binding_gives_the_same_scope(self):
        row = list(self.keyword)
        expected = g.reference(self.keyword)
        for binding in ('slash', 'directive', 'unit_scope', 'nested'):
            row[0] = binding
            self.assertEqual(q.independent(tuple(row)), expected, binding)

    def test_each_precedence_rule_is_visible(self):
        source = g.source(self.keyword)
        self.assertNotEqual(q.interpret(source.replace('  timeunit 10ns;\n  timeprecision 1ns;\n', '')),
                            g.reference(self.keyword))
        row = ('directive', 'module', *self.keyword[2:])
        decoy = g.source(row).replace('`timescale 10ns/1ns\n', '')
        self.assertNotEqual(q.interpret(decoy), g.reference(row))
        row = ('nested', 'module', *self.keyword[2:])
        moved = g.source(row).replace('  timeunit 10ns / 1ns;\n', '')
        with self.assertRaises(AssertionError): q.interpret(moved.replace('`timescale 1ms/1us\n', ''))

    def test_a_directive_after_a_definition_does_not_reach_it(self):
        row = ('unit_scope', 'module', *self.keyword[2:])
        self.assertEqual(q.independent(row), g.reference(self.keyword))

    def test_literal_argument_and_real_forms_agree(self):
        expected = g.reference(self.keyword)
        for form in ('suffix', 'fine', 'argument'):
            row = (*self.keyword[:4], form, *self.keyword[5:])
            self.assertEqual(q.independent(row), expected, form)

    def test_nonblocking_control_uses_the_same_scope(self):
        row = (*self.keyword[:7], 'nba')
        self.assertEqual(q.independent(row), g.reference(self.keyword))
        self.assertIn('real dv', g.source((*self.keyword[:4], 'argument', *self.keyword[5:7], 'nba')))

    def test_exact_ties_round_up_only_where_the_values_are_exact(self):
        for precision, value in (('same', '2.5'), ('tenth', '1.25'), ('milli', '1.0625')):
            row = ('keyword', 'module', '10ns', precision, 'real', 'tie', 'finer', 'statement')
            self.assertIn(f'#{value};', g.source(row))
        row = ('keyword', 'module', '10ns', 'same', 'real', 'tie', 'finer', 'statement')
        self.assertIn('30470000fs', lines(row)[1])

    def test_no_row_reads_a_tie_or_outside_stime(self):
        for row in g.MODEL.rows():
            for line in g.reference(row).splitlines():
                self.assertEqual(line.split()[2], line.split()[3])

    def test_package_is_never_nested(self):
        self.assertFalse(any(row[0] == 'nested' and row[1] == 'package' for row in g.MODEL.rows()))

    def test_five_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 5)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_syntax_and_scopes_are_rejected(self):
        source = g.source(self.keyword)
        for bad in (source.replace('timeunit 10ns;', 'timeunit 3ns;'),
                    source.replace('timeprecision 1ns;', ''),
                    source.replace('#1.27;', '#(1.27);'),
                    source.replace('u.work(2);', 'v.work(2);'),
                    source.replace('`timescale 1ms/1us\nmodule worker;\n  timeunit 10ns;\n  timeprecision 1ns;\n',
                                   'module worker;\n')):
            with self.assertRaises((AssertionError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
