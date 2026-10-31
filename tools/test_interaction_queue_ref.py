"""Qualify queue-reference expectations with positional identity mappings."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_queue_ref as cases


def layout(row):
    h = ("first", "middle", "last").index(row[3])
    orders = {"push_front": [3, 0, 1, 2], "push_back": [0, 1, 2, 3],
              "insert": [0, 3, 1, 2], "pop_front": [1, 2], "pop_back": [0, 1],
              "delete_held": [i for i in range(3) if i != h],
              "delete_other": [i for i in range(3) if i != (2 if h == 0 else 0)],
              "copy": [0, 1, 2], "concat": [0, 1, 2, 3], "clear": []}
    order = orders[row[4]][:3] if row[2] == "three" else orders[row[4]]
    live = row[4] not in ("copy", "concat") and h in order
    return order, order.index(h) if live else None


class QueueReferenceOracle(unittest.TestCase):
    def test_all_legal_rows_match_a_positional_mapping_without_heap_cells(self):
        for row in cases.MODEL.rows():
            w = int(row[0]); mask = (1 << w) - 1
            h = ("first", "middle", "last").index(row[3])
            order, destination = layout(row)
            added = f"{(1 << (w - 1)) | (1 << (w // 2)) | 1:0{w}b}"
            for phase in range(3):
                initial = [f"{mask if phase == i else 0:0{w}b}" for i in range(3)]
                for value in (("known",) if row[5] == "known" else ("known", row[5])):
                    given = int(initial[h], 2)
                    raw_first = f"{given ^ mask:0{w}b}" if value == "known" else value * w
                    first = raw_first if row[1] == "logic" or value == "known" else "0" * w
                    second = f"{given if value == 'known' else given ^ mask:0{w}b}"
                    changed = [(initial + [added])[i] for i in order]
                    first_queue, final = changed.copy(), changed.copy()
                    if destination is not None:
                        first_queue[destination] = first; final[destination] = second
                    r = cases.reference(row, phase, value)
                    self.assertEqual(r['initial'], initial, row)
                    self.assertEqual(r['before'], initial[h], row)
                    self.assertEqual(r['raw_first'], raw_first, row)
                    self.assertEqual(r['first'], first, row)
                    self.assertEqual(r['second'], second, row)
                    self.assertEqual(r['changed'], changed, row)
                    self.assertEqual(r['after_first'], first_queue, row)
                    self.assertEqual(r['final'], final, row)
                    self.assertEqual(r['valid'], destination is not None, row)
                    popped = initial[0 if row[4] == 'pop_front' else 2] \
                        if row[4] in ('pop_front', 'pop_back') else '0' * w
                    self.assertEqual(r['popped'], popped, row)

    def test_equal_valued_whole_assignment_outdates_but_method_preserves(self):
        base = ("33", "logic", "unbounded", "middle", "push_back", "known")
        method = cases.reference(base, 1, "known")
        assigned = cases.reference((*base[:4], "concat", "known"), 1, "known")
        self.assertEqual(method['changed'], assigned['changed'])
        self.assertTrue(method['valid']); self.assertFalse(assigned['valid'])
        self.assertNotEqual(method['after_first'], assigned['after_first'])

    def test_bounded_insert_and_push_front_drop_only_the_old_last_reference(self):
        for operation in ("push_front", "insert", "push_back"):
            for held in ("first", "middle", "last"):
                row = ("129", "logic", "three", held, operation, "z")
                r = cases.reference(row, 2, "z")
                self.assertEqual(len(r['changed']), 3)
                self.assertEqual(r['valid'], held != "last" or operation == "push_back")
                self.assertEqual(r['first'], "z" * 129)

    def test_one_bit_rotations_distinguish_all_original_element_identities(self):
        row = ("1", "bit", "unbounded", "middle", "push_front", "x")
        signatures = {tuple(cases.initial_values(row, p)[i] for p in range(3)) for i in range(3)}
        self.assertEqual(len(signatures), 3)
        self.assertEqual({value for _, _, value in cases.phases(row)}, {'known', 'x'})
        for _, phase, value in cases.phases(row):
            r = cases.reference(row, phase, value)
            self.assertEqual(r['after_first'][2], r['first'])
            self.assertEqual(r['after_first'][1], r['initial'][0])

    def test_selection_keeps_every_structural_reference_lifetime_scenario(self):
        selected = cases.MODEL.select()
        self.assertEqual({r[2:5] for r in selected}, {r[2:5] for r in cases.MODEL.rows()})
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))


if __name__ == "__main__":
    unittest.main()
