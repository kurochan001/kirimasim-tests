"""Do not count an output difference from an abnormal process as a detection."""

import contextlib
import io
from pathlib import Path
import subprocess
from types import SimpleNamespace
import unittest
from unittest import mock

import qualify_assertion_wait as qualification
from common import Case
from interaction_cover import Model


class QualificationExitStatus(unittest.TestCase):
    def setUp(self):
        model = Model("fixture", (("a", ("0",)), ("b", ("0",))), lambda row: True)
        self.generator = SimpleNamespace(
            MODEL=model, NAME="fixture", VERSION=1, CHAPTER=9, __file__=__file__,
            make_case=lambda row: Case("test_fixture", "fixture", "9.4.3", "fixture",
                                       "module test_fixture; endmodule", "ok\n"))
        self.parents = {"fixture": ("0", "0")}
        self.faults = (("fixture_fault", "fixture", "endmodule", "/* MUTATED */ endmodule"),)

    def run_fixture(self, returncode):
        def runner(test):
            subprocess.run(["fixture"])
            return (("fail", "output differs: line 1 is 'bad', expected 'ok'")
                    if "MUTATED" in test.read_text() else ("pass", ""))

        with mock.patch.object(subprocess, "run", return_value=subprocess.CompletedProcess(
                ["fixture"], returncode)), contextlib.redirect_stdout(io.StringIO()):
            return qualification.qualify(self.generator, self.parents, self.faults, runner, {})

    def test_crash_or_signal_cannot_be_counted_as_a_detection(self):
        for returncode in (1, -6):
            with self.subTest(returncode=returncode):
                result = self.run_fixture(returncode)
                self.assertFalse(result["all_controls_pass"])
                self.assertFalse(result["all_faults_detected"])
                self.assertEqual(result["faults"][0]["subprocess_returncodes"], [returncode])

    def test_clean_exit_and_observed_difference_are_both_required(self):
        result = self.run_fixture(0)
        self.assertTrue(result["all_controls_pass"])
        self.assertTrue(result["all_faults_detected"])

    def test_exit_observer_is_restored_when_the_runner_raises(self):
        original = subprocess.run

        def runner(test):
            raise RuntimeError("fixture interrupted")

        with self.assertRaisesRegex(RuntimeError, "fixture interrupted"):
            qualification.qualify(self.generator, self.parents, self.faults, runner, {})
        self.assertIs(subprocess.run, original)


if __name__ == "__main__":
    unittest.main()
