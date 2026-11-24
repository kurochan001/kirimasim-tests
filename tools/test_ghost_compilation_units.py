"""Check Ghost's two SystemVerilog compilation-unit models."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import textwrap
import unittest


CHAPTER = Path(__file__).resolve().parent.parent / "tests/ch3"
ORIGIN = """\
`timescale 1ns/1ns
`define UNIT_ORIGIN_TAG 7
`default_nettype none

package unit_origin_package;
  parameter int published = 29;
endpackage

int unit_private_value = 73;

module unit_origin(output wire [3:0] tag);
  assign tag = `UNIT_ORIGIN_TAG;
endmodule
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostCompilationUnits(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        (self.directory / "origin.sv").write_text(ORIGIN, encoding="utf-8")

    def run_unit(self, mode: str, *files: str | Path) -> subprocess.CompletedProcess:
        return subprocess.run(
            [
                str(self.simulator), "--quiet", "--lrm-strict",
                "--compilation-unit", mode, *map(str, files),
            ],
            cwd=self.directory,
            capture_output=True,
            text=True,
            timeout=90,
        )

    def check_output(self, result: subprocess.CompletedProcess, line: str) -> None:
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        self.assertIn(line, result.stdout.splitlines())

    def test_directives_are_isolated_in_per_file_mode(self):
        (self.directory / "receiver.sv").write_text(textwrap.dedent("""\
            `timescale 1ns/1ns
            module receiver;
              wire [3:0] origin_tag;
            `ifdef UNIT_ORIGIN_TAG
              localparam int received = `UNIT_ORIGIN_TAG;
              wire receiver_net;
            `else
              localparam int received = -1;
            `endif
              assign receiver_net = 1'b1;
              unit_origin origin(origin_tag);

              initial #1 $display("origin=%0d receiver=%0d net=%b package=%0d",
                                  origin_tag, received, receiver_net,
                                  unit_origin_package::published);
            endmodule
            """), encoding="utf-8")

        for mode, received in (("single", 7), ("per-file", -1)):
            with self.subTest(mode=mode):
                result = self.run_unit(mode, "origin.sv", "receiver.sv")
                self.check_output(result, f"origin=7 receiver={received} net=1 package=29")

    def test_private_name_is_inaccessible_in_per_file_mode(self):
        (self.directory / "lookup.sv").write_text(textwrap.dedent("""\
            `timescale 1ns/1ns
            module lookup;
              initial $display("published=%0d private=%0d",
                               unit_origin_package::published, $unit::unit_private_value);
            endmodule
            """), encoding="utf-8")

        shared = self.run_unit("single", "origin.sv", "lookup.sv")
        self.check_output(shared, "published=29 private=73")
        isolated = self.run_unit("per-file", "origin.sv", "lookup.sv")
        self.assertGreater(isolated.returncode, 0, isolated.stdout + isolated.stderr)
        messages = re.sub(r"\x1b\[[0-9;]*m", "", isolated.stdout + isolated.stderr)
        self.assertRegex(
            messages, r"(?i)lookup\.sv:4:[^\n]*error[^\n]*"
            r"(?:undefined|undeclared|unknown)[^\n]*unit_private_value",
        )
        self.assertNotIn("published=29 private=73", isolated.stdout.splitlines())

    def test_incomplete_declaration_continues_into_next_file(self):
        sources = [
            CHAPTER / "declaration_across_file_boundary_head.sv",
            CHAPTER / "declaration_across_file_boundary_tail.sv",
            CHAPTER / "test_declaration_across_file_boundary.sv",
        ]
        for mode in ("single", "per-file"):
            with self.subTest(mode=mode):
                self.check_output(self.run_unit(mode, *sources), "a=7 b=42")
