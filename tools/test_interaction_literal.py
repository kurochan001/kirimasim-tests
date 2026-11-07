"""Literal forms, their carriers and the expression context that widens them."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_literal as g
import qualify_literal as q


def values(row): return dict(line.split() for line in q.independent(row).splitlines())


class LiteralContext(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_triple_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 6552)
        self.assertEqual(len(selected), 66)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 303, 3: 148})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[0]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'parts', 'literal_text', 'evaluate', 'fill_value', 'convert')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + "\n// localparam lp = 1'b0;\n"), case.expected)

    def test_examples_of_the_standard(self):
        cases = (("4'shf", '1111', True), ("3'b01x", '01x', False), ("12'hx", 'x' * 12, False),
                 ("16'sd?", 'z' * 16, True), ("16'sbz", 'z' * 16, True), ("5 'D 3", '00011', False))
        for text, bits, signed in cases:
            value = q.read_literal(text)
            self.assertEqual((value.bits, value.signed), (bits, signed), text)
        self.assertEqual(q.read_literal("'h 3x").bits, '0' * 26 + '11xxxx')
        self.assertEqual(q.read_literal("'h z3").bits, 'z' * 28 + '0011')
        self.assertEqual(q.read_literal("'h 0z3").bits, '0' * 24 + '0000zzzz0011'[-8:])
        self.assertEqual(q.read_literal("'0").bits, '0')

    def test_truncation_starts_from_the_left(self):
        self.assertEqual(q.read_literal("6'd173").bits, '101101')
        self.assertEqual(q.read_literal("12'hZacb").bits, 'acb'.replace('a', '1010').replace('c', '1100').replace('b', '1011'))
        self.assertEqual(q.read_literal("6'bx001011").bits, '001011')

    def test_signed_literal_extends_by_its_kept_top(self):
        row = ('b', 'signed', 'truncate', 'one', 'assign', 'logic', '33')
        self.assertEqual(values(row)['d'], '1' * 27 + '101011')
        row = ('b', 'signed', 'truncate', 'zero', 'assign', 'logic', '33')
        self.assertEqual(values(row)['d'], '0' * 27 + '001011')

    def test_sign_of_the_target_does_not_extend(self):
        row = ('b', 'unsigned', 'exact', 'one', 'assign', 'signed', '33')
        self.assertEqual(values(row)['d'], '0' * 27 + '101011')

    def test_unsigned_mate_turns_the_operand_unsigned(self):
        signed = ('b', 'signed', 'exact', 'one', 'add_signed', 'logic', '33')
        unsigned = ('b', 'signed', 'exact', 'one', 'add_unsigned', 'logic', '33')
        self.assertEqual(values(signed)['d'], format((-21 + 3) % 2**33, '033b'))
        self.assertEqual(values(unsigned)['d'], format(43 + 3, '033b'))

    def test_arithmetic_shift_fills_with_the_sign_or_an_unknown(self):
        # 6'so?2 is zzz010, signed, so it widens with z and the shift brings in z.
        row = ('o', 'signed', 'exact', 'z', 'ashr', 'logic', '33')
        self.assertEqual(values(row)['d'], 'z' * 31 + '01')
        row = ('b', 'unsigned', 'exact', 'one', 'ashr', 'logic', '33')
        self.assertEqual(values(row)['d'], '0' * 28 + '10101')

    def test_arithmetic_on_an_unknown_is_all_x_but_a_selection_keeps_bits(self):
        row = ('b', 'unsigned', 'narrow', 'x', 'add_unsigned', 'logic', '8')
        self.assertEqual(values(row)['d'], 'x' * 8)
        row = ('b', 'unsigned', 'narrow', 'x', 'cond', 'logic', '8')
        self.assertEqual(values(row)['d'], '00xxxx01')

    def test_every_carrier_agrees_except_a_parameter_of_a_literal_that_takes_the_context(self):
        for row in g.MODEL.rows():
            value = values(row)
            self.assertEqual(value['d'], value['m'])
            if row[0] != 'fill' and not g.grows(row): self.assertEqual(value['d'], value['p'], row)

    def test_example_of_an_unsized_number_led_by_x_taking_the_expression_size(self):
        # 5.7.1, Example 4: f = 'hx yields {85{1'hx}}, and e = 'h5 pads with zeros.
        row = ('h', 'unsigned', 'unsized', 'x', 'assign', 'logic', '65')
        self.assertEqual(values(row)['d'], 'x' * 65)
        self.assertEqual(values(row)['w'], 'x' * 65)
        self.assertEqual(values(row)['p'], '0' * 33 + 'x' * 32)
        row = ('h', 'unsigned', 'unsized', 'z', 'cond', 'logic', '33')
        self.assertEqual(values(row)['d'], 'z' * 33)
        row = ('h', 'unsigned', 'unsized', 'one', 'assign', 'logic', '65')
        self.assertEqual(values(row)['d'], '0' * 61 + '1010')

    def test_a_parameter_holds_a_filling_literal_as_one_bit(self):
        row = ('fill', 'unsigned', 'unsized', 'one', 'assign', 'logic', '33')
        self.assertEqual(values(row)['d'], '1' * 33)
        self.assertEqual(values(row)['p'], '0' * 32 + '1')
        self.assertEqual(values(row)['s'], '1')

    def test_a_bit_target_converts_and_the_net_keeps_the_values(self):
        row = ('h', 'unsigned', 'narrow', 'z', 'assign', 'bit', '8')
        self.assertEqual(values(row)['d'], '0' * 8)
        self.assertEqual(values(row)['w'], 'z' * 8)

    def test_unsized_numbers_report_no_size(self):
        for row in g.MODEL.rows():
            if row[2] == 'unsized' and row[0] != 'fill': self.assertNotIn('$bits', g.source(row))

    def test_legal_forms_only(self):
        rows = g.MODEL.rows()
        self.assertFalse([r for r in rows if r[0] == 'fill' and (r[1] == 'signed' or r[2] != 'unsized')])
        self.assertFalse([r for r in rows if r[0] == 'd' and r[3] in 'xz' and r[2] in ('exact', 'truncate')])
        self.assertFalse([r for r in rows if r[0] != 'fill' and r[2] == 'unsized' and r[3] in 'xz' and r[4] == 'ashr'])

    def test_four_state_metadata_follows_the_literal(self):
        for row in g.MODEL.rows():
            text = g.literal_text(row).lower()
            self.assertEqual(g.make_case(row).fourstate, any(c in text for c in 'xz?'))

    def test_six_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 15)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_implementation_defined_widths_and_unknown_forms_are_rejected(self):
        for text in ('4294967296', "'h1_0000_0000", "'sb" + '1' * 33, "6'dxx"):
            with self.assertRaises(AssertionError): q.read_literal(text)
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('t = -lp', 't = lp * 2'),
                    source.replace('localparam lp', 'parameter lp'),
                    source.replace('$bits(12', '$size(12')):
            with self.assertRaises((AssertionError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
