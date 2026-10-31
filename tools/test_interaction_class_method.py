"""Independent recursive cell interpreter for class argument/receiver witnesses."""

from dataclasses import dataclass
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_class_method as cases


@dataclass
class Cell:
    value: str


def simulate(row):
    width, state, value, dispatch, kind, mode, depth = row
    width, depth = int(width), int(depth)
    output = []
    for label, phase, unknown in cases.phases(row):
        objects = {}
        for owner in (2, 5):
            # Build the bit patterns independently of the generator's stimulus.
            marks = ["".join(str((i + d + owner + phase + 1) % 2)
                             for i in range(width)) for d in range(4)]
            updates = []
            for d, mark in enumerate(marks):
                raw = value * width if unknown and (d + owner + phase) % 2 else (
                    "".join(str(1 - int(bit)) for bit in mark))
                updates.append("".join("0" if state == "bit" and b in "xz" else b for b in raw))
            initial = value * width if unknown else marks[depth]
            if state == "bit":
                initial = initial.replace("x", "0").replace("z", "0")
            guard = marks[0]
            objects[owner] = dict(payload=Cell(initial), guard=guard, marks=marks,
                                  updates=updates, base=0, leaf=0)
            output.append(f"{label} init owner={owner} payload={initial} guard={guard}")

        def walk(obj, owner, d, actual):
            argument = Cell(actual.value) if mode == "input" else actual
            body = "base" if dispatch == "base_nonvirtual" else "leaf"
            tag = {"base": 1, "leaf": 2}[body]
            obj[body] += 1
            obj["payload"].value = obj["updates"][d]
            output.append(f"who={tag} owner={owner} d={d} entry={argument.value} "
                          f"property={obj['payload'].value}")
            if mode != "const_ref":
                argument.value = obj["marks"][d]
            total = walk(obj, owner, d - 1, argument) if d else 0
            output.append(f"who={tag} owner={owner} d={d} exit={argument.value} "
                          f"property={obj['payload'].value}")
            return total + 100 * tag + 10 * owner + d

        for index, owner in enumerate((2, 5, 2)):
            obj = objects[owner]
            total = walk(obj, owner, depth, obj["payload"])
            output.append(f"{label} call={index} total={total}")
            for o, saved in objects.items():
                output.append(f"{label} saved owner={o} payload={saved['payload'].value} "
                              f"guard={saved['guard']} base={saved['base']} leaf={saved['leaf']}")
    return "\n".join(output) + "\n"


class ClassMethodReference(unittest.TestCase):
    def test_all_legal_rows_match_independent_recursive_cells(self):
        self.assertEqual(len(cases.MODEL.rows()), 1944)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), simulate(row), row)

    def test_selected_rows_cover_pairs_triples_and_mandatory_witnesses(self):
        selected = cases.MODEL.select()
        covered = set(t for row in selected for t in cases.MODEL.targets(row))
        self.assertEqual(covered, cases.MODEL.universe())
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))
        self.assertEqual(sum(len(t) == 2 for t in covered), 202)
        self.assertEqual(sum(len(t) == 3 for t in covered), 99)

    def test_recursive_input_exits_keep_private_depth_markers(self):
        row = ("1", "logic", "known", "direct", "function", "input", "3")
        text = cases.reference(row)
        self.assertIn("who=2 owner=2 d=0 exit=1 property=0", text)
        self.assertIn("who=2 owner=2 d=1 exit=0 property=0", text)
        self.assertIn("who=2 owner=2 d=3 exit=0 property=0", text)
        self.assertIn("k0 call=0 total=886", text)

    def test_ref_and_const_ref_observe_property_updates_differently_from_input(self):
        base = ("1", "logic", "x", "direct", "task")
        by_ref = cases.reference((*base, "ref", "3"))
        const = cases.reference((*base, "const_ref", "3"))
        self.assertIn("who=2 owner=5 d=3 entry=0 property=0", by_ref)
        self.assertIn("who=2 owner=5 d=3 exit=0 property=0", by_ref)
        self.assertIn("who=2 owner=5 d=3 exit=x property=x", const)

    def test_nonvirtual_base_view_uses_base_body_and_separate_object_storage(self):
        row = ("1", "bit", "known", "base_nonvirtual", "task", "ref", "3")
        text = cases.reference(row)
        self.assertIn("k0 call=0 total=486", text)
        self.assertIn("k0 saved owner=2 payload=1 guard=1 base=8 leaf=0", text)
        self.assertIn("k0 saved owner=5 payload=0 guard=0 base=4 leaf=0", text)
        self.assertNotIn("who=2", text)

    def test_unknown_rows_keep_known_controls_and_bit_conversion(self):
        row = ("129", "bit", "z", "base_virtual", "function", "const_ref", "1")
        self.assertEqual(len(cases.phases(row)), 6)
        self.assertNotIn("z", cases.reference(row))
        logic = (row[0], "logic", *row[2:])
        self.assertIn("entry=" + "z" * 129, cases.reference(logic))

    def test_source_keeps_identical_reference_types_and_never_writes_const_formal(self):
        for row in cases.MODEL.anchors:
            source = cases.make_case(row).body
            self.assertEqual("formal = this.m0" in source, row[5] != "const_ref")
            self.assertIn("this.payload = this.u0", source)
            self.assertIn("automatic", source)
            self.assertNotIn("#", source)


if __name__ == "__main__":
    unittest.main()
