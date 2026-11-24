"""Verify that the selected Ghost log receives the VPI output channel."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


FIXTURE = (Path(__file__).resolve().parent.parent
           / "tests/ch38/test_vpi_printf_return_counts.sv")


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR") and os.environ.get("GHOST_INCLUDE"),
                     "set GHOST_SIMULATOR and GHOST_INCLUDE to run Ghost with VPI")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared library")
class GhostVpiOutputLog(unittest.TestCase):
    def test_printf_reaches_output_and_current_log(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        include = Path(os.environ["GHOST_INCLUDE"]).resolve() / "sukimasim/vpi"
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            library = directory / "output_probe.so"
            linker = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            build = subprocess.run(
                [
                    os.environ.get("CC", "cc"), "-shared", "-fPIC", *linker,
                    f"-I{include}", "-o", str(library), str(FIXTURE.with_suffix(".c")),
                ],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            log = directory / "active.log"
            result = subprocess.run(
                [
                    str(simulator), "--quiet", "--lrm-strict", "--logfile", str(log),
                    "--lib", str(library), str(FIXTURE),
                ],
                cwd=directory, capture_output=True, text=True, timeout=90,
            )
            self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
            self.assertTrue(log.is_file(), "the requested log was not created")
            expected = FIXTURE.with_suffix(".expected").read_text(encoding="utf-8")
            self.assertIn(expected, result.stdout)
            logged = log.read_text(encoding="utf-8")
            self.assertIn("design: done\n", logged)
            self.assertIn(expected, logged)
