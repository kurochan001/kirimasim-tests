# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Hand-derived wide values, independent integer comparisons and replay integrity."""
import copy
import hashlib
from itertools import product
import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch

import random_cross_models as models
import random_cross_evidence as evidence
import run_random_cross as runner


def conditional(a=None, b=None, condition='1', signs=('signed', 'signed'),
                relation='wide', state='logic'):
    a = a if a is not None else '1'+'0'*254
    b = b if b is not None else '0'*len(a)
    return {'id':'case_0000', 'profile':'wide_conditional_context',
            'parameters':{'width':len(a), 'relation':relation, 'sign_a':signs[0],
                          'sign_b':signs[1], 'state':state},
            'stimuli':[{'a':a, 'b':b, 'condition':condition}]}


def comparison(a=None, b=None, operator='eq', signs=('unsigned', 'unsigned'),
               result_width=514):
    a = a if a is not None else '0'*255
    b = b if b is not None else a
    relation = {-1:'narrow', 0:'same', 1:'wide'}[len(b)-len(a)]
    return {'id':'case_0000', 'profile':'wide_comparison_context',
            'parameters':{'width':len(a), 'rhs_relation':relation, 'sign_a':signs[0],
                          'sign_b':signs[1], 'operator':operator, 'result_width':result_width},
            'stimuli':[{'a':a, 'b':b}]}


def expected_lines(case):
    return models.materialize(case)[1].splitlines()


