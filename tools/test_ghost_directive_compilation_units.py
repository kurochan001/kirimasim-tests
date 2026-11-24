"""Check directive and declaration visibility in Ghost compilation-unit modes."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent
FIXTURES = ROOT / "tests/ch5"
MACRO_SOURCE = FIXTURES / "compilation_unit_directive_provider.sv"
MACRO_CONSUMER = FIXTURES / "test_directive_crosses_files_in_one_compilation_unit.sv"

ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")


NETTYPE_SOURCE = """\
`timescale 100ps/10ps
`default_nettype none
module nettype_provider(output wire bit_value);
  assign bit_value = 1'b1;
endmodule
"""

NETTYPE_CONSUMER = """\
`timescale 100ps/10ps
module nettype_consumer;
  {declaration}
  nettype_provider provider(.bit_value(port_created_wire));
  initial #1 $display("implicit port value=%b", port_created_wire);
endmodule
"""


PRIVATE_SOURCE = """\
`timescale 1ns/1ns
package units_public_codes;
  localparam int STEP = 3;
endpackage

int unit_marker = 17;
module private_unit_source;
  initial $display("source local=%0d", $unit::unit_marker + units_public_codes::STEP);
endmodule
"""


PRIVATE_CONSUMER = """\
`timescale 1ns/1ns
int unit_marker = 41;
module private_unit_consumer;
  private_unit_source child();
  initial #1 $display("consumer local=%0d", $unit::unit_marker + units_public_codes::STEP);
endmodule
"""


TIMESCALE_CONSUMER = """\
timeunit 1ns/1ps;

module unit_delay(output bit done);
  initial #1.24 done = 1;
endmodule

module timescale_boundary;
  timeunit 1ps/1ps;
  wire done;
  unit_delay child(done);
  initial begin
    @(posedge done);
    $display("child arrived at %0.0f ps", $realtime);
  end
endmodule
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostDirectiveCompilationUnits(unittest.TestCase):
    def simulate(self, mode: str, directory: Path, *sources: Path) -> subprocess.CompletedProcess:
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        return subprocess.run(
            [str(simulator), "--quiet-all", "--lrm-strict", "--compilation-unit", mode,
             *map(str, sources)],
            cwd=directory, capture_output=True, text=True, timeout=60,
        )

    def test_macro_visibility_depends_on_mode_and_read_order(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            for mode, sources, marker in (
                ("single", (MACRO_SOURCE, MACRO_CONSUMER), 29),
                ("single", (MACRO_CONSUMER, MACRO_SOURCE), -1),
                ("per-file", (MACRO_SOURCE, MACRO_CONSUMER), -1),
                ("per-file", (MACRO_CONSUMER, MACRO_SOURCE), -1),
            ):
                with self.subTest(mode=mode, first=sources[0].name):
                    result = self.simulate(mode, directory, *sources)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout.splitlines(),
                                     ["provider marker=29", f"consumer marker={marker}"])

    def test_default_nettype_applies_only_to_its_unit(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            provider = directory / "nettype_provider.sv"
            consumer = directory / "nettype_consumer.sv"
            provider.write_text(NETTYPE_SOURCE, encoding="utf-8")

            consumer.write_text(NETTYPE_CONSUMER.format(declaration=""), encoding="utf-8")
            single = self.simulate("single", directory, provider, consumer)
            separate = self.simulate("per-file", directory, provider, consumer)
            self.assertNotEqual(single.returncode, 0, single.stdout)
            diagnostic = ANSI_ESCAPE.sub("", single.stderr + single.stdout)
            self.assertRegex(
                diagnostic,
                r"(?im)^.*nettype_consumer\.sv:4:[^\n]*(?:undeclared|undefined)[^\n]*port_created_wire",
            )
            self.assertEqual(separate.returncode, 0, separate.stderr)
            self.assertEqual(separate.stdout.splitlines(), ["implicit port value=1"])

            consumer.write_text(NETTYPE_CONSUMER.format(declaration="wire port_created_wire;"),
                                encoding="utf-8")
            for mode in ("single", "per-file"):
                with self.subTest(mode=mode):
                    explicit = self.simulate(mode, directory, provider, consumer)
                    self.assertEqual(explicit.returncode, 0, explicit.stderr)
                    self.assertEqual(explicit.stdout.splitlines(), ["implicit port value=1"])

    def test_same_named_unit_variables_keep_distinct_values(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            provider = directory / "private_unit_source.sv"
            consumer = directory / "private_unit_consumer.sv"
            provider.write_text(PRIVATE_SOURCE, encoding="utf-8")
            consumer.write_text(PRIVATE_CONSUMER, encoding="utf-8")

            single = self.simulate("single", directory, provider, consumer)
            separate = self.simulate("per-file", directory, provider, consumer)
            self.assertNotEqual(single.returncode, 0, single.stdout)
            diagnostic = ANSI_ESCAPE.sub("", single.stderr + single.stdout)
            self.assertRegex(
                diagnostic,
                r"(?im)^.*private_unit_consumer\.sv:2:[^\n]*redefinition[^\n]*unit_marker",
            )
            self.assertEqual(separate.returncode, 0, separate.stderr)
            self.assertEqual(separate.stdout.splitlines(),
                             ["source local=20", "consumer local=44"])

    def test_timescale_directive_respects_the_compilation_unit_boundary(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            provider = directory / "timescale_directive.sv"
            consumer = directory / "unit_consumer.sv"
            consumer.write_text(TIMESCALE_CONSUMER, encoding="utf-8")
            for directive, same_unit_ps in (("10ns/1ns", 12000), ("100ps/10ps", 120)):
                provider.write_text(f"`timescale {directive}\n", encoding="utf-8")
                # In one unit the directive has precedence. In separate units,
                # the consumer inherits its own 1 ns / 1 ps declaration.
                for mode, arrival_ps in (("single", same_unit_ps), ("per-file", 1240)):
                    with self.subTest(directive=directive, mode=mode):
                        result = self.simulate(mode, directory, provider, consumer)
                        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                        self.assertEqual(result.stdout, f"child arrived at {arrival_ps} ps\n")
