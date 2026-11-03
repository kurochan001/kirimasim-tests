"""Streaming permutations and stateful concatenation inputs retain exact evidence."""

import copy
import hashlib
from pathlib import Path
import random
import tempfile
import time
import unittest
from unittest.mock import patch

import random_cross_models as m
import random_cross_evidence as evidence
import random_cross_compare as compare
import run_random_cross as runner


def stream_case(operation='unpack', state='logic'):
    return {'id':'case_0000','profile':'streaming_context',
            'parameters':{'width':1,'direction':'left','slice':3,'form':'tagged','operation':operation,'state':state},
            'stimuli':[{'source':'1','tag':'001'}]}


def concat_case(update='nba', states='bl'):
    return {'id':'case_0000','profile':'concat_assignment_sequence',
            'parameters':{'width':32,'left_width':1,'rhs_relation':'narrow','rhs_sign':'signed',
                          'states':states,'member_sign':'signed','update':update},
            'stimuli':{'initial_left':'1','initial_right':'0'*31,
                       'operations':[{'source':'z'+'0'*29+'1','after':'0'*31},
                                     {'source':'1'*31,'after':'0'*31}]}}


def independent_stream(value, direction, size, unpack):
    if direction=='right':return value
    if not unpack:
        r=len(value)%size
        chunks=([value[:r]] if r else [])+[value[i:i+size] for i in range(r,len(value),size)]
        return ''.join(reversed(chunks))
    count,partial=divmod(len(value),size)
    chunks=[value[i*size:(i+1)*size] for i in range(count)]
    return (value[count*size:] if partial else '')+''.join(reversed(chunks))


