"""Check suspension and host-driven resumption at separate stop calls."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


DESIGN = """`timescale 1ns/1ns
module stop_control;
  initial begin
    #7 $display("marker before first stop at %0d", $time);
    $stop(1);
    $display("marker resumed first stop at %0d", $time);
    #6 $display("marker before second stop at %0d", $time);
    $stop(1);
    #9 $display("marker resumed second stop at %0d", $time);
    $finish(0);
  end
endmodule
"""

MARKERS = (
    "marker before first stop at 7",
    "marker resumed first stop at 7",
    "marker before second stop at 13",
    "marker resumed second stop at 22",
)


@unittest.skipUnless(os.environ.get("IVERILOG_BIN"), "set IVERILOG_BIN to the Icarus bin directory")
class IcarusStopControl(unittest.TestCase):
    def test_stop_suspends_until_the_host_resumes(self):
        binary = Path(os.environ["IVERILOG_BIN"]).resolve()
        scenarios = (
            ("finish\n", 1, (7,)),
            ("cont\nfinish\n", 3, (7, 13)),
            ("cont\ncont\n", 4, (7, 13)),
        )
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "stop_control.sv"
            image = Path(temporary) / "stop_control.vvp"
            source.write_text(DESIGN, encoding="utf-8")
            build = subprocess.run(
                [str(binary / "iverilog"), "-g2012", "-s", source.stem, "-o", str(image), str(source)],
                cwd=temporary, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr or build.stdout)
            for commands, count, stopped_times in scenarios:
                with self.subTest(commands=commands.splitlines()):
                    run = subprocess.run(
                        [str(binary / "vvp"), str(image)],
                        cwd=temporary, input=commands, capture_output=True, text=True, timeout=10,
                    )
                    self.assertEqual(run.returncode, 0, run.stderr or run.stdout)
                    output = run.stdout.splitlines()
                    self.assertEqual(
                        tuple(line for line in output if line.startswith("marker ")),
                        MARKERS[:count],
                    )
                    diagnostics = [line for line in output if "$stop(" in line]
                    self.assertEqual(len(diagnostics), len(stopped_times))
                    for line, tick in zip(diagnostics, stopped_times):
                        self.assertRegex(line, rf"stop_control\.sv:\d+: \$stop\(1\) called at {tick}\b")
