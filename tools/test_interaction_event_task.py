"""Independent subscriber queues and Active/NBA payload updates for named events."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_event_task as cases


def interpret(row):
    home, passing, emitter, trigger, count, order, arrival = row
    count = int(count)
    objects = {"a": [], "b": [], "noise": []}
    values = {who: {"hits": [0]*3, "at": [-1]*3, "value": [0]*3, "stamp": 0}
              for who in ("a", "b")}
    first, second = order.split("_")
    emissions = {2: ("noise", 7), 3: (first, 10), 4: (second, 20),
                 8: (first, 30), 10: (second, 40), 16: ("noise", 50),
                 20: (second, 60), 22: (first, 70), 24: ("a", 80), 25: ("b", 90)}
    snapshots = {0: "start", 3: "noise", 4: "pulse1", 5: "pair1", 9: "repeat1",
                 11: "pair2", 19: "rearmed", 21: "round2_first", 23: "round2_pair", 26: "final"}
    arm = 1 if arrival == "early" else 6
    output = []
    for tick in range(27):
        if tick in (arm, 12 + arm):
            for target in ("a", "b"):
                # Event values passed by input and ref select this same object;
                # the actual event variables are never rebound in this model.
                objects[target].extend((target, slot) for slot in range(count))
        if tick in snapshots:
            label = snapshots[tick]
            output.append(f"{label} time={tick}")
            for who, state in values.items():
                for slot in range(3):
                    output.append(f"{label} {who}{slot} hits={state['hits'][slot]} "
                                  f"at={state['at'][slot]} value={state['value'][slot]}")
        if tick not in emissions:
            continue
        target, token = emissions[tick]
        nba = []
        for who, scale in (("a", 1), ("b", 10)):
            values[who]["stamp"] = token * scale
            nba.append(("write", who, token * scale + 1))

        def notify(obj):
            subscribers, objects[obj] = objects[obj], []
            for who, slot in subscribers:
                state = values[who]
                state["hits"][slot] += 1
                state["at"][slot] = tick
                state["value"][slot] = state["stamp"]

        if trigger == "blocking":
            notify(target)
        else:
            nba.append(("trigger", target, None))
        for action, who, value in nba:
            if action == "write":
                values[who]["stamp"] = value
            else:
                notify(who)
    return "\n".join(output) + "\n"


class ScopedEventOracle(unittest.TestCase):
    def test_every_legal_row_matches_independent_subscriber_queue(self):
        self.assertEqual(len(cases.MODEL.rows()), 288)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_all_pairs_triples_and_six_mandatory_witnesses(self):
        rows = cases.MODEL.select()
        self.assertEqual(len(rows), 13)
        targets = {t for row in rows for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 109)
        self.assertEqual(sum(len(t) == 3 for t in targets), 52)
        self.assertTrue(set(cases.MODEL.anchors) <= set(rows))

    def test_snapshot_precedes_same_tick_trigger_and_late_wait_does_not_remember(self):
        early = cases.MODEL.anchors[0]
        late = (*early[:-1], "late")
        text = cases.reference(early)
        self.assertIn("noise a0 hits=0 at=-1 value=0", text)
        self.assertIn("pulse1 a0 hits=1 at=3 value=10", text)
        self.assertIn("pulse1 b0 hits=0 at=-1 value=0", text)
        self.assertIn("pair1 b0 hits=1 at=4 value=200", text)
        text = cases.reference(late)
        self.assertIn("pair1 a0 hits=0 at=-1 value=0", text)
        self.assertIn("repeat1 a0 hits=1 at=8 value=30", text)
        self.assertIn("pair2 b0 hits=1 at=10 value=400", text)

    def test_nba_trigger_observes_queued_payload_and_blocking_observes_old_payload(self):
        row = cases.MODEL.anchors[0]
        nba = (*row[:3], "nba", *row[4:])
        self.assertIn("pair1 a0 hits=1 at=3 value=10", cases.reference(row))
        self.assertIn("pair1 a0 hits=1 at=3 value=11", cases.reference(nba))
        self.assertIn("pair1 b0 hits=1 at=4 value=201", cases.reference(nba))

    def test_every_armed_listener_wakes_and_unused_slots_remain_untouched(self):
        for count in range(1, 4):
            row = (*cases.MODEL.anchors[0][:4], str(count), "a_b", "early")
            text = cases.reference(row)
            for who in ("a", "b"):
                for slot in range(3):
                    hit = 2 if slot < count else 0
                    self.assertIn(f"final {who}{slot} hits={hit} ", text)

    def test_rearming_reverses_source_order_and_later_pulses_do_not_repeat_callbacks(self):
        text = cases.reference(cases.MODEL.anchors[0])
        self.assertIn("repeat1 a0 hits=1 at=3 value=10", text)
        self.assertIn("round2_first a0 hits=1 at=3 value=10", text)
        self.assertIn("round2_first b0 hits=2 at=20 value=600", text)
        self.assertIn("final a0 hits=2 at=22 value=70", text)
        self.assertIn("final b0 hits=2 at=20 value=600", text)

    def test_sources_and_task_arguments_use_the_selected_scope_and_direction(self):
        for row in cases.MODEL.select():
            body = cases.make_case(row).body
            self.assertIn(f"task automatic observe({row[1]} event ev, input int slot)", body)
            self.assertEqual(body.count(".observe("), 4 * int(row[4]))
            self.assertIn(f"{row[0]} event_source;", body)
            if row[0] == "package":
                self.assertIn("observe(event_source::a, 0)", body)
            else:
                self.assertIn("event_source bank_a(), bank_b();", body)
                self.assertIn("observe(bank_b.go, 0)", body)
            self.assertIn(cases.fire(row, "a"), body)
            self.assertIn(cases.fire(row, "b"), body)

    def test_rendered_sources_avoid_handle_assignment_null_wait_and_automatic_nba_targets(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertEqual(case.body.count("join_none"), 2)
            self.assertNotIn("null", case.body)
            self.assertNotIn("#0", case.body)
            self.assertIn("  int stamp;\n  task automatic prepare", case.body)
            self.assertIn("stamp <= token + 1;", case.body)


if __name__ == "__main__":
    unittest.main()
