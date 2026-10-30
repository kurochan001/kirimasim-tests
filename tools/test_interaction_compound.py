"""Independent numeric checks for compound shifts and their type boundaries."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_compound as compound


class CompoundShiftOracle(unittest.TestCase):
    def test_known_rows_agree_with_bounded_integer_arithmetic(self):
        # The production oracle maps character positions. This check instead
        # uses integer arithmetic and two's complement, including widened reads.
        for row in compound.MODEL.rows():
            if row[7] != "known" or row[5] in ("x", "z"):
                continue
            width = int(row[0])
            mask = (1 << width) - 1
            amount = int(compound.count_bits(row), 2)
            signed = row[2] == "signed" and row[3] != "part"
            for phase in (0, 1):
                source = compound.source_bits(row, phase)
                number = int(source, 2)
                signed_number = number - (1 << width) if signed and number >> (width - 1) else number
                if row[4] == "shl":
                    value = (number * (1 << amount)) & mask if amount < width else 0
                elif row[4] == "shr" or not signed:
                    value = number // (1 << amount) if amount < width else 0
                else:
                    value = (signed_number // (1 << amount)) & mask if amount < width else (
                        mask if signed_number < 0 else 0)
                extended = value | (1 << width) if signed and value >> (width - 1) else value
                expected = (source, f"{value:0{width}b}", f"{extended:0{width + 1}b}")
                self.assertEqual(compound.reference(row, phase), expected, (row, phase))

    def test_part_selection_loses_sign_but_array_element_keeps_it(self):
        base = ("33", "logic", "signed", "element", "ashr", "last", "8", "known")
        part = (*base[:3], "part", *base[4:])
        self.assertEqual(compound.reference(base, 0)[1:], ("1" * 33, "1" * 34))
        self.assertEqual(compound.reference(part, 0)[1:], ("0" * 32 + "1", "0" * 33 + "1"))
        # A 65-bit count is self-determined; it must not widen a 33-bit LHS.
        wide_count = (*base[:6], "65", base[7])
        self.assertEqual(compound.reference(base, 0), compound.reference(wide_count, 0))

    def test_unknown_signs_counts_and_storage_conversion(self):
        zsign = ("65", "logic", "signed", "element", "ashr", "width", "65", "z")
        self.assertEqual(compound.reference(zsign, 0)[1:], ("z" * 65, "z" * 66))
        bit = (zsign[0], "bit", *zsign[2:])
        self.assertEqual(compound.reference(bit, 0)[1:], ("0" * 65, "0" * 66))
        for count in ("x", "z"):
            unknown = (*zsign[:5], count, *zsign[6:])
            self.assertEqual(compound.reference(unknown, 0)[1:], ("x" * 65, "x" * 66))
            converted = (unknown[0], "bit", *unknown[2:])
            self.assertEqual(compound.reference(converted, 0)[1:], ("0" * 65, "0" * 66))


if __name__ == "__main__":
    unittest.main()
