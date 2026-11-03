"""Random shifts/casts: standards-derived boundaries, replay and prior streams."""

import copy
import hashlib
from pathlib import Path
import random
import tempfile
import time
import unittest
from unittest.mock import patch

import interaction_cast as casts
import interaction_shift as shifts
import random_cross_models as m
import random_cross_evidence as evidence
import random_cross_compare as compare
import run_random_cross as runner


def shift_case(width=33, sign='signed', op='ashr', relation='wide', state='logic', cw=65, cs='signed'):
    return {'id':'case_0000','profile':'shift_context',
            'parameters':{'width':width,'sign':sign,'operator':op,'relation':relation,'state':state,
                          'count_width':cw,'count_sign':cs},
            'stimuli':[{'source':'1'+'0'*(width-1),'count':f'{width:0{cw}b}'}]}


def cast_case(width=33, sign='signed', kind='typed_bit', relation='wide', op='add', state='logic'):
    return {'id':'case_0000','profile':'cast_pipeline',
            'parameters':{'width':width,'sign':sign,'cast':kind,'relation':relation,'operation':op,'state':state},
            'stimuli':[{'source':'1'+'0'*(width-2)+'z'}]}


def last_result(case):
    return m.materialize(case)[1].splitlines()[-1].split('=',1)[1]


