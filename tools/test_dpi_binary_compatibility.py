"""Run one precompiled DPI-C library with Ghost and Verilator."""

import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

from run_verilator import ROOT, execute


FIXTURE = ROOT / "tests/ch35/test_dpi_import_output_inout.sv"


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR") and os.environ.get("GHOST_INCLUDE"),
                     "set GHOST_SIMULATOR and GHOST_INCLUDE for a cross-simulator check")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared library")
class DpiBinaryCompatibility(unittest.TestCase):
    def test_compiled_dpi_c_library_runs_in_both_simulators(self):
        ghost = str(Path(os.environ["GHOST_SIMULATOR"]).resolve())
        include = Path(os.environ["GHOST_INCLUDE"]).resolve()
        verilator = shutil.which(os.environ.get("VERILATOR", "verilator"))
        if verilator is None:
            self.skipTest("Verilator executable unavailable")
        verilator = str(Path(verilator).resolve())
        expected = FIXTURE.with_suffix(".expected").read_text(encoding="utf-8")
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            lib = directory / ("portable.dylib" if sys.platform == "darwin" else "portable.so")
            build = subprocess.run(
                [
                    os.environ.get("CC", "cc"), "-shared", "-fPIC",
                    f"-I{include}", "-o", str(lib), str(FIXTURE.with_suffix(".c")),
                ],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            binary_hash = hashlib.sha256(lib.read_bytes()).digest()
            ghost_run = subprocess.run(
                [ghost, "--quiet", "--lrm-strict", "--lib", str(lib), str(FIXTURE)],
                cwd=directory, capture_output=True, text=True, timeout=90,
            )
            self.assertEqual(ghost_run.returncode, 0, ghost_run.stderr or ghost_run.stdout)
            self.assertTrue(ghost_run.stdout.startswith(expected), ghost_run.stdout)
            self.assertEqual(hashlib.sha256(lib.read_bytes()).digest(), binary_hash)

            # Pass the prebuilt library to the linker. C source is compiled only once.
            result = execute(
                [
                    verilator, "--binary", "--timing", "-Wno-fatal",
                    "--top-module", FIXTURE.stem, "--prefix", "Vportable",
                    "--Mdir", "obj", "-LDFLAGS", "../" + lib.name, str(FIXTURE),
                ],
                timeout=180, cwd=temporary,
            )
            self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
            # The linker records the relative library name when its install name
            # is unspecified. Resolve it from the model's build directory.
            verilator_run = subprocess.run(
                [str(directory / "obj/Vportable")], cwd=directory / "obj",
                capture_output=True, text=True, timeout=90,
            )
            self.assertEqual(verilator_run.returncode, 0,
                             verilator_run.stderr or verilator_run.stdout)
            self.assertTrue(verilator_run.stdout.startswith(expected), verilator_run.stdout)
            self.assertEqual(hashlib.sha256(lib.read_bytes()).digest(), binary_hash)
