"""Pass the chosen C++ compiler to Lyra, and name the compiler's first error
when what Lyra generated does not compile. A run or a check that a signal
ends is a failure whatever it printed, a run that hangs times out, and no
reason names a directory of the machine."""

import os
import copy
import io
import json
import re
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path
from unittest import mock

import run_lyra
import suite_results

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
        self.test.write_text("/*\n" + fields + "\n*/\nmodule m; endmodule\n", encoding="utf-8")

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


class LyraShardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        for module in (suite_results, run_lyra):
            patch = mock.patch.object(module, "ROOT", self.root)
            patch.start()
            self.addCleanup(patch.stop)
        patch = mock.patch.object(suite_results, "runner_digest", return_value="runner123")
        patch.start()
        self.addCleanup(patch.stop)
        self.tests = []
        for i in range(24):
            path = self.root / "tests" / "ch6" / f"test_{i}.sv"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("/*\n:type: simulation\n:expected_stdout: ok\n*/\nmodule m; endmodule\n")
            self.tests.append(path)
        self.inputs = suite_results.fingerprints(self.tests)
        self.paths = []
        for index in range(4):
            statuses = {suite_results.test_id(t): ("fail" if i % 3 == 0 else "pass", "sample")
                        for i, t in enumerate(self.tests) if run_lyra.shard_index(t, 4) == index}
            path = self.root / f"shard-{index}.json"
            suite_results.write(path, "lyra", "Lyra", "Lyra (commit abcdef123456)", statuses,
                                inputs=self.inputs, runner_sha256="runner123",
                                configuration={"cxx": "c++", "shard": {"index": index, "count": 4}})
            self.paths.append(path)

    def change(self, index, modify):
        path = self.paths[index]
        data = json.loads(path.read_text())
        modify(data)
        path.write_text(json.dumps(data))

    def test_assignment_is_complete_disjoint_and_independent_of_input_order(self):
        groups = [{suite_results.test_id(t) for t in self.tests if run_lyra.shard_index(t, 4) == i}
                  for i in range(4)]
        self.assertTrue(all(groups))
        self.assertEqual(sum(map(len, groups)), len(self.tests))
        self.assertEqual(set.union(*groups), set(self.inputs))
        self.assertEqual([run_lyra.shard_index(t, 4) for t in self.tests],
                         list(reversed([run_lyra.shard_index(t, 4) for t in reversed(self.tests)])))

    def test_assignment_is_independent_of_checkout_directory(self):
        expected = [run_lyra.shard_index(t, 4) for t in self.tests]
        other = self.root / "other-checkout"
        relocated = [other / t.relative_to(self.root) for t in self.tests]
        with mock.patch.object(suite_results, "ROOT", other):
            self.assertEqual([run_lyra.shard_index(t, 4) for t in relocated], expected)

    def test_worker_cli_runs_every_simulation_once_and_excludes_formal_tests(self):
        formal = self.root / "tests" / "ch6" / "test_formal.sv"
        formal.write_text("/*\n:type: formal\n*/\nmodule m; endmodule\n")
        visited, paths = [], []

        def execute(test, *unused):
            visited.append(suite_results.test_id(test))
            return "pass", ""

        with mock.patch.object(suite_results, "find_tests", return_value=self.tests + [formal]), \
                mock.patch.object(run_lyra.shutil, "which", return_value=LYRA), \
                mock.patch.object(run_lyra, "run", side_effect=execute), \
                mock.patch("sys.stdout", io.StringIO()):
            for index in range(4):
                path = self.root / f"worker-{index}.json"
                paths.append(path)
                with mock.patch("sys.argv", ["run_lyra.py", "--commit", "abcdef123456",
                                             "--shard-count", "4", "--shard-index", str(index),
                                             "--json", str(path), "-j", "2"]):
                    self.assertEqual(run_lyra.main(), 0)
        self.assertEqual(len(visited), len(self.tests))
        self.assertEqual(set(visited), set(self.inputs))
        _, _, results, _, _ = run_lyra.merge_shards(paths, self.tests, 4)
        self.assertEqual(set(results), set(self.inputs))

    def test_complete_union_preserves_verdicts_reasons_and_verified_fingerprints(self):
        version, config, results, inputs, runner = run_lyra.merge_shards(
            list(reversed(self.paths)), self.tests, 4)
        self.assertEqual(version, "Lyra (commit abcdef123456)")
        self.assertEqual(config, {"cxx": "c++"})
        self.assertEqual(inputs, self.inputs)
        self.assertEqual(runner, "runner123")
        self.assertEqual(results, {suite_results.test_id(t): ("fail" if i % 3 == 0 else "pass", "sample")
                                   for i, t in enumerate(self.tests)})

    def test_missing_or_duplicate_shards_are_rejected(self):
        for paths in (self.paths[:-1], self.paths + [self.paths[0]]):
            with self.subTest(paths=paths), self.assertRaises(ValueError):
                run_lyra.merge_shards(paths, self.tests, 4)

    def test_incomplete_wrongly_assigned_or_unknown_tests_are_rejected(self):
        original = self.paths[0].read_text()
        data = json.loads(original)
        name = next(iter(data["tests"]))
        other = next(n for n in self.inputs if n not in data["tests"])
        for replace in (None, other, "ch6/test_unknown"):
            with self.subTest(replace=replace):
                changed = copy.deepcopy(data)
                record = changed["tests"].pop(name)
                if replace is not None:
                    changed["tests"][replace] = record
                self.paths[0].write_text(json.dumps(changed))
                with self.assertRaises(ValueError):
                    run_lyra.merge_shards(self.paths, self.tests, 4)
        self.paths[0].write_text(original)

    def test_changed_inputs_runner_version_configuration_and_status_are_rejected(self):
        original = self.paths[0].read_text()
        for field, value in [("runner_sha256", "old"), ("runner_changed", True),
                             ("version", "different"), ("simulator", "other"),
                             ("configuration", {"cxx": "clang++", "shard": {"index": 0, "count": 4}}),
                             ("configuration", {"shard": {"index": 0, "count": 3}})]:
            with self.subTest(field=field, value=value):
                self.paths[0].write_text(original)
                self.change(0, lambda d: d.update({field: value}))
                with self.assertRaises(ValueError):
                    run_lyra.merge_shards(self.paths, self.tests, 4)
        for field, value in [("inputs_sha256", "old"), ("inputs_changed", True), ("status", "not_run")]:
            with self.subTest(field=field):
                self.paths[0].write_text(original)
                self.change(0, lambda d: next(iter(d["tests"].values())).update({field: value}))
                with self.assertRaises(ValueError):
                    run_lyra.merge_shards(self.paths, self.tests, 4)

    def test_input_edits_after_validation_are_never_given_a_new_matching_fingerprint(self):
        version, config, results, inputs, runner = run_lyra.merge_shards(self.paths, self.tests, 4)
        self.tests[0].write_text(self.tests[0].read_text() + "// changed\n")
        out = self.root / "merged.json"
        suite_results.write(out, "lyra", "Lyra", version, results, inputs=inputs,
                            configuration=config, runner_sha256=runner)
        record = json.loads(out.read_text())["tests"][suite_results.test_id(self.tests[0])]
        self.assertTrue(record["inputs_changed"])
        self.assertNotIn("inputs_sha256", record)

    def test_merge_cli_needs_no_simulator_and_keeps_an_existing_output_on_failure(self):
        output = self.root / "merged.json"
        args = ["run_lyra.py", "--merge-shards", *map(str, self.paths), "--shard-count", "4",
                "--json", str(output)]
        with mock.patch("sys.argv", args), \
                mock.patch.object(suite_results, "find_tests", return_value=self.tests), \
                mock.patch.object(run_lyra.shutil, "which", side_effect=AssertionError("must not run Lyra")), \
                mock.patch("sys.stdout", io.StringIO()), mock.patch("sys.stderr", io.StringIO()):
            self.assertEqual(run_lyra.main(), 0)
            saved = output.read_bytes()
            self.paths[-1].unlink()
            with self.assertRaises(SystemExit) as failure:
                run_lyra.main()
            self.assertEqual(failure.exception.code, 2)
            self.assertEqual(output.read_bytes(), saved)

    def test_workflow_propagates_a_merge_failure_even_with_an_existing_output(self):
        workflow = (Path(__file__).resolve().parent.parent / ".github/workflows/nightly.yml").read_text()
        step = re.search(r"      - name: Validate and combine the complete suite\n"
                         r"        run: \|\n((?:          [^\n]*\n|\n)+)", workflow)
        self.assertIsNotNone(step)
        script = textwrap.dedent(step.group(1))
        binary = self.root / "bin"
        binary.mkdir()
        python = binary / "python3"
        python.write_text("#!/bin/sh\nexit 2\n")
        python.chmod(0o755)
        shards = self.root / "shards"
        shards.mkdir()
        (shards / "part.json").write_text("{}")
        (shards / "part.log").write_text("partial")
        output = self.root / "results" / "lyra.json"
        output.parent.mkdir()
        output.write_text("previous valid output")
        result = subprocess.run(["bash", "-c", script], cwd=self.root, capture_output=True,
                                env={**os.environ, "PATH": str(binary) + os.pathsep + os.environ["PATH"],
                                     "GITHUB_STEP_SUMMARY": str(self.root / "summary")})
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(output.read_text(), "previous valid output")


if __name__ == "__main__":
    unittest.main()
