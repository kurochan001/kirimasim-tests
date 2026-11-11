"""A test name is unique among all generators, not only within one."""

from pathlib import Path
import sys
import types
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import common


def generator(name: str, chapter: int, *cases: str):
    made = [common.Case(name=case, description="d", lrm="11.4", comment="c",
                        body="module m; endmodule", expected="ok\n") for case in cases]
    return types.SimpleNamespace(NAME=name, VERSION="1", CHAPTER=chapter, cases=lambda: made)


class Names(unittest.TestCase):
    def test_distinct_names_give_one_test_and_one_expected_file_each(self):
        files = common.outputs([generator("one", 11, "test_gen_a"), generator("two", 11, "test_gen_b")])
        self.assertEqual(sorted(p.name for p in files),
                         ["test_gen_a.expected", "test_gen_a.sv", "test_gen_b.expected", "test_gen_b.sv"])

    def test_a_name_of_two_generators_fails(self):
        # In the same chapter the second would overwrite the first silently;
        # in another chapter two tests would have the same :name:.
        for chapter in (11, 12):
            with self.assertRaisesRegex(ValueError, "duplicate test name test_gen_a: generators one and two"):
                common.outputs([generator("one", 11, "test_gen_a"), generator("two", chapter, "test_gen_a")])

    def test_a_name_twice_in_one_generator_fails(self):
        with self.assertRaisesRegex(ValueError, "duplicate test name test_gen_a: generators one and one"):
            common.outputs([generator("one", 11, "test_gen_a", "test_gen_a")])


if __name__ == "__main__":
    unittest.main()
