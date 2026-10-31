"""Independent FIFO event interpreter using integer value/unknown bit planes."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_loop_nba as cases


def pack(bits):
    value, unknown = 0, 0
    for bit in bits:
        value = value * 2 + int(bit == "1")
        unknown = unknown * 2 + int(bit in "xz")
    return value, unknown


def show(word, width):
    value, unknown = word
    return "".join("x" if unknown & (1 << bit) else str((value >> bit) & 1)
                   for bit in range(width - 1, -1, -1))


def interpret(row):
    width, state, value, loop, count, storage, update, home = row
    width, count = int(width), int(count)
    masks = ["0" * width, "1" * width, "".join(str(1 - (i % 2)) for i in range(width))]
    output, stamp = [], 0
    for unknown_phase in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown_phase else "k") + str(phase)
            objects = {}
            for owner in (2, 5):
                bias = 0 if owner == 2 else 1
                objects[owner] = dict(words=[pack(masks[(phase+bias+i) % 3])
                                     for i in range(1 if storage == "scalar" else 3)],
                                     guard=masks[(phase+bias+2) % 3], calls=0, issued=0)
            queue = []
            for call, owner in enumerate((2, 5, 2)):
                obj = objects[owner]
                obj["calls"] += 1
                for i in range(count):
                    slot = i % 3 if storage == "rotate" else 0
                    index = 0 if storage == "scalar" else slot + 2
                    raw = value * width if unknown_phase and not ((i+call) % 2) else (
                        masks[(1, 2, 0)[(i+phase+int(owner == 5)+call) % 3]])
                    typed = "".join("0" if state == "bit" and b in "xz" else b for b in raw)
                    old = obj["words"][slot]
                    incoming = pack(typed)
                    result = (old[0] ^ incoming[0], old[1] | incoming[1])
                    if state == "bit":
                        result = (result[0] & ~result[1], 0)
                    output.append(f"phase={stamp} owner={owner} call={obj['calls']} step={i} "
                                  f"index={index} old={show(old, width)} raw={raw} mask={typed}")
                    obj["issued"] += 1
                    if update == "blocking":
                        obj["words"][slot] = result
                    else:
                        queue.append((obj, slot, result))
            for stage in ("active", "settled"):
                if stage == "settled":
                    while queue:
                        obj, slot, result = queue.pop(0)
                        obj["words"][slot] = result
                for owner, obj in objects.items():
                    output.append(f"{label} {stage} owner={owner} calls={obj['calls']} "
                                  f"issued={obj['issued']} guard={obj['guard']}")
                    output += [f"{label} {stage} owner={owner} word{i}={show(word, width)}"
                               for i, word in enumerate(obj["words"])]
            stamp += 1
    return "\n".join(output) + "\n"


class LoopAssignmentReference(unittest.TestCase):
    def test_all_legal_rows_match_fifo_integer_plane_interpreter(self):
        self.assertEqual(len(cases.MODEL.rows()), 3888)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selected_rows_keep_every_pair_triple_and_anchor(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        covered = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(covered, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in covered), 246)
        self.assertEqual(sum(len(t) == 3 for t in covered), 111)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_nba_reads_old_value_while_blocking_feeds_each_iteration(self):
        row = cases.MODEL.anchors[0]
        nba = cases.reference(row)
        blocking = cases.reference((*row[:6], "blocking", row[7]))
        self.assertIn("phase=0 owner=2 call=1 step=1 index=0 old=0 raw=1 mask=1", nba)
        self.assertIn("phase=0 owner=2 call=1 step=1 index=0 old=1 raw=1 mask=1", blocking)
        self.assertIn("k0 active owner=2 word0=0", nba)
        self.assertIn("k0 settled owner=2 word0=1", nba)
        self.assertIn("k0 active owner=2 word0=1", blocking)

    def test_rotated_indices_and_instances_keep_separate_pending_writes(self):
        row = ("1", "logic", "known", "repeat", "5", "rotate", "nba", "interface")
        text = cases.reference(row)
        self.assertIn("phase=0 owner=2 call=2 step=4 index=3 old=1 raw=1 mask=1", text)
        for i in range(3):
            self.assertIn(f"k0 settled owner=2 word{i}=0", text)
        for i, bit in enumerate("101"):
            self.assertIn(f"k0 settled owner=5 word{i}={bit}", text)
        self.assertIn("k0 settled owner=2 calls=2 issued=10 guard=1", text)
        self.assertIn("k0 settled owner=5 calls=1 issued=5 guard=0", text)

    def test_bit_conversion_precedes_xor_and_logic_unknowns_feed_back(self):
        row = ("1", "logic", "z", "while", "3", "same", "blocking", "interface")
        text = cases.reference(row)
        self.assertIn("phase=3 owner=2 call=1 step=0 index=2 old=0 raw=z mask=z", text)
        self.assertIn("phase=3 owner=2 call=1 step=1 index=2 old=x", text)
        bit = cases.reference((row[0], "bit", *row[2:]))
        self.assertIn("old=0 raw=z mask=0", bit)
        self.assertNotIn("old=x", bit)

    def test_home_changes_source_but_not_the_required_observations(self):
        for row in cases.MODEL.anchors:
            other = (*row[:7], "interface" if row[7] == "module" else "module")
            self.assertEqual(cases.reference(row), cases.reference(other))
            self.assertIn(row[7] + " loop_worker", cases.make_case(row).body)
            self.assertNotEqual(cases.make_case(row).body, cases.make_case(other).body)

    def test_sources_keep_targets_static_and_masks_poisoned_after_return(self):
        for row in cases.MODEL.anchors:
            source = cases.make_case(row).body
            self.assertIn("task automatic issue", source)
            self.assertIn("endtask", source)
            self.assertIn("a.issue(0);\n    a.raw0 = '0;", source)
            self.assertNotIn("new[", source)
            self.assertEqual(len(cases.phases(row)), 3 if row[2] == "known" else 6)


if __name__ == "__main__":
    unittest.main()
