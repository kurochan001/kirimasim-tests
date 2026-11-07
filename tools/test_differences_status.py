"""The report of the listed differences on master: which tests count for which
simulator, short forms, patterns, and the states of the run."""

import json
import subprocess
import sys
import tempfile
from pathlib import Path
import unittest

import differences_status as status

LIST = """# Where the releases differ

Intro that names Icarus Verilog 13.0 and Verilator 5.052 and `ch1/test_intro`.

## Icarus Verilog 13.0

### Results

| Clause | What it does | Tests |
| --- | --- | --- |
| 1.1 | Something. | `ch1/test_ica`, [the test](../tests/ch1/test_icb.sv) |
| 1.2 | Something else. | `gen/ch2/test_gen_cond_07`, `_08` |
| 1.3 | A family. | the `gen/ch2/test_gen_fam_{one,two}_*` tests |
| 1.4 | Out of date. | `ch1/test_both_oracles` |

## Verilator 5.052

### Results

- `ch1/test_ver` differs, and `ch1/test_gone` is named but is no test.

## 2026-11-03: dated additions

- Verilator 5.052 alone: `ch1/test_dated_v`.
- Icarus 13.0 and Verilator 5.052 both: `ch1/test_dated_both`.
- Neither named: `ch1/test_dated_none`.

## A test whose expected output followed both releases

- `ch1/test_history`
"""

LIST_JA = LIST.replace("### Results", "### 結果").replace("## 2026-11-03: dated additions",
                                                           "## 2026-11-03：日付の追加")

ORACLES = {
    "ch1/test_ica": "spec verilator@5.052",
    "ch1/test_icb": "spec verilator@5.052",
    "gen/ch2/test_gen_cond_07": "spec verilator@5.052",
    "gen/ch2/test_gen_cond_08": "spec verilator@5.052",
    "gen/ch2/test_gen_fam_one_a": "spec",
    "gen/ch2/test_gen_fam_two_b": "spec",
    "gen/ch2/test_gen_fam_three_c": "spec",
    "ch1/test_both_oracles": "spec iverilog@13.0 verilator@5.052",
    "ch1/test_ver": "spec iverilog@13.0",
    "ch1/test_dated_v": "spec",
    "ch1/test_dated_both": "spec iverilog@13.0",
    "ch1/test_dated_none": "spec verilator@5.052",
    "ch1/test_history": "spec",
    "ch1/test_intro": "spec",
}

ICARUS = {"ch1/test_ica": "pass", "ch1/test_icb": "known", "gen/ch2/test_gen_cond_07": "known",
          "gen/ch2/test_gen_cond_08": "pass", "gen/ch2/test_gen_fam_one_a": "pass",
          "gen/ch2/test_gen_fam_two_b": "known", "ch1/test_both_oracles": "pass",
          "ch1/test_dated_none": "pass", "ch1/test_history": "known",
          "ch1/test_dated_v": "known"}
VERILATOR = {"ch1/test_ver": "pass", "ch1/test_dated_v": "known", "ch1/test_dated_both": "known",
             "ch1/test_history": "pass"}


