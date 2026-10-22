"""Guard the boundary between automatically found candidates and approved links."""

import tempfile
import contextlib
import io
import json
import sys
import unittest
from pathlib import Path
from unittest import mock

import requirement_matching as matching


class RequirementMatchingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.test = self.root / "tests/ch6/test_sample.sv"
        self.test.parent.mkdir(parents=True)
        self.test.write_text("/*\n:lrm: 1800-2023 6.16.1\n*/\nmodule m; endmodule\n")
        patcher = mock.patch.object(matching.coverage, "ROOT", self.root)
        patcher.start()
        self.addCleanup(patcher.stop)
        inputs_root = mock.patch.object(matching.suite_results, "ROOT", self.root)
        inputs_root.start()
        self.addCleanup(inputs_root.stop)

    def row(self, rid, clause="6.16.1", **extra):
        return {"id": rid, "clause": clause, "kind": "normal", "checks": [], **extra}

    def review(self, **extra):
        return {"test": "tests/ch6/test_sample.sv",
                "inputs_sha256": matching.suite_results.input_digest(self.test),
                "reviewed_on": "2026-10-22", "reviewer": "unit-test", "scope": "len only",
                "decisions": [{"requirement_ids": ["A"], "disposition": "partial_observation",
                               "explanation": "No uninitialized case",
                               "evidence": [{"file": "tests/ch6/test_sample.sv",
                                             "contains": "module m;"}]}], **extra}

    def test_scoped_decision_never_approves_coverage_or_whole_file(self):
        rows = [self.row("A")]
        data = matching.inventory([self.test], rows)
        matching.attach_dispositions(data, {"schema": 1, "reviews": [self.review()]}, rows)
        self.assertEqual(data["linked_test_files"], 0)
        self.assertEqual(data["tests"][0]["registered_requirement_ids"], [])
        self.assertEqual(data["tests"][0]["unapproved_candidate_ids"], ["A"])
        self.assertEqual(data["scoped_review_test_files"], 1)
        self.assertEqual(data["review_disposition_counts"]["partial_observation"], 1)
        self.assertIn("テスト全体のレビュー完了数ではありません", matching.report(data))

    def test_changed_expected_output_invalidates_scoped_decision(self):
        expected = self.test.with_suffix(".expected")
        expected.write_text("first\n")
        self.test.write_text(self.test.read_text().replace(":lrm:",
                             ":expected_stdout: @test_sample.expected\n:lrm:"))
        review = self.review()
        expected.write_text("changed\n")
        with self.assertRaisesRegex(matching.coverage.InvalidCoverage, "stale test review"):
            matching.attach_dispositions(matching.inventory([self.test], [self.row("A")]),
                                         {"schema": 1, "reviews": [review]}, [self.row("A")])

    def test_review_ledger_rejects_bad_ids_approval_labels_duplicates_and_evidence(self):
        for mistake in ("unknown_id", "approval", "missing_evidence", "outside_input", "duplicate"):
            with self.subTest(mistake=mistake):
                review = self.review()
                decision = review["decisions"][0]
                if mistake == "unknown_id":
                    decision["requirement_ids"] = ["UNKNOWN"]
                elif mistake == "approval":
                    decision["disposition"] = "approved"
                elif mistake == "missing_evidence":
                    decision["evidence"][0]["contains"] = "absent text"
                elif mistake == "outside_input":
                    other = self.root / "unrelated.txt"
                    other.write_text("module m;")
                    decision["evidence"].append({"file": "unrelated.txt", "contains": "module m;"})
                reviews = [review, review] if mistake == "duplicate" else [review]
                with self.assertRaises(matching.coverage.InvalidCoverage):
                    matching.attach_dispositions(matching.inventory([self.test], [self.row("A")]),
                                                 {"schema": 1, "reviews": reviews}, [self.row("A")])

    def test_citation_candidates_never_become_approved_links(self):
        data = matching.inventory([self.test], [self.row("NORMAL"),
                                  self.row("ERROR", kind="error"),
                                  self.row("HELD", interpretation_issue="CONFLICT")])
        test = data["tests"][0]
        self.assertEqual(data["linked_test_files"], 0)
        self.assertEqual(test["registered_requirement_ids"], [])
        self.assertEqual(test["unapproved_candidate_ids"], ["NORMAL"])
        self.assertEqual(test["different_case_kind_ids"], ["ERROR"])
        self.assertEqual(test["interpretation_pending_ids"], ["HELD"])

    def test_broader_citation_is_reported_without_direct_matching(self):
        data = matching.inventory([self.test], [self.row("CHILD", clause="6.16.1.1")])
        self.assertEqual(data["tests"][0]["unapproved_candidate_ids"], [])
        self.assertEqual(data["tests"][0]["broader_citations"], [
            {"clause": "6.16.1", "descendant_requirement_count": 1}])
        self.assertEqual(data["linked_test_files"], 0)

    def test_multiple_reviewed_observations_do_not_count_as_multiple_files(self):
        check = {"test": "tests/ch6/test_sample.sv"}
        data = matching.inventory([self.test], [self.row("A", checks=[check]),
                                  self.row("B", checks=[check]), self.row("PENDING")])
        self.assertEqual(data["linked_test_files"], 1)
        self.assertEqual(data["chapters"][0]["linked_test_files"], 1)
        self.assertEqual(data["tests"][0]["registered_requirement_ids"], ["A", "B"])
        self.assertEqual(data["tests"][0]["unapproved_candidate_ids"], ["PENDING"])
        self.assertIn("全テストの意味上の照合は未完了", matching.report(data))

    def test_changed_stimulus_changes_matching_fingerprint(self):
        before = matching.inventory([self.test], [])
        self.test.write_text(self.test.read_text() + "// changed input\n")
        after = matching.inventory([self.test], [])
        self.assertNotEqual(before["tests"][0]["inputs_sha256"],
                            after["tests"][0]["inputs_sha256"])

    def test_collective_participation_is_distinguished_from_an_individual_witness(self):
        check = {"test": "tests/ch6/test_sample.sv"}
        row = self.row("PART", checks=[check], check_groups=[{"tests": [check["test"]]}])
        test = matching.inventory([self.test], [row])["tests"][0]
        self.assertEqual(test["registered_requirement_ids"], ["PART"])
        self.assertEqual(test["collective_requirement_ids"], ["PART"])

    def test_updates_reject_registry_or_reviewed_input_changes_during_scan(self):
        for changing in ("registry", "test", "review_ledger"):
            with self.subTest(changing=changing):
                registry_path = self.root / "behaviors.json"
                registry_path.write_text(json.dumps({"requirements": []}))
                (self.root / "standard-sections.json").write_text("{}")
                (self.root / matching.DISPOSITIONS).write_text('{"schema": 1, "reviews": []}')
                row = self.row("A", checks=[{"test": "tests/ch6/test_sample.sv",
                               "inputs_sha256": matching.suite_results.input_digest(self.test)}])
                original = matching.inventory
                def raced(tests, rows):
                    if changing == "test":
                        self.test.write_text(self.test.read_text() + "// edited during scan\n")
                    data = original(tests, rows)
                    if changing == "registry":
                        registry_path.write_text("{}")
                    elif changing == "review_ledger":
                        (self.root / matching.DISPOSITIONS).write_text(
                            '{"schema": 1, "reviews": [], "edited": true}')
                    return data
                output = self.root / f"{changing}.json"
                with (mock.patch.object(matching.coverage, "DATA", self.root),
                      mock.patch.object(matching.coverage, "validate", return_value=({}, [row])),
                      mock.patch.object(matching.suite_results, "find_tests", return_value=[self.test]),
                      mock.patch.object(matching, "inventory", side_effect=raced),
                      mock.patch.object(matching, "OUTPUT", output),
                      mock.patch.object(matching, "REPORT", self.root / "report.md"),
                      mock.patch.object(sys, "argv", ["matching", "--update"]),
                      contextlib.redirect_stdout(io.StringIO())):
                    self.assertEqual(matching.main(), 1)
                self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
