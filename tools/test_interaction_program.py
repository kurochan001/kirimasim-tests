"""Independent event queue for program ownership, cancellation and global finish."""

import heapq
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_program as cases


def simulate(row):
    finish, initials, waiting, topology, progress, spawn, keepers = row
    state = dict.fromkeys(("entered", "prepared", "short_done", "parent_done", "resumed",
                          "primary_done", "secondary_done", "checkpoint", "escaped", "probe_escape",
                          "task_returned", "caller_returned", "released", "survivor", "keeper_a", "keeper_b"), 0)
    alive = {"target", "a"} | ({"b"} if keepers == "two" else set())
    outstanding = 2 if initials == "two" else 1
    pending, serial, lines = [], 0, []

    def schedule(time, owner, field):
        nonlocal serial
        heapq.heappush(pending, (time, serial, owner, field))
        serial += 1

    def observe(label, time):
        lines.append(f"{label} t={time} " + " ".join(f"{k}={v}" for k, v in state.items()))

    schedule(0, "target", "entered")
    schedule(1, "target", "short_done")
    if progress == "partial":
        schedule(1, "target", "prepared")
    if topology == "nested":
        schedule(2, "target", "parent_done")
    schedule(1 if spawn == "any" else 0, "target", "resume")
    schedule(4, "target", "primary_end")
    if initials == "two":
        schedule(6, "target", "secondary_end")
    schedule(5, "target", "checkpoint")
    schedule(7, "target", "probe_escape")
    schedule(7 + (progress == "partial") if waiting == "delay" else 8, "target", "escaped")
    schedule(8, "module", "released")
    schedule(7 if waiting == "delay" else 8, "a", "survivor")
    schedule(9, "module", "observe")
    schedule(12, "a", "keeper_end")
    if keepers == "two":
        schedule(13, "module", "between")
        schedule(15, "b", "keeper_end")
    schedule(20, "module", "sentinel")
    while pending:
        time, _, owner, action = heapq.heappop(pending)
        if owner != "module" and owner not in alive:
            continue
        if action in ("observe", "between"):
            observe(action, time)
        elif action == "resume":
            state["resumed"] = time
        elif action in ("primary_end", "secondary_end"):
            state["primary_done" if action == "primary_end" else "secondary_done"] = 1
            outstanding -= 1
            if outstanding == 0 or (action == "primary_end" and finish != "natural"):
                alive.remove(owner)
        elif action == "keeper_end":
            state["keeper_a" if owner == "a" else "keeper_b"] = 1
            alive.remove(owner)
        elif action == "sentinel":
            raise AssertionError("module survived all programs")
        else:
            state[action] += 1
        if not alive:
            observe("final", time)
            break
    return "\n".join(lines) + "\n"


class ProgramShutdown(unittest.TestCase):
    def test_all_288_rows_match_independent_owned_event_queue(self):
        self.assertEqual(len(cases.MODEL.rows()), 288)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), simulate(row), row)

    def test_all_pair_triple_and_mandatory_targets_survive_selection(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 18)
        covered = {target for row in selected for target in cases.MODEL.targets(row)}
        self.assertEqual(covered, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in covered), 109)
        self.assertEqual(sum(len(t) == 3 for t in covered), 38)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_natural_completion_waits_for_every_initial_before_cancelling(self):
        one = cases.MODEL.anchors[0]
        two = (one[0], "two", *one[2:])
        self.assertIn("secondary_done=0 checkpoint=0 escaped=0", simulate(one))
        self.assertIn("secondary_done=1 checkpoint=1 escaped=0", simulate(two))

    def test_exit_direct_and_in_task_cancel_other_initials_and_do_not_return(self):
        row = cases.MODEL.anchors[1]
        for mode in ("exit", "task"):
            text = simulate((mode, *row[1:]))
            self.assertIn("secondary_done=0 checkpoint=0 escaped=0", text)
            self.assertIn("task_returned=0 caller_returned=0", text)

    def test_independent_programs_keep_simulation_alive_until_last_completion(self):
        for row in cases.MODEL.anchors:
            text = simulate(row)
            self.assertIn("observe t=9", text)
            if row[-1] == "two":
                self.assertIn("between t=13", text)
                self.assertIn("final t=15", text)
                self.assertIn("keeper_a=1 keeper_b=0", text)
            else:
                self.assertNotIn("between", text)
                self.assertIn("final t=12", text)

    def test_wait_progress_nesting_and_join_resume_are_observed_without_late_writes(self):
        for row in cases.MODEL.rows():
            text = simulate(row)
            self.assertIn(f"prepared={int(row[4] == 'partial')}", text)
            self.assertIn(f"parent_done={int(row[3] == 'nested')}", text)
            self.assertIn(f"resumed={int(row[5] == 'any')}", text)
            self.assertIn("escaped=0 probe_escape=0", text)
            self.assertIn("released=1 survivor=1", text)

    def test_sources_keep_implicit_finish_and_single_final_observer(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertNotIn("$finish", case.body)
            self.assertNotIn("disable", case.body)
            self.assertEqual(case.body.count("final begin"), 1)
            self.assertIn("#5 checkpoint++;", case.body)
            self.assertIn("#20", case.body)


if __name__ == "__main__":
    unittest.main()