class Report(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for name, oracle in ORACLES.items():
            path = self.root / "tests" / f"{name}.sv"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(f"/*\n:name: {name.split('/')[-1]}\n:oracle: {oracle}\n*/\nmodule m; endmodule\n",
                            encoding="utf-8")
        (self.root / "docs").mkdir()
        (self.root / status.LIST).write_text(LIST, encoding="utf-8")
        (self.root / status.LIST_JA).write_text(LIST_JA, encoding="utf-8")

    def found(self):
        headings, entries = status.read_list(LIST)
        return headings, status.classify(self.root, entries, {"icarus": ICARUS, "verilator": VERILATOR})

    def test_tests_count_for_the_simulator_of_their_item(self):
        _, found = self.found()
        icarus, verilator = found["simulators"]["icarus"], found["simulators"]["verilator"]
        self.assertEqual(sorted(icarus["match"]), ["ch1/test_dated_none", "ch1/test_ica", "gen/ch2/test_gen_cond_08"])
        self.assertEqual(sorted(icarus["differ"]), ["ch1/test_history", "ch1/test_icb", "gen/ch2/test_gen_cond_07"])
        self.assertEqual(sorted(verilator["match"]), ["ch1/test_history", "ch1/test_ver"])
        self.assertEqual(sorted(verilator["differ"]), ["ch1/test_dated_both", "ch1/test_dated_v"])

    def test_the_title_and_unnamed_lines_go_by_oracle(self):
        _, found = self.found()
        # The intro names both simulators before any heading: it is not an item.
        for sim in found["simulators"].values():
            self.assertFalse(any("test_intro" in t for s in ("match", "differ", "missing") for t in sim[s]))
        # A line that names neither simulator counts for the release its :oracle: leaves out.
        self.assertIn("ch1/test_dated_none", found["simulators"]["icarus"]["match"])
        self.assertNotIn("ch1/test_dated_none", found["simulators"]["verilator"]["differ"])

    def test_patterns_are_groups(self):
        _, found = self.found()
        heading, members = found["simulators"]["icarus"]["patterns"]["gen/ch2/test_gen_fam_{one,two}_*"]
        self.assertEqual(members, ["gen/ch2/test_gen_fam_one_a", "gen/ch2/test_gen_fam_two_b"])
        self.assertEqual(found["simulators"]["verilator"]["patterns"], {})

    def test_items_to_check(self):
        _, found = self.found()
        self.assertEqual(sorted(found["not_tests"]), ["ch1/test_gone"])
        self.assertEqual(sorted(found["simulators"]["icarus"]["oracle"]), ["ch1/test_both_oracles"])
        self.assertEqual(found["simulators"]["verilator"]["oracle"], {})

    def test_a_named_test_that_did_not_run(self):
        statuses = dict(ICARUS)
        del statuses["ch1/test_icb"]
        _, entries = status.read_list(LIST)
        found = status.classify(self.root, entries, {"icarus": statuses})
        self.assertEqual(list(found["simulators"]["icarus"]["missing"]), ["ch1/test_icb"])

    def test_labels_and_anchors(self):
        headings, _ = self.found()
        self.assertEqual(headings[1], ("Results", "Icarus Verilog 13.0 › Results"))
        self.assertEqual(status.slugs([h for h, _ in headings])[:4],
                         ["icarus-verilog-130", "results", "verilator-5052", "results-1"])
        self.assertEqual(status.slugs(["2026-11-03：日付の追加"]), ["2026-11-03日付の追加"])

    def test_both_reports_from_the_command(self):
        for name, tests in (("icarus", ICARUS), ("verilator", VERILATOR)):
            (self.root / f"{name}.json").write_text(json.dumps(
                {"name": name, "version": f"{name} devel", "time": "2026-11-07T06:16:14Z",
                 "suite_commit": "0123456789abcdef", "tests": tests}), encoding="utf-8")
        run = subprocess.run([sys.executable, str(Path(status.__file__)), "--icarus", str(self.root / "icarus.json"),
                              "--verilator", str(self.root / "verilator.json"), "--output", str(self.root / "out"),
                              "--root", str(self.root), "--source-url", "https://example.org/r/blob/abc"],
                             capture_output=True, text=True)
        self.assertEqual(run.returncode, 0, run.stderr)
        english = (self.root / "out" / status.REPORT).read_text(encoding="utf-8")
        japanese = (self.root / "out" / status.REPORT_JA).read_text(encoding="utf-8")
        self.assertIn("| Icarus Verilog | icarus devel | 2026-11-07 06:16 | [`0123456`]"
                      "(https://example.org/r/commit/0123456789abcdef) | 6 | 3 | 3 | 0 |", english)
        self.assertIn("### Now match (3)", english)
        self.assertIn("(https://example.org/r/blob/abc/docs/simulator-differences.md#results)", english)
        self.assertIn("| `gen/ch2/test_gen_fam_{one,two}_*` |", english)
        self.assertIn("| 2 | 1 | 1 | 0 |", english)
        self.assertIn("### 一致した (3)", japanese)
        self.assertIn("(https://example.org/r/blob/abc/docs/simulator-differences.ja.md#結果)", japanese)
        self.assertIn("[2026-11-03：日付の追加](https://example.org/r/blob/abc/docs/simulator-differences.ja.md"
                      "#2026-11-03日付の追加)", japanese)

    def test_a_missing_results_file_leaves_the_simulator_out(self):
        (self.root / "icarus.json").write_text(json.dumps(
            {"name": "icarus", "version": "v", "time": "2026-11-07T06:16:14Z", "tests": ICARUS}), encoding="utf-8")
        run = subprocess.run([sys.executable, str(Path(status.__file__)), "--icarus", str(self.root / "icarus.json"),
                              "--verilator", str(self.root / "none.json"), "--output", str(self.root / "out"),
                              "--root", str(self.root)], capture_output=True, text=True)
        self.assertEqual(run.returncode, 0, run.stderr)
        english = (self.root / "out" / status.REPORT).read_text(encoding="utf-8")
        self.assertIn("| Verilator | no results |", english)
        self.assertNotIn("## Verilator", english)


if __name__ == "__main__":
    unittest.main()
