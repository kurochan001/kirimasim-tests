"""Independent per-instance objects, integer bit planes and reader aliases."""

from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_ifgenerate as cases


def encode(width, lane, phase, guard=False):
    if phase == 11:
        return 0
    if phase == 12:
        return 0 if guard else (1 << width)-1
    bank = lane + (5 if guard else 1)
    return sum((((bank * 256 + bit + 1) // (2**phase)) % 2) << bit for bit in range(width))


def show(planes, width):
    value, x, z = planes
    return "".join("x" if x >> bit & 1 else "z" if z >> bit & 1 else str(value >> bit & 1)
                   for bit in range(width-1, -1, -1))


def interpret(row):
    base, count, form, route, access, state, value = row
    branch = int(route == "b")
    instances = []
    for lane in range(int(count)):
        width = int(base)+lane
        a, b = {"width": width}, {"width": width}
        instances.append({"a": a, "b": b, "writer": b if branch else a,
                          "reader": b if branch else a, "guard": a if branch else b})
    lines = []
    phases = [(f"k{i}", i, False) for i in range(13)]
    if value != "known":
        phases += [(f"u{i}", i, True) for i in range(3)]
    for label, phase, unknown in phases:
        raw_words = []
        for lane, inst in enumerate(instances):
            width = inst["a"]["width"]
            mask, v, x, z = (1 << width)-1, encode(width, lane, phase), 0, 0
            if unknown:
                positions = {0, width-1, (lane+phase+1) % width}
                bad = sum(1 << bit for bit in positions)
                v &= ~bad
                x, z = (bad, 0) if value == "x" else (0, bad)
            raw_words.append(show((v, x, z), width))
            if branch:
                v = mask ^ v
                x, z = x | z, 0
            v &= ~(x | z)
            if state == "bit":
                x, z = 0, 0
            inst["writer"].update(payload=(v, x, z), tag=11+lane+100*branch)
            inst["guard"].update(payload=(encode(width, lane, phase, True), 0, 0), tag=-lane-1)
        for lane, inst in enumerate(instances):
            a, b, reader = inst["a"], inst["b"], inst["reader"]
            width = a["width"]
            lines += [f"{label} lane={lane} raw={raw_words[lane]}",
                      f"{label} lane={lane} a={show(a['payload'],width)} atag={a['tag']} "
                      f"b={show(b['payload'],width)} btag={b['tag']}",
                      f"{label} lane={lane} seen={show(reader['payload'],width)} sid={reader['tag']} "
                      f"bits={a['width']},{b['width']},{reader['width']} branch={branch}"]
    return "\n".join(lines) + "\n"


class GeneratedInterfaceBinding(unittest.TestCase):
    def test_all_864_rows_match_independent_instance_objects_and_reader_aliases(self):
        self.assertEqual(len(cases.MODEL.rows()), 864)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_every_pair_triple_and_six_mandatory_cases(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 165)
        self.assertEqual(sum(len(t) == 3 for t in targets), 74)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_histories_identify_all_780_payload_positions_in_both_routes(self):
        for inverted in (False, True):
            signatures = []
            for lane in range(3):
                width = 129+lane
                for guard in (False, True):
                    frames = [encode(width, lane, phase, guard) for phase in range(13)]
                    for bit in range(width):
                        history = tuple(((v >> bit) & 1) ^ (inverted and not guard) for v in frames)
                        signatures.append(history)
            self.assertEqual(len(signatures), 780)
            self.assertEqual(len(set(signatures)), 780)

    def test_complement_occurs_before_two_state_conversion(self):
        row = ("1", "1", "if", "b", "modport", "bit", "z")
        self.assertIn("u0 lane=0 seen=0 sid=111", interpret(row))
        logic = (*row[:5], "logic", row[6])
        self.assertIn("u0 lane=0 seen=x sid=111", interpret(logic))
        direct = (*logic[:3], "a", *logic[4:])
        self.assertIn("u0 lane=0 seen=z sid=11", interpret(direct))

    def test_widths_tags_and_guard_values_are_independent_per_generated_element(self):
        text = interpret(cases.MODEL.anchors[1])
        for lane, width in enumerate((129, 130, 131)):
            self.assertIn(f"sid={111+lane} bits={width},{width},{width} branch=1", text)
            self.assertIn(f"atag={-1-lane}", text)

    def test_if_case_and_whole_modport_forms_have_equal_defined_behavior(self):
        row = cases.MODEL.anchors[1]
        for form in ("if", "case"):
            for access in ("whole", "modport"):
                changed = (*row[:2], form, row[3], access, *row[5:])
                self.assertEqual(interpret(row), interpret(changed))

    def test_unknown_cases_retain_known_controls_and_observe_unknown_source_bits(self):
        for row in cases.MODEL.select():
            text = cases.reference(row)
            for phase in range(13):
                self.assertIn(f"k{phase} lane=0 raw=", text)
            symbols = "".join(re.findall(r"raw=([01xz]+)", text))
            self.assertEqual(any(c in symbols for c in "xz"), row[6] != "known")

    def test_rendered_cases_classify_fourstate_and_keep_valid_widths(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertEqual(case.fourstate, row[6] != "known")
            self.assertLessEqual(int(row[0])+int(row[1])-1, 131)


if __name__ == "__main__":
    unittest.main()
