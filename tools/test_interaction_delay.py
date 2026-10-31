"""Independent heap scheduler and encoded four-state words for delay verification."""

import heapq
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_delay as cases


def interpret(row):
    width, state, value, profile, pulse, operation = row
    width = int(width)
    zero, one = (0,) * width, (1,) * width
    alternating = tuple(1 - i % 2 for i in range(width))
    opposite = tuple(1 - bit for bit in alternating)
    commands = [(0, zero)]
    cursor = 2
    for word in (one, zero, alternating, opposite, zero):
        commands.append((cursor, word))
        cursor += 12
    span = {"short": 1, "long": 10}[pulse]
    commands.extend(((cursor, one), (cursor + span, zero)))
    cursor += span + 12
    commands.extend(((cursor, one), (cursor + 1, opposite), (cursor + 13, zero)))
    cursor += 25
    if value != "known":
        unknown = (2 if value == "x" else 3,) * width
        mixed = list(alternating)
        for index in {0, width // 2, width - 1}:
            mixed[index] = unknown[0]
        for word in (unknown, zero, tuple(mixed), zero):
            commands.append((cursor, word))
            cursor += 12
        commands.extend(((cursor, unknown), (cursor + span, zero)))
        cursor += span + 12
    end = cursor + 2

    def convert(word):
        return tuple(bit if bit < 2 else 0 for bit in word) if state == "bit" else word

    def evaluate(word):
        return word if operation == "direct" else tuple((1, 0, 2, 2)[bit] for bit in word)

    # A separate from/to table represents scalar delay semantics. For vectors,
    # classification is on the complete new word, never independently per bit.
    rise, fall, turnoff = {"one": (5, 5, 5), "two": (7, 3, 3), "three": (7, 5, 2)}[profile]
    table = {(old, new): (fall, rise, min(rise, fall, turnoff), turnoff)[new]
             for old in range(4) for new in range(4) if old != new}

    def delay(old, new):
        if width == 1:
            return table[old[0], new[0]]
        if all(bit == 0 for bit in new):
            return fall
        if all(bit == 3 for bit in new):
            return turnoff
        return rise

    raw, source = zero, convert(zero)
    rhs = output = evaluate(source)
    heap = [(at, 1, seq, "drive", word) for seq, (at, word) in enumerate(commands)]
    heapq.heapify(heap)
    sequence, generation, due = len(heap), 0, None
    changes, last, collisions = 0, -1, []
    result = []
    driven_ticks = {at for at, _ in commands}
    for tick in range(end + 1):
        if tick in driven_ticks and due == tick:
            collisions.append(tick)
        while heap and heap[0][0] == tick:
            _, _, _, action, data = heapq.heappop(heap)
            if action == "commit":
                token, word = data
                if token == generation:
                    output = word
                    changes += 1
                    last, due = tick, None
                continue
            raw, source = data, convert(data)
            new = evaluate(source)
            if new == rhs:
                continue
            rhs = new
            generation += 1
            due = None
            if new != output:
                due = tick + delay(output, new)
                sequence += 1
                heapq.heappush(heap, (due, 0, sequence, "commit", (generation, new)))
        text = lambda word: "".join("01xz"[bit] for bit in word)
        result.append(f"tick={tick} raw={text(raw)} source={text(source)} rhs={text(rhs)} "
                      f"out={text(output)} changes={changes} last={last}")
    return "\n".join(result) + "\n", collisions


def frames(row):
    return [dict(field.split("=", 1) for field in line.split())
            for line in cases.reference(row).splitlines()]


class ContinuousDelayOracle(unittest.TestCase):
    def test_all_504_rows_match_independent_heap_and_avoid_input_output_ties(self):
        self.assertEqual(len(cases.MODEL.rows()), 504)
        for row in cases.MODEL.rows():
            expected, collisions = interpret(row)
            self.assertEqual(cases.reference(row), expected, row)
            self.assertEqual(collisions, [], row)

    def test_selection_keeps_all_pairs_triples_and_seven_mandatory_witnesses(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 63)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 141)
        self.assertEqual(sum(len(t) == 3 for t in targets), 129)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_scalar_x_uses_minimum_but_vector_x_uses_rise_delay(self):
        scalar = ("1", "logic", "x", "three", "short", "direct")
        vector = ("2", *scalar[1:])
        sf, vf = frames(scalar), frames(vector)
        start = next(i for i, f in enumerate(sf) if "x" in f["raw"])
        self.assertEqual(sf[start + 1]["out"], "0")
        self.assertEqual(sf[start + 2]["out"], "x")
        self.assertEqual(vf[start + 2]["out"], "00")
        self.assertEqual(vf[start + 7]["out"], "xx")

    def test_short_pulse_is_rejected_and_long_pulse_arrives_with_rise_and_fall(self):
        base = ("2", "logic", "known", "two")
        short = frames((*base, "short", "direct"))
        long = frames((*base, "long", "direct"))
        self.assertTrue(all(f["out"] == "00" for f in short[62:74]))
        self.assertEqual(long[68]["out"], "00")
        self.assertEqual(long[69]["out"], "11")
        self.assertEqual(long[74]["out"], "11")
        self.assertEqual(long[75]["out"], "00")

    def test_bit_storage_converts_unknowns_before_inversion_and_delay_selection(self):
        row = ("33", "bit", "z", "three", "short", "invert")
        data = frames(row)
        at = next(i for i, f in enumerate(data) if set(f["raw"]) == {"z"})
        self.assertEqual(data[at]["source"], "0" * 33)
        self.assertEqual(data[at]["rhs"], "1" * 33)
        self.assertEqual(data[at + 10]["changes"], data[at]["changes"])

    def test_replacement_cancels_old_deadline_and_schedules_from_current_output(self):
        data = frames(("2", "logic", "known", "two", "short", "direct"))
        self.assertEqual(data[82]["out"], "00")  # old ones request must not arrive
        self.assertEqual(data[83]["out"], "01")
        self.assertEqual(data[83]["last"], "83")

    def test_scalar_delay_table_and_implicit_turnoff_match_all_profiles(self):
        for profile, delays in (("one", (5, 5, 5, 5)), ("two", (3, 7, 3, 3)),
                                ("three", (5, 7, 2, 2))):
            row = ("1", "logic", "z", profile, "short", "direct")
            self.assertEqual(tuple(cases.propagation(row, bit) for bit in "01xz"), delays)
        row = ("33", "logic", "z", "three", "short", "direct")
        self.assertEqual(cases.propagation(row, "z" * 33), 2)
        self.assertEqual(cases.propagation(row, "0" * 32 + "z"), 7)
        self.assertEqual(cases.propagation(row, "0" * 33), 5)

    def test_rendered_sources_use_scalar_or_whole_vector_and_postponed_counters(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            declaration = "wire delayed;" if row[0] == "1" else f"wire [{int(row[0])-1}:0] delayed;"
            self.assertIn(declaration, case.body)
            self.assertIn("$strobe(", case.body)
            self.assertIn("if ($time >= 20)", case.body)
            self.assertIn("changes++;", case.body)
            self.assertIn("last = $time - 20;", case.body)
            self.assertNotIn("#0", case.body)
            self.assertEqual(case.fourstate, row[2] != "known")


if __name__ == "__main__":
    unittest.main()
