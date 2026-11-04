"""Package lookup must preserve method scope, typed results and handle identity."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_class_import as g
import qualify_class_import as q


def snapshots(text):
    return {fields['phase']: fields for line in text.splitlines()
            if (fields := dict(item.split('=', 1) for item in line.split()))}


class ClassMethodPackageLookup(unittest.TestCase):
    def test_only_zero_width_package_rows_are_excluded(self):
        self.assertEqual(prod(len(v) for _, v in g.MODEL.factors), 3456)
        self.assertEqual(len(g.MODEL.rows()), 3264)
        self.assertTrue(all(g.package_width(row) > 0 for row in g.MODEL.rows()))
        self.assertTrue(all(row[0] != '1' or row[3] != 'narrow' for row in g.MODEL.rows()))

    def test_selection_preserves_all_pair_triple_targets_and_anchors(self):
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 34)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 244, 3: 110})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertEqual(len(g.MODEL.anchors), 6)
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(selected, g.MODEL.select())

    def test_all_actual_legal_programs_match_independent_source_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(q.independent(row), g.reference(row))

    def test_interpreter_does_not_call_generator_or_reference_helpers(self):
        row = g.MODEL.anchors[1]
        source, expected = g.source(row), g.reference(row)
        with patch.object(g, 'source', side_effect=AssertionError('generator')), \
             patch.object(g, 'reference', side_effect=AssertionError('reference')), \
             patch.object(g, 'updates', side_effect=AssertionError('operations')), \
             patch.object(g, 'assigned', side_effect=AssertionError('conversion')), \
             patch.object(g, 'package_width', side_effect=AssertionError('dimensions')):
            self.assertEqual(q.interpret(source), expected)

    def test_metadata_and_comments_do_not_supply_executable_declarations(self):
        case = g.make_case(g.MODEL.anchors[0])
        source, _ = common.render(case, g.NAME, g.VERSION, g.CHAPTER, 'spec')
        source += '\n// package bad; class wrong; initial begin\n'
        self.assertEqual(q.interpret(source), case.expected)

    def test_hand_calculated_one_bit_package_and_independent_object_progress(self):
        seen = snapshots(g.reference(g.MODEL.anchors[0]))
        self.assertEqual(seen['init'], {'phase': 'init', 'outer': '1', 'inner': '1',
            'a': '0', 'old': '0', 'b': '0', 'read_a': '1', 'read_old': '1', 'read_b': '1', 'same': '1'})
        self.assertEqual(seen['package']['read_b'], '0')
        self.assertEqual(seen['package']['b'], '0')
        self.assertEqual(seen['guard']['b'], '1')
        self.assertEqual(seen['recover'], {'phase': 'recover', 'outer': '0', 'inner': '1',
            'a': '0', 'old': '0', 'b': '1', 'read_a': '1', 'read_old': '1', 'read_b': '1', 'same': '1'})

    def test_signed_source_extends_before_result_assignment(self):
        row = g.MODEL.anchors[1]
        signed = snapshots(q.independent(row))['init']
        unsigned = snapshots(q.independent((*row[:2], 'u', *row[3:])))['init']
        self.assertEqual(signed['inner'], '1' + '0' * 127)
        self.assertEqual(signed['read_a'], '11' + '0' * 127)
        self.assertEqual(unsigned['read_a'], '01' + '0' * 127)

    def test_wider_package_truncates_and_retains_its_own_width(self):
        seen = snapshots(q.independent(g.MODEL.anchors[2]))['init']
        self.assertEqual(seen['inner'], '1' + '0' * 65)
        self.assertEqual(seen['read_a'], '0' * 65)
        self.assertEqual(len(seen['outer']), 66)

    def test_kept_alias_and_rebound_handle_observe_different_objects(self):
        row = ('33', 'logic', 'u', 'same', 'known', 'enclosing', 'function', 'replace')
        replaced = snapshots(q.independent(row))
        kept = snapshots(q.independent((*row[:-1], 'keep')))
        self.assertEqual(replaced['alias']['same'], '0')
        self.assertEqual(replaced['alias']['a'], '1' * 33)
        self.assertEqual(replaced['alias']['old'], '0' * 32 + '1')
        self.assertEqual(kept['alias']['same'], '1')
        self.assertEqual(kept['alias']['a'], kept['alias']['old'])
        self.assertEqual(replaced['guard']['b'], ('10' * 33)[:33])

    def test_import_spelling_and_task_function_preserve_the_same_result(self):
        row = list(g.MODEL.anchors[1])
        want = g.reference(tuple(row))
        for access in ('wildcard', 'explicit', 'qualified'):
            for routine in ('function', 'task'):
                row[5], row[6] = access, routine
                self.assertEqual(q.independent(tuple(row)), want)

    def test_method_import_does_not_leak_into_module_or_other_method(self):
        seen = snapshots(q.independent(g.MODEL.anchors[2]))
        self.assertEqual(seen['package']['outer'], '0' * 65 + '1')
        self.assertEqual(seen['package']['inner'], 'x' * 66)
        self.assertEqual(seen['package']['read_b'], 'x' * 65)
        self.assertEqual(seen['package']['b'], ('01' * 65)[:65])
        self.assertEqual(seen['outer']['outer'], '0' * 66)
        self.assertEqual(seen['recover']['read_b'], '0' * 64 + '1')

    def test_unknown_source_and_property_convert_to_two_state_zero_then_recover(self):
        row = g.MODEL.anchors[2]
        bit_row = (row[0], 'bit', *row[2:])
        seen = snapshots(q.independent(bit_row))
        self.assertEqual(seen['property']['a'], '0' * 65)
        self.assertEqual(seen['package']['inner'], '0' * 66)
        self.assertEqual(seen['package']['read_a'], '0' * 65)
        self.assertEqual(seen['recover']['read_a'], '0' * 64 + '1')
        # Input X/Z is required even when all observed bit values become zero.
        self.assertTrue(g.make_case(bit_row).fourstate)
        self.assertTrue(g.make_case(row).fourstate)

    def test_eight_actual_source_mutations_change_observed_values(self):
        controls, variants = q.variants()
        self.assertEqual(len(controls), 4)
        self.assertEqual(len(variants), 12)
        for name, (parent, source, kind) in variants.items():
            with self.subTest(name=name):
                if kind == 'control': self.assertEqual(q.interpret(source), controls[parent].expected)
                else: self.assertNotEqual(q.interpret(source), controls[parent].expected)

    def test_literal_parser_rejects_forms_outside_the_emitted_grammar(self):
        self.assertEqual(q.literal("33'h1").binary(), '0' * 32 + '1')
        self.assertEqual(q.literal("{4'bxz01, 2'b10}").binary(), 'xz0110')
        for unsupported in ("129'hx", "16'bx", "4'baaaa", "0'h0"):
            with self.assertRaises(AssertionError): q.literal(unsupported)

    def test_unknown_syntax_extra_process_or_direct_class_import_is_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        for mutant in (source.replace('endmodule', 'initial begin end\nendmodule'),
                       source.replace('class box_t;', 'class box_t; import source_pkg::*;'),
                       source.replace('return data;', 'return data + 1;', 1),
                       source.replace('old = a;', 'old = null;')):
            with self.assertRaises(AssertionError): q.interpret(mutant)


if __name__ == '__main__':
    unittest.main()
