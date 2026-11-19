# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Packed histories checked against declared-label maps and A/B bit planes."""

import copy
import hashlib
from itertools import product
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import random_cross_models as m
import random_cross_packed as packed
import random_cross_evidence as evidence
import run_random_cross as runner


def bounds_case(direction='descending', select='plus', target='logic'):
    return {'id': 'case_0000', 'profile': 'packed_bounds_sequence',
            'parameters': {'width': 4, 'span': 3, 'low': 5, 'direction': direction,
                           'select': select, 'target_state': target},
            'stimuli': {'initial': '1xz0', 'operations': [
                {'kind': 'read', 'index': f'{4:032b}'},
                {'kind': 'write', 'index': f'{4:032b}', 'data': '101'},
                {'kind': 'write', 'index': 'x' + '0'*31, 'data': '000'}]}}


def field_case(state='logic', aggregate='signed'):
    return {'id': 'case_0000', 'profile': 'packed_field_sequence',
            'parameters': {'widths': [1, 7, 1], 'signs': ['signed', 'unsigned', 'signed'],
                           'state': state, 'aggregate_sign': aggregate},
            'stimuli': {'initial': 'z10101011', 'operations': [
                {'kind': 'copy', 'source': 0, 'target': 1},
                {'kind': 'field', 'field': 2, 'data': 'x'},
                {'kind': 'shift', 'operator': '>>>', 'amount': 1},
                {'kind': 'whole', 'data': '100000001'},
                {'kind': 'shift', 'operator': '<<', 'amount': 9}]}}


def plane_oracle(case):
    """A separate numeric representation; no string-model helpers are called."""
    p = case['parameters']
    widths = p['widths']
    width = sum(widths)
    mask = (1 << width) - 1
    offsets = [sum(widths[i+1:]) for i in range(3)]

    def encode(text):
        a = b = 0
        for char in text:
            a = (a << 1) | int(char in '1x')
            b = (b << 1) | int(char in 'xz')
        return a, b

    def text(a, b, n):
        return ''.join({(0, 0): '0', (1, 0): '1', (1, 1): 'x', (0, 1): 'z'}[
            ((a >> i) & 1, (b >> i) & 1)] for i in range(n-1, -1, -1))

    def store(a, b):
        return (a & ~b, 0) if p['state'] == 'bit' else (a, b)

    a, b = store(*encode(case['stimuli']['initial']))
    result = []

    def observe(label):
        fields = []
        extended = []
        for i, n in enumerate(widths):
            keep = (1 << n) - 1
            aa, bb = (a >> offsets[i]) & keep, (b >> offsets[i]) & keep
            fields.append(text(aa, bb, n))
            if p['signs'][i] == 'signed':
                if aa & (1 << (n-1)): aa |= 7 << n
                if bb & (1 << (n-1)): bb |= 7 << n
            extended.append(text(aa, bb, n+3))
        result.append(label + ' whole=' + text(a, b, width) + ' ' +
                      ' '.join(f'f{i}={v}' for i, v in enumerate(fields)) + ' ' +
                      ' '.join(f'e{i}={v}' for i, v in enumerate(extended)))

    observe('initial')
    for step, op in enumerate(case['stimuli']['operations']):
        if op['kind'] == 'whole':
            a, b = store(*encode(op['data']))
        elif op['kind'] in ('field', 'copy'):
            target = op.get('field', op.get('target'))
            n = widths[target]
            if op['kind'] == 'field':
                aa, bb = encode(op['data'])
            else:
                source = op['source']
                sn = widths[source]
                aa, bb = (a >> offsets[source]) & ((1 << sn)-1), (b >> offsets[source]) & ((1 << sn)-1)
                if p['signs'][source] == 'signed':
                    if aa & (1 << (sn-1)): aa -= 1 << sn
                    if bb & (1 << (sn-1)): bb -= 1 << sn
            aa, bb = store(aa & ((1 << n)-1), bb & ((1 << n)-1))
            keep = ((1 << n)-1) << offsets[target]
            a = (a & ~keep) | (aa << offsets[target])
            b = (b & ~keep) | (bb << offsets[target])
        else:
            k = op['amount']
            if op['operator'] == '<<':
                a, b = (a << k) & mask, (b << k) & mask
            else:
                if op['operator'] == '>>>' and p['aggregate_sign'] == 'signed':
                    if a & (1 << (width-1)): a -= 1 << width
                    if b & (1 << (width-1)): b -= 1 << width
                a, b = (a >> k) & mask, (b >> k) & mask
        observe(f'step={step} kind={op["kind"]}')
    return '\n'.join(result) + '\n'


