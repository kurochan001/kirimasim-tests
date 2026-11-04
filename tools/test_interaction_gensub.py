"""Generated lexical bindings, array identity and typed subroutine copy-out."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_gensub as g
import qualify_gensub as q


def snapshots(text):
    result = {}; phase = step = None
    for line in text.splitlines():
        fields = dict(item.split('=', 1) for item in line.split()[1:])
        if line.startswith('h '): phase, step = fields['p'], fields['step']
        else: result[phase, step, int(fields['id'])] = fields
    return result


class GeneratedSubroutineBinding(unittest.TestCase):
    def test_all_factor_rows_are_legal(self):
        self.assertEqual(prod(len(v) for _, v in g.MODEL.factors), 2304)
        self.assertEqual(len(g.MODEL.rows()), 2304)
        self.assertTrue(all(g.layout(row, slot)[0] > 0 for row in g.MODEL.rows() for slot in range(4)))

    def test_selection_retains_every_pair_triple_and_anchor(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 228, 3: 112})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertEqual(len(g.MODEL.anchors), 6)
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(selected, g.MODEL.select())

    def test_all_actual_legal_programs_match_independent_elaboration_and_execution(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_actual_sv_interpretation_calls_no_generator_or_reference_helper(self):
        row = g.MODEL.anchors[1]; source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'source', side_effect=AssertionError('source')), \
             patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'layout', side_effect=AssertionError('layout')), \
             patch.object(g, 'initial', side_effect=AssertionError('stimulus')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')), \
             patch.object(g, 'xor', side_effect=AssertionError('operation')):
            self.assertEqual(q.interpret(source), expected)

    def test_metadata_and_comments_do_not_define_elaborated_scopes(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        source += '\n// module fake; localparam int KIND = 99; initial begin\n'
        self.assertEqual(q.interpret(source), case.expected)

    def test_one_bit_hand_calculated_scope_widths_bounds_and_first_capture(self):
        seen = snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertEqual(seen['0', 'init', 0], {'id': '0', 'left': '-2', 'right': '-1',
            'bits': '1', 'tag': '1', 'data': '1', 'guard': '0', 'ret': '00000'})
        self.assertEqual(seen['0', 'first0', 0]['data'], '0')
        self.assertEqual(seen['0', 'first0', 0]['ret'], '00001')
        self.assertEqual(seen['0', 'first0', 1], seen['0', 'init', 1])
        self.assertEqual([seen['0', 'init', i]['bits'] for i in range(4)], ['1', '3', '2', '2'])
        self.assertEqual([seen['0', 'init', i]['tag'] for i in range(4)], ['1', '4', '2', '3'])

    def test_if_and_case_elaborate_the_same_selected_scopes(self):
        row = g.MODEL.anchors[1]
        other = (*row[:3], 'if', *row[4:])
        self.assertEqual(q.independent(row), q.independent(other))

    def test_function_return_and_task_copyout_share_the_assignment_conversion(self):
        row = g.MODEL.anchors[4]
        other = (*row[:5], 'function', *row[6:])
        self.assertEqual(q.independent(row), q.independent(other))

    def test_signed_return_extends_its_own_generated_width(self):
        row = ('32', 'logic', 's', 'if', 'default', 'function', 'forward', 'known', 'down')
        signed = snapshots(q.independent(row)); unsigned = snapshots(q.independent((*row[:2], 'u', *row[3:])))
        # b.g[0] has 33-bit signed data; the producer destination has 36 bits.
        self.assertEqual(signed['0', 'first2', 2]['ret'][:4], '1111')
        self.assertEqual(unsigned['0', 'first2', 2]['ret'][:4], '0001')
        self.assertEqual(signed['0', 'first2', 2]['ret'][4:], unsigned['0', 'first2', 2]['ret'][4:])

    def test_default_is_reevaluated_after_external_refresh(self):
        row = g.MODEL.anchors[0]
        seen = snapshots(q.independent(row))
        self.assertEqual(seen['0', 'refresh', 0]['data'], '1')
        self.assertEqual(seen['0', 'again3', 0]['ret'], '00001')
        self.assertEqual(seen['0', 'again3', 0]['data'], '0')
        # A wider generated scope distinguishes the live default from caller drive.
        default = snapshots(q.independent(g.MODEL.anchors[4]))
        explicit = snapshots(q.independent((*g.MODEL.anchors[4][:4], 'explicit', *g.MODEL.anchors[4][5:])))
        self.assertNotEqual(default['0', 'again0', 0]['data'], explicit['0', 'again0', 0]['data'])

    def test_guard_changes_without_changing_target_and_probe_reads_target(self):
        seen = snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertNotEqual(seen['0', 'guard', 3]['guard'], seen['0', 'again3', 3]['guard'])
        self.assertEqual(seen['0', 'guard', 3]['data'], seen['0', 'again3', 3]['data'])
        self.assertEqual(seen['0', 'probe', 3]['ret'], '00001')
        for slot in range(3): self.assertEqual(seen['0', 'probe', slot], seen['0', 'guard', slot])
        for slot in range(4): self.assertEqual(seen['0', 'idle', slot], seen['0', 'probe', slot])

    def test_array_direction_changes_queries_without_swapping_state(self):
        row = g.MODEL.anchors[0]
        up = snapshots(q.independent(row)); down = snapshots(q.independent((*row[:-1], 'down')))
        for slot in range(4):
            self.assertLess(int(up['0', 'init', slot]['left']), int(up['0', 'init', slot]['right']))
            self.assertGreater(int(down['0', 'init', slot]['left']), int(down['0', 'init', slot]['right']))
            for field in ('data', 'guard', 'ret', 'bits', 'tag'):
                self.assertEqual(up['0', 'probe', slot][field], down['0', 'probe', slot][field])

    def test_reversed_call_order_preserves_final_independent_scopes(self):
        row = g.MODEL.anchors[0]
        forward = snapshots(q.independent(row)); reverse = snapshots(q.independent((*row[:6], 'reverse', *row[7:])))
        for phase in ('0', '1'):
            for slot in range(4): self.assertEqual(forward[phase, 'idle', slot], reverse[phase, 'idle', slot])

    def test_z_is_captured_before_xor_and_bit_input_still_requires_fourstate(self):
        row = g.MODEL.anchors[1]
        seen = snapshots(q.independent(row))
        self.assertEqual(seen['1', 'init', 0]['data'], 'z' * 129)
        self.assertEqual(seen['1', 'first3', 0]['ret'], 'z' * 133)
        self.assertEqual(seen['1', 'first3', 0]['data'], 'x' * 129)
        bit = (row[0], 'bit', *row[2:])
        self.assertTrue(g.make_case(row).fourstate)
        self.assertTrue(g.make_case(bit).fourstate)
        self.assertEqual(snapshots(q.independent(bit))['1', 'init', 0]['data'], '0' * 129)

    def test_nine_real_source_mutations_change_interpreted_outputs(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 4); self.assertEqual(len(programs), 13)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_extra_process_unknown_statement_or_out_of_range_index_is_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        variants = (source.replace('  initial begin', '  initial begin\n    #1;', 1),
                    source.replace('saved = data[LEFT];', 'saved = data[999];', 1),
                    source.replace('return saved;', 'return $random;', 1),
                    source.replace('$finish;', '$finish; drive = 1;', 1))
        for mutant in variants:
            with self.assertRaises((AssertionError, ValueError)): q.interpret(mutant)


if __name__ == '__main__':
    unittest.main()
