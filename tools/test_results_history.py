"""Partial/local imports keep each simulator's real date, source and denominator."""

import copy
import io
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

    def test_prune_drops_simulators_without_a_runner_except_retired_ones(self):
        run = {**self.nightly, "simulators": {**self.nightly["simulators"],
                                              "nvc": {"name": "nvc"}, "other": {"name": "x"}}}
        history.save_json(self.directory / "history.json", {"runs": [run]})
        for sim in ("icarus", "nvc", "other"):
            history.save_json(self.directory / "latest" / f"{sim}.json", {"tests": {}})
        runs = history.prune(self.directory)
        self.assertEqual(list(runs[0]["simulators"]), ["icarus", "nvc"])
        saved = json.loads((self.directory / "history.json").read_text())
        self.assertNotIn("other", json.dumps(saved))
        self.assertEqual(sorted(p.stem for p in (self.directory / "latest").glob("*.json")),
                         ["icarus", "nvc"])

    def test_update_leaves_out_a_simulator_without_a_runner(self):
        history.save_json(self.directory / "history.json", {"runs": [self.nightly]})
        source = self.directory / "other.json"
        history.save_json(source, result("other", "Other", {"ch6/test_one": "pass"}))
        with mock.patch.object(history.suite_stats, "collect", return_value={
                "totals": {"tests": 1}, "chapters": {6: {"tests": 1}}}):
            run = history.update(self.directory, [source], "b" * 40, "", "2026-10-27T00:00:00Z")
        self.assertEqual(run["simulators"], {})
        self.assertFalse((self.directory / "latest" / "other.json").exists())

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
        japanese = history.latest_results_table(history.load_history(self.directory), language="ja")
        self.assertIn("| シミュレータ | バージョン | 実行 (UTC)", japanese)
        self.assertEqual(japanese.splitlines()[2:], table.splitlines()[2:])

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
        for name in ("status-retired.svg", "status-retired.ja.svg"):
            (self.directory / "charts" / name).write_text("<svg/>")
        history.render(self.directory, runs)
        report = (self.directory / "README.md").read_text()
        self.assertIn("[local result](https://example.test/local-result.json)", report)
        self.assertIn("(local)", report)
        self.assertIn("charts/chapters.svg?v=20261027T162103", report)
        self.assertIn("Icarus Verilog", report)
        self.assertIn("Ghost", report)
        self.assertNotIn("Retired Simulator", report)
        japanese = (self.directory / "README.ja.md").read_text()
        self.assertIn("[ローカル実行結果](https://example.test/local-result.json)", japanese)
        self.assertNotIn("Retired Simulator", japanese)
        for name in ("status-retired.svg", "status-retired.ja.svg"):
            self.assertFalse((self.directory / "charts" / name).exists())
        for path in (self.directory / "charts").glob("*.svg"):
            ET.parse(path)

    def test_bilingual_render_preserves_json_and_each_chart_has_localized_labels(self):
        self.import_local()
        runs = history.load_history(self.directory)
        before = copy.deepcopy(runs)
        paths = [self.directory / "history.json", *sorted((self.directory / "latest").glob("*.json"))]
        raw = {path: path.read_bytes() for path in paths}
        history.render(self.directory, runs)
        self.assertEqual(runs, before)
        self.assertEqual({path: path.read_bytes() for path in paths}, raw)
        english = (self.directory / "README.md").read_text()
        japanese = (self.directory / "README.ja.md").read_text()
        for report in (english, japanese):
            self.assertIn("[English](README.md) / [日本語](README.ja.md)", report)
            self.assertIn("2026-10-26 00:00", report)
            self.assertIn("2026-10-27 16:21", report)
            self.assertIn("| local | 1 (50.0%)", report)
            self.assertIn("| nightly | 1 (100.0%)", report)
        self.assertIn("charts/chapters.svg?v=20261027T162103", english)
        self.assertIn("charts/chapters.ja.svg?v=20261027T162103", japanese)
        for name in ("overview", "rate", "chapters", "status-icarus", "status-ghost"):
            for suffix in ("", ".ja"):
                self.assertTrue((self.directory / "charts" / f"{name}{suffix}.svg").is_file())
        chapter = (self.directory / "charts/chapters.ja.svg").read_text()
        for value in ("章別の一致テスト数", "データ型", "スイート aaaaaaa / nightly",
                      "スイート bbbbbbb / local", "0/1  0%"):
            self.assertIn(value, chapter)
        status = (self.directory / "charts/status-ghost.ja.svg").read_text()
        self.assertIn("一致 (pass)", status)
        self.assertIn("不一致 (fail)", status)
        self.assertEqual(history.test_count_y_max(history.load_history(self.directory)), 1000)
        for name in ("overview.svg", "overview.ja.svg", "status-ghost.svg", "status-ghost.ja.svg"):
            root = ET.fromstring((self.directory / "charts" / name).read_text())
            self.assertIn("1000", [node.text for node in root.iter("{http://www.w3.org/2000/svg}text")])

    def test_the_test_count_charts_end_at_the_next_thousand_above_the_most_tests(self):
        info = lambda **counts: {"counts": {"pass": 0, "fail": 0, **counts}}
        run = lambda tests, **sims: {"tests": tests, "simulators": sims}
        self.assertEqual(history.test_count_y_max([]), 1000)
        self.assertEqual(history.test_count_y_max([run(999)]), 1000)
        self.assertEqual(history.test_count_y_max([run(12000)]), 13000)
        self.assertEqual(history.test_count_y_max([run(10510), run(12268)]), 13000)
        self.assertEqual(history.test_count_y_max(
            [run(12268, icarus=info(**{"pass": 9000, "fail": 5001}))]), 15000)

    def test_japanese_changes_and_summaries_keep_raw_reasons_statuses_and_counts(self):
        reasons = ["value x != 0; 42.0ns", 'raw | <value> "日本語"', "feature_not_supported"]
        now = result("ghost", "Ghost", {"ch6/recovered": "pass", "ch6/failed": "fail",
                     "ch6/known": "known", "ch6/unsupported": "unsupported", "ch6/new": "pass"})
        for test, reason in zip(("ch6/failed", "ch6/known", "ch6/unsupported"), reasons):
            now["tests"][test]["reason"] = reason
        before = {"ch6/recovered": "fail", "ch6/failed": "pass", "ch6/known": "pass",
                  "ch6/unsupported": "pass", "ch6/removed": "pass"}
        run = {**self.nightly, "tests": 5, "simulators": {"ghost": history.summarize(now, before)}}
        original = copy.deepcopy(run)
        changes = history.changes_section(run, language="ja")
        for reason in reasons:
            self.assertIn(reason, changes)
        for code in ("fail", "known", "unsupported"):
            self.assertIn(f"({code})", changes)
        text = history.change_text(run["simulators"]["ghost"]["changes"], "ja")
        for expected in ("新たに一致 1件", "一致しなくなったテスト 3件", "新規テスト 1件（一致 1件）",
                         "削除されたテスト 1件"):
            self.assertIn(expected, text)
        self.assertIn("2 (40.0%)", history.latest_table(run, "ja"))
        english = history.summary(run)
        japanese = history.summary(run, language="ja")
        self.assertIn("## Nightly results", english)
        self.assertIn("## 夜間実行結果", japanese)
        self.assertIn("テスト5件", japanese)
        for reason in reasons:
            self.assertIn(reason, english)
            self.assertIn(reason, japanese)
        self.assertEqual(run, original)
        svg = history.stacked_chart("ステータス別の結果", "全ステータスの凡例", [run], "ghost", "ja")
        root = ET.fromstring(svg)
        labels = [node for node in root.iter("{http://www.w3.org/2000/svg}text")
                  if node.get("y") == "74.0"]
        self.assertEqual(len(labels), 4)
        for left, right in zip(labels, labels[1:]):
            # A full-width glyph at 12px is roughly twice an ASCII glyph.
            width = sum(12 if ord(c) > 127 else 7 for c in left.text)
            self.assertLess(float(left.get("x")) + width, float(right.get("x")) - 18)

    def test_cli_job_summary_includes_english_and_collapsible_japanese(self):
        output = io.StringIO()
        args = ["results_history.py", "update", "--history", str(self.directory),
                "--suite-commit", "a" * 40, "--time", self.nightly["time"], "fixture.json"]
        with mock.patch.object(history.sys, "argv", args), \
             mock.patch.object(history, "update", return_value=self.nightly), \
             mock.patch.object(history.sys, "stdout", output):
            self.assertEqual(history.main(), 0)
        shown = output.getvalue()
        self.assertTrue(shown.startswith(history.summary(self.nightly)))
        self.assertIn("<details>\n<summary>日本語</summary>", shown)
        self.assertIn(history.summary(self.nightly, "ja"), shown)


if __name__ == "__main__":
    unittest.main()
