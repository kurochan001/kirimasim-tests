"""Check inside value ranges with integer intervals rather than bit strings."""

from decimal import Decimal, ROUND_DOWN
from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_range as ranges


def joint(bits, own_signed, signed):
    """Return the value of an operand in the joint type of a comparison."""
    if any(c in "xz" for c in bits):
        return None
    value = int(bits, 2)
    if signed and own_signed and bits[0] == "1":
        value -= 1 << len(bits)
    return value


def relation(left, right, ns, bs, holds):
    signed = ns == bs == "signed"
    a, b = joint(left, ns == "signed", signed), joint(right, bs == "signed", signed)
    if signed is False:
        # An unsigned comparison reads both operands as unsigned values.
        a = None if a is None else int(left, 2)
        b = None if b is None else int(right, 2)
    return "x" if a is None or b is None else str(int(holds(a, b)))


def wildcard(left, right, ns, bs):
    width = max(len(left), len(right))
    signed = ns == bs == "signed"
    def extend(bits):
        return (bits[0] if signed else "0") * (width - len(bits)) + bits
    pairs = [(a, b) for a, b in zip(extend(left), extend(right)) if b not in "xz"]
    if any(a in "01" and a != b for a, b in pairs):
        return "0"
    return "x" if any(a in "xz" for a, _ in pairs) else "1"


def tolerance(a, b, signed, form):
    if any(c in "xz" for c in a + b):
        return None
    av = int(a, 2) - ((1 << len(a)) if signed and a[0] == "1" else 0)
    bv = int(b, 2) - ((1 << len(b)) if signed and b[0] == "1" else 0)
    if form == "abs_tol":
        delta = bv
    else:
        delta = int((Decimal(av) * Decimal(bv) / Decimal(100)).quantize(0, ROUND_DOWN))
    return sorted((av - delta, av + delta))


def in_range(row, needle, stored):
    _, _, ns, bs, _, form, _, _ = row
    if form in ("abs_tol", "rel_tol"):
        bounds = tolerance(stored["a"], stored["b"], bs == "signed", form)
        if bounds is None or any(c in "xz" for c in needle):
            return "x"
        width = len(stored["a"])
        low, high = (ranges.word(v, width) for v in bounds)
    else:
        low, high = stored.get("lo"), stored.get("hi")
    checks = []
    if low is not None:
        checks.append(relation(needle, low, ns, bs, lambda a, b: a >= b))
    if high is not None:
        checks.append(relation(needle, high, ns, bs, lambda a, b: a <= b))
    if any(c in "xz" for c in needle):
        checks.append("x")
    return "0" if "0" in checks else "x" if "x" in checks else "1"


def member_results(row, needle, stored):
    results = [in_range(row, needle, stored)]
    if row[7] == "mixed":
        results += [wildcard(needle, stored[ranges.CARRIER[row[5]]], row[2], row[3]),
                    wildcard(needle, "1" * int(row[0]), row[2], row[3])]
    return "1" if "1" in results else "x" if "x" in results else "0"


class RangeOracle(unittest.TestCase):
    def test_every_selected_case_agrees_with_integer_intervals(self):
        for row in ranges.MODEL.select():
            case = ranges.make_case(row)
            raw = re.findall(r"^p(\d) raw=(\S)", case.expected, re.M)
            related = dict(re.findall(r"^p(\d) relation=(\S)", case.expected, re.M))
            self.assertEqual(len(raw), 4, case.name)
            for phase, result in raw:
                needle, _, stored = ranges.phase_inputs(row, int(phase))
                self.assertEqual(result, member_results(row, needle, stored), case.name)
                if phase in related:
                    self.assertEqual(related[phase], in_range(row, needle, stored), case.name)

    def test_unknown_low_bound_cases_keep_the_known_bound(self):
        # Then a range with one X comparison is X whether the two relations
        # are joined by && or any X comparison makes the range X.
        for row in ranges.MODEL.select():
            if row[5] == "closed" and row[6] in ("bound_x", "bound_z") and row[4] == "logic":
                high = ranges.operands(row)["hi"]
                for phase in range(4):
                    needle, _, _ = ranges.phase_inputs(row, phase)
                    self.assertEqual(relation(needle, high, row[2], row[3], lambda a, b: a <= b),
                                     "1", ranges.case_name(row))

    def test_signed_bounds_zero_extend_against_a_wider_unsigned_needle(self):
        row = ("33", "wide", "unsigned", "signed", "logic", "closed", "known", "single")
        stored = ranges.operands(row)
        needle = ranges.resize(stored["hi"], 34, True)
        self.assertEqual(ranges.membership(row, needle, stored), "0")
        self.assertEqual(ranges.membership(row, "0" + stored["hi"], stored), "1")
        signed = ("33", "wide", "signed", "signed", "logic", "closed", "known", "single")
        self.assertEqual(ranges.membership(signed, needle, stored), "1")

    def test_tolerance_bounds_swap_and_truncate_toward_zero(self):
        row = ("65", "same", "signed", "signed", "logic", "abs_tol", "known", "single")
        ops = ranges.operands(row)
        self.assertEqual([ranges.number(b, True) for b in ranges.tolerance_bounds(row, **ops)],
                         [-6, -2])
        row = ("65", "same", "signed", "signed", "logic", "rel_tol", "known", "single")
        ops = ranges.operands(row)
        self.assertEqual([ranges.number(b, True) for b in ranges.tolerance_bounds(row, **ops)],
                         [-34, -26])
        unsigned = ("65", "same", "unsigned", "unsigned", "logic", "rel_tol", "known", "single")
        ops = ranges.operands(unsigned)
        self.assertEqual([int(b, 2) for b in ranges.tolerance_bounds(unsigned, **ops)], [26, 34])
        unknown = (*row[:6], "bound_x", "single")
        stored = {k: ranges.two_state(v) for k, v in
                  ranges.with_unknown(unknown, ranges.operands(row)).items()}
        self.assertEqual([ranges.number(b, True) for b in ranges.tolerance_bounds(row, **stored)],
                         [-36, -28])

    def test_open_and_empty_ranges(self):
        row = ("32", "same", "unsigned", "unsigned", "logic", "reversed", "known", "single")
        stored = ranges.operands(row)
        for value in (0, 1, 2, 3, (1 << 32) - 1):
            self.assertEqual(ranges.range_result(row, ranges.word(value, 32), stored), "0")
        row = ("1", "wide", "signed", "signed", "logic", "low_open", "known", "single")
        stored = ranges.operands(row)
        self.assertEqual(ranges.range_result(row, "10", stored), "1")
        self.assertEqual(ranges.range_result(row, "00", stored), "0")
        self.assertEqual(ranges.range_result(row, "1x", stored), "x")

    def test_a_wildcard_value_outweighs_an_unknown_range(self):
        row = ("64", "same", "signed", "unsigned", "logic", "closed", "bound_x", "mixed")
        needle, _, stored = ranges.phase_inputs(row, 0)
        self.assertEqual(ranges.range_result(row, needle, stored), "x")
        self.assertEqual(ranges.membership(row, needle, stored), "1")
        single = (*row[:7], "single")
        self.assertEqual(ranges.membership(single, needle, stored), "x")


if __name__ == "__main__":
    unittest.main()
