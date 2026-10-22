"""Regression tests against inflated behavioral coverage or stale pass evidence."""

import copy
import contextlib
import io
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import behavior_coverage as coverage
import suite_results


class BehaviorCoverageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.inventory = json.loads((coverage.DATA / "standard-sections.json").read_text())
        cls.registry = json.loads((coverage.DATA / "behaviors.json").read_text())

    def setUp(self):
        self.inv = copy.deepcopy(self.inventory)
        # A small requirements fixture; don't accidentally certify other sections.
        for s in self.inv["sections"]:
            if s["review"] == "complete":
                s["review"] = "in_progress"
        first = next(r for r in self.registry["requirements"] if r["id"] == "SV2023-4.9.3-RHS-SAMPLED")
        self.reg = {"schema": 1, "requirements": [copy.deepcopy(first)]}

    def validated(self):
        return coverage.validate(self.inv, self.reg)

    def assert_invalid(self, text):
        with self.assertRaisesRegex(coverage.InvalidCoverage, text):
            self.validated()

    def result(self, status="pass", simulator="icarus", row=None):
        r = row or self.reg["requirements"][0]
        check = r["checks"][0]
        test = coverage.ROOT / check["test"]
        return {"simulator": simulator, "name": simulator,
                "version": "Icarus Verilog version 13.0 (stable) (v13_0)",
                "generated_at": "2026-10-22T00:00:00+00:00",
                "runner_sha256": suite_results.runner_digest(simulator),
                "tests": {suite_results.test_id(test): {
                    "status": status, "inputs_sha256": suite_results.input_digest(test)}}}

    def execute(self, result, rows=None):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.json"
            path.write_text(json.dumps(result))
            return coverage.execution(rows or self.validated()[1], [path])

    def test_no_requirement_inferred_from_thousands_of_citations(self):
        self.reg["requirements"] = []
        sections, rows = self.validated()
        stats = coverage.summarize(sections, rows, {"executed": []})
        self.assertEqual(stats["registered"], 0)
        self.assertIsNone(stats["registered_percent"])
        self.assertIsNone(stats["whole_standard_percent"])

    def test_registered_full_coverage_does_not_mean_standard_full_coverage(self):
        sections, rows = self.validated()
        stats = coverage.summarize(sections, rows, {"executed": [rows[0]["id"]]})
        self.assertEqual(stats["registered_percent"], 100)
        self.assertIsNone(stats["whole_standard_percent"])
        self.assertIsNone(stats["whole_standard_executed_percent"])

    def test_complete_audit_can_still_have_unmapped_obligations(self):
        self.reg["requirements"][0]["checks"] = []
        sections, rows = self.validated()
        small = {"4.9.3": {"kind": "normative", "review": "complete"},
                 "P": {"kind": "informative", "review": "unreviewed"}}
        stats = coverage.summarize(small, rows, {"executed": []}, denominator_reviewed=True)
        self.assertEqual(stats["whole_standard_percent"], 0)
        self.assertEqual(stats["unmapped"], 1)

    def test_complete_design_coverage_can_still_lack_execution_evidence(self):
        _, rows = self.validated()
        stats = coverage.summarize({"4.9.3": {"kind": "normative", "review": "complete"}},
                                   rows, {"executed": []}, denominator_reviewed=True)
        self.assertEqual(stats["whole_standard_percent"], 100)
        self.assertEqual(stats["whole_standard_executed_percent"], 0)

    def test_reading_all_source_does_not_approve_overlapping_requirement_units(self):
        _, rows = self.validated()
        stats = coverage.summarize({"4.9.3": {"kind": "normative", "review": "complete"}},
                                   rows, {"executed": [rows[0]["id"]]})
        self.assertEqual(stats["extraction_progress_percent"], 100)
        self.assertEqual(stats["registered_percent"], 100)
        self.assertIsNone(stats["whole_standard_percent"])

    def test_source_review_evidence_cannot_be_removed_from_baseline(self):
        sections, rows = self.validated()
        before = coverage.baseline(sections, rows)
        before["source_reviewed_sections"] = ["4.9.3"]
        after = {**before, "source_reviewed_sections": []}
        with self.assertRaisesRegex(coverage.InvalidCoverage, "source review regression"):
            coverage.check_baseline(before, after)

    def measured(self, rows=None, source_complete=True, reviewed=False, executed=None):
        sections, fixture = self.validated()
        return coverage.measurement(sections, rows or fixture,
                                    {"executed": executed or []},
                                    {"source_review_complete": source_complete}, reviewed, "inventory")

    def test_provisional_denominator_keeps_holds_and_unmapped_rows(self):
        _, rows = self.validated()
        held = {**rows[0], "id": "HELD", "mapped": False, "checks": [],
                "interpretation_issue": "CONFLICT"}
        missing = {**held, "id": "MISSING"}
        missing.pop("interpretation_issue")
        stats = self.measured(rows + [held, missing], executed=[rows[0]["id"]])
        self.assertAlmostEqual(stats["provisional_design_percent"], 100 / 3)
        self.assertAlmostEqual(stats["provisional_execution_percent"], 100 / 3)
        self.assertEqual(stats["whole_standard_status"], "provisional")
        self.assertEqual(stats["requirement_status_counts"], {
            "pass": 1, "mapped_without_pass": 0, "unmapped": 1, "interpretation_pending": 1})

    def test_partial_source_cannot_be_reported_as_provisional_full_scope(self):
        result = self.measured(source_complete=False)
        self.assertEqual(result["whole_standard_status"], "source_incomplete")
        self.assertIsNone(result["provisional_design_percent"])
        self.assertIsNone(result["provisional_execution_percent"])

    def test_linked_file_count_deduplicates_requirements_without_inferring_unlinked_tests(self):
        _, rows = self.validated()
        linked = coverage.ROOT / rows[0]["checks"][0]["test"]
        unlinked = coverage.ROOT / "tests/ch6/test_string_len.sv"
        second = {**rows[0], "id": "SECOND"}
        with mock.patch.object(suite_results, "find_tests", return_value=[linked, unlinked]):
            result = self.measured(rows + [second])
        self.assertEqual(result["test_mapping"], {
            "suite_test_files": 2, "linked_test_files": 1, "unlinked_test_files": 1})
        self.assertEqual(result["requirement_status_counts"]["mapped_without_pass"], 2)

    def test_denominator_identity_ignores_mapping_and_run_progress(self):
        _, rows = self.validated()
        original = self.measured(rows)["denominator"]["sha256"]
        rows[0]["mapped"] = False
        rows[0]["checks"] = []
        self.assertEqual(self.measured(rows, executed=[])["denominator"]["sha256"], original)
        rows[0]["acceptance"] += " An additional observable requirement."
        self.assertNotEqual(self.measured(rows)["denominator"]["sha256"], original)

    def test_outcome_partition_preserves_nonpassing_reasons(self):
        for status in ("pass", "fail", "known", "unsupported"):
            with self.subTest(status=status):
                runs, _ = self.execute(self.result(status))
                run = runs["snapshots"][0]
                self.assertEqual(run["status_counts"][status], 1)
                self.assertEqual(sum(run["status_counts"].values()), 1)

    def grouped_fixture(self):
        row = self.reg["requirements"][0]
        other = coverage.ROOT / "tests/ch4/test_sched_intra_assignment_target.sv"
        fields = suite_results.header(other)
        expected = other.parent / fields["expected_stdout"][1:]
        row["checks"].append({**row["checks"][0],
                              "test": other.relative_to(coverage.ROOT).as_posix(),
                              "inputs_sha256": suite_results.input_digest(other),
                              "evidence": [{"file": other.relative_to(coverage.ROOT).as_posix(),
                                            "contains": "module"},
                                           {"file": expected.relative_to(coverage.ROOT).as_posix(),
                                            "contains": expected.read_text().strip()}]})
        row["check_groups"] = [{"id": "joint-observations",
                                "tests": [c["test"] for c in row["checks"]],
                                "reviewer": "unit-test fixture", "reviewed_on": "2026-10-22",
                                "observation": "Both fixture observations are required together."}]
        return row

    def test_collective_witness_requires_every_member_to_pass(self):
        row = self.grouped_fixture()
        second = coverage.ROOT / row["checks"][1]["test"]
        for state in (None, "known", "unsupported", "fail", "pass"):
            with self.subTest(state=state):
                result = self.result()
                if state:
                    result["tests"][suite_results.test_id(second)] = {
                        "status": state, "inputs_sha256": suite_results.input_digest(second)}
                runs, _ = self.execute(result)
                self.assertEqual(bool(runs["executed"]), state == "pass")
                self.assertEqual(runs["snapshots"][0]["outcomes"][row["id"]], state or "not_run")

    def test_ungrouped_checks_remain_independent_alternatives(self):
        row = self.grouped_fixture()
        del row["check_groups"]
        self.assertEqual(len(self.execute(self.result())[0]["executed"]), 1)

    def test_collective_witness_cannot_merge_partial_runs(self):
        row = self.grouped_fixture()
        with tempfile.TemporaryDirectory() as directory:
            paths = []
            for index, check in enumerate(row["checks"]):
                result = self.result()
                test = coverage.ROOT / check["test"]
                result["tests"] = {suite_results.test_id(test): {
                    "status": "pass", "inputs_sha256": suite_results.input_digest(test)}}
                path = Path(directory) / f"partial-{index}.json"
                path.write_text(json.dumps(result))
                paths.append(path)
            runs, _ = coverage.execution(self.validated()[1], paths)
        self.assertEqual(runs["executed"], [])

    def test_collective_review_rejects_missing_and_unknown_members(self):
        row = self.grouped_fixture()
        group = row["check_groups"][0]
        original = group["tests"][:]
        group["tests"] = original[:1]
        self.assert_invalid("ungrouped test")
        group["tests"] = original + ["tests/ch4/missing.sv"]
        self.assert_invalid("unknown/duplicate check group member")
        group["tests"] = original
        del group["observation"]
        self.assert_invalid("collective review")

    def test_baseline_prevents_dropping_collective_requirement(self):
        row = self.grouped_fixture()
        sections, rows = self.validated()
        previous = coverage.baseline(sections, rows)
        del row["check_groups"]
        sections, rows = self.validated()
        with self.assertRaisesRegex(coverage.InvalidCoverage, "collective witness changed"):
            coverage.check_baseline(previous, coverage.baseline(sections, rows))

    def test_stale_pass_and_absent_result_have_distinct_outcomes(self):
        stale = self.result()
        next(iter(stale["tests"].values()))["inputs_sha256"] = "old"
        absent = self.result()
        absent["tests"].clear()
        self.assertEqual(self.execute(stale)[0]["snapshots"][0]["status_counts"]["stale"], 1)
        self.assertEqual(self.execute(absent)[0]["snapshots"][0]["status_counts"]["not_run"], 1)

    def test_a_simulator_cannot_inherit_another_simulators_pass(self):
        _, rows = self.validated()
        other = copy.deepcopy(next(r for r in self.registry["requirements"]
                                   if r["id"] == "SV2023-6.22.5-NO-HANDLE-REAL"))
        other["mapped"] = True
        with tempfile.TemporaryDirectory() as directory:
            paths = []
            for simulator, version, passing in [
                    ("icarus", "Icarus Verilog version 13.0", rows[0]),
                    ("verilator", "Verilator 5.052", other)]:
                result = self.result(simulator=simulator, row=passing)
                result["version"] = version
                path = Path(directory) / (simulator + ".json")
                path.write_text(json.dumps(result))
                paths.append(path)
            runs, _ = coverage.execution(rows + [other], paths)
        self.assertEqual(len(runs["executed"]), 2)
        self.assertEqual([len(s["executed"]) for s in runs["snapshots"]], [1, 1])

    def test_compact_artifacts_and_history_are_reproducible_and_checked(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            data_folder = folder / "coverage"
            shutil.copytree(coverage.DATA, data_folder)
            common = ["--output", str(folder / "full.md"), "--summary-output", str(folder / "short.md"),
                      "--summary-json", str(folder / "short.json")]
            def run(args):
                with (mock.patch.object(coverage, "DATA", data_folder),
                      mock.patch.object(sys, "argv", ["coverage", *args, *common]),
                      contextlib.redirect_stdout(io.StringIO()),
                      contextlib.redirect_stderr(io.StringIO())):
                    return coverage.main()
            self.assertEqual(run(["--update", "--history", str(folder / "history.json")]), 0)
            self.assertEqual(run(["--check"]), 0)
            data = json.loads((folder / "short.json").read_text())
            history = json.loads((folder / "history.json").read_text())["runs"][0]
            self.assertNotIn("generated_at", data)
            self.assertIn("generated_at", history)
            self.assertEqual(data["denominator"], history["denominator"])
            self.assertNotIn("outcomes", history["execution"]["snapshots"][0])
            (folder / "short.md").write_text("stale\n")
            self.assertEqual(run(["--check"]), 1)
            self.assertEqual(run(["--update"]), 0)
            (folder / "short.json").write_text("{}\n")
            self.assertEqual(run(["--check"]), 1)

    def test_parent_introductions_are_not_completed_by_children(self):
        sections, rows = self.validated()
        small = {"4.9": {"kind": "normative", "review": "unreviewed"},
                 "4.9.3": {"kind": "normative", "review": "complete"}}
        self.assertIsNone(coverage.summarize(small, rows, {"executed": []})["whole_standard_percent"])

    def test_duplicate_requirement_id_is_rejected(self):
        self.reg["requirements"] *= 2
        self.assert_invalid("duplicate behavior")

    def test_missing_normative_annex_root_is_rejected(self):
        self.inv["sections"] = [s for s in self.inv["sections"] if s["id"] != "H"]
        self.assert_invalid("must include")

    def test_complete_section_without_decomposition_is_rejected(self):
        self.inv["sections"][0].update(review="complete", review_note="reviewed", reviewed_on="2026-10-22")
        self.assert_invalid("no decomposed obligations")

    def test_no_behavior_cannot_hide_a_registered_obligation(self):
        for s in self.inv["sections"]:
            if s["id"] == self.reg["requirements"][0]["clause"]:
                s.update(review="no_behavior", review_note="incorrect", reviewed_on="2026-10-22")
        self.assert_invalid("has a requirement")

    def test_stale_reviewed_inputs_are_rejected(self):
        self.reg["requirements"][0]["checks"][0]["inputs_sha256"] = "0" * 64
        self.assert_invalid("stale reviewed mapping")

    def test_missing_observation_anchor_is_rejected(self):
        self.reg["requirements"][0]["checks"][0]["evidence"][0]["contains"] = "not in source"
        self.assert_invalid("missing observation anchor")

    def test_citation_alone_is_not_evidence(self):
        check = self.reg["requirements"][0]["checks"][0]
        check["evidence"] = [{"file": check["test"], "contains": ":lrm:"}]
        self.assert_invalid("checked output")

    def test_output_alone_without_stimulus_is_rejected(self):
        check = self.reg["requirements"][0]["checks"][0]
        check["evidence"] = check["evidence"][1:]
        self.assert_invalid("stimulus")

    def test_non_input_file_cannot_supply_evidence(self):
        check = self.reg["requirements"][0]["checks"][0]
        check["evidence"].append({"file": "README.md", "contains": "SystemVerilog"})
        self.assert_invalid("not among test inputs")

    def test_outside_repository_path_is_rejected(self):
        self.reg["requirements"][0]["checks"][0]["test"] = "../outside.sv"
        self.assert_invalid("outside repository")

    def test_fresh_actual_pass_counts(self):
        runs, ignored = self.execute(self.result())
        self.assertEqual(runs["executed"], [self.reg["requirements"][0]["id"]])
        self.assertFalse(ignored)

    def test_known_fail_and_unsupported_do_not_count(self):
        for status in ("known", "unsupported", "fail"):
            with self.subTest(status=status):
                runs, ignored = self.execute(self.result(status))
                self.assertFalse(runs["executed"])

    def test_legacy_pass_does_not_count(self):
        result = self.result()
        result.pop("runner_sha256")
        runs, ignored = self.execute(result)
        self.assertFalse(runs["executed"])
        self.assertTrue(ignored)

    def test_changed_runner_pass_does_not_count(self):
        result = self.result()
        result["runner_changed"] = True
        runs, ignored = self.execute(result)
        self.assertFalse(runs["executed"])
        self.assertTrue(ignored)

    def test_stale_test_pass_does_not_count(self):
        result = self.result()
        next(iter(result["tests"].values()))["inputs_sha256"] = "old"
        runs, ignored = self.execute(result)
        self.assertFalse(runs["executed"])
        self.assertEqual(runs["snapshots"][0]["stale_links"], 1)

    def test_changed_during_execution_does_not_count(self):
        result = self.result()
        next(iter(result["tests"].values()))["inputs_changed"] = True
        runs, ignored = self.execute(result)
        self.assertFalse(runs["executed"])

    def test_spec_only_negative_cannot_count_accidental_rejection(self):
        row = copy.deepcopy(next(r for r in self.registry["requirements"]
                                 if r["id"] == "SV2023-7.8.5-NO-REAL-MEMBER"))
        row["mapped"] = True
        runs, _ = self.execute(self.result(row=row), [row])
        self.assertFalse(runs["executed"])

    def test_negative_requires_the_reviewed_simulator_version(self):
        row = copy.deepcopy(next(r for r in self.registry["requirements"]
                                 if r["id"] == "SV2023-6.22.5-NO-HANDLE-REAL"))
        row["mapped"] = True
        result = self.result(row=row)
        result["version"] = "Icarus Verilog version 14.0 (devel)"
        runs, _ = self.execute(result, [row])
        self.assertFalse(runs["executed"])

    def test_baseline_blocks_deletion_unmapping_and_rewording(self):
        sections, rows = self.validated()
        before = coverage.baseline(sections, rows)
        for change in ("delete", "unmap", "relax"):
            with self.subTest(change=change):
                new = copy.deepcopy(rows)
                if change == "delete":
                    new.clear()
                elif change == "unmap":
                    new[0]["mapped"] = False
                else:
                    new[0]["acceptance"] = "Anything is acceptable"
                with self.assertRaises(coverage.InvalidCoverage):
                    coverage.check_baseline(before, coverage.baseline(sections, new))

    def test_baseline_blocks_silent_scope_reduction(self):
        sections, rows = self.validated()
        before = coverage.baseline(sections, rows)
        sections["34"]["kind"] = "informative"
        with self.assertRaises(coverage.InvalidCoverage):
            coverage.check_baseline(before, coverage.baseline(sections, rows))

    def test_history_records_denominator_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "history.json"
            coverage.append_history(path, {"registered": 10, "registry_sha256": "first"})
            coverage.append_history(path, {"registered": 12, "registry_sha256": "second"})
            self.assertEqual([r["registered"] for r in json.loads(path.read_text())["runs"]], [10, 12])

    def test_update_locks_new_requirements_against_later_removal(self):
        for section in self.inv["sections"]:
            section["review"] = "in_progress"
        for rule in self.reg["requirements"]:
            rule.pop("source_spans", None)
        sections, rows = self.validated()
        initial = coverage.baseline(sections, rows, self.inv["source"])
        extra = copy.deepcopy(self.reg["requirements"][0])
        extra.update(id="SV2023-4.9.3-NEW-BOUNDARY", checks=[],
                     behavior="An additional boundary obligation in the fixture.")
        self.reg["requirements"].append(extra)
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / "standard-sections.json").write_text(json.dumps(self.inv))
            (folder / "requirement-source-index.json").write_bytes(
                (coverage.DATA / "requirement-source-index.json").read_bytes())
            (folder / "requirement-audit.json").write_text(json.dumps({
                "schema": 1, "pdf_sha256": self.inv["source"]["pdf_sha256"],
                "text_sha256": json.loads((coverage.DATA / "requirement-source-index.json").read_text())["text_sha256"],
                "sections": {}}))
            registry_path = folder / "behaviors.json"
            registry_path.write_text(json.dumps(self.reg))
            (folder / "behavior-baseline.json").write_text(json.dumps(initial))
            def run(mode):
                with (mock.patch.object(coverage, "DATA", folder),
                      mock.patch.object(sys, "argv", ["coverage", mode, "--output", str(folder / "report.md")]),
                      contextlib.redirect_stdout(io.StringIO()),
                      contextlib.redirect_stderr(io.StringIO())):
                    return coverage.main()
            self.assertEqual(run("--check"), 1)
            self.assertEqual(run("--update"), 0)
            self.assertEqual(run("--check"), 0)
            self.reg["requirements"].pop()
            registry_path.write_text(json.dumps(self.reg))
            self.assertEqual(run("--check"), 1)


