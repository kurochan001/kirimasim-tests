"""Both README languages must track the same inventory and fail on stale data."""

import contextlib
import io
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import suite_stats


class BilingualStatsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name, fields in (
            ("tests/ch4/test_a.sv", ":oracle: spec iverilog@13.0 verilator@5.052\n:spec_check: human"),
            ("tests/ch16/test_b.sv", ":oracle: spec\n:should_fail_because: illegal"),
            ("tests/gen/ch11/test_c.sv", ":oracle: spec verilator@5.052\n:generator: width_sign@1"),
        ):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("/*\n" + fields + "\n*/\n", encoding="utf-8")
        self.stats = suite_stats.collect(self.root)

    def test_languages_share_inventory_counts_and_all_chapters(self):
        english = suite_stats.markdown(self.stats)
        japanese = suite_stats.markdown(self.stats, "ja")
        self.assertEqual(self.stats["totals"]["tests"], 3)
        self.assertEqual(set(suite_stats.CHAPTERS_JA), set(suite_stats.CHAPTERS))
        for text in (english, japanese):
            rows = [line.split("|") for line in text.splitlines() if line.startswith("| ")]
            chapter_rows = {int(row[1]): [cell.strip() for cell in row[3:-1]]
                            for row in rows if row[1].strip().isdigit()}
            self.assertEqual(len(chapter_rows), 38)
            self.assertEqual(chapter_rows[4], ["1", "1", "", ""])
            self.assertEqual(chapter_rows[11], ["1", "", "1", ""])
            self.assertEqual(chapter_rows[16], ["1", "", "", "1"])
            self.assertEqual(chapter_rows[34], ["—", "", "", ""])
        self.assertIn("**3 tests** in 3 chapters", english)
        self.assertIn("3章にわたり**3本のテスト**", japanese)
        self.assertIn("`width_sign`が1本", japanese)
        self.assertIn("1本は人が規格と照合済み", japanese)

    def test_japanese_drift_is_rejected_and_update_preserves_both_prose_sections(self):
        readmes = tuple((self.root / name, lang) for name, lang in
                        (("README.md", "en"), ("README.ja.md", "ja")))
        for path, language in readmes:
            section = suite_stats.markdown(self.stats, language) if language == "en" else "stale\n"
            path.write_text("intro\n" + suite_stats.BEGIN + "\n" + section
                            + suite_stats.END + "\nconclusion\n", encoding="utf-8")
        before = {path: path.read_bytes() for path, _ in readmes}
        with mock.patch.object(suite_stats, "READMES", readmes), \
                mock.patch.object(suite_stats, "collect", return_value=self.stats):
            output = io.StringIO()
            with mock.patch("sys.argv", ["suite_stats.py", "--check"]), contextlib.redirect_stdout(output):
                self.assertEqual(suite_stats.main(), 1)
            self.assertIn("README.ja.md is out of date", output.getvalue())
            self.assertNotIn("README.md is out of date", output.getvalue())
            self.assertEqual(before, {path: path.read_bytes() for path, _ in readmes})
            with mock.patch("sys.argv", ["suite_stats.py", "--update"]):
                self.assertEqual(suite_stats.main(), 0)
            with mock.patch("sys.argv", ["suite_stats.py", "--check"]):
                self.assertEqual(suite_stats.main(), 0)
        for path, language in readmes:
            text = path.read_text(encoding="utf-8")
            self.assertTrue(text.startswith("intro\n"))
            self.assertTrue(text.endswith("\nconclusion\n"))
            self.assertIn(suite_stats.markdown(self.stats, language), text)

    def test_japanese_without_human_review_does_not_claim_it(self):
        self.stats["totals"]["human"] = 0
        text = suite_stats.markdown(self.stats, "ja")
        self.assertIn("人による照合はまだありません", text)
        self.assertNotIn("本は人が規格と照合済み", text)


if __name__ == "__main__":
    unittest.main()
