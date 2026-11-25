"""Check that option-file evidence requires both successful invocations."""

import unittest

import run_vpi_vlog_option_files as checker


class VlogOptionFileTests(unittest.TestCase):
    def test_both_invocations_must_match(self):
        completed = {"exit": 0, "completed": True, "matches": True}
        both = {"plugin_build_exit": 0, "control": completed, "nested": completed}
        self.assertEqual(checker.assess(both), ("pass", ""))
        for mode in ("control", "nested"):
            for changed in ({"exit": -11}, {"completed": False}, {"matches": False, "observed": []}):
                with self.subTest(mode=mode, changed=changed):
                    run = {**completed, **changed}
                    self.assertEqual(checker.assess({**both, mode: run})[0], "fail")

    def test_a_flat_filename_is_reported_as_a_representation_difference(self):
        observation = {"plugin_build_exit": 0,
                       "control": {"exit": 0, "completed": True, "matches": True},
                       "nested": {"exit": 0, "completed": True, "matches": False,
                                  "observed": ["options: flat outer filename", "applied=17,29,31"]}}
        self.assertEqual(checker.assess(observation), ("fail", "argv after -f is the filename string"))
