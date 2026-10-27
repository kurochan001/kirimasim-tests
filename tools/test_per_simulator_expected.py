"""Guard the per-simulator expected outputs (README.md, "Metadata").

A test may keep one generic :expected_stdout: and add
:expected_stdout_<simulator>: for the simulators whose output legitimately
differs. The simulator's own field wins, the generic field stays the fallback,
and every referenced expectation file is part of the input fingerprint, so a
change to any of them invalidates the stored execution evidence.
"""

import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import lint_metadata
import run_icarus
import run_kirimasim
import run_lyra
import run_ghost
import run_verilator
import suite_results


class PerSimulatorExpectedTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.test = self.root / "tests/ch6/test_sample.sv"
        self.test.parent.mkdir(parents=True)
        self.files = {}
        for name in ("generic", "icarus", "verilator"):
            self.files[name] = self.test.parent / f"sample.{name}.expected"
        self.patcher = mock.patch.object(suite_results, "ROOT", self.root)
        self.patcher.start()
        self.addCleanup(self.patcher.stop)

    def write(self, metadata: str, generic: str = "generic\n",
              icarus: str | None = None, verilator: str | None = None):
        fields = [":lrm: 1800-2023 6.16.1", ":oracle: spec"]
        if generic is not None:
            self.files["generic"].write_text(generic)
            fields.append(":expected_stdout: @sample.generic.expected")
        if icarus is not None:
            self.files["icarus"].write_text(icarus)
            fields.append(":expected_stdout_icarus: @sample.icarus.expected")
        if verilator is not None:
            self.files["verilator"].write_text(verilator)
            fields.append(":expected_stdout_verilator: @sample.verilator.expected")
        self.test.write_text("/*\n" + "\n".join([metadata, *fields]) + "\n*/\n"
                             "module test_sample; endmodule\n")

    def test_simulator_field_wins_over_generic_fallback(self):
        self.write(":name: test_sample", "generic\n",
                   icarus="from icarus\n", verilator="from verilator\n")
        self.assertEqual(suite_results.expected_output(self.test, "icarus"), "from icarus\n")
        self.assertEqual(suite_results.expected_output(self.test, "verilator"),
                         "from verilator\n")
        # A simulator without its own field still uses the generic expectation.
        self.assertEqual(suite_results.expected_output(self.test, "kirimasim"), "generic\n")
        self.assertEqual(suite_results.expected_output(self.test, "lyra"), "generic\n")

    def test_generic_only_test_keeps_working(self):
        self.write(":name: test_sample", "generic\n")
        for simulator in suite_results.SIMULATORS:
            with self.subTest(simulator=simulator):
                self.assertEqual(suite_results.expected_output(self.test, simulator),
                                 "generic\n")

    def test_each_runner_reads_its_own_field(self):
        self.write(":name: test_sample", "generic\n",
                   icarus="from icarus\n", verilator="from verilator\n")
        self.assertEqual(run_icarus.expected_output(self.test), "from icarus\n")
        self.assertEqual(run_verilator.expected_output(self.test), "from verilator\n")
        self.assertEqual(run_kirimasim.expected_output(self.test), "generic\n")
        self.assertEqual(run_lyra.expected_output(self.test), "generic\n")
        self.assertEqual(run_ghost.expected_output(self.test), "generic\n")

    def test_inline_values_work_and_keep_the_priority(self):
        self.test.write_text("/*\n:name: test_sample\n:expected_stdout: generic\n"
                             ":expected_stdout_icarus: icarus value\n*/\n"
                             "module test_sample; endmodule\n")
        self.assertEqual(suite_results.expected_output(self.test, "icarus"), "icarus value\n")
        self.assertEqual(suite_results.expected_output(self.test, "verilator"), "generic\n")

    def test_digest_covers_every_referenced_expectation(self):
        self.write(":name: test_sample", "generic\n",
                   icarus="from icarus\n", verilator="from verilator\n")
        before = suite_results.input_digest(self.test)
        for name in ("generic", "icarus", "verilator"):
            with self.subTest(changed=name):
                # Only a change to the selected file or the fallback may alter
                # a verdict; all of them must invalidate the fingerprint.
                self.files[name].write_text("changed\n")
                self.assertNotEqual(suite_results.input_digest(self.test), before)
                self.files[name].write_text(
                    "generic\n" if name == "generic"
                    else "from icarus\n" if name == "icarus" else "from verilator\n")

    def test_digest_includes_unselected_generic_file(self):
        self.write(":name: test_sample", "generic\n", icarus="from icarus\n")
        selected = suite_results.input_digest(self.test)
        self.files["generic"].write_text("generic changed\n")
        self.assertNotEqual(suite_results.input_digest(self.test), selected)

    def test_input_files_lists_every_referenced_expectation(self):
        self.write(":name: test_sample", "generic\n",
                   icarus="from icarus\n", verilator="from verilator\n")
        names = {path.name for path in suite_results.input_files(self.test)}
        self.assertTrue({"sample.generic.expected", "sample.icarus.expected",
                         "sample.verilator.expected"} <= names)

    def test_lint_accepts_a_simulator_only_expectation(self):
        self.files["icarus"].write_text("from icarus\n")
        self.test.write_text("/*\n:name: test_sample\n:lrm: 1800-2023 6.16.1\n"
                             ":oracle: spec\n:expected_stdout_icarus: @sample.icarus.expected\n*/\n"
                             "module test_sample; endmodule\n")
        problems = lint_metadata.check(self.test)
        self.assertEqual([p for p in problems if p[0] in ("expected", "expected-key")], [])

    def test_lint_rejects_unknown_simulator_field(self):
        self.write(":name: test_sample", "generic\n")
        self.test.write_text(self.test.read_text().replace(
            ":oracle: spec\n", ":oracle: spec\n:expected_stdout_ghdl: @sample.generic.expected\n"))
        problems = lint_metadata.check(self.test)
        self.assertIn("expected-key", [rule for rule, _ in problems])

    def test_lint_accepts_known_simulator_fields(self):
        self.write(":name: test_sample", "generic\n", icarus="from icarus\n")
        problems = lint_metadata.check(self.test)
        self.assertEqual([p for p in problems if p[0] in ("expected", "expected-key")], [])

    def test_lint_validates_every_expectation_file(self):
        self.write(":name: test_sample", "generic\n", icarus="from icarus\n")
        self.files["icarus"].unlink()
        problems = lint_metadata.check(self.test)
        self.assertIn("expected", [rule for rule, _ in problems])

    def test_unknown_simulator_has_no_expected_output(self):
        self.write(":name: test_sample", "generic\n")
        with self.assertRaises(ValueError):
            suite_results.expected_output(self.test, "ghdl")


if __name__ == "__main__":
    unittest.main()
