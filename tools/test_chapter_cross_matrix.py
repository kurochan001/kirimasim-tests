"""Chapter mapping boundaries and conservative single-run status reporting."""

from copy import deepcopy
import csv
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import chapter_cross_matrix as report
import suite_results


class ChapterMatrix(unittest.TestCase):
    def setUp(self):
        self.model = {"id": "example", "factors": {"storage": ["scalar", "array"]},
                      "selected_cases": 2, "selection": [
                          {"test": "tests/gen/ch11/test_a.sv", "values": {"storage": "scalar"},
                           "inputs_sha256": "a"},
                          {"test": "tests/gen/ch11/test_b.sv", "values": {"storage": "array"},
                           "inputs_sha256": "b"}]}
        self.summary = {"models": [self.model], "runs": []}
        self.registry = {"schema": 1, "reviewer": "unit fixture", "reviewed_on": "2026-10-31",
                         "models": [{"id": "example", "primary_chapter": 11, "pairs": [
                             {"chapters": [7, 11], "reason": "array selection",
                              "when": {"storage": ["array"]}}]}]}

    def test_every_model_needs_exactly_one_review(self):
        for entries in ([], self.registry["models"] * 2):
            data = deepcopy(self.registry)
            data["models"] = entries
            with self.assertRaisesRegex(ValueError, "every current model exactly once"):
                report.reviewed_pairs(self.summary, data)
        data = deepcopy(self.registry)
        data["models"][0]["id"] = "unreviewed"
        with self.assertRaisesRegex(ValueError, "every current model exactly once"):
            report.reviewed_pairs(self.summary, data)

    def test_only_explicit_pairs_and_filtered_witnesses_are_counted(self):
        rows = report.reviewed_pairs(self.summary, self.registry)
        self.assertEqual([r["chapters"] for r in rows], [(11, 11), (7, 11)])
        self.assertEqual([c["test"] for c in rows[1]["matches"]],
                         ["tests/gen/ch11/test_b.sv"])
        data = deepcopy(self.registry)
        data["models"][0]["pairs"] = []
        self.assertEqual(len(report.reviewed_pairs(self.summary, data)), 1)

    def test_reversed_duplicate_pairs_are_rejected(self):
        self.registry["models"][0]["pairs"].append({"chapters": [11, 7], "reason": "duplicate"})
        with self.assertRaisesRegex(ValueError, "duplicate chapter pair"):
            report.reviewed_pairs(self.summary, self.registry)

    def test_secondary_diagonals_cannot_inflate_the_model_total(self):
        self.registry["models"][0]["pairs"].append({"chapters": [7, 7], "reason": "secondary"})
        with self.assertRaisesRegex(ValueError, "diagonal is reserved"):
            report.reviewed_pairs(self.summary, self.registry)

    def test_invalid_or_empty_factor_filters_are_rejected(self):
        for condition in ({"typo": ["array"]}, {"storage": ["queue"]}, {"storage": []}):
            self.registry["models"][0]["pairs"][0]["when"] = condition
            with self.assertRaisesRegex(ValueError, "invalid factor filter"):
                report.reviewed_pairs(self.summary, self.registry)
        self.registry["models"][0]["pairs"][0]["when"] = {"storage": ["array"]}
        self.model["selection"].pop()
        with self.assertRaisesRegex(ValueError, "no selected witness"):
            report.reviewed_pairs(self.summary, self.registry)

    def test_matrix_is_symmetric_and_uses_models_not_test_counts(self):
        rows = report.reviewed_pairs(self.summary, self.registry)
        matrix = report.matrix(rows)
        self.assertEqual(len(matrix), 42)
        self.assertTrue(all(len(r) == 43 for r in matrix))
        self.assertEqual(sum(matrix[c][c + 1] for c in range(1, 42)), 1)
        self.assertEqual(matrix[7][12], 1)
        self.assertEqual(matrix[11][8], 1)
        self.assertEqual(matrix[6][12], 0)
        for a in range(1, 42):
            for b in range(1, 42):
                self.assertEqual(matrix[a][b + 1], matrix[b][a + 1])
        passed = report.matrix(rows, set())
        self.assertTrue(all(value == 0 for row in passed[1:] for value in row[2:]))

    def test_csv_preserves_japanese_and_quoted_fields(self):
        rows = [["章名", "説明"], ["タスクと関数", '引用符"、カンマ,改行\nを保持']]
        encoded = report.csv_bytes(rows)
        self.assertTrue(encoded.startswith(b"\xef\xbb\xbf"))
        self.assertEqual(list(csv.reader(io.StringIO(encoded.decode("utf-8-sig")))), rows)

    def add_run(self, root, name, day, statuses, **extra):
        run = {"simulator": "kirimasim", "version": name, "runner_changed": False,
               "generated_at": f"2026-10-{day:02d}T00:00:00+00:00", "tests": {}}
        for case, status in zip(self.model["selection"], statuses):
            if status is not None:
                run["tests"][suite_results.test_id(report.ROOT / case["test"])] = {
                    "status": status, "inputs_sha256": case["inputs_sha256"]}
        run.update(extra)
        (root / name).write_text(json.dumps(run))
        self.summary["runs"].append({"source": name, "simulator": "kirimasim"})

    def test_latest_eligible_run_keeps_failures_and_rejects_newer_partial_runs(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(
                report.interaction_coverage, "run_problem", return_value=""):
            root = Path(directory)
            self.add_run(root, "older.json", 28, ["pass", "pass"])
            self.add_run(root, "complete.json", 29, ["pass", "fail"])
            self.add_run(root, "partial.json", 30, ["pass", None])
            source, _, statuses = report.latest_run(self.summary, root)
            self.assertEqual(source, "complete.json")
            self.assertEqual(set(statuses["example"].values()), {"pass", "fail"})

    def test_partial_runs_cannot_be_combined(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(
                report.interaction_coverage, "run_problem", return_value=""):
            root = Path(directory)
            self.add_run(root, "first.json", 29, ["pass", None])
            self.add_run(root, "second.json", 30, [None, "pass"])
            with self.assertRaisesRegex(ValueError, "no current, stable"):
                report.latest_run(self.summary, root)

    def test_stale_records_and_unstable_runners_cannot_qualify(self):
        for problem in ("fingerprint", "runner"):
            with self.subTest(problem=problem), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.summary["runs"] = []
                self.add_run(root, "stale.json", 30, ["pass", "pass"])
                run = json.loads((root / "stale.json").read_text())
                if problem == "fingerprint":
                    next(iter(run["tests"].values()))["inputs_sha256"] = "old"
                (root / "stale.json").write_text(json.dumps(run))
                with mock.patch.object(report.interaction_coverage, "run_problem",
                                       return_value="runner changed" if problem == "runner" else ""):
                    with self.assertRaisesRegex(ValueError, "no current, stable"):
                        report.latest_run(self.summary, root)

    def test_changed_selected_inputs_are_rejected(self):
        with mock.patch.object(suite_results, "input_digest", side_effect=["a", "changed"]):
            with self.assertRaisesRegex(ValueError, "stale selected input"):
                report.validate_inputs(self.summary, report.ROOT)


if __name__ == "__main__":
    unittest.main()
