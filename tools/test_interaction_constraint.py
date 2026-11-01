"""Concrete solution, inheritance and failure-retention boundary checks."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_constraint as constraints


class ConstraintSemantics(unittest.TestCase):
    def test_added_constraint_keeps_the_base_value_and_previous_success(self):
        row = ('derived', 'add', 'concrete', 'inline', 'sat_fail_sat', '4')
        self.assertEqual(constraints.reference(row),
                         'phase=0 fail=0 ok=1 a=5 b=8\nguard=0 fail=0 ok=1 a=5 b=8\n'
                         'phase=1 fail=1 ok=0 a=5 b=8\nguard=1 fail=0 ok=1 a=5 b=8\n'
                         'phase=2 fail=0 ok=1 a=5 b=8\nguard=2 fail=0 ok=1 a=5 b=8\n')

    def test_replacement_through_base_handle_uses_leaf_and_preserves_initial_failure(self):
        row = ('base', 'replace', 'pure', 'extern', 'fail_sat_fail', '4')
        self.assertEqual(constraints.reference(row),
                         'phase=0 fail=1 ok=0 a=12 b=13\nguard=0 fail=0 ok=1 a=7 b=10\n'
                         'phase=1 fail=0 ok=1 a=7 b=10\nguard=1 fail=0 ok=1 a=7 b=10\n'
                         'phase=2 fail=1 ok=0 a=7 b=10\nguard=2 fail=0 ok=1 a=7 b=10\n')

    def test_wide_values_do_not_overflow_a_signed_32_bit_reference(self):
        row = ('base', 'replace', 'pure', 'extern', 'fail_sat_fail', '33')
        self.assertEqual(constraints.solved_values(row), (2147483651, 2147483654))
        text = constraints.reference(row)
        self.assertIn('phase=0 fail=1 ok=0 a=8589934588 b=8589934589\n', text)
        self.assertIn('phase=1 fail=0 ok=1 a=2147483651 b=2147483654\n', text)

    def test_handle_origin_and_definition_do_not_change_a_unique_solution(self):
        reference = None
        for handle in ('base', 'derived'):
            for origin in ('concrete', 'pure'):
                for definition in ('inline', 'extern'):
                    row = (handle, 'replace', origin, definition, 'sat_fail_sat', '8')
                    value = constraints.reference(row)
                    if reference is None:
                        reference = value
                    self.assertEqual(value, reference)


if __name__ == '__main__':
    unittest.main()
