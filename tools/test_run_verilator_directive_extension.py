"""Check the source-local controls for tool-defined directives."""

import unittest

import run_verilator_directive_extension as checker


def rejected(source):
    return {"exit": 1, "source": source, "expected_line": 19, "unrelated_errors": 0,
            "truncations": [{"severity": "error", "file": source, "line": 19}]}


class DirectiveExtensionTests(unittest.TestCase):
    def setUp(self):
        self.trials = {
            "control": rejected("case.sv"),
            "other_file": rejected("other_source.sv"),
            "selected": {"exit": 0, "truncations": [], "unrelated_errors": 0,
                         "simulation_exit": 0, "simulation_matches": True},
        }

    def test_requires_the_same_error_at_both_control_sites(self):
        self.assertEqual(checker.assess(self.trials), ("pass", ""))
        for trial, change in (("control", {"exit": -9}),
                              ("other_file", {"exit": 0}),
                              ("other_file", {"truncations": rejected("case.sv")["truncations"]})):
            with self.subTest(trial=trial, change=change):
                modified = {**self.trials, trial: {**self.trials[trial], **change}}
                self.assertEqual(checker.assess(modified)[0], "fail")

    def test_rejects_a_warning_at_the_configured_site(self):
        found, other = checker.diagnostics("%Warning-WIDTHTRUNC: case.sv:19:21: truncation")
        self.assertEqual(found, [{"severity": "warning", "file": "case.sv", "line": 19}])
        self.assertEqual(other, 0)
        self.trials["selected"]["truncations"] = found
        self.assertEqual(checker.assess(self.trials)[0], "fail")

    def test_requires_the_configured_source_to_run(self):
        self.trials["selected"]["simulation_exit"] = -9
        self.assertEqual(checker.assess(self.trials)[0], "fail")
