import copy
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import suite_results
import sv2023_features as sf


def root_with_tests(directory):
    root = Path(directory).resolve()
    (root / "tests" / "ch8").mkdir(parents=True)
    (root / "tests" / "ch8" / "test_a.sv").write_text(
        "/*\n:name: test_a\n:oracle: spec iverilog@13.0\n:expected_stdout: ok\n*/\nmodule m; endmodule\n",
        encoding="utf-8")
    (root / "tests" / "ch8" / "test_illegal_b.sv").write_text(
        "/*\n:name: test_illegal_b\n:oracle: spec\n:should_fail_because: x\n*/\nmodule m; endmodule\n",
        encoding="utf-8")
    (root / "coverage" / "results").mkdir(parents=True)
    (root / "coverage" / "behaviors.json").write_text(json.dumps({"requirements": [
        {"id": "SV2023-8.11-EXTRACT-X", "checks": [{"test": "tests/ch8/test_a.sv"}]},
        {"id": "SV2023-8.11-EXTRACT-Y", "checks": []}]}), encoding="utf-8")
    return root


FEATURE = {"key": "type_this", "title": {"en": "type(this)", "ja": "type(this)"}, "listed_in": "dvcon",
           "clauses": ["8.11"], "requirements": ["SV2023-8.11-EXTRACT-X", "SV2023-8.11-EXTRACT-Y"],
           "illegal_forms": [{"clause": "8.11", "en": "outside a class", "ja": "クラスの外"}],
           "tests": [{"test": "ch8/test_a", "illegal": False}, {"test": "ch8/test_illegal_b", "illegal": True}]}


class Features(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = root_with_tests(self.tmp.name)
        patcher = mock.patch.object(suite_results, "ROOT", self.root)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.addCleanup(self.tmp.cleanup)

    def test_a_valid_ledger_and_its_counts(self):
        ledger = {"schema": 1, "features": [FEATURE]}
        self.assertEqual(sf.validate(ledger, self.root), [])
        digest = suite_results.input_digest(self.root / "tests" / "ch8" / "test_a.sv")
        with mock.patch.object(suite_results, "runner_digest", return_value="r"):
            (self.root / "coverage" / "results" / "x-icarus13.json").write_text(json.dumps(
                {"simulator": "icarus", "runner_sha256": "r", "tests": {
                    "ch8/test_a": {"status": "pass", "inputs_sha256": digest},
                    "ch8/test_illegal_b": {"status": "pass", "inputs_sha256": "old"}}}), encoding="utf-8")
            passes = sf.saved_passes(self.root, {"ch8/test_a", "ch8/test_illegal_b"})
        self.assertEqual(passes["icarus"], {"ch8/test_a"})
        text = sf.render(ledger, "en", passes, {"SV2023-8.11-EXTRACT-X"}, self.root)
        self.assertIn("| [type(this)](#type-this) | 8.11 | 2 | 1 | 1 | 1 | 1 | 1 |", text)
        self.assertIn("| 1/2 |", text)
        self.assertIn("`SV2023-8.11-EXTRACT-Y` (-)", text)

    def test_problems_are_reported(self):
        for change in ({"listed_in": "blog"}, {"clauses": ["clause eight"]},
                       {"requirements": ["SV2023-UNKNOWN"]},
                       {"tests": [{"test": "ch8/test_a", "illegal": True}]},
                       {"tests": [{"test": "ch8/test_illegal_b", "illegal": False}]},
                       {"tests": [{"test": "ch8/test_missing", "illegal": False}]}):
            with self.subTest(change=change):
                feature = copy.deepcopy(FEATURE)
                feature.update(change)
                self.assertTrue(sf.validate({"schema": 1, "features": [feature]}, self.root))
        self.assertTrue(sf.validate({"schema": 1, "features": [FEATURE, FEATURE]}, self.root))


if __name__ == "__main__":
    unittest.main()
