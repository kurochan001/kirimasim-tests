"""Check the sampling oracle with an independent ordered-event simulation."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_clocking as generator


def simulate(row):
    """Advance through Active, NBA, Observed and the later report per edge."""
    output = []
    for count, (label, before, incoming) in enumerate(generator.phases(row), 1):
        storage = list(before)
        sampled = storage.copy()  # 1step: last value before entering the edge's slot.
        update = ["0" if row[1] == "bit" and bit in "xz" else bit for bit in incoming]
        pending = []
        if row[6] == "blocking":
            storage = update.copy()
        else:
            pending.append(update.copy())
        for assignment in pending:
            storage = assignment
        if row[4] == "zero":
            sampled = storage.copy()
        output += [f"{label} before={before} source={incoming}",
                   f"{label} hits={count} sampled={''.join(sampled)} "
                   f"at_cb={''.join(storage)} live={''.join(storage)}"]
    return "\n".join(output) + "\n"


class ClockingSampling(unittest.TestCase):
    def test_all_legal_rows_match_the_ordered_region_model(self):
        for row in generator.MODEL.rows():
            self.assertEqual(generator.reference(row), simulate(row), row)

    def test_step_and_zero_distinguish_every_known_control(self):
        for row in generator.MODEL.select():
            step = (*row[:4], "step", *row[5:])
            zero = (*row[:4], "zero", *row[5:])
            self.assertNotEqual(generator.reference(step), generator.reference(zero))
            for label, before, incoming in generator.phases(row):
                if label.endswith("known"):
                    self.assertTrue(all(a != b for a, b in zip(before, incoming)))

    def test_bit_storage_converts_unknowns_before_zero_skew_sampling(self):
        bit = ("1", "bit", "z", "local", "zero", "posedge", "nba")
        logic = (*bit[:1], "logic", *bit[2:])
        self.assertIn("p0_z hits=2 sampled=0 at_cb=0 live=0", generator.reference(bit))
        self.assertIn("p0_z hits=2 sampled=z at_cb=z live=z", generator.reference(logic))

    def test_unknown_rows_include_known_controls_and_wide_mixed_values(self):
        for value in ("x", "z"):
            row = ("129", "logic", value, "interface", "step", "negedge", "blocking")
            phases = generator.phases(row)
            self.assertEqual(len(phases), 6)
            for label, _, raw in phases:
                if label.endswith("known"):
                    self.assertEqual(set(raw) - set("01"), set())
                else:
                    self.assertEqual({raw[0], raw[64], raw[-1]}, {value})
                    self.assertTrue(set(raw) & set("01"))

    def test_access_edge_and_assignment_variants_keep_the_same_sampling_contract(self):
        base = ("65", "logic", "x", "local", "step", "posedge", "blocking")
        expected = generator.reference(base)
        for access in ("local", "interface", "virtual"):
            for edge in ("posedge", "negedge"):
                for update in ("blocking", "nba"):
                    row = (*base[:3], access, base[4], edge, update)
                    self.assertEqual(generator.reference(row), expected)

    def test_selection_preserves_targets_and_mandatory_unsupported_paths(self):
        selected = generator.MODEL.select()
        covered = set(t for row in selected for t in generator.MODEL.targets(row))
        self.assertEqual(covered, generator.MODEL.universe())
        self.assertTrue(set(generator.MODEL.anchors) <= set(selected))
        self.assertTrue(any(r[3] == "virtual" for r in selected))
        self.assertEqual(len(generator.MODEL.rows()), 864)


if __name__ == "__main__":
    unittest.main()
