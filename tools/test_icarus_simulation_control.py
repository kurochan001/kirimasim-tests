"""Check simulation suspension and resumption through the Icarus debugger."""

import os
from pathlib import Path
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


@unittest.skipUnless(os.environ.get("IVERILOG_BIN"), "set IVERILOG_BIN to the Icarus bin directory")
class IcarusSimulationControl(unittest.TestCase):
    def run_stop(self, statement: str) -> str:
        bin_dir = Path(os.environ["IVERILOG_BIN"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            source = directory / "stop_resume.sv"
            source.write_text(SOURCE.format(stop=statement), encoding="utf-8")
            build = subprocess.run(
                [str(bin_dir / "iverilog"), "-g2012", "-s", "stop_resume", "-o", "test.vvp",
                 source.name],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            result = subprocess.run(
                [str(bin_dir / "vvp"), "test.vvp"],
                cwd=directory, input="time\ncont\n", capture_output=True, text=True, timeout=60,
            )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        return result.stdout

    def test_stop_suspends_at_the_call_and_resumes_at_the_same_tick(self):
        for statement, reports_call in (("$stop", True), ("$stop(1)", True), ("$stop(0)", False)):
            with self.subTest(statement=statement):
                output = self.run_stop(statement)
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
