"""Scalar strength formatting at contention, pull and release boundaries."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_strengthfmt as strength


class StrengthFormatSemantics(unittest.TestCase):
    def test_known_resolution_distinguishes_floating_contention_and_dominance(self):
        self.assertEqual(strength.resolved('wire','equal_weak','z','z'),('z','HiZ'))
        self.assertEqual(strength.resolved('wire','equal_weak','0','1'),('x','WeX'))
        self.assertEqual(strength.resolved('wire','a_stronger','0','1'),('0','St0'))
        self.assertEqual(strength.resolved('wire','b_stronger','0','1'),('1','St1'))

    def test_pull_defaults_compete_at_pull_strength_and_yield_to_strong(self):
        self.assertEqual(strength.resolved('tri0','equal_weak','1','1'),('0','Pu0'))
        self.assertEqual(strength.resolved('tri1','equal_weak','z','z'),('1','Pu1'))
        self.assertEqual(strength.resolved('tri0','equal_pull','1','z'),('x','PuX'))
        self.assertEqual(strength.resolved('tri1','a_stronger','0','1'),('0','St0'))

    def test_write_order_exposes_half_updates_and_release_order(self):
        ab=strength.observations(('wire','equal_weak','ab','display','normal'))
        ba=strength.observations(('wire','equal_weak','ba','display','normal'))
        self.assertEqual(ab[:3],[('idle','z','z'),('p0_half','0','z'),('p0_full','0','1')])
        self.assertEqual(ba[:3],[('idle','z','z'),('p0_half','z','1'),('p0_full','0','1')])
        self.assertEqual(ab[-2:],[('release_half','z','1'),('release_full','z','z')])
        self.assertEqual(ba[-2:],[('release_half','1','z'),('release_full','z','z')])

    def test_string_apis_share_the_full_literal_protocol(self):
        expected=(
            'slot=idle a=z b=z value=z\nstrength=HiZ guard0=Su0 guard1=Su1\n'
            'slot=p0_half a=0 b=z value=0\nstrength=We0 guard0=Su0 guard1=Su1\n'
            'slot=p0_full a=0 b=1 value=x\nstrength=WeX guard0=Su0 guard1=Su1\n'
            'slot=p1_half a=1 b=1 value=1\nstrength=We1 guard0=Su0 guard1=Su1\n'
            'slot=p1_full a=1 b=0 value=x\nstrength=WeX guard0=Su0 guard1=Su1\n'
            'slot=p2_half a=0 b=0 value=0\nstrength=We0 guard0=Su0 guard1=Su1\n'
            'slot=p2_full a=0 b=0 value=0\nstrength=We0 guard0=Su0 guard1=Su1\n'
            'slot=p3_half a=1 b=0 value=x\nstrength=WeX guard0=Su0 guard1=Su1\n'
            'slot=p3_full a=1 b=1 value=1\nstrength=We1 guard0=Su0 guard1=Su1\n'
            'slot=release_half a=z b=1 value=1\nstrength=We1 guard0=Su0 guard1=Su1\n'
            'slot=release_full a=z b=z value=z\nstrength=HiZ guard0=Su0 guard1=Su1\n')
        for api in ('display','sformatf','swrite'):
            self.assertEqual(strength.reference(('wire','equal_weak','ab',api,'normal')),expected)


if __name__=='__main__':
    unittest.main()
