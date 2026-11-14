"""Program instances across the hierarchy: implicit and explicit instances, parameters, names across scopes and the end of the run."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_progmod as g
import qualify_progmod as q


class ProgramHierarchyInstances(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_rows(self):
        rows = g.MODEL.rows()
        self.assertEqual(len(rows), 66)
        implicit = [r for r in rows if r[0] in g.IMPLICIT]
        self.assertTrue(all(r[1] == 'one' and r[3] != 'override' for r in implicit))
        self.assertFalse(any(r[2] == 'upward' and r[0] not in g.NESTED for r in rows))
        self.assertFalse(any(r[1] == 'two' and r[3] == 'default' for r in rows))
        self.assertFalse(any(r[4] == 'read' and r[1] == 'one' for r in rows))

    def test_pair_group_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 24)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(q.interpret(g.source(row)), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[2]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'instances', 'program_lines', 'instance_lines', 'defparam_lines', 'legal')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, constant, None) for constant in ('VALUES', 'BASES', 'SENTINEL_TIME', 'DECOY_TIME')]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[1])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source.replace('program worker', '// module worker;\nprogram worker')),
                         case.expected)

    def test_a_nested_program_without_ports_runs_and_one_with_ports_does_not(self):
        # 24.3 and 23.4: the first is instantiated once under its own name; the second is ignored.
        output = q.interpret(g.source(('nested', 'one', 'upward', 'default', 'none', 'ignored')))
        self.assertIn('.prog t=3 got=1\n', output)
        self.assertNotIn('ignored program ran', output)

    def test_the_run_ends_with_the_last_program(self):
        # 24.3: with instances ending at 4 and 6 the run ends at 6, before the sentinel at 50.
        output = q.interpret(g.source(('top_inst', 'two', 'absolute', 'override', 'read', 'none')))
        self.assertTrue(output.endswith('end t=6 total=37\n'))
        self.assertNotIn('sentinel', output)

    def test_without_programs_the_sentinel_prints(self):
        source = g.source(('top_inst', 'one', 'absolute', 'default', 'none', 'none'))
        source = source.replace('program worker', 'module worker').replace('endprogram', 'endmodule')
        self.assertIn('sentinel t=50', q.interpret(source))

    def test_equal_delays_writing_together_are_rejected(self):
        # Two instances at the same time in the same region: the interpretation needs one order only.
        source = g.source(('top_inst', 'two', 'absolute', 'override', 'none', 'none')).replace(
            '#(.D(6), .K(5)) p2', '#(.D(4), .K(5)) p2')
        with self.assertRaises(AssertionError): q.interpret(source)

    def test_five_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 5)
        self.assertEqual(len(programs), 12)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)


if __name__ == '__main__': unittest.main()
