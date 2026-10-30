"""Check case-inside selection with integer comparisons and a linear search."""

from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import interaction_case_inside as cases
from test_interaction_range import relation, wildcard


def item(row, expr, stored, index):
    es, its, first = row[2], row[3], row[5]
    if index == 1:
        return wildcard(expr, stored["second"], es, its)
    if index == 2:
        return wildcard(expr, stored["third"], es, its)
    if first == "range":
        checks = [relation(expr, stored["lo"], es, its, lambda a, b: a >= b),
                  relation(expr, stored["hi"], es, its, lambda a, b: a <= b)]
        return "0" if "0" in checks else "x" if "x" in checks else "1"
    names = {"value": ["first"], "array": ["arr0", "arr1"], "list": ["first", "alt"]}[first]
    results = [wildcard(expr, stored[n], es, its) for n in names]
    return "1" if "1" in results else "x" if "x" in results else "0"


def search(row, expr, stored):
    """Return the item a linear search selects (0 for default) and the matches."""
    results = [item(row, expr, stored, i) for i in range(3)]
    matches = [i + 1 for i, r in enumerate(results) if r == "1"]
    return (matches[0] if matches else 0), matches


class CaseInsideOracle(unittest.TestCase):
    def test_every_selected_case_agrees_with_a_linear_search(self):
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            _, stored = cases.stored_values(row)
            lines = re.findall(r"^p(\d) expr=(\S+) r=(\d) sel=(\d)(?: probe(?:_seen)?=(\d))?$",
                               case.expected, re.M)
            self.assertEqual(len(lines), 4, case.name)
            for _, expr, r, sel, probe in lines:
                choice, matches = search(row, expr, stored)
                self.assertEqual(int(r), choice, (case.name, expr))
                self.assertEqual(sel, "1", case.name)
                self.assertEqual(probe == "", row[8] == "variable", case.name)
                if row[7] == "unique0":
                    self.assertLessEqual(len(matches), 1, (case.name, expr))
                    if probe:
                        self.assertEqual(probe, "1", case.name)
                elif probe:
                    # A normal case stops at the first match, so the third
                    # item is evaluated only when the first two do not match.
                    self.assertEqual(probe, str(int(choice in (0, 3))), case.name)

    def test_an_unknown_result_moves_on_to_a_later_item(self):
        row = ("64", "same", "unsigned", "unsigned", "logic", "range", "item_x", "plain", "call")
        _, stored = cases.stored_values(row)
        expr = stored["second"]
        self.assertEqual(item(row, expr, stored, 0), "x")
        self.assertEqual(search(row, expr, stored)[0], 2)
        self.assertIn(expr, cases.expressions(row))

    def test_an_unknown_case_expression_bit_is_not_a_wildcard(self):
        row = ("32", "same", "unsigned", "unsigned", "logic", "value", "expr_x", "plain", "call")
        _, stored = cases.stored_values(row)
        for expr in cases.expressions(row):
            self.assertTrue(expr.endswith("x"))
            self.assertEqual(search(row, expr, stored)[0], 0)
        wild = ("32", "same", "unsigned", "unsigned", "logic", "value", "item_x", "plain", "call")
        _, stored = cases.stored_values(wild)
        self.assertEqual(item(wild, stored["first"][:-1] + "0", stored, 0), "1")
        self.assertEqual(item(wild, stored["first"][:-1] + "1", stored, 0), "1")

    def test_a_signed_item_zero_extends_against_a_wider_unsigned_expression(self):
        row = ("33", "wide", "unsigned", "signed", "logic", "array", "known", "plain", "variable")
        _, stored = cases.stored_values(row)
        trap = cases.resize(stored["arr1"], 34, True)
        self.assertEqual(search(row, trap, stored)[0], 0)
        self.assertEqual(search(row, "0" + stored["arr1"], stored)[0], 1)
        self.assertIn(trap, cases.expressions(row))

    def test_bit_storage_turns_an_unknown_item_bit_into_zero(self):
        row = ("64", "narrow", "signed", "unsigned", "bit", "list", "item_z", "unique0", "variable")
        given, stored = cases.stored_values(row)
        self.assertIn("z", given["alt"])
        self.assertEqual(stored["alt"], given["alt"].replace("z", "0"))


if __name__ == "__main__":
    unittest.main()
