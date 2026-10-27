"""Partial/local imports keep each simulator's real date, source and denominator."""

import copy
import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path
from unittest import mock

import results_history as history


def result(simulator, name, tests):
    return {"simulator": simulator, "name": name, "version": f"{name} build 123456789abc",
            "tests": {test: {"status": status} for test, status in tests.items()}}


class ResultsHistoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.nightly = {
            "time": "2026-10-26T00:00:00Z", "suite_commit": "a" * 40,
            "run_url": "https://example.test/nightly", "tests": 1, "chapters": {"6": 1},
            "simulators": {"icarus": history.summarize(
                result("icarus", "Icarus Verilog", {"ch6/test_one": "pass"}), None)},
        }
        self.ghost = result("ghost", "Ghost", {"ch6/test_one": "pass", "ch9/test_two": "fail"})

    def import_local(self):
        history.save_json(self.directory / "history.json", {"runs": [self.nightly]})
        source = self.directory / "guest.json"
        history.save_json(source, self.ghost)
        with mock.patch.object(history.suite_stats, "collect", return_value={
                "totals": {"tests": 2}, "chapters": {6: {"tests": 1}, 9: {"tests": 1}}}):
            return history.update(self.directory, [source], "b" * 40,
                                  "https://example.test/local-result.json",
                                  "2026-10-27T16:21:03Z", source="local")

    def test_local_import_preserves_the_previous_real_run(self):
        before = copy.deepcopy(self.nightly)
        imported = self.import_local()
        runs = history.load_history(self.directory)
        self.assertEqual(runs[0], before)
        self.assertEqual(imported["source"], "local")
        self.assertEqual(set(imported["simulators"]), {"ghost"})
        latest = json.loads((self.directory / "latest/ghost.json").read_text())
        self.assertEqual(latest["source"], "local")
        self.assertEqual(latest["suite_commit"], "b" * 40)
        self.assertEqual(latest["tests"], {"ch6/test_one": "pass", "ch9/test_two": "fail"})

    def test_latest_table_keeps_each_actual_source_date_and_test_count(self):
        self.import_local()
        table = history.latest_results_table(history.load_history(self.directory))
        icarus = next(line for line in table.splitlines() if "Icarus Verilog" in line)
        ghost = next(line for line in table.splitlines() if "| Ghost |" in line)
        self.assertIn("2026-10-26 00:00", icarus)
        self.assertIn("| nightly | 1 (100.0%)", icarus)
        self.assertIn("a" * 40, icarus)
        self.assertIn("2026-10-27 16:21", ghost)
        self.assertIn("| local | 1 (50.0%)", ghost)
        self.assertIn("b" * 40, ghost)

    def test_chapter_image_keeps_older_simulators_with_explicit_provenance(self):
        self.import_local()
        svg = (self.directory / "charts/chapters.svg").read_text()
        ET.fromstring(svg)
        for text in ("Icarus Verilog", "Ghost", "2026-10-26 00:00 UTC",
                     "2026-10-27 16:21 UTC", "Suite aaaaaaa / nightly", "Suite bbbbbbb / local"):
            self.assertIn(text, svg)
        self.assertIn("0/1  0%", svg)

    def test_report_marks_local_link_and_filters_retired_simulators(self):
        self.import_local()
        runs = history.load_history(self.directory)
        runs[0]["simulators"]["retired"] = history.summarize(
            result("retired", "Retired Simulator", {"ch6/test_one": "pass"}), None)
        history.render(self.directory, runs)
        report = (self.directory / "README.md").read_text()
        self.assertIn("[local result](https://example.test/local-result.json)", report)
        self.assertIn("(local)", report)
        self.assertIn("charts/chapters.svg?v=20261027T162103", report)
        self.assertIn("Icarus Verilog", report)
        self.assertIn("Ghost", report)
        self.assertNotIn("Retired Simulator", report)
        for path in (self.directory / "charts").glob("*.svg"):
            ET.parse(path)


if __name__ == "__main__":
    unittest.main()
