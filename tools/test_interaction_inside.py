"""Check membership using completion enumeration rather than comparison code."""

from itertools import product, permutations
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_inside as inside


def completed_comparison(needle, member, needle_sign, set_sign):
    width = max(len(needle), len(member))
    signed = needle_sign == set_sign == "signed"
    left = (needle[0] if signed else "0") * (width - len(needle)) + needle
    right = (member[0] if signed else "0") * (width - len(member)) + member
    # Complete each extended unknown bit separately. Four-state equality
    # deliberately has no knowledge of correlations between repeated X bits.
    choices = [(c,) if c in "01" else ("0", "1") for c in left]
    results = [all(r in "xz" or a == r for a, r in zip(bits, right))
               for bits in product(*choices)]
    return "1" if all(results) else "0" if not any(results) else "x"


class MembershipOracle(unittest.TestCase):
    def test_single_members_agree_with_completion_enumeration(self):
        words = ["".join(bits) for width in (1, 2, 3) for bits in product("01xz", repeat=width)]
        for needle in words:
            for member in words:
                for ns, ss in product(("unsigned", "signed"), repeat=2):
                    expected = completed_comparison(needle, member, ns, ss)
                    self.assertEqual(inside.membership(needle, [member], ns, ss), expected,
                                     (needle, member, ns, ss))

    def test_or_is_per_comparison_and_independent_of_member_order(self):
        # Covering every possible binary completion is not a definite match:
        # x ==? 0 and x ==? 1 are each X, hence their four-state OR is X.
        self.assertEqual(inside.membership("x", ["0", "1"], "unsigned", "unsigned"), "x")
        for order in permutations(["11", "1x", "00"]):
            self.assertEqual(inside.membership("1z", list(order), "unsigned", "unsigned"), "1")
        self.assertEqual(inside.membership("0x", ["10", "11"], "unsigned", "unsigned"), "0")
        self.assertEqual(inside.membership("xz", [], "signed", "signed"), "0")

    def test_width_sign_and_rhs_wildcard_extension_are_distinct(self):
        self.assertEqual(inside.membership("1", ["11"], "signed", "signed"), "1")
        self.assertEqual(inside.membership("1", ["11"], "signed", "unsigned"), "0")
        self.assertEqual(inside.membership("111", ["x1"], "signed", "signed"), "1")
        self.assertEqual(inside.membership("111", ["x1"], "signed", "unsigned"), "0")
        self.assertEqual(inside.membership("xx", ["01"], "signed", "signed"), "x")

    def test_set_storage_converts_unknowns_before_matching(self):
        logic = ("1", "same", "unsigned", "unsigned", "logic", "list", "1", "rhs_z")
        binary = (*logic[:4], "bit", *logic[5:])
        needle, supplied, stored = inside.inputs(logic, 1)
        self.assertEqual((needle, supplied, stored), ("1", ["z"], ["z"]))
        self.assertEqual(inside.membership(needle, stored, "unsigned", "unsigned"), "1")
        needle, supplied, stored = inside.inputs(binary, 1)
        self.assertEqual((needle, supplied, stored), ("1", ["z"], ["0"]))
        self.assertEqual(inside.membership(needle, stored, "unsigned", "unsigned"), "0")


if __name__ == "__main__":
    unittest.main()