class InputFingerprintTests(unittest.TestCase):
    def test_design_expected_include_c_helper_and_missing_files_affect_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            folder = root / "tests" / "ch1"
            folder.mkdir(parents=True)
            test = folder / "test_case.sv"
            test.write_text('/*\n:expected_stdout: @case.expected\n:vpi_c: @case.c\n'
                            ':dpi_c: bare.c\n:files: missing.dat\n*/\n'
                            '`include "case.svh"\nmodule m; endmodule\n')
            files = [folder / n for n in ("case.expected", "case.c", "case.svh", "bare.c")]
            for path in files:
                path.write_text("original\n")
            with mock.patch.object(suite_results, "ROOT", root):
                digest = suite_results.input_digest(test)
                for path in [test, *files]:
                    original = path.read_bytes()
                    path.write_bytes(original + b"changed\n")
                    self.assertNotEqual(suite_results.input_digest(test), digest)
                    path.write_bytes(original)
                (folder / "missing.dat").write_text("now exists")
                self.assertNotEqual(suite_results.input_digest(test), digest)

    def test_snapshot_writer_detects_inputs_changed_while_running(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            folder = root / "tests" / "ch1"
            folder.mkdir(parents=True)
            test = folder / "test_case.sv"
            test.write_text("module m; endmodule\n")
            with (mock.patch.object(suite_results, "ROOT", root),
                  mock.patch.object(suite_results, "runner_digest", return_value="runner")):
                before = suite_results.fingerprints([test])
                test.write_text("module changed; endmodule\n")
                target = root / "result.json"
                suite_results.write(target, "icarus", "Icarus", "13.0",
                                    {"ch1/test_case": ("pass", "")},
                                    inputs=before, runner_sha256="runner")
                result = json.loads(target.read_text())["tests"]["ch1/test_case"]
                self.assertTrue(result["inputs_changed"])
                self.assertNotIn("inputs_sha256", result)


if __name__ == "__main__":
    unittest.main()
