"""Reparse assignment-pattern output with an independent SystemVerilog frontend."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


@unittest.skipUnless(
    os.environ.get("GHOST_SIMULATOR") and os.environ.get("SLANG_EXECUTABLE"),
    "set GHOST_SIMULATOR and SLANG_EXECUTABLE to run the pattern round trip",
)
class GhostPatternRoundTrip(unittest.TestCase):
    def assert_round_trip(self, literals: tuple[str, ...]) -> None:
        ghost = str(Path(os.environ["GHOST_SIMULATOR"]).resolve())
        slang = str(Path(os.environ["SLANG_EXECUTABLE"]).resolve())
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            assignments = "\n".join(
                f"    words[{index}] = {literal};" for index, literal in enumerate(literals)
            )
            (directory / "format.sv").write_text(
                f"""module pattern_string_probe;
  string words[{len(literals)}];
  initial begin
{assignments}
    $display("BEGIN_PATTERN");
    $display("%p", words);
    $display("END_PATTERN");
  end
endmodule
""",
                encoding="utf-8",
            )
            formatted = subprocess.run(
                [ghost, "--quiet-all", "--lrm-strict", "format.sv"],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(formatted.returncode, 0, formatted.stderr)
            _, begin, remainder = formatted.stdout.partition("BEGIN_PATTERN\n")
            pattern, end, _ = remainder.partition("\nEND_PATTERN\n")
            self.assertTrue(begin and end and pattern, formatted.stdout)

            comparisons = " && ".join(
                f"(WORDS[{index}] == {literal})" for index, literal in enumerate(literals)
            )
            (directory / "reparsed.sv").write_text(
                f"""module pattern_round_trip;
  localparam string WORDS[{len(literals)}] = {pattern};
  localparam bit MATCH = {comparisons};
endmodule
""",
                encoding="utf-8",
            )
            parsed = subprocess.run(
                [slang, "--std=1800-2023", "--top", "pattern_round_trip",
                 "--ast-json", "parsed.json", "reparsed.sv"],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(parsed.returncode, 0, parsed.stderr)
            ast = json.loads((directory / "parsed.json").read_text(encoding="utf-8"))
            instance = next(item for item in ast["design"]["members"]
                            if item["kind"] == "Instance" and item["name"] == "pattern_round_trip")
            match = next(item for item in instance["body"]["members"]
                         if item["kind"] == "Parameter" and item["name"] == "MATCH")
            self.assertEqual(match["value"], "1'b1", pattern)

    def test_plain_array_pattern_round_trips(self):
        self.assert_round_trip(('"alpha"', '"beta"', '"gamma"'))

    def test_array_pattern_retains_string_delimiters_and_escapes(self):
        self.assert_round_trip((r'"double\"quote"', r'"back\\slash"', r'"tab\tnext\nline"'))
