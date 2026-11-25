"""Check the closing timestamps in completed extended VCD files."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


CHAPTER = Path(__file__).resolve().parent.parent / "tests/ch21"


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostEvcdClose(unittest.TestCase):
    def capture_traces(self, fixture: str, filenames: tuple[str, ...]) -> dict[str, str]:
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        source = CHAPTER / fixture
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            result = subprocess.run(
                [str(simulator), "--quiet", "--lrm-strict", str(source)],
                cwd=directory, capture_output=True, text=True, timeout=90,
            )
            self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
            expected = source.with_suffix(".expected").read_text(encoding="utf-8")
            self.assertTrue(result.stdout.startswith(expected), result.stdout)
            traces = {}
            for filename in filenames:
                trace = directory / filename
                self.assertTrue(trace.is_file(), f"no trace at {filename}")
                traces[filename] = trace.read_text(encoding="ascii")
        return traces

    def check_trace(self, data: str, *, last_change: int, close_time: int) -> None:
        # The closing time is separate from the last port value change time.
        self.assertEqual(len(re.findall(r"(?m)^\s*\$vcdclose\b", data)), 1)
        self.assertRegex(data, rf"(?m)^\s*\$vcdclose\s+#{close_time}\s+\$end\s*\Z")
        current_time = None
        changes = []
        for line in data.splitlines():
            timestamp = re.fullmatch(r"\s*#([0-9]+)\s*", line)
            if timestamp:
                current_time = int(timestamp[1])
            if re.fullmatch(r"\s*p\S+\s+[0-7]\s+[0-7]\s+<\s*[0-9]+\s*", line):
                changes.append(current_time)
        self.assertTrue(changes, "no port value changes found")
        self.assertEqual(changes[-1], last_change)

    def test_vcdclose_records_end_even_after_changes_stop(self):
        traces = self.capture_traces(
            "test_evcd_dumps_whole_port_when_connected_to_slice_and_expression.sv",
            ("whole_ports.evcd",),
        )
        self.check_trace(traces["whole_ports.evcd"], last_change=4, close_time=17)

    def test_finish_finalizes_active_and_paused_files(self):
        traces = self.capture_traces(
            "test_evcd_close_waits_for_finish_even_when_dumping_is_paused.sv",
            ("active.evcd", "paused.evcd"),
        )
        self.check_trace(traces["active.evcd"], last_change=11, close_time=29)
        self.check_trace(traces["paused.evcd"], last_change=6, close_time=29)

    def test_queue_drain_finalizes_file_at_last_scheduled_event(self):
        traces = self.capture_traces(
            "test_evcd_close_records_final_time_when_queue_drains.sv",
            ("drained.evcd",),
        )
        self.check_trace(traces["drained.evcd"], last_change=4, close_time=21)
