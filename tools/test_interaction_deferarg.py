"""Deferred input snapshots and static references keep distinct observation paths."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_deferarg as g
import lint_metadata
import qualify_deferarg as q


class DeferredArgumentCapture(unittest.TestCase):
    def test_legal_rows_reject_only_zero_width_and_inequivalent_refs(self):
        self.assertEqual(prod(len(levels) for _, levels in g.MODEL.factors), 576)
        self.assertEqual(len(g.MODEL.rows()), 368)
        for row in g.MODEL.rows():
            self.assertGreater(g.formal_width(row), 0)
            if row[2] == 'constref': self.assertEqual(g.formal_width(row), int(row[0]))

    def test_selection_preserves_all_targets_and_seven_boundary_anchors(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 29)
        self.assertEqual(len(g.MODEL.anchors), 7)
        self.assertEqual(Counter(len(t) for t in g.MODEL.universe()), {2: 145, 3: 71})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(selected, g.MODEL.select())

    def test_every_legal_row_matches_the_independent_emitted_sv_interpreter(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_independent_interpreter_never_calls_expected_value_or_resize_helpers(self):
        row = g.MODEL.anchors[0]; want = g.reference(row)
        with patch.object(g, 'reference', side_effect=AssertionError('oracle called')), \
             patch.object(g, 'converted', side_effect=AssertionError('conversion called')):
            self.assertEqual(q.independent(row), want)

    def test_hand_checked_signed_scalar_widening_and_reference_value(self):
        self.assertIn('cap=1 arg=11 live=0 dec=-1 bits=2 ready=1 calls=1',
                      g.reference(g.MODEL.anchors[0]))
        row = ('1', 'signed', 'constref', 'same', 'task', 'final', 'nba')
        self.assertIn('r p=2 t=22 cap=0 arg=1 live=1 dec=-1 bits=1 ready=1 calls=3', g.reference(row))

    def test_narrow_input_loses_only_high_bits_at_the_word_boundary(self):
        row = ('33', 'unsigned', 'input', 'narrow', 'task', 'observed', 'nba')
        line = g.reference(row).splitlines()[2]
        self.assertIn('arg=' + '0' * 32 + ' live=', line)
        self.assertIn('dec=0 bits=32', line)

    def test_signedness_and_formal_width_affect_the_observed_decimal(self):
        signed = g.reference(g.MODEL.anchors[0])
        unsigned = g.reference(('1', 'unsigned', 'input', 'wide', 'function', 'observed', 'blocking'))
        self.assertIn('arg=11 live=0 dec=-1', signed)
        self.assertIn('arg=01 live=0 dec=1', unsigned)

    def test_every_frame_flips_all_source_bits_and_keeps_idle_observation(self):
        for row in g.MODEL.select():
            for old, new in g.frames(row):
                self.assertEqual(len(old), int(row[0]))
                self.assertEqual(''.join(str(1 - int(x)) for x in old), new)
            self.assertTrue(g.reference(row).endswith('ready=1 calls=3\n'))
            self.assertIn('end t=30', g.reference(row))

    def test_routines_and_regions_use_distinct_legal_sv_paths_without_writing_actions(self):
        for row in g.MODEL.select():
            source = g.source(row)
            self.assertIn('task automatic report' if row[4] == 'task' else 'function automatic void report', source)
            self.assertIn('assert #0 (1)' if row[5] == 'observed' else 'assert final (1)', source)
            self.assertNotIn('#0;', source)
            body = source.split('report(', 1)[1].split('endtask' if row[4] == 'task' else 'endfunction', 1)[0]
            self.assertEqual(body.count('$display'), 1)
            self.assertNotIn('calls++', body)

    def test_source_interpreter_reads_actual_values_modes_and_observation_expressions(self):
        row = g.MODEL.anchors[0]; source = g.source(row); want = g.reference(row)
        for old, new in [("value = 1'h1;", "value = 1'h0;"),
                         ('calls++;', 'calls += 0;'), ('ready = 1;', 'ready = 0;'),
                         ('phase, $time, captured, arg, value', 'phase, $time, value, arg, value')]:
            with self.subTest(old=old):
                self.assertIn(old, source)
                self.assertNotEqual(q.interpret(source.replace(old, new, 1)), want)

    def test_unknown_emitted_syntax_is_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        with self.assertRaises(AssertionError): q.interpret(source.replace("value = 1'h1;", 'value = opaque();', 1))
        with self.assertRaises(AssertionError): q.interpret(source.replace('calls++;', 'calls--;', 1))

    def test_selected_cases_pass_metadata_and_line_width_rules(self):
        with tempfile.TemporaryDirectory() as directory:
            chapter = Path(directory) / 'ch13'; chapter.mkdir()
            for row in g.MODEL.select():
                case = g.make_case(row); source, expected = common.render(case, g.NAME, 1, 13, 'spec')
                path = chapter / (case.name + '.sv'); path.write_text(source, encoding="utf-8")
                path.with_suffix('.expected').write_text(expected, encoding='utf-8')
                self.assertEqual(lint_metadata.check(path), [])


if __name__ == '__main__':
    unittest.main()