class BitProfileTests(unittest.TestCase):
    def test_prior_five_profile_manifests_and_materializations_keep_exact_hashes(self):
        goldens={1:('3648b055e3b1fc251ec395be2f434e37a3c708d0bf7f7f9b51c88590fd0d04a3','c587bd2b017255a5d63e62e165f391477624d2b2d6f0bf9af4bafeeed0ff36ae'),
                 731:('045dbccb178fd92cfcfb2bb725f8fc4c09ca5eaba1c7564025880f156636f3c6','09d75fa0312ad588a12046bf0c5b8779aa4eae47b18542af3c8b6a63347ee6e3'),
                 20261103:('3e0b7e6979d0aa356865ee00ae72b71bdb6cb073341440691fada223003553f6','ec5017d9a778a051c00a7ebd291d288bb2046933508ae2868b1ff725f5712457')}
        for seed,(manifest_hash,materialized_hash) in goldens.items():
            manifest=m.generate(seed,96,8,m.FIVE_PROFILES)
            self.assertEqual(evidence.digest(manifest),manifest_hash)
            self.assertEqual(hashlib.sha256(''.join(s+e for s,e in map(m.materialize,manifest['cases'])).encode()).hexdigest(),materialized_hash)

    def test_every_fixed_shift_row_still_matches_the_generalized_reference(self):
        for row in shifts.MODEL.rows():
            w,sign,op,count,value,relation,state=row;source,amount,want=shifts.reference(row)
            case=shift_case(int(w),sign,op,relation,state,cw=32,cs='unsigned')
            case['stimuli']=[{'source':source,'count':amount}]
            self.assertEqual(last_result(case),want,row)

    def test_every_fixed_cast_row_still_matches_the_generalized_reference(self):
        for row in casts.MODEL.rows():
            w,sign,value,kind,relation,op,state=row;source,intermediate,want=casts.reference(row)
            case=cast_case(int(w),sign,kind,relation,op,state);case['stimuli']=[{'source':source}]
            expected=m.materialize(case)[1]
            self.assertEqual(expected,f'v0_source={source}\nv0_cast={intermediate}\nv0_result={want}\n',row)

    def test_arbitrary_known_shifts_match_integer_oracle(self):
        rng=random.Random(731)
        for w in m.WIDTHS:
            for signed in (False,True):
                for op in shifts.OPS:
                    for relation in ('same','wide') if w==1 else ('narrow','same','wide'):
                        case=shift_case(w,'signed' if signed else 'unsigned',op,relation)
                        n=max(w,w+{'narrow':-1,'same':0,'wide':1}[relation]);wr=w+{'narrow':-1,'same':0,'wide':1}[relation]
                        for amount in (0,1,w-1,w,w+1,130,(1<<65)-1):
                            value=rng.getrandbits(w)
                            case['stimuli']=[{'source':f'{value:0{w}b}','count':f'{amount:065b}'}]
                            negative=signed and bool(value&(1<<(w-1)));extended=value-(1<<w) if negative else value
                            extended&=(1<<n)-1
                            if op in ('shl','ashl'):result=0 if amount>=n else extended<<amount
                            elif op=='ashr' and negative:
                                result=-1 if amount>=n else (extended-(1<<n))>>amount
                            else:result=0 if amount>=n else extended>>amount
                            self.assertEqual(last_result(case),f'{result&((1<<wr)-1):0{wr}b}')

    def test_destination_widens_left_operand_before_shift(self):
        case=shift_case(width=32,sign='unsigned',op='shl',cw=8)
        case['stimuli']=[{'source':'0'*31+'1','count':f'{32:08b}'}]
        self.assertEqual(last_result(case),'1'+'0'*32)
        case['parameters']['relation']='same';self.assertEqual(last_result(case),'0'*32)

    def test_count_sign_does_not_change_shift_sign_or_widen_data(self):
        case=shift_case(width=32,sign='unsigned',op='ashr',relation='same',cw=65)
        case['stimuli']=[{'source':'1'*32,'count':'1'*65}]
        self.assertEqual(last_result(case),'0'*32)
        case['parameters']['sign']='signed';self.assertEqual(last_result(case),'1'*32)
        case['parameters']['count_sign']='unsigned';self.assertEqual(last_result(case),'1'*32)
        self.assertIn('logic unsigned [64:0] count;',m.materialize(case)[0])

    def test_unknown_count_produces_x_before_two_state_assignment(self):
        case=shift_case(width=65);case['stimuli'][0]['count']='0'*64+'z'
        self.assertEqual(last_result(case),'x'*66)
        case['parameters']['state']='bit';self.assertEqual(last_result(case),'0'*66)
        self.assertTrue(m.requires_fourstate(case))

    def test_arithmetic_shift_copies_z_sign_bit_but_logical_shift_zeros(self):
        case=shift_case(width=32,relation='wide',cw=8);case['stimuli']=[{'source':'z'+'0'*31,'count':f'{33:08b}'}]
        self.assertEqual(last_result(case),'z'*33)
        case['parameters']['operator']='shr';self.assertEqual(last_result(case),'0'*33)

    def test_typed_bit_cast_converts_unknowns_before_add(self):
        case=cast_case(width=32);case['stimuli']=[{'source':'z'*32}]
        self.assertEqual(last_result(case),'0'*33+'1')
        case['parameters']['cast']='typed_logic';self.assertEqual(last_result(case),'x'*34)
        case['parameters']['state']='bit';self.assertEqual(last_result(case),'0'*34)

    def test_size_cast_preserves_sign_while_unsigned_cast_changes_extension(self):
        case=cast_case(width=32,kind='size',relation='narrow',op='plain');case['stimuli']=[{'source':'1'*32}]
        self.assertEqual(last_result(case),'1'*34)
        case['parameters'].update(cast='typed_logic');self.assertEqual(last_result(case),'000'+'1'*31)
        case['parameters'].update(cast='unsigned',relation='same');self.assertEqual(last_result(case),'00'+'1'*32)

    def test_arbitrary_known_casts_match_separate_integer_conversion(self):
        rng=random.Random(731)
        for w in m.WIDTHS:
            for sign in ('signed','unsigned'):
                for kind in ('size','signed','unsigned','typed_bit','typed_logic'):
                    for relation in ('same',) if kind in ('signed','unsigned') else (('same','wide') if w==1 else ('narrow','same','wide')):
                        case=cast_case(w,sign,kind,relation);raw=rng.getrandbits(w);case['stimuli']=[{'source':f'{raw:0{w}b}'}]
                        cw=w+{'narrow':-1,'same':0,'wide':1}[relation]
                        source_value=raw-(1<<w) if sign=='signed' and raw>>(w-1) else raw
                        if kind in ('signed','unsigned'):intermediate=raw;is_signed=kind=='signed'
                        else:intermediate=source_value&((1<<cw)-1);is_signed=kind=='size' and sign=='signed'
                        if is_signed and intermediate>>(cw-1):intermediate-=1<<cw
                        want=(intermediate+1)&((1<<(w+2))-1)
                        self.assertEqual(last_result(case),f'{want:0{w+2}b}')

    def test_replay_of_both_new_domains_preserves_bytes_without_random_draws(self):
        manifest=m.generate(731,6,8,('shift_context','cast_pipeline'))
        with tempfile.TemporaryDirectory() as folder:
            first,second=Path(folder)/'first',Path(folder)/'second';records,_=evidence.prepare(manifest,first)
            with patch.object(m.random,'Random',side_effect=AssertionError('redrawn')):
                replay,_=evidence.prepare(manifest,second,first/'manifest.json')
            self.assertEqual(records,replay)
            for record in records.values():
                for field in ('source','expected'):self.assertEqual((first/record[field]).read_bytes(),(second/record[field]).read_bytes())

    def test_content_identity_preserves_values_and_vector_order(self):
        for case in (shift_case(),cast_case()):
            same=copy.deepcopy(case);same['id']='case_0001';self.assertEqual(m.content_digest(case),m.content_digest(same))
            same['stimuli'][0]['source']='0'*same['parameters']['width'];self.assertNotEqual(m.content_digest(case),m.content_digest(same))
            first=copy.deepcopy(case);first['stimuli']+=same['stimuli'];second=copy.deepcopy(first);second['stimuli'].reverse()
            self.assertNotEqual(m.content_digest(first),m.content_digest(second))

    def test_fourstate_classification_and_verilator_exclusion(self):
        for case in (shift_case(),cast_case()):
            self.assertEqual(m.requires_fourstate(case),case['profile']=='cast_pipeline')
            case['stimuli'][0]['source']='z'*case['parameters']['width'];case['parameters']['state']='bit'
            self.assertTrue(m.requires_fourstate(case))
            with patch.object(compare,'stage',side_effect=AssertionError('two-state execution')):
                result=compare.execute({'fourstate':True},Path('.'),'verilator',{},1,5,time.monotonic()+10)
            self.assertEqual(result['status'],'unsupported')

    def test_invalid_parameters_payloads_and_caps_are_rejected(self):
        invalid=[]
        for field,value in [('width',True),('count_width',True),('count_width',129),('operator','>>>; $finish'),('operator',[]),('relation','invalid')]:
            case=shift_case();case['parameters'][field]=value;invalid.append(case)
        case=shift_case();case['stimuli'][0]['count']='1';invalid.append(case)
        case=cast_case();case['parameters'].update(cast='signed',relation='wide');invalid.append(case)
        case=cast_case();case['parameters']['cast']='invalid';invalid.append(case)
        case=cast_case(width=1,relation='narrow');invalid.append(case)
        for profile in ('shift_context','cast_pipeline'):
            case=m.generate(1,1,32,(profile,))['cases'][0];case['stimuli'].append(copy.deepcopy(case['stimuli'][0]));invalid.append(case)
        for case in invalid:
            with self.subTest(case=case),self.assertRaises(ValueError):m.materialize(case)

    def test_operator_dependency_is_fingerprinted(self):
        self.assertIn('generators/interaction_shift.py',runner.SOURCES)
        self.assertEqual(runner.source_hashes()['generators/interaction_shift.py'],runner.sha(m.ROOT/'generators/interaction_shift.py'))
