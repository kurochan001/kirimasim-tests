"""Independent event timelines and list operations for the two new crosses."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_assertion as assertion
import interaction_wait as waiting


def stored(bits, state):
    return "".join("0" if state == "bit" and b in "xz" else b for b in bits)


def boolean(bits, expression):
    if expression == "reduce_or":
        return "1" if any(b == "1" for b in bits) else "0" if all(b == "0" for b in bits) else "x"
    if expression == "case_equal":
        return str(int(all(b == "0" for b in bits)))
    comparisons = ["1" if b == "0" else "0" if b == "1" else "x" for b in bits]
    return "0" if "0" in comparisons else "x" if "x" in comparisons else "1"


def assertion_simulation(row):
    lines, passed, failed = [], 0, 0
    for tag, before, raw in assertion.phases(row):
        current, incoming = stored(before, row[1]), stored(raw, row[1])
        lines.append(f"{tag} before={current} source={raw}")
        if row[6] == "before":
            current = incoming
        sampled = current
        pending = []
        if row[6] == "edge":
            if row[5] == "nba":
                pending.append(incoming)
            else:
                current = incoming
        for update in pending:
            current = update
        predicate = boolean(sampled, row[3])
        if predicate == "1":
            passed += 1
        else:
            failed += 1
        action = current
        if row[6] == "after":
            current = incoming
        lines.append(f"{tag} pass={passed} fail={failed} predicate={predicate} "
                     f"sampled={sampled} at_action={action} final={current}")
    return "\n".join(lines) + "\n"


def wait_setup(row, guard, raw):
    marker = stored(raw, row[1])
    other = ("".join(str(1 - int(b)) for b in marker) if set(marker) <= set("01")
             else "1" * len(marker))
    initial = [] if row[4] == "create" else [other]
    if row[4] == "shrink":
        initial.append(marker)
    elif row[4] in ("clear", "replace"):
        initial.append(guard)
    final = initial.copy()
    if row[4] == "create":
        final.extend([marker, guard])
    elif row[4] == "grow":
        final.insert(0, marker)
    elif row[4] == "shrink":
        final.pop(0)
    elif row[4] == "clear":
        final.clear()
    else:
        final[0] = marker
    return marker, initial, final


def matches(values, marker, target, condition):
    if condition == "size":
        return len(values) == target
    same_element = bool(values) and values[0] == marker
    return same_element and (condition != "both" or len(values) == target)


def wait_simulation(row):
    lines = []
    for tag, guard, raw in waiting.phases(row):
        marker, initial, final = wait_setup(row, guard, raw)
        current = final.copy() if row[6] == "ready" else initial.copy()
        wake, delta, saved = 0, -1, []
        for tick in (0, 1, 3):
            if tick == 1:
                noise = final.copy()
                assert noise is not current
            if tick == 3 and row[6] == "waiting":
                current = final.copy()
            if not wake and matches(current, marker, len(final), row[5]):
                wake, delta, saved = 1, tick, current.copy()
            if tick == 1:
                checkpoint = f"{tag} noise wake={wake} dt={delta} size={len(current)}"
        lines += [f"{tag} start={len(initial)} raw={raw} marker={marker}", checkpoint,
                  f"{tag} done wake={wake} dt={delta} captured={len(saved)} size={len(current)}"]
        lines += [f"{tag} live{i}={v}" for i, v in enumerate(current)]
        lines += [f"{tag} saved{i}={v}" for i, v in enumerate(saved)]
    return "\n".join(lines) + "\n"


class AssertionVisibility(unittest.TestCase):
    def test_all_2592_rows_match_the_independent_event_timeline(self):
        for row in assertion.MODEL.rows():
            self.assertEqual(assertion.reference(row), assertion_simulation(row), row)

    def test_before_edge_and_after_have_distinct_sample_action_final_relations(self):
        for timing, expected in [("before", ("1", "1", "1")), ("edge", ("0", "1", "1")),
                                 ("after", ("0", "0", "1"))]:
            row = ("1", "logic", "known", "equal", "posedge", "nba", timing, "module")
            fields = dict(t.split("=") for t in assertion.reference(row).splitlines()[1].split()[1:])
            self.assertEqual(tuple(fields[k] for k in ("sampled", "at_action", "final")), expected)

    def test_logical_and_case_equality_preserve_unknown_predicate_difference(self):
        self.assertEqual(assertion.predicate("x", "equal"), "x")
        self.assertEqual(assertion.predicate("x", "case_equal"), "0")
        self.assertEqual(assertion.predicate("1x", "equal"), "0")
        self.assertEqual(assertion.predicate("z0", "reduce_or"), "x")

    def test_every_selected_row_has_known_pass_and_fail_controls(self):
        for row in assertion.MODEL.select():
            lines = assertion.reference(row).splitlines()
            last_known = dict(t.split("=") for t in lines[5].split()[1:])
            self.assertGreater(int(last_known["pass"]), 0)
            self.assertGreater(int(last_known["fail"]), 0)

    def test_bit_unknown_conversion_precedes_sampling(self):
        row = ("1", "bit", "x", "equal", "posedge", "nba", "edge", "module")
        self.assertIn("predicate=1 sampled=0 at_action=1 final=1", assertion.reference(row))
        self.assertIn("predicate=x sampled=x at_action=1 final=1",
                      assertion.reference((row[0], "logic", *row[2:])))

    def test_selection_covers_targets_and_retains_unsupported_paths(self):
        selected = assertion.MODEL.select()
        self.assertEqual(set(t for r in selected for t in assertion.MODEL.targets(r)),
                         assertion.MODEL.universe())
        self.assertTrue(set(assertion.MODEL.anchors) <= set(selected))


class ContainerWaiting(unittest.TestCase):
    def test_all_1440_rows_match_list_operations_and_event_resumption(self):
        for row in waiting.MODEL.rows():
            self.assertEqual(waiting.reference(row), wait_simulation(row), row)

    def test_element_waits_never_access_an_empty_container(self):
        for row in waiting.MODEL.rows():
            for _, guard, raw in waiting.phases(row):
                marker, initial, final = wait_setup(row, guard, raw)
                self.assertFalse(matches(initial, marker, len(final), row[5]))
                self.assertTrue(matches(final, marker, len(final), row[5]))
                if row[5] != "size":
                    self.assertTrue(initial and final)

    def test_same_size_replacement_requires_an_element_sensitive_predicate(self):
        self.assertFalse(waiting.allowed(("1", "bit", "known", "queue", "replace", "size", "waiting")))
        row = ("129", "logic", "z", "dynamic", "replace", "both", "waiting")
        self.assertIn("noise wake=0 dt=-1 size=2", waiting.reference(row))
        self.assertIn("done wake=1 dt=3 captured=2 size=2", waiting.reference(row))

    def test_already_true_wait_does_not_wait_for_an_additional_notification(self):
        row = ("33", "bit", "x", "dynamic", "create", "size", "ready")
        self.assertIn("noise wake=1 dt=0 size=2", waiting.reference(row))
        self.assertIn("done wake=1 dt=0 captured=2 size=2", waiting.reference(row))

    def test_clear_and_pop_preserve_their_different_result_shapes(self):
        clear = ("1", "logic", "known", "queue", "clear", "size", "waiting")
        pop = (*clear[:4], "shrink", "element", "waiting")
        self.assertIn("captured=0 size=0", waiting.reference(clear))
        self.assertIn("captured=1 size=1", waiting.reference(pop))

    def test_selection_covers_every_target_and_anchor(self):
        selected = waiting.MODEL.select()
        self.assertEqual(set(t for r in selected for t in waiting.MODEL.targets(r)),
                         waiting.MODEL.universe())
        self.assertTrue(set(waiting.MODEL.anchors) <= set(selected))


if __name__ == "__main__":
    unittest.main()
