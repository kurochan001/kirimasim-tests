"""Check that default-setting evidence is conditional on the selected mode."""

from pathlib import Path
import subprocess
import unittest
from unittest import mock

import run_language_defaults as defaults


class LanguageDefaultsTests(unittest.TestCase):
    def test_time_unit_and_precision_are_checked_independently_for_each_setting(self):
        test = defaults.CASES["ghost"][defaults.TIMESCALE]
        scale_steps = {"1ns/100ps": "unit=1.000 absolute=1.000 fraction=0.300",
                       "10ns/10ps": "unit=1.000 absolute=0.100 fraction=0.300"}

        def simulate(command, work):
            self.assertNotIn("--timescale-override", command)
            setting = command[command.index("--timescale") + 1]
            return subprocess.CompletedProcess(command, 0, scale_steps[setting] + "\ndefault timing exercised\n", "")

        with mock.patch.object(defaults, "invoke", side_effect=simulate):
            observed = defaults.timescale_checks("ghost", Path("ghost"), test)
        self.assertTrue(observed["1ns/100ps"]["pass"])
        self.assertFalse(observed["10ns/10ps"]["pass"])

    def test_keyword_rejection_must_name_the_declaration_line(self):
        test = defaults.CASES["icarus"][defaults.KEYWORDS]
        original = test.read_text(encoding="utf-8")
        line = original.count("\n", 0, original.index(defaults.LEGACY_DECLARATION)) + 1

        def compile_or_run(command, work):
            if command[0] == "vvp":
                return subprocess.CompletedProcess(command, 0, "selected keyword set value=1\n", "")
            source = (Path(work) / test.name).read_text(encoding="utf-8")
            legacy = defaults.LEGACY_DECLARATION in source
            if legacy == ("-g2005" in command):
                return subprocess.CompletedProcess(command, 0, "", "")
            diagnostic_line = line if legacy else line + 1
            return subprocess.CompletedProcess(command, 2, "", f"{test.name}:{diagnostic_line}: syntax error\n")

        with mock.patch.object(defaults, "invoke", side_effect=compile_or_run):
            observed = defaults.keyword_checks(Path("iverilog"), Path("vvp"), test)
        self.assertTrue(observed["identifier_2005"]["pass"])
        self.assertTrue(observed["identifier_2012"]["pass"])
        self.assertFalse(observed["type_2005"]["pass"])
        self.assertTrue(observed["type_2012"]["pass"])
