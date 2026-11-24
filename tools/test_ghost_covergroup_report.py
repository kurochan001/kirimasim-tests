"""Check per-bin hits in Ghost's exported covergroup report."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostCovergroupReport(unittest.TestCase):
    def run_fixture(self, test_name: str, directory: str, *options: str) -> str:
        test = ROOT / "tests" / "ch19" / (test_name + ".sv")
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        result = subprocess.run(
            [str(simulator), "--quiet", "--lrm-strict", str(test), *options],
            cwd=directory,
            capture_output=True,
            text=True,
            timeout=90,
        )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        return result.stdout

    def bin_hits(self, test_name: str) -> dict[str, dict[str, tuple[int, bool]]]:
        with tempfile.TemporaryDirectory() as directory:
            report = Path(directory) / "coverage.json"
            self.run_fixture(test_name, directory, "--save-coverage", str(report))
            data = json.loads(report.read_text(encoding="utf-8"))

        groups = [group for group in data["covergroups"] if group["name"] == "monitor"]
        self.assertEqual(len(groups), 1)
        return {
            point["name"]: {item["name"]: (item["hitCount"], item["counted"]) for item in point["bins"]}
            for point in groups[0]["coverpoints"]
        }

    def test_unmatched_values_and_abandoned_transitions(self):
        hits = self.bin_hits("test_default_bins_with_failed_and_pending_transition_paths")
        self.assertEqual(hits["values"], {"expected_values": (7, True), "unmatched_value": (2, False)})
        self.assertEqual(
            hits["transitions"],
            {
                "long_path": (0, True),
                "short_paths": (2, True),
                "wait_path": (1, True),
                "unmatched_transition": (2, False),
            },
        )

    def test_pending_transition_does_not_hit_the_default(self):
        hits = self.bin_hits("test_default_transition_bin_ignores_a_pending_nonconsecutive_match")
        self.assertEqual(hits["transitions"], {"wait_path": (1, True), "unmatched_transition": (0, False)})

    def test_select_database_filename_and_load_both_types(self):
        case = "test_coverage_db_name_and_type_data_across_two_runs"
        with tempfile.TemporaryDirectory() as directory:
            self.run_fixture(case, directory, "+save_named_database")
            chosen = Path(directory) / "chosen_coverage.json"
            self.assertTrue(chosen.is_file(), "coverage database was not written to the selected filename")
            self.assertGreater(chosen.stat().st_size, 0)
            self.assertFalse((Path(directory) / "unused_coverage.json").exists())

            output = self.run_fixture(case, directory, "+load_named_database")
            expected = (ROOT / "tests" / "ch19" / (case + ".expected")).read_text(encoding="utf-8")
            measures = [line for line in output.splitlines(keepends=True) if line.startswith("four=")]
            self.assertEqual("".join(measures), expected)
