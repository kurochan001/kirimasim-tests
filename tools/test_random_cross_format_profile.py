# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent digit arithmetic, known-only scope and immutable replay controls."""
import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import random_cross_models as models
import random_cross_format as formatting
import random_cross_evidence as evidence
import run_random_cross as runner


def case(source=None, sign='unsigned', radix='b', vectors=None):
    source='0'*255 if source is None else source
    return {'id':'case_0000','profile':'wide_format_scan_sequence',
            'parameters':{'width':len(source),'sign':sign,'radix':radix},
            'stimuli':vectors if vectors is not None else [{'source':source}]}


def output(case):return models.materialize(case)[1].splitlines()


def digits(value,base):
    if value==0:return '0'
    result='';negative=value<0;value=abs(value)
    while value:
        value,remainder=divmod(value,base);result='0123456789abcdef'[remainder]+result
    return ('-' if negative else '')+result


def independent_text(bits,sign,radix):
    value=0
    for bit in bits:value=2*value+(bit=='1')
    if radix=='d' and sign=='signed' and bits[0]=='1':value-=2**len(bits)
    return digits(value,{'b':2,'h':16,'d':10}[radix])


class WideFormatProfileTests(unittest.TestCase):
    def test_minimum_zero_strings_are_one_character(self):
        for width in formatting.WIDTHS:
            for sign in ('signed','unsigned'):
                for radix in formatting.RADICES:
                    self.assertEqual(output(case('0'*width,sign,radix))[1],
                                     'v0_text=0 length=1')

    def test_signed_minimum_decimal_retains_all_bits(self):
        bits='1'+'0'*512;expected='-'+digits(2**512,10)
        self.assertEqual(output(case(bits,'signed','d'))[1],
                         f'v0_text={expected} length={len(expected)}')
        self.assertEqual(output(case(bits,'signed','d'))[2],
                         f'v0_parsed={bits} count=1 source_after={bits}')

    def test_unsigned_all_ones_decimal_is_not_host_sized(self):
        bits='1'*513;expected=digits(2**513-1,10)
        self.assertEqual(output(case(bits,'unsigned','d'))[1],
                         f'v0_text={expected} length={len(expected)}')

    def test_binary_and_hex_format_physical_bits_for_both_signs(self):
        for sign in ('signed','unsigned'):
            self.assertEqual(output(case('1'*257,sign,'b'))[1],
                             'v0_text='+'1'*257+' length=257')
            self.assertEqual(output(case('1'*257,sign,'h'))[1],
                             'v0_text=1'+'f'*64+' length=65')

    def test_all_formats_match_independent_repeated_digit_division(self):
        for width in (255,257,513):
            for value in (0,1,2**(width-1),2**width-1,2**(width-1)+17):
                bits=f'{value:0{width}b}'
                for sign in ('signed','unsigned'):
                    for radix in formatting.RADICES:
                        expected=independent_text(bits,sign,radix)
                        self.assertEqual(output(case(bits,sign,radix))[1],
                                         f'v0_text={expected} length={len(expected)}')

    def test_lowercase_method_and_citation_are_hex_only(self):
        for radix in formatting.RADICES:
            source,_=models.materialize(case(radix=radix))
            self.assertEqual('text = text.tolower();' in source,radix=='h')
            self.assertEqual('6.16.5' in source,radix=='h')
            self.assertIn('21.3.3',source)

    def test_input_text_parsed_count_and_width_are_separate_observations(self):
        bits='0'*256+'1';lines=output(case(bits,'signed','h'))
        self.assertEqual(lines,[f'v0_input={bits}','v0_text=1 length=1',
                                f'v0_parsed={bits} count=1 source_after={bits}',
                                'widths=257,257'])

    def test_sequence_order_and_duplicate_vectors_are_preserved(self):
        a,b='0'*255,'1'*255
        first=case(a,vectors=[{'source':x} for x in (a,a,b,a)])
        second=case(a,vectors=[{'source':x} for x in (a,b,a,a)])
        self.assertNotEqual(models.content_digest(first),models.content_digest(second))
        self.assertEqual(len(output(first)),13)
        self.assertEqual([line.split('=',1)[1] for line in output(first) if '_input=' in line],
                         [a,a,b,a])
        source,_=models.materialize(first);self.assertEqual(source.count('$sscanf('),4)

    def test_parameter_domains_reject_booleans_unknown_fields_and_old_widths(self):
        for key,value in [('width',True),('width',129),('width',250),('width',514),
                          ('sign','logic'),('radix','x')]:
            bad=case();bad['parameters'][key]=value
            with self.assertRaises(ValueError):models.validate_case(bad)
        bad=case();bad['parameters']['extra']=0
        with self.assertRaises(ValueError):models.validate_case(bad)

    def test_vectors_require_known_full_width_data_and_bounded_counts(self):
        for vectors in ([],[{'source':'0'*255}]*33,[{'source':'0'}],
                        [{'source':'0'*254+'x'}],[{'source':'z'*255}],
                        [{'source':'0'*255,'extra':0}],[{'value':'0'*255}]):
            with self.assertRaises(ValueError):models.validate_case(case(vectors=vectors))

    def test_profile_is_opt_in_with_default_thirteen_and_known_only_scope(self):
        self.assertEqual(len(models.PROFILES),13)
        self.assertEqual(len(models.SUPPORTED_PROFILES),21)
        self.assertEqual(models.SUPPORTED_PROFILES[-1],'wide_format_scan_sequence')
        self.assertNotIn('wide_format_scan_sequence',models.PROFILES)
        self.assertFalse(models.requires_fourstate(case('1'*513,'signed','d')))

    def test_deterministic_generation_replays_without_rng_draws(self):
        for seed in (1,731,20261119):
            manifest=models.generate(seed,96,8,formatting.PROFILES)
            self.assertEqual(manifest,models.generate(seed,96,8,formatting.PROFILES))
            self.assertTrue(all(not models.requires_fourstate(c) for c in manifest['cases']))
            with patch.object(models.random,'Random',side_effect=AssertionError('replay drew randomness')):
                models.validate(manifest)
                for c in manifest['cases']:
                    self.assertEqual(models.materialize(c),models.materialize(copy.deepcopy(c)))
                    self.assertEqual(len(output(c)),25)

    def test_previous_twenty_profile_streams_are_unchanged(self):
        goldens = {1: ('fe7da8b53c1d011f56eae1a7c5395c4129bef279a0cf6db4c59dba9f0e725c2c', 'e7aa9dc31e744f49596fd08a3fc773b334ea71d8b50eee25f63965ec8cf7aba6'), 731: ('6425ba33cd8c4b32801ec4479f615529948b918091ff757470ab09d31e21dd2b', '36851179fa50990c52699e0324948905199b8602773a959e4352b337ee9e6dd1'), 20261119: ('67d81594a0bc6b3ff1a2509152f8e53924b47772d4bdf6dd713c2e27d1a5b7ec', 'e311a978900a47eb9f5c9200b20c398d25ef2ce447d5e2e983eac4e539d97166')}
        for seed,(manifest_hash,materialized_hash) in goldens.items():
            manifest=models.generate(seed,96,8,models.SUPPORTED_PROFILES[:20])
            self.assertEqual(hashlib.sha256(models.canonical(manifest).encode()).hexdigest(),manifest_hash)
            materialized=''.join(a+b for a,b in map(models.materialize,manifest['cases']))
            self.assertEqual(hashlib.sha256(materialized.encode()).hexdigest(),materialized_hash)
        self.assertEqual(len(goldens),3)

    def test_saved_replay_preserves_baseline_and_flags_reference_drift(self):
        manifest={'schema':1,'generator':models.GENERATOR,'seed':1,'cases':[case(radix='d')]}
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);original,_=evidence.prepare(manifest,root/'original')
            replay,info=evidence.prepare(manifest,root/'replay',root/'original/manifest.json')
            self.assertEqual(original,replay);self.assertFalse(info['cases']['case_0000']['expected_changed'])
            previous=formatting.materialize
            def corrupt(c):
                source,want,clauses=previous(c)
                return source,[line.replace('v0_text=0 length=1','v0_text=9 length=1') for line in want],clauses
            with patch.object(formatting,'materialize',side_effect=corrupt):
                _,info=evidence.prepare(manifest,root/'drift',root/'original/manifest.json')
            self.assertTrue(info['cases']['case_0000']['expected_changed'])
            self.assertEqual((root/'drift/cases/case_0000.expected').read_bytes(),
                             (root/'original/cases/case_0000.expected').read_bytes())
            self.assertIn('v0_text=9',(root/'drift/current-reference/case_0000.expected').read_text())

    def test_driver_watch_inventory_includes_profile_and_shared_decimal_helper(self):
        self.assertIn('tools/random_cross_format.py',runner.SOURCES)
        self.assertIn('generators/function_formal_contexts.py',runner.SOURCES)


if __name__=='__main__':unittest.main()
