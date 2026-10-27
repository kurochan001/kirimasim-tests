"""Formal export/runner safety checks. These tests never invoke a solver."""

import copy
from itertools import product
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from sva_reference import formal
from sva_reference.engine import Engine
from sva_reference.parser import Unsupported


class FormalExportTests(unittest.TestCase):
    def test_dfa_export_preserves_prefix_counts_and_alphabet_bit_order(self):
        for expression, names, length in [
            ("(a ##1 b) or (a ##1 b)", "ab", 2),
            ("first_match((a ##[1:2] b) or (a ##2 c))", "abc", 3),
            ("a[*0] ##1 b", "ab", 2),
        ]:
            machine = formal.dfa(expression, names)
            for word in product(range(1 << len(names)), repeat=length):
                samples = [{name: str((letter >> i) & 1) for i, name in enumerate(names)} for letter in word]
                engine = Engine(samples)
                matches = engine.matches(expression)
                state = 0
                self.assertEqual(machine.counts[state], sum(m.end == -1 for m in matches))
                for tick, letter in enumerate(word):
                    state = machine.transitions[state][letter]
                    self.assertEqual(machine.counts[state], sum(m.end == tick for m in matches))

    def test_export_never_reads_expectations_or_constrains_symbolic_inputs(self):
        original = Path.read_text
        def read(path, *args, **kwargs):
            if path.suffix == ".expected":
                raise AssertionError("formal export consulted expected output")
            return original(path, *args, **kwargs)
        with mock.patch.object(Path, "read_text", read):
            for name in formal.catalogue():
                source, metadata = formal.export(name)
                self.assertIn("(* any", source)
                self.assertIn("assert(actual_", source)
                self.assertNotIn("assume(", source)
                self.assertTrue(metadata["clause"])

    def test_negative_controls_change_the_reference_and_keep_the_actual_model(self):
        for name in ["first_match_tie", "within_endpoints", "empty_left", "followed_overlap", "gated_past"]:
            correct, _ = formal.export(name)
            wrong, _ = formal.export(name, mutation=True)
            self.assertNotEqual(correct, wrong)
            # The generated actual machine/table is unchanged; only the
            # independent reference is intentionally broken.
            boundary = "reg [31:0] reference_count" if name in formal.specs.SEQUENCES else "endcase end"
            self.assertEqual(correct.split(boundary)[0], wrong.split(boundary)[0])

    def test_unknown_cases_and_incomplete_dfa_export_fail_closed(self):
        with self.assertRaises(Unsupported):
            formal.export("unknown")
        with self.assertRaisesRegex(Unsupported, "state limit"):
            formal.dfa("a ##[1:3] b", "ab", max_states=1)

    def test_prove_and_bmc_use_different_engines(self):
        self.assertIn("abc pdr", formal.sby_text("prove", 8, 30))
        self.assertIn("smtbmc yices", formal.sby_text("bmc", 8, 30))
        self.assertNotIn("expect fail", formal.sby_text("bmc", 8, 30))


class FormalRunnerTests(unittest.TestCase):
    def fake_run(self, directory, status=None, rc=0, mode="bmc", expected="PASS", trace=False):
        folder = Path(directory) / "run"
        def launch(*args, **kwargs):
            artifact = folder / "case"
            artifact.mkdir()
            if status:
                (artifact / "status").write_text(status)
            if trace:
                (artifact / "trace.vcd").write_text("test-only fake witness")
            process = mock.Mock()
            process.wait.return_value = rc
            return process
        with mock.patch.object(formal.subprocess, "Popen", launch):
            return formal.run_job(folder, "module check_model; endmodule", mode=mode, depth=2,
                expected=expected, binary=Path("unused-sby"), env={}, timeout=1)

    def test_zero_exit_without_a_status_is_not_a_pass(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.fake_run(directory)
        self.assertEqual(result["status"], "ERROR")
        self.assertFalse(result["ok"])

    def test_unknown_and_inconsistent_exit_codes_are_not_success(self):
        for status, rc in [("UNKNOWN", 4), ("PASS", 2), ("ERROR", 16)]:
            with tempfile.TemporaryDirectory() as directory:
                self.assertFalse(self.fake_run(directory, status, rc)["ok"])

    def test_cover_and_negative_controls_require_a_witness(self):
        for mode, status, rc, expected in [("cover", "PASS", 0, "PASS"), ("bmc", "FAIL", 2, "FAIL")]:
            for trace in [False, True]:
                with tempfile.TemporaryDirectory() as directory:
                    result = self.fake_run(directory, status, rc, mode, expected, trace)
                self.assertEqual(result["ok"], trace)

    def test_existing_output_and_empty_selection_are_rejected_without_tools(self):
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "keep"
            file.write_text("existing result")
            with self.assertRaisesRegex(ValueError, "never overwritten"):
                formal.run(directory, "unused-sby", selected=["fusion"])
            self.assertEqual(file.read_text(), "existing result")
            with self.assertRaisesRegex(ValueError, "at least one"):
                formal.run(directory, "unused-sby", selected=[])

    def test_report_freshness_and_task_completeness_do_not_rerun_tools(self):
        report = {"schema": 1, "source_hashes": formal.source_hashes(), "selected": ["fusion"],
                  "prove": False, "source_changed": False, "ok": True, "counts": {"PASS": 2},
                  "jobs": [{"case": "fusion_bmc", "mutation": False, "mode": "bmc",
                            "status": "PASS", "expected": "PASS", "ok": True, "rc": 0, "traces": []},
                           {"case": "fusion_cover", "mutation": False, "mode": "cover",
                            "status": "PASS", "expected": "PASS", "ok": True, "rc": 0,
                            "traces": ["case/engine_0/trace.vcd"]}]}
        self.assertTrue(formal.validate_report(report))
        for change in [lambda x: x.update(source_hashes={}), lambda x: x.update(selected=[]),
                       lambda x: x.update(prove=True), lambda x: x.update(jobs=[]),
                       lambda x: x["jobs"][0].update(mode="prove"),
                       lambda x: x["jobs"][0].update(status="UNKNOWN"),
                       lambda x: x.update(source_changed=True), lambda x: x.update(counts={})]:
            bad = copy.deepcopy(report)
            change(bad)
            with self.assertRaises(ValueError):
                formal.validate_report(bad)


if __name__ == "__main__":
    unittest.main()
