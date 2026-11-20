import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import review_sample as rs
import suite_results


def write_test(root, name, oracle="spec", kind="simulation", expected="x=1"):
    path = root / "tests" / "ch5" / f"{name}.sv"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"/*\n:name: {name}\n:description: d\n:type: {kind}\n:lrm: 1800-2023 5.7\n"
                    f":oracle: {oracle}\n:expected_stdout: {expected}\n*/\nmodule {name}; endmodule\n",
                    encoding="utf-8")
    return path


def results(root, statuses):
    """latest/<simulator>.json for statuses {sim: {test: status}}, with the
    current input digest of each test."""
    directory = root / "latest"
    directory.mkdir()
    for sim, tests in statuses.items():
        records = {}
        for test, status in tests.items():
            path = root / "tests" / f"{test}.sv"
            records[test] = {"status": status, "inputs_sha256": suite_results.input_digest(path)}
        (directory / f"{sim}.json").write_text(json.dumps(
            {"version": "v", "generated_at": "t", "suite_commit": "c", "tests": records}),
            encoding="utf-8")
    return directory


class TempRoot(unittest.TestCase):
    """A temporary repository root, which input digests are relative to."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name).resolve()
        patcher = mock.patch.object(suite_results, "ROOT", self.root)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.addCleanup(self.tmp.cleanup)


class Strata(TempRoot):

    def test_strata_follow_the_oracle_and_the_passing_simulators(self):
        for name in ("test_none", "test_ghost", "test_kg", "test_ref", "test_k", "test_fixed"):
            write_test(self.root, name, oracle="spec iverilog@13.0" if name == "test_fixed" else "spec")
        write_test(self.root, "test_formal", kind="formal")
        directory = results(self.root, {
            "icarus": {"ch5/test_none": "known", "ch5/test_ref": "pass", "ch5/test_fixed": "pass"},
            "kirimasim": {"ch5/test_none": "fail", "ch5/test_kg": "pass", "ch5/test_k": "pass"},
            "ghost": {"ch5/test_none": "fail", "ch5/test_ghost": "pass", "ch5/test_kg": "pass",
                      "ch5/test_ref": "pass", "ch5/test_k": "fail", "ch5/test_formal": "pass"}})
        found = rs.classify(self.root, rs.load_runs(directory))
        self.assertEqual(found["strata"], {"pass_nowhere": ["ch5/test_none"],
                                           "ghost_only": ["ch5/test_ghost"],
                                           "kirimasim_ghost": ["ch5/test_kg"],
                                           "reference_pass": ["ch5/test_ref"]})
        self.assertEqual(found["left_out"], {"formal": 1, "fixed_release_oracle": 1,
                                             "no_current_result": 0, "other": 1})

    def test_a_result_for_an_older_input_is_not_used(self):
        path = write_test(self.root, "test_changed")
        directory = results(self.root, {"ghost": {"ch5/test_changed": "pass"}})
        path.write_text(path.read_text(encoding="utf-8") + "// edited\n", encoding="utf-8")
        found = rs.classify(self.root, rs.load_runs(directory))
        self.assertEqual(found["left_out"]["no_current_result"], 1)
        self.assertEqual(found["strata"]["ghost_only"], [])

    def test_chapters_restrict_the_population(self):
        write_test(self.root, "test_a")
        directory = results(self.root, {"ghost": {"ch5/test_a": "pass"}})
        runs = rs.load_runs(directory)
        self.assertEqual(rs.classify(self.root, runs, {"6"})["strata"]["ghost_only"], [])
        self.assertEqual(rs.classify(self.root, runs, {"5"})["strata"]["ghost_only"], ["ch5/test_a"])


class Drawing(unittest.TestCase):
    strata = {"ghost_only": [f"ch1/test_{i:03d}" for i in range(200)], "pass_nowhere": ["ch1/x"]}

    def test_the_same_seed_gives_the_same_sample(self):
        counts = {"ghost_only": 10, "pass_nowhere": 5}
        first = rs.draw(self.strata, counts, 42)
        self.assertEqual(first, rs.draw(dict(reversed(list(self.strata.items()))), counts, 42))
        self.assertEqual(len(first["ghost_only"]), 10)
        self.assertEqual(first["pass_nowhere"], ["ch1/x"])
        self.assertNotEqual(first["ghost_only"], rs.draw(self.strata, counts, 43)["ghost_only"])

    def test_a_stratum_does_not_depend_on_the_draws_of_another(self):
        alone = rs.draw(self.strata, {"ghost_only": 10}, 42)["ghost_only"]
        together = rs.draw(self.strata, {"ghost_only": 10, "pass_nowhere": 1}, 42)["ghost_only"]
        self.assertEqual(alone, together)


class Bounds(unittest.TestCase):
    def test_no_error_gives_the_rule_of_three(self):
        self.assertAlmostEqual(rs.upper_bound(0, 60), 0.05)
        self.assertAlmostEqual(rs.upper_bound(0, 300), 0.01)
        self.assertIsNone(rs.upper_bound(0, 0))

    def test_errors_give_the_clopper_pearson_bound(self):
        bound = rs.upper_bound(1, 60)
        self.assertAlmostEqual(rs.binomial_cdf(1, 60, bound), 0.05, places=6)
        self.assertAlmostEqual(bound, 0.0764, places=3)
        self.assertEqual(rs.upper_bound(5, 5), 1.0)


class Ledger(TempRoot):
    def setUp(self):
        super().setUp()
        self.path = write_test(self.root, "test_r")
        self.ledger = self.root / "human-review.json"
        self.sheet = self.root / "sheet.json"

    def fill(self, **fields):
        item = {"test": "ch5/test_r", "path": "tests/ch5/test_r.sv", "stratum": "ghost_only",
                "inputs_sha256": suite_results.input_digest(self.path), "verdict": "correct",
                "basis_clauses": "5.7.1, 5.7.2", "reviewer": "A. Person", "date": "2026-11-21",
                "notes": ""}
        item.update(fields)
        self.sheet.write_text(json.dumps({"seed": 1, "generated_at": "t", "tests": [item]}),
                              encoding="utf-8")

    def test_a_filled_entry_is_recorded_and_the_test_is_not_changed(self):
        before = self.path.read_bytes()
        self.fill()
        self.assertEqual(rs.record(self.sheet, self.ledger, self.root), 0)
        reviews = json.loads(self.ledger.read_text(encoding="utf-8"))["reviews"]
        self.assertEqual([(r["test"], r["verdict"], r["basis_clauses"]) for r in reviews],
                         [("ch5/test_r", "correct", ["5.7.1", "5.7.2"])])
        self.assertEqual(self.path.read_bytes(), before)
        rows = rs.summarize(json.loads(self.ledger.read_text(encoding="utf-8")), self.root)
        self.assertEqual((rows["ghost_only"]["n"], rows["ghost_only"]["k"]), (1, 0))

    def test_bad_entries_are_refused(self):
        for fields in ({"verdict": "fine"}, {"reviewer": ""}, {"reviewer": "Model (AI)"},
                       {"date": "21/11/2026"}, {"basis_clauses": ""}, {"inputs_sha256": "0" * 64}):
            with self.subTest(fields=fields):
                self.fill(**fields)
                self.assertEqual(rs.record(self.sheet, self.ledger, self.root), 1)
                self.assertFalse(self.ledger.exists())

    def test_a_review_goes_stale_when_the_test_changes(self):
        self.fill(verdict="expectation_wrong")
        rs.record(self.sheet, self.ledger, self.root)
        ledger = json.loads(self.ledger.read_text(encoding="utf-8"))
        self.assertEqual(rs.summarize(ledger, self.root)["ghost_only"]["k"], 1)
        self.path.write_text(self.path.read_text(encoding="utf-8") + "// fixed\n", encoding="utf-8")
        row = rs.summarize(ledger, self.root)["ghost_only"]
        self.assertEqual((row["n"], row["stale"], row["upper_bound"]), (0, 1, None))


class Sheet(TempRoot):
    def test_an_entry_carries_the_expectation_and_empty_fields(self):
        root = self.root
        write_test(root, "test_e", expected="a=1")
        item = rs.entry(root, "ch5/test_e", "ghost_only", {"ghost": "pass"}, "d" * 64)
        self.assertEqual(item["expected_stdout"], "a=1\n")
        self.assertEqual(item["clauses"], ["5.7"])
        self.assertEqual([item[k] for k in ("verdict", "basis_clauses", "reviewer", "date")],
                         ["", "", "", ""])
        text = rs.render({"seed": 1, "results_read": {}, "population": dict.fromkeys(rs.STRATA, 0),
                          "drawn": dict.fromkeys(rs.STRATA, 0), "tests": [item]}, "ja", rs.SOURCE_URL)
        self.assertIn("a=1", text)
        self.assertIn("判定", text)


if __name__ == "__main__":
    unittest.main()
