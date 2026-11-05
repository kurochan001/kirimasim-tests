"""Scan stopping, query-sized character fields and full-word preservation."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_scansel as g
import qualify_scansel as q


def snapshots(output):
    result, current = {}, None
    for line in output.splitlines():
        if line.startswith('h '):
            # Text/format have no spaces in the deliberately bounded grammar.
            fields = dict(part.split('=', 1) for part in line.split()[1:])
            current = result[fields.pop('p'), fields.pop('step')] = {'h': fields}
        else: current['v'] = dict(part.split('=', 1) for part in line.split()[1:])
    return result


class FormattedScanPartialWrite(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(int(case.lrm.split()[0].split('.')[0]), g.CHAPTER)
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_deterministic_legal_pair_triple_and_anchor_coverage(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 5760)
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 292, 3: 142})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)
        self.assertFalse(any(row[5] == 'whole' and row[7] == 'high' for row in g.MODEL.rows()))

    def test_every_legal_saved_program_matches_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_primary_reference_or_stimulus_helpers(self):
        row = g.MODEL.anchors[1]; source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'source', side_effect=AssertionError('source')), \
             patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'target', side_effect=AssertionError('lvalue')), \
             patch.object(g, 'limit', side_effect=AssertionError('query')), \
             patch.object(g, 'input_text', side_effect=AssertionError('stimulus')), \
             patch.object(g, 'numeric_token', side_effect=AssertionError('digits')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')):
            self.assertEqual(q.interpret(source), expected)

    def test_comment_and_metadata_words_do_not_choose_semantics(self):
        case = g.make_case(g.MODEL.anchors[0]); source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// $sscanf(text, fmt, wb, wa, tag);\n'), case.expected)

    def test_hand_calculated_one_bit_success(self):
        values = snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertEqual(values['0', 'trial']['h']['rc'], '3')
        self.assertEqual(values['0', 'trial']['h']['tag'], '7')
        self.assertEqual(values['0', 'trial']['v']['a'], '1')
        self.assertEqual(values['0', 'trial']['v']['b'], '01')
        self.assertEqual(values['0', 'trial']['v']['wa'], values['0', 'before']['v']['wa'])

    def test_overlong_first_field_assigns_prefix_then_stops_at_literal(self):
        values = snapshots(q.independent(g.MODEL.anchors[4]))
        before, trial = values['0', 'before'], values['0', 'trial']
        self.assertEqual(trial['h']['rc'], '1')
        self.assertEqual(trial['h']['tag'], '-91')
        self.assertEqual(trial['v']['wb'], before['v']['wb'])
        self.assertNotEqual(trial['v']['wa'], before['v']['wa'])
        self.assertEqual(values['0', 'again']['h']['rc'], '3')
        self.assertEqual(values['0', 'again']['h']['tag'], '8')

    def test_second_conversion_mismatch_preserves_second_destination_and_marker(self):
        values = snapshots(q.independent(g.MODEL.anchors[2]))
        for phase in ('0', '1', '2'):
            before, trial = values[phase, 'before'], values[phase, 'trial']
            self.assertEqual(trial['h']['rc'], '1')
            self.assertEqual(trial['h']['tag'], before['h']['tag'])
            self.assertEqual(trial['v']['wb'], before['v']['wb'])

    def test_empty_input_returns_eof_and_preserves_all_prior_outputs(self):
        values = snapshots(q.independent(g.MODEL.anchors[3]))
        for phase in ('0', '1', '2'):
            before, trial = values[phase, 'before'], values[phase, 'trial']
            self.assertEqual(trial['h']['rc'], '-1')
            self.assertEqual(trial['h']['tag'], before['h']['tag'])
            self.assertEqual(trial['v'], before['v'])

    def test_indexed_select_spelling_has_same_semantics(self):
        row = g.MODEL.anchors[2]
        self.assertEqual(q.independent(row), q.independent((*row[:5], 'minus', *row[6:])))

    def test_literal_and_runtime_format_contents_agree_in_reference_semantics(self):
        row = g.MODEL.anchors[1]
        self.assertEqual(q.independent(row), q.independent((*row[:8], 'literal')))

    def test_hex_field_width_counts_characters_instead_of_bits(self):
        values = snapshots(q.independent(g.MODEL.anchors[4]))['0', 'trial']
        self.assertEqual(values['h']['fmt'], '[%39h|%b|%d]')
        self.assertEqual(values['v']['bits_a'], '32')
        self.assertEqual(values['v']['field'], '39')
        token = 'a5c3' * 10
        self.assertEqual(values['v']['seen_a'], f'{int(token[:39], 16) & 0xffffffff:032b}')

    def test_all_unselected_guard_bits_are_preserved(self):
        for row in (g.MODEL.anchors[1], g.MODEL.anchors[2], g.MODEL.anchors[4]):
            values = snapshots(q.independent(row)); width = int(row[0]); total = width + 7
            base = 7 if row[7] == 'high' else 0
            before, after = values['0', 'before']['v']['wa'], values['0', 'again']['v']['wa']
            for bit in set(range(total)) - set(range(base, base + width)):
                self.assertEqual(before[total - bit - 1], after[total - bit - 1])

    def test_xz_digits_are_known_ascii_and_destination_conversion_is_separate(self):
        row = g.MODEL.anchors[1]; logic = snapshots(q.independent(row))
        bit = snapshots(q.independent((row[0], 'bit', *row[2:])))
        self.assertIn('z', logic['1', 'again']['v']['seen_a'])
        self.assertIn('x', logic['1', 'again']['v']['seen_b'])
        self.assertEqual(bit['1', 'again']['v']['seen_a'], '0' * 129)
        self.assertEqual(bit['1', 'again']['v']['seen_b'], '0' * 130)
        self.assertTrue(g.make_case((row[0], 'bit', *row[2:])).fourstate)

    def test_followup_and_known_recovery_keep_history_without_resetting(self):
        values = snapshots(q.independent(g.MODEL.anchors[3]))
        self.assertEqual(values['1', 'before']['v'], values['0', 'idle']['v'])
        self.assertEqual(values['2', 'before']['h']['tag'], '18')
        self.assertEqual(values['2', 'again']['h']['tag'], '28')
        self.assertTrue(set(values['2', 'again']['v']['seen_a']) <= {'0', '1'})
        for phase in ('0', '1', '2'): self.assertEqual(values[phase, 'guard'], values[phase, 'idle'])

    def test_six_controls_and_nine_actual_sv_faults(self):
        controls, programs = q.variants(); self.assertEqual(len(controls), 6); self.assertEqual(len(programs), 15)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unsupported_formats_and_out_of_range_targets_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('%1b|%b|%d', '%1f|%b|%d'),
                    source.replace('a, b, tag);', 'wa[99 +: 1], b, tag);'),
                    source.replace('rc=-77;', 'rc=-77; $random;'),
                    source.replace('$finish;', '$finish; a=0;')):
            with self.assertRaises((AssertionError, ValueError, KeyError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
