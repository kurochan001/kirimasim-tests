"""Check parsing of directed transitions without conflating state totals."""

import unittest

import run_fsm_transition_coverage as checker


def report(*sections):
    return "\n".join([checker.HEADER, *sections, checker.FOOTER])


class FsmTransitionReportTests(unittest.TestCase):
    def test_parse_direction_repetition_and_distinct_instances(self):
        output = report(
            "FSM: top.forward.state (pragma enum modes)",
            "  State Coverage: 100.0%",
            "  States (2/2 covered):",
            "    S0: 2 hits",
            "  Transitions (2/2 covered):",
            "    S0 -> S1: 3 hits",
            "    S1 -> S0: 1 hit",
            "FSM: top.reverse.state (pragma enum modes)",
            "  Transitions (1/2 covered):",
            "    S0 -> S1: 0 hits",
            "    S1 -> S0: 2 hits",
        )
        self.assertEqual(checker.report_edges(output, "top"), [
            "forward.state S0->S1 3", "forward.state S1->S0 1", "reverse.state S1->S0 2",
        ])

    def test_do_not_accept_state_only_or_incomplete_transition_totals(self):
        for section in (["States (1/2 covered):", "S0: 1 hit"],
                        ["Transitions (2/2 covered):", "S0 -> S1: 1 hit"]):
            with self.subTest(section=section), self.assertRaisesRegex(ValueError, "transition total"):
                checker.report_edges(report("FSM: top.state", *section), "top")

    def test_do_not_silently_overwrite_duplicate_edges(self):
        with self.assertRaisesRegex(ValueError, "duplicate transition"):
            checker.report_edges(report("FSM: top.state", "Transitions (1/2 covered):",
                                        "S0 -> S1: 1 hit", "S0 -> S1: 2 hits"), "top")
