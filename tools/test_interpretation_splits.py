import copy
import tempfile
import unittest
from pathlib import Path

import interpretation_splits as isp


def ledger_root(directory):
    root = Path(directory)
    (root / "tests" / "ch7").mkdir(parents=True)
    (root / "tests" / "ch7" / "test_x.sv").write_text("module m; endmodule\n", encoding="utf-8")
    (root / "docs").mkdir()
    for name in ("review.md", "review.en.md"):
        (root / "docs" / name).write_text('# R\n\n<a id="contested"></a>\n\n## C\n', encoding="utf-8")
    return root


ENTRY = {"test": "ch7/test_x", "kind": "contested", "clauses": ["7.3"],
         "readings": {"ja": {"a": "読み方の一つ", "b": "もう一つの読み方"},
                      "en": {"a": "One reading", "b": "The other reading"}},
         "expectation_follows": "a", "source": {"document": "docs/review.md", "anchor": "contested"},
         "proposal": None, "status": "unresolved", "resolution": None}


class Ledger(unittest.TestCase):
    def test_a_complete_entry_is_valid_and_rendered_in_both_languages(self):
        with tempfile.TemporaryDirectory() as directory:
            root = ledger_root(directory)
            ledger = {"schema": 1, "entries": [ENTRY]}
            self.assertEqual(isp.validate(ledger, root), [])
            ja, en = isp.render(ledger, "ja"), isp.render(ledger, "en")
            self.assertIn("もう一つの読み方", ja)
            self.assertIn("[review.en](review.en.md#contested)", en)
            self.assertNotIn("読み方", en)
            self.assertEqual([l for l in ja.splitlines() if l.startswith("#")].__len__(),
                             [l for l in en.splitlines() if l.startswith("#")].__len__())

    def test_missing_parts_are_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            root = ledger_root(directory)
            cases = {"test": "ch7/test_missing", "kind": "unclear", "status": "done",
                     "expectation_follows": "c", "clauses": []}
            for field, value in cases.items():
                with self.subTest(field=field):
                    entry = copy.deepcopy(ENTRY)
                    entry[field] = value
                    self.assertTrue(isp.validate({"schema": 1, "entries": [entry]}, root))
            entry = copy.deepcopy(ENTRY)
            entry["source"]["anchor"] = "elsewhere"
            self.assertTrue(isp.validate({"schema": 1, "entries": [entry]}, root))
            entry = copy.deepcopy(ENTRY)
            entry["readings"]["en"]["b"] = ""
            self.assertTrue(isp.validate({"schema": 1, "entries": [entry]}, root))
            entry = copy.deepcopy(ENTRY)
            entry["status"] = "resolved"
            self.assertTrue(isp.validate({"schema": 1, "entries": [entry]}, root))
            entry["resolution"] = {"commit": "abc1234", "date": "2026-11-20", "ja": "直した", "en": "Fixed"}
            self.assertEqual(isp.validate({"schema": 1, "entries": [entry]}, root), [])
            self.assertTrue(isp.validate({"schema": 1, "entries": [ENTRY, ENTRY]}, root))


if __name__ == "__main__":
    unittest.main()
