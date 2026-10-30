"""A simulation runner must not judge a formal test, and a test whose expected
output is recorded only with another simulator is a known difference rather
than a failure (issues #13 and #14 of 2026-10-28). Ghost's runner selects
the same way (issue #22)."""

import sys
import tempfile
import unittest
from pathlib import Path

import run_ghost
import run_icarus
import run_kirimasim
import run_lyra
import run_verilator


RUNNERS = (run_ghost, run_icarus, run_kirimasim, run_lyra, run_verilator)


class SimulationSelectionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n" + fields + "\n*/\nmodule test_sample; endmodule\n")
        return path

    def test_every_simulation_runner_skips_formal_tests(self):
        simulation = self.make_test("test_sim", ":type: simulation")
        formal = self.make_test("test_formal", ":type: formal")
        elaboration = self.make_test("test_elaboration", ":type: elaboration")
        for runner in RUNNERS:
            with self.subTest(runner=runner.__name__):
                self.assertEqual(runner.simulation_tests([simulation, formal, elaboration]),
                                 [simulation, elaboration])

    def test_every_simulation_runner_keeps_the_order_of_named_tests(self):
        first = self.make_test("test_first", ":type: simulation")
        second = self.make_test("test_second", ":type: elaboration")
        for runner in RUNNERS:
            with self.subTest(runner=runner.__name__):
                self.assertEqual(runner.simulation_tests([second, first]), [second, first])


class OtherSimulatorExpectationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n" + fields + "\n*/\nmodule test_sample; endmodule\n")
        return path

    def test_other_simulator_expectation_is_named(self):
        test = self.make_test("test_other",
                              ":type: simulation\n:expected_stdout_verilator: value")
        self.assertEqual(run_kirimasim.expectation_of_other_simulator(test), "verilator")
        self.assertIsNone(run_kirimasim.expectation_of_other_simulator(
            self.make_test("test_own", ":type: simulation\n:expected_stdout_kirimasim: mine")))

    def test_generic_expectation_leaves_no_other_simulator(self):
        test = self.make_test("test_generic",
                              ":type: simulation\n:expected_stdout: value")
        self.assertIsNone(run_kirimasim.expectation_of_other_simulator(test))

    def test_own_expectation_wins_over_another_simulator(self):
        test = self.make_test("test_both",
                              ":type: simulation\n:expected_stdout_kirimasim: mine\n"
                              ":expected_stdout_verilator: theirs")
        self.assertIsNone(run_kirimasim.expectation_of_other_simulator(test))


class KirimasimClassificationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n:type: simulation\n" + fields + "\n*/\n"
                        "module test_sample; endmodule\n")
        return path

    def simulator(self, stdout="", stderr="", code=0):
        path = self.root / "kirimasim"
        path.write_text(f"#!{sys.executable}\n"
                        f"import sys\nsys.stdout.write({stdout!r})\n"
                        f"sys.stderr.write({stderr!r})\nsys.exit({code})\n")
        path.chmod(0o755)
        return str(path)

    def run_test(self, test, **result):
        return run_kirimasim.run(test, self.simulator(**result))

    def test_unsupported_is_reported_before_a_missing_expectation(self):
        test = self.make_test("test_unsupported", "")
        self.assertEqual(self.run_test(test, stderr="error: unsupported: later\n", code=2),
                         ("unsupported", "later"))

    def test_unsupported_is_not_hidden_by_matching_output(self):
        test = self.make_test("test_unsupported_match", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, stdout="value\n",
                                       stderr="error: unsupported: later\n", code=2),
                         ("unsupported", "later"))

    def test_expectation_of_another_simulator_is_a_known_difference(self):
        test = self.make_test("test_other", ":expected_stdout_verilator: value")
        self.assertEqual(self.run_test(test),
                         ("known", "the expected output is recorded with verilator"))

    def test_missing_expectation_remains_a_failure(self):
        test = self.make_test("test_missing", "")
        self.assertEqual(self.run_test(test), ("fail", "no :expected_stdout:"))

    def test_generic_expectation_passes(self):
        test = self.make_test("test_pass", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, stdout="value\n"), ("pass", ""))

    def test_difference_is_a_failure(self):
        test = self.make_test("test_difference", ":expected_stdout: value")
        status, reason = self.run_test(test, stdout="other\n")
        self.assertEqual(status, "fail")
        self.assertTrue(reason.startswith("output differs"))


if __name__ == "__main__":
    unittest.main()