class WideRandomProfileTests(unittest.TestCase):
    def test_signed_branch_extension_precedes_conditional_selection(self):
        case = conditional()
        self.assertEqual(expected_lines(case)[1], 'v0_result=11'+'0'*254)
        case['parameters']['sign_b'] = 'unsigned'
        self.assertEqual(expected_lines(case)[1], 'v0_result=01'+'0'*254)

    def test_unknown_condition_merges_identical_z_to_x_before_bit_storage(self):
        for width in (255, 513):
            case = conditional('z'*width, 'z'*width, 'x', relation='same')
            self.assertEqual(expected_lines(case)[1], 'v0_result='+'x'*width)
            case['parameters']['state'] = 'bit'
            self.assertEqual(expected_lines(case)[1], 'v0_result='+'0'*width)
            self.assertTrue(models.requires_fourstate(case))

    def test_equal_known_branches_remain_known_for_ambiguous_condition(self):
        value = '10'*256+'1'
        self.assertEqual(expected_lines(conditional(value,value,'z',relation='narrow'))[1],
                         'v0_result='+value[1:])

    def test_known_condition_preserves_selected_z_before_destination_conversion(self):
        value = '1'+'z'*254
        case = conditional(value,'0'*255,'1',relation='same')
        self.assertEqual(expected_lines(case)[1], 'v0_result='+value)
        case['parameters']['state'] = 'bit'
        self.assertEqual(expected_lines(case)[1], 'v0_result=1'+'0'*254)

    def test_mixed_sign_comparison_zero_extends_the_signed_operand(self):
        a, b = '1'*255, '0'*255+'1'
        case = comparison(a,b,'lt',('signed','signed'))
        self.assertEqual(expected_lines(case)[1], 'v0_result=1 wide='+'0'*513+'1 binary='+'0'*513+'1 bits=1')
        case['parameters']['sign_b'] = 'unsigned'
        self.assertEqual(expected_lines(case)[1], 'v0_result=0 wide='+'0'*514+' binary='+'0'*514+' bits=1')

    def test_unknown_comparison_result_stays_unsigned_one_bit_before_storage(self):
        case = comparison('0'*254+'x','0'*254+'1','eq')
        self.assertEqual(expected_lines(case)[1], 'v0_result=x wide='+'0'*513+'x binary='+'0'*514+' bits=1')
        self.assertTrue(models.requires_fourstate(case))

    def test_wildcards_apply_only_to_right_operand(self):
        prefix = '0'*254
        rhs_mask = comparison(prefix+'x',prefix+'z','weq')
        self.assertEqual(expected_lines(rhs_mask)[1], 'v0_result=1 wide='+'0'*513+'1 binary='+'0'*513+'1 bits=1')
        lhs_unknown = comparison(prefix+'x',prefix+'1','weq')
        self.assertTrue(expected_lines(lhs_unknown)[1].startswith('v0_result=x wide='))
        unequal = comparison('x'+'0'*253+'0', 'x'+'0'*253+'1','eq')
        self.assertTrue(expected_lines(unequal)[1].startswith('v0_result=0 wide='))

    def test_ten_known_operators_match_independent_python_integer_order(self):
        operations = {'lt':lambda a,b:a<b,'le':lambda a,b:a<=b,
                      'gt':lambda a,b:a>b,'ge':lambda a,b:a>=b,
                      'eq':lambda a,b:a==b,'ne':lambda a,b:a!=b,
                      'ceq':lambda a,b:a==b,'cne':lambda a,b:a!=b,
                      'weq':lambda a,b:a==b,'wne':lambda a,b:a!=b}
        for width, delta, signs, operator in product((257,513),(-1,0,1),
                product(('signed','unsigned'),repeat=2),operations):
            wb = width+delta
            for av,bv in [((1<<width)-1,1),(1<<(width-1),(1<<wb)-1),
                          ((1<<(width-1))-1,(1<<(wb-1))-1)]:
                a,b = f'{av:0{width}b}',f'{bv:0{wb}b}'
                if signs == ('signed','signed'):
                    av -= (1<<width) if a[0]=='1' else 0
                    bv -= (1<<wb) if b[0]=='1' else 0
                bit = str(int(operations[operator](av,bv)))
                got = expected_lines(comparison(a,b,operator,signs,7))[1]
                self.assertEqual(got,f'v0_result={bit} wide=000000{bit} binary=000000{bit} bits=1')

    def test_previous_sixteen_profile_manifests_and_sources_are_unchanged(self):
        goldens = {1: ('f04235b7c0f15fd24b60e33bb27db4fdc7f5918aea1e39ad91dcdfa326ea5824', '9a6e58026fa141c6441e57439e055d5f4fa5dc6cfc897f1d692f3da022bebe5b'), 731: ('e1175356ab66c64c3d23afc936d9bf989011d8cf6e69077065dd9e7327217454', '91efb86fa68e4fe70a96749a5fc5b83708982df14f9f622402038c9789f4f052'), 20261119: ('319317a83b44c4032d8fd1ba65fedbb291731766e171552b166258241a6925b1', '2425ddf9dfdd57ca368b45b5461e8314510621b3c6b0c65581f4de7028b8ea4e')}
        profiles = models.SUPPORTED_PROFILES[:16]
        for seed, (manifest_hash, materialized_hash) in goldens.items():
            manifest = models.generate(seed, 96, 8, profiles)
            self.assertEqual(hashlib.sha256(models.canonical(manifest).encode()).hexdigest(),
                             manifest_hash)
            content = ''.join(s+e for s,e in map(models.materialize,manifest['cases']))
            self.assertEqual(hashlib.sha256(content.encode()).hexdigest(), materialized_hash)

    def test_new_profiles_are_opt_in_and_do_not_replace_previous_domains(self):
        self.assertEqual(len(models.PROFILES),13)
        self.assertEqual(len(models.SUPPORTED_PROFILES),22)
        self.assertEqual(models.WIDE_PROFILES,('wide_conditional_context','wide_comparison_context'))
        self.assertFalse(set(models.WIDE_PROFILES)&set(models.PROFILES))
        for case in [conditional(),comparison()]:
            case['profile'] = case['profile'].removeprefix('wide_')
            with self.assertRaises(ValueError):models.validate_case(case)

    def test_deterministic_generation_contains_known_and_fourstate_programs(self):
        for seed in (1,731,20261119):
            manifest = models.generate(seed,96,8,models.WIDE_PROFILES)
            self.assertEqual(manifest,models.generate(seed,96,8,models.WIDE_PROFILES))
            states = [models.requires_fourstate(case) for case in manifest['cases']]
            self.assertGreater(sum(states),20)
            self.assertGreater(len(states)-sum(states),20)
            with patch.object(models.random,'Random',side_effect=AssertionError('replay drew randomness')):
                models.validate(manifest)
                for case in manifest['cases']:
                    self.assertEqual(models.materialize(case),models.materialize(copy.deepcopy(case)))

    def test_invalid_widths_destinations_and_vector_shapes_are_rejected(self):
        for case in [conditional(),comparison()]:
            for field,value in [('width',True),('width',129),('width',250),('sign_a','real')]:
                bad=copy.deepcopy(case);bad['parameters'][field]=value
                with self.assertRaises(ValueError):models.validate_case(bad)
            for stimuli in [[],case['stimuli']*33,[{'a':'0','b':'0'}]]:
                bad=copy.deepcopy(case);bad['stimuli']=stimuli
                with self.assertRaises(ValueError):models.validate_case(bad)
        case=comparison();case['parameters']['result_width']=515
        with self.assertRaises(ValueError):models.validate_case(case)

    def test_wide_literals_use_exact_width_chunks_and_driver_hashes_formatter(self):
        text,_=models.materialize(conditional('z'*513,'0'*513))
        self.assertNotIn("513'b",text)
        self.assertIn("64'b",text)
        self.assertIn("1'bz",text)
        self.assertIn('generators/wide_literals.py',runner.SOURCES)

    def test_saved_replay_preserves_baseline_and_flags_reference_drift(self):
        case=comparison(operator='ceq',result_width=7)
        manifest={'schema':1,'generator':models.GENERATOR,'seed':1,'cases':[case]}
        with tempfile.TemporaryDirectory() as temporary:
            base=Path(temporary);records,_=evidence.prepare(manifest,base/'original')
            current,info=evidence.prepare(manifest,base/'replay',base/'original/manifest.json')
            self.assertEqual(records,current)
            self.assertFalse(info['cases']['case_0000']['expected_changed'])
            original=models.materialize_comparison
            def corrupt(case):
                lines,expected=original(case)
                return lines,[x.replace('v0_result=1','v0_result=0') for x in expected]
            with patch.object(models,'materialize_comparison',side_effect=corrupt):
                _,info=evidence.prepare(manifest,base/'drift',base/'original/manifest.json')
            self.assertTrue(info['cases']['case_0000']['expected_changed'])
            self.assertEqual((base/'drift/cases/case_0000.expected').read_bytes(),
                             (base/'original/cases/case_0000.expected').read_bytes())
            self.assertIn('v0_result=0',(base/'drift/current-reference/case_0000.expected').read_text())


if __name__ == '__main__':
    unittest.main()
