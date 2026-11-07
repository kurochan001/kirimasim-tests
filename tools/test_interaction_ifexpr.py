"""Interface members: the declared type on every access path, and statements sharing the storage."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_ifexpr as g
import qualify_ifexpr as q


def acc(row): return int(q.independent(row).splitlines()[0].split()[1].split('=')[1])


class InterfaceMemberExpression(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 2940)
        self.assertEqual(len(selected), 49)
        self.assertEqual(len(g.MODEL.universe()), 264)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'term', 'updates', 'operand')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'DECLS', {}), patch.object(g, 'EXPRS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// logic signed [7:0] v = 8'shfa;\n"), case.expected)

    def test_the_path_and_the_update_do_not_change_the_result(self):
        for row in g.MODEL.select():
            expected = q.independent(row).splitlines()[:2]
            for path in ('port', 'modport', 'generic', 'element', 'hier'):
                for update in ('direct', 'compound', 'task', 'inside'):
                    lines = q.independent((path, *row[1:4], update)).splitlines()[:2]
                    self.assertEqual(lines, expected, (row, path, update))

    def test_the_type_of_the_member_decides_the_operators(self):
        # One update each: case runs two, so halve.
        one = {decl: {expr: acc(('port', decl, expr, 'case', 'direct')) // 2 for expr in g.EXPRS}
               for decl in g.DECLS}
        self.assertEqual(one['s8'], {'div': -1, 'shift': -2, 'mixed': 250, 'part': 10, 'cmp': 1, 'neg': 6,
                                     'mul': 6})
        self.assertEqual(one['u8'], {'div': 62, 'shift': 62, 'mixed': 250, 'part': 10, 'cmp': 0, 'neg': -250,
                                     'mul': 750})
        self.assertEqual(one['s4'], {'div': -1, 'shift': -2, 'mixed': 10, 'part': 10, 'cmp': 1, 'neg': 6,
                                     'mul': 6})

    def test_statements_read_the_shared_count(self):
        counts = {stmt: q.independent(('modport', 's8', 'cmp', stmt, 'task')).splitlines()[0]
                  for stmt in ('if', 'case', 'repeat', 'while', 'for', 'do', 'foreach')}
        self.assertEqual(counts, {'if': 'user acc=1 n=2', 'case': 'user acc=2 n=1', 'repeat': 'user acc=3 n=0',
                                  'while': 'user acc=2 n=1', 'for': 'user acc=2 n=1', 'do': 'user acc=1 n=2',
                                  'foreach': 'user acc=2 n=1'})
        self.assertEqual(q.independent(('modport', 'u8', 'part', 'if', 'task')).splitlines()[0],
                         'user acc=30 n=0')

    def test_the_other_element_keeps_its_values(self):
        for row in g.MODEL.select():
            if row[0] == 'element':
                self.assertEqual(q.independent(row).splitlines()[-1], 'other acc=0 n=3')

    def test_seven_controls_and_seven_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 7)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_the_modport_limits_the_port(self):
        direct = g.source(('modport', 's8', 'mixed', 'while', 'direct'))
        inside = g.source(('modport', 's8', 'mixed', 'while', 'inside'))
        for bad in (direct.replace('p.acc = p.acc + (', 'p.v = p.acc + ('),
                    direct.replace('ref n, ref acc', 'input n, ref acc'),
                    inside.replace('import step, import fold', 'import step')):
            with self.assertRaises(AssertionError): q.interpret(bad)
        # A port without a modport reaches every member.
        row = ('port', 's8', 'mixed', 'while', 'direct')
        self.assertEqual(q.interpret(g.source(row).replace('ref n, ref acc', 'input n, ref acc')), g.reference(row))

    def test_unknown_forms_are_rejected(self):
        source = g.source(('port', 's8', 'div', 'while', 'direct'))
        for bad in (source.replace('p.v / 4', 'p.v % 4'),
                    source.replace('while (p.n > 1)', 'while (p.n != 1)'),
                    source.replace('member_user u (i0);', 'member_user u (i1);')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
