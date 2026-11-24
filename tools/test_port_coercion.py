"""Check permitted port coercion and the warning required when coercion is absent."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


INPUT_DRIVEN_INTERNALLY = """\
module coerced_input(input wire channel, input wire drive);
  assign channel = drive;
endmodule

module test_coerced_input;
  bit drive = 0;
  wire observed;
  coerced_input endpoint(observed, drive);

  initial begin
    #1 $display("first control=%b reverse=%b", drive, observed);
    #1 drive = 1;
    #1 $display("second control=%b reverse=%b", drive, observed);
  end
endmodule
"""

OUTPUT_DRIVEN_EXTERNALLY = """\
module coerced_output(output wire channel, output wire observed);
  assign observed = channel;
endmodule

module test_coerced_output;
  bit drive = 0;
  wire channel = drive;
  wire observed;
  coerced_output endpoint(channel, observed);

  initial begin
    #1 $display("first control=%b reverse=%b", channel, observed);
    #1 drive = 1;
    #1 $display("second control=%b reverse=%b", channel, observed);
  end
endmodule
"""

PORT_WARNING = re.compile(
    r"(?im)^(?=[^\r\n]*\bwarn(?:ing)?\b)"
    r"(?=[^\r\n]*\b(?:port|coerc\w*)\b)(?=[^\r\n]*\bchannel\b)"
)


class PortCoercion(unittest.TestCase):
    def verify_directions(self, run):
        for name, design in (
            ("input_driven_internally", INPUT_DRIVEN_INTERNALLY),
            ("output_driven_externally", OUTPUT_DRIVEN_EXTERNALLY),
        ):
            with self.subTest(direction=name), tempfile.TemporaryDirectory() as temporary:
                source = Path(temporary) / (name + ".sv")
                source.write_text(design, encoding="utf-8")
                stdout, diagnostics = run(source)
                samples = [line for line in stdout.splitlines()
                           if line.startswith(("first ", "second "))]
                coerced = ["first control=0 reverse=0", "second control=1 reverse=1"]
                uncoerced = ["first control=0 reverse=z", "second control=1 reverse=z"]
                self.assertIn(samples, (coerced, uncoerced), stdout + diagnostics)
                if samples == uncoerced:
                    self.assertRegex(diagnostics, PORT_WARNING,
                                     "channel kept its declared direction without a warning")

    def invoke(self, source, *command):
        result = subprocess.run(command, cwd=source.parent,
                                capture_output=True, text=True, timeout=90)
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        return result

    @unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
    def test_ghost(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()

        def run(source):
            result = self.invoke(source, str(simulator), "--lrm-strict", source.name)
            return result.stdout, result.stderr + "\n" + result.stdout

        self.verify_directions(run)

    @unittest.skipUnless(os.environ.get("IVERILOG_BIN"), "set IVERILOG_BIN to the Icarus bin directory")
    def test_icarus(self):
        binary = Path(os.environ["IVERILOG_BIN"]).resolve()

        def run(source):
            build = self.invoke(source, str(binary / "iverilog"), "-g2012",
                                "-o", "trial.vvp", source.name)
            result = self.invoke(source, str(binary / "vvp"), "trial.vvp")
            return result.stdout, "\n".join((build.stdout, build.stderr, result.stdout, result.stderr))

        self.verify_directions(run)

    @unittest.skipUnless(os.environ.get("KIRIMASIM_EXECUTABLE"),
                         "set KIRIMASIM_EXECUTABLE to run kirimasim")
    def test_kirimasim(self):
        simulator = Path(os.environ["KIRIMASIM_EXECUTABLE"]).resolve()

        def run(source):
            result = self.invoke(source, str(simulator), source.name)
            return result.stdout, result.stderr + "\n" + result.stdout

        self.verify_directions(run)
