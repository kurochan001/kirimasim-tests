"""Ensure license denial variants change only the intended directive."""

from pathlib import Path
import unittest

import run_protect_licenses as checker
import suite_results


class LicenseVariantTests(unittest.TestCase):
    def fixture(self, case):
        return (suite_results.ROOT / Path("tests", case + ".sv")).read_bytes()

    def test_feature_denial_preserves_other_phase_and_match(self):
        source = self.fixture(checker.RELEASE)
        denied = checker.denied_input(source, "decrypt")
        original = checker.license_pragma(source, "decrypt")[1]
        changed = checker.license_pragma(denied, "decrypt")[1]
        self.assertEqual(changed, {**original, "feature": "deny"})
        self.assertEqual(checker.license_pragma(source, "runtime"),
                         checker.license_pragma(denied, "runtime"))

    def test_nonmatching_return_for_same_feature_changes_only_match(self):
        source = self.fixture(checker.NO_RELEASE)
        denied = checker.denied_input(source, "runtime")
        original = checker.license_pragma(source, "runtime")[1]
        changed = checker.license_pragma(denied, "runtime")[1]
        self.assertEqual(changed, {**original, "match": "71"})
        self.assertEqual(checker.license_pragma(source, "decrypt"),
                         checker.license_pragma(denied, "decrypt"))


if __name__ == "__main__":
    unittest.main()
