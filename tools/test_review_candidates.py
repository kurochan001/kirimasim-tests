import json
import tempfile
import unittest
from pathlib import Path

import review_candidates as rc


def entry(test, spec_only=True, formal=False, clauses=()):
    return {"id": test, "spec_only": spec_only, "formal": formal, "clauses": list(clauses)}


def run(**tests):
    return {"version": "v", "time": "2026-11-08T00:00:00Z", "suite_commit": "abc", "tests": tests}


class ReviewCandidatesTests(unittest.TestCase):
    def test_both_verilator_tokens_of_the_interim_pin_are_releases(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            (root / "tests" / "ch1").mkdir(parents=True)
            for name, oracle in (("old", "spec verilator@5.052"), ("new", "spec verilator@5.054"),
                                 ("icarus", "spec iverilog@13.0"), ("spec", "spec")):
                (root / "tests" / "ch1" / f"test_{name}.sv").write_text(
                    f"/*\n:name: test_{name}\n:lrm: 1800-2023 1.1\n:oracle: {oracle}\n*/\nmodule m; endmodule\n",
                    encoding="utf-8")
            spec_only = {e["id"]: e["spec_only"] for e in rc.tests_of(root)}
            self.assertEqual(spec_only, {"ch1/test_old": False, "ch1/test_new": False,
                                         "ch1/test_icarus": False, "ch1/test_spec": True})

    def test_categories_follow_the_oracle_and_the_results(self):
        entries = [entry("a"), entry("b"), entry("c"), entry("d", spec_only=False),
                   entry("e", spec_only=False), entry("f"), entry("g", formal=True)]
        runs = {"icarus": run(a="known", b="known", c="fail", d="pass", e="pass", f="pass", g="fail"),
                "kirimasim": run(a="fail", b="pass", c="unsupported", d="pass", e="fail", f="pass"),
                "lyra": run(a="fail", b="fail", c="fail", d="fail", e="pass", f="fail"),
                "ghost": run(a="fail", b="fail", c="fail", d="fail", e="fail", f="fail")}
        found = rc.classify(entries, runs)
        self.assertEqual(found["spec_fail_all"], ["a"])
        self.assertEqual(found["kirimasim_only"], ["b"])
        self.assertEqual(found["spec_no_pass"], ["c"])
        self.assertEqual(found["oracle_ghost_lyra"], ["d"])

    def test_a_test_without_any_result_is_not_a_candidate(self):
        found = rc.classify([entry("new")], {"ghost": run(old="fail")})
        self.assertEqual(sum(map(len, found.values())), 0)

    def test_only_the_known_simulators_are_read(self):
        with tempfile.TemporaryDirectory() as directory:
            for name in ("ghost", "other"):
                Path(directory, name + ".json").write_text(json.dumps(
                    {"version": name, "time": "t", "suite_commit": "c", "tests": {"x": "pass"}}), encoding="utf-8")
            runs = rc.load(Path(directory))
        self.assertEqual(list(runs), ["ghost"])

    def test_report_marks_an_older_suite_commit_and_absent_simulators(self):
        runs = {"ghost": run(a="fail"), "lyra": {**run(a="fail"), "suite_commit": "old",
                                                  "time": "2026-11-06T00:00:00Z"}}
        found = rc.classify([entry("a")], runs)
        text = rc.render("en", runs, found, [], rc.SOURCE_URL)
        self.assertIn("`old` (older suite commit)", text)
        self.assertIn("| Icarus Verilog | not available | | |", text)
        self.assertIn("`Lf Gf`", text)

    def test_clauses_with_only_spec_only_tests(self):
        clauses = rc.spec_only_clauses([entry("a", clauses=["4.9.3"]),
                                        entry("b", clauses=["4.9.3"]),
                                        entry("c", spec_only=False, clauses=["4.9.4"]),
                                        entry("d", clauses=["4.9.4"])], rc.ROOT)
        self.assertEqual(clauses, [{"clause": "4.9.3", "tests": 2}])


if __name__ == "__main__":
    unittest.main()
