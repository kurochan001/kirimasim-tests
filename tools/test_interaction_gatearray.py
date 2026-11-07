"""Terminal bit mapping, truth tables and per-bit delays of gate arrays."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_gatearray as g
import qualify_gatearray as q


def snapshot(row):
    return {tuple(line.split()[:2]): line.split()[2] for line in q.independent(row).splitlines()}


class GateArrayConnection(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(case.lrm.split()[0].split('.')[0], str(g.CHAPTER))
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_legal_pair_triple_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 4464)
        self.assertEqual(len(selected), 51)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 278, 3: 135})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_generator_helpers(self):
        row = g.MODEL.anchors[1]
        source, expected = g.source(row), g.reference(row)
        names = ('source', 'reference', 'word', 'enable', 'gate_output', 'propagation', 'output_history', 'observed')
        patches = [patch.object(g, name, side_effect=AssertionError(name)) for name in names]
        for item in patches: item.start()
        try: self.assertEqual(q.interpret(source), expected)
        finally:
            for item in patches: item.stop()

    def test_comments_and_metadata_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// not g[3:0] (y, a_in);\n'), case.expected)

    def test_array_direction_does_not_change_the_bit_mapping(self):
        for row in g.MODEL.select():
            expected = g.reference(row)
            for array in ('down', 'up', 'offset'):
                self.assertEqual(q.independent((row[0], array, *row[2:])), expected, array)

    def test_terminal_direction_and_form_keep_the_string_of_bits(self):
        row = g.MODEL.anchors[0]
        for form in ('whole_up', 'concat'):
            self.assertEqual(q.independent((row[0], row[1], form, *row[3:])), g.reference(row), form)
            self.assertEqual(q.independent((*row[:3], form, *row[4:])), g.reference(row), form)

    def test_a_part_select_drives_only_its_bits(self):
        row = g.MODEL.anchors[5]
        for bits in snapshot(row).values():
            self.assertEqual(bits[0], 'z')
            self.assertEqual(bits[5:], 'zzz')

    def test_hand_calculated_tables_and_delays(self):
        # bufif1 #(1, 3, 2); the second phase has data 0x11 and control 110x.
        value = snapshot(g.MODEL.anchors[1])
        self.assertEqual(value['p0', 't3'], '0101')
        self.assertEqual(value['p1', 't0'], '0101')
        self.assertEqual(value['p1', 't1'], '0x0x')
        self.assertEqual(value['p1', 't2'], '0xzx')
        # Third phase: 1010 with control 0110, so 0 stays 3, and z takes 2.
        self.assertEqual(value['p2', 't1'], '0x1x')
        self.assertEqual(value['p2', 't2'], 'zx1z')
        self.assertEqual(value['p2', 't3'], 'z01z')

    def test_each_bit_takes_the_delay_of_its_own_new_value(self):
        # An array is four gates, so a rise and a fall of one word end apart.
        value = snapshot(('not', 'down', 'whole_down', 'whole_down', 'none', 'two', 'known'))
        self.assertEqual(value['p0', 't3'], '1010')
        self.assertEqual(value['p1', 't0'], '1010')
        self.assertEqual(value['p1', 't1'], '1110')
        self.assertEqual(value['p1', 't3'], '1100')

    def test_scalar_terminals_reach_every_instance(self):
        value = snapshot(('and', 'down', 'whole_down', 'scalar', 'vector', 'none', 'known'))
        self.assertEqual(value['p0', 't3'], '1111')
        self.assertEqual(value['p1', 't0'], '0000')
        self.assertEqual(value['p2', 't0'], '0110')

    def test_reads_stay_away_from_every_output_event(self):
        for row in g.MODEL.select():
            for events in g.output_history(row):
                for time, _ in events: self.assertEqual(2 * time % 2, 0)

    def test_first_output_before_its_delay_is_not_asserted(self):
        for row in g.MODEL.rows():
            self.assertNotIn('p0 t0', g.reference(row))
        source = g.source(g.MODEL.anchors[1]).replace('#3.5;', '#0.5;', 1)
        with self.assertRaises(AssertionError): q.interpret(source)

    def test_three_delays_only_on_tristate_elements(self):
        self.assertTrue(all(row[0] in ('bufif1', 'nmos') for row in g.MODEL.rows() if row[5] == 'three'))
        self.assertTrue(all((row[0] == 'not') == (row[4] == 'none') for row in g.MODEL.rows()))

    def test_six_controls_and_nine_executable_source_faults(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 6)
        self.assertEqual(len(programs), 15)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_connection_errors_pulses_and_unknown_forms_are_rejected(self):
        source = g.source(g.MODEL.anchors[1])
        for bad in (source.replace('wire [0:3] y;', 'wire [0:4] y;'),
                    source.replace('en[4:1]);', 'en[4:2]);'),
                    "module m; timeunit 1ns / 1ps; wire [3:0] y; logic [3:0] a_in; not #5 g[3:0] (y, a_in);\n"
                    "initial begin a_in = 4'b0000; #1; a_in = 4'b1111; #1; $finish; end endmodule\n",
                    source.replace('bufif1 #', 'bufif0 #'),
                    source.replace('$display(', '$strobe(')):
            with self.assertRaises((AssertionError, KeyError, ValueError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
