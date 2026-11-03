"""Typed array reductions and declaration-order copy histories with replay."""

import copy
import hashlib
from itertools import product
from math import prod
from pathlib import Path
import random
import tempfile
import time
import unittest
from unittest.mock import patch

import interaction_array as fixed_copy
import random_cross_models as m
import random_cross_evidence as evidence
import random_cross_compare as compare
import run_random_cross as runner


def reduction_case(method='sum', transform='plain', state='logic', storage='fixed', width=32, sign='unsigned', count=3):
    return {'id':'case_0000','profile':'array_reduction_context',
            'parameters':{'width':width,'state':state,'sign':sign,'storage':storage,'count':count,'method':method,'transform':transform},
            'stimuli':[{'values':['1'*width for _ in range(count)]}]}


def copy_case(state='logic'):
    return {'id':'case_0000','profile':'unpacked_array_copy_sequence',
            'parameters':{'width':32,'count':3,'state':state,'sign':'signed','source_order':'descending','target_order':'ascending'},
            'stimuli':{'source':['0'*31+'1','1'*32,'z'+'0'*31],'target':['1'*32,'0'*32,'0'*32],
                       'operations':[{'kind':'copy','source_start':0,'target_start':1,'length':2},
                                     {'kind':'write_source','index':0,'data':'0'*32},
                                     {'kind':'write_target','index':0,'data':'x'*32},
                                     {'kind':'copy','source_start':1,'target_start':0,'length':2}]}}


