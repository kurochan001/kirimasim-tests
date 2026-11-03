"""Qualification uses emitted programs, not the random model's expected-value helpers."""

from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import qualify_random_arrays as q
import random_cross_models as m
from test_random_cross_array_profiles import copy_case, reduction_case


class IndependentRandomArrayTests(unittest.TestCase):
    def test_generated_bounded_programs_match_at_minimum_and_maximum_vector_counts(self):
        for seed in (1,731,20261103):
            for steps in (1,32):
                for profile in ('array_reduction_context','unpacked_array_copy_sequence'):
                    for case in m.generate(seed,12,steps,(profile,))['cases']:
                        source,expected=m.materialize(case)
                        self.assertEqual(q.interpret(source),expected)

    def test_no_generator_parameter_or_reference_helper_is_called_by_interpretation(self):
        programs=[m.materialize(copy_case()),m.materialize(reduction_case())]
        with (patch.object(m,'materialize',side_effect=AssertionError('generator')),
             patch.object(m,'array_copy_indices',side_effect=AssertionError('indices')),
             patch.object(m,'reduce_array_elements',side_effect=AssertionError('reference')),
             patch.object(m.array_methods,'return_type',side_effect=AssertionError('type')),
             patch.object(m.array_methods,'reduce_values',side_effect=AssertionError('reduction'))):
            for source,expected in programs:self.assertEqual(q.interpret(source),expected)

    def test_actual_declaration_order_and_copy_statement_affect_interpretation(self):
        source,expected=m.materialize(copy_case())
        self.assertEqual(q.interpret(source),expected)
        mutated=source.replace('target[6:7] = source[4:3];','target[6:7] = source[3:2];',1)
        self.assertNotEqual(q.interpret(mutated),expected)
        self.assertNotEqual(q.interpret(source.replace('target[6:7] = source[4:3];','target = source;',1)),expected)

    def test_actual_return_type_and_with_expression_are_not_inferred_from_metadata(self):
        case=reduction_case(width=1,transform='widen');source,expected=m.materialize(case)
        self.assertNotEqual(q.interpret(source.replace("2'(item)","1'(item)",1)),expected)
        case=reduction_case(width=32,transform='int');case['stimuli'][0]['values'][0]='z'*32
        source,expected=m.materialize(case)
        self.assertNotEqual(q.interpret(source.replace("int'(item)","integer'(item)",1)),expected)

    def test_singleton_unknown_and_signed_widening_are_preserved(self):
        for method in ('sum','product','and','or','xor'):
            case=reduction_case(method,width=1,sign='signed',count=1);case['stimuli']=[{'values':['z']}]
            source,expected=m.materialize(case);self.assertEqual(q.interpret(source),expected)
            self.assertIn('value=z direct=zz saved=zz',expected)

    def test_unrecognized_processes_expressions_and_oversized_arrays_are_rejected(self):
        source,_=m.materialize(copy_case())
        invalid=[source.replace('initial begin','always begin',1),source.replace('source[4:2]','source[99999:2]',1),
                 source.replace('target[6:7] = source[4:3];','target[6:7] <= source[4:3];',1),
                 source.replace('target[6:7] = source[4:3];','target[6:7] = source[4:3] + 1;',1)]
        for value in invalid:
            with self.assertRaises((AssertionError,ValueError)):q.interpret(value)

    def test_comments_and_metadata_are_not_declarations(self):
        source,expected=m.materialize(copy_case())
        self.assertEqual(q.interpret('// module misleading; initial begin\n'+source),expected)
        self.assertEqual(q.interpret(source.replace('/*','/* typedef bit [0:0] word_t;\n',1)),expected)
