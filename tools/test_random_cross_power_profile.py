# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Hand-derived power boundaries and independent modular-arithmetic checks."""
import copy
import hashlib
from itertools import product
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import random_cross_models as models
import random_cross_power as powers
import random_cross_evidence as evidence
import run_random_cross as runner


def sample(base='11', exponent='111', base_sign='unsigned', exponent_sign='unsigned',
           state='logic', relation='wide'):
    return {'id': 'case_0000', 'profile': 'integral_power_context',
            'parameters': {'width': len(base), 'exponent_width': len(exponent),
                           'base_sign': base_sign, 'exponent_sign': exponent_sign,
                           'relation': relation, 'state': state},
            'stimuli': [{'base': base, 'exponent': exponent}]}


def observations(case):
    return dict(line.split('=', 1) for line in models.materialize(case)[1].splitlines())


def repeated_square(base, exponent, width):
    """Independent small-state modular arithmetic; never calls the reference."""
    modulus = 1 << width
    accumulator = 1
    while exponent:
        if exponent & 1:
            accumulator = accumulator * base % modulus
        base = base * base % modulus
        exponent //= 2
    return accumulator % modulus


class IntegralPowerProfileTests(unittest.TestCase):
    def test_unsigned_and_signed_base_have_distinct_hand_derived_results(self):
        unsigned = observations(sample())  # 3**7 = 2187; low five bits are eleven.
        self.assertEqual(unsigned['v0_narrow'], '11')
        self.assertEqual(unsigned['v0_full'], '01011')
        self.assertEqual(unsigned['v0_captured'], '00011')
        signed = observations(sample(base_sign='signed'))
        self.assertEqual(signed['v0_narrow'], '11')
        self.assertEqual(signed['v0_full'], '11111')
        self.assertEqual(signed['v0_captured'], '11111')

    def test_negative_exponent_sign_does_not_change_base_sign(self):
        value = observations(sample(exponent_sign='signed'))  # 3**-1 -> integral zero.
        self.assertEqual(value['v0_full'], '00000')
        self.assertEqual(value['v0_narrow'], '00')
        value = observations(sample(base_sign='signed', exponent_sign='signed'))
        self.assertEqual(value['v0_full'], '11111')  # (-1)**-1.
        value = observations(sample(base_sign='signed', exponent_sign='signed', exponent='110'))
        self.assertEqual(value['v0_full'], '00001')  # (-1)**-2.

    def test_context_extension_precedes_power_but_capture_extends_after(self):
        value = observations(sample(base='10', exponent='011', base_sign='signed'))
        self.assertEqual(value['v0_narrow'], '00')  # -8 modulo four.
        self.assertEqual(value['v0_full'], '11000')  # -8 modulo thirty-two.
        self.assertEqual(value['v0_captured'], '00000')
        self.assertEqual(value['v0_widths'], '2,3,5')

    def test_zero_to_negative_power_is_unknown_before_bit_storage(self):
        case = sample(base='00', exponent_sign='signed', state='bit')
        value = observations(case)
        self.assertTrue(models.requires_fourstate(case))
        self.assertEqual(value['v0_narrow'], 'xx')
        self.assertEqual(value['v0_full'], 'xxxxx')
        self.assertEqual(value['v0_captured'], '000xx')  # Unsigned narrow X extends with zeros.
        signed = observations(sample(base='00', exponent_sign='signed', state='bit', base_sign='signed'))
        self.assertEqual(signed['v0_captured'], 'xxxxx')
        self.assertEqual(value['v0_stored'], '00000')
        self.assertEqual(value['v0_converted'], '00000')

    def test_known_zero_exponent_returns_one_and_keeps_expression_width(self):
        value = observations(sample(base='00', exponent='000'))
        self.assertEqual(value['v0_narrow'], '01')
        self.assertEqual(value['v0_full'], '00001')
        self.assertEqual(value['v0_captured'], '00001')
        self.assertEqual(value['v0_widths'], '2,3,5')

    def test_explicit_unknown_inputs_remain_observable_before_conversion(self):
        for base, exponent in [('z1', '010'), ('11', 'x10')]:
            case = sample(base=base, exponent=exponent, state='bit')
            value = observations(case)
            self.assertTrue(models.requires_fourstate(case))
            self.assertEqual(value['v0_base'], base)
            self.assertEqual(value['v0_exponent'], exponent)
            self.assertEqual(value['v0_full'], 'xxxxx')
            self.assertEqual(value['v0_stored'], '00000')

    def test_65_bit_exponent_is_not_narrowed_or_signed_by_its_base(self):
        exponent = '1' + '0' * 64
        unsigned = observations(sample(exponent=exponent))
        signed = observations(sample(exponent=exponent, exponent_sign='signed'))
        self.assertEqual(unsigned['v0_full'], '00001')  # 3 has period eight modulo 32.
        self.assertEqual(signed['v0_full'], '00000')  # 3 to a negative integral power.
        self.assertEqual(unsigned['v0_widths'], '2,65,5')
        self.assertEqual(unsigned['v0_exponent'], exponent)
        self.assertFalse(models.requires_fourstate(sample(exponent=exponent)))

    def test_narrow_destination_does_not_change_natural_expression_width(self):
        value = observations(sample(relation='narrow'))
        self.assertEqual(value['v0_full'], '1')
        self.assertEqual(value['v0_narrow'], '11')
        self.assertEqual(value['v0_widths'], '2,3,1')

    def test_small_known_powers_match_independent_repeated_squaring(self):
        for base, exponent, sign_a, sign_b in product(range(4), range(8),
                                                     ('signed', 'unsigned'), ('signed', 'unsigned')):
            case = sample(base=f'{base:02b}', exponent=f'{exponent:03b}',
                          base_sign=sign_a, exponent_sign=sign_b)
            value = observations(case)
            a = base - 4 if sign_a == 'signed' and base >= 2 else base
            e = exponent - 8 if sign_b == 'signed' and exponent >= 4 else exponent
            if e < 0:
                expected = 'xxxxx' if a == 0 else f'{(1 if a == 1 else (-1 if e & 1 else 1) if a == -1 else 0) % 32:05b}'
            else:
                expected = f'{repeated_square(a, e, 5):05b}'
            self.assertEqual(value['v0_full'], expected, (a, e))

    def test_opt_in_generation_is_deterministic_and_replay_draws_nothing(self):
        selected = powers.PROFILES
        manifest = models.generate(731, 96, 8, selected)
        self.assertEqual(manifest, models.generate(731, 96, 8, selected))
        self.assertTrue(all(case['profile'] == 'integral_power_context' for case in manifest['cases']))
        with patch.object(models.random, 'Random', side_effect=AssertionError('replay drew randomness')):
            models.validate(manifest)
            for case in manifest['cases']:
                self.assertEqual(models.materialize(case), models.materialize(copy.deepcopy(case)))

    def test_defaults_and_the_two_previous_opt_in_profiles_are_preserved(self):
        self.assertEqual(len(models.PROFILES), 13)
        self.assertEqual(models.EXTRA_PROFILES, ('packed_bounds_sequence', 'packed_field_sequence'))
        self.assertEqual(len(models.SUPPORTED_PROFILES), 22)
        self.assertNotIn('integral_power_context', models.PROFILES)
        self.assertIn('integral_power_context', models.SUPPORTED_PROFILES)

    def test_invalid_parameters_and_unknown_base_zero_are_rejected(self):
        changes = [('width', True), ('width', 3), ('exponent_width', 64),
                   ('base_sign', 'real'), ('relation', 'other'), ('state', 'wire')]
        for field, value in changes:
            case = sample();case['parameters'][field] = value
            with self.assertRaises(ValueError):
                models.validate_case(case)
        for vector in [{'base': 'z1', 'exponent': '000'}, {'base': '11', 'exponent': '01'},
                       {'base': '11', 'exponent': '010', 'extra': '1'}]:
            case = sample();case['stimuli'] = [vector]
            with self.assertRaises(ValueError):
                models.validate_case(case)
        for count in (0, 33):
            case = sample();case['stimuli'] *= count
            with self.assertRaises(ValueError):
                models.validate_case(case)

    def test_saved_evidence_retains_inputs_and_detects_reference_drift(self):
        manifest = {'schema': 1, 'generator': models.GENERATOR, 'seed': 1, 'cases': [sample()]}
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            original = base/'original';records, _ = evidence.prepare(manifest, original)
            replay = base/'replay'
            current, info = evidence.prepare(manifest, replay, original/'manifest.json')
            self.assertEqual(records, current)
            self.assertEqual(info['baseline'], 'saved_artifact')
            self.assertFalse(info['cases']['case_0000']['source_changed'])
            self.assertFalse(info['cases']['case_0000']['expected_changed'])
            original_materialize = powers.materialize
            def changed_reference(case):
                lines, expected, clauses = original_materialize(case)
                return lines, [line.replace('v0_full=01011', 'v0_full=00000')
                               for line in expected], clauses
            with patch.object(powers, 'materialize', side_effect=changed_reference):
                _, drift = evidence.prepare(manifest, base/'drift', original/'manifest.json')
            self.assertTrue(drift['cases']['case_0000']['expected_changed'])
            self.assertEqual((base/'drift/cases/case_0000.expected').read_bytes(),
                             (original/'cases/case_0000.expected').read_bytes())
            self.assertIn('v0_full=00000',
                          (base/'drift/current-reference/case_0000.expected').read_text())
            self.assertIn('tools/random_cross_power.py', runner.SOURCES)
            self.assertIn('generators/power_boundaries.py', runner.SOURCES)
            self.assertIn('generators/bitvector_queries.py', runner.SOURCES)
            record = records['case_0000']
            self.assertEqual(hashlib.sha256((original/record['source']).read_bytes()).hexdigest(), record['source_sha256'])


if __name__ == '__main__':
    unittest.main()
