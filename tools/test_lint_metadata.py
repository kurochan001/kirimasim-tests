"""The rules of lint_metadata.py for empty fields, the regular expression of
an illegal test and names that more than one test has, and the comparison
with the baseline of known problems."""

from pathlib import Path
import tempfile
import unittest
from unittest import mock

import lint_metadata as lint
import suite_results

LEGAL = """/*
:name: {name}
:description: d
:tags: {chapter}
:type: simulation
:lrm: 1800-2023 {clause}
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: ok
*/
module m; initial $display("ok"); endmodule
"""
ILLEGAL = """/*
:name: {name}
:description: d
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: r
:expected_stderr_regex: {regex}
*/
module m; endmodule
"""


class Rules(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name).resolve()

    def write(self, test: str, text: str) -> Path:
        path = self.root / "tests" / f"{test}.sv"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def legal(self, test: str, name: str | None = None) -> Path:
        chapter = test.split("/")[-2]
        return self.write(test, LEGAL.format(name=name or test.split("/")[-1], chapter=chapter,
                                             clause=chapter.removeprefix("ch") + ".1"))

    def rules(self, path: Path) -> list[str]:
        return [rule for rule, _ in lint.check(path)]

    def test_a_complete_test_has_no_problem(self):
        self.assertEqual(lint.check(self.legal("ch6/test_a")), [])
        self.assertEqual(lint.check(self.write(
            "ch6/test_b", ILLEGAL.format(name="test_b", regex=r"test_b\.sv:14:"))), [])

    def test_a_field_without_a_value_is_reported(self):
        # The header parser would read ":tags: ch6" as the description.
        path = self.write("ch6/test_a", LEGAL.format(name="test_a", chapter="ch6", clause="6.1")
                          .replace(":description: d", ":description:   "))
        self.assertEqual(suite_results.header(path)["description"], ":tags: ch6")
        problems = dict(lint.check(path))
        self.assertEqual(problems["empty-field"], ":description: has no value")
        last = self.write("ch6/test_c", LEGAL.format(name="test_c", chapter="ch6", clause="6.1")
                          .replace(":expected_stdout: ok", ":expected_stdout:"))
        self.assertIn("empty-field", self.rules(last))

    def test_a_regex_that_does_not_compile_is_reported(self):
        path = self.write("ch6/test_a", ILLEGAL.format(name="test_a", regex=r"test_a\.sv:(14:"))
        problems = dict(lint.check(path))
        self.assertIn("does not compile", problems["stderr-regex"])
        self.assertNotIn("empty-field", problems)
        # An empty field is reported once, as empty, not as a regex.
        empty = self.write("ch6/test_b", ILLEGAL.format(name="test_b", regex=""))
        self.assertIn("empty-field", self.rules(empty))
        self.assertNotIn("stderr-regex", self.rules(empty))

    def test_a_name_of_two_tests_is_reported_for_both(self):
        paths = [self.legal("ch6/test_a"), self.legal("ch8/test_a"), self.legal("ch8/test_b"),
                 self.legal("gen/ch9/test_c", name="test_b")]
        with mock.patch.object(suite_results, "ROOT", self.root):
            problems = lint.duplicate_names(lint.names_of(paths))
        self.assertEqual(problems, {
            "ch6/test_a": ":name: test_a is also in ch8/test_a",
            "ch8/test_a": ":name: test_a is also in ch6/test_a",
            "ch8/test_b": ":name: test_b is also in gen/ch9/test_c",
            "gen/ch9/test_c": ":name: test_b is also in ch8/test_b"})

    def test_distinct_names_are_not_reported(self):
        paths = [self.legal("ch6/test_a"), self.legal("ch8/test_b")]
        with mock.patch.object(suite_results, "ROOT", self.root):
            self.assertEqual(lint.duplicate_names(lint.names_of(paths)), {})


class Baseline(unittest.TestCase):
    CHECKED = {"ch6/test_a", "ch6/test_b"}

    def test_a_line_without_a_count_is_one_problem(self):
        self.assertEqual(lint.parse_baseline("# c\nch6/test_a width\nch6/test_b width 3\n\n"),
                         {"ch6/test_a width": 1, "ch6/test_b width": 3})

    def test_a_malformed_or_repeated_line_is_an_error(self):
        for text in ("ch6/test_a\n", "ch6/test_a width 0\n", "ch6/test_a width x\n",
                     "ch6/test_a width 1 2\n", "ch6/test_a width\nch6/test_a width 2\n"):
            with self.assertRaises(ValueError, msg=text):
                lint.parse_baseline(text)

    def test_the_written_baseline_is_read_back_with_its_counts(self):
        found = {"ch6/test_b width": ["line 3", "line 4"], "ch6/test_a todo": ["TODO"]}
        self.assertEqual(lint.parse_baseline(lint.format_baseline(found)),
                         {"ch6/test_a todo": 1, "ch6/test_b width": 2})

    def test_a_second_problem_of_a_known_rule_in_the_same_test_is_new(self):
        found = {"ch6/test_a width": ["line 3: comment of 90 columns",
                                      "line 9: code of 120 columns"]}
        new, known, gone = lint.compare(found, {"ch6/test_a width": 1}, self.CHECKED)
        self.assertEqual(new, ["ch6/test_a width (2 found, 1 known): "
                               "line 3: comment of 90 columns; line 9: code of 120 columns"])
        self.assertEqual((known, gone), ([], []))

    def test_the_known_number_of_problems_is_known(self):
        found = {"ch6/test_a width": ["line 3", "line 9"]}
        new, known, gone = lint.compare(found, {"ch6/test_a width": 2}, self.CHECKED)
        self.assertEqual((new, gone), ([], []))
        self.assertEqual(known, ["KNOWN ch6/test_a width: line 3; line 9"])

    def test_an_unlisted_problem_is_new(self):
        new, known, gone = lint.compare({"ch6/test_a todo": ["TODO"]}, {}, self.CHECKED)
        self.assertEqual((new, known, gone), (["ch6/test_a todo: TODO"], [], []))

    def test_fewer_problems_than_listed_are_gone_for_checked_tests_only(self):
        baseline = {"ch6/test_a width": 2, "ch6/test_b width": 1, "ch7/test_c width": 1}
        new, known, gone = lint.compare({"ch6/test_a width": ["line 3"]}, baseline, self.CHECKED)
        self.assertEqual(new, [])
        self.assertEqual(known, ["KNOWN ch6/test_a width: line 3"])
        self.assertEqual(len(gone), 2)
        self.assertIn("GONE ch6/test_a width:", gone[0])
        self.assertIn("lists 2 but 1 found", gone[0])
        self.assertIn("GONE ch6/test_b width:", gone[1])

    def test_the_baseline_of_the_suite_is_well_formed(self):
        baseline = lint.read_baseline()
        self.assertTrue(baseline)
        self.assertTrue(all(count >= 1 for count in baseline.values()))


if __name__ == "__main__":
    unittest.main()
