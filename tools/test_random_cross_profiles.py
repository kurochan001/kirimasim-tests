"""New random domains: actual sequences, standard boundaries and old replay bytes."""

import copy
from itertools import product
from pathlib import Path
import random
import sys
import tempfile
import unittest
from unittest.mock import patch

import random_cross_models as m
import random_cross_evidence as evidence
import random_cross_compare as compare
import run_random_cross as runner
import qualify_pkgwatch as independent


def conditional_case(state='logic', relation='same', signs=('unsigned', 'unsigned')):
    return {'id': 'case_0000', 'profile': 'conditional_context',
            'parameters': {'width': 32, 'relation': relation, 'sign_a': signs[0], 'sign_b': signs[1], 'state': state},
            'stimuli': [{'a': '0'*30+'zz', 'b': '0'*30+'zz', 'condition': 'x'}]}


def package_case(state='logic', update='nba', event='lsb', wait='logical'):
    return {'id': 'case_0000', 'profile': 'package_change_sequence',
            'parameters': {'width': 32, 'state': state, 'access': 'qualified', 'storage': 'scalar',
                           'update': update, 'event': event, 'wait': wait},
            'stimuli': {'initial': {'payload': '1'*32, 'neighbor': '1'*32, 'control': '1'*32, 'other_guard': '1'*32},
                        'operations': [{'target': 'payload', 'data': '0'*31+'1'},
                                       {'target': 'payload', 'data': '0'*31+'1'},
                                       {'target': 'payload', 'data': 'x'*32},
                                       {'target': 'payload', 'data': '1'+'0'*31},
                                       {'target': 'payload', 'data': '0'*32},
                                       {'target': 'neighbor', 'data': '0'*32},
                                       {'target': 'control', 'data': '0'*32}]}}


def observation(expected, tag, name='a'):
    snapshot = expected.split('snap tag='+tag+' ', 1)[1].split('\nsnap ', 1)[0]
    return next(line for line in snapshot.splitlines() if line.startswith('o name='+name+' '))


