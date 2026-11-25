import unittest

from run_ghost_checker_initialization import evaluate


class CheckerInitializationTests(unittest.TestCase):
    def setUp(self):
        self.samples = [
            {"active": "1", "inactive": "2", "const": "3", "control": "4",
             "initializer_preserved": True},
            {"active": "2", "inactive": "3", "const": "4", "control": "5",
             "initializer_preserved": True},
        ]

    def test_accepts_observed_variation_for_each_kind(self):
        self.assertEqual(evaluate(self.samples), ("pass", ""))

    def test_identifies_single_invariant_kind(self):
        self.samples[1]["inactive"] = self.samples[0]["inactive"]
        self.assertEqual(evaluate(self.samples),
                         ("fail", "invariant checker initialization across seeds: inactive"))

    def test_checks_that_seed_affected_the_control(self):
        self.samples[1]["control"] = self.samples[0]["control"]
        self.assertEqual(evaluate(self.samples),
                         ("fail", "the ordinary random control was invariant across seeds"))

    def test_rejects_changes_to_the_initializer(self):
        self.samples[1]["initializer_preserved"] = False
        self.assertEqual(evaluate(self.samples), ("fail", "explicit initializer changed"))


if __name__ == "__main__":
    unittest.main()