class StreamProfileTests(unittest.TestCase):
    def test_prior_seven_profile_hashes_and_bytes_are_preserved(self):
        goldens={1:('126401d205bf9a0444198da5a5c4557f144ee23ee4cfb3ff79101780ea6c45b3','05a59198498e0dba27eb3eefa54c9514f296b42c45d111bcee213661c74960d8'),
                 731:('a5a4c1113bd487430b72693137bc9d612fd461733ccf8241d164026723d0ed87','a61a825c2f1a0376f1d42f22623a665d2e99a62c94d8abf92bd3c38349fb33ad'),
                 20261103:('6dc8e712407039bfd9ac0388655837914631a0a1eeb8e9faa03107d8e5be1e5e','ec36a7a533dbab7c831494b3f7180d091e40b45d284cc643a858322772ce7166')}
        for seed,(manifest_digest,bytes_digest) in goldens.items():
            manifest=m.generate(seed,96,8,m.SEVEN_PROFILES)
            self.assertEqual(evidence.digest(manifest),manifest_digest)
            self.assertEqual(hashlib.sha256(''.join(s+e for s,e in map(m.materialize,manifest['cases'])).encode()).hexdigest(),bytes_digest)

    def test_fixed_streaming_rows_match_general_profile(self):
        for row in m.streams.MODEL.rows():
            w,direction,size,form,operation,state,_=row;source,incoming,want=m.streams.reference(row)
            case=stream_case(operation,state);case['parameters'].update(width=int(w),direction=direction,slice=int(size),form=form)
            case['stimuli']=[{'source':source,**({'tag':'101'} if form=='tagged' else {})}]
            self.assertEqual(m.materialize(case)[1],f'v0_source={source} incoming={incoming}\nv0_result={want}\n')

    def test_partial_pack_and_unpack_have_different_hand_checked_results(self):
        self.assertTrue(m.materialize(stream_case('pack'))[1].endswith('v0_result=0110\n'))
        self.assertTrue(m.materialize(stream_case('unpack'))[1].endswith('v0_result=1001\n'))

    def test_arbitrary_streams_match_independent_block_decoder_and_round_trip(self):
        rng=random.Random(731)
        for n in range(1,133):
            value=''.join(rng.choice('01xz') for _ in range(n))
            for size in (1,2,3,7,8,16,17,32,33,n,n+1):
                for direction in ('left','right'):
                    for unpack in (False,True):
                        self.assertEqual(m.streams.reorder(value,direction,size,unpack),independent_stream(value,direction,size,unpack))
                    packed=m.streams.reorder(value,direction,size)
                    self.assertEqual(m.streams.reorder(packed,direction,size,True),value)

    def test_stream_conversion_occurs_after_permutation(self):
        case=stream_case();case['stimuli']=[{'tag':'xz0','source':'1'}]
        self.assertTrue(m.materialize(case)[1].endswith('v0_result=1xz0\n'))
        case['parameters']['state']='bit';self.assertTrue(m.materialize(case)[1].endswith('v0_result=1000\n'))
        self.assertTrue(m.requires_fourstate(case))

    def test_right_stream_or_slice_larger_than_input_is_identity(self):
        for change in ({'direction':'right'},{'slice':132}):
            case=stream_case();case['parameters'].update(change)
            self.assertTrue(m.materialize(case)[1].endswith('v0_result=0011\n'))

    def test_all_fixed_concat_rows_and_both_phases_match(self):
        for row in m.concatenation.MODEL.rows():
            w,_,relation,sign,states,member,update,_=row;left,right,sw=m.concatenation.geometry(row)
            for phase in (0,1):
                source,_,a,b,before_a,before_b,after=m.concatenation.reference(row,phase)
                case=concat_case(update,states);case['parameters'].update(width=int(w),left_width=left,rhs_relation=relation,rhs_sign=sign,member_sign=member)
                case['stimuli']={'initial_left':before_a,'initial_right':before_b,'operations':[{'source':source,'after':after}]}
                immediate=(before_a,before_b) if update=='nba' else (a,b)
                expected=(f'initial={before_a} {before_b}\nv0_input={source}\nv0_scheduled={immediate[0]} {immediate[1]}\n'
                          f'v0_changed={after}\nv0_final={a} {b}\nv0_wide={m.bit_values.resize(a,left+1,member=="signed")} '
                          f'{m.bit_values.resize(b,right+1,member=="signed")} concat=0{a}{b}\n')
                self.assertEqual(m.materialize(case)[1],expected,row)

    def test_mixed_state_split_and_readback_signedness_are_observed(self):
        source,expected=m.materialize(concat_case())
        self.assertIn('v0_final=0 z'+'0'*29+'1\n',expected)
        self.assertIn('v0_wide=00 zz'+'0'*29+'1 concat=00z'+'0'*29+'1\n',expected)
        self.assertIn('bit signed [0:0] left;',source)

    def test_nba_keeps_previous_state_until_settled_and_captures_source(self):
        _,expected=m.materialize(concat_case())
        self.assertIn('v0_scheduled=1 '+'0'*31+'\n',expected)
        self.assertIn('v0_changed='+'0'*31+'\n',expected)
        self.assertIn('v0_final=0 z'+'0'*29+'1\n',expected)
        self.assertIn('v1_scheduled=0 z'+'0'*29+'1\n',expected)
        self.assertIn('v1_final=1 '+'1'*31+'\n',expected)

    def test_blocking_has_new_immediate_values_but_same_settled_history(self):
        blocking=m.materialize(concat_case('blocking'))[1];nba=m.materialize(concat_case())[1]
        self.assertIn('v0_scheduled=0 z'+'0'*29+'1\n',blocking)
        self.assertEqual([l for l in blocking.splitlines() if '_final=' in l],[l for l in nba.splitlines() if '_final=' in l])

    def test_arbitrary_known_concat_splits_match_integer_partition(self):
        rng=random.Random(731)
        for w in (2,32,33,64,65,129):
            for left in range(1,w):
                for sign in ('signed','unsigned'):
                    case=concat_case(states='ll');case['parameters'].update(width=w,left_width=left,rhs_sign=sign)
                    raw=rng.getrandbits(w-1);value=raw-(1<<(w-1)) if sign=='signed' and raw>>(w-2) else raw
                    fitted=value&((1<<w)-1);a=f'{fitted>>(w-left):0{left}b}';b=f'{fitted&((1<<(w-left))-1):0{w-left}b}'
                    case['stimuli']={'initial_left':'0'*left,'initial_right':'0'*(w-left),'operations':[{'source':f'{raw:0{w-1}b}','after':'0'*(w-1)}]}
                    self.assertIn(f'v0_final={a} {b}\n',m.materialize(case)[1])

    def test_initial_values_repeats_and_operation_order_remain_input(self):
        case=concat_case();same=copy.deepcopy(case);same['id']='case_0001';self.assertEqual(m.content_digest(case),m.content_digest(same))
        changes=[copy.deepcopy(case) for _ in range(4)]
        changes[0]['stimuli']['operations'].reverse();changes[1]['stimuli']['operations'].insert(1,copy.deepcopy(case['stimuli']['operations'][0]))
        changes[2]['stimuli']['initial_left']='0';changes[3]['stimuli']['operations'][0]['after']='1'*31
        for other in changes:self.assertNotEqual(m.content_digest(case),m.content_digest(other))
        self.assertNotEqual(m.materialize(case)[1],m.materialize(changes[0])[1])
        self.assertNotEqual(m.materialize(case)[1],m.materialize(changes[2])[1])

    def test_saved_replay_preserves_both_new_profiles_without_redrawing(self):
        manifest=m.generate(731,6,8,('streaming_context','concat_assignment_sequence'))
        with tempfile.TemporaryDirectory() as folder:
            first,second=Path(folder)/'first',Path(folder)/'second';records,_=evidence.prepare(manifest,first)
            with patch.object(m.random,'Random',side_effect=AssertionError('redrawn')):
                replay,_=evidence.prepare(manifest,second,first/'manifest.json')
            self.assertEqual(records,replay)
            for record in records.values():
                for field in ('source','expected'):self.assertEqual((first/record[field]).read_bytes(),(second/record[field]).read_bytes())

    def test_xz_inputs_are_never_judged_by_two_state_comparison(self):
        stream=stream_case(state='bit');stream['stimuli'][0]['tag']='zx0'
        for case in (stream,concat_case(states='bb')):
            self.assertTrue(m.requires_fourstate(case))
            with patch.object(compare,'stage',side_effect=AssertionError('two-state execution')):
                result=compare.execute({'fourstate':m.requires_fourstate(case)},Path('.'),'verilator',{},1,5,time.monotonic()+10)
            self.assertEqual(result['status'],'unsupported')
        self.assertFalse(m.requires_fourstate(stream_case()))

    def test_invalid_geometry_payloads_and_limits_are_rejected(self):
        invalid=[]
        for field,value in [('slice',0),('slice',True),('slice',133),('form','evil; $finish'),('operation','bad')]:
            case=stream_case();case['parameters'][field]=value;invalid.append(case)
        case=stream_case();case['stimuli'][0]['tag']='x';invalid.append(case)
        for field,value in [('left_width',0),('left_width',32),('left_width',True),('states',[]),('width',1)]:
            case=concat_case();case['parameters'][field]=value;invalid.append(case)
        case=concat_case();case['stimuli']['operations'][0]['after']='0';invalid.append(case)
        for profile in ('streaming_context','concat_assignment_sequence'):
            case=m.generate(1,1,32,(profile,))['cases'][0];items=case['stimuli'] if profile=='streaming_context' else case['stimuli']['operations']
            items.append(copy.deepcopy(items[0]));invalid.append(case)
        for case in invalid:
            with self.subTest(case=case),self.assertRaises(ValueError):m.materialize(case)

    def test_new_reference_and_source_dependencies_are_fingerprinted(self):
        for name in ('generators/interaction_stream.py','generators/interaction_concat.py'):
            self.assertIn(name,runner.SOURCES);self.assertEqual(runner.source_hashes()[name],runner.sha(m.ROOT/name))
