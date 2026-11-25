"""Test the preprocessor witnesses and their control conditions."""

import unittest

import run_preprocessor_effects as checker


class PreprocessorEffectTests(unittest.TestCase):
    def test_manual_line_alone_does_not_prove_automatic_emission(self):
        paths = checker.line_records(
            '`line 1 "payload.svh" 1\n`line 3 "main.sv" 2\n`line 700 "reviewed_origin.sv" 0\n')
        run = {"preprocessor_exit": 0, "compile_exit": 0, "simulation_exit": 0,
               "simulation_matches": True}
        emitted = {**run, "line_records": paths}
        omitted = {**run, "line_records": []}
        self.assertTrue(checker.line_is_qualified({"emitted": emitted, "omitted": omitted}, "main.sv"))
        self.assertFalse(checker.line_is_qualified({
            "emitted": {**emitted, "line_records": paths[-1:]}, "omitted": omitted}, "main.sv"))
        self.assertFalse(checker.line_is_qualified({
            "emitted": emitted, "omitted": {**omitted, "simulation_exit": -9}}, "main.sv"))
        with self.assertRaisesRegex(ValueError, "malformed"):
            checker.line_records('`line 7 "bad.sv" 3')

    def test_undef_diagnostic_is_optional_and_local(self):
        actual = checker.undef_warnings(
            "%Warning-MACRO: main.sv:8:2: cannot undef VT_NEVER_DEFINED_MACRO")
        self.assertEqual(actual, [{"file": "main.sv", "line": 8, "missing_macro_named": True}])
        clean = {"compile_exit": 0, "simulation_exit": 0, "simulation_matches": True, "undef_warnings": []}
        for site, warnings, expected in ((8, [], True), (8, actual, True), (9, actual, False)):
            with self.subTest(site=site, warnings=warnings):
                trials = {"control": clean, "unknown": {**clean, "undef_warnings": warnings}}
                self.assertEqual(checker.undef_is_qualified(trials, "main.sv", site), expected)
        warned_control = {**clean, "undef_warnings": actual}
        self.assertFalse(checker.undef_is_qualified({"control": warned_control, "unknown": clean},
                                                    "main.sv", 8))
