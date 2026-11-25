"""Check that a source-local diagnostic carries the information under test."""

from pathlib import Path
import subprocess
import unittest
from unittest import mock

import run_language_diagnostics as diagnostics


def process(code=0, *, stdout="", stderr=""):
    return subprocess.CompletedProcess([], code, stdout, stderr)


class LanguageDiagnosticTests(unittest.TestCase):
    def setUp(self):
        self.compiler = diagnostics.Compiler("icarus", Path("iverilog"), Path("vvp"))

    def test_dpi_diagnostic_accepts_warning_or_error_with_full_migration_information(self):
        test = diagnostics.CASES[diagnostics.DPI]
        detail = "DPI is deprecated; use DPI-C and note that changes to the C code may be required"
        for severity, code in (("warning", 0), ("error", 1)):
            with self.subTest(severity=severity):
                original = process(code, stderr=f"{test.name}:15:10: {severity}: {detail}")
                with mock.patch.object(diagnostics.Compiler, "check",
                                       side_effect=[(original, None), (process(), None)]):
                    self.assertEqual(diagnostics.dpi_case(self.compiler, test)[0], "pass")

    def test_dpi_diagnostic_rejects_missing_c_information_and_wrong_source_line(self):
        test = diagnostics.CASES[diagnostics.DPI]
        partial = f"{test.name}:15:10: warning: DPI is deprecated; replacing it with DPI-C may change behavior"
        wrong_line = (f"{test.name}:16:10: warning: DPI is deprecated; use DPI-C. "
                      "Changes to the C code may be required.")
        for message in (partial, wrong_line):
            with self.subTest(message=message), mock.patch.object(
                    diagnostics.Compiler, "check", side_effect=[(process(stderr=message), None), (process(), None)]):
                self.assertEqual(diagnostics.dpi_case(self.compiler, test)[0], "fail")

    def test_each_uncoerced_port_needs_an_associated_direction_warning(self):
        test = diagnostics.CASES[diagnostics.PORT]
        for message, expected in (
            ("", "fail"),
            ("warning: unused input_backward", "fail"),
            ("warning: output port output_backward remains one-way", "fail"),
            ("warning: input port input_backward remains one-way", "pass"),
        ):
            with self.subTest(message=message):
                run = process(stdout="input outward=z output inward=1\nboth nets had a permitted value\n")
                with mock.patch.object(diagnostics.Compiler, "check", return_value=(process(stderr=message), run)):
                    self.assertEqual(diagnostics.port_case(self.compiler, test)[0], expected)
