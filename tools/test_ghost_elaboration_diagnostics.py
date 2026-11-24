"""Check both selected elaboration errors in one Ghost invocation."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


FIXTURE = (Path(__file__).resolve().parent.parent / "tests/ch20"
           / "test_elaboration_runs_both_selected_errors_before_stopping_simulation.sv")


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostElaborationDiagnostics(unittest.TestCase):
    def test_both_diagnostics_appear_without_simulation(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            result = subprocess.run(
                [str(simulator), "--quiet", "--lrm-strict", str(FIXTURE)],
                cwd=temporary, capture_output=True, text=True, timeout=60,
            )
        messages = re.sub(r"\x1b\[[0-9;]*m", "", result.stdout + result.stderr)
        self.assertGreater(result.returncode, 0, messages)
        self.assertNotIn("SIMULATION_STARTED", messages.splitlines())

        source = FIXTURE.read_text(encoding="utf-8").splitlines()
        for marker in ("FIRST_FAILURE_MARKER", "SECOND_FAILURE_MARKER"):
            line = next(i for i, text in enumerate(source, 1) if f'"{marker}"' in text)
            with self.subTest(marker=marker):
                self.assertRegex(
                    messages,
                    rf"(?i){re.escape(FIXTURE.name)}:{line}:(?:\d+:)?"
                    rf"[^\n]*\berror\b[^\n]*\b{marker}\b",
                )
