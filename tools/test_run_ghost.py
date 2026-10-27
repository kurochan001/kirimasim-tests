"""Keep private diagnostics private without weakening the public verdicts."""

import contextlib
import io
import json
import signal
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_ghost
import suite_results


PROFILE = {
    "arguments": ["--quiet"], "environment": {"PRIVATE_STRICT_MODE": "1"},
    "include_subdirs": ["private-api"], "trailer": "[private] Simulation completed",
    "banner_pattern": r"^\[private\] ",
    "severity_pattern": r"^Error: .* at time \d+$",
}


class GhostRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.test = Path(self.temp.name).resolve() / "test_sample.sv"
        self.write(":expected_stdout: TEST PASSED")

    def write(self, fields):
        self.test.write_text("/*\n" + fields + "\n*/\nmodule m; endmodule\n")

    def run_result(self, stdout="TEST PASSED\n", stderr="", code=0):
        result = subprocess.CompletedProcess([], code, stdout, stderr)
        real_run = subprocess.run

        def execute(command, **kwargs):
            if command[0] == "/private/simulator":
                return result
            return real_run(command, **kwargs)

        with mock.patch.object(run_ghost.subprocess, "run", side_effect=execute):
            return run_ghost.run(self.test, "/private/simulator", None, PROFILE)

    def test_test_output_survives_framework_trailer(self):
        raw = ("[private] loading\nTEST PASSED\nError: report at time 0\n"
               "[private] Simulation completed\nTEST PASSED\nstatistics\n")
        self.assertEqual(self.run_result(raw), ("pass", ""))

    def test_diagnostic_looking_test_output_is_not_removed(self):
        raw = "[TIMING] user data\nCover point hit at time 1\nTEST PASSED\n"
        self.assertEqual(run_ghost.normalize(raw, PROFILE), raw)

    def test_private_stdout_and_stderr_never_enter_failure_reasons(self):
        status, reason = self.run_result("private-brand internal.cpp:42\n",
                                         "/private/repository/runtime.cpp:3: error: secret", 255)
        self.assertEqual((status, reason), ("fail", "output differs (exit 255)"))

    def test_crash_after_complete_output_is_a_failure(self):
        self.assertEqual(self.run_result(code=-signal.SIGSEGV),
                         ("fail", f"crashed (signal {signal.SIGSEGV})"))

    def test_exit_code_is_checked_when_the_test_requires_it(self):
        self.write(":expected_stdout: TEST PASSED\n:expected_exit: 0")
        self.assertEqual(self.run_result(code=2), ("fail", "exit code 2, expected 0"))

    def test_unspecified_exit_code_uses_the_shared_judging_rules(self):
        self.assertEqual(self.run_result(code=2), ("pass", ""))

    def test_declared_nonzero_exit_and_stderr_are_checked(self):
        self.write(":expected_stdout: TEST PASSED\n:expected_exit: nonzero\n"
                   ":expected_stderr_regex: expected fatal")
        self.assertEqual(self.run_result(stderr="expected fatal", code=2), ("pass", ""))
        self.assertEqual(self.run_result(stderr="private error", code=2),
                         ("fail", "no message matches 'expected fatal'"))

    def test_illegal_design_requires_the_expected_error(self):
        self.write(":should_fail_because: bad declaration\n:expected_stderr_regex: bad declaration")
        self.assertEqual(self.run_result("", "error: bad declaration", 255), ("pass", ""))
        self.assertEqual(self.run_result("", "private.cpp:12: error: secret", 255),
                         ("fail", "no error matches 'bad declaration'"))
        self.assertEqual(self.run_result("", "error: bad declaration", 0),
                         ("fail", "the design was accepted, but it is illegal"))

    def test_timeout_is_recorded_without_partial_private_output(self):
        with mock.patch.object(run_ghost.subprocess, "run", side_effect=
                               subprocess.TimeoutExpired("private-name", 90,
                                                         output="private.cpp:1")):
            self.assertEqual(run_ghost.run(self.test, "/private/simulator", None, PROFILE),
                             ("fail", "timed out"))

    def test_metadata_and_private_environment_reach_the_simulator(self):
        self.write(":expected_stdout: TEST PASSED\n:files: helper.sv\n:incdirs: headers\n"
                   ":defines: FLAG=1\n:top_module: chosen\n:args: +value=7")
        with mock.patch.object(run_ghost.subprocess, "run", return_value=
                               subprocess.CompletedProcess([], 0, "TEST PASSED\n", "")) as execute:
            run_ghost.run(self.test, "/private/simulator", None, PROFILE)
        command = execute.call_args_list[0].args[0]
        self.assertEqual(command[:2], ["/private/simulator", "--quiet"])
        self.assertIn(f"+incdir+{self.test.parent / 'headers'}", command)
        self.assertIn("+define+FLAG=1", command)
        self.assertIn("-top", command)
        self.assertLess(command.index(str(self.test.parent / "helper.sv")),
                        command.index(str(self.test)))
        self.assertEqual(command[-1], "+value=7")
        self.assertEqual(execute.call_args_list[0].kwargs["env"]["PRIVATE_STRICT_MODE"], "1")

    def test_public_cli_result_contains_no_private_identity_or_diagnostics(self):
        root = self.test.parent
        test = root / "tests/ch6/test_sample.sv"
        test.parent.mkdir(parents=True)
        test.write_text(self.test.read_text())
        executable = root / "private-brand"
        executable.write_text(f"#!{sys.executable}\n"
                              "import sys\nprint('private-brand secret.cpp:42')\n"
                              "print('/private/source/secret.cpp:5: error: hidden', file=sys.stderr)\n")
        executable.chmod(0o700)
        profile = root / "private-profile.json"
        profile.write_text(json.dumps(PROFILE))
        output = root / "result.json"
        log = io.StringIO()
        with (mock.patch.object(suite_results, "ROOT", root),
              mock.patch.object(suite_results, "runner_digest", return_value="runner"),
              mock.patch.object(sys, "argv", ["run_ghost.py", "--simulator", str(executable),
                                             "--profile", str(profile), "--json", str(output),
                                             str(test)]),
              contextlib.redirect_stdout(log)):
            self.assertEqual(run_ghost.main(), 1)
        data = json.loads(output.read_text())
        self.assertEqual((data["simulator"], data["name"]), ("ghost", "Ghost"))
        self.assertRegex(data["version"], r"^private build [0-9a-f]{12}$")
        self.assertEqual(data["tests"]["ch6/test_sample"]["status"], "fail")
        public = log.getvalue() + output.read_text()
        for private in ("private-brand", "secret.cpp", "/private/source", "PRIVATE_STRICT_MODE"):
            self.assertNotIn(private, public)


if __name__ == "__main__":
    unittest.main()
