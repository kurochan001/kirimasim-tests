"""The rules of lint_metadata.py for empty fields, the regular expression of
an illegal test and names that more than one test has."""

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


if __name__ == "__main__":
    unittest.main()
