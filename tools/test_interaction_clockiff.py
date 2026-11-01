"""Clocking iff acceptance, held samples and guard-only changes."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_clockiff as clockiff


class ClockingIffSemantics(unittest.TestCase):
    def test_one_step_before_guard_protocol(self):
        self.assertEqual(clockiff.reference(('1','bit','posedge','step','nba','scalar','before')),
            'warm gate=1 raw=1 hits=1\ndata=0 cb=0 seen=0\n'
            'p0_pre gate=0 raw=1 hits=1\ndata=1 cb=0 seen=0\n'
            'p0_edge gate=0 raw=2 hits=1\ndata=0 cb=0 seen=0\n'
            'p0_late gate=0 raw=2 hits=1\ndata=0 cb=0 seen=0\n'
            'p1_pre gate=1 raw=2 hits=1\ndata=0 cb=0 seen=0\n'
            'p1_edge gate=1 raw=3 hits=2\ndata=1 cb=0 seen=0\n'
            'p1_late gate=1 raw=3 hits=2\ndata=1 cb=0 seen=0\n'
            'p2_pre gate=0 raw=3 hits=2\ndata=0 cb=0 seen=0\n'
            'p2_edge gate=0 raw=4 hits=2\ndata=1 cb=0 seen=0\n'
            'p2_late gate=0 raw=4 hits=2\ndata=1 cb=0 seen=0\n'
            'p3_pre gate=1 raw=4 hits=2\ndata=1 cb=0 seen=0\n'
            'p3_edge gate=1 raw=5 hits=3\ndata=0 cb=1 seen=1\n'
            'p3_late gate=1 raw=5 hits=3\ndata=0 cb=1 seen=1\n')

    def test_late_guard_changes_do_not_sample_current_live_data(self):
        text=clockiff.reference(('1','logic','posedge','zero','blocking','scalar','after'))
        self.assertIn('p1_late gate=1 raw=3 hits=2\ndata=1 cb=0 seen=0\n',text)
        self.assertIn('p3_late gate=1 raw=5 hits=3\ndata=0 cb=1 seen=1\n',text)

    def test_wide_high_bit_is_true_and_zero_guard_has_no_set_bits(self):
        self.assertEqual(clockiff.gate_bits('wide_high',True),'1'+'0'*32)
        self.assertEqual(clockiff.gate_bits('wide_low',True),'0'*32+'1')
        self.assertEqual(clockiff.gate_bits('wide_high',False),'0'*33)
        row=('33','logic','negedge','zero','nba','wide_high','before')
        text=clockiff.reference(row)
        self.assertIn('p3_edge gate='+'1'+'0'*32+' raw=5 hits=3\n',text)

    def test_known_storage_polarity_and_write_region_controls_are_equivalent(self):
        expected=clockiff.reference(('8','bit','posedge','step','blocking','scalar','after'))
        for state in ('bit','logic'):
            for edge in ('posedge','negedge'):
                for update in ('blocking','nba'):
                    self.assertEqual(clockiff.reference(('8',state,edge,'step',update,'scalar','after')),expected)


if __name__=='__main__':
    unittest.main()
