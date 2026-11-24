"""Check the final timestamps of extended VCD files after Ghost exits."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tests/ch21/test_evcd_close_waits_for_finish_even_when_dumping_is_paused.sv"
SOURCE_ENV = "GHOST_SIMULATOR"
SCALE_FS = {"s": 10**15, "ms": 10**12, "us": 10**9, "ns": 10**6, "ps": 10**3, "fs": 1}


@unittest.skipUnless(os.environ.get(SOURCE_ENV), "set GHOST_SIMULATOR to run Ghost")
class GhostEvcdClosure(unittest.TestCase):
    def test_active_and_paused_dumps_close_at_finish_time(self):
        simulator = Path(os.environ[SOURCE_ENV]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            run = subprocess.run(
                [str(simulator), "--quiet-all", "--lrm-strict", "-top", SOURCE.stem, str(SOURCE)],
                cwd=temporary, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(run.returncode, 0, run.stderr or run.stdout)
            self.assertEqual(run.stdout.splitlines(), [
                "closed before finish active=0 paused=0",
                "explicit finish=29",
            ])
            for name, last_event_ns in (("active.evcd", 11), ("paused.evcd", 6)):
                with self.subTest(file=name):
                    waveform = (Path(temporary) / name).read_text(encoding="utf-8")
                    self.assert_close(waveform, last_event_ns)

    def assert_close(self, waveform: str, last_event_ns: int) -> None:
        scale = re.search(r"\$timescale\s+(\d+)\s*(s|ms|us|ns|ps|fs)\s+\$end", waveform)
        self.assertIsNotNone(scale, "missing EVCD timescale")
        tick_fs = int(scale[1]) * SCALE_FS[scale[2]]
        last_event = max(map(int, re.findall(r"(?m)^\s*#(\d+)\s*$", waveform)), default=-1)
        self.assertEqual(last_event * tick_fs, last_event_ns * SCALE_FS["ns"])
        close = re.findall(r"(?m)^\s*\$vcdclose\s+#(\d+)\s+\$end", waveform)
        self.assertEqual([int(tick) * tick_fs for tick in close], [29 * SCALE_FS["ns"]])
        self.assertRegex(waveform, r"\$vcdclose\s+#\d+\s+\$end\s*\Z")
