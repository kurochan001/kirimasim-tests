"""Concrete observations at the clocking/assertion sampling boundary."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_clockassert as clockassert


class ClockAssertionSemantics(unittest.TestCase):
    def test_edge_nba_is_live_in_actions_but_not_in_the_clockvar(self):
        row = ('1', 'bit', 'posedge', 'negedge', 'edge', 'nba', 'explicit')
        self.assertEqual(clockassert.reference(row),
            'phase=0 before=0 source=1\n'
            'clock pass=0 fail=1 sampled=0 live=1\n'
            'held pass=0 fail=1 sampled=0 live=1\n'
            'raw pass=1 fail=0 sampled=1 live=1\nfinal clockvar=0 data=1\n'
            'phase=1 before=1 source=0\n'
            'clock pass=1 fail=1 sampled=1 live=0\n'
            'held pass=1 fail=1 sampled=1 live=0\n'
            'raw pass=1 fail=1 sampled=0 live=0\nfinal clockvar=1 data=0\n'
            'phase=2 before=0 source=1\n'
            'clock pass=1 fail=2 sampled=0 live=1\n'
            'held pass=1 fail=2 sampled=0 live=1\n'
            'raw pass=2 fail=1 sampled=1 live=1\nfinal clockvar=0 data=1\n')

    def test_between_clocks_retains_the_sample_and_distinguishes_action_times(self):
        row = ('1', 'logic', 'negedge', 'posedge', 'between', 'blocking', 'default')
        text = clockassert.reference(row)
        self.assertIn('clock pass=0 fail=1 sampled=0 live=0\n', text)
        self.assertIn('held pass=0 fail=1 sampled=0 live=1\n', text)
        self.assertIn('raw pass=1 fail=0 sampled=1 live=1\n', text)
        self.assertIn('final clockvar=0 data=1\n', text)

    def test_early_write_reaches_both_clocks_with_all_wide_bits_preserved(self):
        row = ('33', 'logic', 'posedge', 'posedge', 'early', 'nba', 'default')
        self.assertEqual(clockassert.phases(row)[2], (0xAAAAAAAA, 0x155555555))
        text = clockassert.reference(row)
        value = format(0x155555555, '033b')
        for name in ('clock', 'held', 'raw'):
            self.assertIn(f'{name} pass=2 fail=1 sampled={value} live={value}\n', text)

    def test_default_one_step_and_polarity_changes_preserve_the_protocol(self):
        expected = None
        for declaration in ('default', 'explicit'):
            for sample_edge in ('posedge', 'negedge'):
                for probe_edge in ('posedge', 'negedge'):
                    row = ('8', 'bit', sample_edge, probe_edge, 'between', 'nba', declaration)
                    value = clockassert.reference(row)
                    if expected is None:
                        expected = value
                    self.assertEqual(value, expected)


if __name__ == '__main__':
    unittest.main()
