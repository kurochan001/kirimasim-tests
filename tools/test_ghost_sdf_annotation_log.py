"""Check the log produced by Ghost for an explicit SDF annotation log path."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostSdfAnnotationLog(unittest.TestCase):
    def test_log_records_both_annotated_paths(self):
        fixture = ROOT / "tests/ch32/test_sdf_log_file_records_each_annotated_path.sv"
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [str(simulator), "--quiet", "--lrm-strict", str(fixture)],
                cwd=directory,
                capture_output=True,
                text=True,
                timeout=90,
            )
            self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
            self.assertIn("a=3 b=7", result.stdout.splitlines())
            log = Path(directory) / "selected_annotation.log"
            self.assertTrue(log.is_file(), "the requested SDF annotation log was not written")
            entries = log.read_text(encoding="utf-8").splitlines()

        first = {i for i, entry in enumerate(entries) if "destination_a" in entry}
        second = {i for i, entry in enumerate(entries) if "destination_b" in entry}
        self.assertTrue(
            bool(first and second and len(first | second) >= 2),
            "the log needs an entry for each annotated path:\n" + "\n".join(entries),
        )
