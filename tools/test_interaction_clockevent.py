"""Clockvar retention, event fanout and unrelated notifications have separate witnesses."""

from collections import Counter
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_clockevent as generator
import lint_metadata
import qualify_clockevent as qualification


class ClockingNamedEvent(unittest.TestCase):
    def test_every_legal_row_matches_the_independent_emitted_statement_queue(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(qualification.independent(row), generator.reference(row))

    def test_selection_reaches_the_width_skew_trigger_lower_bound(self):
        model = generator.MODEL; selected = model.select()
        self.assertEqual(len(model.rows()), 192)
        self.assertEqual(len(selected), 24)
        self.assertEqual(Counter(len(target) for target in model.universe()), {2: 100, 3: 40})
        self.assertEqual({target for row in selected for target in model.targets(row)}, model.universe())
        self.assertTrue(set(model.anchors) <= set(selected))
        self.assertEqual(selected, model.select())

    def test_hand_checked_scalar_sampling_and_delayed_live_read(self):
        step = generator.reference(generator.MODEL.anchors[0])
        zero = generator.reference(('1', 'zero', 'posedge', 'blocking', 'blocking', '1'))
        self.assertIn('phase=0 time=5 bridge=1 noise=0 sample=0 live=0', step)
        self.assertIn('slot=0 hits=1 woke=2 late_at=4 seen=0 raw=1 held=0 late_raw=0', step)
        self.assertIn('slot=0 hits=1 woke=2 late_at=4 seen=1 raw=1 held=1 late_raw=0', zero)

    def test_every_frame_distinguishes_old_and_new_at_all_bits(self):
        for row in generator.MODEL.select():
            for old, new in generator.frames(row):
                self.assertEqual(len(old), int(row[0]))
                self.assertEqual(''.join('1' if bit == '0' else '0' for bit in old), new)

    def test_single_listener_keeps_inactive_slot_and_noise_does_not_wake_it(self):
        text = generator.reference(generator.MODEL.anchors[0])
        self.assertEqual(text.count('slot=1 hits=0 woke=-1 late_at=-1 seen=0 raw=0 held=0 late_raw=0'), 4)
        self.assertIn('phase=3 time=30 bridge=3 noise=3', text)
        self.assertIn('slot=0 hits=3 woke=22 late_at=24', text)

    def test_two_listeners_have_identical_data_but_independent_counters(self):
        row = ('65', 'step', 'negedge', 'nba', 'nba', '2')
        lines = generator.reference(row).splitlines()
        for index in range(0, len(lines), 3):
            self.assertEqual(lines[index+1].replace('slot=0', 'slot=1'), lines[index+2])

    def test_source_parser_detects_actual_input_and_observation_faults(self):
        row = generator.MODEL.anchors[0]
        source = generator.make_case(row).body
        for old, new in [('incoming = 1\'h1;', 'incoming = 1\'h0;'),
                         ('seen[0] = cb.data;', 'seen[0] = data;'),
                         ('-> ready;', '-> noise;'),
                         ('input #1step data;', 'input #0 data;'),
                         ('initial forever begin : listener_0', 'initial begin : listener_0')]:
            with self.subTest(old=old):
                self.assertIn(old, source)
                self.assertNotEqual(qualification.interpret(source.replace(old, new, 1)), generator.reference(row))

    def test_source_parser_rejects_unknown_syntax_instead_of_ignoring_it(self):
        source = generator.make_case(generator.MODEL.anchors[0]).body
        with self.assertRaises(AssertionError):
            qualification.interpret(source.replace("incoming = 1'h1;", 'incoming = opaque();', 1))

    def test_no_unspecified_waiter_order_or_procedural_zero_delay_is_observed(self):
        for row in generator.MODEL.select():
            source = generator.make_case(row).body
            self.assertNotIn('#0;', source)
            self.assertNotIn('->> #', source)
            self.assertEqual(source.count('initial forever begin : listener_'), int(row[5]))

    def test_selected_witnesses_pass_metadata_and_source_width_rules(self):
        with tempfile.TemporaryDirectory() as directory:
            chapter = Path(directory)/'ch14'; chapter.mkdir()
            for row in generator.MODEL.select():
                case = generator.make_case(row)
                source, expected = common.render(case, generator.NAME, 1, 14, 'spec')
                path = chapter/(case.name+'.sv'); path.write_text(source, encoding="utf-8")
                path.with_suffix('.expected').write_text(expected, encoding='utf-8')
                self.assertEqual(lint_metadata.check(path), [])


if __name__ == '__main__': unittest.main()
