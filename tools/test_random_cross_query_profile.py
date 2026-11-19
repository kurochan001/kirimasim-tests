# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent state planes, control conversion, ordered replay and drift checks."""
import copy
import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import random_cross_models as models
import random_cross_queries as queries
import random_cross_evidence as evidence
import run_random_cross as runner


def case(source=None,a='0',b='1',c='0',sign='unsigned',direction='descending',vectors=None):
    source='0'*255 if source is None else source
    return {'id':'case_0000','profile':'wide_bitquery_sequence',
            'parameters':{'width':len(source),'sign':sign,'direction':direction,'control_width':len(a)},
            'stimuli':vectors if vectors is not None else [{'source':source,'a':a,'b':b,'c':c}]}


def output(c):return models.materialize(c)[1].splitlines()


def planes(bits):
    one=x=z=0
    for index,char in enumerate(reversed(bits)):
        one|=(char=='1')<<index;x|=(char=='x')<<index;z|=(char=='z')<<index
    return {'0':((1<<len(bits))-1)^(one|x|z),'1':one,'x':x,'z':z}


class WideQueryProfileTests(unittest.TestCase):
    def test_zero_and_full_one_histograms(self):
        for width in queries.WIDTHS:
            self.assertEqual(output(case('0'*width))[1],f'v0_hist zeros={width} ones=0 x=0 z=0')
            self.assertEqual(output(case('1'*width))[1],f'v0_hist zeros=0 ones={width} x=0 z=0')

    def test_histograms_match_independent_disjoint_integer_planes(self):
        for width in queries.WIDTHS:
            value=('01xz'*((width+3)//4))[:width];p=planes(value)
            self.assertEqual(output(case(value))[1],
                             'v0_hist '+' '.join(label+'='+str(p[state].bit_count())
                              for label,state in [('zeros','0'),('ones','1'),('x','x'),('z','z')]))
            self.assertEqual(sum(v.bit_count() for v in p.values()),width)

    def test_unknown_without_ones_keeps_onehot0_true(self):
        value='x'+'0'*254
        self.assertIn('hot=0 hot0=1 unknown=1',output(case(value))[2])

    def test_two_ones_are_counted_even_with_other_unknown_bits(self):
        value='11xz'+'0'*251
        self.assertIn('hot=0 hot0=0 unknown=1',output(case(value))[2])

    def test_wide_controls_use_only_lsb_and_deduplicate(self):
        value='0'*248+'101xzz0';a='1'*254+'x';b='z'*254+'1';c='0'*254+'x'
        line=output(case(value,a,b,c))[2]
        self.assertTrue(line.endswith('selected=3 single=1'))
        self.assertEqual(line,output(case(value,a,c,b))[2])
        source,_=models.materialize(case(value,a,b,c))
        self.assertIn('$countbits(source, control_a, control_b, control_c, control_a)',source)

    def test_three_state_union_counts_each_selected_bit_once(self):
        value='01xz'+'0'*251
        self.assertTrue(output(case(value,'0','1','x'))[2].endswith('selected=254 single=252'))
        self.assertTrue(output(case(value,'x','z','x'))[2].endswith('selected=2 single=1'))

    def test_signedness_and_range_direction_do_not_change_counts(self):
        value='1xz'+'0'*252;reference=output(case(value))
        for sign in ('signed','unsigned'):
            for direction in ('ascending','descending'):
                c=case(value,sign=sign,direction=direction)
                self.assertEqual(output(c),reference)
                self.assertIn('[0:254]' if direction=='ascending' else '[254:0]',models.materialize(c)[0])

    def test_input_query_retention_and_return_width_observations_are_separate(self):
        value='0'*254+'1';lines=output(case(value))
        self.assertEqual(len(lines),5)
        self.assertEqual(lines[0],f'v0_input={value} a=0 b=1 c=0')
        self.assertEqual(lines[3],f'v0_after={value} a=0 b=1 c=0')
        self.assertEqual(lines[4],'return_bits=32,32,1,1,1')

    def test_actual_fourstate_scope_includes_ignored_upper_control_bits(self):
        self.assertFalse(models.requires_fourstate(case()))
        self.assertTrue(models.requires_fourstate(case(a='x'+'0'*254,b='0'*255,c='0'*255)))
        self.assertTrue(models.requires_fourstate(case('0'*254+'z')))

    def test_sequence_order_and_duplicate_inputs_are_preserved(self):
        a=case()['stimuli'][0];b=dict(a,source='1'*255)
        first=case(vectors=[a,a,b,a]);second=case(vectors=[a,b,a,a])
        self.assertNotEqual(models.content_digest(first),models.content_digest(second))
        self.assertEqual(len(output(first)),17)
        self.assertEqual([x.split('=',1)[1].split(' ',1)[0] for x in output(first) if '_input=' in x],
                         [a['source'],a['source'],b['source'],a['source']])

    def test_parameter_and_vector_domains_reject_malformed_inputs(self):
        for key,value in [('width',True),('width',129),('control_width',True),('control_width',2),
                          ('direction','up'),('sign','logic'),('extra',0)]:
            bad=case();bad['parameters'][key]=value
            with self.assertRaises(ValueError):models.validate_case(bad)
        for vectors in ([],[case()['stimuli'][0]]*33,[{'source':'0'*255}],
                        [dict(case()['stimuli'][0],a='00')],[dict(case()['stimuli'][0],source='q'*255)]):
            with self.assertRaises(ValueError):models.validate_case(case(vectors=vectors))

    def test_opt_in_determinism_and_replay_without_random_draws(self):
        self.assertEqual(len(models.PROFILES),13);self.assertEqual(len(models.SUPPORTED_PROFILES),22)
        self.assertNotIn(queries.PROFILES[0],models.PROFILES)
        for seed in (1,731,20261119):
            manifest=models.generate(seed,96,8,queries.PROFILES)
            self.assertEqual(manifest,models.generate(seed,96,8,queries.PROFILES))
            with patch.object(models.random,'Random',side_effect=AssertionError('replay used RNG')):
                models.validate(manifest)
                for c in manifest['cases']:
                    self.assertEqual(models.materialize(c),models.materialize(copy.deepcopy(c)))
                    self.assertEqual(len(output(c)),33)

    def test_prior_twenty_one_profile_goldens_remain_exact(self):
        goldens = {1: ('cad042a0f0ea4c3195b9a24f85acf890fe125d1e2f68cb4993cb3b6efcf1e985', 'dc98a4cb26bd688143c2055628e18fba340153f494e6fdda40b0f1e51f698042'), 731: ('9cf9ad6ef5ac96af3ef843a7a7c4021abd1450341a4956faeb30467f64764c36', '55347d0b578d29c8aaa6f579400e93f73d5f15fe376c2ca3e3feefe8690834e7'), 20261119: ('e1043ba78667180a45e1bf225eeb2392cba0b1c7f152d7e9edac44c5f2b46d40', '5bd2ff9f9864d3797b3a4c9c7d1b304479f2941903574d0a800ba350e84c133c')}
        for seed,(manifest_hash,materialized_hash) in goldens.items():
            manifest=models.generate(seed,96,8,models.SUPPORTED_PROFILES[:21])
            self.assertEqual(hashlib.sha256(models.canonical(manifest).encode()).hexdigest(),manifest_hash)
            self.assertEqual(hashlib.sha256(''.join(a+b for a,b in map(models.materialize,manifest['cases'])).encode()).hexdigest(),materialized_hash)

    def test_saved_replay_keeps_old_expectation_when_reference_drifts(self):
        manifest={'schema':1,'generator':models.GENERATOR,'seed':1,'cases':[case()]}
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);original,_=evidence.prepare(manifest,root/'original')
            replay,info=evidence.prepare(manifest,root/'replay',root/'original/manifest.json')
            self.assertEqual(original,replay);self.assertFalse(info['cases']['case_0000']['expected_changed'])
            previous=queries.materialize
            def corrupt(c):
                source,want,clauses=previous(c)
                return source,[line.replace('zeros=255','zeros=254') for line in want],clauses
            with patch.object(queries,'materialize',side_effect=corrupt):
                _,info=evidence.prepare(manifest,root/'drift',root/'original/manifest.json')
            self.assertTrue(info['cases']['case_0000']['expected_changed'])
            self.assertEqual((root/'drift/cases/case_0000.expected').read_bytes(),(root/'original/cases/case_0000.expected').read_bytes())
            self.assertIn('zeros=254',(root/'drift/current-reference/case_0000.expected').read_text())

    def test_driver_watches_the_new_materializer(self):
        self.assertIn('tools/random_cross_queries.py',runner.SOURCES)


if __name__=='__main__':unittest.main()
