"""Qualify the event-OR oracle with closed-form per-phase event counts."""

from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_iff as cases


def definitely_nonzero(bits):
    # The minimum possible numeric value is positive only with a known one.
    return int(bits.translate(str.maketrans("xz", "00")), 2) > 0


def snapshots(text):
    return re.findall(r"^p(\d+)_(guards|left_up|right_up|left_down|right_down|left_repeat) "
                      r"gates=([01xz]+),([01xz]+) raw=(\d+),(\d+) hit=(\d+)$", text, re.M)


class EventOrOracle(unittest.TestCase):
    def test_every_legal_case_matches_closed_form_counts(self):
        progress = {"change": ((0, 1, 1, 2, 2, 2), (0, 0, 1, 1, 2, 2)),
                    "posedge": ((0, 1, 1, 1, 1, 1), (0, 0, 1, 1, 1, 1)),
                    "negedge": ((0, 0, 0, 1, 1, 1), (0, 0, 0, 0, 1, 1))}
        named = ((0, 1, 1, 2, 2, 3), (0, 0, 1, 1, 2, 2))
        stages = ("guards", "left_up", "right_up", "left_down", "right_down", "left_repeat")
        for row in cases.MODEL.rows():
            source, edge, filter_ = row[1:4]
            left = named[0] if source == "named" else progress[edge][0]
            right = named[1] if source in ("named", "mixed") else progress[edge][1]
            accepted_before = 0
            records = snapshots(cases.make_case(row).expected)
            self.assertEqual(len(records), 36 if row[4] == "known" else 60)
            for phase, stage, ga, gb, a, b, hit in records:
                i, j = int(phase), stages.index(stage)
                allowed_a = filter_ == "second" or definitely_nonzero(ga)
                allowed_b = filter_ == "first" or definitely_nonzero(gb)
                self.assertEqual((int(a), int(b)), (i * left[-1] + left[j],
                                                  i * right[-1] + right[j]), row)
                self.assertEqual(int(hit), accepted_before +
                                 allowed_a * left[j] + allowed_b * right[j], row)
                if stage == "left_repeat":
                    accepted_before = int(hit)

    def test_wide_unknown_guards_use_logical_truth_not_equality_to_one(self):
        for bits, expected in (("0", False), ("x", False), ("z", False), ("1", True),
                               ("x" * 33, False), ("z" * 33, False),
                               ("1" + "x" * 32, True), ("z" * 32 + "1", True)):
            self.assertEqual(definitely_nonzero(bits), expected)
        row = ("or", "signals", "change", "both", "mixed", "blocking")
        records = {f"p{p}_{s}": int(h) for p, s, _, _, _, _, h in
                   snapshots(cases.make_case(row).expected)}
        self.assertEqual(records['p4_left_repeat'] - records['p4_guards'], 2)
        self.assertEqual(records['p5_left_repeat'] - records['p5_guards'], 2)
        self.assertEqual(records['p6_left_repeat'] - records['p6_guards'], 0)

    def test_iff_precedence_keeps_the_other_term_unguarded(self):
        for filter_, delta in (("both", 0), ("first", 2), ("second", 2)):
            row = ("comma", "signals", "change", filter_, "xz", "blocking")
            records = {f"p{p}_{s}": int(h) for p, s, _, _, _, _, h in
                       snapshots(cases.make_case(row).expected)}
            self.assertEqual(records['p6_left_repeat'] - records['p6_guards'], delta)

    def test_signal_nba_is_observed_before_commit_and_named_repeats_are_events(self):
        signal = ("or", "signals", "change", "both", "known", "nba")
        blocking = (*signal[:-1], "blocking")
        self.assertIn('p0_left_up_scheduled=0,0\n', cases.make_case(signal).expected)
        self.assertIn('p0_left_up_scheduled=1,0\n', cases.make_case(blocking).expected)
        row = ("or", "named", "change", "both", "known", "nba")
        text = cases.make_case(row).expected
        self.assertIn('p0_left_repeat gates=0,0 raw=3,2 hit=0\n', text)
        self.assertIn('p3_left_repeat gates=1,1 raw=12,8 hit=10\n', text)


if __name__ == "__main__":
    unittest.main()
