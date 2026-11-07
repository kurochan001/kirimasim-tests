"""Parameter overrides: the declaration or the final override decides the type, and defparam wins."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_paramtype as g
import qualify_paramtype as q


def first(row): return q.independent(row).splitlines()[0]


class ParameterOverrideType(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 252)
        self.assertEqual(len(selected), 44)
        self.assertEqual(len(g.MODEL.universe()), 120)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'final_type', 'signed_value')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        patches += [patch.object(g, 'VALUES', {}), patch.object(g, 'DECLS', {})]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// defparam u.P = 8'd1;\n"), case.expected)

    def test_the_method_does_not_change_the_result(self):
        for decl in g.DECLS:
            for value in g.VALUES:
                results = {q.independent((decl, value, method)) for method in
                           ('default', 'ordered', 'named', 'defparam', 'both', 'local')}
                self.assertEqual(len(results), 1, (decl, value))

    def test_no_type_or_range_takes_the_final_value(self):
        self.assertEqual(first(('untyped', 'wide', 'defparam')), 'P=3855 bits=12 neg=0')
        self.assertEqual(first(('untyped', 'ssized', 'both')), 'P=-3 bits=8 neg=1')
        self.assertEqual(first(('untyped', 'concat', 'named')), 'P=13 bits=4 neg=0')

    def test_a_range_alone_is_unsigned_and_keeps_its_width(self):
        self.assertEqual(first(('range', 'ssized', 'ordered')), 'P=253 bits=8 neg=0')
        self.assertEqual(first(('range', 'wide', 'named')), 'P=15 bits=8 neg=0')

    def test_signed_alone_takes_the_range_of_the_value(self):
        self.assertEqual(first(('signed', 'narrow', 'default')), 'P=-6 bits=4 neg=1')
        self.assertEqual(first(('signed', 'wide', 'defparam')), 'P=-241 bits=12 neg=1')
        self.assertEqual(first(('signed', 'concat', 'both')), 'P=-3 bits=4 neg=1')

    def test_a_type_converts_the_value(self):
        self.assertEqual(first(('int', 'ssized', 'named')), 'P=-3 bits=32 neg=1')
        self.assertEqual(first(('logic', 'sum', 'local')), 'P=3 bits=4 neg=0')
        self.assertEqual(first(('srange', 'sized', 'both')), 'P=-56 bits=8 neg=1')
        self.assertEqual(q.independent(('struct', 'sized', 'defparam')), 'P=200 bits=8 neg=0\nhi=-4 lo=8\n')

    def test_the_values_do_not_depend_on_the_evaluation_width(self):
        # Each value fits its own width, so evaluating it at a wider width gives the same number.
        for text, width, signed, number in g.VALUES.values():
            self.assertEqual(q.evaluate(text, {}).number(), number, text)
            self.assertEqual(q.evaluate(text, {}).width, width, text)

    def test_eight_controls_and_eight_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 8)
        self.assertEqual(len(programs), 16)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(('untyped', 'wide', 'defparam'))
        for bad in (source.replace("defparam u.P = 12'hf0f;", 'defparam u.P = 3855;'),
                    source.replace("defparam u.P = 12'hf0f;", "defparam v.P = 12'hf0f;"),
                    source.replace('#(parameter P', '#(parameter real P')):
            with self.assertRaises((AssertionError, IndexError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