class RandomProfileTests(unittest.TestCase):
    def test_default_profile_allocation_is_balanced_at_original_nightly_size(self):
        manifest=m.generate(731,96,8)
        counts={profile:sum(c['profile']==profile for c in manifest['cases']) for profile in m.PROFILES}
        self.assertEqual(len(counts),13)
        self.assertEqual(sorted(counts.values()),[7,7,7,7,7,7,7,7,8,8,8,8,8])
        self.assertEqual(manifest,m.generate(731,96,8))

    def test_arbitrary_conditional_inputs_follow_fixed_standard_reference_boundaries(self):
        for row in m.conditional.MODEL.rows():
            w,sa,sb,c,pattern,relation,state=row
            if int(w) not in m.WIDTHS:continue
            a,b,want=m.conditional.reference(row)
            case=conditional_case(state,relation,(sa,sb));case['parameters']['width']=int(w)
            case['stimuli']=[{'a':a,'b':b,'condition':c}]
            self.assertEqual(m.materialize(case)[1],f'v0_inputs={a} {b} condition={c}\nv0_result={want}\n')

    def test_all_single_bit_conditional_pairs_follow_merge_table(self):
        for a,b,condition in product('01xz',repeat=3):
            case=conditional_case();case['parameters']['width']=1
            case['stimuli']=[{'a':a,'b':b,'condition':condition}]
            want=a if condition=='1' else b if condition=='0' else a if a==b and a in '01' else 'x'
            self.assertTrue(m.materialize(case)[1].endswith('v0_result='+want+'\n'))

    def test_conditional_context_sign_extension_before_merge_and_storage_conversion(self):
        case=conditional_case(relation='wide',signs=('signed','signed'))
        case['stimuli']=[{'a':'1'*32,'b':'1'*31+'0','condition':'z'}]
        self.assertIn('v0_result='+'1'*32+'x\n',m.materialize(case)[1])
        case['parameters']['sign_b']='unsigned'
        self.assertIn('v0_result=0'+'1'*31+'x\n',m.materialize(case)[1])
        case['parameters']['state']='bit'
        self.assertIn('v0_result=0'+'1'*31+'0\n',m.materialize(case)[1])

    def test_known_condition_preserves_z_but_ambiguous_condition_merges_z_to_x(self):
        case=conditional_case();case['stimuli'][0]['condition']='1'
        self.assertTrue(m.materialize(case)[1].endswith('0'*30+'zz\n'))
        case['stimuli'][0]['condition']='x'
        self.assertTrue(m.materialize(case)[1].endswith('0'*30+'xx\n'))

    def test_package_projected_events_repetitions_and_full_value_history(self):
        _,expected=m.materialize(package_case())
        self.assertIn('hits=0 last='+'0'*32+' at=-1',observation(expected,'1'))
        self.assertEqual(observation(expected,'1'),observation(expected,'2'))
        self.assertIn('hits=2 last=1'+'0'*31+' at=20',observation(expected,'5'))
        for tag in ('6','7','idle'):self.assertEqual(observation(expected,'5'),observation(expected,tag))
        self.assertIn('data='+'0'*32+' copy='+'0'*32,observation(expected,'5'))
        self.assertIn('wakes=1 wt=25 held='+'0'*32,observation(expected,'5'))

    def test_initial_zero_wakes_at_registration_without_spurious_event(self):
        case=package_case();case['stimuli']['initial']['payload']='0'*32
        _,expected=m.materialize(case)
        self.assertIn('hits=0 last='+'0'*32+' at=-1 pred=1 wakes=1 wt=1',observation(expected,'armed'))
        self.assertIn('wakes=1 wt=1',observation(expected,'idle'))
        self.assertEqual(independent.interpret(m.materialize(case)[0]),expected)

    def test_mixed_unknown_equality_known_mismatch_dominates_x(self):
        case=package_case();case['stimuli']['operations'][2]['data']='1'+'x'*31
        _,expected=m.materialize(case)
        self.assertIn('pred=0 wakes=0',observation(expected,'3'))
        case['stimuli']['operations'][2]['data']='0'+'x'*31
        self.assertIn('pred=x wakes=0',observation(m.materialize(case)[1],'3'))
        case['parameters']['wait']='case'
        self.assertIn('pred=0 wakes=0',observation(m.materialize(case)[1],'3'))

    def test_bit_unknown_coercion_changes_first_wake_and_retains_history(self):
        _,expected=m.materialize(package_case(state='bit'))
        self.assertIn('wakes=1 wt=15',observation(expected,'3'))
        self.assertIn('pred=0 wakes=1 wt=15',observation(expected,'4'))
        self.assertIn('wakes=1 wt=15',observation(expected,'idle'))

    def test_blocking_and_nba_have_distinct_immediate_destination(self):
        _,blocking=m.materialize(package_case(update='blocking'))
        _,nba=m.materialize(package_case(update='nba'))
        self.assertIn('drive step=1 t=5 raw='+'0'*31+'1 active='+'0'*31+'1',blocking)
        self.assertIn('drive step=1 t=5 raw='+'0'*31+'1 active='+'1'*32,nba)
        self.assertEqual(observation(blocking,'5'),observation(nba,'5'))

    def test_package_fanout_and_independent_control_remain_live(self):
        _,expected=m.materialize(package_case())
        for tag in ('armed','1','3','5','7','idle'):
            self.assertEqual(observation(expected,tag).replace('name=a','name=b'),observation(expected,tag,'b'))
        self.assertIn('wakes=0 wt=-1',observation(expected,'6','g'))
        self.assertIn('wakes=1 wt=35',observation(expected,'7','g'))

    def test_random_package_programs_match_independent_actual_source_interpretation(self):
        for seed in (1,731,20261103):
            for steps in (1,8,32):
                for case in m.generate(seed,24,steps,('package_change_sequence',))['cases']:
                    source,expected=m.materialize(case)
                    self.assertEqual(independent.interpret(source),expected)
                    self.assertEqual(independent.interpret(source,reverse_observers=True),expected)

    def test_new_profiles_save_and_replay_actual_stimuli_without_redrawing(self):
        manifest=m.generate(1234,10,8,('conditional_context','package_change_sequence'))
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);first=root/'first';second=root/'replay';records,_=evidence.prepare(manifest,first)
            with patch.object(m.random,'Random',side_effect=AssertionError('redrawn')):
                replay,_=evidence.prepare(manifest,second,first/'manifest.json')
            for name,record in records.items():
                self.assertEqual(record,replay[name])
                for field in ('source','expected'):self.assertEqual((first/record[field]).read_bytes(),(second/record[field]).read_bytes())

    def test_all_new_execution_inputs_and_order_affect_content_identity(self):
        for case in (conditional_case(),package_case()):
            original=m.content_digest(case);other=copy.deepcopy(case);other['id']='case_0001'
            self.assertEqual(m.content_digest(other),original)
            if case['profile']=='conditional_context':other['stimuli'][0]['condition']='1'
            else:other['stimuli']['operations'].reverse()
            self.assertNotEqual(m.content_digest(other),original)
        case=package_case();other=copy.deepcopy(case);other['stimuli']['operations'].pop(1)
        self.assertNotEqual(m.content_digest(case),m.content_digest(other))

    def test_fourstate_classification_includes_raw_inputs_even_with_bit_destination(self):
        for case in (conditional_case(state='bit'),package_case(state='bit')):
            self.assertTrue(m.requires_fourstate(case))
        case=package_case();case['stimuli']['operations'][2]['data']='1'*32
        self.assertFalse(m.requires_fourstate(case))
        case=conditional_case();case['stimuli']=[{'a':'0'*32,'b':'1'*32,'condition':'0'}]
        self.assertFalse(m.requires_fourstate(case))

    def test_parameter_and_operation_injection_or_invalid_bounds_are_rejected(self):
        invalid=[]
        case=conditional_case();case['parameters']['width']=True;invalid.append(case)
        case=conditional_case();case['parameters']['width']=1;case['parameters']['relation']='narrow';invalid.append(case)
        case=conditional_case();case['stimuli'][0]['condition']='xx';invalid.append(case)
        case=conditional_case();case['stimuli'][0]['a']='0; $finish;';invalid.append(case)
        case=package_case();case['parameters']['access']='*; $finish';invalid.append(case)
        case=package_case();case['stimuli']['operations'][0]['target']='other_guard';invalid.append(case)
        case=package_case();case['stimuli']['operations']=[];invalid.append(case)
        case=package_case();case['stimuli']['operations']*=5;invalid.append(case)
        case=package_case();case['stimuli']['initial']['extra']='0'*32;invalid.append(case)
        for case in invalid:
            with self.subTest(case=case),self.assertRaises(ValueError):m.materialize(case)

    def test_new_source_dependency_is_fingerprinted(self):
        self.assertIn('generators/interaction_pkgwatch.py',runner.SOURCES)
        self.assertEqual(runner.source_hashes()['generators/interaction_pkgwatch.py'],runner.sha(m.ROOT/'generators/interaction_pkgwatch.py'))

    def test_two_state_comparison_never_launches_for_new_fourstate_cases(self):
        import time
        for case in (conditional_case(),package_case(state='bit')):
            record={'fourstate':m.requires_fourstate(case)}
            with patch.object(compare,'stage',side_effect=AssertionError('two-state execution started')):
                result=compare.execute(record,Path('.'),'verilator',{},1,5,time.monotonic()+10)
            self.assertEqual(result['status'],'unsupported')

    def test_case_caps_are_enforced_for_each_new_profile(self):
        for profile in ('conditional_context','package_change_sequence'):
            manifest=m.generate(1,1,32,(profile,));m.validate(manifest)
            case=manifest['cases'][0]
            values=case['stimuli'] if profile=='conditional_context' else case['stimuli']['operations']
            values.append(copy.deepcopy(values[-1]))
            with self.assertRaises(ValueError):m.validate(manifest)
