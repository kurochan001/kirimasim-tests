"""A simulation runner must not judge a formal test, and a test whose expected
output is recorded only with another simulator is a known difference rather
than a failure (issues #13 and #14 of 2026-10-28). Ghost's runner selects
the same way (issue #22).

A run or a compiler that a signal ends is a failure whatever it printed, a
build that hangs times out, no test ends the run of the others, and no reason
names a directory of the machine (2026-11-12)."""

import os
import sys
import tempfile
import time
import unittest
from pathlib import Path
from unittest import mock

import run_ghost
import run_icarus
import run_kirimasim
import run_lyra
import run_verilator


RUNNERS = (run_ghost, run_icarus, run_kirimasim, run_lyra, run_verilator)


def fake_tool(path, stdout="", stderr="", code=0, signal=None, sleep=0, before=""):
    """An executable that stands for a simulator: it runs the Python lines of
    `before`, waits `sleep` seconds, prints `stdout` and `stderr`, in which
    {test} is its last argument, {home} the home directory and {cwd} the
    directory it runs in, and then ends with `code`, or by `signal`."""
    end = f"os.kill(os.getpid(), {signal})" if signal else f"sys.exit({code})"
    path.write_text(f"#!{sys.executable}\n"
                    "import os, sys, time\nfrom pathlib import Path\n"
                    f"{before}\ntime.sleep({sleep})\n"
                    "places = dict(test=sys.argv[-1], home=Path.home(), cwd=os.getcwd())\n"
                    f"sys.stdout.write({stdout!r}.format(**places))\n"
                    f"sys.stderr.write({stderr!r}.format(**places))\n"
                    f"sys.stdout.flush()\nsys.stderr.flush()\n{end}\n", encoding="utf-8")
    path.chmod(0o755)
    return str(path)


def machine_directories():
    """The directories that no reason may name."""
    temp = tempfile.gettempdir()
    return {str(Path.home()), temp, os.path.realpath(temp)}


class SimulationSelectionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n" + fields + "\n*/\nmodule test_sample; endmodule\n", encoding="utf-8")
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
        path.write_text("/*\n" + fields + "\n*/\nmodule test_sample; endmodule\n", encoding="utf-8")
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
                        "module test_sample; endmodule\n", encoding="utf-8")
        return path

    def simulator(self, **result):
        return fake_tool(self.root / "kirimasim", **result)

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

    def test_a_crash_after_the_expected_output_is_a_failure(self):
        test = self.make_test("test_crash", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, stdout="value\n", signal=9),
                         ("fail", "crashed (signal 9)"))

    def test_a_crash_on_an_illegal_design_is_a_failure(self):
        test = self.make_test("test_illegal", ":should_fail_because: bad\n"
                                              ":expected_stderr_regex: test_illegal\\.sv:3:")
        self.assertEqual(self.run_test(test, stderr="{test}:3:1: error: bad\n", signal=9),
                         ("fail", "crashed (signal 9)"))
        self.assertEqual(self.run_test(test, stderr="{test}:3:1: error: bad\n", code=2),
                         ("pass", ""))

    def test_a_reason_names_no_directory_of_the_machine(self):
        test = self.make_test("test_places", ":expected_stdout: value")
        status, reason = self.run_test(
            test, stdout="other\n", stderr="{test}:3:1: error: no {home}/a.svh in {cwd}\n", code=1)
        self.assertEqual(status, "fail")
        self.assertIn("<home>/a.svh in <tmp>", reason)
        for directory in machine_directories():
            self.assertNotIn(directory, reason)

    def test_a_path_in_the_output_is_replaced_before_the_line_is_cut(self):
        test = self.make_test("test_long", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, stdout="{home}/" + "d/" * 40 + "a.sv:3\n"),
                         ("fail", "output differs: line 1 is '<home>/" + "d/" * 25
                                  + "...', expected 'value'"))

    def test_an_error_of_the_runner_fails_only_that_test(self):
        test = self.make_test("test_error", ":expected_stdout: value")
        with mock.patch.object(run_kirimasim, "judge",
                               side_effect=RuntimeError(f"cannot read {Path.home()}/x")):
            self.assertEqual(run_kirimasim.run(test, self.simulator()),
                             ("fail", "runner error: RuntimeError: cannot read <home>/x"))


class IcarusJudgingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.bin = self.root / "bin"
        self.bin.mkdir()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n:type: simulation\n" + fields + "\n*/\n"
                        "module test_sample; endmodule\n", encoding="utf-8")
        return path

    def run_test(self, test, compiler=None, simulation=None):
        fake_tool(self.bin / "iverilog", **(compiler or {}))
        fake_tool(self.bin / "vvp", **(simulation or {}))
        return run_icarus.run(test, self.bin, run_icarus.install_prefix(self.bin))

    def test_the_expected_output_passes(self):
        test = self.make_test("test_pass", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, simulation=dict(stdout="value\n")), (True, ""))

    def test_a_crash_after_the_expected_output_is_a_failure(self):
        test = self.make_test("test_crash", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, simulation=dict(stdout="value\n", signal=9)),
                         (False, "crashed (signal 9)"))

    def test_a_compiler_that_crashes_does_not_reject_an_illegal_design(self):
        test = self.make_test("test_illegal", ":should_fail_because: bad\n"
                                              ":expected_stderr_regex: test_illegal\\.sv:3:")
        message = "{test}:3: error: bad\n"
        self.assertEqual(self.run_test(test, compiler=dict(stderr=message, signal=9)),
                         (False, "compiler crashed (signal 9)"))
        self.assertEqual(self.run_test(test, compiler=dict(stderr=message, code=1)), (True, ""))

    def test_a_compiler_that_fails_without_a_message_is_a_failure(self):
        test = self.make_test("test_silent", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, compiler=dict(code=1)), (False, "compile failed: "))

    def test_a_compiler_that_hangs_times_out(self):
        test = self.make_test("test_hang", ":expected_stdout: value")
        start = time.monotonic()
        with mock.patch.object(run_icarus, "COMPILE_TIMEOUT", 1):
            self.assertEqual(self.run_test(test, compiler=dict(sleep=60)),
                             (False, "timed out (compile)"))
        self.assertLess(time.monotonic() - start, 30)

    def test_a_reason_names_no_directory_of_the_machine(self):
        test = self.make_test("test_places", ":expected_stdout: value")
        ok, reason = self.run_test(
            test, compiler=dict(stderr="{test}:3: error: no {home}/a.svh in {cwd}\n", code=1))
        self.assertFalse(ok)
        self.assertIn("test_places.sv:3: error: no <home>/a.svh in ", reason)
        for directory in machine_directories():
            self.assertNotIn(directory, reason)

    def test_a_path_in_the_output_is_replaced_before_the_line_is_cut(self):
        test = self.make_test("test_long", ":expected_stdout: value")
        ok, reason = self.run_test(
            test, simulation=dict(stdout="SORRY: {home}/" + "d/" * 40 + "a.sv:3: no\n"))
        self.assertEqual((ok, reason), (False, "output differs: line 1 is 'SORRY: <home>/"
                                               + "d/" * 21 + "d...', expected 'value'"))

    def test_a_path_that_the_simulator_cut_short_is_replaced(self):
        root = str(run_icarus.ROOT)
        for runner in (run_icarus, run_verilator, run_kirimasim, run_lyra):
            with self.subTest(runner=runner.__name__):
                # The repository may lie in the home directory, as on a CI
                # runner, where the home directory is replaced first.
                with mock.patch.object(Path, "home", return_value=Path("/no-such-home")):
                    self.assertEqual(runner.neutral(f"WARNING: {root[:len(root) - 3]} Invalid value"),
                                     "WARNING: <path> Invalid value")
                cut = runner.neutral(f"WARNING: {root[:len(root) - 3]} Invalid value")
                self.assertNotIn(str(Path.home()), cut)
                self.assertNotIn(root[:len(root) - 3], cut)
                self.assertEqual(runner.neutral(f"is '{str(Path.home())[:9]}...', expected"),
                                 "is '<path>...', expected")
                self.assertEqual(runner.neutral(f"{root}/tests/a.sv {root[:7]} /usr/lib"),
                                 f"tests/a.sv {root[:7]} /usr/lib")

    def test_the_directories_of_the_test_and_of_the_simulator_are_replaced(self):
        prefix = Path("/opt/simulator/1.0")
        text = run_icarus.neutral(f"{run_icarus.ROOT}/tests/ch6/a.sv:3: {prefix}/lib/b.v /scratch/t/a",
                                  "/scratch/t", prefix)
        self.assertEqual(text, "tests/ch6/a.sv:3: <icarus>/lib/b.v <tmp>/a")

    def test_an_error_of_the_runner_fails_only_that_test(self):
        test = self.make_test("test_error", ":expected_stdout: value")
        with mock.patch.object(run_icarus, "judge", side_effect=IndexError("list index")):
            self.assertEqual(run_icarus.run(test, self.bin),
                             (False, "runner error: IndexError: list index"))


class VerilatorJudgingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()

    def make_test(self, name, fields):
        path = self.root / "tests/ch6" / f"{name}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("/*\n:type: simulation\n" + fields + "\n*/\n"
                        "module test_sample; endmodule\n", encoding="utf-8")
        return path

    def run_test(self, test, build=None, model=None):
        """The fake verilator leaves the fake model where -Mdir says."""
        model_path = fake_tool(self.root / "Vt", **(model or {}))
        copy = ("import shutil\n"
                "obj = Path(sys.argv[sys.argv.index('-Mdir') + 1])\nobj.mkdir()\n"
                f"shutil.copy({model_path!r}, obj / 'Vt')")
        verilator = fake_tool(self.root / "verilator", before=copy, **(build or {}))
        return run_verilator.run(test, verilator, 1)

    def test_the_expected_output_passes(self):
        test = self.make_test("test_pass", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, model=dict(stdout="value\n")), (True, ""))

    def test_a_crash_after_the_expected_output_is_a_failure(self):
        test = self.make_test("test_crash", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, model=dict(stdout="value\n", signal=9)),
                         (False, "crashed (signal 9)"))

    def test_a_compiler_that_crashes_does_not_reject_an_illegal_design(self):
        test = self.make_test("test_illegal", ":should_fail_because: bad\n"
                                              ":expected_stderr_regex: test_illegal\\.sv:3:")
        message = "%Error: {test}:3:1: bad\n"
        self.assertEqual(self.run_test(test, build=dict(stderr=message, signal=9)),
                         (False, "build crashed (signal 9)"))
        self.assertEqual(self.run_test(test, build=dict(stderr=message, code=1)), (True, ""))

    def test_a_build_that_fails_without_a_message_is_a_failure(self):
        test = self.make_test("test_silent", ":expected_stdout: value")
        self.assertEqual(self.run_test(test, build=dict(code=1)), (False, "build failed: "))

    def test_a_build_that_hangs_times_out(self):
        test = self.make_test("test_hang", ":expected_stdout: value")
        start = time.monotonic()
        with mock.patch.object(run_verilator, "BUILD_TIMEOUT", 1):
            self.assertEqual(self.run_test(test, build=dict(sleep=60)),
                             (False, "timed out (build)"))
        self.assertLess(time.monotonic() - start, 30)

    def test_a_model_that_hangs_times_out(self):
        test = self.make_test("test_loop", ":expected_stdout: value")
        with mock.patch.object(run_verilator, "RUN_TIMEOUT", 1):
            self.assertEqual(self.run_test(test, model=dict(sleep=60)), (False, "timed out"))

    def test_a_reason_names_no_directory_of_the_machine(self):
        test = self.make_test("test_places", ":expected_stdout: value")
        ok, reason = self.run_test(
            test, build=dict(stderr="%Error: {test}:3:1: no {home}/a.svh in {cwd}\n", code=1))
        self.assertFalse(ok)
        self.assertIn("test_places.sv:3:1: no <home>/a.svh in ", reason)
        for directory in machine_directories():
            self.assertNotIn(directory, reason)

    def test_a_path_in_the_output_is_replaced_before_the_line_is_cut(self):
        test = self.make_test("test_long", ":expected_stdout: value")
        ok, reason = self.run_test(test, model=dict(stdout="{home}/" + "d/" * 40 + "a.sv:3\n"))
        self.assertEqual((ok, reason), (False, "output differs: line 1 is '<home>/"
                                               + "d/" * 25 + "...', expected 'value'"))

    def test_an_error_of_the_runner_fails_only_that_test(self):
        test = self.make_test("test_error", ":expected_stdout: value")
        with mock.patch.object(run_verilator, "judge", side_effect=IndexError("list index")):
            self.assertEqual(run_verilator.run(test, "verilator", 1),
                             (False, "runner error: IndexError: list index"))


if __name__ == "__main__":
    unittest.main()
