"""A crash or compile failure is not a detected class-method fault."""

import unittest
from qualify_class_method import qualifies


class QualificationExitStatus(unittest.TestCase):
    def test_only_normal_output_difference_counts_as_detected(self):
        good = dict(status="fail", reason="output differs: line 3", subprocess_returncodes=[0, 0, 0])
        self.assertTrue(qualifies(good))
        for codes in ([], [1], [0, -11, 0], [0, 0, 2]):
            self.assertFalse(qualifies(dict(good, subprocess_returncodes=codes)))
        for reason in ("compile failed", "unsupported", "timeout"):
            self.assertFalse(qualifies(dict(good, reason=reason)))

    def test_controls_require_pass_and_normal_exit(self):
        good = dict(status="pass", reason="", subprocess_returncodes=[0, 0, 0])
        self.assertTrue(qualifies(good, True))
        self.assertFalse(qualifies(dict(good, subprocess_returncodes=[0, -6, 0]), True))
        self.assertFalse(qualifies(dict(good, status="fail"), True))


if __name__ == "__main__":
    unittest.main()
