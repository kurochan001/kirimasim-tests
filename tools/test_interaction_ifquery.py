"""Query-driven interface scans, dimension order and per-instance retention."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_ifquery as g
import qualify_ifquery as q


def snapshots(output):
    result, current = {}, None
    for line in output.splitlines():
        fields = dict(part.split('=', 1) for part in line.split()[1:])
        if line.startswith('h '):
            current = result[fields['p'], fields['step']] = {}
        else:
            key = (line[0], int(fields.pop('id')), fields.pop('dim', 'shape'))
            current[key] = fields
    return result


class InterfaceArrayQueryWalk(unittest.TestCase):
    def test_selection_covers_legal_pairs_triples_and_anchors_deterministically(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 4608)
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 274, 3: 96})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_legal_actual_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_does_not_call_primary_semantic_helpers(self):
        row = g.MODEL.anchors[1]
        source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'source', side_effect=AssertionError('source')), \
             patch.object(g, 'layout', side_effect=AssertionError('layout')), \
             patch.object(g, 'stimulus', side_effect=AssertionError('stimulus')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')), \
             patch.object(g, 'metrics', side_effect=AssertionError('queries')):
            self.assertEqual(q.interpret(source), expected)

    def test_metadata_and_comment_words_do_not_select_semantics(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// $size(data, 2); calls++;\n'), case.expected)

    def test_singleton_query_increment_and_hand_calculated_terminal(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        shape = values['0', 'before']['q', 0, '1']
        self.assertEqual(shape, {'left': '-4', 'right': '-4', 'low': '-4', 'high': '-4', 'increment': '1', 'size': '1'})
        self.assertEqual(values['0', 'first0']['v', 0, 'shape']['terminal'], '-5')
        self.assertEqual(values['0', 'first0']['v', 0, 'shape']['weight'], '-4')

    def test_unpacked_dimension_precedes_offset_packed_dimension(self):
        values = snapshots(q.independent(g.MODEL.anchors[4]))['0', 'before']
        self.assertEqual(values['q', 0, 'shape'], {'bits': '96', 'dims': '2', 'unpacked': '1'})
        self.assertEqual(values['q', 0, '1']['left'], '3')
        self.assertEqual(values['q', 0, '1']['right'], '5')
        self.assertEqual(values['q', 0, '2']['left'], '34')
        self.assertEqual(values['q', 0, '2']['right'], '3')
        self.assertEqual(values['q', 1, '2']['left'], '-2')
        self.assertEqual(values['q', 1, '2']['right'], '31')

    def test_default_and_explicit_first_dimension_have_same_results(self):
        row = g.MODEL.anchors[1]
        other = (*row[:6], 'default', *row[7:])
        self.assertEqual(q.independent(row), q.independent(other))

    def test_function_return_and_task_output_copy_preserve_local_width(self):
        row = g.MODEL.anchors[4]
        function = snapshots(q.independent(row))
        task = snapshots(q.independent((*row[:7], 'task', *row[8:])))
        self.assertEqual(function, task)
        for slot, padding in ((0, 4), (1, 2)):
            value = function['0', 'first' + str(slot)]['v', slot, 'shape']
            self.assertEqual(value['result'], '0' * padding + value['checksum'])

    def test_one_call_changes_only_its_receiver_and_result(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertEqual(values['0', 'before']['v', 1, 'shape'], values['0', 'first0']['v', 1, 'shape'])
        self.assertEqual(values['0', 'first0']['v', 0, 'shape']['calls'], '1')
        self.assertEqual(values['0', 'first0']['v', 1, 'shape']['calls'], '0')

    def test_refresh_retains_results_until_reverse_order_recall(self):
        row = g.MODEL.anchors[4]
        values = snapshots(q.independent(row))
        for slot in range(2):
            self.assertEqual(values['0', 'first0']['v', slot, 'shape']['checksum'],
                             values['0', 'refresh']['v', slot, 'shape']['checksum'])
        self.assertNotEqual(values['0', 'first0']['d', 0, 'shape'], values['0', 'refresh']['d', 0, 'shape'])
        self.assertEqual(values['0', 'first0']['d', 1, 'shape'], values['0', 'refresh']['d', 1, 'shape'])
        self.assertNotEqual(values['0', 'first0']['v', 1, 'shape']['guard'], values['0', 'refresh']['v', 1, 'shape']['guard'])

    def test_idle_preserves_history_and_each_phase_calls_twice(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        for phase in ('0', '1', '2'):
            self.assertEqual(values[phase, 'again0'], values[phase, 'idle'])
            for slot in range(2):
                self.assertEqual(values[phase, 'idle']['v', slot, 'shape']['calls'], str(2 * (int(phase) + 1)))

    def test_bit_input_conversion_and_logic_unknown_propagation(self):
        row = g.MODEL.anchors[1]
        logic = snapshots(q.independent(row))
        bit = snapshots(q.independent((*row[:1], 'bit', *row[2:])))
        self.assertIn('z', logic['1', 'before']['d', 0, 'shape']['0'])
        self.assertNotIn('z', bit['1', 'before']['d', 0, 'shape']['0'])
        self.assertIn('x', logic['1', 'first0']['v', 0, 'shape']['checksum'])
        self.assertNotIn('x', bit['1', 'first0']['v', 0, 'shape']['checksum'])
        self.assertTrue(g.make_case((*row[:1], 'bit', *row[2:])).fourstate)

    def test_complement_converts_z_to_x_and_recovery_restores_known_inputs(self):
        values = snapshots(q.independent(g.MODEL.anchors[1]))
        self.assertIn('z', values['1', 'before']['d', 0, 'shape']['2'])
        self.assertIn('x', values['1', 'refresh']['d', 0, 'shape']['2'])
        self.assertNotIn('z', values['1', 'refresh']['d', 0, 'shape']['2'])
        for bits in values['2', 'before']['d', 0, 'shape'].values():
            self.assertTrue(set(bits) <= {'0', '1'})

    def test_ordered_scan_is_not_a_commutative_element_xor(self):
        _, variants = q.variants()
        parent, source, _ = variants['reverse_walk']
        controls, _ = q.variants()
        actual, expected = snapshots(q.interpret(source)), snapshots(controls[parent].expected)
        self.assertNotEqual(actual['0', 'first0']['v', 0, 'shape']['checksum'],
                            expected['0', 'first0']['v', 0, 'shape']['checksum'])

    def test_nine_actual_source_mutations_change_observations(self):
        controls, programs = q.variants()
        self.assertEqual(len(controls), 5)
        self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                actual = q.interpret(source)
                if kind == 'control': self.assertEqual(actual, controls[parent].expected)
                else: self.assertNotEqual(actual, controls[parent].expected)

    def test_unsupported_programs_are_rejected_instead_of_guessed(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('calls++;', 'calls++; $random;', 1),
                    source.replace('data[at]', 'data[999]'),
                    source.replace('$size(data)', '$size(data, 3)'),
                    source.replace('$finish;', '$finish; ra=rb;')):
            with self.assertRaises((AssertionError, ValueError, KeyError)):
                q.interpret(bad)


if __name__ == '__main__':
    unittest.main()
