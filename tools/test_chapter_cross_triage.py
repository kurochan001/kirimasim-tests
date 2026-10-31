"""Keep chapter triage distinct from citation counts and successful execution."""

from collections import Counter
from copy import deepcopy
import csv
import io
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import chapter_cross_triage as triage
import suite_results


class ChapterTriage(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        patch = mock.patch.object(suite_results, "ROOT", self.root)
        patch.start()
        self.addCleanup(patch.stop)
        self.path = self.root / "tests/ch25/test_witness.sv"
        self.path.parent.mkdir(parents=True)
        self.path.write_text('''/*
:name: test_witness
:type: simulation
:lrm: 1800-2023 25.5.5 14.16
:expected_stdout: @test_witness.expected
*/
module test_witness; initial $display("observed"); endmodule
''')
        self.path.with_suffix(".expected").write_text("observed\n")
        self.data = {"schema": 1, "reviewer": "unit fixture", "reviewed_on": "2026-10-31",
                     "excluded_chapters": {"1": "overview", "2": "references", "34": "scope"},
                     "pairs": [{"chapters": [14, 25], "category": "E", "priority": "P1",
                                "reason": "reviewed fixture", "objective": "output skew",
                                "factors": ["skew (zero/nonzero)", "access (direct/virtual)"],
                                "observation": "before/after drive", "witnesses": [{
                                    "test": "tests/ch25/test_witness.sv",
                                    "inputs_sha256": suite_results.input_digest(self.path)}]}]}

    def validate(self, data=None, modeled=None):
        return triage.validate_registry(data or self.data, modeled or {}, self.root)

    def test_citations_remain_leads_until_observations_are_reviewed(self):
        leads = triage.discover(self.root)
        self.assertEqual(leads[(14, 25)], ["tests/ch25/test_witness.sv"])
        rows = triage.classify({}, {}, self.data["excluded_chapters"], leads)
        row = next(r for r in rows if r["pair"] == (14, 25))
        self.assertEqual(row["category"], "R")
        self.assertEqual(row["priority"], "未評価")
        self.assertEqual(row["witnesses"], [])
        rows = triage.classify({}, self.validate(), self.data["excluded_chapters"], leads)
        row = next(r for r in rows if r["pair"] == (14, 25))
        self.assertEqual(row["category"], "E")
        self.assertEqual(row["models"], 0)
        self.assertNotIn("pass", row)

    def test_all_pairs_have_one_disposition_and_the_matrix_is_symmetric(self):
        rows = triage.classify({(6, 11): 4}, self.validate(), self.data["excluded_chapters"], {})
        self.assertEqual(len(rows), 820)
        self.assertEqual(len({r["pair"] for r in rows}), 820)
        counts = Counter(r["category"] for r in rows)
        self.assertEqual(counts, {"M": 1, "E": 1, "N": 117, "R": 701})
        matrix = triage.status_matrix(rows)
        self.assertEqual(len(matrix), 42)
        self.assertTrue(all(len(row) == 43 for row in matrix))
        for a in range(1, 42):
            self.assertEqual(matrix[a][a + 1], "D")
            for b in range(1, 42):
                self.assertEqual(matrix[a][b + 1], matrix[b][a + 1])
        self.assertEqual(matrix[14][26], "E1")
        self.assertEqual(matrix[6][12], "M")
        self.assertEqual(matrix[1][26], "N")

    def test_expected_output_changes_require_a_fresh_source_review(self):
        self.validate()
        self.path.with_suffix(".expected").write_text("different\n")
        with self.assertRaisesRegex(ValueError, "stale reviewed witness"):
            self.validate()

    def test_foreign_source_changes_also_invalidate_the_review(self):
        self.path.write_text(self.path.read_text().replace(
            ":type: simulation", ":type: simulation\n:dpi_c: @witness.c"))
        source = self.path.parent / "witness.c"
        source.write_text("/* initial C fixture */\n")
        self.data["pairs"][0]["witnesses"][0]["inputs_sha256"] = suite_results.input_digest(self.path)
        self.validate()
        source.write_text("/* changed C fixture */\n")
        with self.assertRaisesRegex(ValueError, "stale reviewed witness"):
            self.validate()

    def test_positive_simulation_and_both_chapter_citations_are_required(self):
        original = self.path.read_text()
        for fragment, replacement in [
                (":type: simulation", ":type: formal"),
                (":type: simulation", ":type: simulation\n:should_fail_because: illegal"),
                ("25.5.5 14.16", "25.5.5")]:
            with self.subTest(replacement=replacement):
                self.path.write_text(original.replace(fragment, replacement))
                with self.assertRaisesRegex(ValueError, "positive simulation citing both"):
                    self.validate()

    def test_cannot_promote_a_witness_without_an_expected_observation(self):
        self.path.write_text(self.path.read_text().replace(
            ":expected_stdout: @test_witness.expected\n", ""))
        with self.assertRaisesRegex(ValueError, "no expected observation"):
            self.validate()

    def test_existing_and_candidate_categories_have_different_evidence_requirements(self):
        for category, witnesses in [("E", []), ("C", self.data["pairs"][0]["witnesses"])]:
            data = deepcopy(self.data)
            data["pairs"][0].update(category=category, witnesses=witnesses)
            with self.assertRaisesRegex(ValueError, "only E entries require"):
                self.validate(data)
        data = deepcopy(self.data)
        data["pairs"][0].update(category="C", witnesses=[])
        rows = triage.classify({}, self.validate(data), data["excluded_chapters"], {})
        self.assertEqual(next(r for r in rows if r["pair"] == (14, 25))["category"], "C")

    def test_new_models_require_retiring_the_old_zero_cell_review(self):
        with self.assertRaisesRegex(ValueError, "zero pair now has a model"):
            self.validate(modeled={(14, 25): 1})

    def test_duplicate_reversed_and_diagonal_entries_are_rejected(self):
        data = deepcopy(self.data)
        data["pairs"] *= 2
        with self.assertRaisesRegex(ValueError, "duplicate triage pair"):
            self.validate(data)
        for pair in [[25, 14], [14, 14], [0, 25]]:
            data = deepcopy(self.data)
            data["pairs"][0]["chapters"] = pair
            with self.assertRaisesRegex(ValueError, "ordered, off-diagonal"):
                self.validate(data)

    def test_exclusion_cannot_hide_reviewed_or_modeled_pairs(self):
        self.data["excluded_chapters"]["14"] = "not a valid exclusion for this fixture"
        with self.assertRaisesRegex(ValueError, "conflicts with exclusion"):
            self.validate()
        with self.assertRaisesRegex(ValueError, "conflicts with a registered model"):
            self.validate(modeled={(14, 25): 1})

    def test_negative_and_formal_citations_are_not_positive_exploration_leads(self):
        original = self.path.read_text()
        for fragment in [":type: formal", ":type: simulation\n:should_fail_because: illegal"]:
            self.path.write_text(original.replace(":type: simulation", fragment))
            self.assertFalse(triage.discover(self.root))
        self.assertEqual(triage.cited_chapters({"lrm": "1800-2023 14.16 25.5.5 H.7.6"}), {14, 25})

    def test_csv_roundtrip_keeps_the_status_codes(self):
        matrix = triage.status_matrix(triage.classify({}, self.validate(), {}, {}))
        encoded = triage.chapters.csv_bytes(matrix)
        decoded = list(csv.reader(io.StringIO(encoded.decode("utf-8-sig"))))
        self.assertEqual(decoded[14][26], "E1")
        self.assertEqual(decoded[1][3], "R")


if __name__ == "__main__":
    unittest.main()
