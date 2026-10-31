"""Imperative scanner and isolated/shared namespaces, independent of the oracle."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_return as cases


def simulate(row):
    width, kind, value, loop, stop, scope = row
    width = int(width)
    output = []
    for unknown in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown else "k") + str(phase)
            objects = {}
            for owner in (2, 5, 0):
                shadow = scope == "package" and owner != 0
                state = {name: (100 * (i + 1) + owner if shadow else 0)
                         for i, name in enumerate(("calls", "scanned", "weight", "tails", "dead"))}
                state.update(last=-600-owner if shadow else -9, runs=0,
                             guard="".join("1" if (i + owner) & 1 else "0" for i in range(width)))
                objects[owner] = state
            for call, owner in enumerate((2, 5, 2)):
                index = {"head": 0, "middle": width // 2, "tail": width - 1, "none": -1}[stop]
                if index >= 0 and owner == 5:
                    index = width - 1 - index
                data = []
                for i in range(width):
                    b = "0"
                    if i == index:
                        b = value if unknown else "1"
                    elif index >= 0 and i > index:
                        b = "1" if phase == 1 else str((i + owner) % 2) if phase == 2 else "0"
                    data.append("0" if kind == "bit" and b in "xz" else b)
                raw_backup = (value * width if unknown else "1" * width if phase == 0 else
                              "".join(str((i + owner + phase) % 2) for i in range(width)))
                backup = "".join("0" if kind == "bit" and b in "xz" else b for b in raw_backup)
                state = objects[0 if scope == "package" else owner]
                state["calls"] += 1
                state["last"] = -2
                answer = None
                for i, b in enumerate(data):
                    state["scanned"] += 1
                    state["weight"] += i + 1
                    if b in ("1", "x", "z"):
                        state["last"] = i
                        answer = "".join(reversed(data))
                        break
                if answer is None:
                    state["tails"] += 1
                    state["last"] = -1
                    answer = backup
                objects[owner]["runs"] += 1
                output.append(f"{label} call={call} owner={owner} input={''.join(reversed(data))} answer={answer}")
                for name, o in (("a", 2), ("b", 5), ("pkg", 0)):
                    s = objects[o]
                    output.append(f"{label} {name} calls={s['calls']} scanned={s['scanned']} "
                                  f"weight={s['weight']} tails={s['tails']} dead={s['dead']} "
                                  f"last={s['last']} runs={s['runs']} guard={s['guard']}")
    return "\n".join(output) + "\n"


class LoopReturnReference(unittest.TestCase):
    def test_all_legal_rows_match_independent_iterative_scanner(self):
        self.assertEqual(len(cases.MODEL.rows()), 864)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), simulate(row), row)

    def test_selection_keeps_all_targets_and_anchors(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 161)
        self.assertEqual(sum(len(t) == 3 for t in targets), 120)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_logic_x_or_z_stops_but_bit_conversion_can_reach_tail(self):
        for value in ("x", "z"):
            row = ("65", "logic", value, "while", "middle", "local")
            logic = cases.reference(row)
            bit = cases.reference((row[0], "bit", *row[2:]))
            self.assertIn("u0 a calls=1 scanned=33 weight=561 tails=0 dead=0 last=32", logic)
            self.assertIn("u0 a calls=1 scanned=65 weight=2145 tails=1 dead=0 last=-1", bit)

    def test_package_state_accumulates_across_both_callers_and_ignores_shadows(self):
        row = ("1", "bit", "known", "for", "head", "package")
        text = cases.reference(row)
        self.assertIn("k0 pkg calls=3 scanned=3 weight=3 tails=0 dead=0 last=0 runs=0", text)
        self.assertIn("k0 a calls=102 scanned=202 weight=302 tails=402 dead=502 last=-602 runs=2", text)
        self.assertIn("k0 b calls=105 scanned=205 weight=305 tails=405 dead=505 last=-605 runs=1", text)

    def test_local_state_remains_per_instance_and_package_is_untouched(self):
        row = ("1", "logic", "known", "repeat", "none", "local")
        text = cases.reference(row)
        self.assertIn("k0 a calls=2 scanned=2 weight=2 tails=2 dead=0 last=-1 runs=2", text)
        self.assertIn("k0 b calls=1 scanned=1 weight=1 tails=1 dead=0 last=-1 runs=1", text)
        self.assertIn("k0 pkg calls=0 scanned=0 weight=0 tails=0 dead=0 last=-9 runs=0", text)

    def test_width_one_keeps_legal_degenerate_boundaries(self):
        texts = [cases.reference(("1", "logic", "z", "for", stop, "local"))
                 for stop in ("head", "middle", "tail")]
        self.assertEqual(texts[0], texts[1])
        self.assertEqual(texts[1], texts[2])

    def test_sources_keep_return_tail_and_dead_statements_distinct(self):
        for row in cases.MODEL.anchors:
            source = cases.make_case(row).body
            self.assertIn("return data;\n        dead++;", source)
            self.assertIn("tails++; last = -1;\n    return backup;\n    dead += 1000;", source)
            self.assertEqual("return_pkg::pick(data, backup)" in source, row[5] == "package")
            self.assertEqual(len(cases.phases(row)), 3 if row[2] == "known" else 6)


if __name__ == "__main__":
    unittest.main()
