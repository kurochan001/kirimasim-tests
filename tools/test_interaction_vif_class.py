"""Routing identity, copied binding slots and null-write state preservation."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_vif_class as vif


class VirtualInterfaceClassSemantics(unittest.TestCase):
    def test_single_bit_copy_rebind_and_saved_reference_protocol(self):
        self.assertEqual(vif.reference(('1','bit','full','a','shallow','copy','method')),
            'stage=copied ok=-1 object=0 vif=1 saved_source=1 saved_copy=1\n'
            'a=0 b=1 guard=0 saved=11:0\nsource=11:0 writes=0 copy=11:0 writes=0\nguard=33:0 writes=0\n'
            'stage=initial_write ok=1 object=0 vif=1 saved_source=1 saved_copy=1\n'
            'a=1 b=1 guard=0 saved=11:1\nsource=11:1 writes=0 copy=11:1 writes=1\nguard=33:0 writes=0\n'
            'stage=rebound ok=-1 object=0 vif=0 saved_source=1 saved_copy=0\n'
            'a=1 b=1 guard=0 saved=11:1\nsource=11:1 writes=0 copy=22:1 writes=1\nguard=33:0 writes=0\n'
            'stage=other_write ok=1 object=0 vif=0 saved_source=1 saved_copy=0\n'
            'a=1 b=0 guard=0 saved=11:1\nsource=11:1 writes=0 copy=22:0 writes=2\nguard=33:0 writes=0\n'
            'stage=null_write ok=0 object=0 vif=0 saved_source=1 saved_copy=0\n'
            'a=1 b=0 guard=0 saved=11:1\nsource=11:1 writes=0 copy=-1:0 writes=2\nguard=33:0 writes=0\n'
            'stage=saved_write ok=-1 object=0 vif=0 saved_source=1 saved_copy=0\n'
            'a=0 b=0 guard=0 saved=11:0\nsource=11:0 writes=0 copy=-1:0 writes=2\nguard=33:0 writes=0\n'
            'stage=restored ok=-1 object=0 vif=1 saved_source=1 saved_copy=1\n'
            'a=0 b=0 guard=0 saved=11:0\nsource=11:0 writes=0 copy=11:0 writes=2\nguard=33:0 writes=0\n')

    def test_alias_control_shares_null_binding_and_success_count(self):
        text=vif.reference(('8','logic','modport','b','alias','source','property'))
        null=text.split('stage=null_write',1)[1].split('stage=saved_write',1)[0]
        self.assertIn('ok=0 object=1 vif=1 saved_source=0 saved_copy=0',null)
        self.assertIn('source=-1:00000000 writes=2 copy=-1:00000000 writes=2',null)

    def test_saved_binding_writes_original_bus_while_actor_is_null(self):
        text=vif.reference(('33','bit','modport','b','shallow','source','method'))
        saved=text.split('stage=saved_write',1)[1].split('stage=restored',1)[0]
        self.assertIn('saved_source=0 saved_copy=1',saved)
        self.assertIn('saved=22:'+'1'*33,saved)
        self.assertIn('source=-1:'+'0'*33+' writes=2 copy=22:'+'1'*33+' writes=0',saved)

    def test_known_storage_and_access_controls_keep_the_same_observations(self):
        expected=vif.reference(('8','bit','full','a','shallow','copy','method'))
        for state in ('bit','logic'):
            for port in ('full','modport'):
                for access in ('method','property'):
                    self.assertEqual(vif.reference(('8',state,port,'a','shallow','copy',access)),expected)


if __name__=='__main__':
    unittest.main()
