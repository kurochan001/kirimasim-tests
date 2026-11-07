"""Array query functions give the bounds of loops over fixed, packed, dynamic and queue dimensions."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_arrayloop as g
import qualify_arrayloop as q


class ArrayQueryLoop(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.rows():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 440)
        self.assertEqual(len(selected), 40)
        self.assertEqual(len(g.MODEL.universe()), 151)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'query', 'visits', 'declaration', 'fill', 'loop_lines')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'FIXED', {}), patch.object(g, 'BYTES', ())]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// w[1] = new[4];\n"), case.expected)

    def test_increment_follows_the_bounds_and_is_minus_one_for_dynamic_dimensions(self):
        first = lambda row: q.independent(row).splitlines()[:2]
        self.assertEqual(first(('offset', 'type', 'for', 'lowhigh')), ['left=5 right=2 inc=1', 'low=2 high=5 size=4'])
        self.assertEqual(first(('neg', 'var', 'for', 'lowhigh')), ['left=-2 right=1 inc=-1', 'low=-2 high=1 size=4'])
        self.assertEqual(first(('queue', 'var', 'for', 'lowhigh')), ['left=0 right=3 inc=-1', 'low=0 high=3 size=4'])
        self.assertEqual(first(('empty', 'var', 'for', 'lowhigh')), ['left=0 right=-1 inc=-1', 'low=0 high=-1 size=0'])

    def test_dimensions_count_packed_and_unpacked(self):
        dims = lambda row: q.independent(row).splitlines()[2]
        self.assertEqual(dims(('asc', 'dim', 'for', 'lowhigh')), 'dims=3 unpacked=2')
        self.assertEqual(dims(('packed', 'dim', 'for', 'lowhigh')), 'dims=3 unpacked=0')
        self.assertEqual(dims(('packed', 'elem', 'for', 'lowhigh')), 'dims=2 unpacked=0')
        self.assertEqual(dims(('dynamic', 'elem', 'for', 'lowhigh')), 'dims=2 unpacked=1')

    def test_loops_visit_in_the_order_of_their_bounds(self):
        visit = lambda row: q.independent(row).splitlines()[3]
        self.assertEqual(visit(('desc', 'var', 'foreach', 'leftright')), 'visit 3:11 2:22 1:33 0:44')
        self.assertEqual(visit(('desc', 'var', 'while', 'lowhigh')), 'visit 0:44 1:33 2:22 3:11')
        self.assertEqual(visit(('neg', 'elem', 'repeat', 'highlow')), 'visit 1:44 0:33 -1:22 -2:11')
        self.assertEqual(visit(('empty', 'var', 'do', 'size')), 'visit 0:xx')
        self.assertEqual(visit(('empty', 'elem', 'foreach', 'leftright')), 'visit')

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('dynamic', 'elem', 'for', 'lowhigh'))
        for bad in (source.replace('$low(w[1])', '$low(w, 2)'), source.replace('$size(w[1])', '$length(w[1])'),
                    source.replace('logic [7:0] w', 'logic [15:0] w'), source.replace('w[1] = new[4];', 'w[1].sort();')):
            with self.assertRaises((AssertionError, KeyError, IndexError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
