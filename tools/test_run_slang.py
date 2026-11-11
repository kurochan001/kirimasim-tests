"""Judge slang's verdicts as the other runners judge illegal designs, and keep
the files of the machine out of the record."""

import contextlib
import io
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run_slang
import suite_results

# A fake slang: it reads "// fake: error N" and "// fake: crash" in the last
# file it is given, and names that file relative to the directory it runs in,
# as slang does.
FAKE = """\
import os, re, signal, sys
path = sys.argv[-1]
text = open(path).read()
if "// fake: crash" in text:
    os.kill(os.getpid(), signal.SIGSEGV)
lines = [int(n) for n in re.findall(r"// fake: error (\\d+)", text)]
for n in lines:
    print(f"{os.path.relpath(path)}:{n}:3: error: fake error at {n}", file=sys.stderr)
    print("  the line", file=sys.stderr)
sys.exit(1 if lines else 0)
"""


class SlangReferenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.slang = self.root / "slang"
        self.slang.write_text(f"#!{sys.executable}\n" + FAKE)
        self.slang.chmod(0o700)
        patch = mock.patch.object(suite_results, "ROOT", self.root)
        patch.start()
        self.addCleanup(patch.stop)

    def write(self, name, fields, body=""):
        test = self.root / "tests" / "ch6" / f"{name}.sv"
        test.parent.mkdir(parents=True, exist_ok=True)
        test.write_text("/*\n" + fields + "\n*/\nmodule m;\n" + body + "endmodule\n")
        return test

    def illegal(self, body):
        return run_slang.run(self.write(
            "test_illegal_x", ":should_fail_because: bad\n"
            ":expected_stderr_regex: test_illegal_x\\.sv:5:", body), str(self.slang))

    def test_an_illegal_design_rejected_at_the_marked_line(self):
        verdict = self.illegal("// fake: error 5\n")
        self.assertEqual((verdict["kind"], verdict["status"]), ("illegal", "rejected_at_line"))
        self.assertEqual(verdict["first_error"],
                         "tests/ch6/test_illegal_x.sv:5:3: error: fake error at 5")

    def test_an_illegal_design_rejected_elsewhere(self):
        self.assertEqual(self.illegal("// fake: error 6\n")["status"], "rejected_elsewhere")

    def test_an_error_after_the_first_still_counts(self):
        self.assertEqual(self.illegal("// fake: error 6\n// fake: error 5\n")["status"],
                         "rejected_at_line")

    def test_an_illegal_design_accepted(self):
        self.assertEqual(self.illegal(""), {"kind": "illegal", "status": "accepted"})

    def test_a_legal_test_is_clean_or_rejected_with_the_first_error(self):
        test = self.write("test_x", ":expected_stdout: x")
        self.assertEqual(run_slang.run(test, str(self.slang)),
                         {"kind": "legal", "status": "clean"})
        test = self.write("test_x", ":expected_stdout: x", "// fake: error 6\n// fake: error 7\n")
        self.assertEqual(run_slang.run(test, str(self.slang)),
                         {"kind": "legal", "status": "rejected",
                          "first_error": "tests/ch6/test_x.sv:6:3: error: fake error at 6"})

    def test_a_vpi_test_is_marked(self):
        test = self.write("test_vpi", ":vpi_c: @test_vpi.c\n:expected_stdout: x",
                          "// fake: error 6\n")
        verdict = run_slang.run(test, str(self.slang))
        self.assertEqual((verdict["status"], verdict.get("vpi")), ("rejected", True))

    def test_a_crash_is_neither_clean_nor_a_rejection(self):
        test = self.write("test_illegal_x", ":should_fail_because: bad\n"
                          ":expected_stderr_regex: x", "// fake: crash\n")
        self.assertEqual(run_slang.run(test, str(self.slang))["status"], "crashed")

    def test_a_file_outside_the_repository_is_named_without_its_directories(self):
        self.assertEqual(run_slang.relative("/elsewhere/dir/x.sv:3:1: error: e", str(self.root)),
                         "x.sv:3:1: error: e")

    def test_options_and_metadata_reach_slang(self):
        test = self.write("test_x", ":expected_stdout: x\n:files: helper.sv defs.svh\n"
                          ":incdirs: headers\n:defines: FLAG=1\n:top_module: chosen\n:args: +v=1")
        with mock.patch.object(run_slang.subprocess, "run", return_value=
                               subprocess.CompletedProcess([], 0, "", "")) as execute:
            run_slang.run(test, "/opt/slang")
        command = execute.call_args.args[0]
        self.assertEqual(command[:len(run_slang.OPTIONS) + 1], ["/opt/slang", *run_slang.OPTIONS])
        self.assertIn(f"-I{test.parent}", command)
        self.assertIn(f"-I{test.parent / 'headers'}", command)
        self.assertIn("-DFLAG=1", command)
        self.assertEqual(command[command.index("--top") + 1], "chosen")
        self.assertEqual(command[-2:], [str(test.parent / "helper.sv"), str(test)])
        self.assertNotIn("+v=1", command)

    def test_one_compilation_unit_is_selected_only_when_the_test_needs_it(self):
        def command(fields):
            test = self.write("test_x", ":expected_stdout: x\n:files: helper.sv" + fields)
            with mock.patch.object(run_slang.subprocess, "run", return_value=
                                   subprocess.CompletedProcess([], 0, "", "")) as execute:
                run_slang.run(test, "/opt/slang")
            return execute.call_args.args[0]
        single = command("\n:compilation_unit: single")
        self.assertEqual(single.count("--single-unit"), 1)
        self.assertLess(single.index("--single-unit"), single.index(single[-2]))
        self.assertNotIn("--single-unit", command(""))
        self.assertNotIn("--single-unit", command("\n:compilation_unit: separate"))

    def test_the_record_names_the_commit_and_no_directory_of_the_machine(self):
        self.write("test_illegal_x", ":should_fail_because: bad\n"
                   ":expected_stderr_regex: test_illegal_x\\.sv:5:", "// fake: error 5\n")
        self.write("test_x", ":expected_stdout: x", "// fake: error 6\n")
        self.write("test_vpi", ":vpi_c: @test_vpi.c\n:expected_stdout: x")
        self.write("test_formal", ":type: formal\n:formal_case: x", "// fake: error 6\n")
        output = self.root / "record.json"
        argv = ["run_slang.py", "--slang", str(self.slang), "--commit", "0123abc",
                "--json", str(output), *map(str, sorted((self.root / "tests").rglob("*.sv")))]
        log = io.StringIO()
        with mock.patch.object(sys, "argv", argv), contextlib.redirect_stdout(log):
            self.assertEqual(run_slang.main(), 0)
        text = output.read_text()
        data = json.loads(text)
        self.assertEqual((data["reference"], data["slang_commit"], data["options"]),
                         ("slang", "0123abc", run_slang.OPTIONS))
        self.assertNotIn("simulator", data)
        self.assertEqual(sorted(data["tests"]),
                         ["ch6/test_illegal_x", "ch6/test_vpi", "ch6/test_x"])
        self.assertEqual(data["summary"]["illegal"]["rejected_at_line"], 1)
        self.assertEqual(data["summary"]["legal"]["rejected"], 1)
        self.assertEqual(data["summary"]["legal_vpi"]["clean"], 1)
        self.assertEqual(data["tests"]["ch6/test_x"]["inputs_sha256"],
                         suite_results.input_digest(self.root / "tests/ch6/test_x.sv"))
        self.assertIn("REJECTED ch6/test_x: tests/ch6/test_x.sv:6:3:", log.getvalue())
        self.assertNotIn(self.temp.name, text)
        self.assertNotIn(str(self.root), text)


if __name__ == "__main__":
    unittest.main()
