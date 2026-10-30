"""Reject incomplete bindings and falsely successful execution evidence."""

from copy import deepcopy
import tempfile
from pathlib import Path
import unittest
from unittest import mock

import combination_gaps as gaps
import suite_results


class ReviewedBindings(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name).resolve()
        self.name = "tests/ch9/test_gap_fixture.sv"
        self.path = self.root / self.name
        self.path.parent.mkdir(parents=True)
        self.path.write_text("""/*
:name: test_gap_fixture
:type: simulation
:lrm: 1800-2023 9.4.2
:spec_check: ai
:oracle: spec
:expected_stdout: ok
*/
module test_gap_fixture; initial $display("ok"); endmodule
""")
        self.patch_root = mock.patch.object(suite_results, "ROOT", self.root)
        self.patch_root.start()
        self.addCleanup(self.patch_root.stop)
        self.digest = suite_results.input_digest(self.path)
        binding = {"test": self.name, "role": "primary", "basis": "reused",
                   "observations": ["one deterministic event observation"],
                   "lrm": ["9.4.2"], "inputs_sha256": self.digest}
        self.data = {"schema": 1, "scope": "test fixture", "reviewer": "unit fixture",
                     "reviewed_on": "2026-10-30", "items": [
                         {"id": i, "title": i, "spec_review": "reviewed fixture",
                          "limitations": [], "bindings": [deepcopy(binding)]} for i in gaps.IDS]}

    def test_missing_candidate_or_primary_observation_is_rejected(self):
        self.assertEqual(gaps.validate(self.data, self.root), {self.name: self.digest})
        missing = deepcopy(self.data)
        missing["items"].pop()
        with self.assertRaisesRegex(ValueError, "twenty"):
            gaps.validate(missing, self.root)
        no_primary = deepcopy(self.data)
        no_primary["items"][0]["bindings"][0]["role"] = "contrast"
        with self.assertRaisesRegex(ValueError, "no primary"):
            gaps.validate(no_primary, self.root)

    def test_changed_inputs_are_not_silently_reapproved(self):
        self.path.write_text(self.path.read_text().replace('$display("ok")', '$display("wrong")'))
        with self.assertRaisesRegex(ValueError, "stale binding"):
            gaps.validate(self.data, self.root)

    def test_referenced_expectation_changes_invalidate_bindings(self):
        expected = self.path.with_suffix(".expected")
        expected.write_text("ok\n")
        self.path.write_text(self.path.read_text().replace(
            ":expected_stdout: ok", ":expected_stdout: @" + expected.name))
        digest = suite_results.input_digest(self.path)
        for item in self.data["items"]:
            item["bindings"][0]["inputs_sha256"] = digest
        gaps.validate(self.data, self.root)
        expected.write_text("wrong\n")
        with self.assertRaisesRegex(ValueError, "stale binding"):
            gaps.validate(self.data, self.root)

    def test_citation_and_generated_candidate_identity_must_agree(self):
        wrong = deepcopy(self.data)
        wrong["items"][0]["bindings"][0]["lrm"] = ["21.3.2"]
        with self.assertRaisesRegex(ValueError, "citation"):
            gaps.validate(wrong, self.root)
        wrong = deepcopy(self.data)
        wrong["items"][0]["bindings"][0]["basis"] = "new"
        with self.assertRaisesRegex(ValueError, "metadata differs"):
            gaps.validate(wrong, self.root)

    def test_test_paths_cannot_escape_the_suite(self):
        outside = self.root / "outside.sv"
        outside.write_text(self.path.read_text())
        wrong = deepcopy(self.data)
        wrong["items"][0]["bindings"][0]["test"] = "outside.sv"
        with self.assertRaisesRegex(ValueError, "invalid"):
            gaps.validate(wrong, self.root)

    def test_alias_paths_cannot_duplicate_one_test(self):
        alias = self.path.with_name("test_gap_alias.sv")
        alias.symlink_to(self.path)
        for name in ("tests/ch9/./test_gap_fixture.sv",
                     "tests//ch9/test_gap_fixture.sv", alias.relative_to(self.root).as_posix()):
            with self.subTest(name=name):
                wrong = deepcopy(self.data)
                wrong["items"][0]["bindings"][0]["test"] = name
                with self.assertRaisesRegex(ValueError, "invalid"):
                    gaps.validate(wrong, self.root)

    def tagged_binding(self, identifier):
        path = self.path.with_name("test_gap_tagged.sv")
        path.write_text(self.path.read_text().replace(
            ":oracle: spec", ":oracle: spec\n:combination_gap: " + identifier))
        return {"test": path.relative_to(self.root).as_posix(), "role": "primary",
                "basis": "new", "observations": ["tagged new observation"],
                "lrm": ["9.4.2"], "inputs_sha256": suite_results.input_digest(path)}

    def test_every_tagged_test_requires_its_new_primary_binding(self):
        binding = self.tagged_binding("E01")
        with self.assertRaisesRegex(ValueError, "unregistered new observation"):
            gaps.validate(self.data, self.root)
        self.data["items"][0]["bindings"].append(binding)
        self.assertIn(binding["test"], gaps.validate(self.data, self.root))
        binding["basis"] = "reused"
        with self.assertRaisesRegex(ValueError, "unregistered new observation"):
            gaps.validate(self.data, self.root)
        binding["basis"] = "new"
        binding["role"] = "contrast"
        with self.assertRaisesRegex(ValueError, "must be primary"):
            gaps.validate(self.data, self.root)

    def test_unknown_or_wrong_candidate_metadata_is_rejected(self):
        self.tagged_binding("E99")
        with self.assertRaisesRegex(ValueError, "unknown combination_gap"):
            gaps.validate(self.data, self.root)
        binding = self.tagged_binding("E02")
        self.data["items"][0]["bindings"].append(binding)
        with self.assertRaisesRegex(ValueError, "metadata differs"):
            gaps.validate(self.data, self.root)

    def snapshot(self, status="pass", **changes):
        run = {"simulator": "kirimasim", "version": "test build",
               "generated_at": "2026-10-30T00:00:00+00:00", "runner_changed": False,
               "runner_sha256": "current", "tests": {"ch9/test_gap_fixture": {
                   "status": status, "inputs_sha256": self.digest}}}
        run.update(changes)
        with mock.patch.object(gaps, "ROOT", self.root), \
                mock.patch.object(suite_results, "runner_digest", return_value="current"):
            return gaps.snapshot(self.data, run, {self.name: self.digest})

    def test_unsupported_and_known_are_never_success(self):
        self.assertTrue(all(g["complete"] for g in self.snapshot()["groups"].values()))
        for status in ("unsupported", "known", "fail"):
            result = self.snapshot(status)
            self.assertEqual(result["statuses"][status], 1)
            self.assertFalse(any(g["complete"] for g in result["groups"].values()))

    def test_stale_or_missing_results_are_not_success(self):
        for changes, expected in (({"runner_changed": True}, "stale"),
                                  ({"tests": {}}, "not_run")):
            result = self.snapshot(**changes)
            self.assertEqual(result["statuses"][expected], 1)
            self.assertFalse(any(g["complete"] for g in result["groups"].values()))

    def test_invalid_provenance_and_changed_result_inputs_are_stale(self):
        record = {"status": "pass", "inputs_sha256": self.digest}
        changes = [{"runner_sha256": "old"}, {"version": ""},
                   {"generated_at": "2026-10-30T00:00:00"}]
        for altered_record in ({**record, "inputs_sha256": "old"},
                               {**record, "inputs_changed": True},
                               {**record, "status": "unknown"}):
            changes.append({"tests": {"ch9/test_gap_fixture": altered_record}})
        for change in changes:
            with self.subTest(change=change):
                result = self.snapshot(**change)
                self.assertEqual(result["statuses"]["stale"], 1)
                self.assertFalse(any(g["complete"] for g in result["groups"].values()))


if __name__ == "__main__":
    unittest.main()
