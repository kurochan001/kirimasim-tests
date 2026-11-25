"""Test the source mutations and diagnostic location checks."""

from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

import run_slang_source_checks as checks


class SlangSourceChecksTests(unittest.TestCase):
    def test_anchor_on_its_own_line_counts_the_leading_newline(self):
        change = checks.Change("begin", "reset", "\nend\n", "unmatched")
        edited, line = checks.changed_source("begin\nmodule m; endmodule\nend\n", change)
        self.assertEqual(edited, "reset\nmodule m; endmodule\nend\n")
        self.assertEqual(line, 3)

    def test_missing_or_ambiguous_mutation_is_an_error(self):
        change = checks.Change("begin", "reset", "end", "unmatched")
        for source in ("end", "begin\nbegin\nend", "begin\nend\nend"):
            with self.subTest(source=source):
                with self.assertRaisesRegex(ValueError, "expected"):
                    checks.changed_source(source, change)

    def test_only_the_expected_error_on_the_expected_line_matches(self):
        change = checks.Change("start", "reset", "end", "unmatched")
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            test = work / "sample.sv"
            test.write_text("start\nbody\nend\n", encoding="utf-8")
            for code, diagnostic, matched in (
                (1, "sample.sv:3:12: error: unmatched closing pragma", True),
                (1, "sample.sv:2:12: error: unmatched closing pragma", False),
                (1, "sample.sv:3:12: error: some other pragma diagnostic", False),
                (-9, "sample.sv:3:12: error: unmatched closing pragma", False),
            ):
                with self.subTest(code=code, diagnostic=diagnostic):
                    with mock.patch.object(checks.protect, "compile_source",
                                           side_effect=[(0, []), (code, [diagnostic])]):
                        probe_dir = work / "probe"
                        probe_dir.mkdir(exist_ok=True)
                        outcomes = checks.pragma_checks(test, Path("slang"), "m", probe_dir,
                                                        {"remove_open": change})
                    self.assertTrue(outcomes["control"]["pass"])
                    self.assertEqual(outcomes["remove_open"]["pass"], matched)

    def test_reset_diagnostics_are_checked_in_the_following_source(self):
        fixture = checks.suite_results.ROOT / "tests/ch34/test_protect_reset_stops_encoding_state_at_file_boundary.sv"
        probes = checks.RESET_CASES["ch34/test_protect_reset_stops_encoding_state_at_file_boundary"]
        for location in ("next_group.sv:2:1", "next_group.sv:1:1", "encoding_group.sv:2:1"):
            with self.subTest(location=location), tempfile.TemporaryDirectory() as directory:
                def compiler(command, *, cwd, **unused):
                    self.assertIn("--single-unit", command)
                    self.assertEqual(command[-3:], ["encoding_group.sv", "next_group.sv", fixture.name])
                    source = (cwd / "encoding_group.sv").read_text(encoding="utf-8")
                    if checks.OMITTED not in source:
                        return subprocess.CompletedProcess(command, 0, "", "")
                    return subprocess.CompletedProcess(command, 1, "", f"{location}: error: invalid base64 byte '?'\n")

                with mock.patch.object(checks.subprocess, "run", side_effect=compiler):
                    rows = checks.reset_checks(fixture, Path("slang"), "protect_file_reset_top",
                                               Path(directory), probes)
                self.assertTrue(rows["protect_reset"]["pass"])
                self.assertTrue(rows["named_reset"]["pass"])
                self.assertEqual(rows["state_leaks_without_reset"]["pass"], location == "next_group.sv:2:1")
