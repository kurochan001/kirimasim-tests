"""Hierarchical names: a process disables, triggers, writes or calls in another instance."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_hierproc as g
import qualify_hierproc as q


class HierarchicalProcessControl(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 252)
        self.assertEqual(len(selected), 42)
        self.assertEqual(len(g.MODEL.universe()), 149)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'target_items', 'actor_items', 'case_name')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'START', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// disable u.run;\n'), case.expected)

    def test_disabling_a_block_that_does_not_run_does_nothing(self):
        self.assertEqual(q.independent(('disable', 'down', 'waiting', 'initial')), '2 act x=0\n2 after x=0\n8 end x=0\n')
        self.assertEqual(q.independent(('disable', 'down', 'late', 'initial')),
                         '2 act x=0\n7 inner\n7 after x=0\n8 end x=0\n')

    def test_a_trigger_or_change_with_nobody_waiting_is_lost(self):
        self.assertEqual(q.independent(('trigger', 'sibling', 'late', 'fork')), '2 act x=0\n8 end x=0\n')
        self.assertEqual(q.independent(('write', 'up', 'late', 'task')), '2 act x=0\n8 end x=5\n')
        self.assertEqual(q.independent(('level', 'up', 'late', 'task')), '2 act x=0\n4 woke x=5\n8 end x=5\n')

    def test_a_nonblocking_write_is_read_old_and_a_task_call_takes_its_delay(self):
        self.assertEqual(q.independent(('nba', 'root', 'waiting', 'initial')),
                         '2 act x=0\n2 sent x=0\n2 woke x=5\n8 end x=5\n')
        self.assertEqual(q.independent(('call', 'generate', 'waiting', 'task')), '2 act x=0\n3 woke x=5\n8 end x=5\n')

    def test_every_path_reaches_the_same_target(self):
        for action in g.ACTIONS:
            results = {q.independent((action, path, 'waiting', 'initial')) for path in g.PATHS}
            self.assertEqual(len(results), 1, action)

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_names_and_forms_are_rejected(self):
        source = g.source(('trigger', 'down', 'waiting', 'initial'))
        top = g.case_name(('disable', 'root', 'waiting', 'initial'))
        root = g.source(('disable', 'root', 'waiting', 'initial'))
        for bad in (source.replace('-> u.e;', '-> u.f;'), source.replace('-> u.e;', '-> v.e;'),
                    source.replace('-> u.e;', 'disable u.x;'), root.replace(f'$root.{top}.u.run', '$root.other.u.run'),
                    source.replace('-> u.e;', '->> u.e;')):
            with self.assertRaises((AssertionError, KeyError, IndexError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
