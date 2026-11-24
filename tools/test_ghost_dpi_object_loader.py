"""Exercise Ghost's DPI compiler diagnostics and foreign object loading."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


CHAPTER = Path(__file__).resolve().parent.parent / "tests/ch35"
FIXTURE = CHAPTER / "test_dpi_resolves_imports_from_two_foreign_objects.sv"


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostDpiDiagnostics(unittest.TestCase):
    def test_legacy_version_compile_time_diagnostic(self):
        fixture = CHAPTER / "test_legacy_dpi_packed_whole_array_transfer.sv"
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [str(simulator), "--quiet", "--lrm-strict", "--parse-only", str(fixture)],
                cwd=directory,
                capture_output=True,
                text=True,
                timeout=90,
            )
        self.assertGreaterEqual(result.returncode, 0, "the compiler crashed")
        messages = result.stdout + result.stderr
        self.assertRegex(
            messages,
            r"(?is)\A(?=.*\b(?:warning|error)\b)(?=.*\bDPI\b)(?=.*\bDPI-C\b)"
            r"(?=.*deprecat)(?=.*\bC\b.{0,45}(?:application|code|source).{0,180}"
            r"(?:chang|adapt|update|modif))",
        )


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared-library compiler")
class GhostDpiObjectLoader(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.working = Path(temp.name)
        self.library_root = self.working / "foreign objects"
        self.library_root.joinpath("nested").mkdir(parents=True)
        self.simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()

        self.extension = ".dylib" if sys.platform == "darwin" else ".so"
        for side in ("left", "right"):
            path = self.library_root / "nested" / f"libfixture_{side}{self.extension}"
            build = subprocess.run(
                [
                    os.environ.get("CC", "cc"), "-shared", "-fPIC",
                    f"-DSV_LOADER_{side.upper()}", "-o", str(path), str(FIXTURE.with_suffix(".c")),
                ],
                cwd=self.working,
                capture_output=True,
                text=True,
                timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)

    def check_load(self, cwd: Path, arguments: list[str], order: list[str]) -> None:
        run = subprocess.run(
            [str(self.simulator), "--quiet", "--lrm-strict", *arguments, str(FIXTURE)],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=90,
        )
        self.assertEqual(run.returncode, 0, run.stderr or run.stdout)
        lines = [
            line for line in run.stdout.splitlines()
            if line.startswith(("loaded ", "from left="))
        ]
        expected = FIXTURE.with_suffix(".expected").read_text(encoding="utf-8").splitlines()
        self.assertEqual(lines, [*(f"loaded {side}" for side in order), *expected])

    def test_explicit_file_names_with_default_and_selected_root(self):
        left = f"nested/libfixture_left{self.extension}"
        right = f"nested/libfixture_right{self.extension}"
        with self.subTest(root="default"):
            self.check_load(
                self.library_root,
                ["-sv_lib", left, "-sv_lib", right, "-sv_lib", left],
                ["left", "right"],
            )
        with self.subTest(root="selected"):
            self.check_load(
                self.working,
                ["-sv_root", str(self.library_root), "-sv_lib", str(self.library_root / right),
                 "-sv_lib", left],
                ["right", "left"],
            )

    def test_relative_paths_from_working_directory_and_duplicate_library(self):
        self.check_load(
            self.library_root,
            ["-sv_lib", "nested/libfixture_left", "-sv_lib", "nested/libfixture_right",
             "-sv_lib", "nested/libfixture_left"],
            ["left", "right"],
        )

    def test_selected_root_and_absolute_path_without_extensions(self):
        self.check_load(
            self.working,
            ["-sv_root", str(self.library_root),
             "-sv_lib", str(self.library_root / "nested/libfixture_right"),
             "-sv_lib", "nested/libfixture_left"],
            ["right", "left"],
        )

    def test_bootstrap_order_and_direct_duplicate(self):
        bootstrap = self.working / "bootstrap.txt"
        bootstrap.write_text(
            "#!SV_LIBRARIES\n"
            "  nested/libfixture_left\n"
            "   # Paths omit the platform extension.\n"
            "  nested/libfixture_right  \n",
            encoding="utf-8",
        )
        self.check_load(
            self.working,
            ["-sv_root", str(self.library_root), "-sv_liblist", str(bootstrap),
             "-sv_lib", str(self.library_root / "nested/libfixture_right")],
            ["left", "right"],
        )
