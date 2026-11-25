"""Check simulation suspension and resumption through the Icarus debugger."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


SOURCE = """\
`timescale 1ns/1ns
module stop_resume;
  initial begin
    #37;
    $display("before stop t=%0d", $time);
    {stop};
    $display("after stop t=%0d", $time);
    #5 $display("delayed t=%0d", $time);
    $finish(0);
  end
endmodule
"""

CHAPTER = Path(__file__).resolve().parent.parent / "tests/ch20"
REPEATED_STOPS = CHAPTER / "test_stop_suspends_each_call_and_resumes_same_tick.sv"
DIAGNOSTIC_DEFAULT = CHAPTER / "test_control_diagnostic_argument_defaults_to_one.sv"


@unittest.skipUnless(os.environ.get("IVERILOG_BIN"), "set IVERILOG_BIN to the Icarus bin directory")
class IcarusSimulationControl(unittest.TestCase):
    def run_control(self, source_text: str, commands: str, *arguments: str) -> str:
        bin_dir = Path(os.environ["IVERILOG_BIN"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            source = directory / "stop_resume.sv"
            source.write_text(source_text, encoding="utf-8")
            build = subprocess.run(
                [str(bin_dir / "iverilog"), "-g2012", "-o", "test.vvp", source.name],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            result = subprocess.run(
                [str(bin_dir / "vvp"), "test.vvp", *arguments],
                cwd=directory, input=commands, capture_output=True, text=True, timeout=60,
            )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        return result.stdout

    def test_stop_suspends_at_the_call_and_resumes_at_the_same_tick(self):
        for statement, reports_call in (("$stop", True), ("$stop(1)", True), ("$stop(0)", False)):
            with self.subTest(statement=statement):
                output = self.run_control(SOURCE.format(stop=statement), "time\ncont\n")
                records = output.splitlines()
                key_records = [
                    "before stop t=37", "37 ticks", "** Continue **", "after stop t=37", "delayed t=42",
                ]
                self.assertEqual([line for line in records if line in key_records], key_records, output)
                debugger_input = records.index("37 ticks")
                call_records = [line for line in records if "$stop" in line]
                if reports_call:
                    self.assertEqual(len(call_records), 1, output)
                    self.assertRegex(call_records[0], r"stop_resume\.sv:6:\s+\$stop.*\b37\b")
                    self.assertLess(records.index(call_records[0]), debugger_input, output)
                else:
                    self.assertEqual(call_records, [], output)

    def test_two_stops_each_require_a_continue_command(self):
        source = REPEATED_STOPS.read_text(encoding="utf-8")
        expected = REPEATED_STOPS.with_suffix(".expected").read_text(encoding="utf-8").splitlines()
        output = self.run_control(source, "time\ncont\ntime\ncont\n")
        self.assertEqual([line for line in output.splitlines() if line in expected], expected, output)

        stopped = self.run_control(source, "time\ncont\ntime\nfinish\n")
        self.assertIn("first resume at 7", stopped)
        self.assertIn("\n11 ticks\n", stopped)
        self.assertNotIn("second resume at", stopped)
        self.assertNotIn("finish at", stopped)

    def test_default_diagnostics_match_explicit_level_one(self):
        source = DIAGNOSTIC_DEFAULT.read_text(encoding="utf-8")
        expected = DIAGNOSTIC_DEFAULT.with_suffix(".expected").read_text(encoding="utf-8").splitlines()
        for task, commands, args in (("stop", "time\ncont\n", ()), ("finish", "", ("+finish-control",))):
            notices = {}
            for level in (None, 0, 1, 2):
                with self.subTest(task=task, level=level):
                    options = args if level is None else (*args, f"+level={level}")
                    output = self.run_control(source, commands, *options)
                    records = output.splitlines()
                    expected_records = expected[:1] if task == "finish" else [
                        expected[0], "17 ticks", "** Continue **", *expected[1:],
                    ]
                    markers = (*expected, "17 ticks", "** Continue **")
                    self.assertEqual([line for line in records if line in markers], expected_records, output)
                    diagnostics = [line for line in records if f"${task}" in line]
                    self.assertEqual(len(diagnostics), 0 if level == 0 else 1, output)
                    if diagnostics:
                        prefix = f"${task}" if level is None else f"${task}({level})"
                        position = records.index(diagnostics[0])
                        self.assertLess(records.index(expected[0]), position, output)
                        if task == "stop":
                            self.assertLess(position, records.index("17 ticks"), output)
                        match = re.fullmatch(rf"stop_resume\.sv:\d+: {re.escape(prefix)} (.*)", diagnostics[0])
                        self.assertIsNotNone(match, output)
                        notices[level] = match[1]
            self.assertIn("called at 17", notices.get(1, ""))
            self.assertEqual(notices.get(None), notices.get(1))
