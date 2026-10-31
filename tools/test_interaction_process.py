"""Event-driven interpreter independent of the process oracle's value updates."""

from collections import deque
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_process as cases


def interpret(row):
    width, state, value, process, access, home, gate, idle = row
    width = int(width)
    words = ["0" * width, "1" * width, "".join(str(1-i%2) for i in range(width))]
    signals = {o: dict(en="1", data=words[0], mask=words[1], noise=words[0],
                       q="x" * width, events=0) for o in ("a", "b")}
    active, nba, output = deque(), deque(), []

    def xor(a, b):
        x = int("".join("1" if c in "xz" else "0" for c in a), 2)
        y = int("".join("1" if c in "xz" else "0" for c in b), 2)
        number = int(a.replace("x", "0").replace("z", "0"), 2) ^ int(
            b.replace("x", "0").replace("z", "0"), 2)
        return "".join("x" if (x | y) & (1 << i) else str((number >> i) & 1)
                       for i in range(width-1, -1, -1))

    def settle():
        while active:
            owner = active.popleft()
            s = signals[owner]
            s["events"] += 1
            if s["en"] == "1":
                answer = xor(s["data"], s["mask"])
                if state == "bit":
                    answer = answer.replace("x", "0")
                if process == "latch":
                    nba.append((owner, answer))
                else:
                    s["q"] = answer
            elif process == "comb":
                s["q"] = ("1" if idle == "one" else "0") * width
        while nba:
            owner, answer = nba.popleft()
            signals[owner]["q"] = answer

    def dump(label):
        for owner, s in signals.items():
            output.append(f"{label} {owner} en={s['en']} data={s['data']} mask={s['mask']} "
                          f"q={s['q']} noise={s['noise']} events={s['events']}")

    active.extend(("a", "b"))  # Startup executes each implicit process once.
    settle()
    dump("start")
    for unknown in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown else "k") + str(phase)
            gate_a = {"zero": "0", "one": "1", "x": "x", "z": "z"}[gate]
            gate_b = {"0": "1", "1": "0", "x": "z", "z": "x"}[gate_a]
            raw = value * width
            schedule = [
                ("a", "en", "1"), ("b", "en", "1"),
                ("a", "data", words[phase]), ("b", "data", words[(phase+1) % 3]),
                ("a", "mask", raw if unknown else words[(phase+2) % 3]),
                ("b", "mask", raw if unknown else words[phase]),
                ("a", "en", gate_a), ("b", "en", gate_b),
                ("a", "data", raw if unknown else words[(phase+1) % 3]),
                ("b", "data", raw if unknown else words[(phase+2) % 3]),
                ("a", "mask", words[(phase+1) % 3]), ("b", "mask", words[(phase+2) % 3]),
                ("a", "noise", None), ("b", "noise", None),
                ("a", "en", "1"), ("b", "en", "1")]
            for i, (owner, field, bits) in enumerate(schedule):
                s = signals[owner]
                if bits is None:
                    bits = "".join("1" if c == "0" else "0" for c in s[field])
                if state == "bit" and field != "en":
                    bits = bits.replace("x", "0").replace("z", "0")
                if bits != s[field] and field != "noise":
                    active.append(owner)
                s[field] = bits
                settle()
                dump(f"{label}_{i}")
    return "\n".join(output) + "\n"


class ImplicitProcessReference(unittest.TestCase):
    def test_all_legal_rows_match_separate_active_and_nba_event_queues(self):
        self.assertEqual(len(cases.MODEL.rows()), 1728)
        for row in cases.MODEL.rows():
            expected = cases.reference(row)
            self.assertEqual(expected, interpret(row), row)
            self.assertLessEqual(max(int(line.rsplit("events=", 1)[1])
                                     for line in expected.splitlines()), 37, row)

    def test_selection_covers_all_pairs_triples_and_anchors(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        covered = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(covered, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in covered), 242)
        self.assertEqual(sum(len(t) == 3 for t in covered), 96)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_idle_is_hold_only_for_latches_and_default_only_for_comb(self):
        for row in cases.MODEL.rows():
            self.assertEqual(row[3] == "latch", row[7] == "hold")
        row = cases.MODEL.anchors[0]
        with self.assertRaisesRegex(ValueError, "not a legal"):
            cases.MODEL.targets((*row[:7], "hold"))

    def test_startup_runs_once_and_noise_never_changes_evaluation_count(self):
        for row in cases.MODEL.anchors:
            lines = cases.reference(row).splitlines()
            self.assertTrue(all(line.endswith("events=1") for line in lines[:2]))
            previous = {}
            for line in lines:
                label, owner, *items = line.split()
                values = dict(item.split("=") for item in items)
                if label.endswith(("_12", "_13")):
                    self.assertEqual(values["events"], previous[owner]["events"])
                previous[owner] = values

    def test_same_typed_value_does_not_wake_and_other_instance_keeps_count(self):
        row = cases.MODEL.anchors[0]
        lines = cases.reference(row).splitlines()
        self.assertTrue(all(line.endswith("events=1") for line in lines[:8]))
        for row in cases.MODEL.anchors:
            previous = {}
            for line in cases.reference(row).splitlines():
                label, owner, *items = line.split()
                current = dict(item.split("=") for item in items)
                if owner in previous and current["events"] != previous[owner]["events"]:
                    self.assertTrue(any(current[k] != previous[owner][k] for k in ("en", "data", "mask")))
                previous[owner] = current

    def test_function_and_direct_paths_require_identical_observations(self):
        for row in cases.MODEL.anchors:
            other = (*row[:4], "function" if row[4] == "direct" else "direct", *row[5:])
            self.assertEqual(cases.reference(row), cases.reference(other))
            self.assertNotEqual(cases.make_case(row).body, cases.make_case(other).body)

    def test_unknown_gates_are_marked_fourstate_even_with_known_data(self):
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            self.assertEqual(case.fourstate, row[2] != "known" or row[6] in ("x", "z"))
            self.assertIn("if (events < 512) events++;", case.body)
            self.assertNotIn("q = '0;\n  initial", case.body)


if __name__ == "__main__":
    unittest.main()
