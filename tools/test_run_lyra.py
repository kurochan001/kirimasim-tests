"""Pass the chosen C++ compiler to Lyra, and name the compiler's first error
when what Lyra generated does not compile. A run or a check that a signal
ends is a failure whatever it printed, a run that hangs times out, and no
reason names a directory of the machine."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_lyra

LYRA = "/opt/lyra/lyra"
# What Lyra printed on the Nightly runner when clang++ 18 compiled its std
# package (2026-11-08); the directories are those of the runner.
GENERATED_FAILURE = (
    "error: compiling 'sv_esc_std.cpp' failed\n"
    "note: In file included from /tmp/lyra-build-a1b2c3/project/sv_esc_std.cpp:1:\n"
    "In file included from /home/runner/lyra/lyra.runfiles/_main/runtime_surface/lyra/runtime/"
    "prelude.hpp:52:\n"
    "/home/runner/lyra/lyra.runfiles/_main/runtime_surface/lyra/runtime/file_table.hpp:307:15: "
    "error: no template named 'expected' in namespace 'std'\n"
    "/home/runner/lyra/lyra.runfiles/_main/runtime_surface/lyra/runtime/file_table.hpp:310:3: "
    "error: a later error\n")


class LyraRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.test = Path(self.temp.name).resolve() / "test_sample.sv"
        self.write(":expected_stdout: TEST PASSED")

    def write(self, fields):
        self.test.write_text("/*\n" + fields + "\n*/\nmodule m; endmodule\n")

    def run_result(self, stdout="TEST PASSED\n", stderr="", code=0, cxx=None):
        """The status and reason, and the command that ran Lyra. Without a
        code, Lyra takes longer than the runner allows."""
        result = subprocess.CompletedProcess([], code, stdout, stderr)
        real_run = subprocess.run
        commands = []

        def execute(command, **kwargs):
            if command[0] == LYRA:
                commands.append(command)
                if code is None:
                    raise subprocess.TimeoutExpired(command, kwargs["timeout"])
                return result
            return real_run(command, **kwargs)

        with mock.patch.object(run_lyra.subprocess, "run", side_effect=execute):
            verdict = run_lyra.run(self.test, LYRA, Path(self.temp.name), cxx)
        return verdict, commands[0]

    def test_the_named_compiler_reaches_lyra_run(self):
        verdict, command = self.run_result(cxx="c++")
        self.assertEqual(verdict, ("pass", ""))
        self.assertEqual(command[1], "run")
        self.assertEqual(command[command.index("--cxx") + 1], "c++")

    def test_without_a_compiler_lyra_chooses_its_own(self):
        _, command = self.run_result()
        self.assertNotIn("--cxx", command)

    def test_an_illegal_design_is_checked_without_a_compiler(self):
        self.write(":should_fail_because: bad declaration\n:expected_stderr_regex: bad declaration")
        verdict, command = self.run_result("", "t.sv:1:1: error: bad declaration", 1, cxx="c++")
        self.assertEqual(verdict, ("pass", ""))
        self.assertEqual(command[1], "check")
        self.assertNotIn("--cxx", command)

    def test_a_generated_file_that_does_not_compile_names_the_compiler_error(self):
        verdict, _ = self.run_result("", GENERATED_FAILURE, 1)
        self.assertEqual(verdict, (
            "fail", "compile failed: error: compiling 'sv_esc_std.cpp' failed: "
                    "file_table.hpp:307:15: error: no template named 'expected' in namespace 'std'"))

    def test_a_generated_file_without_a_compiler_error_keeps_lyras_message(self):
        verdict, _ = self.run_result("", "error: compiling 'pkg.cpp' failed\nnote: killed\n", 1)
        self.assertEqual(verdict, ("fail", "compile failed: error: compiling 'pkg.cpp' failed"))

    def test_lyras_own_errors_are_unchanged(self):
        verdict, _ = self.run_result("", "t.sv:3:5: error: this expression has no behaviour to "
                                         "simulate\nt.sv:4:5: error: another\n", 1)
        self.assertEqual(verdict, ("fail", "compile failed: error: this expression has no "
                                           "behaviour to simulate"))

    def test_a_crash_after_the_expected_output_is_a_failure(self):
        verdict, _ = self.run_result("TEST PASSED\n", "", -11)
        self.assertEqual(verdict, ("fail", "crashed (signal 11)"))

    def test_a_check_that_crashes_does_not_reject_an_illegal_design(self):
        self.write(":should_fail_because: bad declaration\n:expected_stderr_regex: bad declaration")
        verdict, _ = self.run_result("", "t.sv:1:1: error: bad declaration", -6)
        self.assertEqual(verdict, ("fail", "crashed (signal 6)"))

    def test_a_failure_without_a_message_is_a_failure(self):
        verdict, _ = self.run_result("", "", 1)
        self.assertEqual(verdict, ("fail", "output differs (exit 1): line 1 is missing, "
                                           "expected 'TEST PASSED'"))

    def test_a_run_that_hangs_times_out(self):
        with mock.patch.object(run_lyra, "RUN_TIMEOUT", 7):
            verdict, _ = self.run_result(code=None)
        self.assertEqual(verdict, ("fail", "timed out"))

    def test_a_reason_names_no_directory_of_the_machine(self):
        temp = tempfile.gettempdir()
        verdict, _ = self.run_result("", f"{self.test}:3:5: error: cannot open "
                                         f"{Path.home()}/a.svh from {temp}/b\n", 1)
        self.assertEqual(verdict, ("fail", "compile failed: error: cannot open "
                                           "<home>/a.svh from <tmp>/b"))
        for directory in (str(Path.home()), temp, os.path.realpath(temp)):
            self.assertNotIn(directory, verdict[1])

    def test_a_path_in_the_output_is_replaced_before_the_line_is_cut(self):
        verdict, _ = self.run_result(f"{Path.home()}/" + "d/" * 40 + "a.sv\n")
        self.assertEqual(verdict, ("fail", "output differs: line 1 is '<home>/" + "d/" * 25
                                           + "...', expected 'TEST PASSED'"))

    def test_an_error_of_the_runner_fails_only_that_test(self):
        with mock.patch.object(run_lyra, "judge", side_effect=IndexError("list index")):
            verdict = run_lyra.run(self.test, LYRA, Path(self.temp.name))
        self.assertEqual(verdict, ("fail", "runner error: IndexError: list index"))


if __name__ == "__main__":
    unittest.main()
