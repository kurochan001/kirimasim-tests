"""Prevent diagnostic-location fixes from accepting unrelated frontend errors."""

import json
import tempfile
import unittest
from pathlib import Path

import suite_results
import lint_metadata


class NightlyDiagnosticsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.examples = json.loads((Path(__file__).parent / "fixtures" /
                                   "nightly_diagnostics_20261027.json").read_text())

    def test_reviewed_diagnostics_match(self):
        for row in self.examples:
            with self.subTest(test=row["test"]):
                self.assertTrue(suite_results.judge_illegal(
                    suite_results.ROOT / row["test"], False, row["diagnostic"])[0])

    def test_unrelated_error_at_same_location_is_rejected(self):
        for row in self.examples:
            with self.subTest(test=row["test"]):
                unrelated = row["diagnostic"].split("error:")[0] + "error: unrelated declaration"
                self.assertFalse(suite_results.judge_illegal(
                    suite_results.ROOT / row["test"], False, unrelated)[0])

    def test_unsupported_rule_words_are_not_success_evidence(self):
        for row in self.examples:
            with self.subTest(test=row["test"]):
                # Preserve the intended rule's words and location: an unsupported
                # diagnostic must not become successful conformance evidence.
                unsupported = row["diagnostic"].replace("error:", "error: unsupported:", 1)
                self.assertFalse(suite_results.judge_illegal(
                    suite_results.ROOT / row["test"], False, unsupported)[0])

    def test_recorded_frontend_failures_are_rejected(self):
        for row in self.examples:
            for failure in row.get("rejected_diagnostics", []):
                with self.subTest(test=row["test"], source=failure["source"]):
                    self.assertFalse(suite_results.judge_illegal(
                        suite_results.ROOT / row["test"], False, failure["message"])[0])

    def test_declared_configuration_can_be_selected_as_top(self):
        for name in ("test_illegal_config_design_is_config",
                     "test_illegal_config_instance_inside_other_config"):
            with self.subTest(test=name):
                path = suite_results.ROOT / "tests/ch33" / (name + ".sv")
                self.assertNotIn("top-module", [rule for rule, _ in lint_metadata.check(path)])

    def test_unknown_configuration_top_is_rejected(self):
        path = suite_results.ROOT / "tests/ch33/test_illegal_config_design_is_config.sv"
        with tempfile.TemporaryDirectory() as directory:
            copy = Path(directory) / path.name
            copy.write_text(path.read_text().replace(":top_module: cfgdc",
                                                     ":top_module: cfgdc_missing"))
            self.assertIn("top-module", [rule for rule, _ in lint_metadata.check(copy)])


if __name__ == "__main__":
    unittest.main()
