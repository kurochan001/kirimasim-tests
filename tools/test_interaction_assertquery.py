"""Bit vector functions in immediate and deferred assertions, with x and z bits and flushed reports."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_assertquery as g
import qualify_assertquery as q


def lines(row): return q.independent(row).splitlines()


class AssertionVectorQuery(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 450)
        self.assertEqual(len(selected), 30)
        self.assertEqual(len(g.MODEL.universe()), 153)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'holds', 'evaluations')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'PATTERNS', {}), patch.object(g, 'QUERIES', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// v = 4'b0100;\n"), case.expected)

    def test_x_and_z_bits_are_not_counted(self):
        results = {(query, pattern): lines((query, pattern, 'simple', 'initial', 'settled'))[0].split()[1]
                   for query in g.QUERIES for pattern in ('xone', 'xall', 'zone')}
        self.assertEqual(results, {('onehot', 'xone'): 'pass', ('onehot', 'xall'): 'fail', ('onehot', 'zone'): 'pass',
                                   ('onehot0', 'xone'): 'pass', ('onehot0', 'xall'): 'pass',
                                   ('onehot0', 'zone'): 'pass', ('countones', 'xone'): 'fail',
                                   ('countones', 'xall'): 'fail', ('countones', 'zone'): 'fail',
                                   ('known', 'xone'): 'fail', ('known', 'xall'): 'fail', ('known', 'zone'): 'fail',
                                   ('countzero', 'xone'): 'pass', ('countzero', 'xall'): 'fail',
                                   ('countzero', 'zone'): 'pass'})

    def test_always_comb_reports_at_time_zero(self):
        for row in g.MODEL.rows():
            self.assertEqual(lines(row)[0].startswith('0 '), row[3] == 'comb', row)

    def test_a_rerun_flushes_only_deferred_reports(self):
        for kind in g.KINDS:
            reports = [line for line in lines(('countones', 'one', kind, 'comb', 'glitch')) if line[0] == '1']
            # The glitch 0011 has two ones; the final value 0100 has one.
            self.assertEqual(reports, ['1 pass', '1 fail'] if kind == 'simple' else ['1 fail'], kind)

    def test_a_nonblocking_write_at_the_edge_is_not_seen(self):
        for kind in g.KINDS:
            self.assertEqual(lines(('known', 'xall', kind, 'clocked', 'glitch')), ['2 pass'], kind)
            self.assertEqual(lines(('known', 'xall', kind, 'clocked', 'settled')), ['2 fail'], kind)

    def test_six_controls_and_six_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 12)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('onehot', 'xone', 'observed', 'comb', 'glitch'))
        for bad in (source.replace('assert #0', 'assume #0'),
                    source.replace('$onehot(v)', '$countones(v)'),
                    source.replace('always_comb', 'always_latch')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
