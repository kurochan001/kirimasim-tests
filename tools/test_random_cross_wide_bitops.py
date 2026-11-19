# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent boundary values and deterministic replay of wide bit operations."""
import copy
import hashlib
from itertools import product
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import random_cross_models as models
import random_cross_evidence as evidence


def shift(source=None, count='1', sign='signed', operator='ashr', relation='same',
          state='logic', count_sign='unsigned'):
    source = '1'+'0'*254 if source is None else source
    return {'id':'case_0000', 'profile':'wide_shift_context',
            'parameters':{'width':len(source), 'sign':sign, 'operator':operator,
                          'relation':relation, 'state':state,
                          'count_width':len(count), 'count_sign':count_sign},
            'stimuli':[{'source':source, 'count':count}]}


def cast(source=None, kind='size', relation='wide', sign='signed',
         operation='plain', state='logic'):
    source = '1'+'0'*254 if source is None else source
    return {'id':'case_0000', 'profile':'wide_cast_pipeline',
            'parameters':{'width':len(source), 'sign':sign, 'cast':kind,
                          'relation':relation, 'operation':operation, 'state':state},
            'stimuli':[{'source':source}]}


def lines(case):
    return models.materialize(case)[1].splitlines()


class WideBitOperationTests(unittest.TestCase):
    def test_arithmetic_and_logical_fill_use_left_sign(self):
        for width in (255, 513):
            source='1'+'0'*(width-1)
            for count_sign in ('signed','unsigned'):
                case=shift(source,'0'*31+'1',count_sign=count_sign)
                self.assertEqual(lines(case)[1],'v0_result=11'+'0'*(width-2))
                case['parameters']['sign']='unsigned'
                self.assertEqual(lines(case)[1],'v0_result=01'+'0'*(width-2))
                case['parameters'].update(sign='signed',operator='shr')
                self.assertEqual(lines(case)[1],'v0_result=01'+'0'*(width-2))

    def test_context_extension_happens_before_left_shift(self):
        case=shift(count='0'*31+'1',operator='shl',relation='wide',sign='unsigned')
        self.assertEqual(lines(case)[1],'v0_result=1'+'0'*255)
        case['parameters']['relation']='same'
        self.assertEqual(lines(case)[1],'v0_result='+'0'*255)

    def test_signed_count_minus_one_is_huge_unsigned_and_bounded(self):
        for width in (257,513):
            for count_width,operator in product((32,65),('shl','shr','ashl','ashr')):
                case=shift('1'+'0'*(width-1),'1'*count_width,
                           operator=operator,count_sign='signed')
                bit='1' if operator=='ashr' else '0'
                self.assertEqual(lines(case)[1],'v0_result='+bit*width)

    def test_unknown_count_is_unknown_before_two_state_storage(self):
        for unknown in 'xz':
            case=shift('1'*513,'0'*64+unknown,state='logic')
            self.assertEqual(lines(case)[1],'v0_result='+'x'*513)
            case['parameters']['state']='bit'
            self.assertEqual(lines(case)[1],'v0_result='+'0'*513)
            self.assertTrue(models.requires_fourstate(case))

    def test_arithmetic_shift_copies_unknown_sign_bits(self):
        for unknown in 'xz':
            case=shift(unknown+'0'*256,'0'*31+'1')
            self.assertEqual(lines(case)[1],'v0_result='+unknown*2+'0'*255)

    def test_known_shift_results_match_independent_integer_arithmetic(self):
        for width,sign,operator,relation in product((257,513),('signed','unsigned'),
                ('shl','shr','ashl','ashr'),('narrow','same','wide')):
            output_width=width+{'narrow':-1,'same':0,'wide':1}[relation]
            natural=max(width,output_width)
            for value,amount in ((1<<(width-1),0),((1<<width)-1,1),
                                 ((1<<(width-1))+1,width-1),(1,width),(3,width+1)):
                operand=value-((1<<width) if sign=='signed' and value>>(width-1) else 0)
                operand &= (1<<natural)-1
                if operator in ('shl','ashl'):
                    result=operand<<amount
                elif operator=='ashr' and sign=='signed':
                    if operand>>(natural-1):operand-=1<<natural
                    result=operand>>amount
                else:result=operand>>amount
                result &= (1<<output_width)-1
                case=shift(f'{value:0{width}b}',f'{amount:032b}',sign,operator,relation)
                self.assertEqual(lines(case)[1],f'v0_result={result:0{output_width}b}')

    def test_typed_bit_removes_unknown_before_addition(self):
        case=cast('x'+'0'*253+'z','typed_bit','same',operation='add')
        self.assertEqual(lines(case)[1],'v0_cast='+'0'*255)
        self.assertEqual(lines(case)[2],'v0_result='+'0'*256+'1')
        case['parameters'].update(cast='typed_logic',state='bit')
        self.assertEqual(lines(case)[1],'v0_cast=x'+'0'*253+'z')
        self.assertEqual(lines(case)[2],'v0_result='+'0'*257)
        self.assertTrue(models.requires_fourstate(case))

    def test_size_cast_preserves_sign_and_typed_logic_returns_unsigned(self):
        case=cast('1'*255)
        self.assertEqual(lines(case)[1],'v0_cast='+'1'*256)
        self.assertEqual(lines(case)[2],'v0_result='+'1'*257)
        case['parameters']['cast']='typed_logic'
        self.assertEqual(lines(case)[1],'v0_cast='+'1'*256)
        self.assertEqual(lines(case)[2],'v0_result=0'+'1'*256)

    def test_signing_cast_keeps_width_but_changes_outer_extension(self):
        case=cast('1'*513,'unsigned','same')
        self.assertEqual(lines(case)[1],'v0_cast='+'1'*513)
        self.assertEqual(lines(case)[2],'v0_result=00'+'1'*513)
        case['parameters']['cast']='signed'
        self.assertEqual(lines(case)[2],'v0_result='+'1'*515)

    def test_narrow_size_cast_truncates_before_addition(self):
        case=cast('1'+'0'*254,'size','narrow',operation='add')
        self.assertEqual(lines(case)[1],'v0_cast='+'0'*254)
        self.assertEqual(lines(case)[2],'v0_result='+'0'*256+'1')

    def test_new_profiles_are_opt_in_and_have_safe_count_widths(self):
        self.assertEqual(len(models.PROFILES),13)
        self.assertEqual(len(models.SUPPORTED_PROFILES),22)
        self.assertEqual(models.WIDE_BIT_PROFILES,('wide_shift_context','wide_cast_pipeline'))
        self.assertEqual(models.WIDE_PROFILES,('wide_conditional_context','wide_comparison_context'))
        self.assertFalse(set(models.PROFILES)&set(models.WIDE_BIT_PROFILES))
        for case in (shift(count='0'*32),cast()):
            bad=copy.deepcopy(case);bad['profile']=bad['profile'].removeprefix('wide_')
            with self.assertRaises(ValueError):models.validate_case(bad)
        bad=shift(count='0'*8)
        with self.assertRaises(ValueError):models.validate_case(bad)

    def test_validation_rejects_invalid_domains_types_and_shapes(self):
        for case in (shift(count='0'*32),cast()):
            for key,value in (('width',True),('width',129),('width',250),('sign','real')):
                bad=copy.deepcopy(case);bad['parameters'][key]=value
                with self.assertRaises(ValueError):models.validate_case(bad)
            for stimuli in ([],case['stimuli']*33,[{'source':'0'}]):
                bad=copy.deepcopy(case);bad['stimuli']=stimuli
                with self.assertRaises(ValueError):models.validate_case(bad)
        case=shift(count='0'*32);case['stimuli'][0]['count']='0'*31
        with self.assertRaises(ValueError):models.validate_case(case)
        case=cast(kind='signed',relation='narrow')
        with self.assertRaises(ValueError):models.validate_case(case)

    def test_previous_eighteen_profile_streams_are_unchanged(self):
        goldens = {1: ('07f680414d81886749000d55c6507e81c8334e436263039adf10f6e1f8162ea1', '3b238b255b83b8c1c303016ce43ea80997c928203f91272275c721a85991faa4'), 731: ('f0042d59d503c2575fa4dd851bae0e3587e617ad9edb557332c687143d72a00c', 'cbf0d91fbaaae948a473e35beb9672c5cbca8413d56360851467674b034bcc17'), 20261119: ('0d6462d0707638af044903604d827ab3bcb18f6406fc781844c8cdfe97fd456f', '633878763c8e366836163c8f935c1f4e2b1da0445ad082c344109fae6a3edb21')}
        for seed,(manifest_hash,source_hash) in goldens.items():
            manifest=models.generate(seed,96,8,models.SUPPORTED_PROFILES[:18])
            self.assertEqual(hashlib.sha256(models.canonical(manifest).encode()).hexdigest(),manifest_hash)
            source="".join(s+e for s,e in map(models.materialize,manifest["cases"]))
            self.assertEqual(hashlib.sha256(source.encode()).hexdigest(),source_hash)

    def test_deterministic_generation_replays_without_random_draws(self):
        for seed in (1,731,20261119):
            manifest=models.generate(seed,96,8,models.WIDE_BIT_PROFILES)
            self.assertEqual(manifest,models.generate(seed,96,8,models.WIDE_BIT_PROFILES))
            states=[models.requires_fourstate(case) for case in manifest['cases']]
            self.assertGreater(sum(states),20)
            self.assertGreater(len(states)-sum(states),20)
            with patch.object(models.random,'Random',side_effect=AssertionError('replay drew randomness')):
                models.validate(manifest)
                for case in manifest['cases']:
                    self.assertEqual(models.materialize(case),models.materialize(copy.deepcopy(case)))

    def test_saved_replay_preserves_baseline_and_detects_reference_drift(self):
        case=cast('1'*255)
        manifest={'schema':1,'generator':models.GENERATOR,'seed':1,'cases':[case]}
        with tempfile.TemporaryDirectory() as temporary:
            base=Path(temporary);original,_=evidence.prepare(manifest,base/'original')
            replay,info=evidence.prepare(manifest,base/'replay',base/'original/manifest.json')
            self.assertEqual(original,replay)
            self.assertFalse(info['cases']['case_0000']['expected_changed'])
            previous=models.materialize_cast
            def corrupt(case):
                source,want=previous(case)
                return source,[line.replace('v0_result=1','v0_result=0') for line in want]
            with patch.object(models,'materialize_cast',side_effect=corrupt):
                _,info=evidence.prepare(manifest,base/'drift',base/'original/manifest.json')
            self.assertTrue(info['cases']['case_0000']['expected_changed'])
            self.assertEqual((base/'drift/cases/case_0000.expected').read_bytes(),
                             (base/'original/cases/case_0000.expected').read_bytes())


if __name__=='__main__':unittest.main()
