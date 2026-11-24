"""Check the separate search locations for quoted and angle-bracket includes."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


HEADER = "markers/scope_probe.svh"
BOTH_FORMS = f"""\
module include_kinds;
  `include "{HEADER}"
  localparam int USER_VALUE = `INCLUDE_PICK;
  `undef INCLUDE_PICK
  `include <{HEADER}>
  localparam int STANDARD_VALUE = `INCLUDE_PICK;
  `undef INCLUDE_PICK
endmodule
"""


class StandardIncludeSearch(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        for directory, value in (("user", 41), ("standard", 73)):
            path = self.directory / directory / HEADER
            path.parent.mkdir(parents=True)
            path.write_text(f"`define INCLUDE_PICK {value}\n", encoding="utf-8")
        self.write("both.sv", BOTH_FORMS)
        self.write("angle.sv", f"module angle_probe;\n  `include <{HEADER}>\nendmodule\n")
        self.write("quoted.sv", f"""\
module quote_probe;
  `include "{HEADER}"
  initial $display("quote=%0d", `INCLUDE_PICK);
endmodule
""")

    def write(self, name: str, source: str) -> None:
        (self.directory / name).write_text(source, encoding="utf-8")

    def invoke(self, executable: str, *options: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            [str(Path(os.environ[executable]).resolve()), *options],
            cwd=self.directory, capture_output=True, text=True, timeout=60,
        )

    @unittest.skipUnless(os.environ.get("SLANG_EXECUTABLE"), "set SLANG_EXECUTABLE to run Slang")
    def test_slang_angle_path_uses_the_configured_standard_location(self):
        arguments = ("--std=1800-2023", "-I", "user")
        result = self.invoke(
            "SLANG_EXECUTABLE", *arguments, "--isystem", "standard", "--top", "include_kinds",
            "--ast-json", "design.json", "both.sv",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        ast = json.loads((self.directory / "design.json").read_text(encoding="utf-8"))
        module = next(item for item in ast["design"]["members"] if item["kind"] == "Instance")
        values = {p["name"]: int(p["value"]) for p in module["body"]["members"]
                  if p["kind"] == "Parameter"}
        self.assertEqual(values, {"USER_VALUE": 41, "STANDARD_VALUE": 73})

        omitted = self.invoke("SLANG_EXECUTABLE", *arguments, "--top", "angle_probe", "angle.sv")
        self.assertGreater(omitted.returncode, 0, omitted.stdout + omitted.stderr)
        self.assertRegex(omitted.stderr, r"angle\.sv:2:12: error: [^\n]*scope_probe\.svh[^\n]*No such file")

    @unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
    def test_ghost_user_include_path_is_available_only_to_the_quoted_form(self):
        arguments = ("--quiet-all", "--lrm-strict", "+incdir+user")
        quoted = self.invoke("GHOST_SIMULATOR", *arguments, "-top", "quote_probe", "quoted.sv")
        self.assertEqual(quoted.returncode, 0, quoted.stderr or quoted.stdout)
        self.assertEqual(quoted.stdout, "quote=41\n")

        angle = self.invoke("GHOST_SIMULATOR", *arguments, "-top", "angle_probe", "angle.sv")
        self.assertGreater(angle.returncode, 0, angle.stdout + angle.stderr)
        self.assertRegex(angle.stderr, r"angle\.sv:2:12: error: CouldNotOpenIncludeFile")