class PackedRandomTests(unittest.TestCase):
    def test_three_previous_default_manifests_and_materializations_are_unchanged(self):
        goldens = {
            1: ('c401c8e1be538d910dccd677ec2575170fcbc613cd68c817365c863ceadeeef8', '460b23c9bdd1141a81af78ac64a532e5def3723841ad0dea20ef22f4b405d245'),
            731: ('b88d50277d3efce9d290060543b338553965afc35d6248c8beb4383a0bfad3b9', 'e86fad27b08871c47c7a530f4b2d624c9d1572e7ece63ed8f4c174f0ffb77090'),
            20261117: ('e3924ec1adb01adbf64aca55dc40716f34823382dd9cb1c342b0eb79dfe3eb1c', '03b79d24f4b2afa2856d48fa7e0b1be3046bba07a41ee2bcbf59b2c55d4eb6a0')}
        self.assertEqual(len(m.PROFILES), 13)
        self.assertEqual(len(m.SUPPORTED_PROFILES), 22)
        for seed, (manifest, corpus) in goldens.items():
            data = m.generate(seed, 96, 8)
            self.assertEqual(hashlib.sha256(m.canonical(data).encode()).hexdigest(), manifest)
            self.assertEqual(hashlib.sha256(''.join(s+e for s, e in map(m.materialize, data['cases'])).encode()).hexdigest(), corpus)

    def test_opt_in_generation_is_balanced_deterministic_and_replay_draws_nothing(self):
        data = m.generate(731, 96, 8, m.EXTRA_PROFILES)
        self.assertEqual(data, m.generate(731, 96, 8, m.EXTRA_PROFILES))
        self.assertEqual([sum(c['profile'] == p for c in data['cases']) for p in m.EXTRA_PROFILES], [48, 48])
        with patch.object(m.random, 'Random', side_effect=AssertionError('replay drew randomness')):
            m.validate(data)
            for case in data['cases']:
                self.assertEqual(m.materialize(case), m.materialize(copy.deepcopy(case)))

    def test_partial_negative_and_unknown_addresses_have_hand_derived_outputs(self):
        source, expected = m.materialize(bounds_case())
        self.assertIn('logic [8:5] value;', source)
        self.assertIn('value[index +: 3]', source)
        self.assertIn('whole=1xz0 slice=z0x bit=x', expected)
        self.assertIn('whole=1x10 slice=10x bit=x', expected)
        self.assertTrue(expected.endswith('whole=1x10 slice=xxx bit=x\n'))
        _, expected = m.materialize(bounds_case('ascending'))
        self.assertIn('whole=1xz0 slice=x1x bit=x', expected)
        self.assertIn('whole=01z0 slice=x01 bit=x', expected)
        _, expected = m.materialize(bounds_case(target='bit'))
        self.assertIn('whole=1x10 slice=100 bit=x', expected)
        self.assertTrue(expected.endswith('whole=1x10 slice=000 bit=x\n'))

    def test_small_exhaustive_bounds_writes_match_a_declared_label_dictionary(self):
        for raw in map(''.join, product('01xz', repeat=3)):
            for ascending, plus, target in product((False, True), (False, True), ('bit', 'logic')):
                left, right = (-1, 1) if ascending else (1, -1)
                declared = list(range(left, right + (1 if ascending else -1), 1 if ascending else -1))
                for base in range(-3, 4):
                    chosen = ([base+1, base] if plus else [base, base-1]) if not ascending else (
                        [base, base+1] if plus else [base-1, base])
                    for data in ('00', '11', 'xz', 'zx'):
                        labels = dict(zip(declared, raw))
                        for name, bit in zip(chosen, data):
                            if name in labels: labels[name] = bit
                        whole = ''.join(labels[i] for i in declared)
                        part = ''.join(labels.get(i, 'x') for i in chosen)
                        if target == 'bit': part = ''.join('0' if c in 'xz' else c for c in part)
                        case = bounds_case('ascending' if ascending else 'descending', 'plus' if plus else 'minus', target)
                        case['parameters'].update(width=3, span=2, low=-1)
                        case['stimuli'] = {'initial': raw, 'operations': [{'kind': 'write', 'index': f'{base & 0xffffffff:032b}', 'data': data}]}
                        result = m.materialize(case)[1].splitlines()[-1]
                        self.assertTrue(result.endswith(f'whole={whole} slice={part} bit={labels.get(base, "x")}'), case)

    def test_every_word_boundary_unknown_index_and_clipped_write(self):
        for width in packed.WIDTHS:
            case = bounds_case()
            case['parameters'].update(width=width, low=0, span=min(width, 65))
            case['stimuli'] = {'initial': '1'*width, 'operations': [
                {'kind': 'write', 'index': '1'*32, 'data': '0'*min(width, 65)},
                {'kind': 'write', 'index': '0'*31+'z', 'data': '0'*min(width, 65)}]}
            _, expected = m.materialize(case)
            keep = width - min(width, 65) + 1
            self.assertIn('whole=' + '1'*keep + '0'*(width-keep), expected)
            self.assertTrue(m.requires_fourstate(case))

    def test_known_out_of_range_indices_require_fourstate_observation(self):
        case = bounds_case(target='bit')
        case['stimuli'] = {'initial': '1010', 'operations': [{'kind': 'read', 'index': f'{4:032b}'}]}
        self.assertTrue(m.requires_fourstate(case))
        case['stimuli']['operations'][0]['index'] = f'{5:032b}'
        self.assertFalse(m.requires_fourstate(case))
        case['stimuli']['operations'][0]['index'] = f'{7:032b}'
        self.assertTrue(m.requires_fourstate(case))

    def test_struct_field_order_and_sign_extension_have_hand_derived_outputs(self):
        source, expected = m.materialize(field_case())
        self.assertIn('typedef struct packed signed', source)
        self.assertIn('value.f1 = value.f0;', source)
        self.assertIn('initial whole=z10101011 f0=z f1=1010101 f2=1 e0=zzzz e1=0001010101 e2=1111', expected)
        self.assertIn('step=0 kind=copy whole=zzzzzzzz1', expected)
        self.assertIn('step=2 kind=shift whole=zzzzzzzzz', expected)
        self.assertTrue(expected.endswith('whole=000000000 f0=0 f1=0000000 f2=0 e0=0000 e1=0000000000 e2=0000\n'))

    def test_struct_histories_match_separate_integer_ab_plane_model(self):
        for seed in (1, 731, 20261117):
            for case in m.generate(seed, 96, 16, (m.EXTRA_PROFILES[1],))['cases']:
                self.assertEqual(m.materialize(case)[1], plane_oracle(case), case)

    def test_all_layouts_storage_signs_and_shift_boundary_cases_match_planes(self):
        for widths, state, sign in product(packed.LAYOUTS, ('bit', 'logic'), ('signed', 'unsigned')):
            case = field_case(state, sign)
            case['parameters']['widths'] = list(widths)
            w = sum(widths)
            case['stimuli'] = {'initial': 'z' + ('1x0z'*w)[:w-1], 'operations': [
                {'kind': 'shift', 'operator': op, 'amount': amount}
                for op, amount in product(('<<', '>>', '>>>'), (0, 1, 63, 64, 65, w-1, w, w+1))]}
            self.assertEqual(m.materialize(case)[1], plane_oracle(case))

    def test_invalid_types_ranges_injection_and_oversized_histories_are_rejected(self):
        bad = []
        for key, value in [('width', True), ('span', 0), ('low', False), ('direction', 'bad; $finish'), ('target_state', []), ('extra', 1)]:
            c = bounds_case();c['parameters'][key] = value;bad.append(c)
        c = bounds_case();c['stimuli']['operations'][0]['index'] = '0; $finish;';bad.append(c)
        c = bounds_case();c['stimuli']['operations'] *= 11;bad.append(c)
        for key, value in [('widths', [True, 7, 1]), ('widths', [1, 8, 1]), ('signs', ['signed']), ('aggregate_sign', 'bad')]:
            c = field_case();c['parameters'][key] = value;bad.append(c)
        c = field_case();c['stimuli']['operations'][0]['target'] = 3;bad.append(c)
        c = field_case();c['stimuli']['operations'][0]['source'] = 1;bad.append(c)
        for case in bad:
            with self.subTest(case=case), self.assertRaises(ValueError): m.materialize(case)

    def test_cli_exposes_extra_models_without_changing_default_allocation(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch('sys.argv', ['run_random_cross.py', '--generate-only', '--seed', '731', '--cases', '2',
                                   '--models', *m.EXTRA_PROFILES, '--output', directory]):
                self.assertEqual(runner.main(), 0)
            data = json.loads((Path(directory)/'manifest.json').read_text())
            self.assertEqual({c['profile'] for c in data['cases']}, set(m.EXTRA_PROFILES))
            self.assertIn('tools/random_cross_packed.py', runner.source_hashes())

    def test_saved_replay_verifies_actual_sv_and_expected_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            manifest = m.generate(731, 4, 8, m.EXTRA_PROFILES)
            evidence.prepare(manifest, path)
            original = {p.name: p.read_bytes() for p in (path/'cases').iterdir()}
            for case in manifest['cases']:
                source, expected = m.materialize(case)
                self.assertEqual(original[case['id']+'.sv'], source.encode())
                self.assertEqual(original[case['id']+'.expected'], expected.encode())


if __name__ == '__main__':
    unittest.main()
