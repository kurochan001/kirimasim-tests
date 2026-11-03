"""Comparisons and reductions: truth tables, context, replay and legacy streams."""

import copy
import hashlib
from itertools import product
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


def comparison_case(op='eq', width=32, relation='same', signs=('signed','signed'), wr=7):
    wb=width+{'narrow':-1,'same':0,'wide':1}[relation]
    return {'id':'case_0000','profile':'comparison_context',
            'parameters':{'width':width,'rhs_relation':relation,'sign_a':signs[0],'sign_b':signs[1],
                          'operator':op,'result_width':wr},
            'stimuli':[{'a':'0'*width,'b':'0'*wb}]}


def logic_case(shape='direct', state='logic', result_state='logic', wr=7):
    return {'id':'case_0000','profile':'packed_logic_context',
            'parameters':{'width':32,'state':state,'sign':'signed','shape':shape,'span':32,'offset':0,
                          'result_state':result_state,'result_width':wr},
            'stimuli':[{'source':'0'+'x'*30+'1'}]}


def result(case):
    return m.materialize(case)[1].splitlines()[-1]


class PredicateProfileTests(unittest.TestCase):
    def test_nine_profile_corpus_and_materialized_bytes_keep_previous_hashes(self):
        goldens={1:('b4ea591f21efe465e41f063eb0d00e0c7807c6568ff300bdf54a11b23b5a8c5e','1514bcb207f20595b2d4b52430ec36841196fd92b274b4ef28e950586eab26c0'),
                 731:('0d2492c1c780916767a14a81c2c0033ba63d3cdb30eda3a99aaf041a520471c1','bf9d8d04600e3a0b1df5f14a976e946147cdc4e3524adc2b15e282b327409f92'),
                 20261103:('cd77d75022c23cd029b0d481f4094b546640e7e5e4f564ecfc484b35bb1dd6d9','3abb59a7768994c052e847507aadee0c133084f1cce91ac27978b4d3be400f79')}
        for seed,(manifest_hash,bytes_hash) in goldens.items():
            manifest=m.generate(seed,96,8,m.NINE_PROFILES)
            self.assertEqual(evidence.digest(manifest),manifest_hash)
            self.assertEqual(hashlib.sha256(''.join(s+e for s,e in map(m.materialize,manifest['cases'])).encode()).hexdigest(),bytes_hash)

    def test_all_fixed_comparison_rows_and_four_inputs_match(self):
        for row in m.comparisons.MODEL.rows():
            w,relation,sa,sb,op,_=row;case=comparison_case(op,int(w),relation,(sa,sb))
            case['stimuli']=[dict(zip(('a','b'),m.comparisons.inputs(row,i))) for i in range(4)]
            expected=[]
            for i,vector in enumerate(case['stimuli']):
                a,b=vector['a'],vector['b'];r=m.comparisons.compare(a,b,sa,sb,op)
                expected += [f'v{i}_inputs={a} {b}',f'v{i}_result={r} wide=000000{r} binary=000000{m.bit_values.two_state(r)} bits=1']
            self.assertEqual(m.materialize(case)[1],'\n'.join(expected)+'\n',row)

    def test_one_bit_equality_tables_independently_define_wildcards(self):
        for a,b in product('01xz',repeat=2):
            for op in ('eq','ne','ceq','cne','weq','wne'):
                if op.startswith('c'):r=str(int(a==b))
                elif op.startswith('w') and b in 'xz':r='1'
                elif a in 'xz' or b in 'xz':r='x'
                else:r=str(int(a==b))
                if op in ('ne','cne','wne') and r!='x':r=str(1-int(r))
                case=comparison_case(op,1);case['stimuli']=[{'a':a,'b':b}]
                self.assertEqual(result(case),f'v0_result={r} wide=000000{r} binary=000000{m.bit_values.two_state(r)} bits=1')

    def test_known_mismatch_resolves_equality_but_not_relational_unknown(self):
        case=comparison_case();case['stimuli']=[{'a':'1'+'0'*30+'x','b':'0'*32}]
        self.assertIn('result=0 wide=0000000',result(case))
        case['parameters']['operator']='lt';self.assertIn('result=x wide=000000x binary=0000000',result(case))
        case['stimuli'][0]['a']='0'*31+'x';case['parameters']['operator']='eq';self.assertIn('result=x',result(case))

    def test_only_rhs_unknowns_are_wildcards(self):
        case=comparison_case('weq');case['stimuli']=[{'a':'x'+'0'*31,'b':'0'*32}]
        self.assertIn('result=x',result(case))
        case['stimuli']=[{'a':'0'*32,'b':'x'+'0'*31}];self.assertIn('result=1',result(case))

    def test_arbitrary_known_comparisons_match_integer_oracle_and_ignore_result_width(self):
        rng=random.Random(731)
        for w in m.WIDTHS:
            for relation in ('same','wide') if w==1 else ('narrow','same','wide'):
                wb=w+{'narrow':-1,'same':0,'wide':1}[relation]
                for sa,sb in product(('signed','unsigned'),repeat=2):
                    a,b=rng.getrandbits(w),rng.getrandbits(wb)
                    if sa==sb=='signed':a-=1<<w if a>>(w-1) else 0;b-=1<<wb if b>>(wb-1) else 0
                    values={'lt':a<b,'le':a<=b,'gt':a>b,'ge':a>=b,'eq':a==b,'ne':a!=b,'ceq':a==b,'cne':a!=b,'weq':a==b,'wne':a!=b}
                    for op,want in values.items():
                        case=comparison_case(op,w,relation,(sa,sb),wr=130)
                        case['stimuli']=[{'a':f'{a&((1<<w)-1):0{w}b}','b':f'{b&((1<<wb)-1):0{wb}b}'}]
                        self.assertIn(f'result={int(want)} wide='+('0'*129+str(int(want))),result(case))

    def test_all_fixed_logical_rows_and_known_baselines_match(self):
        for row in m.logical.MODEL.rows():
            w,state,shape,_,_,rs=row
            for baseline in (False,True):
                raw,stored,operand,values=m.logical.reference(row,baseline=baseline)
                case=logic_case('slice' if shape=='half' else shape,state,rs)
                case['parameters'].update(width=int(w),span=int(w)//2 if shape=='half' else int(w))
                case['stimuli']=[{'source':raw}]
                expected=[f'v0_input={raw} source={stored} expr={operand}']
                expected += [f'v0_{op}={scalar} wide={wide} bits=1' for op,(scalar,wide) in values.items()]
                self.assertEqual(m.materialize(case)[1],'\n'.join(expected)+'\n',row)

    def test_exhaustive_short_reductions_follow_independent_fold(self):
        def fold(values,op):
            total='1' if op=='and' else '0'
            for v in values:
                v='x' if v=='z' else v
                if op=='and':total='0' if '0' in (total,v) else '1' if total==v=='1' else 'x'
                elif op=='or':total='1' if '1' in (total,v) else '0' if total==v=='0' else 'x'
                else:total='x' if 'x' in (total,v) else str(int(total)^int(v))
            return total
        invert={'0':'1','1':'0','x':'x'}
        for n in range(1,5):
            for values in product('01xz',repeat=n):
                result=m.logical.evaluate(''.join(values));a,o,x=(fold(values,op) for op in ('and','or','xor'))
                self.assertEqual(result,{'and':a,'nand':invert[a],'or':o,'nor':invert[o],'xor':x,'xnor':invert[x],'not':invert[o]})

    def test_controlling_bits_and_input_coercion_have_distinct_effects(self):
        case=logic_case();expected=m.materialize(case)[1]
        self.assertIn('v0_and=0',expected);self.assertIn('v0_or=1',expected);self.assertIn('v0_xor=x',expected);self.assertIn('v0_not=0',expected)
        case['parameters']['state']='bit';self.assertIn('v0_xor=1',m.materialize(case)[1])
        case=logic_case(result_state='bit');expected=m.materialize(case)[1];self.assertIn('v0_xor=x wide=0000000',expected)

    def test_prefix_and_arbitrary_slice_are_applied_after_input_conversion(self):
        case=logic_case('prefix_zero');case['stimuli']=[{'source':'1'*32}]
        self.assertIn('v0_and=0',m.materialize(case)[1])
        case=logic_case('prefix_one');case['stimuli']=[{'source':'x'*32}]
        self.assertIn('v0_or=1',m.materialize(case)[1])
        case=logic_case('slice');case['parameters'].update(span=3,offset=5);case['stimuli']=[{'source':'0'*24+'1xz'+'0'*5}]
        self.assertIn('expr=1xz\n',m.materialize(case)[1]);self.assertIn('source[7:5]',m.materialize(case)[0])
        case['parameters']['state']='bit';self.assertIn('expr=100\n',m.materialize(case)[1])

    def test_one_bit_results_zero_extend_even_for_signed_source(self):
        case=logic_case(wr=130);case['stimuli']=[{'source':'1'*32}]
        self.assertIn('v0_and=1 wide='+'0'*129+'1 bits=1',m.materialize(case)[1])
        case=comparison_case('ceq',wr=130);self.assertIn('result=1 wide='+'0'*129+'1',result(case))

    def test_replay_preserves_actual_new_stimuli_without_redrawing(self):
        manifest=m.generate(731,6,8,('comparison_context','packed_logic_context'))
        with tempfile.TemporaryDirectory() as folder:
            first,second=Path(folder)/'first',Path(folder)/'second';records,_=evidence.prepare(manifest,first)
            with patch.object(m.random,'Random',side_effect=AssertionError('redrawn')):replay,_=evidence.prepare(manifest,second,first/'manifest.json')
            self.assertEqual(records,replay)
            for record in records.values():
                for field in ('source','expected'):self.assertEqual((first/record[field]).read_bytes(),(second/record[field]).read_bytes())

    def test_ids_are_administrative_but_input_and_order_change_content_identity(self):
        for case in (comparison_case(),logic_case()):
            same=copy.deepcopy(case);same['id']='case_0001';self.assertEqual(m.content_digest(case),m.content_digest(same))
            key='a' if case['profile']=='comparison_context' else 'source';same['stimuli'][0][key]='1'*32
            self.assertNotEqual(m.content_digest(case),m.content_digest(same))
            a=copy.deepcopy(case);a['stimuli']+=same['stimuli'];b=copy.deepcopy(a);b['stimuli'].reverse();self.assertNotEqual(m.content_digest(a),m.content_digest(b))

    def test_fourstate_classification_prevents_two_state_judging(self):
        for case in (comparison_case(),logic_case(state='bit',result_state='bit')):
            key='a' if case['profile']=='comparison_context' else 'source';case['stimuli'][0][key]='z'*32
            self.assertTrue(m.requires_fourstate(case))
            with patch.object(compare,'stage',side_effect=AssertionError('two-state execution')):
                verdict=compare.execute({'fourstate':True},Path('.'),'verilator',{},1,5,time.monotonic()+10)
            self.assertEqual(verdict['status'],'unsupported')

    def test_invalid_shapes_bounds_and_caps_are_rejected(self):
        invalid=[]
        for field,value in [('width',True),('operator',[]),('operator','evil'),('result_width',0),('result_width',131)]:
            case=comparison_case();case['parameters'][field]=value;invalid.append(case)
        for field,value in [('span',0),('offset',True),('offset',1),('shape','evil'),('result_state','evil')]:
            case=logic_case();case['parameters'][field]=value;invalid.append(case)
        case=logic_case();case['stimuli'][0]['source']='x; $finish';invalid.append(case)
        for profile in ('comparison_context','packed_logic_context'):
            case=m.generate(1,1,32,(profile,))['cases'][0];case['stimuli'].append(copy.deepcopy(case['stimuli'][0]));invalid.append(case)
        for case in invalid:
            with self.subTest(case=case),self.assertRaises(ValueError):m.materialize(case)

    def test_comparison_and_logical_reference_dependencies_are_hashed(self):
        for name in ('generators/interaction_compare.py','generators/interaction_logic.py'):
            self.assertIn(name,runner.SOURCES);self.assertEqual(runner.source_hashes()[name],runner.sha(m.ROOT/name))