class ArrayProfileTests(unittest.TestCase):
    def test_eleven_profile_manifests_and_bytes_retain_previous_hashes(self):
        goldens={1:('7649ad0be492ffcabf811773587f0930376d50a904d163a0cd6ba276e186d86a','a0ae45f82c8c13c3ec240878e18184c9ecb06fb7ef7cf6da25bf8e308facc940'),
                 731:('d696cef3c27abb5e7a6efaba58095c64758b819300ffc6b41cc5e77cf2ea7c53','31561f140039d648481fb8255f5936240d4764b2cf2a1d55e6dc02bcbfc31019'),
                 20261103:('69fe7b1aa3f1bfc6bdcf12881eb8f982e5caddaac595e08e75c2b533a7463571','23cb4821f9577bcbfd6e14735bb6716904de84de342429cc4742aa5c21c2ad76')}
        for seed,(manifest_hash,bytes_hash) in goldens.items():
            manifest=m.generate(seed,96,8,m.ELEVEN_PROFILES)
            self.assertEqual(evidence.digest(manifest),manifest_hash)
            self.assertEqual(hashlib.sha256(''.join(s+e for s,e in map(m.materialize,manifest['cases'])).encode()).hexdigest(),bytes_hash)

    def test_every_fixed_reduction_row_and_both_backgrounds_match(self):
        for row in m.array_methods.MODEL.rows():
            w,state,sign,storage,method,transform,value_kind=row
            for phase in (0,1):
                case=reduction_case(method,transform,state,storage,int(w),sign)
                raw=m.array_methods.inputs(row,phase)
                if value_kind!='known':raw[0]=value_kind[-1]+m.array_methods.pattern(int(w),'known')[1:]
                case['stimuli']=[{'values':raw}]
                result_value,wide=m.array_methods.reference(row,phase);n=m.array_methods.return_type(row)[0]
                self.assertTrue(m.materialize(case)[1].endswith(f'v0_value={result_value} direct={wide} saved={wide} bits={n}\n'),row)

    def test_singleton_returns_converted_element_including_z_for_every_method(self):
        for method in ('sum','product','and','or','xor'):
            case=reduction_case(method,width=1,count=1);case['stimuli']=[{'values':['z']}]
            self.assertTrue(m.materialize(case)[1].endswith('v0_value=z direct=0z saved=0z bits=1\n'))
            self.assertEqual(m.reduce_array_elements(['z'],method),'z')
            self.assertEqual(m.reduce_array_elements(['z','1'],method),'x' if method!='or' else '1')

    def test_unknowns_are_converted_per_element_before_reduction(self):
        case=reduction_case(transform='int',width=1,count=1);case['stimuli']=[{'values':['z']}]
        self.assertIn('v0_value='+'0'*32,m.materialize(case)[1])
        case['parameters']['transform']='integer';self.assertIn('v0_value='+'0'*31+'z',m.materialize(case)[1])
        case['parameters'].update(transform='plain',state='bit');self.assertIn('supplied=z stored=0',m.materialize(case)[1])
        self.assertTrue(m.requires_fourstate(case))

    def test_return_width_is_self_determined_before_wide_assignment(self):
        case=reduction_case(width=1);self.assertIn('v0_value=1 direct=01 saved=01 bits=1',m.materialize(case)[1])
        case['parameters']['transform']='widen';self.assertIn('v0_value=11 direct=011 saved=011 bits=2',m.materialize(case)[1])

    def test_arbitrary_known_reductions_match_integer_arithmetic_and_masks(self):
        rng=random.Random(731)
        for w in m.WIDTHS:
            for count in range(1,6):
                for sign,transform,method in product(('signed','unsigned'),('plain','widen','int','integer'),('sum','product','and','or','xor')):
                    raw=[rng.getrandbits(w) for _ in range(count)];n=32 if transform in ('int','integer') else w+(transform=='widen')
                    rsign='signed' if transform in ('int','integer') else sign;mask=(1<<n)-1
                    values=[(v-(1<<w) if sign=='signed' and v>>(w-1) else v)&mask for v in raw]
                    if method=='sum':value=sum(values)&mask
                    elif method=='product':value=prod(values)&mask
                    else:
                        value=values[0]
                        for v in values[1:]:value={'and':value&v,'or':value|v,'xor':value^v}[method]
                    want=f'{value:0{n}b}';wide=('1' if rsign=='signed' and value>>(n-1) else '0')+want
                    case=reduction_case(method,transform,width=w,sign=sign,count=count);case['stimuli']=[{'values':[f'{v:0{w}b}' for v in raw]}]
                    self.assertTrue(m.materialize(case)[1].endswith(f'v0_value={want} direct={wide} saved={wide} bits={n}\n'))

    def test_boolean_array_fold_matches_independent_pair_tables(self):
        tables={'and':['0000','01xx','0xxx','0xxx'],'or':['01xx','1111','x1xx','x1xx'],'xor':['01xx','10xx','xxxx','xxxx']}
        alphabet='01xz'
        for count in range(1,5):
            for values in product(alphabet,repeat=count):
                for method,table in tables.items():
                    value=values[0]
                    for v in values[1:]:value=table[alphabet.index(value)][alphabet.index(v)]
                    self.assertEqual(m.reduce_array_elements(list(values),method),value)
        with self.assertRaises(ValueError):m.reduce_array_elements([],'sum')

    def test_container_initialization_and_real_size_observations_are_emitted(self):
        for storage in ('fixed','dynamic','queue'):
            case=reduction_case(storage=storage,count=5);source,expected=m.materialize(case)
            self.assertIn('v0_size=5',expected)
            self.assertIn('$size(a)' if storage=='fixed' else 'a.size()',source)
            if storage=='dynamic':self.assertIn('a = new[5];',source)
            elif storage=='queue':self.assertEqual(source.count('a.push_back('),5)
            else:self.assertIn('word_t a[5:1];',source)

    def test_every_fixed_copy_row_preserves_values_guards_and_mutation_independence(self):
        for row in fixed_copy.MODEL.rows():
            w,sign,state,so,to,_,operation=row
            for phase in (0,1):
                raw,_,changed=fixed_copy.values(row,phase);want,wide,_=fixed_copy.reference(row,phase)
                case=copy_case(state);case['parameters'].update(width=int(w),sign=sign,source_order=so,target_order=to)
                case['stimuli']={'source':raw,'target':['1'*int(w)]*3,'operations':[{'kind':'copy','source_start':0,'target_start':0,'length':3 if operation=='whole' else 2},{'kind':'write_source','index':0,'data':changed}]}
                expected=m.materialize(case)[1]
                self.assertIn('v1_target='+' '.join(want)+'\n',expected)
                self.assertIn('v1_wide='+' '.join(wide)+'\n',expected)

    def test_partial_copy_maps_declaration_order_and_preserves_untouched_guard(self):
        source,expected=m.materialize(copy_case())
        self.assertIn('target[6:7] = source[4:3];',source)
        self.assertIn('v0_target='+'1'*32+' '+'0'*31+'1 '+'1'*32+'\n',expected)
        self.assertIn('v1_target='+'1'*32+' '+'0'*31+'1 '+'1'*32+'\n',expected)
        self.assertIn('v2_source='+'0'*32+' '+'1'*32+' z'+'0'*31+'\n',expected)

    def test_copying_is_by_value_and_guard_rewrites_do_not_modify_source(self):
        _,expected=m.materialize(copy_case())
        self.assertIn('v1_source='+'0'*32+' '+'1'*32+' z'+'0'*31+'\n',expected)
        self.assertIn('v2_target='+'x'*32+' '+'0'*31+'1 '+'1'*32+'\n',expected)
        self.assertIn('v3_target='+'1'*32+' z'+'0'*31+' '+'1'*32+'\n',expected)
        case=copy_case('bit');self.assertIn('v3_target='+'1'*32+' '+'0'*32+' '+'1'*32+'\n',m.materialize(case)[1])

    def test_saved_replay_preserves_both_array_profiles_without_redrawing(self):
        manifest=m.generate(731,6,8,('array_reduction_context','unpacked_array_copy_sequence'))
        with tempfile.TemporaryDirectory() as folder:
            first,second=Path(folder)/'first',Path(folder)/'second';records,_=evidence.prepare(manifest,first)
            with patch.object(m.random,'Random',side_effect=AssertionError('redrawn')):replay,_=evidence.prepare(manifest,second,first/'manifest.json')
            self.assertEqual(records,replay)
            for record in records.values():
                for field in ('source','expected'):self.assertEqual((first/record[field]).read_bytes(),(second/record[field]).read_bytes())

    def test_initial_values_and_all_ordered_operations_are_part_of_identity(self):
        case=copy_case();same=copy.deepcopy(case);same['id']='case_0001';self.assertEqual(m.content_digest(case),m.content_digest(same))
        changes=[copy.deepcopy(case) for _ in range(4)]
        changes[0]['stimuli']['source'][0]='0'*32;changes[1]['stimuli']['target'][0]='0'*32
        changes[2]['stimuli']['operations'].reverse();changes[3]['stimuli']['operations'].insert(1,copy.deepcopy(case['stimuli']['operations'][0]))
        for other in changes:self.assertNotEqual(m.content_digest(case),m.content_digest(other))
        self.assertNotEqual(m.materialize(case)[1],m.materialize(changes[2])[1])

    def test_all_new_xz_inputs_are_excluded_from_two_state_judging(self):
        reduction=reduction_case(state='bit');reduction['stimuli'][0]['values'][0]='z'*32
        for case in (reduction,copy_case('bit')):
            self.assertTrue(m.requires_fourstate(case))
            with patch.object(compare,'stage',side_effect=AssertionError('two-state execution')):
                result=compare.execute({'fourstate':True},Path('.'),'verilator',{},1,5,time.monotonic()+10)
            self.assertEqual(result['status'],'unsupported')

    def test_invalid_counts_ranges_payloads_and_caps_are_rejected(self):
        invalid=[]
        for field,value in [('count',0),('count',True),('count',6),('method','evil'),('transform',[])]:
            case=reduction_case();case['parameters'][field]=value;invalid.append(case)
        case=reduction_case();case['stimuli'][0]['values']=[];invalid.append(case)
        for field,value in [('length',0),('length',4),('source_start',2),('target_start',True)]:
            case=copy_case();case['stimuli']['operations'][0][field]=value;invalid.append(case)
        case=copy_case();case['stimuli']['operations'][1]['index']=3;invalid.append(case)
        case=copy_case();case['stimuli']['source']=['0'*32];invalid.append(case)
        for profile in ('array_reduction_context','unpacked_array_copy_sequence'):
            case=m.generate(1,1,32,(profile,))['cases'][0];items=case['stimuli'] if profile=='array_reduction_context' else case['stimuli']['operations']
            items.append(copy.deepcopy(items[0]));invalid.append(case)
        for case in invalid:
            with self.subTest(case=case),self.assertRaises(ValueError):m.materialize(case)

    def test_array_method_reference_dependency_is_fingerprinted(self):
        name='generators/interaction_method.py';self.assertIn(name,runner.SOURCES)
        self.assertEqual(runner.source_hashes()[name],runner.sha(m.ROOT/name))
