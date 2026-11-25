"""Verify that the optional outcomes still require working controls."""

import subprocess
import unittest

import run_optional_lexical as lexical


class OptionalLexicalTests(unittest.TestCase):
    def test_variants_change_only_the_selected_literal(self):
        for case, fixture, expected_control, expected_trial in (
            (lexical.OCTAL, b'localparam p = "L\\376R";',
             b'localparam p = "L\\376R";', b'localparam p = "L\\400R";'),
            (lexical.RAW, b'localparam p = "L\x0bR";',
             b'localparam p = "L\\vR";', b'localparam p = "L\x0bR";'),
        ):
            with self.subTest(case=case):
                control, trial, site = lexical.source_variants(case, b"module m;\n" + fixture)
                self.assertEqual((control, trial, site),
                                 (b"module m;\n" + expected_control, b"module m;\n" + expected_trial, 2))

    def test_octal_acceptance_does_not_prescribe_the_overflow_value(self):
        expected = ["in_range=4cff52", "variant=4cfe52"]
        control = {"exit": 0, "errors": [], "values": expected}
        for overflow in ("4c0052", "0"):
            with self.subTest(overflow=overflow):
                trial = {"exit": 0, "errors": [], "values": [expected[0], "variant=" + overflow]}
                self.assertTrue(lexical.assess_ghost(
                    lexical.OCTAL, {"control": control, "trial": trial}, expected, 2))

    def test_optional_error_requires_the_expected_site_and_a_working_control(self):
        expected = ["in_range=4cff52", "variant=4cfe52"]
        control = {"exit": 0, "errors": [], "values": expected}
        for code, line, diagnostic, passed in (
            (1, 2, "OctalEscapeCodeTooBig", True),
            (1, 3, "OctalEscapeCodeTooBig", False),
            (1, 2, "syntax error", False),
            (-6, 2, "OctalEscapeCodeTooBig", False),
        ):
            with self.subTest(code=code, line=line, diagnostic=diagnostic):
                trial = lexical.ghost_observation(
                    subprocess.CompletedProcess([], code, "", f"octal.sv:{line}:12: error: {diagnostic}"),
                    "octal.sv")
                self.assertEqual(lexical.assess_ghost(
                    lexical.OCTAL, {"control": control, "trial": trial}, expected, 2), passed)
                self.assertFalse(lexical.assess_ghost(
                    lexical.OCTAL, {"control": {**control, "values": []}, "trial": trial}, expected, 2))

    def test_raw_acceptance_must_preserve_the_byte(self):
        expected = ["raw=4c0b52 escaped=4c0b52"]
        control = {"exit": 0, "errors": [], "values": expected}
        trial = {"exit": 0, "errors": [], "values": ["raw=4c0052 escaped=4c0b52"]}
        self.assertTrue(lexical.assess_ghost(lexical.RAW, {"control": control, "trial": control}, expected, 2))
        self.assertFalse(lexical.assess_ghost(lexical.RAW, {"control": control, "trial": trial}, expected, 2))
