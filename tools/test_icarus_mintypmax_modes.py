"""Check the three explicit Icarus min/typ/max selections."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / (
    "tests/ch11/test_mintypmax_uses_positional_alternatives_across_contexts.sv"
)
SELECTIONS = {
    "min": "choice=13 procedural=7 net=21 path=17",
    "typ": "choice=5 procedural=4 net=8 path=3",
    "max": "choice=9 procedural=19 net=11 path=12",
}


@unittest.skipUnless(os.environ.get("IVERILOG_BIN"), "set IVERILOG_BIN to the Icarus bin directory")
class IcarusMinTypMaxModes(unittest.TestCase):
    def test_options_select_positions_in_every_context(self):
        binary = Path(os.environ["IVERILOG_BIN"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            for mode, expected in SELECTIONS.items():
                with self.subTest(mode=mode):
                    image = Path(temporary) / f"{mode}.vvp"
                    build = subprocess.run(
                        [str(binary / "iverilog"), "-g2012", "-gspecify", f"-T{mode}",
                         "-s", SOURCE.stem, "-o", str(image), str(SOURCE)],
                        cwd=temporary, capture_output=True, text=True, timeout=60,
                    )
                    self.assertEqual(build.returncode, 0, build.stderr or build.stdout)
                    run = subprocess.run(
                        [str(binary / "vvp"), str(image), "+record_selection"],
                        cwd=temporary, capture_output=True, text=True, timeout=60,
                    )
                    self.assertEqual(run.returncode, 0, run.stderr or run.stdout)
                    self.assertEqual(run.stdout.splitlines(), [expected, "consistent=1"])
