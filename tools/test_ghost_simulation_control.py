"""Check Ghost's raw simulation-control diagnostics and resumption."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


CONTROL_SOURCE = """\
`timescale 1ns/1ns
module task_holder;
  initial begin
    #13 $display("before control=%0d", $time);
    {task};
    $display("resumed same tick=%0d", $time);
    #3 $display("resumed later=%0d", $time);
  end
endmodule
module control_probe;
  task_holder terminal_site();
endmodule
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostSimulationControl(unittest.TestCase):
    def run_control(self, task: str, *arguments: str, commands: str = "") -> str:
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "control_probe.sv"
            source.write_text(CONTROL_SOURCE.format(task=task), encoding="utf-8")
            result = subprocess.run(
                [str(simulator), "--lrm-strict", "--top", "control_probe",
                 *arguments, source.name],
                cwd=temporary, input=commands, capture_output=True, text=True, timeout=60,
            )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        self.assertIn("before control=13", result.stdout)
        if task.startswith("$finish"):
            self.assertNotIn("resumed same tick=", result.stdout)
            self.assertNotIn("resumed later=", result.stdout)
        return result.stdout + result.stderr

    def test_finish_zero_has_no_diagnostic(self):
        self.assertEqual(self.run_control("$finish(0)", "--quiet-all"), "before control=13\n")

    def test_default_finish_diagnostic_matches_level_one(self):
        default = self.run_control("$finish", "--quiet")
        explicit = self.run_control("$finish(1)", "--quiet")
        default_notices = [line for line in default.splitlines() if "$finish" in line]
        explicit_notices = [line for line in explicit.splitlines() if "$finish" in line]
        self.assertTrue(default_notices, default)
        self.assertEqual(default_notices, explicit_notices)
        self.assertRegex(default_notices[0], r"\b13\b")

    def test_finish_one_identifies_time_and_location(self):
        output = self.run_control("$finish(1)", "--quiet-all")
        self.assertRegex(output, r"(?m)^.*\$finish.*\b13\b")
        self.assertRegex(output, r"control_probe\.terminal_site|control_probe\.sv[:(]5\b")

    def test_finish_two_adds_memory_and_cpu_statistics(self):
        output = self.run_control("$finish(2)", "--quiet-all")
        self.assertRegex(output, r"(?m)^.*\$finish.*\b13\b")
        self.assertRegex(output, r"control_probe\.terminal_site|control_probe\.sv[:(]5\b")
        with self.subTest(statistic="memory"):
            self.assertRegex(output, r"(?i)\b(?:memory|allocated|heap|rss)\b[^\n]*[0-9]")
        with self.subTest(statistic="CPU"):
            self.assertRegex(output, r"(?i)\b(?:cpu|processor)\b[^\n]*[0-9]")

    def test_stop_resumes_from_same_tick_in_debugger(self):
        output = self.run_control(
            "$stop", "--quiet", "--interactive",
            commands="run 100ns\ntime\ncontinue\ntime\nquit\n",
        )
        running = re.search(r"Continuing simulation", output, re.IGNORECASE)
        self.assertIsNotNone(running, output)
        self.assertRegex(output[:running.start()], r"Simulation time:\s*13ns")
        self.assertNotIn("resumed same tick=", output[:running.start()])
        self.assertIn("resumed same tick=13", output[running.end():])
        self.assertIn("resumed later=16", output[running.end():])
