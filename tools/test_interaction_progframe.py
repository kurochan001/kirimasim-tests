"""Private task frames, copyout, early return and program-local cancellation."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_progframe as g
import qualify_progframe as q


def snapshots(output):
    result, current = {}, None
    for line in output.splitlines():
        fields = dict(part.split('=', 1) for part in line.split()[1:])
        if line.startswith('h '): current = result[fields['step']] = {}; continue
        owner = line[0]; lane = fields.pop('lane', None)
        current[owner + ('_' + lane if lane else '_flags' if 'parent' in fields else '')] = fields
    return result


def values(row): return snapshots(q.independent(row))


class ProgramTaskFrameLifetime(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(int(case.lrm.split()[0].split('.')[0]), g.CHAPTER)
            common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')

    def test_deterministic_legal_pair_triple_and_anchor_coverage(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()), 3456)
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 249, 3: 100})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_every_legal_saved_program_matches_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpretation_uses_no_primary_reference_or_stimulus_helpers(self):
        row = g.MODEL.anchors[1]; source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'source', side_effect=AssertionError('source')), \
             patch.object(g, 'actual', side_effect=AssertionError('binding')), \
             patch.object(g, 'pattern', side_effect=AssertionError('pattern')), \
             patch.object(g, 'inputs', side_effect=AssertionError('inputs')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')), \
             patch.object(g, 'xor', side_effect=AssertionError('xor')):
            self.assertEqual(q.interpret(source), expected)

    def test_comment_and_metadata_words_do_not_choose_semantics(self):
        case = g.make_case(g.MODEL.anchors[0]); source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        self.assertEqual(q.interpret(source + '\n// return; $exit; #0;\n'), case.expected)

    def test_hand_calculated_one_bit_private_staging_and_copyout(self):
        v = values(g.MODEL.anchors[0])
        self.assertEqual(v['entry_first']['p']['a'], '1001')
        self.assertEqual(v['entry_first']['p_a']['entry'], '1')
        self.assertEqual(v['entry_first']['p_a']['local'], '0')
        self.assertEqual(v['first_return']['q']['a'], '0000')
        self.assertEqual(v['first_return']['p']['a'], v['refresh']['p']['a'])

    def test_before_exit_cancels_both_calls_and_no_copyout(self):
        v = values(g.MODEL.anchors[0])
        for step in ('first_return', 'after_stop', 'complete'):
            self.assertEqual(v[step]['p'], v['refresh']['p'])
            for lane in ('a', 'b'):
                self.assertEqual(v[step]['p_' + lane]['done'], '0')
                self.assertEqual(v[step]['p_' + lane]['returned'], '0')
        self.assertEqual(v['complete']['p_flags']['after'], '0')

    def test_between_exit_copies_only_first_call_in_actual_order(self):
        row = g.MODEL.anchors[1]; v = values(row)
        self.assertEqual(v['complete']['p_a']['done'], '0')
        self.assertEqual(v['complete']['p_b']['done'], '1')
        self.assertEqual(v['complete']['p']['a'], v['refresh']['p']['a'])
        self.assertNotEqual(v['complete']['p']['b'], v['refresh']['p']['b'])

    def test_other_program_survives_and_recovers_for_every_stop_mode(self):
        for stop in ('before', 'between', 'natural'):
            row = list(g.MODEL.anchors[1]); row[6] = stop; v = values(tuple(row))
            self.assertEqual(v['idle']['q_a']['done'], '2')
            self.assertEqual(v['idle']['q_b']['done'], '1')
            self.assertEqual(v['idle']['q_flags']['recovered'], '1')
            self.assertEqual(v['idle']['q_flags']['stop'], '0')

    def test_early_return_copies_out_but_skips_tail(self):
        row = g.MODEL.anchors[4]; v = values(row)
        self.assertEqual(v['first_return']['p_a']['returned'], '1')
        self.assertEqual(v['first_return']['p_a']['tail'], '0')
        self.assertNotEqual(v['first_return']['p']['a'], v['refresh']['p']['a'])

    def test_normal_end_runs_tail_and_preserves_task_history(self):
        v = values(g.MODEL.anchors[5])
        self.assertEqual(v['idle']['q_a']['tail'], '2')
        self.assertEqual(v['idle']['q_b']['tail'], '1')
        self.assertEqual(v['idle'], v['recovered'])

    def test_inout_samples_before_external_actual_update(self):
        v = values(g.MODEL.anchors[5])
        self.assertEqual(v['entry_both']['q_b']['entry'], v['complete']['q_b']['late'])
        self.assertNotEqual(v['entry_both']['q_b']['entry'], v['refresh']['q']['src_b'])

    def test_signed_formal_controls_widened_copyout(self):
        row = g.MODEL.anchors[4]; signed = values(row)
        unsigned = values((*row[:3], 'u', *row[4:]))
        self.assertEqual(signed['first_return']['p']['a'][:3], '111')
        self.assertEqual(unsigned['first_return']['p']['a'][:3], '000')
        self.assertEqual(signed['first_return']['p']['a'][3:], unsigned['first_return']['p']['a'][3:])

    def test_xz_capture_bit_conversion_and_fourstate_metadata(self):
        row = g.MODEL.anchors[1]; logic = values(row)
        bit = values((row[0], 'bit', *row[2:]))
        self.assertEqual(logic['entry_both']['p_a']['entry'], 'x' * 129)
        self.assertTrue(set(bit['entry_both']['p_a']['entry']) <= {'0', '1'})
        self.assertTrue(g.make_case((row[0], 'bit', *row[2:])).fourstate)

    def test_known_reset_precedes_recovery_without_erasing_counts(self):
        v = values(g.MODEL.anchors[2])
        self.assertEqual(v['reset']['p_a']['entered'], '1')
        self.assertEqual(v['recovered']['p_a']['entered'], '2')
        self.assertTrue(set(v['recovered']['p']['a']) <= {'0', '1'})
        self.assertIn('z', v['recovered']['q_b']['entry'])

    def test_scalar_array_binding_and_unselected_guards(self):
        row = g.MODEL.anchors[1]; v = values(row)
        self.assertEqual(q.independent(row), q.independent((*row[:5], 'scalar', *row[6:])))
        for snapshot in v.values():
            for owner in ('p', 'q'):
                self.assertEqual(snapshot[owner]['guard'], v['entry_first'][owner]['guard'])

    def test_six_controls_and_nine_actual_sv_faults(self):
        controls, programs = q.variants(); self.assertEqual(len(controls), 6); self.assertEqual(len(programs), 15)
        for name, (parent, source, kind) in programs.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_unsupported_syntax_and_invalid_actuals_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for bad in (source.replace('task automatic', 'task static'),
                    source.replace('transfer(p_src_a, p_a, 0, 6)', 'transfer(p_src_a, p_no, 0, 6)'),
                    source.replace('held=sampled;', 'held=$random;'),
                    source.replace('join\n', 'join_none\n')):
            with self.assertRaises((AssertionError, ValueError, KeyError)): q.interpret(bad)


if __name__ == '__main__': unittest.main()
