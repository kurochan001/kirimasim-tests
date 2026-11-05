"""Typed elaboration boundaries and independently interpreted generated SV."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_genexpr as g
import qualify_genexpr as q


def snapshots(output):
    result, current = {}, None
    for line in output.splitlines():
        fields = dict(part.split('=', 1) for part in line.split()[1:])
        if line.startswith('h '):
            current = result[fields.pop('p'), fields.pop('step'), int(fields.pop('id'))] = {'h': fields}
        elif line.startswith('q '):
            fields.pop('id'); current['q'] = fields
        else:
            fields.pop('id'); current[int(fields.pop('lane'))] = fields
    return result


class GeneratedConstantExpressionShape(unittest.TestCase):
    def test_primary_clause_matches_generator_and_matrix_chapter(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(int(case.lrm.split()[0].split('.')[0]), g.CHAPTER)

    def test_deterministic_legal_selection_covers_pairs_triples_and_anchors(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 6912)
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 297, 3: 132})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_legal_actual_programs_agree_with_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_independent_interpretation_uses_no_primary_semantic_helpers(self):
        row = g.MODEL.anchors[1]; source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'source', side_effect=AssertionError('source')), \
             patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'constants', side_effect=AssertionError('constants')), \
             patch.object(g, 'word', side_effect=AssertionError('stimulus')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')), \
             patch.object(g, 'flipped', side_effect=AssertionError('xor')):
            self.assertEqual(q.interpret(source), expected)

    def test_metadata_and_comments_do_not_choose_semantics(self):
        case = g.make_case(g.MODEL.anchors[0]); source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// E = A ^ B; SELECT=4;\n'), case.expected)

    def test_scalar_signed_add_is_widened_before_arithmetic(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))['0', 'all', 0]
        self.assertEqual(values['h'], {'a': '1', 'b': '1', 'e': '10', 'dec': '-2'})
        self.assertEqual(values['q'], {'neg': '1', 'count': '3', 'width': '4', 'bits': '2', 'kind': '1'})
        narrow = (*g.MODEL.anchors[0][:6], 'same', *g.MODEL.anchors[0][7:])
        other = snapshots(q.independent(narrow))['0', 'all', 0]
        self.assertEqual(other['h']['e'], '0')
        self.assertEqual(other['q']['count'], '1')

    def test_mixed_sign_operands_zero_extend_even_into_signed_result(self):
        row = g.MODEL.anchors[1]; values = snapshots(q.independent(row))['0', 'all', 0]
        self.assertEqual(values['h']['e'], '0' + '1' * 129)
        self.assertEqual(values['q']['neg'], '0')
        signed_rhs = (*row[:4], 's', *row[5:])
        other = snapshots(q.independent(signed_rhs))['0', 'all', 0]
        self.assertEqual(other['h']['e'], '1' * 130)
        self.assertEqual(other['q']['neg'], '1')

    def test_destination_sign_changes_interpretation_after_equal_bit_calculation(self):
        row = g.MODEL.anchors[4]; a = snapshots(q.independent(row))['0', 'all', 0]
        b = snapshots(q.independent((*row[:5], 'u', *row[6:])))['0', 'all', 0]
        self.assertEqual(a['h']['e'], b['h']['e'])
        self.assertNotEqual(a['h']['dec'], b['h']['dec'])
        self.assertNotEqual(a['q']['kind'], b['q']['kind'])
        self.assertEqual(a['q']['count'], b['q']['count'])

    def test_if_and_case_generate_select_the_same_scopes(self):
        row = g.MODEL.anchors[1]
        self.assertEqual(q.independent(row), q.independent((*row[:8], 'if', row[9])))

    def test_named_and_positional_parameter_bindings_agree(self):
        row = g.MODEL.anchors[4]
        self.assertEqual(q.independent(row), q.independent((*row[:9], 'positional')))

    def test_bits_query_drives_width_and_genvar_changes_actual_width(self):
        row = g.MODEL.anchors[1]; values = snapshots(q.independent(row))['0', 'all', 0]
        self.assertEqual(values['q']['bits'], '130')
        self.assertEqual(values['q']['width'], '131')
        self.assertEqual(values[0]['bits'], '131')
        self.assertEqual(values[1]['bits'], '132')

    def test_single_raw_update_keeps_other_elements_and_instance(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertNotEqual(values['0', 'all', 0][0]['raw'], values['0', 'input', 0][0]['raw'])
        self.assertEqual(values['0', 'all', 0][1], values['0', 'input', 0][1])
        self.assertEqual(values['0', 'all', 1], values['0', 'input', 1])

    def test_guard_update_and_idle_do_not_modify_continuous_results(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        before, after = values['0', 'input', 1], values['0', 'guard', 1]
        last = int(before['q']['count']) - 1
        self.assertNotEqual(before[last]['guard'], after[last]['guard'])
        for lane in range(last + 1): self.assertEqual(before[lane]['value'], after[lane]['value'])
        for phase in ('0', '1', '2'):
            for slot in range(2): self.assertEqual(values[phase, 'guard', slot], values[phase, 'idle', slot])

    def test_runtime_unknown_conversion_is_separate_from_known_elaboration(self):
        row = g.MODEL.anchors[1]; logic = snapshots(q.independent(row))
        bit = snapshots(q.independent((row[0], 'bit', *row[2:])))
        self.assertEqual(logic['0', 'all', 0]['h'], logic['1', 'all', 0]['h'])
        self.assertIn('z', logic['1', 'all', 0][0]['raw'])
        self.assertNotIn('z', bit['1', 'all', 0][0]['raw'])
        self.assertIn('x', logic['1', 'input', 0][0]['raw'])
        self.assertNotIn('z', logic['1', 'input', 0][0]['raw'])
        self.assertTrue(g.make_case((row[0], 'bit', *row[2:])).fourstate)

    def test_known_recovery_restores_each_element(self):
        values = snapshots(q.independent(g.MODEL.anchors[1]))
        for slot in range(2):
            data = values['2', 'all', slot]
            for lane in range(int(data['q']['count'])):
                self.assertTrue(set(data[lane]['raw']) <= {'0', '1'})
                self.assertTrue(set(data[lane]['value']) <= {'0', '1'})

    def test_nine_actual_source_faults_change_observations(self):
        controls, programs = q.variants(); self.assertEqual(len(controls), 5); self.assertEqual(len(programs), 14)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unsupported_syntax_and_unelaborated_hierarchies_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('E = A + B', 'E = A / B'),
                    source.replace('a.choice.g[0]', 'a.choice.g[99]'),
                    source.replace('#1;', '#1; $random;', 1),
                    source.replace('$finish;', '$finish; a.choice.g[0].raw=0;')):
            with self.assertRaises((AssertionError, ValueError, KeyError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
