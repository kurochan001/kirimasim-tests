"""Run the same precompiled DPI libraries with Ghost and Verilator."""

import os
from pathlib import Path
import shutil
import sys
import unittest

from run_dpi_binary_compatibility import CASES, run_case
from suite_results import ROOT


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR") and os.environ.get("GHOST_INCLUDE"),
                     "set GHOST_SIMULATOR and GHOST_INCLUDE for a cross-simulator check")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared library")
class DpiBinaryCompatibility(unittest.TestCase):
    def test_compiled_dpi_c_library_runs_in_both_simulators(self):
        self.check_shared_library("test_dpi_import_output_inout")

    def test_packed_dimensions_and_sized_array_share_a_binary(self):
        self.check_shared_library("test_dpi_packed_dims_linearized_row_major")

    def test_multiword_bit_and_logic_ports_share_a_binary(self):
        self.check_shared_library("test_dpi_svdpi_scalar_and_chunk_types")

    def test_registered_fixtures_share_their_binaries_across_simulators(self):
        for case in CASES:
            with self.subTest(case=case):
                self.check_shared_library(Path(case).name)

    def check_shared_library(self, fixture_name):
        fixture = ROOT / "tests/ch35" / f"{fixture_name}.sv"
        ghost = str(Path(os.environ["GHOST_SIMULATOR"]).resolve())
        include = Path(os.environ["GHOST_INCLUDE"]).resolve()
        verilator = shutil.which(os.environ.get("VERILATOR", "verilator"))
        if verilator is None:
            self.skipTest("Verilator executable unavailable")
        verilator = str(Path(verilator).resolve())
        result = run_case(fixture, ghost, verilator, os.environ.get("CC", "cc"), include,
                          os.environ.get("CXX", "c++"))
        self.assertEqual([f"{part}={status}" for part, status in result["checks"].items()
                          if status != "pass"], [])
