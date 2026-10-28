"""Exercise the FST runner with a fake simulator and the committed fixture."""

import sys
import tempfile
import unittest
from pathlib import Path

import fst_reader
import run_fst


ROOT = Path(__file__).resolve().parent.parent
FIXTURE = ROOT / "tools" / "fixtures" / "fst" / "simple.fst"
EXPECTED = ROOT / "tools" / "fixtures" / "fst" / "simple.expected"


class FstRunnerTests(unittest.TestCase):
    def setUp(self):
        self.source = fst_reader.find_source()
        if self.source is None:
            self.skipTest("libfst source not found; set LIBFST_SRC")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.test = self.root / "tests/ch21/test_fake_fst.sv"
        self.test.parent.mkdir(parents=True)
        self.expected = self.test.parent / "fake.fst.expected"
        self.expected.write_text(EXPECTED.read_text(encoding="utf-8"), encoding="utf-8")
        self.write_test()
        self.simulator = self.root / "fake-simulator"
        self.simulator.write_text(
            f"#!{sys.executable}\n"
            "import shutil, sys\n"
            f"shutil.copy({str(FIXTURE)!r}, 'wave.fst')\n"
            "print('done')\n")
        self.simulator.chmod(0o755)

    def write_test(self):
        fields = "\n".join([
            ":name: test_fake_fst",
            ":description: fake FST runner test",
            ":tags: ch21",
            ":type: simulation",
            ":lrm: 1800-2023 21.7.1",
            ":oracle: spec",
            ":spec_check: ai",
            ":fourstate: no",
            ":nondeterministic: no",
            ":expected_stdout: done",
            ":fst_file: wave.fst",
            ":fst_times: 0 10",
            ":fst_expected: @fake.fst.expected",
        ])
        self.test.write_text(
            f"/*\n{fields}\n*/\nmodule test_fake_fst; endmodule\n",
            encoding="utf-8")

    def test_runner_compares_the_fst_file(self):
        self.assertEqual(run_fst.run(self.test, str(self.simulator), str(self.source)),
                         ("pass", ""))

    def test_runner_reports_a_different_fst(self):
        self.expected.write_text("nope\n", encoding="utf-8")
        status, reason = run_fst.run(self.test, str(self.simulator), str(self.source))
        self.assertEqual(status, "fail")
        self.assertTrue(reason.startswith("FST differs"))

    def test_selection_requires_fst_expected(self):
        self.assertEqual(run_fst.fst_tests([self.test]), [self.test])
        other = self.test.parent / "test_other.sv"
        other.write_text("/*\n:name: test_other\n*/\n", encoding="utf-8")
        self.assertEqual(run_fst.fst_tests([self.test, other]), [self.test])


if __name__ == "__main__":
    unittest.main()
