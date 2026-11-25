"""Validate the Annex J stimulus and the observed load-order comparison."""

from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import run_ghost_dpi_load as loader
import suite_results


class GhostDpiLoadTests(unittest.TestCase):
    def test_bootstrap_file_has_magic_and_one_path_per_entry(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "first.libs"
            loader.write_bootstrap(path, [Path("nested/first"), Path("nested/second")])
            self.assertEqual(path.read_text().splitlines(), [
                "#!SV_LIBRARIES", " nested/first", "# A comment may start in column one.",
                "   # Indentation is allowed.", "   nested/second  ",
            ])
            loader.write_bootstrap(path, [])
            self.assertEqual(path.read_text(), "#!SV_LIBRARIES\n")

    def test_root_switch_and_mixed_file_alias_point_at_intended_objects(self):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            root = work / "DPI objects"
            (root / "nested").mkdir(parents=True)
            objects = {letter: root / "nested" / f"libannex_j_{letter}.so" for letter in "abcd"}
            for name, path in objects.items():
                path.write_text(name)
            scenarios = {name: (cwd, args) for name, cwd, args in
                         loader.annex_invocations(work, root, objects, "bacd")}
            cwd, before = scenarios["root_switch_order"]
            self.assertEqual(before[:5], ["-sv_lib", "nested/libbefore_root", "-sv_root", str(root), "-sv_lib"])
            self.assertTrue((cwd / "nested/libbefore_root.so").samefile(objects["b"]))
            self.assertFalse((root / "nested/libbefore_root.so").exists())
            self.assertIn(str(work / "libannex_j_c"), (work / "second.libs").read_text())
            self.assertTrue((work / "libannex_j_c.so").samefile(objects["c"]))
            _, mixed = scenarios["bootstrap_before_direct"]
            self.assertLess(mixed.index("-sv_lib"), mixed.index("-sv_liblist"))
            self.assertTrue((root / "nested/libannex_j_alias.so").samefile(objects["a"]))

    def test_load_records_must_appear_once_in_order_before_correct_dpi_output(self):
        case = next(iter(loader.CASES))
        fixture = suite_results.ROOT / "tests" / f"{case}.sv"
        output = suite_results.expected_output(fixture)
        first, second = "loaded Annex J a\n", "loaded Annex J b\n"
        with patch.object(loader.subprocess, "run") as run:
            run.return_value = subprocess.CompletedProcess([], 0, first + second + output, "")
            self.assertEqual(loader.invocation(Path("ghost"), fixture, fixture.parent, [], "ab"), "pass")
            for lines in (second + first, first + second + first):
                run.return_value = subprocess.CompletedProcess([], 0, lines + output, "")
                self.assertEqual(loader.invocation(Path("ghost"), fixture, fixture.parent, [], "ab"),
                                 "load_order_or_dpi_output_differs")


if __name__ == "__main__":
    unittest.main()
