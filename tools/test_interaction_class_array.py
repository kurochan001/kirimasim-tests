"""Observable storage independence, nested aliases and retained element handles."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_class_array as arrays


class ClassArraySemantics(unittest.TestCase):
    def test_single_element_shallow_copy_keeps_distinct_array_storage(self):
        row=('fixed','1','1','first','shallow','copy','element')
        self.assertEqual(arrays.reference(row),
            'stage=copied same_holder=0 ctor=2 old=1\n'
            'same_first=1 old_source=1 old_copy=1\n'
            'source stamp=1 size=1\nsource[0] word=0 ref=1\n'
            'copy stamp=1 size=1\ncopy[0] word=0 ref=1\n'
            'guard stamp=2 size=1\nguard[0] word=1 ref=0\n'
            'stage=shared same_holder=0 ctor=2 old=0\n'
            'same_first=1 old_source=1 old_copy=1\n'
            'source stamp=1 size=1\nsource[0] word=0 ref=0\n'
            'copy stamp=1 size=1\ncopy[0] word=0 ref=0\n'
            'guard stamp=2 size=1\nguard[0] word=1 ref=0\n'
            'stage=changed same_holder=0 ctor=2 old=0\n'
            'same_first=0 old_source=1 old_copy=0\n'
            'source stamp=1 size=1\nsource[0] word=0 ref=0\n'
            'copy stamp=1 size=1\ncopy[0] word=1 ref=1\n'
            'guard stamp=2 size=1\nguard[0] word=1 ref=0\n'
            'stage=retained same_holder=0 ctor=2 old=1\n'
            'same_first=0 old_source=1 old_copy=0\n'
            'source stamp=1 size=1\nsource[0] word=0 ref=1\n'
            'copy stamp=1 size=1\ncopy[0] word=1 ref=1\n'
            'guard stamp=2 size=1\nguard[0] word=1 ref=0\n')

    def test_alias_control_shares_replaced_elements_and_drops_the_old_reference(self):
        row=('queue','8','3','last','alias','source','element')
        changed=arrays.reference(row).split('stage=changed',1)[1].split('stage=retained',1)[0]
        self.assertIn('same_holder=1 ctor=2 old=00000000',changed)
        self.assertIn('same_first=1 old_source=0 old_copy=0',changed)
        for owner in ('source','copy'):
            self.assertIn(f'{owner}[2] word=11111111 ref=11111111',changed)

    def test_resize_preserves_prefix_defaults_and_external_handle(self):
        grown=arrays.reference(('dynamic','33','1','first','shallow','copy','resize'))
        self.assertIn('copy[2] word='+'0'*33+' ref=null',grown)
        self.assertEqual(grown.count('guard stamp=2 size=1'),4)
        shrunk=arrays.reference(('queue','8','3','last','shallow','copy','resize'))
        retained=shrunk.split('stage=retained',1)[1]
        self.assertIn('old_source=1 old_copy=0',retained)
        self.assertIn('source[2] word=00000000 ref=11111111',retained)
        self.assertIn('copy stamp=1 size=1',retained)

    def test_fixed_resize_is_excluded_and_singleton_positions_are_equivalent(self):
        self.assertEqual(len(arrays.MODEL.rows()),240)
        self.assertEqual(len(arrays.MODEL.select()),18)
        self.assertTrue(all(r[0]!='fixed' or r[6]=='element' for r in arrays.MODEL.rows()))
        self.assertEqual(arrays.reference(('dynamic','8','1','first','shallow','source','resize')),
                         arrays.reference(('dynamic','8','1','last','shallow','source','resize')))


if __name__=='__main__':
    unittest.main()
