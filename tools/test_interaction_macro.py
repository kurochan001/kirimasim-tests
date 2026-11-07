"""Text macros expand as text at the point of use, whatever the design element."""

from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_macro as g
import qualify_macro as q


def expanded(source): return q.squeeze(q.Preprocessor().expand(source))


class MacroExpansionContext(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 7679)
        self.assertEqual(len(selected), 114)
        self.assertEqual(len(g.MODEL.universe()), 463)
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[3]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'core', 'definitions', 'use', 'value', 'body_text')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// `define M(x) 1\n'), case.expected)

    def test_hand_calculated_values(self):
        # 1 | 6 + 1 * 3 is 1 | 9, and ((1 | 6) + 1) * 3 is 8 * 3.
        self.assertEqual(q.independent(('function', 'bare', 'low', 'show', 'unit')), '9\n')
        self.assertEqual(q.independent(('function', 'wrap', 'low', 'show', 'unit')), '24\n')
        # 1 | 6 + 1 + 1 | 6 * 3 is 1 | 8 | 18.
        self.assertEqual(q.independent(('function', 'twice', 'low', 'show', 'unit')), '27\n')
        # A conditional takes in the whole rest of the text.
        self.assertEqual(q.independent(('function', 'bare', 'cond', 'show', 'unit')), '2\n')
        self.assertEqual(q.independent(('function', 'wrap', 'cond', 'show', 'unit')), '9\n')
        # The concatenation has four bits, with the value 6.
        self.assertEqual(q.independent(('function', 'twice', 'brace', 'show', 'unit')), '25\n')

    def test_every_form_of_definition_gives_the_same_value(self):
        for form in ('function', 'object', 'omit', 'empty', 'second', 'late', 'actual', 'lines'):
            for body in ('bare', 'wrap', 'twice'):
                for actual in g.ACTUAL:
                    row = (form, body, actual, 'show', 'unit')
                    self.assertEqual(q.independent(row), f'{g.VALUE[body, actual]}\n', row)

    def test_a_later_definition_of_the_inner_macro_is_the_one_used(self):
        source = g.source(('late', 'wrap', 'simple', 'show', 'unit'))
        self.assertLess(source.index('`define M'), source.index('`define INNER'))
        self.assertEqual(q.interpret(source), '12\n')

    def test_the_inactive_block_is_not_compiled(self):
        source = g.source(('function', 'bare', 'simple', 'show', 'elsif'))
        self.assertIn('`NOT_DEFINED endcase', source)
        self.assertEqual(q.interpret(source), '6\n')
        with self.assertRaises(AssertionError):
            q.interpret(source.replace('`define OK_FLAG', '`define NO_FLAG'))

    def test_a_definition_reaches_the_rest_of_the_compilation_unit(self):
        for context in ('pkg', 'ifc', 'cls', 'show'):
            for arrange in ('unit', 'other', 'same'):
                row = ('function', 'wrap', 'simple', context, arrange)
                self.assertEqual(q.independent(row), '12\n', row)
        other = g.make_case(('function', 'wrap', 'simple', 'show', 'other'))
        self.assertEqual(other.extra['top_module'], other.name)

    def test_text_forms_are_only_shown(self):
        self.assertTrue(all(row[3] == 'show' and row[1] == 'bare' for row in g.MODEL.rows()
                            if row[0] in g.TEXT_FORMS))
        self.assertEqual(q.independent(('string', 'bare', 'brace', 'show', 'unit')), "{2'b01, 2'b10}\n")
        self.assertEqual(q.independent(('quote', 'bare', 'low', 'show', 'unit')), 'v="1 | 6"\n')

    def test_macros_do_not_expand_in_string_literals(self):
        self.assertEqual(expanded('`define V 7\n"`V" `V'), '"`V" 7')

    def test_default_rules(self):
        self.assertEqual(expanded('`define M(a=5, b, c="C") a b c\n`M(1, , 3)'), '1 3')
        self.assertEqual(expanded('`define M(a=5, b, c="C") a b c\n`M(, 2)'), '5 2 "C"')
        with self.assertRaises(AssertionError): expanded('`define M(a=5, b, c) a b c\n`M(1)')
        with self.assertRaises(AssertionError): expanded('`define M(a) a\n`M(1, 2)')
        with self.assertRaises(AssertionError): expanded('`define M(a) a\n`M')

    def test_a_macro_inside_an_argument_expands_once_substituted(self):
        self.assertEqual(expanded('`define TOP(a,b) a + b\n`TOP( `TOP(b,1), `TOP(42,a) )'), 'b + 1 + 42 + a')

    def test_a_recursive_macro_is_an_error(self):
        with self.assertRaises(AssertionError): expanded('`define M `M\n`M')

    def test_nine_controls_and_ten_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 9)
        self.assertEqual(len(programs), 19)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unknown_forms_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('`M(1 | 6)', '`N(1 | 6)'),
                    source.replace('$display("%0d"', '$strobe("%0d"'),
                    source.replace('* 3', '/ 3'),
                    source.replace('module ', 'module helper; int q; endmodule\nmodule ')):
            with self.assertRaises((AssertionError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
