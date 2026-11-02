"""Generate-scope binding, cancellation intervals and independent controls."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_gendisable as generator
import qualify_gendisable as qualification


class GenerateDisableSemantics(unittest.TestCase):
    def test_all_legal_rows_match_lexical_event_scoreboard(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row), qualification.independent(row))

    def test_local_override_does_not_cancel_the_other_instance(self):
        text = generator.reference(('case', 'override', 'present', 'default', 'at_end', 'before'))
        phase = text.split('phase=2 ')[1].split('phase=3 ')[0]
        self.assertIn('lane0 pass=2 fail=2', phase)
        self.assertIn('lane1 pass=3 fail=3', phase)
        self.assertIn('root pass=2 fail=2', phase)

    def test_interclock_pulse_cancels_old_attempt_without_blocking_new_vacuity(self):
        row = ('if', 'inherit', 'present', 'default', 'between', 'after')
        text = generator.reference(row).split('phase=1 ')[1].split('phase=2 ')[0]
        self.assertIn('root pass=2 fail=1', text)
        self.assertIn('lane0 pass=2 fail=1', text)
        self.assertIn('guard_pass=2 guard_fail=2', text)

    def test_explicit_zero_preserves_failures_despite_either_default(self):
        for default in ('inherit', 'override'):
            text = generator.reference(('loop', default, 'present', 'zero', 'at_end', 'after'))
            self.assertIn('lane0 pass=8 fail=6 guard_pass=8 guard_fail=6', text)
            self.assertIn('lane1 pass=8 fail=6 guard_pass=8 guard_fail=6', text)

    def test_generate_shape_shadowing_and_declaration_order_preserve_binding(self):
        outputs = {generator.reference((form, 'override', shadow, 'default', 'at_start', order))
                   for form in ('if', 'case', 'loop') for shadow in ('absent', 'present')
                   for order in ('before', 'after')}
        self.assertEqual(len(outputs), 1)

    def test_explicit_condition_ignores_parent_and_local_defaults(self):
        text = generator.reference(('case', 'override', 'present', 'explicit', 'at_end', 'before'))
        phase = text.split('phase=4 ')[1].split('phase=5 ')[0]
        self.assertIn('lane0 pass=4 fail=4', phase)
        self.assertIn('lane1 pass=5 fail=5', phase)


if __name__ == '__main__':
    unittest.main()
